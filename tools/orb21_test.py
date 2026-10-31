#!/usr/bin/env python3
"""Koshish #21 (qaida 17 Oct, kharcha 1 Nov 2026) - Zarattini & Aziz 2023 "Can Day Trading Really Be Profitable?" 5m ORB, SIRF USTEC.
Qaida (badalna mana): `JasOrb5EA.mq5` o1 header + docs/purana-haal.md, grep "Koshish #21 kharcha".

  python3 tools/orb21_test.py              # TALAASH 2021-24 (data/qdm/M1)
  python3 tools/orb21_test.py --imtihan    # 2025+ EK dafa (sirf TALAASH PASS ke baad)

09:30 NY pehli 5m candle hari = BUY, laal = SELL, doji = nahi. Entry 09:35 open, SL = pehli candle ka doosra kinara (1R), TP 10R,
warna 16:00 band. Ek minute mein SL + TP = SL. Kharcha har taraf 0.00285% (asli spread x 0.75).
"""
import argparse

import numpy as np
import pandas as pd

from noise_boundary_test import NMIN, line, load, matrices

COST = 0.75 * 0.0038e-2
TPR = 10.0


def trades(days, M):
    O, H, L, C = M['Open'], M['High'], M['Low'], M['Close']
    out = []
    for i, d in enumerate(days):
        o0, c4 = O[i, 0], C[i, 4]
        hi, lo = np.nanmax(H[i, :5]), np.nanmin(L[i, :5])
        e = O[i, 5]
        if np.isnan(o0) or np.isnan(c4) or np.isnan(e) or c4 == o0:
            continue
        side = 1 if c4 > o0 else -1
        sl = lo if side > 0 else hi
        R = side * (e - sl)
        if not R > 0:
            continue
        tp = e + side * TPR * R
        xp, k = C[i, NMIN - 1], NMIN - 1
        for j in range(5, NMIN):
            h, l, op = H[i, j], L[i, j], O[i, j]
            if np.isnan(h):
                continue
            hit_sl = l <= sl if side > 0 else h >= sl
            hit_tp = h >= tp if side > 0 else l <= tp
            if hit_sl:
                xp = sl if j == 5 else (min(op, sl) if side > 0 else max(op, sl))
                k = j
                break
            if hit_tp:
                xp = tp if j == 5 else (max(op, tp) if side > 0 else min(op, tp))
                k = j
                break
        if np.isnan(xp):
            continue
        out.append((d, side, e, xp, R, k))
    t = pd.DataFrame(out, columns=['d', 'side', 'e', 'x', 'R', 'k'])
    t['r0'] = t.side * (t.x - t.e) / t.R
    t['r'] = (t.side * (t.x - t.e) - COST * (t.e + t.x)) / t.R
    t['y'] = pd.to_datetime(t.d).dt.year
    return t


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--imtihan', action='store_true')
    a = ap.parse_args()
    days, M = matrices(load('USATECHIDXUSD'))
    t = trades(days, M)
    t = t[t.y >= 2025] if a.imtihan else t[t.y <= 2024]
    n, e, se = len(t), t.r.mean(), t.r.std(ddof=1) / np.sqrt(len(t))
    yr = t.groupby('y').r.sum()
    print(('IMTIHAN 2025+ (EK dafa)' if a.imtihan else 'TALAASH 2021-24') + ' - USTEC 5m ORB, asli kharcha')
    print('   ' + line('KUL ', t.r) + f'   bina kharcha {t.r0.mean():+.3f}R')
    print('   ' + line('BUY ', t[t.side > 0].r))
    print('   ' + line('SELL', t[t.side < 0].r))
    print(f'   saal musbat {(yr > 0).sum()}/{len(yr)}: ' + '  '.join(f'{y}:{v:+.1f}R' for y, v in yr.items()))
    print(f'   TP 10R lage: {(t.r0 > 9).sum()}, SL: {(t.r0 <= -0.99).sum()}, 16:00 band: {((t.r0 > -0.99) & (t.r0 <= 9)).sum()}')
    print(f'   ausat R = {100 * (t.R / t.e).mean():.3f}% qeemat, ~{n / max(1, pd.to_datetime(t.d).dt.to_period("M").nunique()):.1f} tr/mahina')
    ok = (n >= 30 and e - 2 * se > 0) if a.imtihan else (n >= 100 and e - 2 * se > 0 and (yr > 0).mean() > 0.5)
    print('PASS' if ok else 'FAIL')


if __name__ == '__main__':
    main()
