import warnings; warnings.filterwarnings('ignore')
src=open('/home/claude/work/multi.py').read().split("SPLIT=pd.Timestamp")[0]
exec(src)
from sklearn.linear_model import LogisticRegression
from sklearn.preprocessing import StandardScaler
def dayframe(df):
    d=df.index.normalize(); g=df.groupby(d)
    return pd.DataFrame({'dopen':g.open.first(),'dclose':g.close.last(),'dhigh':g.high.max(),'dlow':g.low.min()})
F={k:dayframe(v) for k,v in data.items()}
base={}
for k,f in F.items():
    c=f.dclose
    base[k+'_r1']=c.pct_change().shift(1); base[k+'_r3']=c.pct_change(3).shift(1); base[k+'_rng']=((f.dhigh-f.dlow)/c).shift(1)
B=pd.DataFrame(base)
COST=2.0/1e4
def run(target,shuffle=False,seed=0):
    f=F[target]; c=f.dclose
    X=B.copy()
    X['r5']=c.pct_change(5).shift(1); X['r10']=c.pct_change(10).shift(1)
    X['e20']=(c/c.ewm(span=20).mean()-1).shift(1); X['e50']=(c/c.ewm(span=50).mean()-1).shift(1); X['vol10']=c.pct_change().rolling(10).std().shift(1)
    X=pd.concat([X,pd.get_dummies(X.index.dayofweek,prefix='dow').set_index(X.index).astype(float)],axis=1)
    y=(f.dclose/f.dopen-1)            # open->close, 1 trade per day
    dfm=X.join(y.rename('y'),how='inner').dropna(subset=['y']); X=dfm.drop(columns='y').fillna(0); X=X.loc[:,X.std()>0]; y=dfm.y
    rng=np.random.default_rng(seed); pos=pd.Series(0.0,index=X.index)
    first=X.index[0].year+3
    for yr in range(max(first,2010),2027):
        tr=X.index.year<yr; te=X.index.year==yr
        if te.sum()==0 or tr.sum()<700: continue
        ytr=(y[tr]>0).astype(int).values
        if shuffle: ytr=rng.permutation(ytr)
        sc=StandardScaler().fit(X[tr].values); m=LogisticRegression(C=0.005,max_iter=300).fit(sc.transform(X[tr].values),ytr)
        pos[te]=np.sign(m.predict_proba(sc.transform(X[te].values))[:,1]-0.5)
    mk=pos!=0; r=y[mk]; p=pos[mk]; net=p*r-COST; gross=p*r
    return dict(n=len(net),gross_bp=gross.mean()*1e4,net_bp=net.mean()*1e4,t=net.mean()/net.std()*np.sqrt(len(net)),tg=gross.mean()/gross.std()*np.sqrt(len(net)),cum=((1+net).prod()-1)*100)
rows=[]
for k in sorted(F):
    try: rows.append(dict(mkt=k,**run(k)))
    except Exception as e: print(k,e)
D=pd.DataFrame(rows); D.to_csv('/home/claude/work/ml_all.csv',index=False)
pd.set_option('display.width',200)
print(D.sort_values('t',ascending=False).round(2).to_string(index=False))
Z=D.t.sum()/np.sqrt(len(D)); Zg=D.tg.sum()/np.sqrt(len(D))
print('\nmarkets',len(D),' mean gross %.2f bp, mean net %.2f bp  | Stouffer Z net %.2f, gross %.2f | t>2: %d  t>3: %d  t<-2: %d'%(D.gross_bp.mean(),D.net_bp.mean(),Z,Zg,(D.t>2).sum(),(D.t>3).sum(),(D.t<-2).sum()))
pl=[]
for k in sorted(F):
    try: pl.append(run(k,shuffle=True,seed=1)['t'])
    except: pass
pl=np.array(pl); print('PLACEBO (shuffled labels): mean t %.2f sd %.2f, t>2: %d of %d'%(pl.mean(),pl.std(),(pl>2).sum(),len(pl)))

# ---- extra checks: placebo GROSS, always-long GROSS, per-year AUDCHF
pg=[];bh=[]
for k in sorted(F):
    try:
        pg.append(run(k,shuffle=True,seed=2)['tg'])
        f=F[k]; y=(f.dclose/f.dopen-1).loc['2010-01-01':]; bh.append(y.mean()/y.std()*np.sqrt(len(y)))
    except Exception as e: pass
pg=np.array(pg);bh=np.array(bh)
print('\nPLACEBO gross Z (35 mkts, shuffled): %.2f (mean t %.2f sd %.2f) ; REAL gross Z %.2f'%(pg.sum()/np.sqrt(len(pg)),pg.mean(),pg.std(),Zg))
print('Always-long gross Z over same markets: %.2f'%(bh.sum()/np.sqrt(len(bh))))
