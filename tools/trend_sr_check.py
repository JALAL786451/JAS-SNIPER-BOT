"""JasSmcTrend t3 ki S/R lakeerein (indicators/smc_trend_pro.pine) ka Python port.
Chhota structure + t2 ka ishara/khatam + nakli bari TF (4 candle ke blocks). Har band
candle ke baad lakeer ka haal; candle t par wahi lakeer lagti hai jo t-1 ke baad bani,
aur t ki bari TF. Assert: (a) har rang badalna narangi lakeer ke sahi taraf close par,
(b) sleti nuqte ke paar rang kabhi nahi badalta, (c) S <= close <= R, (d) narangi ke paar
"chup" close sirf us candle par jahan nayi chhoti swing bani. `python3 tools/trend_sr_check.py`
"""
import sys, random
import os
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from trend_check import pivots, atr, walk

def internal_b(h, l, c, lr):
    ph, pl = pivots(h, l, lr)
    ish = isl = None; ishB = islB = None
    idir = 0; out = []
    for t in range(len(c)):
        newP = ph[t] is not None or pl[t] is not None
        if ph[t] is not None: ish, ishB = ph[t], t - lr
        if pl[t] is not None: isl, islB = pl[t], t - lr
        flip = 0
        if ish is not None and c[t] > ish:
            if idir <= 0: flip = 1
            idir, ish = 1, None
        elif isl is not None and c[t] < isl:
            if idir >= 0: flip = -1
            idir, isl = -1, None
        out.append((idir, flip, isl, ish, islB, ishB, newP))
    return out

def run(o, h, l, c, seed, intLR=2, dispATR=0.5, block=4):
    rnd = random.Random(seed + 1000)
    vals = [-100, -62.5, -25, 0, 25, 62.5, 100]
    htf = []
    for t in range(len(c)):
        if t % block == 0: cur = rnd.choice(vals)
        htf.append(cur)
    it = internal_b(h, l, c, intLR); a = atr(h, l, c)
    lastDir, lastSL, lastSLB, ended, adv = 0, None, None, False, 0
    # state after last close
    st_sL = st_sB = st_rL = st_rB = None; st_adv = 0; st_idir = 0
    S = dict(changes=0, chgOK=0, dotCross=0, dotChg=0, orCross=0, orSilent=0, orSilentNoPivot=0,
             sideBad=0, bothDotted=0, bars=0, orNa=0, sig=0, blockedBars=0)
    for t in range(len(c)):
        hs = htf[t]
        blkDn = hs >= 30   # SELL ruka
        blkUp = hs <= -30  # BUY ruka
        # line applied to this bar (from previous close + this bar's filter)
        sOr = st_adv == 1 or (st_adv == 0 and st_idir >= 0 and not blkDn)
        rOr = st_adv == -1 or (st_adv == 0 and st_idir <= 0 and not blkUp)
        if st_adv == 0 and ((st_idir == 1 and blkDn) or (st_idir == -1 and blkUp)): S['blockedBars'] += 1
        pS, pR = st_sL, st_rL
        # --- engine (t2, unchanged) ---
        idir, flip, isl, ish, islB, ishB, newP = it[t]
        A = a[t]; body = abs(c[t]-o[t])
        fvgUp = t >= 2 and l[t] > h[t-2]; fvgDn = t >= 2 and h[t] < l[t-2]
        dispUp = A is not None and c[t] > o[t] and (body >= dispATR*A or fvgUp)
        dispDn = A is not None and c[t] < o[t] and (body >= dispATR*A or fvgDn)
        sigUp = flip == 1 and dispUp and hs > -30
        sigDn = flip == -1 and dispDn and hs < 30
        if sigUp: lastDir, lastSL, lastSLB = 1, (isl if isl is not None else l[t]), (islB if isl is not None else t)
        if sigDn: lastDir, lastSL, lastSLB = -1, (ish if ish is not None else h[t]), (ishB if ish is not None else t)
        prevAdv = adv
        if sigUp or sigDn: ended = False
        elif (lastDir == 1 and (c[t] < lastSL or idir != 1)) or (lastDir == -1 and (c[t] > lastSL or idir != -1)): ended = True
        adv = 0 if ended else lastDir
        S['sig'] += sigUp or sigDn
        # --- checks vs applied lines ---
        if t > 0:
            crossS = pS is not None and c[t] < pS
            crossR = pR is not None and c[t] > pR
            if adv != prevAdv:
                S['changes'] += 1
                ok = (adv == 1 and crossR and rOr) or (adv == -1 and crossS and sOr) or \
                     (adv == 0 and prevAdv == 1 and crossS and sOr) or (adv == 0 and prevAdv == -1 and crossR and rOr)
                S['chgOK'] += ok
                if not ok: print("BAD change", seed, t, prevAdv, adv, pS, pR, c[t], sOr, rOr)
            for cr, orx in ((crossS, sOr), (crossR, rOr)):
                if cr and not orx:
                    S['dotCross'] += 1
                    if adv != prevAdv: S['dotChg'] += 1
                if cr and orx:
                    S['orCross'] += 1
                    # silent = neither colour change nor structure flip
                    if adv == prevAdv and flip == 0:
                        S['orSilent'] += 1
                        if not newP: S['orSilentNoPivot'] += 1
            if not sOr and not rOr: S['bothDotted'] += 1
            if not ((sOr and pS is not None) or (rOr and pR is not None)): S['orNa'] += 1
        # --- new state after this close (Design-1 levels) ---
        sL, sB, rL, rB = isl, islB, ish, ishB
        if adv == 1 and (isl is None or lastSL > isl): sL, sB = lastSL, lastSLB
        if adv == -1 and (ish is None or lastSL < ish): rL, rB = lastSL, lastSLB
        if sL is not None and sL > c[t]: S['sideBad'] += 1
        if rL is not None and rL < c[t]: S['sideBad'] += 1
        st_sL, st_sB, st_rL, st_rB, st_adv, st_idir = sL, sB, rL, rB, adv, idir
        S['bars'] += 1
    return S

tot = {}
for seed in range(12):
    o, h, l, c = walk(5000, seed)
    s = run(o, h, l, c, seed)
    for k, v in s.items(): tot[k] = tot.get(k, 0) + v
for k in sorted(tot): print(f"{k:18s} {tot[k]}")

assert tot['changes'] == tot['chgOK'], "rang narangi lakeer ke bahar badla"
assert tot['dotChg'] == 0, "sleti nuqte ke paar rang badla"
assert tot['sideBad'] == 0, "S/R qeemat ke ghalat taraf"
assert tot['orSilentNoPivot'] == 0, "narangi ke paar chup close bina nayi swing ke"
print("t3 S/R jaanch OK")
