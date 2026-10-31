#!/usr/bin/env python3
"""Koshish #51 (31 Oct 2026) - HAR MARKET KA APNA QAIDA: 3 sabit khandaan x 28 market (daily).
Qaida (badalna mana): docs/purana-haal.md, grep "Koshish #51 qaida".

  python3 tools/har_market51.py              # TALAASH (entry < 2019), 84 jor, sakht shart Exp - 3.24 SE
  python3 tools/har_market51.py --imtihan    # 2019+ EK dafa, sirf TALAASH ke bache hue jor

K1 TREND (Supertrend 10/3, SL 4 ATR10) · K2 GIRAWAT (IBS #15, SL 3 ATR14) · K3 TOOT (Turtle 20/10, SL 2 ATR20).
Forex + DOLLARIDX BUY + SELL (aaina), baqi sirf BUY.
"""
import argparse

import numpy as np
import pandas as pd

from ftmo_test import COST, SWAP, atr_rma, session_day, supertrend_up
from tokri47 import BOTH, GROUPS, load_any

CUT = pd.Timestamp('2019-01-01', tz='UTC')
Z_TAL = 3.24


def daily(df):
    day = session_day(df['t']).values
    g = pd.DataFrame({'d': day, 'O': df['Open'].values, 'H': df['High'].values, 'L': df['Low'].values,
                      'C': df['Close'].values, 't': df['t'].values})
    x = g.groupby('d', sort=True).agg(t=('t', 'first'), O=('O', 'first'), H=('H', 'max'), L=('L', 'min'),
                                      C=('C', 'last')).reset_index()
    return x


def k1_trend(x, both):
    o, h, l, c = (x[k].values for k in 'OHLC')
    up, atr = supertrend_up(h, l, c)
    out, pos, j = [], 0, 1
    n = len(x)
    i = 31
    while i < n - 1:
        if pos == 0:
            fu, fd = up[i] and not up[i - 1], (not up[i]) and up[i - 1]
            if fu or (both and fd):
                d = 1 if fu else -1
                e, sd = o[i + 1], 4.0 * atr[i]
                pos, ei, sl = d, i + 1, e - d * sd
            i += 1
            continue
        # khuli trade: is candle (i) par SL?
        if (pos > 0 and l[i] <= sl) or (pos < 0 and h[i] >= sl):
            xp = (min(o[i], sl) if pos > 0 else max(o[i], sl)) if i > ei else sl
            out.append((ei, i, e, xp, sd, pos))
            pos = 0
            i += 1
            continue
        if bool(up[i]) != (pos > 0):
            out.append((ei, i + 1, e, o[i + 1], sd, pos))
            flip_d = pos
            pos = 0
            if both:                                   # ulta flip khud nayi entry
                d = -flip_d
                e, sd = o[i + 1], 4.0 * atr[i]
                pos, ei, sl = d, i + 1, e - d * sd
        i += 1
    return out


def k2_ibs(x, both):
    o, h, l, c = (x[k].values for k in 'OHLC')
    sma = pd.Series(c).rolling(200).mean().values
    atr = atr_rma(h, l, c, 14)
    ibs = np.where(h > l, (c - l) / np.where(h > l, h - l, 1), 0.5)
    out, pos, n = [], 0, len(x)
    for i in range(201, n):
        if pos:
            days = i - ei
            if (pos > 0 and l[i] <= sl) or (pos < 0 and h[i] >= sl):
                out.append((ei, i, e, (min(o[i], sl) if pos > 0 else max(o[i], sl)), sd, pos))
                pos = 0
            elif (pos > 0 and ibs[i] > 0.8) or (pos < 0 and ibs[i] < 0.2) or days >= 5:
                out.append((ei, i, e, c[i], sd, pos))
                pos = 0
            continue
        if np.isnan(sma[i]) or np.isnan(atr[i]) or atr[i] <= 0:
            continue
        if c[i] > sma[i] and ibs[i] < 0.2:
            pos, ei, e, sd = 1, i, c[i], 3.0 * atr[i]
            sl = e - sd
        elif both and c[i] < sma[i] and ibs[i] > 0.8:
            pos, ei, e, sd = -1, i, c[i], 3.0 * atr[i]
            sl = e + sd
    return out


def k3_toot(x, both):
    o, h, l, c = (x[k].values for k in 'OHLC')
    atr = atr_rma(h, l, c, 20)
    hi20 = pd.Series(h).rolling(20).max().shift(1).values
    lo20 = pd.Series(l).rolling(20).min().shift(1).values
    hi10 = pd.Series(h).rolling(10).max().shift(1).values
    lo10 = pd.Series(l).rolling(10).min().shift(1).values
    out, pos, n = [], 0, len(x)
    for i in range(25, n - 1):
        if pos:
            if (pos > 0 and l[i] <= sl) or (pos < 0 and h[i] >= sl):
                xp = (min(o[i], sl) if pos > 0 else max(o[i], sl)) if i > ei else sl
                out.append((ei, i, e, xp, sd, pos))
                pos = 0
                continue
            if (pos > 0 and c[i] < lo10[i]) or (pos < 0 and c[i] > hi10[i]):
                out.append((ei, i + 1, e, o[i + 1], sd, pos))
                pos = 0
            continue
        if np.isnan(atr[i]) or np.isnan(hi20[i]):
            continue
        if c[i] > hi20[i]:
            pos, ei, e, sd = 1, i + 1, o[i + 1], 2.0 * atr[i]
            sl = e - sd
        elif both and c[i] < lo20[i]:
            pos, ei, e, sd = -1, i + 1, o[i + 1], 2.0 * atr[i]
            sl = e + sd
    return out


FAM = {'K1 trend': k1_trend, 'K2 girawat': k2_ibs, 'K3 toot': k3_toot}


def rtab(x, tr):
    t = pd.to_datetime(x['t'].values, utc=True)
    rows = []
    for ei, xi, e, xp, sd, d in tr:
        if xi >= len(x) or sd <= 0:
            continue
        nights = (t[xi] - t[ei]).days
        r = (d * (xp - e) - COST * (e + xp) - SWAP * nights * e) / sd
        rows.append((t[ei], d, r))
    return pd.DataFrame(rows, columns=['t', 'd', 'r'])


def stat(r):
    n = len(r)
    if n < 2:
        return n, 0.0, 9.9
    return n, r.mean(), r.std(ddof=1) / np.sqrt(n)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--imtihan', action='store_true')
    a = ap.parse_args()
    syms = [s for g in GROUPS.values() for s in g]
    res = []
    for s in syms:
        x = daily(load_any(s))
        for fam, fn in FAM.items():
            t = rtab(x, fn(x, s in BOTH))
            tal = t[t.t < CUT]
            n, e, se = stat(tal.r)
            yr = tal.groupby(tal.t.dt.year).r.sum()
            ok = n >= 30 and e - Z_TAL * se > 0 and (yr > 0).mean() > 0.5
            im = t[t.t >= CUT]
            ni, ei_, sei = stat(im.r)
            res.append((s, fam, n, e, e - Z_TAL * se, (yr > 0).sum(), len(yr), ok, ni, ei_, ei_ - 2 * sei))
    df = pd.DataFrame(res, columns=['m', 'k', 'n', 'exp', 'exp_z', 'yp', 'yn', 'ok', 'ni', 'expi', 'expi2'])
    print(f'TALAASH entry < 2019: {len(df)} jor, shart >= 30 tr, Exp - {Z_TAL} SE > 0, saal > 50%')
    for fam in FAM:
        d = df[df.k == fam]
        print(f'\n{fam}:  bache {d.ok.sum()} / {len(d)}   (TALAASH Exp ausat {d.exp.mean():+.3f}R)')
        for _, r in d.sort_values('exp_z', ascending=False).head(6).iterrows():
            print(f'   {r.m:15s} {int(r.n):4d} tr  Exp {r.exp:+.3f}  Exp-3.24SE {r.exp_z:+.3f}  saal {int(r.yp)}/{int(r.yn)}'
                  f'{"  <- BACHA" if r.ok else ""}')
    keep = df[df.ok]
    print(f'\nBACHE HUE JOR: {len(keep)}')
    if a.imtihan:
        print('\nIMTIHAN 2019+ (EK dafa): PASS = >= 15 tr aur Exp - 2SE > 0')
        for _, r in keep.iterrows():
            okI = r.ni >= 15 and r.expi2 > 0
            print(f'   {r.m:15s} {r.k:10s} {int(r.ni):4d} tr  Exp {r.expi:+.3f}  Exp-2SE {r.expi2:+.3f}  {"ASLI PASS" if okI else "FAIL"}')


if __name__ == '__main__':
    main()
