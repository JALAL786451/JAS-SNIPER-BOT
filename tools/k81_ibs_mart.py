#!/usr/bin/env python3
"""Koshish #81 (2 Nov 2026) - IBS daily (i6) US500 + USTEC + chhota martingale (1.5x, 3 qadam), $1000 cent.
Qaida (badalna mana): docs/purana-haal.md, grep "Koshish #81 qaida".

  python3 tools/k81_ibs_mart.py                      # TALAASH 2012-2018
  python3 tools/k81_ibs_mart.py --imtihan --pakka    # 2019+ EK dafa (sirf TALAASH PASS ke baad)
"""
import argparse
import sys

import numpy as np
import pandas as pd

from ftmo53_asli import ASLI
from ftmo_test import ibs_trades, load

BAL0, BASE, STOP = 1000.0, 10.0, 800.0
STEPS = (1.0, 1.5, 2.25)
MKTS = ('US500', 'USTEC')


def get_trades(imtihan):
    rows = []
    for s in MKTS:
        df = load(s)
        if not imtihan:
            df = df[df.t < pd.Timestamp('2019-01-01', tz='UTC')].reset_index(drop=True)
        for (ei, xi, e, x, sd, d) in ibs_trades(df):
            te, tx = df.t.iloc[ei], df.t.iloc[min(xi, len(df) - 1)]
            if imtihan and te < pd.Timestamp('2019-01-01', tz='UTC'):
                continue
            rows.append((te, tx, s, d * (x - e) / sd, (e + x) / sd))
    t = pd.DataFrame(rows, columns=['te', 'tx', 'm', 'g', 'cf']).sort_values('te').reset_index(drop=True)
    return t


def simulate(t, R, mart):
    """R = har trade ka R (kharche ke baad). Har mkt alag chain. Wapas: pnl $ list, stop laga?"""
    step = {m: 0 for m in MKTS}
    bal, pnl, stopped = BAL0, np.zeros(len(t)), False
    pending = []                                   # (tx, i)
    ms, tes, txs = t.m.values, t.te.values, t.tx.values
    for i in range(len(t)):
        pending.sort()
        while pending and pending[0][0] <= tes[i]:
            _, j = pending.pop(0)
            bal += pnl[j]
        if bal < STOP:
            stopped = True
            break
        k = STEPS[step[ms[i]]] if mart else 1.0
        pnl[i] = BASE * k * R[i]
        pending.append((txs[i], i))
        if mart:
            step[ms[i]] = step[ms[i]] + 1 if (R[i] < 0 and step[ms[i]] < len(STEPS) - 1) else 0
    for _, j in pending:
        bal += pnl[j]
    return pnl, stopped


def boot(ms, R, mart, n=10000, seed=1):
    rng = np.random.default_rng(seed)
    hits = 0
    N = len(R)
    for _ in range(n):
        idx = rng.integers(0, N, N)
        step = {m: 0 for m in MKTS}
        bal = BAL0
        for i in idx:
            k = STEPS[step[ms[i]]] if mart else 1.0
            bal += BASE * k * R[i]
            if mart:
                step[ms[i]] = step[ms[i]] + 1 if (R[i] < 0 and step[ms[i]] < 2) else 0
            if bal < STOP:
                hits += 1
                break
    return hits / n


def report(nm, t, pnl, stopped, days):
    eq = BAL0 + np.cumsum(pnl)
    dd = (np.maximum.accumulate(np.r_[BAL0, eq]) - np.r_[BAL0, eq]).max()
    dly = pd.Series(pnl).groupby(t.tx.dt.date.values).sum()
    print(f'{nm} | kul ${pnl.sum():+8.1f} | roz ${pnl.sum() / days:+.2f} | bura din ${dly.min():+.1f} | '
          f'max girawat ${dd:.1f} | jeet {(pnl > 0).mean():.0%} | stop {"HAAN" if stopped else "nahi"}')
    return pnl.sum(), dd


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--imtihan', action='store_true')
    ap.add_argument('--pakka', action='store_true')
    a = ap.parse_args()
    if a.imtihan and not a.pakka:
        print('INKAAR: IMTIHAN sirf EK dafa, TALAASH PASS ke baad, --imtihan --pakka se.')
        sys.exit(2)
    t = get_trades(a.imtihan)
    span = pd.bdate_range(t.te.min().date(), t.tx.max().date())
    days = len(span)
    print(f'{"IMTIHAN 2019+" if a.imtihan else "TALAASH 2012-2018"}: {len(t)} trade, {days} trading din, '
          f'{t.te.min().date()} .. {t.tx.max().date()}')
    for mult in (1.0, 2.0):
        cost = t.m.map(lambda s: 0.75 * ASLI[s]).values * mult
        R = t.g.values - cost * t.cf.values
        n = len(R)
        ex, se = R.mean(), R.std(ddof=1) / np.sqrt(n)
        print(f'\nkharcha {mult:.0f}x: Exp {ex:+.3f}R, SE {se:.3f}, Exp-2SE {ex - 2 * se:+.3f}, jeet {(R > 0).mean():.1%}')
        pA, sA = simulate(t, R, False)
        pB, sB = simulate(t, R, True)
        totA, ddA = report('A fix $10   ', t, pA, sA, days)
        totB, ddB = report('B martingale', t, pB, sB, days)
        bA, bB = boot(t.m.values, R, False), boot(t.m.values, R, True)
        print(f'bootstrap account stop ($800): A {bA:.2%} | B {bB:.2%}')
        if mult == 2.0:
            ok = ex - 2 * se > 0 and totB > totA and ddB < 200 and not sB and bB < 0.05
            print(f'\n{"IMTIHAN" if a.imtihan else "TALAASH"}: ' + ('PASS' if ok else 'FAIL') +
                  ' (2x: A Exp-2SE>0, B kul > A, B girawat < $200, stop nahi, bootstrap < 5%)')


if __name__ == '__main__':
    main()
