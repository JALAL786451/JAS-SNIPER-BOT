#!/usr/bin/env python3
"""Koshish #87 TALAASH (3 Nov 2026) - JasNaqsha 15M (gold M1 2009-2018) = FAIL. Qaida: docs/purana-haal.md grep "Koshish #87 qaida"
(test se pehle likha, badalna mana). Chat mein ghalti se "#83" naam tha - repo mein #83-86 pehle se the, isliye #87.

Faisla 1D + 4H, amal 15M. Supertrend / session_day repo ke tools/ftmo_test.py se (wohi tested functions).
Chalane ka tareeqa:  python3 tools/k87_naqsha15m.py   (~2 min; nateeja docs/research/k87-natija.txt)
"""
import io
import math
import sys
import zipfile
from pathlib import Path

import numpy as np
import pandas as pd

REPO = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(REPO / 'tools'))
from ftmo_test import session_day, supertrend_up  # noqa: E402

YEARS = range(2009, 2019)
K = 6.0                 # SL = K x ATR10 (4H)
COST = 0.0003           # har taraf, notional par
SWAP = 0.03 / 365       # har raat
WARM_DAYS = 200         # EMA200
WARM_4H = 30


def load_m1():
    parts = []
    for y in YEARS:
        with zipfile.ZipFile(REPO / 'data' / 'histdata' / f'XAUUSD_M1_{y}_NY.zip') as z:
            name = next(n for n in z.namelist() if n.lower().endswith('.csv'))
            parts.append(pd.read_csv(io.BytesIO(z.read(name)), sep=';', header=None,
                                     names=['dt', 'O', 'H', 'L', 'C', 'V'], dtype={'dt': str}))
    df = pd.concat(parts, ignore_index=True)
    t = pd.to_datetime(df['dt'], format='%Y%m%d %H%M%S')
    # File ke waqt = New York local (DST samet) - repo ka qaida (tools/k80_asia_bb.py). v1 mein ghalti se fixed +5h tha.
    df['t'] = t.dt.tz_localize('America/New_York', ambiguous='NaT', nonexistent='NaT').dt.tz_convert('UTC')
    df = df.dropna(subset=['t'])
    return df[['t', 'O', 'H', 'L', 'C']].sort_values('t').drop_duplicates('t').reset_index(drop=True)


def dst_check(m1):
    """Har hafte ki pehli candle (Itwar 18:00 NY) ka UTC ghanta, mahine ke hisaab se: sardi 23, garmi 22 aana chahiye."""
    gap = m1['t'].diff() > pd.Timedelta(hours=36)
    st = m1.loc[gap, 't']
    s = pd.DataFrame({'m': st.dt.month, 'h': st.dt.hour})
    return s.groupby('m')['h'].agg(lambda x: x.value_counts().index[0]).to_dict()


def build(m1):
    g = m1.set_index('t').resample('15min')
    m15 = pd.DataFrame({'O': g['O'].first(), 'H': g['H'].max(), 'L': g['L'].min(), 'C': g['C'].last()}).dropna().reset_index()
    n = len(m15)
    day = session_day(m15['t'])
    blk = ((m15['t'].dt.tz_convert('America/New_York') + pd.Timedelta(hours=7)).dt.hour // 4).values
    base = pd.DataFrame({'i': np.arange(n), 'd': day.values, 'b': blk, 'H': m15['H'].values, 'L': m15['L'].values, 'C': m15['C'].values})
    g4 = base.groupby(['d', 'b'], sort=True).agg(f=('i', 'first'), la=('i', 'last'), H=('H', 'max'), L=('L', 'min'), C=('C', 'last')).sort_values('f')
    gd = base.groupby('d', sort=True).agg(la=('i', 'last'), C=('C', 'last')).sort_values('la')
    return m15, day, g4, gd


def stats(rs):
    rs = np.asarray(rs, float)
    n = len(rs)
    if n == 0:
        return dict(n=0, win=float('nan'), exp=float('nan'), se=float('nan'), lo=float('nan'), pf=float('nan'), tot=0.0, dd=0.0)
    exp = rs.mean()
    se = rs.std(ddof=1) / math.sqrt(n) if n > 1 else float('nan')
    pos, neg = rs[rs > 0].sum(), -rs[rs < 0].sum()
    cum = np.cumsum(rs)
    dd = float((np.maximum.accumulate(np.r_[0.0, cum]) - np.r_[0.0, cum]).max())
    return dict(n=n, win=(rs > 0).mean() * 100, exp=exp, se=se, lo=exp - 2 * se, pf=(pos / neg if neg > 0 else float('inf')), tot=rs.sum(), dd=dd)


def fmt(name, s):
    if s['n'] == 0:
        return f'{name:<22} trades 0'
    return (f"{name:<22} trades {s['n']:>4}  jeet {s['win']:5.1f}%  Exp {s['exp']:+.3f}R  SE {s['se']:.3f}  "
            f"Exp-2SE {s['lo']:+.3f}  PF {s['pf']:.2f}  kul {s['tot']:+.1f}R  girawat {s['dd']:.1f}R")


def main():
    out = []
    P = out.append
    m1 = load_m1()
    P(f"M1 candles: {len(m1):,}  ({m1['t'].iloc[0]} se {m1['t'].iloc[-1]})")
    P('Hafte ki pehli candle (UTC ghanta, mahina: ghanta): ' + str(dst_check(m1)))
    m15, day, g4, gd = build(m1)
    n15, n4, nd = len(m15), len(g4), len(gd)
    P(f'15M {n15:,} | 4H {n4:,} | 1D {nd:,}')

    O, H, L, C = m15['O'].values, m15['H'].values, m15['L'].values, m15['C'].values
    first, last = g4['f'].values, g4['la'].values
    up, atr = supertrend_up(g4['H'].values, g4['L'].values, g4['C'].values)

    dC = gd['C']
    e50 = dC.ewm(span=50, adjust=False).mean().values
    e200 = dC.ewm(span=200, adjust=False).mean().values
    dC = dC.values
    dlast = gd['la'].values
    dayv = day.values.astype('datetime64[D]')

    def bias_at(e_i):
        """Entry candle se PEHLE ki aakhri band 1D: +1 upar, -1 neeche, 0 mila, None = EMA200 abhi tayyar nahi."""
        k = int(np.searchsorted(dlast, e_i, side='left')) - 1
        if k < WARM_DAYS:
            return None
        if dC[k] > e50[k] > e200[k]:
            return 1
        if dC[k] < e50[k] < e200[k]:
            return -1
        return 0

    def run(mode):
        trades, free = [], 0
        for j in range(max(WARM_4H, 1), n4 - 1):
            fu = up[j] and not up[j - 1]
            fd = (not up[j]) and up[j - 1]
            if not (fu or fd):
                continue
            e_i = int(first[j + 1])
            if e_i < free:
                continue
            d = 1 if fu else -1
            b = bias_at(e_i)
            if b is None:
                continue
            if mode == 'main' and b != d:
                continue
            if mode == 'ref' and d != 1:
                continue
            entry = O[e_i]
            dist = K * atr[j]
            sl = entry - d * dist
            ex_i = ex_p = None
            why = 'end'
            for jj in range(j + 1, n4):
                a, bnd = int(first[jj]), int(last[jj]) + 1
                if d == 1:
                    hit = np.nonzero(L[a:bnd] <= sl)[0]
                else:
                    hit = np.nonzero(H[a:bnd] >= sl)[0]
                if len(hit):
                    ex_i = a + int(hit[0])
                    ex_p = min(O[ex_i], sl) if d == 1 else max(O[ex_i], sl)
                    why = 'SL'
                    break
                against = (not up[jj]) if d == 1 else up[jj]
                if against and jj + 1 < n4:
                    ex_i = int(first[jj + 1])
                    ex_p = O[ex_i]
                    why = 'flip'
                    break
            if ex_i is None:
                ex_i, ex_p = n15 - 1, C[-1]
            nights = int((dayv[ex_i] - dayv[e_i]).astype(int))
            gross = d * (ex_p - entry)
            net = gross - COST * (entry + ex_p) - SWAP * nights * entry
            trades.append(dict(side='BUY' if d == 1 else 'SELL', t_in=m15['t'].iloc[e_i], t_out=m15['t'].iloc[ex_i],
                               year=m15['t'].iloc[e_i].year, entry=entry, exit=ex_p, dist=dist, why=why, nights=nights,
                               Rg=gross / dist, R=net / dist))
            free = ex_i
        return pd.DataFrame(trades)

    main = run('main')
    ref = run('ref')
    main.to_csv(REPO / 'docs/research/k87-trades.csv', index=False)

    buy, sell = main[main.side == 'BUY'], main[main.side == 'SELL']
    sb, ss = stats(buy.R), stats(sell.R)
    sell_ok = ss['n'] > 1 and ss['lo'] > 0
    final = main if sell_ok else buy
    sf = stats(final.R)

    P('')
    P('=== NATEEJA (R mein, kharcha + swap ke baad) ===')
    P(fmt('BUY', sb))
    P(fmt('SELL', ss))
    P(fmt('BUY+SELL (dono)', stats(main.R)))
    P(f"SELL ka apna Exp-2SE > 0?  {'HAAN -> SELL final mein' if sell_ok else 'NAHI -> SELL band, final = sirf BUY'}")
    P(fmt('FINAL', sf))
    P(fmt('FINAL bina kharcha', stats(final.Rg)))
    P('')
    P('Saal-war (entry ke saal ke hisaab se), R:')
    P(f"{'saal':<6}{'BUY n':>7}{'BUY R':>9}{'SELL n':>8}{'SELL R':>9}{'FINAL R':>10}")
    yrs = sorted(main.year.unique())
    pos_years = 0
    for y in yrs:
        b_, s_, f_ = buy[buy.year == y], sell[sell.year == y], final[final.year == y]
        pos_years += 1 if f_.R.sum() > 0 else 0
        P(f"{y:<6}{len(b_):>7}{b_.R.sum():>+9.2f}{len(s_):>8}{s_.R.sum():>+9.2f}{f_.R.sum():>+10.2f}")
    P(f'Musbat saal (FINAL): {pos_years} / {len(yrs)}')
    P('Exit ki wajah (FINAL): ' + str(final.why.value_counts().to_dict()) + f"  ausat din {final.nights.mean():.1f}")

    P('')
    P('=== PASS / FAIL (qaida: purana-haal Koshish #87) ===')
    c1 = sf['n'] >= 100
    c2 = sf['n'] > 1 and sf['lo'] > 0
    c3 = pos_years >= 6
    P(f"trades >= 100          : {sf['n']}  -> {'PASS' if c1 else 'FAIL'}")
    P(f"Exp - 2SE > 0          : {sf['lo']:+.3f}  -> {'PASS' if c2 else 'FAIL'}")
    P(f"musbat saal >= 6       : {pos_years}  -> {'PASS' if c3 else 'FAIL'}")
    P('TALAASH NATEEJA: ' + ('PASS -> IMTIHAN (2019-aaj) ek dafa' if (c1 and c2 and c3) else 'FAIL -> idea band'))

    P('')
    P('=== Sirf hawala (faisle mein shamil nahi): wohi engine, sirf BUY, BINA 1D filter ===')
    P(fmt('BUY bina 1D filter', stats(ref.R)))

    txt = '\n'.join(out)
    print(txt)
    (REPO / 'docs/research/k87-natija.txt').write_text(txt + '\n')


if __name__ == '__main__':
    main()
