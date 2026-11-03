#!/usr/bin/env python3
"""Jaanch (3 Nov 2026, user): hamari BUY tokri (B1 trend 4H + B2 IBS) jab KHULI ho, us waqt kaun sa instrument girta hai? SIRF 2012-2018.
Tokri ka roz ka R = har khuli trade ka (din ka close badlav / SL doori). Har instrument ka roz ka % badlav. Correlation + khuli dinon par ausat.

  python3 tools/ulta_jaanch.py
"""
import numpy as np
import pandas as pd

from ftmo_4h import st4h_trades
from ftmo_test import FILES, ibs_trades, load
from tokri47 import load_any

A, B = pd.Timestamp('2012-01-01', tz='UTC'), pd.Timestamp('2019-01-01', tz='UTC')
OTHERS = ['DEUIDXEUR', 'GBRIDXGBP', 'FRAIDXEUR', 'EUSIDXEUR', 'ESPIDXEUR', 'CHEIDXCHF', 'JPNIDXJPY', 'AUSIDXAUD', 'HKGIDXHKD',
          'CHIIDXUSD', 'USA30IDXUSD', 'USSC2000IDXUSD', 'LIGHTCMDUSD', 'BRENTCMDUSD', 'COCOACMDUSD', 'COFFEECMDUSX',
          'COTTONCMDUSX', 'SOYBEANCMDUSX', 'BTCUSD']


def dclose(df):
    d = df[(df.t >= A) & (df.t < B)].copy()
    d['d'] = d.t.dt.tz_convert('America/New_York').dt.date
    return d.groupby('d').Close.last()


def main():
    days = None
    bask = {}
    for s in FILES:
        df = load(s)
        c = dclose(df)
        dr = c.diff()
        days = c.index if days is None else days.union(c.index)
        tl = st4h_trades(df, 6.0) + (ibs_trades(df) if s in ('US500', 'USTEC') else [])
        for (ei, xi, e, x, sd, d) in tl:
            te, tx = df.t.iloc[ei], df.t.iloc[min(xi, len(df) - 1)]
            if te < A or te >= B:
                continue
            d0, d1 = te.tz_convert('America/New_York').date(), tx.tz_convert('America/New_York').date()
            for dd in dr.index[(dr.index > d0) & (dr.index <= d1)]:
                bask[dd] = bask.get(dd, 0.0) + d * dr[dd] / sd
    br = pd.Series(bask).reindex(sorted(days)).fillna(0.0)
    openD = br != 0
    print(f'2012-2018: {len(br)} din, tokri khuli {openD.sum()} din, tokri ke bure din (R < -0.5): {(br < -0.5).sum()}')
    rows = []
    for s in OTHERS:
        try:
            r = dclose(load_any(s)).pct_change() * 100
        except Exception as ex:
            print(s, 'data nahi', ex)
            continue
        j = pd.concat([br, r], axis=1, keys=['b', 'r']).dropna()
        j = j[j.index.isin(br.index)]
        corr = j.b.corr(j.r)
        on = j[j.b != 0].r.mean()
        bad = j[j.b < -0.5].r.mean()
        allm = j.r.mean()
        rows.append((s, corr, allm, on, bad, len(j)))
    rows.sort(key=lambda x: x[1])
    print(f'{"instrument":16s} {"corr":>6s} {"aam din %":>9s} {"tokri khuli %":>13s} {"tokri bura din %":>16s}')
    for s, c, a, o, b, n in rows:
        print(f'{s:16s} {c:+6.2f} {a:+9.3f} {o:+13.3f} {b:+16.3f}   ({n} din)')


if __name__ == '__main__':
    main()
