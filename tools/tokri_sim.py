# Tokri Q10-Q13 sim (5 Nov): python3 tools/tokri_sim.py grid | G,T,N,B,S,J[,DH]  (G/T = din ATR, N fishing hadd, B/S = % equity)
# Tokri sim: fishing 0.01 + dhaal 0.01 (Q1-Q9) gold H1, cent account (0.01 lot = 1 USC / $1)
import sys, itertools, pickle, numpy as np, pandas as pd
exec(open(__file__.replace('tokri_sim.py','tokri_q8q9.py')).read().split('# 1D values')[0])  # data + rukh funcs (prints nothing before)
day=h.index.normalize()
D=pd.Series(d1r.shift(1).reindex(day,method='ffill').values,h.index).values
A=pd.Series(d1a.shift(1).reindex(day,method='ffill').values,h.index).values
k4=h.index.floor('4h')
s4=h4s.shift(1).reindex(k4,method='ffill').values; r4=h4r.shift(1).reindex(k4,method='ffill').values
C=h.c.values; HI=h.h.values; LO=h.l.values; low2=h.l.rolling(48).min().values
mon=h.index.to_period('M').astype(str).values
COST=0.30 if 'COST' not in dir() else COST
def run(i0,i1,G,T,N,B,S,J,eq0=37800.0,DH=1,DMAX=99):
    bal=eq0; L=[]  # [dir, open, kind] kind 0 fish 1 dhaal
    peak=eq0; mdd=0; stops=0; maxn=0; mpl={}
    for i in range(i0,i1):
        a=A[i]; c=C[i]
        if not a==a or not s4[i]==s4[i]: continue
        # TP fishing (intrabar high/low)
        keep=[]
        for p in L:
            if p[2]==0:
                tp=p[1]+p[0]*p[3]
                if (p[0]==1 and HI[i]>=tp) or (p[0]==-1 and LO[i]<=tp): bal+=p[3]-COST; continue  # tk1 fix: TP open waqt ki ATR se (pehle chalti ATR = ghalat)
            keep.append(p)
        L=keep
        fl=lambda p:(c-p[1])*p[0]-COST
        # Q9: dhaal band jab 4H basket ki taraf mude
        keep=[]
        for p in L:
            if p[2]==1 and s4[i]==-p[0]: bal+=fl(p); continue
            keep.append(p)
        L=keep
        # jori close: dhaal + sab se buri fishing >=0
        if J:
            for dp in [p for p in L if p[2]==1]:
                fish=[p for p in L if p[2]==0 and p[0]==-dp[0]]
                if not fish: continue
                w=min(fish,key=fl)
                if fl(dp)+fl(w)>=0 and dp in L: bal+=fl(dp)+fl(w); L.remove(dp); L.remove(w)
        flo=sum(fl(p) for p in L); eq=bal+flo
        # aakhri hadd
        if S and flo<=-S*eq0/100:
            bal=eq; L=[]; stops+=1; flo=0
        # fishing side
        st=s4[i]; side= 1 if st==1 else (-1 if (st==-1 and D[i]==-1) else 0)
        nf=sum(1 for p in L if p[2]==0)
        if side and nf<N and flo>-B*eq0/100:
            mine=[p[1] for p in L if p[2]==0 and p[0]==side]
            if not mine or min(abs(c-o) for o in mine)>=G*a: L.append([side,c,0,T*a])
        # dhaal (Q2,Q6,Q7,Q8)
        for bs in (1,-1):
            fish=[p for p in L if p[2]==0 and p[0]==bs]
            if not fish: continue
            lb=sum(fl(p) for p in fish); nd=sum(1 for p in L if p[2]==1 and p[0]==-bs)
            against = (D[i]==-bs and r4[i]==-bs)
            bounce = (c-low2[i]) if bs==1 else (max(HI[max(0,i-48):i+1])-c)
            if DH and nd<DMAX and against and lb<=-200*(nd+1) and bounce<a: L.append([-bs,c,1,0])
        maxn=max(maxn,len(L))
        eq=bal+sum(fl(p) for p in L); peak=max(peak,eq); mdd=max(mdd,(peak-eq)/peak)
        mpl[mon[i]]=eq
    eq=bal+sum(fl(p) for p in L)
    m=pd.Series(mpl); mr=m.diff().fillna(m.iloc[0]-eq0)
    return dict(ret=round((eq/eq0-1)*100,1),mdd=round(mdd*100,1),worstM=round(mr.min()),stops=stops,maxn=maxn,openEnd=len(L))
idx=lambda s:np.searchsorted(h.index.values,np.datetime64(s))
part=sys.argv[1]
if part=='grid':
    i0,i1=idx('2010-01-01'),idx('2019-01-01'); out=[]
    for G,T,N,B,S,J in itertools.product([0.25,0.5,1],[0.25,0.5,1],[5,10,20],[2,5,10],[0,10,20],[1,0]):
        r=run(i0,i1,G,T,N,B,S,J); r.update(G=G,T=T,N=N,B=B,S=S,J=J); out.append(r); print(r,flush=True)
    pickle.dump(out,open('grid.pkl','wb'))
else:
    v=list(map(float,part.split(",")))+[1]; G,T,N,B,S,J,DH=v[:7]; DM=int(v[7]) if len(v)>8 else 99
    for a,b in (('2010-01-01','2019-01-01'),('2019-01-01','2026-11-01'),('2026-08-18','2026-11-01')):
        print(a,b,run(idx(a),idx(b),G,T,int(N),B,S,int(J),DH=int(DH),DMAX=DM))
