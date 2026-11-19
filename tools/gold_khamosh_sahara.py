#!/usr/bin/env python3
"""19 Nov 2026 (70vi): gold g3.1 ka 1D chup ho (khamosh daur) to 4 EA (t5, i6, k2, e2) ne kya kiya?
#101 ke engine (ftmo101.py) ki trades, kharcha asli (andaza), swap 0, e2 metal = ek trade. Sirf jama % (compounding,
FTMO pehra, USD hadd 3 NAHI). Naya test NAHI - sirf purane engine ka hisaab.

  python3 tools/gold_khamosh_sahara.py
"""
import sys
from pathlib import Path
sys.path.insert(0, str(Path(__file__).resolve().parent))
import numpy as np, pandas as pd
from ftmo53_asli import ASLI
from ftmo68 import KCOST, KH, khirki_trades
from ftmo_4h import st4h_trades
from ftmo_test import FILES, ibs_trades, kachhua_trades, load
from tokri47 import load_any
from ftmo99 import SPREAD as TIDE
base=list(FILES); syms=base+list(KH)+[s for s in TIDE if s not in base]
dfs={s:load(s) for s in base}; dfs.update({s:load_any(s) for s in syms if s not in base})
rows=[]
def add(ea,risk,s,tl,cost):
    t=pd.to_datetime(dfs[s]['t'].values,utc=True)
    for x in tl:
        R=x[5]*(x[3]-x[2])/x[4]; c=cost*(x[2]+x[3])/x[4]
        rows.append((ea,s,t[x[0]],t[x[1]],R-c,(R-c)*risk))
for s in syms:
    if s in base: add('t5 (4H trend)',0.75,s,st4h_trades(dfs[s],6.0),0.75*ASLI[s])
    if s in ('US500','USTEC'): add('i6 (IBS US)',1.0,s,ibs_trades(dfs[s]),0.75*ASLI[s])
    if s in KH: add('k2 (khirki 7 index)',0.15,s,khirki_trades(dfs[s],*KH[s]),KCOST)
    if s in TIDE: add('e2 (Kachhua 12)',0.25,s,kachhua_trades(dfs[s]),0.75*TIDE[s])
T=pd.DataFrame(rows,columns=['ea','s','t','tx','R','pct'])
print('data aakhri:',T.tx.max())
e=T[(T.ea=='e2 (Kachhua 12)')&T.s.isin(['XAUUSD','XAGUSD'])].sort_values('t')
keep=[];busy=None
for i,r in e.iterrows():
    if busy is None or r.t>=busy: keep.append(i); busy=r.tx
drop=set(e.index)-set(keep); print('e2 metal: kul',len(e),'hataye (dono ek saath)',len(drop))
T=T.drop(index=list(drop))
W=[('2013-01-04','2016-03-03','2013-16 (38 mahine)'),('2018-04-05','2019-01-25','2018-19 (9.7)'),('2022-05-31','2023-01-06','2022 (7.2)'),('2026-03-03','2026-10-28','2026 Mar-Oct (7.8)')]
eas=['t5 (4H trend)','i6 (IBS US)','k2 (khirki 7 index)','e2 (Kachhua 12)']
print('daur | '+' | '.join(eas)+' | SAB')
for a,b,n in W:
    w=T[(T.tx>=pd.Timestamp(a,tz='UTC'))&(T.tx<pd.Timestamp(b,tz='UTC'))]
    print(n,'|',' | '.join(f"{w[w.ea==x].pct.sum():+.2f}% ({(w.ea==x).sum()})" for x in eas),f'| {w.pct.sum():+.2f}%')
w=T[(T.tx>=pd.Timestamp('2026-03-03',tz='UTC'))&(T.ea=='e2 (Kachhua 12)')]
print('\n2026 e2 market wise:'); print(w.groupby('s').agg(n=('pct','size'),pct=('pct','sum')).round(2).sort_values('pct').to_string())

