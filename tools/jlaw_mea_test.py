#!/usr/bin/env python3
"""Koshish #43 (29 Oct 2026) - J Law "Multiple Edge" (Chart Fanatics): momentum toot + kam volume pullback
toote level aur EMA20 par, sirf BUY. Qaida (badalna mana): docs/purana-haal.md, grep "Koshish #43 qaida".

  python3 tools/jlaw_mea_test.py             # TALAASH (entry < 2019), daily + 4H
  python3 tools/jlaw_mea_test.py --imtihan   # 2019+ EK dafa

Data: data/ftmo/*.zip (Dukascopy H1, UTC, Volume). Kharcha #34 jaisa.
"""
import argparse
import io
import zipfile

import numpy as np
import pandas as pd

from ftmo_test import FILES, ROOT, session_day
from gold_h4_pullback import report

MARKETS = {'XAUUSD': 0.50, 'XAGUSD': 0.0, 'US500': 0.0, 'USTEC': 0.0}
CUT = pd.Timestamp('2019-01-01', tz='UTC')
COST_PCT, SWAP = 0.0003, 0.03 / 365
PIV, WAIT = 3, 15


def load_v(sym):
    zname, key = FILES[sym]
    with zipfile.ZipFile(ROOT / 'data' / 'ftmo' / zname) as z:
        name = next(n for n in z.namelist() if key in n and n.endswith('.csv'))
        df = pd.read_csv(io.BytesIO(z.read(name)), dtype={'Date': str, 'Time': str})
    df['t'] = pd.to_datetime(df['Date'] + df['Time'], format='%Y%m%d%H:%M:%S', utc=True)
    return df[['t', 'Open', 'High', 'Low', 'Close', 'Volume']].sort_values('t').drop_duplicates('t').reset_index(drop=True)


def bars(df, tf):
    day = session_day(df['t'])
    if tf == 'D1':
        key = [day.values]
    else:
        key = [day.values, ((df['t'].dt.tz_convert('America/New_York') + pd.Timedelta(hours=7)).dt.hour // 4).values]
    g = df.groupby(key)
    x = g.agg(t=('t', 'first'), Open=('Open', 'first'), High=('High', 'max'), Low=('Low', 'min'),
              Close=('Close', 'last'), Volume=('Volume', 'sum')).sort_values('t').reset_index(drop=True)
    x['day'] = session_day(x['t']).values
    return x


def trades(x, min_usd, cost_on=True):
    o, h, l, c, v = (x[k].values.astype(float) for k in ('Open', 'High', 'Low', 'Close', 'Volume'))
    n = len(x)
    tr = np.maximum(h - l, np.maximum(abs(h - np.roll(c, 1)), abs(l - np.roll(c, 1))))
    tr[0] = h[0] - l[0]
    atr = pd.Series(tr).ewm(alpha=1 / 14, adjust=False, min_periods=14).mean().values
    sma = pd.Series(c).rolling(20).mean().values
    ema = pd.Series(c).ewm(span=20, adjust=False, min_periods=20).mean().values
    vol20 = pd.Series(v).rolling(20).mean().values            # vol20[k] = k tak; B-1 wala = vol20[B-1]
    piv = np.full(n, np.nan)                                  # piv[k] = k par pakka hua swing high (k-PIV wala)
    for k in range(2 * PIV, n):
        j = k - PIV
        if h[j] == h[j - PIV:j + PIV + 1].max():
            piv[k] = h[j]
    lastL = pd.Series(piv).ffill().values                     # lastL[k] = k tak aakhri pakka swing high

    out, pos, setup = [], 0, None
    day, tt = x['day'].values, x['t'].values
    for i in range(30, n - 1):
        if pos:
            if l[i] <= sl:                                    # SL (gap neeche = open)
                xp, xi = min(o[i], sl) if i > e else sl, i
            elif c[i] < sma[i] - 0.5 * atr[i]:
                xp, xi = o[i + 1], i + 1
            else:
                continue
            cost = 0.0
            if cost_on:
                nights = (pd.Timestamp(day[xi]) - pd.Timestamp(day[e])).days
                cost = max(min_usd, COST_PCT * (ep + xp)) + SWAP * nights * ep
            out.append((pd.Timestamp(tt[e], tz='UTC'), (xp - ep - cost) / ru, xi - e))
            pos, setup = 0, None
            continue
        L = lastL[i - 1]
        # (1) momentum toot
        if (not np.isnan(L) and c[i] > L >= c[i - 1] and c[i] > o[i] and h[i] - l[i] >= 1.5 * atr[i - 1]
                and v[i] >= 1.5 * vol20[i - 1]):
            setup = (i, L, vol20[i - 1])
            continue
        if setup is None:
            continue
        B, LB, vb = setup
        if i - B > WAIT or c[i] < LB - atr[i]:                # (2) intezar khatam / toot fail
            setup = None
            continue
        # (3) pullback: level + EMA20 ek jagah, kam volume
        if (l[i] <= LB + 0.5 * atr[i] and abs(ema[i] - LB) <= atr[i] and c[i] >= LB - 0.5 * atr[i]
                and v[B + 1:i + 1].mean() < vb):
            ep, sl = o[i + 1], min(LB, l[i]) - 0.5 * atr[i]
            setup = None
            if ep <= sl:
                continue
            pos, e, ru = 1, i + 1, ep - sl
            # entry bar par SL bhi usi bar mein dekhna: agla loop i+1 se (i > e shart se open nahi)
    return pd.DataFrame(out, columns=['t', 'r', 'bars'])


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--imtihan', action='store_true')
    a = ap.parse_args()
    print('IMTIHAN 2019+ (EK dafa)' if a.imtihan else 'TALAASH entry < 2019')
    raw = {s: load_v(s) for s in MARKETS}
    for tf in ('D1', 'H4'):
        print(f'\n=== #43{"a" if tf == "D1" else "b"} {tf} ===')
        allt, all0, cells = [], [], []
        for sym, mn in MARKETS.items():
            df = raw[sym]
            if not a.imtihan:
                df = df[df['t'] < CUT + pd.Timedelta(days=30)].reset_index(drop=True)
            x = bars(df, tf)
            keep = (lambda t: t[t['t'] >= CUT]) if a.imtihan else (lambda t: t[t['t'] < CUT])
            t, t0 = keep(trades(x, mn)), keep(trades(x, mn, cost_on=False))
            if len(t) < 2:
                print(f'{sym:7s}: {len(t)} tr')
                continue
            _, _, _, _, yr = report(f'{sym:7s}', t)
            cells += list(yr.values)
            t['m'] = sym
            allt.append(t)
            all0.append(t0)
        t = pd.concat(allt)
        n, ex, se, _, _ = report('KUL    ', t)
        print(f'   bina kharcha {pd.concat(all0)["r"].mean():+.4f}R, ausat {t["bars"].mean():.1f} bar, '
              f'{n / max(1, t["t"].dt.tz_localize(None).dt.to_period("M").nunique()):.1f} tr/mahina (jin mahinon mein trade)')
        mk = t.groupby('m')['r'].mean()
        cells = np.array(cells)
        print(f'   market musbat {(mk > 0).sum()}/4, (market x saal) musbat {(cells > 0).sum()}/{len(cells)}')
        if a.imtihan:
            ok = n >= 30 and ex > 0
        else:
            ok = n >= 100 and ex - 2 * se > 0 and (mk > 0).sum() >= 3 and (cells > 0).mean() > 0.5
        print('PASS' if ok else 'FAIL')


if __name__ == '__main__':
    main()
