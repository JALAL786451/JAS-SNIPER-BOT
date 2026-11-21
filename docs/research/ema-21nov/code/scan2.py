import pandas as pd, numpy as np, itertools, time
t0=time.time()
m=pd.read_csv('/home/claude/work/xau_m15.csv',parse_dates=['t']).set_index('t')
idx=m.index; O=m.o.values;H=m.h.values;L=m.l.values;C=m.c.values
hr=idx.hour.values; dts=idx.normalize().values
ud,start=np.unique(dts,return_index=True); end=np.r_[start[1:],len(m)]
nd=len(ud)
# first index of hour h in each day
FH=-np.ones((nd,25),dtype=int)
for d in range(nd):
    s,e=start[d],end[d]; hh=hr[s:e]
    for h in range(24):
        w=np.flatnonzero(hh>=h)
        FH[d,h]=s+w[0] if len(w) else -1
    FH[d,24]=e  # end of day
nb=end-start
# daily OHLC
dO=np.array([O[start[d]] for d in range(nd)]);dC=np.array([C[end[d]-1] for d in range(nd)])
dH=np.array([H[start[d]:end[d]].max() for d in range(nd)]);dL=np.array([L[start[d]:end[d]].min() for d in range(nd)])
pc=np.r_[dC[0],dC[:-1]]
tr=np.maximum(dH-dL,np.maximum(abs(dH-pc),abs(dL-pc)))
atrd=pd.Series(tr).ewm(alpha=1/14,adjust=False).mean().values   # known after day d
ema50=pd.Series(dC).ewm(span=50,adjust=False).mean().values
ema20=pd.Series(dC).ewm(span=20,adjust=False).mean().values
dow=pd.to_datetime(ud).dayofweek.values
valid=np.array([nb[d]>=60 for d in range(nd)])
IS=pd.to_datetime(ud)<pd.Timestamp('2018-01-01')
def sim(d,i0,iX,sgn,sl,tp,cost):
    """enter open[i0], exit open[iX] or sl/tp (price levels, None ok). returns frac return"""
    e=O[i0]
    if iX<=i0: return None
    hs=H[i0:iX]; ls=L[i0:iX]
    if sgn>0:
        slp=e-sl if sl else None; tpp=e+tp if tp else None
        a=np.flatnonzero(ls<=slp)[0] if slp is not None and (ls<=slp).any() else 10**9
        b=np.flatnonzero(hs>=tpp)[0] if tpp is not None and (hs>=tpp).any() else 10**9
    else:
        slp=e+sl if sl else None; tpp=e-tp if tp else None
        a=np.flatnonzero(hs>=slp)[0] if slp is not None and (hs>=slp).any() else 10**9
        b=np.flatnonzero(ls<=tpp)[0] if tpp is not None and (ls<=tpp).any() else 10**9
    if a<=b and a<10**9: x=slp
    elif b<10**9: x=tpp
    else: x=O[iX] if iX<len(O) else C[-1]
    return (sgn*(x-e)-cost)/e
def summ(rets,days):
    r=np.array(rets); 
    if len(r)<300: return None
    isr=np.array([x for x,dd in zip(rets,days) if IS[dd]]); oo=np.array([x for x,dd in zip(rets,days) if not IS[dd]])
    f=lambda a: (a.mean()/a.std()*np.sqrt(len(a))) if len(a)>30 and a.std()>0 else np.nan
    eq=np.cumprod(1+r); 
    yrs=(pd.Timestamp(ud[-1])-pd.Timestamp(ud[0])).days/365.25
    return dict(n=len(r),tpy=len(r)/yrs,ret=(eq[-1]-1)*100,dd=(eq/np.maximum.accumulate(eq)-1).min()*100,wr=(r>0).mean()*100,avg_bp=r.mean()*1e4,t=f(r),is_t=f(isr),oos_t=f(oo),is_avg=isr.mean()*1e4,oos_avg=oo.mean()*1e4,oos_ret=(np.prod(1+oo)-1)*100)
def run_cfg(gen,cost):
    rets=[];days=[]
    for d in range(30,nd):
        if not valid[d]: continue
        r=gen(d,cost)
        if r is None: continue
        rets.append(r); days.append(d)
    return rets,days
rows=[]
def add(name,gen,**kw):
    rets,days=run_cfg(gen,0.5); s=summ(rets,days)
    if s: rows.append(dict(strategy=name,**kw,**s))
# ---- Family 1: fixed-time entry, direction rules, optional SL/TP in ATR
def dirrule(rule,d):
    p=d-1
    if rule=='long': return 1
    if rule=='short': return -1
    if rule=='mom1': return 1 if dC[p]>dC[p-1] else -1
    if rule=='rev1': return -1 if dC[p]>dC[p-1] else 1
    if rule=='mom3': return 1 if dC[p]>dC[p-3] else -1
    if rule=='rev3': return -1 if dC[p]>dC[p-3] else 1
    if rule=='trend': return 1 if dC[p]>ema50[p] else -1
    if rule=='trendL': return 1 if dC[p]>ema50[p] else 0
    if rule=='dipbuy': return 1 if (dC[p]>ema50[p] and dC[p]<dC[p-1]) else 0
    if rule=='ripsell': return -1 if (dC[p]<ema50[p] and dC[p]>dC[p-1]) else 0
    if rule=='dip_rip': 
        if dC[p]>ema50[p] and dC[p]<dC[p-1]: return 1
        if dC[p]<ema50[p] and dC[p]>dC[p-1]: return -1
        return 0
    if rule=='gapfade': return 0
rules=['long','mom1','rev1','mom3','rev3','trend','trendL','dipbuy','dip_rip']
sltp=[(None,None),(0.5,None),(0.5,1.0),(0.5,2.0),(1.0,2.0)]  # (SL in ATRd, TP in R multiples of SL)
for rule in rules:
  for Te in (1,7,8,13,14):
    for (k,mR) in sltp:
      for Tx in (21,):
        def gen(d,cost,rule=rule,Te=Te,k=k,mR=mR,Tx=Tx):
            s=dirrule(rule,d)
            if s==0: return None
            i0=FH[d,Te]; iX=FH[d,Tx]
            if i0<0 or iX<0 or iX-i0<4: return None
            a=atrd[d-1]; sl=k*a if k else None; tp=mR*sl if (mR and sl) else None
            return sim(d,i0,iX,s,sl,tp,cost)
        add('fixed:'+rule,gen,Te=Te,sl_atr=k,tp_R=mR,Tx=Tx)
# ---- Family 2: Asia-range breakout (00:00-Te UTC range) then trade until Tx
for Te in (6,7,8):
  for mode in ('both','long'):
    for Tx in (17,21):
      for slmode in ('opp','half'):
        def gen(d,cost,Te=Te,mode=mode,Tx=Tx,slmode=slmode):
            s0=FH[d,0]; i0=FH[d,Te]; iX=FH[d,Tx]
            if s0<0 or i0<0 or iX<0 or i0-s0<8: return None
            hi=H[s0:i0].max(); lo=L[s0:i0].min(); rng=hi-lo
            if rng<=0: return None
            for j in range(i0,iX):
                if H[j]>=hi and True:
                    sgn=1; e=max(hi,O[j]); break
                if L[j]<=lo and mode=='both':
                    sgn=-1; e=min(lo,O[j]); break
            else: return None
            sl=rng if slmode=='opp' else rng/2
            # simulate from bar j to iX using entry e
            x=None
            for q in range(j,iX):
                if sgn>0 and L[q]<=e-sl and not (q==j and False): x=e-sl;break
                if sgn<0 and H[q]>=e+sl: x=e+sl;break
            if x is None: x=O[iX] if iX<len(O) else C[-1]
            return (sgn*(x-e)-cost)/e
        add('asia_breakout',gen,Te=Te,mode=mode,Tx=Tx,sl=slmode)
# ---- Family 3: prior-day high/low break or fade
for mode in ('break','fade'):
  for sides in ('both','long'):
    for Te in (7,13):
      for Tx in (21,):
        def gen(d,cost,mode=mode,sides=sides,Te=Te,Tx=Tx):
            pH=dH[d-1];pL=dL[d-1]; i0=FH[d,Te]; iX=FH[d,Tx]
            if i0<0 or iX<0 or iX-i0<4: return None
            a=atrd[d-1]
            for j in range(i0,iX):
                if H[j]>=pH:
                    sgn=1 if mode=='break' else -1; e=max(pH,O[j]); break
                if L[j]<=pL:
                    sgn=-1 if mode=='break' else 1; e=min(pL,O[j]); break
            else: return None
            if sides=='long' and sgn<0: return None
            sl=0.5*a; x=None
            for q in range(j,iX):
                if sgn>0 and L[q]<=e-sl: x=e-sl;break
                if sgn<0 and H[q]>=e+sl: x=e+sl;break
            if x is None: x=O[iX] if iX<len(O) else C[-1]
            return (sgn*(x-e)-cost)/e
        add('prevday_'+mode,gen,sides=sides,Te=Te,Tx=Tx)
# ---- Family 4: day-of-week long (Te=1 -> 21)
for wd in range(5):
  for Te in (1,13):
    def gen(d,cost,wd=wd,Te=Te):
        if dow[d]!=wd: return None
        i0=FH[d,Te]; iX=FH[d,21]
        if i0<0 or iX<0: return None
        return sim(d,i0,iX,1,None,None,cost)
    add('dow_long',gen,Te=Te,wd=wd)
R=pd.DataFrame(rows); R.to_csv('/home/claude/work/scan2.csv',index=False)
print('configs',len(R),'time %.0fs'%(time.time()-t0))
pd.set_option('display.width',260); pd.set_option('display.max_rows',100)
cols=['strategy','Te','Tx','sl_atr','tp_R','rule','mode','sides','n','tpy','ret','dd','wr','avg_bp','t','is_t','oos_t','oos_ret']
for c in cols:
    if c not in R: R[c]=np.nan
print('\nTOP by overall t (net of $0.5 cost):'); print(R.sort_values('t',ascending=False)[cols].head(15).round(2).to_string(index=False))
ok=R[(R.is_t>0)&(R.oos_t>0)]
print('\nconfigs positive in BOTH halves:',len(ok),'of',len(R)); print('configs with t>2:',(R.t>2).sum(),' t>3:',(R.t>3).sum(),'  (by pure luck at this count expect ~%.0f with t>2)'%(len(R)*0.023))
print('\nMedian t over all configs: %.2f ; mean avg return/trade %.1f bp'%(R.t.median(),R.avg_bp.mean()))
