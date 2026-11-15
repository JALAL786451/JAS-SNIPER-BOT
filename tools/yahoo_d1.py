#!/usr/bin/env python3
"""Yahoo Finance se lamba DAILY OHLC (10 cash index) -> data/yahoo/D1.zip (#103 seasonality: sirf mahana close ki ranking).
Purane saal mein High/Low kai jagah khali (flat) = SL ka hisaab is se NAHI; gold/silver futures ka OHLC kharab tha = hataya.
  python3 tools/yahoo_d1.py            # sab symbol utaaro (dobara chalane se taza)
Naam: hamara naam -> Yahoo symbol. Sirf qeemat (koi zaati maloomat nahi jati).
"""
import io
import json
import time
import urllib.parse
import urllib.request
import zipfile
from pathlib import Path

import pandas as pd

ROOT = Path(__file__).resolve().parent.parent
SYMS = {'US500': '^GSPC', 'USTEC': '^NDX', 'US30': '^DJI', 'DE30': '^GDAXI', 'UK100': '^FTSE', 'FR40': '^FCHI',
        'EU50': '^STOXX50E', 'JP225': '^N225', 'AUS200': '^AXJO', 'HK50': '^HSI'}


def fetch(ysym):
    url = (f'https://query1.finance.yahoo.com/v8/finance/chart/{urllib.parse.quote(ysym)}'
           '?period1=0&period2=9999999999&interval=1d&events=history')
    req = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0'})
    with urllib.request.urlopen(req, timeout=60) as r:
        j = json.load(r)['chart']['result'][0]
    q = j['indicators']['quote'][0]
    df = pd.DataFrame({'t': pd.to_datetime(j['timestamp'], unit='s', utc=True).tz_convert(j['meta']['exchangeTimezoneName']).date,
                       'Open': q['open'], 'High': q['high'], 'Low': q['low'], 'Close': q['close']})
    return df.dropna().drop_duplicates('t').reset_index(drop=True)


def main():
    out = ROOT / 'data' / 'yahoo' / 'D1.zip'
    with zipfile.ZipFile(out, 'w', zipfile.ZIP_DEFLATED) as z:
        for name, ys in SYMS.items():
            df = fetch(ys)
            z.writestr(f'{name}.csv', df.to_csv(index=False, float_format='%.6g'))
            print(f'{name:7s} {ys:10s} {len(df):6d} din, {df["t"].iloc[0]} .. {df["t"].iloc[-1]}', flush=True)
            time.sleep(1)


def load_d1(name):
    with zipfile.ZipFile(ROOT / 'data' / 'yahoo' / 'D1.zip') as z:
        df = pd.read_csv(io.BytesIO(z.read(f'{name}.csv')), parse_dates=['t'])
    return df


if __name__ == '__main__':
    main()
