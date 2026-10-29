#!/usr/bin/env python3
"""duka_get d2 (29 Oct 2026) - Dukascopy datafeed se seedha H1 / M1 (QDM ki jagah), sirf standard library.
Cloud (Claude) se Dukascopy rokta hai (~0.04 file/s) - laptop par chalao: tools/JAS_DATA.bat (ek click).

  python3 tools/duka_get.py h1              # docs/qdm-data-list.md ke H1 symbol -> data/duka/H1/<ID>_H1.zip
  python3 tools/duka_get.py m1              # 4 index M1 2021-aaj -> data/duka/M1/<ID>_M1_<saal>.zip (har saal alag, < 25 MB)
  python3 tools/duka_get.py h1 EURUSD       # sirf diye hue symbol
  --out <folder>  (default: repo ho to data/duka, warna is file ke saath JAS_DATA)

Resume: har bi5 file cache (--cache) mein; dobara chalao to wahin se. Server connection kaat de to retry.
Format QDM jaisa: Date,Time,Open,High,Low,Close,Volume (UTC, BID); volume 0 wali (khaali) candle nahi.
Jaanch (29 Oct): USA500 H1 2018-01-02 14:00 = QDM file ke barabar (2684.169 vs 2684.2).
"""
import argparse
import datetime as dt
import io
import lzma
import math
import struct
import sys
import time
import urllib.error
import urllib.request
import zipfile
from concurrent.futures import ThreadPoolExecutor
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
URL = 'https://datafeed.dukascopy.com/datafeed/'
H1 = ['USA30IDXUSD', 'USSC2000IDXUSD', 'DEUIDXEUR', 'GBRIDXGBP', 'FRAIDXEUR', 'EUSIDXEUR', 'JPNIDXJPY',
      'AUSIDXAUD', 'HKGIDXHKD', 'ESPIDXEUR', 'NLDIDXEUR', 'CHEIDXCHF', 'CHIIDXUSD',
      'LIGHTCMDUSD', 'BRENTCMDUSD', 'GASCMDUSD', 'COPPERCMDUSD', 'COCOACMDUSD', 'COFFEECMDUSX',
      'SUGARCMDUSD', 'COTTONCMDUSX', 'SOYBEANCMDUSX',
      'EURUSD', 'GBPUSD', 'USDJPY', 'AUDUSD', 'USDCAD', 'USDCHF', 'NZDUSD', 'EURJPY', 'GBPJPY',
      'EURGBP', 'AUDJPY', 'EURCHF', 'BTCUSD', 'ETHUSD']
M1 = ['USA500IDXUSD', 'USATECHIDXUSD', 'USA30IDXUSD', 'DEUIDXEUR']
FX = {'EUR', 'GBP', 'USD', 'JPY', 'AUD', 'CAD', 'CHF', 'NZD'}
FACTOR = {'GASCMDUSD': 10_000, 'COPPERCMDUSD': 10_000}   # baqi neeche ka qaida (probe 29 Oct)


def factor(sym):
    if sym in FACTOR:
        return FACTOR[sym]
    if len(sym) == 6 and sym[:3] in FX and sym[3:] in FX:
        return 1_000 if 'JPY' in sym else 100_000
    return 1_000


def fetch(path, cache, tries=8):
    """bi5 bytes (b'' = khaali / 404). Cache mein ho to wahi. Na mile to None (dobara chalao)."""
    f = cache / path
    if f.exists():
        return f.read_bytes()
    for k in range(tries):
        try:
            req = urllib.request.Request(URL + path, headers={'User-Agent': 'Mozilla/5.0'})
            b = urllib.request.urlopen(req, timeout=60).read()
            break
        except urllib.error.HTTPError as e:
            if e.code == 404:
                b = b''
                break
        except Exception:
            pass
        time.sleep(min(60, 2 ** k))
    else:
        return None
    f.parent.mkdir(parents=True, exist_ok=True)
    f.write_bytes(b)
    return b


def candles(b, start, fac):
    if not b:
        return []
    raw = lzma.decompress(b)
    out = []
    for i in range(0, len(raw) - 23, 24):
        t, o, c, lo, hi, v = struct.unpack('>5if', raw[i:i + 24])
        if v > 0:
            out.append((start + dt.timedelta(seconds=t), o / fac, hi / fac, lo / fac, c / fac, v))
    return out


def write_zip(rows, fac, zpath, name):
    nd = int(round(math.log10(fac)))
    buf = io.StringIO()
    buf.write('Date,Time,Open,High,Low,Close,Volume\n')
    for t, o, h, l, c, v in rows:
        buf.write(f'{t:%Y%m%d},{t:%H:%M:%S},{o:.{nd}f},{h:.{nd}f},{l:.{nd}f},{c:.{nd}f},{v:.4f}\n')
    zpath.parent.mkdir(parents=True, exist_ok=True)
    with zipfile.ZipFile(zpath, 'w', zipfile.ZIP_DEFLATED) as z:
        z.writestr(name, buf.getvalue())


def run(jobs, cache, workers):
    """jobs = [(path, start)] -> {path: bytes|None}"""
    with ThreadPoolExecutor(workers) as ex:
        res = list(ex.map(lambda j: fetch(j[0], cache), jobs))
    return dict(zip([j[0] for j in jobs], res))


def get_h1(sym, cache, workers, today, out):
    fac = factor(sym)
    years = range(2003, today.year + 1)
    yr = run([(f'{sym}/{y}/BID_candles_day_1.bi5', None) for y in years], cache, workers)
    if any(v is None for v in yr.values()):
        return 'adhoora (saal)'
    have = [y for y in years                                     # >= 20 asli din (2011 mein akeli candle jaisi nahi)
            if len(candles(yr[f'{sym}/{y}/BID_candles_day_1.bi5'], dt.datetime(y, 1, 1), fac)) >= 20]
    if not have:
        return 'Dukascopy par nahi'
    months = [(y, m) for y in range(have[0], today.year + 1) for m in range(12)
              if (y, m) < (today.year, today.month - 1)]          # chalta mahina abhi file nahi
    jobs = [(f'{sym}/{y}/{m:02d}/BID_candles_hour_1.bi5', dt.datetime(y, m + 1, 1)) for y, m in months]
    got = run(jobs, cache, workers)
    if any(v is None for v in got.values()):
        return 'adhoora (dobara chalao)'
    rows = [r for p, s in jobs for r in candles(got[p], s, fac)]
    write_zip(rows, fac, out / 'H1' / f'{sym}_H1.zip', f'{sym}_H1.csv')
    return f'{len(rows)} candle {rows[0][0]:%Y-%m} - {rows[-1][0]:%Y-%m}' if rows else 'khaali'


def get_m1(sym, cache, workers, today, out):
    fac = factor(sym)
    msg = []
    for y in range(2021, today.year + 1):                         # 2021-24 TALAASH, 2025+ IMTIHAN
        tag, d0, d1 = str(y), dt.date(y, 1, 1), min(dt.date(y, 12, 31), today - dt.timedelta(days=1))
        days = [d0 + dt.timedelta(days=i) for i in range((d1 - d0).days + 1)]
        days = [d for d in days if d.weekday() != 5]               # Hafta: market band
        jobs = [(f'{sym}/{d.year}/{d.month - 1:02d}/{d.day:02d}/BID_candles_min_1.bi5',
                 dt.datetime(d.year, d.month, d.day)) for d in days]
        got = run(jobs, cache, workers)
        if any(v is None for v in got.values()):
            msg.append(f'{tag} adhoora (dobara chalao)')
            continue
        rows = [r for p, s in jobs for r in candles(got[p], s, fac)]
        write_zip(rows, fac, out / 'M1' / f'{sym}_M1_{tag}.zip', f'{sym}_M1_{tag}.csv')
        msg.append(f'{tag} {len(rows)} candle')
    return ', '.join(msg)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('tf', choices=['h1', 'm1'])
    ap.add_argument('symbols', nargs='*')
    ap.add_argument('--cache', default=str(Path.home() / '.cache' / 'duka'))
    ap.add_argument('--workers', type=int, default=4)
    ap.add_argument('--out')
    a = ap.parse_args()
    cache, today = Path(a.cache), dt.date.today()
    out = Path(a.out) if a.out else (ROOT / 'data' / 'duka' if (ROOT / 'data').is_dir()
                                     else Path(__file__).resolve().parent / 'JAS_DATA')
    syms = a.symbols or (H1 if a.tf == 'h1' else M1)
    bad = 0
    print(f'{a.tf.upper()}: {len(syms)} symbol -> {out}', flush=True)
    for s in syms:
        t0 = time.time()
        r = (get_h1 if a.tf == 'h1' else get_m1)(s, cache, a.workers, today, out)
        bad += 'adhoora' in r
        print(f'{s:15s} {r}  ({time.time() - t0:.0f}s)', flush=True)
    print('SAB MUKAMMAL' if not bad else f'{bad} adhoore - dobara chalao (cache se wahin se)')
    sys.exit(1 if bad else 0)


if __name__ == '__main__':
    main()
