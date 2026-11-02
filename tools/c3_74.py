#!/usr/bin/env python3
"""Koshish #74 (2 Nov 2026) - "3Commas Bot" (user ka Pine, defaults): EMA21 / EMA50 cross, 2H x 11 market, BUY + SELL.
Qaida (badalna mana): docs/purana-haal.md, grep "Koshish #74 qaida".

  python3 tools/c3_74.py                    # TALAASH: entry < 2019 (XAU/XAG 2003 se, baqi data shuru se) + jaanch
  python3 tools/c3_74.py --imtihan --pakka  # IMTIHAN 2019-01..aaj EK dafa (sirf TALAASH PASS par)
                                            # (--imtihan akela = inkaar; --pakka zaroori)

Qaida (mukhtasar): 2H candle = Dukascopy H1 (17:00 NY din, NY+7h hour // 2). EMA(close) 21 / 50 (ta.ema, SMA se shuru),
ATR14 (RMA), swing 5 (signal candle samet). BUY: EMA21 crossover EMA50 (band candle) -> agli 2H open; SL = lowest low(5)
- 1 x ATR14; TP = signal close + 1 x (signal close - SL). SELL ulta. Flip band (nayi trade sirf khali hone par).
Band H1 par: SL ya TP (dono ek H1 candle mein = SL), gap = open par. Fill SL ke paar (faasla <= 0) = trade nahi.
1R = |entry - SL|. Kharcha 0.75 x ASLI (#53) har taraf / index CFD 0.02%, swap 3%/saal har calendar raat (ftmo73.net_r).
PASS: TALAASH kul >= 100 tr aur Exp - 2SE > 0; IMTIHAN kul >= 30 tr aur Exp - 2SE > 0.
"""
import argparse
import sys

import numpy as np
import pandas as pd

from ftmo53_asli import ASLI
from ftmo68 import KCOST, KH
from ftmo73 import net_r
from ftmo_test import FILES, atr_rma, load, session_day
from tokri47 import load_any

FAST, SLOW, ATR_N, SWING, RNR, ATR_K = 21, 50, 14, 5, 1.0, 1.0
CUT = pd.Timestamp('2019-01-01', tz='UTC')
T0 = {'XAUUSD': '2003-01-01', 'XAGUSD': '2003-01-01'}      # baqi: data shuru se


def ema(x, n):
    """TradingView ta.ema: alpha 2/(n+1); pehli qeemat = SMA(n) (pehle n-1 candle na)."""
    a = 2.0 / (n + 1)
    out = np.full(len(x), np.nan)
    if len(x) >= n:
        out[n - 1] = x[:n].mean()
        for i in range(n, len(x)):
            out[i] = a * x[i] + (1 - a) * out[i - 1]
    return out


def blocks2h(df):
    """2H candle: (pehli H1 idx, aakhri H1 idx, H, L, C) - din 17:00 NY, block = (NY+7h).hour // 2."""
    day = session_day(df['t'])
    blk = ((df['t'].dt.tz_convert('America/New_York') + pd.Timedelta(hours=7)).dt.hour // 2).values
    g = pd.DataFrame({'i': np.arange(len(df)), 'd': day.values, 'b': blk,
                      'H': df['High'].values, 'L': df['Low'].values, 'C': df['Close'].values})
    g = g.groupby(['d', 'b'], sort=True).agg(f=('i', 'first'), la=('i', 'last'),
                                            H=('H', 'max'), L=('L', 'min'), C=('C', 'last')).sort_values('f')
    return g['f'].values, g['la'].values, g['H'].values, g['L'].values, g['C'].values


def signals(H, L, C):
    """Har 2H candle j par (sirf j tak ke band candle): up / dn cross, BUY SL/TP, SELL SL/TP."""
    e1, e2 = ema(C, FAST), ema(C, SLOW)
    atr = atr_rma(H, L, C, ATR_N)
    p1, p2 = np.r_[np.nan, e1[:-1]], np.r_[np.nan, e2[:-1]]
    ok = ~(np.isnan(e1) | np.isnan(e2) | np.isnan(p1) | np.isnan(p2) | np.isnan(atr))
    up = ok & (e1 > e2) & (p1 <= p2)                       # ta.crossover
    dn = ok & (e1 < e2) & (p1 >= p2)                       # ta.crossunder
    ll = pd.Series(L).rolling(SWING).min().values          # ta.lowest(low, 5) - signal candle samet
    hh = pd.Series(H).rolling(SWING).max().values
    ok &= ~(np.isnan(ll) | np.isnan(hh))
    up &= ok
    dn &= ok
    slb = ll - ATR_K * atr
    tpb = C + RNR * (C - slb)
    sls = hh + ATR_K * atr
    tps = C - RNR * (sls - C)
    return up, dn, slb, tpb, sls, tps


def c3_trades(df):
    """(entry H1 idx, exit H1 idx, entry, exit, 1R doori, rukh, signal 2H idx, nishan) - ek waqt ek trade (flip band).
    nishan: 'tp' / 'sl' / 'gap' / 'dono' (SL + TP ek H1 candle mein -> SL) / 'khuli' (data khatam)."""
    f, la, H, L, C = blocks2h(df)
    up, dn, slb, tpb, sls, tps = signals(H, L, C)
    o, hi, lo, cl = (df[c].values for c in ('Open', 'High', 'Low', 'Close'))
    n1, nb, out = len(o), len(f), []
    j = 0
    while j < nb - 1:
        if not (up[j] or dn[j]):
            j += 1
            continue
        d = 1 if up[j] else -1
        sl, tp = (slb[j], tpb[j]) if d > 0 else (sls[j], tps[j])
        ei = f[j + 1]                                      # agli 2H candle ki open
        e = o[ei]
        sd = d * (e - sl)
        if not sd > 0:                                     # fill SL ke paar = trade nahi
            j += 1
            continue
        xi = xp = None
        a, step = ei, 512
        while a < n1:
            b = min(n1, a + step)
            m = (lo[a:b] <= sl) | (hi[a:b] >= tp) if d > 0 else (hi[a:b] >= sl) | (lo[a:b] <= tp)
            k = np.flatnonzero(m)
            if len(k):
                xi = a + k[0]
                break
            a, step = b, step * 2
        if xi is None:
            out.append((ei, n1 - 1, e, cl[-1], sd, d, j, 'khuli'))
            break
        op = o[xi]
        if d * (op - sl) <= 0 or d * (op - tp) >= 0:       # gap: open SL ya TP ke paar -> open par
            xp, tag = op, 'gap'
        elif (lo[xi] <= sl) if d > 0 else (hi[xi] >= sl):  # SL pehle (ehtiyat)
            both = (hi[xi] >= tp) if d > 0 else (lo[xi] <= tp)
            xp, tag = sl, ('dono' if both else 'sl')
        else:
            xp, tag = tp, 'tp'
        out.append((ei, xi, e, xp, sd, d, j, tag))
        j = int(np.searchsorted(f, xi, side='right') - 1)  # jis 2H candle mein band hui - wahi se naya signal
    return out


def mirror(df):
    m = df.copy()
    m['Open'], m['High'], m['Low'], m['Close'] = -df['Open'], -df['Low'], -df['High'], -df['Close']
    return m


def window(df, s, trades, imtihan):
    t = df['t'].values.astype('datetime64[ns]').astype(np.int64)
    if imtihan:
        a0, a1 = CUT.value, np.iinfo(np.int64).max
    else:
        a0 = pd.Timestamp(T0[s], tz='UTC').value if s in T0 else np.iinfo(np.int64).min
        a1 = CUT.value
    return [x for x in trades if a0 <= t[x[0]] < a1]


def st(r):
    r = np.asarray(r, float)
    n = len(r)
    if n == 0:
        return 0, np.nan, np.nan, np.nan
    se = r.std(ddof=1) / np.sqrt(n) if n > 1 else np.nan
    return n, r.mean(), se, 100 * np.mean(r > 0)


def fmt(n, ex, se, jt):
    return f'{n:5d} {ex:+.3f}R +-{se:.3f} jeet {jt:3.0f}%' if n > 1 else f'{n:5d} {"-":>21s}'


def jaanch(dfs, syms, trades):
    """(a) aaina, (b) look-ahead, (c) ginti - sirf TALAASH khirki (entry < 2019); natija (R) yahan nahi."""
    print('JAANCH (sanity) - sirf entry < 2019:')
    ok_all = True
    for s in syms:
        df = dfs[s]
        tw = window(df, s, trades[s], False)
        mw = window(df, s, c3_trades(mirror(df)), False)
        same = len(tw) == len(mw) and all(
            (a[0], a[1], a[4], a[5], a[6], a[7]) == (b[0], b[1], b[4], -b[5], b[6], b[7]) and a[2] == -b[2] and a[3] == -b[3]
            for a, b in zip(tw, mw))
        ok_all &= same
        print(f'  (a) aaina {s:10s}: asli {len(tw):4d} tr (BUY {sum(x[5] > 0 for x in tw)}, SELL {sum(x[5] < 0 for x in tw)})'
              f' | ulti qeemat {len(mw):4d} tr | BUY(ulta) == SELL(asli) aur ulta: {"HAAN" if same else "NAHI"}')
    # (b) look-ahead: data ko signal candle ke aakhri H1 par kaato -> us tak ke signal / SL / TP badalne nahi chahiye;
    #     entry = agli 2H ki pehli H1 (> signal candle ki aakhri H1); kaate data ke band trade = poore data ke trade
    rng = np.random.default_rng(74)
    la_ok = sig_ok = ent_ok = tr_ok = True
    nchk = 0
    for s in syms:
        df = dfs[s]
        f, la, H, L, C = blocks2h(df)
        full = signals(H, L, C)
        ncut = int(np.searchsorted(df['t'].values, np.datetime64(CUT.tz_convert(None))))
        jmax = int(np.searchsorted(la, ncut - 1, side='right') - 1)
        for j in rng.integers(SLOW + 10, jmax, size=4):
            cut = df.iloc[:la[j] + 1]
            f2, la2, H2, L2, C2 = blocks2h(cut)
            part = signals(H2, L2, C2)
            la_ok &= len(f2) == j + 1 and np.array_equal(f2, f[:j + 1])
            sig_ok &= all(np.array_equal(p, q[:j + 1], equal_nan=True) for p, q in zip(part, full))
            tc = [x for x in c3_trades(cut) if x[7] != 'khuli']
            tf = [x for x in trades[s] if x[0] <= la[j] and x[7] != 'khuli']
            tf = [x for x in tf if x[1] <= la[j]]
            tr_ok &= tc == tf
            nchk += 1
        ent_ok &= all(x[0] == f[x[6] + 1] and x[0] == la[x[6]] + 1 and df['t'].iloc[x[0]] > df['t'].iloc[la[x[6]]]
                      for x in trades[s])
    print(f'  (b) look-ahead ({nchk} kaat, {len(syms)} market): 2H candle wahi {"HAAN" if la_ok else "NAHI"} | signal/SL/TP sirf'
          f' band candle se {"HAAN" if sig_ok else "NAHI"} | entry = agli 2H open {"HAAN" if ent_ok else "NAHI"}'
          f' | kaate data ke trade = poore data ke {"HAAN" if tr_ok else "NAHI"}')
    ok_all &= la_ok and sig_ok and ent_ok and tr_ok
    print(f'  JAANCH: {"SAB THEEK" if ok_all else "GHALTI - natija mat maano"}\n')
    return ok_all


def report(dfs, syms, trades, cost, imtihan):
    name = 'IMTIHAN entry 2019-01..aaj' if imtihan else 'TALAASH entry < 2019 (XAU/XAG 2003 se, baqi data shuru se)'
    print(f'{name} - R kharcha (dono taraf) + swap ke BAAD; 1R = |entry - SL|')
    print(f'  {"market":10s} | {"BUY  N   Exp      SE      jeet":31s} | {"SELL N   Exp      SE      jeet":31s} | (c) ginti')
    allr, allg, side = [], [], {1: [], -1: []}
    tags = {}
    for s in syms:
        tw = window(dfs[s], s, trades[s], imtihan)
        row = []
        for d in (1, -1):
            r = [net_r(dfs[s], x, cost[s]) for x in tw if x[5] == d]
            side[d] += r
            row.append(fmt(*st(r)))
        allr += [net_r(dfs[s], x, cost[s]) for x in tw]
        allg += [x[5] * (x[3] - x[2]) / x[4] for x in tw]
        for x in tw:
            tags[x[7]] = tags.get(x[7], 0) + 1
        print(f'  {s:10s} | {row[0]} | {row[1]} | {len(tw):4d}')
    print(f'  {"BUY kul":10s} | {fmt(*st(side[1]))}')
    print(f'  {"SELL kul":10s} | {fmt(*st(side[-1]))}')
    n, ex, se, jt = st(allr)
    print(f'  KUL       : {n} tr, Exp {ex:+.3f}R, SE {se:.3f}, Exp-2SE {ex - 2 * se:+.3f}, jeet {jt:.0f}%')
    ng, exg, seg, jtg = st(allg)
    print(f'  maloomat - KUL kharche se PEHLE (gross): Exp {exg:+.3f}R, SE {seg:.3f}, jeet {jtg:.0f}%')
    print(f'  maloomat - band kaise: ' + ', '.join(f'{k} {v}' for k, v in sorted(tags.items()))
          + '  (dono = SL aur TP ek H1 candle mein -> SL maana)')
    need = 30 if imtihan else 100
    ok = n >= need and ex - 2 * se > 0
    print(f'{"IMTIHAN" if imtihan else "TALAASH"}: {"PASS" if ok else "FAIL"}  (shart: KUL N >= {need} aur KUL Exp - 2SE > 0)')
    return ok


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--imtihan', action='store_true', help='2019+ EK dafa - sirf --pakka ke saath')
    ap.add_argument('--pakka', action='store_true')
    a = ap.parse_args()
    if a.imtihan and not a.pakka:
        print('INKAAR: IMTIHAN (2019+) sirf EK dafa, sirf TALAASH PASS ke baad, aur sirf --imtihan --pakka se.')
        sys.exit(2)
    syms = list(FILES) + list(KH)
    dfs = {s: (load(s) if s in FILES else load_any(s)) for s in syms}
    cost = {s: (0.75 * ASLI[s] if s in FILES else KCOST) for s in syms}
    trades = {s: c3_trades(dfs[s]) for s in syms}
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
