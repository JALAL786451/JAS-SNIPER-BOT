#!/usr/bin/env python3
"""Koshish #83 (2 Nov 2026) - $1000 cent: #81 IBS martingale + Trend 4H ($7.5) + Khirki ($1.5).
Qaida (badalna mana): docs/purana-haal.md, grep "Koshish #83 qaida".

  python3 tools/k83_teen.py                     # TALAASH 2012-2018
  python3 tools/k83_teen.py --imtihan --pakka   # 2019+ EK dafa
"""
import argparse
import sys

import numpy as np
import pandas as pd

from ftmo53_asli import ASLI
from ftmo68 import KCOST, KH, khirki_trades
from ftmo_4h import st4h_trades
from ftmo_test import FILES, ibs_trades, load
from tokri47 import load_any

BAL0, STOP = 1000.0, 800.0
STEPS = (1.0, 1.5, 2.25)
SWAP = 0.03 / 365
CUT = pd.Timestamp('2019-01-01', tz='UTC')
T0 = pd.Timestamp('2012-01-01', tz='UTC')
SYS = {'IBS': 10.0, 'TREND': 7.5, 'KHIRKI': 1.5}


def get_trades(imtihan):
    rows = []
    jobs = [('IBS', s, ibs_trades) for s in ('US500', 'USTEC')] + \
           [('TREND', s, lambda d: st4h_trades(d, 6.0)) for s in FILES] + \
           [('KHIRKI', s, lambda d, s=s: khirki_trades(d, *KH[s])) for s in KH]
    cache = {}
    for sy, s, fn in jobs:
        if s not in cache:
            cache[s] = load(s) if s in FILES else load_any(s)
        df = cache[s]
        for (ei, xi, e, x, sd, d) in fn(df):
            te, tx = df.t.iloc[ei], df.t.iloc[min(xi, len(df) - 1)]
            if (te >= CUT) != imtihan or te < T0:
                continue
            nights = max(0, (tx.normalize() - te.normalize()).days)
            rows.append((te, tx, sy, s, d * (x - e) / sd, (e + x) / sd, nights * SWAP * e / sd))
    t = pd.DataFrame(rows, columns=['te', 'tx', 'sy', 'm', 'g', 'cf', 'sw'])
    return t.sort_values('te').reset_index(drop=True)


def stake(t, R, rng_idx=None):
    """$ fi trade (martingale sirf IBS, har mkt alag chain), trade ki tarteeb se."""
    idx = np.arange(len(t)) if rng_idx is None else rng_idx
    sy, m = t.sy.values, t.m.values
    step, out = {}, np.zeros(len(idx))
    for n, i in enumerate(idx):
        if sy[i] == 'IBS':
            k = STEPS[step.get(m[i], 0)]
            step[m[i]] = step.get(m[i], 0) + 1 if (R[i] < 0 and step.get(m[i], 0) < 2) else 0
        else:
            k = 1.0
        out[n] = SYS[sy[i]] * k * R[i]
    return out


def equity(t, pnl):
    """Band hone ki tarteeb se balance; stop laga?"""
    o = np.argsort(t.tx.values, kind='stable')
    eq = BAL0 + np.cumsum(pnl[o])
    dd = (np.maximum.accumulate(np.r_[BAL0, eq]) - np.r_[BAL0, eq]).max()
    return eq, dd, bool((eq < STOP).any())


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--imtihan', action='store_true')
    ap.add_argument('--pakka', action='store_true')
    a = ap.parse_args()
    if a.imtihan and not a.pakka:
        print('INKAAR: IMTIHAN sirf EK dafa, --imtihan --pakka')
        sys.exit(2)
    t = get_trades(a.imtihan)
    days = len(pd.bdate_range(t.te.min().date(), t.tx.max().date()))
    weeks = days / 5
    print(f'{"IMTIHAN 2019+" if a.imtihan else "TALAASH 2012-2018"}: {len(t)} trade, {days} trading din '
          f'({t.te.min().date()} .. {t.tx.max().date()}) = {len(t) / weeks:.2f} trade/hafta')
    for sy in SYS:
        print(f'  {sy:6s}: {(t.sy == sy).sum():4d} tr ({(t.sy == sy).sum() / weeks:.2f}/hafta)')
    for mult in (1.0, 2.0):
        cost = np.where(t.sy == 'KHIRKI', KCOST, t.m.map(lambda s: 0.75 * ASLI.get(s, 0)).values) * mult
        R = t.g.values - cost * t.cf.values - t.sw.values
        pnl = stake(t, R)
        eq, dd, stp = equity(t, pnl)
        ibs = t.sy.values == 'IBS'
        tb = t[ibs].reset_index(drop=True)
        pb = stake(tb, R[ibs])
        _, ddb, _ = equity(tb, pb)
        print(f'\nkharcha {mult:.0f}x:')
        for sy in SYS:
            k = t.sy.values == sy
            r = R[k]
            print(f'  {sy:6s}: Exp {r.mean():+.3f}R (Exp-2SE {r.mean() - 2 * r.std(ddof=1) / np.sqrt(len(r)):+.3f}), '
                  f'jeet {(r > 0).mean():.0%}, ${pnl[k].sum():+.1f}')
        dly = pd.Series(pnl).groupby(t.tx.dt.date.values).sum()
        print(f'  TEENO : kul ${pnl.sum():+.1f} (roz ${pnl.sum() / days:+.2f}, mahina ${pnl.sum() / days * 21:+.1f}) | '
              f'bura din ${dly.min():+.1f} | girawat ${dd:.1f} | stop {"HAAN" if stp else "nahi"}')
        print(f'  #81 B akela: kul ${pb.sum():+.1f} (roz ${pb.sum() / days:+.2f}) | girawat ${ddb:.1f}')
        rng = np.random.default_rng(1)
        hits = 0
        for _ in range(10000):
            ix = rng.integers(0, len(t), len(t))
            if (BAL0 + np.cumsum(stake(t, R, ix)) < STOP).any():
                hits += 1
        print(f'  bootstrap stop: {hits / 100:.2f}%')
        if mult == 2.0:
            ok = len(t) / weeks >= 3 and pnl.sum() > pb.sum() and dd < 200 and not stp and hits < 500
            print(f'\n{"IMTIHAN" if a.imtihan else "TALAASH"}: {"PASS" if ok else "FAIL"} '
                  '(2x: >=3/hafta, kul > #81 B, girawat < $200, stop nahi, bootstrap < 5%)')


if __name__ == '__main__':
    main()
