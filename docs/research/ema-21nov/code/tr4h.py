exec(open('/home/claude/work/bt2.py').read())
def trades_stop(b,f,s_,k,cost=0.5,n=14):
    O,H,L,C=b.O,b.H,b.L,b.C; A=atr(b.h,n); sg=cross(C,f,s_,'long'); N=len(C)
    T=[]; pos=0; blocked=False; pnl=np.zeros(N)
    for i in range(1,N):
        want=sg[i-1]
        if pos==1:
            if O[i]<=stop: pnl[i]=O[i]-C[i-1]-cost/2; T.append((ei,i,ep,O[i],'SL')); pos=0; blocked=(want==1); continue
            if want==0: pnl[i]=O[i]-C[i-1]-cost/2; T.append((ei,i,ep,O[i],'EMA')); pos=0; blocked=False; continue
            pnl[i]=O[i]-C[i-1]
            if L[i]<=stop: pnl[i]+=stop-O[i]-cost/2; T.append((ei,i,ep,stop,'SL')); pos=0; blocked=(want==1); continue
            pnl[i]+=C[i]-O[i]
        else:
            if want==0: blocked=False
            if want==1 and not blocked:
                pos=1; ep=O[i]; ei=i; stop=ep-k*A[i-1]; pnl[i]=-cost/2
                if L[i]<=stop: pnl[i]+=stop-O[i]-cost/2; T.append((ei,i,ep,stop,'SL')); pos=0; blocked=True; continue
                pnl[i]+=C[i]-O[i]
    if pos==1: T.append((ei,N-1,ep,C[-1],'OPEN'))
    return T,pnl
h=load('/home/claude/work/xau_h4.csv'); b=BT(h,1560)
for k in (0,3,4,5,6,8):
    if k==0: p,pnl=b.run(cross(b.C,50,200,'long')); T=None
    else: T,pnl=trades_stop(b,50,200,k)
    r=pnl/np.r_[b.C[0],b.C[:-1]]; eq=np.cumprod(1+r); dd=(eq/np.maximum.accumulate(eq)-1).min()*100
    out='k=%s ret %.0f%% dd %.1f%%'%(k,(eq[-1]-1)*100,dd)
    if T:
        pn=np.array([(x[3]-x[2]-0.5)/x[2] for x in T]); out+=' n=%d wr=%.0f%% pf=%.2f worst=%.1f%% SLhits=%d'%(len(T),(pn>0).mean()*100,pn[pn>0].sum()/-pn[pn<0].sum(),pn.min()*100,sum(1 for x in T if x[4]=='SL'))
    print(out)
T,pnl=trades_stop(b,50,200,4)
print('\nAll 4H 50/200 4ATR trades:')
for e,x,ep,xp,why in T: print(b.idx[e].strftime('%Y-%m-%d %H:%M'),'%.2f'%ep,'->',b.idx[x].strftime('%Y-%m-%d %H:%M'),'%.2f'%xp,why,'%.1f%%'%((xp-ep-0.5)/ep*100))
