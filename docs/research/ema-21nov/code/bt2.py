import pandas as pd, numpy as np, sys
def load(f):
    h=pd.read_csv(f,parse_dates=['t']).set_index('t'); return h
def ema(x,n): return pd.Series(x).ewm(span=n,adjust=False).mean().values
class BT:
    def __init__(s,h,ppy,cost=0.5): s.h=h;s.O=h.o.values;s.H=h.h.values;s.L=h.l.values;s.C=h.c.values;s.idx=h.index;s.ppy=ppy;s.cost=cost
    def run(s,sig,cost=None):
        cost=s.cost if cost is None else cost
        p=np.r_[0,sig[:-1]]; pp=np.r_[0,p[:-1]]; prev=np.r_[s.C[0],s.C[:-1]]
        pnl=(s.O-prev)*pp+(s.C-s.O)*p-np.abs(p-pp)*cost/2
        return p,pnl
    def stats(s,p,pnl,mask=None):
        C=s.C; 
        if mask is not None: p,pnl,C=p[mask],pnl[mask],C[mask]
        r=pnl/np.r_[C[0],C[:-1]]; eq=np.cumprod(1+r); dd=(eq/np.maximum.accumulate(eq)-1).min()*100
        seg=np.r_[0,np.flatnonzero(np.diff(p)!=0)+1,len(p)]
        t=np.array([r[a:b].sum() for a,b in zip(seg[:-1],seg[1:]) if p[a]!=0]); n=len(t)
        gw=t[t>0].sum(); gl=-t[t<0].sum()
        return dict(ret=(eq[-1]-1)*100,dd=dd,n=n,wr=(t>0).mean()*100 if n else 0,pf=gw/gl if gl>0 else np.nan,
                    sh=r.mean()/r.std()*np.sqrt(s.ppy) if r.std()>0 else 0)
def cross(C,f,s_,mode):
    x=np.where(ema(C,f)>ema(C,s_),1,-1); return np.where(x>0,1,0) if mode=='long' else x
def atr(h,n=14):
    pc=h.c.shift(1); tr=pd.concat([h.h-h.l,(h.h-pc).abs(),(h.l-pc).abs()],axis=1).max(axis=1); return tr.ewm(alpha=1/n,adjust=False).mean().values
def run_stop(b,f,s_,k,cost=0.5,n=14):
    """long only EMA cross with ATR stop. entry at next open; stop = entry-k*ATR(at signal). exit on cross-down (next open) or stop hit (intrabar, at stop or open if gapped)"""
    O,H,L,C=b.O,b.H,b.L,b.C; A=atr(b.h,n); sg=cross(C,f,s_,'long')
    N=len(C); pnl=np.zeros(N); pos=0; stop=0; entry=0; blocked=False
    for i in range(1,N):
        want=sg[i-1]
        if pos==1:
            if O[i]<=stop: pnl[i]=stop_exit=O[i]-C[i-1]; pnl[i]-=cost/2; pos=0; blocked=(want==1); continue
            if want==0: pnl[i]=O[i]-C[i-1]-cost/2; pos=0; blocked=False; continue
            # hold through bar
            pnl[i]=O[i]-C[i-1]
            if L[i]<=stop: pnl[i]+=stop-O[i]-cost/2; pos=0; blocked=(want==1); continue
            pnl[i]+=C[i]-O[i]
        else:
            if want==0: blocked=False
            if want==1 and not blocked:
                pos=1; entry=O[i]; stop=entry-k*A[i-1]; pnl[i]=-cost/2
                if L[i]<=stop: pnl[i]+=stop-O[i]-cost/2; pos=0; blocked=True; continue
                pnl[i]+=C[i]-O[i]
    return pnl
