import sys; sys.path.insert(0,'.')
from sim import *
import pickle
R='/home/user/JAS-SNIPER-BOT/data/qdm/'
res=pickle.load(open('tr.pkl','rb'))
sp=load([R+'M1/USA500IDXUSD_M1_%d.zip'%y for y in range(2012,2019)])
for D in [0.001,0.0025]:
  for mode,h0,h1 in [('mom',13,20),('rev',13,20)]:
    tr=trades(sp,D,0.00007,mode,5,h0,h1); n=len(tr)
    print('us500 cost.007%',D,mode,n,'perday %.1f'%(n/tr.day.nunique()),'win %.3f Exp %.4f se %.4f'%((tr.R>0).mean(),tr.R.mean(),tr.R.std()/n**.5))
    res[('us500c',D,mode)]=tr
pickle.dump(res,open('tr.pkl','wb'))
# martingale on gold 0.25% mom
for key in [('gold2015',0.0025,'mom'),('gold2015',0.001,'mom'),('gold2015',0.0025,'rev')]:
  tr=res[key]
  for base,mult,nmax,ds in [(1.25,2,5,40),(1,2,6,64),(2,2,4,30),(10,1,1,30)]:
    eq,s=mart(tr,base,mult,nmax,ds,kill=0.0)
    print(key,'base',base,'x',mult,'n',nmax,'dstop',ds,'final %.0f'%eq,'days',len(s),'median %.1f'%s.median(),'p10 %.1f'%s.quantile(.1),'min %.1f'%s.min(),'win-days %.2f'%(s>0).mean(), 'maxDD %.0f'%((s.cumsum().cummax()-s.cumsum()).max()))
