#!/usr/bin/env python3
"""Koshish #33 (28 Oct 2026) - JAS Trend Pro t2 (Supertrend 10/3, sirf BUY) gold chhoti TF.

Qaida (badalna mana): docs/purana-haal.md, grep "Koshish #33 qaida".
4H + 1H: data/ftmo/XAU_XAG_H1_dukascopy.zip (TALAASH 2003..2018);
15m: data/qdm/XAUUSD_M1_2021_24.zip (TALAASH 2021..2024).

  python3 tools/gold_st_tf.py

Flip upar = agli open BUY, flip neeche = agli open band, SL nahi, 1R = 3 x ATR(10).
Kharcha max($0.50, 0.03% x (entry+exit)) + swap 3%/saal har raat.
"""
import numpy as np
import pandas as pd

from fib_ote_test import bars, load_m1
from ftmo_test import ST_MULT, load, session_day, supertrend_up
from gold_h4_pullback import report

COST_USD, COST_PCT = 0.50, 0.0003
SWAP = 0.03 / 365


def h4_from_h1(df):
    day = session_day(df['t'])
    blk = ((df['t'].dt.tz_convert('America/New_York') + pd.Timedelta(hours=7)).dt.hour // 4).values
    g = df.groupby([day.values, blk])
    return g.agg(t=('t', 'first'), Open=('Open', 'first'), High=('High', 'max'),
                 Low=('Low', 'min'), Close=('Close', 'last')).sort_values('t').reset_index(drop=True)


def trades(x, cost_on=True):
    o, h, l, c = (x[k].values for k in ('Open', 'High', 'Low', 'Close'))
    up, atr = supertrend_up(h, l, c)
    day = session_day(x['t']).values
    tt = x['t'].values
    out, pos = [], 0
    for i in range(1, len(x) - 1):
        if pos == 0 and up[i] and not up[i - 1] and i > 30:
            pos, e, ep, ru = 1, i + 1, o[i + 1], ST_MULT * atr[i]
        elif pos == 1 and not up[i] and up[i - 1]:
            xp = o[i + 1]
            cost = 0.0
            if cost_on:
                nights = (pd.Timestamp(day[i + 1]) - pd.Timestamp(day[e])).days
                cost = max(COST_USD, COST_PCT * (ep + xp)) + SWAP * nights * ep
            out.append((pd.Timestamp(tt[e], tz='UTC'), 1, (xp - ep - cost) / ru, i + 1 - e))
            pos = 0
    return pd.DataFrame(out, columns=['t', 'side', 'r', 'bars'])


def main():
    h1 = load('XAUUSD')
    h1 = h1[h1['t'] < pd.Timestamp('2019-01-02', tz='UTC')].reset_index(drop=True)
    m15 = bars(load_m1('XAUUSD_M1_2021_24.zip'), '15min')
    end18 = lambda t: t[t['t'] < pd.Timestamp('2019-01-01', tz='UTC')]
    for name, x, keep in [('4H  2003-18', h4_from_h1(h1), end18), ('1H  2003-18', h1, end18),
                          ('15m 2021-24', m15, lambda t: t)]:
        t = keep(trades(x))
        n, ex, se, yp, yr = report(name, t)
        print('   saal: ' + ' '.join(f'{y % 100:02d}:{v:+.0f}' for y, v in yr.items()))
        t0 = keep(trades(x, cost_on=False))
        print(f'   bina kharcha {t0["r"].mean():+.4f}R, ausat {t["bars"].mean():.0f} candle, '
              f'{"PASS" if n >= 100 and ex - 2 * se > 0 and yp > 0.5 else "FAIL"}')


if __name__ == '__main__':
    main()
