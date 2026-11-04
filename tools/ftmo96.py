#!/usr/bin/env python3
"""Koshish #96 (4 Nov 2026) - FTMO: #68 + Kachhua commodity (#6): XAG, Brent, WTI (alag slot har market).
Qaida (badalna mana): docs/purana-haal.md, grep "Koshish #96 qaida".

  python3 tools/ftmo96.py                          # CHUNAO 2012-2018 (Kachhua risk 0 / 0.10 / 0.25 / 0.50), swap 5% faisla
  python3 tools/ftmo96.py --imtihan --pakka --risk X   # 2019+ EK dafa, chuni risk (sirf CHUNAO PASS par)

Data: XAG ftmo zip, tel Dukascopy H1 JAS_ZIP (2013-01 se). Kharcha tel 0.05%/taraf; commodity swap faisla 5%/saal (0 / 10 maloomat).
"""
import argparse
import sys

import numpy as np
import pandas as pd

import ftmo_test
from ftmo53_asli import ASLI
from ftmo60 import summary
from ftmo68 import KCOST, KH, khirki_trades
from ftmo_4h import st4h_trades
from ftmo_test import FILES, Mkt, ibs_trades, kachhua_trades, load, raatein
from tokri47 import load_any

KM = ['XAGUSD', 'BRENTCMDUSD', 'LIGHTCMDUSD']
OIL = ('BRENTCMDUSD', 'LIGHTCMDUSD')
OIL_COST = 0.05e-2
RISKS = [0.10, 0.25, 0.50]


def run_cost(mkts, systems, start_ns, end_ns, grid, cetday, cost, swap):
    """ftmo53_asli.run_cost jyon ka tyon - sirf swap har market alag (swap[mi], har raat notional par)."""
    BAL0 = ftmo_test.BAL0
    tl = []
    for si, (risk, trades, smap) in enumerate(systems):
        risk_usd = BAL0 * risk / 100
        for mi, m in enumerate(mkts):
            for (ei, xi, e, x, sd, d) in trades[mi]:
                ge, gx = m.gi[ei], m.gi[xi]
                if grid[ge] >= start_ns and grid[ge] < end_ns:
                    tl.append((ge, gx, si * 10 + smap.get(mi, mi), e, x, risk_usd / sd, mi, d))
    tl.sort()
    i0 = np.searchsorted(grid, start_ns)
    i_end = np.searchsorted(grid, end_ns)
    phase, target = 1, 1.10
    bal, open_, ti = BAL0, {}, 0
    day, dstart, days = None, bal, set()
    day0 = None
    for t in range(i0, i_end):
        if cetday[t] != day:
            day = cetday[t]
            nr = raatein(day0, day)
            day0 = day
            for p in open_.values():
                bal -= nr * swap[p[2][6]] * p[1] * mkts[p[2][6]].clf[t]
            dstart = bal
        for slot in list(open_):
            ge, gx, _, e, x, u, mi, d = open_[slot][2]
            if gx == t:
                bal += d * (x - e) * u - cost[mi] * x * u
                del open_[slot]
        while ti < len(tl) and tl[ti][0] <= t:
            tr = tl[ti]
            ti += 1
            if tr[0] < t or tr[2] in open_ or tr[1] <= tr[0]:
                continue
            bal -= cost[tr[6]] * tr[3] * tr[5]
            open_[tr[2]] = (tr[3], tr[5], tr)
            days.add(day)
        worst = bal + sum(((mkts[p[2][6]].lowf[t] if p[2][7] > 0 else mkts[p[2][6]].highf[t]) - p[0]) * p[2][7] * p[1]
                          for p in open_.values())
        eq = bal + sum((mkts[p[2][6]].clf[t] - p[0]) * p[2][7] * p[1] for p in open_.values())
        if worst < dstart - 0.05 * BAL0 or worst < 0.90 * BAL0:
            return ('fail1' if phase == 1 else 'fail2'), (grid[t] - start_ns) / 2.63e15, False
        if eq >= target * BAL0:
            if phase == 2:
                return 'pass', (grid[t] - start_ns) / 2.63e15, False
            phase, target = 2, 1.05
            bal, open_, days, dstart = BAL0, {}, set(), BAL0
    return 'adhoora', (grid[i_end - 1] - start_ns) / 2.63e15, False


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--imtihan', action='store_true')
    ap.add_argument('--pakka', action='store_true')
    ap.add_argument('--risk', type=float, default=None)
    a = ap.parse_args()
    if a.imtihan and not (a.pakka and a.risk):
        print('INKAAR: IMTIHAN (2019+) sirf EK dafa, CHUNAO PASS ke baad, --imtihan --pakka --risk X se.')
        sys.exit(2)
    base = list(FILES)
    syms = base + list(KH) + list(OIL)
    dfs = {s: load(s) for s in base}
    dfs.update({s: load_any(s) for s in list(KH) + list(OIL)})
    grid = np.unique(np.concatenate([d['t'].values.astype('datetime64[ns]').astype(np.int64) for d in dfs.values()]))
    cet = pd.to_datetime(grid, utc=True).tz_convert('Europe/Prague')
    cetday = (cet.year * 10000 + cet.month * 100 + cet.day).values
    mk = [Mkt(s, dfs[s], grid) for s in syms]
    trend = [st4h_trades(dfs[s], 6.0) if s in base else [] for s in syms]
    ibs = [ibs_trades(dfs[s]) if s in ('US500', 'USTEC') else [] for s in syms]
    kh = [khirki_trades(dfs[s], *KH[s]) if s in KH else [] for s in syms]
    td = [kachhua_trades(dfs[s]) if s in KM else [] for s in syms]
    cost = [0.75 * ASLI[s] if s in base else (OIL_COST if s in OIL else KCOST) for s in syms]
    keys = [si * 10 + mi for si, tl in enumerate([trend, ibs, kh, td]) for mi in range(len(syms)) if tl[mi]]
    assert len(keys) == len(set(keys)), 'slot takraao'
    if a.imtihan:
        starts, end = pd.date_range('2019-01-01', '2026-10-01', freq='MS', tz='UTC'), grid[-1] + 1
    else:
        starts, end = pd.date_range('2012-01-01', '2018-12-01', freq='MS', tz='UTC'), pd.Timestamp('2019-01-01', tz='UTC').value
    for s in KM:
        mi = syms.index(s)
        t = dfs[s]['t'].values.astype('datetime64[ns]').astype(np.int64)
        k = [x for x in td[mi] if (starts[0].value <= t[x[0]] < end)]
        if not k:
            print(f'Kachhua {s}: 0 tr'); continue
        r = np.array([x[5] * (x[3] - x[2]) / x[4] for x in k])
        print(f'Kachhua {s}: {len(k)} tr (BUY {sum(x[5] > 0 for x in k)}, SELL {sum(x[5] < 0 for x in k)}), '
              f'{r.mean():+.3f}R +-{r.std(ddof=1) / np.sqrt(len(r)):.3f} (kharche se pehle), jeet {np.mean(r > 0) * 100:.0f}%'
              f', pehli entry {dfs[s]["t"].iloc[k[0][0]]}')
    print(f"{'IMTIHAN 2019+' if a.imtihan else 'CHUNAO 2012-2018'}: {len(starts)} challenge (kharcha asli)")
    swaps = [0.05] if a.imtihan else [0.05, 0.0, 0.10]
    risks = [0.0] + ([a.risk] if a.imtihan else RISKS)
    verdict = None
    for sw in swaps:
        swap = [(sw if s in OIL else 0.03) / 365 for s in syms]   # XAG = #68 ka market, swap per-market -> 3%
        tag = 'FAISLA' if sw == 0.05 else 'maloomat'
        print(f'-- commodity swap {sw * 100:.0f}%/saal ({tag})')
        print('K risk | pass fail(P1/P2) adhoora | P1fail% | pass mahine median')
        rows = {}
        for rk in risks:
            sy = [(0.75, trend, {}), (1.0, ibs, {}), (0.15, kh, {})] + ([(rk, td, {})] if rk > 0 else [])
            res = [run_cost(mk, sy, s0.value, end, grid, cetday, cost, swap) for s0 in starts]
            ps, f1, f2, ad, med = summary(res)
            rows[rk] = (ps, f1, f2, ad, med, 100 * f1 / len(res))
            print(f'{rk:6.2f} | {ps:4d} {f1 + f2:4d} ({f1}/{f2}) {ad:7d} | {100 * f1 / len(res):6.1f}% | {med:6.1f}'
                  f'{"   <- #68 (isi run)" if rk == 0 else ""}', flush=True)
        b = rows[0.0]
        if not a.imtihan:
            ok = [(r_[0] - r_[1] - r_[2], -r_[4], -rk, rk) for rk, r_ in rows.items()
                  if rk > 0 and r_[5] < 20 and r_[0] > r_[1] + r_[2] and r_[0] - r_[1] - r_[2] > b[0] - b[1] - b[2]]
            line = f'{max(ok)[3]}%' if ok else 'KOI NAHI = FAIL'
            print(f'CHUNI Kachhua risk ({tag}): {line}')
            if sw == 0.05:
                verdict = line
        else:
            r_ = rows[a.risk]
            okI = r_[1] + r_[2] == 0 and r_[0] >= b[0] and r_[4] < b[4]
            print('IMTIHAN: ' + ('PASS' if okI else 'FAIL') + f' (shart: fail 0, pass >= {b[0]}, median < {b[4]:.1f})')
    if verdict is not None:
        print(f'\nCHUNAO FAISLA (swap 5%): {verdict}')


if __name__ == '__main__':
    main()
