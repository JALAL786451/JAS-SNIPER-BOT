# QDM data list (29 Oct 2026) - ek hi dafa sab

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
