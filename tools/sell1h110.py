#!/usr/bin/env python3
"""#110s (69vi, 19 Nov 2026): gold 1H SELL. Qaida: docs/research/sell-1h-qaida.md
  A (user): 1H EMA20 < EMA50 aur close < EMA50; high >= EMA20 aur close < EMA20 -> SELL; exit close > EMA20.
  B (Claude): A + sirf jab PICHLE mukammal din D1 EMA50 < EMA200 (BUY qaida 'BUY mat lo' kahe).
  SL entry + 2 x ATR14 (1H) = 1R (gap = open), ek waqt ek trade, swap 0.
  Faisla kharcha 0.03% har taraf; ittila row 0.015% (pehle se elaan, faisla nahi).
"""
import sys
from pathlib import Path

import numpy as np
import pandas as pd

sys.path.insert(0, str(Path(__file__).resolve().parent))
from ftmo_test import load, session_day  # noqa: E402

CUT = pd.Timestamp('2019-01-01', tz='UTC')


def bars(sym):
    d = load(sym).rename(columns={'Open': 'O', 'High': 'H', 'Low': 'L', 'Close': 'C'})
    d = d[d['H'] > d['L']].reset_index(drop=True)
    c = d['C']
    for n in (20, 50):
        d[f'E{n}'] = c.ewm(span=n, adjust=False).mean()
    pc = c.shift()
    tr = np.maximum(d['H'] - d['L'], np.maximum((d['H'] - pc).abs(), (d['L'] - pc).abs()))
    d['ATR'] = tr.ewm(alpha=1 / 14, adjust=False).mean()
    day = session_day(d['t'])
    dc = d.groupby(day.values)['C'].last()
    dn = (dc.ewm(span=50, adjust=False).mean() < dc.ewm(span=200, adjust=False).mean())
    dn.iloc[:200] = False
    d['G'] = pd.Series(day.values).map(dn.shift(1)).fillna(False).astype(bool).values
    return d.iloc[200:].reset_index(drop=True)


def run(d, v, cost):
    O, H, C, E20, E50, A, G = (d[k].values for k in ['O', 'H', 'C', 'E20', 'E50', 'ATR', 'G'])
    T = d['t']
    out, i, n = [], 0, len(d)
    while i < n - 1:
        sig = E20[i] < E50[i] and C[i] < E50[i] and H[i] >= E20[i] and C[i] < E20[i] and (v == 'A' or G[i])
        if not sig:
            i += 1
            continue
        ent, rd = C[i], 2 * A[i]
        sl, ex, j = ent + rd, None, i + 1
        while j < n:
            if H[j] >= sl:
                ex = max(sl, O[j])
                break
            if C[j] > E20[j]:
                ex = C[j]
                break
            j += 1
        if ex is None:
            ex, j = C[n - 1], n - 1
        out.append((T.iloc[i], (ent - ex) / rd - cost * (ent + ex) / rd))
        i = j + 1
    return pd.DataFrame(out, columns=['in', 'R'])


def line(x):
    se = x.std(ddof=1) / np.sqrt(len(x))
    return f'{len(x):5d} tr | jeet {100 * (x > 0).mean():4.1f}% | Exp {x.mean():+.3f}R (SE {se:.3f}, -2.5SE {x.mean() - 2.5 * se:+.3f}) | kul {x.sum():+.1f}R'


def main():
    ginti = '--ginti' in sys.argv
    data = {s: bars(s) for s in ('XAUUSD', 'XAGUSD')}
    for v in ('A', 'B'):
        res = {s: run(data[s], v, 0.0003) for s in data}
        a = {s: res[s][res[s]['in'] < CUT]['R'] for s in res}
        if ginti:
            print(v, {s: (len(a[s]), int((res[s]['in'] >= CUT).sum())) for s in res})
            continue
        for s in res:
            print(f'{v} {s} TALAASH 0.03%  {line(a[s])}')
        g = a['XAUUSD']
        se = g.std(ddof=1) / np.sqrt(len(g))
        ok = len(g) >= 100 and g.mean() > 0 and g.mean() - 2.5 * se > 0 and a['XAGUSD'].mean() > 0
        print(f'  QAIDA {v}: => {"PASS" if ok else "FAIL"}')
        lo = run(data['XAUUSD'], v, 0.00015)
        print(f'  {v} gold ittila 0.015%: {line(lo[lo["in"] < CUT]["R"])}')
        z = run(data['XAUUSD'], v, 0.0)
        print(f'  {v} gold bina kharcha: Exp {z[z["in"] < CUT]["R"].mean():+.3f}R')
        if ok:
            for s in res:
                print(f'  {v} {s} IMTIHAN {line(res[s][res[s]["in"] >= CUT]["R"])}')
        else:
            print('  IMTIHAN chhupa')


if __name__ == '__main__':
    main()
