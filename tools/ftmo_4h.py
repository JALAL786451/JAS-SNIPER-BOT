#!/usr/bin/env python3
"""Koshish #35 (28 Oct 2026) - #34 JAS Trend 4H tokri + server SL, FTMO 2-step.

Qaida (badalna mana): docs/purana-haal.md, grep "Koshish #35 qaida".
FTMO hisaab `ftmo_test.run` (#27) jyon ka tyon; trades yahan 4H se.

  python3 tools/ftmo_4h.py                          # CHUNAO 2012-2018 (12 setting)
  python3 tools/ftmo_4h.py --imtihan --risk 0.5 --k 6   # 2019+ EK dafa
"""
import argparse

import numpy as np
import pandas as pd

from ftmo_test import ATR_LEN, FILES, Mkt, load, run, session_day, supertrend_up


def st4h_trades(df, k):
    """(entry H1 idx, exit H1 idx, entry, exit, SL doori, +1) - 4H flip, SL = k x ATR10(4H)."""
    day = session_day(df['t'])
    blk = ((df['t'].dt.tz_convert('America/New_York') + pd.Timedelta(hours=7)).dt.hour // 4).values
    g = pd.DataFrame({'i': np.arange(len(df)), 'd': day.values, 'b': blk,
                      'H': df['High'].values, 'L': df['Low'].values, 'C': df['Close'].values})
    g = g.groupby(['d', 'b'], sort=True).agg(f=('i', 'first'), la=('i', 'last'),
                                            H=('H', 'max'), L=('L', 'min'), C=('C', 'last'))
    g = g.sort_values('f')
    first, last = g['f'].values, g['la'].values
    up, atr = supertrend_up(g['H'].values, g['L'].values, g['C'].values)
    o, lo, cl = df['Open'].values, df['Low'].values, df['Close'].values
    n4, out, j = len(g), [], 1
    while j < n4 - 1:
        if not (j > ATR_LEN * 3 and up[j] and not up[j - 1]):
            j += 1
            continue
        nxt = first[j + 1]
        e = o[nxt]
        sl = e - k * atr[j]
        ex_i = ex_p = None
        jj = j + 1
        while jj < n4:
            a, b = first[jj], last[jj] + 1
            hit = np.nonzero(lo[a:b] <= sl)[0]
            if len(hit):
                ex_i = a + hit[0]
                ex_p = min(o[ex_i], sl)
                break
            if not up[jj] and jj + 1 < n4:
                ex_i, ex_p = first[jj + 1], o[first[jj + 1]]
                break
            jj += 1
        if ex_i is None:
            ex_i, ex_p = len(df) - 1, cl[-1]
        out.append((nxt, ex_i, e, ex_p, k * atr[j], 1))
        j = jj + 1                           # SL / flip ke baad sirf naya flip upar
    return out


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--imtihan', action='store_true')
    ap.add_argument('--risk', type=float, nargs='*', default=[0.25, 0.5, 0.75, 1.0])
    ap.add_argument('--k', type=float, nargs='*', default=[4, 6, 8])
    a = ap.parse_args()
    dfs = {s: load(s) for s in FILES}
    grid = np.unique(np.concatenate([d['t'].values.astype('datetime64[ns]').astype(np.int64) for d in dfs.values()]))
    cet = pd.to_datetime(grid, utc=True).tz_convert('Europe/Prague')
    cetday = (cet.year * 10000 + cet.month * 100 + cet.day).values
    mkts = [Mkt(s, dfs[s], grid) for s in FILES]
    if a.imtihan:
        starts = pd.date_range('2019-01-01', '2026-10-01', freq='MS', tz='UTC')
        end = grid[-1] + 1
    else:
        starts = pd.date_range('2012-01-01', '2018-12-01', freq='MS', tz='UTC')
        end = pd.Timestamp('2019-01-01', tz='UTC').value
    print(f"{'IMTIHAN 2019+' if a.imtihan else 'CHUNAO 2012-2018'}: {len(starts)} challenge")
    print('risk%  k | pass fail(P1/P2) adhoora | P1fail% | pass mahine (median) | kam din | trades/mahina')
    for k in a.k:
        trades = [st4h_trades(m.df, k) for m in mkts]
        for r in a.risk:
            res = [run(mkts, [(r, trades, {})], s.value, end, grid, cetday) for s in starts]
            ps = [x for x in res if x[0] == 'pass']
            f1 = sum(x[0] == 'fail1' for x in res)
            f2 = sum(x[0] == 'fail2' for x in res)
            ad = sum(x[0] == 'adhoora' for x in res)
            med = np.median([x[1] for x in ps]) if ps else float('nan')
            n_tr = sum(1 for mi in range(4) for tr in trades[mi]
                       if starts[0].value <= grid[mkts[mi].gi[tr[0]]] < end)
            mon = (end - starts[0].value) / 2.63e15
            print(f'{r:5.2f} {k:3.0f} | {len(ps):4d} {f1 + f2:4d} ({f1}/{f2}) {ad:7d} | {100 * f1 / len(res):6.1f}% |'
                  f' {med:6.1f} | {sum(x[2] for x in ps):3d} | {n_tr / mon:.2f}')


if __name__ == '__main__':
    main()
