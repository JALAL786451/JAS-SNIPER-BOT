#!/usr/bin/env python3
"""64vi (17 Nov 2026) - K14: Umar Ashraf "Morning Top" (Gemini khulasa, docs/research/umar-ashraf-morning-top.md).
Orderflow / tape CFD par nahi -> sirf QEEMAT wala hissa, qaide TEST SE PEHLE likhe (badalna mana):
  1. Din gap DOWN: 9:30 ET open < pichle din 16:00 close se kam az kam 0.10%.
  2. Chhor do agar pichle 3 din lagatar neeche band hue (overextended).
  3. 9:30 ke baad rally: din ka high >= open + 30% gap.
  4. 5-min candle (9:45-10:30 ke beech band) pichli 5-min candle ke LOW se neeche band ho, aur din ka high pichli 3
     candles mein bana ho (taza top) -> SELL agli candle ke open par. Din mein 1 trade.
  5. SL = din ka high + 0.02%. Exit: E1 = 2R TP ya 16:00 band; E2 = sirf 16:00 band (SL wahi).
  Muqabla (placebo): wahi signal BINA gap shart (har din) -> gap ka asar hai ya nahi.
Kharcha 0.01% har taraf. Data data/qdm/M1 (UTC) 2012-26.
  python3 tools/k14_morning_top_test.py
"""
import io
import zipfile
from pathlib import Path

import numpy as np
import pandas as pd

M1 = Path(__file__).resolve().parent.parent / 'data' / 'qdm' / 'M1'
COST = 0.0001


def load(pref):
    out = []
    for zp in sorted(M1.glob(f'{pref}_M1_*.zip')):
        with zipfile.ZipFile(zp) as z:
            df = pd.read_csv(io.BytesIO(z.read(z.namelist()[0])), dtype={'Date': str, 'Time': str})
        t = pd.to_datetime(df['Date'] + df['Time'], format='%Y%m%d%H:%M:%S', utc=True).dt.tz_convert('America/New_York')
        m = t.dt.hour * 60 + t.dt.minute
        keep = (m >= 570) & (m < 960)
        d = df.loc[keep, ['Open', 'High', 'Low', 'Close']].copy()
        d['t'] = t[keep].dt.tz_localize(None)
        out.append(d)
    return pd.concat(out).sort_values('t').drop_duplicates('t').reset_index(drop=True)


def days(df):
    df['d'] = df['t'].dt.normalize()
    res = []
    g = list(df.groupby('d'))
    closes = [x['Close'].iloc[-1] if x['t'].iloc[-1].hour == 15 else np.nan for _, x in g]
    for k in range(4, len(g)):
        d, x = g[k]
        pc = closes[k - 1]
        if np.isnan(pc) or x['t'].iloc[0].strftime('%H:%M') != '09:30' or x['t'].iloc[-1].hour != 15:
            continue
        down3 = closes[k - 1] < closes[k - 2] < closes[k - 3] < closes[k - 4]
        res.append((d, x.reset_index(drop=True), pc, down3))
    return res


def trade(x, pc, need_gap, skip3, down3, exit_mode):
    op = x['Open'].iloc[0]
    gap = pc - op
    if need_gap and (gap < 0.001 * pc or (skip3 and down3)):
        return None
    f = x.set_index('t').resample('5min', label='left', closed='left').agg(
        {'Open': 'first', 'High': 'max', 'Low': 'min', 'Close': 'last'}).dropna()
    hi_run, hi_idx = -np.inf, -1
    for i in range(len(f)):
        if f['High'].iloc[i] > hi_run:
            hi_run, hi_idx = f['High'].iloc[i], i
        tm = f.index[i] + pd.Timedelta(minutes=5)
        if tm.hour * 60 + tm.minute < 585 or i == 0:
            continue
        if tm.hour * 60 + tm.minute > 630:
            return None
        rally = hi_run - op
        if need_gap and rally < 0.3 * gap:
            continue
        if not need_gap and rally <= 0:
            continue
        if f['Close'].iloc[i] < f['Low'].iloc[i - 1] and i - hi_idx <= 3:
            et = tm
            rest = x[x['t'] >= et]
            if len(rest) < 2:
                return None
            ep = rest['Open'].iloc[0]
            sl = hi_run * 1.0002
            r = sl - ep
            if r <= 0:
                return None
            tp = ep - 2 * r
            xp = rest['Close'].iloc[-1]
            for h, l, o in zip(rest['High'].values, rest['Low'].values, rest['Open'].values):
                if h >= sl:
                    xp = max(o, sl)
                    break
                if exit_mode == 1 and l <= tp:
                    xp = min(o, tp)
                    break
            return (ep - xp - COST * (ep + xp)) / r
    return None


def stat(rs):
    rs = np.array(rs)
    if len(rs) == 0:
        return '   0 tr'
    cum = rs.cumsum()
    dd = float(np.max(np.maximum.accumulate(np.r_[0, cum])[1:] - cum))
    return f'{len(rs):4d} tr {rs.mean():+.3f}R kul {rs.sum():+6.1f}R dd {dd:4.1f}R jeet {100 * (rs > 0).mean():3.0f}%'


def main():
    for nm, pref in (('US500', 'USA500IDXUSD'), ('USTEC', 'USATECHIDXUSD')):
        dd = days(load(pref))
        print(f'\n== {nm}: {len(dd)} din | 2012-18 | 2019-26 ==')
        for lab, ng, sk, ex in (('E1 gap+skip3 (asal)', 1, 1, 1), ('E2 gap+skip3 EOD  ', 1, 1, 2),
                                ('E1 gap, skip nahi ', 1, 0, 1), ('E1 BINA gap (placebo)', 0, 0, 1)):
            a, b = [], []
            for d, x, pc, d3 in dd:
                r = trade(x, pc, ng, sk, d3, ex)
                if r is not None:
                    (a if d.year < 2019 else b).append(r)
            print(f'  {lab:22s}: {stat(a)} | {stat(b)}')


if __name__ == '__main__':
    main()
