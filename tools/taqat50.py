#!/usr/bin/env python3
"""Koshish #50 (31 Oct 2026) - TOKRI MEIN TAQAT KA MUQABLA (cross-sectional momentum, long + short).
Qaida (badalna mana): docs/purana-haal.md, grep "Koshish #50 qaida".

  python3 tools/taqat50.py edge              # A: TALAASH (entry < 2019)
  python3 tools/taqat50.py edge --imtihan    # A: 2019+ EK dafa (sirf TALAASH PASS ke baad)
  python3 tools/taqat50.py ftmo              # B: CHUNAO 2012-2018
  python3 tools/taqat50.py ftmo --imtihan --risk 0.5

Har Juma close: taqat = 60 din return / (daily SD x sqrt 60); top 4 BUY, bottom 4 SELL (group se ek taraf max 2);
agle din open par; SL 3 x ATR20(D); set se bahar = agle din open band.
"""
import argparse

import numpy as np
import pandas as pd

from ftmo_test import BAL0, COST, SWAP, Mkt, atr_rma, run, session_day
from tokri47 import GROUPS, load_any

LOOK, NTOP, GCAP, SLM = 60, 4, 2, 3.0
CUT = pd.Timestamp('2019-01-01', tz='UTC')


def daily(df):
    day = session_day(df['t']).values
    g = pd.DataFrame({'i': np.arange(len(df)), 'd': day, 'O': df['Open'].values, 'H': df['High'].values,
                      'L': df['Low'].values, 'C': df['Close'].values})
    x = g.groupby('d', sort=True).agg(f=('i', 'first'), la=('i', 'last'), O=('O', 'first'), H=('H', 'max'),
                                      L=('L', 'min'), C=('C', 'last'))
    x['atr'] = atr_rma(x.H.values, x.L.values, x.C.values, 20)
    lr = np.log(x.C).diff()
    x['score'] = (np.log(x.C) - np.log(x.C.shift(LOOK))) / (lr.rolling(LOOK).std() * np.sqrt(LOOK))
    return x


def build():
    syms = [s for g in GROUPS.values() for s in g]
    gid = {s: next(i for i, g in enumerate(GROUPS.values()) if s in g) for s in syms}
    dfs = {s: load_any(s) for s in syms}
    dl = {s: daily(dfs[s]) for s in syms}
    cal = sorted(set().union(*[set(d.index) for d in dl.values()]))
    reb = [d for d in cal if pd.Timestamp(d).weekday() == 4]
    trades = {s: [] for s in syms}
    pos = {}                                        # sym -> [dir, entry H1 idx, entry, sl, sd]

    def nxt_day(s, d):
        idx = dl[s].index
        k = idx.searchsorted(d, side='right')
        return idx[k] if k < len(idx) else None

    def close(s, ex_i, ex_p):
        d, ei, e, sl, sd = pos.pop(s)
        trades[s].append((ei, ex_i, e, ex_p, sd, d))

    def sl_scan(s, d0, d1):
        """d0 (shamil) se d1 (shamil nahi) tak SL lagi? -> (H1 idx, qeemat) ya None."""
        if s not in pos:
            return None
        d, ei, e, sl, sd = pos[s]
        df = dfs[s]
        x = dl[s]
        rows = x.loc[(x.index >= d0) & (x.index < d1)]
        for day, r in rows.iterrows():
            a, b = int(r.f), int(r.la) + 1
            lo, hi, op = df['Low'].values[a:b], df['High'].values[a:b], df['Open'].values[a:b]
            a0 = max(a, ei)
            if a0 >= b:
                continue
            seg_lo, seg_hi = df['Low'].values[a0:b], df['High'].values[a0:b]
            hit = np.nonzero(seg_lo <= sl)[0] if d > 0 else np.nonzero(seg_hi >= sl)[0]
            if len(hit):
                k = a0 + hit[0]
                p = min(df['Open'].values[k], sl) if d > 0 else max(df['Open'].values[k], sl)
                return k, p
        return None

    prev = None
    for rd in reb:
        # pichle rebalance ke agle din se aaj tak SL
        if prev is not None:
            for s in list(pos):
                st = pos[s]
                h = sl_scan(s, prev, rd + pd.Timedelta(days=1))
                if h:
                    close(s, *h)
        prev = rd + pd.Timedelta(days=1)
        sc = []
        for s in syms:
            x = dl[s]
            if rd in x.index:
                r = x.loc[rd]
                if not np.isnan(r.score) and not np.isnan(r.atr) and r.atr > 0:
                    sc.append((r.score, s))
        if len(sc) < 2 * NTOP:
            continue
        sc.sort(reverse=True)
        longs, shorts, cnt = [], [], {}
        for v, s in sc:
            if len(longs) < NTOP and cnt.get(('L', gid[s]), 0) < GCAP:
                longs.append(s)
                cnt[('L', gid[s])] = cnt.get(('L', gid[s]), 0) + 1
        for v, s in reversed(sc):
            if s in longs:
                continue
            if len(shorts) < NTOP and cnt.get(('S', gid[s]), 0) < GCAP:
                shorts.append(s)
                cnt[('S', gid[s])] = cnt.get(('S', gid[s]), 0) + 1
        want = {s: 1 for s in longs}
        want.update({s: -1 for s in shorts})
        for s in syms:
            nd = nxt_day(s, rd)
            if nd is None:
                continue
            f = int(dl[s].loc[nd, 'f'])
            o = dfs[s]['Open'].values[f]
            cur = pos.get(s)
            w = want.get(s, 0)
            if cur and cur[0] != w:
                close(s, f, o)
            if w and s not in pos:
                sd = SLM * dl[s].loc[rd, 'atr']
                pos[s] = [w, f, o, o - w * sd, sd]
    for s in list(pos):                              # data khatam: aakhri close
        df = dfs[s]
        close(s, len(df) - 1, df['Close'].values[-1])
    return syms, dfs, trades


def r_table(syms, dfs, trades):
    rows = []
    for s in syms:
        t = dfs[s]['t'].values
        for ei, xi, e, x, sd, d in trades[s]:
            nights = (t[xi] - t[ei]) / np.timedelta64(1, 'D')
            r = (d * (x - e) - COST * (e + x) - SWAP * nights * e) / sd
            rows.append((pd.Timestamp(t[ei], tz='UTC'), s, d, r, d * (x - e) / sd))
    return pd.DataFrame(rows, columns=['t', 'm', 'd', 'r', 'r0'])


def line(nm, r):
    n = len(r)
    if n < 2:
        return f'{nm}: {n} tr'
    e, se = r.mean(), r.std(ddof=1) / np.sqrt(n)
    return f'{nm}: {n:5d} tr, Exp {e:+.3f}R, SE {se:.3f}, Exp-2SE {e - 2 * se:+.3f}, jeet {100 * (r > 0).mean():.0f}%'


def edge(imtihan):
    syms, dfs, trades = build()
    t = r_table(syms, dfs, trades)
    t = t[t.t >= CUT] if imtihan else t[(t.t < CUT) & (t.t >= pd.Timestamp('2012-01-01', tz='UTC'))]
    print('A. EDGE ' + ('IMTIHAN 2019+ (EK dafa)' if imtihan else 'TALAASH 2012-2018'))
    print(line('KUL ', t.r))
    n, e, se = len(t), t.r.mean(), t.r.std(ddof=1) / np.sqrt(len(t))
    print(f'   bina kharcha {t.r0.mean():+.3f}R')
    print('   ' + line('BUY ', t[t.d > 0].r))
    print('   ' + line('SELL', t[t.d < 0].r))
    yr = t.groupby(t.t.dt.year).r.sum()
    print('   saal: ' + '  '.join(f'{y}:{v:+.1f}R' for y, v in yr.items()))
    months = max(1, t.t.dt.tz_localize(None).dt.to_period('M').nunique())
    print(f'   ~{n / months:.1f} tr/mahina; market: ' + ', '.join(f'{m} {g.r.sum():+.1f}' for m, g in t.groupby('m')))
    ok = (n >= 30 and e - 2 * se > 0) if imtihan else (n >= 100 and e - 2 * se > 0 and (yr > 0).mean() > 0.5)
    print('PASS' if ok else 'FAIL')


def ftmo(imtihan, risks):
    syms, dfs, trades = build()
    grid = np.unique(np.concatenate([d['t'].values.astype('datetime64[ns]').astype(np.int64) for d in dfs.values()]))
    cet = pd.to_datetime(grid, utc=True).tz_convert('Europe/Prague')
    cetday = (cet.year * 10000 + cet.month * 100 + cet.day).values
    mkts = [Mkt(s, dfs[s], grid) for s in syms]
    tl = [trades[s] for s in syms]
    if imtihan:
        starts = pd.date_range('2019-01-01', '2026-10-01', freq='MS', tz='UTC')
        end = grid[-1] + 1
    else:
        starts = pd.date_range('2012-01-01', '2018-12-01', freq='MS', tz='UTC')
        end = CUT.value
    print(f"B. FTMO {'IMTIHAN 2019+' if imtihan else 'CHUNAO 2012-2018'}: {len(starts)} challenge")
    print('risk% | pass fail(P1/P2) adhoora | P1fail% | pass mahine (median)')
    for r in risks:
        res = [run(mkts, [(r, tl, {})], s.value, end, grid, cetday) for s in starts]
        ps = [x for x in res if x[0] == 'pass']
        f1, f2 = sum(x[0] == 'fail1' for x in res), sum(x[0] == 'fail2' for x in res)
        ad = sum(x[0] == 'adhoora' for x in res)
        med = np.median([x[1] for x in ps]) if ps else float('nan')
        print(f'{r:5.2f} | {len(ps):4d} {f1 + f2:4d} ({f1}/{f2}) {ad:7d} | {100 * f1 / len(res):6.1f}% | {med:6.1f}', flush=True)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('part', choices=['edge', 'ftmo'])
    ap.add_argument('--imtihan', action='store_true')
    ap.add_argument('--risk', type=float, nargs='*', default=[0.25, 0.5, 0.75])
    a = ap.parse_args()
    edge(a.imtihan) if a.part == 'edge' else ftmo(a.imtihan, a.risk)


if __name__ == '__main__':
    main()
