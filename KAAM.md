# KAAM - Jalal ka EK register (hook har nayi chat ko KHUD dikhata hai)

Jawab CHHOTA. User ki har nayi baat USI jawab mein yahan EK line. Kaam ho -> qatar hata kar ek line `docs/purana-haal.md`.
**Ye file <= 4 KB.** Purani tafseel: `grep "KAAM se hataya" docs/purana-haal.md` (19 Nov wala = poora purana KAAM harf ba harf).

## Pehle jawab mein KHUD
1. MT5 table (hook) - user tasdeeq. 2. Neeche se AGLA kaam + salah. 3. 1 nayi maloomat (`docs/nayi-maloomat.md` mein na ho).
4. Har report / SS par **KHUD NAZAR**: khatra, EA takrao, backtest se farq - bina pooche (`docs/khud-nazar.md`).
5. KAHANI.txt / poori TRADING.md NA parho; purani baat sirf `grep`. "Chat lambi" ka zikr baar baar NAHI.

## ABHI KA MAQSAD (user 20 Nov: baat track par aate hi chat mehngi - is liye Claude USI waqt yahan 2-3 line likhe, nayi chat yahin se shuru)
- Gold script g3.3.2 = tests se 100% mili (71vi). User SS ka matlab: script ko PICHHLE TESTS se milao (EA / demo NAHI jab tak user na kahe).
- User SS / sawal ka matlab pakka na ho to EK chhota sawal poochho, andaze se lamba jawab NAHI.

## Pakki baatein (bhoolna mana)
- **User 19 Nov (naraz, haq par):** branch / setting ka masla user ko NA samjhao, NA settings baar baar badlo - Claude khud chup-chaap theek kare. Chat ke aakhir mein kaam default (`jas-desk-v3`) par pohncha ho, ye Claude KHUD check kare.
- Purane EA / Pine mein tabdeeli NAHI - naya kaam NAYI file; risk hadd khud NAHI barhana; backtest -> demo -> live.
- Naya idea = pehle G1-G10 darwaza (`docs/research/test-se-pehle-shartein.md`) + user "test karo"; purani koshish `grep` (dobara NAHI).
- **User 19 Nov:** test SIRF usi market par jo user kahe (gold kaha = sirf gold). Silver / doosra market jaanch ke liye khud NA jorna - pehle poochhna.
- FTMO: swap-free; khareedne se pehle "Swing 2-Step 100k?" likhwana. FundingPips par EA NAHI. EA plan sirf FTMO.
- 4 EA ki taqseem / jor #101 waise hi (K21 66vi: bina US sab FAIL). Gold tokri BAND. t5 chalne dein.
- ASAL maqsad: user ke tareeqe wala fighting EA (profit lots + jori band, DEEWAR, dohri lot). Hasrat (16 Nov): FTMO jaldi wala EA + pro BUY/SELL Pine + tested fighter.
- LIVE 253687618: m8.5; jori A / B YES, C NA. TV ka kaam user khud + SS (PC Claude bridge NAHI). Weekly 50%+ = agent NAHI.
- Behtar ab tak: Kachhua 12 market 0.25% (had 0.45). SELL / YouTube / ICT / zones FAIL. Gold Pine = g3.1.

## Khule kaam (upar wala pehle)
| # | Kaam | Haal |
|---|---|---|
| **FABLE** | 22 Nov 2 AM ke baad YAAD DILAO: Fable 5.2 se 4 EA (t5, i6, k2, e2) + instruments + qaidon ki AZAD jaanch (`docs/fable-jaanch.md`). User: Fable mehnga magar yahi | User: nayi chat, model Fable 5.2, "TRADING", phir "docs/fable-jaanch.md wala kaam karo". 'Full reset' muft EK dafa 11 Dec tak BACHA ke |
| **K21g** | JAS GOLD **g3.3.2** `indicators/jas_gold_g3_3_2.pine` = gold ki chalti script (g3.3.1 sahara + ABHI khali jagah) | **TV ✅ 20 Nov**, labels theek, tests se 100% mili. AGLA: pehla 'ABHI: BUY' SS (demo pehle) |
| **K24** | JAS GOLD **g4** `indicators/jas_gold_g4.pine` (user "A" 19 Nov): g3.1 qaida wahi + SMC Coach sirf ittila | pinecheck saaf; user TV paste (gold 15m/1H/4H) + SS; error = g4.1 |
| **K11** | j2 (`JasLarai1_EA`) demo 472716649 par, deewar OFF | 3rd MT5 `C:\MT5_DEMO2` (/portable) + 472716649 login; purane 2 MT5 ka login KABHI na badlein |
| SMA | US500 D1 SMA200 (EA kaam, script nahi): 17 Nov 1 close neeche, 20 Nov ~7,030 | jab user chahe SS; 3+ close neeche = V2 baat |
| TAJ | 71vi: demo 9 band = US index -2,036 / metal -120; EA 8/8 test se mile (bug nahi); ghalti = design (sab BUY, US t5+i6 dohra) | user faisla: t5 US + SMA200 filter test (naya) ya Fable tak ruko |
| K7 | e2 Kachhua demo 474832446 | 20 Nov: e2 3 SELL +627 (XAG, AUD, BTC nayi); i6 US500 SL -1,000; XAG SL Peer ~50.78 sarakna chahiye (na = EA log) |
| K19 | Kachhua Naqsha k1 `indicators/jas_kachhua_naqsha.pine` | user TV paste + SS (error = k1.1) |
| K6 | LIVE report se user ka asli tareeqa (naqsha) | K11 ke baad, user ki haan |
| FTMO | Black Friday: 20 Nov ftmo.com par offer NAHI | 24-27 Nov dobara (`docs/bank.md`) |
