#!/usr/bin/env python3
"""Koshish #47 (31 Oct 2026) - BARI TOKRI 28 market: #34 JAS Trend 4H + pehra + FTMO.
Qaida (badalna mana): docs/purana-haal.md, grep "Koshish #47 qaida".

  python3 tools/tokri47.py edge                 # A: TALAASH (entry < 2019)
  python3 tools/tokri47.py edge --imtihan       # A: 2019+ EK dafa (sirf TALAASH PASS ke baad)
  python3 tools/tokri47.py ftmo                 # B: CHUNAO 2012-2018 (risk 0.25/0.5/0.75)
  python3 tools/tokri47.py ftmo --imtihan --risk 0.5   # B: 2019+ EK dafa
  --tf D1 = Koshish #48 (daily, SL 4 x ATR, risk 0.5/0.75/1.0) - qaida grep "Koshish #48 qaida"

Data: data/ftmo (4) + data/duka/H1/JAS_ZIP (24), UTC H1. Index/metal/oil/fasal/BTC sirf BUY;
forex + DOLLARIDX BUY + SELL. SL = 6 x ATR10(4H). Kharcha 0.03%/taraf + swap 3%/saal.
"""
import argparse
import io
import zipfile

import numpy as np
import pandas as pd

from ftmo_test import ATR_LEN, BAL0, COST, ROOT, SWAP, Mkt, load, session_day, supertrend_up

K = 6.0                                      # #47 (4H); #48 (D1) = 4.0
TF = 'H4'
CUT = pd.Timestamp('2019-01-01', tz='UTC')
GROUPS = {
    'US idx': ['US500', 'USTEC', 'USA30IDXUSD', 'USSC2000IDXUSD'],
    'EU idx': ['DEUIDXEUR', 'FRAIDXEUR', 'GBRIDXGBP', 'EUSIDXEUR', 'ESPIDXEUR', 'CHEIDXCHF'],
    'Asia idx': ['JPNIDXJPY', 'HKGIDXHKD', 'CHIIDXUSD', 'AUSIDXAUD'],
    'metal': ['XAUUSD', 'XAGUSD'],
    'oil': ['LIGHTCMDUSD', 'BRENTCMDUSD'],
    'fasal': ['COCOACMDUSD', 'COFFEECMDUSX', 'COTTONCMDUSX', 'SOYBEANCMDUSX'],
    'USD fx': ['GBPUSD', 'NZDUSD', 'USDCAD', 'USDCHF', 'DOLLARIDXUSD'],
    'crypto': ['BTCUSD'],
}
BOTH = set(GROUPS['USD fx'])                 # BUY + SELL
FTMO4 = {'US500', 'USTEC', 'XAUUSD', 'XAGUSD'}


def load_any(sym):
    if sym in FTMO4:
        return load(sym)
    with zipfile.ZipFile(ROOT / 'data' / 'duka' / 'H1' / 'JAS_ZIP' / f'{sym}_H1.zip') as z:
        name = next(n for n in z.namelist() if n.endswith('.csv'))
        df = pd.read_csv(io.BytesIO(z.read(name)), dtype={'Date': str, 'Time': str})
    df['t'] = pd.to_datetime(df['Date'] + df['Time'], format='%Y%m%d%H:%M:%S', utc=True)
    return df[['t', 'Open', 'High', 'Low', 'Close']].sort_values('t').drop_duplicates('t').reset_index(drop=True)


def trades4h(df, k, both):
    """(entry H1 idx, exit H1 idx, entry, exit, SL doori, rukh) - 4H (ya TF = D1) Supertrend flip, server SL = k x ATR10."""
    day = session_day(df['t'])
    blk = ((df['t'].dt.tz_convert('America/New_York') + pd.Timedelta(hours=7)).dt.hour // 4).values
    if TF == 'D1':
        blk = np.zeros(len(df), dtype=int)
    g = pd.DataFrame({'i': np.arange(len(df)), 'd': day.values, 'b': blk,
                      'H': df['High'].values, 'L': df['Low'].values, 'C': df['Close'].values})
    g = g.groupby(['d', 'b'], sort=True).agg(f=('i', 'first'), la=('i', 'last'),
                                            H=('H', 'max'), L=('L', 'min'), C=('C', 'last')).sort_values('f')
    first, last = g['f'].values, g['la'].values
    up, atr = supertrend_up(g['H'].values, g['L'].values, g['C'].values)
    o, lo, hi, cl = (df[c].values for c in ('Open', 'Low', 'High', 'Close'))
    n4, out, j = len(g), [], 1
    while j < n4 - 1:
        fu, fd = up[j] and not up[j - 1], (not up[j]) and up[j - 1]
        if j <= ATR_LEN * 3 or not (fu or (both and fd)):
            j += 1
            continue
        d = 1 if fu else -1
        nxt = first[j + 1]
        e, sd = o[nxt], k * atr[j]
        sl = e - d * sd
        ex_i = ex_p = None
        by_flip = False
        jj = j + 1
        while jj < n4:
            a, b = first[jj], last[jj] + 1
            hit = np.nonzero(lo[a:b] <= sl)[0] if d > 0 else np.nonzero(hi[a:b] >= sl)[0]
            if len(hit):
                ex_i = a + hit[0]
                ex_p = min(o[ex_i], sl) if d > 0 else max(o[ex_i], sl)
                break
            if bool(up[jj]) != (d > 0) and jj + 1 < n4:
                ex_i, ex_p, by_flip = first[jj + 1], o[first[jj + 1]], True
                break
            jj += 1
        if ex_i is None:
            ex_i, ex_p = len(df) - 1, cl[-1]
        out.append((nxt, ex_i, e, ex_p, sd, d))
        j = jj if (both and by_flip) else jj + 1     # BUY+SELL: ulta flip khud nayi entry
    return out


def r_of(df, tr):
    t = df['t'].values
    rows = []
    for ei, xi, e, x, sd, d in tr:
        nights = (t[xi] - t[ei]) / np.timedelta64(1, 'D')
        r = (d * (x - e) - COST * (e + x) - SWAP * nights * e) / sd
        r0 = d * (x - e) / sd
        rows.append((pd.Timestamp(t[ei], tz='UTC'), d, r, r0))
    return pd.DataFrame(rows, columns=['t', 'd', 'r', 'r0'])


def line(name, r):
    n = len(r)
    if n < 2:
        return f'{name}: {n} tr'
    ex, se = r.mean(), r.std(ddof=1) / np.sqrt(n)
    return f'{name}: {n:5d} tr, Exp {ex:+.3f}R, SE {se:.3f}, Exp-2SE {ex - 2 * se:+.3f}, jeet {100 * (r > 0).mean():.0f}%'


def edge(imtihan):
    print('A. EDGE ' + ('IMTIHAN 2019+ (EK dafa)' if imtihan else 'TALAASH entry < 2019'))
    allt, cells, mk = [], [], {}
    for gname, syms in GROUPS.items():
        for s in syms:
            df = load_any(s)
            t = r_of(df, trades4h(df, K, s in BOTH))
            t = t[t.t >= CUT] if imtihan else t[t.t < CUT]
            t['m'], t['g'] = s, gname
            allt.append(t)
            if len(t):
                cells += list(t.groupby(t.t.dt.year)['r'].sum().values)
                mk[s] = (len(t), t.r.mean())
            print('  ' + line(f'{s:15s} {gname:8s}', t.r))
    t = pd.concat(allt)
    print('\n' + line('KUL          ', t.r))
    n, ex, se = len(t), t.r.mean(), t.r.std(ddof=1) / np.sqrt(len(t))
    print(f'   bina kharcha {t.r0.mean():+.3f}R')
    for d, nm in ((1, 'BUY '), (-1, 'SELL')):
        print('   ' + line(nm, t[t.d == d].r))
    for gname in GROUPS:
        print('   ' + line(f'{gname:8s}', t[t.g == gname].r))
    big = {s: v for s, v in mk.items() if v[0] >= 10}
    pos = sum(1 for v in big.values() if v[1] > 0)
    cells = np.array(cells)
    months = max(1, t.t.dt.tz_localize(None).dt.to_period('M').nunique())
    print(f'   >=10 tr wale market musbat {pos}/{len(big)}, (market x saal) musbat {(cells > 0).sum()}/{len(cells)}, '
          f'~{n / months:.1f} tr/mahina (jin mahinon mein trade)')
    if imtihan:
        ok = n >= 30 and ex - 2 * se > 0
    else:
        ok = n >= 100 and ex - 2 * se > 0 and (cells > 0).mean() > 0.5 and pos >= 0.6 * len(big)
    print('PASS' if ok else 'FAIL')


def run_pehra(mkts, trades, gid, risk, start_ns, end_ns, grid, cetday):
    """ftmo_test.run (#27) jaisa, + pehra: group mein max 2, kul khuli <= floor(3 / risk)."""
    max_open = int(3.0 // risk)
    risk_usd = BAL0 * risk / 100
    tl = []
    for mi, m in enumerate(mkts):
        for (ei, xi, e, x, sd, d) in trades[mi]:
            ge, gx = m.gi[ei], m.gi[xi]
            if start_ns <= grid[ge] < end_ns:
                tl.append((ge, gx, mi, e, x, risk_usd / sd, mi, d))
    tl.sort()
    i0, i_end = np.searchsorted(grid, start_ns), np.searchsorted(grid, end_ns)
    phase, target = 1, 1.10
    bal, open_, ti = BAL0, {}, 0
    day, dstart, days, kam = None, bal, set(), False
    for t in range(i0, i_end):
        if cetday[t] != day:
            day = cetday[t]
            for p in open_.values():
                bal -= SWAP * p[1] * mkts[p[2][6]].clf[t]
            dstart = bal
        for slot in list(open_):
            _, gx, _, e, x, u, _, d = open_[slot][2]
            if gx == t:
                bal += d * (x - e) * u - COST * x * u
                del open_[slot]
        while ti < len(tl) and tl[ti][0] <= t:
            tr = tl[ti]
            ti += 1
            if tr[0] < t or tr[2] in open_ or tr[1] <= tr[0]:
                continue
            if len(open_) >= max_open or sum(1 for s in open_ if gid[s] == gid[tr[2]]) >= 2:
                continue
            bal -= COST * tr[3] * tr[5]
            open_[tr[2]] = (tr[3], tr[5], tr)
            days.add(day)
        worst = bal + sum(((mkts[p[2][6]].lowf[t] if p[2][7] > 0 else mkts[p[2][6]].highf[t]) - p[0]) * p[2][7] * p[1]
                          for p in open_.values())
        eq = bal + sum((mkts[p[2][6]].clf[t] - p[0]) * p[2][7] * p[1] for p in open_.values())
        if worst < dstart - 0.05 * BAL0 or worst < 0.90 * BAL0:
            return ('fail1' if phase == 1 else 'fail2'), (grid[t] - start_ns) / 2.63e15, kam
        if eq >= target * BAL0:
            if len(days) < 4:
                kam = True
            if phase == 2:
                return 'pass', (grid[t] - start_ns) / 2.63e15, kam
            phase, target = 2, 1.05
            bal, open_, days, dstart = BAL0, {}, set(), BAL0
    return 'adhoora', (grid[i_end - 1] - start_ns) / 2.63e15, kam


def ftmo(imtihan, risks):
    syms = [s for g in GROUPS.values() for s in g]
    gid = [next(i for i, g in enumerate(GROUPS.values()) if s in g) for s in syms]
    dfs = {s: load_any(s) for s in syms}
    grid = np.unique(np.concatenate([d['t'].values.astype('datetime64[ns]').astype(np.int64) for d in dfs.values()]))
    cet = pd.to_datetime(grid, utc=True).tz_convert('Europe/Prague')
    cetday = (cet.year * 10000 + cet.month * 100 + cet.day).values
    mkts = [Mkt(s, dfs[s], grid) for s in syms]
    trades = [trades4h(dfs[s], K, s in BOTH) for s in syms]
    if imtihan:
        starts = pd.date_range('2019-01-01', '2026-10-01', freq='MS', tz='UTC')
        end = grid[-1] + 1
    else:
        starts = pd.date_range('2012-01-01', '2018-12-01', freq='MS', tz='UTC')
        end = CUT.value
    n_tr = sum(1 for mi in range(len(mkts)) for tr in trades[mi] if starts[0].value <= grid[mkts[mi].gi[tr[0]]] < end)
    print(f"B. FTMO {'IMTIHAN 2019+' if imtihan else 'CHUNAO 2012-2018'}: {len(starts)} challenge, "
          f"{n_tr / ((end - starts[0].value) / 2.63e15):.1f} signal/mahina (pehre se pehle)")
    print('risk% | pass fail(P1/P2) adhoora | P1fail% | pass mahine (median) | kam din')
    for r in risks:
        res = [run_pehra(mkts, trades, gid, r, s.value, end, grid, cetday) for s in starts]
        ps = [x for x in res if x[0] == 'pass']
        f1, f2 = sum(x[0] == 'fail1' for x in res), sum(x[0] == 'fail2' for x in res)
        ad = sum(x[0] == 'adhoora' for x in res)
        med = np.median([x[1] for x in ps]) if ps else float('nan')
        print(f'{r:5.2f} | {len(ps):4d} {f1 + f2:4d} ({f1}/{f2}) {ad:7d} | {100 * f1 / len(res):6.1f}% | {med:6.1f} | '
              f'{sum(x[2] for x in ps):3d}', flush=True)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('part', choices=['edge', 'ftmo'])
    ap.add_argument('--imtihan', action='store_true')
    ap.add_argument('--risk', type=float, nargs='*')
    ap.add_argument('--tf', choices=['H4', 'D1'], default='H4')
    a = ap.parse_args()
    global K, TF
    TF = a.tf
    K = 4.0 if TF == 'D1' else 6.0
    print(f'TF {TF}, SL {K:.0f} x ATR10')
    if a.risk is None:
        a.risk = [0.5, 0.75, 1.0] if TF == 'D1' else [0.25, 0.5, 0.75]
    if a.part == 'edge':
        edge(a.imtihan)
    else:
        ftmo(a.imtihan, a.risk)


if __name__ == '__main__':
    main()
