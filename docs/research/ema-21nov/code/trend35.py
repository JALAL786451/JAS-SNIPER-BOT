import re
src=open('/home/claude/work/multi.py').read().split("SPLIT=pd.Timestamp")[0]
exec(src)
exec(open('/home/claude/work/bt2.py').read().split("class BT")[0])
def cross(C,f,s_): return (ema(C,f)>ema(C,s_)).astype(int)
def atrf(h,n=14):
    pc=h.c.shift(1); tr=pd.concat([h.h-h.l,(h.h-pc).abs(),(h.l-pc).abs()],axis=1).max(axis=1); return tr.ewm(alpha=1/n,adjust=False).mean().values
SPLIT=pd.Timestamp('2018-01-01')
H4={}
for k,v in data.items():
    h=v.rename(columns={'open':'o','high':'h','low':'l','close':'c'}).resample('4h').agg({'o':'first','h':'max','l':'min','c':'last'}).dropna()
    if len(h)>3000: H4[k]=h
print(len(H4),'markets in 4H')
def simulate(h,f,s_,k,cost_frac):
    O,Hh,L,C=h.o.values,h.h.values,h.l.values,h.c.values; N=len(C); sg=cross(C,f,s_)
    A=atrf(h) if k else None
    r=np.zeros(N); pos=0; blocked=False; ntr=0
    for i in range(1,N):
        want=sg[i-1]
        if pos==1:
            if k and O[i]<=stop: r[i]=(O[i]-C[i-1])/C[i-1]-cost_frac/2; pos=0; blocked=(want==1); continue
            if want==0: r[i]=(O[i]-C[i-1])/C[i-1]-cost_frac/2; pos=0; blocked=False; continue
            r[i]=(O[i]-C[i-1])/C[i-1]
            if k and L[i]<=stop: r[i]+=(stop-O[i])/C[i-1]-cost_frac/2; pos=0; blocked=(want==1); continue
            r[i]+=(C[i]-O[i])/C[i-1]
        else:
            if want==0: blocked=False
            if want==1 and not blocked and i>=f*0+s_+5:
                pos=1; ntr+=1; stop=O[i]-k*A[i-1] if k else 0; r[i]=-cost_frac/2
                if k and L[i]<=stop: r[i]+=(stop-O[i])/C[i-1]-cost_frac/2; pos=0; blocked=True; continue
                r[i]+=(C[i]-O[i])/C[i-1]
    return pd.Series(r,index=h.index),ntr
def stats(r,ntr):
    d=r.groupby(r.index.normalize()).apply(lambda x:(1+x).prod()-1)
    eq=(1+d).cumprod(); yrs=(d.index[-1]-d.index[0]).days/365.25
    return dict(ret=(eq.iloc[-1]-1)*100,cagr=(eq.iloc[-1]**(1/yrs)-1)*100,dd=(eq/eq.cummax()-1).min()*100,sh=d.mean()/d.std()*np.sqrt(252) if d.std()>0 else 0,n=ntr,yrs=yrs),d
COST=0.0002  # 2 bp round trip (generous-to-realistic)
res=[];daily={}
for (f,s_,k) in [(50,200,0),(50,200,4),(25,100,0),(100,400,0),(10,30,0)]:
    rows=[];ds={}
    for nm,h in H4.items():
        r,n=simulate(h,f,s_,k,COST); st,d=stats(r,n)
        bh=(h.c.iloc[-1]/h.c.iloc[0]-1)*100
        dIS=d[d.index<SPLIT]; dOO=d[d.index>=SPLIT]
        t=lambda x: x.mean()/x.std()*np.sqrt(len(x)) if len(x)>100 and x.std()>0 else np.nan
        rows.append(dict(mkt=nm,**st,bh=bh,t_is=t(dIS),t_oos=t(dOO),ret_oos=((1+dOO).prod()-1)*100 if len(dOO) else np.nan)); ds[nm]=d
    D=pd.DataFrame(rows); D['cfg']=f'{f}/{s_} k{k}'
    P_=pd.DataFrame(ds).mean(axis=1).dropna()  # equal weight of available markets
    eq=(1+P_).cumprod(); yrs=(P_.index[-1]-P_.index[0]).days/365.25
    ptr=D.n.sum()/yrs
    res.append(dict(cfg=f'{f}/{s_} stop{k}',mkts=len(D),pos=(D.ret>0).sum(),beat_bh=(D.ret>D.bh).sum(),pos_oos=(D.ret_oos>0).sum(),med_ret=D.ret.median(),port_cagr=(eq.iloc[-1]**(1/yrs)-1)*100,port_dd=(eq/eq.cummax()-1).min()*100,port_sharpe=P_.mean()/P_.std()*np.sqrt(252),trades_per_year=ptr,
      port_oos_cagr=(((1+P_[P_.index>=SPLIT]).prod())**(365.25/(P_.index[-1]-SPLIT).days)-1)*100))
    daily[(f,s_,k)]=(D,P_)
pd.set_option('display.width',250); pd.set_option('display.max_rows',100)
print(pd.DataFrame(res).round(1).to_string(index=False))
D,P_=daily[(50,200,0)]
print('\n50/200 long-only per market (2bp cost):'); print(D[['mkt','yrs','ret','dd','n','bh','t_is','t_oos','ret_oos']].round(1).sort_values('t_oos',ascending=False).to_string(index=False))
D4,P4=daily[(50,200,4)]; D4.to_csv('/home/claude/work/trend35_50_200_k4.csv',index=False)
# equal weight buy&hold portfolio for reference
bh=pd.DataFrame({nm:h.c.pct_change().groupby(h.index.normalize()).apply(lambda x:(1+x.dropna()).prod()-1) for nm,h in H4.items()}).mean(axis=1)
eqb=(1+bh).cumprod(); yb=(bh.index[-1]-bh.index[0]).days/365.25
print('\nEqual-weight buy&hold all markets: CAGR %.1f%% maxDD %.1f%% Sharpe %.2f'%((eqb.iloc[-1]**(1/yb)-1)*100,(eqb/eqb.cummax()-1).min()*100,bh.mean()/bh.std()*np.sqrt(252)))
pd.DataFrame(res).to_csv('/home/claude/work/trend35_summary.csv',index=False)
