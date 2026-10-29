#!/usr/bin/env python3
"""Koshish #45 (29 Oct 2026) - Connors & Alvarez "Double 7s" daily, sirf BUY.
Qaida (badalna mana): docs/purana-haal.md, grep "Koshish #45 qaida".

  python3 tools/double7_test.py             # TALAASH (entry < 2019)
  python3 tools/double7_test.py --imtihan   # 2019+ EK dafa

PASS sirf US500 + USTEC; XAU/XAG maloomat. Kharcha #34 jaisa.
"""
import argparse

import numpy as np
import pandas as pd

from ftmo_test import atr_rma, load, session_day
from gold_h4_pullback import report

MARKETS = {'US500': 0.0, 'USTEC': 0.0, 'XAUUSD': 0.50, 'XAGUSD': 0.0}
PASS_M = ('US500', 'USTEC')
CUT = pd.Timestamp('2019-01-01', tz='UTC')
COST_PCT, SWAP = 0.0003, 0.03 / 365


def bars_d1(df):
    day = session_day(df['t'])
    x = df.groupby(day.values).agg(t=('t', 'first'), Open=('Open', 'first'), High=('High', 'max'),
                                   Low=('Low', 'min'), Close=('Close', 'last')).sort_values('t').reset_index()
    return x.rename(columns={'index': 'day'})


def trades(x, min_usd, cost_on=True):
    o, h, l, c = (x[k].values.astype(float) for k in ('Open', 'High', 'Low', 'Close'))
    sma = pd.Series(c).rolling(200).mean().values
    lo7 = pd.Series(c).rolling(7).min().values
    hi7 = pd.Series(c).rolling(7).max().values
    atr = atr_rma(h, l, c, 14)
    day, tt = x['day'].values, x['t'].values
    out, pos = [], 0
    for i in range(200, len(x) - 1):
        if pos:
            if l[i] <= sl:
                xp, xi = (min(o[i], sl) if i > e else sl), i
            elif c[i] >= hi7[i]:
                xp, xi = o[i + 1], i + 1
            else:
                continue
            cost = 0.0
            if cost_on:
                nights = (pd.Timestamp(day[xi]) - pd.Timestamp(day[e])).days
                cost = max(min_usd, COST_PCT * (ep + xp)) + SWAP * nights * ep
            out.append((pd.Timestamp(tt[e], tz='UTC'), (xp - ep - cost) / ru, xi - e))
            pos = 0
            continue
        if c[i] > sma[i] and c[i] <= lo7[i]:
            pos, e, ep, ru = 1, i + 1, o[i + 1], 3 * atr[i]
            sl = ep - ru
    return pd.DataFrame(out, columns=['t', 'r', 'bars'])


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--imtihan', action='store_true')
    a = ap.parse_args()
    print('IMTIHAN 2019+ (EK dafa)' if a.imtihan else 'TALAASH entry < 2019')
    keep = (lambda t: t[t['t'] >= CUT]) if a.imtihan else (lambda t: t[t['t'] < CUT])
    res = {}
    for sym, mn in MARKETS.items():
        df = load(sym)
        if not a.imtihan:
            df = df[df['t'] < CUT + pd.Timedelta(days=60)].reset_index(drop=True)
        x = bars_d1(df)
        t, t0 = keep(trades(x, mn)), keep(trades(x, mn, cost_on=False))
        t['m'], t['r0'] = sym, t0['r'].values if len(t0) == len(t) else np.nan
        res[sym] = t
        tag = '' if sym in PASS_M else '  (maloomat)'
        report(f'{sym:7s}{tag}', t)
    t = pd.concat([res[m] for m in PASS_M])
    n, ex, se, _, _ = report('KUL index', t)
    print(f'   bina kharcha {t["r0"].mean():+.4f}R, ausat {t["bars"].mean():.1f} din, {n / max(1, t["t"].dt.year.nunique()):.0f} tr/saal')
    mk = t.groupby('m')['r'].mean()
    cells = t.groupby(['m', t['t'].dt.year])['r'].sum().values
    print(f'   index musbat {(mk > 0).sum()}/2, (market x saal) musbat {(cells > 0).sum()}/{len(cells)}')
    ok = (n >= 30 and ex > 0) if a.imtihan else (n >= 100 and ex - 2 * se > 0 and (mk > 0).all() and (cells > 0).mean() > 0.5)
    print('PASS' if ok else 'FAIL')


if __name__ == '__main__':
    main()
