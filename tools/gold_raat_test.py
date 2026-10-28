#!/usr/bin/env python3
"""Koshish #30 (28 Oct 2026) - Gold "raat ki tezi" H1.

Qaida (badalna mana): docs/purana-haal.md, grep "Koshish #30 qaida".
Data: data/ftmo/XAU_XAG_H1_dukascopy.zip (Dukascopy H1, UTC) -> NY waqt.

  python3 tools/gold_raat_test.py             # TALAASH (entry 2003..2018)
  python3 tools/gold_raat_test.py --imtihan   # 2019+ EK dafa

A = BUY 19:00 NY -> 08:00 NY, B = SELL 08:00 -> 16:00 NY, din = BUY 08 -> 16
(sirf maloomat). SL = 1 x ATR14 daily = 1R. Kharcha = max($0.50, 0.03%).
"""
import argparse

import numpy as np
import pandas as pd

from ftmo_test import load, session_day

COST_USD, COST_PCT = 0.50, 0.0003


def daily_atr(df):
    day = session_day(df['t'])
    d = df.groupby(day.values).agg(h=('High', 'max'), l=('Low', 'min'), c=('Close', 'last'))
    pc = d['c'].shift()
    tr = np.maximum(d['h'] - d['l'], np.maximum((d['h'] - pc).abs(), (d['l'] - pc).abs()))
    atr = tr.ewm(alpha=1 / 14, adjust=False, min_periods=14).mean()
    return day, atr.shift()          # sirf band din ka ATR (aaj ke din se pehle)


def trades(df, day, atr, h_in, h_out, side, days_ok):
    ny = df['t'].dt.tz_convert('America/New_York')
    hr, wd = ny.dt.hour.values, ny.dt.weekday.values
    o, h, l = df['Open'].values, df['High'].values, df['Low'].values
    a = atr.reindex(day.values).values
    tt = df['t'].values
    out = []
    for i in np.where((hr == h_in) & np.isin(wd, days_ok))[0]:
        if np.isnan(a[i]):
            continue
        e, risk = o[i], a[i]
        sl = e - side * risk
        x = None
        j = i
        while j < len(o) and (tt[j] - tt[i]) < np.timedelta64(24, 'h'):
            if j > i and hr[j] == h_out:
                x = o[j]
                break
            if (side == 1 and l[j] <= sl) or (side == -1 and h[j] >= sl):
                op = o[j]
                x = min(sl, op) if side == 1 else max(sl, op)
                if j == i:
                    x = sl
                break
            j += 1
        if x is None:
            continue                 # chhutti / data ghaib
        cost = max(COST_USD, COST_PCT * e)
        out.append((pd.Timestamp(tt[i], tz='UTC'), (side * (x - e) - cost) / risk))
    return pd.DataFrame(out, columns=['t', 'r'])


def report(name, t):
    r = t['r']
    n, ex = len(r), r.mean()
    se = r.std(ddof=1) / np.sqrt(n)
    yr = t.groupby(t['t'].dt.year)['r'].sum()
    print(f'{name}: {n} tr, Exp {ex:+.4f}R, SE {se:.4f}, Exp-2SE {ex - 2 * se:+.4f}, '
          f'jeet {100 * (r > 0).mean():.1f}%, kul {r.sum():+.1f}R, saal {(yr > 0).sum()}/{len(yr)}')
    print('   saal: ' + ' '.join(f'{y % 100:02d}:{v:+.0f}' for y, v in yr.items()))
    return n, ex, se, (yr > 0).mean()


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--imtihan', action='store_true')
    a = ap.parse_args()
    df = load('XAUUSD')
    day, atr = daily_atr(df)
    if a.imtihan:
        keep = lambda t: t[t['t'] >= pd.Timestamp('2019-01-01', tz='UTC')]
        print('IMTIHAN 2019+ (EK dafa)')
    else:
        cut = df['t'] < pd.Timestamp('2019-01-02', tz='UTC')   # 2018 ki aakhri raat band ho sake
        df, day = df[cut].reset_index(drop=True), day[cut].reset_index(drop=True)
        keep = lambda t: t[t['t'] < pd.Timestamp('2019-01-01', tz='UTC')]
        print('TALAASH 2003..2018')
    res = {}
    for name, hi, ho, s, dd in [('A raat BUY 19->08', 19, 8, 1, [6, 0, 1, 2, 3]),
                                ('B din SELL 08->16', 8, 16, -1, [0, 1, 2, 3, 4]),
                                ('din BUY 08->16 (maloomat)', 8, 16, 1, [0, 1, 2, 3, 4])]:
        res[name] = report(name, keep(trades(df, day, atr, hi, ho, s, dd)))
    for name in list(res)[:2]:
        n, ex, se, yp = res[name]
        if a.imtihan:
            ok = n >= 30 and ex - 2 * se > 0
        else:
            ok = n >= 100 and ex - 2 * se > 0 and yp > 0.5
        print(f'{name}: {"PASS" if ok else "FAIL"}')


if __name__ == '__main__':
    main()
