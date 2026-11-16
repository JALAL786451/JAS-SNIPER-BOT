#!/usr/bin/env python3
"""62vi (17 Nov 2026) - TEST #3: JasLarai ki DEEWAR aap ki ASLI LIVE gold trades par (253687618, 18 Aug - 5 Nov 2026).

Sawal: agar deewar (InpWall, KHUD) shuru se chalti to gold ka nuqsan kitna hota?
Qaida (JasLarai j2 ki hubahu nakal, test se PEHLE likha, ek hi setting - tuning NAHI):
  NET = BUY lot - SELL lot (aap ki lots + deewar lots). |NET| >= 0.03 ho to NET wali taraf ki SAB SE NAYI lots
  (NET jitni) ki ausat = wRef. Qeemat wRef se 15$ khilaf -> ulti lot min(|NET|, 1.00) market par. Agli deewar 60 s baad.
  Deewar lot kabhi band nahi (EA band nahi karta; jori se equity nahi badalti).
Farz: aap ne har trade WAHI li / band ki jo asal mein ki (deewar dekh kar aap shayad kuch aur karte - ye test nahi bata sakta).
Qeemat: aap ke 12k deal ki qeemat + Dukascopy gold H1 (27 Oct tak; har ghante O, H/L, C). Ikai USC: 1 lot x 1$ = 100 USC.

  python3 tools/larai_deewar_test.py
"""
import sys
from pathlib import Path

import numpy as np
import pandas as pd

sys.path.insert(0, str(Path(__file__).resolve().parent))
from ftmo_test import load  # noqa: E402

ROOT = Path(__file__).resolve().parent.parent
DIST, MINNET, MAXLOT, WAIT = 15.0, 0.03, 1.00, 60
K = 100.0   # USC per 1 lot per $1


def main():
    d = pd.read_csv(ROOT / 'data/live_253687618/deals.csv.gz')
    d = d[d['symbol'] == 'XAUUSDc'].copy()
    d['t'] = pd.to_datetime(d['time'], format='%Y.%m.%d %H:%M:%S')
    p = pd.read_csv(ROOT / 'data/live_253687618/positions.csv.gz')
    p = p[p['symbol'] == 'XAUUSDc']
    closed = dict(zip(p['position'], zip(pd.to_datetime(p['close_time'], format='%Y.%m.%d %H:%M:%S'), p['close_price'])))
    ins = d[d['direction'] == 'in']
    # events: (t, kind, ...)  kind 0 = price tick, 1 = open, 2 = close
    ev = []
    pos = {}
    for r in ins.itertuples():
        sgn = 1 if r.type == 'buy' else -1
        pos[r.order] = [sgn, r.volume, r.price, r.t]
        ev.append((r.t, 1, r.order, r.price))
        if r.order in closed:
            ct, cp = closed[r.order]
            ev.append((ct, 2, r.order, cp))
    # deal qeematein = ticks
    for r in d.itertuples():
        ev.append((r.t, 0, None, r.price))
    # H1 ticks (Exness server waqt ~ UTC+0; Dukascopy UTC). Farq dekh kar offset
    h1 = load('XAUUSD')
    h1 = h1[(h1['t'] >= '2026-08-17') & (h1['t'] <= '2026-11-06')].copy()
    h1['tl'] = h1['t'].dt.tz_localize(None)
    # offset: deal qeemat - usi ghante ka beech
    m = pd.merge_asof(d.sort_values('t')[['t', 'price']], h1[['tl', 'Open', 'High', 'Low', 'Close']].rename(columns={'tl': 't'}), on='t')
    inside = ((m['price'] >= m['Low'] - 2) & (m['price'] <= m['High'] + 2)).mean()
    off = float(np.nanmedian(m['price'] - (m['High'] + m['Low']) / 2))
    print(f'Dukascopy H1 vs deal qeemat: {100 * inside:.1f}% deal ghante ki range (+-2$) mein, beech se farq ~{off:+.2f}$')
    for r in h1.itertuples():
        t0 = r.tl
        a, b = (r.Low, r.High) if r.Close >= r.Open else (r.High, r.Low)
        for dt, px in ((0, r.Open), (20, a), (40, b), (59, r.Close)):
            ev.append((t0 + pd.Timedelta(minutes=dt), 0, None, px))
    ev.sort(key=lambda e: (e[0], e[1]))

    book = {}                 # khuli: id -> [sgn, vol, price, t]
    walls = []                # [sgn, vol, price, t]
    real_me = 0.0
    last_wall = None
    px = None
    tick_max = 0
    curve = []
    for t, kind, oid, price in ev:
        px = price
        if kind == 1:
            book[oid] = pos[oid]
        elif kind == 2 and oid in book:
            s, v, op, _ = book.pop(oid)
            real_me += s * (price - op) * v * K
        # deewar jaanch
        allp = list(book.values()) + walls
        net = round(sum(s * v for s, v, _, _ in allp), 2)
        if abs(net) >= MINNET - 1e-9 and (last_wall is None or (t - last_wall).total_seconds() >= WAIT):
            side = 1 if net > 0 else -1
            need, sv, so = abs(net), 0.0, 0.0
            for s, v, op, ot in sorted([q for q in allp if q[0] == side], key=lambda q: q[3], reverse=True):
                x = min(v, need)
                sv += x
                so += x * op
                need -= x
                if need <= 1e-9:
                    break
            if sv > 0:
                ref = so / sv
                gone = (ref - px) if side > 0 else (px - ref)
                if gone >= DIST - 1e-9:
                    wl = np.floor(min(abs(net), MAXLOT) / 0.01 + 1e-9) * 0.01
                    if wl >= 0.01:
                        walls.append([-side, round(wl, 2), px, t])
                        last_wall = t
        fl_me = sum(s * (px - op) * v * K for s, v, op, _ in book.values())
        fl_w = sum(s * (px - op) * v * K for s, v, op, _ in walls)
        tick_max = max(tick_max, len(book) + len(walls))
        curve.append((t, px, real_me + fl_me, fl_w, len(book), len(walls)))
    c = pd.DataFrame(curve, columns=['t', 'px', 'me', 'w', 'nb', 'nw'])
    c['wd'] = c['me'] + c['w']
    print(f'\nDeewar lagi: {len(walls)} dafa, kul {sum(w[1] for w in walls):.2f} lot | aakhir tickets: aap {c.nb.iloc[-1]} + deewar {c.nw.iloc[-1]} (sab se zyada ek waqt {tick_max})')
    print('\n  Tareekh       gold      ASAL (gold P/L USC)   DEEWAR ke saath    farq')
    for day in ['2026-08-31', '2026-09-15', '2026-09-30', '2026-10-15', '2026-10-27', '2026-11-05']:
        r = c[c['t'] <= pd.Timestamp(day) + pd.Timedelta(hours=23, minutes=59)].iloc[-1]
        print(f'  {day}  {r.px:8.2f}   {r.me:+12,.0f}        {r.wd:+12,.0f}   {r.wd - r.me:+10,.0f}')
    for nm, col in (('ASAL', 'me'), ('DEEWAR', 'wd')):
        v = c[col].values
        i = int(np.argmin(v))
        dd = float(np.max(np.maximum.accumulate(v) - v))
        print(f'  {nm:7s} sab se neeche {v[i]:+,.0f} ({c.t.iloc[i]:%d %b %H:%M}) | chotti se sab se bari girawat {dd:,.0f}')
    print('\nDeewar ki list (pehli 15):')
    for s, v, op, t in walls[:15]:
        print(f'  {t:%d %b %H:%M}  {"SELL" if s < 0 else "BUY "} {v:.2f} @ {op:.2f}')


if __name__ == '__main__':
    main()
