#!/usr/bin/env python3
"""#53 FTMO mansooba (trend 4H 0.75% + IBS US500/USTEC 1%) - ASLI kharche se dobara hisaab (1 Nov 2026). Sirf andaza:
qaida / setting / faisla NAHI badalta (nayi koshish nahi). Kharcha har taraf = 0.75 x JasSpreadNaap s1 spread%.

  python3 tools/ftmo53_asli.py      # 2019-01 .. 2026-10 har mahine nayi challenge (#53 IMTIHAN jaisa)
"""
import numpy as np
import pandas as pd

import ftmo_test
from ftmo_4h import st4h_trades
from ftmo_test import FILES, Mkt, ibs_trades, load

ASLI = {'US500': 0.0052e-2, 'USTEC': 0.0038e-2, 'XAUUSD': 0.0059e-2, 'XAGUSD': 0.0445e-2}


def main():
    syms = list(FILES)
    dfs = {s: load(s) for s in syms}
    grid = np.unique(np.concatenate([d['t'].values.astype('datetime64[ns]').astype(np.int64) for d in dfs.values()]))
    cet = pd.to_datetime(grid, utc=True).tz_convert('Europe/Prague')
    cetday = (cet.year * 10000 + cet.month * 100 + cet.day).values
    starts = pd.date_range('2019-01-01', '2026-10-01', freq='MS', tz='UTC')
    end = grid[-1] + 1
    mk = [Mkt(s, dfs[s], grid) for s in syms]
    trend = [st4h_trades(dfs[s], 6.0) for s in syms]
    ibs = [ibs_trades(dfs[s]) if s in ('US500', 'USTEC') else [] for s in syms]
    for nm, costs in (('purana 0.03% sab par', {s: 0.0003 for s in syms}), ('ASLI spread x 1.5', {s: 0.75 * ASLI[s] for s in syms})):
        c = [costs[s] for s in syms]
        res = [run_cost(mk, [(0.75, trend, {}), (1.0, ibs, {})], s0.value, end, grid, cetday, c) for s0 in starts]
        ps = [x for x in res if x[0] == 'pass']
        f1, f2 = sum(x[0] == 'fail1' for x in res), sum(x[0] == 'fail2' for x in res)
        ad = sum(x[0] == 'adhoora' for x in res)
        print(f'{nm:22s}: {len(starts)} challenge | pass {len(ps)}  fail {f1 + f2} ({f1}/{f2})  adhoora {ad} | '
              f'pass mahine median {np.median([x[1] for x in ps]):.1f}, 25% {np.percentile([x[1] for x in ps], 25):.1f}, '
              f'75% {np.percentile([x[1] for x in ps], 75):.1f}', flush=True)


def run_cost(mkts, systems, start_ns, end_ns, grid, cetday, cost):
    BAL0, SWAP = ftmo_test.BAL0, ftmo_test.SWAP
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
    for t in range(i0, i_end):
        if cetday[t] != day:
            day = cetday[t]
            for p in open_.values():
                bal -= SWAP * p[1] * mkts[p[2][6]].clf[t]
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


if __name__ == '__main__':
    main()
