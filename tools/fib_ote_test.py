#!/usr/bin/env python3
"""Koshish #22 (28 Oct 2026) - Fib OTE gold 15m, `indicators/jas_fib_swing.pine` f5 ka Python.

Qaida (badalna mana): docs/purana-haal.md, grep "Koshish #22 qaida" aur "#22 Python tarjuma".
Data: data/qdm/XAUUSD_M1_2021_24.zip (QDM Dukascopy M1, UTC) -> 15m + 1H.

  python3 tools/fib_ote_test.py     # TALAASH 2021-2024

1H pivot 5 se leg, entry 0.618 limit, SL swing + 5%, TP 1.272, din (17:00 NY)
khatam = band. Kharcha max($0.50, 0.03%) har trade, R mein.
"""
import io
import sys
import zipfile
from pathlib import Path

import numpy as np
import pandas as pd

from ftmo_test import session_day

ROOT = Path(__file__).resolve().parent.parent
COST_USD, COST_PCT = 0.50, 0.0003
PIV, ENTRY_K, TP_K, SL_BUF = 5, 0.618, 1.272, 0.05


def load_m1(name):
    with zipfile.ZipFile(ROOT / 'data' / 'qdm' / name) as z:
        csv = next(n for n in z.namelist() if n.endswith('.csv'))
        df = pd.read_csv(io.BytesIO(z.read(csv)), dtype={'Date': str, 'Time': str})
    df['t'] = pd.to_datetime(df['Date'] + df['Time'], format='%Y%m%d%H:%M:%S', utc=True)
    return df[['t', 'Open', 'High', 'Low', 'Close']].sort_values('t').drop_duplicates('t').set_index('t')


def bars(m1, rule):
    return m1.resample(rule).agg({'Open': 'first', 'High': 'max', 'Low': 'min', 'Close': 'last'}).dropna().reset_index()


def pivots(h1):
    """[(maloom hone ka waqt, pivot ka waqt, qeemat, 1=high / -1=low)], waqt ki tarteeb mein."""
    h, l, t = h1['High'].values, h1['Low'].values, h1['t'].values
    out = []
    for k in range(PIV, len(h1) - PIV):
        avail = t[k + PIV] + np.timedelta64(1, 'h')
        if h[k] > h[k - PIV:k].max() and h[k] >= h[k + 1:k + PIV + 1].max():
            out.append((avail, t[k], h[k], 1))
        if l[k] < l[k - PIV:k].min() and l[k] <= l[k + 1:k + PIV + 1].min():
            out.append((avail, t[k], l[k], -1))
    out.sort(key=lambda p: (p[0], p[1]))
    return out


def run(m15, piv, cost_on=True):
    o, h, l, c = (m15[k].values for k in ('Open', 'High', 'Low', 'Close'))
    tt = m15['t'].values
    day = session_day(m15['t']).values
    pi = 0
    leg_s = leg_e = None             # (qeemat, waqt)
    leg_type = 0
    sw_hi = sw_lo = np.nan
    cur = 0
    armed = broken = False
    pos = 0
    out = []

    def close_trade(px, why, i):
        r = (px - ent) * pos / abs(ent - sl)
        if cost_on:
            r -= max(COST_USD, COST_PCT * ent) / abs(ent - sl)
        out.append((pd.Timestamp(tt[ent_i], tz='UTC'), pos, r, why))

    for i in range(len(m15)):
        # 1) naye pivot (pichhli band 1H tak)
        changed = False
        while pi < len(piv) and piv[pi][0] <= tt[i]:
            _, pt, pp, ptype = piv[pi]
            pi += 1
            if ptype == leg_type:
                if (ptype == 1 and pp > leg_e[0]) or (ptype == -1 and pp < leg_e[0]):
                    leg_e, changed = (pp, pt), True
            else:
                if leg_e is not None:
                    leg_s = leg_e
                leg_e, leg_type, changed = (pp, pt), ptype, True
        if changed:
            armed, broken = True, False
            if leg_s is not None:
                sw_hi, sw_lo = max(leg_s[0], leg_e[0]), min(leg_s[0], leg_e[0])
                cur = leg_type
        # 2) naya din = khuli trade pichhli close par band
        if pos != 0 and i > 0 and day[i] != day[i - 1]:
            close_trade(c[i - 1], 'din', i)
            pos = 0
        # 3) entry (limit 0.618)
        rng = sw_hi - sw_lo
        if armed and pos == 0 and cur != 0 and not broken and rng > 0:
            ep = sw_hi - ENTRY_K * rng if cur == 1 else sw_lo + ENTRY_K * rng
            slp = sw_lo - SL_BUF * rng if cur == 1 else sw_hi + SL_BUF * rng
            tpp = sw_lo + TP_K * rng if cur == 1 else sw_hi - TP_K * rng
            if (cur == 1 and l[i] <= ep) or (cur == -1 and h[i] >= ep):
                fill = min(o[i], ep) if cur == 1 else max(o[i], ep)
                armed = False
                if (cur == 1 and fill > slp) or (cur == -1 and fill < slp):
                    pos, ent, sl, tp, ent_i = cur, fill, slp, tpp, i
        # 4) SL pehle, phir TP (entry wali candle par TP nahi)
        if pos != 0:
            hit_sl = l[i] <= sl if pos == 1 else h[i] >= sl
            hit_tp = i > ent_i and (h[i] >= tp if pos == 1 else l[i] <= tp)
            if hit_sl:
                px = sl if i == ent_i else (min(sl, o[i]) if pos == 1 else max(sl, o[i]))
                close_trade(px, 'sl', i)
                pos = 0
            elif hit_tp:
                close_trade(tp, 'tp', i)
                pos = 0
        # 5) leg toota? (is candle ki close; agli candle se entry band)
        if (cur == 1 and c[i] < sw_lo) or (cur == -1 and c[i] > sw_hi):
            broken = True
    return pd.DataFrame(out, columns=['t', 'side', 'r', 'why'])


def report(name, t):
    r = t['r']
    n, ex = len(r), r.mean()
    se = r.std(ddof=1) / np.sqrt(n)
    yr = t.groupby(t['t'].dt.year)['r'].sum()
    print(f'{name}: {n} tr, Exp {ex:+.4f}R, SE {se:.4f}, Exp-2SE {ex - 2 * se:+.4f}, '
          f'jeet {100 * (r > 0).mean():.1f}%, kul {r.sum():+.1f}R, saal {(yr > 0).sum()}/{len(yr)}')
    return n, ex, se, (yr > 0).mean(), yr


def main():
    if '--imtihan' in sys.argv:
        sys.exit('IMTIHAN 2025+ ka M1 data abhi nahi (TALAASH pass ho to user se)')
    m1 = load_m1('XAUUSD_M1_2021_24.zip')
    m15, h1 = bars(m1, '15min'), bars(m1, '1h')
    piv = pivots(h1)
    print(f'TALAASH 2021-2024: {len(m15)} 15m candle, {len(piv)} pivot')
    t = run(m15, piv)
    n, ex, se, yp, yr = report('KUL', t)
    print('   saal: ' + ' '.join(f'{y}:{v:+.0f}' for y, v in yr.items()))
    report('BUY ', t[t['side'] == 1])
    report('SELL', t[t['side'] == -1])
    report('bina kharcha (maloomat)', run(m15, piv, cost_on=False))
    print(f'   band: {t["why"].value_counts().to_dict()}')
    print('PASS' if (n >= 100 and ex - 2 * se > 0 and yp > 0.5) else 'FAIL')


if __name__ == '__main__':
    main()
