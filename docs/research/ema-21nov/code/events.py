import warnings; warnings.filterwarnings('ignore')
src=open('/home/claude/work/multi.py').read().split("SPLIT=pd.Timestamp")[0]
exec(src)
import datetime as D
FOMC="""2005-02-02 2005-03-22 2005-05-03 2005-06-30 2005-08-09 2005-09-20 2005-11-01 2005-12-13
2006-01-31 2006-03-28 2006-05-10 2006-06-29 2006-08-08 2006-09-20 2006-10-25 2006-12-12
2007-01-31 2007-03-21 2007-05-09 2007-06-28 2007-08-07 2007-09-18 2007-10-31 2007-12-11
2008-01-30 2008-03-18 2008-04-30 2008-06-25 2008-08-05 2008-09-16 2008-10-29 2008-12-16
2009-01-28 2009-03-18 2009-04-29 2009-06-24 2009-08-12 2009-09-23 2009-11-04 2009-12-16
2010-01-27 2010-03-16 2010-04-28 2010-06-23 2010-08-10 2010-09-21 2010-11-03 2010-12-14
2011-01-26 2011-03-15 2011-04-27 2011-06-22 2011-08-09 2011-09-21 2011-11-02 2011-12-13
2012-01-25 2012-03-13 2012-04-25 2012-06-20 2012-08-01 2012-09-13 2012-10-24 2012-12-12
2013-01-30 2013-03-20 2013-05-01 2013-06-19 2013-07-31 2013-09-18 2013-10-30 2013-12-18
2014-01-29 2014-03-19 2014-04-30 2014-06-18 2014-07-30 2014-09-17 2014-10-29 2014-12-17
2015-01-28 2015-03-18 2015-04-29 2015-06-17 2015-07-29 2015-09-17 2015-10-28 2015-12-16
2016-01-27 2016-03-16 2016-04-27 2016-06-15 2016-07-27 2016-09-21 2016-11-02 2016-12-14
2017-02-01 2017-03-15 2017-05-03 2017-06-14 2017-07-26 2017-09-20 2017-11-01 2017-12-13
2018-01-31 2018-03-21 2018-05-02 2018-06-13 2018-08-01 2018-09-26 2018-11-08 2018-12-19
2019-01-30 2019-03-20 2019-05-01 2019-06-19 2019-07-31 2019-09-18 2019-10-30 2019-12-11
2020-01-29 2020-04-29 2020-06-10 2020-07-29 2020-09-16 2020-11-05 2020-12-16
2021-01-27 2021-03-17 2021-04-28 2021-06-16 2021-07-28 2021-09-22 2021-11-03 2021-12-15
2022-01-26 2022-03-16 2022-05-04 2022-06-15 2022-07-27 2022-09-21 2022-11-02 2022-12-14
2023-02-01 2023-03-22 2023-05-03 2023-06-14 2023-07-26 2023-09-20 2023-11-01 2023-12-13
2024-01-31 2024-03-20 2024-05-01 2024-06-12 2024-07-31 2024-09-18 2024-11-07 2024-12-18
2025-01-29 2025-03-19 2025-05-07 2025-06-18 2025-07-30 2025-09-17 2025-10-29 2025-12-10
2026-01-28 2026-03-18 2026-04-29 2026-06-17 2026-07-29 2026-09-16 2026-10-28""".split()
fomc=[pd.Timestamp(x) for x in FOMC]
def nfp_dates():
    out=[]
    for y in range(2004,2027):
        for m in range(1,13):
            d=D.date(y,m,12); sat=d+D.timedelta(days=(5-d.weekday())%7)   # reference week ends Saturday
            fri=sat+D.timedelta(days=6)   # first Friday after
            fri=fri+D.timedelta(days=14)  # third Friday after
            if fri.month==1 and fri.day==1: fri+=D.timedelta(days=7)
            if fri.month==7 and fri.day in (3,): fri-=D.timedelta(days=1)
            out.append(pd.Timestamp(fri))
    return sorted(set(out))
nfp=[d for d in nfp_dates() if pd.Timestamp('2005-01-01')<=d<=pd.Timestamp('2026-10-31')]
print('NFP days',len(nfp),'FOMC days',len(fomc))
def to_utc(day,hh,mm):
    return pd.Timestamp(D.datetime(day.year,day.month,day.day,hh,mm),tz='America/New_York').tz_convert('UTC').tz_localize(None)
COST=2.0/1e4
def trades(df,events,rel_h,rel_m,kind,rule):
    """kind: nfp/fomc; rule: pre_long, pre_short, mom, fade"""
    out=[]; idx=df.index; op=df.open; cl=df.close
    for day in events:
        T=to_utc(day,rel_h,rel_m); hb=T.floor('1h')
        if hb not in idx or (hb-pd.Timedelta(hours=6)) not in idx: continue
        i=idx.get_loc(hb)
        if rule in('pre_long','pre_short'):
            s=1 if rule=='pre_long' else -1
            e=op.iloc[i-6]; x=op.iloc[i]
            if idx[i]-idx[i-6]!=pd.Timedelta(hours=6): continue
        else:
            if i+3>=len(idx): continue
            react=cl.iloc[i]/op.iloc[i]-1
            if react==0: continue
            s=np.sign(react)*(1 if rule=='mom' else -1)
            # trade from the next bar open until +4h (same session)
            e=op.iloc[i+1]; j=i+5 if idx[min(i+5,len(idx)-1)]-idx[i+1]==pd.Timedelta(hours=4) else None
            if j is None: continue
            x=op.iloc[j]
        out.append((day,s*(x-e)/e-COST))
    return pd.Series({d:r for d,r in out})
def tt(a): return a.mean()/a.std()*np.sqrt(len(a)) if len(a)>20 and a.std()>0 else np.nan
rows=[]
for mk,df in data.items():
    for ev,days,(h,m) in (('NFP',nfp,(8,30)),('FOMC',fomc,(14,0))):
        for rule in ('pre_long','pre_short','mom','fade'):
            r=trades(df,days,h,m,ev,rule)
            if len(r)<40: continue
            ins=r[r.index<'2018-01-01']; oos=r[r.index>='2018-01-01']
            rows.append(dict(mkt=mk,ev=ev,rule=rule,n=len(r),net_bp=r.mean()*1e4,t=tt(r),t_is=tt(ins),t_oos=tt(oos),oos_bp=oos.mean()*1e4,win=(r>0).mean()*100))
R=pd.DataFrame(rows); R.to_csv('/home/claude/work/events.csv',index=False)
pd.set_option('display.width',220)
print('tests',len(R))
print(R.sort_values('t',ascending=False).head(14).round(2).to_string(index=False))
print('\nt>2:',(R.t>2).sum(),' t>3:',(R.t>3).sum(),' (chance expectation at t>2 ~',round(len(R)*0.023,1),')')
print('\nGOLD only:'); print(R[R.mkt=='XAUUSD'].round(2).to_string(index=False))
# pooled by (event,rule): average t across markets
P=R.groupby(['ev','rule']).agg(mkts=('mkt','count'),avg_bp=('net_bp','mean'),Z=('t',lambda x:x.sum()/np.sqrt(len(x))),Zoos=('t_oos',lambda x:x.sum()/np.sqrt(x.notna().sum()))).round(2)
print('\nPOOLED across markets:'); print(P)
