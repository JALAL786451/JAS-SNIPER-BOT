#!/usr/bin/env python3
"""Koshish #57 (1 Nov 2026) - "teacher" tareeqa 4H TREND par: #47 ke 24 naye market (#53 wale 4 bahar) mein se TALAASH par
behtareen 5, phir sirf unhe IMTIHAN 2019+ EK dafa. Qaida: docs/purana-haal.md, grep "Koshish #57 qaida".

  python3 tools/teacher57.py              # chunao (TALAASH) - top 5
  python3 tools/teacher57.py --imtihan    # top 5 par 2019+ EK dafa
"""
import argparse

import numpy as np
import pandas as pd

from tokri47 import BOTH, CUT, FTMO4, GROUPS, K, load_any, r_of, trades4h

TOP, Z_IM = 5, 2.33


def stat(r):
    n = len(r)
    if n < 2:
        return n, 0.0, 9.9
    return n, r.mean(), r.std(ddof=1) / np.sqrt(n)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--imtihan', action='store_true')
    a = ap.parse_args()
    rows, tabs = [], {}
    for g, syms in GROUPS.items():
        for s in syms:
            if s in FTMO4:
                continue
            df = load_any(s)
            t = r_of(df, trades4h(df, K, s in BOTH))
            tabs[s] = t
            tal = t[t.t < CUT]
            n, e, se = stat(tal.r)
            yr = tal.groupby(tal.t.dt.year).r.sum()
            ok = n >= 30 and (yr > 0).mean() > 0.5
            rows.append((s, g, n, e, e - 2 * se, (yr > 0).sum(), len(yr), ok))
    df = pd.DataFrame(rows, columns=['m', 'g', 'n', 'exp', 'exp2', 'yp', 'yn', 'ok']).sort_values('exp2', ascending=False)
    print(f'CHUNAO (TALAASH < 2019): {len(df)} market, shart (>= 30 tr, saal > 50%) poori {df.ok.sum()}:')
    for _, r in df.iterrows():
        print(f'   {r.m:15s} {r.g:8s} {int(r.n):4d} tr  Exp {r.exp:+.3f}R  Exp-2SE {r.exp2:+.3f}  saal {int(r.yp)}/{int(r.yn)}'
              f'{"" if r.ok else "  (shart nahi)"}')
    top = df[df.ok].head(TOP)
    print(f'TOP {TOP}: ' + ', '.join(top.m))
    if not a.imtihan:
        return
    print(f'\nIMTIHAN 2019+ (EK dafa): PASS = >= 15 tr aur Exp - {Z_IM} SE > 0')
    for _, r in top.iterrows():
        im = tabs[r.m]
        im = im[im.t >= CUT]
        n, e, se = stat(im.r)
        yr = im.groupby(im.t.dt.year).r.sum()
        ok = n >= 15 and e - Z_IM * se > 0
        print(f'   {r.m:15s} {n:4d} tr  Exp {e:+.3f}R  Exp-{Z_IM}SE {e - Z_IM * se:+.3f}  jeet {100 * (im.r > 0).mean():.0f}%'
              f'  saal {(yr > 0).sum()}/{len(yr)}  {"SELECT (PASS)" if ok else "FAIL"}')


if __name__ == '__main__':
    main()
