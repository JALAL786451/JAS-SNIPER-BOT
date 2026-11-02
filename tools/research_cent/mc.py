import numpy as np
rng=np.random.default_rng(1)
def sim(p,cost_R,n,chains,base,dstop,acct_stop=0.5,days=250,runs=4000,mult=2):
    ruin=0; meds=[];bads=[];fin=[]
    for r in range(runs):
        eq=1000.0; dp_all=[]
        for d in range(days):
            dp=0; c=0
            while c<chains and dp>-dstop:
                step=0
                while True:
                    risk=base*mult**step
                    w=rng.random()<p
                    pnl=risk*((1 if w else -1)-cost_R); dp+=pnl
                    if w or step==n-1: break
                    if dp<=-dstop: break
                    step+=1
                c+=1
            eq+=dp; dp_all.append(dp)
            if eq<1000*acct_stop: ruin+=1; break
        a=np.array(dp_all); meds.append(np.median(a)); bads.append(np.percentile(a,5)); fin.append(eq)
    return ruin/runs, np.median(meds), np.median(bads), np.median(fin)
print('p n chains base dstop | P(ruin<50%/yr) median_day p5_day median_final')
for p,cr in [(0.5,0.0),(0.491,0.04),(0.70,0.05)]:
  for n,ch,b,ds in [(5,4,2.5,80),(6,8,1.25,80),(4,6,2,60),(8,10,1,300),(1,10,1.5,30)]:
    if p==0.70 and n>4: continue
    r=sim(p,cr,n,ch,b,ds,runs=1500)
    print(p,n,ch,b,ds,'| %.3f %.1f %.1f %.0f'%r)
