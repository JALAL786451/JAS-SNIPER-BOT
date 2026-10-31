#!/usr/bin/env python3
"""#49 ka seedha REPORT CARD (31 Oct 2026): ek $100k account, FTMO reset ke baghair, lagatar chalaya.
Trend 4H tokri (XAU, XAG, US500, USTEC) 0.75% + IBS US500 2%, risk hamesha $100k par (compound nahi).
Kharcha / swap #27 jaisa. Girawat (DD) = equity ki chothi se sab se neeche (khuli trade ka bura ghanta shamil).

  python3 tools/report49.py                 # 2019-aaj
  python3 tools/report49.py --from 2012     # 2012-2018 (purana)
"""
import argparse

import numpy as np
import pandas as pd

from ftmo_4h import st4h_trades
from ftmo_test import BAL0, COST, FILES, SWAP, Mkt, ibs_trades, load

NAMES = {'XAUUSD': 'Gold', 'XAGUSD': 'Silver', 'US500': 'US500', 'USTEC': 'USTEC'}


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--from', dest='frm', default='2019')
    ap.add_argument('--to', default=None)
    ap.add_argument('--ibs-syms', nargs='*', default=['US500'])     # #53: US500 USTEC
    ap.add_argument('--ibs-risk', type=float, default=2.0)          # #53: 1.0
    a = ap.parse_args()
    syms = list(FILES)
    dfs = {s: load(s) for s in syms}
    grid = np.unique(np.concatenate([d['t'].values.astype('datetime64[ns]').astype(np.int64) for d in dfs.values()]))
    cet = pd.to_datetime(grid, utc=True).tz_convert('Europe/Prague')
    cetday = (cet.year * 10000 + cet.month * 100 + cet.day).values
    mkts = [Mkt(s, dfs[s], grid) for s in syms]
    systems = [('Trend 4H', 0.75, [st4h_trades(dfs[s], 6.0) for s in syms]),
               ('IBS', a.ibs_risk, [ibs_trades(dfs[s]) if s in a.ibs_syms else [] for s in syms])]
    t0 = pd.Timestamp(f'{a.frm}-01-01', tz='UTC').value
    t1 = pd.Timestamp(a.to, tz='UTC').value if a.to else (pd.Timestamp('2019-01-01', tz='UTC').value if a.frm < '2019' else grid[-1] + 1)
    tl = []
    for si, (nm, risk, trades) in enumerate(systems):
        for mi, m in enumerate(mkts):
            for (ei, xi, e, x, sd, d) in trades[mi]:
                ge, gx = m.gi[ei], m.gi[xi]
                if t0 <= grid[ge] < t1:
                    tl.append((ge, gx, si * 10 + mi, e, x, BAL0 * risk / 100 / sd, mi, d, si))
    tl.sort()
    i0, i1 = np.searchsorted(grid, t0), np.searchsorted(grid, t1)
    bal, open_, ti, day = BAL0, {}, 0, None
    closed = []                                   # (system, market, P/L $, saal)
    peak, maxdd, dstart, worstday = BAL0, 0.0, BAL0, 0.0
    eq_daily = []
    for t in range(i0, i1):
        if cetday[t] != day:
            if day is not None:
                eq_daily.append((day, eq))
            day = cetday[t]
            for p in open_.values():
                bal -= SWAP * p[1] * mkts[p[2][6]].clf[t]
            dstart = bal + sum((mkts[p[2][6]].clf[t] - p[0]) * p[2][7] * p[1] for p in open_.values())
        for slot in list(open_):
            ep, u, tr = open_[slot]
            if tr[1] == t:
                pl = tr[7] * (tr[4] - ep) * u - COST * tr[4] * u - COST * ep * u
                bal += tr[7] * (tr[4] - ep) * u - COST * tr[4] * u
                closed.append((tr[8], tr[6], pl, pd.Timestamp(grid[t], tz='UTC').year))
                del open_[slot]
        while ti < len(tl) and tl[ti][0] <= t:
            tr = tl[ti]
            ti += 1
            if tr[0] < t or tr[2] in open_ or tr[1] <= tr[0]:
                continue
            bal -= COST * tr[3] * tr[5]
            open_[tr[2]] = (tr[3], tr[5], tr)
        worst = bal + sum(((mkts[p[2][6]].lowf[t] if p[2][7] > 0 else mkts[p[2][6]].highf[t]) - p[0]) * p[2][7] * p[1]
                          for p in open_.values())
        eq = bal + sum((mkts[p[2][6]].clf[t] - p[0]) * p[2][7] * p[1] for p in open_.values())
        peak = max(peak, eq)
        maxdd = max(maxdd, (peak - worst) / BAL0)
        worstday = min(worstday, (worst - dstart) / BAL0)
    c = pd.DataFrame(closed, columns=['s', 'm', 'pl', 'y'])
    years = (grid[i1 - 1] - grid[i0]) / 3.156e16
    print(f'=== #49 REPORT CARD: $100,000 account, {pd.Timestamp(grid[i0], tz="UTC"):%b %Y} - {pd.Timestamp(grid[i1 - 1], tz="UTC"):%b %Y} ({years:.1f} saal) ===')
    print(f'EA: 2 (Trend 4H 0.75% + IBS {a.ibs_risk}% {"+".join(a.ibs_syms)})   Market: 4 (Gold, Silver, US500, USTEC)')
    print(f'Kul trade: {len(c)}  (~{len(c) / years / 12:.1f} mahina)   jeet: {100 * (c.pl > 0).mean():.0f}%')
    print(f'Kul faida: ${bal - BAL0:,.0f}  = {100 * (bal - BAL0) / BAL0:.1f}%   (~{100 * (bal - BAL0) / BAL0 / years:.1f}% saal)')
    print(f'Sab se bari girawat (DD): {100 * maxdd:.1f}%   sab se bura din: {100 * worstday:.1f}%')
    print('Saal ba saal:', '  '.join(f'{y}: {100 * v / BAL0:+.1f}%' for y, v in c.groupby('y').pl.sum().items()))
    for si, (nm, risk, _) in enumerate(systems):
        x = c[c.s == si]
        print(f'  {nm:8s}: {len(x)} trade, jeet {100 * (x.pl > 0).mean():.0f}%, faida ${x.pl.sum():,.0f}')
    for mi, s in enumerate(syms):
        x = c[c.m == mi]
        print(f'  {NAMES[s]:7s}: {len(x)} trade, faida ${x.pl.sum():,.0f}')


if __name__ == '__main__':
    main()
