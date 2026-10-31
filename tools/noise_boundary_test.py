#!/usr/bin/env python3
"""Koshish #37 (qaida 29 Oct, test 31 Oct 2026) - Zarattini-Aziz-Barbon 2024 "Beat the Market" noise-boundary
intraday momentum, USA500 + USATECH M1. Qaida (badalna mana): docs/purana-haal.md, grep "Koshish #37 qaida".

  python3 tools/noise_boundary_test.py            # TALAASH 2021-24 (data/qdm/M1)

Cash session 09:30-16:00 NY. sigma(k) = pichhle 14 din ka ausat |Close(k)/Open - 1|. UB = max(Open, kal Close) x (1+sigma),
LB = min(...) x (1-sigma). Sirf :00 / :30 (10:00-15:30) par: close > UB = BUY, < LB = SELL; trailing stop BUY max(UB, VWAP),
SELL min(LB, VWAP) sirf :00 / :30 par; 16:00 sab band. R = sigma x entry. Kharcha 0.03%/taraf.
"""
import glob
import io
import zipfile

import numpy as np
import pandas as pd

from ftmo_test import COST, ROOT

SYMS = {'USA500': 'USA500IDXUSD', 'USATECH': 'USATECHIDXUSD'}
NMIN = 390
DEC = list(range(30, 361, 30))                # 10:00 ... 15:30 (09:30 se minute)


def load(sym):
    parts = []
    for p in sorted(glob.glob(str(ROOT / 'data' / 'qdm' / 'M1' / f'{sym}_M1_*.zip'))):
        with zipfile.ZipFile(p) as z:
            n = next(x for x in z.namelist() if x.endswith('.csv'))
            parts.append(pd.read_csv(io.BytesIO(z.read(n)), dtype={'Date': str, 'Time': str}))
    df = pd.concat(parts)
    df['t'] = pd.to_datetime(df['Date'] + df['Time'], format='%Y%m%d%H:%M:%S', utc=True)
    df = df.sort_values('t').drop_duplicates('t')
    ny = df['t'].dt.tz_convert('America/New_York')
    df['k'] = ny.dt.hour * 60 + ny.dt.minute - (9 * 60 + 30)
    df['d'] = ny.dt.date
    df = df[(df.k >= 0) & (df.k < NMIN)]
    return df


def matrices(df):
    good = df.groupby('d').filter(lambda g: len(g) >= 300 and (g.k == 0).any() and (g.k == NMIN - 1).any())
    days = sorted(good.d.unique())
    M = {}
    for col in ('Open', 'High', 'Low', 'Close', 'Volume'):
        M[col] = good.pivot(index='d', columns='k', values=col).reindex(index=days, columns=range(NMIN)).values
    return days, M


def trades(days, M):
    O, H, L, C, V = M['Open'], M['High'], M['Low'], M['Close'], M['Volume']
    op = O[:, 0]
    move = np.abs(C / op[:, None] - 1)
    sig = pd.DataFrame(move).rolling(14, min_periods=10).mean().shift(1).values
    pc = np.r_[np.nan, C[:-1, NMIN - 1]]
    out = []
    for i in range(len(days)):
        if np.isnan(pc[i]) or np.isnan(sig[i, DEC[0]]):
            continue
        tp = (H[i] + L[i] + C[i]) / 3
        w = np.nan_to_num(V[i], nan=0.0)
        if np.nansum(w) <= 0:
            w = np.where(np.isnan(tp), 0.0, 1.0)
        tpw = np.nan_to_num(tp) * w
        vwap = np.cumsum(tpw) / np.where(np.cumsum(w) > 0, np.cumsum(w), np.nan)
        hi_b, lo_b = max(op[i], pc[i]), min(op[i], pc[i])
        pos, ep, rr, ek = 0, 0.0, 0.0, 0
        for k in DEC:
            c, s = C[i, k], sig[i, k]
            if np.isnan(c) or np.isnan(s):
                continue
            ub, lb = hi_b * (1 + s), lo_b * (1 - s)
            if pos > 0 and c < max(ub, vwap[k]):
                out.append((days[i], pos, ep, c, rr, k)); pos = 0; continue
            if pos < 0 and c > min(lb, vwap[k]):
                out.append((days[i], pos, ep, c, rr, k)); pos = 0; continue
            if pos == 0:
                if c > ub:
                    pos, ep, rr, ek = 1, c, s * c, k
                elif c < lb:
                    pos, ep, rr, ek = -1, c, s * c, k
        if pos:
            xp = C[i, NMIN - 1]
            out.append((days[i], pos, ep, xp, rr, NMIN - 1))
    t = pd.DataFrame(out, columns=['d', 'side', 'e', 'x', 'R', 'k'])
    t['r0'] = t.side * (t.x - t.e) / t.R
    t['r'] = (t.side * (t.x - t.e) - COST * (t.e + t.x)) / t.R
    t['pct'] = t.side * (t.x - t.e) / t.e - COST * 2
    t['y'] = pd.to_datetime(t.d).dt.year
    return t


def line(nm, r):
    n = len(r)
    if n < 2:
        return f'{nm}: {n} tr'
    e, se = r.mean(), r.std(ddof=1) / np.sqrt(n)
    return f'{nm}: {n:5d} tr, Exp {e:+.3f}R, SE {se:.3f}, Exp-2SE {e - 2 * se:+.3f}, jeet {100 * (r > 0).mean():.0f}%'


def main():
    allt = []
    for nm, sym in SYMS.items():
        days, M = matrices(load(sym))
        t = trades(days, M)
        t['m'] = nm
        allt.append(t)
        print(f'{nm}: {len(days)} din')
        print('   ' + line('kul ', t.r) + f'   bina kharcha {t.r0.mean():+.3f}R')
        print('   ' + line('BUY ', t[t.side > 0].r))
        print('   ' + line('SELL', t[t.side < 0].r))
        print('   saal: ' + '  '.join(f'{y}:{v:+.1f}R' for y, v in t.groupby('y').r.sum().items()))
    t = pd.concat(allt)
    n, e, se = len(t), t.r.mean(), t.r.std(ddof=1) / np.sqrt(len(t))
    yr = t.groupby('y').r.sum()
    months = pd.to_datetime(t.d).dt.to_period('M').nunique()
    print('\nTALAASH 2021-24 TOKRI (dono market):')
    print('   ' + line('KUL ', t.r) + f'   bina kharcha {t.r0.mean():+.3f}R')
    print(f'   saal musbat {(yr > 0).sum()}/{len(yr)}: ' + '  '.join(f'{y}:{v:+.1f}R' for y, v in yr.items()))
    print(f'   ~{n / max(1, months):.1f} tr/mahina (dono), ausat trade {100 * t.pct.mean():+.3f}% (kharcha ke baad)')
    ok = n >= 100 and e - 2 * se > 0 and (yr > 0).sum() >= 3
    print('PASS' if ok else 'FAIL')


if __name__ == '__main__':
    main()
