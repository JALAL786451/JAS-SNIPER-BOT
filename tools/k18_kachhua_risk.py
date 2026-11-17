#!/usr/bin/env python3
"""K18 (64vi, 17 Nov 2026) - user "haan 0.35": Kachhua 12 market risk 0.25% vs 0.35% (#68 wahi), FTMO #101 simulator.
QAIDA (pehle likha): 0.35 behtar SIRF agar dono daur (2012-18, 2019-26) mein fail 0 rahe AUR pass median mahine kam hon.
Sirf TEST - EA (e2 InpRiskPct 0.25) mein koi tabdeeli nahi; badalna user ki alag ijazat se.
  python3 tools/k18_kachhua_risk.py [0.25 0.45 ...]   # risk list (khaali = 0.25 0.35)
"""
import sys
from pathlib import Path

import numpy as np
import pandas as pd

sys.path.insert(0, str(Path(__file__).resolve().parent))
from ftmo53_asli import ASLI, run_cost  # noqa: E402
from ftmo60 import summary  # noqa: E402
from ftmo68 import KCOST, KH, khirki_trades  # noqa: E402
from ftmo_4h import st4h_trades  # noqa: E402
from ftmo_test import FILES, Mkt, ibs_trades, kachhua_trades, load  # noqa: E402
from tokri47 import load_any  # noqa: E402
import ftmo_test  # noqa: E402
from ftmo99 import SPREAD  # noqa: E402

ftmo_test.SWAP = 0.0


def main():
    base = list(FILES)
    syms = list(dict.fromkeys(base + list(KH) + list(SPREAD)))
    dfs = {s: (load(s) if s in base else load_any(s)) for s in syms}
    grid = np.unique(np.concatenate([d['t'].values.astype('datetime64[ns]').astype(np.int64) for d in dfs.values()]))
    cet = pd.to_datetime(grid, utc=True).tz_convert('Europe/Prague')
    cetday = (cet.year * 10000 + cet.month * 100 + cet.day).values
    mk = [Mkt(s, dfs[s], grid) for s in syms]
    trend = [st4h_trades(dfs[s], 6.0) if s in base else [] for s in syms]
    ibs = [ibs_trades(dfs[s]) if s in ('US500', 'USTEC') else [] for s in syms]
    kh = [khirki_trades(dfs[s], *KH[s]) if s in KH else [] for s in syms]
    td = [kachhua_trades(dfs[s]) if s in SPREAD else [] for s in syms]
    cost = [0.75 * ASLI[s] if s in base else (0.75 * SPREAD[s] if s in SPREAD else KCOST) for s in syms]
    tmap = {mi: 100 + mi for mi in range(len(syms))}
    tmap[syms.index('XAGUSD')] = 100 + syms.index('XAUUSD')
    print('daur    | Kachhua risk | pass fail(P1/P2) adhoora | pass mahine median | 25% / 75%')
    for lab, starts, end in (('2012-18', pd.date_range('2012-01-01', '2018-12-01', freq='MS', tz='UTC'),
                              pd.Timestamp('2019-01-01', tz='UTC').value),
                             ('2019-26', pd.date_range('2019-01-01', '2026-10-01', freq='MS', tz='UTC'), grid[-1] + 1)):
        for rk in [float(x) for x in sys.argv[1:]] or (0.25, 0.35):
            sy = [(0.75, trend, {}), (1.0, ibs, {}), (0.15, kh, {}), (rk, td, tmap)]
            res = [run_cost(mk, sy, s0.value, end, grid, cetday, cost) for s0 in starts]
            ps, f1, f2, ad, med = summary(res)
            m = [x[1] for x in res if x[0] == 'pass']
            print(f'{lab} | {rk:.2f}%        | {ps:4d} {f1 + f2:4d} ({f1}/{f2}) {ad:7d} | {med:6.1f}'
                  f'             | {np.percentile(m, 25):4.1f} / {np.percentile(m, 75):4.1f}', flush=True)


if __name__ == '__main__':
    main()
