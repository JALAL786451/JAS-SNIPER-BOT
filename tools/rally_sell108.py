#!/usr/bin/env python3
"""#108r (69vi, 19 Nov 2026, user "test karo"): gold D1 RALLY-SELL.
Qaida (test se PEHLE likha, docs/research/rally-sell-qaida.md, badalna MANA):
  Daur: D1 EMA50 < EMA200 aur close < EMA200.
  Ishara (band D1 candle): high >= EMA50 aur close < EMA50 (rally EMA50 ko chhoo kar wapas) -> SELL close par.
  SL = entry + 2 x ATR14 (1R). Exit: high SL chhoye (gap ho to open par) YA close > EMA50 (close par).
  Ek waqt ek trade. Kharcha 0.03% har taraf. Swap 0 (swap-free).
  python3 tools/rally_sell108.py --ginti   # sirf trade ginti (nateeja nahi) - G5 data jaanch
  python3 tools/rally_sell108.py          # TALAASH (< 2019); IMTIHAN sirf TALAASH PASS par
"""
import sys
from pathlib import Path

import numpy as np
import pandas as pd

sys.path.insert(0, str(Path(__file__).resolve().parent))
from ftmo_test import load, session_day  # noqa: E402

COST = 0.0003
CUT = pd.Timestamp('2019-01-01')


def daily(sym):
    h = load(sym)
    h['d'] = session_day(h['t']).values
    d = h.groupby('d').agg(O=('Open', 'first'), H=('High', 'max'), L=('Low', 'min'), C=('Close', 'last'))
    c = d['C']
    d['E50'] = c.ewm(span=50, adjust=False).mean()
    d['E200'] = c.ewm(span=200, adjust=False).mean()
    pc = c.shift()
    tr = np.maximum(d['H'] - d['L'], np.maximum((d['H'] - pc).abs(), (d['L'] - pc).abs()))
    d['ATR'] = tr.ewm(alpha=1 / 14, adjust=False).mean()
    return d.iloc[200:]


def run(d):
    O, H, C, E50, E200, A = (d[k].values for k in ['O', 'H', 'C', 'E50', 'E200', 'ATR'])
    idx = d.index
    out, i, n = [], 0, len(d)
    while i < n - 1:
        if E50[i] < E200[i] and C[i] < E200[i] and H[i] >= E50[i] and C[i] < E50[i]:
            ent, rd = C[i], 2 * A[i]
            sl = ent + rd
            ex, why, j = None, None, i + 1
            while j < n:
                if H[j] >= sl:
                    ex, why = max(sl, O[j]), 'SL'
                    break
                if C[j] > E50[j]:
                    ex, why = C[j], 'EMA50'
                    break
                j += 1
            if ex is None:
                ex, why, j = C[n - 1], 'khuli', n - 1
            r = (ent - ex) / rd - COST * (ent + ex) / rd
            out.append((idx[i], idx[j], ent, ex, r, why))
            i = j + 1
        else:
            i += 1
    return pd.DataFrame(out, columns=['in', 'out', 'ent', 'ex', 'R', 'why'])


def line(t):
    if len(t) == 0:
        return '    0 tr'
    se = t['R'].std(ddof=1) / np.sqrt(len(t)) if len(t) > 1 else np.nan
    return (f"{len(t):4d} tr | jeet {100 * (t['R'] > 0).mean():4.1f}% | Exp {t['R'].mean():+.3f}R "
            f"(SE {se:.3f}, -2SE {t['R'].mean() - 2 * se:+.3f}) | kul {t['R'].sum():+.1f}R")


def main():
    ginti = '--ginti' in sys.argv
    res = {}
    for s in ['XAUUSD', 'XAGUSD']:
        t = run(daily(s))
        res[s] = t
        a, b = t[t['in'] < CUT], t[t['in'] >= CUT]
        if ginti:
            print(f'{s}: TALAASH {len(a)} tr | IMTIHAN {len(b)} tr | saal: {sorted(a["in"].dt.year.value_counts().to_dict().items())}')
            continue
        print(f'{s} TALAASH  {line(a)}')
    if ginti:
        return
    g = res['XAUUSD']
    a = g[g['in'] < CUT]
    se = a['R'].std(ddof=1) / np.sqrt(len(a))
    s_a = res['XAGUSD'][res['XAGUSD']['in'] < CUT]
    ok = len(a) >= 30 and a['R'].mean() > 0 and a['R'].mean() - 2 * se > 0 and s_a['R'].mean() > 0
    print(f"QAIDA TALAASH: gold n>=30 {len(a) >= 30}, Exp>0 {a['R'].mean() > 0}, Exp-2SE>0 {a['R'].mean() - 2 * se > 0}, "
          f"silver Exp>0 {s_a['R'].mean() > 0} => {'PASS' if ok else 'FAIL'}")
    if ok:
        for s in res:
            b = res[s][res[s]['in'] >= CUT]
            print(f'{s} IMTIHAN  {line(b)}')
    else:
        print('IMTIHAN chhupa (TALAASH FAIL) - 2019+ data dekha NAHI gaya.')
    print('Aakhri 5 gold trades:')
    print(g.tail(5).to_string(index=False, float_format=lambda v: f'{v:.3f}') if ok else '(chhupi)')


if __name__ == '__main__':
    main()
