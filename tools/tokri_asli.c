/* Tokri asli tareeqa (Q14-Q19, 44vi chat) - tez C sim. Chalao: python3 tools/tokri_asli.py
   stdin: "O H L C YYYY" har H1 bar. args: mode(0 mom,1 jori,2 ulta) D T L H STOP yearly
   0.01 lot = $1 har $1; spread SP $0.24 har 0.01 (lot khulte waqt kata). Raasta: sabz O-L-H-C, laal O-H-L-C. */
#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#define MX 20000
#define SP 0.24
static int dirv[MX], un[MX], hof[MX], hedged[MX], n = 0;   /* hof: hedge lot ka asal index-id, -1 = aam lot */
static long idv[MX], nid = 0;
static double ent[MX];
static int MODE, L; static double D, T, H, STOP;
static double bal = 1000, p, anc; static long stops = 0, trades = 0, tps = 0; static double stoploss = 0, tpsum = 0;
static double fl1(int i, double q) { return un[i] * ((q - ent[i]) * dirv[i] - SP); }
static void openl(int d, double q, int u, long h) {
    if (n >= MX) { fprintf(stderr, "MX\n"); exit(1); }
    dirv[n] = d; ent[n] = q; un[n] = u; hof[n] = (int)h; hedged[n] = 0; idv[n] = nid++; n++; trades++;
}
static int unit(int d) {
    if (L == 3) { for (int i = 0; i < n; i++) if (dirv[i] == -d && hof[i] < 0) return 2; return 1; }
    return L;
}
static void do_open(int s, double q) {
    if (MODE == 0) openl(s, q, unit(s), -1);
    else if (MODE == 2) openl(-s, q, unit(-s), -1);
    else { int u = L == 3 ? 1 : L; openl(1, q, u, -1); openl(-1, q, u, -1); }
}
static void remove_at(int i) { n--; dirv[i] = dirv[n]; ent[i] = ent[n]; un[i] = un[n]; hof[i] = hof[n]; hedged[i] = hedged[n]; idv[i] = idv[n]; }
static int find(long id) { for (int i = 0; i < n; i++) if (idv[i] == id) return i; return -1; }
static char mark[MX];
static void walk(double b) {
    const double E = 1e-9;
    for (;;) {
        if (fabs(b - p) < E) { p = b; return; }
        int s = b > p ? 1 : -1; double N = 0, fl = 0, best = (b - p) * s; int have = 0;
        for (int i = 0; i < n; i++) { N += dirv[i] * un[i]; fl += fl1(i, p); }
        double dd;
        for (int i = 0; i < n; i++) {
            if (hof[i] < 0 && dirv[i] == s) { dd = (ent[i] + s * (T + SP) - p) * s; if (dd < 0) dd = 0; if (dd <= best) { best = dd; have = 1; } }
            if (H > 0 && hof[i] < 0 && dirv[i] == -s && !hedged[i]) { dd = (ent[i] + s * (H - SP) - p) * s; if (dd < 0) dd = 0; if (dd <= best) { best = dd; have = 1; } }
            if (H > 0 && hof[i] >= 0 && dirv[i] == s) { dd = (ent[i] + s * (H + SP) - p) * s; if (dd < 0) dd = 0; if (dd <= best) { best = dd; have = 1; } }
        }
        dd = (anc + s * D - p) * s; if (dd < 0) dd = 0; if (dd <= best) { best = dd; have = 1; }
        if (N * s < 0) { dd = (-STOP - fl) / N * s; if (dd < 0) dd = 0; if (dd <= best) { best = dd; have = 1; } }
        if (!have) { p = b; return; }
        double q = p + s * best; p = q;
        /* stop */
        double f2 = 0; for (int i = 0; i < n; i++) f2 += fl1(i, q);
        if (f2 <= -STOP + 1e-6 && n) {
            bal += f2; stoploss += f2; stops++; n = 0; anc = q; do_open(s, q); continue;
        }
        /* tp / hedge done */
        for (int i = 0; i < n; i++) mark[i] = 0;
        for (int i = 0; i < n; i++) {
            if (hof[i] < 0 && dirv[i] == s && (ent[i] + s * (T + SP) - q) * s <= 1e-7) mark[i] = 1;
            if (hof[i] >= 0 && dirv[i] == s && (ent[i] + s * (H + SP) - q) * s <= 1e-7) mark[i] = 2;
        }
        /* asal lot band -> us ki hedge bhi band; hedge band -> asal azad */
        for (int i = 0; i < n; i++) if (mark[i] == 1 && hedged[i]) { for (int j = 0; j < n; j++) if (hof[j] == (int)idv[i]) mark[j] = 3; }
        for (int i = 0; i < n; i++) if (mark[i] == 2) { int k = find(hof[i]); if (k >= 0) hedged[k] = 0; }
        for (int i = n - 1; i >= 0; i--) if (mark[i]) { double v = fl1(i, q); bal += v; if (mark[i] == 1) { tps++; tpsum += v; } remove_at(i); }
        if (H > 0) {
            int m = n;
            for (int i = 0; i < m; i++) if (hof[i] < 0 && dirv[i] == -s && !hedged[i] && (ent[i] + s * (H - SP) - q) * s <= 1e-7) { hedged[i] = 1; openl(-dirv[i], q, un[i], idv[i]); }
        }
        if ((anc + s * D - q) * s <= 1e-7) { do_open(s, q); anc = q; }
        if (!n) { do_open(s, q); anc = q; }
    }
}
int main(int argc, char **argv) {
    MODE = atoi(argv[1]); D = atof(argv[2]); T = atof(argv[3]); L = atoi(argv[4]); H = atof(argv[5]); STOP = atof(argv[6]); int yearly = atoi(argv[7]);
    double o, h, l, c; int y, cy = -1, blown = 0; double peak = 1000, mdd = 0, maxl = 0, minfl = 0, yeq = 1000, eq = 1000;
    int first = 1;
    while (scanf("%lf %lf %lf %lf %d", &o, &h, &l, &c, &y) == 5) {
        if (first) { p = o; anc = o; do_open(1, o); first = 0; cy = y; }
        if (y != cy) { if (yearly) printf("%d %+.0f stops=%ld\n", cy, eq - yeq, stops); yeq = eq; cy = y; }
        walk(o);
        if (c >= o) { walk(l); walk(h); } else { walk(h); walk(l); }
        walk(c);
        double fl = 0, u = 0; for (int i = 0; i < n; i++) { fl += fl1(i, c); u += un[i]; }
        eq = bal + fl; if (fl < minfl) minfl = fl; if (u > maxl) maxl = u;
        if (eq > peak) peak = eq; if (peak - eq > mdd) mdd = peak - eq;
        if (eq <= 0) { blown = y; break; }
    }
    if (yearly) printf("%d %+.0f stops=%ld\n", cy, eq - yeq, stops);
    printf("%.0f %ld %ld %.0f %.0f %.0f %d %ld %.0f %.0f\n", eq, stops, trades, mdd, maxl, minfl, blown, tps, tpsum, stoploss);
    return 0;
}
