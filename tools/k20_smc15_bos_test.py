#!/usr/bin/env python3
"""K20 (64vi, 17 Nov 2026) - user ka diya "Gold 15M Non-Repainting SMC Strategy" (BOS) jyon ka tyon, gold M1 (QDM UTC) 2019-26.
Qaide (script se): 15m; pivot 12/12 (confirm 12 candle baad) = level; close level ke paar crossover + close EMA200 ki taraf
-> agli candle open par entry; SL 2 ATR14, TP 2.5 x SL; sirf 07-20 UTC Mon-Fri; ek waqt ek; entry par level reset.
Ek candle mein SL aur TP dono = SL pehle (ehtiyat). Kharcha: 0 / asli ($0.20 har taraf ~ spread) / script wala ($0.05).
  python3 tools/k20_smc15_bos_test.py
"""
import io
import zipfile
from pathlib import Path

import numpy as np
import pandas as pd

Q = Path(__file__).resolve().parent.parent / 'data' / 'qdm'


def load():
    fs = [Q / 'M1' / f'XAUUSD_M1_{y}.zip' for y in (2019, 2020, 2025, 2026)] + [Q / 'XAUUSD_M1_2021_24.zip']
    out = []
    for f in fs:
        with zipfile.ZipFile(f) as z:
            d = pd.read_csv(io.BytesIO(z.read(z.namelist()[0])), dtype={'Date': str, 'Time': str})
        d['t'] = pd.to_datetime(d['Date'] + d['Time'], format='%Y%m%d%H:%M:%S')
        out.append(d[['t', 'Open', 'High', 'Low', 'Close']])
    m = pd.concat(out).sort_values('t').drop_duplicates('t').set_index('t')
    return m.resample('15min').agg({'Open': 'first', 'High': 'max', 'Low': 'min', 'Close': 'last'}).dropna().reset_index()


def run(x, cost):
    o, h, l, c = (x[k].values for k in ('Open', 'High', 'Low', 'Close'))
    n = len(c)
    ema = pd.Series(c).ewm(span=200, adjust=False).mean().values
    tr = np.maximum(h - l, np.maximum(abs(h - np.r_[c[0], c[:-1]]), abs(l - np.r_[c[0], c[:-1]])))
    atr = pd.Series(tr).ewm(alpha=1 / 14, adjust=False).mean().values
    hr, wd = x['t'].dt.hour.values, x['t'].dt.weekday.values
    L = 12
    ch = cl = np.nan
    pch = pcl = np.nan
    pos, out = 0, []
    i = 2 * L + 1
    while i < n - 1:
        k = i - L
        if h[k] == h[k - L:k + L + 1].max() and h[k] > h[k - L:k].max() if L else False:
            ch = h[k]
        if l[k] == l[k - L:k + L + 1].min() and l[k] < l[k - L:k].min() if L else False:
            cl = l[k]
        bull = not np.isnan(ch) and c[i] > ch and c[i - 1] <= (pch if not np.isnan(pch) else ch) and c[i] > ema[i]
        bear = not np.isnan(cl) and c[i] < cl and c[i - 1] >= (pcl if not np.isnan(pcl) else cl) and c[i] < ema[i]
        sess = 7 <= hr[i] < 20 and wd[i] < 5
        d = 1 if (bull and sess) else (-1 if (bear and sess) else 0)
        pch, pcl = ch, cl
        if d:
            if d == 1:
                ch = np.nan
            else:
                cl = np.nan
            ep, r = o[i + 1], 2.0 * atr[i]
            sl, tp = c[i] - d * r, c[i] + d * 2.5 * r
            j, xp = i + 1, None
            while j < n:
                if (l[j] <= sl) if d > 0 else (h[j] >= sl):
                    xp = sl
                    break
                if (h[j] >= tp) if d > 0 else (l[j] <= tp):
                    xp = tp
                    break
                j += 1
            if xp is None:
                break
            out.append((x['t'].iloc[i + 1], d, (d * (xp - ep) - 2 * cost) / r))
            i = j + 1
            pch, pcl = ch, cl
            continue
        i += 1
    return pd.DataFrame(out, columns=['t', 'd', 'R'])


def main():
    x = load()
    print(f'gold 15m candles {len(x)}, {x["t"].iloc[0]} - {x["t"].iloc[-1]}')
    for lab, cost in (('bina kharcha', 0.0), ('script wala $0.05', 0.05), ('asli $0.20/taraf', 0.20)):
        t = run(x, cost)
        R = t['R'].values
        se = R.std(ddof=1) / np.sqrt(len(R))
        cum = R.cumsum()
        dd = float(np.max(np.maximum.accumulate(np.r_[0, cum])[1:] - cum))
        yr = t.groupby(t['t'].dt.year)['R'].sum()
        print(f'\n{lab}: {len(R)} tr, jeet {100 * (R > 0).mean():.0f}%, Exp {R.mean():+.3f}R (Exp-2SE {R.mean() - 2 * se:+.3f}), '
              f'kul {R.sum():+.1f}R, girawat {dd:.1f}R | BUY {R[t.d == 1].mean():+.3f} SELL {R[t.d == -1].mean():+.3f}')
        print('  saal: ' + ' '.join(f'{y}:{v:+.0f}' for y, v in yr.items()))


if __name__ == '__main__':
    main()
