#!/usr/bin/env python3
"""Koshish #60 (1 Nov 2026) - FTMO: #53 (trend 4H 0.75% + IBS US500/USTEC 1%) + #59 chutti se pehle wala din (US500 + USTEC).
Qaida (badalna mana): docs/purana-haal.md, grep "Koshish #60 qaida". Kharcha asli (ftmo53_asli).

  python3 tools/ftmo60.py              # CHUNAO 2012-2018 (chutti risk 0 / 0.25 / 0.5 / 0.75 / 1.0)
  python3 tools/ftmo60.py --imtihan    # 2019+ EK dafa, chuni risk
"""
import argparse
import datetime as D

import numpy as np
import pandas as pd

from ftmo53_asli import ASLI, run_cost
from ftmo_4h import st4h_trades
from ftmo_test import FILES, Mkt, atr_rma, ibs_trades, load, session_day

NY = 'America/New_York'
RISKS = [0.25, 0.5, 0.75, 1.0]


def easter(y):
    a, b, c = y % 19, y // 100, y % 100
    d, e = b // 4, b % 4
    f = (b + 8) // 25
    g = (b - f + 1) // 3
    h = (19 * a + b - d - g + 15) % 30
    i, k = c // 4, c % 4
    l = (32 + 2 * e + 2 * i - h - k) % 7
    m = (a + 11 * h + 22 * l) // 451
    n = h + l - 7 * m + 114
    return n // 31, n % 31 + 1


def hol(dt):
    """NYSE pehle se maloom chutti (#59 / jas_chutti.pine h1 jaisa)."""
    y, m, d, w = dt.year, dt.month, dt.day, dt.isoweekday()
    wk, mon, fri = w <= 5, w == 1, w == 5
    h = False
    if m == 1:
        h = (d == 1 and wk) or (d == 2 and mon) or (y >= 1998 and mon and 15 <= d <= 21)
    elif m == 2:
        h = mon and 15 <= d <= 21
    elif m == 5:
        h = mon and d >= 25
    elif m == 6:
        h = y >= 2022 and ((d == 19 and wk) or (d == 18 and fri) or (d == 20 and mon))
    elif m == 7:
        h = (d == 4 and wk) or (d == 3 and fri) or (d == 5 and mon)
    elif m == 9:
        h = mon and d <= 7
    elif m == 11:
        h = (w == 4 and 22 <= d <= 28) or (y in (1972, 1976, 1980) and w == 2 and 2 <= d <= 8)
    elif m == 12:
        h = (d == 25 and wk) or (d == 24 and fri) or (d == 26 and mon)
    if not h and fri and m in (3, 4):
        em, ed = easter(y)
        h = D.date(y, em, ed) - D.timedelta(days=2) == dt
    return h


def prenext(dt):
    """dt ke baad agla trading din p - kya p chutti se pehle wala din hai? -> (bool, p)."""
    p = dt
    while True:
        p += D.timedelta(days=1)
        if p.isoweekday() <= 5 and not hol(p):
            break
    q = p
    while True:
        q += D.timedelta(days=1)
        if q.isoweekday() <= 5:
            return hol(q), p


def chutti_trades(df):
    """(entry idx, exit idx, entry, exit, ATR14 daily, 1): d 16:00 NY -> p 16:00 NY (3 Jul / 24 Dec = 13:00)."""
    ny = df['t'].dt.tz_convert(NY)
    date, hr, mn = ny.dt.date.values, ny.dt.hour.values, ny.dt.minute.values
    key = {(date[i], hr[i]): i for i in np.nonzero((mn == 0) & ((hr == 16) | (hr == 13)))[0]}
    sd = session_day(df['t'])
    g = df.assign(sd=sd.values).groupby('sd', sort=True)
    h, l, c = g['High'].max().values, g['Low'].min().values, g['Close'].last().values
    a = atr_rma(h, l, c, 14)
    labels = [x.date() for x in g['High'].max().index]
    atr_prev = dict(zip(labels[1:], a[:-1]))
    op = df['Open'].values
    out, d = [], min(date)
    while d <= max(date):
        if d.isoweekday() <= 5 and not hol(d):
            f, p = prenext(d)
            if f:
                early = (p.month, p.day) in ((7, 3), (12, 24))
                ei, xi, at = key.get((d, 16)), key.get((p, 13 if early else 16)), atr_prev.get(d)
                if ei is not None and xi is not None and at and at > 0 and xi > ei:
                    out.append((ei, xi, op[ei], op[xi], at, 1))
        d += D.timedelta(days=1)
    return out


def summary(res):
    ps = [x for x in res if x[0] == 'pass']
    f1, f2 = sum(x[0] == 'fail1' for x in res), sum(x[0] == 'fail2' for x in res)
    ad = sum(x[0] == 'adhoora' for x in res)
    med = float(np.median([x[1] for x in ps])) if ps else float('nan')
    return len(ps), f1, f2, ad, med


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--imtihan', action='store_true')
    ap.add_argument('--risk', type=float, default=None, help='IMTIHAN: CHUNAO wali chutti risk')
    a = ap.parse_args()
    syms = list(FILES)
    dfs = {s: load(s) for s in syms}
    grid = np.unique(np.concatenate([d['t'].values.astype('datetime64[ns]').astype(np.int64) for d in dfs.values()]))
    cet = pd.to_datetime(grid, utc=True).tz_convert('Europe/Prague')
    cetday = (cet.year * 10000 + cet.month * 100 + cet.day).values
    mk = [Mkt(s, dfs[s], grid) for s in syms]
    trend = [st4h_trades(dfs[s], 6.0) for s in syms]
    ibs = [ibs_trades(dfs[s]) if s in ('US500', 'USTEC') else [] for s in syms]
    ch = [chutti_trades(dfs[s]) if s in ('US500', 'USTEC') else [] for s in syms]
    cost = [0.75 * ASLI[s] for s in syms]
    if a.imtihan:
        starts, end = pd.date_range('2019-01-01', '2026-10-01', freq='MS', tz='UTC'), grid[-1] + 1
    else:
        starts, end = pd.date_range('2012-01-01', '2018-12-01', freq='MS', tz='UTC'), pd.Timestamp('2019-01-01', tz='UTC').value
    for s, tl in zip(syms, ch):
        if tl:
            t = dfs[s]['t'].values
            k = [x for x in tl if starts[0].value <= t[x[0]].astype(np.int64) < end]
            pct = np.mean([x[3] / x[2] - 1 for x in k]) * 100
            print(f'chutti {s}: {len(k)} tr ({len(k) / ((end - starts[0].value) / 3.156e16):.1f}/saal), ausat {pct:+.3f}% (kharche se pehle)')
    print(f"{'IMTIHAN 2019+' if a.imtihan else 'CHUNAO 2012-2018'}: {len(starts)} challenge (kharcha asli)")
    print('chutti risk | pass fail(P1/P2) adhoora | P1fail% | pass mahine median')
    risks = [0.0] + ([a.risk] if a.imtihan else RISKS)
    rows = {}
    for rc in risks:
        sy = [(0.75, trend, {}), (1.0, ibs, {})] + ([(rc, ch, {})] if rc > 0 else [])
        res = [run_cost(mk, sy, s0.value, end, grid, cetday, cost) for s0 in starts]
        ps, f1, f2, ad, med = summary(res)
        rows[rc] = (ps, f1, f2, ad, med, 100 * f1 / len(res))
        print(f'{rc:10.2f}  | {ps:4d} {f1 + f2:4d} ({f1}/{f2}) {ad:7d} | {100 * f1 / len(res):6.1f}% | {med:6.1f}'
              f'{"   <- #53 akela" if rc == 0 else ""}', flush=True)
    b = rows[0.0]
    if not a.imtihan:
        ok = [(r[0] - r[1] - r[2], -r[4], -rc, rc) for rc, r in rows.items()
              if rc > 0 and r[5] < 20 and r[0] > r[1] + r[2] and r[0] - r[1] - r[2] >= b[0] - b[1] - b[2]]
        print('CHUNI chutti risk: ' + (f'{max(ok)[3]}%' if ok else 'KOI NAHI = FAIL'))
    else:
        r = rows[a.risk]
        okI = r[1] + r[2] == 0 and r[0] >= 83 and r[4] < 11.7
        print('IMTIHAN: ' + ('PASS' if okI else 'FAIL') + ' (shart: fail 0, pass >= 83, median < 11.7)')


if __name__ == '__main__':
    main()
