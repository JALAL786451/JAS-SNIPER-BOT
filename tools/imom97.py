#!/usr/bin/env python3
"""Koshish #97 (4 Nov 2026) - Intraday Momentum (Gao, Han, Li, Zhou 2018 JFE) US500 + USTEC, #9 ki ghaltiyan theek (pilot).
Qaida (badalna mana): docs/purana-haal.md, grep "Koshish #97 qaida".

  python3 tools/imom97.py                       # TALAASH 2012-2018
  python3 tools/imom97.py --imtihan --pakka     # 2019/2021+ EK dafa (sirf TALAASH PASS + user tasdeeq)
"""
import argparse
import datetime as D
import glob
import io
import sys
import zipfile
from pathlib import Path

import numpy as np
import pandas as pd

sys.path.insert(0, str(Path(__file__).resolve().parent))
from ftmo60 import hol  # noqa: E402

ROOT = Path(__file__).resolve().parent.parent
SYMS = {'US500': ('USA500IDXUSD', 0.0052e-2), 'USTEC': ('USATECHIDXUSD', 0.0038e-2)}


def nyse_days(y0, y1):
    return [x for x in pd.date_range(f'{y0}-01-01', f'{y1}-12-31').date if x.isoweekday() <= 5 and not hol(x)]


def half_day(x):
    if x.month == 12 and x.day == 24:
        return True
    if x.month == 7 and x.day == 3:
        return True
    if x.month == 11 and x.isoweekday() == 5:
        th = x - D.timedelta(days=1)
        return th.isoweekday() == 4 and 22 <= th.day <= 28   # 4th Thursday
    return False


def load(qid, y0, y1):
    parts = []
    for y in range(y0, y1 + 1):
        for p in glob.glob(str(ROOT / 'data' / 'qdm' / 'M1' / f'{qid}_M1_{y}.zip')):
            with zipfile.ZipFile(p) as z:
                n = next(x for x in z.namelist() if x.endswith('.csv'))
                parts.append(pd.read_csv(io.BytesIO(z.read(n)), dtype={'Date': str, 'Time': str}))
    df = pd.concat(parts)
    df['t'] = pd.to_datetime(df['Date'] + df['Time'], format='%Y%m%d%H:%M:%S', utc=True)
    df = df.sort_values('t').drop_duplicates('t')
    ny = df['t'].dt.tz_convert('America/New_York')
    df['d'] = ny.dt.date
    df['k'] = ny.dt.hour * 60 + ny.dt.minute
    df = df[(df.k >= 595) & (df.k <= 959)]
    return {d: g for d, g in df.groupby('d', sort=True)}


def run(sym, y0, y1):
    qid, spr = SYMS[sym]
    bars = load(qid, y0, y1)
    days = nyse_days(y0, y1)
    cost = 1.5 * spr
    hist, out = [], []
    for i in range(1, len(days)):
        d, pd_ = days[i], days[i - 1]
        if half_day(d) or half_day(pd_) or d not in bars or pd_ not in bars:
            continue
        g, gp = bars[d], bars[pd_]
        w10 = g[(g.k >= 595) & (g.k <= 599)]
        wp = gp[(gp.k >= 955) & (gp.k <= 959)]
        we = g[(g.k >= 930) & (g.k <= 934)]
        wx = g[(g.k >= 955) & (g.k <= 959)]
        if not len(w10) or not len(wp) or not len(we) or not len(wx):
            continue
        p10, pp = w10['Close'].iloc[-1], wp['Close'].iloc[-1]
        ent, ex = we['Open'].iloc[0], wx['Close'].iloc[-1]
        r1 = p10 / pp - 1
        lh = abs(ex / ent - 1)
        if len(hist) >= 20 and r1 != 0:
            dr = 1 if r1 > 0 else -1
            rr = 3 * np.mean(hist[-20:]) * ent
            path = g[(g.k >= we['k'].iloc[0]) & (g.k <= wx['k'].iloc[-1])]
            xp = ex
            for o, h, lo in zip(path['Open'].values, path['High'].values, path['Low'].values):
                sl = ent - dr * rr
                if dr == 1 and lo <= sl:
                    xp = min(o, sl)
                    break
                if dr == -1 and h >= sl:
                    xp = max(o, sl)
                    break
            g_r = dr * (xp - ent) / rr
            n_r = g_r - cost * ent / rr
            out.append((d, sym, dr, r1, g_r, n_r, dr * (xp / ent - 1) * 100, xp != ex))
        hist.append(lh)
    return out


def stats(r):
    r = np.asarray(r)
    se = r.std(ddof=1) / np.sqrt(len(r))
    return r.mean(), se


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--imtihan', action='store_true')
    ap.add_argument('--pakka', action='store_true')
    a = ap.parse_args()
    if a.imtihan and not a.pakka:
        print('INKAAR: IMTIHAN sirf EK dafa, TALAASH PASS + user tasdeeq ke baad, --imtihan --pakka se.')
        sys.exit(2)
    if a.imtihan:
        has19 = glob.glob(str(ROOT / 'data' / 'qdm' / 'M1' / 'USA500IDXUSD_M1_2019.zip'))
        y0, y1, tag = (2019 if has19 else 2021), 2026, 'IMTIHAN'
    else:
        y0, y1, tag = 2012, 2018, 'TALAASH'
    allt = []
    for s in SYMS:
        allt += run(s, y0, y1)
    df = pd.DataFrame(allt, columns=['d', 'sym', 'dr', 'r1', 'g', 'n', 'pct', 'sl'])
    print(f'#97 {tag} {y0}-{y1}: {len(df)} tr (~{len(df) / ((y1 - y0 + 1) * 12):.1f}/mahina), SL lage {df.sl.mean() * 100:.1f}%')
    for s in SYMS:
        x = df[df.sym == s]
        m, se = stats(x.n)
        print(f'  {s}: {len(x)} tr, Exp {m:+.3f}R (+-{se:.3f}), bina kharcha {x.g.mean():+.3f}R, ausat {x.pct.mean():+.4f}%, jeet {(x.n > 0).mean() * 100:.0f}%')
    m, se = stats(df.n)
    print(f'  KUL: Exp {m:+.3f}R, Exp-2SE {m - 2 * se:+.3f}, bina kharcha {df.g.mean():+.3f}R, jeet {(df.n > 0).mean() * 100:.0f}%')
    yr = df.groupby(pd.to_datetime(df.d).dt.year)['n'].agg(['size', 'mean'])
    print('  saal: ' + ', '.join(f'{y} {v["mean"]:+.3f}({int(v["size"])})' for y, v in yr.iterrows()))
    q = df.r1.abs().quantile(2 / 3)
    t3 = df[df.r1.abs() >= q]
    print(f'  maloomat |r1| top tihai: {len(t3)} tr, Exp {t3.n.mean():+.3f}R')
    if tag == 'TALAASH':
        ok = (len(df) >= 300 and m - 2 * se > 0 and all(df[df.sym == s].n.mean() > 0 for s in SYMS)
              and (yr['mean'] > 0).sum() >= 5)
        print(f'TALAASH: {"PASS" if ok else "FAIL"} (shart: >= 300 tr, Exp-2SE > 0, dono market Exp > 0, saal >= 5/7)  | purana #9: -0.207R, 0/9')
    else:
        ok = len(df) >= 300 and m - 2 * se > 0
        print(f'IMTIHAN: {"PASS" if ok else "FAIL"} (shart: >= 300 tr, Exp-2SE > 0)')


if __name__ == '__main__':
    main()
