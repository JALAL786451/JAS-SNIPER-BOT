#!/usr/bin/env python3
"""Koshish #103 (16 Nov 2026) - WAHI-MAHINA SEASONALITY long/short tokri (12 market), swap 0.
Qaida (badalna mana): docs/purana-haal.md, grep "Koshish #103 qaida".

  python3 tools/season103.py             # TALAASH (mahine <= 2018)
  python3 tools/season103.py --imtihan   # 2019+ EK dafa
"""
import argparse

import numpy as np
import pandas as pd

from ftmo99 import SPREAD
from ftmo_test import atr_rma, load, session_day
from tokri47 import load_any
from yahoo_d1 import load_d1

H1 = {'US500': 'US500', 'USTEC': 'USTEC', 'US30': 'USA30IDXUSD', 'DE30': 'DEUIDXEUR', 'UK100': 'GBRIDXGBP',
      'FR40': 'FRAIDXEUR', 'EU50': 'EUSIDXEUR', 'JP225': 'JPNIDXJPY', 'AUS200': 'AUSIDXAUD', 'HK50': 'HKGIDXHKD',
      'XAUUSD': 'XAUUSD', 'XAGUSD': 'XAGUSD'}
GROUP = {'US500': 'US', 'USTEC': 'US', 'US30': 'US', 'DE30': 'EU', 'UK100': 'EU', 'FR40': 'EU', 'EU50': 'EU',
         'JP225': 'AS', 'AUS200': 'AS', 'HK50': 'AS', 'XAUUSD': 'MT', 'XAGUSD': 'MT'}
METAL = ('XAUUSD', 'XAGUSD')
KCOST = 0.0002
N_SIDE, G_MAX, Y_MAX, Y_MIN, ATR_N, SL_K = 3, 2, 20, 10, 20, 3.0


def h1(name):
    return load(H1[name]) if H1[name] in ('US500', 'USTEC', 'XAUUSD', 'XAGUSD') else load_any(H1[name])


def daily(df):
    g = df.assign(sd=session_day(df['t'])).groupby('sd', sort=True)
    last = g.apply(lambda x: x.index[-1], include_groups=False).values
    first = np.r_[0, last[:-1] + 1]
    day = pd.DatetimeIndex(g['Close'].last().index)
    return first, last, g['High'].max().values, g['Low'].min().values, g['Close'].last().values, day


def monthly_ret(dates, close):
    """{(saal, mahina): return} - mahine ki aakhri close / pichhle mahine ki aakhri close - 1."""
    s = pd.Series(np.asarray(close, dtype=float), index=pd.PeriodIndex(pd.DatetimeIndex(dates), freq='M'))
    m = s.groupby(level=0).last()
    out = {}
    for p, v in m.items():
        if p - 1 in m.index:
            out[(p.year, p.month)] = v / m[p - 1] - 1.0
    return out


def score(mr, y, m):
    """ausat (isi mahine, pichhle <= 20 saal, >= 10) / SD (unhi saalon ke sab mahine). Sirf saal < y."""
    same = [mr[(yy, m)] for yy in range(y - Y_MAX, y) if (yy, m) in mr]
    if len(same) < Y_MIN:
        return None
    allr = [v for (yy, _), v in mr.items() if y - Y_MAX <= yy < y]
    sd = np.std(allr, ddof=1)
    return np.mean(same) / sd if sd > 0 else None


def pick(sc):
    """sc: {market: score} -> (BUY list, SELL list); ek group se ek taraf max 2."""
    order = sorted(sc, key=lambda k: sc[k], reverse=True)
    buy, sell = [], []
    for k in order:
        if len(buy) < N_SIDE and sum(GROUP[b] == GROUP[k] for b in buy) < G_MAX:
            buy.append(k)
    for k in reversed(order):
        if k not in buy and len(sell) < N_SIDE and sum(GROUP[b] == GROUP[k] for b in sell) < G_MAX:
            sell.append(k)
    return buy, sell


class Mk:
    def __init__(self, name):
        self.name = name
        self.df = h1(name)
        self.first, self.last, H, L, C, self.day = daily(self.df)
        self.atr = atr_rma(H, L, C, ATR_N)
        self.o, self.h, self.l, self.c = (self.df[k].values for k in ('Open', 'High', 'Low', 'Close'))
        self.ym = self.day.year * 100 + self.day.month
        if name in METAL:
            self.mr = monthly_ret(self.day, C)
        else:
            y = load_d1(name)
            self.mr = monthly_ret(y['t'], y['Close'])
        self.cost = 0.75 * SPREAD[H1[name]] if H1[name] in SPREAD else KCOST

    def days(self, y, m):
        """mahine ke din idx (a, b) ya None. Data shart (H1 mein 2012-14 khali jagah): is mahine aur pichhle mahine
        >= 15 session din, pehla din tareekh <= 4, mahina mukammal (baad ka data maujood)."""
        ix = np.nonzero(self.ym == y * 100 + m)[0]
        pm = (y - 1) * 100 + 12 if m == 1 else y * 100 + m - 1
        if (len(ix) < 15 or (self.ym == pm).sum() < 15 or self.day[ix[0]].day > 4 or ix[-1] + 1 >= len(self.day)
                or not self.atr[ix[0] - 1] > 0):
            return None
        return ix[0], ix[-1]

    def trade(self, a, b, d):
        """(entry H1 idx, exit H1 idx, entry, exit, SL doori, rukh)"""
        e = self.first[a]
        ep, ru = self.o[e], SL_K * self.atr[a - 1]
        sl = ep - d * ru
        x = self.last[b]
        seg = slice(e, x + 1)
        hit = np.nonzero(self.l[seg] <= sl)[0] if d > 0 else np.nonzero(self.h[seg] >= sl)[0]
        if len(hit):
            xi = e + hit[0]
            return e, xi, ep, (min(self.o[xi], sl) if d > 0 else max(self.o[xi], sl)), ru, d
        return e, x + 1, ep, self.c[x], ru, d


def all_trades(mk, y0, y1):
    """[(saal, mahina, market, trade tuple)] y0..y1 (dono shamil)."""
    out = []
    for y in range(y0, y1 + 1):
        for m in range(1, 13):
            sc, dd = {}, {}
            for k in mk.values():
                s, r = score(k.mr, y, m), k.days(y, m)
                if s is not None and r is not None:
                    sc[k.name], dd[k.name] = s, r
            if len(sc) < 2 * N_SIDE:
                continue
            buy, sell = pick(sc)
            for names, d in ((buy, 1), (sell, -1)):
                for n in names:
                    out.append((y, m, n, mk[n].trade(*dd[n], d)))
    return out


def cluster_se(r, key):
    m, n = r.mean(), len(r)
    s = pd.Series(r - m).groupby(key).sum().values
    g = len(s)
    return np.sqrt((s ** 2).sum() * g / max(1, g - 1)) / n


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--imtihan', action='store_true')
    im = ap.parse_args().imtihan
    mk = {n: Mk(n) for n in H1}
    y0, y1 = (2019, 2026) if im else (2012, 2018)
    print(f"#103 wahi-mahina seasonality long/short, swap 0 - {'IMTIHAN 2019+ (EK dafa)' if im else 'TALAASH <= 2018'}")
    rows = []
    for (y, m, n, (ei, xi, e, x, ru, d)) in all_trades(mk, y0, y1):
        c = mk[n].cost * (e + x)
        rows.append((y, m, n, d, (d * (x - e) - c) / ru, d * (x - e) / ru))
    t = pd.DataFrame(rows, columns=['y', 'm', 'mk', 'd', 'r', 'r0'])
    key = (t['y'] * 100 + t['m']).values
    n, ex = len(t), t['r'].mean()
    se, sec = t['r'].std(ddof=1) / np.sqrt(n), cluster_se(t['r'].values, key)
    nm = len(set(key))
    yrs = t.groupby('y')['r'].sum()
    for lab, q in (('BUY ', t[t['d'] > 0]), ('SELL', t[t['d'] < 0])):
        print(f'  {lab} {len(q):4d} tr, jeet {np.mean(q["r"] > 0) * 100:3.0f}%, Exp {q["r"].mean():+.3f}R')
    print('  market: ' + ' '.join(f'{k}:{len(v)}/{v.mean():+.2f}' for k, v in t.groupby('mk')['r']))
    print(f'KUL {n} tr ({nm} mahine, {n / nm:.1f}/mahina), jeet {np.mean(t["r"] > 0) * 100:.0f}%, Exp {ex:+.4f}R, SE {se:.4f} '
          f'(cluster {sec:.4f}), Exp-2SE(cluster) {ex - 2 * sec:+.4f}')
    print(f'   bina kharcha {t["r0"].mean():+.4f}R, kul {t["r"].sum():+.1f}R, saal musbat {(yrs > 0).sum()}/{len(yrs)}: '
          + ' '.join(f'{y}:{v:+.1f}' for y, v in yrs.items()))
    ok = n >= (30 if im else 100) and ex - 2 * sec > 0 and (im or (yrs > 0).mean() > 0.5)
    print('PASS' if ok else 'FAIL')


if __name__ == '__main__':
    main()
