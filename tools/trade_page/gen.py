"""Trade Roznamcha page (1 Nov 2026): 5 EA ki 2012-aaj trades + 4H chart data -> tools/trade_page/roznamcha.html
(artifact https://claude.ai/artifact/8mv4nJR8T9rHUXGJvBHrMK). Chalao: cd tools && python3 trade_page/gen.py"""
import json, sys
from pathlib import Path
HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE.parent))
OUT_JSON = HERE / 'data.json'
import numpy as np, pandas as pd
from ftmo_test import FILES, load, ibs_trades, session_day
from ftmo_4h import st4h_trades
from ftmo68 import KH, KCOST, khirki_trades
from ftmo53_asli import ASLI
from tokri47 import load_any
from sell73 import st4h_sell_trades, ibs_sell_trades, buy_ko_tarjeeh
from ftmo73 import sma200_gate, net_r

NAME = {'XAUUSD': 'Gold', 'XAGUSD': 'Silver', 'US500': 'US500', 'USTEC': 'USTEC', 'DEUIDXEUR': 'GER40', 'GBRIDXGBP': 'UK100',
        'FRAIDXEUR': 'FRA40', 'EUSIDXEUR': 'EU50', 'JPNIDXJPY': 'JP225', 'AUSIDXAUD': 'AUS200', 'HKGIDXHKD': 'HK50'}
DEC = {'XAUUSD': 2, 'XAGUSD': 3}
base = list(FILES); syms = base + list(KH)
dfs = {s: load(s) for s in base}; dfs.update({s: load_any(s) for s in KH})
T0 = pd.Timestamp('2012-01-01', tz='UTC').value
legs = []  # (ea, sym, trades, risk)
for s in base:
    b1 = st4h_trades(dfs[s], 6.0); b2 = ibs_trades(dfs[s]) if s in ('US500', 'USTEC') else []
    legs.append(('B1', s, b1, 0.75))
    legs.append(('S1', s, buy_ko_tarjeeh(st4h_sell_trades(dfs[s], 6.0, sma200_gate(dfs[s])), b1 + b2), 0.75))
    if b2:
        legs.append(('B2', s, b2, 1.0))
        legs.append(('S2', s, buy_ko_tarjeeh(ibs_sell_trades(dfs[s]), b1 + b2), 1.0))
for s in KH:
    legs.append(('B3', s, khirki_trades(dfs[s], *KH[s]), 0.15))

def blocks(df):
    day = session_day(df['t'])
    blk = ((df['t'].dt.tz_convert('America/New_York') + pd.Timedelta(hours=7)).dt.hour // 4).values
    g = pd.DataFrame({'i': np.arange(len(df)), 'd': day.values, 'b': blk, 'O': df['Open'].values,
                      'H': df['High'].values, 'L': df['Low'].values, 'C': df['Close'].values})
    g = g.groupby(['d', 'b'], sort=True).agg(f=('i', 'first'), O=('O', 'first'), H=('H', 'max'), L=('L', 'min'), C=('C', 'last')).sort_values('f')
    return g
bars = {}; need = {}
for s in syms:
    g = blocks(dfs[s]); bars[s] = g; need[s] = np.zeros(len(g), bool)
trades = []
for ea, s, tl, risk in legs:
    df = dfs[s]; t = df['t'].values.astype('datetime64[ns]').astype(np.int64)
    f = bars[s]['f'].values
    cost = 0.75 * ASLI[s] if s in ASLI else KCOST
    for x in tl:
        if t[x[0]] < T0: continue
        r = net_r(df, x, cost)
        d = x[5]; sl = x[2] - d * x[4]
        hit = (d > 0 and x[3] <= sl + 1e-9) or (d < 0 and x[3] >= sl - 1e-9)
        bi = int(np.searchsorted(f, x[0], 'right') - 1); bx = int(np.searchsorted(f, x[1], 'right') - 1)
        need[s][max(0, bi - 30):min(len(f), bx + 12)] = True
        trades.append(dict(ea=ea, m=s, d=int(d), te=int(t[x[0]] // 60_000_000_000), tx=int(t[x[1]] // 60_000_000_000),
                           e=float(x[2]), x=float(x[3]), sl=float(sl), r=round(float(r), 3), rk=risk, sl_hit=bool(hit), bi=bi, bx=bx, op=bool(x[1] == len(df) - 1)))
trades.sort(key=lambda z: z['te'])
# encode bars per market: only needed segments; ints in price ticks; deltas
out = {}
for s in syms:
    g = bars[s]; nd = need[s]; dec = DEC.get(s, 1); k = 10 ** dec
    tt = dfs[s]['t'].values.astype('datetime64[ns]').astype(np.int64)[g['f'].values] // 3_600_000_000_000  # hours
    O, H, L, C = [np.round(g[c].values * k).astype(np.int64) for c in 'OHLC']
    segs = []; i = 0; n = len(g); idxmap = {}
    while i < n:
        if not nd[i]: i += 1; continue
        j = i
        while j < n and nd[j]: j += 1
        prev_c = int(C[i]); prev_t = int(tt[i]); parts = []
        for q in range(i, j):
            parts.append(f"{int(tt[q]) - prev_t},{int(O[q]) - prev_c},{int(H[q]) - prev_c},{int(L[q]) - prev_c},{int(C[q]) - prev_c}")
            prev_c = int(C[q]); prev_t = int(tt[q])
        segs.append(dict(i0=i, t0=int(tt[i]), c0=int(C[i]), b=";".join(parts)))
        i = j
    out[s] = dict(name=NAME[s], dec=dec, segs=segs)
data = dict(trades=trades, bars=out, names=NAME, gen='2026-11-01')
js = json.dumps(data, separators=(',', ':'))
open(OUT_JSON, 'w').write(js)
t = (HERE / 'template.html').read_text()
(HERE / 'roznamcha.html').write_text(t.replace('__DATA__', js))
from collections import Counter
print(len(trades), Counter(z['ea'] for z in trades), f'{len(js)/1e6:.2f} MB')
