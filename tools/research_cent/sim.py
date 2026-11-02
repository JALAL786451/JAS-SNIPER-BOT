import sys, zipfile, io, numpy as np, pandas as pd
def load(paths):
    dfs=[]
    for p in paths:
        z=zipfile.ZipFile(p); n=z.namelist()[0]
        d=pd.read_csv(z.open(n))
        d['dt']=pd.to_datetime(d.Date.astype(str)+' '+d.Time)
        dfs.append(d[['dt','Open','High','Low','Close']])
    d=pd.concat(dfs).sort_values('dt').reset_index(drop=True); return d
def trades(d, D, cost, mode, tf=5, h0=0, h1=24):
    # entries at TF bar opens when flat; exit TP/SL = D fraction of price, conservative SL-first
    O=d.Open.values; H=d.High.values; L=d.Low.values; C=d.Close.values
    t=d.dt; hr=t.dt.hour.values; mi=t.dt.minute.values; day=t.dt.date.values
    # direction signals on tf bars
    c=pd.Series(C)
    ema=c.ewm(span=20*tf).mean().values
    ma=c.rolling(20*tf).mean().values; sd=c.rolling(20*tf).std().values
    out=[]; i=200*tf; N=len(C)
    while i<N-1:
        if mi[i]%tf!=0 or not(h0<=hr[i]<h1): i+=1; continue
        j=i-1
        if mode=='mom': s=1 if C[j]>ema[j] else -1
        elif mode=='rev':
            if C[j]>ma[j]+2*sd[j]: s=-1
            elif C[j]<ma[j]-2*sd[j]: s=1
            else: i+=1; continue
        else: s=1 if (i//tf)%2==0 else -1
        e=O[i]; tp=e*(1+s*D); sl=e*(1-s*D); k=i; res=None
        while k<N:
            if day[k]!=day[i] and k-i>600: res=s*(C[k]-e)/(e*D); break
            if s==1:
                if L[k]<=sl: res=-1;break
                if H[k]>=tp: res=1;break
            else:
                if H[k]>=sl: res=-1;break
                if L[k]<=tp: res=1;break
            k+=1
        if res is None: break
        out.append((day[i], res - cost/D)); i=k+1
    return pd.DataFrame(out,columns=['day','R'])
def mart(tr, base, mult, nmax, daystop, acct=1000.0, kill=0.5):
    # base = $ risked at step1; sequential; reset after win or after nmax losses
    eq=acct; step=0; daily={}; minEq=eq; dead=False
    for dday,R in zip(tr.day,tr.R):
        if dead: break
        dp=daily.get(dday,0.0)
        if dp<=-daystop: continue
        risk=base*mult**step
        pnl=risk*R; eq+=pnl; daily[dday]=dp+pnl
        if R>0: step=0
        else:
            step+=1
            if step>=nmax: step=0
        if eq<acct*kill: dead=True
    s=pd.Series(daily)
    return eq, s
if __name__=='__main__':
    pass
