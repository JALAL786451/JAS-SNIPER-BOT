#!/usr/bin/env python3
"""FTMO imkaan f2 (27 Oct 2026) - kisi system / tokri ka FTMO 2-step pass hone ka andaza.

Monte Carlo: har run mein din ba din trades, FTMO ke qaide:
  Phase 1 target +10%, Phase 2 +5%, din ka max nuksan 5% (shuru ke balance ka),
  kul max nuksan 10%, kam az kam 4 trade wale din, waqt ki had nahi (yahan --mahine tak).
Risk har trade par shuru ke balance ka fixed % (1R).

Har system ka trade = do qeemat (jeet W / haar L) jo Exp, SD aur jeet % se milti hain.
Faida pakka nahi: har run mein asli Exp = N(Exp, SE) se (--pakka-faida se band).

Hadd (imaandari): trade ka R band hone wale din par (khuli trade ka beech ka
nuksan nahi dikhta), systems aapas mein azad maane, Kachhua ka jeet % andaza.

Misaal:
  python3 tools/ftmo_imkaan.py --preset ibs
  python3 tools/ftmo_imkaan.py --preset ibs --preset kachhua --risk 0.5 1 1.5
  python3 tools/ftmo_imkaan.py --system naya:0.10:0.03:0.8:4:0.55
  python3 tools/ftmo_imkaan.py --preset ibs --preset kachhua --jaal   (f2: har system ka alag risk)
"""
import argparse
import math

import numpy as np

DIN_MAHINA = 21

# naam: (Exp R, SE, SD fi trade, trades fi mahina, jeet %) - IMTIHAN (2019+) ke number
PRESETS = {
    # #15 IBS S&P: 190 trades +0.082R (2SE 0.053), ~7.8 saal; jeet 61-69%
    'ibs': ('IBS S&P', 0.082, 0.0265, 0.0265 * math.sqrt(190), 190 / (7.8 * 12), 0.65),
    # #6 Kachhua commodity: 567 trades +0.067R; SD TALAASH se (1478 tr, 2SE 0.098); jeet % andaza
    'kachhua': ('Kachhua commodity', 0.067, 0.049 * math.sqrt(1478) / math.sqrt(567),
                0.049 * math.sqrt(1478), 567 / (7.8 * 12), 0.30),
}


def do_qeemat(exp, sd, q):
    """Jeet q par W, haar par L - Exp aur SD dono milte hain."""
    return exp + sd * math.sqrt((1 - q) / q), exp - sd * math.sqrt(q / (1 - q))


def chalao(systems, risks, runs, mahine, pakka, rng):
    """risks: ek number (sab systems) ya har system ki list (f2)."""
    if not isinstance(risks, (list, tuple)):
        risks = [risks] * len(systems)
    din = mahine * DIN_MAHINA
    phase = np.ones(runs, dtype=int)          # 1, 2; 3 = dono pass
    bal = np.zeros(runs)                      # % (shuru ke balance ka)
    trade_din = np.zeros(runs, dtype=int)
    natija = np.zeros(runs, dtype=int)        # 0 chal raha, 1 pass, 2 din ka, 3 kul
    p1_din = np.full(runs, -1)
    p2_din = np.full(runs, -1)
    sys = []
    for (_, exp, se, sd, tpm, q) in systems:
        w, l = do_qeemat(exp, sd, q)
        shift = np.zeros(runs) if pakka else rng.normal(0.0, se, runs)
        sys.append((w + shift, l + shift, tpm / DIN_MAHINA, q))

    for d in range(din):
        zinda = natija == 0
        if not zinda.any():
            break
        pnl = np.zeros(runs)
        aaj = np.zeros(runs, dtype=bool)
        for (w, l, p, q), risk in zip(sys, risks):
            t = rng.random(runs) < p
            jeet = rng.random(runs) < q
            pnl += np.where(t, np.where(jeet, w, l), 0.0) * risk
            aaj |= t & (risk > 0)
        pnl[~zinda] = 0.0
        bal += pnl
        trade_din += (aaj & zinda)
        natija[zinda & (pnl <= -5.0)] = 2
        natija[(natija == 0) & (bal <= -10.0)] = 3
        target = np.where(phase == 1, 10.0, 5.0)
        hua = (natija == 0) & (bal >= target) & (trade_din >= 4)
        p1 = hua & (phase == 1)
        p1_din[p1] = d
        phase[p1] = 2
        bal[p1] = 0.0
        trade_din[p1] = 0
        p2 = hua & ~p1 & (phase == 2)
        p2_din[p2] = d
        natija[p2] = 1
    return natija, p1_din, p2_din


def main():
    ap = argparse.ArgumentParser(description='FTMO 2-step pass ka imkaan (Monte Carlo)')
    ap.add_argument('--preset', action='append', choices=sorted(PRESETS), default=[])
    ap.add_argument('--system', action='append', default=[],
                    help='naam:Exp:SE:SD:trades_fi_mahina:jeet (misaal naya:0.1:0.03:0.8:4:0.55)')
    ap.add_argument('--risk', type=float, nargs='+', default=[0.5, 1.0, 1.5, 2.0])
    ap.add_argument('--mahine', type=int, default=36, help='kitne mahine tak dekhna (FTMO had nahi)')
    ap.add_argument('--runs', type=int, default=20000)
    ap.add_argument('--pakka-faida', action='store_true', help='Exp bilkul pakka maano (SE nahi)')
    ap.add_argument('--seed', type=int, default=1)
    ap.add_argument('--jaal', action='store_true',
                    help='f2: pehle do system ka alag alag risk - har khane mein DONO pass / fail kul / mahine')
    a = ap.parse_args()

    systems = [PRESETS[p] for p in a.preset]
    for s in a.system:
        n, e, se, sd, t, q = s.split(':')
        systems.append((n, float(e), float(se), float(sd), float(t), float(q)))
    if not systems:
        systems = [PRESETS['ibs']]

    print('FTMO imkaan f2 - 2-step (P1 +10%, P2 +5%, din 5%, kul 10%, min 4 din)')
    for (n, e, se, sd, t, q) in systems:
        print(f'  {n}: Exp {e:+.3f}R  SE {se:.3f}  SD {sd:.2f}  {t:.1f} trade/mahina  jeet {q:.0%}')
    print(f'  {a.runs} runs, {a.mahine} mahine tak, faida {"pakka" if a.pakka_faida else "SE ke saath (asli)"}\n')
    if a.jaal and len(systems) >= 2:
        ra = [0.5, 1.0, 1.5, 2.0, 2.5, 3.0]
        rb = [0.0, 0.1, 0.25, 0.5]
        print(f'JAAL: qatar = {systems[0][0]} risk %, khana = {systems[1][0]} risk %')
        print('har khane mein: DONO pass / fail kul / ausat mahine\n')
        print('      ' + ''.join(f'{b:>17.2f}%' for b in rb))
        for r1 in ra:
            row = f'{r1:>5.1f}%'
            for r2 in rb:
                rng = np.random.default_rng(a.seed)
                nat, _, p2 = chalao(systems[:2], [r1, r2], a.runs, a.mahine, a.pakka_faida, rng)
                w = p2[nat == 1]
                m = f'{np.median(w) / DIN_MAHINA:.0f}m' if w.size else '-'
                row += f'{(nat == 1).mean():>8.0%} /{(nat == 3).mean():>4.0%} /{m:>4}'
            print(row)
        return
    print(f'{"Risk":>5} | {"P1 pass":>7} | {"DONO pass":>9} | {"Fail din":>8} | {"Fail kul":>8} | {"Abhi baqi":>9} | {"Ausat waqt (dono)":>17}')
    print('-' * 82)
    for r in a.risk:
        rng = np.random.default_rng(a.seed)
        nat, p1, p2 = chalao(systems, r, a.runs, a.mahine, a.pakka_faida, rng)
        n = a.runs
        waqt = p2[nat == 1]
        med = f'{np.median(waqt) / DIN_MAHINA:.0f} mahine' if waqt.size else '-'
        print(f'{r:>4.1f}% | {(p1 >= 0).sum() / n:>7.0%} | {(nat == 1).sum() / n:>9.0%} | '
              f'{(nat == 2).sum() / n:>8.0%} | {(nat == 3).sum() / n:>8.0%} | '
              f'{(nat == 0).sum() / n:>9.0%} | {med:>17}')


if __name__ == '__main__':
    main()
