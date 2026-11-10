# Exness statement PDF (pdftotext -layout) ka hisaab: band (chhoti/bari lot) + khuli tickets qeemat tarteeb. Chalao: pdftotext -layout x.pdf r.txt; python3 tools/exness_pdf.py r.txt
import re,sys,collections
L=open(sys.argv[1]).read().splitlines()
op=L.index('Open Trades:') if 'Open Trades:' in L else [i for i,l in enumerate(L) if l.startswith('Open Trades')][0]
rx=re.compile(r'^(\d{9,})\s+(buy|sell)\s+(\S+ \S+)\s+(\S+)\s+([\d.]+)\s+([\d.]+)\s+(.*)$')
cl=[];o=[]
for i,l in enumerate(L):
    m=rx.match(l.strip())
    if not m: continue
    nums=m.group(7).split()
    pm=re.search(r'(-?\d{1,3}(?: \d{3})*(?:\.\d+)?)\s*$',l.strip());rec=dict(id=m.group(1),t=m.group(2),ot=m.group(3),sym=m.group(4),op=float(m.group(5)),vol=float(m.group(6)),pr=0 if not pm else float(pm.group(1).replace(' ','')),rest=nums)
    (o if i>op else cl).append(rec)
print('closed',len(cl),'open',len(o))
for sym in sorted(set(r['sym'] for r in cl+o)):
    c=[r for r in cl if r['sym']==sym]
    print('\n==',sym,'BAND',len(c),'kul %.2f'%sum(r['pr'] for r in c))
    for t in('buy','sell'):
        for lab,f in(('chhoti<=0.10',lambda v:v<=0.1001),('bari>0.10',lambda v:v>0.1001)):
            x=[r for r in c if r['t']==t and f(r['vol'])]
            if x: print(' ',t,lab,len(x),'tk lot %.2f'%sum(r['vol'] for r in x),'P/L %.2f'%sum(r['pr'] for r in x))
    k=[r for r in o if r['sym']==sym]
    print(' KHULI',len(k),'P/L %.2f'%sum(r['pr'] for r in k))
    for r in sorted(k,key=lambda r:-r['op']):
        print('   %s %-4s %5.2f @%-10.3f %10.2f  %s'%(r['id'],r['t'],r['vol'],r['op'],r['pr'],r['ot']))
# daily
d=collections.defaultdict(float)
for r in cl:
    # close time is in rest: rest[0]=closedate? 
    pass
