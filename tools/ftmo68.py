#!/usr/bin/env python3
"""Koshish #68 (1 Nov 2026) - FTMO: #53 (trend 4H 0.75% + IBS US500/USTEC 1%) + #67 US chutti ki khirki x 7 non-US index CFD.
Qaida (badalna mana): docs/purana-haal.md, grep "Koshish #68 qaida". Kharcha asli (#53), khirki 0.02%/taraf.

  python3 tools/ftmo68.py              # CHUNAO 2012-2018 (khirki risk 0 / 0.10 / 0.15 / 0.25 har index)
  python3 tools/ftmo68.py --imtihan --risk 0.15   # 2019+ EK dafa, chuni risk
"""
import argparse
import datetime as D

import numpy as np
import pandas as pd

from ftmo53_asli import ASLI, run_cost
from ftmo60 import hol, summary
from ftmo_4h import st4h_trades
from ftmo_test import FILES, Mkt, atr_rma, ibs_trades, load
from tokri47 import load_any

KH = {'DEUIDXEUR': ('Europe/Berlin', 17 * 60 + 30), 'GBRIDXGBP': ('Europe/London', 16 * 60 + 30),
      'FRAIDXEUR': ('Europe/Paris', 17 * 60 + 30), 'EUSIDXEUR': ('Europe/Berlin', 17 * 60 + 30),
      'JPNIDXJPY': ('Asia/Tokyo', 15 * 60), 'AUSIDXAUD': ('Australia/Sydney', 16 * 60),
      'HKGIDXHKD': ('Asia/Hong_Kong', 16 * 60)}
KCOST = 0.0002
RISKS = [0.10, 0.15, 0.25]


def f_win(e):
    """#67 f_win: E ka agla weekday P NYSE din ho aur P ke baad wala weekday NYSE chutti H -> H, warna None."""
    p = e + D.timedelta(days=1)
    while p.isoweekday() > 5:
        p += D.timedelta(days=1)
    if hol(p):
        return None
    q = p + D.timedelta(days=1)
    while q.isoweekday() > 5:
        q += D.timedelta(days=1)
    return q if hol(q) else None


def khirki_trades(df, tz, cmin):
    loc = df['t'].dt.tz_convert(tz)
    dt = loc.dt.date.values
    mn = (loc.dt.hour * 60 + loc.dt.minute).values
    first = {}
    for i in np.nonzero(mn >= cmin)[0]:
        first.setdefault(dt[i], i)                    # local din ki cash close ke baad pehli H1
    g = pd.DataFrame({'d': dt, 'H': df['High'].values, 'L': df['Low'].values, 'C': df['Close'].values}).groupby('d', sort=True)
    days = list(g.groups.keys())
    a = atr_rma(g['H'].max().values, g['L'].min().values, g['C'].last().values, 20)
    atr_prev = dict(zip(days[1:], a[:-1]))
    dates = sorted(first)
    op, lo = df['Open'].values, df['Low'].values
    out = []
    for k, e in enumerate(dates):
        h = f_win(e)
        at = atr_prev.get(e)
        if h is None or not at or not at > 0:
            continue
        xd = next((x for x in dates[k + 1:] if x >= h), None)
        if xd is None:
            continue
        ei, xi = first[e], first[xd]
        ep, sd = op[ei], 3.0 * at
        sl = ep - sd
        xp = op[xi]
        hit = np.nonzero(lo[ei:xi] <= sl)[0]
        if len(hit):
            j = ei + hit[0]
            xi, xp = j, (sl if j == ei else min(op[j], sl))
        if xi > ei:
            out.append((ei, xi, ep, xp, sd, 1))
    return out


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--imtihan', action='store_true')
    ap.add_argument('--risk', type=float, default=None)
    a = ap.parse_args()
    base = list(FILES)
    syms = base + list(KH)
    dfs = {s: load(s) for s in base}
    dfs.update({s: load_any(s) for s in KH})
    grid = np.unique(np.concatenate([d['t'].values.astype('datetime64[ns]').astype(np.int64) for d in dfs.values()]))
    cet = pd.to_datetime(grid, utc=True).tz_convert('Europe/Prague')
    cetday = (cet.year * 10000 + cet.month * 100 + cet.day).values
    mk = [Mkt(s, dfs[s], grid) for s in syms]
    trend = [st4h_trades(dfs[s], 6.0) if s in base else [] for s in syms]
    ibs = [ibs_trades(dfs[s]) if s in ('US500', 'USTEC') else [] for s in syms]
    kh = [khirki_trades(dfs[s], *KH[s]) if s in KH else [] for s in syms]
    cost = [0.75 * ASLI[s] if s in base else KCOST for s in syms]
    if a.imtihan:
        starts, end = pd.date_range('2019-01-01', '2026-10-01', freq='MS', tz='UTC'), grid[-1] + 1
    else:
        starts, end = pd.date_range('2012-01-01', '2018-12-01', freq='MS', tz='UTC'), pd.Timestamp('2019-01-01', tz='UTC').value
    yrs = (end - starts[0].value) / 3.156e16
    for s, tl in zip(syms, kh):
        if tl:
            t = dfs[s]['t'].values.astype('datetime64[ns]').astype(np.int64)
            k = [x for x in tl if starts[0].value <= t[x[0]] < end]
            r = [(x[3] - x[2]) / x[4] for x in k]
            print(f'khirki {s}: {len(k)} tr ({len(k) / yrs:.1f}/saal), ausat {np.mean([x[3] / x[2] - 1 for x in k]) * 100:+.3f}%, {np.mean(r):+.3f}R (kharche se pehle)')
    print(f"{'IMTIHAN 2019+' if a.imtihan else 'CHUNAO 2012-2018'}: {len(starts)} challenge (kharcha asli)")
    print('khirki risk | pass fail(P1/P2) adhoora | P1fail% | pass mahine median')
    risks = [0.0] + ([a.risk] if a.imtihan else RISKS)
    rows = {}
    for rk in risks:
        sy = [(0.75, trend, {}), (1.0, ibs, {})] + ([(rk, kh, {})] if rk > 0 else [])
        res = [run_cost(mk, sy, s0.value, end, grid, cetday, cost) for s0 in starts]
        ps, f1, f2, ad, med = summary(res)
        rows[rk] = (ps, f1, f2, ad, med, 100 * f1 / len(res))
        print(f'{rk:10.2f}  | {ps:4d} {f1 + f2:4d} ({f1}/{f2}) {ad:7d} | {100 * f1 / len(res):6.1f}% | {med:6.1f}'
              f'{"   <- #53 akela" if rk == 0 else ""}', flush=True)
    b = rows[0.0]
    if not a.imtihan:
        ok = [(r[0] - r[1] - r[2], -r[4], -rk, rk) for rk, r in rows.items()
              if rk > 0 and r[5] < 20 and r[0] > r[1] + r[2] and r[0] - r[1] - r[2] >= b[0] - b[1] - b[2]]
        print('CHUNI khirki risk: ' + (f'{max(ok)[3]}%' if ok else 'KOI NAHI = FAIL'))
    else:
        r = rows[a.risk]
        okI = r[1] + r[2] == 0 and r[0] >= 83 and r[4] < 11.7
        print('IMTIHAN: ' + ('PASS' if okI else 'FAIL') + ' (shart: fail 0, pass >= 83, median < 11.7)')


if __name__ == '__main__':
    main()
