#!/usr/bin/env python3
"""Koshish #99 (5 Nov 2026): Kachhua (Tide) 12 market, SWAP 0 (FTMO swap-free), kharcha 0.75 x Exness spread.

Qaida (badalna mana): docs/purana-haal.md, grep "Koshish #99 qaida".
  python3 tools/ftmo99.py            # TALAASH (entry < 2019)
  python3 tools/ftmo99.py --imtihan  # 2019+ EK dafa (sirf TALAASH PASS ke baad)
"""
import argparse
from collections import defaultdict

import numpy as np

from ftmo_test import kachhua_trades
from tokri47 import load_any

SPREAD = {'XAUUSD': 0.0059e-2, 'XAGUSD': 0.0445e-2, 'US500': 0.0052e-2, 'USTEC': 0.0038e-2,
          'LIGHTCMDUSD': 0.0194e-2, 'BRENTCMDUSD': 0.0151e-2, 'BTCUSD': 0.0079e-2,
          'EURUSD': 0.0084e-2, 'GBPUSD': 0.0095e-2, 'USDJPY': 0.0085e-2, 'USDCHF': 0.0183e-2,
          'AUDUSD': 0.0149e-2}


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--imtihan', action='store_true')
    im = ap.parse_args().imtihan
    a, b = (np.datetime64('2019-01-01'), np.datetime64('2100-01-01')) if im else (np.datetime64('1900-01-01'), np.datetime64('2019-01-01'))
    allr, allb, cells, mk_pos = [], [], defaultdict(float), 0
    print(f"#99 Kachhua 12 market, swap 0, kharcha 0.75 x spread - {'IMTIHAN 2019+' if im else 'TALAASH < 2019'}")
    for s, sp in SPREAD.items():
        df = load_any(s)
        t = df['t'].values.astype('datetime64[ns]')
        cost = 0.75 * sp
        rs, bs = [], []
        for ei, xi, e, x, r, d in kachhua_trades(df):
            if not (a <= t[ei] < b):
                continue
            rr = (d * (x - e) - cost * (e + x)) / r
            rs.append(rr)
            bs.append(d)
            cells[(s, int(str(t[ei])[:4]))] += rr
        rs = np.array(rs)
        ex = rs.mean() if len(rs) else np.nan
        mk_pos += int(len(rs) > 0 and ex > 0)
        nb = sum(1 for d in bs if d == 1)
        print(f"  {s:12s} data {str(t[0])[:10]}  {len(rs):4d} tr (BUY {nb}, SELL {len(rs) - nb})  Exp {ex:+.3f}R")
        allr += list(rs)
        allb += bs
    R = np.array(allr)
    n = len(R)
    ex = R.mean()
    se = R.std(ddof=1) / np.sqrt(n)
    pos = np.mean([v > 0 for v in cells.values()])
    B = np.array(allb)
    print(f"KUL {n} tr, jeet {np.mean(R > 0) * 100:.0f}%, Exp {ex:+.3f}R (SE {se:.3f}), Exp-2SE {ex - 2 * se:+.3f}")
    print(f"  BUY {np.sum(B == 1)} tr {R[B == 1].mean():+.3f}R · SELL {np.sum(B == -1)} tr {R[B == -1].mean():+.3f}R")
    print(f"  market Exp > 0: {mk_pos}/12 · (market x saal) musbat {pos * 100:.0f}% ({len(cells)} khane)")
    if im:
        ok = n >= 30 and ex - 2 * se > 0
        print('IMTIHAN', 'PASS' if ok else 'FAIL', f'(>=30 tr {n >= 30}, Exp-2SE>0 {ex - 2 * se > 0})')
    else:
        c = [n >= 100, ex - 2 * se > 0, mk_pos >= 8, pos > 0.5]
        print('TALAASH', 'PASS' if all(c) else 'FAIL', f'(>=100 {c[0]}, Exp-2SE>0 {c[1]}, >=8/12 {c[2]}, saal>50% {c[3]})')


if __name__ == '__main__':
    main()
