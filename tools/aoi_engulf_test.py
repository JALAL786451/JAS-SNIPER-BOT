#!/usr/bin/env python3
"""Koshish #36 (29 Oct 2026) - HTF rukh + AOI (4H pivot zone) + M30 engulfing, gold.

Qaida (badalna mana): docs/purana-haal.md, grep "Koshish #36 qaida".
HTF: data/ftmo/XAU_XAG_H1_dukascopy.zip (2025 se pehle); M30 + exit: data/qdm/XAUUSD_M1_2021_24.zip.

  python3 tools/aoi_engulf_test.py      # TALAASH 2021-2024
"""
import numpy as np
import pandas as pd

from fib_ote_test import bars, load_m1
from ftmo_test import load, session_day

COST_USD, COST_PCT = 0.50, 0.0003
SWAP = 0.03 / 365
PIV, LOOK_D, CLU, ZONE, SL_BUF, TP_R, MAX_BARS = 5, 90, 0.5, 0.25, 0.1, 2.0, 240


def rma(x, n):
    return x.ewm(alpha=1 / n, adjust=False, min_periods=n).mean()


def htf(h1):
    """W / D / 4H candles H1 se: end (band hone ka waqt), close, EMA50 upar?"""
    day = session_day(h1['t'])
    ny_blk = ((h1['t'].dt.tz_convert('America/New_York') + pd.Timedelta(hours=7)).dt.hour // 4).values
    keys = {'D': [day.values],
            'W': [(day - pd.to_timedelta(day.dt.weekday, unit='D')).values],
            '4H': [day.values, ny_blk]}
    out = {}
    for k, key in keys.items():
        g = h1.groupby(key, sort=False).agg(end=('t', 'last'), h=('High', 'max'), l=('Low', 'min'),
                                            c=('Close', 'last'), t0=('t', 'first'))
        g = g.sort_values('t0').reset_index(drop=True)
        g['end'] = g['end'] + pd.Timedelta(hours=1)
        g['bull'] = g['c'] > g['c'].ewm(span=50, adjust=False, min_periods=50).mean()
        g['bear'] = g['c'] < g['c'].ewm(span=50, adjust=False, min_periods=50).mean()
        pc = g['c'].shift()
        tr = np.maximum(g['h'] - g['l'], np.maximum((g['h'] - pc).abs(), (g['l'] - pc).abs()))
        g['atr'] = rma(tr, 14)
        out[k] = g
    return out


def pivots4h(g):
    h, l, e = g['h'].values, g['l'].values, g['end'].values
    p = []
    for k in range(PIV, len(g) - PIV):
        if h[k] > h[k - PIV:k].max() and h[k] >= h[k + 1:k + PIV + 1].max():
            p.append((e[k + PIV], e[k], h[k]))
        if l[k] < l[k - PIV:k].min() and l[k] <= l[k + 1:k + PIV + 1].min():
            p.append((e[k + PIV], e[k], l[k]))
    p.sort()
    return np.array([x[0] for x in p]), np.array([x[1] for x in p]), np.array([x[2] for x in p])


def asof(times, g, col):
    """Har waqt par pichhli BAND candle ki value."""
    idx = np.searchsorted(g['end'].values, times, side='right') - 1
    v = g[col].values
    return np.where(idx >= 0, v[np.clip(idx, 0, None)], np.nan)


def run(m1, H, cost_on=True):
    m30 = bars(m1, '30min')
    m30['end'] = m30['t'] + pd.Timedelta(minutes=30)
    te = m30['end'].values
    up = sum(asof(te, H[k], 'bull').astype(float) for k in H)
    dn = sum(asof(te, H[k], 'bear').astype(float) for k in H)
    atr_d = asof(te, H['D'], 'atr')
    o, h, l, c = (m30[k].values for k in ('Open', 'High', 'Low', 'Close'))
    pc_ = np.r_[np.nan, c[:-1]]
    tr = np.maximum(h - l, np.maximum(np.abs(h - pc_), np.abs(l - pc_)))
    atr30 = rma(pd.Series(tr), 14).values
    pa, pt, pp = pivots4h(H['4H'])
    m1o, m1h, m1l = (m1[k].values for k in ('Open', 'High', 'Low'))
    m1t = m1.index.values
    day = session_day(m30['t']).values
    look = np.timedelta64(LOOK_D, 'D')
    out, i = [], 1
    while i < len(m30) - 1:
        side = 0
        A = atr_d[i]
        if not np.isnan(A) and not np.isnan(atr30[i]):
            bull = c[i - 1] < o[i - 1] and c[i] > o[i] and o[i] <= c[i - 1] and c[i] >= o[i - 1] \
                and (c[i] - o[i]) > (o[i - 1] - c[i - 1])
            bear = c[i - 1] > o[i - 1] and c[i] < o[i] and o[i] >= c[i - 1] and c[i] <= o[i - 1] \
                and (o[i] - c[i]) > (c[i - 1] - o[i - 1])
            if (bull and up[i] >= 2) or (bear and dn[i] >= 2):
                j0, j1 = np.searchsorted(pa, te[i] - look), np.searchsorted(pa, te[i], side='right')
                lv = pp[j0:j1][pt[j0:j1] >= te[i] - look]
                if len(lv) >= 2:
                    strong = np.array([(np.abs(lv - v) <= CLU * A).sum() >= 2 for v in lv])
                    sv = lv[strong]
                    if bull and np.any((l[i] <= sv + ZONE * A) & (c[i] >= sv - ZONE * A) & (sv <= c[i])):
                        side = 1
                    if bear and np.any((h[i] >= sv - ZONE * A) & (c[i] <= sv + ZONE * A) & (sv >= c[i])):
                        side = -1
        if side == 0:
            i += 1
            continue
        e = i + 1
        px = o[e]
        sl = l[i] - SL_BUF * atr30[i] if side == 1 else h[i] + SL_BUF * atr30[i]
        risk = (px - sl) * side
        if risk <= 0:
            i += 1
            continue
        tp = px + side * TP_R * risk
        k0 = np.searchsorted(m1t, m30['t'].values[e])
        k_end = np.searchsorted(m1t, m30['t'].values[min(e + MAX_BARS, len(m30) - 1)])
        xp = None
        for k in range(k0, k_end):
            hit_sl = m1l[k] <= sl if side == 1 else m1h[k] >= sl
            hit_tp = m1h[k] >= tp if side == 1 else m1l[k] <= tp
            if hit_sl:
                xp = min(sl, m1o[k]) if side == 1 else max(sl, m1o[k])
                break
            if hit_tp:
                xp = max(tp, m1o[k]) if side == 1 else min(tp, m1o[k])
                break
        if xp is None:
            k = k_end
            xp = m1o[min(k, len(m1o) - 1)]
        x30 = min(np.searchsorted(m30['t'].values, m1t[min(k, len(m1t) - 1)], side='right') - 1, len(m30) - 1)
        nights = (pd.Timestamp(day[x30]) - pd.Timestamp(day[e])).days
        cost = (max(COST_USD, COST_PCT * px) + SWAP * nights * px) if cost_on else 0.0
        out.append((pd.Timestamp(m30['t'].values[e], tz='UTC'), side, (side * (xp - px) - cost) / risk))
        i = max(x30, e) + 1
    return pd.DataFrame(out, columns=['t', 'side', 'r'])


def report(name, t):
    r = t['r']
    n, ex = len(r), r.mean()
    se = r.std(ddof=1) / np.sqrt(n)
    yr = t.groupby(t['t'].dt.year)['r'].sum()
    print(f'{name}: {n} tr, Exp {ex:+.4f}R, SE {se:.4f}, Exp-2SE {ex - 2 * se:+.4f}, '
          f'jeet {100 * (r > 0).mean():.1f}%, kul {r.sum():+.1f}R, saal {(yr > 0).sum()}/{len(yr)}')
    return n, ex, se, (yr > 0).sum(), yr


def main():
    h1 = load('XAUUSD')
    h1 = h1[h1['t'] < pd.Timestamp('2025-01-01', tz='UTC')].reset_index(drop=True)
    H = htf(h1)
    m1 = load_m1('XAUUSD_M1_2021_24.zip')
    t = run(m1, H)
    n, ex, se, yp, yr = report('KUL', t)
    print('   saal: ' + ' '.join(f'{y}:{v:+.0f}' for y, v in yr.items()))
    report('BUY ', t[t['side'] == 1])
    report('SELL', t[t['side'] == -1])
    report('bina kharcha (maloomat)', run(m1, H, cost_on=False))
    print('PASS' if (n >= 100 and ex - 2 * se > 0 and yp >= 3) else 'FAIL')


if __name__ == '__main__':
    main()
