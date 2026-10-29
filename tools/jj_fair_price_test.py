#!/usr/bin/env python3
"""Koshish #44 (29 Oct 2026) - JJ Simon "Fair Pricing Theory" (Chart Fanatics), 1m USTEC.
Qaida (badalna mana): docs/purana-haal.md, grep "Koshish #44 qaida".

  python3 tools/jj_fair_price_test.py      # TALAASH 2021-22 (data/ustec)

A = session ki pehli candle ki continuation (6h ulta bias), B = FP (session open) ki taraf reversion
(displacement / BOS, >= 30.4 point door). TP 38 / SL 25 point, 60 candle time stop, 3 lagataar haar = session band.
"""
import io
import zipfile

import numpy as np
import pandas as pd

from ftmo_test import ROOT

SESS = {'Asia': (18, 0), 'NY': (9, 30), 'NYPM': (14, 0)}
TP, SL, NEED, HOLD, WIN = 38.0, 25.0, 0.8 * 38.0, 60, 90
COST_PTS, COST_PCT = 3.0, 0.0003


def load():
    with zipfile.ZipFile(ROOT / 'data' / 'ustec' / 'USTEC_M1_2021-2022_dukascopy.zip') as z:
        csv = next(n for n in z.namelist() if n.endswith('.csv'))
        df = pd.read_csv(io.BytesIO(z.read(csv)), dtype={'Date': str, 'Time': str})
    df['t'] = pd.to_datetime(df['Date'] + df['Time'], format='%Y%m%d%H:%M:%S', utc=True)
    return df.sort_values('t').drop_duplicates('t').reset_index(drop=True)


def sim(o, h, l, c, e, side, tp, sl):
    """entry open[e]; (exit index, point)."""
    ep = o[e]
    for k in range(e, min(e + HOLD, len(o))):
        if side > 0:
            if l[k] <= ep - sl:
                return k, -sl
            if h[k] >= ep + tp:
                return k, tp
        else:
            if h[k] >= ep + sl:
                return k, -sl
            if l[k] <= ep - tp:
                return k, tp
    k = min(e + HOLD, len(o)) - 1
    return k, side * (c[k] - ep)


def run(df):
    o, h, l, c = (df[k].values.astype(float) for k in ('Open', 'High', 'Low', 'Close'))
    t = df['t']
    ny = t.dt.tz_convert('America/New_York')
    n = len(df)
    # swing high / low (3 candle), j+1 par pakka
    swl = np.zeros(n, bool)
    swh = np.zeros(n, bool)
    swl[1:-1] = (l[1:-1] < l[:-2]) & (l[1:-1] < l[2:])
    swh[1:-1] = (h[1:-1] > h[:-2]) & (h[1:-1] > h[2:])
    # har i ke liye: i-1 tak pakka aakhri swing low/high, aur kya woh i se pehle close se toot chuka
    lastL, lastH = np.full(n, np.nan), np.full(n, np.nan)
    curL = curH = np.nan
    for i in range(3, n):
        j = i - 2                                 # j+1 = i-1 tak pakka
        if swl[j]:
            curL = l[j]
        if swh[j]:
            curH = h[j]
        lastL[i], lastH[i] = curL, curH
        if not np.isnan(curL) and c[i] < curL:     # i par toota -> aage active nahi
            curL = np.nan
        if not np.isnan(curH) and c[i] > curH:
            curH = np.nan
    hm = ny.dt.hour.values * 60 + ny.dt.minute.values
    tns = t.values.astype('datetime64[ns]').astype(np.int64)
    out = []
    busy = -1                                     # pichhli trade ka exit index
    starts = []
    for name, (hh, mm) in SESS.items():
        for s0 in np.flatnonzero(hm == hh * 60 + mm):
            starts.append((s0, name))
    starts.sort()
    for s0, name in starts:
        if s0 < 400 or s0 + 2 >= n or s0 <= busy:
            continue
        end_ns = tns[s0] + WIN * 60 * 10**9
        s1 = int(np.searchsorted(tns, end_ns))     # window: s0..s1-1
        fp = o[s0]
        k6 = int(np.searchsorted(tns, tns[s0] - 6 * 3600 * 10**9))
        bias = -1 if c[s0 - 1] > o[k6] else 1
        color = np.sign(c[s0] - o[s0])
        nxt = s0 + 1
        # A
        if color == bias and color != 0:
            brk = c[s0] < l[s0 - 3:s0].min() if color < 0 else c[s0] > h[s0 - 3:s0].max()
            if brk:
                tp, sl = (76.0, 50.0) if h[s0] - l[s0] > 25 else (TP, SL)
                x, pts = sim(o, h, l, c, s0 + 1, int(color), tp, sl)
                out.append((t[s0 + 1], name, 'A', int(color), o[s0 + 1], pts, sl))
                busy, nxt = x, x
        # B
        streak = 0
        i = max(nxt, s0 + 1)
        while i < s1 and i + 1 < n and streak < 3:
            side = -1 if c[i] > fp else 1
            if abs(c[i] - fp) >= NEED:
                if side < 0:
                    disp = c[i] < o[i] and c[i - 1] > o[i - 1] and o[i] - c[i] > c[i - 1] - o[i - 1] and c[i] < l[i - 1]
                    bos = not np.isnan(lastL[i]) and c[i] < lastL[i]
                else:
                    disp = c[i] > o[i] and c[i - 1] < o[i - 1] and c[i] - o[i] > o[i - 1] - c[i - 1] and c[i] > h[i - 1]
                    bos = not np.isnan(lastH[i]) and c[i] > lastH[i]
                if disp or bos:
                    x, pts = sim(o, h, l, c, i + 1, side, TP, SL)
                    out.append((t[i + 1], name, 'B', side, o[i + 1], pts, SL))
                    streak = streak + 1 if pts < 0 else 0
                    busy = x
                    i = x + 1
                    continue
            i += 1
    return pd.DataFrame(out, columns=['t', 'sess', 'kind', 'side', 'ep', 'pts', 'sl'])


def stats(name, r, t):
    n = len(r)
    if n < 2:
        print(f'{name}: {n} tr')
        return n, 0.0, 1.0
    ex, se = r.mean(), r.std(ddof=1) / np.sqrt(n)
    yr = r.groupby(t.dt.year).sum()
    print(f'{name}: {n:5d} tr, Exp {ex:+.4f}R, SE {se:.4f}, Exp-2SE {ex - 2 * se:+.4f}, jeet {100 * (r > 0).mean():.1f}%, '
          f'kul {r.sum():+.1f}R, saal ' + ' '.join(f'{y}:{v:+.1f}' for y, v in yr.items()))
    return n, ex, se


def main():
    df = load()
    tr = run(df)
    tr['r'] = (tr['pts'] - COST_PTS) / tr['sl']
    tr['r0'] = tr['pts'] / tr['sl']
    tr['rp'] = (tr['pts'] - COST_PCT * 2 * tr['ep']) / tr['sl']
    print(f'TALAASH 2021-22 USTEC 1m, kharcha {COST_PTS} point/trade')
    months = tr['t'].dt.strftime('%Y%m').nunique()
    print(f'{len(tr)} trade, {len(tr) / months:.1f} tr/mahina')
    n, ex, se = stats('KUL      ', tr['r'], tr['t'])
    for k in ('A', 'B'):
        stats(f'  {k}      ', tr.loc[tr.kind == k, 'r'], tr.loc[tr.kind == k, 't'])
    for s in SESS:
        stats(f'  {s:7s}', tr.loc[tr.sess == s, 'r'], tr.loc[tr.sess == s, 't'])
    for sd, nm in ((1, 'BUY'), (-1, 'SELL')):
        stats(f'  {nm:7s}', tr.loc[tr.side == sd, 'r'], tr.loc[tr.side == sd, 't'])
    print(f'   bina kharcha {tr["r0"].mean():+.4f}R, 0.03%/taraf {tr["rp"].mean():+.4f}R')
    yr = tr['r'].groupby(tr['t'].dt.year).sum()
    ok = n >= 100 and ex - 2 * se > 0 and (yr > 0).all()
    print('PASS' if ok else 'FAIL')


if __name__ == '__main__':
    main()
