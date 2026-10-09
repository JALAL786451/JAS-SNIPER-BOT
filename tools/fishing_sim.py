"""JasFishingEA f1 ke qaide (F1-F6) nakli gold qeemat par - offline jaanch.

Maqsad: (1) qaide kahin atak / bhaag to nahi jate, (2) kitab kitni barhti
hai, (3) seedhi bekhabar (random) qeemat par nateeja kya hota hai. Asal
jawab sirf MT5 Strategy Tester (asli qeemat) aur demo dega - ye sirf
mantiq ki jaanch hai. Rukh ka filter yahan band hai (random qeemat mein
rukh hota hi nahi).

    python3 tools/fishing_sim.py
"""
import math
import random

DIR, TP1, TPB, HEDGE, CLOSEALL, MAXPOS, SPREAD = 1.5, 1.0, 5.0, 3.5, 1.0, 20, 0.25


def run(seed, days=20, vol_day=45.0):
    rnd = random.Random(seed)
    steps = days * 1440 * 6                       # har 10 second
    sd = vol_day / math.sqrt(1440 * 6)
    mid = 4000.0
    lots = []                                     # (dir, open)
    ref, real, cyc_real = mid, 0.0, 0.0
    n = dict(f1=0, f2=0, f3=0, f4=0, f5=0, f6=0)
    maxpos = 0
    for _ in range(steps):
        mid += rnd.gauss(0, sd)
        bid, ask = mid - SPREAD / 2, mid + SPREAD / 2
        pp = [(bid - o) if d == 1 else (o - ask) for d, o in lots]
        net = sum(d for d, _ in lots)
        flo = sum(pp)
        maxpos = max(maxpos, len(lots))

        def close(i):
            nonlocal real, cyc_real
            real += pp[i]
            cyc_real += pp[i]
            lots.pop(i)

        def open_(d):
            lots.append((d, ask if d == 1 else bid))

        if len(lots) >= 2 and cyc_real + flo >= CLOSEALL:           # F6
            real += flo
            lots.clear()
            n["f6"] += 1
            ref = mid
            continue
        if net != 0:
            d = 1 if net > 0 else -1
            a = max((i for i in range(len(lots)) if lots[i][0] == d), key=lambda i: i)
            if len(lots) == 1 and pp[a] >= TP1:                      # F2
                close(a); n["f2"] += 1; ref = mid; continue
            if len(lots) > 1:
                b = max((i for i in range(len(lots)) if lots[i][0] == d), key=lambda i: pp[i])
                if pp[b] >= TPB:                                     # F4
                    close(b); n["f4"] += 1; ref = mid; continue
            if pp[a] <= -HEDGE:                                      # F3
                open_(-d); n["f3"] += 1; ref = mid
            continue
        mv = mid - ref
        if abs(mv) < DIR:
            continue
        d = 1 if mv > 0 else -1
        side = [i for i in range(len(lots)) if lots[i][0] == d]
        if side:
            b = max(side, key=lambda i: pp[i])
            if pp[b] >= TP1:                                         # F5 sarkao
                close(b); open_(d); n["f5"] += 1; ref = mid; continue
        if len(lots) >= MAXPOS:
            continue
        if not lots:
            cyc_real = 0.0
        open_(d); n["f1"] += 1; ref = mid
    bid, ask = mid - SPREAD / 2, mid + SPREAD / 2
    flo = sum((bid - o) if d == 1 else (o - ask) for d, o in lots)
    return real + flo, maxpos, len(lots), n


def main():
    res = [run(s) for s in range(12)]
    for i, (tot, mp, left, n) in enumerate(res):
        print(f"seed {i:2d}: kul {tot:+8.2f}$ (0.01 lot)  sab se zyada lots {mp:2d}  aakhir khuli {left:2d}  {n}")
    avg = sum(r[0] for r in res) / len(res)
    print(f"ausat 20 din: {avg:+.2f}$ fi 0.01 lot  (random qeemat par spread hi kharcha banta hai)")


if __name__ == "__main__":
    main()
