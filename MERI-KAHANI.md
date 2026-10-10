# MERI KAHANI — har nayi chat yahan se shuru kare

Ye file is liye hai ke chat full ya reset ho to Jalal ko apni kahani **0 se na
dohrani pare**. Har nayi chat pehle ye file, phir `ABHI-KAHAN-HAIN.md` parhe.
Tafseel ke liye: `METHOD.md` (method + naape hue number), `EA-LAWS.md`
(qanoon), `EA-QAWAID.md`, `EA-CHECKLIST.md`.

Aakhri update: 10 October 2026.

---

## 1. Main kaun hoon, aur kaise baat karni hai

- Naam Jalal. Pakistan (PKT, UTC+5). Gold (XAUUSD) trader, taqreeban 1.5 saal.
- **Roman Urdu**, chhota aur saaf. Hamesha **"aap"**, kabhi "tu/tera" nahi.
- **SBS** = ek waqt mein ek qadam. Har qadam ke baad main **"D"** likhta hoon.
- **Pehle poochho, phir file banao.** File ke baad sawal nahi.
- **Faisle Claude kare (8 Oct raat):** user ne kaha "mere paas kisi bhi sawal ka
  samajhdari wala jawab nahi". Is liye A/B/C mat poochho - apna mashwara khud
  lo, bata do kya kiya aur kyun, aur sirf AGLA EK QADAM do. Sawal sirf tab jab
  user ka paisa/account ya koi na-palatne wali cheez ho.
- Mushkil baat ho to **misaal aur table** se, lambi tehreer se nahi.
- Link hamesha **click hone wala** do (markdown link), aur raw link mein
  commit hash wala bhi do (GitHub kabhi purani copy dikhata hai).
- Mujhe baar baar "aaraam karo" mat kaho - jab thakunga khud bata doonga.
- **Chart bilkul saaf chahiye (10 Oct):** indicator chart par sirf ishara dikhaye;
  lakeerein, rang, lambi tables settings mein BAND rakho (Tide Seekh bhi "bohot text" se napasand hua tha).
- Main ab MT5 par kaafi theek kaam kar leta hoon (compile, chart par lagana,
  Strategy Tester).

## 1b. Live kitab ka haal

**9 Oct (JasDeskView v4.2, XAUUSDc, qeemat ~4185.46):** 160 position, BUY 102 /
2.21 lot (ausat 4188.779) / SELL 58 / 2.05 lot (ausat 4167.154), **NET +0.16
(LONG - jami nahi, $1 = 16 USC)**, kul 4.26 lot, **Close All -4,532.20 USC**
(faide wali 46 = +1,754.70, nuqsan wali 114 = -6,286.90). BUY band = -730.60,
SELL band = -3,801.60. Nuqsan zyada tar SELL mein: 0.01 x 49 = -1,508.00, ek
**1.15 SELL @ 4174.488 = -1,289.30**, 0.05 x 5 = -792.80. BUY mein 0.05 x 22 =
-667.60. Barabar ka price 4465.84 ($280 upar). 2 Oct se kitab ~3 guna bari
(1.36 -> 4.26 lot) aur nuqsan -2,920 -> -4,532.

**9 Oct, thori der baad (qeemat 4184.65):** user ne beech mein 2 SELL band, 1 BUY
khola -> 159 position, BUY 103 / 2.22 (ausat 4188.772), SELL 56 / 2.03 (ausat
4166.936), NET +0.19, Close All -4,564.60, barabar 4422.08. **User ne kaha: "ab
mashware se kaam karunga"** (bina mashware lot na kholna/band karna). Panel ka
BARI LOT KI JORI: 1.15 SELL + 59 BUY (sasti pehle, ausat 4173.30) = **+106.30**,
lots 4.25 -> 1.95, NET wahi +0.19, bachi kitab 99 position -4,670.90 (30 BUY
upar wali shamil). PLAN A (1.15 SELL + 22 faide wali = +11.90) NET ko +0.89 kar
deta hai - khatarnak.
**1.15 SELL GHALTI SE lagi thi** (user 0.05 lagana chahta tha), phir qeemat tezi se
upar gayi. User: "jaldi nahi karna", sawal: "nikal bhi jaon aur nuqsan bhi na ho" -
jawab diya: jo nuqsan ho chuka woh kisi jori/hedge se nahi mit-ta, sirf qeemat
(NET +0.19) ya aage ki kamai se; teen raaste taraazu ki misaal se. Mashwara: abhi
RUKO, ghalti dobara na ho is liye MT5 mein One Click Trading band + default lot 0.01.
**9 Oct shaam (Exness mobile app, user ne khud mazeed lots kholi/band kin):** 3:50 PM -
172 position (BUY 107 / SELL 65), Close All -4,717.12, equity 43,494.68. 4:16 PM -
**167 position (BUY 103 / SELL 64), app par "Fully hedged" (NET 0, jami)**, Close
All **-4,845.48**, **equity 43,409.42** (balance ~48,254.90), aaj ki band trades
+1,742.90. Beech ki trades: naye BUY 4174-4177, SELL ~4179.99, chhote faide band
(+2.40, +11.80, +9.10, +0.90, +5.60). **Sabaq (dikhaya): asal score EQUITY hai** -
3:50 se 4:16 equity -85 (bori: band faida +, khula utna hi -). 28 Sep wali 0.01
BUY @ 4367.366 (-186) abhi khuli. Mobile par One-click BAND.

(purana) 2 Oct raat ~8 PM:

99 position, BUY 0.68 (ausat 4204.75) / SELL 0.68 (ausat 4162.05), **NET 0 (jami)**,
Close All **-2,920 USC** (subha -3,277 tha; user ne haath se SELL upar shift kiye).
Saara nuqsan 28 Sep ki **0.59 BUY @ ~4213** mein. Aaj ki lots theek jagah: SELL upar, BUY neeche. Saara nuqsan BUY mein; SELL taqreeban barabar. User ka
iraada: SELL khatam, BUY rakho - tukdon mein (har dafa 0.20 se zyada nahi),
"ek band, ek khule" (nayi lot tabhi jab purani band ho), news ke waqt kuch nahi.

## 2. Accounts

| | Number | Qisam | Note |
|---|---|---|---|
| **LIVE** | 253687618 | Exness MT5 **StandardCent**, `XAUUSDc`, USC, Hedge, 1:2000 | **Swap-free (Islamic)**. 0.01 lot = $1 harkat par 1 USC |
| **DEMO** | 472540009 (9 Oct screenshot mein **472716649**, Exness-MT5Trial16, Hedge - JasTideRadarEA isi par) | Exness-MT5Trial16, `XAUUSDm`, **USD** standard, Hedge | Contract spec mein BUY swap -513.2 points/lot/din likha mila tha (2 Oct), **magar user kehta hai gold par swap nahi katta (8 Oct)** - hisaab mein swap 0. Shak ho to MT5 ka Swap column dekho |

- Live par **koi EA trade nahi karta** jab tak demo par test na ho.
- Mere computer par **do MT5** hain (live aur demo). MetaEditor hamesha **usi
  MT5 se F4** se kholo, warna file doosre MT5 ke folder mein chali jati hai.
- Account ki kahani: Standard USD ($707 → $489, nuqsan), phir Cent par aaya
  (fayda). Sep 2026 cent mahina +3,656 USC closed. 1 Oct ko account 53,330 USC
  se taqreeban 43,100 USC par tha (jami kitab ki wajah se).

## 3. Meri method (Fishing Lots) - ek nazar mein

Poori tafseel `METHOD.md` mein. Khulasa:
1. 1m par EMA 20/50 se rukh, chhoti lot (0.01), ~$1 faide par band (fishing).
2. Ulta gaya to intezar, ~$3 par dekhna, ~$4 tak.
3. Rukh badla to nayi lots naye rukh mein + bachao (against) lots.
4. **Freeze**: dono taraf lot barabar → kitab jami, qeemat kuch nahi kar sakti.
5. Intezar (swap-free hai, is liye muft).
6. **Unwind (Phase 6)**: ek taraf band, doosri chalne do, phir Close All.

Mera apna qaida (1 Oct): **SELL khatam karo, BUY rakho** - meri soch hai ke
gold ke girne ki hadd hai aur aakhir upar jata hai. BUY **neeche** hon, SELL
**upar**. Jori: SELL ko **sab se mehngi (upar wali) BUY** ke saath band karna.

Pehle main **2 mobile** se ek saath SELL aur BUY band karta tha - ab ye kaam
MT5 ka **Close By** karta hai (spread nahi, beech ka khatra nahi).

## 4. Jo sabaq naape hue numbers se nikle (dobara mat sikhana, yaad dilana)

- **Jami kitab ka nuqsan ek "bori" hai.** Kaun si lot kis ke saath band karo,
  KUL nuqsan wahi rehta hai. Sirf balance vs khula hisaab badalta hai.
- Kitab sirf tab behtar hoti hai jab **band karo, phir behtar jagah kholo**
  (SELL neeche band → upar dobara; ya BUY upar band → neeche dobara).
  Sirf naya kholne se ausat girta hai, nuqsan nahi.
- **Jitni kam lot khuli, khatra utna kam, magar wapsi ka fasla utna lamba.**
- 75% jeet ke bawajood nuqsan hua kyunki haar jeet se ~3x bari thi.
  **Jeet ki ginti nahi, jeet/haar ka size** faisla karta hai.
- Bara TF behtar: 1D 49.7% > 4H 43.8% > 1H 42% > 1m 37.5% (mera apna data).
- "Sabr" sahi cheez ke saath: jeet wali trade mein, haar wali mein nahi.
  Stop loss = "kahani badal gayi" ka pata chalna.
- **News (NFP, CPI, FOMC)**: 30 min pehle se ~1 ghanta baad tak koi nayi lot
  nahi (qanoon L10). NFP = har mahine pehla Jumma 5:30 PM PKT; gold $15-40+
  hilta hai, pehla jhatka aksar palat-ta hai, spread barhta hai.
- Martingale / grid / lot doubling **nahi**. August ka USD account aise gaya.
- **72 trades se faisla nahi hota** (JAS Seerhi, 8 Oct): -0.09R ka asal matlab
  "-0.35R se +0.17R ke darmiyan kahin". Settings badal badal kar 10 dafa
  aazmao to ek qismat se +0.2R dikha degi - woh naye data par gayab ho jata
  hai. Is liye: faisle ka qaida test se PEHLE likho, aur har aazmaish gino.
- Tester ka "144 trades / 36.8% jeet" = har trade ke do tukre (TP1 aadhi +
  baqi). Asal ginti entries ki hai (72, jeet 43%).
- **Kachhua (Tide) mein 2R par aadhi band karna nuqsan deh** (8 Oct, 1D gold,
  ~459 trades): aadhi band = +274%, PF 1.59; poori chalne do = +506%, PF 1.68.
  Girawat sirf 27% -> 24.5% kam hui. Trend system ki kamai chand BARI jeet se
  aati hai - unhein kaatna mehenga. (Seerhi ke ulat: wahan 1R par aadhi.)
- **Kachhua har daur mein musbat, magar aaj kal kam** (8 Oct, 1D gold, 459
  trades): 1970-99 +0.63R fi trade, 2000-18 +0.16R, 2019-aaj +0.30R. Saal
  mein ~8 trade -> 1% risk par aaj ke daur mein ~+2% saal ka andaza. Bara
  +506% zyada tar 1970s ki tezi aur 50 saal ke compounding se tha.
- **Guzara trading se? (8 Oct, user ka sawal)** Chhote account par kisi bhi
  system se nahi. ~$430 par +2%/saal = ~$9; 20%/saal (bohot achha) = ~$86.
  ~$300 mahina ke liye ~$18,000 par 20% chahiye. Kamai capital se barhti hai,
  risk barhane se nahi - risk barhana = August wala USD account.
- **Kachhua bohot markets par musbat** (9 Oct, JAS Tide Radar): gold +0.50R,
  silver +0.26R, EURUSD/GBPUSD +0.15R, AUD/JPY/CHF ~+0.1R, S&P ~0, BTC +0.76R
  har trade (har ek par ~120-560 trades). Har akeli chhoti, magar sab ek taraf.
  Silver gold ke saath +0.90 = wohi trade dugni; ek USD taraf ki kai trades =
  ek bari trade.
- **9 market mila kar (9 Oct, Radar r2):** 2019 se ~+10R saal (1% risk par ~10%
  saal), magar poori history mein sab se gehri girawat 90R - correlated
  markets (gold + silver) saath girti hain. Aaj ke daur ki girawat naape baghair
  demo/live nahi.
- **Jami kitab ka nateeja = (ausat SELL - ausat BUY) x lots** - qeemat se nahi
  badalta (10 Oct, do misaal ek hi din): demo 472540009 mein SELL ausat BUY se
  $0.63 UPAR -> 55 jori par ~+20 (spread ke baad) tay; Fishing EA Tester mein
  SELL @ ~3,962 aur BUY @ ~4,695 (SELL $733 NEECHE) -> ~-7,330 tay. User ka
  khayal "SELL upar, BUY neeche rakho" (Fishing logic ke liye, 10 Oct) range
  mein yahi plus deta hai, magar trend mein qeemat wapas na aaye to BUY SELL ke
  neeche khulna mumkin hi nahi rehta. Farq sirf is ka hai ke qeemat wapas aayi
  ya nahi. User: "real ke waqt aap ki advice yaad rakhunga".
- **Chakkar k4 Tester mein FAIL** (10 Oct, wahi 3 mahine): -5,561, **jeet 94%**
  phir bhi nuqsan - ausat jeet +7 vs ausat haar -136. Balance +20,739 tak
  barha magar equity shuru se kabhi upar nahi gayi (DD 5,618). "75% jeet phir
  bhi nuqsan" wala sabaq aur bhi bara: jeet ki ginti nahi, haar ka size.
- **Fishing EA f1 (user ke apne qaide) Tester mein FAIL** (10 Oct, XAUUSDm M1 real
  ticks, Jul-Sep 2026): kul -711.68, kitab 20 lots par atak gayi (khula -7,411).
  Sarkao ne +6,695 balance mein dikhaya magar 10 SELL @ ~3,962 aur 10 BUY @ ~4,695
  jami ho kar ~-7,330 ki "bori" ban gayin - wahi naqsha jo live kitab ka hai.
  Close All ka din kabhi nahi aaya. Sabaq dobara: asal score EQUITY / KUL hai,
  band hue faide nahi; jami kitab ka nuqsan har qeemat par wahi rehta hai.
- **Radar EA ka MT5 Tester (10 Oct, Exness data, 2019 se) - pehle se likha qaida
  PASS:** 414 trades, +40.39R bina swap, girawat 12.7R, 6/8 saal musbat. Magar
  **saara faida BTC se** (+44.2R); baqi 7 market mila kar -3.9R (FX -17.3R,
  gold +12.5R). Demo ka swap -22R kha gaya (is liye paise mein breakeven). Agar
  live cent par BTC nahi to live ke liye abhi qabil NAHI. Andar ke nateeje dekh
  kar market hatana/chunna mana (overfitting).
- **JAS SMC Trend ka "advance ishara" gold par kaam ka NAHI** (10 Oct, pehle se
  likha qaida, OANDA:XAUUSD): 15m 140 ishare FARK -1.1% (2SE 8.0%), 1H 207
  ishare FARK -1.7% (2SE 6.6%) - aam candle jaisa, balke zara bura. BTC par bhi
  har TF par shor. "Advance" = jaldi, faida nahi. Ishara sirf dekhne ka;
  settings ghuma kar dobara nahi aazmana (Seerhi wala sabaq).
- **Radar r3 (9 Oct raat) - pehle se likha qaida PASS = demo ke qabil:** 2005
  se 1254 trades, ~+6.8R saal, sab se gehri girawat 14.9R, 21 mein se 19 saal
  musbat (qaida: girawat <= 25R aur >= 70% saal). 2019 se ~+6.7R saal (1% risk
  par ~6.7%). Gold + silver ko ek trade gina (dohri trade hati) to 2019 ka
  ~+9.7R -> ~+6.7R hua. Puri history mein 1987-2001 ki 72R girawat bhi hai -
  lamba bura daur ho sakta hai. Girawat sirf band trades ki (asal zyada).
  Agla: broker (Exness) data par MT5 Tester, phir demo - `JasTideRadarEA.mq5`.

## 5. Mere tools (repo mein) - kya hai, kis haal mein

| File | Kya karta hai | Haal |
|---|---|---|
| `JasDeskView.mq5` v4.2 | **Sirf parhta hai.** Close-All ginti, lots by size, ausat, NET, BARI LOT KI JORI, PLAN A/B + "NET baad mein" | ✅ Live par chal raha. Kami: "ek taraf band" line sirf ek taraf ka fasla batati hai, poori kitab ka nahi |
| `JasJoriClose.mq5` s1 | **Script.** Bari lot ki lot-barabar jori **Close By** se band, ek Yes/No | ✅ Demo 150/150, **live 64/64 (+550.70 USC, 1 Oct)**. Abhi sasti BUY pehle chunta hai - user upar wali BUY pehle chahta hai (option banana baqi) |
| `indicators/jas_tide_radar.pine` r3 | **9 market ka kachhua ek 1D chart par** (trade nahi karta): har market ki trade/SL/agla toot, gold ke saath sync, USD daao, MILA HUA hisaab (sab / 2005 se / 2019 se), FAISLA row | ✅ r3 chal raha (9 Oct): **DEMO KE QABIL** |
| `indicators/smc_trend_pro.pine` t3 | **JAS SMC Trend (10 Oct):** SMC v4 ke hisson se ek rukh (score -100..+100, 5 haal) + **advance ishara** (chhota CHOCH, bari TF ke khilaf nahi, jaan wali candle). t3: **MA50 ka rang** = ishara (hara/laal chalu, sleti khatam) + **narangi S/R lakeer** (yahan band candle par rang badal sakta hai) + sleti nuqte wali (yahan kabhi nahi); table mein har TF ka apna rukh number. Andar naap: 2 ATR pehle vs aam candle, pehle se likha qaida | t1/t2 compile + chal gaye. **BTC 1H/4H/1D: FARK +0.1/+0.0/+3.5% = SABIT NAHI.** t3 **compile + chal gaya** (10 Oct). **Gold imtihan (pehle se likha qaida): XAUUSD 15m FARK -1.1%, 1H -1.7% = SABIT NAHI** -> sirf dekhne ka, trade/Tester/demo nahi, settings nahi ghumani |
| `JasTideRadarEA.mq5` e1 | **Radar r3 ke qaide ka EA, ek chart se 9 market**, USD hadd 3, gold+silver ek, 1% risk (broker ka hisaab), SL server par + roz aage. Default SIRF DIKHANA. Tester ke aakhir mein Journal mein R ka hisaab + pehle se likha qaida | **Compile ✅ (9 Oct). Tester ✅ QAIDA PASS (10 Oct): 2019 se 414 trades, +40.39R bina swap, girawat 12.7R - magar BTC +44.2R, baqi 7 market -3.9R.** Demo trade Peer 12 Oct se (pehle k4 hatana - takraao). Live cent nahi (BTC shayad wahan nahi) |
| `JasTideEA.mq5` t4 | Turtle/Donchian 1D, ek position, SL, 1% risk | Compile ✅. MT5 test t3: 132 trades, PF 1.23, DD 46% (Pine: 458, PF 1.56, DD 21%). Shak: demo swap. t4 swap alag ginta hai - **test baqi** |
| `docs/tide_rehnuma.html` | Tide Seekh ki Roman Urdu guide ([artifact](https://claude.ai/artifact/5w4xy7FcTuCnQqxbb3A6C2)): qaide, panel rows, roz ka kaam, MT5 order/SL, naap, demo plan | ✅ 8 Oct |
| `indicators/jas_tide_seekh.pine` + `strategies/jas_tide_seekh_test.pine` | **Tide (kachhua 1D) ka seekhne wala panel** (8 Oct, user: B + nayi file): har qaida ✓/✗, plan, lot, sarakta SL, purane nateeje R mein, switch "2R par aadhi" (BAND = 458 wala). Strategy copy mein v1.1 ki kharabiyan durust | Bana, **compile baqi**. Pehle Tester, phir demo |
| `indicators/jas_seerhi.pine` + `strategies/jas_seerhi_test.pine` | **Top-down seekhne ka script** (8 Oct, user ne faisle Claude par chhore): 1D rukh (structure + trend line + MA) -> 1H pullback -> 1H entry, SL/TP1(aadhi+BE)/TP2, lot, har qadam ka ✓/✗ panel. Strategy copy Tester ke liye | Compile ✅ (8 Oct, s1.2 panel). **1H Tester 2025-26: 72 trades, -5.7%, PF 0.86 = koi edge sabit nahi.** Settings ki tuning nahi; agla jaanch wala tester (ABHI-KAHAN-HAIN) |
| `indicators/smc_coach_pro_v4.pine` | **v3 + Pine v6 + kharabiyan durust + PIP HISAAB** (1D/1H candle ka raasta pip mein + har pip par waqt/volume ka profile) | **v4.1 compile + chal raha (8 Oct)**, 1m/15m/1h/1D par number aapas mein milte hain. Sirf observation. v3 waisi rakhi hai |
| `indicators/smc_coach_pro_v3.pine` | SMC dashboard (pehle v2). Tables sirf 1m/15m par, 9 TF ki chalti candle, BUY/SELL pressure, MA21/63, chhupa tracker + expectancy line, MTF 90% aur 15m signal | ✅ Compile hua (2 Oct). Naye signal sirf TEST ke liye |
| `indicators/jas_pro_box.pine` + `strategies/jas_pro_box_test.pine` | Teen tareeqe (MA pullback / candle / SMC sweep) ki ginti | Sirf observation. 15m har jagah manfi; C·SMC 1H-4H musbat magar ginti kam. User ne kaha 1D results achhe nahi |
| `JasChakkarEA.mq5` k4 | **EA, "trend ko dost bana kar".** Rukh ke saath 0.01 jhukao (NET 0.05 tak), ulti chaal par hedge, nuqsan par kuch band nahi, bari lot ki faide wali jori, Close All +30. Qaide Q0-Q9 `ABHI-KAHAN-HAIN.md` mein | Compile ✅ (9 Oct). **Tester FAIL (10 Oct, Jul-Oct 2026 real ticks): -5,561, jeet 94%, equity DD 5,618, aakhir mein darjanon lots phansi.** Live nahi; demo se hatana |
| `JasBasketEA.mq5` b20 | Meri method ka EA, sirf apni (magic) lots | Haath ki lots ko nahi chhoota |
| `JasDesk.mq5` | Button wala desk | User ne MT5 se hata diya |

## 5b. User ke trading qaide jo EA mein jaate hain (3-4 Oct)

- **Nuqsan par kabhi band nahi** - akeli lot ho ya jori, sirf 0 ya faida. Jab koi choice ho, woh chuno jo 0/faida de.
- **Close All** jab SELL + BUY mila kar faida ho, phir rukh dekh kar naya setup.
- **Trend is our friend** - rukh ke khilaf lot nahi. Lot kabhi 0.01 se bari nahi.
- Hedge zaroorat par, magar zyada der nahi. Seconds ka hisaab.
- Equity ka khayal sab se upar.

## 6. Kaam ke qaide jo seekhe gaye (dobara ghalti na ho)

- MQL5 `StringFormat("sirf likhai")` → **error**. Kam az kam ek value chahiye.
- String `cond ? "" : "..."` se bacho, `Pick()` helper use karo.
- Har file ki pehli line par **build number**, panel par bhi wahi.
- Script **Scripts** ya Experts folder - dono chalte hain (nishan alag hota hai).
- Live par script/EA chalane se pehle: Algo Trading hara, kaam ke baad **laal**.
  JasDeskView ko Algo Trading ki zarurat nahi (Allow Algo Trading khali).
- MetaEditor warning "return value of 'OrderCalcProfit' should be checked" ko bhi theek karo - na theek ho to hisaab 0 maan kar ghalat faisla ho sakta hai.
- User Claude app par chat karta hai; lambi chat + bohot screenshots se tokens jaldi khatam hote hain. Bara kaam ho to nayi chat.
- Cloud session MQL5 compile nahi kar sakta - user F7 karta hai, error ka
  screenshot bhejta hai.
- **Chhota jawab (A / B / D) aaye aur do sawal khule hon to ek line mein
  poochho kis ka jawab hai.** 7 Oct: "A" SMC Pine script ka tha, Claude ne
  EA ka samjha aur ghalat file bana di (wapas li gayi).

## 7. Routines / settings (claude.ai par)

- Gold update: **din mein 1 dafa**, Peer-Jumma 6:05 PM PKT, message sirf ahem
  din par (pehle har ghante thi - usage kha rahi thi).
- "Usage credits" switch OFF. $100 cloud credit muft mila (claim karna).
  "Full reset" muft button Oct 22 tak.
- Lambi chat zyada usage khati hai - kaam bara ho to **nayi chat** + code:
  `JAS-DESK-V3-0110 — ABHI-KAHAN-HAIN.md parho aur wahin se shuru karo. Branch: claude/zen-maxwell-7ypyqg`

## 8. Ye file kaise zinda rahe

Har chat ke aakhir mein (ya koi bara faisla/nateeja aaye to foran) Claude:
- naya **faisla / nateeja / sabaq** yahan ya `ABHI-KAHAN-HAIN.md` mein likhe,
- `ABHI-KAHAN-HAIN.md` = **abhi kya chal raha hai** (badalta rehta hai),
- `MERI-KAHANI.md` = **pakki baatein** (kam badalti hain),
- commit + push kare.
