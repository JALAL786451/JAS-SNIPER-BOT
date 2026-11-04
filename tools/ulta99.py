"""Koshish #99 / #100 (4 Nov 2026, 37vi chat, user ijazat) - #68 mansooba ka ULTA: SL nahi, TP = k x R.
Qaida (badalna mana): docs/purana-haal.md, grep "Koshish #99 / #100 qaida".
  A (#99) = TP + purana qaida exit (SL nahi)      B (#100) = sirf TP (na SL, na qaida exit)
  python3 tools/ulta99.py              # CHUNAO 2012-2018
  python3 tools/ulta99.py --imtihan --kA 0.5 --kB 1.0
"""
import argparse

import numpy as np
import pandas as pd

from ftmo53_asli import ASLI, run_cost
from ftmo60 import summary
from ftmo68 import KCOST, KH, f_win, khirki_trades
from ftmo_4h import st4h_trades
from ftmo_test import ATR_LEN, FILES, Mkt, atr_rma, ibs_trades, load, session_day, supertrend_up
from tokri47 import load_any

KS = [0.25, 0.5, 1.0, 2.0]


def t5_sig(df, k=6.0):
    """Har 4H upar palat: (ei, qaida exit idx, e, qaida exit qeemat, R, +1) - SL nahi."""
    day = session_day(df['t'])
    blk = ((df['t'].dt.tz_convert('America/New_York') + pd.Timedelta(hours=7)).dt.hour // 4).values
    g = pd.DataFrame({'i': np.arange(len(df)), 'd': day.values, 'b': blk,
                      'H': df['High'].values, 'L': df['Low'].values, 'C': df['Close'].values})
    g = g.groupby(['d', 'b'], sort=True).agg(f=('i', 'first'), la=('i', 'last'),
                                            H=('H', 'max'), L=('L', 'min'), C=('C', 'last')).sort_values('f')
    first = g['f'].values
    up, atr = supertrend_up(g['H'].values, g['L'].values, g['C'].values)
    o, cl = df['Open'].values, df['Close'].values
    n4, out = len(g), []
    for j in range(1, n4 - 1):
        if not (j > ATR_LEN * 3 and up[j] and not up[j - 1]):
            continue
        nxt = first[j + 1]
        xi, xp = len(df) - 1, cl[-1]
        for jj in range(j + 1, n4):
            if not up[jj] and jj + 1 < n4:
                xi, xp = first[jj + 1], o[first[jj + 1]]
                break
        out.append((nxt, xi, o[nxt], xp, k * atr[j], 1))
    return out


def i6_sig(df):
    df = df.copy()
    df['sd'] = session_day(df['t'])
    g = df.groupby('sd', sort=True)
    last = g.apply(lambda x: x.index[-1], include_groups=False).values
    h, l, c = g['High'].max().values, g['Low'].min().values, g['Close'].last().values
    a = atr_rma(h, l, c, 14)
    sma = pd.Series(c).rolling(200).mean().values
    ibs = np.where(h > l, (c - l) / np.where(h > l, h - l, 1), np.nan)
    nd, out = len(last), []
    for j in range(nd - 1):
        if not (not np.isnan(sma[j]) and a[j] > 0 and ibs[j] < 0.2 and c[j] > sma[j]):
            continue
        for jj in range(j + 1, nd):
            if (ibs[jj] > 0.8 or jj - j >= 5) and jj + 1 < nd:
                out.append((last[j] + 1, last[jj] + 1, c[j], c[jj], 3.0 * a[j], 1))
                break
    return out


def k2_sig(df, tz, cmin):
    loc = df['t'].dt.tz_convert(tz)
    dt = loc.dt.date.values
    mn = (loc.dt.hour * 60 + loc.dt.minute).values
    first = {}
    for i in np.nonzero(mn >= cmin)[0]:
        first.setdefault(dt[i], i)
    g = pd.DataFrame({'d': dt, 'H': df['High'].values, 'L': df['Low'].values, 'C': df['Close'].values}).groupby('d', sort=True)
    days = list(g.groups.keys())
    a = atr_rma(g['H'].max().values, g['L'].min().values, g['C'].last().values, 20)
    atr_prev = dict(zip(days[1:], a[:-1]))
    dates = sorted(first)
    op = df['Open'].values
    out = []
    for k, e in enumerate(dates):
        h = f_win(e)
        at = atr_prev.get(e)
        if h is None or not at or not at > 0:
            continue
        xd = next((x for x in dates[k + 1:] if x >= h), None)
        if xd is None:
            continue
        ei, xi = first[e], first[xd]
        if xi > ei:
            out.append((ei, xi, op[ei], op[xi], 3.0 * at, 1))
    return out


def tp_apply(df, sig, k, mode):
    """mode A: TP ya qaida exit (jo pehle); B: sirf TP (warna data ka aakhri close)."""
    o, hi, cl = df['Open'].values, df['High'].values, df['Close'].values
    n, out = len(df), []
    for ei, xi, e, xp, r, d in sig:
        tp = e + k * r
        end = xi if mode == 'A' else n
        hit = np.nonzero(hi[ei:end] >= tp)[0]
        if len(hit):
            j = ei + hit[0]
            out.append((ei, j, e, max(o[j], tp) if j > ei else tp, r, 1))
        elif mode == 'A':
            out.append((ei, xi, e, xp, r, 1))
        else:
            out.append((ei, n - 1, e, cl[-1], r, 1))
    return out


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--imtihan', action='store_true')
    ap.add_argument('--kA', type=float)
    ap.add_argument('--kB', type=float)
    a = ap.parse_args()
    base = list(FILES)
    syms = base + list(KH)
    dfs = {s: load(s) for s in base}
    dfs.update({s: load_any(s) for s in KH})
    grid = np.unique(np.concatenate([d['t'].values.astype('datetime64[ns]').astype(np.int64) for d in dfs.values()]))
    cet = pd.to_datetime(grid, utc=True).tz_convert('Europe/Prague')
    cetday = (cet.year * 10000 + cet.month * 100 + cet.day).values
    mk = [Mkt(s, dfs[s], grid) for s in syms]
    cost = [0.75 * ASLI[s] if s in base else KCOST for s in syms]
    # #68 asal (SL ke saath)
    t68 = [st4h_trades(dfs[s], 6.0) if s in base else [] for s in syms]
    i68 = [ibs_trades(dfs[s]) if s in ('US500', 'USTEC') else [] for s in syms]
    k68 = [khirki_trades(dfs[s], *KH[s]) if s in KH else [] for s in syms]
    # ulta ke signal (SL nahi)
    ts = [t5_sig(dfs[s]) if s in base else [] for s in syms]
    isg = [i6_sig(dfs[s]) if s in ('US500', 'USTEC') else [] for s in syms]
    ks = [k2_sig(dfs[s], *KH[s]) if s in KH else [] for s in syms]
    if a.imtihan:
        starts, end = pd.date_range('2019-01-01', '2026-10-01', freq='MS', tz='UTC'), grid[-1] + 1
    else:
        starts, end = pd.date_range('2012-01-01', '2018-12-01', freq='MS', tz='UTC'), pd.Timestamp('2019-01-01', tz='UTC').value

    def go(tr, ib, kh):
        sy = [(0.75, tr, {}), (1.0, ib, {}), (0.15, kh, {})]
        return summary([run_cost(mk, sy, s0.value, end, grid, cetday, cost) for s0 in starts])

    def r_info(lists, t0):
        r = [(x[3] - x[2]) / x[4] for L in lists for x in L if t0[0] <= x[0] < t0[1]]
        return len(r), float(np.mean(r)) if r else 0.0

    print(f"{'IMTIHAN 2019+' if a.imtihan else 'CHUNAO 2012-2018'}: {len(starts)} challenge")
    print('variant  k   | pass fail(P1/P2) adhoora | P1fail% | median')
    b = go(t68, i68, k68)
    print(f'#68 asal      | {b[0]:4d} {b[1] + b[2]:4d} ({b[1]}/{b[2]}) {b[3]:7d} | {100 * b[1] / len(starts):6.1f}% | {b[4]:6.1f}', flush=True)
    ks_run = {'A': [a.kA] if a.imtihan else KS, 'B': [a.kB] if a.imtihan else KS}
    for mode in 'AB':
        ok = []
        for k in ks_run[mode]:
            if k is None:
                continue
            tr = [tp_apply(dfs[s], x, k, mode) if x else [] for s, x in zip(syms, ts)]
            ib = [tp_apply(dfs[s], x, k, mode) if x else [] for s, x in zip(syms, isg)]
            kh = [tp_apply(dfs[s], x, k, mode) if x else [] for s, x in zip(syms, ks)]
            ps, f1, f2, ad, med = go(tr, ib, kh)
            p1 = 100 * f1 / len(starts)
            print(f'{mode}      {k:4.2f} | {ps:4d} {f1 + f2:4d} ({f1}/{f2}) {ad:7d} | {p1:6.1f}% | {med:6.1f}', flush=True)
            if a.imtihan:
                okI = f1 + f2 == 0 and ps >= b[0] and med < b[4]
                print(f'IMTIHAN {mode}: ' + ('PASS' if okI else 'FAIL') + f' (shart: fail 0, pass >= {b[0]}, median < {b[4]:.1f})')
            elif p1 < 20 and ps > f1 + f2 and ps - f1 - f2 >= b[0] - b[1] - b[2]:
                ok.append((ps - f1 - f2, -med, k))
        if not a.imtihan:
            print(f'CHUNA {mode}: ' + (f'k = {max(ok)[2]}' if ok else 'KOI NAHI = FAIL'), flush=True)


if __name__ == '__main__':
    main()
