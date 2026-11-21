import pandas as pd, numpy as np, itertools, json
h=pd.read_csv('/home/claude/work/xau_h4.csv',parse_dates=['t']).set_index('t')
O=h.o.values; C=h.c.values; idx=h.index
COST=0.50   # $ per oz per round trip (spread+slippage) ~ Exness gold
def ema(x,n): return pd.Series(x).ewm(span=n,adjust=False).mean().values
def run(pos, cost=COST):
    """pos[i] = desired position (-1,0,1) decided at close of bar i, filled at open of bar i+1."""
    p=np.r_[0,pos[:-1]]            # position held during bar i
    ret=np.zeros(len(C))
    # bar return: from open to close for held position; entry at open (fill), so use O->C ; carry across bars handled by C[i-1]->O[i] gap
    prev=np.r_[C[0],C[:-1]]
    # held through gap if same position as previous bar
    pp=np.r_[0,p[:-1]]
    gap=(O-prev)*pp
    # price pnl in $: 
    pnl=gap+(C-O)*p
    # cost when position changes: each change of 1 unit costs cost/2 ; flip = 2 units
    chg=np.abs(p-pp); pnl=pnl-chg*cost/2
    return p,pnl
def stats(p,pnl,mask=None):
    if mask is not None: p,pnl,c=p[mask],pnl[mask],C[mask]
    else: c=C
    # fixed 1 oz: $ stats; also % based on price at entry (use pnl/price compounding)
    r=pnl/np.r_[c[0],c[:-1]]
    eq=np.cumprod(1+r); tot=(eq[-1]-1)*100
    dd=((eq/np.maximum.accumulate(eq))-1).min()*100
    # trades
    ch=np.flatnonzero(np.diff(np.r_[0,p,0])!=0)
    trades=[];
    # trade pnl by segments of constant nonzero position
    seg=np.r_[0,np.flatnonzero(np.diff(p)!=0)+1,len(p)]
    for a,b in zip(seg[:-1],seg[1:]):
        if p[a]!=0: trades.append(r[a:b].sum())
    t=np.array(trades); n=len(t)
    wr=(t>0).mean()*100 if n else 0
    gw=t[t>0].sum(); gl=-t[t<0].sum(); pf=gw/gl if gl>0 else np.nan
    yrs=len(c)/ (6*5*52)
    sh=r.mean()/r.std()*np.sqrt(6*5*52) if r.std()>0 else 0
    return dict(ret=tot,dd=dd,trades=n,wr=wr,pf=pf,sh=sh,yrs=yrs,ret_dd=tot/abs(dd) if dd else np.nan)
def sig_price(n,mode):
    e=ema(C,n); s=np.where(C>e,1,-1)
    if mode=='long': s=np.where(s>0,1,0)
    return s
def sig_cross(f,s_,mode):
    a,b=ema(C,f),ema(C,s_); s=np.where(a>b,1,-1)
    if mode=='long': s=np.where(s>0,1,0)
    return s
rows=[]
split=idx<'2022-01-01'; oos=~split
for mode in ('both','long'):
    for n in [10,20,30,50,75,100,150,200,300]:
        s=sig_price(n,mode); p,pnl=run(s)
        rows.append(dict(kind='Price/EMA',par=f'EMA{n}',mode=mode,**{'all_'+k:v for k,v in stats(p,pnl).items()},**{'is_'+k:v for k,v in stats(p,pnl,split).items()},**{'oos_'+k:v for k,v in stats(p,pnl,oos).items()}))
    for f,s_ in [(5,20),(9,21),(10,30),(20,50),(21,55),(20,100),(50,100),(50,200),(30,90),(13,48)]:
        s=sig_cross(f,s_,mode); p,pnl=run(s)
        rows.append(dict(kind='EMA cross',par=f'{f}/{s_}',mode=mode,**{'all_'+k:v for k,v in stats(p,pnl).items()},**{'is_'+k:v for k,v in stats(p,pnl,split).items()},**{'oos_'+k:v for k,v in stats(p,pnl,oos).items()}))
R=pd.DataFrame(rows)
R.to_csv('/home/claude/work/results.csv',index=False)
bh=C[-1]/C[0]-1
dd=(C/np.maximum.accumulate(C)-1).min()
print('Buy&Hold return %.0f%%  maxDD %.0f%%  bars=%d  %s -> %s'%(bh*100,dd*100,len(C),idx[0],idx[-1]))
pd.set_option('display.width',250); pd.set_option('display.max_rows',200)
cols=['kind','par','mode','all_ret','all_dd','all_trades','all_wr','all_pf','all_sh','is_ret','oos_ret','oos_dd','oos_pf']
print(R[cols].round(1).to_string(index=False))
