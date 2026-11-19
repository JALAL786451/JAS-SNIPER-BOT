#!/usr/bin/env python3
"""Koshish #107g (18 Nov 2026) - gold ki EK script: Tide 1D BUY (T) + 4H Supertrend BUY t5 (F) ek saath.

Qaida (badalna mana): docs/research/gold-do-buy-qaida.md (test se PEHLE commit 8075328).
S1 dono mil kar kamate? | S2 dohra risk (ek saath khule)? | S3 1D EMA50<EMA200 = 4H ke liye "BUY mat lo"?
Data: data/ftmo/XAU_XAG_H1_dukascopy.zip (gold H1). Kharcha 0.03% har taraf + swap 3%/saal (dono par).

  python3 tools/gold_do_buy.py
"""
import sys
from pathlib import Path

import numpy as np
import pandas as pd

sys.path.insert(0, str(Path(__file__).resolve().parent))
from ftmo_test import load, session_day, supertrend_up  # noqa: E402
from tide_ea_check import atr_rma, ema  # noqa: E402

COST, SWAP, RISK = 0.0003, 0.03 / 365, 0.5
CUT = pd.Timestamp('2019-01-01')


def day_bars(h1):
    sd = session_day(h1['t'])
    d = h1.groupby(sd.values).agg(o=('Open', 'first'), h=('High', 'max'), l=('Low', 'min'), c=('Close', 'last'))
    return d.reset_index().rename(columns={'index': 'sd'})


def tide_buy(d):
    """Radar r3 / pine_engine jaisa, SIRF BUY. Entry signal candle s ke close par."""
    o, h, l, c = (d[k].tolist() for k in 'ohlc')
    A, EF, ES = atr_rma(h, l, c, 14), ema(c, 50), ema(c, 200)
    sd = d['sd'].values
    out, pos = [], 0
    for s in range(210, len(c)):
        atc = False
        if pos:
            px = None
            if l[s] <= sl:
                px = o[s] if o[s] < sl else sl
            elif EF[s - 1] < ES[s - 1]:
                px, atc = c[s], True
            else:
                sl = max(sl, min(l[s - 5:s]))
                if c[s] <= sl:
                    px, atc = c[s], True
            if px is not None:
                nights = (sd[s] - sd[e]) / np.timedelta64(1, 'D')
                pnl = px - ep - COST * (ep + px) - SWAP * ep * max(nights, 0)
                out.append((sd[e], sd[s], pnl / r))
                pos = 0
        if not pos and not atc and A[s] > 0:
            if c[s] > max(h[s - 10:s]) and EF[s - 1] > ES[s - 1] and A[s] / c[s] * 100 >= 0.25:
                pos, e, ep, r = 1, s, c[s], 2.0 * A[s]
                sl = ep - r
    return pd.DataFrame(out, columns=['t', 'tx', 'R'])


def h4_bars(h1):
    """tools/rehnuma_r2_test.py main() jaisa."""
    day = session_day(h1['t'])
    blk = ((h1['t'].dt.tz_convert('America/New_York') + pd.Timedelta(hours=7)).dt.hour // 4).values
    key = pd.Series(list(zip(day.values, blk)))
    gid = (key != key.shift()).cumsum().values - 1
    return h1.groupby(gid).agg(t=('t', 'first'), Open=('Open', 'first'), High=('High', 'max'),
                               Low=('Low', 'min'), Close=('Close', 'last')).reset_index(drop=True)


def st_buy(x, slm=6.0):
    """rehnuma_r2_test.run(h4, +1, 6.0) jyon ka tyon + band hone ka din."""
    o, h, l, c = (x[k].values for k in ('Open', 'High', 'Low', 'Close'))
    up, atr = supertrend_up(h, l, c)
    sd = session_day(x['t']).values
    out, i, n = [], 31, len(x)
    while i < n - 1:
        if up[i] and not up[i - 1] and atr[i] > 0:
            e, ep, r = i + 1, o[i + 1], slm * atr[i]
            sl = ep - r
            j, xp = e, None
            while j < n:
                if l[j] <= sl:
                    xp = min(o[j], sl)
                    break
                if not up[j] and j + 1 < n:
                    xp = o[j + 1]
                    j += 1
                    break
                j += 1
            if xp is None:
                break
            nights = int((sd[min(j, n - 1)] - sd[e]) / np.timedelta64(1, 'D'))
            pnl = xp - ep - COST * (ep + xp) - SWAP * ep * max(nights, 0)
            out.append((sd[e], sd[min(j, n - 1)], pnl / r))
            i = j
            continue
        i += 1
    return pd.DataFrame(out, columns=['t', 'tx', 'R'])


def rstat(r):
    n = len(r)
    ex = r.mean() if n else np.nan
    se = r.std(ddof=1) / np.sqrt(n) if n > 1 else np.nan
    return n, ex, se


def acct(t):
    t = t.sort_values('tx')
    pct = t['R'].values * RISK
    cum = np.cumsum(pct)
    dd = float(np.max(np.maximum.accumulate(np.r_[0, cum])[1:] - cum)) if len(cum) else 0.0
    mon = pd.Series(pct, index=pd.DatetimeIndex(t['tx'])).groupby(pd.Grouper(freq='ME')).sum()
    mon = mon[mon != 0]
    return (cum[-1] if len(cum) else 0.0), dd, (mon.min() if len(mon) else 0.0), (100 * (mon > 0).mean() if len(mon) else 0.0)


def show(lab, t):
    n, ex, se = rstat(t['R'])
    kul, dd, wm, mp = acct(t)
    print(f'  {lab:9s} {n:4d} tr | Exp {ex:+.3f}R (-2SE {ex - 2 * se:+.3f}) | jeet {100 * (t["R"] > 0).mean():4.1f}% | '
          f'kul {kul:+6.1f}% | girawat {dd:5.1f}% | bura mahina {wm:+5.2f}% | mahine plus {mp:3.0f}%')
    return n, ex, se, kul


def open_days(t, days):
    s = set()
    for a, b in zip(t['t'].values, t['tx'].values):
        s.update(days[(days >= a) & (days <= b)].tolist())
    return s


def main():
    h1 = load('XAUUSD')
    d = day_bars(h1)
    T, F = tide_buy(d), st_buy(h4_bars(h1))
    efd, esd = np.array(ema(d['c'].tolist(), 50)), np.array(ema(d['c'].tolist(), 200))
    dsd = d['sd'].values
    k = np.searchsorted(dsd, F['t'].values, side='left') - 1          # entry din se PICHHLA band din
    F['mat_lo'] = efd[np.maximum(k, 0)] < esd[np.maximum(k, 0)]
    res = {}
    for nm, lo, hi in (('TALAASH 2003-2018', pd.Timestamp('2003-01-01'), CUT), ('IMTIHAN 2019-aaj', CUT, pd.Timestamp('2100-01-01'))):
        print(f'\n== {nm} (risk {RISK}% har engine, kharcha 0.03% + swap 3%) ==')
        t, f = T[(T['t'] >= lo) & (T['t'] < hi)], F[(F['t'] >= lo) & (F['t'] < hi)]
        rt, rf = show('T Tide 1D', t), show('F 4H t5', f)
        rd = show('DONO', pd.concat([t, f]))
        res[nm] = (rt, rf, rd, t, f)
        days = dsd[(dsd >= np.datetime64(lo)) & (dsd < np.datetime64(hi))]
        ot, of = open_days(t, days), open_days(f, days)
        mt = pd.Series(t['R'].values * RISK, index=pd.DatetimeIndex(t['tx'])).groupby(pd.Grouper(freq='ME')).sum()
        mf = pd.Series(f['R'].values * RISK, index=pd.DatetimeIndex(f['tx'])).groupby(pd.Grouper(freq='ME')).sum()
        mm = pd.concat([mt, mf], axis=1, sort=True).fillna(0)
        print(f'  S2: T khula {len(ot)} din, un mein F bhi {100 * len(ot & of) / max(len(ot), 1):.0f}% | '
              f'F khula {len(of)} din, un mein T bhi {100 * len(ot & of) / max(len(of), 1):.0f}% | '
              f'mahana corr {mm.corr().iloc[0, 1]:+.2f}')
        yr = pd.concat([t.assign(e='T'), f.assign(e='F')])
        yr = yr.assign(y=pd.DatetimeIndex(yr['tx']).year, p=yr['R'] * RISK).pivot_table(index='y', columns='e', values='p', aggfunc='sum').fillna(0)
        print('  saal (T | F | dono %): ' + '  '.join(f'{y % 100:02d}:{r.get("T", 0):+.1f}|{r.get("F", 0):+.1f}|{r.get("T", 0) + r.get("F", 0):+.1f}'
                                                   for y, r in yr.iterrows()))
    # S1
    (tt, tf, td, _, _), (it, ifn, idn, _, _) = res['TALAASH 2003-2018'], res['IMTIHAN 2019-aaj']
    s1t = tt[1] > 0 and tf[1] > 0 and td[1] - 2 * td[2] > 0
    s1i = it[1] > 0 and ifn[1] > 0 and idn[3] > 0
    print(f'\nS1 dono BUY: TALAASH {"PASS" if s1t else "FAIL"} | IMTIHAN {"PASS" if s1i else "FAIL"} -> '
          f'{"DONO BUY script mein" if s1t and s1i else "sirf wo engine jo dono daur Exp > 0"}')
    # S3
    print('\nS3 1D EMA50<EMA200 = 4H BUY mat lo?')
    out, s3_talaash_ok = {}, False
    for nm in res:
        if nm.startswith('IMTIHAN') and not s3_talaash_ok:
            break
        f = res[nm][4]
        g, b = f[~f['mat_lo']]['R'], f[f['mat_lo']]['R']
        ng, eg, sg = rstat(g)
        nb, eb, sb = rstat(b)
        diff, sed = eg - eb, np.sqrt(sg ** 2 + sb ** 2)
        out[nm] = (ng, nb, diff, sed, f)
        if nm.startswith('TALAASH'):
            s3_talaash_ok = ng >= 30 and nb >= 30 and diff > 2 * sed
        print(f'  {nm}: theek {ng} tr {eg:+.3f}R | mat lo {nb} tr {eb:+.3f}R | farq {diff:+.3f} = {diff / sed:+.2f} SE')
    if not s3_talaash_ok:
        print('  S3 TALAASH FAIL -> IMTIHAN chalaya NAHI; 4H ke liye EMA zone sirf ittila')
    else:
        _, _, diff_i, _, f = out['IMTIHAN 2019-aaj']
        kul_all = f['R'].sum() * RISK
        kul_flt = f[~f['mat_lo']]['R'].sum() * RISK
        ok = diff_i > 0 and kul_flt >= 0.9 * kul_all
        print(f'  S3 TALAASH PASS | IMTIHAN farq {diff_i:+.3f}, filter kul {kul_flt:+.1f}% vs {kul_all:+.1f}% -> {"PASS" if ok else "FAIL"}')


if __name__ == '__main__':
    main()
