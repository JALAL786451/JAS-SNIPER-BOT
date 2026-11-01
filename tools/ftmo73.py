#!/usr/bin/env python3
"""Koshish #73 (1 Nov 2026) - FTMO: #68 (3 BUY leg) + 2 SELL aaina leg (S1 trend 4H SELL, S2 IBS SELL).
Qaida (badalna mana): docs/purana-haal.md, grep "Koshish #73 qaida". SELL code: tools/sell73.py.

  python3 tools/ftmo73.py              # Qadam 1 TALAASH 2012-18 (SELL, kharche ke BAAD) -> Qadam 2 CHUNAO 2012-18
  python3 tools/ftmo73.py --imtihan --k X   # Qadam 3: 2019+ EK dafa, chuna k
"""
import argparse

import numpy as np
import pandas as pd

from ftmo53_asli import ASLI, run_cost
from ftmo60 import summary
from ftmo68 import KCOST, KH, khirki_trades
from ftmo_4h import st4h_trades
from ftmo_test import FILES, SWAP, Mkt, ibs_trades, load
from sell73 import buy_ko_tarjeeh, ibs_sell_trades, st4h_sell_trades
from tokri47 import load_any

S1_MKTS = ('XAUUSD', 'XAGUSD', 'US500', 'USTEC')    # qaida: S1 ke market
S2_MKTS = ('US500', 'USTEC')
KS = [0.25, 0.5, 1.0]                               # SELL risk = k x BUY risk (S1 0.75%, S2 1.0%)


def net_r(df, x, cost):
    """kharche (dono taraf) + swap (har calendar raat) ke BAAD R."""
    t = df['t'].values
    nights = max(0, int((t[x[1]].astype('datetime64[D]') - t[x[0]].astype('datetime64[D]')).astype(int)))
    gross = x[5] * (x[3] - x[2]) / x[4]
    return gross - cost * (x[2] + x[3]) / x[4] - SWAP * nights * x[2] / x[4]


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--imtihan', action='store_true')
    ap.add_argument('--k', type=float, default=None)
    a = ap.parse_args()
    base = list(FILES)
    syms = base + list(KH)
    dfs = {s: load(s) for s in base}
    dfs.update({s: load_any(s) for s in KH})
    trend = [st4h_trades(dfs[s], 6.0) if s in base else [] for s in syms]
    ibs = [ibs_trades(dfs[s]) if s in ('US500', 'USTEC') else [] for s in syms]
    kh = [khirki_trades(dfs[s], *KH[s]) if s in KH else [] for s in syms]
    s1, s2 = [], []
    for mi, s in enumerate(syms):
        buys = trend[mi] + ibs[mi]
        s1.append(buy_ko_tarjeeh(st4h_sell_trades(dfs[s], 6.0), buys) if s in S1_MKTS else [])
        s2.append(buy_ko_tarjeeh(ibs_sell_trades(dfs[s]), buys) if s in S2_MKTS else [])
    cost = [0.75 * ASLI[s] if s in base else KCOST for s in syms]
    t0, t1 = pd.Timestamp('2012-01-01', tz='UTC').value, pd.Timestamp('2019-01-01', tz='UTC').value
    print('TALAASH 2012-2018 SELL (BUY ko tarjeeh ke baad, kharcha + swap ke BAAD)')
    allr = []
    for name, leg in (('S1 trend SELL', s1), ('S2 IBS SELL', s2)):
        for mi, s in enumerate(syms):
            if not leg[mi]:
                continue
            tt = dfs[s]['t'].values.astype('datetime64[ns]').astype(np.int64)
            r = np.array([net_r(dfs[s], x, cost[mi]) for x in leg[mi] if t0 <= tt[x[0]] < t1])
            allr += list(r)
            if len(r) > 1:
                print(f'  {name} {s:7s}: {len(r):4d} tr  {r.mean():+.3f}R +-{r.std(ddof=1) / np.sqrt(len(r)):.3f}  jeet {np.mean(r > 0) * 100:.0f}%')
    allr = np.array(allr)
    se = allr.std(ddof=1) / np.sqrt(len(allr))
    okT = len(allr) >= 100 and allr.mean() > 0
    print(f'  KUL SELL: {len(allr)} tr  {allr.mean():+.3f}R  (Exp-2SE {allr.mean() - 2 * se:+.3f})  jeet {np.mean(allr > 0) * 100:.0f}%'
          f' -> TALAASH {"PASS" if okT else "FAIL = band (CHUNAO nahi)"}  (shart: N >= 100, Exp > 0)')
    if not okT:
        return
    grid = np.unique(np.concatenate([d['t'].values.astype('datetime64[ns]').astype(np.int64) for d in dfs.values()]))
    cet = pd.to_datetime(grid, utc=True).tz_convert('Europe/Prague')
    cetday = (cet.year * 10000 + cet.month * 100 + cet.day).values
    mk = [Mkt(s, dfs[s], grid) for s in syms]
    if a.imtihan:
        starts, end = pd.date_range('2019-01-01', '2026-10-01', freq='MS', tz='UTC'), grid[-1] + 1
    else:
        starts, end = pd.date_range('2012-01-01', '2018-12-01', freq='MS', tz='UTC'), t1
    print(f"{'IMTIHAN 2019+' if a.imtihan else 'CHUNAO 2012-2018'}: {len(starts)} challenge (kharcha asli)")
    print('SELL k    | pass fail(P1/P2) adhoora | P1fail% | pass mahine median')
    rows = {}
    for k in [0.0] + ([a.k] if a.imtihan else KS):
        # slot key = si*10 + mi: tarteeb trend 0, ibs 1, S1 2, S2 3, khirki 4 (mi 4..10 -> 44..50) - takraao nahi
        sy = [(0.75, trend, {}), (1.0, ibs, {})]
        if k > 0:
            sy += [(0.75 * k, s1, {}), (1.0 * k, s2, {})]
        else:
            sy += [(0.0, [[]] * len(syms), {}), (0.0, [[]] * len(syms), {})]
        sy += [(0.15, kh, {})]
        res = [run_cost(mk, sy, s0.value, end, grid, cetday, cost) for s0 in starts]
        ps, f1, f2, ad, med = summary(res)
        rows[k] = (ps, f1, f2, ad, med, 100 * f1 / len(res))
        print(f'{k:9.2f} | {ps:4d} {f1 + f2:4d} ({f1}/{f2}) {ad:7d} | {100 * f1 / len(res):6.1f}% | {med:6.1f}'
              f'{"   <- #68 (isi run)" if k == 0 else ""}', flush=True)
    b = rows[0.0]
    if not a.imtihan:
        ok = [(r[0] - r[1] - r[2], -r[4], -k, k) for k, r in rows.items()
              if k > 0 and r[5] < 20 and r[0] > r[1] + r[2] and r[0] - r[1] - r[2] >= b[0] - b[1] - b[2]]
        print('CHUNI SELL k: ' + (f'{max(ok)[3]}' if ok else 'KOI NAHI = FAIL'))
    else:
        r = rows[a.k]
        okI = r[1] + r[2] == 0 and r[0] >= b[0] and r[4] < b[4]
        print('IMTIHAN: ' + ('PASS' if okI else 'FAIL') + f' (shart: fail 0, pass >= {b[0]}, median < {b[4]:.1f})')


if __name__ == '__main__':
    main()
