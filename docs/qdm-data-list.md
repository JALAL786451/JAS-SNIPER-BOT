# QDM data list (29 Oct 2026) - ek hi dafa sab

**ASAAN TAREEQA (29 Oct, user ne manga):** laptop par `tools/JAS_DATA.bat` double-click = sab (36 H1 + 4 index M1 2021-aaj)
seedha Dukascopy se, QDM ke baghair (`tools/duka_get.py`, resume + retry). XPTUSD / XPDUSD Dukascopy par nahi (list se bahar).
Cloud (Claude) se Dukascopy rokta hai (29 Oct naap: 529s mein 22 file) - is liye laptop. Neeche QDM wala purana tareeqa.

Export tareeqa (har symbol): Export tab > **Export to CSV** (MT5 wala nahi) > Timeframe > No Session > Original >
"Generic bar format (comma delimited)". Pehle Data sources > Dukascopy mein symbol chun kar **Update** (download, ghante lag sakte).
Naam QDM mein thoda alag ho sakta hai - search box mein lafz likhein (jaise "DEU", "LIGHT").

**Pehle se hai (dobara NAHI):** XAUUSD, XAGUSD, USA500, USATECH H1 (all time), XAUUSD M1 2015 + 2021-24, USTEC M1 2021-22.

## A. H1, All time (har symbol ek CSV)

**Index (13):** USA30.IDX/USD (US30), USSC2000.IDX/USD (US2000), DEU.IDX/EUR (GER40), GBR.IDX/GBP (UK100),
FRA.IDX/EUR (FRA40), EUS.IDX/EUR (EU50), JPN.IDX/JPY (JP225), AUS.IDX/AUD (AUS200), HKG.IDX/HKD (HK50),
ESP.IDX/EUR (SPN35), NLD.IDX/EUR (N25), CHE.IDX/CHF (SWI20), CHI.IDX/USD (China A50)

**Commodity (11):** LIGHT.CMD/USD (WTI), BRENT.CMD/USD, GAS.CMD/USD (natgas), COPPER.CMD/USD, XPTUSD (platinum),
XPDUSD (palladium), COCOA.CMD/USD, COFFEE.CMD/USX, SUGAR.CMD/USD, COTTON.CMD/USX, SOYBEAN.CMD/USX

**Forex (12):** EURUSD, GBPUSD, USDJPY, AUDUSD, USDCAD, USDCHF, NZDUSD, EURJPY, GBPJPY, EURGBP, AUDJPY, EURCHF

**Crypto (2):** BTCUSD, ETHUSD

## B. M1 (sirf intraday test #37 noise-boundary, #41 asli Gao-Han-Li-Zhou)

USA500.IDX/USD, USATECH.IDX/USD, USA30.IDX/USD, DEU.IDX/EUR - har ek ki **do** file:
1. 2021-01-01 se 2024-12-31 (TALAASH)
2. 2025-01-01 se aaj (IMTIHAN - Claude PASS se pehle nahi kholega)

## Bhejna (GitHub web upload = 25 MB har file)

- `H1_index.zip`, `H1_commodity.zip`, `H1_forex_crypto.zip` (H1 chhoti hoti hai, ek zip mein kai CSV).
- M1: har symbol + daur alag zip, jaise `USA500_M1_2021_24.zip`, `USA500_M1_2025_aaj.zip` (~20 MB).
- GitHub: branch `claude/jas-desk-v3-0110-yu3w2h` > `data/qdm/` > Add file > Upload files. Ya chat mein attach.

## Tarteeb-war checklist (user 29 Oct: H1 38 + M1 4 index)

| # | QDM symbol | TF | Daur | Zip |
|---|---|---|---|---|
| 1 | USA30.IDX/USD | H1 | All time | H1_index |
| 2 | USSC2000.IDX/USD | H1 | All time | H1_index |
| 3 | DEU.IDX/EUR | H1 | All time | H1_index |
| 4 | GBR.IDX/GBP | H1 | All time | H1_index |
| 5 | FRA.IDX/EUR | H1 | All time | H1_index |
| 6 | EUS.IDX/EUR | H1 | All time | H1_index |
| 7 | JPN.IDX/JPY | H1 | All time | H1_index |
| 8 | AUS.IDX/AUD | H1 | All time | H1_index |
| 9 | HKG.IDX/HKD | H1 | All time | H1_index |
| 10 | ESP.IDX/EUR | H1 | All time | H1_index |
| 11 | NLD.IDX/EUR | H1 | All time | H1_index |
| 12 | CHE.IDX/CHF | H1 | All time | H1_index |
| 13 | CHI.IDX/USD | H1 | All time | H1_index |
| 14 | LIGHT.CMD/USD | H1 | All time | H1_commodity |
| 15 | BRENT.CMD/USD | H1 | All time | H1_commodity |
| 16 | GAS.CMD/USD | H1 | All time | H1_commodity |
| 17 | COPPER.CMD/USD | H1 | All time | H1_commodity |
| 18 | XPTUSD | H1 | All time | H1_commodity |
| 19 | XPDUSD | H1 | All time | H1_commodity |
| 20 | COCOA.CMD/USD | H1 | All time | H1_commodity |
| 21 | COFFEE.CMD/USX | H1 | All time | H1_commodity |
| 22 | SUGAR.CMD/USD | H1 | All time | H1_commodity |
| 23 | COTTON.CMD/USX | H1 | All time | H1_commodity |
| 24 | SOYBEAN.CMD/USX | H1 | All time | H1_commodity |
| 25 | EURUSD | H1 | All time | H1_forex_crypto |
| 26 | GBPUSD | H1 | All time | H1_forex_crypto |
| 27 | USDJPY | H1 | All time | H1_forex_crypto |
| 28 | AUDUSD | H1 | All time | H1_forex_crypto |
| 29 | USDCAD | H1 | All time | H1_forex_crypto |
| 30 | USDCHF | H1 | All time | H1_forex_crypto |
| 31 | NZDUSD | H1 | All time | H1_forex_crypto |
| 32 | EURJPY | H1 | All time | H1_forex_crypto |
| 33 | GBPJPY | H1 | All time | H1_forex_crypto |
| 34 | EURGBP | H1 | All time | H1_forex_crypto |
| 35 | AUDJPY | H1 | All time | H1_forex_crypto |
| 36 | EURCHF | H1 | All time | H1_forex_crypto |
| 37 | BTCUSD | H1 | All time | H1_forex_crypto |
| 38 | ETHUSD | H1 | All time | H1_forex_crypto |
| 39 | USA500.IDX/USD | M1 | 2021-01-01 - 2024-12-31 | USA500_M1_2021_24 |
| 40 | USA500.IDX/USD | M1 | 2025-01-01 - aaj | USA500_M1_2025_aaj |
| 41 | USATECH.IDX/USD | M1 | 2021-01-01 - 2024-12-31 | USATECH_M1_2021_24 |
| 42 | USATECH.IDX/USD | M1 | 2025-01-01 - aaj | USATECH_M1_2025_aaj |
| 43 | USA30.IDX/USD | M1 | 2021-01-01 - 2024-12-31 | USA30_M1_2021_24 |
| 44 | USA30.IDX/USD | M1 | 2025-01-01 - aaj | USA30_M1_2025_aaj |
| 45 | DEU.IDX/EUR | M1 | 2021-01-01 - 2024-12-31 | DEU_M1_2021_24 |
| 46 | DEU.IDX/EUR | M1 | 2025-01-01 - aaj | DEU_M1_2025_aaj |

H1 mein 36 naye + 2 crypto = 38 (USA500, USATECH, XAU, XAG ka H1 pehle se hai). Koi zip 25 MB se bari ho to do hisson mein.
