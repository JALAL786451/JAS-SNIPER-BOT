#!/usr/bin/env python3
"""Koshish #102 (16 Nov 2026) - Connors "Double 7s" NON-US INDEX TOKRI (7 index), sirf BUY, swap 0.
Qaida (badalna mana): docs/purana-haal.md, grep "Koshish #102 qaida". #45 (double7_test.py) ka qaida, naye market.

  python3 tools/double7_102.py             # TALAASH (entry < 2019)
  python3 tools/double7_102.py --imtihan   # 2019+ EK dafa
"""
import argparse

import numpy as np
import pandas as pd

from ftmo_test import atr_rma, session_day
from tokri47 import load_any

MARKETS = ['DEUIDXEUR', 'GBRIDXGBP', 'FRAIDXEUR', 'EUSIDXEUR', 'JPNIDXJPY', 'AUSIDXAUD', 'HKGIDXHKD']
CUT = pd.Timestamp('2019-01-01', tz='UTC')
KCOST = 0.0002          # har taraf (khirki jaisa); swap 0


def daily(df):
    """H1 -> daily (NY 17:00): pehli / aakhri H1 idx, O H L C, din."""
    g = df.assign(sd=session_day(df['t'])).groupby('sd', sort=True)
    last = g.apply(lambda x: x.index[-1], include_groups=False).values
    first = np.r_[0, last[:-1] + 1]
    return (first, last, df['Open'].values[first], g['High'].max().values, g['Low'].min().values,
            g['Close'].last().values, df['t'].values[first])


def d7_trades(df):
    """(entry H1 idx, exit H1 idx, entry, exit, SL doori, 1, entry din idx, din pakra) - FTMO sim wali shakal + 2."""
    first, last, O, H, L, C, T = daily(df)
    sma = pd.Series(C).rolling(200).mean().values
    lo7 = pd.Series(C).rolling(7).min().values
    hi7 = pd.Series(C).rolling(7).max().values
    atr = atr_rma(H, L, C, 14)
    o, lo = df['Open'].values, df['Low'].values
    nd, out, i = len(last), [], 200
    while i < nd - 1:
        if not (C[i] > sma[i] and C[i] <= lo7[i] and atr[i] > 0):
            i += 1
            continue
        e = i + 1
        ep, ru = O[e], 3.0 * atr[i]
        sl = ep - ru
        done = None
        jj = e
        while jj < nd:
            hit = np.nonzero(lo[first[jj]:last[jj] + 1] <= sl)[0]
            if len(hit):
                xi = first[jj] + hit[0]
                done = (xi, min(o[xi], sl), jj - e + 0.5, jj + 1)          # SL wale din nayi nahi
                break
            if C[jj] >= hi7[jj] and jj + 1 < nd:
                done = (first[jj + 1], O[jj + 1], jj + 1 - e, jj + 1)
                break
            jj += 1
        if done is None:
            break                                                          # data khatam, khuli trade nahi gini
        out.append((first[e], done[0], ep, done[1], ru, 1, e, done[2]))
        i = done[3]
    return out, (O, C, sma, T)


def drift_pct(O, C, sma, T, keep):
    """bara wala [aam din % open->open, SMA200-upar din %] - sirf usi daur ke din."""
    ro = O[1:] / O[:-1] - 1.0                       # ro[k]: open[k] -> open[k+1]
    k = np.arange(1, len(O) - 1)
    ok = keep(pd.to_datetime(T[k], utc=True))
    k = k[ok]
    aam = ro[k].mean()
    up = ro[k[C[k - 1] > sma[k - 1]]].mean()
    return max(aam, up), aam, up


def cluster_se(r, wk):
    m, n = r.mean(), len(r)
    s = pd.Series(r - m).groupby(wk).sum().values
    g = len(s)
    return np.sqrt((s ** 2).sum() * g / max(1, g - 1)) / n


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--imtihan', action='store_true')
    im = ap.parse_args().imtihan
    keep = (lambda t: t >= CUT) if im else (lambda t: t < CUT)
    print(f"#102 Double 7s non-US index tokri, swap 0, kharcha 0.02%/taraf - {'IMTIHAN 2019+ (EK dafa)' if im else 'TALAASH entry < 2019'}")
    rows = []
    for s in MARKETS:
        df = load_any(s)
        if not im:
            df = df[df['t'] < CUT + pd.Timedelta(days=60)].reset_index(drop=True)
        tl, (O, C, sma, T) = d7_trades(df)
        dr, aam, up = drift_pct(O, C, sma, T, keep)
        t = df['t'].values
        n0 = len(rows)
        for (ei, xi, e, x, ru, _, _, bars) in tl:
            te = pd.Timestamp(t[ei], tz='UTC')
            if not keep(te):
                continue
            cost = KCOST * (e + x)
            rows.append((s, te, (x - e - cost) / ru, (x - e - cost) / e * 100, (x - e) / ru, bars, dr * bars * 100))
        r = np.array([q[2] for q in rows[n0:]])
        print(f'  {s:10s} {len(r):4d} tr, jeet {np.mean(r > 0) * 100:3.0f}%, Exp {r.mean():+.3f}R | aam din {aam * 100:+.4f}%, SMA200-upar {up * 100:+.4f}%')
    d = pd.DataFrame(rows, columns=['m', 't', 'r', 'pct', 'r0', 'bars', 'drift'])
    iso = d['t'].dt.isocalendar()
    wk = (iso['year'].astype(int) * 100 + iso['week'].astype(int)).values
    n, ex = len(d), d['r'].mean()
    se, sec = d['r'].std(ddof=1) / np.sqrt(n), cluster_se(d['r'].values, wk)
    mk = d.groupby('m')['r'].mean()
    cells = d.groupby(['m', d['t'].dt.year])['r'].sum().values
    yrs = d.groupby(d['t'].dt.year)['r'].sum()
    pct, drift = d['pct'].mean(), d['drift'].mean()
    months = (d['t'].max() - d['t'].min()).days / 30.44
    print(f'KUL {n} tr ({n / months:.1f}/mahina), jeet {np.mean(d["r"] > 0) * 100:.0f}%, Exp {ex:+.4f}R, SE {se:.4f} (cluster {sec:.4f}, {len(set(wk))} hafte), '
          f'Exp-2SE(cluster) {ex - 2 * sec:+.4f}')
    print(f'   bina kharcha {d["r0"].mean():+.4f}R, ausat {d["bars"].mean():.1f} din, kul {d["r"].sum():+.1f}R')
    print(f'   index musbat {(mk > 0).sum()}/{len(mk)}, (market x saal) musbat {(cells > 0).sum()}/{len(cells)}, saal: '
          + ' '.join(f'{y}:{v:+.1f}' for y, v in yrs.items()))
    ratio = pct / drift if drift > 0 else float('inf')
    print(f'   D7 {pct:+.3f}% har trade vs drift {drift:+.3f}% ({ratio:.2f}x; shart >= 2x)')
    base = ex - 2 * sec > 0 and pct >= 2 * drift and pct > 0
    ok = (n >= 30 and base) if im else (n >= 100 and base and (mk > 0).sum() >= 5 and (cells > 0).mean() > 0.5)
    print('PASS' if ok else 'FAIL')


if __name__ == '__main__':
    main()
