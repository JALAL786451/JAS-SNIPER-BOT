#!/usr/bin/env python3
"""K10 / B (16 Nov 2026, 61vi) - demo 474832446 ki asli trades vs Python signal (i6 IBS, t5 trend) - US500 + USTEC.
Data: data/ftmo H1 (30 Sep tak) + data/demo_474832446/QDM_M1_20261001_1115.zip (QDM Dukascopy M1, UTC) -> H1.
Sirf milaan (koshish nahi, koi qaida / setting nahi badalti).   python3 tools/milaan_k10.py
"""
import io
import zipfile
from pathlib import Path

import numpy as np
import pandas as pd

from ftmo_4h import st4h_trades
from ftmo_test import atr_rma, ibs_trades, load, session_day

ROOT = Path(__file__).resolve().parent.parent
Z = ROOT / 'data' / 'demo_474832446' / 'QDM_M1_20261001_1115.zip'
KEY = {'US500': 'USA500IDXUSD', 'USTEC': 'USATECHIDXUSD'}


def m1(sym):
    with zipfile.ZipFile(Z) as z:
        n = next(x for x in z.namelist() if KEY[sym] in x)
        d = pd.read_csv(io.BytesIO(z.read(n)), dtype={'Date': str, 'Time': str})
    d['t'] = pd.to_datetime(d['Date'] + d['Time'], format='%Y%m%d%H:%M:%S', utc=True)
    return d[['t', 'Open', 'High', 'Low', 'Close']]


def main():
    for sym in KEY:
        m = m1(sym)
        h1 = m.set_index('t').resample('1h').agg({'Open': 'first', 'High': 'max', 'Low': 'min', 'Close': 'last'}).dropna().reset_index()
        a = load(sym)
        d = pd.concat([a[a['t'] < h1['t'].iloc[0]], h1]).reset_index(drop=True)
        t = d['t'].values
        print(f'\n===== {sym} (data {str(t[-1])[:16]} UTC tak) =====')
        print('t5 trend (Python, 20 Oct se):')
        for (ei, xi, e, x, sd, dr) in st4h_trades(d, 6.0):
            if str(t[ei])[:10] >= '2026-10-20':
                print(f'   {str(t[ei])[:16]} -> {str(t[xi])[:16]}  entry {e:9.2f}  exit {x:9.2f}  SL {e - dr * sd:9.2f}  fasla {sd:7.2f}  {(x - e) * dr / sd:+.2f}R')
        print('i6 IBS (Python, 17:00 NY close, 20 Oct se):')
        for (ei, xi, e, x, sd, dr) in ibs_trades(d):
            if str(t[ei])[:10] >= '2026-10-20':
                print(f'   {str(t[ei])[:16]} -> {str(t[xi])[:16]}  entry {e:9.2f}  exit {x:9.2f}  SL {e - sd:9.2f}  fasla {sd:7.2f}  {(x - e) / sd:+.2f}R')
        # rozana jadwal: 17:00 NY din; IBS 17:00 par aur 16:15 NY par (EA i6 ka faisla)
        sd_ = session_day(d['t'])
        g = d.assign(sd=sd_).groupby('sd', sort=True)
        H, L, C = g['High'].max(), g['Low'].min(), g['Close'].last()
        atr = pd.Series(atr_rma(H.values, L.values, C.values, 14), index=H.index)
        sma = C.rolling(200).mean()
        ny = m['t'].dt.tz_convert('America/New_York')
        msd = session_day(m['t'])
        print('rozana: din | close17 IBS17 | 16:15 NY: qeemat IBS | SMA200 | 3xATR14 (us din tak)')
        for day in H.index[H.index >= '2026-10-28']:
            mm = m[(msd == day).values & ((ny.dt.hour * 60 + ny.dt.minute) < 16 * 60 + 15).values & (ny.dt.normalize().dt.tz_localize(None) <= day).values]
            if len(mm) == 0:
                continue
            hh, ll, cc = max(mm['High'].max(), 0), mm['Low'].min(), mm['Close'].iloc[-1]
            ibs17 = (C[day] - L[day]) / (H[day] - L[day])
            ibs16 = (cc - ll) / (hh - ll)
            print(f'   {str(day)[:10]} | {C[day]:9.2f} {ibs17:5.2f} | {cc:9.2f} {ibs16:5.2f} {"BUY?" if ibs16 < 0.2 and cc > sma[day] else ("band?" if ibs16 > 0.8 else "")} | {sma[day]:9.2f} | {3 * atr[day]:7.2f}')


if __name__ == '__main__':
    main()
