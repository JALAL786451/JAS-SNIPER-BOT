#!/usr/bin/env python3
"""K9 / A (16 Nov 2026, 61vi) - FTMO jor #101 (t5 trend 0.75% + i6 IBS 1% + k2 khirki 0.15% + Kachhua e2 0.25%) ka TAJZIYA.
Sirf CHUNAO 2012-2018 (IMTIHAN 2019+ yahan NAHI khulta). Dhaancha: tools/ftmo101.py (wahi trades, kharcha, swap 0, slot).
Hisaab mustaqil $100k par (compounding nahi, run_cost jaisa) - har EA ka P/L alag, jama = jor.

  python3 tools/jor105.py            # tajziya: saal/mahina hissa, mel, bure din, ek-EA-nikaal challenge
"""
import sys

import numpy as np
import pandas as pd

from ftmo53_asli import ASLI, run_cost
from ftmo60 import summary
from ftmo68 import KCOST, KH, khirki_trades
from ftmo_4h import st4h_trades
from ftmo_test import FILES, Mkt, ibs_trades, kachhua_trades, load
from tokri47 import load_any
import ftmo_test
from ftmo99 import SPREAD

ftmo_test.SWAP = 0.0
TIDE = SPREAD
NAMES = ['t5 trend', 'i6 IBS', 'k2 khirki', 'e2 Kachhua']
RISK = [0.75, 1.0, 0.15, 0.25]
BAL0 = ftmo_test.BAL0


def banao():
    """ftmo101 jaisa: (mk, [4 system ki trades], [slot map], cost, grid, cetday)."""
    base = list(FILES)
    syms = base + list(KH) + [s for s in TIDE if s not in base]
    dfs = {s: load(s) for s in base}
    dfs.update({s: load_any(s) for s in syms if s not in base})
    grid = np.unique(np.concatenate([d['t'].values.astype('datetime64[ns]').astype(np.int64) for d in dfs.values()]))
    cet = pd.to_datetime(grid, utc=True).tz_convert('Europe/Prague')
    cetday = (cet.year * 10000 + cet.month * 100 + cet.day).values
    mk = [Mkt(s, dfs[s], grid) for s in syms]
    trend = [st4h_trades(dfs[s], 6.0) if s in base else [] for s in syms]
    ibs = [ibs_trades(dfs[s]) if s in ('US500', 'USTEC') else [] for s in syms]
    kh = [khirki_trades(dfs[s], *KH[s]) if s in KH else [] for s in syms]
    td = [kachhua_trades(dfs[s]) if s in TIDE else [] for s in syms]
    cost = [0.75 * ASLI[s] if s in base else (0.75 * TIDE[s] if s in TIDE else KCOST) for s in syms]
    tmap = {mi: 100 + mi for mi in range(len(syms))}
    tmap[syms.index('XAGUSD')] = 100 + syms.index('XAUUSD')
    return syms, mk, [trend, ibs, kh, td], [{}, {}, {}, tmap], cost, grid, cetday


def raasta(mk, trades, smap, cost, grid, start_ns, end_ns, risk=1.0):
    """Ek system ka mustaqil raasta (risk % par): bal[t] (band P/L), mtm[t] (khuli, close), wm[t] (khuli, bura).
    run_cost jaisa: slot bhara ho to trade chhoot jati; t = gx par pehle band phir naya."""
    n = len(grid)
    dbal, mtm, wm = np.zeros(n), np.zeros(n), np.zeros(n)
    ru = BAL0 * risk / 100
    tl = []
    for mi, m in enumerate(mk):
        for (ei, xi, e, x, sd, d) in trades[mi]:
            ge, gx = m.gi[ei], m.gi[xi]
            if start_ns <= grid[ge] < end_ns:
                tl.append((ge, gx, smap.get(mi, mi), e, x, ru / sd, mi, d))
    tl.sort()
    free, lst = {}, []
    for (ge, gx, slot, e, x, u, mi, d) in tl:
        if gx <= ge or free.get(slot, -1) > ge:
            continue
        free[slot] = gx
        m = mk[mi]
        dbal[ge] -= cost[mi] * e * u
        if gx < n:
            dbal[gx] += d * (x - e) * u - cost[mi] * x * u
        mtm[ge:gx] += (m.clf[ge:gx] - e) * d * u
        wm[ge:gx] += ((m.lowf[ge:gx] if d > 0 else m.highf[ge:gx]) - e) * d * u
        lst.append((ge, gx, mi, (d * (x - e) - cost[mi] * (e + x)) * u / ru))
    return np.cumsum(dbal), mtm, wm, lst


def main():
    syms, mk, tls, maps, cost, grid, cetday = banao()
    s0, s1 = pd.Timestamp('2012-01-01', tz='UTC').value, pd.Timestamp('2019-01-01', tz='UTC').value
    i0, i1 = np.searchsorted(grid, s0), np.searchsorted(grid, s1)
    R = [raasta(mk, tls[k], maps[k], cost, grid, s0, s1, RISK[k]) for k in range(4)]
    sl = slice(i0, i1)
    eq = np.array([(b + m)[sl] for b, m, _, _ in R])          # equity P/L $ har EA
    bal = np.array([b[sl] for b, _, _, _ in R])
    wst = np.array([(b + w)[sl] for b, _, w, _ in R])
    g, cd = grid[sl], cetday[sl]
    ts = pd.to_datetime(g, utc=True)
    print('=== K9 TAJZIYA: jor #101, CHUNAO 2012-2018, mustaqil $100k (%, compounding nahi) ===')
    print('\n1) Har EA: trades, R, saal ba saal % (equity)')
    yr = ts.year.values
    hdr = 'EA          risk  trades  avgR   jeet% | ' + ' '.join(f'{y:>6d}' for y in range(2012, 2019)) + ' |  kul%  hissa'
    print(hdr)
    tot = eq[:, -1].sum()
    for k in range(4):
        r = np.array([x[3] for x in R[k][3]])
        ye = [eq[k][yr == y][-1] - (eq[k][yr == y - 1][-1] if y > 2012 else 0) for y in range(2012, 2019)]
        print(f'{NAMES[k]:11s} {RISK[k]:4.2f} {len(r):6d} {r.mean():+6.3f} {100 * np.mean(r > 0):5.0f}% | '
              + ' '.join(f'{v / 1000:+6.1f}' for v in ye) + f' | {eq[k][-1] / 1000:+6.1f} {100 * eq[k][-1] / tot:5.0f}%')
    te = eq.sum(0)
    ye = [te[yr == y][-1] - (te[yr == y - 1][-1] if y > 2012 else 0) for y in range(2012, 2019)]
    print(f'{"JOR":11s} {sum(RISK):4.2f} {"":6s} {"":6s} {"":6s} | ' + ' '.join(f'{v / 1000:+6.1f}' for v in ye) + f' | {tot / 1000:+6.1f}')

    # mahana
    ym = (ts.year * 100 + ts.month).values
    last = np.r_[np.nonzero(np.diff(ym))[0], len(ym) - 1]
    mon = np.diff(np.c_[np.zeros(4), eq[:, last]], axis=1) / 1000            # % mahana
    mt = mon.sum(0)
    print('\n2) Mahana % (84 mahine): ausat, std, musbat mahine, Sharpe (saalana), bura mahina; faida / std = raftar ki qeemat')
    for k in range(4):
        m = mon[k]
        print(f'{NAMES[k]:11s} ausat {m.mean():+5.2f}  std {m.std(ddof=1):4.2f}  musbat {100 * np.mean(m > 0):3.0f}%  Sharpe {m.mean() / m.std(ddof=1) * 12 ** .5:4.2f}'
              f'  bura {m.min():+5.2f}  acha {m.max():+5.2f}  | risk 1% par ausat {m.mean() / RISK[k]:+5.2f}')
    print(f'{"JOR":11s} ausat {mt.mean():+5.2f}  std {mt.std(ddof=1):4.2f}  musbat {100 * np.mean(mt > 0):3.0f}%  Sharpe {mt.mean() / mt.std(ddof=1) * 12 ** .5:4.2f}  bura {mt.min():+5.2f}  acha {mt.max():+5.2f}')
    print('\n3) Aapas ka mel (correlation): mahana [upar] / rozana CET din [neeche]')
    dl = np.r_[np.nonzero(np.diff(cd))[0], len(cd) - 1]
    dd = np.diff(np.c_[np.zeros(4), eq[:, dl]], axis=1)
    cm, cdy = np.corrcoef(mon), np.corrcoef(dd)
    print('            ' + ' '.join(f'{n[:9]:>10s}' for n in NAMES))
    for a in range(4):
        print(f'{NAMES[a]:11s} ' + ' '.join(f'{(cm[a, b] if b > a else cdy[a, b]) if a != b else 1:10.2f}' for b in range(4)))
    print('\n4) Jor ke bure / ache mahine mein kaun: (jor ke 20 sab se bure mahine, 20 sab se ache) ausat % har EA')
    o = np.argsort(mt)
    for nm, ix in (('20 bure', o[:20]), ('20 ache', o[-20:]), ('jor < 0 (%d)' % (mt < 0).sum(), np.nonzero(mt < 0)[0])):
        print(f'{nm:14s} jor {mt[ix].mean():+5.2f} | ' + '  '.join(f'{NAMES[k]} {mon[k][ix].mean():+5.2f}' for k in range(4)))
    print('   EA khud musbat jab jor manfi (rokta nahi, bachata): ' + '  '.join(f'{NAMES[k]} {100 * np.mean(mon[k][mt < 0] > 0):.0f}%' for k in range(4)))

    # din ki hadd: run_cost jaisa - dstart = din ke shuru ka BALANCE, worst = balance + khuli (bura)
    print('\n5) Din ki hadd (FTMO 5% = -5000): har CET din ka sab se bura lamha = worst - din-shuru balance (jor)')
    ds = np.r_[0, dl[:-1] + 1]
    rows = []
    tb, tw = bal.sum(0), wst.sum(0)
    for a, b in zip(ds, dl):
        dst = tb[a - 1] if a > 0 else 0.0
        j = a + int(np.argmin(tw[a:b + 1]))
        rows.append((tw[j] - dst, cd[a], [wst[k][j] - (bal[k][a - 1] if a > 0 else 0.0) for k in range(4)]))
    v = np.array([r[0] for r in rows])
    con = np.array([r[2] for r in rows])
    for lim in (-1000, -2000, -3000, -4000):
        ix = v <= lim
        if ix.sum():
            print(f'  din <= {lim / 1000:+.0f}%: {ix.sum():4d} din | ausat hissa: ' + '  '.join(f'{NAMES[k]} {con[ix, k].mean() / 1000:+5.2f}%' for k in range(4)))
        else:
            print(f'  din <= {lim / 1000:+.0f}%: 0 din')
    print('  10 sab se bure din (jor %, phir har EA %):')
    for i in np.argsort(v)[:10]:
        print(f'    {rows[i][1]}  {v[i] / 1000:+5.2f} | ' + '  '.join(f'{NAMES[k][:2]} {con[i, k] / 1000:+5.2f}' for k in range(4)))
    # sab se gehra girao (equity, mustaqil)
    for k in range(5):
        e = eq[k] if k < 4 else te
        ddn = (e - np.maximum.accumulate(e)).min()
        print(f'  max girao {NAMES[k] if k < 4 else "JOR":11s} {ddn / 1000:+6.2f}%')

    if '--tez' in sys.argv:
        return
    print('\n6) Challenge (84, har mahine, run_cost): ek EA nikaal kar / aadha kar ke  ->  pass fail(P1/P2) adhoora | median mahine')
    starts = pd.date_range('2012-01-01', '2018-12-01', freq='MS', tz='UTC')

    def chal(rk, nm):
        sy = [(rk[k], tls[k], maps[k]) for k in range(4) if rk[k] > 0]
        res = [run_cost(mk, sy, s.value, s1, grid, cetday, cost) for s in starts]
        ps, f1, f2, ad, med = summary(res)
        print(f'  {nm:34s} {ps:3d} {f1 + f2:3d} ({f1}/{f2}) {ad:3d} | {med:5.1f}', flush=True)
    chal(RISK, 'jor #101 (abhi)')
    for k in range(4):
        r = list(RISK); r[k] = 0
        chal(r, f'bina {NAMES[k]}')
    for k in range(4):
        r = list(RISK); r[k] /= 2
        chal(r, f'{NAMES[k]} aadha ({r[k]:.3f}%)')


if __name__ == '__main__':
    main()
