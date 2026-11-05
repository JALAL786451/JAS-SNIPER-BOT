# Tokri Q8 (wapasi hadd) + Q9 (4H mur jaye to dhaal SELL) - gold 4H 2005-2026 dukascopy, 1D/4H Naqsha Rukh.
import pandas as pd, numpy as np, zipfile, io
R='/home/user/JAS-SNIPER-BOT/'
z=zipfile.ZipFile(R+'data/ftmo/XAU_XAG_H1_dukascopy.zip')
h=pd.read_csv(io.BytesIO(z.read('XAUUSD/2026.10.28XAUUSD-H1-No Session.csv')),header=None,names=['d','t','o','h','l','c','v'],skiprows=1)
h.index=pd.to_datetime(h.d.astype(str)+' '+h.t,format='%Y%m%d %H:%M:%S'); h=h[['o','h','l','c']].astype(float)
def rs(df,rule): return df.resample(rule).agg({'o':'first','h':'max','l':'min','c':'last'}).dropna()
def atr(df,p=14):
    tr=pd.concat([df.h-df.l,(df.h-df.c.shift()).abs(),(df.l-df.c.shift()).abs()],axis=1).max(axis=1); return tr.ewm(alpha=1/p,adjust=False).mean()
def st(df,p=10,m=3):
    hl2=((df.h+df.l)/2).values; a=atr(df,p).values; up=hl2-m*a; dn=hl2+m*a; c=df.c.values
    U=up.copy();D=dn.copy();d=np.ones(len(df))
    for i in range(1,len(df)):
        U[i]=max(up[i],U[i-1]) if c[i-1]>U[i-1] else up[i]
        D[i]=min(dn[i],D[i-1]) if c[i-1]<D[i-1] else dn[i]
        d[i]=1 if (d[i-1]==-1 and c[i]>D[i-1]) else (-1 if (d[i-1]==1 and c[i]<U[i-1]) else d[i-1])
    return pd.Series(d,df.index)
def rukh(df):
    e50=df.c.ewm(span=50,adjust=False).mean(); e200=df.c.ewm(span=200,adjust=False).mean(); s=st(df)
    return pd.Series(np.where((df.c>e50)&(e50>e200)&(s>0),1,np.where((df.c<e50)&(e50<e200)&(s<0),-1,0)),df.index),s
d1=rs(h,'1D'); d1r,_=rukh(d1); d1a=atr(d1)
h4=rs(h,'4h'); h4r,h4s=rukh(h4)
# 1D values of PREVIOUS closed day mapped to each 4H bar
day=h4.index.normalize()
prevD=pd.Series(d1r.shift(1).reindex(day,method='ffill').values,h4.index)
prevA=pd.Series(d1a.shift(1).reindex(day,method='ffill').values,h4.index)
c=h4.c.values; n=len(h4)
low12=h4.l.rolling(12).min().values
X=pd.DataFrame({'c':c,'D':prevD.values,'H':h4r.values,'S':h4s.values,'A':prevA.values,'low':low12},h4.index)
X=X['2005':]
X['bnc']=(X.c-X.low)/X.A
for k in (6,24): X[f'f{k}']=(X.c-X.c.shift(-k))/X.A   # SELL ka faida ATR mein
X['mae24']=(X.c.rolling(24).max().shift(-24)-X.c)/X.A
ev=X[(X.D==-1)&(X.H==-1)].dropna()
ev['b']=pd.cut(ev.bnc,[0,0.25,0.5,0.75,1,1.5,9])
print("Q1: SELL (1D+4H neeche) - wapasi ATR mein vs aage 4 din"); 
print(ev.groupby('b',observed=True).agg(n=('f24','size'),f6=('f6','mean'),f24=('f24','mean'),jeet24=('f24',lambda s:(s>0).mean()),mae=('mae24','mean')).round(2))
print("aaj ATR:",round(prevA.iloc[-1],1))
# Q2: 4H ST up-flip while a SELL would be open (prev bar both neeche)
f=X[(X.S==1)&(X.S.shift(1)==-1)&(X.D.shift(1)==-1)].copy()
# hold until 4H ST flips down again
S=X.S.values; idx={t:i for i,t in enumerate(X.index)}
res=[]
for t in f.index:
    i=idx[t]; j=i+1
    while j<len(X) and S[j]==1: j+=1
    if j>=len(X): continue
    res.append(((X.c.iloc[i]-X.c.iloc[j])/X.A.iloc[i], (X.c.iloc[i]-X.c.iloc[min(i+24,len(X)-1)])/X.A.iloc[i], X.D.iloc[i]))
r=pd.DataFrame(res,columns=['hold_till_down','hold24','D'])
print("Q2: 4H mur kar upar - SELL rakhne ka faida (ATR, + = rakhna behtar)"); print(len(r), r[['hold_till_down','hold24']].mean().round(2).to_dict(), 'jeet', (r.hold_till_down>0).mean().round(2))
print(r.groupby('D')[['hold_till_down','hold24']].agg(['mean','size']).round(2))
print(X.loc['2026-10-27':'2026-10-28',['c','A','bnc','D','H']].round(2).tail(3))
print("median f24 by bucket", ev.groupby('b',observed=True).f24.median().round(2).to_dict())
