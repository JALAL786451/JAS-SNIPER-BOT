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
    """Account se azad trades: (entry H1 idx, exit H1 idx, entry, exit, SL doori, rukh +1/-1)."""
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
        out.append((nxt, ex_i, e, ex_p, k * atr[j], 1))
        j = jj + 1                           # SL / flip ke baad sirf naya flip upar
    return out


def atr_rma(h, l, c, n):
    """TradingView ta.atr(n) (RMA)."""
    pc = np.r_[np.nan, c[:-1]]
    tr = np.nanmax(np.vstack([h - l, abs(h - pc), abs(l - pc)]), axis=0)
    a = np.full(len(c), np.nan)
    if len(c) >= n:
        a[n - 1] = tr[:n].mean()
        for i in range(n, len(c)):
            a[i] = (a[i - 1] * (n - 1) + tr[i]) / n
    return a


def ibs_trades(df):
    """Koshish #28: IBS #15 (b2) - (entry H1 idx, exit H1 idx, entry, exit, SL doori).
    Entry / IBS band = din ka close; idx = agli H1 (us waqt se hisaab mein)."""
    df = df.copy()
    df['sd'] = session_day(df['t'])
    g = df.groupby('sd', sort=True)
    last = g.apply(lambda x: x.index[-1], include_groups=False).values
    h, l, c = g['High'].max().values, g['Low'].min().values, g['Close'].last().values
    a = atr_rma(h, l, c, 14)
    sma = pd.Series(c).rolling(200).mean().values
    ibs = np.where(h > l, (c - l) / np.where(h > l, h - l, 1), np.nan)
    o, lo = df['Open'].values, df['Low'].values
    nd, out, j = len(last), [], 0
    while j < nd - 1:
        if not (not np.isnan(sma[j]) and a[j] > 0 and ibs[j] < 0.2 and c[j] > sma[j]):
            j += 1
            continue
        e, r = c[j], 3.0 * a[j]
        sl = e - r
        ex_i = ex_p = None
        jj = j + 1
        while jj < nd:
            a0, b0 = last[jj - 1] + 1, last[jj] + 1
            hit = np.nonzero(lo[a0:b0] <= sl)[0]
            if len(hit):
                ex_i = a0 + hit[0]
                ex_p = min(o[ex_i], sl)
                break
            if (ibs[jj] > 0.8 or jj - j >= 5) and jj + 1 < nd:
                ex_i, ex_p = last[jj] + 1, c[jj]
                break
            jj += 1
        if ex_i is None:
            break                             # data khatam, khuli trade nahi gini
        out.append((last[j] + 1, ex_i, e, ex_p, r, 1))
        j = jj + 1                           # band / SL wale din nayi nahi
    return out


def daily(df):
    """H1 -> daily (17:00 NY): har din ki aakhri H1 idx, H, L, C."""
    g = df.assign(sd=session_day(df['t'])).groupby('sd', sort=True)
    last = g.apply(lambda x: x.index[-1], include_groups=False).values
    return last, g['High'].max().values, g['Low'].min().values, g['Close'].last().values


def kachhua_trades(df):
    """Koshish #29: Kachhua (Tide 1, Radar r3 f_tide) - BUY aur SELL, 2xATR SL, SL roz sarakta."""
    last, h, l, c = daily(df)
    a = atr_rma(h, l, c, 14)
    ef = pd.Series(c).ewm(span=50, adjust=False).mean().values
    es = pd.Series(c).ewm(span=200, adjust=False).mean().values
    sh = pd.Series(h).shift(1)
    sl_ = pd.Series(l).shift(1)
    hb, lb = sh.rolling(10).max().values, sl_.rolling(10).min().values   # t-10..t-1
    hx, lx = sh.rolling(5).max().values, sl_.rolling(5).min().values     # t-5..t-1
    o, hi, lo = df['Open'].values, df['High'].values, df['Low'].values
    out, d, e, r, sl, ent = [], 0, 0.0, 0.0, 0.0, 0
    for t in range(200, len(last) - 1):
        at_c = False
        if d != 0:
            a0, b0 = last[t - 1] + 1, last[t] + 1
            hit = np.nonzero(lo[a0:b0] <= sl)[0] if d == 1 else np.nonzero(hi[a0:b0] >= sl)[0]
            ex_i = ex_p = None
            if len(hit):
                ex_i = a0 + hit[0]
                ex_p = min(o[ex_i], sl) if d == 1 else max(o[ex_i], sl)
            elif (ef[t - 1] < es[t - 1]) if d == 1 else (ef[t - 1] > es[t - 1]):
                ex_i, ex_p, at_c = last[t] + 1, c[t], True
            else:
                sl = max(sl, lx[t]) if d == 1 else min(sl, hx[t])
                if (c[t] <= sl) if d == 1 else (c[t] >= sl):
                    ex_i, ex_p, at_c = last[t] + 1, c[t], True
            if ex_i is not None:
                out.append((ent, ex_i, e, ex_p, r, d))
                d = 0
        if d == 0 and not at_c and a[t] > 0 and not np.isnan(hb[t]):
            live = a[t] / c[t] * 100 >= 0.25
            if c[t] > hb[t] and ef[t - 1] > es[t - 1] and live:
                d = 1
            elif c[t] < lb[t] and ef[t - 1] < es[t - 1] and live:
                d = -1
            if d:
                e, r, ent = c[t], 2.0 * a[t], last[t] + 1
                sl = e - d * r
    return out


def r_stats(df, trades, r_div=1.0, a='1900', b='2100'):
    """Har trade ka R (kharcha + swap ke baad), saal aur rukh ke saath. r_div: SL doori / R."""
    t = df['t'].values
    out, yrs, dirs = [], [], []
    for ei, xi, e, x, sd, d in trades:
        if not (np.datetime64(a) <= t[ei] < np.datetime64(b)):
            continue
        nights = (t[xi] - t[ei]) / np.timedelta64(1, 'D')
        out.append((d * (x - e) - COST * (e + x) - SWAP * nights * e) / (sd / r_div))
        yrs.append(pd.Timestamp(t[ei]).year)
        dirs.append(d)
    return np.array(out), np.array(yrs), np.array(dirs)


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
        highf = clf.copy()
        highf[gi] = df['High'].values
        self.lowf, self.highf, self.clf = lowf, highf, clf
        self.df = df


def run(mkts, systems, start_ns, end_ns, grid, cetday):
    """Ek challenge: 'pass' / 'fail1' / 'fail2' / 'adhoora', mahine, kam_din.
    systems = [(risk %, [har market ki trades], slot map)]; slot = (system, market) - ek slot ek position.
    slot map {market: slot} se do market ek slot (Kachhua: gold+silver ek)."""
    # (global entry, global exit, slot, entry, exit, units, market, rukh)
    tl = []
    for si, (risk, trades, smap) in enumerate(systems):
        risk_usd = BAL0 * risk / 100
        for mi, m in enumerate(mkts):
            for (ei, xi, e, x, sd, d) in trades[mi]:
                ge, gx = m.gi[ei], m.gi[xi]
                if grid[ge] >= start_ns and grid[ge] < end_ns:
                    tl.append((ge, gx, si * 10 + smap.get(mi, mi), e, x, risk_usd / sd, mi, d))
    tl.sort()
    i0 = np.searchsorted(grid, start_ns)
    i_end = np.searchsorted(grid, end_ns)
    phase, target = 1, 1.10
    bal, open_, ti = BAL0, {}, 0
    day, dstart, days = None, bal, set()
    kam_din = False
    for t in range(i0, i_end):
        if cetday[t] != day:
            day = cetday[t]
            dstart = bal
            # swap: har raat har khuli position
            for p in open_.values():
                bal -= SWAP * p[1] * mkts[p[2][6]].clf[t]
            dstart = bal
        # bandish (SL ya flip) is ghante
        for slot in list(open_):
            ge, gx, _, e, x, u, _, d = open_[slot][2]
            if gx == t:
                bal += d * (x - e) * u - COST * x * u
                del open_[slot]
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
        worst = bal + sum(((mkts[p[2][6]].lowf[t] if p[2][7] > 0 else mkts[p[2][6]].highf[t]) - p[0]) * p[2][7] * p[1]
                          for p in open_.values())
        eq = bal + sum((mkts[p[2][6]].clf[t] - p[0]) * p[2][7] * p[1] for p in open_.values())
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
    ap.add_argument('--ibs', action='store_true', help='#28: IBS ka TALAASH (trade R), --imtihan = 2019+')
    ap.add_argument('--kachhua', action='store_true', help='#29: Kachhua ka TALAASH (trade R), --imtihan = 2019+')
    ap.add_argument('--jor', type=float, nargs='*', help='FTMO jor: JasTrend 1%%/4xATR + EA2 (--ea2) in risk par')
    ap.add_argument('--ea2', choices=['ibs', 'kachhua'], default='kachhua')
    a = ap.parse_args()
    if a.ibs:
        return edge_report('#28 IBS', ibs_trades, a.imtihan)
    if a.kachhua:
        return edge_report('#29 Kachhua', kachhua_trades, a.imtihan)
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
    combos = []
    if a.jor:
        jt = [trades_for(m.df, 4) for m in mkts]
        fn, smap = (ibs_trades, {}) if a.ea2 == 'ibs' else (kachhua_trades, {1: 0})   # Kachhua: gold+silver ek
        e2 = [fn(m.df) for m in mkts]
        combos = [(r, a.ea2[:3].upper(), [(1.0, jt, {}), (r, e2, smap)]) for r in a.jor]
    else:
        for k in a.k:
            trades = [trades_for(m.df, k) for m in mkts]
            combos += [(r, k, [(r, trades, {})]) for r in a.risk]
    for r, k, systems in combos:
        trades = [sum((sy[1][mi] for sy in systems), []) for mi in range(4)]
        res = [run(mkts, systems, s.value, end, grid, cetday) for s in starts]
        ps = [x for x in res if x[0] == 'pass']
        f1 = sum(x[0] == 'fail1' for x in res)
        f2 = sum(x[0] == 'fail2' for x in res)
        ad = sum(x[0] == 'adhoora' for x in res)
        med = np.median([x[1] for x in ps]) if ps else float('nan')
        kd = sum(x[2] for x in ps)
        n_tr = sum(sum(1 for tr in trades[mi] if s0 <= mkts[mi].grid[mkts[mi].gi[tr[0]]] < end)
                   for mi in range(4) for s0 in [starts[0].value])
        mon = (end - starts[0].value) / 2.63e15
        print(f'{r:5.2f} {k!s:>3} | {len(ps):4d} {f1 + f2:4d} ({f1}/{f2}) {ad:7d} | {100 * f1 / len(res):6.1f}% |'
              f' {med:6.1f} | {kd:3d} | {n_tr / mon:.2f}')


def edge_report(name, fn, imtihan):
    a, b = ('2019', '2100') if imtihan else ('1900', '2019')
    print(f"{name} {'IMTIHAN 2019+' if imtihan else 'TALAASH < 2019'} (R = server SL, kharcha + swap ke baad)")
    allr, alld, ypos, yall, mpos = [], [], 0, 0, 0
    for s in FILES:
        df = load(s)
        r, y, dr = r_stats(df, fn(df), 1.0, a, b)
        alld.append(dr)
        allr.append(r)
        ys = pd.Series(r).groupby(y).sum() if len(r) else pd.Series(dtype=float)
        ypos += int((ys > 0).sum())
        yall += len(ys)
        mpos += int(len(r) and r.mean() > 0)
        se = r.std(ddof=1) / len(r) ** 0.5 if len(r) > 1 else float('nan')
        print(f'{s:7s} {len(r):4d} tr  jeet {100 * (r > 0).mean():4.1f}%  Exp {r.mean():+.3f}R  SE {se:.3f}'
              f'  Exp-2SE {r.mean() - 2 * se:+.3f}  saal {int((ys > 0).sum())}/{len(ys)}  {y.min() if len(y) else "-"}-{y.max() if len(y) else "-"}')
    r, dr = np.concatenate(allr), np.concatenate(alld)
    for dd, nm in ((1, 'BUY'), (-1, 'SELL')):
        x = r[dr == dd]
        if len(x) > 1:
            print(f'  {nm:4s} {len(x):4d} tr  Exp {x.mean():+.3f}R  SE {x.std(ddof=1) / len(x) ** 0.5:.3f}  (maloomat)')
    se = r.std(ddof=1) / len(r) ** 0.5
    edge = r.mean() - 2 * se
    ok = (len(r) >= 30 and edge > 0) if imtihan else (len(r) >= 100 and edge > 0 and mpos >= 3 and ypos * 2 > yall)
    print(f'KUL     {len(r):4d} tr  Exp {r.mean():+.4f}R  SE {se:.4f}  Exp-2SE {edge:+.4f}  market musbat {mpos}/4'
          f'  saal {ypos}/{yall}  ->  {"PASS" if ok else "FAIL"}')


if __name__ == '__main__':
    main()
