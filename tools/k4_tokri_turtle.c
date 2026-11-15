/* K4 (15 Nov 2026) - TOKRI (JasTokriEA tk2 ke qaide) ka tez engine. Chalata hai: tools/k4_tokri_turtle.py
   Hukm: docs/k4-fable-hukm.md. Ye sirf user ke tareeqe ka TEST hai - kisi EA mein grid/hedge NAHI daala.

   Sab hisaab INT mein: qeemat cent (bid), paisa "cu" = unit x cent (1 unit = 0.01 lot; 100 cu = 1 USC).
   BUY ask (bid+SP) par khulti, bid par band; SELL bid par khulti, ask par band (hukm 6.3).
   EA ka Work() har "tick" par lafz-ba-lafz (tick() neeche); candle ke andar qeemat lagataar chalti hai
   (raasta PATH), aur engine sirf un qeematon par rukta hai jahan kuch ho sakta hai (zone()).
   Jaanch: tools/k4_tokri_turtle.py ref = wahi qaide Python mein cent-ba-cent; nateeja lot-ba-lot barabar aana chahiye.

   bars file: int64 n; int64 t[n] (UTC sec); int32 o[n],h[n],l[n],c[n] (cent); int32 sd[n] (session din, 1970 se din);
              int16 yr[n] (session saal); int8 dow[n] (session din ka hafta-din, Peer=0)
   rukh file: int8 r[n]  (+1 BUY bhari, -1 SELL bhari, 0 = rukh nahi)
   args: key=value (neeche par()). stdout: S (khulasa), Y (saal), H (aakhri hadd), D file (roz), L file (har lot). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>
#include <limits.h>

typedef long long i64;
#define MAXP 256

typedef struct { int dir, u, open, tp; i64 seq, swap, topen; int bk; } Pos;
static Pos P[MAXP];
static int n = 0, N = 0, G = 0;
static i64 K = 0, SW = 0, bal, seqc = 0;

/* qaide (tk2 inputs) */
static int SP = 24, STEP = 200, TP = 100, MAXT = 30, UH = 2, UL = 1, MODE = 0, NEUT = 1, C2 = 0, PATH = 0;
static i64 BC = 50, BARD = 190000, HADD = 380000, EQ0 = 3800000, MINSEC = 10, BARSEC = 60, SWAPL = 0, SWAPS = 0;
static int RESTART = 1;      /* 1 = hadd ke baad agle session din naye sire se; 0 = hamesha ke liye STOP */
static int BMODE = 0;        /* CLOSE ALL ka NET: 0 = tk2 (sirf khuli lots), 1 = tokri ka kul hisaab (is daur ke band munafe + khula) */
static int NOTP = 0;         /* 1 = lot ka TP nahi, sirf CLOSE ALL (Q21 lafz-ba-lafz) */
static i64 cyc = 0;          /* is tokri (khali se ab tak) ka band hisaab */

/* haal */
static int rk = 0, lastnz = 0, halt = 0, ZU = INT_MAX, ZD = INT_MIN, tpend = 0;
static i64 anc2 = 0, lastopen = -1000000000LL, curt = 0;
static int basket = 0;

/* ginti */
static i64 peak, mineq, maxdd = 0, minfl = 0, ntp = 0, sumtp = 0, nbc = 0, sumbc = 0, nstop = 0, sumstop = 0, nc2 = 0, sumc2 = 0;
static i64 lots = 0, swaptot = 0, maxnot = 0, blown = 0, ddt = 0, firststop = 0, barsmaxt = 0, barsbard = 0, barsin = 0;
static double maxddp = 0, minml = 1e18;
static int maxn = 0, maxg = 0, maxabsn = 0;
static i64 y_eq0, y_lots, y_stop, y_tp, y_bc, y_days, y_stoploss; static int y_maxn, y_cur = -1; static double y_ddp; static i64 y_peak;
static i64 d_lots, d_tp, d_stop, d_mineq; static int d_maxn;
static FILE *flog = NULL, *fday = NULL;
static i64 logfrom = 0, logto = -1, curbar = 0;

static inline i64 fdiv(i64 a, i64 b) { i64 q = a / b, r = a % b; if (r != 0 && ((r < 0) != (b < 0))) q--; return q; }
static inline i64 netat(int q) { return K + (i64)N * q + SW; }
static inline i64 plat(int i, int q) { return P[i].dir > 0 ? (i64)P[i].u * (q - P[i].open) : (i64)P[i].u * (P[i].open - q - SP); }

static void eqtrack(int q)
{
    i64 fl = netat(q), eq = bal + fl;
    if (eq > peak) peak = eq;
    if (eq > y_peak) y_peak = eq;
    i64 dd = peak - eq;
    if (dd > maxdd) maxdd = dd;
    double ddp = peak > 0 ? (double)dd / (double)peak : 0;
    if (ddp > maxddp) { maxddp = ddp; ddt = curt; }
    double yd = y_peak > 0 ? (double)(y_peak - eq) / (double)y_peak : 0;
    if (yd > y_ddp) y_ddp = yd;
    if (eq < mineq) mineq = eq;
    if (eq < d_mineq) d_mineq = eq;
    if (fl < minfl) minfl = fl;
    if (eq <= 0 && !blown) blown = curt;
}

static int inlog(void) { return flog && curbar >= logfrom && (logto < 0 || curbar <= logto); }

static void open_pos(int dir, int u, int q, i64 t)
{
    if (n >= MAXP) { fprintf(stderr, "MAXP\n"); exit(2); }
    if (n == 0) { basket++; cyc = 0; }
    Pos *x = &P[n++];
    x->dir = dir; x->u = u; x->open = dir > 0 ? q + SP : q; x->tp = NOTP ? (dir > 0 ? INT_MAX / 2 : INT_MIN / 2) : x->open + dir * TP;
    x->seq = ++seqc; x->swap = 0; x->topen = t; x->bk = basket;
    if (dir > 0) { K -= (i64)u * x->open; N += u; } else { K += (i64)u * (x->open - SP); N -= u; }
    G += u; lastopen = t; lots++; y_lots++; d_lots++;
    if (n > maxn) maxn = n;
    if (n > y_maxn) y_maxn = n;
    if (n > d_maxn) d_maxn = n;
    if (G > maxg) maxg = G;
    if (abs(N) > maxabsn) maxabsn = abs(N);
    i64 notional = (i64)G * q;                       /* cu; margin 1:200 = notional/200 */
    if (notional > maxnot) maxnot = notional;
    double ml = (double)(bal + netat(q)) / ((double)notional / 200.0);
    if (ml < minml) minml = ml;
    if (inlog()) fprintf(flog, "O %lld %d %d %d %d %d %d %d %lld\n", t, dir, u, x->open, q, n, x->bk, rk, x->seq);
}

static void close_pos(int i, i64 pl, char kind, int q, i64 t)
{
    Pos *x = &P[i];
    bal += pl + x->swap; SW -= x->swap; swaptot += x->swap; cyc += pl + x->swap;
    if (x->dir > 0) { K += (i64)x->u * x->open; N -= x->u; } else { K -= (i64)x->u * (x->open - SP); N += x->u; }
    G -= x->u;
    if (inlog()) fprintf(flog, "C %lld %c %d %d %d %d %lld %lld %d %d %lld %lld\n", t, kind, x->dir, x->u, x->open, q, pl, bal, n - 1, x->bk, x->seq, x->swap);
    P[i] = P[--n];
}

static i64 closeall(int q, char kind, i64 t)
{
    i64 s = 0;
    for (int i = n - 1; i >= 0; i--) { i64 pl = plat(i, q); s += pl + P[i].swap; close_pos(i, pl, kind, q, t); }
    anc2 = 2LL * q + SP;
    return s;
}

/* EA ka ek tick: server TP, phir Work() (JasTokriEA.mq5 tk2). 1 = kuch badla. */
static int tick(int q, i64 t)
{
    int changed = 0;
    for (int i = n - 1; i >= 0 && !NOTP; i--)
        if (P[i].dir > 0 ? q >= P[i].tp : q + SP <= P[i].tp) {
            i64 pl = (i64)P[i].u * TP;                     /* TP qeemat par hi bharo (gap mein behtar qeemat NAHI di) */
            ntp++; y_tp++; d_tp++; sumtp += pl;
            close_pos(i, pl, 'T', q, t); changed = 1;
        }
    if (changed && n == 0) anc2 = 2LL * q + SP;
    for (int it = 0; it < 8; it++) {
        i64 net = netat(q);
        if (n > 0 && net <= -HADD) {                        /* 6 AAKHRI HADD */
            int nn = n, gg = G, NN = N;
            i64 s = closeall(q, 'H', t);
            halt = 1; nstop++; y_stop++; d_stop++; sumstop += s; y_stoploss += s;
            if (!firststop) firststop = t;
            printf("H %lld %lld %d %d %d %d %d %lld\n", t, s, nn, gg, NN, rk, q, bal);
            changed = 1; break;
        }
        if (n >= 2 && net + (BMODE ? cyc : 0) >= BC) {      /* 4 CLOSE ALL */
            i64 s = closeall(q, 'B', t);
            nbc++; y_bc++; sumbc += s; changed = 1; continue;
        }
        if (halt) break;
        if (rk == 0 && NEUT == 2) break;                    /* K4 variant a(ii): rukh nahi = nayi lot band */
        if (net <= -BARD) break;                            /* 5 BARDASHT */
        if (n >= MAXT) break;
        if (t - lastopen < MINSEC) break;
        if (n == 0) {                                       /* 1 tokri khali */
            if (rk != 0) { open_pos(rk, UH, q, t); changed = 1; continue; }
            i64 d = 2LL * q + SP - anc2;                    /* K4 variant a(i): rukh nahi -> Step chaal ka intezar, 0.01 */
            if (d >= 2LL * STEP || d <= -2LL * STEP) {
                int dir = d > 0 ? 1 : -1; if (MODE) dir = -dir;
                open_pos(dir, UL, q, t); changed = 1; continue;
            }
            break;
        }
        int last = 0;                                       /* 2 aakhri lot se doori */
        for (int i = 1; i < n; i++) if (P[i].seq > P[last].seq) last = i;
        i64 m2 = 2LL * q + SP, mv2 = m2 - 2LL * P[last].open;
        if (mv2 < 2LL * STEP && mv2 > -2LL * STEP) break;
        int dir = mv2 > 0 ? 1 : -1; if (MODE) dir = -dir;
        int blocked = 0;
        for (int i = 0; i < n; i++)
            if (P[i].dir == dir) { i64 a = m2 - 2LL * P[i].open; if (a < STEP && a > -STEP) { blocked = 1; break; } }
        if (blocked) break;
        open_pos(dir, dir == rk ? UH : UL, q, t); changed = 1;
    }
    return changed;
}

static inline void cand(i64 x, int q) { if (x > q) { if (x < ZU) ZU = (int)x; } else if (x < q) { if (x > ZD) ZD = (int)x; } }
static inline void candr(i64 num, i64 den, int q) { i64 f = fdiv(num, den); cand(f - 1, q); cand(f, q); cand(f + 1, q); cand(f + 2, q); }

/* q ke upar / neeche sab se qareeb qeemat jahan tick() kuch kar sakta hai (zyada umeedwar = be-zarar) */
static void zone(int q)
{
    ZU = INT_MAX; ZD = INT_MIN;
    if (!NOTP) for (int i = 0; i < n; i++) cand(P[i].dir > 0 ? P[i].tp : P[i].tp - SP, q);
    if (n > 0 && N != 0) {
        i64 net = netat(q);
        candr((i64)q * N + (-HADD - net), N, q);
        candr((i64)q * N + (BC - (BMODE ? cyc : 0) - net), N, q);
        candr((i64)q * N + (-BARD - net), N, q);
    }
    if (!halt && n < MAXT && !(rk == 0 && NEUT == 2)) {
        if (n == 0) {
            if (rk == 0) { candr(anc2 + 2LL * STEP - SP, 2, q); candr(anc2 - 2LL * STEP - SP, 2, q); }
        } else {
            int last = 0;
            for (int i = 1; i < n; i++) if (P[i].seq > P[last].seq) last = i;
            candr(2LL * P[last].open + 2LL * STEP - SP, 2, q); candr(2LL * P[last].open - 2LL * STEP - SP, 2, q);
            for (int i = 0; i < n; i++) { candr(2LL * P[i].open + STEP - SP, 2, q); candr(2LL * P[i].open - STEP - SP, 2, q); }
        }
    }
}

static int p = 0;            /* maujooda bid */
static i64 bar_t = 0, k = 0, total = 0;

static void point(int q, i64 t)
{
    curt = t;
    eqtrack(q);
    if (tick(q, t)) eqtrack(q);
    tpend = (t - lastopen < MINSEC);
    zone(q);
}

static void walk(int target)
{
    while (p != target && !blown) {
        int s = target > p ? 1 : -1;
        i64 dist = (i64)(target - p) * s, dc = -1, dt = -1;
        int c = s > 0 ? ZU : ZD;
        if (s > 0 ? (c <= target) : (c >= target)) dc = (i64)(c - p) * s;
        if (tpend && total > 0) {
            i64 need = lastopen + MINSEC - bar_t;
            if (need <= BARSEC) {
                i64 kmin = (need * total + BARSEC - 1) / BARSEC;
                if (kmin <= k) kmin = k + 1;
                if (kmin - k <= dist) dt = kmin - k;
            }
        }
        i64 d = dc;
        if (dt >= 0 && (d < 0 || dt < d)) d = dt;
        if (d < 0) { k += dist; p = target; break; }
        p += (int)(s * d); k += d;
        point(p, bar_t + (BARSEC * k) / total);
    }
    curt = bar_t + (total > 0 ? (BARSEC * k) / total : 0);
    eqtrack(p);
}

static void year_out(int q)
{
    i64 eq = bal + netat(q);
    printf("Y %d %lld %lld %lld %lld %d %lld %lld %.5f %lld %lld\n", y_cur, eq - y_eq0, y_lots, y_stop, y_days, y_maxn, y_tp, y_bc, y_ddp, y_stoploss, eq);
    y_eq0 = eq; y_lots = y_stop = y_tp = y_bc = y_days = y_stoploss = 0; y_maxn = n; y_ddp = 0; y_peak = eq;
}

static void day_out(int sd, int q)
{
    if (fday) fprintf(fday, "%d %lld %lld %lld %d %d %d %d %lld %lld %lld %lld %d\n", sd, bal + netat(q), bal, netat(q), n, N, G, rk, d_lots, d_tp, d_stop, d_mineq, d_maxn);
    d_lots = d_tp = d_stop = 0; d_mineq = bal + netat(q); d_maxn = n;
}

int main(int argc, char **argv)
{
    if (argc < 3) { fprintf(stderr, "usage: k4 bars rukh key=val...\n"); return 1; }
    FILE *f = fopen(argv[1], "rb"); if (!f) { perror(argv[1]); return 1; }
    i64 nb; if (fread(&nb, 8, 1, f) != 1) return 1;
    i64 *T = malloc(nb * 8); int *O = malloc(nb * 4), *Hh = malloc(nb * 4), *L = malloc(nb * 4), *C = malloc(nb * 4), *SD = malloc(nb * 4);
    short *YR = malloc(nb * 2); signed char *DW = malloc(nb), *R = malloc(nb);
    if (fread(T, 8, nb, f) != (size_t)nb || fread(O, 4, nb, f) != (size_t)nb || fread(Hh, 4, nb, f) != (size_t)nb || fread(L, 4, nb, f) != (size_t)nb ||
        fread(C, 4, nb, f) != (size_t)nb || fread(SD, 4, nb, f) != (size_t)nb || fread(YR, 2, nb, f) != (size_t)nb || fread(DW, 1, nb, f) != (size_t)nb) { fprintf(stderr, "bars read\n"); return 1; }
    fclose(f);
    f = fopen(argv[2], "rb"); if (!f) { perror(argv[2]); return 1; }
    if (fread(R, 1, nb, f) != (size_t)nb) { fprintf(stderr, "rukh read\n"); return 1; }
    fclose(f);
    i64 i0 = 0, i1 = nb;
    for (int a = 3; a < argc; a++) {
        char *e = strchr(argv[a], '='); if (!e) continue; *e = 0; char *v = e + 1; char *kx = argv[a];
        #define PAR(nm, var) else if (!strcmp(kx, nm)) var = atoll(v)
        if (!strcmp(kx, "log")) flog = fopen(v, "w");
        else if (!strcmp(kx, "daily")) fday = fopen(v, "w");
        PAR("i0", i0); PAR("i1", i1); PAR("sp", SP); PAR("step", STEP); PAR("tp", TP); PAR("bc", BC); PAR("maxt", MAXT);
        PAR("bard", BARD); PAR("hadd", HADD); PAR("eq0", EQ0); PAR("uh", UH); PAR("ul", UL); PAR("mode", MODE); PAR("neut", NEUT);
        PAR("c2", C2); PAR("path", PATH); PAR("minsec", MINSEC); PAR("barsec", BARSEC); PAR("swapl", SWAPL); PAR("swaps", SWAPS);
        PAR("restart", RESTART); PAR("bmode", BMODE); PAR("notp", NOTP); PAR("logfrom", logfrom); PAR("logto", logto);
        else { fprintf(stderr, "na-maloom: %s\n", kx); return 1; }
    }
    if (MAXT > MAXP - 2) { fprintf(stderr, "maxt bara\n"); return 1; }
    bal = EQ0; peak = EQ0; mineq = EQ0; d_mineq = EQ0; y_eq0 = EQ0; y_peak = EQ0;
    int cur_sd = 0;
    for (i64 i = i0; i < i1 && !blown; i++) {
        int o = O[i], h = Hh[i], l = L[i], c = C[i], force = 0;
        bar_t = T[i]; curt = bar_t; curbar = i; barsin++;
        if (i == i0) {
            cur_sd = SD[i]; y_cur = YR[i]; y_days = 1; rk = R[i]; lastnz = rk; p = o; anc2 = 2LL * o + SP; force = 1;
        } else if (SD[i] != cur_sd) {
            day_out(cur_sd, p);
            if (SWAPL || SWAPS) {                           /* rollover: Budh ki raat 3 guna (MT5 gold) */
                int mult = DW[i - 1] == 2 ? 3 : 1;
                for (int j = 0; j < n; j++) { i64 s = -(P[j].dir > 0 ? SWAPL : SWAPS) * P[j].u * mult; P[j].swap += s; SW += s; }
                force = 1;
            }
            if (YR[i] != y_cur) { year_out(p); y_cur = YR[i]; }
            cur_sd = SD[i]; y_days++;
            if (halt && RESTART) { halt = 0; anc2 = 2LL * o + SP; force = 1; }
        }
        if (R[i] != rk) {                                   /* rukh badla (pichhle BAND din / 4H candle se) */
            int r = R[i];
            if (C2 && lastnz != 0 && r != lastnz) {         /* K4 variant c2: purani bhari taraf ki nuqsan wali lots band */
                for (int j = n - 1; j >= 0; j--)
                    if (P[j].dir == lastnz) { i64 pl = plat(j, o); if (pl + P[j].swap < 0) { nc2++; sumc2 += pl + P[j].swap; close_pos(j, pl, 'R', o, bar_t); } }
                if (n == 0) anc2 = 2LL * o + SP;
            }
            rk = r; if (r != 0) lastnz = r;
            force = 1;
        }
        k = 0;
        if (force || tpend || o >= ZU || o <= ZD) { p = o; point(o, bar_t); } else p = o;
        if (n >= MAXT) barsmaxt++;
        if (n > 0 && netat(p) <= -BARD) barsbard++;
        int a, b;
        if (PATH == 0) { a = h; b = l; } else if (PATH == 1) { a = l; b = h; }
        else if (PATH == 2) { if (c >= o) { a = l; b = h; } else { a = h; b = l; } }
        else { if (c >= o) { a = h; b = l; } else { a = l; b = h; } }
        total = (i64)abs(a - o) + abs(b - a) + abs(c - b);
        if (!tpend && l > ZD && h < ZU) { curt = bar_t; eqtrack(a); eqtrack(b); p = c; continue; }
        walk(a); walk(b); walk(c);
    }
    day_out(cur_sd, p);
    year_out(p);
    i64 fl = netat(p), eq = bal + fl;
    printf("S %lld %lld %.5f %lld %lld %lld %lld %lld %lld %lld %lld %lld %lld %lld %lld %d %d %d %lld %lld %lld %lld %lld %.1f %lld %lld %d %lld %lld %lld\n",
           eq, eq - EQ0, maxddp, maxdd, mineq, peak, nstop, lots, ntp, sumtp, nbc, sumbc, sumstop, nc2, sumc2, maxn, maxg, maxabsn, minfl,
           barsmaxt, barsbard, blown, maxnot, minml, swaptot, fl, n, firststop, ddt, barsin);
    if (flog) fclose(flog);
    if (fday) fclose(fday);
    return 0;
}
