#!/usr/bin/env python3
"""Koshish #52 (31 Oct 2026) - "teacher" tareeqa: #51 ke 84 jor (3 khandaan x 28 market) mein se TALAASH par
behtareen 5 chuno, phir sirf unhe IMTIHAN 2019+ EK dafa. Qaida: docs/purana-haal.md, grep "Koshish #52 qaida".

  python3 tools/teacher52.py              # chunao (TALAASH) - top 5 ki list
  python3 tools/teacher52.py --imtihan    # top 5 par 2019+ EK dafa
"""
import argparse

import numpy as np
import pandas as pd

from har_market51 import CUT, FAM, daily, rtab, stat
from tokri47 import BOTH, GROUPS, load_any

TOP, Z_IM = 5, 2.33


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--imtihan', action='store_true')
    a = ap.parse_args()
    rows, tabs = [], {}
    for s in [s for g in GROUPS.values() for s in g]:
        x = daily(load_any(s))
        for fam, fn in FAM.items():
            t = rtab(x, fn(x, s in BOTH))
            tabs[(s, fam)] = t
            tal = t[t.t < CUT]
            n, e, se = stat(tal.r)
            yr = tal.groupby(tal.t.dt.year).r.sum()
            if n >= 30 and (yr > 0).mean() > 0.5:
                rows.append((s, fam, n, e, e - 2 * se, (yr > 0).sum(), len(yr)))
    df = pd.DataFrame(rows, columns=['m', 'k', 'n', 'exp', 'exp2', 'yp', 'yn']).sort_values('exp2', ascending=False)
    top = df.head(TOP)
    print(f'CHUNAO (TALAASH < 2019): {len(df)} jor shart (>= 30 tr, saal > 50%) poori; Exp-2SE se TOP {TOP}:')
    for _, r in top.iterrows():
        print(f'   {r.m:15s} {r.k:10s} {int(r.n):4d} tr  Exp {r.exp:+.3f}R  Exp-2SE {r.exp2:+.3f}  saal {int(r.yp)}/{int(r.yn)}')
    if not a.imtihan:
        return
    print(f'\nIMTIHAN 2019+ (EK dafa): PASS = >= 15 tr aur Exp - {Z_IM} SE > 0')
    for _, r in top.iterrows():
        im = tabs[(r.m, r.k)]
        im = im[im.t >= CUT]
        n, e, se = stat(im.r)
        yr = im.groupby(im.t.dt.year).r.sum()
        ok = n >= 15 and e - Z_IM * se > 0
        print(f'   {r.m:15s} {r.k:10s} {n:4d} tr  Exp {e:+.3f}R  Exp-{Z_IM}SE {e - Z_IM * se:+.3f}  jeet {100 * (im.r > 0).mean():.0f}%'
              f'  saal {(yr > 0).sum()}/{len(yr)}  {"SELECT (PASS)" if ok else "FAIL"}')


if __name__ == '__main__':
    main()
