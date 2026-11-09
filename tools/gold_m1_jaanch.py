# gold_m1_jaanch.py (g1, 9 Nov 2026) - QDM XAUUSD M1 zip jaanch: rows, range, ghalat bar, gap, timezone (Sunday khulna)
import zipfile, io, csv, sys, datetime as dt, collections
def check(p):
    z = zipfile.ZipFile(p); f = z.open(z.namelist()[0])
    r = csv.reader(io.TextIOWrapper(f)); next(r)
    prev = None; n = bad = dup = 0; gaps = []; sun = collections.Counter(); first = None
    zerovol = 0
    for row in r:
        t = dt.datetime.strptime(row[0]+row[1], "%Y%m%d%H:%M:%S")
        o,h,l,c = map(float,row[2:6]); v = float(row[6]); n += 1
        if first is None: first = t
        if not (l <= min(o,c) and h >= max(o,c) and l > 0): bad += 1
        if v == 0: zerovol += 1
        if prev:
            d = (t-prev).total_seconds()/60
            if d <= 0: dup += 1
            elif d > 90:
                gaps.append((d, prev, t))
                if t.weekday() == 6: sun[t.hour] += 1
        prev = t; pc = c
    wk = [g for g in gaps if g[1].weekday()==4 and g[2].weekday()==6]
    other = sorted([g for g in gaps if g not in wk], reverse=True)
    print(f"{p.split('/')[-1]}: {n} bar, {first} -> {prev}, ghalat OHLC {bad}, dup/ulta {dup}, vol=0 {zerovol}")
    print(f"  weekend gap {len(wk)}, Sunday khulne ka ghanta (UTC?) {dict(sun)}")
    print(f"  baqi gap >90 min: {len(other)}; sab se bare 6:")
    for d,a,b in other[:6]: print(f"    {d/60:.1f}h  {a} -> {b}")
for p in sys.argv[1:]: check(p)
