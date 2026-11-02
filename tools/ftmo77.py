#!/usr/bin/env python3
"""Koshish #77 (2 Nov 2026) - FTMO #68 + Phase 2 risk 1.5x + pehra-shart G (user ki shart).
Qaida (badalna mana): docs/purana-haal.md, grep "Koshish #77 qaida".

  python3 tools/ftmo77.py                                # CHUNAO 2012-2018: A, B, C (+ maloomat A+G)
  python3 tools/ftmo77.py --imtihan --pakka --pick B|C|G # 2019+ EK dafa (G = #78: #68 + G akela)

A = #68 jyon ka tyon. B = A + P2 mein har lot 1.5x. C = B + G.
G: nayi trade se pehle  bal - sum(khuli trades ka shuru risk $) - nayi ka risk $  <  max(din shuru - 4k, 91k)  => trade nahi.
"""
import argparse
import sys

import numpy as np
import pandas as pd

import ftmo_test
from ftmo53_asli import ASLI, run_cost as run_cost53
from ftmo60 import summary
from ftmo68 import KCOST, KH, khirki_trades
from ftmo_4h import st4h_trades
from ftmo_test import FILES, Mkt, ibs_trades, load, raatein
from tokri47 import load_any


def run_cost(mkts, systems, start_ns, end_ns, grid, cetday, cost, p2mult=1.0, guard=False):
    """ftmo53_asli.run_cost jyon ka tyon + P2 lot guna (p2mult) + pehra-shart G."""
    BAL0, SWAP = ftmo_test.BAL0, ftmo_test.SWAP
    tl = []
    for si, (risk, trades, smap) in enumerate(systems):
        risk_usd = BAL0 * risk / 100
        for mi, m in enumerate(mkts):
            for (ei, xi, e, x, sd, d) in trades[mi]:
                ge, gx = m.gi[ei], m.gi[xi]
                if grid[ge] >= start_ns and grid[ge] < end_ns:
                    tl.append((ge, gx, si * 10 + smap.get(mi, mi), e, x, risk_usd / sd, mi, d, risk_usd))
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
                bal -= nr * SWAP * p[1] * mkts[p[2][6]].clf[t]
            dstart = bal
        for slot in list(open_):
            ge, gx, _, e, x, u0, mi, d, _r = open_[slot][2]
            if gx == t:
                u = open_[slot][1]
                bal += d * (x - e) * u - cost[mi] * x * u
                del open_[slot]
        while ti < len(tl) and tl[ti][0] <= t:
            tr = tl[ti]
            ti += 1
            if tr[0] < t or tr[2] in open_ or tr[1] <= tr[0]:
                continue
            k = p2mult if phase == 2 else 1.0
            u, rusd = tr[5] * k, tr[8] * k
            if guard:
                at_risk = sum(p[3] for p in open_.values()) + rusd
                if bal - at_risk < max(dstart - 0.04 * BAL0, 0.91 * BAL0):
                    continue
            bal -= cost[tr[6]] * tr[3] * u
            open_[tr[2]] = (tr[3], u, tr, rusd)
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
    ap.add_argument('--pick', choices=['B', 'C', 'G'])
    a = ap.parse_args()
    if a.imtihan and not (a.pakka and a.pick):
        print('INKAAR: IMTIHAN (2019+) sirf EK dafa, CHUNAO ke baad, --imtihan --pakka --pick B|C|G se.')
        sys.exit(2)
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
    sy = [(0.75, trend, {}), (1.0, ibs, {}), (0.15, kh, {})]
    if a.imtihan:
        starts, end = pd.date_range('2019-01-01', '2026-10-01', freq='MS', tz='UTC'), grid[-1] + 1
    else:
        starts, end = pd.date_range('2012-01-01', '2018-12-01', freq='MS', tz='UTC'), pd.Timestamp('2019-01-01', tz='UTC').value
    # jaanch: A (p2 1, G band) == ftmo53 run_cost
    chk = [run_cost53(mk, sy, s0.value, end, grid, cetday, cost) for s0 in starts[:12]]
    chk2 = [run_cost(mk, sy, s0.value, end, grid, cetday, cost) for s0 in starts[:12]]
    print(f'JAANCH A == #68 engine (pehle 12 challenge): {"HAAN" if chk == chk2 else "NAHI"}')
    if chk != chk2:
        sys.exit(1)
    runs = {'A': (1.0, False), 'B': (1.5, False), 'C': (1.5, True), 'G': (1.0, True)}   # G = #78
    if a.imtihan:
        runs = {'A': runs['A'], a.pick: runs[a.pick]}
    else:
        runs['A+G (maloomat)'] = runs.pop('G')
    print(f"{'IMTIHAN 2019+' if a.imtihan else 'CHUNAO 2012-2018'}: {len(starts)} challenge (kharcha asli)")
    print('run              | pass fail(P1/P2) adhoora | P1fail% | pass mahine median')
    rows = {}
    for nm, (pm, g) in runs.items():
        res = [run_cost(mk, sy, s0.value, end, grid, cetday, cost, pm, g) for s0 in starts]
        ps, f1, f2, ad, med = summary(res)
        rows[nm] = (ps, f1, f2, ad, med, 100 * f1 / len(res))
        print(f'{nm:16s} | {ps:4d} {f1 + f2:4d} ({f1}/{f2}) {ad:7d} | {100 * f1 / len(res):6.1f}% | {med:6.1f}', flush=True)
    b = rows['A']
    if not a.imtihan:
        ok = [(r[4], r[1] + r[2], 0 if nm == 'C' else 1, nm) for nm, r in rows.items()
              if nm in ('B', 'C') and r[5] < 20 and r[0] > r[1] + r[2]
              and r[0] - r[1] - r[2] >= b[0] - b[1] - b[2] and r[4] < b[4]]
        print('CHUNAO: ' + (f'CHUNA {min(ok)[3]}' if ok else 'KOI NAHI = FAIL'))
    else:
        r = rows[a.pick]
        okI = r[1] + r[2] == 0 and r[0] >= b[0] and r[4] < b[4]
        print('IMTIHAN: ' + ('PASS' if okI else 'FAIL') + f' (shart: fail 0, pass >= {b[0]}, median < {b[4]:.1f})')


if __name__ == '__main__':
    main()
