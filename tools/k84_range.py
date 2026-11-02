#!/usr/bin/env python3
"""Koshish #84 (2 Nov 2026) - gold RANGE BARS gate: ek rang ke k bar ke baad agla usi rang ka %. Qaida: docs/purana-haal.md grep "Koshish #84 qaida".

  python3 tools/k84_range.py      # GATE 2009-2013, kharcha nahi
"""
import zipfile
from pathlib import Path

import numpy as np
import pandas as pd

ROOT = Path(__file__).resolve().parents[1]


def load(years):
    out = []
    for y in years:
        z = zipfile.ZipFile(ROOT / f'data/histdata/XAUUSD_M1_{y}_NY.zip')
        nm = next(n for n in z.namelist() if n.endswith('.csv'))
        out.append(pd.read_csv(z.open(nm), sep=';', header=None, names=['dt', 'O', 'H', 'L', 'C', 'V']))
    return pd.concat(out, ignore_index=True)


def colours(df, R, flip):
    O, H, L, C = (df[c].values for c in 'OHLC')
    col = []
    o = hi = lo = O[0]
    for i in range(len(O)):
        up_first = (C[i] < O[i]) if not flip else (C[i] >= O[i])   # aam: close>=open -> O,L,H,C (pehle neeche)
        path = (O[i], H[i], L[i], C[i]) if up_first else (O[i], L[i], H[i], C[i])
        for q in path:
            while True:
                if q >= lo + R:                                     # upar band
                    col.append(1 if lo + R >= o else -1)
                    o = hi = lo = lo + R
                elif q <= hi - R:                                   # neeche band
                    col.append(-1 if hi - R <= o else 1)
                    o = hi = lo = hi - R
                else:
                    hi, lo = max(hi, q), min(lo, q)
                    break
    return np.array(col)


def stats(c, k):
    n = same = 0
    run = 1
    for i in range(1, len(c) - 1):
        run = run + 1 if c[i] == c[i - 1] else 1
        if run >= k and i >= k - 1:
            n += 1
            same += c[i + 1] == c[i]
    p = same / n if n else np.nan
    return p, np.sqrt(p * (1 - p) / n) if n else np.nan, n


def main():
    df = load(range(2009, 2014))
    print(f'GATE 2009-2013: {len(df)} M1 candle')
    res = {}
    for R in (5, 10, 20):
        hurdle = 0.24 / R
        for flip in (False, True):
            c = colours(df, R, flip)
            for k in range(1, 6):
                p, se, n = stats(c, k)
                res[(R, k, flip)] = p
                ok = abs(p - 0.5) > 2 * se + hurdle
                print(f'R ${R:2d} {"ULTA " if flip else "aam  "} k={k}: {n:6d} | agla usi rang {p:.1%} (SE {se:.1%}, hurdle {hurdle:.1%})'
                      f'{"  <- PAAR" if ok else ""}', flush=True)
    passed = []
    # pakka faisla dobara (SE ke saath)
    print()
    for R in (5, 10, 20):
        hurdle = 0.24 / R
        c0, c1 = colours(df, R, False), colours(df, R, True)
        for k in range(1, 6):
            p0, s0, _ = stats(c0, k)
            p1, s1, _ = stats(c1, k)
            ok0 = abs(p0 - 0.5) > 2 * s0 + hurdle
            ok1 = abs(p1 - 0.5) > 2 * s1 + hurdle and np.sign(p1 - 0.5) == np.sign(p0 - 0.5)
            keep = abs(p1 - 0.5) >= 0.7 * abs(p0 - 0.5)
            if ok0 and ok1 and keep:
                passed.append((R, k, p0, p1))
    print('GATE: ' + ('PASS ' + str(passed) if passed else 'FAIL (koi R,k hurdle + raasta ulta dono par paar nahi)'))


if __name__ == '__main__':
    main()
