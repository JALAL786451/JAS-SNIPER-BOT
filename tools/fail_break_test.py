#!/usr/bin/env python3
"""Koshish #38 (29 Oct 2026) - failed breakdown / breakout kal ke H/L par, NY open, US index.

Qaida (badalna mana): docs/purana-haal.md, grep "Koshish #38 qaida".
Data: data/ftmo/*.zip (Dukascopy H1, UTC -> NY).

  python3 tools/fail_break_test.py             # TALAASH (entry < 2019)
  python3 tools/fail_break_test.py --imtihan   # 2019+ EK dafa
"""
import argparse

import numpy as np
import pandas as pd

from ftmo_test import COST, load, session_day
from gold_h4_pullback import report

MARKETS = ['US500', 'USTEC']
CUT = pd.Timestamp('2019-01-01', tz='UTC')
ATR_LEN, BRK, SL_BUF, TP_R, LOOK = 14, 0.1, 0.2, 3.0, 3
HOURS = (9, 10, 11)


def trades(df, cost_on=True):
    o, h, l, c = (df[k].values for k in ('Open', 'High', 'Low', 'Close'))
    t = df['t']
    hr = t.dt.tz_convert('America/New_York').dt.hour.values
    day = session_day(t).values
    g = df.assign(d=day).groupby('d').agg(H=('High', 'max'), L=('Low', 'min'))
    prev = g.shift()
    kH, kL = prev['H'].reindex(day).values, prev['L'].reindex(day).values
    pc = np.r_[np.nan, c[:-1]]
    tr = np.nanmax(np.c_[h - l, np.abs(h - pc), np.abs(l - pc)], axis=1)
    atr = pd.Series(tr).ewm(alpha=1 / ATR_LEN, adjust=False, min_periods=ATR_LEN).mean().values
    lo3 = pd.Series(l).rolling(LOOK).min().values
    hi3 = pd.Series(h).rolling(LOOK).max().values
    out, done, i, n = [], set(), LOOK, len(c)
    while i < n - 1:
        if hr[i] not in HOURS or day[i] in done or np.isnan(kL[i]) or np.isnan(atr[i]):
            i += 1
            continue
        a = atr[i]
        if lo3[i] <= kL[i] - BRK * a and c[i] > kL[i]:
            d, sl = 1, lo3[i] - SL_BUF * a
        elif hi3[i] >= kH[i] + BRK * a and c[i] < kH[i]:
            d, sl = -1, hi3[i] + SL_BUF * a
        else:
            i += 1
            continue
        done.add(day[i])
        j = i + 1
        e = o[j]
        risk = d * (e - sl)
        if risk <= 0:            # gap stop ke paar khula: trade nahi
            i = j
            continue
        tp = e + d * TP_R * risk
        x = None
        while j < n:
            if day[j] != day[i] or hr[j] >= 16:
                x = o[j]
                break
            if d > 0:
                if o[j] <= sl or l[j] <= sl:
                    x = min(o[j], sl)
                elif o[j] >= tp or h[j] >= tp:
                    x = max(o[j], tp)
            else:
                if o[j] >= sl or h[j] >= sl:
                    x = max(o[j], sl)
                elif o[j] <= tp or l[j] <= tp:
                    x = min(o[j], tp)
            if x is not None:
                break
            j += 1
        if x is None:
            x = c[n - 1]
        k = COST * (e + x) if cost_on else 0.0
        out.append((t.iloc[i + 1], d, (d * (x - e) - k) / risk))
        i = j
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
    print(f'   market musbat {(mk > 0).sum()}/2, (market x saal) musbat {(cells > 0).sum()}/{len(cells)}')
    if a.imtihan:
        ok = n >= 30 and ex - 2 * se > 0
    else:
        ok = n >= 100 and ex - 2 * se > 0 and (mk > 0).sum() == 2 and (cells > 0).mean() > 0.5
    print('PASS' if ok else 'FAIL')


if __name__ == '__main__':
    main()
