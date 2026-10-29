#!/usr/bin/env python3
"""Koshish #39 (29 Oct 2026) - TV built-in "Momentum strategy" (length 12) H1 TOKRI.

Qaida (badalna mana): docs/purana-haal.md, grep "Koshish #39 qaida".
Data: data/ftmo/*.zip (Dukascopy H1, UTC).

  python3 tools/mom_h1_test.py             # TALAASH (entry < 2019)
  python3 tools/mom_h1_test.py --imtihan   # 2019+ EK dafa

Stop-and-reverse: BUY STOP high+tick / SELL STOP low-tick sirf agli candle ke liye.
Har market ek position, R = ATR14(H1) entry waqt.
"""
import argparse

import numpy as np
import pandas as pd

from ftmo_test import COST, SWAP, load
from gold_h4_pullback import report

MARKETS = {'XAUUSD': (0.50, 0.01), 'XAGUSD': (0.0, 0.001), 'US500': (0.0, 0.1), 'USTEC': (0.0, 0.1)}
CUT = pd.Timestamp('2019-01-01', tz='UTC')
LEN, ATR_LEN = 12, 14


def trades(df, min_usd, tick, cost_on=True):
    o, h, l, c = (df[k].values for k in ('Open', 'High', 'Low', 'Close'))
    t = df['t']
    day = (t.dt.tz_convert('America/New_York') + pd.Timedelta(hours=7)).dt.normalize().values
    mom0 = c - np.r_[np.full(LEN, np.nan), c[:-LEN]]
    mom1 = mom0 - np.r_[np.nan, mom0[:-1]]
    pc = np.r_[np.nan, c[:-1]]
    tr = np.nanmax(np.c_[h - l, np.abs(h - pc), np.abs(l - pc)], axis=1)
    atr = pd.Series(tr).ewm(alpha=1 / ATR_LEN, adjust=False, min_periods=ATR_LEN).mean().values
    out, pos = [], None          # pos = (dir, entry, i, atr)

    def close(i, x):
        d, e, j, a = pos
        nights = int((day[i] - day[j]) / np.timedelta64(1, 'D'))
        k = (max(min_usd, COST * e) + max(min_usd, COST * x) + SWAP * nights * e) if cost_on else 0.0
        out.append((t.iloc[j], d, (d * (x - e) - k) / a))

    for i in range(1, len(c)):
        p = i - 1                 # order pichhli band candle par lagta hai
        if np.isnan(mom1[p]) or np.isnan(atr[p]):
            continue
        if mom0[p] > 0 and mom1[p] > 0 and (pos is None or pos[0] < 0):
            stop = h[p] + tick
            if h[i] >= stop:
                x = max(o[i], stop)
                if pos:
                    close(i, x)
                pos = (1, x, i, atr[p])
        elif mom0[p] < 0 and mom1[p] < 0 and (pos is None or pos[0] > 0):
            stop = l[p] - tick
            if l[i] <= stop:
                x = min(o[i], stop)
                if pos:
                    close(i, x)
                pos = (-1, x, i, atr[p])
    return pd.DataFrame(out, columns=['t', 'd', 'r'])


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--imtihan', action='store_true')
    a = ap.parse_args()
    print('IMTIHAN 2019+ (EK dafa)' if a.imtihan else 'TALAASH entry < 2019')
    allt, all0, cells = [], [], []
    for sym, (mn, tick) in MARKETS.items():
        df = load(sym)
        if not a.imtihan:
            df = df[df['t'] < CUT + pd.Timedelta(days=3)].reset_index(drop=True)
        keep = (lambda x: x[x['t'] >= CUT]) if a.imtihan else (lambda x: x[x['t'] < CUT])
        t, t0 = keep(trades(df, mn, tick)), keep(trades(df, mn, tick, cost_on=False))
        _, _, _, _, yr = report(f'{sym:7s}', t)
        print(f'   BUY {t[t.d > 0].r.mean():+.4f}R  SELL {t[t.d < 0].r.mean():+.4f}R  '
              f'bina kharcha {t0.r.mean():+.4f}R  tr/mahina {len(t) / max(1, t.t.dt.strftime("%Y%m").nunique()):.0f}')
        cells += list(yr.values)
        t['m'] = sym
        allt.append(t)
        all0.append(t0)
    t = pd.concat(allt)
    n, ex, se, _, _ = report('KUL    ', t)
    print(f'   bina kharcha {pd.concat(all0)["r"].mean():+.4f}R')
    mk = t.groupby('m')['r'].mean()
    cells = np.array(cells)
    print(f'   market musbat {(mk > 0).sum()}/4, (market x saal) musbat {(cells > 0).sum()}/{len(cells)}')
    if a.imtihan:
        ok = n >= 30 and ex - 2 * se > 0
    else:
        ok = n >= 100 and ex - 2 * se > 0 and (mk > 0).sum() >= 3 and (cells > 0).mean() > 0.5
    print('PASS' if ok else 'FAIL')


if __name__ == '__main__':
    main()
