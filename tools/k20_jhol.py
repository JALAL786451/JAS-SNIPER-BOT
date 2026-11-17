#!/usr/bin/env python3
"""K20 (17 Nov 2026, 66vi) - ASLI PASS ke jhol J1-J4 ka NAAP (EA mein koi tabdeeli nahi). Tafseel docs/khud-nazar.md.
Wahi trades / kharcha / swap 0 jo jor #101 / tools/jor105.py mein (t5 0.75, i6 1.0, k2 0.15, e2 0.25).

J1  cluster SE: mile hue market (US500+USTEC = US, XAU+XAG = MET, tel = OIL) ki trades ek hi din ki = EK cluster.
J2  buy-and-hold muqabla: har trade ka "market ki aam chaal" wala hissa (drift R) nikaal kar asli edge.
J4  US index group: t5 + i6 ek waqt ek taraf kitni trades / kitna risk; jor ke bure din 2019+ par bhi.
J3  ginti (IMTIHAN kitni dafa dekha) - is file mein nahi, docs/khud-nazar.md mein.

  python3 tools/k20_jhol.py
"""
import numpy as np
import pandas as pd

from jor105 import BAL0, NAMES, RISK, banao

GROUP = {'US500': 'US', 'USTEC': 'US', 'XAUUSD': 'MET', 'XAGUSD': 'MET',
         'LIGHTCMDUSD': 'OIL', 'BRENTCMDUSD': 'OIL'}
DAYNS = 86400 * 10 ** 9


def trade_list(mk, trades, smap, cost, grid, s0, s1, risk):
    """jor105.raasta jaisi chunai (slot bhara = trade chhoot), magar har trade ki poori tafseel."""
    ru = BAL0 * risk / 100
    tl = []
    for mi, m in enumerate(mk):
        for (ei, xi, e, x, sd, d) in trades[mi]:
            ge, gx = m.gi[ei], m.gi[xi]
            if s0 <= grid[ge] < s1:
                tl.append((ge, gx, smap.get(mi, mi), e, x, sd, mi, d))
    tl.sort()
    free, out = {}, []
    for (ge, gx, slot, e, x, sd, mi, d) in tl:
        if gx <= ge or free.get(slot, -1) > ge:
            continue
        free[slot] = gx
        r = (d * (x - e) - cost[mi] * (e + x)) / sd
        out.append(dict(ge=ge, gx=gx, mi=mi, d=d, e=e, sd=sd, R=r, u=ru / sd))
    return out


def se_naive(r):
    return r.std(ddof=1) / np.sqrt(len(r))


def se_cluster(r, keys):
    """Cluster-robust SE of mean: sum((sum_c (r-m))^2) / n^2."""
    m = r.mean()
    s = pd.Series(r - m).groupby(pd.Series(keys)).sum().values
    n, g = len(r), len(s)
    return np.sqrt((s ** 2).sum() * g / max(g - 1, 1)) / n, g


def drift_per_ns(m, grid, s0, s1):
    """Market ki aam chaal (log) us daur mein, per ns."""
    i0, i1 = np.searchsorted(grid, s0), min(np.searchsorted(grid, s1), len(grid)) - 1
    c = m.clf
    ok = np.nonzero(np.isfinite(c[i0:i1 + 1]) & (c[i0:i1 + 1] > 0))[0]
    a, b = i0 + ok[0], i0 + ok[-1]
    return np.log(c[b] / c[a]) / (grid[b] - grid[a])


def main():
    syms, mk, tls, maps, cost, grid, cetday = banao()
    t = lambda s: pd.Timestamp(s, tz='UTC').value
    daur = [('CHUNAO 2012-18', t('2012-01-01'), t('2019-01-01')),
            ('IMTIHAN 2019-26', t('2019-01-01'), int(grid[-1]) + 1)]
    grp = [GROUP.get(s, s) for s in syms]

    print('=== K20: ASLI PASS ke jhol ka NAAP (J1 cluster SE, J2 buy-and-hold, J4 US group) ===')
    print('Mizaj: t5 = sirf BUY (4H Supertrend upar palta), i6 = sirf BUY (IBS dip), k2 / e2 = dekho BUY/SELL ginti.\n')
    allt = {}
    for nm, s0, s1 in daur:
        print(f'--- {nm} ---')
        print('EA           trades BUY/SELL  ExpR  | Exp-2SE alag | Exp-2SE cluster (clusters) | driftR  Exp-drift  (-2SE cl)')
        for k in range(4):
            L = trade_list(mk, tls[k], maps[k], cost, grid, s0, s1, RISK[k])
            allt[(nm, k)] = L
            if len(L) < 5:
                print(f'{NAMES[k]:12s} {len(L):5d} - kam'); continue
            r = np.array([x['R'] for x in L])
            nb = sum(x['d'] > 0 for x in L)
            keys = [f"{grp[x['mi']]}|{cetday[x['ge']]}" for x in L]
            sn = se_naive(r)
            sc, g = se_cluster(r, keys)
            dr = {mi: drift_per_ns(mk[mi], grid, s0, s1) for mi in {x['mi'] for x in L}}
            drR = np.array([x['d'] * x['e'] * dr[x['mi']] * (grid[min(x['gx'], len(grid) - 1)] - grid[x['ge']]) / x['sd']
                            for x in L])
            ed = r - drR
            sce, _ = se_cluster(ed, keys)
            print(f'{NAMES[k]:12s} {len(r):5d} {nb:4d}/{len(r) - nb:<4d} {r.mean():+6.3f} | {r.mean() - 2 * sn:+7.3f}      |'
                  f' {r.mean() - 2 * sc:+7.3f} ({g:4d})            | {drR.mean():+6.3f} {ed.mean():+7.3f}  ({ed.mean() - 2 * sce:+6.3f})')
            for gname in ('US', 'MET'):
                ix = np.array([grp[x['mi']] == gname for x in L])
                if ix.sum() >= 20 and ix.sum() < len(L):
                    kk = [keys[i] for i in np.nonzero(ix)[0]]
                    scg, gg = se_cluster(r[ix], kk)
                    print(f'   {gname:4s} hissa {ix.sum():5d} tr  ExpR {r[ix].mean():+6.3f}  Exp-2SE cl {r[ix].mean() - 2 * scg:+7.3f}'
                          f'  driftR {drR[ix].mean():+6.3f}  Exp-drift {ed[ix].mean():+6.3f}')
        print()

    print('--- J4: US index group (US500 + USTEC) par t5 + i6 ek saath (sab BUY) ---')
    for nm, s0, s1 in daur:
        i0, i1 = np.searchsorted(grid, s0), np.searchsorted(grid, s1)
        n = i1 - i0
        cnt, rk = np.zeros(n, int), np.zeros(n)
        for k in (0, 1):
            for x in allt[(nm, k)]:
                if grp[x['mi']] != 'US':
                    continue
                a, b = x['ge'] - i0, min(x['gx'], i1) - i0
                cnt[a:b] += 1
                rk[a:b] += RISK[k]
        live = cnt > 0
        print(f'{nm}: US par koi trade {100 * live.mean():4.1f}% waqt | jab khuli: 1 tr {100 * np.mean(cnt[live] == 1):4.1f}%'
              f'  2 tr {100 * np.mean(cnt[live] == 2):4.1f}%  3 tr {100 * np.mean(cnt[live] == 3):4.1f}%  4 tr {100 * np.mean(cnt[live] == 4):4.1f}%'
              f' | max SL-risk ek saath {rk.max():.2f}%')

    print('\n--- J4: jor (4 EA) ke bure din, CET din, worst lamha vs din-shuru balance (FTMO din hadd 5%) ---')
    for nm, s0, s1 in daur:
        i0, i1 = np.searchsorted(grid, s0), np.searchsorted(grid, s1)
        n = i1 - i0
        bal, wst = np.zeros((4, n)), np.zeros((4, n))
        for k in range(4):
            db, wm = np.zeros(n + 1), np.zeros(n)
            for x in allt[(nm, k)]:
                m = mk[x['mi']]
                a, b = x['ge'] - i0, min(x['gx'], i1) - i0
                u, e, d = x['u'], x['e'], x['d']
                db[a] -= cost[x['mi']] * e * u
                if x['gx'] < i1:
                    db[b] += x['R'] * x['sd'] * u + cost[x['mi']] * e * u
                wm[a:b] += ((m.lowf[i0 + a:i0 + b] if d > 0 else m.highf[i0 + a:i0 + b]) - e) * d * u
            bal[k] = np.cumsum(db[:n])
            wst[k] = bal[k] + wm
        cd = cetday[i0:i1]
        dl = np.r_[np.nonzero(np.diff(cd))[0], n - 1]
        ds = np.r_[0, dl[:-1] + 1]
        tb, tw = bal.sum(0), wst.sum(0)
        rows = []
        for a, b in zip(ds, dl):
            dst = tb[a - 1] if a > 0 else 0.0
            j = a + int(np.nanargmin(tw[a:b + 1]))
            rows.append((tw[j] - dst, cd[a], [wst[k][j] - (bal[k][a - 1] if a > 0 else 0.0) for k in range(4)]))
        v = np.array([r[0] for r in rows])
        con = np.array([r[2] for r in rows])
        print(f'{nm}: ' + '  '.join(f'din<={lim // 1000:+d}%: {(v <= lim).sum()}' for lim in (-1000, -2000, -3000, -4000, -5000)))
        for i in np.argsort(v)[:5]:
            print(f'    {rows[i][1]}  jor {v[i] / 1000:+5.2f}% | ' + '  '.join(f'{NAMES[k][:2]} {con[i, k] / 1000:+5.2f}' for k in range(4)))


if __name__ == '__main__':
    main()
