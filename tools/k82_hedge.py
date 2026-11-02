#!/usr/bin/env python3
"""Koshish #82 (2 Nov 2026) - gold 1m EMA20/50 + hedge-freeze (user ki method, SL ki jagah hedge) vs SL.
Qaida (badalna mana): docs/purana-haal.md, grep "Koshish #82 qaida".

  python3 tools/k82_hedge.py                      # TALAASH histdata 2009-2018
  python3 tools/k82_hedge.py --imtihan --pakka    # QDM 2021-24 EK dafa (sirf TALAASH PASS ke baad)

Size 1 oz ($1 qeemat = $1). "Wapas" = hedge ke baad EMA rukh pehle asli ke khilaf ho, phir asli ki taraf mude.
"""
import argparse
import sys
import zipfile
from pathlib import Path

import numpy as np
import pandas as pd

ROOT = Path(__file__).resolve().parent.parent
TP, HG = 1.0, 3.0
SPREAD = 0.24
NEWS = (8 * 60 + 30, 10 * 60, 14 * 60)


def load(imtihan):
    if imtihan:
        z = zipfile.ZipFile(ROOT / 'data/qdm/XAUUSD_M1_2021_24.zip')
        d = pd.read_csv(z.open(z.namelist()[0]))
        t = pd.to_datetime(d.Date.astype(str) + ' ' + d.Time).dt.tz_localize('UTC').dt.tz_convert('America/New_York')
        d['t'] = t.dt.tz_localize(None)
        d = d.rename(columns={'Open': 'O', 'High': 'H', 'Low': 'L', 'Close': 'C'})
    else:
        out = []
        for y in range(2009, 2019):
            z = zipfile.ZipFile(ROOT / f'data/histdata/XAUUSD_M1_{y}_NY.zip')
            nm = [n for n in z.namelist() if n.endswith('.csv')][0]
            x = pd.read_csv(z.open(nm), sep=';', header=None, names=['dt', 'O', 'H', 'L', 'C', 'V'])
            x['t'] = pd.to_datetime(x['dt'], format='%Y%m%d %H%M%S')
            out.append(x)
        d = pd.concat(out)
    return d[['t', 'O', 'H', 'L', 'C']].drop_duplicates('t').sort_values('t').reset_index(drop=True)


def run(d, cost, hedge):
    O, H, L, C = d.O.values, d.H.values, d.L.values, d.C.values
    e20 = d.C.ewm(span=20, adjust=False).mean().values
    e50 = d.C.ewm(span=50, adjust=False).mean().values
    tr = np.sign(e20 - e50)
    mins = (d.t.dt.hour * 60 + d.t.dt.minute).values
    wd = d.t.dt.weekday.values
    news = np.zeros(len(d), bool)
    for m in NEWS:
        news |= (np.abs(mins - m) <= 15)
    news &= wd < 5
    n = len(d)
    eq = np.zeros(n)
    real = 0.0
    state, dr, e, hp, flipped = 0, 0, 0.0, 0.0, False      # 0 flat, 1 asli, 2 hedge
    ntr = nhg = 0
    for i in range(51, n):
        t_ = tr[i - 1]
        nw = news[i]
        if state == 0 and not nw and t_ != 0:
            dr, e, state = int(t_), O[i], 1
            real -= cost
            ntr += 1
        if state == 2:
            if t_ == -dr:
                flipped = True
            if flipped and t_ == dr and not nw:
                real += -dr * (O[i] - hp)
                state = 1
        if state == 1:
            hl, tp = e - dr * HG, e + dr * TP
            hit_h = (L[i] <= hl) if dr > 0 else (H[i] >= hl)
            hit_t = (H[i] >= tp) if dr > 0 else (L[i] <= tp)
            if hit_h:
                px = min(O[i], hl) if dr > 0 else max(O[i], hl)
                if hedge:
                    hp, state, flipped = px, 2, (t_ == -dr)
                    real -= cost
                    nhg += 1
                else:
                    real += dr * (px - e)
                    state = 0
            elif hit_t:
                real += dr * (tp - e)
                state = 0
        m = 0.0
        if state >= 1:
            m += dr * (C[i] - e)
        if state == 2:
            m += -dr * (C[i] - hp)
        eq[i] = real + m
    return eq, ntr, nhg


def report(nm, d, eq):
    s = pd.Series(eq, index=d.t.values)
    day = s.groupby(d.t.dt.date.values).last()
    dly = day.diff().fillna(day.iloc[0])
    dd = (np.maximum.accumulate(eq) - eq).max()
    yr = day.groupby(pd.to_datetime(day.index).year).last().diff().fillna(day.groupby(pd.to_datetime(day.index).year).last().iloc[0])
    print(f'{nm} | kul ${eq[-1]:+9.1f} | roz ${eq[-1] / len(day):+.2f} | aam din ${dly.median():+.2f} | bura din ${dly.min():+.1f} '
          f'| max girawat ${dd:.0f}')
    print('   saal: ' + ' '.join(f'{y}:{v:+.0f}' for y, v in yr.items()))
    return eq[-1], dd, yr


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--imtihan', action='store_true')
    ap.add_argument('--pakka', action='store_true')
    a = ap.parse_args()
    if a.imtihan and not a.pakka:
        print('INKAAR: IMTIHAN sirf EK dafa, TALAASH PASS ke baad, --imtihan --pakka se.')
        sys.exit(2)
    d = load(a.imtihan)
    print(f'{"IMTIHAN QDM 2021-24" if a.imtihan else "TALAASH 2009-2018"}: {len(d)} M1, {d.t.iloc[0]} .. {d.t.iloc[-1]} (NY)')
    for mult in (1, 2):
        c = SPREAD * mult
        print(f'\nkharcha har leg {c:.2f}:')
        eH, ntr, nhg = run(d, c, True)
        tH, ddH, yH = report('H hedge', d, eH)
        print(f'   {ntr} trade, {nhg} hedge')
        eS, ntr2, _ = run(d, c, False)
        tS, ddS, yS = report('S SL   ', d, eS)
        print(f'   {ntr2} trade')
        if mult == 2:
            if a.imtihan:
                halves = [tH > 0]
            else:
                halves = [yH.loc[2009:2013].sum() > 0, yH.loc[2014:2018].sum() > 0]
            ok = tH > 0 and all(halves) and ddH < 200 and tH > tS
            print(f'\n{"IMTIHAN" if a.imtihan else "TALAASH"}: ' + ('PASS' if ok else 'FAIL') +
                  ' (2x: H kul > 0, dono aadhe musbat, girawat < $200, H > S)')


if __name__ == '__main__':
    main()
