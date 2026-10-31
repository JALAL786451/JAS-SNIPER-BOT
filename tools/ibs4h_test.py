#!/usr/bin/env python3
"""Koshish #56 (1 Nov 2026) - IBS #15 (girawat par khareed) bilkul wahi, sirf 4H candle, US500 + USTEC, ASLI kharcha.

Qaida (badalna mana): docs/purana-haal.md, grep "Koshish #56 qaida".
Data: data/ftmo/*.zip (Dukascopy H1, UTC) -> 4H NY 17:00 se jura.

  python3 tools/ibs4h_test.py             # TALAASH (entry < 2019)
  python3 tools/ibs4h_test.py --imtihan   # 2019+ EK dafa

IBS < 0.2 + close > SMA200 (4H) = BUY close par; band IBS > 0.8 ya 5 candle; SL 3 x ATR14 (4H) = 1R.
"""
import argparse

import numpy as np
import pandas as pd

from ftmo_test import atr_rma, load, session_day
from gold_h4_pullback import report

MARKETS = {'US500': 0.75 * 0.0052e-2, 'USTEC': 0.75 * 0.0038e-2}
SWAP = 0.03 / 365
CUT = pd.Timestamp('2019-01-01', tz='UTC')


def ibs4h_trades(df, cost_pct, cost_on=True):
    df = df.reset_index(drop=True)
    sd = session_day(df['t']).values
    blk = ((df['t'].dt.tz_convert('America/New_York') + pd.Timedelta(hours=7)).dt.hour // 4).values
    key = pd.Series(pd.to_datetime(sd)).dt.strftime('%Y%m%d').astype(int).values * 10 + blk
    chg = np.r_[True, key[1:] != key[:-1]]
    gid = np.cumsum(chg) - 1
    g = pd.DataFrame({'g': gid, 'i': np.arange(len(df)), 'H': df['High'].values, 'L': df['Low'].values,
                      'C': df['Close'].values}).groupby('g', sort=True)
    last = g['i'].last().values
    h, l, c = g['H'].max().values, g['L'].min().values, g['C'].last().values
    a = atr_rma(h, l, c, 14)
    sma = pd.Series(c).rolling(200).mean().values
    ibs = np.where(h > l, (c - l) / np.where(h > l, h - l, 1), np.nan)
    o, lo, tt = df['Open'].values, df['Low'].values, df['t'].values
    nb, out, j = len(last), [], 0
    while j < nb - 1:
        if not (not np.isnan(sma[j]) and a[j] > 0 and ibs[j] < 0.2 and c[j] > sma[j]):
            j += 1
            continue
        e, r = c[j], 3.0 * a[j]
        sl = e - r
        ex_i = ex_p = None
        jj = j + 1
        while jj < nb:
            a0, b0 = last[jj - 1] + 1, last[jj] + 1
            hit = np.nonzero(lo[a0:b0] <= sl)[0]
            if len(hit):
                ex_i = a0 + hit[0]
                ex_p = min(o[ex_i], sl)
                break
            if ibs[jj] > 0.8 or jj - j >= 5:
                ex_i, ex_p = last[jj], c[jj]
                break
            jj += 1
        if ex_i is None:
            break
        cost = 0.0
        if cost_on:
            nights = (pd.Timestamp(sd[ex_i]) - pd.Timestamp(sd[last[j]])).days
            cost = cost_pct * (e + ex_p) + SWAP * nights * e
        out.append((pd.Timestamp(tt[last[j]], tz='UTC'), 1, (ex_p - e - cost) / r, jj - j))
        j = jj + 1
    return pd.DataFrame(out, columns=['t', 'side', 'r', 'bars'])


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--imtihan', action='store_true')
    a = ap.parse_args()
    print('IMTIHAN 2019+ (EK dafa)' if a.imtihan else 'TALAASH entry < 2019')
    allt, all0, cells = [], [], []
    for sym, cp in MARKETS.items():
        df = load(sym)
        if not a.imtihan:
            df = df[df['t'] < CUT + pd.Timedelta(days=3)].reset_index(drop=True)
        keep = (lambda t: t[t['t'] >= CUT]) if a.imtihan else (lambda t: t[t['t'] < CUT])
        t, t0 = keep(ibs4h_trades(df, cp)), keep(ibs4h_trades(df, cp, cost_on=False))
        _, _, _, _, yr = report(f'{sym:7s}', t)
        cells += list(yr.values)
        t['m'] = sym
        allt.append(t)
        all0.append(t0)
    t = pd.concat(allt)
    n, ex, se, _, _ = report('KUL    ', t)
    t0 = pd.concat(all0)
    mon = t['t'].dt.tz_localize(None).dt.to_period('M').nunique()
    print(f'   bina kharcha {t0["r"].mean():+.4f}R, ~{n / max(1, mon):.1f} tr/mahina (dono), ausat {t["bars"].mean():.1f} candle')
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
