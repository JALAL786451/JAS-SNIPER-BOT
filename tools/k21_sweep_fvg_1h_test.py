#!/usr/bin/env python3
"""K21 (65vi, 17 Nov 2026) - user ka diya "Gold 1H Sweep + FVG + BreakEven [Non-Repaint]" Pine strategy jyon ka tyon,
gold M1 (QDM UTC) 2019-26 -> 1H.
Qaide (script se): pivot 15/15 = swing; sweep = wick level ke paar + close wapas andar + close EMA200 ki taraf;
FVG (default ON): BUY low > high[2] aur pichhli candle hari (SELL ulta); 07-20 UTC Mon-Fri; SL = wick -/+ 0.5 ATR14,
TP 2.5R; 1R par SL entry + 10 tick (BE). Entry agli candle open (TV default). TV ki tarah exit order entry ke BAAD
wali candle close par lagta (entry candle par SL/TP nahi); BE bhi candle close par, agli candle se.
Ek candle mein SL + TP dono = TV raasta (open high ke qareeb -> pehle high).
Kharcha: script wala ($0.25/oz commission har taraf + 5 tick slippage) aur asli ($0.20/oz spread + $0.05).
  python3 tools/k21_sweep_fvg_1h_test.py
"""
import sys

import numpy as np
import pandas as pd

sys.path.insert(0, __import__('os').path.dirname(__file__))
from k20_smc15_bos_test import load as load15  # noqa: E402


def load():
    x = load15().set_index('t')
    return x.resample('1h').agg({'Open': 'first', 'High': 'max', 'Low': 'min', 'Close': 'last'}).dropna().reset_index()


def pivots(a, L, hi):
    n = len(a)
    out = np.full(n, np.nan)
    for i in range(2 * L, n):
        k = i - L
        left, right = a[k - L:k], a[k + 1:i + 1]
        if hi and a[k] > left.max() and a[k] >= right.max():
            out[i] = a[k]
        if not hi and a[k] < left.min() and a[k] <= right.min():
            out[i] = a[k]
    return out


def run(x, use_fvg=True, use_be=True, cost=0.30, L=15, slb=0.5, rr=2.5, tick=0.01):
    o, h, l, c = (x[k].values for k in ('Open', 'High', 'Low', 'Close'))
    n = len(c)
    ema = pd.Series(c).ewm(span=200, adjust=False).mean().values
    pc = np.r_[c[0], c[:-1]]
    tr = np.maximum(h - l, np.maximum(abs(h - pc), abs(l - pc)))
    atr = pd.Series(tr).ewm(alpha=1 / 14, adjust=False).mean().values
    hr, wd = x['t'].dt.hour.values, x['t'].dt.weekday.values
    ph, pl = pivots(h, L, True), pivots(l, L, False)
    sh = sl_ = np.nan
    hs = ls = False
    pos = 0          # 0, +1, -1
    pend = 0         # entry agli candle open par
    ep = SL = TP = R = np.nan
    act = False      # exit order laga hua?
    be = False
    out, raw = [], [0, 0]
    t0 = None
    for i in range(1, n):
        # --- candle i ke andar: pending entry open par, phir laga hua exit
        if pend:
            pos, ep, act, be, t0 = pend, o[i], False, False, x['t'].iloc[i]
            pend = 0
        if pos and act:
            up_first = abs(o[i] - h[i]) < abs(o[i] - l[i])
            hitsl = (l[i] <= SL) if pos > 0 else (h[i] >= SL)
            hittp = (h[i] >= TP) if pos > 0 else (l[i] <= TP)
            xp = None
            if hitsl and hittp:
                tp_first = up_first if pos > 0 else not up_first
                xp = TP if tp_first else SL
            elif hitsl:
                xp = SL
            elif hittp:
                xp = TP
            if xp is not None:
                if pos > 0 and o[i] < SL and hitsl: xp = o[i]       # gap
                if pos < 0 and o[i] > SL and hitsl: xp = o[i]
                out.append((t0, pos, (pos * (xp - ep) - cost) / R, be))
                pos = 0
        # --- candle close par script
        if i < 2:
            continue
        if not np.isnan(ph[i]):
            sh, hs = ph[i], False
        if not np.isnan(pl[i]):
            sl_, ls = pl[i], False
        bfvg = l[i] > h[i - 2] and c[i - 1] > o[i - 1]
        sfvg = h[i] < l[i - 2] and c[i - 1] < o[i - 1]
        rb = not np.isnan(sl_) and not ls and l[i] < sl_ < c[i] and c[i] > ema[i]
        rs = not np.isnan(sh) and not hs and h[i] > sh > c[i] and c[i] < ema[i]
        raw[0] += rb
        raw[1] += rs
        bull = rb and (bfvg if use_fvg else True)
        bear = rs and (sfvg if use_fvg else True)
        if not np.isnan(sl_) and l[i] < sl_:
            ls = True
        if not np.isnan(sh) and h[i] > sh:
            hs = True
        sess = 7 <= hr[i] < 20 and wd[i] < 5
        if sess and pos == 0 and i < n - 1:
            if bull:
                s = l[i] - atr[i] * slb
                if c[i] - s > 0:
                    SL, R, TP, pend = s, c[i] - s, c[i] + (c[i] - s) * rr, 1
            if bear:   # Pine mein dono ho to doosra entry pehle ko badal deta
                s = h[i] + atr[i] * slb
                if s - c[i] > 0:
                    SL, R, TP, pend = s, s - c[i], c[i] - (s - c[i]) * rr, -1
        if pos > 0:
            if use_be and not be and h[i] >= ep + R:
                SL, be = ep + tick * 10, True
            act = True
        elif pos < 0:
            if use_be and not be and l[i] <= ep - R:
                SL, be = ep - tick * 10, True
            act = True
    return pd.DataFrame(out, columns=['t', 'd', 'R', 'be']), raw


def show(lab, t):
    if not len(t):
        print(f'\n{lab}: 0 trade')
        return
    R = t['R'].values
    se = R.std(ddof=1) / np.sqrt(len(R)) if len(R) > 1 else 0
    cum = R.cumsum()
    dd = float(np.max(np.maximum.accumulate(np.r_[0, cum])[1:] - cum))
    yr = t.groupby(t['t'].dt.year)['R'].sum()
    print(f'\n{lab}: {len(R)} tr, jeet {100 * (R > 0.05).mean():.0f}%, BE {100 * (abs(R) <= 0.05).mean():.0f}%, '
          f'Exp {R.mean():+.3f}R (Exp-2SE {R.mean() - 2 * se:+.3f}), kul {R.sum():+.1f}R, girawat {dd:.1f}R | '
          f'BUY {R[t.d == 1].mean() if (t.d == 1).any() else 0:+.3f} ({(t.d == 1).sum()}) '
          f'SELL {R[t.d == -1].mean() if (t.d == -1).any() else 0:+.3f} ({(t.d == -1).sum()})')
    print('  saal: ' + ' '.join(f'{y}:{v:+.0f}' for y, v in yr.items()))


def main():
    x = load()
    print(f'gold 1H candles {len(x)}, {x["t"].iloc[0]} - {x["t"].iloc[-1]}')
    for fvg in (True, False):
        for be in (True, False):
            for lab, cost in (('script kharcha $0.60/oz', 0.60), ('asli $0.30/oz', 0.30)):
                t, raw = run(x, fvg, be, cost)
                show(f'FVG {"ON" if fvg else "OFF"} BE {"ON" if be else "OFF"} | {lab} | sweep (FVG se pehle) BUY {raw[0]} SELL {raw[1]}', t)


if __name__ == '__main__':
    main()
