#!/usr/bin/env python3
"""Koshish #54 (31 Oct 2026) = #37 noise boundary bilkul wahi, sirf ASLI kharcha (JasSpreadNaap s1, Exness Demo 20 din).
Qaida (badalna mana): docs/purana-haal.md, grep "Koshish #54 kharcha qaida".

  python3 tools/noise54.py              # TALAASH M1 2021-24
  python3 tools/noise54.py --imtihan    # 2025+ EK dafa (QDM M1 2025-aaj upload ke baad)

Naap (faisle ke waqt): US500m 0.40 = 0.0052%, USTECm 1.12 = 0.0038%. Kharcha har taraf = 0.75 x spread% (aana-jana 1.5 x spread).
"""
import argparse

import numpy as np
import pandas as pd

from noise_boundary_test import SYMS, line, load, matrices, trades

SPREAD = {'USA500': 0.0052e-2, 'USATECH': 0.0038e-2}       # faisle ke waqt ka ausat spread (hissa)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--imtihan', action='store_true')
    a = ap.parse_args()
    allt = []
    for nm, sym in SYMS.items():
        days, M = matrices(load(sym))
        t = trades(days, M)
        t = t[t.y >= 2025] if a.imtihan else t[t.y <= 2024]
        c = 0.75 * SPREAD[nm]
        t['r'] = (t.side * (t.x - t.e) - c * (t.e + t.x)) / t.R
        t['rp'] = (t.side * (t.x - t.e) - 1.5 * 0.40 * (1.0 if nm == 'USA500' else 1.12 / 0.40)) / t.R   # sirf jaanch: spread points mein pakka
        t['m'] = nm
        allt.append(t)
        print(f'{nm}: kharcha har taraf {100 * c:.5f}%')
        print('   ' + line('kul ', t.r) + f'   bina kharcha {t.r0.mean():+.3f}R')
        print('   ' + line('BUY ', t[t.side > 0].r))
        print('   ' + line('SELL', t[t.side < 0].r))
        print('   saal: ' + '  '.join(f'{y}:{v:+.1f}R' for y, v in t.groupby('y').r.sum().items()))
    t = pd.concat(allt)
    n, e, se = len(t), t.r.mean(), t.r.std(ddof=1) / np.sqrt(len(t))
    yr = t.groupby('y').r.sum()
    months = pd.to_datetime(t.d).dt.to_period('M').nunique()
    print('\n' + ('IMTIHAN 2025+ (EK dafa)' if a.imtihan else 'TALAASH 2021-24') + ' TOKRI (dono market), ASLI kharcha:')
    print('   ' + line('KUL ', t.r) + f'   bina kharcha {t.r0.mean():+.3f}R')
    print(f'   saal musbat {(yr > 0).sum()}/{len(yr)}: ' + '  '.join(f'{y}:{v:+.1f}R' for y, v in yr.items()))
    print(f'   ~{n / max(1, months):.1f} tr/mahina (dono)')
    print('   jaanch (faisla nahi): spread points mein pakka (aaj ke points, 2021 ki kam qeemat par % zyada): ' + line('KUL', t.rp))
    ok = (n >= 30 and e - 2 * se > 0) if a.imtihan else (n >= 100 and e - 2 * se > 0 and (yr > 0).sum() >= 3)
    print('PASS' if ok else 'FAIL')


if __name__ == '__main__':
    main()
