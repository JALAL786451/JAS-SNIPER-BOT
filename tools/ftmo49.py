#!/usr/bin/env python3
"""Koshish #49 (31 Oct 2026) - FTMO: #34 4H trend tokri (XAU, XAG, US500, USTEC) + #15 IBS S&P mila kar.
Qaida (badalna mana): docs/purana-haal.md, grep "Koshish #49 qaida".

  python3 tools/ftmo49.py                               # CHUNAO 2012-2018 (9 setting)
  python3 tools/ftmo49.py --imtihan --tr 0.5 --ibs 1.0  # 2019+ EK dafa
"""
import argparse

import numpy as np
import pandas as pd

from ftmo_4h import st4h_trades
from ftmo_test import FILES, Mkt, ibs_trades, load, run

K = 6.0


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--imtihan', action='store_true')
    ap.add_argument('--tr', type=float, nargs='*', default=[0.25, 0.5, 0.75])
    ap.add_argument('--ibs', type=float, nargs='*', default=[0.5, 1.0, 2.0])
    a = ap.parse_args()
    syms = list(FILES)
    dfs = {s: load(s) for s in syms}
    grid = np.unique(np.concatenate([d['t'].values.astype('datetime64[ns]').astype(np.int64) for d in dfs.values()]))
    cet = pd.to_datetime(grid, utc=True).tz_convert('Europe/Prague')
    cetday = (cet.year * 10000 + cet.month * 100 + cet.day).values
    mkts = [Mkt(s, dfs[s], grid) for s in syms]
    trend = [st4h_trades(dfs[s], K) for s in syms]
    ibs = [ibs_trades(dfs[s]) if s == 'US500' else [] for s in syms]
    if a.imtihan:
        starts = pd.date_range('2019-01-01', '2026-10-01', freq='MS', tz='UTC')
        end = grid[-1] + 1
    else:
        starts = pd.date_range('2012-01-01', '2018-12-01', freq='MS', tz='UTC')
        end = pd.Timestamp('2019-01-01', tz='UTC').value
    mon = (end - starts[0].value) / 2.63e15
    cnt = lambda tl: sum(1 for mi in range(len(mkts)) for t in tl[mi] if starts[0].value <= grid[mkts[mi].gi[t[0]]] < end)
    print(f"{'IMTIHAN 2019+' if a.imtihan else 'CHUNAO 2012-2018'}: {len(starts)} challenge | "
          f"trend {cnt(trend) / mon:.1f} + IBS {cnt(ibs) / mon:.1f} trade/mahina")
    print('trend% ibs% | pass fail(P1/P2) adhoora | P1fail% | pass mahine (median) | kam din')
    best = None
    for rt in a.tr:
        for ri in a.ibs:
            res = [run(mkts, [(rt, trend, {}), (ri, ibs, {})], s.value, end, grid, cetday) for s in starts]
            ps = [x for x in res if x[0] == 'pass']
            f1, f2 = sum(x[0] == 'fail1' for x in res), sum(x[0] == 'fail2' for x in res)
            ad = sum(x[0] == 'adhoora' for x in res)
            med = np.median([x[1] for x in ps]) if ps else float('nan')
            p1 = 100 * f1 / len(res)
            ok = p1 < 20 and len(ps) > f1 + f2
            print(f'{rt:5.2f} {ri:4.1f} | {len(ps):4d} {f1 + f2:4d} ({f1}/{f2}) {ad:7d} | {p1:6.1f}% | {med:6.1f} | '
                  f'{sum(x[2] for x in ps):3d}{"  <- shart poori" if ok else ""}', flush=True)
            if ok:
                key = (len(ps) - f1 - f2, -(rt + ri))
                if best is None or key > best[0]:
                    best = (key, rt, ri)
    if not a.imtihan:
        print('CHUNI SETTING: ' + (f'trend {best[1]}% + IBS {best[2]}%' if best else 'KOI NAHI = FAIL'))
    else:
        print('(IMTIHAN: PASS = pass > fail aur P1 fail < 20%)')


if __name__ == '__main__':
    main()
