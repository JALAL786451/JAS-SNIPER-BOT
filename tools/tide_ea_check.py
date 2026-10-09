"""JasTideRadarEA ka engine Pine ke engine se milao (offline jaanch).

indicators/jas_tide_radar.pine ka f_tide() request.security ke andar chalta
hai aur [1] / [2] se pichli BAND candle parhta hai. EA wahi kaam ek array par
karta hai: signal candle s, naali s-10..s-1, sarakta SL s-5..s-1, EMA s-1.
Ye script dono ko random daily candles par chala kar dekhta hai ke har trade
(entry candle, rukh, entry, band candle, band qeemat) bilkul ek jaisi hai, aur
weekend ki chhoti candle wala milaap theek hai.

    python3 tools/tide_ea_check.py
"""
import math
import random

ENTRY, EXIT, ATRL, MULT, EF, ES, MINATR = 10, 5, 14, 2.0, 50, 200, 0.25


def atr_rma(h, l, c, n):
    out, s = [], 0.0
    for k in range(len(c)):
        tr = h[k] - l[k] if k == 0 else max(h[k] - l[k], abs(h[k] - c[k - 1]), abs(l[k] - c[k - 1]))
        if k < n:
            s += tr
            out.append(s / n if k == n - 1 else 0.0)
        else:
            out.append((out[-1] * (n - 1) + tr) / n)
    return out


def ema(c, n):
    out, s, a = [], 0.0, 2.0 / (n + 1)
    for k, x in enumerate(c):
        if k < n:
            s += x
            out.append(s / (k + 1))
        else:
            out.append(a * x + (1 - a) * out[-1])
    return out


def pine_engine(o, h, l, c, start):
    """f_tide() jaisa: chart candle t par candle t-1 ka hisaab, [2] wale level."""
    A, EFa, ESa = atr_rma(h, l, c, ATRL), ema(c, EF), ema(c, ES)
    hbA = [max(h[max(0, t - ENTRY + 1):t + 1]) for t in range(len(c))]
    lbA = [min(l[max(0, t - ENTRY + 1):t + 1]) for t in range(len(c))]
    hxA = [max(h[max(0, t - EXIT + 1):t + 1]) for t in range(len(c))]
    lxA = [min(l[max(0, t - EXIT + 1):t + 1]) for t in range(len(c))]
    d, e, r, sl, trades = 0, None, None, None, []
    for t in range(start + 1, len(c) + 1):   # t = len(c): aakhri candle ke baad wala din
        _o, _h, _l, _c, _a = o[t - 1], h[t - 1], l[t - 1], c[t - 1], A[t - 1]
        _hb, _lb, _hx, _lx, _ef, _es = hbA[t - 2], lbA[t - 2], hxA[t - 2], lxA[t - 2], EFa[t - 2], ESa[t - 2]
        cl = atC = False
        px = None
        if d != 0:
            if d == 1 and _l <= sl:
                px, cl = (_o if _o < sl else sl), True
            elif d == -1 and _h >= sl:
                px, cl = (_o if _o > sl else sl), True
            if not cl and (_ef < _es if d == 1 else _ef > _es):
                px, cl, atC = _c, True, True
            if not cl:
                sl = max(sl, _lx) if d == 1 else min(sl, _hx)
                if (d == 1 and _c <= sl) or (d == -1 and _c >= sl):
                    px, cl, atC = _c, True, True
        if cl:
            trades[-1] += (t - 1, round(px, 9))
            d = 0
        if d == 0 and not atC and _a > 0:
            bull, bear, live = _ef > _es, _ef < _es, _a / _c * 100 >= MINATR
            buy, sell = _c > _hb and bull and live, _c < _lb and bear and live
            if buy or sell:
                d = 1 if buy else -1
                e, r = _c, MULT * _a
                sl = _c - d * r
                trades.append((t - 1, d, round(e, 9)))
    return trades


def ea_engine(o, h, l, c, start):
    """JasTideRadarEA ka RunEngine() - line ba line wahi tarteeb."""
    A, EFa, ESa = atr_rma(h, l, c, ATRL), ema(c, EF), ema(c, ES)
    d, e, r, sl, trades = 0, 0.0, 0.0, 0.0, []
    for s in range(start, len(c)):
        oo, hh, ll, cc, a = o[s], h[s], l[s], c[s], A[s]
        hb, lb = max(h[s - ENTRY:s]), min(l[s - ENTRY:s])
        hx, lx = max(h[s - EXIT:s]), min(l[s - EXIT:s])
        ef, es = EFa[s - 1], ESa[s - 1]
        cl = atC = False
        px = 0.0
        if d != 0:
            if d == 1 and ll <= sl:
                px, cl = (oo if oo < sl else sl), True
            elif d == -1 and hh >= sl:
                px, cl = (oo if oo > sl else sl), True
            if not cl and ((d == 1 and ef < es) or (d == -1 and ef > es)):
                px, cl, atC = cc, True, True
            if not cl:
                sl = max(sl, lx) if d == 1 else min(sl, hx)
                if (d == 1 and cc <= sl) or (d == -1 and cc >= sl):
                    px, cl, atC = cc, True, True
        if cl:
            trades[-1] += (s, round(px, 9))
            d = 0
        if d == 0 and not atC and a > 0 and cc > 0:
            bull, bear, live = ef > es, ef < es, a / cc * 100.0 >= MINATR
            if live and ((cc > hb and bull) or (cc < lb and bear)):
                d = 1 if (cc > hb and bull) else -1
                e, r = cc, MULT * a
                sl = cc - d * r
                trades.append((s, d, round(e, 9)))
    return trades


def walk(n, seed):
    rnd = random.Random(seed)
    o, h, l, c = [], [], [], []
    p, drift = 100.0, 0.0
    for k in range(n):
        if k % 150 == 0:
            drift = rnd.choice([-1, 1]) * rnd.uniform(0.0005, 0.003)
        op = p * math.exp(rnd.gauss(0, 0.002))   # kabhi gap
        cl = op * math.exp(drift + rnd.gauss(0, 0.012))
        hi = max(op, cl) * math.exp(abs(rnd.gauss(0, 0.006)))
        lo = min(op, cl) * math.exp(-abs(rnd.gauss(0, 0.006)))
        o.append(op); h.append(hi); l.append(lo); c.append(cl)
        p = cl
    return o, h, l, c


def merge_weekend(bars, crypto):
    """EA ka LoadBars(): Sunday/Saturday ki candle agli candle mein; aakhir mein ho to chhor do."""
    out, pend = [], None
    for (dow, o, h, l, c) in bars:
        if not crypto and dow in (0, 6):
            pend = (o, h, l) if pend is None else (pend[0], max(pend[1], h), min(pend[2], l))
            continue
        if pend is not None:
            o, h, l = pend[0], max(pend[1], h), min(pend[2], l)
            pend = None
        out.append((dow, o, h, l, c))
    return out


def main():
    total = 0
    for seed in range(40):
        o, h, l, c = walk(1500, seed)
        start = 300
        a, b = pine_engine(o, h, l, c, start), ea_engine(o, h, l, c, start)
        assert a == b, f"seed {seed}: farq\n{a[:5]}\n{b[:5]}"
        total += len(a)
    print(f"engine: 40 random series, {total} trades - Pine aur EA bilkul ek jaise")

    # weekend milaap: Fri, Sun(chhoti), Mon -> Fri, (Sun+Mon)
    bars = [(5, 10, 11, 9, 10.5), (0, 10.6, 10.9, 10.4, 10.7), (1, 10.7, 12, 10.5, 11.8)]
    m = merge_weekend(bars, crypto=False)
    assert m == [(5, 10, 11, 9, 10.5), (1, 10.6, 12, 10.4, 11.8)], m
    # aakhri candle Sunday hai (Monday abhi band nahi) -> chhor do
    assert merge_weekend(bars[:2], crypto=False) == [bars[0]]
    # crypto par har din apni candle
    assert merge_weekend(bars, crypto=True) == bars
    print("weekend milaap: theek")


if __name__ == "__main__":
    main()
