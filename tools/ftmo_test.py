#!/usr/bin/env python3
"""FTMO test f1 (28 Oct 2026) - Koshish #27: JasTrend (#26 sirf BUY) asli tareekh par FTMO 2-step.

Qaida (badalna mana): docs/purana-haal.md, grep "Koshish #27 qaida".
Data: data/ftmo/*.zip (Dukascopy H1, UTC). Daily candle H1 se, din 17:00 NY par band.

  python3 tools/ftmo_test.py            # CHUNAO 2012-2018 (12 setting)
  python3 tools/ftmo_test.py --imtihan --risk 0.5 --k 6   # 2019+ EK dafa

Hadd (imaandari): lot fractional (asal mein 0.01 lot), spread ki jagah 0.03%/taraf,
swap andaza 3%/saal, alag market ke H1 low ek waqt maane (sakht), FTMO ke
news / weekend qaide nahi (Swing account).
"""
import argparse
import io
import zipfile
from pathlib import Path

import numpy as np
import pandas as pd

ROOT = Path(__file__).resolve().parent.parent
FILES = {
    'XAUUSD': ('XAU_XAG_H1_dukascopy.zip', 'XAUUSD-H1'),
    'XAGUSD': ('XAU_XAG_H1_dukascopy.zip', 'XAGUSD-H1'),
    'US500': ('USA500_H1_dukascopy.zip', 'USA500IDXUSD'),
    'USTEC': ('USATECH_H1_dukascopy.zip', 'USATECHIDXUSD'),
}
BAL0 = 100_000.0
COST = 0.0003           # har taraf
SWAP = 0.03 / 365       # har raat, notional par
ATR_LEN, ST_MULT = 10, 3.0


def load(sym):
    zname, key = FILES[sym]
    with zipfile.ZipFile(ROOT / 'data' / 'ftmo' / zname) as z:
        name = next(n for n in z.namelist() if key in n and n.endswith('.csv'))
        df = pd.read_csv(io.BytesIO(z.read(name)), dtype={'Date': str, 'Time': str})
    df['t'] = pd.to_datetime(df['Date'] + df['Time'], format='%Y%m%d%H:%M:%S', utc=True)
    return df[['t', 'Open', 'High', 'Low', 'Close']].sort_values('t').drop_duplicates('t').reset_index(drop=True)


def session_day(t):
    """17:00 NY se agla din; Sat/Sun -> Mon."""
    d = (t.dt.tz_convert('America/New_York') + pd.Timedelta(hours=7)).dt.normalize().dt.tz_localize(None)
    wd = d.dt.weekday
    return d + pd.to_timedelta(np.where(wd == 5, 2, np.where(wd == 6, 1, 0)), unit='D')


def supertrend_up(h, l, c):
    """TradingView ta.supertrend(3, 10): True = rukh upar (dir < 0)."""
    n = len(c)
    tr = np.maximum(h - l, np.maximum(abs(h - np.r_[np.nan, c[:-1]]), abs(l - np.r_[np.nan, c[:-1]])))
    tr[0] = h[0] - l[0]
    atr = np.full(n, np.nan)
    atr[ATR_LEN - 1] = tr[:ATR_LEN].mean()
    for i in range(ATR_LEN, n):
        atr[i] = (atr[i - 1] * (ATR_LEN - 1) + tr[i]) / ATR_LEN
    src = (h + l) / 2
    up = np.full(n, False)
    lo_b, hi_b, st = np.nan, np.nan, np.nan
    for i in range(n):
        if np.isnan(atr[i]):
            continue
        lb, ub = src[i] - ST_MULT * atr[i], src[i] + ST_MULT * atr[i]
        if not np.isnan(lo_b):
            lb = lb if (lb > lo_b or c[i - 1] < lo_b) else lo_b
            ub = ub if (ub < hi_b or c[i - 1] > hi_b) else hi_b
        if np.isnan(st):
            d = 1
        elif st == hi_b:
            d = -1 if c[i] > ub else 1
        else:
            d = 1 if c[i] < lb else -1
        st = lb if d == -1 else ub
        lo_b, hi_b = lb, ub
        up[i] = d == -1
    return up, atr


def trades_for(df, k):
    """Account se azad trades: (entry H1 idx, exit H1 idx, entry, exit, SL doori)."""
    df = df.copy()
    df['sd'] = session_day(df['t'])
    g = df.groupby('sd', sort=True)
    last = g.apply(lambda x: x.index[-1], include_groups=False).values
    h, l, c = g['High'].max().values, g['Low'].min().values, g['Close'].last().values
    up, atr = supertrend_up(h, l, c)
    o, lo, cl = df['Open'].values, df['Low'].values, df['Close'].values
    nd = len(last)
    out = []
    j = 1
    while j < nd - 1:
        if not (j > ATR_LEN * 3 and up[j] and not up[j - 1]):
            j += 1
            continue
        nxt = last[j] + 1
        e, sl = o[nxt], o[nxt] - k * atr[j]
        ex_i = ex_p = None
        jj = j + 1
        while jj < nd:
            a = nxt if jj == j + 1 else last[jj - 1] + 1
            b = last[jj] + 1
            hit = np.nonzero(lo[a:b] <= sl)[0]
            if len(hit):
                ex_i = a + hit[0]
                ex_p = min(o[ex_i], sl)
                break
            if not up[jj] and jj + 1 < nd:
                ex_i, ex_p = last[jj] + 1, o[last[jj] + 1]
                break
            jj += 1
        if ex_i is None:
            ex_i, ex_p = len(df) - 1, cl[-1]
        out.append((nxt, ex_i, e, ex_p, k * atr[j]))
        j = jj + 1                           # SL / flip ke baad sirf naya flip upar
    return out


class Mkt:
    def __init__(self, sym, df, grid):
        self.sym = sym
        self.grid = grid                     # global timeline (UTC ns)
        gi = np.searchsorted(grid, df['t'].values.astype('datetime64[ns]').astype(np.int64))
        self.gi = gi
        n = len(grid)
        # forward-fill: low = us ghante ka low (bar na ho to pichla close)
        lowf = np.full(n, np.nan)
        clf = np.full(n, np.nan)
        clf[gi] = df['Close'].values
        clf = pd.Series(clf).ffill().values
        lowf[:] = clf
        lowf[gi] = df['Low'].values
        self.lowf, self.clf = lowf, clf
        self.df = df


def run(mkts, trades, risk, start_ns, end_ns, grid, cetday):
    """Ek challenge: 'pass' / 'fail1' / 'fail2' / 'adhoora', mahine, kam_din."""
    risk_usd = BAL0 * risk / 100
    # (global entry, global exit, sym idx, entry, exit, units)
    tl = []
    for mi, m in enumerate(mkts):
        for (ei, xi, e, x, sd) in trades[mi]:
            ge, gx = m.gi[ei], m.gi[xi]
            if grid[ge] >= start_ns and grid[ge] < end_ns:
                tl.append((ge, gx, mi, e, x, risk_usd / sd))
    tl.sort()
    i0 = np.searchsorted(grid, start_ns)
    i_end = np.searchsorted(grid, end_ns)
    phase, target = 1, 1.10
    bal, open_, ti = BAL0, {}, 0
    day, dstart, days = None, bal, set()
    t_pass1 = None
    kam_din = False
    for t in range(i0, i_end):
        if cetday[t] != day:
            day = cetday[t]
            dstart = bal
            # swap: har raat har khuli position
            for mi, p in open_.items():
                bal -= SWAP * p[1] * mkts[mi].clf[t]
            dstart = bal
        # bandish (SL ya flip) is ghante
        for mi in list(open_):
            ge, gx, _, e, x, u = open_[mi][2]
            if gx == t:
                bal += (x - e) * u - COST * x * u
                del open_[mi]
        # nayi entry
        while ti < len(tl) and tl[ti][0] <= t:
            tr = tl[ti]
            ti += 1
            if tr[0] < t or tr[2] in open_ or tr[1] <= tr[0]:
                continue
            bal -= COST * tr[3] * tr[5]
            open_[tr[2]] = (tr[3], tr[5], tr)
            days.add(day)
        # equity: bura (low) aur close
        worst = bal + sum((mkts[mi].lowf[t] - p[0]) * p[1] for mi, p in open_.items())
        eq = bal + sum((mkts[mi].clf[t] - p[0]) * p[1] for mi, p in open_.items())
        if worst < dstart - 0.05 * BAL0 or worst < 0.90 * BAL0:
            return ('fail1' if phase == 1 else 'fail2'), (grid[t] - start_ns) / 2.63e15, kam_din
        if eq >= target * BAL0:
            if len(days) < 4:
                kam_din = True
            if phase == 2:
                return 'pass', (grid[t] - start_ns) / 2.63e15, kam_din
            phase, target = 2, 1.05
            bal, open_, days, dstart = BAL0, {}, set(), BAL0
            # P2: sirf is waqt ke baad wale naye trade
    return 'adhoora', (grid[i_end - 1] - start_ns) / 2.63e15, kam_din


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--imtihan', action='store_true')
    ap.add_argument('--risk', type=float, nargs='*', default=[0.25, 0.5, 0.75, 1.0])
    ap.add_argument('--k', type=float, nargs='*', default=[4, 6, 8])
    a = ap.parse_args()
    dfs = {s: load(s) for s in FILES}
    grid = np.unique(np.concatenate([d['t'].values.astype('datetime64[ns]').astype(np.int64) for d in dfs.values()]))
    cet = pd.to_datetime(grid, utc=True).tz_convert('Europe/Prague')
    cetday = (cet.year * 10000 + cet.month * 100 + cet.day).values
    mkts = [Mkt(s, dfs[s], grid) for s in FILES]
    if a.imtihan:
        starts = pd.date_range('2019-01-01', '2026-10-01', freq='MS', tz='UTC')
        end = grid[-1] + 1
    else:
        starts = pd.date_range('2012-01-01', '2018-12-01', freq='MS', tz='UTC')
        end = pd.Timestamp('2019-01-01', tz='UTC').value
    print(f"{'IMTIHAN 2019+' if a.imtihan else 'CHUNAO 2012-2018'}: {len(starts)} challenge")
    print('risk%  k | pass fail(P1/P2) adhoora | P1fail% | pass mahine (median) | kam din | trades/mahina')
    for k in a.k:
        trades = [trades_for(m.df, k) for m in mkts]
        for r in a.risk:
            res = [run(mkts, trades, r, s.value, end, grid, cetday) for s in starts]
            ps = [x for x in res if x[0] == 'pass']
            f1 = sum(x[0] == 'fail1' for x in res)
            f2 = sum(x[0] == 'fail2' for x in res)
            ad = sum(x[0] == 'adhoora' for x in res)
            med = np.median([x[1] for x in ps]) if ps else float('nan')
            kd = sum(x[2] for x in ps)
            n_tr = sum(sum(1 for tr in trades[mi] if s0 <= mkts[mi].grid[mkts[mi].gi[tr[0]]] < end)
                       for mi in range(4) for s0 in [starts[0].value])
            mon = (end - starts[0].value) / 2.63e15
            print(f'{r:5.2f} {k:3.0f} | {len(ps):4d} {f1 + f2:4d} ({f1}/{f2}) {ad:7d} | {100 * f1 / len(res):6.1f}% |'
                  f' {med:6.1f} | {kd:3d} | {n_tr / mon:.2f}')


if __name__ == '__main__':
    main()
