#!/usr/bin/env python3
"""Koshish #41 (29 Oct 2026) - Gao-Han-Li-Zhou 2018 intraday momentum, H1 proxy.

Qaida (badalna mana): docs/purana-haal.md, grep "Koshish #41 qaida".
Data: data/ftmo/*.zip (Dukascopy H1, UTC -> NY).

  python3 tools/intraday_mom_test.py             # TALAASH (entry < 2019)
  python3 tools/intraday_mom_test.py --imtihan   # 2019+ EK dafa
"""
import argparse

import numpy as np
import pandas as pd

from ftmo_test import COST, load, session_day
from gold_h4_pullback import report

MARKETS = ['US500', 'USTEC']
CUT = pd.Timestamp('2019-01-01', tz='UTC')
ATR_LEN = 14


def trades(df, cost_on=True):
    o, h, l, c = (df[k].values for k in ('Open', 'High', 'Low', 'Close'))
    t = df['t']
    ny = t.dt.tz_convert('America/New_York')
    hr = ny.dt.hour.values
    day = session_day(t).values
    pc = np.r_[np.nan, c[:-1]]
    tr = np.nanmax(np.c_[h - l, np.abs(h - pc), np.abs(l - pc)], axis=1)
    atr = pd.Series(tr).ewm(alpha=1 / ATR_LEN, adjust=False, min_periods=ATR_LEN).mean().values
    out = []
    for i in np.where(hr == 15)[0]:
        j = i - 6                                   # 09:00 candle, usi din ki
        if j < 0 or hr[j] != 9 or day[j] != day[i] or np.isnan(atr[i]) or i + 1 >= len(c):
            continue
        s = np.sign(c[j] - o[j])
        if s == 0:
            continue
        e = o[i]
        x = o[i + 1]
        k = COST * (e + x) if cost_on else 0.0
        out.append((t.iloc[i], s, (s * (x - e) - k) / atr[i]))
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
            df = df[df['t'] < CUT + pd.Timedelta(days=3)].reset_index(drop=True)
        keep = (lambda x: x[x['t'] >= CUT]) if a.imtihan else (lambda x: x[x['t'] < CUT])
        t, t0 = keep(trades(df)), keep(trades(df, cost_on=False))
        _, _, _, _, yr = report(f'{sym:6s}', t)
        print(f'   BUY {(t.d > 0).sum()} {t[t.d > 0].r.mean():+.4f}R  SELL {(t.d < 0).sum()} {t[t.d < 0].r.mean():+.4f}R  '
              f'bina kharcha {t0.r.mean():+.4f}R  tr/mahina {len(t) / max(1, t.t.dt.strftime("%Y%m").nunique()):.1f}')
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
