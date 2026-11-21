import sys; sys.path.insert(0,'/home/claude/jas-sniper-bot/tools')
import warnings; warnings.filterwarnings('ignore')
src=open('/home/claude/work/trend35.py').read().split("COST=0.0002")[0]
exec(src)
import importlib.util
spec=importlib.util.spec_from_file_location('ftmo_test','/home/claude/jas-sniper-bot/tools/ftmo_test.py'); ft=importlib.util.module_from_spec(spec); spec.loader.exec_module(ft)
out=[]
for mk in ('XAUUSD','USATECH','USA500','XAGUSD'):
    h=H4[mk]; up,_=ft.supertrend_up(h.h.values,h.l.values,h.c.values)
    t5=pd.Series(up.astype(int),index=h.index)                     # t5-jaisa: 4H Supertrend upar = BUY
    ema=pd.Series((ema_ := (pd.Series(h.c.values).ewm(span=50,adjust=False).mean()>pd.Series(h.c.values).ewm(span=200,adjust=False).mean()).values.astype(int)),index=h.index)  # hamara 50/200 upar
    ret=h.c.pct_change().fillna(0)
    d=lambda p:(p.shift(1).fillna(0)*ret).groupby(h.index.normalize()).sum()
    m=h.index>='2013-01-01'; t5m=t5[m]; em=ema[m]
    both=((t5m==1)&(em==1)).mean()*100
    # kitne hisse waqt jab hamara BUY zone mein, t5 bhi BUY mein
    cond=((t5m==1)&(em==1)).sum()/max(em.sum(),1)*100
    cor=pd.concat([d(t5),d(ema)],axis=1)[lambda x:x.index>='2013'].corr().iloc[0,1]
    out.append((mk,(t5m==1).mean()*100,(em==1).mean()*100,cond,cor))
print('market  t5-BUY-waqt%  EMA50/200-BUY-waqt%  EMA zone mein t5 bhi BUY %  daily return correlation')
for o in out: print('%-8s %6.0f %14.0f %20.0f %24.2f'%o)
