#!/usr/bin/env python3
"""K22 (65vi, 17 Nov 2026) - user ka "agla qadam" mashwara (Gemini): gold par 2 untested shakal. Gold M1 QDM UTC 2019 - 4 Nov 2026.

QAIDA (test se PEHLE likha, badalna mana):
  PASS = trade >= 500, Exp - 2SE > 0 (asli kharcha $0.40/oz round trip), aur 8 mein se >= 5 saal plus.
  Sirf MAIN shakal par faisla; doosri shakal sirf maloomat.

A) London ORB: London 08:00-08:30 local (DST khud) ki M1 range. 08:30 se 12:00 local tak pehla M5 close range ke
   paar = agli M5 open par entry (BUY upar / SELL neeche). SL = range ka doosra kinara. Din mein ek trade, Mon-Fri.
   MAIN: TP nahi, 16:00 London band.  Maloomat: TP 2R.
   Range 0 ya < $0.50 = skip.
B) Door nikal kar wapsi (fade): M15, SMA20 + ATR14 (M15). Sirf 19:00-06:00 UTC (der NY + Asia), Mon-Fri.
   Close > SMA20 + k*ATR = agli open par SELL (neeche ulta BUY). SL = entry -/+ 1.5 ATR (= 1R), TP = signal waqt ka SMA20,
   warna 12 candle (3 ghante) baad band. Ek waqt ek trade.
   MAIN: k = 2.5.  Maloomat: k = 3.0.
Ek candle mein SL + TP dono = SL pehle (ehtiyat).
NATEEJA (17 Nov): A FAIL (1975 tr -0.062R, 3/8 saal; bina kharcha +0.036) | B FAIL (1840 tr -0.132R, 0/8; bina kharcha -0.014).
  python3 tools/k22_london_orb_fade_test.py
"""
import io
import zipfile
from pathlib import Path

import numpy as np
import pandas as pd

Q = Path(__file__).resolve().parent.parent / 'data' / 'qdm'
COST = 0.40


def load_m1():
    fs = [Q / 'M1' / f'XAUUSD_M1_{y}.zip' for y in (2019, 2020, 2025, 2026)] + [Q / 'XAUUSD_M1_2021_24.zip']
    out = []
    for f in fs:
        with zipfile.ZipFile(f) as z:
            d = pd.read_csv(io.BytesIO(z.read(z.namelist()[0])), dtype={'Date': str, 'Time': str})
        d['t'] = pd.to_datetime(d['Date'] + d['Time'], format='%Y%m%d%H:%M:%S')
        out.append(d[['t', 'Open', 'High', 'Low', 'Close']])
    return pd.concat(out).sort_values('t').drop_duplicates('t').set_index('t')


def rs(m, f):
    return m.resample(f).agg({'Open': 'first', 'High': 'max', 'Low': 'min', 'Close': 'last'}).dropna()


def orb(m1, tp_r=None):
    m5 = rs(m1, '5min')
    loc = m5.index.tz_localize('UTC').tz_convert('Europe/London')
    m5 = m5.assign(ld=loc.date, lm=loc.hour * 60 + loc.minute, wd=loc.weekday)
    l1 = m1.index.tz_localize('UTC').tz_convert('Europe/London')
    m1 = m1.assign(ld=l1.date, lm=l1.hour * 60 + l1.minute)
    rng = m1[(m1.lm >= 480) & (m1.lm < 510)].groupby('ld').agg(hi=('High', 'max'), lo=('Low', 'min'), n=('Close', 'size'))
    out = []
    for day, g in m5[(m5.lm >= 510) & (m5.lm < 960) & (m5.wd < 5)].groupby('ld'):
        if day not in rng.index or rng.loc[day, 'n'] < 20:
            continue
        hi, lo = rng.loc[day, 'hi'], rng.loc[day, 'lo']
        if hi - lo < 0.5:
            continue
        o, h, l, c, lm = (g[k].values for k in ('Open', 'High', 'Low', 'Close', 'lm'))
        for i in range(len(g) - 1):
            if lm[i] + 5 > 720:
                break
            d = 1 if c[i] > hi else (-1 if c[i] < lo else 0)
            if not d:
                continue
            ep = o[i + 1]
            sl = lo if d > 0 else hi
            r = d * (ep - sl)
            if r <= 0:
                break
            tp = ep + d * tp_r * r if tp_r else None
            xp = None
            for j in range(i + 1, len(g)):
                if (l[j] <= sl) if d > 0 else (h[j] >= sl):
                    xp = sl
                    break
                if tp is not None and ((h[j] >= tp) if d > 0 else (l[j] <= tp)):
                    xp = tp
                    break
            if xp is None:
                xp = c[-1]
            out.append((g.index[i + 1], d, (d * (xp - ep) - COST) / r))
            break
    return pd.DataFrame(out, columns=['t', 'd', 'R'])


def fade(m1, k):
    x = rs(m1, '15min').reset_index()
    o, h, l, c = (x[q].values for q in ('Open', 'High', 'Low', 'Close'))
    n = len(c)
    sma = pd.Series(c).rolling(20).mean().values
    pc = np.r_[c[0], c[:-1]]
    tr = np.maximum(h - l, np.maximum(abs(h - pc), abs(l - pc)))
    atr = pd.Series(tr).ewm(alpha=1 / 14, adjust=False).mean().values
    hr, wd = x['t'].dt.hour.values, x['t'].dt.weekday.values
    out, i = [], 20
    while i < n - 13:
        ok = (hr[i] >= 19 or hr[i] < 6) and wd[i] < 5
        d = -1 if c[i] > sma[i] + k * atr[i] else (1 if c[i] < sma[i] - k * atr[i] else 0)
        # gap / naya hafta: agli candle 1 ghante se zyada door ho to nahi
        if not ok or not d or (x['t'].iloc[i + 1] - x['t'].iloc[i]) > pd.Timedelta('1h'):
            i += 1
            continue
        ep, r = o[i + 1], 1.5 * atr[i]
        sl, tp = ep - d * r, sma[i]
        if d * (tp - ep) <= 0:
            i += 1
            continue
        xp, j = None, i + 1
        while j <= i + 12:
            if (l[j] <= sl) if d > 0 else (h[j] >= sl):
                xp = sl
                break
            if (h[j] >= tp) if d > 0 else (l[j] <= tp):
                xp = tp
                break
            j += 1
        if xp is None:
            j = i + 12
            xp = c[j]
        out.append((x['t'].iloc[i + 1], d, (d * (xp - ep) - COST) / r))
        i = j + 1
    return pd.DataFrame(out, columns=['t', 'd', 'R'])


def show(lab, t, main):
    R = t['R'].values
    se = R.std(ddof=1) / np.sqrt(len(R))
    cum = R.cumsum()
    dd = float(np.max(np.maximum.accumulate(np.r_[0, cum])[1:] - cum))
    yr = t.groupby(t['t'].dt.year)['R'].sum()
    plus = int((yr > 0).sum())
    ok = len(R) >= 500 and R.mean() - 2 * se > 0 and plus >= 5
    print(f'\n{lab}: {len(R)} tr, jeet {100 * (R > 0).mean():.0f}%, Exp {R.mean():+.3f}R (Exp-2SE {R.mean() - 2 * se:+.3f}), '
          f'kul {R.sum():+.0f}R, girawat {dd:.0f}R, plus saal {plus}/{len(yr)} | BUY {R[t.d == 1].mean():+.3f} '
          f'SELL {R[t.d == -1].mean():+.3f}' + (f'  => {"PASS" if ok else "FAIL"}' if main else '  (maloomat)'))
    print('  saal: ' + ' '.join(f'{y}:{v:+.0f}' for y, v in yr.items()))
    return ok


def main():
    m1 = load_m1()
    print(f'gold M1 {len(m1)}, {m1.index[0]} - {m1.index[-1]}, kharcha ${COST}/oz')
    show('A London ORB MAIN (TP nahi, 16:00 band)', orb(m1), True)
    show('A London ORB TP 2R', orb(m1, 2.0), False)
    show('B Fade MAIN k=2.5', fade(m1, 2.5), True)
    show('B Fade k=3.0', fade(m1, 3.0), False)


if __name__ == '__main__':
    main()
