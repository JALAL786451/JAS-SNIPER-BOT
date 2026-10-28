#!/usr/bin/env python3
"""Koshish #31 (28 Oct 2026) - Gold H4 pullback, daily Supertrend rukh ke saath.

Qaida (badalna mana): docs/purana-haal.md, grep "Koshish #31 qaida".
Data: data/ftmo/XAU_XAG_H1_dukascopy.zip (Dukascopy H1, UTC) -> H4 NY 17:00 se jura.

  python3 tools/gold_h4_pullback.py             # TALAASH (entry 2003..2018)
  python3 tools/gold_h4_pullback.py --imtihan   # 2019+ EK dafa

BUY: daily rukh upar + H4 RSI(2) < 10; SELL ulta (> 90). SL 2 x ATR14(H4) = 1R.
Band: SL / RSI(2) > 70 (< 30) / rukh palta / 30 H4. Kharcha max($0.50, 0.03%)
+ swap 3%/saal har raat (dono rukh).
"""
import argparse

import numpy as np
import pandas as pd

from ftmo_test import load, session_day, supertrend_up

COST_USD, COST_PCT = 0.50, 0.0003
SWAP = 0.03 / 365
RSI_IN, RSI_OUT, MAX_BARS, SL_ATR = 10, 70, 30, 2.0


def rma(x, n):
    return x.ewm(alpha=1 / n, adjust=False, min_periods=n).mean()


def build(df):
    """H4 (17, 21, 01, 05, 09, 13 NY) + pichhle band din ka Supertrend rukh."""
    day = session_day(df['t'])
    blk = ((df['t'].dt.tz_convert('America/New_York') + pd.Timedelta(hours=7)).dt.hour // 4).values
    g = df.groupby([day.values, blk])
    h4 = g.agg(t=('t', 'first'), o=('Open', 'first'), h=('High', 'max'),
               l=('Low', 'min'), c=('Close', 'last')).reset_index(names=['day', 'blk'])
    h4 = h4.sort_values('t').reset_index(drop=True)
    d = df.groupby(day.values).agg(h=('High', 'max'), l=('Low', 'min'), c=('Close', 'last'))
    up, atr_d = supertrend_up(d['h'].values, d['l'].values, d['c'].values)
    tr = pd.Series(np.where(np.isnan(atr_d), 0, np.where(up, 1, -1)), index=d.index).shift().fillna(0)
    h4['trend'] = tr.reindex(h4['day']).values      # 0 = abhi pata nahi
    c = h4['c']
    dlt = c.diff()
    rs = rma(dlt.clip(lower=0), 2) / rma(-dlt.clip(upper=0), 2)
    h4['rsi'] = 100 - 100 / (1 + rs)
    pc = c.shift()
    trh = np.maximum(h4['h'] - h4['l'], np.maximum((h4['h'] - pc).abs(), (h4['l'] - pc).abs()))
    h4['atr'] = rma(trh, 14)
    return h4


def trades(h4, cost_on=True):
    o, h, l = h4['o'].values, h4['h'].values, h4['l'].values
    rsi, atr, trend = h4['rsi'].values, h4['atr'].values, h4['trend'].values
    day, tt = h4['day'].values, h4['t'].values
    out, n, i = [], len(h4), 0
    while i < n - 1:
        e = i + 1
        side = 0
        if not np.isnan(rsi[i]) and not np.isnan(atr[i]):
            if rsi[i] < RSI_IN and trend[e] == 1:
                side = 1
            elif rsi[i] > 100 - RSI_IN and trend[e] == -1:
                side = -1
        if side == 0:
            i += 1
            continue
        px, risk = o[e], SL_ATR * atr[i]
        sl = px - side * risk
        x = why = None
        j = e
        while j < n:
            if j > e:
                if (side == 1 and rsi[j - 1] > RSI_OUT) or (side == -1 and rsi[j - 1] < 100 - RSI_OUT):
                    x, why = o[j], 'rsi'
                elif trend[j] != side:
                    x, why = o[j], 'rukh'
                elif j - e >= MAX_BARS:
                    x, why = o[j], '30bar'
                if x is not None:
                    break
            if (side == 1 and l[j] <= sl) or (side == -1 and h[j] >= sl):
                x = sl if j == e else (min(sl, o[j]) if side == 1 else max(sl, o[j]))
                why = 'sl'
                break
            j += 1
        if x is None:
            break                    # data khatam, adhoori trade chhodi
        nights = (pd.Timestamp(day[j]) - pd.Timestamp(day[e])).days
        cost = (max(COST_USD, COST_PCT * px) + SWAP * nights * px) if cost_on else 0.0
        out.append((pd.Timestamp(tt[e], tz='UTC'), side, (side * (x - px) - cost) / risk, j - e, why))
        i = j                        # band wali H4 ki band se agla signal
    return pd.DataFrame(out, columns=['t', 'side', 'r', 'bars', 'why'])


def report(name, t):
    r = t['r']
    n, ex = len(r), r.mean()
    se = r.std(ddof=1) / np.sqrt(n)
    yr = t.groupby(t['t'].dt.year)['r'].sum()
    print(f'{name}: {n} tr, Exp {ex:+.4f}R, SE {se:.4f}, Exp-2SE {ex - 2 * se:+.4f}, '
          f'jeet {100 * (r > 0).mean():.1f}%, kul {r.sum():+.1f}R, saal {(yr > 0).sum()}/{len(yr)}')
    return n, ex, se, (yr > 0).mean(), yr


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
    h4 = build(df)
    t = keep(trades(h4))
    n, ex, se, yp, yr = report('KUL', t)
    print('   saal: ' + ' '.join(f'{y % 100:02d}:{v:+.0f}' for y, v in yr.items()))
    report('BUY ', t[t['side'] == 1])
    report('SELL', t[t['side'] == -1])
    report('bina kharcha (maloomat)', keep(trades(h4, cost_on=False)))
    print(f'   band: {t["why"].value_counts().to_dict()}, ausat {t["bars"].mean():.1f} H4')
    ok = (n >= 30 and ex - 2 * se > 0) if a.imtihan else (n >= 100 and ex - 2 * se > 0 and yp > 0.5)
    print('PASS' if ok else 'FAIL')


if __name__ == '__main__':
    main()
