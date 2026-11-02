#!/usr/bin/env python3
"""Koshish #80 (2 Nov 2026) - gold Asia M5 Bollinger fade, BINA martingale. TALAASH 2009-2018 (2015 bahar).
Qaida (badalna mana): docs/purana-haal.md, grep "Koshish #80 qaida".
Data: data/histdata/XAUUSD_M1_<saal>_NY.zip (New York waqt -> UTC).

  python3 tools/k80_asia_bb.py
"""
import zipfile
from pathlib import Path

import numpy as np
import pandas as pd

ROOT = Path(__file__).resolve().parent.parent
SLP = 0.0025                      # TP = SL = 0.25%
COSTS = (0.00006, 0.00012)        # round trip: maloomat, FAISLA


def load():
    out = []
    for y in range(2009, 2019):
        z = zipfile.ZipFile(ROOT / f'data/histdata/XAUUSD_M1_{y}_NY.zip')
        nm = [n for n in z.namelist() if n.endswith('.csv')][0]
        d = pd.read_csv(z.open(nm), sep=';', header=None, names=['dt', 'O', 'H', 'L', 'C', 'V'])
        t = pd.to_datetime(d['dt'], format='%Y%m%d %H%M%S')
        d['t'] = t.dt.tz_localize('America/New_York', ambiguous='NaT', nonexistent='NaT').dt.tz_convert('UTC')
        out.append(d.dropna(subset=['t'])[['t', 'O', 'H', 'L', 'C']])
    m1 = pd.concat(out).drop_duplicates('t').sort_values('t').reset_index(drop=True)
    return m1


def trades(m1):
    s = m1.set_index('t')
    m5 = pd.DataFrame({'O': s.O.resample('5min').first(), 'H': s.H.resample('5min').max(),
                       'L': s.L.resample('5min').min(), 'C': s.C.resample('5min').last()}).dropna()
    mid = m5.C.rolling(20).mean()
    sd = m5.C.rolling(20).std(ddof=0)
    up, lo = mid + 2 * sd, mid - 2 * sd
    sig = np.where(m5.C > up, -1, np.where(m5.C < lo, 1, 0))
    t5 = m5.index.values
    o5 = m5.O.values
    tm = m1.t.values.astype('datetime64[ns]')
    H, L, O = m1.H.values, m1.L.values, m1.O.values
    res = []
    free_at = np.datetime64('1970-01-01', 'ns')
    for j in range(20, len(m5) - 1):
        d = sig[j]
        if d == 0:
            continue
        te = t5[j + 1]
        hr = pd.Timestamp(te).hour
        if hr > 5 or te < free_at:
            continue
        e = o5[j + 1]
        tp, sl = e * (1 + d * SLP), e * (1 - d * SLP)
        t_end = pd.Timestamp(te).normalize() + pd.Timedelta(hours=7)
        i0 = np.searchsorted(tm, te)
        i1 = np.searchsorted(tm, t_end.to_datetime64())
        hh, ll = H[i0:i1], L[i0:i1]
        hit_sl = (ll <= sl) if d > 0 else (hh >= sl)
        hit_tp = (hh >= tp) if d > 0 else (ll <= tp)
        a = np.argmax(hit_sl) if hit_sl.any() else 10 ** 9
        b = np.argmax(hit_tp) if hit_tp.any() else 10 ** 9
        if a == b == 10 ** 9:
            if i1 >= len(O):
                continue
            x, ix = O[i1], i1                         # 07:00 UTC ki open
        elif a <= b:
            x, ix = sl, i0 + a
        else:
            x, ix = tp, i0 + b
        res.append((pd.Timestamp(te), d, e, x))
        free_at = tm[min(ix, len(tm) - 1)] + np.timedelta64(1, 'm')
    df = pd.DataFrame(res, columns=['t', 'd', 'e', 'x'])
    df['g'] = df.d * (df.x - df.e) / (SLP * df.e)          # R kharche se pehle
    return df


def stats(r):
    n = len(r)
    return n, r.mean(), r.std(ddof=1) / np.sqrt(n), (r > 0).mean()


def main():
    m1 = load()
    print(f'M1 {len(m1)} candle {m1.t.iloc[0]} .. {m1.t.iloc[-1]}')
    df = trades(m1)
    df['y'] = df.t.dt.year
    for c in COSTS:
        df['r'] = df.g - c / SLP
        k = df[df.y != 2015]
        n, ex, se, w = stats(k.r)
        print(f'\nkharcha {c * 100:.3f}% | 2015 bahar: {n} tr, jeet {w:.1%}, Exp {ex:+.3f}R, SE {se:.3f}, Exp-2SE {ex - 2 * se:+.3f}')
        yr = df.groupby('y').r.agg(['count', 'mean'])
        print('saal: ' + ' | '.join(f'{y} {int(r["count"])} {r["mean"]:+.3f}' for y, r in yr.iterrows()))
        h1 = k[k.y <= 2013].r.mean()
        h2 = k[k.y >= 2014].r.mean()
        ys = yr.drop(2015)['mean']
        print(f'aadhe: 2009-13 {h1:+.3f}, 2014-18 {h2:+.3f} | musbat saal {(ys > 0).sum()}/{len(ys)}')
        if c == COSTS[-1]:
            ok = ex - 2 * se > 0 and h1 > 0 and h2 > 0 and (ys > 0).mean() >= 0.6
            print('\nTALAASH: ' + ('PASS' if ok else 'FAIL') + ' (0.012% par: Exp-2SE>0, dono aadhe musbat, >=60% saal)')
    print(f'trades/din ~{len(df) / df.t.dt.date.nunique():.2f} (sirf trade wale din), kharche se pehle Exp {df.g.mean():+.3f}R')


if __name__ == '__main__':
    main()
