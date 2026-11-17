#!/usr/bin/env python3
"""64vi (17 Nov 2026) - K15: Andrea Cimi setup 2 = 15-min ORB, US500 + USTEC M1 2012-26 (footprint / bubbles CFD mein NAHI).
Qaide pehle se: range = 9:30-9:45 ET high/low. 9:45-12:00 mein pehli 1-min close range ke bahar = us taraf trade
agli candle open par. SL: S1 = range ka doosra kinara; S2 = range ka beech (POC ki jagah). Exit: 2R ya 16:00. Din mein 1.
Kharcha 0.01% har taraf. Pehle: gold 15m ORB FAIL (11 Oct), USTEC 5m ORB #21 FAIL.
  python3 tools/k15_orb15_index_test.py
"""
import sys
from pathlib import Path

import numpy as np

sys.path.insert(0, str(Path(__file__).resolve().parent))
from k14_morning_top_test import COST, days, load, stat  # noqa: E402


def trade(x, slmode):
    m = x['t'].dt.hour.values * 60 + x['t'].dt.minute.values
    o, h, l, c = (x[k].values for k in ('Open', 'High', 'Low', 'Close'))
    rng = m < 585
    if rng.sum() < 10:
        return None
    hi, lo = h[rng].max(), l[rng].min()
    for i in np.where((m >= 585) & (m < 720))[0]:
        side = 1 if c[i] > hi else (-1 if c[i] < lo else 0)
        if side == 0 or i + 1 >= len(x):
            continue
        ep = o[i + 1]
        sl = (lo if side > 0 else hi) if slmode == 1 else (hi + lo) / 2
        r = side * (ep - sl)
        if r <= 0:
            return None
        tp, xp = ep + side * 2 * r, c[-1]
        for j in range(i + 1, len(x)):
            if (l[j] <= sl) if side > 0 else (h[j] >= sl):
                xp = sl if (side > 0 and o[j] > sl) or (side < 0 and o[j] < sl) else o[j]
                break
            if (h[j] >= tp) if side > 0 else (l[j] <= tp):
                xp = tp if (side > 0 and o[j] < tp) or (side < 0 and o[j] > tp) else o[j]
                break
        return side, (side * (xp - ep) - COST * (ep + xp)) / r
    return None


def main():
    for nm, pref in (('US500', 'USA500IDXUSD'), ('USTEC', 'USATECHIDXUSD')):
        dd = days(load(pref))
        print(f'\n== {nm} | 2012-18 | 2019-26 ==')
        for slm, lab in ((1, 'SL doosra kinara'), (2, 'SL range beech  ')):
            for want, sl in ((0, 'dono'), (1, 'BUY '), (-1, 'SELL')):
                a, b = [], []
                for d, x, pc, d3 in dd:
                    t = trade(x, slm)
                    if t and (want == 0 or t[0] == want):
                        (a if d.year < 2019 else b).append(t[1])
                print(f'  {lab} {sl}: {stat(a)} | {stat(b)}')


if __name__ == '__main__':
    main()
