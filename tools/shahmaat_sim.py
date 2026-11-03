#!/usr/bin/env python3
"""Koshish #88 (3 Nov 2026) - JasShahmaat recovery: live basket ka NET 4H trend se chalao.

Qaida (badalna mana): docs/purana-haal.md, grep "Koshish #88 qaida".
  python3 tools/shahmaat_sim.py              # TALAASH 2021-2024
  python3 tools/shahmaat_sim.py --imtihan    # 2025+ EK dafa
  python3 tools/shahmaat_sim.py --m71        # #89 m7.1 hedge ladder
"""
import argparse
import sys
from pathlib import Path

import numpy as np
import pandas as pd

sys.path.insert(0, str(Path(__file__).parent))
from ftmo_test import ATR_LEN, load, session_day, supertrend_up  # noqa: E402

P_NOW, EQ0, NET0 = 3934.71, 33_600.0, 0.33
UP_NET, COST_LOT, STOP_GAP = 0.80, 30.0, 40_000.0    # 1 lot x $1 = 100 USC; $400 gap


def h4_trend(df, daily=False):
    """Har H1 bar ke liye: aakhri BAND 4H candle ka supertrend rukh (+1/-1, 0 = abhi nahi)."""
    day = session_day(df['t'])
    blk = ((df['t'].dt.tz_convert('America/New_York') + pd.Timedelta(hours=7)).dt.hour // 4).values
    if daily:
        blk = np.zeros(len(df), dtype=int)
    g = pd.DataFrame({'i': np.arange(len(df)), 'd': day.values, 'b': blk,
                      'H': df['High'].values, 'L': df['Low'].values, 'C': df['Close'].values})
    g = g.groupby(['d', 'b'], sort=True).agg(la=('i', 'last'), H=('H', 'max'), L=('L', 'min'),
                                            C=('C', 'last')).sort_values('la')
    up, _ = supertrend_up(g['H'].values, g['L'].values, g['C'].values)
    sig = np.zeros(len(df))
    lastb = g['la'].values
    for j in range(ATR_LEN * 3, len(g)):
        a = lastb[j] + 1                      # candle band hone ke baad wali H1 se
        b = lastb[j + 1] + 1 if j + 1 < len(g) else len(df)
        sig[a:b] = 1 if up[j] else -1
    return sig


def run(close, sig, i0, i1, down_net):
    """Ek start: (S equity, kuch-na-karo equity, stop out?). Qeemat i0 par P_NOW par scale."""
    px = close[i0:i1] * (P_NOW / close[i0])
    s = sig[i0:i1]
    eq, net, stop = EQ0, NET0, False
    for k in range(1, len(px)):
        eq += net * 100 * (px[k] - px[k - 1])
        if eq <= 0:
            stop = True
            break
        want = UP_NET if s[k] > 0 else (down_net if s[k] < 0 else net)
        cap = eq / STOP_GAP
        want = float(np.clip(want, -cap, cap))
        want = round(want / 0.05) * 0.05      # 0.05 lot qadam
        if abs(want - net) > 1e-9:
            eq -= abs(want - net) * COST_LOT
            net = want
    base = EQ0 + NET0 * 100 * (px[-1] - px[0])
    return eq, base, stop


def run_m71(close, i0, i1, step=10.0, lot=0.05):
    """m7.1: har $10 girawat par 0.05 BUY band, NET 0 tak; wapsi nahi."""
    px = close[i0:i1] * (P_NOW / close[i0])
    eq, net, nxt = EQ0, NET0, px[0] - step
    for k in range(1, len(px)):
        eq += net * 100 * (px[k] - px[k - 1])
        if eq <= 0:
            return eq, EQ0 + NET0 * 100 * (px[-1] - px[0]), True
        while net > 1e-9 and px[k] <= nxt:
            d = min(lot, net)
            net, nxt = net - d, nxt - step
            eq -= d * COST_LOT
    return eq, EQ0 + NET0 * 100 * (px[-1] - px[0]), False


def other_sig(df, kind):
    """#92 raat / #93 mahina SMA10 / #94 Sep+Nov: +1 = NET 0.80, -1 = NET 0.33."""
    ny = df['t'].dt.tz_convert('America/New_York')
    if kind == 'raat':
        h = ny.dt.hour.values
        return np.where((h >= 16) | (h < 9), 1.0, -1.0)
    if kind == 'mausam':
        return np.where(ny.dt.month.isin([9, 11]).values, 1.0, -1.0)
    ym = ny.dt.year.values * 12 + ny.dt.month.values - 1
    c = pd.Series(df['Close'].values).groupby(ym).last()
    ok = (c > c.rolling(10).mean()).shift(1)          # pichle mahine ka faisla
    return np.array([1.0 if ok.get(k) is True else -1.0 for k in ym])


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--imtihan', action='store_true')
    ap.add_argument('--m71', action='store_true')
    ap.add_argument('--upar', action='store_true', help='#90-91: DOWN par NET 0.33')
    ap.add_argument('--d1', action='store_true', help='#91: D1 supertrend')
    ap.add_argument('--sig', choices=['raat', 'sma10', 'mausam'], help='#92-94')
    a = ap.parse_args()
    df = load('XAUUSD')
    sig = other_sig(df, a.sig) if a.sig else h4_trend(df, daily=a.d1)
    a.upar = a.upar or bool(a.sig)
    t = df['t']
    lo, hi = ('2025-01-01', '2099-01-01') if a.imtihan else ('2021-01-01', '2025-01-01')
    m = ((t >= lo) & (t < hi)).values
    idx = np.nonzero(m)[0]
    last = idx[-1]
    close = df['Close'].values
    tt = t.dt.tz_convert('America/New_York')
    mondays = [i for i in idx if tt.iloc[i].weekday() == 0 and tt.iloc[i].hour == 0
               and (i == 0 or tt.iloc[i - 1].weekday() != 0)]
    print(f"{'TALAASH' if not a.imtihan else 'IMTIHAN'} {lo}..{t.iloc[last]:%Y-%m-%d}, Somwar starts {len(mondays)}")
    for months in (6, 3):
        print(f"\n== {months} mahine ==")
        for dn in ((None,) if a.m71 else ((NET0,) if a.upar else (0.0, -0.30))):
            rows = []
            for i0 in mondays:
                end_t = t.iloc[i0] + pd.DateOffset(months=months)
                i1 = int(np.searchsorted(t.values, np.datetime64(end_t.tz_convert(None))))
                if i1 > last:
                    break
                eq, base, stop = (run_m71(close, i0, i1 + 1) if a.m71
                                  else run(close, sig, i0, i1 + 1, dn))
                rows.append((t.iloc[i0], eq, base, stop))
            r = pd.DataFrame(rows, columns=['t', 'S', 'B', 'stop'])
            d = r['S'] - r['B']
            # be-jor tukre: har 'months' ke baad pehla start
            pick, nxt = [], None
            for k, tk in enumerate(r['t']):
                if nxt is None or tk >= nxt:
                    pick.append(k)
                    nxt = tk + pd.DateOffset(months=months)
            dj = d.iloc[pick]
            se = dj.std(ddof=1) / np.sqrt(len(dj)) if len(dj) > 1 else np.nan
            ok = [d.median() > 0, (d > 0).mean() >= 0.60, not r['stop'].any(), dj.mean() - 2 * se > 0]
            print(f"{'m7.1' if dn is None else f'S={dn:+.2f}'} | starts {len(r)} | median S-B {d.median():+8.0f} USC | S behtar {100*(d>0).mean():4.0f}%"
                  f" | stop {int(r['stop'].sum())} | be-jor n={len(dj)} mean {dj.mean():+7.0f} -2SE {dj.mean()-2*se:+7.0f}"
                  f" | S median eq {r['S'].median():7.0f} (B {r['B'].median():7.0f}) | breakeven(>= {EQ0+9512:.0f}) "
                  f"{100*(r['S']>=EQ0+9512).mean():.0f}% | {'PASS' if all(ok) else 'FAIL'} {ok}")


if __name__ == '__main__':
    main()
