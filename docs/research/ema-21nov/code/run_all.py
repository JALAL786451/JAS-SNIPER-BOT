exec(open('/home/claude/work/bt2.py').read())
pd.set_option('display.width',250)
# ---------- 4H stop test ----------
h4=load('/home/claude/work/xau_h4.csv'); b=BT(h4,6*5*52)
print('== 4H  50/200 long, ATR stop')
for k in (None,2,3,4,6):
    if k is None: p,pnl=b.run(cross(b.C,50,200,'long'))
    else:
        pnl=run_stop(b,50,200,k); p=(pnl!=0).astype(int)  # p only used for trade count approx
    r=pnl/np.r_[b.C[0],b.C[:-1]]; eq=np.cumprod(1+r); dd=(eq/np.maximum.accumulate(eq)-1).min()*100
    # worst single trade approx via loss runs skipped; report ret/dd
    print('stop',k,'ret %.0f%% dd %.1f%%'%((eq[-1]-1)*100,dd))
# worst trade for no-stop
p,pnl=b.run(cross(b.C,50,200,'long')); r=pnl/np.r_[b.C[0],b.C[:-1]]
seg=np.r_[0,np.flatnonzero(np.diff(p)!=0)+1,len(p)]
t=np.array([r[a:b_].sum() for a,b_ in zip(seg[:-1],seg[1:]) if p[a]!=0]); print('no-stop worst trade %.1f%%, avg loss %.1f%%, avg win %.1f%%'%(t.min()*100,t[t<0].mean()*100,t[t>0].mean()*100))
# ---------- 15M ----------
h=load('/home/claude/work/xau_m15.csv'); ppy=len(h)/((h.index[-1]-h.index[0]).days/365.25); b=BT(h,ppy)
print('\n== 15M',h.index[0],h.index[-1],len(h),'bars; B&H %.0f%%'%((h.c.iloc[-1]/h.c.iloc[0]-1)*100))
split=b.idx<'2018-01-01'; oos=~split
rows=[]
pairs=[(5,20),(10,30),(20,60),(50,200),(100,400),(200,800),(400,1600),(800,3200),(1600,6400)]
for mode in ('long','both'):
    for f,s_ in pairs:
        p,pnl=b.run(cross(b.C,f,s_,mode)); a=b.stats(p,pnl); i=b.stats(p,pnl,split); o=b.stats(p,pnl,oos)
        rows.append(dict(par=f'{f}/{s_}',mode=mode,ret=a['ret'],dd=a['dd'],n=a['n'],wr=a['wr'],pf=a['pf'],sh=a['sh'],is_ret=i['ret'],oos_ret=o['ret'],oos_pf=o['pf'],oos_dd=o['dd']))
R=pd.DataFrame(rows); R.to_csv('/home/claude/work/results_15m.csv',index=False); print(R.round(1).to_string(index=False))
