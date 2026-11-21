import warnings; warnings.filterwarnings('ignore')
src=open('/home/claude/work/multi.py').read().split("SPLIT=pd.Timestamp")[0]
exec(src)
import numpy as np, pandas as pd
from sklearn.linear_model import LogisticRegression
from sklearn.ensemble import HistGradientBoostingClassifier
from sklearn.preprocessing import StandardScaler
feat={}
def dayframe(df):
    d=df.index.normalize(); g=df.groupby(d)
    out=pd.DataFrame({'dopen':g.open.first(),'dclose':g.close.last(),'dhigh':g.high.max(),'dlow':g.low.min()})
    for h in (7,21):
        x=df[df.index.hour>=h]; out['o%d'%h]=x.groupby(x.index.normalize()).open.first()
    return out
F={k:dayframe(v) for k,v in data.items()}
gold=F['XAUUSD']
cols={}
for k,f in F.items():
    c=f.dclose
    cols[k+'_r1']=c.pct_change().shift(1)          # prev day return (known)
    cols[k+'_r3']=c.pct_change(3).shift(1)
    cols[k+'_asia']=f.o7/f.dopen-1                 # today's Asia session (00->07 UTC), known at 07:00
    cols[k+'_rng']=((f.dhigh-f.dlow)/c).shift(1)
X=pd.DataFrame(cols)
gc=gold.dclose
X['g_r5']=gc.pct_change(5).shift(1); X['g_r10']=gc.pct_change(10).shift(1); X['g_r20']=gc.pct_change(20).shift(1)
X['g_e20']=(gc/gc.ewm(span=20).mean()-1).shift(1); X['g_e50']=(gc/gc.ewm(span=50).mean()-1).shift(1)
X['g_vol10']=gc.pct_change().rolling(10).std().shift(1)
dw=pd.get_dummies(X.index.dayofweek,prefix='dow').set_index(X.index).astype(float); X=pd.concat([X,dw],axis=1)
y_ret=(gold.o21/gold.o7-1)       # trade 07:00 -> 21:00 UTC
dfm=X.join(y_ret.rename('y')).loc['2005-01-01':].dropna(subset=['y']); 
X=dfm.drop(columns='y').fillna(0); X=X.loc[:,X.std()>0]; y=dfm.y
print('features',X.shape[1],'days',len(X),X.index[0].date(),X.index[-1].date())
COST=2.0/1e4
def walk(model_fn,ytrain,start=2010,shuffle=False,seed=0):
    rng=np.random.default_rng(seed); preds=pd.Series(index=X.index,dtype=float)
    for yr in range(start,2027):
        tr=X.index.year<yr; te=X.index.year==yr
        if te.sum()==0: continue
        Xtr=X[tr].values; ytr=(ytrain[tr]>0).astype(int).values
        if shuffle: ytr=rng.permutation(ytr)
        sc=StandardScaler().fit(Xtr); m=model_fn(); m.fit(sc.transform(Xtr),ytr)
        preds[te]=m.predict_proba(sc.transform(X[te].values))[:,1]
    return preds.dropna()
def evaluate(p,thr=0.0):
    r=y.loc[p.index]; pos=np.sign(p-0.5); pos[(p-0.5).abs()<thr]=0
    gross=pos*r; net=gross-np.abs(pos)*COST
    n=net[pos!=0]
    return dict(n=len(n),tpy=len(n)/((p.index[-1]-p.index[0]).days/365.25),gross_bp=gross[pos!=0].mean()*1e4,net_bp=n.mean()*1e4,t=n.mean()/n.std()*np.sqrt(len(n)),hit=(n>0).mean()*100,cum=((1+n).prod()-1)*100,hit_dir=((pos*r)[pos!=0]>0).mean()*100)
LR=lambda: LogisticRegression(C=0.005,max_iter=300)
GB=lambda: HistGradientBoostingClassifier(max_depth=3,max_iter=80,learning_rate=0.04,l2_regularization=5.0,min_samples_leaf=60,random_state=0)
for nm,fn in (('Logistic',LR),('GradBoost',GB)):
    p=walk(fn,y)
    print('\n==',nm,'walk-forward 2010-2026, gold 07:00->21:00 UTC, cost 2bp')
    for thr in (0.0,0.03,0.06):
        e=evaluate(p,thr); print(' thr %.2f: '%thr+' '.join('%s=%.2f'%(k,v) for k,v in e.items()))
    if nm=='Logistic': pL=p
    else: pG=p
# placebo (shuffled labels) distribution of t for Logistic
ts=[]
for s in range(12):
    p=walk(LR,y,shuffle=True,seed=s); ts.append(evaluate(p,0.0)['t'])
print('\nPLACEBO (shuffled labels, Logistic) t-stats:',np.round(ts,2),' mean %.2f sd %.2f'%(np.mean(ts),np.std(ts)))
# buy&hold same window for reference + per-year net of logistic
r=y.loc[pL.index]; pos=np.sign(pL-0.5); net=pos*r-COST
print('\nGold 07->21 always-long avg bp %.2f ; by year (Logistic net %%):'%(r.mean()*1e4))
print(((1+net).groupby(net.index.year).prod()-1).mul(100).round(1).to_dict())
