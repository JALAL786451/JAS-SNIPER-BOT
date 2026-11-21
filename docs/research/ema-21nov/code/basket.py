src=open('/home/claude/work/trend35.py').read().split("COST=0.0002")[0]
exec(src)
COST=0.0002
ds={};info={}
for nm,h in H4.items():
    r,n=simulate(h,50,200,4,COST); st,d=stats(r,n); ds[nm]=d; info[nm]=(st,n)
D=pd.DataFrame(ds)
def seg(s,a,b): return s[(s.index>=a)&(s.index<b)].dropna()
rows=[]
for nm in D:
    s=D[nm].dropna(); i=seg(s,'1900','2018'); o=seg(s,'2018','2100')
    tt=lambda x: x.mean()/x.std()*np.sqrt(len(x)) if len(x)>200 and x.std()>0 else np.nan
    eq=(1+s).cumprod(); 
    rows.append(dict(mkt=nm,yrs=info[nm][0]['yrs'],is_yrs=len(i)/252,t_is=tt(i),t_oos=tt(o),ret=(eq.iloc[-1]-1)*100,dd=(eq/eq.cummax()-1).min()*100,trades=info[nm][1]))
M=pd.DataFrame(rows).set_index('mkt')
# rule fixed BEFORE looking at OOS: needs >=5y history before 2018 and t_is>0.5
sel=M[(M.is_yrs>=5)&(M.t_is>0.5)].index.tolist()
print('chosen using only pre-2018 data (t_is>0.5):',sel)
def port(names,a,b):
    P_=D[names][(D.index>=a)&(D.index<b)].mean(axis=1).dropna(); eq=(1+P_).cumprod(); yrs=(P_.index[-1]-P_.index[0]).days/365.25
    return dict(cagr=(eq.iloc[-1]**(1/yrs)-1)*100,dd=(eq/eq.cummax()-1).min()*100,sh=P_.mean()/P_.std()*np.sqrt(252))
print('\nBASKET chosen on pre-2018 only, judged on 2018-2026 (never used to choose):')
print(' basket',sel,port(sel,'2018','2100'))
print(' gold alone',port(['XAUUSD'],'2018','2100'))
allm=list(D.columns); print(' all 35 markets',port(allm,'2018','2100'))
bhp=pd.DataFrame({nm:h.c.pct_change().groupby(h.index.normalize()).apply(lambda x:(1+x.dropna()).prod()-1) for nm,h in H4.items()})
b=bhp[sel][bhp.index>='2018'].mean(axis=1).dropna(); eq=(1+b).cumprod(); y=(b.index[-1]-b.index[0]).days/365.25
print(' same basket buy&hold: cagr %.1f dd %.1f sh %.2f'%((eq.iloc[-1]**(1/y)-1)*100,(eq/eq.cummax()-1).min()*100,b.mean()/b.std()*np.sqrt(252)))
yrs=(D.index[-1]-D.index[0]).days/365.25
print(' trades per year (basket, whole history):',round(sum(info[n][1]/info[n][0]['yrs'] for n in sel),1))
pd.set_option('display.width',200)
print('\nper-market (stop 4 ATR, 2bp):'); print(M.loc[sel].round(1).to_string())
print('\nnot chosen (for reference):'); print(M.drop(sel)[['yrs','t_is','t_oos','ret','dd']].round(1).sort_values('t_oos',ascending=False).head(12).to_string())
