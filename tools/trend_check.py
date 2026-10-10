"""JasSmcTrend (indicators/smc_trend_pro.pine) ka Python port: bara structure +
qila, chhota CHOCH, toorne wali candle, aur NAAP. Bari TF ka filter band.
Random qeemat par koi edge nahi hoti, is liye ishara % buniyad ke barabar aana
chahiye - aage dekhne wali ghalti ho to yahan jhoota FARK dikhta. Qila hamesha
qeemat ke sahi taraf (assert). Pine badle to ye bhi. `python3 tools/trend_check.py`"""
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
