import pandas as pd, numpy as np, zipfile
R='/home/claude/jalal786451/jas-sniper-bot/data/'
def rd_hist(z):
    with zipfile.ZipFile(R+z) as zf:
        n=[x for x in zf.namelist() if x.endswith('.csv')][0]
        d=pd.read_csv(zf.open(n),sep=';',header=None,names=['t','o','h','l','c','v'])
    d['t']=pd.to_datetime(d['t'],format='%Y%m%d %H%M%S')+pd.Timedelta(hours=5); return d
def rd_qdm(z):
    with zipfile.ZipFile(R+z) as zf:
        n=[x for x in zf.namelist() if x.endswith('.csv')][0]; d=pd.read_csv(zf.open(n))
    d['t']=pd.to_datetime(d['Date'].astype(str)+' '+d['Time'])
    return d.rename(columns={'Open':'o','High':'h','Low':'l','Close':'c','Volume':'v'})[['t','o','h','l','c','v']]
P=[rd_hist(f'histdata/XAUUSD_M1_{y}_NY.zip') for y in range(2009,2019)]
P+= [rd_qdm('qdm/M1/XAUUSD_M1_2019.zip'),rd_qdm('qdm/M1/XAUUSD_M1_2020.zip'),rd_qdm('qdm/XAUUSD_M1_2021_24.zip'),rd_qdm('qdm/M1/XAUUSD_M1_2025.zip'),rd_qdm('qdm/M1/XAUUSD_M1_2026.zip')]
d=pd.concat(P).drop_duplicates('t').sort_values('t').set_index('t')
print(d.index.min(),d.index.max(),len(d))
h=d.resample('15min').agg({'o':'first','h':'max','l':'min','c':'last'}).dropna()
print(len(h)); g=h.index.to_series().diff().dt.days; print('gaps>5d',g[g>5].to_dict())
h.to_csv('/home/claude/work/xau_m15.csv')
