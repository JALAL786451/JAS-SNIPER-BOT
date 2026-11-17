#!/usr/bin/env python3
"""K17 (64vi, 17 Nov 2026) - e2 Kachhua 12 market -> 33 market (data/duka, FTMO par milne wale). Swap 0.
QAIDA (test se PEHLE likha, badalna mana):
 A) EDGE naye 21 market (kachhua_trades = e2 ke qaide, kharcha = POORA andazan spread, 0.75x nahi):
    forex / index / DXY 0.02%, softs (cocoa, coffee, cotton, soybean) 0.10%.
    TALAASH (< 2019) PASS = >=100 tr, Exp-2SE > 0, >= 11/21 market plus, market x saal > 50% plus.
    IMTIHAN (2019+) sirf TALAASH PASS par khud chalta: >= 30 tr aur Exp-2SE > 0.
 B) FTMO (#101 wala simulator run_cost, wahi #68 trend 0.75 + IBS 1 + khirki 0.15 + Kachhua 0.25):
    Kachhua 12 market vs 33 market, har mahine naya 2-step challenge, 2012-18 aur 2019-26.
    33 behtar = fail zyada NAHI aur pass median mahine kam.
  python3 tools/k17_kachhua33.py
"""
import sys
from collections import defaultdict
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
SOFT = ['COCOACMDUSD', 'COFFEECMDUSX', 'COTTONCMDUSX', 'SOYBEANCMDUSX']
NEW = ['AUDCAD', 'AUDCHF', 'AUDNZD', 'NZDUSD', 'USDCAD', 'USDSEK', 'AUSIDXAUD', 'DEUIDXEUR', 'ESPIDXEUR', 'EUSIDXEUR',
       'FRAIDXEUR', 'GBRIDXGBP', 'HKGIDXHKD', 'JPNIDXJPY', 'USA30IDXUSD', 'USSC2000IDXUSD', 'DOLLARIDXUSD'] + SOFT
NCOST = {s: (0.10e-2 if s in SOFT else 0.02e-2) for s in NEW}


def edge(dfs, a, b, lab):
    allr, cells, pos = [], defaultdict(float), 0
    print(f'\n== A) EDGE naye {len(NEW)} market - {lab} ==')
    for s in NEW:
        t = dfs[s]['t'].values.astype('datetime64[ns]')
        rs = []
        for ei, xi, e, x, r, d in kachhua_trades(dfs[s]):
            if a <= t[ei] < b:
                rr = (d * (x - e) - NCOST[s] * (e + x)) / r
                rs.append(rr)
                cells[(s, str(t[ei])[:4])] += rr
        rs = np.array(rs)
        pos += int(len(rs) > 0 and rs.mean() > 0)
        print(f'  {s:15s} data {str(t[0])[:4]}  {len(rs):4d} tr  {rs.mean() if len(rs) else np.nan:+.3f}R')
        allr += list(rs)
    R = np.array(allr)
    ex, se = R.mean(), R.std(ddof=1) / np.sqrt(len(R))
    sal = np.mean([v > 0 for v in cells.values()])
    print(f'  KUL {len(R)} tr, Exp {ex:+.3f}R, Exp-2SE {ex - 2 * se:+.3f}, market plus {pos}/{len(NEW)}, market x saal plus {sal * 100:.0f}%')
    return len(R), ex - 2 * se, pos, sal


def main():
    base = list(FILES)
    tide12 = list(SPREAD)
    syms = base + list(KH) + [s for s in tide12 if s not in base] + NEW
    syms = list(dict.fromkeys(syms))
    dfs = {s: (load(s) if s in base else load_any(s)) for s in syms}
    n, s2, pos, sal = edge(dfs, np.datetime64('1900-01-01'), np.datetime64('2019-01-01'), 'TALAASH < 2019')
    ok = n >= 100 and s2 > 0 and pos >= 11 and sal > 0.5
    print('  TALAASH', 'PASS' if ok else 'FAIL')
    if ok:
        n, s2, _, _ = edge(dfs, np.datetime64('2019-01-01'), np.datetime64('2100-01-01'), 'IMTIHAN 2019+')
        print('  IMTIHAN', 'PASS' if n >= 30 and s2 > 0 else 'FAIL')
    grid = np.unique(np.concatenate([d['t'].values.astype('datetime64[ns]').astype(np.int64) for d in dfs.values()]))
    cet = pd.to_datetime(grid, utc=True).tz_convert('Europe/Prague')
    cetday = (cet.year * 10000 + cet.month * 100 + cet.day).values
    mk = [Mkt(s, dfs[s], grid) for s in syms]
    trend = [st4h_trades(dfs[s], 6.0) if s in base else [] for s in syms]
    ibs = [ibs_trades(dfs[s]) if s in ('US500', 'USTEC') else [] for s in syms]
    kh = [khirki_trades(dfs[s], *KH[s]) if s in KH else [] for s in syms]
    kall = {s: kachhua_trades(dfs[s]) for s in tide12 + NEW}
    cost = [0.75 * ASLI[s] if s in base else (0.75 * SPREAD[s] if s in SPREAD else (NCOST[s] if s in NCOST else KCOST))
            for s in syms]
    tmap = {mi: 100 + mi for mi in range(len(syms))}
    tmap[syms.index('XAGUSD')] = 100 + syms.index('XAUUSD')
    print('\n== B) FTMO 2-step (#68 + Kachhua 0.25%), har mahine naya challenge ==')
    print('daur      | Kachhua | pass fail(P1/P2) adhoora | pass mahine median')
    for lab, starts, end in (('2012-18', pd.date_range('2012-01-01', '2018-12-01', freq='MS', tz='UTC'),
                              pd.Timestamp('2019-01-01', tz='UTC').value),
                             ('2019-26', pd.date_range('2019-01-01', '2026-10-01', freq='MS', tz='UTC'), grid[-1] + 1)):
        for nm, use in (('12 mkt', tide12), ('33 mkt', tide12 + NEW)):
            td = [(kall[s] if s in use and s in kall else []) for s in syms]
            sy = [(0.75, trend, {}), (1.0, ibs, {}), (0.15, kh, {}), (0.25, td, tmap)]
            res = [run_cost(mk, sy, s0.value, end, grid, cetday, cost) for s0 in starts]
            ps, f1, f2, ad, med = summary(res)
            print(f'{lab:9s} | {nm}  | {ps:4d} {f1 + f2:4d} ({f1}/{f2}) {ad:7d} | {med:6.1f}', flush=True)


if __name__ == '__main__':
    main()
