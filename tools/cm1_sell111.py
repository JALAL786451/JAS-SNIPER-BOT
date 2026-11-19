#!/usr/bin/env python3
"""#111m (69vi, 19 Nov 2026, user "test karo"): C-M1 month-end "dash for cash" SELL, 8 index (Etula et al. RFS 2020).
Qaida: docs/research/cm1-sell-qaida.md (test se PEHLE, badalna MANA). Research: docs/research/daur11-sell-agent.md.
  D = T-(s+1) (T = market ka mahine ka aakhri trading din, s = settlement din); SELL D-5 close, band D close.
  SL 3 x ATR20 D1 (high chhoye; gap = open). Window mein NYSE chhutti-se-pehle din ho to skip. Kharcha 0.03% / taraf.
  python3 tools/cm1_sell111.py --ginti   # sirf ginti + data jaanch
  python3 tools/cm1_sell111.py           # TALAASH (< 2019); IMTIHAN sirf PASS par
"""
import io
import sys
import zipfile
from pathlib import Path

import numpy as np
import pandas as pd

ROOT = Path(__file__).resolve().parent.parent
CUT = pd.Timestamp('2019-01-01')
COST = 0.0003
START = {'DE30': '1990', 'UK100': '1996', 'FR40': '2000', 'EU50': '2007', 'JP225': '1990', 'AUS200': '1999',
         'HK50': '1990', 'US30': '1995-06-01'}
SETTLE = {  # (se, s) - us tareekh se s
    'US30': [('1995-06-01', 3), ('2017-09-05', 2), ('2024-05-28', 1)],
    'UK100': [('1900', 3), ('2014-10-06', 2)], 'FR40': [('1900', 3), ('2014-10-06', 2)],
    'EU50': [('1900', 3), ('2014-10-06', 2)], 'JP225': [('1900', 3), ('2019-07-16', 2)],
    'AUS200': [('1900', 3), ('2016-03-07', 2)], 'DE30': [('1900', 2)], 'HK50': [('1900', 2)]}


def load(sym):
    with zipfile.ZipFile(ROOT / 'data' / 'yahoo' / 'D1.zip') as z:
        d = pd.read_csv(io.BytesIO(z.read(f'{sym}.csv')))
    d['t'] = pd.to_datetime(d['t'])
    d = d.dropna().sort_values('t').drop_duplicates('t').reset_index(drop=True)
    return d


def nyse_preholiday():
    t = load('US500')['t']
    bd = t + pd.offsets.BDay(1)
    nxt = t.shift(-1)
    return set(t[(nxt > bd)].dt.normalize())


def settle(sym, day):
    s = None
    for a, v in SETTLE[sym]:
        if day >= pd.Timestamp(a):
            s = v
    return s


def run(sym, pre, cost=COST):
    d = load(sym)
    pc = d['Close'].shift()
    tr = np.maximum(d['High'] - d['Low'], np.maximum((d['High'] - pc).abs(), (d['Low'] - pc).abs()))
    d['ATR'] = tr.rolling(20).mean()
    O, H, C, A, T = d['Open'].values, d['High'].values, d['Close'].values, d['ATR'].values, d['t']
    ym = T.dt.to_period('M')
    last = d.groupby(ym).tail(1).index.values  # T har mahine
    out = []
    for ti in last:
        day = T.iloc[ti]
        if day < pd.Timestamp(START[sym]):
            continue
        s = settle(sym, day)
        di = ti - (s + 1)
        ei = di - 5
        if ei < 21 or not (A[ei] > 0):
            continue
        win = T.iloc[ei + 1:di + 1].dt.normalize()
        if any(x in pre for x in win):
            continue
        ent, rd = C[ei], 3 * A[ei]
        sl, ex, why = ent + rd, C[di], 'D'
        for j in range(ei + 1, di + 1):
            if H[j] >= sl:
                ex, why = max(sl, O[j]), 'SL'
                break
        out.append((day.to_period('M'), sym, day, (ent - ex) / rd - cost * (ent + ex) / rd, why, H[ei] == C[ei] == O[ei]))
    return pd.DataFrame(out, columns=['m', 'sym', 'T', 'R', 'why', 'flat'])


def summ(t, label):
    b = t.groupby('m')['R'].mean()  # har mahine tokri ka ausat
    se = b.std(ddof=1) / np.sqrt(len(b))
    per = t.groupby('sym')['R'].mean()
    print(f'{label}: {len(t)} tr, {len(b)} mahine | trade Exp {t["R"].mean():+.4f}R | tokri/mahina Exp {b.mean():+.4f}R '
          f'(SE {se:.4f}, -2SE {b.mean() - 2 * se:+.4f}) | musbat market {int((per > 0).sum())}/{len(per)}')
    print('   ', ' '.join(f'{k} {v:+.3f}' for k, v in per.items()))
    return b.mean(), se, int((per > 0).sum())


def main():
    pre = nyse_preholiday()
    syms = list(START)
    if '--ginti' in sys.argv:
        for s in syms:
            t = run(s, pre)
            a = t[t['T'] < CUT]
            print(f'{s}: TALAASH {len(a)} | IMTIHAN {int((t["T"] >= CUT).sum())} | flat candle {int(a["flat"].sum())} | SL {int((a["why"] == "SL").sum())}')
        return
    all_t = pd.concat([run(s, pre) for s in syms])
    a = all_t[all_t['T'] < CUT]
    m, se, pos = summ(a, 'TALAASH 0.03%')
    ok = len(a) >= 100 and m > 0 and m - 2 * se > 0 and pos >= 5
    print(f'QAIDA TALAASH: n>=100 {len(a) >= 100}, Exp>0 {m > 0}, Exp-2SE>0 {m - 2 * se > 0}, musbat>=5/8 {pos >= 5} => {"PASS" if ok else "FAIL"}')
    a2 = pd.concat([run(s, pre, 2 * COST) for s in syms])
    summ(a2[a2['T'] < CUT], 'ittila TALAASH 2x kharcha')
    a0 = pd.concat([run(s, pre, 0.0) for s in syms])
    summ(a0[a0['T'] < CUT], 'ittila TALAASH bina kharcha')
    if ok:
        b = all_t[all_t['T'] >= CUT]
        mb, seb, posb = summ(b, 'IMTIHAN 2019+ 0.03%')
        print(f'QAIDA IMTIHAN: Exp>0 {mb > 0}, musbat>=5/8 {posb >= 5} => {"PASS" if mb > 0 and posb >= 5 else "FAIL"}')
    else:
        print('IMTIHAN chhupa (2019+ dekha NAHI)')


if __name__ == '__main__':
    main()
