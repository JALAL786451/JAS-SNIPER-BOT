#!/usr/bin/env python3
"""62vi (17 Nov 2026) - TEST #2: Rehnuma r2 poore account par (gold H1 2003-26, kharcha + swap).
4H BUY (r1 / t5, SL 6 ATR) @ 0.75% + chhota 1H BUY idea (4H upar, SL 3 ATR) @ 0.25% - dono ek saath khul sakte hain.
Faida / nuqsan % shuru ke balance par (compounding nahi), trade band hone ke din. Phir 1H idea ka SL 2 / 3 / 4 ATR
SIRF mazbooti dekhne ke liye (3 hi rahega - chunao NAHI).

  python3 tools/rehnuma_r2_jor.py
"""
import sys
from pathlib import Path

import numpy as np
import pandas as pd

sys.path.insert(0, str(Path(__file__).resolve().parent))
from ftmo_test import load, session_day, supertrend_up  # noqa: E402
import rehnuma_r2_test as r2  # noqa: E402


def frames():
    h1 = load('XAUUSD')
    day = session_day(h1['t'])
    blk = ((h1['t'].dt.tz_convert('America/New_York') + pd.Timedelta(hours=7)).dt.hour // 4).values
    key = pd.Series(list(zip(day.values, blk)))
    gid = (key != key.shift()).cumsum().values - 1
    h4 = h1.groupby(gid).agg(t=('t', 'first'), Open=('Open', 'first'), High=('High', 'max'), Low=('Low', 'min'),
                             Close=('Close', 'last')).reset_index(drop=True)
    up4, _ = supertrend_up(h4['High'].values, h4['Low'].values, h4['Close'].values)
    last = np.r_[gid[1:] != gid[:-1], True]
    k = np.where(last, gid, gid - 1)
    g_up = np.where(k >= 0, up4[np.maximum(k, 0)], False)
    return h1, h4, g_up


def main():
    h1, h4, g_up = frames()
    a = r2.run(h4, +1, 6.0).assign(pct=lambda x: x['R'] * 0.75)
    b = r2.run(h1, +1, 3.0, g_up).assign(pct=lambda x: x['R'] * 0.25)
    for nm, lo, hi in (('2003-2018', '2003', '2019'), ('2019-2026', '2019', '2027')):
        print(f'\n== {nm}: % saal ba saal (4H 0.75% | 1H 0.25% | dono) ==')
        rows = []
        for t in (a, b):
            tt = t.assign(t=t['t'].dt.tz_localize(None))
            rows.append(tt[(tt['t'] >= lo) & (tt['t'] < hi)])
        both = pd.concat(rows).sort_values('t')
        for y in sorted(both['t'].dt.year.unique()):
            ya, yb = (r[r['t'].dt.year == y]['pct'].sum() for r in rows)
            print(f'  {y}: {ya:+6.2f}% | {yb:+6.2f}% | {ya + yb:+6.2f}%')
        for lab, t in (('4H akela', rows[0]), ('1H akela', rows[1]), ('DONO', both)):
            cum = t['pct'].cumsum().values
            dd = float(np.max(np.maximum.accumulate(np.r_[0, cum])[1:] - cum)) if len(cum) else 0
            mon = t.groupby(t['t'].dt.to_period('M'))['pct'].sum()
            print(f'  {lab:8s}: kul {cum[-1]:+6.1f}% | girawat {dd:4.1f}% | bura mahina {mon.min():+5.2f}% | '
                  f'mahine plus {100 * (mon > 0).mean():.0f}%')
    print('\n== 1H idea ka SL (sirf mazbooti; 3 hi rahega) - R har trade ==')
    for sl in (2.0, 3.0, 4.0):
        t = r2.run(h1, +1, sl, g_up)
        tt = t.assign(t=t['t'].dt.tz_localize(None))
        x, y = tt[tt['t'] < '2019']['R'], tt[tt['t'] >= '2019']['R']
        print(f'  SL {sl:.0f} ATR: 2003-18 {len(x)} tr {x.mean():+.3f}R | 2019-26 {len(y)} tr {y.mean():+.3f}R')


if __name__ == '__main__':
    main()
