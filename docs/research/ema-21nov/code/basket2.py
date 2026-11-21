src=open('/home/claude/work/trend35.py').read().split("COST=0.0002")[0]
exec(src)
COST=0.0002
def sim_ent(h,f=50,s_=200,k=4):
    O,Hh,L,C=h.o.values,h.h.values,h.l.values,h.c.values; N=len(C); sg=cross(C,f,s_); A=atrf(h)
    r=np.zeros(N); pos=0; blocked=False; ents=[]; stop=0
    for i in range(1,N):
        want=sg[i-1]
        if pos==1:
            if O[i]<=stop: r[i]=(O[i]-C[i-1])/C[i-1]-COST/2; pos=0; blocked=(want==1); continue
            if want==0: r[i]=(O[i]-C[i-1])/C[i-1]-COST/2; pos=0; blocked=False; continue
            r[i]=(O[i]-C[i-1])/C[i-1]
            if L[i]<=stop: r[i]+=(stop-O[i])/C[i-1]-COST/2; pos=0; blocked=(want==1); continue
            r[i]+=(C[i]-O[i])/C[i-1]
        else:
            if want==0: blocked=False
            if want==1 and not blocked and i>=s_+5:
                pos=1; ents.append(h.index[i]); stop=O[i]-k*A[i-1]; r[i]=-COST/2
                if L[i]<=stop: r[i]+=(stop-O[i])/C[i-1]-COST/2; pos=0; blocked=True; continue
                r[i]+=(C[i]-O[i])/C[i-1]
    return pd.Series(r,index=h.index),pd.DatetimeIndex(ents)
START=pd.Timestamp('2009-03-15')
mk=['XAUUSD','USATECH','USA500','XAGUSD']
res={};ent={}
for m in mk: res[m],ent[m]=sim_ent(H4[m])
for m in mk: print(m,'history from',H4[m].index[0].date(),'to',H4[m].index[-1].date())
yrs=lambda a,b:(b-a).days/365.25
print('\nTRADES PER CALENDAR YEAR (entries):')
T=pd.DataFrame({m:pd.Series(1,index=ent[m][ent[m]>=START]).groupby(lambda d:d.year).sum() for m in mk}).fillna(0).astype(int)
print(T.to_string())
for m in mk:
    e=ent[m][ent[m]>=START]; y=yrs(max(START,H4[m].index[0]+pd.Timedelta(days=60)),H4[m].index[-1])
    print('%-8s %3d trades in %.1f yrs = %.1f per year'%(m,len(e),y,len(e)/y))
def daily(s): return s.groupby(s.index.normalize()).apply(lambda x:(1+x).prod()-1)
Dd=pd.DataFrame({m:daily(res[m]) for m in mk})
def port(names,a):
    P_=Dd[names][Dd.index>=a].mean(axis=1).dropna(); eq=(1+P_).cumprod(); y=yrs(P_.index[0],P_.index[-1])
    return dict(cagr=round((eq.iloc[-1]**(1/y)-1)*100,1),dd=round((eq/eq.cummax()-1).min()*100,1),sh=round(P_.mean()/P_.std()*np.sqrt(252),2),tot=round((eq.iloc[-1]-1)*100))
print('\nPORTFOLIOS (equal weight, 4H 50/200 buy-only, 4 ATR stop, 2bp cost)')
for a,lbl in ((START,'from 2009-03 (gold alone until indices start)'),(pd.Timestamp('2012-10-01'),'common period from 2012-10')):
    print(lbl)
    for names in (['XAUUSD'],['XAUUSD','USATECH'],['XAUUSD','USATECH','USA500'],['XAUUSD','USATECH','USA500','XAGUSD']):
        sub=[n for n in names if n in Dd]; ents=sum(len(ent[n][ent[n]>=max(a,H4[n].index[0])]) for n in sub)
        y=yrs(max(a,min(H4[n].index[0] for n in sub)),H4['XAUUSD'].index[-1])
        print('  %-38s trades/yr %.1f  %s'%('+'.join(sub),ents/y,port(sub,a)))
print('\ncorrelation of daily returns (2013+):'); print(Dd[Dd.index>='2013'].corr().round(2).to_string())
T.to_csv('/home/claude/work/trades_per_year.csv')
