# POST-MORTEM 97 koshish (4 Nov 2026, 36vi chat, user "D")

Sirf record se (`docs/purana-haal.md`), koi test NAHI, agent NAHI. Code Claude ka faisla, record ke number par.
F = factor kamzor (kharche se pehle bhi ~0) | K = kharcha/swap ne mara (pehle faida tha) | I = ghalat instrument |
T = ghalat timeframe | D = data kam/patla (trades kam, SE bara) | A = paper jaisa nahi bana | B = code bug

## 1. PASS (post-mortem nahi)
6, 15, 26, 27, 34, 45 (kamzor), 49, 52, 53, 59 (bank), 67, 68, 76 (bank), 81, 83. Untested: 85, 86 (C2, K1 - sirf "test karo" par).

## 2. FAIL ki wajah
| Code | Koshish | Daleel (record) |
|---|---|---|
| F | 1-2 Holy Grail, 3 Williams VB, 5 TOM, 7-8 Ichimoku, 11 jori, 16, 17, 20, 24 | kharche se pehle bhi ~0 / kinare |
| F | 22, 30, 31, 36, 38, 40, 41, 43b, 44, 47, 48, 50, 51, 56, 75, 80, 97 | bina kharcha 0 se +0.03R (shor) |
| F | 39 gold 1H mom | bina kharcha XAU +0.097R magar SE 0.06 = bina kharcha bhi saabit nahi |
| F | 54 (#37 asli spread) | TALAASH PASS, IMTIHAN bina kharcha bhi -0.015R = edge 2025 mein khatam |
| F | 57, 58, 64, 65, 70 | IMTIHAN / drift jaanch fail |
| F | 61-63 Dow 30 share | faida = share ki drift |
| F | 73 SELL aaina, 74 3Commas, 84 range bar, 87 Naqsha 15M | kharche se pehle ~0 |
| F | 12 user 15m, 82 hedge-freeze, 88-95 recovery | jeet/maqsad wala hisaab manfi (12 par K bhi) |
| K | 42 raat drift US index | bina kharcha raat +0.028R (paper jaisa), andaza kharcha 0.03% + swap ~0.07R |
| K | 55 trend 1H tokri | bina kharcha +0.089R, ASLI kharcha ke baad +0.027R (Exp-2SE -0.028) |
| K | 72 forex 4H trend | kharcha+swap ~0.045R > edge ~0.01R (forex BAND user 1-11) |
| K+I | 66 trend 4H XPT/XPD/XCU | spread gold se 40-90x |
| K+T | 18 MA 1m, 30-33 gold intraday | 1m-H1 par kharcha kha gaya; gold 4H #33 baad mein t5 tokri mein aa gaya |
| I | 13 (T), 14, 25, 28, 29 | ghalat mkt/TF - theek kar ke PASS bane: #34, #15/#52, #26, #53 |
| I+A+K | 9 Gao | ghalat mkt + chhota R + spread; theek kar ke #97 = F |
| D | 4 TSMOM, 10 coint (16 tr), 32 (SE 0.40), 43a (3 tr), 46a (SE 0.25) | trades kam / data chhota |
| D | 21 ORB USTEC 5m | ASLI kharcha ke baad bhi +0.110R (bina +0.140), 997 tr sirf 2021-24, Exp-2SE -0.042 |
| A/D | 19 SMC DZ/SZ | TV acha, MT5 par nahi (MT5 4H baqi) |
| B | 23 (chala nahi), 65 v1 (ghalat), 87 v1 (DST loader) | theek kar ke dobara: 65 v3 F, 87 v2 F |
| jor | 35, 60, 69 (bank), 71, 77, 78, 79, 96 | naya edge nahi, FTMO jor ne fail/waqt barhaya |

## 3. DOBARA-TEST LIST (sirf jin ka kharche se pehle faida tha, aur abhi tak dobara nahi hua)
1. **#42 raat drift US500+USTEC** - kharcha andaza 0.03%/taraf tha; asli spread US500 0.0039%, USTEC 0.00285% (~8x kam),
   Exness swap-free. Khatra: edge chhota (+0.028R), drift jaisa (sabaq 5), FTMO swap pata nahi.
2. **#21 ORB USTEC 5m** - asli kharcha ke baad bhi musbat, fail sirf SE (data 2021-24). Dukascopy 2012-18 par nayi TALAASH.

BAHAR (kyun): #37/#54 (dobara ho chuka, IMTIHAN F), #9/#97 (ho chuka), #33/#55 (asli kharcha ho chuka), #72 (forex BAND),
#66 (spread asli hai), #39/#46/#48 (bina kharcha bhi saabit nahi).

Agla qadam: har ek ka qaida G1-G10 (`docs/research/test-se-pehle-shartein.md`) se, test sirf user "test karo" par.

## 4. DARWAZA G1-G10 (4 Nov, user "D"; test NAHI chala)
**#42 raat drift (agar dobara = #98, asli spread):**
| G | Haal | Daleel |
|---|---|---|
| G1 | AADHA | Cooper-Cliff-Gulen 2008, Lou-Polk-Skouras 2019, kai mulk; ~30 saal, 50 nahi. Chhapne ke baad bhi (#42 2003-18 raat +0.028R vs din +0.006R) |
| G2 | AADHA | raat band bazaar ka khatra (risk premium) + khareedar/bechne walon ki "tug of war" - pakki wajah nahi |
| G3 | NAHI | trade 16:00 -> 09:00 NY (H1 data), daily/4H nahi; FTMO 5% hadd theek |
| G4 | HAAN | US500, USTEC Exness + FTMO |
| G5 | HAAN | `data/ftmo/` Dukascopy H1 2003-18, #42 mein 2898 tr |
| G6 | NAHI | har raat US index BUY = i6 + t5 jaisa hi rukh (aam tezi); #96/#28 sabaq: pass ka waqt nahi ghatega |
| G7 | Exness HAAN / FTMO PATA NAHI | asli spread ~0.007R aana-jana; Exness swap-free 0; FTMO long index swap ~5%/saal = ~0.015R/raat -> baqi +0.005..+0.021R |
| G8 | HAAN (likh sakte) | #42 qaida jyon ka tyon, sirf kharcha asli + swap 0 aur 5% dono |
| G9 | KAMZOR | 0.25% risk par ~0.02R x 40 tr/mahina = ~0.2%/mahina; FTMO median par asar ~0 |
| G10 | | P(TALAASH) ~0.35, P(IMTIHAN / TALAASH) ~0.5, P(FTMO behtar) ~0.03 |
**Faisla: G3 + G6 NAHI = test NAHI.** BANK nahi, BAND (drift ka hissa, alag factor nahi).

**#21 ORB USTEC 5m:** G3 NAHI (5m; sabaq 2), G6 haan, G5 Dukascopy M1 2012-18 chahiye (`data/qdm/M1` sirf 2021+?). **Faisla: G3 NAHI = test NAHI.**

**Post-mortem ka nateeja:** 97 mein se koi bhi FAIL darwaza paar nahi karta. Abhi ka akela tayyar ummeedwar = C2 #85 (`factors-gehri.md`, P(FTMO behtar) ~0.07) - sirf user "test karo" par.
