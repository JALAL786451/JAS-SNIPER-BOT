#!/usr/bin/env python3
"""#109s (69vi, 19 Nov 2026, user): gold 4H SELL - EMA20/50 (V1) aur sirf EMA50 (V2). Qaida: docs/research/sell-4h-qaida.md
  V1: EMA20 < EMA50 aur close < EMA50; high >= EMA20 aur close < EMA20 -> SELL; exit close > EMA20.
  V2: EMA50 neeche ja rahi (EMA50 < 1 candle pehle wali); high >= EMA50 aur close < EMA50 -> SELL; exit close > EMA50.
  Dono: entry band 4H candle ke close par, SL entry + 2 x ATR14 (4H) = 1R (gap = open), ek waqt ek trade,
  kharcha 0.03% har taraf, swap 0.
  python3 tools/sell4h109.py --ginti   # sirf ginti
  python3 tools/sell4h109.py          # TALAASH (< 2019); IMTIHAN sirf PASS wale variant ka
"""
import sys
from pathlib import Path

import numpy as np
import pandas as pd

sys.path.insert(0, str(Path(__file__).resolve().parent))
from ftmo_test import load, session_day  # noqa: E402

COST = 0.0003
CUT = pd.Timestamp('2019-01-01', tz='UTC')


def h4(sym):
    h1 = load(sym)
    day = session_day(h1['t'])
    blk = ((h1['t'].dt.tz_convert('America/New_York') + pd.Timedelta(hours=7)).dt.hour // 4).values
    key = pd.Series(list(zip(day.values, blk)))
    gid = (key != key.shift()).cumsum().values - 1
    d = h1.groupby(gid).agg(t=('t', 'first'), O=('Open', 'first'), H=('High', 'max'), L=('Low', 'min'),
                            C=('Close', 'last')).reset_index(drop=True)
    c = d['C']
    for n in (20, 50):
        d[f'E{n}'] = c.ewm(span=n, adjust=False).mean()
    pc = c.shift()
    tr = np.maximum(d['H'] - d['L'], np.maximum((d['H'] - pc).abs(), (d['L'] - pc).abs()))
    d['ATR'] = tr.ewm(alpha=1 / 14, adjust=False).mean()
    return d.iloc[200:].reset_index(drop=True)


def run(d, v):
    O, H, C, E20, E50, A = (d[k].values for k in ['O', 'H', 'C', 'E20', 'E50', 'ATR'])
    T = d['t'].values
    out, i, n = [], 1, len(d)
    while i < n - 1:
        if v == 1:
            sig, ex_e = E20[i] < E50[i] and C[i] < E50[i] and H[i] >= E20[i] and C[i] < E20[i], E20
        else:
            sig, ex_e = E50[i] < E50[i - 1] and H[i] >= E50[i] and C[i] < E50[i], E50
        if not sig:
            i += 1
            continue
        ent, rd = C[i], 2 * A[i]
        sl, ex, why, j = ent + rd, None, None, i + 1
        while j < n:
            if H[j] >= sl:
                ex, why = max(sl, O[j]), 'SL'
                break
            if C[j] > ex_e[j]:
                ex, why = C[j], 'EMA'
                break
            j += 1
        if ex is None:
            ex, why, j = C[n - 1], 'khuli', n - 1
        out.append((pd.Timestamp(T[i]), (ent - ex) / rd - COST * (ent + ex) / rd, why))
        i = j + 1
    t = pd.DataFrame(out, columns=['in', 'R', 'why'])
    t['in'] = pd.to_datetime(t['in'], utc=True)
    return t


def st(x):
    se = x.std(ddof=1) / np.sqrt(len(x))
    return x.mean(), se


def line(x):
    m, se = st(x)
    return f'{len(x):5d} tr | jeet {100 * (x > 0).mean():4.1f}% | Exp {m:+.3f}R (SE {se:.3f}, -2.5SE {m - 2.5 * se:+.3f}) | kul {x.sum():+.1f}R'


def main():
    ginti = '--ginti' in sys.argv
    data = {s: h4(s) for s in ('XAUUSD', 'XAGUSD')}
    for v in (1, 2):
        nm = 'V1 EMA20/50' if v == 1 else 'V2 sirf EMA50'
        res = {s: run(data[s], v) for s in data}
        a = {s: res[s][res[s]['in'] < CUT]['R'] for s in res}
        if ginti:
            print(nm, {s: (len(a[s]), int((res[s]['in'] >= CUT).sum())) for s in res})
            continue
        for s in res:
            print(f'{nm} {s} TALAASH {line(a[s])}')
        m, se = st(a['XAUUSD'])
        ok = len(a['XAUUSD']) >= 100 and m > 0 and m - 2.5 * se > 0 and a['XAGUSD'].mean() > 0
        print(f'  QAIDA {nm}: gold n>=100 {len(a["XAUUSD"]) >= 100}, Exp>0 {m > 0}, Exp-2.5SE>0 {m - 2.5 * se > 0}, '
              f'silver Exp>0 {a["XAGUSD"].mean() > 0} => {"PASS" if ok else "FAIL"}')
        if ok:
            for s in res:
                print(f'  {nm} {s} IMTIHAN {line(res[s][res[s]["in"] >= CUT]["R"])}')
        else:
            print('  IMTIHAN chhupa (2019+ dekha NAHI)')


if __name__ == '__main__':
    main()
