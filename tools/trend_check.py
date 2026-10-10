"""JasSmcTrend (indicators/smc_trend_pro.pine) ka Python port: bara structure +
qila, chhota CHOCH, toorne wali candle, aur NAAP. Bari TF ka filter band.
Random qeemat par koi edge nahi hoti, is liye ishara % buniyad ke barabar aana
chahiye - aage dekhne wali ghalti ho to yahan jhoota FARK dikhta. Qila hamesha
qeemat ke sahi taraf (assert). Pine badle to ye bhi. `python3 tools/trend_check.py`

t3: sr_run() S/R lakeerein (narangi / sleti nuqte) ko nakli bari TF filter ke
saath jaanchta hai: rang sirf narangi ke paar badalta hai, nuqte wali ke paar
kabhi nahi, S <= close <= R, aur chup narangi toot sirf nayi chhoti swing
wali candle par."""
import math, random, sys

def pivots(hi, lo, lr):
    n = len(hi)
    ph = [None] * n
    pl = [None] * n
    for t in range(2 * lr, n):
        c = t - lr
        win_h = hi[t - 2 * lr:t + 1]
        win_l = lo[t - 2 * lr:t + 1]
        if all(hi[c] > x for i, x in enumerate(win_h) if i != lr):
            ph[t] = hi[c]
        if all(lo[c] < x for i, x in enumerate(win_l) if i != lr):
            pl[t] = lo[c]
    return ph, pl

def struct(o, h, l, c, lr):
    ph, pl = pivots(h, l, lr)
    sh = sl = qila = legHi = legLo = pullLo = pullHi = None
    d = 0
    out = []
    for t in range(len(c)):
        lowLR = min(l[max(0, t - lr):t + 1])
        highLR = max(h[max(0, t - lr):t + 1])
        if ph[t] is not None: sh, pullLo = ph[t], lowLR
        if pl[t] is not None: sl, pullHi = pl[t], highLR
        if pullLo is not None: pullLo = min(pullLo, l[t])
        if pullHi is not None: pullHi = max(pullHi, h[t])
        legHi = h[t] if legHi is None else max(legHi, h[t])
        legLo = l[t] if legLo is None else min(legLo, l[t])
        if d == 1 and qila is not None and c[t] < qila:
            d, qila, legLo, sl = -1, legHi, l[t], None
        elif d == -1 and qila is not None and c[t] > qila:
            d, qila, legHi, sh = 1, legLo, h[t], None
        elif d >= 0 and sh is not None and c[t] > sh:
            qila = pullLo
            d, legHi, sh = 1, h[t], None
        elif d <= 0 and sl is not None and c[t] < sl:
            qila = pullHi
            d, legLo, sl = -1, l[t], None
        out.append((d, qila))
    return out

def internal(h, l, c, lr):
    ph, pl = pivots(h, l, lr)
    ish = isl = None
    idir = 0
    out = []
    for t in range(len(c)):
        if ph[t] is not None: ish = ph[t]
        if pl[t] is not None: isl = pl[t]
        flip = 0
        if ish is not None and c[t] > ish:
            if idir <= 0: flip = 1
            idir, ish = 1, None
        elif isl is not None and c[t] < isl:
            if idir >= 0: flip = -1
            idir, isl = -1, None
        out.append((idir, flip, isl, ish))
    return out

def atr(h, l, c, n=14):
    out = [None] * len(c)
    rma = None
    trs = []
    for t in range(len(c)):
        tr = h[t] - l[t] if t == 0 else max(h[t] - l[t], abs(h[t] - c[t-1]), abs(l[t] - c[t-1]))
        trs.append(tr)
        if t == n - 1:
            rma = sum(trs) / n
        elif t >= n:
            rma = (rma * (n - 1) + tr) / n
        out[t] = rma
    return out

def walk(n, seed, drift=0.0):
    rnd = random.Random(seed)
    o, h, l, c = [], [], [], []
    p = 4000.0
    for _ in range(n):
        op = p
        path = [op]
        for _ in range(4):
            path.append(path[-1] + rnd.gauss(drift, 1.5))
        cl = path[-1]
        o.append(op); c.append(cl)
        h.append(max(path) + abs(rnd.gauss(0, 0.4)))
        l.append(min(path) - abs(rnd.gauss(0, 0.4)))
        p = cl
    return o, h, l, c

def run(o, h, l, c, intLR=2, mainLR=3, dispATR=0.5, TP=2.0, SL=1.0, MAXB=100):
    st = struct(o, h, l, c, mainLR)
    it = internal(h, l, c, intLR)
    a = atr(h, l, c)
    tests = []  # [tgt, stp, dir, bar, kind]
    cnt = [0] * 8
    sigs = 0
    lastDir, lastSL, ended, adv = 0, None, False, 0   # t2: MA lakeer ka rang
    for t in range(len(c)):
        keep = []
        for tg, sp, d, b, kind in tests:
            hitT = h[t] >= tg if d == 1 else l[t] <= tg
            hitS = l[t] <= sp if d == 1 else h[t] >= sp
            res = -1 if hitS else (1 if hitT else (2 if t - b >= MAXB else 0))
            if res == 0:
                keep.append([tg, sp, d, b, kind]); continue
            if res != 2:
                cnt[kind * 4 + (0 if d == 1 else 2) + (0 if res == 1 else 1)] += 1
        tests = keep
        body = abs(c[t] - o[t])
        fvgUp = t >= 2 and l[t] > h[t-2]
        fvgDn = t >= 2 and h[t] < l[t-2]
        A = a[t]
        dispUp = A is not None and c[t] > o[t] and (body >= dispATR * A or fvgUp)
        dispDn = A is not None and c[t] < o[t] and (body >= dispATR * A or fvgDn)
        _, flip, isl, ish = it[t]
        sigUp = flip == 1 and dispUp
        sigDn = flip == -1 and dispDn
        idir = it[t][0]
        if sigUp: lastDir, lastSL = 1, (it[t][2] if it[t][2] is not None else l[t])
        if sigDn: lastDir, lastSL = -1, (it[t][3] if it[t][3] is not None else h[t])
        prevAdv = adv
        if sigUp or sigDn: ended = False
        elif (lastDir == 1 and (c[t] < lastSL or idir != 1)) or (lastDir == -1 and (c[t] > lastSL or idir != -1)): ended = True
        adv = 0 if ended else lastDir
        # lakeer sirf ishare wali candle par rangeen hoti hai (sleti -> hara/laal)
        if prevAdv != adv and adv != 0: assert sigUp or sigDn, (t, prevAdv, adv)
        # rangeen lakeer kabhi SL ke ghalat taraf wali band candle par nahi
        if adv == 1: assert c[t] >= lastSL and idir == 1, (t, c[t], lastSL)
        if adv == -1: assert c[t] <= lastSL and idir == -1, (t, c[t], lastSL)
        # invariant: internal SL must be on the losing side of the entry
        if sigUp and isl is not None: assert isl < c[t], (t, isl, c[t])
        if sigDn and ish is not None: assert ish > c[t], (t, ish, c[t])
        d_, q = st[t]
        if d_ == 1 and q is not None: assert c[t] >= q
        if d_ == -1 and q is not None: assert c[t] <= q
        if A is not None and A > 0:
            for d, k in ((1, 0), (-1, 0)):
                tests.append([c[t] + d * TP * A, c[t] - d * SL * A, d, t, k])
            if sigUp: tests.append([c[t] + TP * A, c[t] - SL * A, 1, t, 1]); sigs += 1
            if sigDn: tests.append([c[t] - TP * A, c[t] + SL * A, -1, t, 1]); sigs += 1
    return cnt, sigs

def sr_run(o, h, l, c, seed, intLR=2, dispATR=0.5):
    """t3 ki S/R lakeerein (Pine D4 + F ka port). Bari TF nakli: har 4 candle ka
    ek block, qeemat {-100..100} mein se. Candle t par LAGI lakeer = t-1 ke baad
    ki haalat + candle t ki bari TF (wohi filter jo yeh candle dekhti hai)."""
    rnd = random.Random(seed + 1000)
    vals = [-100.0, -62.5, -25.0, 0.0, 25.0, 62.5, 100.0]
    hv = []
    for t in range(len(c)):
        if t % 4 == 0: v = rnd.choice(vals)
        hv.append(v)
    ph, pl = pivots(h, l, intLR)
    a = atr(h, l, c)
    ish = isl = ishB = islB = None
    idir = 0
    lastDir, lastSL, lastSLBar, ended, adv = 0, None, None, False, 0
    srS = srR = None
    srAdv = srIDir = 0
    st = dict(change=0, change_ok=0, dot_cross=0, dot_change=0, or_cross=0, silent=0, silent_pivot=0, side_err=0)
    for t in range(len(c)):
        # candle t par lagi lakeerein (t-1 ki haalat + abhi ki bari TF)
        sellRuka = hv[t] >= 30
        buyRuka = hv[t] <= -30
        sOr = srAdv == 1 or (srAdv == 0 and srIDir >= 0 and not sellRuka)
        rOr = srAdv == -1 or (srAdv == 0 and srIDir <= 0 and not buyRuka)
        aS, aR = srS, srR
        # f_internal
        newPiv = ph[t] is not None or pl[t] is not None
        if ph[t] is not None: ish, ishB = ph[t], t - intLR
        if pl[t] is not None: isl, islB = pl[t], t - intLR
        flip = 0
        if ish is not None and c[t] > ish:
            if idir <= 0: flip = 1
            idir, ish = 1, None
        elif isl is not None and c[t] < isl:
            if idir >= 0: flip = -1
            idir, isl = -1, None
        # ishara (bari TF filter ke saath)
        A = a[t]
        body = abs(c[t] - o[t])
        fvgUp = t >= 2 and l[t] > h[t-2]
        fvgDn = t >= 2 and h[t] < l[t-2]
        dispUp = A is not None and c[t] > o[t] and (body >= dispATR * A or fvgUp)
        dispDn = A is not None and c[t] < o[t] and (body >= dispATR * A or fvgDn)
        sigUp = flip == 1 and dispUp and hv[t] > -30
        sigDn = flip == -1 and dispDn and hv[t] < 30
        if sigUp: lastDir, lastSL, lastSLBar = 1, (isl if isl is not None else l[t]), (islB if isl is not None else t)
        if sigDn: lastDir, lastSL, lastSLBar = -1, (ish if ish is not None else h[t]), (ishB if ish is not None else t)
        prevAdv = adv
        if sigUp or sigDn: ended = False
        elif (lastDir == 1 and (c[t] < lastSL or idir != 1)) or (lastDir == -1 and (c[t] > lastSL or idir != -1)): ended = True
        adv = 0 if ended else lastDir
        # (a) rang badla = lagi NARANGI lakeer ke sahi taraf paar band
        if adv != prevAdv:
            st['change'] += 1
            if adv < prevAdv: ok = aS is not None and sOr and c[t] < aS
            else: ok = aR is not None and rOr and c[t] > aR
            assert ok, ('a', t, prevAdv, adv, aS, aR, sOr, rOr, c[t])
            st['change_ok'] += 1
        # (b) sleti nuqte wali ke paar rang kabhi nahi badalta
        for lv, orng, below in ((aS, sOr, True), (aR, rOr, False)):
            if lv is None: continue
            crossed = c[t] < lv if below else c[t] > lv
            if not crossed: continue
            if not orng:
                st['dot_cross'] += 1
                if adv != prevAdv: st['dot_change'] += 1
            else:
                st['or_cross'] += 1
                # (d) chup narangi toot (rang wahi, palta nahi) sirf nayi swing par
                if adv == prevAdv and flip == 0:
                    st['silent'] += 1
                    assert newPiv, ('d', t, lv, c[t])
                    st['silent_pivot'] += 1
        assert st['dot_change'] == 0, ('b', t)
        # D4: band candle par nayi haalat
        nS, nR = isl, ish
        if adv == 1 and (isl is None or lastSL > isl): nS = lastSL
        if adv == -1 and (ish is None or lastSL < ish): nR = lastSL
        srS, srR, srAdv, srIDir = nS, nR, adv, idir
        # (c) S <= close <= R
        if (srS is not None and srS > c[t]) or (srR is not None and srR < c[t]):
            st['side_err'] += 1
        assert st['side_err'] == 0, ('c', t, srS, c[t], srR)
    return st

def summary(cnt):
    bWU, bLU, bWD, bLD, iWU, iLU, iWD, iLD = cnt
    pU = bWU / max(1, bWU + bLU); pD = bWD / max(1, bWD + bLD)
    nU, nD = iWU + iLU, iWD + iLD; nI = nU + nD
    expW = nU * pU + nD * pD
    var = nU * pU * (1 - pU) + nD * pD * (1 - pD)
    fark = (iWU + iWD - expW) / nI
    se2 = 2 * math.sqrt(var) / nI
    return nI, (iWU + iWD) / nI, expW / nI, fark, se2

if __name__ == "__main__":
    tot = [0] * 8
    for seed in range(12):
        o, h, l, c = walk(5000, seed)
        cnt, sigs = run(o, h, l, c)
        nI, ir, br, fark, se2 = summary(cnt)
        print(f"seed {seed:2d}: ishare {sigs:4d} (gine {nI:4d}) ishara {ir:.3f} aam {br:.3f} FARK {fark:+.3f} 2SE {se2:.3f}")
        tot = [x + y for x, y in zip(tot, cnt)]
    nI, ir, br, fark, se2 = summary(tot)
    print(f"KUL      : gine {nI} ishara {ir:.3f} aam {br:.3f} FARK {fark:+.3f} 2SE {se2:.3f}")
    # drift check: buniyad UPAR vs NEECHE alag honi chahiye, FARK phir bhi ~0
    o, h, l, c = walk(5000, 99, drift=0.15)
    cnt, sigs = run(o, h, l, c)
    print("drift +0.15: aam UPAR %.3f NEECHE %.3f" % (cnt[0] / (cnt[0] + cnt[1]), cnt[2] / (cnt[2] + cnt[3])),
          "| ishara/FARK", ["%.3f" % x for x in summary(cnt)[1:]])
    # t3: S/R lakeerein, nakli bari TF ke saath
    tot = {}
    for seed in range(12):
        o, h, l, c = walk(5000, seed)
        for k, v in sr_run(o, h, l, c, seed).items(): tot[k] = tot.get(k, 0) + v
    print(f"t3 S/R: rang badla {tot['change']} (narangi ke paar {tot['change_ok']}/{tot['change']})"
          f" | nuqte paar {tot['dot_cross']}, rang badla {tot['dot_change']}"
          f" | narangi paar {tot['or_cross']}, chup {tot['silent']} (nayi swing par {tot['silent_pivot']})"
          f" | S/R ghalat taraf {tot['side_err']}")
