import pandas as pd, numpy as np, zipfile, io, glob, os, time, warnings
warnings.filterwarnings('ignore')
R='/home/claude/jas-sniper-bot/data/'
def rd(zf,n):
    d=pd.read_csv(zf.open(n)); d.columns=[c.strip().lower() for c in d.columns]
    d['t']=pd.to_datetime(d['date'].astype(str)+' '+d['time']); return d.set_index('t')[['open','high','low','close']].astype(float)
data={}
for f in sorted(glob.glob(R+'duka/H1/JAS_ZIP/*.zip')):
    nm=os.path.basename(f).replace('_H1.zip','')
    with zipfile.ZipFile(f) as z: data[nm]=rd(z,[n for n in z.namelist() if n.endswith('.csv')][0])
for f in glob.glob(R+'ftmo/*.zip'):
    with zipfile.ZipFile(f) as z:
        for n in z.namelist():
            if n.endswith('.csv'):
                nm=('XAGUSD' if 'XAG' in n else 'XAUUSD' if 'XAU' in n else os.path.basename(f).split('_')[0])
                data[nm]=rd(z,n)
data={k:v[~v.index.duplicated()].sort_index() for k,v in data.items() if len(v)>20000}
print(len(data),'instruments:',' '.join(sorted(data)))
SPLIT=pd.Timestamp('2018-01-01')
def prep(df):
    idx=df.index; O=df.open.values;H=df.high.values;L=df.low.values;C=df.close.values
    hr=idx.hour.values; dts=idx.normalize().values
    ud,start=np.unique(dts,return_index=True); end=np.r_[start[1:],len(df)]
    nd=len(ud); FH=-np.ones((nd,25),dtype=int)
    for d in range(nd):
        s,e=start[d],end[d]; hh=hr[s:e]
        for h in range(24):
            w=np.flatnonzero(hh>=h); FH[d,h]=s+w[0] if len(w) else -1
        FH[d,24]=e if e<len(df) else -1
    dC=np.array([C[end[d]-1] for d in range(nd)]); dH=np.array([H[start[d]:end[d]].max() for d in range(nd)]); dL=np.array([L[start[d]:end[d]].min() for d in range(nd)])
    ema50=pd.Series(dC).ewm(span=50,adjust=False).mean().values
    return dict(O=O,H=H,L=L,C=C,FH=FH,dC=dC,dH=dH,dL=dL,ema50=ema50,ud=pd.to_datetime(ud),nd=nd,start=start,end=end)
RULES=['long','mom1','rev1','mom3','rev3','mom5','rev5','trend','dip_rip']
def direction(P,rule):
    dC=P['dC'];nd=P['nd']; p=np.arange(nd)-1; s=np.zeros(nd)
    ok=np.arange(nd)>=60
    def sh(k): return np.r_[np.full(k,np.nan),dC[:-k]]
    prevC=np.r_[np.nan,dC[:-1]]
    if rule=='long': s=np.ones(nd)
    elif rule in('mom1','rev1'): x=np.sign(prevC-sh(2)) if False else np.sign(np.r_[np.nan,dC[:-1]]-np.r_[np.nan,np.nan,dC[:-2]]); s=x if rule=='mom1' else -x
    elif rule in('mom3','rev3'): x=np.sign(prevC-np.r_[[np.nan]*4,dC[:-4]]); s=x if rule=='mom3' else -x
    elif rule in('mom5','rev5'): x=np.sign(prevC-np.r_[[np.nan]*6,dC[:-6]]); s=x if rule=='mom5' else -x
    elif rule=='trend': s=np.sign(prevC-np.r_[np.nan,P['ema50'][:-1]])
    elif rule=='dip_rip':
        up=prevC>np.r_[np.nan,P['ema50'][:-1]]; dn=prevC<np.r_[np.nan,np.nan,dC[:-2]]
        s=np.where(up&dn,1,np.where((~up)&(~dn),-1,0)).astype(float)
    s=np.nan_to_num(s); s[~ok]=0; return s
def fixed(P,rule,Te,L,cost_bp):
    FH=P['FH'];O=P['O']; Tx=min(Te+L,24)
    i0=FH[:,Te]; iX=FH[:,Tx]; s=direction(P,rule)
    m=(i0>=0)&(iX>i0+0)&(s!=0)&((iX-i0)<=L+3)
    e=O[np.where(m,i0,0)]; x=O[np.where(m,iX,0)]
    r=(s*(x-e)/e-cost_bp/1e4)[m]; return r,np.flatnonzero(m)
def rangebreak(P,Te,mode,Tx,cost_bp):
    FH=P['FH'];O=P['O'];H=P['H'];L=P['L'];rs=[];ds=[]
    for d in range(60,P['nd']):
        s0=FH[d,0];i0=FH[d,Te];iX=FH[d,Tx]
        if s0<0 or i0<0 or iX<0 or i0-s0<3 or iX-i0<2: continue
        hi=H[s0:i0].max();lo=L[s0:i0].min()
        if hi<=lo: continue
        sg=0
        for j in range(i0,iX):
            if H[j]>=hi: sg=1;e=max(hi,O[j]);break
            if L[j]<=lo and mode=='both': sg=-1;e=min(lo,O[j]);break
        if sg==0: continue
        x=O[iX]; rs.append((sg*(x-e)/e)-cost_bp/1e4); ds.append(d)
    return np.array(rs),np.array(ds)
def prevday(P,mode,Te,Tx,cost_bp):
    FH=P['FH'];O=P['O'];H=P['H'];L=P['L'];rs=[];ds=[]
    for d in range(60,P['nd']):
        i0=FH[d,Te];iX=FH[d,Tx]
        if i0<0 or iX<0 or iX-i0<3: continue
        pH=P['dH'][d-1];pL=P['dL'][d-1]; sg=0
        for j in range(i0,iX):
            if H[j]>=pH: sg=1 if mode=='break' else -1; e=max(pH,O[j]);break
            if L[j]<=pL: sg=-1 if mode=='break' else 1; e=min(pL,O[j]);break
        if sg==0: continue
        x=O[iX]; rs.append((sg*(x-e)/e)-cost_bp/1e4); ds.append(d)
    return np.array(rs),np.array(ds)
def tstat(a): return a.mean()/a.std()*np.sqrt(len(a)) if len(a)>30 and a.std()>0 else np.nan
t0=time.time()
P={k:prep(v) for k,v in data.items()}
print('prep %.0fs'%(time.time()-t0))
configs=[]
for rule in RULES:
    for Te in (1,7,8,13,14,20):
        for L in (4,8): configs.append(('fixed',rule,Te,L))
for Te in (6,8):
    for mode in ('both','long'): configs.append(('range',mode,Te,21))
for mode in ('break','fade'): configs.append(('prevday',mode,8,21)); configs.append(('prevday',mode,13,21))
def eval_cfg(cfg,cost):
    out={}
    for k,p in P.items():
        if cfg[0]=='fixed': r,di=fixed(p,cfg[1],cfg[2],cfg[3],cost)
        elif cfg[0]=='range': r,di=rangebreak(p,cfg[2],cfg[1],cfg[3],cost)
        else: r,di=prevday(p,cfg[1],cfg[2],cfg[3],cost)
        if len(r)<300: continue
        isd=p['ud'][di]<SPLIT
        out[k]=(r,isd)
    return out
rows=[]
for cfg in configs:
    net=eval_cfg(cfg,1.0); gross=eval_cfg(cfg,0.0)
    if len(net)<10: continue
    ts=np.array([tstat(r) for r,_ in net.values()]); tis=np.array([tstat(r[i]) for r,i in net.values()]); toos=np.array([tstat(r[~i]) for r,i in net.values()])
    avg=np.array([r.mean()*1e4 for r,_ in net.values()]); gav=np.array([r.mean()*1e4 for r,_ in gross.values()])
    z=np.nansum(ts)/np.sqrt(np.sum(~np.isnan(ts)))
    rows.append(dict(kind=cfg[0],a=cfg[1],Te=cfg[2],L=cfg[3],inst=len(net),net_bp=avg.mean(),gross_bp=gav.mean(),pos=(avg>0).sum(),Z=z,Z_is=np.nansum(tis)/np.sqrt(np.sum(~np.isnan(tis))),Z_oos=np.nansum(toos)/np.sqrt(np.sum(~np.isnan(toos))),maxt=np.nanmax(ts)))
D=pd.DataFrame(rows); D.to_csv('/home/claude/work/multi.csv',index=False)
pd.set_option('display.width',250)
print('time %.0fs, %d configs x ~%d instruments'%(time.time()-t0,len(D),int(D.inst.mean())))
print(D.sort_values('Z',ascending=False).head(12).round(2).to_string(index=False))
print('\nWorst:'); print(D.sort_values('Z').head(4).round(2).to_string(index=False))
print('\nconfigs: Z>3:',(D.Z>3).sum(),' Z>2:',(D.Z>2).sum(),' Z<-3:',(D.Z<-3).sum(),'of',len(D))
print('avg over ALL configs: net %.2f bp, gross %.2f bp per trade; instruments positive on avg %.0f%%'%(D.net_bp.mean(),D.gross_bp.mean(),(D.pos/D.inst).mean()*100))
tot=sum(0 for _ in [0])
