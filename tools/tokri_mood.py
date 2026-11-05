# Tokri: live zakhm par gold 1D/4H mood (Naqsha Rukh: close>EMA50>EMA200 + Supertrend 10,3). Data: dukascopy H1 + 28 Oct baad live deals se.
import pandas as pd, numpy as np, zipfile, io
R='/home/user/JAS-SNIPER-BOT/'
z=zipfile.ZipFile(R+'data/ftmo/XAU_XAG_H1_dukascopy.zip')
h=pd.read_csv(io.BytesIO(z.read('XAUUSD/2026.10.28XAUUSD-H1-No Session.csv')),header=None,names=['d','t','o','h','l','c','v'],skiprows=1)
h.index=pd.to_datetime(h.d.astype(str)+' '+h.t,format='%Y%m%d %H:%M:%S'); h=h.astype({'o':float,'h':float,'l':float,'c':float})
h=h[['o','h','l','c']]
# extend with live deal prices after last bar
d=pd.read_csv(R+'data/live_253687618/deals.csv.gz'); d=d[d.symbol=='XAUUSDc'].copy()
d['ts']=pd.to_datetime(d.time,format='%Y.%m.%d %H:%M:%S')
ext=d[d.ts>h.index[-1]+pd.Timedelta(hours=1)].set_index('ts').price.resample('1h').ohlc().dropna()
ext.columns=['o','h','l','c']; h=pd.concat([h,ext])
def rs(df,rule): return df.resample(rule).agg({'o':'first','h':'max','l':'min','c':'last'}).dropna()
def st(df,p=10,m=3):
    hl2=(df.h+df.l)/2; tr=pd.concat([df.h-df.l,(df.h-df.c.shift()).abs(),(df.l-df.c.shift()).abs()],axis=1).max(axis=1)
    atr=tr.ewm(alpha=1/p,adjust=False).mean(); up=hl2-m*atr; dn=hl2+m*atr
    U=up.copy();D=dn.copy();dirn=np.ones(len(df))
    c=df.c.values
    for i in range(1,len(df)):
        U.iloc[i]=max(up.iloc[i],U.iloc[i-1]) if c[i-1]>U.iloc[i-1] else up.iloc[i]
        D.iloc[i]=min(dn.iloc[i],D.iloc[i-1]) if c[i-1]<D.iloc[i-1] else dn.iloc[i]
        dirn[i]= 1 if (dirn[i-1]==-1 and c[i]>D.iloc[i-1]) else (-1 if (dirn[i-1]==1 and c[i]<U.iloc[i-1]) else dirn[i-1])
    return pd.Series(dirn,df.index)
def rukh(df):
    e50=df.c.ewm(span=50,adjust=False).mean(); e200=df.c.ewm(span=200,adjust=False).mean(); s=st(df)
    r=np.where((df.c>e50)&(e50>e200)&(s>0),'UPAR',np.where((df.c<e50)&(e50<e200)&(s<0),'NEECHE','MILA'))
    ema=np.where((df.c>e50)&(df.c>e200)&(e50>e200),'UPAR',np.where((df.c<e50)&(df.c<e200)&(e50<e200),'NEECHE','MILA'))
    return pd.DataFrame({'c':df.c,'rukh':r,'ema1d':ema,'st':s,'e50':e50.round(0),'e200':e200.round(0)})
D1=rukh(rs(h,'1D')); H4=rukh(rs(h,'4h'))
print("1D:"); print(D1.loc['2026-08-12':'2026-08-28'].to_string()); print(D1.loc['2026-10-27':].to_string())
print("4H:"); print(H4.loc['2026-08-17':'2026-08-26',['c','rukh','st']].to_string()); print(H4.loc['2026-10-30':,['c','rukh','st']].to_string())
p=pd.read_csv(R+'data/live_253687618/positions.csv.gz'); p['ot']=pd.to_datetime(p.open_time,format='%Y.%m.%d %H:%M:%S')
b=p[(p.type=='sell')&(p.volume>=0.25)&(((p.ot>='2026-08-18')&(p.ot<'2026-08-26'))|((p.ot>='2026-11-01')))]
print(b.groupby(b.ot.dt.date).agg(n=('volume','size'),lot=('volume','sum'),pl=('profit','sum')))
