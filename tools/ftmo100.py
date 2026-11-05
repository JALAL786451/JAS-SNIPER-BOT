#!/usr/bin/env python3
"""Koshish #100 (5 Nov 2026): FTMO challenge - TREND (JasTrend 4H 0.75%) vs TIDE (Kachhua 12 market), swap 0.

Qaida (badalna mana): docs/purana-haal.md, grep "Koshish #100 qaida".
  python3 tools/ftmo100.py                    # CHUNAO 2012-2018 (Tide risk grid)
  python3 tools/ftmo100.py --imtihan --risk R # 2019+ EK dafa
"""
import argparse

import numpy as np
import pandas as pd

import ftmo_test
from ftmo53_asli import run_cost
from ftmo60 import summary
from ftmo99 import SPREAD
from ftmo_4h import st4h_trades
from ftmo_test import Mkt, kachhua_trades
from tokri47 import load_any

ftmo_test.SWAP = 0.0          # FTMO swap-free (user ki email)
TREND4 = ('XAUUSD', 'XAGUSD', 'US500', 'USTEC')


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--imtihan', action='store_true')
    ap.add_argument('--risk', type=float, default=None)
    a = ap.parse_args()
    syms = list(SPREAD)
    dfs = {s: load_any(s) for s in syms}
    grid = np.unique(np.concatenate([d['t'].values.astype('datetime64[ns]').astype(np.int64) for d in dfs.values()]))
    cet = pd.to_datetime(grid, utc=True).tz_convert('Europe/Prague')
    cetday = (cet.year * 10000 + cet.month * 100 + cet.day).values
    mk = [Mkt(s, dfs[s], grid) for s in syms]
    cost = [0.75 * SPREAD[s] for s in syms]
    trend = [st4h_trades(dfs[s], 6.0) if s in TREND4 else [] for s in syms]
    tide = [kachhua_trades(dfs[s]) for s in syms]
    metal = {syms.index('XAGUSD'): syms.index('XAUUSD')}     # gold + silver ek slot
    if a.imtihan:
        starts = pd.date_range('2019-01-01', '2026-10-01', freq='MS', tz='UTC')
        risks = [a.risk]
    else:
        starts = pd.date_range('2012-01-01', '2018-12-01', freq='MS', tz='UTC')
        risks = [0.25, 0.50, 0.75, 1.0]
    end = grid[-1] + 1 if a.imtihan else pd.Timestamp('2019-01-01', tz='UTC').value
    nm = 'IMTIHAN 2019-01..2026-10' if a.imtihan else 'CHUNAO 2012-01..2018-12'
    print(f'#100 {nm}: {len(starts)} challenge, swap 0 (pass / fail (P1/P2) / adhoora, median mahine)', flush=True)

    def show(lbl, res):
        p, f1, f2, ad, med = summary(res)
        print(f'  {lbl:28s} pass {p:3d}  fail {f1 + f2:3d} ({f1}/{f2})  adhoora {ad:3d}  median {med:5.1f}  pass-fail {p - f1 - f2:+d}', flush=True)
        return p, f1, f2, med

    A = show('A TREND 0.75% (4 market)', [run_cost(mk, [(0.75, trend, {})], s.value, end, grid, cetday, cost) for s in starts])
    best = None
    for r in risks:
        p, f1, f2, med = B = show(f'B TIDE {r:.2f}% (12 market)', [run_cost(mk, [(r, tide, metal)], s.value, end, grid, cetday, cost) for s in starts])
        n = len(starts)
        if not a.imtihan and f1 < 0.2 * n and p > f1 + f2:
            key = (p - f1 - f2, -med, -r)
            best = max(best, (key, r)) if best else (key, r)
    if not a.imtihan:
        print('  CHUNAO:', f'umeedwar risk {best[1]:.2f}%' if best else 'koi umeedwar NAHI = Tide FTMO FAIL')
    else:
        da, db = A[0] - A[1] - A[2], B[0] - B[1] - B[2]
        tj = db > da or (db == da and B[3] < A[3])
        print('  IMTIHAN:', 'TIDE JEETA' if tj else 'TREND JEETA', f'(pass-fail A {da:+d} vs B {db:+d}, median A {A[3]:.1f} vs B {B[3]:.1f})')


if __name__ == '__main__':
    main()
