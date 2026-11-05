# Tokri asli tareeqa (Q14-Q19, 44vi chat 6 Nov) - gold H1 2005-2026, $1000 USD, 0.01 lot = $1 har $1.
#   python3 tools/tokri_asli.py                 -> sab variant ki table (C engine: tools/tokri_asli.c)
#   python3 tools/tokri_asli.py saal mom 1.5 1 1 [H] [STOP]  -> ek variant saal-ba-saal
# Qaide: har D $ chaal par nayi lot (mom: chaal ki taraf | jori: BUY+SELL dono | ulta: chaal ke khilaf);
#   har lot alag band jab spread ($0.24/0.01) ke BAAD +T $; nuqsan wali intezar (wahi +T par band);
#   L=1 sab 0.01 | L=2 sab 0.02 | L=3 (Q16): chaal wali 0.02 jab ulti taraf lot khuli ho, warna 0.01.
#   hadd: khula nuqsan -$STOP (300) -> sab band, phir naye sire se. H = hedge: lot -H $ par ulti hedge lot (same size),
#   hedge band jab khud +H (asal phir azad); asal TP par -> hedge bhi band. Bar ke andar raasta O-L-H-C / O-H-L-C (andaza).
import sys, os, zipfile, io, subprocess, tempfile, pandas as pd
R = os.path.dirname(os.path.abspath(__file__)) + '/..'
TMP = tempfile.gettempdir()
EXE, DAT = TMP + '/tokri_asli', TMP + '/tokri_xau.txt'
subprocess.run(['gcc', '-O2', '-o', EXE, R + '/tools/tokri_asli.c', '-lm'], check=True)
if not os.path.exists(DAT):
    with zipfile.ZipFile(R + '/data/ftmo/XAU_XAG_H1_dukascopy.zip') as z:
        df = pd.read_csv(io.BytesIO(z.read('XAUUSD/2026.10.28XAUUSD-H1-No Session.csv')))
    df = df[df.Date >= 20050101]
    pd.DataFrame({'o': df.Open, 'h': df.High, 'l': df.Low, 'c': df.Close, 'y': df.Date // 10000}).to_csv(DAT, sep=' ', header=False, index=False)
MD = {'mom': 0, 'jori': 1, 'ulta': 2}
def run(M, D, T, L, H=0, STOP=300, yearly=0):
    out = subprocess.run([EXE, str(MD[M]), str(D), str(T), str(L), str(H), str(STOP), str(yearly)], stdin=open(DAT), capture_output=True, text=True).stdout
    return out
if __name__ == '__main__':
    if len(sys.argv) > 1 and sys.argv[1] == 'saal':
        a = sys.argv[2:] + ['0', '300'][len(sys.argv) - 6:]
        print(run(a[0], a[1], a[2], a[3], a[4], a[5], 1)); sys.exit()
    print('mode D   T   L H  | equity stops trades maxDD max0.01 bura_khula blown tps tp$ stop$')
    from concurrent.futures import ThreadPoolExecutor
    jobs = [(M, D, T, L, H) for M in ('mom', 'jori', 'ulta') for D in (1, 1.5, 2, 3) for T in (0.3, 1, 2, 4) for L in (1, 2, 3) for H in (0, 20, 50) if not (H and L != 1)]
    with ThreadPoolExecutor(os.cpu_count()) as ex:
        for j, o in zip(jobs, ex.map(lambda j: run(*j), jobs)):
            print(f"{j[0]:4} {j[1]:<3} {j[2]:<3} {j[3]} {j[4]:<2} | {o.strip()}", flush=True)
