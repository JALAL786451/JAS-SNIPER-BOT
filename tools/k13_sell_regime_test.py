#!/usr/bin/env python3
"""64vi (17 Nov 2026) - K13 TEST (a): SELL sirf girawat ke daur mein.
4H Supertrend(10,3) neeche palte = SELL, SIRF jab pichla D1 close < D1 SMA200 (gate). SL 6 ATR (t5 jaisa), exit = ST wapas upar.
BUY side (t5) muqable ke liye: bina gate aur D1 > SMA200 gate. Kharcha 0.03% har taraf; SELL swap 0 (swap-free).
  python3 tools/k13_sell_regime_test.py
"""
import sys
from pathlib import Path

import numpy as np
import pandas as pd

sys.path.insert(0, str(Path(__file__).resolve().parent))
from ftmo_test import load, session_day  # noqa: E402
import rehnuma_r2_test as r2  # noqa: E402


def h4_and_gate(sym):
    h1 = load(sym)
    day = session_day(h1['t'])
    blk = ((h1['t'].dt.tz_convert('America/New_York') + pd.Timedelta(hours=7)).dt.hour // 4).values
    key = pd.Series(list(zip(day.values, blk)))
    gid = (key != key.shift()).cumsum().values - 1
    h4 = h1.groupby(gid).agg(t=('t', 'first'), Open=('Open', 'first'), High=('High', 'max'), Low=('Low', 'min'),
                             Close=('Close', 'last')).reset_index(drop=True)
    h4day = session_day(h4['t']).values
    d1 = h1.groupby(day.values)['Close'].last()
    sma = d1.rolling(200).mean()
    below = (d1 < sma).shift(1)  # pichla MUKAMMAL din (repaint nahi)
    above = (d1 > sma).shift(1)
    g_dn = pd.Series(h4day).map(below).fillna(False).astype(bool).values
    g_up = pd.Series(h4day).map(above).fillna(False).astype(bool).values
    return h4, g_dn, g_up


def line(t, lo, hi):
    tt = t.assign(t=t['t'].dt.tz_localize(None))
    x = tt[(tt['t'] >= lo) & (tt['t'] < hi)]['R']
    if len(x) == 0:
        return '   0 tr'
    cum = x.cumsum().values
    dd = float(np.max(np.maximum.accumulate(np.r_[0, cum])[1:] - cum))
    return f'{len(x):4d} tr {x.mean():+.3f}R kul {x.sum():+6.1f}R dd {dd:4.1f}R'


def main():
    for sym in ('XAUUSD', 'US500', 'USTEC', 'XAGUSD'):
        h4, g_dn, g_up = h4_and_gate(sym)
        y0 = str(h4['t'].dt.year.iloc[0])
        print(f'\n== {sym} 4H ({y0}-2026) | pehla hissa <2019 | doosra 2019-26 ==')
        for nm, side, gate in (('SELL bina gate ', -1, None), ('SELL D1<SMA200', -1, g_dn),
                               ('BUY  bina gate ', +1, None), ('BUY  D1>SMA200', +1, g_up)):
            t = r2.run(h4, side, 6.0, gate)
            print(f'  {nm}: {line(t, "1990", "2019")} | {line(t, "2019", "2027")}')


if __name__ == '__main__':
    main()
