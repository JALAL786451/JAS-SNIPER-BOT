#!/usr/bin/env python3
"""K4 (15 Nov 2026) - gold M1 2009-2026 ka data jorna + jaanch. Hukm: docs/k4-fable-hukm.md sec 3 / sec 6.4.

  python3 tools/k4_data.py            # jaanch ki report (waqt zone, jor, gap, ajeeb candle, H1 se mel)

Waqt zone (NAAP se, andaza nahi - neeche `jaanch()`):
  histdata 2009-2018 = NEW YORK ka MAQAMI waqt DST ke SAATH (hukm mein "EST, DST nahi" likha tha - GHALAT nikla:
     Dukascopy H1 (UTC) se mel sardiyon mein +5h, garmiyon mein +4h, har saal 2009-2018).
  QDM 2019, 2020, 2021-24, 2025, 2026 = UTC (roz ka waqfa 21-22 UTC garmi / 22-23 UTC sardi = 17-18 NY).
Sab ko UTC epoch second + NY 17:00 "session din" (tools/ftmo_test.py session_day jaisa) mein badla.
Qeemat BID, cent (x100) int mein gol - engine poora int hisaab karta hai.
"""
import io
import os
import sys
import tempfile
import zipfile
from pathlib import Path

import numpy as np
import pandas as pd

ROOT = Path(__file__).resolve().parent.parent
CACHE = Path(os.environ.get('K4_CACHE', tempfile.gettempdir())) / 'k4_cache'
NY = 'America/New_York'
QDM = [('2019', 'data/qdm/M1/XAUUSD_M1_2019.zip'), ('2020', 'data/qdm/M1/XAUUSD_M1_2020.zip'),
       ('2021-24', 'data/qdm/XAUUSD_M1_2021_24.zip'), ('2025', 'data/qdm/M1/XAUUSD_M1_2025.zip'),
       ('2026', 'data/qdm/M1/XAUUSD_M1_2026.zip')]


def _hist(y):
    """histdata: NY maqami waqt (DST ke saath) -> UTC."""
    z = zipfile.ZipFile(ROOT / f'data/histdata/XAUUSD_M1_{y}_NY.zip')
    nm = [n for n in z.namelist() if n.endswith('.csv')][0]
    x = pd.read_csv(z.open(nm), sep=';', header=None, names=['dt', 'O', 'H', 'L', 'C', 'V'])
    t = pd.to_datetime(x['dt'], format='%Y%m%d %H%M%S')
    x['t'] = t.dt.tz_localize(NY, ambiguous='NaT', nonexistent='NaT').dt.tz_convert('UTC')
    bad = int(x['t'].isna().sum())
    return x.dropna(subset=['t'])[['t', 'O', 'H', 'L', 'C']], bad


def _qdm(path):
    z = zipfile.ZipFile(ROOT / path)
    d = pd.read_csv(z.open(z.namelist()[0]))
    d['t'] = pd.to_datetime(d.Date.astype(str) + ' ' + d.Time, format='%Y%m%d %H:%M:%S').dt.tz_localize('UTC')
    return d.rename(columns={'Open': 'O', 'High': 'H', 'Low': 'L', 'Close': 'C'})[['t', 'O', 'H', 'L', 'C']]


def session_day(t):
    """17:00 NY se agla din; Sat/Sun -> Mon (tools/ftmo_test.py jaisa)."""
    d = (t.dt.tz_convert(NY) + pd.Timedelta(hours=7)).dt.normalize().dt.tz_localize(None)
    wd = d.dt.weekday
    return d + pd.to_timedelta(np.where(wd == 5, 2, np.where(wd == 6, 1, 0)), unit='D')


def load_m1(verbose=False):
    """Poora M1 2009-2026: DataFrame t(UTC), O,H,L,C (cent int32), sd (session din, datetime64), src."""
    f = CACHE / 'm1.pkl'
    if f.exists():
        return pd.read_pickle(f)
    parts, notes = [], []
    for y in range(2009, 2019):
        x, bad = _hist(y)
        x['src'] = f'hist{y}'
        parts.append(x)
        notes.append(f'hist{y}: {len(x)} candle, DST ke ghair-mojood/dohre waqt {bad}')
    for nm, p in QDM:
        x = _qdm(p)
        x['src'] = f'qdm{nm}'
        parts.append(x)
        notes.append(f'qdm{nm}: {len(x)} candle')
    d = pd.concat(parts, ignore_index=True)
    n0 = len(d)
    d = d.drop_duplicates('t', keep='first').sort_values('t').reset_index(drop=True)
    notes.append(f'kul {n0} -> dohre waqt hata kar {len(d)}')
    for c in 'OHLC':
        d[c] = np.round(d[c].values * 100).astype(np.int32)
    d['H'] = d[['O', 'H', 'L', 'C']].max(axis=1).astype(np.int32)
    d['L'] = d[['O', 'H', 'L', 'C']].min(axis=1).astype(np.int32)
    d['sd'] = session_day(d['t'])
    CACHE.mkdir(parents=True, exist_ok=True)
    d.to_pickle(f)
    (CACHE / 'm1_notes.txt').write_text('\n'.join(notes))
    if verbose:
        print('\n'.join(notes))
    return d


def load_h1():
    """Dukascopy H1 (UTC) 2003-2026 - sirf jaanch + 2005-08 EXTRA."""
    z = zipfile.ZipFile(ROOT / 'data/ftmo/XAU_XAG_H1_dukascopy.zip')
    h = pd.read_csv(io.BytesIO(z.read('XAUUSD/2026.10.28XAUUSD-H1-No Session.csv')))
    h['t'] = pd.to_datetime(h.Date.astype(str) + ' ' + h.Time, format='%Y%m%d %H:%M:%S').dt.tz_localize('UTC')
    h = h.rename(columns={'Open': 'O', 'High': 'H', 'Low': 'L', 'Close': 'C'})[['t', 'O', 'H', 'L', 'C']]
    for c in 'OHLC':
        h[c] = np.round(h[c].values * 100).astype(np.int32)
    h['sd'] = session_day(h['t'])
    return h


def daily(d):
    """Session din ki candle: index sd; O,H,L,C (cent), i0/i1 = M1 ki pehli/aakhri line."""
    g = d.groupby('sd', sort=True)
    out = pd.DataFrame({'O': g['O'].first(), 'H': g['H'].max(), 'L': g['L'].min(), 'C': g['C'].last(), 'n': g['C'].size()})
    idx = np.arange(len(d))
    out['i0'] = pd.Series(idx, index=d.index).groupby(d['sd']).first()
    out['i1'] = pd.Series(idx, index=d.index).groupby(d['sd']).last()
    return out


def jaanch():
    d = load_m1(verbose=True)
    print((CACHE / 'm1_notes.txt').read_text())
    h1 = load_h1()
    print(f"\nM1: {d.t.iloc[0]} -> {d.t.iloc[-1]}, {len(d)} candle | H1 Dukascopy: {h1.t.iloc[0]} -> {h1.t.iloc[-1]}")

    print('\n== 1. WAQT ZONE: M1 (UTC mein badalne ke baad) ghante ki candle vs Dukascopy H1 (UTC), har saal ==')
    hr = d.assign(hh=d.t.dt.floor('h')).groupby('hh').agg(H=('H', 'max'), L=('L', 'min'), C=('C', 'last'), n=('C', 'size'))
    j = hr[hr.n >= 55].join(h1.set_index('t'), rsuffix='_d', how='inner')
    j['y'] = j.index.year
    j['dC'], j['dH'], j['dL'] = (j.C - j.C_d).abs() / 100, (j.H - j.H_d) / 100, (j.L - j.L_d) / 100
    print('saal  ghante  ausat|dClose|$  95%|dClose|  M1high-H1high>$3  H1low-M1low>$3')
    for y, x in j.groupby('y'):
        print(f"{y}  {len(x):5d}   {x.dC.mean():.3f}       {x.dC.quantile(.95):.2f}       {(x.dH > 3).sum():3d}             {(x.dL < -3).sum():3d}")
    # DST hafte: March / November ke har din ka ausat farq (ghalat DST qaida ho to yahan $1+ dikhega)
    jj = j[(j.index.month.isin([3, 4, 10, 11]))]
    dd = jj.groupby(jj.index.date).dC.mean()
    print('March/April/Oct/Nov ke dinon mein sab se bara ausat |dClose| (5 din):', [(str(k), round(v, 2)) for k, v in dd.sort_values().tail(5).items()])

    print('\n== 2. JOR (saal badalne par gap / overlap) ==')
    src = d.src.values
    for i in np.where(src[1:] != src[:-1])[0]:
        a, b = d.iloc[i], d.iloc[i + 1]
        print(f"{a.src} aakhri {a.t} C={a.C/100:.2f} | {b.src} pehli {b.t} O={b.O/100:.2f} | waqfa {(b.t - a.t).total_seconds()/3600:.1f} ghante, qeemat farq {(b.O - a.C)/100:+.2f}")

    print('\n== 3. DIN: har session din ki candle ginti; ghaib din (Peer-Jumma jis din M1 nahi) ==')
    dy = daily(d)
    allbd = pd.bdate_range(dy.index[0], dy.index[-1])
    miss = [x for x in allbd if x not in dy.index]
    print(f"session din {len(dy)}; ghaib kaam ke din {len(miss)}: {[str(x.date()) for x in miss]}")
    short = dy[dy.n < 600]
    print(f"chhote din (<600 candle) {len(short)}: {[(str(k.date()), int(v)) for k, v in short.n.items()][:60]}")
    print('saal-ba-saal: din, ausat candle/din, ausat M1 range $, ausat din range $, aakhri close')
    rng = (d.H - d.L) / 100
    for y in range(2009, 2027):
        m = dy.index.year == y
        mm = d.sd.dt.year.values == y
        print(f"{y}: {m.sum():3d} din, {dy.n[m].mean():6.0f}, M1 {rng[mm].mean():.3f}, din {((dy.H - dy.L)[m] / 100).mean():6.2f}, close {dy.C[m].iloc[-1]/100:.2f}")

    print('\n== 4. Din ke andar waqfe (> 15 min, roz ke 17-18 NY waqfe aur weekend ke ilawa) ==')
    dt = d.t.diff().dt.total_seconds()
    ny = d.t.dt.tz_convert(NY)
    prev_ny = ny.shift(1)
    g = d[(dt > 900)].copy()
    g['gap_h'], g['prev'] = dt[g.index] / 3600, prev_ny[g.index]
    normal = (g.prev.dt.hour.isin([16, 17])) & (ny[g.index].dt.hour.isin([17, 18]))
    odd = g[~normal & (g.gap_h < 40)]
    print(f"kul waqfe >15min {len(g)}, aam (roz/weekend) {int(normal.sum()) + int((g.gap_h >= 40).sum())}, ajeeb {len(odd)}")
    print('saal ke hisaab se ajeeb waqfe (ginti, kul ghante):', {int(y): (len(x), round(float(x.gap_h.sum()), 1)) for y, x in odd.groupby(odd.t.dt.year)})

    print('\n== 5. AJEEB CANDLE: M1 range sab se bari 12 + C->O chhalang sab se bari 8 (weekend ke ilawa) ==')
    top = d.assign(r=rng).nlargest(12, 'r')
    for _, x in top.iterrows():
        print(f"  {x.t}  O {x.O/100:.2f} H {x.H/100:.2f} L {x.L/100:.2f} C {x.C/100:.2f}  range {x.r:.2f}  {x.src}")
    jump = (d.O - d.C.shift(1)).abs() / 100
    tj = d.assign(j=jump, gap_h=dt / 3600)
    tj = tj[tj.gap_h < 1.5].nlargest(8, 'j')
    for _, x in tj.iterrows():
        print(f"  chhalang {x.t}  {x.j:.2f}$ (waqfa {x.gap_h*60:.0f} min) {x.src}")
    wk = d.assign(j=(d.O - d.C.shift(1)) / 100, gap_h=dt / 3600)
    wk = wk[wk.gap_h >= 40]
    print(f"weekend/chhutti gap: {len(wk)}; ausat |gap| ${wk.j.abs().mean():.2f}; sab se bare:",
          [(str(x.t.date()), round(x.j, 2)) for _, x in wk.reindex(wk.j.abs().sort_values().index[-6:]).iterrows()])

    print('\n== 6. histdata 2015 vs QDM 2015 (do alag zariye, wahi saal) ==')
    q = _qdm('data/qdm/XAUUSD_M1_2015.zip').set_index('t')
    x = d[d.src == 'hist2015'].set_index('t')
    jq = x.join(q, rsuffix='_q', how='inner')
    print(f"mushtarik candle {len(jq)} (hist {len(x)}, qdm {len(q)}); ausat |dClose| ${(jq.C/100 - jq.C_q).abs().mean():.3f}; 99% ${(jq.C/100 - jq.C_q).abs().quantile(.99):.2f}")


if __name__ == '__main__':
    jaanch()
