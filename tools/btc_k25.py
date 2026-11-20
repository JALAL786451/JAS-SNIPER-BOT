#!/usr/bin/env python3
"""K25 (21 Nov 2026, 73vi) - BTC script ka qaida chunne ka test. Qaida: docs/research/btc-k25-qaida.md (test se PEHLE likha).

  cd tools && python3 btc_k25.py          # TALAASH 2015-2018 + IMTIHAN 2019-2026 sab umeedwar
"""
import numpy as np
import pandas as pd

from ftmo76 import load_btc
from ftmo_test import atr_rma, session_day, supertrend_up

COST = 0.05e-2
SWAPS = {'swap20': 0.20 / 365, 'swap0': 0.0}


def daily_utc(df):
    """H1 / daily -> din 00:00 UTC (7 din). Har din ki aakhri bar idx, H, L, C."""
    g = df.assign(sd=df['t'].dt.floor('D')).groupby('sd', sort=True)
    last = g.apply(lambda x: x.index[-1], include_groups=False).values
    return last, g['High'].max().values, g['Low'].min().values, g['Close'].last().values


def daily_ny(df):
    g = df.assign(sd=session_day(df['t'])).groupby('sd', sort=True)
    last = g.apply(lambda x: x.index[-1], include_groups=False).values
    return last, g['High'].max().values, g['Low'].min().values, g['Close'].last().values


def turtle(df, D, ent, ext, use_ema):
    """Kachhua / Turtle (kachhua_trades jaisa, sirf ent / ext / EMA rok badle)."""
    last, h, l, c = D
    a = atr_rma(h, l, c, 14)
    ef = pd.Series(c).ewm(span=50, adjust=False).mean().values
    es = pd.Series(c).ewm(span=200, adjust=False).mean().values
    sh, sl_ = pd.Series(h).shift(1), pd.Series(l).shift(1)
    hb, lb = sh.rolling(ent).max().values, sl_.rolling(ent).min().values
    hx, lx = sh.rolling(ext).max().values, sl_.rolling(ext).min().values
    o, hi, lo = df['Open'].values, df['High'].values, df['Low'].values
    out, d, e, r, sl, ent_i = [], 0, 0.0, 0.0, 0.0, 0
    for t in range(200, len(last) - 1):
        at_c = False
        if d != 0:
            a0, b0 = last[t - 1] + 1, last[t] + 1
            hit = np.nonzero(lo[a0:b0] <= sl)[0] if d == 1 else np.nonzero(hi[a0:b0] >= sl)[0]
            ex_i = ex_p = None
            if len(hit):
                ex_i = a0 + hit[0]
                ex_p = min(o[ex_i], sl) if d == 1 else max(o[ex_i], sl)
            elif use_ema and ((ef[t - 1] < es[t - 1]) if d == 1 else (ef[t - 1] > es[t - 1])):
                ex_i, ex_p, at_c = last[t] + 1, c[t], True
            else:
                sl = max(sl, lx[t]) if d == 1 else min(sl, hx[t])
                if (c[t] <= sl) if d == 1 else (c[t] >= sl):
                    ex_i, ex_p, at_c = last[t] + 1, c[t], True
            if ex_i is not None:
                out.append((ent_i, min(ex_i, len(o) - 1), e, ex_p, r, d))
                d = 0
        if d == 0 and not at_c and a[t] > 0 and not np.isnan(hb[t]):
            live = a[t] / c[t] * 100 >= 0.25
            up = (ef[t - 1] > es[t - 1]) if use_ema else True
            dn = (ef[t - 1] < es[t - 1]) if use_ema else True
            if c[t] > hb[t] and up and live:
                d = 1
            elif c[t] < lb[t] and dn and live:
                d = -1
            if d:
                e, r, ent_i = c[t], 2.0 * a[t], min(last[t] + 1, len(o) - 1)
                sl = e - d * r
    return out


def supertrend(df, D):
    """1D Supertrend(10,3) (ftmo_test.supertrend_up = TradingView jaisa) hamesha andar: close par mude -> band + ulti trade.
    R = 3 x ATR10 (ST lakeer ki taqreeban doori)."""
    last, h, l, c = D
    up, atr = supertrend_up(h, l, c)
    o = df['Open'].values
    out, d, e, r, ent_i = [], 0, 0.0, 0.0, 0
    for t in range(200, len(last) - 1):
        nd = 1 if up[t] else -1
        if nd != d:
            if d != 0:
                out.append((ent_i, min(last[t] + 1, len(o) - 1), e, c[t], r, d))
            d, e, ent_i, r = nd, c[t], min(last[t] + 1, len(o) - 1), 3.0 * atr[t]
    return out


def stats(df, trades, D, a, b, swap):
    t = df['t'].values
    last, h, l, c = D
    tl = df['t'].values[last]
    R, held, lag, cap = [], [], [], []
    hi, lo = df['High'].values, df['Low'].values
    for ei, xi, e, x, r, d in trades:
        if not (np.datetime64(a) <= t[ei] < np.datetime64(b)):
            continue
        nights = (t[xi] - t[ei]) / np.timedelta64(1, 'D')
        rr = (d * (x - e) - COST * (e + x) - swap * nights * e) / r
        R.append(rr)
        held.append(nights)
        di = np.searchsorted(tl, t[ei]) - 1          # entry wala din
        w = slice(max(0, di - 19), di + 1)
        lag.append((e - l[w].min()) / l[w].min() * 100 if d == 1 else (h[w].max() - e) / h[w].max() * 100)
        mfe = (hi[ei:xi + 1].max() - e) if d == 1 else (e - lo[ei:xi + 1].min())
        if rr > 0 and mfe > 0:
            cap.append(d * (x - e) / mfe * 100)
    R = np.array(R)
    if len(R) == 0:
        return dict(n=0)
    eq = np.cumsum(R)
    dd = (np.maximum.accumulate(np.r_[0, eq])[1:] - eq).max()
    return dict(n=len(R), jeet=(R > 0).mean() * 100, exp=R.mean(), se=R.std(ddof=1) / np.sqrt(len(R)) if len(R) > 1 else 0,
                kul=R.sum(), dd=dd, rdd=R.sum() / dd if dd > 0 else np.inf, din=np.mean(held), bari=R.max(),
                der=np.mean(lag), pakra=np.mean(cap) if cap else np.nan)


def main():
    df = load_btc()
    DU, DN = daily_utc(df), daily_ny(df)
    C = {
        'K0 Kachhua 10/5+EMA': lambda D: turtle(df, D, 10, 5, True),
        'K1 Kachhua 10/5 bina EMA': lambda D: turtle(df, D, 10, 5, False),
        'K2 Turtle 20/10+EMA': lambda D: turtle(df, D, 20, 10, True),
        'K3 Turtle 55/20+EMA': lambda D: turtle(df, D, 55, 20, True),
        'K4 1D Supertrend hamesha': lambda D: supertrend(df, D),
    }
    print(f"data {df['t'].iloc[0]:%Y-%m-%d} .. {df['t'].iloc[-1]:%Y-%m-%d}, din UTC {len(DU[0])}")
    hdr = f"{'umeedwar':28s} {'n':>4s} {'jeet%':>6s} {'Exp R':>7s} {'+-SE':>5s} {'KUL R':>7s} {'DD R':>6s} {'R:DD':>5s} {'din':>5s} {'bari':>5s} {'der%':>5s} {'pakra%':>6s}"
    for part, a, b in [('TALAASH 2015-2018', '2015', '2019'), ('IMTIHAN 2019-2026', '2019', '2027')]:
        for sw in ['swap20', 'swap0']:
            print(f"\n== {part} ({sw}) ==\n{hdr}")
            for k, f in C.items():
                s = stats(df, f(DU), DU, a, b, SWAPS[sw])
                if s['n'] == 0:
                    print(f"{k:28s}    0")
                    continue
                print(f"{k:28s} {s['n']:4d} {s['jeet']:6.0f} {s['exp']:+7.2f} {s['se']:5.2f} {s['kul']:+7.1f} {s['dd']:6.1f} {s['rdd']:5.1f} {s['din']:5.0f} {s['bari']:5.1f} {s['der']:5.1f} {s['pakra']:6.0f}")
    s = stats(df, turtle(df, DN, 10, 5, True), DN, '2019', '2027', SWAPS['swap20'])
    print(f"\n(maloomat) K0 din 17:00 NY 2019+: n {s['n']} Exp {s['exp']:+.2f} KUL {s['kul']:+.1f} DD {s['dd']:.1f}")


if __name__ == '__main__':
    main()
