#!/usr/bin/env python3
"""Koshish #75 (2 Nov 2026) - #74 "3Commas Bot" + hamara 4H trend filter (user "B", phir "D"), 2H x 11 market.
Qaida (badalna mana): docs/purana-haal.md, grep "Koshish #75 qaida".

  python3 tools/c3st_75.py                    # TALAASH: entry < 2019 + jaanch
  python3 tools/c3st_75.py --imtihan --pakka  # IMTIHAN 2019-01..aaj EK dafa (sirf TALAASH PASS par)

Signal / SL / TP / band / kharcha = #74 (`c3_74.py`) jyon ka tyon. NAYA: BUY signal sirf tab jab aakhri BAND 4H candle
(din 17:00 NY, block = (NY+7h).hour // 4) par Supertrend(10, 3) rukh UPAR; SELL sirf jab NEECHE. 4H ATR garam na ho = trade nahi.
Signal 2H candle 4H block ka doosra hissa ho to wahi 4H candle usi waqt band hoti hai (shamil); pehla hissa ho to pichhli 4H.
"""
import argparse
import sys

import numpy as np
import pandas as pd

import c3_74 as base
from c3_74 import blocks2h, mirror, report, signals, window, CUT, SLOW
from ftmo53_asli import ASLI
from ftmo68 import KCOST, KH
from ftmo_test import FILES, load, session_day, supertrend_up
from tokri47 import load_any


def trend4h(df):
    """(aakhri H1 idx har 4H candle, rukh upar, garam) - sirf band candle ki qeemat se."""
    day = session_day(df['t'])
    blk = ((df['t'].dt.tz_convert('America/New_York') + pd.Timedelta(hours=7)).dt.hour // 4).values
    g = pd.DataFrame({'i': np.arange(len(df)), 'd': day.values, 'b': blk,
                      'H': df['High'].values, 'L': df['Low'].values, 'C': df['Close'].values})
    g = g.groupby(['d', 'b'], sort=True).agg(la=('i', 'last'), H=('H', 'max'), L=('L', 'min'),
                                            C=('C', 'last')).sort_values('la')
    up, atr = supertrend_up(g['H'].values, g['L'].values, g['C'].values)
    return g['la'].values, up, ~np.isnan(atr)


def filtered_signals(df):
    """#74 signal, phir 4H filter. Lautata: (f, la, up, dn, slb, tpb, sls, tps)."""
    f, la, H, L, C = blocks2h(df)
    up, dn, slb, tpb, sls, tps = signals(H, L, C)
    la4, up4, ok4 = trend4h(df)
    k = np.searchsorted(la4, la, side='right') - 1          # aakhri 4H jis ki aakhri H1 <= signal 2H ki aakhri H1
    have = k >= 0
    kk = np.where(have, k, 0)
    warm = have & ok4[kk]
    up = up & warm & up4[kk]
    dn = dn & warm & ~up4[kk]
    return f, la, up, dn, slb, tpb, sls, tps


def c3st_trades(df, sig=None):
    """#74 c3_trades jaisa, magar filtered signal. Engine #74 se nakal (flip band, gap, SL pehle).
    sig diya ho (f, la, up, dn, slb, tpb, sls, tps) to wahi - jaanch (a) ke liye."""
    f, la, up, dn, slb, tpb, sls, tps = sig if sig is not None else filtered_signals(df)
    o, hi, lo, cl = (df[c].values for c in ('Open', 'High', 'Low', 'Close'))
    n1, nb, out = len(o), len(f), []
    j = 0
    while j < nb - 1:
        if not (up[j] or dn[j]):
            j += 1
            continue
        d = 1 if up[j] else -1
        sl, tp = (slb[j], tpb[j]) if d > 0 else (sls[j], tps[j])
        ei = f[j + 1]
        e = o[ei]
        sd = d * (e - sl)
        if not sd > 0:
            j += 1
            continue
        xi = None
        a, step = ei, 512
        while a < n1:
            b = min(n1, a + step)
            m = (lo[a:b] <= sl) | (hi[a:b] >= tp) if d > 0 else (hi[a:b] >= sl) | (lo[a:b] <= tp)
            kx = np.flatnonzero(m)
            if len(kx):
                xi = a + kx[0]
                break
            a, step = b, step * 2
        if xi is None:
            out.append((ei, n1 - 1, e, cl[-1], sd, d, j, 'khuli'))
            break
        op = o[xi]
        if d * (op - sl) <= 0 or d * (op - tp) >= 0:
            xp, tag = op, 'gap'
        elif (lo[xi] <= sl) if d > 0 else (hi[xi] >= sl):
            both = (hi[xi] >= tp) if d > 0 else (lo[xi] <= tp)
            xp, tag = sl, ('dono' if both else 'sl')
        else:
            xp, tag = tp, 'tp'
        out.append((ei, xi, e, xp, sd, d, j, tag))
        j = int(np.searchsorted(f, xi, side='right') - 1)
    return out


def jaanch(dfs, syms, trades):
    """(a) filter bina = #74 engine, (b) aaina, (c) look-ahead (filter samet), (d) har trade ka 4H rukh haath se."""
    print('JAANCH (sanity) - sirf entry < 2019:')
    ok_all = True
    # (a) filter hata kar wahi engine = #74 ke trade (engine nakal sahi)
    same74 = True
    for s in syms:
        df = dfs[s]
        f, la, H, L, C = blocks2h(df)
        tn = c3st_trades(df, (f, la) + tuple(signals(H, L, C)))
        t74 = base.c3_trades(df)
        same74 &= tn == t74
    print(f'  (a) filter bina engine == #74 c3_trades (11 market, poora data): {"HAAN" if same74 else "NAHI"}')
    ok_all &= same74
    # (b) aaina: ulti qeemat par BUY == asli SELL (Supertrend shuru mein 'neeche' se chalta - farq sirf shuru ke trade)
    nd = 0
    for s in syms:
        df = dfs[s]
        tw = window(df, s, trades[s], False)
        mw = window(df, s, c3st_trades(mirror(df)), False)
        A = {(x[0], x[5]) for x in tw}
        B = {(x[0], -x[5]) for x in mw}
        diff = len(A ^ B)
        nd += diff
        print(f'  (b) aaina {s:10s}: asli {len(tw):4d} tr (BUY {sum(x[5] > 0 for x in tw)}, SELL {sum(x[5] < 0 for x in tw)})'
              f' | ulti {len(mw):4d} | farq {diff}')
    tot = sum(len(window(dfs[s], s, trades[s], False)) for s in syms)
    am = nd <= max(5, 0.01 * tot)
    print(f'  (b) aaina kul farq {nd} (had <= 1%: {"THEEK" if am else "ZYADA"})')
    ok_all &= am
    # (c) look-ahead: data signal candle ke aakhri H1 par kaato -> filtered signal wahi
    rng = np.random.default_rng(75)
    sig_ok = tr_ok = True
    nchk = 0
    for s in syms:
        df = dfs[s]
        full = filtered_signals(df)
        la = full[1]
        ncut = int(np.searchsorted(df['t'].values, np.datetime64(CUT.tz_convert(None))))
        jmax = int(np.searchsorted(la, ncut - 1, side='right') - 1)
        for j in rng.integers(SLOW + 40, jmax, size=4):
            cut = df.iloc[:la[j] + 1]
            part = filtered_signals(cut)
            sig_ok &= all(np.array_equal(p, q[:j + 1], equal_nan=True) for p, q in zip(part[2:], full[2:]))
            tc = [x for x in c3st_trades(cut) if x[7] != 'khuli']
            tf = [x for x in trades[s] if x[1] <= la[j] and x[7] != 'khuli']
            tr_ok &= tc == tf
            nchk += 1
    print(f'  (c) look-ahead ({nchk} kaat): filtered signal sirf band candle se {"HAAN" if sig_ok else "NAHI"}'
          f' | kaate data ke trade = poore data ke {"HAAN" if tr_ok else "NAHI"}')
    ok_all &= sig_ok and tr_ok
    # (d) haath se: 3 trade - 4H rukh dobara alag hisaab se
    s = syms[0]
    df = dfs[s]
    la4, up4, ok4 = trend4h(df)
    for x in window(df, s, trades[s], False)[:3]:
        f, la, *_ = filtered_signals(df)
        k = np.searchsorted(la4, la[x[6]], side='right') - 1
        print(f'  (d) {s} {df["t"].iloc[x[0]]} {"BUY" if x[5] > 0 else "SELL"}: 4H band {df["t"].iloc[la4[k]]}'
              f' (signal 2H band {df["t"].iloc[la[x[6]]]}) rukh {"UPAR" if up4[k] else "NEECHE"}')
    print(f'  JAANCH: {"SAB THEEK" if ok_all else "GHALTI - natija mat maano"}\n')
    return ok_all


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--imtihan', action='store_true')
    ap.add_argument('--pakka', action='store_true')
    a = ap.parse_args()
    if a.imtihan and not a.pakka:
        print('INKAAR: IMTIHAN (2019+) sirf EK dafa, sirf TALAASH PASS ke baad, aur sirf --imtihan --pakka se.')
        sys.exit(2)
    syms = list(FILES) + list(KH)
    dfs = {s: (load(s) if s in FILES else load_any(s)) for s in syms}
    cost = {s: (0.75 * ASLI[s] if s in FILES else KCOST) for s in syms}
    trades = {s: c3st_trades(dfs[s]) for s in syms}
    if not jaanch(dfs, syms, trades):
        sys.exit(1)
    okT = report(dfs, syms, trades, cost, False)
    if a.imtihan:
        if not okT:
            print('INKAAR: TALAASH FAIL = band, IMTIHAN nahi.')
            sys.exit(2)
        print()
        report(dfs, syms, trades, cost, True)


if __name__ == '__main__':
    main()
