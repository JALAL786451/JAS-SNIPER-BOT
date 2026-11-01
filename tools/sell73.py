#!/usr/bin/env python3
"""Koshish #73 (1 Nov 2026) - SELL ke 2 aaina (mirror) leg + "BUY ko tarjeeh" qaida.
Qaida (badalna mana): docs/purana-haal.md, grep "Koshish #73 qaida". FTMO hisaab: tools/ftmo73.py.

  S1 trend 4H SELL = tools/ftmo_4h.st4h_trades ka aaina (Supertrend neeche mude -> agli 4H open par SELL,
     SL = entry + k x ATR10(4H), band = Supertrend upar mude to agli 4H open, ya SL).
  S2 IBS SELL = tools/ftmo_test.ibs_trades ka aaina (IBS > 0.8 aur close < SMA200 -> din ke close par SELL,
     SL 3 x ATR14 oopar, band = IBS < 0.2 wala din ya 5 din, close par).
  Har trade: (entry H1 idx, exit H1 idx, entry, exit, SL doori, -1).
Judge #73 (1 Nov): buy_ko_tarjeeh SELL banne ke BAAD lagta hai - ruki/kati S2 apni asal band tak nayi S2 rokti hai
(asli EA agle din dobara dekhe) + S2/B2 index ek bar aage. Theek karne par 228 tr -0.0032R = FAIL wahi. SELL band.
"""
import numpy as np
import pandas as pd

from ftmo_test import ATR_LEN, atr_rma, session_day, supertrend_up


def st4h_sell_trades(df, k, gate=None):
    """S1. gate(df, i4h_signal_last_h1_idx) -> True = SELL ki ijazat (None = hamesha)."""
    day = session_day(df['t'])
    blk = ((df['t'].dt.tz_convert('America/New_York') + pd.Timedelta(hours=7)).dt.hour // 4).values
    g = pd.DataFrame({'i': np.arange(len(df)), 'd': day.values, 'b': blk,
                      'H': df['High'].values, 'L': df['Low'].values, 'C': df['Close'].values})
    g = g.groupby(['d', 'b'], sort=True).agg(f=('i', 'first'), la=('i', 'last'),
                                            H=('H', 'max'), L=('L', 'min'), C=('C', 'last'))
    g = g.sort_values('f')
    first, last = g['f'].values, g['la'].values
    up, atr = supertrend_up(g['H'].values, g['L'].values, g['C'].values)
    o, hi, cl = df['Open'].values, df['High'].values, df['Close'].values
    n4, out, j = len(g), [], 1
    while j < n4 - 1:
        if not (j > ATR_LEN * 3 and (not up[j]) and up[j - 1]):
            j += 1
            continue
        if gate is not None and not gate(last[j]):
            j += 1
            continue
        nxt = first[j + 1]
        e = o[nxt]
        sl = e + k * atr[j]
        ex_i = ex_p = None
        jj = j + 1
        while jj < n4:
            a, b = first[jj], last[jj] + 1
            hit = np.nonzero(hi[a:b] >= sl)[0]
            if len(hit):
                ex_i = a + hit[0]
                ex_p = max(o[ex_i], sl)
                break
            if up[jj] and jj + 1 < n4:
                ex_i, ex_p = first[jj + 1], o[first[jj + 1]]
                break
            jj += 1
        if ex_i is None:
            ex_i, ex_p = len(df) - 1, cl[-1]
        out.append((nxt, ex_i, e, ex_p, k * atr[j], -1))
        j = jj + 1                           # SL / flip ke baad sirf naya flip neeche
    return out


def ibs_sell_trades(df):
    """S2: ibs_trades ka hubahu aaina."""
    df = df.copy()
    df['sd'] = session_day(df['t'])
    g = df.groupby('sd', sort=True)
    last = g.apply(lambda x: x.index[-1], include_groups=False).values
    h, l, c = g['High'].max().values, g['Low'].min().values, g['Close'].last().values
    a = atr_rma(h, l, c, 14)
    sma = pd.Series(c).rolling(200).mean().values
    ibs = np.where(h > l, (c - l) / np.where(h > l, h - l, 1), np.nan)
    o, hi = df['Open'].values, df['High'].values
    nd, out, j = len(last), [], 0
    while j < nd - 1:
        if not (not np.isnan(sma[j]) and a[j] > 0 and ibs[j] > 0.8 and c[j] < sma[j]):
            j += 1
            continue
        e, r = c[j], 3.0 * a[j]
        sl = e + r
        ex_i = ex_p = None
        jj = j + 1
        while jj < nd:
            a0, b0 = last[jj - 1] + 1, last[jj] + 1
            hit = np.nonzero(hi[a0:b0] >= sl)[0]
            if len(hit):
                ex_i = a0 + hit[0]
                ex_p = max(o[ex_i], sl)
                break
            if (ibs[jj] < 0.2 or jj - j >= 5) and jj + 1 < nd:
                ex_i, ex_p = last[jj] + 1, c[jj]
                break
            jj += 1
        if ex_i is None:
            break                             # data khatam, khuli trade nahi gini
        out.append((last[j] + 1, ex_i, e, ex_p, r, -1))
        j = jj + 1
    return out


def buy_ko_tarjeeh(sells, buys):
    """Ek market mein ulti positions nahi: BUY khuli ho to SELL nahi khulti; SELL khuli ho aur BUY khule
    to SELL usi waqt usi qeemat (BUY ki entry) par band. buys = us market ki sab BUY trades (trend + IBS)."""
    iv = sorted((b[0], b[1], b[2]) for b in buys)
    out = []
    for s in sells:
        ei, xi = s[0], s[1]
        if any(b0 <= ei < b1 for b0, b1, _ in iv):
            continue                          # BUY khuli hai - SELL nahi
        cut = next(((b0, bp) for b0, b1, bp in iv if ei < b0 < xi), None)
        if cut is not None:
            s = (s[0], cut[0], s[2], cut[1], s[4], s[5])
        out.append(s)
    return out
