#!/usr/bin/env python3
"""57vi (15 Nov 2026) - Rehnuma r1 ka '1D filter' vs JasTrendEA t5 (pehle wala), gold.

Qaida (t5 = Rehnuma default): Supertrend(10,3) 4H (NY 17:00 se), sirf BUY.
  flip upar (band candle) -> agli open BUY, SL = entry - 6 x ATR(10) (1R), TP nahi;
  flip neeche -> agli open band. SL ke baad nayi BUY sirf naye flip par.
Filter (Rehnuma useD): BUY sirf jab 1D Supertrend upar ho (aakhri BAND daily candle;
  4H candle din ki aakhri ho to usi din ka close). Flip par filter band = us flip par trade nahi.
Kharcha 0.03% har taraf + swap 3%/saal har raat (ftmo_test jaisa).
Data: data/ftmo/XAU_XAG_H1_dukascopy.zip (gold H1 2003-2026).

  python3 tools/rehnuma_1d_test.py
"""
import sys
from pathlib import Path

import numpy as np
import pandas as pd

sys.path.insert(0, str(Path(__file__).resolve().parent))
from ftmo_test import load, session_day, supertrend_up  # noqa: E402
from gold_st_tf import h4_from_h1  # noqa: E402

COST, SWAP, SLM = 0.0003, 0.03 / 365, 6.0


def daily_up(h1):
    sd = session_day(h1['t'])
    g = h1.assign(sd=sd.values).groupby('sd', sort=True)
    d = g.agg(High=('High', 'max'), Low=('Low', 'min'), Close=('Close', 'last'))
    up, _ = supertrend_up(d['High'].values, d['Low'].values, d['Close'].values)
    return pd.Series(up, index=d.index)


def run(h4, dup, use_d):
    o, h, l, c = (h4[k].values for k in ('Open', 'High', 'Low', 'Close'))
    up, atr = supertrend_up(h, l, c)
    sd = session_day(h4['t']).values
    last_of_day = np.r_[sd[1:] != sd[:-1], True]
    days = dup.index.values
    dvals = dup.values
    out, i, n = [], 31, len(h4)
    while i < n - 1:
        if up[i] and not up[i - 1]:
            # filter: aakhri band daily candle
            k = np.searchsorted(days, sd[i], side='right') - 1
            if not last_of_day[i]:
                k -= 1
            ok = (not use_d) or (k >= 0 and dvals[k])
            if ok:
                e, ep, r = i + 1, o[i + 1], SLM * atr[i]
                sl = ep - r
                j, xp, why = e, None, ''
                while j < n:
                    if l[j] <= sl:
                        xp, why = min(o[j], sl), 'SL'
                        break
                    if not up[j] and j + 1 < n:
                        xp, why = o[j + 1], 'ST'
                        j += 1
                        break
                    j += 1
                if xp is None:
                    break
                nights = int((sd[min(j, n - 1)] - sd[e]) / np.timedelta64(1, 'D'))
                pnl = xp - ep - COST * (ep + xp) - SWAP * ep * max(nights, 0)
                out.append((h4['t'].iloc[e], pnl / r, why))
                i = j
                continue
        i += 1
    return pd.DataFrame(out, columns=['t', 'R', 'why'])


def stats(t, a, b):
    t = t[(t['t'] >= a) & (t['t'] < b)]
    if len(t) == 0:
        return '0 tr'
    cum = t['R'].cumsum().values
    dd = float(np.max(np.maximum.accumulate(np.r_[0, cum])[1:] - cum)) if len(cum) else 0
    return (f"{len(t):4d} tr | jeet {100 * (t['R'] > 0).mean():4.1f}% | {t['R'].mean():+.3f}R | "
            f"kul {t['R'].sum():+6.1f}R | girawat {dd:4.1f}R | SL {int((t['why'] == 'SL').sum())}")


def main():
    h1 = load('XAUUSD')
    h4 = h4_from_h1(h1)
    dup = daily_up(h1)
    res = {'t5 (pehla, filter nahi)': run(h4, dup, False), 'Rehnuma + 1D filter': run(h4, dup, True)}
    spans = [('2010-2026 (Fable wala)', '2010', '2027'), ('2003-2018 (purana)', '2003', '2019'),
             ('2019-2026 (naya)', '2019', '2027'), ('2023-2026', '2023', '2027')]
    for nm, a, b in spans:
        print(f'\n== {nm} ==')
        for k, t in res.items():
            tt = t.assign(t=t['t'].dt.tz_localize(None))
            print(f'  {k:26s} {stats(tt, pd.Timestamp(a), pd.Timestamp(b))}')
    print('\n== saal ba saal (kul R): t5 | filter ==')
    for k, t in res.items():
        res[k] = t.assign(y=t['t'].dt.year)
    ya = res['t5 (pehla, filter nahi)'].groupby('y')['R'].sum()
    yb = res['Rehnuma + 1D filter'].groupby('y')['R'].sum()
    for y in sorted(set(ya.index) | set(yb.index)):
        if y >= 2010:
            print(f'  {y}: {ya.get(y, 0):+6.2f} | {yb.get(y, 0):+6.2f}')


if __name__ == '__main__':
    main()
