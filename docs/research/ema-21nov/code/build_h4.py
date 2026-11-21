import pandas as pd, zipfile, io, sys
R='/home/claude/jalal786451/jas-sniper-bot/data/'
parts=[]
def rd_hist(z):
    with zipfile.ZipFile(R+z) as zf:
        n=[x for x in zf.namelist() if x.endswith('.csv')][0]
        d=pd.read_csv(zf.open(n),sep=';',header=None,names=['t','o','h','l','c','v'])
    d['t']=pd.to_datetime(d['t'],format='%Y%m%d %H%M%S')+pd.Timedelta(hours=5)  # EST->UTC
    return d
def rd_qdm(z):
    with zipfile.ZipFile(R+z) as zf:
        n=[x for x in zf.namelist() if x.endswith('.csv')][0]
        d=pd.read_csv(zf.open(n))
    d['t']=pd.to_datetime(d['Date'].astype(str)+' '+d['Time'])
    return d.rename(columns={'Open':'o','High':'h','Low':'l','Close':'c','Volume':'v'})[['t','o','h','l','c','v']]
for y in (2016,2017,2018): parts.append(rd_hist(f'histdata/XAUUSD_M1_{y}_NY.zip'))
parts.append(rd_qdm('qdm/M1/XAUUSD_M1_2019.zip')); parts.append(rd_qdm('qdm/M1/XAUUSD_M1_2020.zip'))
parts.append(rd_qdm('qdm/XAUUSD_M1_2021_24.zip')); parts.append(rd_qdm('qdm/M1/XAUUSD_M1_2025.zip')); parts.append(rd_qdm('qdm/M1/XAUUSD_M1_2026.zip'))
d=pd.concat(parts).drop_duplicates('t').sort_values('t').set_index('t')
print(d.index.min(),d.index.max(),len(d))
h=d.resample('4h').agg({'o':'first','h':'max','l':'min','c':'last','v':'sum'}).dropna()
h=h[h.index>='2016-11-21']
print(len(h)); print(h.head(3)); print(h.tail(3))
# gap check
g=h.index.to_series().diff().dt.days; print('gaps >5d:\n',g[g>5])
print('max jump %:',(h.c.pct_change().abs().sort_values().tail(5)*100).round(2).to_dict())
h.to_csv('/home/claude/work/xau_h4.csv')
