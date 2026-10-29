#!/usr/bin/env python3
"""Koshish #46 (29 Oct 2026) - Bollinger Squeeze + Crabel NR7 toot, daily + 4H, BUY + SELL.
Qaida (badalna mana): docs/purana-haal.md, grep "Koshish #46 qaida".

  python3 tools/squeeze_nr7_test.py             # TALAASH (entry < 2019)
  python3 tools/squeeze_nr7_test.py --imtihan   # 2019+ EK dafa
"""
import argparse

import numpy as np
import pandas as pd

from ftmo_test import atr_rma
from gold_h4_pullback import report
from jlaw_mea_test import bars, load_v

MARKETS = {'XAUUSD': 0.50, 'XAGUSD': 0.0, 'US500': 0.0, 'USTEC': 0.0}
CUT = pd.Timestamp('2019-01-01', tz='UTC')
COST_PCT, SWAP = 0.0003, 0.03 / 365


def trades(x, min_usd, cost_on=True):
    o, h, l, c = (x[k].values.astype(float) for k in ('Open', 'High', 'Low', 'Close'))
    n = len(c)
    sma = pd.Series(c).rolling(20).mean().values
    sd = pd.Series(c).rolling(20).std(ddof=0).values
    bw = 4 * sd / sma
    pct = pd.Series(bw).rolling(125).apply(lambda w: (w <= w[-1]).mean(), raw=True).values
    rng = h - l
    nr7 = rng <= pd.Series(rng).rolling(7).min().values
    atr = atr_rma(h, l, c, 14)
    day, tt = x['day'].values, x['t'].values
    out, pos, setup = [], 0, None

    def close_trade(xi, xp):
        cost = 0.0
        if cost_on:
            nights = (pd.Timestamp(day[xi]) - pd.Timestamp(day[e])).days
            cost = max(min_usd, COST_PCT * (ep + xp)) + SWAP * nights * ep
        out.append((pd.Timestamp(tt[e], tz='UTC'), side, (side * (xp - ep) - cost) / ru, xi - e))

    for k in range(130, n - 1):
        if pos:
            if (side > 0 and l[k] <= sl) or (side < 0 and h[k] >= sl):
                close_trade(k, (min(o[k], sl) if side > 0 else max(o[k], sl)) if k > e else sl)
                pos = 0
            elif (side > 0 and c[k] < sma[k]) or (side < 0 and c[k] > sma[k]):
                close_trade(k + 1, o[k + 1])
                pos = 0
            continue
        if setup is not None:
            i, hs, ls, a = setup
            if k - i > 5:
                setup = None
            else:
                up, dn = h[k] > hs, l[k] < ls
                if up or dn:
                    setup = None
                    if up and dn:
                        side = 1 if abs(o[k] - hs) <= abs(o[k] - ls) else -1
                    else:
                        side = 1 if up else -1
                    if side > 0:
                        ep, sl = max(o[k], hs), ls - 0.1 * a
                    else:
                        ep, sl = min(o[k], ls), hs + 0.1 * a
                    e, ru = k, abs(ep - sl)
                    if up and dn:                     # usi bar SL = -1R
                        close_trade(k, sl)
                        continue
                    pos = 1
                    if (side > 0 and c[k] < sma[k]) or (side < 0 and c[k] > sma[k]):
                        close_trade(k + 1, o[k + 1])
                        pos = 0
                    continue
        if nr7[k] and pct[k] <= 0.2 and not np.isnan(atr[k]):
            setup = (k, h[k], l[k], atr[k])
    return pd.DataFrame(out, columns=['t', 'side', 'r', 'bars'])


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--imtihan', action='store_true')
    a = ap.parse_args()
    print('IMTIHAN 2019+ (EK dafa)' if a.imtihan else 'TALAASH entry < 2019')
    keep = (lambda t: t[t['t'] >= CUT]) if a.imtihan else (lambda t: t[t['t'] < CUT])
    raw = {s: load_v(s) for s in MARKETS}
    for tf in ('D1', 'H4'):
        print(f'\n=== #46{"a" if tf == "D1" else "b"} {tf} ===')
        allt, all0, cells = [], [], []
        for sym, mn in MARKETS.items():
            df = raw[sym]
            if not a.imtihan:
                df = df[df['t'] < CUT + pd.Timedelta(days=60)].reset_index(drop=True)
            x = bars(df, tf)
            t, t0 = keep(trades(x, mn)), keep(trades(x, mn, cost_on=False))
            _, _, _, _, yr = report(f'{sym:7s}', t)
            cells += list(yr.values)
            t['m'] = sym
            allt.append(t)
            all0.append(t0)
        t = pd.concat(allt)
        n, ex, se, _, _ = report('KUL    ', t)
        for sd_, nm in ((1, 'BUY '), (-1, 'SELL')):
            report(f'  {nm} ', t[t.side == sd_])
        print(f'   bina kharcha {pd.concat(all0)["r"].mean():+.4f}R, ausat {t["bars"].mean():.1f} bar')
        mk = t.groupby('m')['r'].mean()
        cells = np.array(cells)
        print(f'   market musbat {(mk > 0).sum()}/4, (market x saal) musbat {(cells > 0).sum()}/{len(cells)}')
        ok = (n >= 30 and ex > 0) if a.imtihan else (
            n >= 100 and ex - 2 * se > 0 and (mk > 0).sum() >= 3 and (cells > 0).mean() > 0.5)
        print('PASS' if ok else 'FAIL')


if __name__ == '__main__':
    main()
