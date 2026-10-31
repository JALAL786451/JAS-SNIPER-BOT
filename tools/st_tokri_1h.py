#!/usr/bin/env python3
"""Koshish #55 (1 Nov 2026) - #34 JAS Trend TOKRI (Supertrend 10/3 sirf BUY) bilkul wahi, sirf 1H, ASLI kharcha.

Qaida (badalna mana): docs/purana-haal.md, grep "Koshish #55 qaida".
Data: data/ftmo/*.zip (Dukascopy H1, UTC) - seedha H1 candles.

  python3 tools/st_tokri_1h.py             # TALAASH (entry < 2019)
  python3 tools/st_tokri_1h.py --imtihan   # 2019+ EK dafa

Kharcha har taraf = 0.75 x JasSpreadNaap s1 spread% (gold kam az kam $0.50 aana-jana); swap 3%/saal.
"""
import argparse

import numpy as np
import pandas as pd

from ftmo_test import ST_MULT, load, session_day, supertrend_up
from gold_h4_pullback import report

MARKETS = {'XAUUSD': (0.50, 0.75 * 0.0059e-2), 'XAGUSD': (0.0, 0.75 * 0.0445e-2),
           'US500': (0.0, 0.75 * 0.0052e-2), 'USTEC': (0.0, 0.75 * 0.0038e-2)}
SWAP = 0.03 / 365
CUT = pd.Timestamp('2019-01-01', tz='UTC')


def trades(x, min_usd, cost_pct, cost_on=True):
    o, h, l, c = (x[k].values for k in ('Open', 'High', 'Low', 'Close'))
    up, atr = supertrend_up(h, l, c)
    day = session_day(x['t']).values
    tt = x['t'].values
    out, pos = [], 0
    for i in range(1, len(x) - 1):
        if pos == 0 and up[i] and not up[i - 1] and i > 30:
            pos, e, ep, ru = 1, i + 1, o[i + 1], ST_MULT * atr[i]
        elif pos == 1 and not up[i] and up[i - 1]:
            xp = o[i + 1]
            cost = 0.0
            if cost_on:
                nights = (pd.Timestamp(day[i + 1]) - pd.Timestamp(day[e])).days
                cost = max(min_usd, cost_pct * (ep + xp)) + SWAP * nights * ep
            out.append((pd.Timestamp(tt[e], tz='UTC'), 1, (xp - ep - cost) / ru, i + 1 - e))
            pos = 0
    return pd.DataFrame(out, columns=['t', 'side', 'r', 'bars'])


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--imtihan', action='store_true')
    a = ap.parse_args()
    print('IMTIHAN 2019+ (EK dafa)' if a.imtihan else 'TALAASH entry < 2019')
    allt, all0, cells = [], [], []
    for sym, (mn, cp) in MARKETS.items():
        df = load(sym)
        if not a.imtihan:
            df = df[df['t'] < CUT + pd.Timedelta(days=1)].reset_index(drop=True)
        keep = (lambda t: t[t['t'] >= CUT]) if a.imtihan else (lambda t: t[t['t'] < CUT])
        t, t0 = keep(trades(df, mn, cp)), keep(trades(df, mn, cp, cost_on=False))
        _, _, _, _, yr = report(f'{sym:7s}', t)
        cells += list(yr.values)
        t['m'] = sym
        allt.append(t)
        all0.append(t0)
    t = pd.concat(allt)
    n, ex, se, _, _ = report('KUL    ', t)
    t0 = pd.concat(all0)
    yrs = t['t'].dt.year.nunique()
    print(f'   bina kharcha {t0["r"].mean():+.4f}R, ~{n / max(1, yrs) / 12:.1f} tr/mahina (4 market), ausat {t["bars"].mean():.0f} ghante')
    mk = t.groupby('m')['r'].mean()
    cells = np.array(cells)
    print(f'   market musbat {(mk > 0).sum()}/4, (market x saal) musbat {(cells > 0).sum()}/{len(cells)}')
    if a.imtihan:
        ok = n >= 30 and ex - 2 * se > 0
    else:
        ok = n >= 100 and ex - 2 * se > 0 and (mk > 0).sum() >= 3 and (cells > 0).mean() > 0.5
    print('PASS' if ok else 'FAIL')


if __name__ == '__main__':
    main()
