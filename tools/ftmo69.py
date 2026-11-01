#!/usr/bin/env python3
"""Koshish #69 (1 Nov 2026) - FTMO: #68 (trend 4H 0.75% + IBS 1% + khirki 0.15%) + Tide (Kachhua) USOIL + UKOIL.
Qaida (badalna mana): docs/purana-haal.md, grep "Koshish #69 qaida".

  python3 tools/ftmo69.py                          # CHUNAO 2012-2018 (Tide risk 0 / 0.10 / 0.25 / 0.50 har market)
  python3 tools/ftmo69.py --imtihan --risk X       # 2019+ EK dafa, chuni risk
"""
import argparse

import numpy as np
import pandas as pd

from ftmo53_asli import ASLI, run_cost
from ftmo60 import summary
from ftmo68 import KCOST, KH, khirki_trades
from ftmo_4h import st4h_trades
from ftmo_test import FILES, Mkt, ibs_trades, kachhua_trades, load
from tokri47 import load_any

TIDE = {'LIGHTCMDUSD': 0.0194e-2, 'BRENTCMDUSD': 0.0151e-2}    # Exness spread (JasSpreadNaap 1 Nov)
RISKS = [0.10, 0.25, 0.50]


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--imtihan', action='store_true')
    ap.add_argument('--risk', type=float, default=None)
    a = ap.parse_args()
    base = list(FILES)
    syms = base + list(KH) + list(TIDE)
    dfs = {s: load(s) for s in base}
    dfs.update({s: load_any(s) for s in list(KH) + list(TIDE)})
    grid = np.unique(np.concatenate([d['t'].values.astype('datetime64[ns]').astype(np.int64) for d in dfs.values()]))
    cet = pd.to_datetime(grid, utc=True).tz_convert('Europe/Prague')
    cetday = (cet.year * 10000 + cet.month * 100 + cet.day).values
    mk = [Mkt(s, dfs[s], grid) for s in syms]
    trend = [st4h_trades(dfs[s], 6.0) if s in base else [] for s in syms]
    ibs = [ibs_trades(dfs[s]) if s in ('US500', 'USTEC') else [] for s in syms]
    kh = [khirki_trades(dfs[s], *KH[s]) if s in KH else [] for s in syms]
    td = [kachhua_trades(dfs[s]) if s in TIDE else [] for s in syms]
    cost = [0.75 * ASLI[s] if s in base else (0.75 * TIDE[s] if s in TIDE else KCOST) for s in syms]
    # slot key = si*10 + mi (run_cost): mi >= 10 sirf khirki (si 2) / Tide (si 3) par - takraao nahi
    keys = [si * 10 + mi for si, tl in enumerate([trend, ibs, kh, td]) for mi in range(len(syms)) if tl[mi]]
    assert len(keys) == len(set(keys)), 'slot takraao'
    if a.imtihan:
        starts, end = pd.date_range('2019-01-01', '2026-10-01', freq='MS', tz='UTC'), grid[-1] + 1
    else:
        starts, end = pd.date_range('2012-01-01', '2018-12-01', freq='MS', tz='UTC'), pd.Timestamp('2019-01-01', tz='UTC').value
    if not a.imtihan:
        for s, tl in zip(syms, td):
            if tl:
                t = dfs[s]['t'].values.astype('datetime64[ns]').astype(np.int64)
                k = [x for x in tl if starts[0].value <= t[x[0]] < end]
                r = np.array([x[5] * (x[3] - x[2]) / x[4] for x in k])
                print(f'Tide {s}: {len(k)} tr, {r.mean():+.3f}R +-{r.std(ddof=1) / np.sqrt(len(r)):.3f} (kharche se pehle), jeet {np.mean(r > 0) * 100:.0f}%')
    print(f"{'IMTIHAN 2019+' if a.imtihan else 'CHUNAO 2012-2018'}: {len(starts)} challenge (kharcha asli)")
    print('Tide risk | pass fail(P1/P2) adhoora | P1fail% | pass mahine median')
    risks = [0.0] + ([a.risk] if a.imtihan else RISKS)
    rows = {}
    for rk in risks:
        sy = [(0.75, trend, {}), (1.0, ibs, {}), (0.15, kh, {})] + ([(rk, td, {})] if rk > 0 else [])
        res = [run_cost(mk, sy, s0.value, end, grid, cetday, cost) for s0 in starts]
        ps, f1, f2, ad, med = summary(res)
        rows[rk] = (ps, f1, f2, ad, med, 100 * f1 / len(res))
        print(f'{rk:9.2f} | {ps:4d} {f1 + f2:4d} ({f1}/{f2}) {ad:7d} | {100 * f1 / len(res):6.1f}% | {med:6.1f}'
              f'{"   <- #68 (isi run)" if rk == 0 else ""}', flush=True)
    b = rows[0.0]
    if not a.imtihan:
        ok = [(r[0] - r[1] - r[2], -r[4], -rk, rk) for rk, r in rows.items()
              if rk > 0 and r[5] < 20 and r[0] > r[1] + r[2] and r[0] - r[1] - r[2] >= b[0] - b[1] - b[2]]
        print('CHUNI Tide risk: ' + (f'{max(ok)[3]}%' if ok else 'KOI NAHI = FAIL'))
    else:
        r = rows[a.risk]
        okI = r[1] + r[2] == 0 and r[0] >= b[0] and r[4] < b[4]
        print('IMTIHAN: ' + ('PASS' if okI else 'FAIL') + f' (shart: fail 0, pass >= {b[0]}, median < {b[4]:.1f})')


if __name__ == '__main__':
    main()
