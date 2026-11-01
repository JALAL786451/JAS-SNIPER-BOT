#!/usr/bin/env python3
"""Koshish #71 (1 Nov 2026) - FTMO: #68 (trend 4H 0.75% + IBS 1% + khirki 0.15%) + G2 DOLLAR FILTER.
Qaida (badalna mana): docs/purana-haal.md, grep "Koshish #71 qaida". Research: docs/research/daur2-gold-agent.md (G2).

XAU aur XAG trend BUY sirf tab jab DXY ka 4H Supertrend (10 x 3) NEECHE ho. DXY = ICE formula se banaya
(Dukascopy H1: EURUSD, USDJPY, GBPUSD, USDCAD, USDSEK, USDCHF - data/duka/H1/JAS_ZIP), kyun ke Dukascopy
DOLLARIDXUSD sirf Dec 2017 se hai.

  python3 tools/ftmo71.py              # data jaanch 2018 -> TALAASH 2012-18 -> CHUNAO 2012-18 (pichla PASS ho to)
  python3 tools/ftmo71.py --imtihan    # 2019+ EK dafa (sirf TALAASH + CHUNAO PASS ke baad)
"""
import argparse

import numpy as np
import pandas as pd

from ftmo53_asli import ASLI, run_cost
from ftmo60 import summary
from ftmo68 import KCOST, KH, khirki_trades
from ftmo_4h import st4h_trades
from ftmo_test import FILES, Mkt, ibs_trades, load, session_day, supertrend_up
from tokri47 import load_any

W = {'EURUSD': -0.576, 'USDJPY': 0.136, 'GBPUSD': -0.119, 'USDCAD': 0.091, 'USDSEK': 0.042, 'USDCHF': 0.036}
GOLD = ('XAUUSD', 'XAGUSD')


def dxy_synth():
    """ICE DXY (constant chhor kar): sirf woh H1 jab chhe ke chhe hon. O/C formula se, H = max(O, C), L = min(O, C)."""
    m = None
    for s, w in W.items():
        try:
            d = load_any(s)[['t', 'Open', 'Close']]
        except FileNotFoundError:
            if s != 'USDSEK':
                raise
            print('USDSEK nahi mila -> baqi 5 se (qaida)')
            continue
        d = pd.DataFrame({'t': d['t'], 'o' + s: w * np.log(d['Open']), 'c' + s: w * np.log(d['Close'])})
        m = d if m is None else m.merge(d, on='t', how='inner')
    o = np.exp(m[[c for c in m if c.startswith('o')]].sum(axis=1).values) * 50.14348112
    c = np.exp(m[[c for c in m if c.startswith('c')]].sum(axis=1).values) * 50.14348112
    return pd.DataFrame({'t': m['t'], 'Open': o, 'High': np.maximum(o, c), 'Low': np.minimum(o, c), 'Close': c})


def blocks4h(df):
    """st4h_trades wala 4H block: (key (din, block), aakhri H1 waqt ns, Supertrend upar?)."""
    day = session_day(df['t'])
    blk = ((df['t'].dt.tz_convert('America/New_York') + pd.Timedelta(hours=7)).dt.hour // 4).values
    g = pd.DataFrame({'i': np.arange(len(df)), 'd': day.values, 'b': blk,
                      'H': df['High'].values, 'L': df['Low'].values, 'C': df['Close'].values})
    g = g.groupby(['d', 'b'], sort=True).agg(f=('i', 'first'), la=('i', 'last'),
                                            H=('H', 'max'), L=('L', 'min'), C=('C', 'last')).sort_values('f')
    up, _ = supertrend_up(g['H'].values, g['L'].values, g['C'].values)
    tl = df['t'].values.astype('datetime64[ns]').astype(np.int64)[g['la'].values]
    return g.index.values, tl, up, g['C'].values


def data_check(syn):
    """2018: banaya DXY vs Dukascopy DOLLARIDXUSD. corr >= 0.95 aur 4H rukh >= 90% same."""
    du = load_any('DOLLARIDXUSD')
    a0, a1 = pd.Timestamp('2018-01-01', tz='UTC'), pd.Timestamp('2019-01-01', tz='UTC')
    dd = []
    for d in (syn, du):
        x = d[(d['t'] >= a0 - pd.Timedelta(days=40)) & (d['t'] < a1)].reset_index(drop=True)
        k, tl, up, cl = blocks4h(x)
        dd.append((pd.Series(up, index=pd.MultiIndex.from_tuples(k)), x.assign(sd=session_day(x['t']))))
    (u1, x1), (u2, x2) = dd
    keep = [k for k in u1.index.intersection(u2.index) if pd.Timestamp('2018-01-01') <= k[0] < pd.Timestamp('2019-01-01')]
    agree = np.mean(u1.loc[keep].values == u2.loc[keep].values)
    c1 = x1.groupby('sd')['Close'].last()
    c2 = x2.groupby('sd')['Close'].last()
    j = c1.index.intersection(c2.index)
    j = j[(j >= pd.Timestamp('2018-01-01')) & (j < pd.Timestamp('2019-01-01'))]
    r1, r2 = np.log(c1.loc[j]).diff().dropna(), np.log(c2.loc[j]).diff().dropna()
    corr = np.corrcoef(r1.values, r2.values)[0, 1]
    ok = corr >= 0.95 and agree >= 0.90
    print(f'DATA JAANCH 2018: daily corr {corr:.3f} (>= 0.95), 4H rukh same {agree * 100:.1f}% (>= 90%), '
          f'{len(r1)} din, {len(keep)} block -> {"PASS" if ok else "FAIL (test nahi)"}')
    return ok


def g2_split(df, trades, dx_tl, dx_up):
    """(rakhe, roke): entry signal = gold block j ka aakhri H1 (entry idx - 1); DXY = us waqt tak ka aakhri poora 4H block."""
    t = df['t'].values.astype('datetime64[ns]').astype(np.int64)
    keep, stop = [], []
    for x in trades:
        k = np.searchsorted(dx_tl, t[x[0] - 1], side='right') - 1
        (stop if k >= 0 and dx_up[k] else keep).append(x)       # DXY na mile = trade lo
    return keep, stop


def rstat(df, tl, a, b):
    t = df['t'].values.astype('datetime64[ns]').astype(np.int64)
    r = np.array([(x[3] - x[2]) / x[4] for x in tl if a <= t[x[0]] < b])
    if len(r) < 2:
        return len(r), np.nan, np.nan, np.nan
    return len(r), r.mean(), r.std(ddof=1) / np.sqrt(len(r)), np.mean(r > 0) * 100


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--imtihan', action='store_true')
    a = ap.parse_args()
    syn = dxy_synth()
    print(f'Banaya DXY: {len(syn)} H1, {syn["t"].iloc[0]:%Y-%m-%d} se {syn["t"].iloc[-1]:%Y-%m-%d}')
    if not data_check(syn):
        return
    _, dx_tl, dx_up, _ = blocks4h(syn)
    base = list(FILES)
    syms = base + list(KH)
    dfs = {s: load(s) for s in base}
    dfs.update({s: load_any(s) for s in KH})
    trend = [st4h_trades(dfs[s], 6.0) if s in base else [] for s in syms]
    split = {s: g2_split(dfs[s], trend[syms.index(s)], dx_tl, dx_up) for s in GOLD}
    t0, t1 = pd.Timestamp('2012-01-01', tz='UTC').value, pd.Timestamp('2019-01-01', tz='UTC').value
    print('TALAASH 2012-2018 (kharche se pehle) | rakhe (DXY neeche) | roke (DXY upar)')
    kk, ss = [], []
    for s in GOLD:
        kp, st = split[s]
        n1, m1, e1, w1 = rstat(dfs[s], kp, t0, t1)
        n2, m2, e2, w2 = rstat(dfs[s], st, t0, t1)
        print(f'  {s}: {n1} tr {m1:+.3f}R +-{e1:.3f} jeet {w1:.0f}% | {n2} tr {m2:+.3f}R +-{e2:.3f} jeet {w2:.0f}%')
        t = dfs[s]['t'].values.astype('datetime64[ns]').astype(np.int64)
        kk += [(x[3] - x[2]) / x[4] for x in kp if t0 <= t[x[0]] < t1]
        ss += [(x[3] - x[2]) / x[4] for x in st if t0 <= t[x[0]] < t1]
    okT = np.mean(kk) > np.mean(ss)
    print(f'  KUL: rakhe {len(kk)} tr {np.mean(kk):+.3f}R | roke {len(ss)} tr {np.mean(ss):+.3f}R -> TALAASH {"PASS" if okT else "FAIL = band"}')
    if not okT:
        return
    trend_g2 = [split[s][0] if s in GOLD else tl for s, tl in zip(syms, trend)]
    grid = np.unique(np.concatenate([d['t'].values.astype('datetime64[ns]').astype(np.int64) for d in dfs.values()]))
    cet = pd.to_datetime(grid, utc=True).tz_convert('Europe/Prague')
    cetday = (cet.year * 10000 + cet.month * 100 + cet.day).values
    mk = [Mkt(s, dfs[s], grid) for s in syms]
    ibs = [ibs_trades(dfs[s]) if s in ('US500', 'USTEC') else [] for s in syms]
    kh = [khirki_trades(dfs[s], *KH[s]) if s in KH else [] for s in syms]
    cost = [0.75 * ASLI[s] if s in base else KCOST for s in syms]
    if a.imtihan:
        starts, end = pd.date_range('2019-01-01', '2026-10-01', freq='MS', tz='UTC'), grid[-1] + 1
    else:
        starts, end = pd.date_range('2012-01-01', '2018-12-01', freq='MS', tz='UTC'), t1
    print(f"{'IMTIHAN 2019+' if a.imtihan else 'CHUNAO 2012-2018'}: {len(starts)} challenge (kharcha asli)")
    print('system     | pass fail(P1/P2) adhoora | P1fail% | pass mahine median')
    rows = {}
    for name, tr in (('#68', trend), ('#68 + G2', trend_g2)):
        sy = [(0.75, tr, {}), (1.0, ibs, {}), (0.15, kh, {})]
        res = [run_cost(mk, sy, s0.value, end, grid, cetday, cost) for s0 in starts]
        ps, f1, f2, ad, med = summary(res)
        rows[name] = (ps, f1, f2, ad, med, 100 * f1 / len(res))
        print(f'{name:10s} | {ps:4d} {f1 + f2:4d} ({f1}/{f2}) {ad:7d} | {100 * f1 / len(res):6.1f}% | {med:6.1f}', flush=True)
    b, r = rows['#68'], rows['#68 + G2']
    if not a.imtihan:
        ok = r[5] < 20 and r[0] > r[1] + r[2] and r[0] - r[1] - r[2] >= b[0] - b[1] - b[2]
        print('CHUNAO: ' + ('PASS -> IMTIHAN (--imtihan) EK dafa' if ok else 'FAIL = band (IMTIHAN nahi)'))
    else:
        okI = r[1] + r[2] == 0 and r[0] >= b[0] and r[4] < b[4]
        print('IMTIHAN: ' + ('PASS' if okI else 'FAIL') + f' (shart: fail 0, pass >= {b[0]}, median < {b[4]:.1f})')


if __name__ == '__main__':
    main()
