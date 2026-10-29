#!/usr/bin/env python3
"""Koshish #42 (29 Oct 2026) - US index overnight drift (16:00 NY BUY -> 09:00 NY becho).

Qaida (badalna mana): docs/purana-haal.md, grep "Koshish #42 qaida".
Data: data/ftmo/*.zip (Dukascopy H1, UTC -> NY).

  python3 tools/overnight_test.py             # TALAASH (entry < 2019)
  python3 tools/overnight_test.py --imtihan   # 2019+ EK dafa
"""
import argparse

import numpy as np
import pandas as pd

from ftmo_test import COST, SWAP, load, session_day
from gold_h4_pullback import report

MARKETS = ['US500', 'USTEC']
CUT = pd.Timestamp('2019-01-01', tz='UTC')


def daily_atr(df):
    day = session_day(df['t'])
    g = df.assign(d=day.values).groupby('d').agg(h=('High', 'max'), l=('Low', 'min'), c=('Close', 'last'))
    pc = g['c'].shift()
    tr = np.maximum(g['h'] - g['l'], np.maximum((g['h'] - pc).abs(), (g['l'] - pc).abs()))
    atr = tr.ewm(alpha=1 / 14, adjust=False, min_periods=14).mean().shift()   # sirf band din
    return day.values, atr


def trades(df, overnight=True, cost_on=True):
    o = df['Open'].values
    t = df['t']
    ny = t.dt.tz_convert('America/New_York')
    hr, date = ny.dt.hour.values, ny.dt.normalize().values
    day, atr = daily_atr(df)
    a_of = atr.reindex(day).values
    i16, i09 = np.where(hr == 16)[0], np.where(hr == 9)[0]
    out = []
    if overnight:
        pairs = [(i, i09[np.searchsorted(i09, i)]) for i in i16 if np.searchsorted(i09, i) < len(i09)]
    else:
        pairs = [(i, i16[np.searchsorted(i16, i)]) for i in i09 if np.searchsorted(i16, i) < len(i16)]
        pairs = [(i, j) for i, j in pairs if date[i] == date[j]]
    for i, j in pairs:
        if np.isnan(a_of[i]):
            continue
        e, x = o[i], o[j]
        nights = int((date[j] - date[i]) / np.timedelta64(1, 'D'))
        if overnight and nights > 4:     # chhutti / data ka khala
            continue
        k = (COST * (e + x) + SWAP * nights * e) if cost_on else 0.0
        out.append((t.iloc[i], 1, (x - e - k) / a_of[i]))
    return pd.DataFrame(out, columns=['t', 'd', 'r'])


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--imtihan', action='store_true')
    a = ap.parse_args()
    print('IMTIHAN 2019+ (EK dafa)' if a.imtihan else 'TALAASH entry < 2019')
    allt, all0, cells = [], [], []
    for sym in MARKETS:
        df = load(sym)
        if not a.imtihan:
            df = df[df['t'] < CUT + pd.Timedelta(days=5)].reset_index(drop=True)
        keep = (lambda x: x[x['t'] >= CUT]) if a.imtihan else (lambda x: x[x['t'] < CUT])
        t, t0 = keep(trades(df)), keep(trades(df, cost_on=False))
        _, _, _, _, yr = report(f'{sym:6s}', t)
        dn = keep(trades(df, overnight=False, cost_on=False))
        print(f'   bina kharcha {t0.r.mean():+.4f}R  tr/mahina {len(t) / max(1, t.t.dt.strftime("%Y%m").nunique()):.1f}  '
              f'(maloomat: din 09->16 bina kharcha {dn.r.mean():+.4f}R)')
        print('   saal: ' + ' '.join(f'{y % 100:02d}:{v:+.0f}' for y, v in yr.items()))
        cells += list(yr.values)
        t['m'] = sym
        allt.append(t)
        all0.append(t0)
    t = pd.concat(allt)
    n, ex, se, _, _ = report('KUL   ', t)
    print(f'   bina kharcha {pd.concat(all0)["r"].mean():+.4f}R')
    mk = t.groupby('m')['r'].mean()
    cells = np.array(cells)
    print(f'   market musbat {(mk > 0).sum()}/{len(MARKETS)}, (market x saal) musbat {(cells > 0).sum()}/{len(cells)}')
    if a.imtihan:
        ok = n >= 30 and ex - 2 * se > 0
    else:
        ok = n >= 100 and ex - 2 * se > 0 and (mk > 0).sum() == len(MARKETS) and (cells > 0).mean() > 0.5
    print('PASS' if ok else 'FAIL')


if __name__ == '__main__':
    main()
