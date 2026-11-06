# Research agent 6 Nov 2026 (user ne naam le kar maanga) - factors tasdeeq, nayi strategies, data sites
Aam: McLean & Pontiff 2016 - chhapne ke baad faida ~32-35% kam. Paper ka ~1/2-2/3 umeed rakho.

## A) Hamare 5 faide
1. JasTrend 4H tokri - MAZBOOT (Hurst/Ooi/Pedersen AQR 2017, 1880 se 67 market). Supertrend khud test nahi; 2009 baad thoda kamzor (Carver 2025).
2. IBS US500/USTEC - DARMIYANA (Pagonidis NAAIM; Kinlay: 2015-16 SPY manfi; Pandey & Joshi 2023 tasdeeq). Ghatne ka khatra.
3. Khirki (overnight/close non-US index) - DARMIYANA (Cliff/Cooper/Gulen 2008; Liu & Tse 2017 intl futures 1999-2014; NY Fed). Kharcha 2 spread khatra.
4. Kachhua Donchian 12 - DARMIYANA (trend family; commodity trend 2009 baad kamzor = patla pass sahi).
5. Chutti se pehle SPX/NDX - KAMZOR-DARMIYANA (Ariel 1990; Keef & Roush 2005 1987 baad kam; Ko 2021 insignificant). ~9 tr/saal, risk chhota.

## B) Nayi strategies (tarteeb)
B1 Pre-FOMC drift US500/USTEC (Lucca & Moench 2015; Kurov 2016 baad kamzor; Quantseeker 2014-24 zinda). FOMC T-1 close -> T close, 8/saal. Data: H1 + Fed calendar.
B2 Chutti se pehle non-US index (DE30 UK100 JP225 HK50 AUS200) - #59 code, har exchange ki chutti list (Kim & Park 1994, Cadsby & Ratner 1992).
B3 Mahina-aakhir rebalancing (Harvey/Mazzoleni/Melone 2025): MTD stocks >> bonds -> aakhri 3-5 din SHORT index, warna LONG; naya mahina pehle din band. Threshold pehle likho. Data: US500 + TLT/IEF (Yahoo) ya FRED.
B4 BTC/ETH trend (Liu & Tsyvinski RFS 2021). FTMO crypto leverage/spread dekho.
B5 Gold overnight (US close 17:00 ET -> COMEX open 08:20 ET) (Blose/Gondhalekar/Kort 2014/2018; "kafi kamzor"; Quantpedia: asli fill par kam). Data M1 bid+ask.
B6 Volatility sizing (Moreira & Muir 2017 +; Cederburg 2020 OOS faida nahi; DeMiguel 2024 +) - hadd ke andar, DD kam.
B7 Aakhri 30 min momentum (Baltussen/Da/Lammers/Martens JFE 2021) - M1/M5, kharcha bhaari, aakhir mein.
Mana: gold-real yield (2022 baad toot gaya), BTC din-e-hafta (random jaisa).

## C) Data
1. Dukascopy (free; dukascopy-node / QDM / Tickstory) - BEHTAREEN: XAU/XAG tick 2003 se; USA500 tick 2012 (daily 1980); USATECH/USA30 2013; DEU/GBR/FRA/JPN 2013 (daily 1986-88, DEU daily 2013); EUS/AUS 2014-06; HKG 2013-06; US2000 2018-08; LIGHT/BRENT/GAS/COPPER CMD bhi. Bid+ask alag, UTC. Saare gap (gold M1 2019/20/25/26, US500/USTEC 2019-20) yahan se.
2. HistData.com (free, M1 bid, EST bina DST) - gold 2018 ke baad bhi; SPX/NSX shayad (tasdeeq nahi). Cross-check.
3. Stooq (free daily bulk zip stooq.com/db/h/, quota).
4. Yahoo (yfinance) daily ^GSPC ^NDX ^GDAXI ^FTSE ^FCHI ^STOXX50E ^N225 ^HSI ^AXJO, GC=F CL=F ~2000 se (roll unadjusted).
5. FRED - macro (DFII10, VIX, yields).
6. FirstRate Data (~$299, 1-min futures 2007 se) - sirf zaroorat ho to.
Monday: (1) Dukascopy M1 bid+ask QDM/dukascopy-node, (2) Stooq/Yahoo daily purani history, (3) FirstRate sirf B7 ke liye.
Links: agent report (6 Nov chat) - McLean gwern.net/doc/economics/2016-mclean.pdf, aqr.com A-Century-of-Evidence, jonathankinlay.com/?p=2199, arxiv 2306.12434, ideas.repec.org reveco v48 p440, cfr.ivo-welch.info ko2021pre.pdf, ideas.repec.org jfinan v70 p329, quantseeker pre-fomc, fuqua.duke.edu rebalancing, econpapers rfinst v34 p2689, ideas.repec.org jecfin v42 9403, lehigh.edu/~xuy219/research/COWY.pdf, nd.edu/~zda/intramom.pdf, dukascopy-node.app/instruments, firstratedata.com.
