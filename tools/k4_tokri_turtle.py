#!/usr/bin/env python3
"""K4 (15 Nov 2026) - Tokri (JasTokriEA tk2 ke qaide) + Turtle 55/20 RUKH ka test. Hukm: docs/k4-fable-hukm.md
Nateeja: docs/k4-tokri-turtle.md. Engine: tools/k4_tokri_turtle.c (int hisaab), data: tools/k4_data.py.
Ye sirf user ke tareeqe (METHOD.md / tokri_naqsha Q14-Q22) ka TEST hai - kisi EA mein grid / hedge NAHI daala.

  python3 tools/k4_tokri_turtle.py data          # data ki jaanch (k4_data.py)
  python3 tools/k4_tokri_turtle.py ref 2015      # engine vs Python cent-ba-cent (alag likha) - 1 saal, lot-ba-lot
  python3 tools/k4_tokri_turtle.py sanity        # purana tk2 (4H Supertrend rukh) + purana sim dobara
  python3 tools/k4_tokri_turtle.py chunao        # 324 variant x 2 raasta, SIRF 2009-2017 -> chuna hua variant
  python3 tools/k4_tokri_turtle.py imtihan       # chuna hua EK variant 2018-2026 + tk2-4H + saada Turtle
  python3 tools/k4_tokri_turtle.py jaankari      # baqi variant imtihan mein (sirf jaankari)
  python3 tools/k4_tokri_turtle.py hasas         # kharcha / swap / raasta / 1 din der / waghaira
  python3 tools/k4_tokri_turtle.py waqiat        # 2013, Mar 2020, 2022, 2025-26 + saal-ba-saal lots/din
  python3 tools/k4_tokri_turtle.py log           # 3 basket ka log (jeet, hadd, lamba)

=== QAIDA PEHLE SE (nateeja dekhne se PEHLE likha; badalna MANA) ===
Hukm sec 5 ke 7 PASS shart + ye tafseel jo hukm mein khuli thi (Fable ne CHUNAO chalane se PEHLE tay ki):
 Q-a. Daur: CHUNAO = session din 2009-06-01 (55 din warm-up ke baad) .. 2017 ka aakhri din; IMTIHAN = 2018 ka pehla din ..
      data ka aakhir (5 Nov 2026). Har daur 38,000 USC se, khali tokri se shuru; rukh ka haal pichhle dinon se aata hai.
 Q-b. Har variant DO raaste par chalta hai (M1 ke andar O-H-L-C aur O-L-H-C). Variant ka number = dono mein se BURA:
      nafa = kam wala, girawat = zyada wali, hadd ginti = zyada wali, musbat saal = kam wale.
 Q-c. CHUNAO mein "ahl" variant = nafa > 0, girawat <= 15%, AAKHRI HADD kisi bhi 4 saal (1461 din) ki khirki mein <= 1,
      musbat saal >= 60%. Ahl mein se chuna hua = sab se bara (nafa / girawat). Koi ahl na ho: nafa > 0 walon mein sab se
      bara (nafa / girawat); koi nafa > 0 na ho: sab se kam nuqsan wala - aur K4 = FAIL (shart 2), phir bhi wo EK variant
      IMTIHAN mein EK dafa chalega taake poori tasveer rahe.
 Q-d. PASS (3) "4 saal mein <= 1 dafa" = kisi bhi 1461 din ki khirki mein <= 1 hadd (sakht matlab). (5) saal = session
      saal ka equity farq (khula nuqsan shamil); 2009 aur 2026 adhoore saal bhi gine jate hain.
 Q-e. (6) tk2-4H se "behtar" aur (7) saada se "behtar" = IMTIHAN ka nafa zyada (dono ke apne bure raaste par).
 Q-f. AAKHRI HADD / BARDASHT ki buniyad = shuru equity (EA: g_base yaad rakhta hai, STOP ke baad nahi badalta).
 Q-g. Rukh na ho (variant a-i) aur tokri khali: aakhri band qeemat se Step $ chaal ka intezar, phir chaal ki taraf 0.01
      (tk2 ka apna Step qaida). Variant c2: jab rukh D se hate (khatam ya palte) -> D taraf ki nuqsan wali lots band.
 Q-h. Toot (b): "close" = din ka close pichhle N BAND din ki high/low se bahar; "chhoona" = din ki high/low bahar.
      Dono mein faisla din BAND hone par, rukh AGLE session din ki pehli candle se. Khatam (20 din) bhi usi tarah.
 Q-i. NAYA "?" (engine ki jaanch mein mila, CHUNAO chalane se PEHLE likha): tk2 ke code mein CLOSE ALL sirf KHULI lots
      ke P/L par hai aur har lot ka TP $1 us se pehle lag jata hai -> CLOSE ALL kabhi nahi chalta (jaanch mein 0 dafa).
      K4 ka FAISLA tk2 jaisa hi (khandan F0) par hai. User ki baat (Q14 / Q21 "CLOSE ALL faide mein") ke aur matlab
      ALAG khandan ki tarah, SIRF JAANKARI: F1 = CLOSE ALL jab tokri ka KUL hisaab (khali se ab tak band munafa + khula)
      >= 0.5; F2 = lot ka TP nahi, sirf CLOSE ALL (Q21 lafz-ba-lafz); F3 = ULTA mode (Q20, EA ka input).
      Har khandan par wahi variant + wahi Q-c chunao. F1-F3 ka IMTIHAN sirf tab khulega jab us ka chuna hua variant
      CHUNAO mein "ahl" ho (repo ka sabaq: IMTIHAN chhupa rahe), aur tab bhi EK dafa. F0 ka IMTIHAN har haal EK dafa.
 Q-j. MAIN data = jaisa repo mein hai (koi candle nahi badli); histdata ke mashkook candle (Dukascopy H1 se $2+ bahar)
      kaat kar aur 2015 ko QDM se badal kar sirf "hasas" jaanch.
 Q-k. MAIN kharcha = spread $0.24 (har waqt barabar), swap 0. Candle ke andar waqt = raaste ki doori ke hisaab se
      (EA ka 10 second ka waqfa isi se); C->O chhalang par sab kuch nayi qeemat par (hadd ka poora nuqsan), TP sirf
      TP ki qeemat par (gap ka faida NAHI diya). 4H candle = UTC 0/4/8.. (Exness server UTC+0).
 Q-l. "Bura raasta" sirf hukm wale do (O-H-L-C, O-L-H-C); rang wale do raaste sirf "hasas" mein.
"""
import os
import struct
import subprocess
import sys
import time
from concurrent.futures import ThreadPoolExecutor
from pathlib import Path

import numpy as np
import pandas as pd

sys.path.insert(0, str(Path(__file__).resolve().parent))
import k4_data as KD  # noqa: E402

ROOT = Path(__file__).resolve().parent.parent
CACHE = KD.CACHE
EXE = CACHE / 'k4_engine'
USC = 100                      # cu fi USC
EQ0 = 38_000 * USC
BASE = dict(sp=24, step=200, tp=100, bc=50, maxt=30, uh=2, ul=1, mode=0, neut=1, c2=0, path=0, minsec=10, barsec=60, bmode=0, notp=0)
S_KEYS = ('eq net ddp dd mineq peak nstop lots ntp sumtp nbc sumbc sumstop nc2 sumc2 maxn maxg maxabsn minfl barsmaxt '
          'barsbard blown maxnot minml swaptot fl nend firststop ddt barsin').split()
Y_KEYS = 'year pnl lots stops days maxn tp bc ddp stoploss eq'.split()
H_KEYS = 't loss n G N rk q bal'.split()


# ---------------------------------------------------------------- data + rukh
class Data:
    def __init__(self, src='m1'):
        self.src = src
        d = KD.load_m1() if src == 'm1' else src_frame(src)
        self.t = ((d.t - pd.Timestamp('1970-01-01', tz='UTC')) // pd.Timedelta(seconds=1)).values.astype(np.int64)
        self.o, self.h, self.l, self.c = (d[x].values.astype(np.int32) for x in 'OHLC')
        self.sd = d.sd.values.astype('datetime64[D]')
        self.dy = KD.daily(d)
        self.di = np.searchsorted(self.dy.index.values.astype('datetime64[D]'), self.sd).astype(np.int64)   # har candle ka din number
        self.n = len(d)
        self.bars = CACHE / f'bars_{src}.bin'
        if not self.bars.exists():
            CACHE.mkdir(parents=True, exist_ok=True)
            yr = self.sd.astype('datetime64[Y]').astype(int) + 1970
            dow = ((self.sd.astype(int) + 3) % 7).astype(np.int8)          # 1970-01-01 = Jumerat(3)
            with open(self.bars, 'wb') as f:
                f.write(struct.pack('<q', self.n))
                for a, tp in ((self.t, '<i8'), (self.o, '<i4'), (self.h, '<i4'), (self.l, '<i4'), (self.c, '<i4'),
                              (self.sd.astype(int), '<i4'), (yr, '<i2'), (dow, 'i1')):
                    f.write(np.ascontiguousarray(a, dtype=tp).tobytes())

    def day_i0(self, date):
        """us session din ki pehli candle ka index (date ya us ke baad ka pehla din)."""
        j = int(np.searchsorted(self.dy.index.values, np.datetime64(date)))
        return self.n if j >= len(self.dy) else int(self.dy.i0.iloc[j])

    def span(self, daur):
        warm = int(self.dy.i0.iloc[55])                                 # 55 BAND din ke baad
        if daur == 'chunao':
            return max(warm, self.day_i0('2009-01-01')), self.day_i0('2018-01-01')
        if daur == 'imtihan':
            return self.day_i0('2018-01-01'), self.n
        if daur == 'sab':
            return warm, self.n
        a, b = daur                                                     # (shuru, khatam) tareekh
        return max(warm, self.day_i0(a)), self.day_i0(b)


def src_frame(src):
    """Doosre zariye: 'h1' (Dukascopy H1 2005-08 EXTRA), 'q2015' (2015 = QDM), 'saaf' (bad tick H1 se kaat kar)."""
    if src == 'h1':
        h = KD.load_h1()
        return h[(h.t >= '2004-06-01') & (h.t < '2009-06-01')].reset_index(drop=True)
    d = KD.load_m1().copy()
    if src == 'q2015':
        q = KD._qdm('data/qdm/XAUUSD_M1_2015.zip')
        for c in 'OHLC':
            q[c] = np.round(q[c].values * 100).astype(np.int32)
        q['sd'], q['src'] = KD.session_day(q['t']), 'qdm2015'
        d = pd.concat([d[d.src != 'hist2015'], q], ignore_index=True).sort_values('t').reset_index(drop=True)
        return d
    if src == 'saaf':                                                   # histdata candle jo Dukascopy H1 ki range se $2+ bahar: kaat do
        h1 = KD.load_h1().set_index('t')
        hh = d.t.dt.floor('h')
        hi, lo = h1.H.reindex(hh).values + 200, h1.L.reindex(hh).values - 200
        m = d.src.str.startswith('hist').values & ~np.isnan(hi)
        for c in 'OHLC':
            v = d[c].values.astype(float)
            v[m] = np.minimum(np.maximum(v[m], lo[m]), hi[m])
            d[c] = v.astype(np.int32)
        return d
    raise ValueError(src)


def turtle_states(dy, n_in, n_out, mode):
    """Har BAND din ke baad ka rukh (+1/-1/0). mode 'close' / 'touch'. Sirf pichhle din (shift 1) - lookahead nahi."""
    H, L, C = dy.H.values.astype(float), dy.L.values.astype(float), dy.C.values.astype(float)
    hin = pd.Series(H).rolling(n_in).max().shift(1).values
    lin = pd.Series(L).rolling(n_in).min().shift(1).values
    hout = pd.Series(H).rolling(n_out).max().shift(1).values
    lout = pd.Series(L).rolling(n_out).min().shift(1).values
    st, s, amb = np.zeros(len(dy), np.int8), 0, 0
    for d in range(len(dy)):
        if np.isnan(hin[d]):
            continue
        xu, xd = (C[d], C[d]) if mode == 'close' else (H[d], L[d])
        up, dn = xu > hin[d], xd < lin[d]
        if s == 1 and xd < lout[d]:
            s = 0
        elif s == -1 and xu > hout[d]:
            s = 0
        if s == 0:
            if up and dn:
                amb += 1
            elif up:
                s = 1
            elif dn:
                s = -1
        st[d] = s
    return st, amb


def ffill_nz(st):
    out, s = st.copy(), 0
    for i, v in enumerate(st):
        if v != 0:
            s = v
        out[i] = s
    return out


def st4h_states(D):
    """EA ka Super4H() ain usi tarah: 4H candle (UTC 0/4/8.., Exness server UTC+0), aakhri 400 BAND candle, RMA ATR(10) x3."""
    b = D.t // 14400
    df = pd.DataFrame({'b': b, 'h': D.h, 'l': D.l, 'c': D.c})
    g = df.groupby('b', sort=True)
    bb, h, l, c = g.h.max().index.values, g.h.max().values / 100.0, g.l.min().values / 100.0, g.c.last().values / 100.0
    nb = len(bb)
    res = np.zeros(nb, np.int8)                                # res[j] = Super4H jab aakhri band candle j ho
    W = 400

    def one(lo, hi):                                           # scalar (shuru ke chhote window)
        atr = U = Dn = 0.0
        dr = 1
        for i in range(lo, hi + 1):
            tr = h[i] - l[i]
            if i > lo:
                tr = max(tr, abs(h[i] - c[i - 1]), abs(l[i] - c[i - 1]))
            atr = tr if i == lo else atr + (tr - atr) / 10.0
            hl2 = (h[i] + l[i]) / 2.0
            up, dn = hl2 - 3.0 * atr, hl2 + 3.0 * atr
            if i == lo:
                U, Dn = up, dn
                continue
            pU, pD = U, Dn
            U = max(up, pU) if c[i - 1] > pU else up
            Dn = min(dn, pD) if c[i - 1] < pD else dn
            if dr == -1 and c[i] > pD:
                dr = 1
            elif dr == 1 and c[i] < pU:
                dr = -1
        return dr
    for j in range(49, min(W - 1, nb)):
        res[j] = one(0, j)
    if nb >= W:
        J = np.arange(W - 1, nb)
        lo = J - (W - 1)
        atr = U = Dn = None
        dr = np.ones(len(J), np.int8)
        for s in range(W):
            i = lo + s
            tr = h[i] - l[i]
            if s > 0:
                tr = np.maximum(tr, np.maximum(np.abs(h[i] - c[i - 1]), np.abs(l[i] - c[i - 1])))
            atr = tr.copy() if s == 0 else atr + (tr - atr) / 10.0
            hl2 = (h[i] + l[i]) / 2.0
            up, dn = hl2 - 3.0 * atr, hl2 + 3.0 * atr
            if s == 0:
                U, Dn = up, dn
                continue
            pU, pD = U, Dn
            U = np.where(c[i - 1] > pU, np.maximum(up, pU), up)
            Dn = np.where(c[i - 1] < pD, np.minimum(dn, pD), dn)
            to_up = (dr == -1) & (c[i] > pD)
            to_dn = (dr == 1) & (c[i] < pU)
            dr = np.where(to_up, 1, np.where(to_dn, -1, dr)).astype(np.int8)
        res[J] = dr
    pos = np.searchsorted(bb, b)                               # candle ka 4H number
    return np.where(pos >= 1, res[np.maximum(pos - 1, 0)], 0).astype(np.int8)


def rukh_file(D, name):
    """name: 'T55_20_close' / '..._touch' [+ '_fill'] [+ '_d1'] ya 'ST4H'. Har candle ka rukh (int8) file."""
    f = CACHE / f'rukh_{D.src}_{name}.bin'
    if f.exists():
        return f
    if name == 'ST4H':
        r = st4h_states(D)
    elif name.startswith('GHAIB'):                              # JAAN BOOJH KAR lookahead: sirf tashkhees (cmd_ghaib)
        k = int(name[5:])                                       # is din se k din baad ka close, pichhle close ke muqable
        c = D.dy.C.values.astype(np.int64)
        nd = len(c)
        fut = c[np.minimum(np.arange(nd) + k - 1, nd - 1)]
        st = np.sign(fut - np.r_[c[0], c[:-1]]).astype(np.int8)  # st[d] = din d ka "sahi" rukh
        r = st[D.di].astype(np.int8)
    else:
        p = name.split('_')
        n_in, n_out, mode = int(p[0][1:]), int(p[1]), p[2]
        st, _ = turtle_states(D.dy, n_in, n_out, mode)
        if 'fill' in p:
            st = ffill_nz(st)
        delay = 1 if 'd1' in p else 0
        j = D.di - 1 - delay
        r = np.where(j >= 0, st[np.maximum(j, 0)], 0).astype(np.int8)
    f.write_bytes(r.tobytes())
    return f


# ---------------------------------------------------------------- engine
def build():
    CACHE.mkdir(parents=True, exist_ok=True)
    src = ROOT / 'tools/k4_tokri_turtle.c'
    if not EXE.exists() or EXE.stat().st_mtime < src.stat().st_mtime:
        subprocess.run(['gcc', '-O2', '-o', str(EXE), str(src)], check=True)


def run(D, rukh, daur, eq0=EQ0, **kw):
    """Ek run. Wapas: dict (S ke number + 'Y' list + 'H' list)."""
    i0, i1 = D.span(daur)
    p = dict(BASE)
    p.update(kw)
    p.setdefault('bard', eq0 * 5 // 100)
    p.setdefault('hadd', eq0 * 10 // 100)
    args = [str(EXE), str(D.bars), str(rukh_file(D, rukh)), f'i0={i0}', f'i1={i1}', f'eq0={eq0}'] + [f'{k}={v}' for k, v in p.items()]
    out = subprocess.run(args, capture_output=True, text=True)
    if out.returncode:
        raise RuntimeError(out.stderr)
    r = {'Y': [], 'H': [], 'eq0': eq0, 'ny_total': len(np.unique(D.sd[i0:i1].astype('datetime64[Y]')))}
    for ln in out.stdout.splitlines():
        a = ln.split()
        if a[0] == 'S':
            r.update({k: float(v) if '.' in v else int(v) for k, v in zip(S_KEYS, a[1:])})
        elif a[0] == 'Y':
            r['Y'].append({k: float(v) if '.' in v else int(v) for k, v in zip(Y_KEYS, a[1:])})
        elif a[0] == 'H':
            r['H'].append({k: int(v) for k, v in zip(H_KEYS, a[1:])})
    return r


def window_max(ts, days=1461):
    """kisi bhi `days` din ki khirki mein zyada se zyada kitne waqiat."""
    ts = sorted(ts)
    return max([sum(1 for x in ts if t <= x < t + days * 86400) for t in ts], default=0)


def brief(r):
    yrs = r['Y']
    pos = sum(1 for y in yrs if y['pnl'] > 0)
    ny = r.get('ny_total', len(yrs))                                    # account khatam ke baad ke saal = musbat nahi
    return dict(nafa=r['net'] / r['eq0'] * 100, dd=r['ddp'] * 100, hadd=r['nstop'], hadd4=window_max([h['t'] for h in r['H']]),
                pos=pos, ny=ny, posf=pos / max(ny, 1), lots=r['lots'], blown=r['blown'], mineq=r['mineq'] / r['eq0'] * 100,
                first=r['firststop'], nbc=r['nbc'], ntp=r['ntp'], maxn=r['maxn'])


def worst(rs):
    """Q-b: do raaston mein se bura."""
    b = [brief(r) for r in rs]
    return dict(nafa=min(x['nafa'] for x in b), dd=max(x['dd'] for x in b), hadd=max(x['hadd'] for x in b), hadd4=max(x['hadd4'] for x in b),
                pos=min(x['pos'] for x in b), ny=b[0]['ny'], posf=min(x['posf'] for x in b), lots=max(x['lots'] for x in b),
                blown=max(x['blown'] for x in b), mineq=min(x['mineq'] for x in b),
                first=min([x['first'] for x in b if x['first']], default=0), nbc=max(x['nbc'] for x in b), each=b, raw=rs)


def run2(D, rukh, daur, **kw):
    return worst([run(D, rukh, daur, path=pth, **kw) for pth in (0, 1)])


def fmt(w):
    return (f"nafa {w['nafa']:+7.1f}%  girawat {w['dd']:5.1f}%  hadd {w['hadd']:3d} (4saal mein {w['hadd4']:2d})  "
            f"musbat {w['pos']}/{w['ny']}  lots {w['lots']:7d}" + ('  ACCOUNT KHATAM' if w['blown'] else ''))


# ---------------------------------------------------------------- variants
A = {'i': dict(fill=False, neut=1), 'ii': dict(fill=False, neut=2), 'iii': dict(fill=True, neut=2)}
TURTLES = ((55, 20), (40, 20), (20, 10))
STEPS, TPS = (150, 200, 300), (50, 100, 200)


def variants():
    out = []
    for (ni, no) in TURTLES:
        for a in ('i', 'ii', 'iii'):
            for b in ('close', 'touch'):
                for c2 in (0, 1):
                    for st in STEPS:
                        for tp in TPS:
                            out.append(dict(T=(ni, no), a=a, b=b, c2=c2, step=st, tp=tp))
    return out


def vname(v):
    return f"T{v['T'][0]}/{v['T'][1]} a-{v['a']:3} {v['b']:5} c{v['c2'] + 1} Step${v['step'] / 100:g} TP${v['tp'] / 100:g}"


def vrukh(v, delay=0):
    return f"T{v['T'][0]}_{v['T'][1]}_{v['b']}" + ('_fill' if A[v['a']]['fill'] else '') + ('_d1' if delay else '')


def vkw(v):
    return dict(neut=A[v['a']]['neut'], c2=v['c2'], step=v['step'], tp=v['tp'])


def ahl(w):
    return w['nafa'] > 0 and w['dd'] <= 15 and w['hadd4'] <= 1 and w['posf'] >= 0.6


def chuno(res):
    """Q-c. res = [(variant, worst-dict)]. Wapas (variant, wajah)."""
    ok = [x for x in res if ahl(x[1])]
    if ok:
        return max(ok, key=lambda x: x[1]['nafa'] / max(x[1]['dd'], 1e-9)), 'ahl'
    posi = [x for x in res if x[1]['nafa'] > 0]
    if posi:
        return max(posi, key=lambda x: x[1]['nafa'] / max(x[1]['dd'], 1e-9)), 'koi ahl nahi - nafa>0 mein behtareen'
    return max(res, key=lambda x: x[1]['nafa']), 'koi nafa>0 nahi - sab se kam nuqsan'


# ---------------------------------------------------------------- saada Turtle (tokri ke baghair)
def saada(D, rukh, daur, units=2, sp=24, eq0=EQ0):
    """Sirf Turtle rukh par EK 0.02 lot; rukh khatam (20 din toot) par band. Wapas brief jaisa dict."""
    i0, i1 = D.span(daur)
    r = np.fromfile(rukh_file(D, rukh), dtype=np.int8)[i0:i1]
    o, h, l, c = (x[i0:i1].astype(np.int64) for x in (D.o, D.h, D.l, D.c))
    yr = D.sd[i0:i1].astype('datetime64[Y]').astype(int) + 1970
    n = len(r)
    chg = np.flatnonzero(np.r_[True, r[1:] != r[:-1]])
    ends = np.r_[chg[1:], n]
    bal, ntr = eq0, 0
    lo, hi, cl = np.empty(n), np.empty(n), np.empty(n)
    for a, b in zip(chg, ends):
        d = int(r[a])
        if d == 0:
            lo[a:b] = hi[a:b] = cl[a:b] = bal
            continue
        ent = o[a] + sp if d > 0 else o[a]
        if d > 0:
            lo[a:b], hi[a:b], cl[a:b] = bal + units * (l[a:b] - ent), bal + units * (h[a:b] - ent), bal + units * (c[a:b] - ent)
            ex = o[b] if b < n else c[n - 1]
            bal += units * (ex - ent)
        else:
            lo[a:b], hi[a:b], cl[a:b] = bal + units * (ent - h[a:b] - sp), bal + units * (ent - l[a:b] - sp), bal + units * (ent - c[a:b] - sp)
            ex = o[b] if b < n else c[n - 1]
            bal += units * (ent - ex - sp)
        ntr += 1
    peak = np.maximum.accumulate(np.maximum(hi, eq0))
    dd = float(((peak - lo) / peak).max()) * 100
    ys, prev = [], eq0
    for y in np.unique(yr):
        e = cl[np.flatnonzero(yr == y)[-1]]
        ys.append((int(y), (e - prev) / USC))
        prev = e
    pos = sum(1 for _, v in ys if v > 0)
    return dict(nafa=(cl[-1] - eq0) / eq0 * 100, dd=dd, hadd=0, hadd4=0, pos=pos, ny=len(ys), posf=pos / len(ys), lots=ntr, blown=0,
                mineq=float(lo.min()) / eq0 * 100, Y=ys)


# ---------------------------------------------------------------- Python hawala (cent-ba-cent, alag likha) - jaanch
def ref_run(D, rukh, i0, i1, eq0=EQ0, log=None, **kw):
    """Engine ka alag hisaab: har cent par EA ka Work() lafz-ba-lafz. Sust (1 saal ~ chand minute). Wapas dict."""
    P = dict(BASE)
    P.update(kw)
    SP, STEP, TP, BC, MAXT, UH, UL = P['sp'], P['step'], P['tp'], P['bc'], P['maxt'], P['uh'], P['ul']
    MODE, NEUT, C2, PATH, MINSEC, BARSEC = P['mode'], P['neut'], P['c2'], P['path'], P['minsec'], P['barsec']
    BMODE, NOTP = P['bmode'], P['notp']
    BARD, HADD = P.get('bard', eq0 * 5 // 100), P.get('hadd', eq0 * 10 // 100)
    R = np.fromfile(rukh_file(D, rukh), dtype=np.int8)
    T, O, H, L, C, SD = D.t, D.o, D.h, D.l, D.c, D.sd
    pos = []                                    # [dir, u, open, tp, seq]
    st = dict(bal=eq0, seq=0, rk=0, lastnz=0, halt=False, anc2=0, lastopen=-10**9, peak=eq0, ddp=0.0, mineq=eq0,
              lots=0, ntp=0, nbc=0, nstop=0, sumstop=0, sumtp=0, sumbc=0, nc2=0, sumc2=0, maxn=0, cyc=0)
    out = [] if log else None

    def pl(x, q):
        return x[1] * (q - x[2]) if x[0] > 0 else x[1] * (x[2] - q - SP)

    def net(q):
        return sum(pl(x, q) for x in pos)

    def track(q):
        eq = st['bal'] + net(q)
        if eq > st['peak']:
            st['peak'] = eq
        st['ddp'] = max(st['ddp'], (st['peak'] - eq) / st['peak'])
        st['mineq'] = min(st['mineq'], eq)

    def opn(d, u, q, t):
        st['seq'] += 1
        if not pos:
            st['cyc'] = 0
        op = q + SP if d > 0 else q
        pos.append([d, u, op, op + d * TP, st['seq']])
        st['lastopen'] = t
        st['lots'] += 1
        st['maxn'] = max(st['maxn'], len(pos))
        if out is not None:
            out.append(('O', t, d, u, op, st['seq']))

    def cls(x, v, kind, q, t):
        st['bal'] += v
        st['cyc'] += v
        pos.remove(x)
        if out is not None:
            out.append(('C', t, kind, x[0], x[1], x[2], q, v, x[4]))

    def closeall(q, kind, t):
        s = 0
        for x in list(pos):
            v = pl(x, q)
            s += v
            cls(x, v, kind, q, t)
        st['anc2'] = 2 * q + SP
        return s

    def tick(q, t):
        track(q)
        hit = [] if NOTP else [x for x in pos if (q >= x[3] if x[0] > 0 else q + SP <= x[3])]
        for x in hit:
            v = x[1] * TP
            st['ntp'] += 1
            st['sumtp'] += v
            cls(x, v, 'T', q, t)
        if hit and not pos:
            st['anc2'] = 2 * q + SP
        for _ in range(8):
            n, nt = len(pos), net(q)
            if n > 0 and nt <= -HADD:
                st['sumstop'] += closeall(q, 'H', t)
                st['halt'] = True
                st['nstop'] += 1
                break
            if n >= 2 and nt + (st['cyc'] if BMODE else 0) >= BC:
                st['sumbc'] += closeall(q, 'B', t)
                st['nbc'] += 1
                continue
            if st['halt']:
                break
            rk = st['rk']
            if rk == 0 and NEUT == 2:
                break
            if nt <= -BARD:
                break
            if n >= MAXT:
                break
            if t - st['lastopen'] < MINSEC:
                break
            m2 = 2 * q + SP
            if n == 0:
                if rk != 0:
                    opn(rk, UH, q, t)
                    continue
                d = m2 - st['anc2']
                if abs(d) >= 2 * STEP:
                    dr = 1 if d > 0 else -1
                    opn(-dr if MODE else dr, UL, q, t)
                    continue
                break
            last = max(pos, key=lambda x: x[4])
            mv2 = m2 - 2 * last[2]
            if abs(mv2) < 2 * STEP:
                break
            dr = 1 if mv2 > 0 else -1
            if MODE:
                dr = -dr
            if any(x[0] == dr and abs(m2 - 2 * x[2]) < STEP for x in pos):
                break
            opn(dr, UH if dr == rk else UL, q, t)
        track(q)

    cur_sd = None
    p = 0
    for i in range(i0, i1):
        o, h, l, c, bt = int(O[i]), int(H[i]), int(L[i]), int(C[i]), int(T[i])
        if i == i0:
            cur_sd, st['rk'] = SD[i], int(R[i])
            st['lastnz'], st['anc2'] = st['rk'], 2 * o + SP
        elif SD[i] != cur_sd:
            cur_sd = SD[i]
            if st['halt']:
                st['halt'], st['anc2'] = False, 2 * o + SP
        if int(R[i]) != st['rk']:
            r = int(R[i])
            if C2 and st['lastnz'] != 0 and r != st['lastnz']:
                for x in list(pos):
                    if x[0] == st['lastnz'] and pl(x, o) < 0:
                        v = pl(x, o)
                        st['nc2'] += 1
                        st['sumc2'] += v
                        cls(x, v, 'R', o, bt)
                if not pos:
                    st['anc2'] = 2 * o + SP
            st['rk'] = r
            if r != 0:
                st['lastnz'] = r
        p = o
        tick(p, bt)
        if PATH == 0:
            a, b = h, l
        elif PATH == 1:
            a, b = l, h
        elif PATH == 2:
            a, b = (l, h) if c >= o else (h, l)
        else:
            a, b = (h, l) if c >= o else (l, h)
        total = abs(a - o) + abs(b - a) + abs(c - b)
        k = 0
        for tg in (a, b, c):
            s = 1 if tg > p else -1
            while p != tg:
                p += s
                k += 1
                tick(p, bt + (BARSEC * k) // total)
    fl = net(p)
    st.update(eq=st['bal'] + fl, fl=fl, nend=len(pos))
    st['log'] = out
    return st


def eng_log(path):
    """engine ka log -> hawala jaisi tuple list."""
    out = []
    for ln in open(path):
        a = ln.split()
        if a[0] == 'O':                # O t dir u open bid n basket rk seq
            out.append(('O', int(a[1]), int(a[2]), int(a[3]), int(a[4]), int(a[9])))
        else:                          # C t kind dir u open q pl bal n basket seq swap
            out.append(('C', int(a[1]), a[2], int(a[3]), int(a[4]), int(a[5]), int(a[6]), int(a[7]), int(a[11])))
    return out


def cmd_ref(argv):
    """Engine vs hawala: ek saal (ya tareekh a b), chand variant; har lot barabar honi chahiye."""
    build()
    D = Data()
    if len(argv) >= 2:
        a, b = argv[0], argv[1]
    else:
        y = int(argv[0]) if argv else 2015
        a, b = f'{y}-01-01', f'{y + 1}-01-01'
    i0, i1 = D.span((a, b))
    tests = [('T55_20_close', dict(neut=1, c2=0, path=0)), ('T55_20_touch', dict(neut=2, c2=1, path=1)),
             ('T20_10_close_fill', dict(neut=2, c2=1, path=0, step=150, tp=50)), ('ST4H', dict(path=1, step=300, tp=200)),
             ('T40_20_close', dict(neut=1, c2=0, path=1, mode=1, sp=35)), ('T55_20_close', dict(neut=1, c2=1, path=0, bmode=1)),
             ('T40_20_touch_fill', dict(neut=2, c2=0, path=1, notp=1)), ('T20_10_touch', dict(neut=1, c2=1, path=2, bmode=1, mode=1, minsec=0))]
    if os.environ.get('K4_REF') == 'chuna':                     # chuna hua variant khud, dono raaste
        v = CHUNA['F0']
        tests = [(vrukh(v), dict(vkw(v), path=0)), (vrukh(v), dict(vkw(v), path=1))]
    elif os.environ.get('K4_REF'):
        tests = [tests[int(x)] for x in os.environ['K4_REF'].split(',')]
    ok = True
    for rukh, kw in tests:
        lg = CACHE / f'ref_eng_{os.getpid()}.log'
        t0 = time.time()
        p = dict(BASE)
        p.update(kw)
        args = [str(EXE), str(D.bars), str(rukh_file(D, rukh)), f'i0={i0}', f'i1={i1}', f'eq0={EQ0}', f'bard={EQ0 * 5 // 100}', f'hadd={EQ0 * 10 // 100}',
                f'log={lg}'] + [f'{k}={v}' for k, v in p.items()]
        so = subprocess.run(args, capture_output=True, text=True, check=True).stdout
        e = dict(zip(S_KEYS, [x for x in so.splitlines() if x.startswith('S')][0].split()[1:]))
        t1 = time.time()
        r = ref_run(D, rukh, i0, i1, log=True, **kw)
        t2 = time.time()
        le, lr = sorted(eng_log(lg), key=lambda x: (x[1], x[-1], x[0])), sorted(r['log'], key=lambda x: (x[1], x[-1], x[0]))
        same = le == lr
        nums = (int(e['eq']) == r['eq'] and int(e['lots']) == r['lots'] and int(e['ntp']) == r['ntp'] and int(e['nbc']) == r['nbc']
                and int(e['nstop']) == r['nstop'] and int(e['nc2']) == r['nc2'] and abs(float(e['ddp']) - r['ddp']) < 1e-5 and int(e['mineq']) == r['mineq'])
        ok &= same and nums
        print(f"{a}..{b} {rukh:18} {kw}: engine eq {int(e['eq']) / USC:.2f} lots {e['lots']} tp {e['ntp']} basket {e['nbc']} hadd {e['nstop']} c2 {e['nc2']} dd {float(e['ddp']) * 100:.3f}% "
              f"| hawala eq {r['eq'] / USC:.2f} lots {r['lots']} tp {r['ntp']} basket {r['nbc']} hadd {r['nstop']} c2 {r['nc2']} dd {r['ddp'] * 100:.3f}% "
              f"| log {len(le)}/{len(lr)} line {'BARABAR' if same else 'FARQ'} | number {'BARABAR' if nums else 'FARQ'} | {t1 - t0:.1f}s / {t2 - t1:.0f}s", flush=True)
        if not same:
            for x, y in zip(le, lr):
                if x != y:
                    print('  pehla farq: engine', x, '| hawala', y)
                    break
    print('NATEEJA:', 'engine = hawala (sab barabar)' if ok else 'FARQ HAI - engine par bharosa NAHI')
    return ok


# ---------------------------------------------------------------- chunao / imtihan
FAM = {'F0': ('tk2 jaisa (K4 ka FAISLA)', {}),
       'F1': ('CLOSE ALL = tokri ka kul hisaab (jaankari)', dict(bmode=1)),
       'F2': ('lot ka TP nahi, sirf CLOSE ALL (jaankari)', dict(notp=1)),
       'F3': ('ULTA mode - high SELL / low BUY (jaankari)', dict(mode=1))}


def ts(t):
    return time.strftime('%Y-%m-%d %H:%M', time.gmtime(t)) if t else '-'


def grid(D, fam, daur, vs=None):
    vs = vs or [v for v in variants() if not (fam == 'F2' and v['tp'] != 100)]
    for nm in sorted({vrukh(v) for v in vs}):
        rukh_file(D, nm)
    jobs = [(v, pth) for v in vs for pth in (0, 1)]
    with ThreadPoolExecutor(os.cpu_count()) as ex:
        rs = list(ex.map(lambda j: run(D, vrukh(j[0]), daur, path=j[1], **vkw(j[0]), **FAM[fam][1]), jobs))
    return [(v, worst(rs[2 * i:2 * i + 2])) for i, v in enumerate(vs)]


def table(res, f):
    rows = [dict(T=f"{v['T'][0]}/{v['T'][1]}", a=v['a'], b=v['b'], c=v['c2'] + 1, step=v['step'] / 100, tp=v['tp'] / 100,
                 nafa=round(w['nafa'], 2), girawat=round(w['dd'], 2), hadd=w['hadd'], hadd4=w['hadd4'], musbat=w['pos'], saal=w['ny'],
                 lots=w['lots'], khatam=ts(w['blown']), pehli_hadd=ts(w['first']), closeall=w['nbc'], ahl=int(ahl(w)),
                 nafa_OHLC=round(w['each'][0]['nafa'], 2), nafa_OLHC=round(w['each'][1]['nafa'], 2)) for v, w in res]
    df = pd.DataFrame(rows)
    df.to_csv(f, index=False)
    return df


def cmd_chunao(argv):
    build()
    D = Data()
    fams = argv or ['F0']
    for fam in fams:
        t0 = time.time()
        res = grid(D, fam, 'chunao')
        df = table(res, CACHE / f'chunao_{fam}.csv')
        (v, w), why = chuno(res)
        print(f"\n=== CHUNAO 2009-06..2017 | khandan {fam}: {FAM[fam][0]} | {len(res)} variant x 2 raasta | {time.time() - t0:.0f}s ===")
        print(f"nafa > 0: {(df.nafa > 0).sum()} | ahl (Q-c): {df.ahl.sum()} | account khatam: {(df.khatam != '-').sum()} | "
              f"hadd kabhi nahi: {(df.hadd == 0).sum()} | CLOSE ALL kabhi chala: {(df.closeall > 0).sum()}")
        print(f"nafa %: sab se bura {df.nafa.min():.1f}, darmiyana {df.nafa.median():.1f}, sab se acha {df.nafa.max():.1f} | hadd ginti: kam {df.hadd.min()}, darmiyana {df.hadd.median():.0f}, zyada {df.hadd.max()}")
        for col in ('T', 'a', 'b', 'c', 'step', 'tp'):
            print(f"  {col:4} ke hisaab se darmiyana nafa%: " + '  '.join(f"{k}: {x.nafa.median():+.1f} (hadd {x.hadd.median():.0f})" for k, x in df.groupby(col)))
        print('  behtareen 8 (nafa ke hisaab se):')
        for _, x in df.sort_values('nafa', ascending=False).head(8).iterrows():
            print(f"    T{x['T']} a-{x['a']} {x['b']} c{x['c']} Step${x['step']:g} TP${x['tp']:g}: nafa {x['nafa']:+.1f}% girawat {x['girawat']:.1f}% hadd {x['hadd']} (4saal {x['hadd4']}) musbat {x['musbat']}/{x['saal']} khatam {x['khatam']}")
        print(f"CHUNA HUA ({why}): {vname(v)} -> {fmt(w)}")
        print(f"  dict: {v}")


# CHUNAO ka nateeja (15 Nov 2026, `chunao F0`): 324 mein se 0 variant nafe mein, 0 ahl, 253 account khatam.
# Q-c ke mutabiq "sab se kam nuqsan" wala -> IMTIHAN isi EK par, EK dafa. (K4 = FAIL shart 2 par pehle hi.)
CHUNA = {'F0': {'T': (20, 10), 'a': 'iii', 'b': 'close', 'c2': 1, 'step': 200, 'tp': 200}}


def cmd_imtihan(argv):
    build()
    D = Data()
    v = CHUNA['F0']
    print(f"=== IMTIHAN 2018..5 Nov 2026 - chuna hua EK variant: {vname(v)} ===")
    for daur in ('chunao', 'imtihan'):
        w = run2(D, vrukh(v), daur, **vkw(v))
        k = run2(D, 'ST4H', daur)
        k2 = run2(D, 'ST4H', daur, step=v['step'], tp=v['tp'])
        sd = saada(D, f"T{v['T'][0]}_{v['T'][1]}_{v['b']}", daur)
        s55 = saada(D, 'T55_20_close', daur)
        print(f"\n--- {daur.upper()} ---")
        print(f"tk2-4H (Step$2 TP$1)        : {fmt(k)} | pehli hadd {ts(k['first'])} khatam {ts(k['blown'])}")
        print(f"tk2-4H (chune hue Step/TP)   : {fmt(k2)} | pehli hadd {ts(k2['first'])} khatam {ts(k2['blown'])}")
        print(f"Turtle tokri (chuna hua)     : {fmt(w)} | pehli hadd {ts(w['first'])} khatam {ts(w['blown'])}")
        print(f"   raasta O-H-L-C: {fmt(w['each'][0])}\n   raasta O-L-H-C: {fmt(w['each'][1])}")
        print(f"saada 0.02 (wahi Turtle)     : nafa {sd['nafa']:+7.2f}%  girawat {sd['dd']:5.2f}%  musbat {sd['pos']}/{sd['ny']}  trades {sd['lots']}")
        print(f"saada 0.02 (55/20 close)     : nafa {s55['nafa']:+7.2f}%  girawat {s55['dd']:5.2f}%  musbat {s55['pos']}/{s55['ny']}  trades {s55['lots']}")
        for nm, x in (('tk2-4H', k), ('Turtle tokri', w)):
            for pi, r in enumerate(x['raw']):
                print(f"   {nm} raasta {pi} saal: " + ' '.join(f"{y['year']}:{y['pnl'] / USC:+.0f}({y['stops']}h)" for y in r['Y']))
                print(f"   {nm} raasta {pi} hadd: " + ' '.join(f"{ts(h['t'])[:10]}:{h['loss'] / USC:.0f}" for h in r['H'][:40]))
        print('   saada saal: ' + ' '.join(f"{y}:{p:+.0f}" for y, p in sd['Y']))


# ---------------------------------------------------------------- sanity / hasas / waqiat / log
def cmd_sanity(argv):
    """Bachao 5: purana nateeja dobara. (1) purana sim jaisa tha; (2) naya engine tk2 = 4H Supertrend rukh."""
    build()
    out = subprocess.run([sys.executable, str(ROOT / 'tools/tokri_asli.py')], capture_output=True, text=True).stdout
    rows = [ln.split('|')[1].split() for ln in out.splitlines() if '|' in ln and not ln.startswith('mode')]
    blown = sum(1 for r in rows if int(r[6]) != 0)
    print(f"purana sim (tools/tokri_asli.py, H1 2005-26, $1000): {len(rows)} variant, account khatam {blown} | 44vi chat ka nateeja: 240/240")
    D = Data()
    for nm, kw in (('38,000 USC', {}), ('100,000 USC', dict(eq0=100_000 * USC))):
        w = run2(D, 'ST4H', 'chunao', **kw)
        print(f"naya engine tk2 (4H Supertrend, Step$2 TP$1) CHUNAO 2009-17, {nm}: {fmt(w)} | pehli hadd {ts(w['first'])} khatam {ts(w['blown'])} | CLOSE ALL {w['nbc']} dafa")
    H = Data('h1')
    v = CHUNA['F0']
    for nm, rk, kw in (('tk2 4H Supertrend', 'ST4H', {}), ('Turtle 55/20 close a-i', 'T55_20_close', {}), ('chuna hua ' + vname(v), vrukh(v), vkw(v))):
        w = worst([run(H, rk, ('2005-01-01', '2009-01-01'), path=pth, barsec=3600, **kw) for pth in (0, 1)])
        print(f"EXTRA H1 2005-2008 (kaccha - H1 ke andar raasta andaza) {nm}: {fmt(w)} | pehli hadd {ts(w['first'])} khatam {ts(w['blown'])}")


def cmd_hasas(argv):
    """Chune hue variant par: kharcha, swap, raasta, 1 din der, 10 sec, data, shuru equity, chhoti hadd."""
    build()
    D = Data()
    v = CHUNA['F0']
    rk, kw = vrukh(v), vkw(v)
    tests = [('MAIN (bura raasta)', D, rk, {}),
             ('spread $0.35', D, rk, dict(sp=35)),
             ('swap tester jaisa (BUY -0.51 USC/0.01/raat, Budh 3x)', D, rk, dict(swapl=51)),
             ('rukh 1 din aur der se (lookahead jaanch)', D, vrukh(v, 1), {}),
             ('10 second waqfa 0', D, rk, dict(minsec=0)),
             ('10 second waqfa 60', D, rk, dict(minsec=60)),
             ('shuru 100,000 USC (hadd 10,000)', D, rk, dict(eq0=100_000 * USC)),
             ('hadd ke baad hamesha STOP (pehli hadd tak)', D, rk, dict(restart=0)),
             ('CHHOTA: bhari lot bhi 0.01', D, rk, dict(uh=1)),
             ('CHHOTA: max 10 lots', D, rk, dict(maxt=10)),
             ('CHHOTA: hadd 5% / bardasht 2.5%', D, rk, dict(hadd=EQ0 * 5 // 100, bard=EQ0 * 25 // 1000))]
    for daur in ('chunao', 'imtihan'):
        print(f"\n--- {daur.upper()} : {vname(v)} ---")
        for nm, d, r, extra in tests:
            k = dict(kw)
            k.update(extra)
            w = run2(d, r, daur, **k)
            print(f"{nm:52}: {fmt(w)} | pehli hadd {ts(w['first'])[:10]} khatam {ts(w['blown'])[:10]}")
        for pth, nm in ((0, 'O-H-L-C'), (1, 'O-L-H-C'), (2, 'rang (sabz O-L-H-C / laal O-H-L-C)'), (3, 'ulta rang')):
            print(f"raasta {nm:44}: {fmt(brief(run(D, rk, daur, path=pth, **kw)))}")
    for src, nm in (('saaf', 'histdata ke mashkook candle kaat kar'), ('q2015', '2015 = QDM (Dukascopy)')):
        d2 = Data(src)
        print(f"data {nm:47}: {fmt(run2(d2, rk, 'chunao', **kw))}  (CHUNAO)")


WAQIAT = [('2013 crash (Apr-Jun 2013)', '2013-04-01', '2013-07-01'), ('Mar 2020 (Feb-Apr 2020)', '2020-02-15', '2020-04-15'),
          ('2022 (poora saal)', '2022-01-01', '2023-01-01'), ('2025 (poora saal)', '2025-01-01', '2026-01-01'),
          ('2026 (Jan - 5 Nov)', '2026-01-01', '2027-01-01')]


def cmd_waqiat(argv):
    """Bachao 9 + 10: har bara waqia ALAG run (naya 38,000, khali tokri), aur har saal alag (lots/din)."""
    build()
    D = Data()
    v = CHUNA['F0']
    rk, kw = vrukh(v), vkw(v)
    base = f"T{v['T'][0]}_{v['T'][1]}_{v['b']}"
    R = np.fromfile(rukh_file(D, base), dtype=np.int8)
    print(f"=== BARE WAQIAT (har ek alag run, 38,000 USC se) : {vname(v)} ===")
    for nm, a, b in WAQIAT:
        i0, i1 = D.span((a, b))
        px = f"gold {D.o[i0] / 100:.0f} -> {D.c[i1 - 1] / 100:.0f} (kam {D.l[i0:i1].min() / 100:.0f}, zyada {D.h[i0:i1].max() / 100:.0f})"
        days = np.unique(D.di[i0:i1])
        rd = R[D.dy.i0.values[days]]
        print(f"\n{nm}: {px} | Turtle rukh din: UP {(rd == 1).sum()} DOWN {(rd == -1).sum()} koi nahi {(rd == 0).sum()}")
        w = run2(D, rk, (a, b), **kw)
        k = run2(D, 'ST4H', (a, b))
        sd = saada(D, base, (a, b))
        print(f"   Turtle tokri : {fmt(w)} | pehli hadd {ts(w['first'])[:10]}")
        print(f"   tk2-4H       : {fmt(k)} | pehli hadd {ts(k['first'])[:10]}")
        print(f"   saada 0.02   : nafa {sd['nafa']:+7.2f}%  girawat {sd['dd']:5.2f}%  trades {sd['lots']}")
    print("\n=== SAAL-BA-SAAL ALAG (har saal naya 38,000, khali tokri) + fixed Step ka asar (bachao 10) ===")
    print('saal | gold close | din range $ | Turtle tokri: nafa% hadd lots/din zyada-lots | tk2-4H: nafa% hadd lots/din | saada nafa%')
    for y in range(2009, 2027):
        a, b = f'{y}-01-01', f'{y + 1}-01-01'
        i0, i1 = D.span((a, b))
        if i1 <= i0:
            continue
        days = np.unique(D.di[i0:i1])
        dr = ((D.dy.H - D.dy.L).values[days] / 100).mean()
        w = run2(D, rk, (a, b), **kw)
        k = run2(D, 'ST4H', (a, b))
        sd = saada(D, base, (a, b))
        mx = max(r['maxn'] for r in w['raw'])
        print(f"{y} | {D.c[i1 - 1] / 100:7.0f} | {dr:6.1f} | {w['nafa']:+7.1f}% {w['hadd']:3d} {w['lots'] / len(days):6.1f} {mx:3d} | {k['nafa']:+7.1f}% {k['hadd']:3d} {k['lots'] / len(days):6.1f} | {sd['nafa']:+6.2f}%")


def cmd_jaankari(argv):
    """Baqi F0 variant IMTIHAN mein - SIRF JAANKARI (chunao isi se nahi hua; hukm sec 5)."""
    build()
    D = Data()
    t0 = time.time()
    res = grid(D, 'F0', 'imtihan')
    df = table(res, CACHE / 'imtihan_jaankari_F0.csv')
    print(f"=== IMTIHAN 2018..2026 | F0 ke sab {len(res)} variant - SIRF JAANKARI | {time.time() - t0:.0f}s ===")
    print(f"nafa > 0: {(df.nafa > 0).sum()} | ahl jaisa (4 shart): {df.ahl.sum()} | account khatam: {(df.khatam != '-').sum()} | hadd kabhi nahi: {(df.hadd == 0).sum()}")
    print(f"nafa %: sab se bura {df.nafa.min():.1f}, darmiyana {df.nafa.median():.1f}, sab se acha {df.nafa.max():.1f} | hadd ginti: kam {df.hadd.min()}, darmiyana {df.hadd.median():.0f}, zyada {df.hadd.max()}")
    for _, x in df.sort_values('nafa', ascending=False).head(5).iterrows():
        print(f"    T{x['T']} a-{x['a']} {x['b']} c{x['c']} Step${x['step']:g} TP${x['tp']:g}: nafa {x['nafa']:+.1f}% girawat {x['girawat']:.1f}% hadd {x['hadd']} musbat {x['musbat']}/{x['saal']} khatam {x['khatam']}")


def cmd_tashreeh(argv):
    """Paisa kahan se aaya / kahan gaya: TP ki kamai vs AAKHRI HADD, lots ka jamna, margin (bachao 8)."""
    build()
    D = Data()
    v = CHUNA['F0']
    for daur in ('chunao', 'imtihan'):
        print(f"\n--- {daur.upper()} ---")
        for nm, rk, kw in (('Turtle tokri (chuna hua)', vrukh(v), vkw(v)), ('tk2-4H (Step$2 TP$1)', 'ST4H', {})):
            for pth in (0, 1):
                r = run(D, rk, daur, path=pth, **kw)
                u = lambda x: x / USC
                print(f"{nm} raasta {pth}: lots {r['lots']} | TP {r['ntp']} dafa = {u(r['sumtp']):+.0f} USC | AAKHRI HADD {r['nstop']} dafa = {u(r['sumstop']):+.0f} USC | "
                      f"CLOSE ALL {r['nbc']} dafa = {u(r['sumbc']):+.0f} | rukh palte par band (c2) {r['nc2']} lots = {u(r['sumc2']):+.0f} | aakhir mein khula {u(r['fl']):+.0f} ({r['nend']} lots) | kul {u(r['net']):+.0f} USC")
                print(f"      waqt: {r['barsmaxt'] / r['barsin'] * 100:.0f}% candle par 30 lots poori, {r['barsbard'] / r['barsin'] * 100:.0f}% par BARDASHT (nayi lot band) | zyada se zyada {r['maxn']} lots, {r['maxg'] / 100:.2f} lot kul, net {r['maxabsn'] / 100:.2f} lot | "
                      f"sab se bura khula {u(r['minfl']):.0f} USC | margin 1:200 par zyada se zyada {u(r['maxnot']) / 200:.0f} USC, kam se kam margin level {r['minml'] * 100:.0f}%")


def cmd_ghaib(argv):
    """TASHKHEES (K4 ka faisla NAHI): rukh agar GHAIB se bilkul sahi ho (aaj ka / agle 5 / 20 din ka rukh pehle se pata)
    to tk2 tokri bachti hai? Ye kisi bhi rukh-ishare ki OOPARI HADD hai - asal mein mumkin nahi."""
    build()
    D = Data()
    v = CHUNA['F0']
    for daur in ('chunao', 'imtihan'):
        print(f"\n--- {daur.upper()} : rukh GHAIB se (lookahead jaan boojh kar) ---")
        for k, nm in ((1, 'aaj ka din kis taraf band hoga'), (5, 'agle 5 din kis taraf'), (20, 'agle 20 din kis taraf')):
            for lab, kw in (('tk2 Step$2 TP$1', {}), ('Step$2 TP$2 + c2', dict(step=v['step'], tp=v['tp'], c2=1))):
                w = run2(D, f'GHAIB{k}', daur, **kw)
                print(f"ghaib: {nm:32} | {lab:18}: {fmt(w)} | pehli hadd {ts(w['first'])[:10]} khatam {ts(w['blown'])[:10]}")
            sd = saada(D, f'GHAIB{k}', daur)
            print(f"ghaib: {nm:32} | saada 0.02 lot     : nafa {sd['nafa']:+7.1f}%  girawat {sd['dd']:5.1f}%  trades {sd['lots']}")


def baskets(path):
    """engine log -> {basket: [events]}"""
    bk = {}
    for ln in open(path):
        a = ln.split()
        if a[0] == 'O':
            e = dict(k='O', t=int(a[1]), dir=int(a[2]), u=int(a[3]), open=int(a[4]), bid=int(a[5]), n=int(a[6]), bk=int(a[7]), rk=int(a[8]), seq=int(a[9]))
        else:
            e = dict(k='C', t=int(a[1]), kind=a[2], dir=int(a[3]), u=int(a[4]), open=int(a[5]), bid=int(a[6]), pl=int(a[7]), bal=int(a[8]), n=int(a[9]), bk=int(a[10]), seq=int(a[11]))
        bk.setdefault(e['bk'], []).append(e)
    return bk


def cmd_log(argv):
    """Bachao 6: 3 basket ka poora log (ek jeet, ek hadd, ek lamba) + haath ka hisaab (engine se alag)."""
    build()
    D = Data()
    v = CHUNA['F0']
    daur = argv[0] if argv else 'chunao'
    i0, i1 = D.span(daur)
    lg = CACHE / 'k4_log.txt'
    p = dict(BASE)
    p.update(vkw(v))
    subprocess.run([str(EXE), str(D.bars), str(rukh_file(D, vrukh(v))), f'i0={i0}', f'i1={i1}', f'eq0={EQ0}', f'bard={EQ0 * 5 // 100}',
                    f'hadd={EQ0 * 10 // 100}', f'log={lg}'] + [f'{k}={x}' for k, x in p.items()], capture_output=True, text=True, check=True)
    bk = baskets(lg)
    info = []
    for b, ev in bk.items():
        cl = [e for e in ev if e['k'] == 'C']
        op = [e for e in ev if e['k'] == 'O']
        if len(cl) != len(op):
            continue                                            # daur ke aakhir mein khuli reh gayi
        info.append(dict(b=b, n=len(op), pl=sum(e['pl'] for e in cl), dur=ev[-1]['t'] - ev[0]['t'], hadd=any(e['kind'] == 'H' for e in cl),
                         ca=any(e['kind'] == 'B' for e in cl)))
    df = pd.DataFrame(info)
    print(f"{vname(v)} | {daur}: tokri (khali se khali tak) {len(df)}; jeet {(df.pl > 0).sum()}, haar {(df.pl <= 0).sum()}, hadd par khatam {df.hadd.sum()}, CLOSE ALL se {df.ca.sum()}")
    print(f"lots fi tokri: darmiyana {df.n.median():.0f}, 90% {df.n.quantile(.9):.0f}, zyada {df.n.max()} | muddat ghante: darmiyana {df.dur.median() / 3600:.2f}, zyada {df.dur.max() / 3600:.0f}")
    print(f"kul P/L jeet wali {df.pl[df.pl > 0].sum() / USC:+.0f} USC, haar wali {df.pl[df.pl <= 0].sum() / USC:+.0f} USC")
    win = df[(df.pl > 0) & (df.n >= 4) & (df.n <= 8) & ~df.hadd]
    pick = [('JEET (chhoti tokri)', int(win.iloc[len(win) // 2].b) if len(win) else int(df[df.pl > 0].iloc[0].b))]
    if df.hadd.any():
        hd = df[df.hadd]
        pick.append(('AAKHRI HADD', int(hd.sort_values('n').iloc[0].b)))
    pick.append(('LAMBI (sab se zyada waqt, hadd ke baghair)', int(df[~df.hadd].sort_values('dur').iloc[-1].b)))
    tix = pd.Index(D.t)
    for nm, b in pick:
        ev = bk[b]
        print(f"\n--- {nm}: tokri #{b}, {len([e for e in ev if e['k'] == 'O'])} lots, {ts(ev[0]['t'])} -> {ts(ev[-1]['t'])} UTC ---")
        opens = {e['seq']: e for e in ev if e['k'] == 'O'}
        tot, bad, shown = 0, 0, 0
        for e in ev:
            j = int(np.searchsorted(D.t, e['t'], side='right')) - 1          # us waqt ki M1 candle
            inbar = (D.l[j] <= e['bid'] <= D.h[j]) or e['bid'] == D.o[j] or (e['k'] == 'C' and e['kind'] == 'T')
            if e['k'] == 'C':
                o = opens[e['seq']]
                # haath ka hisaab: BUY = (band bid - khuli ask) x unit ; SELL = (khuli bid - band ask) x unit ; TP = TP qeemat par
                cp = (o['open'] + o['dir'] * p['tp']) if e['kind'] == 'T' else (e['bid'] if o['dir'] > 0 else e['bid'] + p['sp'])
                hand = o['u'] * (cp - o['open']) * o['dir']
                tot += e['pl']
                bad += (hand != e['pl']) or not inbar
            if shown < 60 or e is ev[-1]:
                shown += 1
                side = 'BUY ' if e['dir'] > 0 else 'SELL'
                if e['k'] == 'O':
                    print(f"  {ts(e['t'])[5:]} KHULI {side} {e['u'] / 100:.2f} @ {e['open'] / 100:.2f} (bid {e['bid'] / 100:.2f}) rukh {e['rk']:+d} khuli lots {e['n']}")
                else:
                    kind = {'T': 'TP', 'B': 'CLOSE ALL', 'H': 'AAKHRI HADD', 'R': 'rukh palta (c2)'}[e['kind']]
                    print(f"  {ts(e['t'])[5:]} BAND  {side} {e['u'] / 100:.2f} khuli {e['open'] / 100:.2f} -> {cp / 100:.2f} = {e['pl'] / USC:+.2f} USC ({kind}) balance {e['bal'] / USC:.2f}")
            elif shown == 60:
                shown += 1
                print(f"  ... ({len(ev) - 61} aur line) ...")
        print(f"  tokri ka kul = {tot / USC:+.2f} USC | haath ke hisaab se farq / candle se bahar: {bad} line")


if __name__ == '__main__':
    cmd = sys.argv[1] if len(sys.argv) > 1 else ''
    if cmd == 'data':
        KD.jaanch()
    elif cmd == 'ref':
        sys.exit(0 if cmd_ref(sys.argv[2:]) else 1)
    elif cmd == 'chunao':
        cmd_chunao(sys.argv[2:])
    elif cmd == 'imtihan':
        cmd_imtihan(sys.argv[2:])
    elif cmd in ('sanity', 'hasas', 'waqiat', 'log', 'jaankari', 'tashreeh', 'ghaib'):
        globals()['cmd_' + cmd](sys.argv[2:])
    else:
        print(__doc__)
