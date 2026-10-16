#!/usr/bin/env python3
"""Koshish #17 (user ka idea, 14 Oct, user 'HAN') - MT5 M1 data par TALAASH test.

Qaida (pehle se likha, 16 Oct):
 SELL wala (asal #17): kitab hedge hai, ek SELL 0.01 S par. Gold (bid) S+0.30 chhoo le to SELL band
 (ask par) -> kitab NET BUY. Wapsi par wohi SELL dobara jab bid neeche aaye: level = max(band ki bid,
 chotti - X). Phir naya S = level. X = 3 / 5 / 10 ($).
 ULTA: BUY B par; bid B-0.30 = BUY band -> NET SELL; dobara BUY level = min(band ki bid, tah + X).
 Hafte ki aakhri M1 candle par khula NET band (weekend gap nahi).
 Hisaab: hedge mein equity nahi hilti, is liye har chakkar ka faida = NET khula rehne ke dauran harkat
 - spread (data ka SPREAD khana, 3 digit = points x 0.001). 0.01 lot cent = $1 harkat par 1 USC.
 Ek candle mein high/low ki tarteeb nahi pata -> dobara-level pichhli candles ki chotti se (sakht).
 PASS (sec 4): chakkar >= 100, Exp - 2SE > 0, aadhe se zyada saal musbat. Saal 2021-2024 (TALAASH).
Usage: python3 tools/koshish17_test.py file1.csv [file2.csv ...]
"""
import sys, math
from datetime import datetime, timedelta

CUT = 0.30
YEARS = range(2021, 2025)

rows = []
for fn in sys.argv[1:]:
    for ln in open(fn, encoding='utf-8', errors='ignore'):
        p = ln.strip().split('\t')
        if len(p) < 9 or not p[0][:1].isdigit():
            continue
        t = datetime.strptime(p[0] + ' ' + p[1], '%Y.%m.%d %H:%M:%S')
        if t.year not in YEARS:
            continue
        rows.append((t, float(p[2]), float(p[3]), float(p[4]), float(p[5]), int(p[8]) * 0.001))
rows.sort()
n = len(rows)
print(f'{n} M1 candles, {rows[0][0]} se {rows[-1][0]}')

def run(X, side):
    """side=+1: asal (SELL band, NET BUY). side=-1: ulta (BUY band, NET SELL). Prices mirrored."""
    res = []  # (year, pnl $)
    anchor = None          # hedge wali lot ki qeemat (S ya B)
    openNet = None         # (cut_bid, extreme, spread_at_cut, t)
    for i in range(n):
        t, o, h, l, c, sp = rows[i]
        if side == -1:
            o, h, l, c = -o, -l, -h, -c
        last = i == n - 1 or rows[i + 1][0] - t > timedelta(hours=12)
        if anchor is None:
            anchor = o
        if openNet is None:
            if h >= anchor + CUT:
                cut = max(o, anchor + CUT)
                openNet = [cut, cut, sp, t]
                # isi candle mein wapsi nahi ginte (sakht)
        else:
            cut, ext, sp0, t0 = openNet
            level = max(cut, ext - X)
            if l <= level:
                px = min(o, level)
                res.append((t.year, px - cut - sp0))
                anchor, openNet = px, None
            else:
                openNet[1] = max(ext, h)
        if last and openNet is not None:
            cut, ext, sp0, t0 = openNet
            res.append((t.year, c - cut - sp0))
            anchor, openNet = None, None
        elif last:
            anchor = None
    return res

def show(res, label):
    v = [p for _, p in res]
    m = len(v)
    ex = sum(v) / m
    sd = math.sqrt(sum((x - ex) ** 2 for x in v) / (m - 1)); se = sd / math.sqrt(m)
    eq = pk = dd = 0.0
    for x in v:
        eq += x; pk = max(pk, eq); dd = max(dd, pk - eq)
    yr = {}
    for y, p in res:
        yr[y] = yr.get(y, 0) + p
    py = sum(1 for y in yr if yr[y] > 0)
    ok = m >= 100 and ex - 2 * se > 0 and py * 2 > len(yr)
    ys = ' '.join(f'{y}:{yr[y]:+.0f}' for y in sorted(yr))
    print(f'{label}: {m} chakkar, jeet {100*sum(1 for x in v if x>0)/m:.1f}%, Exp {ex:+.3f}$ (±{se:.3f}), '
          f'Exp-2SE {ex-2*se:+.3f} | 0.01 lot kul {eq:+.0f} USC, max DD {dd:.0f} | saal {ys} | {"PASS" if ok else "FAIL"}')

for side, name in ((1, 'ASAL (SELL band, NET BUY)'), (-1, 'ULTA (BUY band, NET SELL)')):
    for X in (3, 5, 10):
        show(run(X, side), f'{name} X={X}')
