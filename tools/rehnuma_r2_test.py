#!/usr/bin/env python3
"""62vi (16 Nov 2026) - Rehnuma r2 ke 'idea' ka naap (gold H1 2003-26, Dukascopy).

User: "sale ka idea + chhoti TF par buy ka idea". Qaida PEHLE likha, ek hi variant (tuning nahi):
  A) 4H SELL  : Supertrend(10,3) 4H neeche palta -> agli open SELL, SL = entry + 6 ATR, upar palte par band.
  B) 1H BUY   : 1H Supertrend upar palta JAB aakhri band 4H candle ka rukh upar -> agli open BUY,
                SL = entry - 3 ATR(1H), 1H neeche palte par band.
  C) 1H BUY bina 4H shart (muqabla).   D) 1H SELL jab 4H neeche (B ka ulta).
Kharcha 0.03% har taraf; swap BUY par 3%/saal, SELL par 0 (SELL ke haq mein narmi).

  python3 tools/rehnuma_r2_test.py
"""
import sys
from pathlib import Path

import numpy as np
import pandas as pd

sys.path.insert(0, str(Path(__file__).resolve().parent))
from ftmo_test import load, session_day, supertrend_up  # noqa: E402

COST, SWAP = 0.0003, 0.03 / 365


def run(x, side, slm, gate=None):
    """side +1 BUY / -1 SELL. gate[i] True = is candle ke band hone par ijazat."""
    o, h, l, c = (x[k].values for k in ('Open', 'High', 'Low', 'Close'))
    up, atr = supertrend_up(h, l, c)
    sd = session_day(x['t']).values
    out, i, n = [], 31, len(x)
    while i < n - 1:
        flip = (up[i] and not up[i - 1]) if side > 0 else (not up[i] and up[i - 1])
        if flip and (gate is None or gate[i]) and atr[i] > 0:
            e, ep, r = i + 1, o[i + 1], slm * atr[i]
            sl = ep - side * r
            j, xp, why = e, None, ''
            while j < n:
                hit = l[j] <= sl if side > 0 else h[j] >= sl
                if hit:
                    xp, why = (min(o[j], sl) if side > 0 else max(o[j], sl)), 'SL'
                    break
                back = (not up[j]) if side > 0 else up[j]
                if back and j + 1 < n:
                    xp, why = o[j + 1], 'ST'
                    j += 1
                    break
                j += 1
            if xp is None:
                break
            nights = int((sd[min(j, n - 1)] - sd[e]) / np.timedelta64(1, 'D'))
            pnl = side * (xp - ep) - COST * (ep + xp) - (SWAP * ep * max(nights, 0) if side > 0 else 0)
            out.append((x['t'].iloc[e], pnl / r, why))
            i = j
            continue
        i += 1
    return pd.DataFrame(out, columns=['t', 'R', 'why'])


def stats(t, a, b):
    t = t[(t['t'] >= a) & (t['t'] < b)]
    if len(t) == 0:
        return '0 tr'
    cum = t['R'].cumsum().values
    dd = float(np.max(np.maximum.accumulate(np.r_[0, cum])[1:] - cum))
    se = t['R'].std() / np.sqrt(len(t))
    return (f"{len(t):5d} tr | jeet {100 * (t['R'] > 0).mean():4.1f}% | {t['R'].mean():+.3f}R (-2SE {t['R'].mean() - 2 * se:+.3f}) | "
            f"kul {t['R'].sum():+7.1f}R | girawat {dd:5.1f}R")


def main():
    h1 = load('XAUUSD')
    day = session_day(h1['t'])
    blk = ((h1['t'].dt.tz_convert('America/New_York') + pd.Timedelta(hours=7)).dt.hour // 4).values
    key = pd.Series(list(zip(day.values, blk)))
    gid = (key != key.shift()).cumsum().values - 1          # har H1 candle ka 4H block number
    g = h1.groupby(gid)
    h4 = g.agg(t=('t', 'first'), Open=('Open', 'first'), High=('High', 'max'), Low=('Low', 'min'),
               Close=('Close', 'last')).reset_index(drop=True)
    up4, _ = supertrend_up(h4['High'].values, h4['Low'].values, h4['Close'].values)
    last = np.r_[gid[1:] != gid[:-1], True]                  # block ki aakhri H1 candle
    k = np.where(last, gid, gid - 1)                         # aakhri BAND 4H candle
    g_up = np.where(k >= 0, up4[np.maximum(k, 0)], False)
    res = {
        'A) 4H SELL (SL 6 ATR)': run(h4, -1, 6.0),
        '   4H BUY = r1 / t5 (muqabla)': run(h4, +1, 6.0),
        'B) 1H BUY jab 4H upar (SL 3 ATR)': run(h1, +1, 3.0, g_up),
        'C) 1H BUY bina shart': run(h1, +1, 3.0),
        'D) 1H SELL jab 4H neeche': run(h1, -1, 3.0, ~g_up),
    }
    for nm, a, b in [('2003-2018 (CHUNAO)', '2003', '2019'), ('2019-2026 (IMTIHAN)', '2019', '2027'), ('2023-2026', '2023', '2027')]:
        print(f'\n== {nm} ==')
        for kk, t in res.items():
            tt = t.assign(t=t['t'].dt.tz_localize(None))
            print(f'  {kk:34s} {stats(tt, pd.Timestamp(a), pd.Timestamp(b))}')


if __name__ == '__main__':
    main()
