#!/usr/bin/env python3
"""Koshish #40 (29 Oct 2026) - VWAP trend (session VWAP cross), H1 TOKRI.

Qaida (badalna mana): docs/purana-haal.md, grep "Koshish #40 qaida".
Data: data/ftmo/*.zip (Dukascopy H1, UTC -> NY).

  python3 tools/vwap_trend_test.py             # TALAASH (entry < 2019)
  python3 tools/vwap_trend_test.py --imtihan   # 2019+ EK dafa
"""
import argparse

import numpy as np
import pandas as pd

import io
import zipfile

from ftmo_test import COST, FILES, ROOT, session_day
from gold_h4_pullback import report

MARKETS = ['XAUUSD', 'US500', 'USTEC']
CUT = pd.Timestamp('2019-01-01', tz='UTC')
ATR_LEN, SL_ATR, LAST_ENTRY_HR, FLAT_HR = 14, 1.0, 15, 16


def load(sym):
    """ftmo_test.load jaisa, bas Volume column ke saath."""
    zname, key = FILES[sym]
    with zipfile.ZipFile(ROOT / 'data' / 'ftmo' / zname) as z:
        name = next(n for n in z.namelist() if key in n and n.endswith('.csv'))
        df = pd.read_csv(io.BytesIO(z.read(name)), dtype={'Date': str, 'Time': str})
    df['t'] = pd.to_datetime(df['Date'] + df['Time'], format='%Y%m%d%H:%M:%S', utc=True)
    return df[['t', 'Open', 'High', 'Low', 'Close', 'Volume']].sort_values('t').drop_duplicates('t').reset_index(drop=True)


def trades(df, cost_on=True):
    o, h, l, c = (df[k].values for k in ('Open', 'High', 'Low', 'Close'))
    v = df['Volume'].values.astype(float)
    v = np.where(v <= 0, 1.0, v)
    t = df['t']
    hr = t.dt.tz_convert('America/New_York').dt.hour.values
    day = session_day(t).values
    tp = (h + l + c) / 3
    vwap = np.full(len(c), np.nan)
    cum_pv = cum_v = 0.0
    for i in range(len(c)):
        if i == 0 or day[i] != day[i - 1]:
            cum_pv = cum_v = 0.0
        cum_pv += tp[i] * v[i]
        cum_v += v[i]
        vwap[i] = cum_pv / cum_v
    pc = np.r_[np.nan, c[:-1]]
    tr = np.nanmax(np.c_[h - l, np.abs(h - pc), np.abs(l - pc)], axis=1)
    atr = pd.Series(tr).ewm(alpha=1 / ATR_LEN, adjust=False, min_periods=ATR_LEN).mean().values
    vp = np.r_[np.nan, vwap[:-1]]
    up = (pc <= vp) & (c > vwap)          # pichhli candle VWAP ke neeche/upar, ab cross
    dn = (pc >= vp) & (c < vwap)
    out, pos = [], None                    # (dir, entry, sl, risk, i entry bar-1)

    def close(i, x):
        d, e, _, risk, i0 = pos
        k = COST * (e + x) if cost_on else 0.0
        out.append((t.iloc[i0 + 1], d, (d * (x - e) - k) / risk))

    for i in range(1, len(c) - 1):
        if pos is not None:
            d, e, sl, risk, i0 = pos
            x = None
            if day[i] != day[i0] or hr[i] >= FLAT_HR:
                x = o[i]
            elif d > 0 and (o[i] <= sl or l[i] <= sl):
                x = min(o[i], sl)
            elif d < 0 and (o[i] >= sl or h[i] >= sl):
                x = max(o[i], sl)
            elif d > 0 and c[i] < vwap[i]:
                x = o[i + 1]
            elif d < 0 and c[i] > vwap[i]:
                x = o[i + 1]
            if x is not None:
                close(i, x)
                pos = None
        if pos is None and hr[i] < LAST_ENTRY_HR and not np.isnan(atr[i]) and day[i] == day[i + 1]:
            if up[i] and vwap[i] > vwap[i - 1]:
                e = o[i + 1]
                pos = (1, e, e - SL_ATR * atr[i], atr[i], i)
            elif dn[i] and vwap[i] < vwap[i - 1]:
                e = o[i + 1]
                pos = (-1, e, e + SL_ATR * atr[i], atr[i], i)
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
        _, _, _, _, yr = report(f'{sym:7s}', t)
        print(f'   BUY {t[t.d > 0].r.mean():+.4f}R  SELL {t[t.d < 0].r.mean():+.4f}R  bina kharcha {t0.r.mean():+.4f}R  '
              f'tr/mahina {len(t) / max(1, t.t.dt.strftime("%Y%m").nunique()):.1f}')
        cells += list(yr.values)
        t['m'] = sym
        allt.append(t)
        all0.append(t0)
    t = pd.concat(allt)
    n, ex, se, _, _ = report('KUL    ', t)
    print(f'   bina kharcha {pd.concat(all0)["r"].mean():+.4f}R')
    mk = t.groupby('m')['r'].mean()
    cells = np.array(cells)
    print(f'   market musbat {(mk > 0).sum()}/{len(MARKETS)}, (market x saal) musbat {(cells > 0).sum()}/{len(cells)}')
    if a.imtihan:
        ok = n >= 30 and ex - 2 * se > 0
    else:
        ok = n >= 100 and ex - 2 * se > 0 and (mk > 0).sum() >= 2 and (cells > 0).mean() > 0.5
    print('PASS' if ok else 'FAIL')


if __name__ == '__main__':
    main()
