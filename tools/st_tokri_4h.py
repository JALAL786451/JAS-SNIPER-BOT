#!/usr/bin/env python3
"""Koshish #34 (28 Oct 2026) - JAS Trend t2 (Supertrend 10/3 sirf BUY) 4H TOKRI.

Qaida (badalna mana): docs/purana-haal.md, grep "Koshish #34 qaida".
Data: data/ftmo/*.zip (Dukascopy H1, UTC) -> 4H NY 17:00 se jura.

  python3 tools/st_tokri_4h.py             # TALAASH (entry < 2019)
  python3 tools/st_tokri_4h.py --imtihan   # 2019+ EK dafa

4 market XAUUSD, XAGUSD, US500, USTEC; har market ek position, har trade 1R.
Kharcha 0.03% x (entry+exit), gold par kam az kam $0.50; swap 3%/saal.
"""
import argparse

import numpy as np
import pandas as pd

from ftmo_test import load
from gold_h4_pullback import report
from gold_st_tf import h4_from_h1, trades

MARKETS = {'XAUUSD': 0.50, 'XAGUSD': 0.0, 'US500': 0.0, 'USTEC': 0.0}
CUT = pd.Timestamp('2019-01-01', tz='UTC')


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--imtihan', action='store_true')
    a = ap.parse_args()
    print('IMTIHAN 2019+ (EK dafa)' if a.imtihan else 'TALAASH entry < 2019')
    allt, all0, cells = [], [], []
    for sym, mn in MARKETS.items():
        df = load(sym)
        if not a.imtihan:
            df = df[df['t'] < CUT + pd.Timedelta(days=1)].reset_index(drop=True)
        x = h4_from_h1(df)
        keep = (lambda t: t[t['t'] >= CUT]) if a.imtihan else (lambda t: t[t['t'] < CUT])
        t, t0 = keep(trades(x, min_usd=mn)), keep(trades(x, cost_on=False))
        _, ex, _, _, yr = report(f'{sym:7s}', t)
        cells += list(yr.values)
        t['m'] = sym
        allt.append(t)
        all0.append(t0)
    t = pd.concat(allt)
    n, ex, se, _, _ = report('KUL    ', t)
    t0 = pd.concat(all0)
    print(f'   bina kharcha {t0["r"].mean():+.4f}R')
    mk = t.groupby('m')['r'].mean()
    cells = np.array(cells)
    print(f'   market musbat {(mk > 0).sum()}/4, (market x saal) musbat {(cells > 0).sum()}/{len(cells)}')
    if a.imtihan:
        ok = n >= 30 and ex - 2 * se > 0
    else:
        ok = n >= 100 and ex - 2 * se > 0 and (mk > 0).sum() >= 3 and (cells > 0).mean() > 0.5
    print('PASS' if ok else 'FAIL')


if __name__ == '__main__':
    main()
