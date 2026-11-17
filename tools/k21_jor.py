#!/usr/bin/env python3
"""K21 (17 Nov 2026, 66vi) - t5 ke bina US / aadha US wala jor vs jor #101. Shart: docs/khud-nazar.md sec 6 (test se pehle).
  python3 tools/k21_jor.py
"""
import numpy as np
import pandas as pd

from ftmo53_asli import run_cost
from ftmo60 import summary
from jor105 import banao, raasta

US = ('US500', 'USTEC')


def main():
    syms, mk, tls, maps, cost, grid, cetday = banao()
    t5, i6, k2, e2 = tls
    t5us = [tr if syms[mi] in US else [] for mi, tr in enumerate(t5)]
    t5met = [tr if syms[mi] not in US else [] for mi, tr in enumerate(t5)]
    rest = [(1.0, i6, maps[1]), (0.15, k2, maps[2]), (0.25, e2, maps[3])]
    V = {'V0 jor #101 (abhi)': [(0.75, t5, {})] + rest,
         'V1 t5 sirf XAU/XAG': [(0.75, t5met, {})] + rest,
         'V2 t5 US aadha 0.375': [(0.75, t5met, {})] + rest + [(0.375, t5us, {})],
         'V3 bina t5': rest}
    T = lambda s: pd.Timestamp(s, tz='UTC').value
    daur = [('CHUNAO 2012-18', pd.date_range('2012-01-01', '2018-12-01', freq='MS', tz='UTC'), T('2019-01-01')),
            ('2019+', pd.date_range('2019-01-01', '2026-10-01', freq='MS', tz='UTC'), int(grid[-1]) + 1)]
    gir = [('2015-06-01', '2016-03-01'), ('2018-10-01', '2019-01-01'), ('2022-01-01', '2023-01-01')]
    out = {}
    for nm, sy in V.items():
        row = []
        for dn, starts, end in daur:
            res = [run_cost(mk, sy, s.value, end, grid, cetday, cost) for s in starts]
            ps, f1, f2, ad, med = summary(res)
            row.append((ps, f1 + f2, ad, med))
        gp = [sum(raasta(mk, tr, mp, cost, grid, T(a), T(b), rk)[0][-1] for rk, tr, mp in sy) / 1000 for a, b in gir]
        out[nm] = (row, gp)
        print(nm, row, flush=True)
    print('\n=== NATEEJA: [pass fail adhoora median] CHUNAO | 2019+ | girte daur % (2015-16, 2018Q4, 2022) kul ===')
    for nm, (row, gp) in out.items():
        print(f'{nm:24s} ' + ' | '.join(f'{p:3d} {f:2d} {a:2d} {m:5.1f}' for p, f, a, m in row)
              + ' | ' + ' '.join(f'{g:+5.1f}' for g in gp) + f'  kul {sum(gp):+5.1f}')


if __name__ == '__main__':
    main()
