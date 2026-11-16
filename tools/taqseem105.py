#!/usr/bin/env python3
"""Koshish #105 (16 Nov 2026, 61vi, K9 / A) - FTMO jor #101 ki behtar taqseem, USI kul risk (8.80% khula) mein.
Qaida (badalna mana): docs/purana-haal.md, grep "Koshish #105 qaida". Dhaancha: tools/jor105.py / ftmo101.py.

  python3 tools/taqseem105.py                              # CHUNAO 2012-2018, jaali
  python3 tools/taqseem105.py --imtihan 0.5,1.0,0.15,0.3   # 2019+ EK dafa: chuni taqseem vs #101
"""
import itertools
import sys
from multiprocessing import Pool

import numpy as np
import pandas as pd

from ftmo53_asli import run_cost
from ftmo60 import summary
from jor105 import RISK, banao, raasta

SLOTS = [4, 2, 7, 11]
KUL = sum(s * r for s, r in zip(SLOTS, RISK))           # 8.80
G = None


def kul(r):
    return sum(s * x for s, x in zip(SLOTS, r))


def chal(a):
    r, starts, end = a
    syms, mk, tls, maps, cost, grid, cetday = G
    sy = [(r[k], tls[k], maps[k]) for k in range(4) if r[k] > 0]
    return r, summary([run_cost(mk, sy, s, end, grid, cetday, cost) for s in starts])


def main():
    global G
    G = banao()
    syms, mk, tls, maps, cost, grid, cetday = G
    if '--imtihan' in sys.argv:
        ch = tuple(float(x) for x in sys.argv[sys.argv.index('--imtihan') + 1].split(','))
        starts = [s.value for s in pd.date_range('2019-01-01', '2026-10-01', freq='MS', tz='UTC')]
        end = grid[-1] + 1
        with Pool(2) as p:
            out = dict(p.map(chal, [(tuple(RISK), starts, end), (ch, starts, end)]))
        b, c = out[tuple(RISK)], out[ch]
        print(f'IMTIHAN 2019+: {len(starts)} challenge | pass fail(P1/P2) adhoora | median')
        for nm, r, x in (('#101 abhi', RISK, b), ('chuni', ch, c)):
            print(f'  {nm:10s} {tuple(r)} kul {kul(r):.2f}% | {x[0]} {x[1] + x[2]} ({x[1]}/{x[2]}) {x[3]} | {x[4]:.1f}')
        ok = c[1] + c[2] == 0 and c[0] >= b[0] and c[4] < b[4]
        print('IMTIHAN: ' + ('PASS' if ok else 'FAIL') + f' (shart: fail 0, pass >= {b[0]}, median < {b[4]:.1f})')
        return
    s0, s1 = pd.Timestamp('2012-01-01', tz='UTC').value, pd.Timestamp('2019-01-01', tz='UTC').value
    i0, i1 = np.searchsorted(grid, s0), np.searchsorted(grid, s1)
    R = [raasta(mk, tls[k], maps[k], cost, grid, s0, s1, 1.0) for k in range(4)]
    bal = np.array([b[i0:i1] for b, _, _, _ in R])
    wst = np.array([(b + w)[i0:i1] for b, _, w, _ in R])
    cd = cetday[i0:i1]
    ds = np.r_[0, np.nonzero(np.diff(cd))[0] + 1]

    def bura_din(r):
        tb, tw = np.dot(r, bal), np.dot(r, wst)
        dst = np.r_[0.0, tb[ds[1:] - 1]]
        return (np.minimum.reduceat(tw, ds) - dst).min() / 1000
    cur = bura_din(RISK)
    combos = [r for r in itertools.product([0.25, 0.375, 0.50, 0.625, 0.75], [0.75, 1.0, 1.25], [0, 0.15], [0.25, 0.30, 0.35, 0.40])
              if kul(r) <= KUL + 1e-9]
    starts = [s.value for s in pd.date_range('2012-01-01', '2018-12-01', freq='MS', tz='UTC')]
    print(f'CHUNAO 2012-2018: {len(combos)} ummeedwar (kul risk <= {KUL:.2f}%), abhi ka bura din {cur:+.2f}%')
    with Pool(4) as p:
        out = p.map(chal, [(r, starts, s1) for r in combos], chunksize=1)
    print('  t5    i6   k2   e2  | kul%  | pass fail(P1/P2) adh | median | bura din | shart')
    ok = []
    for r, (ps, f1, f2, ad, med) in sorted(out, key=lambda z: (z[1][1] + z[1][2], z[1][4])):
        bd = bura_din(r)
        good = r != tuple(RISK) and f1 + f2 == 0 and ps >= 69 and bd >= cur - 1e-9 and med < 15.47   # abhi ka median 15.47 (chhapta 15.5)
        if good:
            ok.append((med, -ps, kul(r), r))
        print(f'{r[0]:5.3f} {r[1]:4.2f} {r[2]:4.2f} {r[3]:4.2f} | {kul(r):5.2f} | {ps:3d} {f1 + f2:3d} ({f1}/{f2}) {ad:3d} | {med:5.1f} | {bd:+5.2f} | {"HAAN" if good else ""}'
              f'{"  <- abhi" if r == tuple(RISK) else ""}')
    print('CHUNI: ' + (f'{min(ok)[3]} (median {min(ok)[0]:.1f}, pass {-min(ok)[1]}, kul {min(ok)[2]:.2f}%)' if ok else 'KOI NAHI = FAIL (abhi wali taqseem theek)'))


if __name__ == '__main__':
    main()
