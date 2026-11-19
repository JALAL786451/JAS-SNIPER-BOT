#!/usr/bin/env python3
"""Koshish #105z (18 Nov 2026) - JAS Naqsha+5EA ke ZONES (S/R = SZ/DZ) ka asar #34 4H tokri ki trades par.

Qaida (badalna mana): docs/research/zone-test-qaida.md (test se PEHLE commit cfda96d).
Data: data/ftmo/*.zip (Dukascopy H1, UTC) -> 4H / 1D / 1W NY 17:00 se jura.

  python3 tools/zone_test.py                 # TALAASH (entry < 2019)
  python3 tools/zone_test.py --imtihan A     # 2019+ EK dafa, sirf TALAASH PASS wala mafrooza (A ya B)
"""
import argparse

import numpy as np
import pandas as pd

from ftmo_test import ST_MULT, load, session_day, supertrend_up
from gold_st_tf import COST_PCT, SWAP

MARKETS = {'XAUUSD': 0.50, 'XAGUSD': 0.0, 'US500': 0.0, 'USTEC': 0.0}
CUT = pd.Timestamp('2019-01-01', tz='UTC')
H1 = pd.Timedelta(hours=1)
TOL, HZ, MAXL, NEAR, PIV = 0.25, 0.10, 80, 1.0, 5


def h4_bars(df):
    """gold_st_tf.h4_from_h1 jaisa, saath mein band hone ka waqt (te)."""
    day = session_day(df['t'])
    blk = ((df['t'].dt.tz_convert('America/New_York') + pd.Timedelta(hours=7)).dt.hour // 4).values
    g = df.groupby([day.values, blk])
    x = g.agg(t=('t', 'first'), tl=('t', 'last'), Open=('Open', 'first'), High=('High', 'max'),
              Low=('Low', 'min'), Close=('Close', 'last')).sort_values('t').reset_index(drop=True)
    x['te'] = x['tl'] + H1
    return x


def htf_bars(df, key):
    g = df.groupby(key.values)
    x = g.agg(t=('t', 'first'), tl=('t', 'last'), High=('High', 'max'), Low=('Low', 'min'),
              Close=('Close', 'last')).sort_values('t').reset_index(drop=True)
    x['te'] = x['tl'] + H1
    return x


def atr14(x):
    h, l, c = x['High'].values, x['Low'].values, x['Close'].values
    tr = np.maximum(h - l, np.maximum(abs(h - np.r_[np.nan, c[:-1]]), abs(l - np.r_[np.nan, c[:-1]])))
    tr[0] = h[0] - l[0]
    a = np.full(len(c), np.nan)
    if len(c) >= 14:
        a[13] = tr[:14].mean()
        for i in range(14, len(c)):
            a[i] = (a[i - 1] * 13 + tr[i]) / 14
    return a


def pivots(x, rank):
    """(pakka hone ka waqt = pivot ke 5 candle baad band, qeemat, rank)."""
    h, l, te = x['High'].values, x['Low'].values, x['te'].values
    out = []
    for p in range(PIV, len(x) - PIV):
        if h[p] > h[p - PIV:p].max() and h[p] >= h[p + 1:p + PIV + 1].max():
            out.append((te[p + PIV], h[p], rank))
        if l[p] < l[p - PIV:p].min() and l[p] <= l[p + 1:p + PIV + 1].min():
            out.append((te[p + PIV], l[p], rank))
    return out


def trades(x, min_usd):
    """gold_st_tf.trades jyon ka tyon (cost_on) + entry signal ka index."""
    o, h, l, c = (x[k].values for k in ('Open', 'High', 'Low', 'Close'))
    up, atr = supertrend_up(h, l, c)
    day = session_day(x['t']).values
    tt = x['t'].values
    out, pos = [], 0
    for i in range(1, len(x) - 1):
        if pos == 0 and up[i] and not up[i - 1] and i > 30:
            pos, e, ep, ru, si = 1, i + 1, o[i + 1], ST_MULT * atr[i], i
        elif pos == 1 and not up[i] and up[i - 1]:
            xp = o[i + 1]
            nights = (pd.Timestamp(day[i + 1]) - pd.Timestamp(day[e])).days
            cost = max(min_usd, COST_PCT * (ep + xp)) + SWAP * nights * ep
            out.append((pd.Timestamp(tt[e], tz='UTC'), (xp - ep - cost) / ru, si, ep))
            pos = 0
    return pd.DataFrame(out, columns=['t', 'r', 'si', 'ep'])


def zone_dist(df, x, tr):
    """Har trade ke liye qareeb R aur S ki doori (ATR-D), Pine j3.2 ke zone qaide se."""
    d = htf_bars(df, session_day(df['t']))
    sd = session_day(df['t'])
    w = htf_bars(df, sd - pd.to_timedelta(sd.dt.weekday, unit='D'))
    aD = atr14(d)
    dte = d['te'].values
    ev = sorted(pivots(x, 2) + pivots(d, 3) + pivots(w, 4), key=lambda e: (e[0], e[2]))
    xte, xc = x['te'].values, x['Close'].values

    def atr_at(t):
        k = np.searchsorted(dte, t, side='right') - 1
        return aD[k] if k >= 0 else np.nan

    lv = []  # [p, rk, n]
    k = 0
    dR, dS = [], []
    for si, ep in zip(tr['si'].values, tr['ep'].values):
        now = x['t'].values[si]  # bar si ke shuru tak pakke (Pine: [1] + lookahead_on)
        while k < len(ev) and ev[k][0] <= now:
            te, p, rk = ev[k]
            k += 1
            a = atr_at(te)
            if np.isnan(a) or a <= 0:
                continue
            for L in lv:
                if abs(L[0] - p) <= TOL * a:
                    L[0] = (L[0] * L[2] + p) / (L[2] + 1)
                    L[2] += 1
                    L[1] = max(L[1], rk)
                    break
            else:
                lv.append([p, rk, 1])
                if len(lv) > MAXL:
                    j = np.searchsorted(xte, te, side='right') - 1
                    px = xc[max(j, 0)]
                    wi = min(range(len(lv) - 1), key=lambda i: (lv[i][1], lv[i][2], -abs(lv[i][0] - px)))
                    lv.pop(wi)
        a = atr_at(now)
        r_, s_ = np.inf, np.inf
        if not np.isnan(a) and a > 0:
            hz = HZ * a
            for p, _, _ in lv:
                if p > ep:
                    r_ = min(r_, max(0.0, p - hz - ep) / a)
                elif p < ep:
                    s_ = min(s_, max(0.0, ep - p - hz) / a)
                else:
                    r_, s_ = 0.0, 0.0
        dR.append(r_)
        dS.append(s_)
    tr = tr.copy()
    tr['dR'], tr['dS'] = dR, dS
    return tr


def st(r):
    n = len(r)
    ex = r.mean() if n else np.nan
    se = r.std(ddof=1) / np.sqrt(n) if n > 1 else np.nan
    return n, ex, se


def compare(name, good, bad):
    ng, eg, sg = st(good)
    nb, eb, sb = st(bad)
    diff, sed = eg - eb, np.sqrt(sg ** 2 + sb ** 2)
    print(f'  {name}: achha {ng} tr Exp {eg:+.4f} | bura {nb} tr Exp {eb:+.4f} | '
          f'farq {diff:+.4f} SE {sed:.4f} -> {diff / sed:+.2f} SE')
    return ng, nb, diff, sed


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--imtihan', choices=['A', 'B'])
    a = ap.parse_args()
    print(f'IMTIHAN 2019+ (EK dafa) mafrooza {a.imtihan}' if a.imtihan else 'TALAASH entry < 2019')
    allt = []
    for sym, mn in MARKETS.items():
        df = load(sym)
        if not a.imtihan:
            df = df[df['t'] < CUT + pd.Timedelta(days=1)].reset_index(drop=True)
        x = h4_bars(df)
        t = zone_dist(df, x, trades(x, mn))
        t = t[t['t'] >= CUT] if a.imtihan else t[t['t'] < CUT]
        t['m'] = sym
        n, ex, se = st(t['r'])
        print(f'{sym:7s}: {n} tr, Exp {ex:+.4f}R | R<1 ATR-D {100 * (t["dR"] < NEAR).mean():.0f}%, '
              f'S<1 ATR-D {100 * (t["dS"] < NEAR).mean():.0f}%')
        compare('A', t[t['dR'] >= NEAR]['r'], t[t['dR'] < NEAR]['r'])
        compare('B', t[t['dS'] < NEAR]['r'], t[t['dS'] >= NEAR]['r'])
        allt.append(t)
    t = pd.concat(allt)
    n, ex, se = st(t['r'])
    print(f'\nKUL: {n} tr, Exp {ex:+.4f}R, Exp-2SE {ex - 2 * se:+.4f}')
    res = {'A': compare('A (SZ sar par: R < 1 ATR-D = bura)', t[t['dR'] >= NEAR]['r'], t[t['dR'] < NEAR]['r']),
           'B': compare('B (DZ paon mein: S < 1 ATR-D = achha)', t[t['dS'] < NEAR]['r'], t[t['dS'] >= NEAR]['r'])}
    if not a.imtihan:
        for h, (ng, nb, diff, sed) in res.items():
            ok = ng >= 50 and nb >= 50 and diff > 2 * sed
            print(f'  {h}: TALAASH {"PASS" if ok else "FAIL"}')
    else:
        h = a.imtihan
        f = t[t['dR'] >= NEAR] if h == 'A' else t[t['dS'] < NEAR]
        fn, fe, fs = st(f['r'])
        ok = res[h][2] > 0 and fe - 2 * fs > 0 and fe >= ex
        print(f'  filter tokri: {fn} tr, Exp {fe:+.4f}, Exp-2SE {fe - 2 * fs:+.4f} (poori {ex:+.4f}) -> '
              f'{"PASS" if ok else "FAIL"}')


if __name__ == '__main__':
    main()
