import sys; sys.path.insert(0,'.')
from sim import *
R='/home/user/JAS-SNIPER-BOT/data/qdm/'
g=load([R+'XAUUSD_M1_2015.zip'])
sp=load([R+'M1/USA500IDXUSD_M1_%d.zip'%y for y in range(2012,2019)])
res={}
for name,d,cost in [('gold2015',g,0.00006),('us500_12_18',sp,0.0002)]:
    for D in [0.001,0.0025]:
        for mode,h0,h1 in [('mom',7,20),('rev',0,6),('alt',7,20)]:
            tr=trades(d,D,cost,mode,5,h0,h1)
            p=(tr.R>0).mean(); n=len(tr); days=tr.day.nunique()
            print(name,D,mode,'n',n,'perday %.1f'%(n/days),'win %.3f'%p,'Exp %.4fR se %.4f'%(tr.R.mean(),tr.R.std()/n**.5),flush=True)
            res[(name,D,mode)]=tr
import pickle; pickle.dump(res,open('tr.pkl','wb'))
