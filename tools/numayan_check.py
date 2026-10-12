"""JAS Numayan Ginti (indicators/jas_numayan_ginti.pine) ka Python port.

User ki shakal: upar numayan HARI candle (U) -> qeemat U ke neeche -> neeche
har numayan LAAL candle = ISHARA -> kya qeemat palat kar U ka high paar
karti hai? Ulta bhi (neeche numayan laal D -> upar har numayan hari -> D ka
low). Daud: U.high (upar) pehle ya utna hi faasla neeche (close - d) pehle,
agle N (40) din mein. Aam din = wohi haalat (U ke neeche, U zinda) magar aaj
numayan laal nahi. FARK = ishara % - aam % (faasla tokri ke hisaab se).

Random qeemat (koi edge nahi, vol clustering ke saath) par FARK ~0 aana
chahiye - warna code mein aage dekhne wali ya jhuki hui ghalti. Lagaya hua
edge (ishara ke baad halka upar dhakka) par FARK musbat aana chahiye - warna
test andha. Ishara ki ginti ka andaza bhi (gold 1D 2000 se ~6700 din).
Pine badle to ye bhi. `python3 tools/numayan_check.py`
"""
import math
import random

K_BODY = 1.0
MAX_AGE = 60
N = 40


def bucket(d):
    if d is None:
        return -1
    return 0 if d < 2 else 1 if d < 3 else 2 if d < 4 else 3 if d < 6 else 4


class Sig:
    """Ek ek din aage chalne wala engine (Pine jaisa: pehle parho, phir haalat)."""

    def __init__(self):
        self.t = -1
        self.pc = None
        self.atr = None
        self.trs = []
        self.uHi = self.uLo = self.uBar = None
        self.dHi = self.dLo = self.dBar = None

    def step(self, o, h, l, c):
        self.t += 1
        t = self.t
        tr = h - l if self.pc is None else max(h - l, abs(h - self.pc), abs(l - self.pc))
        a1 = self.atr
        if self.atr is None:
            self.trs.append(tr)
            if len(self.trs) == 14:
                self.atr = sum(self.trs) / 14
        else:
            self.atr = (self.atr * 13 + tr) / 14
        self.pc = c
        at = self.atr
        body = abs(c - o)
        bigG = a1 is not None and c > o and body >= K_BODY * a1
        bigR = a1 is not None and c < o and body >= K_BODY * a1
        res = []
        # --- upar wapsi (U = pichli numayan hari) ---
        okU = self.uHi is not None and t - self.uBar <= MAX_AGE and h < self.uHi
        belowU = okU and c < self.uLo and at is not None and at > 0
        if belowU:
            d = (self.uHi - c) / at
            kind = 'E' if bigR else 'A'
            res.append(('U', kind, self.uHi, c - (self.uHi - c), d))
        # --- neeche wapsi (D = pichli numayan laal) ---
        okD = self.dLo is not None and t - self.dBar <= MAX_AGE and l > self.dLo
        aboveD = okD and c > self.dHi and at is not None and at > 0
        if aboveD:
            d = (c - self.dLo) / at
            kind = 'E' if bigG else 'A'
            res.append(('D', kind, c + (c - self.dLo), self.dLo, d))
        # --- haalat ka update (parhne ke baad) ---
        if self.uHi is not None and (t - self.uBar > MAX_AGE or h >= self.uHi):
            self.uHi = None
        if bigG:
            self.uHi, self.uLo, self.uBar = h, l, t
        if self.dLo is not None and (t - self.dBar > MAX_AGE or l <= self.dLo):
            self.dLo = None
        if bigR:
            self.dHi, self.dLo, self.dBar = h, l, t
        return res


def signals(o, h, l, c):
    """Har din: list of (side, kind, up_level, dn_level, dist) - kind 'E'
    ishara, 'A' aam. side 'U' = upar wapsi, 'D' = neeche wapsi."""
    g = Sig()
    return [g.step(o[t], h[t], l[t], c[t]) for t in range(len(c))]


def race(h, l, t, side, up, dn, n=None):
    """t ke baad n din ki daud. 1 = ishare ki taraf wala level pehle (U: up,
    D: dn), 0 = ulta level pehle, None = koi nahi. Ek hi din dono chhuye =
    0 (ishare ke khilaf - mohtaat), dono taraf barabar."""
    n = N if n is None else n
    for k in range(t + 1, min(t + n + 1, len(h))):
        hu = h[k] >= up
        hd = l[k] <= dn
        if side == 'U':
            if hd:
                return 0
            if hu:
                return 1
        else:
            if hu:
                return 0
            if hd:
                return 1
    return None


def tally(o, h, l, c, start=0):
    rows = signals(o, h, l, c)
    # cnt[side][kind][bucket] = [up, resolved]
    cnt = {s: {k: [[0, 0] for _ in range(5)] for k in 'EA'} for s in 'UD'}
    un = {'E': 0, 'A': 0}
    for t in range(start, len(c) - N):
        for side, kind, up, dn, d in rows[t]:
            win = race(h, l, t, side, up, dn)
            if win is None:
                un[kind] += 1
                continue
            b = bucket(d)
            cnt[side][kind][b][0] += win
            cnt[side][kind][b][1] += 1
    return cnt, un


def fark(cnt, sides='UD'):
    sw = sd = sv = 0.0
    for b in range(5):
        e1 = sum(cnt[s]['E'][b][0] for s in sides)
        n1 = sum(cnt[s]['E'][b][1] for s in sides)
        e0 = sum(cnt[s]['A'][b][0] for s in sides)
        n0 = sum(cnt[s]['A'][b][1] for s in sides)
        if n1 == 0 or n0 == 0:
            continue
        q1, q0 = e1 / n1, e0 / n0
        fk = 100 * (q1 - q0)
        sw += n1
        sd += n1 * fk
        sv += n1 * n1 * (q1 * (1 - q1) / n1 + q0 * (1 - q0) / n0) * 10000
    if sw == 0:
        return 0, None, None
    return sw, sd / sw, 2 * math.sqrt(sv) / sw


def make_series(n, seed, edge=0.0, steps=12):
    """Random qeemat, GARCH jaisi vol (bare din ke baad bari harkat), drift 0.
    edge > 0: ishara din ke baad 10 din halka dhakka ishare ki taraf."""
    rnd = random.Random(seed)
    o, h, l, c = [], [], [], []
    p = 1000.0
    var = 1.0
    push = [0.0] * (n + 30)
    g = Sig()
    for t in range(n):
        sig = math.sqrt(var) * 0.01 * p
        op = p
        hi = lo = p
        x = p
        for _ in range(steps):
            x += rnd.gauss(push[t] * sig / steps, sig / math.sqrt(steps))
            hi, lo = max(hi, x), min(lo, x)
        r = (x - op) / max(sig, 1e-9)
        var = 0.05 + 0.90 * var + 0.05 * r * r
        o.append(op); h.append(hi); l.append(lo); c.append(x)
        p = x
        rows = g.step(op, hi, lo, x)
        if edge:
            for side, kind, *_ in rows:
                if kind == 'E':
                    for k in range(t + 1, t + 11):
                        push[k] += edge if side == 'U' else -edge
    return o, h, l, c


def report(tag, cnt, un):
    nE, fE, sE = fark(cnt)
    nU, fU, sU = fark(cnt, 'U')
    nD, fD, sD = fark(cnt, 'D')
    s = lambda f, se: '-' if se is None else f'{f:+.1f}% ±{se:.1f}'
    print(f'{tag}: ishara {int(nE)} (upar {int(nU)}, neeche {int(nD)}), '
          f'FARK {s(fE, sE)} | upar {s(fU, sU)} | neeche {s(fD, sD)} | '
          f'bina faisla ishara {un["E"]} aam {un["A"]}')
    return nE, fE, sE


def main():
    # 1) Random (edge 0): 20 alag series, gold jitni lambi
    tot = {s: {k: [[0, 0] for _ in range(5)] for k in 'EA'} for s in 'UD'}
    tun = {'E': 0, 'A': 0}
    per = []
    for seed in range(20):
        o, h, l, c = make_series(6700, seed)
        cnt, un = tally(o, h, l, c, start=100)
        n1, f1, s1 = fark(cnt)
        per.append(n1)
        for s_ in 'UD':
            for k in 'EA':
                for b in range(5):
                    for i in range(2):
                        tot[s_][k][b][i] += cnt[s_][k][b][i]
        for k in 'EA':
            tun[k] += un[k]
    print(f'Ek series (6700 din) mein ishara: kam {min(per):.0f} / '
          f'ausat {sum(per)/len(per):.0f} / zyada {max(per):.0f}')
    n, f, se = report('RANDOM x20 mila', tot, tun)
    ok_null = abs(f) <= max(se, 1.0) * 1.5
    print('  ->', 'THEEK: random par FARK ~0' if ok_null else 'GHALTI: random par FARK door')
    # 2) Lagaya hua edge: test ko pakarna chahiye
    tot2 = {s: {k: [[0, 0] for _ in range(5)] for k in 'EA'} for s in 'UD'}
    tun2 = {'E': 0, 'A': 0}
    for seed in range(100, 106):
        o, h, l, c = make_series(6700, seed, edge=0.15)
        cnt, un = tally(o, h, l, c, start=100)
        for s_ in 'UD':
            for k in 'EA':
                for b in range(5):
                    for i in range(2):
                        tot2[s_][k][b][i] += cnt[s_][k][b][i]
        for k in 'EA':
            tun2[k] += un[k]
    n2, f2, se2 = report('EDGE 0.15 x6 mila', tot2, tun2)
    ok_edge = f2 - se2 > 0
    print('  ->', 'THEEK: lagaya edge pakra gaya' if ok_edge else 'GHALTI: edge nahi pakra')
    # 3) Ishara ke baad level kabhi ishara wale din se pehle ka nahi (aage dekhna nahi)
    o, h, l, c = make_series(3000, 7)
    rows = signals(o, h, l, c)
    for t, rs in enumerate(rows):
        for side, kind, up, dn, d in rs:
            assert d > 0
            assert (up > c[t] > dn), (t, side, up, c[t], dn)
    print('THEEK: har ishara/aam din par neeche-level < close < upar-level')
    return 0 if (ok_null and ok_edge) else 1


if __name__ == '__main__':
    raise SystemExit(main())
