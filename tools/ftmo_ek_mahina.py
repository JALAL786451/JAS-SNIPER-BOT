#!/usr/bin/env python3
"""FTMO 1 mahine mein pass? (28 Oct 2026, maloomat, koshish nahi) - JasTrend daily + 4H tokri, risk 1/2/3/5%, har mahine naya challenge 2012-2026."""
import sys
import numpy as np, pandas as pd
from ftmo_test import FILES, Mkt, load, run, trades_for
from ftmo_4h import st4h_trades
dfs = {s: load(s) for s in FILES}
grid = np.unique(np.concatenate([d['t'].values.astype('datetime64[ns]').astype(np.int64) for d in dfs.values()]))
cet = pd.to_datetime(grid, utc=True).tz_convert('Europe/Prague')
cetday = (cet.year * 10000 + cet.month * 100 + cet.day).values
mkts = [Mkt(s, dfs[s], grid) for s in FILES]
starts = pd.date_range('2012-02-01', '2026-09-01', freq='MS', tz='UTC')
print(len(starts), 'challenge (har mahine), 2012-2026')
print('system          risk | 1 mahine mein PASS | 1 mahine mein FAIL | kabhi bhi pass / fail')
for name, tr in [('JasTrend daily', [trades_for(m.df, 4) for m in mkts]), ('4H tokri k4', [st4h_trades(m.df, 4) for m in mkts])]:
    for r in [1, 2, 3, 5]:
        res = [run(mkts, [(r, tr, {})], s.value, grid[-1] + 1, grid, cetday) for s in starts]
        p1 = sum(x[0] == 'pass' and x[1] <= 1.0 for x in res)
        f1 = sum(x[0].startswith('fail') and x[1] <= 1.0 for x in res)
        pa = sum(x[0] == 'pass' for x in res); fa = sum(x[0].startswith('fail') for x in res)
        print(f'{name:15s} {r:3d}% | {100*p1/len(res):5.1f}% | {100*f1/len(res):5.1f}% | {pa} / {fa}')
