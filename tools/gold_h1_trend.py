#!/usr/bin/env python3
"""Koshish #32 (28 Oct 2026) - Gold daily Supertrend rukh, H1 EMA20 cross entry, chhota SL.

Qaida (badalna mana): docs/purana-haal.md, grep "Koshish #32 qaida".
Data: data/ftmo/XAU_XAG_H1_dukascopy.zip (Dukascopy H1, UTC), din 17:00 NY.

  python3 tools/gold_h1_trend.py             # TALAASH (entry 2003..2018)
  python3 tools/gold_h1_trend.py --imtihan   # 2019+ EK dafa

BUY: daily rukh upar + H1 close EMA20 ke upar cross; SELL ulta. SL 2 x ATR14(H1)
= 1R, band SL ya daily rukh palta. Kharcha max($0.50, 0.03%) + swap 3%/saal.
"""
import argparse

import numpy as np
import pandas as pd

from ftmo_test import load, session_day, supertrend_up
from gold_h4_pullback import report, rma

COST_USD, COST_PCT = 0.50, 0.0003
SWAP = 0.03 / 365
SL_ATR = 2.0


def build(df):
    day = session_day(df['t'])
    d = df.groupby(day.values).agg(h=('High', 'max'), l=('Low', 'min'), c=('Close', 'last'))
    up, atr_d = supertrend_up(d['h'].values, d['l'].values, d['c'].values)
    tr = pd.Series(np.where(np.isnan(atr_d), 0, np.where(up, 1, -1)), index=d.index).shift().fillna(0)
    x = pd.DataFrame({'t': df['t'], 'day': day.values, 'o': df['Open'], 'h': df['High'],
                      'l': df['Low'], 'c': df['Close']})
    x['trend'] = tr.reindex(x['day']).values
    x['ema'] = x['c'].ewm(span=20, adjust=False, min_periods=20).mean()
    pc = x['c'].shift()
    trh = np.maximum(x['h'] - x['l'], np.maximum((x['h'] - pc).abs(), (x['l'] - pc).abs()))
    x['atr'] = rma(trh, 14)
    return x


def trades(x, cost_on=True):
    o, h, l, c = (x[k].values for k in 'ohlc')
    ema, atr, trend = x['ema'].values, x['atr'].values, x['trend'].values
    day, tt = x['day'].values, x['t'].values
    out, n, i = [], len(x), 1
    while i < n - 1:
        e = i + 1
        side = 0
        if not np.isnan(ema[i - 1]) and not np.isnan(atr[i]):
            if c[i - 1] <= ema[i - 1] and c[i] > ema[i] and trend[e] == 1:
                side = 1
            elif c[i - 1] >= ema[i - 1] and c[i] < ema[i] and trend[e] == -1:
                side = -1
        if side == 0:
            i += 1
            continue
        px, risk = o[e], SL_ATR * atr[i]
        sl = px - side * risk
        xp = why = None
        j = e
        while j < n:
            if j > e and trend[j] != side:
                xp, why = o[j], 'rukh'
                break
            if (side == 1 and l[j] <= sl) or (side == -1 and h[j] >= sl):
                xp = sl if j == e else (min(sl, o[j]) if side == 1 else max(sl, o[j]))
                why = 'sl'
                break
            j += 1
        if xp is None:
            break                    # data khatam, adhoori trade chhodi
        nights = (pd.Timestamp(day[j]) - pd.Timestamp(day[e])).days
        cost = (max(COST_USD, COST_PCT * px) + SWAP * nights * px) if cost_on else 0.0
        out.append((pd.Timestamp(tt[e], tz='UTC'), side, (side * (xp - px) - cost) / risk, j - e, why))
        i = j                        # band wali H1 ki band se agla cross
    return pd.DataFrame(out, columns=['t', 'side', 'r', 'bars', 'why'])


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--imtihan', action='store_true')
    a = ap.parse_args()
    df = load('XAUUSD')
    if a.imtihan:
        print('IMTIHAN 2019+ (EK dafa)')
        keep = lambda t: t[t['t'] >= pd.Timestamp('2019-01-01', tz='UTC')]
    else:
        print('TALAASH 2003..2018')
        df = df[df['t'] < pd.Timestamp('2019-01-02', tz='UTC')].reset_index(drop=True)
        keep = lambda t: t[t['t'] < pd.Timestamp('2019-01-01', tz='UTC')]
    x = build(df)
    t = keep(trades(x))
    n, ex, se, yp, yr = report('KUL', t)
    print('   saal: ' + ' '.join(f'{y % 100:02d}:{v:+.0f}' for y, v in yr.items()))
    report('BUY ', t[t['side'] == 1])
    report('SELL', t[t['side'] == -1])
    report('bina kharcha (maloomat)', keep(trades(x, cost_on=False)))
    print(f'   band: {t["why"].value_counts().to_dict()}, ausat {t["bars"].mean():.1f} H1, '
          f'sab se bari jeet {t["r"].max():+.1f}R')
    ok = (n >= 30 and ex - 2 * se > 0) if a.imtihan else (n >= 100 and ex - 2 * se > 0 and yp > 0.5)
    print('PASS' if ok else 'FAIL')


if __name__ == '__main__':
    main()
