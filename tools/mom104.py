#!/usr/bin/env python3
"""Koshish #104 (16 Nov 2026) - 12-MAHINE MOMENTUM (mahana), Kachhua ke 12 market, swap 0.
Qaida (badalna mana): docs/purana-haal.md, grep "Koshish #104 qaida".

  python3 tools/mom104.py             # TALAASH (entry < 2019)
  python3 tools/mom104.py --imtihan   # 2019+ EK dafa
"""
import argparse

import numpy as np
import pandas as pd

from ftmo99 import SPREAD
from ftmo_test import FILES, atr_rma, load, session_day
from tokri47 import load_any

FX = ('EURUSD', 'GBPUSD', 'USDJPY', 'USDCHF', 'AUDUSD')
CUT = pd.Timestamp('2019-01-01', tz='UTC')
ATR_N, SL_K, LOOK, MIN_DAYS = 20, 3.0, 12, 15


def load_h1(s):
    return load(s) if s in FILES else load_any(s)


def daily(df):
    g = df.assign(sd=session_day(df['t'])).groupby('sd', sort=True)
    last = g.apply(lambda x: x.index[-1], include_groups=False).values
    first = np.r_[0, last[:-1] + 1]
    return first, last, g['High'].max().values, g['Low'].min().values, g['Close'].last().values, pd.DatetimeIndex(g['Close'].last().index)


def mom_trades(df, both):
    """[(entry H1 idx, exit H1 idx, entry, exit, SL doori, rukh, din pakre)] + (O roz, din)."""
    first, last, H, L, C, day = daily(df)
    atr = atr_rma(H, L, C, ATR_N)
    o, hi, lo, cl = (df[k].values for k in ('Open', 'High', 'Low', 'Close'))
    mo = np.asarray(day.year * 12 + day.month - 1)
    cnt = pd.Series(1, index=mo).groupby(level=0).sum()
    m_last = int(mo[-1])                                        # aakhri (adhoora ho sakta) mahina: signal nahi
    bad = [m for m in range(int(mo[0]), m_last) if cnt.get(m, 0) < MIN_DAYS]
    m0 = (max(bad) + 1) if bad else int(mo[0])
    me = {m: int(np.nonzero(mo == m)[0][-1]) for m in range(m0, m_last)}
    out, pos, st = [], 0, None                                  # st = (entry idx, entry, SL doori, SL, entry din)

    def close(xi, xp, xday):
        out.append((st[0], xi, st[1], xp, st[2], pos, xday - st[4]))

    for m in range(m0 + LOOK, m_last):
        t = me[m]
        mom = C[t] / C[me[m - LOOK]] - 1.0
        want = 1 if mom > 0 else (-1 if (mom < 0 and both) else 0)
        a0 = first[t + 1]
        if pos != 0 and want != pos:
            close(a0, o[a0], t + 1)
            pos = 0
        if pos == 0 and want != 0 and atr[t] > 0:
            ru = SL_K * atr[t]
            pos, st = want, (a0, o[a0], ru, o[a0] - want * ru, t + 1)
        if pos != 0:                                            # agle mahine ke aakhir (ya data ke aakhir) tak SL
            b0 = last[me[m + 1]] if m + 1 in me else len(o) - 1
            sl = st[3]
            hit = np.nonzero(lo[a0:b0 + 1] <= sl)[0] if pos > 0 else np.nonzero(hi[a0:b0 + 1] >= sl)[0]
            if len(hit):
                xi = a0 + hit[0]
                close(xi, min(o[xi], sl) if pos > 0 else max(o[xi], sl), np.searchsorted(last, xi) + 0.5)
                pos = 0
    if pos != 0:                                                # data ka aakhir: aakhri close par gini
        close(len(o) - 1, cl[-1], len(last) - 1 + 0.5)
    return out, o[first], day


def cluster_se(r, key):
    m, n = r.mean(), len(r)
    s = pd.Series(r - m).groupby(key).sum().values
    g = len(s)
    return np.sqrt((s ** 2).sum() * g / max(1, g - 1)) / n


def collect():
    rows = []
    for s, sp in SPREAD.items():
        df = load_h1(s)
        tl, O, day = mom_trades(df, s in FX)
        ro = O[1:] / O[:-1] - 1.0
        dts = pd.DatetimeIndex(day[:-1]).tz_localize('UTC')
        drift = {False: ro[dts < CUT].mean() if (dts < CUT).any() else 0.0, True: ro[dts >= CUT].mean()}
        t = df['t'].values
        for (ei, xi, e, x, ru, d, held) in tl:
            te = pd.Timestamp(t[ei], tz='UTC')
            c = 0.75 * sp * (e + x)
            rows.append((s, te, d, (d * (x - e) - c) / ru, d * (x - e) / ru, (d * (x - e) - c) / e * 100, held,
                         drift[te >= CUT] * held * 100, s in FX))
    return pd.DataFrame(rows, columns=['m', 't', 'd', 'r', 'r0', 'pct', 'held', 'drift', 'fx'])


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--imtihan', action='store_true')
    im = ap.parse_args().imtihan
    d = collect()
    d = d[d['t'] >= CUT] if im else d[d['t'] < CUT]
    d = d.reset_index(drop=True)
    print(f"#104 12-mahine momentum (mahana), 12 market, swap 0 - {'IMTIHAN 2019+ (EK dafa)' if im else 'TALAASH entry < 2019'}")
    for s, q in d.groupby('m', sort=False):
        print(f'  {s:12s} {len(q):3d} tr, jeet {np.mean(q["r"] > 0) * 100:3.0f}%, Exp {q["r"].mean():+.3f}R, kul {q["r"].sum():+.1f}R, ausat {q["held"].mean():.0f} din')
    for lab, q in (('sirf-BUY market', d[~d['fx']]), ('forex BUY', d[d['fx'] & (d['d'] > 0)]), ('forex SELL', d[d['fx'] & (d['d'] < 0)])):
        if len(q):
            print(f'  {lab:16s} {len(q):3d} tr, jeet {np.mean(q["r"] > 0) * 100:3.0f}%, Exp {q["r"].mean():+.3f}R')
    key = (d['t'].dt.year * 100 + d['t'].dt.month).values
    n, ex = len(d), d['r'].mean()
    se, sec = d['r'].std(ddof=1) / np.sqrt(n), cluster_se(d['r'].values, key)
    mk = d.groupby('m')['r'].agg(['mean', 'size'])
    mk = mk[mk['size'] >= 5]
    yrs = d.groupby(d['t'].dt.year)['r'].sum()
    b = d[~d['fx']]
    pct, drift = b['pct'].mean(), b['drift'].mean()
    ratio = pct / drift if drift > 0 else float('inf')
    months = max(1.0, (d['t'].max() - d['t'].min()).days / 30.44)
    print(f'KUL {n} tr ({n / months:.1f}/mahina), jeet {np.mean(d["r"] > 0) * 100:.0f}%, Exp {ex:+.4f}R, SE {se:.4f} (cluster {sec:.4f}), '
          f'Exp-2SE(cluster) {ex - 2 * sec:+.4f}')
    print(f'   bina kharcha {d["r0"].mean():+.4f}R, kul {d["r"].sum():+.1f}R, ausat {d["held"].mean():.0f} din pakra')
    print(f'   market musbat {(mk["mean"] > 0).sum()}/{len(mk)} (>= 5 tr), saal musbat {(yrs > 0).sum()}/{len(yrs)}: '
          + ' '.join(f'{y}:{v:+.1f}' for y, v in yrs.items()))
    print(f'   sirf-BUY market: {pct:+.2f}% har trade vs drift {drift:+.2f}% ({ratio:.2f}x; shart >= 2x)')
    base = ex - 2 * sec > 0 and pct > 0 and pct >= 2 * drift
    ok = (n >= 30 and base) if im else (n >= 100 and base and (mk['mean'] > 0).mean() >= 0.6 and (yrs > 0).mean() > 0.5)
    print('PASS' if ok else 'FAIL')


if __name__ == '__main__':
    main()
