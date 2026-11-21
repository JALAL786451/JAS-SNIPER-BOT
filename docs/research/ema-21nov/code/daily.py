import pandas as pd, numpy as np
m=pd.read_csv('/home/claude/work/xau_m15.csv',parse_dates=['t']).set_index('t')
h=m.resample('1h').agg({'o':'first','h':'max','l':'min','c':'last'}).dropna()
print(len(h),h.index[0],h.index[-1])
O=h.o.values;C=h.c.values;idx=h.index
hr=idx.hour.values; date=idx.normalize()
COST=0.5
pos_by_date={}
# index of bar for (date,hour)
key=pd.Series(np.arange(len(h)),index=pd.MultiIndex.from_arrays([date,hr]))
key=key[~key.index.duplicated()]
dates=np.unique(date)
ema_d=pd.Series(C).ewm(span=50*24,adjust=False).mean().values
ema_f=pd.Series(C).ewm(span=10*24,adjust=False).mean().values
def trades(Te,L,rule):
    out=[]
    for d in dates:
        k=(d,Te)
        if k not in key.index: continue
        i=key[k]
        j=i+L
        if j>=len(h) or i<24*60: continue
        # require exit bar to be within 30h of entry (no weekend gap)
        if (idx[j]-idx[i])>pd.Timedelta(hours=L+2): continue
        if rule=='long': s=1
        elif rule=='trend': s=1 if C[i-1]>ema_d[i-1] else -1
        elif rule=='trendL': s=1 if C[i-1]>ema_d[i-1] else 0
        elif rule=='mom': s=1 if C[i-1]>C[i-25] else -1
        elif rule=='rev': s=-1 if C[i-1]>C[i-25] else 1
        elif rule=='trend+rev': # buy dips in uptrend, sell rallies in downtrend
            up=C[i-1]>ema_d[i-1]; dn=C[i-1]<C[i-25]
            s=1 if (up and dn) else (-1 if (not up and not dn) else 0)
        if s==0: continue
        ret=s*(O[j]-O[i])/O[i]-COST/O[i]
        out.append((idx[i],ret))
    return pd.Series([r for _,r in out],index=[t for t,_ in out])
def summ(t):
    if len(t)==0: return None
    eq=(1+t).cumprod(); dd=(eq/eq.cummax()-1).min()*100
    yrs=(t.index[-1]-t.index[0]).days/365.25
    return dict(n=len(t),tpy=len(t)/yrs,ret=(eq.iloc[-1]-1)*100,dd=dd,wr=(t>0).mean()*100,avg=t.mean()*100,t=t.mean()/t.std()*np.sqrt(len(t)))
rows=[]
for rule in ('long','trend','trendL','mom','rev','trend+rev'):
    for Te in (0,4,8,12,16,20):
        for L in (4,8):
            t=trades(Te,L,rule); s=summ(t)
            if not s: continue
            a=summ(t[t.index<'2018-01-01']); b=summ(t[t.index>='2018-01-01'])
            rows.append(dict(rule=rule,Te=Te,L=L,**s,is_avg=a['avg'],oos_avg=b['avg'],is_ret=a['ret'],oos_ret=b['ret']))
R=pd.DataFrame(rows); R.to_csv('/home/claude/work/daily_scan.csv',index=False)
pd.set_option('display.width',250); pd.set_option('display.max_rows',300)
print(R.sort_values('t',ascending=False).head(20).round(2).to_string(index=False))
print('\nworst'); print(R.sort_values('t').head(5).round(2).to_string(index=False))
print('\nalways-long drift by hour (L=4):'); print(R[(R.rule=='long')&(R.L==4)].round(2).to_string(index=False))
