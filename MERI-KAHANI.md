# MERI KAHANI — har nayi chat yahan se shuru kare

Ye file is liye hai ke chat full ya reset ho to Jalal ko apni kahani **0 se na
dohrani pare**. Har nayi chat pehle ye file, phir `ABHI-KAHAN-HAIN.md` parhe.
Tafseel ke liye: `METHOD.md` (method + naape hue number), `EA-LAWS.md`
(qanoon), `EA-QAWAID.md`, `EA-CHECKLIST.md`.

Aakhri update: 11 October 2026 (raat).

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
- **Usage limit bachao (11 Oct):** hafte ki limit 1 din mein 28% gayi. Wajah: kai
  agent wale workflow (har ek 0.6-2.5 million token) aur bohot lambi chat. Qaida:
  (1) **agent/workflow sirf jab user khud naam le kar maange**; aam jaanch Claude
  khud ek dafa kare. (2) Chat lambi ho jaye (ek bara kaam khatam) to **nayi chat**
  `JAS-DESK-V3-0110` code se - har naya message poori purani chat dobara parhta hai.
  (3) Jawab chhote. (4) Chhote qadam (paste / screenshot check) ek message mein.
  (5) Purani chats (left list) idle hon to usage NAHI khaatin - sirf chalti chat
  khaati hai; 11 Oct ko koi Routine bhi chalu nahi tha. (6) Har chat 'xhigh' effort
  par thi - rozmarra ke kaam ke liye 'high' ya 'medium' kaafi.
- Main ab MT5 par kaafi theek kaam kar leta hoon (compile, chart par lagana,
  Strategy Tester).

## 1a. Maqsad aur dil ki baat (11 Oct raat)

- User trading se **ghar (kitchen) ka mahana kharcha** nikalna chahta hai, isi liye baar baar intraday/15m poochta hai. Claude ne hisaab dikhaya: live ~$430 par sabit tareeqe (~5-10%/saal) = mahine ka ~1,000 Rs; is capital par kharcha trading se mumkin nahi; dabao = bari lot (1.15 ghalti, August USD account).
- **User ka faisla: koshish isi mein jaari** - kuch paisa hai, kuch dost interested hain; 'raasta sahi nikal aaye to isi se baqi kaam'. Claude: faisla user ka; doston ka paisa sirf demo qaida PASS ke baad, aur unke APNE account mein (paisa un ka, faisla un ka).
- YouTube/podcast/championship: sab jhoot nahi, magar survivorship bias; asli pehchan = saalon ka verified record (Myfxbook) + risk/girawat ki khuli baat.
- Is chat ke sawal-jawab: Hunt bhai (sabaq, tareeqa nahi); RSI2 vs Kachhua ulte hain (dip vs breakout) - gold trend wala = Kachhua, S&P = RSI2; Darwinex SP500 = wahi S&P chhota data (doosri tasdeeq).

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
| **LIVE** | 253687618 | Exness MT5 **StandardCent**, `XAUUSDc`, USC, Hedge, 1:2000 | **Swap-free (Islamic)**. 0.01 lot = $1 harkat par 1 USC. **56 symbols** (XAUUSDc, BTCUSDc, ETH, EURUSDc, USDJPYc...; 10 Oct). **BTCUSDc:** 0.01 lot = $1 par 0.01 USC, 24/7, **swap long -1763.7 points = BUY 1 lot -17.6 USC/din (Jumma 3x), swap short 0** (ye Specification ka number hai; **asal katauti pakki NAHI** - 11 Oct durusti neeche) |
| **DEMO** | 472540009 (110 jami lots, k1) aur **472716649** (Exness-MT5Trial16, Hedge - **Radar EA demo isi par**); teesra **474651829 Pro** (Exness-MT5Trial15). **User (11 Oct): sirf StandardCent wala LIVE hai, baqi sab DEMO - testing ke liye khole.** Demo MT5 mein live 253687618 bhi saved hai - EA wale chart ke saath live par login kabhi nahi | Exness-MT5Trial16, `XAUUSDm`, **USD** standard, Hedge | Contract spec mein BUY swap -513.2 points/lot/din likha mila tha (2 Oct), **magar user kehta hai gold par swap nahi katta (8 Oct)** - hisaab mein swap 0. Shak ho to MT5 ka Swap column dekho |

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
- **Kachhue ka 1D faisla chhoti TF par chalao = WOHI nateeja** (10 Oct, user ka
  andaza, pehle se likhe qaide par PASS): BTC 1 Jan - 10 Oct 2026, 1D / 1h / 30m
  teeno par 6 trades, 4/6, +6,720.93 - cent tak ek jaise. Faisla daily close
  par hai, chhoti TF sirf SL ko bareeki se dekhti hai. 15m par "behtar entry"
  dhoondna (pullback ka intezar) NAYA system hoga - alag naap chahiye.
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
  live cent par BTC hai (10 Oct) -> demo ke baad live ka raasta khula. Andar ke nateeje dekh
  kar market hatana/chunna mana (overfitting).
- **BTC par Kachhua 2019 ke baad bhi musbat - pehle se likhe qaide par SABIT**
  (10 Oct, TradingView CRYPTO:BTCUSD 1D): 2019-aaj 81 trades, jeet 43%, Exp
  +0.58R (+-0.47), PF 2.67, kul +47R. MT5 (Exness) par bhi 79 trades +44R - do
  alag data, ek jaisa. Magar ye wohi purani history hai (naya saboot nahi) aur
  +-0.47 bara hai; asal imtihan demo par aage ki trades. 2010-18 ke jungli
  saal (+2.41R) ko aaj ki umeed mat samjho.
- **Hunt bhai (1980, chandi) - copy karne wala tareeqa NAHI** (11 Oct, user ka sawal): Nelson Bunker + William Herbert Hunt, daulat tel ki wirasat se (trading se nahi). Chandi ka 'corner' (bazaar ki supply khareed lena) bohot udhaar (margin) par, koi SL nahi, yaqeen 'qeemat upar hi jayegi'. ~$6 -> ~$50 (Jan 1980), phir exchange ne margin ke qaide sakht kiye, 27 Mar 1980 'Silver Thursday' margin call poori na hui. Bankon ka ~$1.1 arab qarz Hunts ko bachane ke liye nahi, brokers/bankon ko girne se bachane ke liye tha. 1988 adalat: bazaar ki manipulation, phir bankruptcy. Sabaq: bara yaqeen + udhaar + SL nahi = arab-patti bhi doob jate hain - wohi naqsha jo jami kitab mein hota hai.
- **Mashhoor 15m ORB (Crabel) gold par SABIT NUQSAN** (11 Oct, 1995 trades 2019-26): Exp -0.08R (±0.06), sirf 2022 musbat. Gold par har intraday idea ab tak manfi ya sifar (Pro Box, SMC Trend, Seerhi, Fishing, Chakkar, ORB); sirf daily trend (Kachhua) musbat. Har nayi koshish ke saath qismat wala PASS ka imkaan barhta hai - koshishein gino.
- **Connors RSI(2): S&P par SABIT, gold par sifar** (11 Oct, pehle se likha sakht qaida): S&P 2003-26 257 trades +0.114R (±0.049), 2019 ke baad bhi musbat (kitaab 2008 ki = naya data). Gold 2000 se +0.005R (±0.048), net -19%. Har idea har market par nahi chalta - idea ke apne market par naapo. Faida chhota (~1.2R saal), DD bhi chhota (3%).
- **ETH par Kachhua SABIT NAHI** (11 Oct, pehle se likha qaida): 2019 se ~88 trades, Exp +0.22R (±0.39) - musbat magar shor se alag nahi. MT5 (Exness) par bhi 86 trades +0.19R - do data ek jaise. BTC (+0.58R) jaisa nahi; ETH ko Radar mein nahi jorna.
- **SMC Coach Scalp sc6.2 (user ki v5 script, EMA 50/100) - SABIT NAHI** (12 Oct, pehle se likha qaida, OANDA:XAUUSD): 15m (Jul-Oct 2026, sirf 3 mahine data) 111 trades, jeet 39.6%, Exp +0.122R (±0.279), PF 1.19, +13.2%, DD 9.8%; 1H (Jan 2025-Oct 2026) 145 trades, jeet 42.1%, Exp +0.215R (±0.249), PF 1.35, +34.4%, DD 9.75%. Dono musbat magar shor se alag nahi (Exp - 2SE < 0) = QAIDA FAIL. Ye arsa gold ki bari tezi ka tha. User ne 'kisi tarah profit' ke liye tuning maangi - mana kiya (overfitting). Phir MT5 (Exness XAUUSDm M15, data 2021-Oct 2026, DXYm mila) = **FAIL**: 1487 trades, jeet 33.4%, Exp -0.037R (±0.071), PF 0.94, -55.2R, girawat 119.6R, balance 10,000 -> 4,844; saal 2021 -37 / 2022 -24 / 2023 -49 / 2024 +3 / 2025 +10 / 2026 +41R - musbat sirf gold ki bari tezi mein. TradingView ka +0.12R sirf usi tezi ke 3 mahine the. **Idea BAND** - gold par 7wa intraday FAIL. User ne 1H par bhi chalaya (wohi EA m1): 429 trades, jeet 36.8%, Exp +0.067R (±0.138), PF 1.10, +28.7R, girawat 22.6R, saal 2021 -10 / 2022 +4 / 2023 -6 / 2024 -2 / 2025 +29 / 2026 +14R = FAIL (faida sirf 2025-26 ki tezi se). 4H bhi: 188 trades, Exp +0.013R (±0.208), PF 1.02, +2.4R, 1/6 saal musbat = FAIL. 15m/1H/4H teeno FAIL - TF badal badal kar aazmana bhi ek nayi koshish ginti hai; is idea par ab koi TF nahi.
- **'Low toot kar wapas high' (ICT Judas / SFP / Turtle Soup) gold par ULTA nikla** (12 Oct, JAS Swing Fail GINTI g1, OANDA:XAUUSD 4H, data 2023-2026): 239 waqiat, A (wapas toota) sirf **28.0% (±6.5)**, ittefaq 50% = qaida 'ITTEFAQ' (shakal asli NAHI). Low toota -> high 35.6% (104), high toota -> low 22.2% (135); har saal 25-29%. Matlab: swing toot-ta hai to ~72% dafa usi taraf aage jata hai - toot aksar ASLI hota hai, jhoota nahi. Ye Kachhue (toot ke saath chalo) wali baat ki tasdeeq hai, nayi strategy nahi. 1W par bhi (2011-26): 150 waqiat, A 25.3% (±8.2) - wahi.
- **Gold ka ghanta ba ghanta (12 Oct, JAS Ghanta Ginti h1, OANDA 1H, sirf ~1.5 saal data):** harkat sab se zyada 18:00-19:00 PKT (~0.61%/ghanta, NY khulna + 17:30 US news), 06:00 (0.56%), 17:00/20:00 (~0.52%); sab se kam 02:00-03:00 (0.27-0.32%, roz ka break) aur 09:00 (0.26%). Shaam 6-9 PKT raat 2 baje se ~dugna. Rukh: sirf 16:00 PKT ★ (+0.03% ±0.027) = 24 mein 1 = ittefaq jaisa, trade nahi. Faida: risk/SL/news ke liye, rukh ke liye nahi.
- **Kal ka high/low toot kar band hone ke baad agla din - koi faida NAHI** (12 Oct, JAS Kal-Toot Ginti k1, OANDA:XAUUSD 1D, 2000 se 6919 din): HIGH ke upar band (1779) agla din -0.002% ±0.048, LOW ke neeche (1470) +0.057% ±0.059, beech (3670) +0.062% ±0.037; FARK -0.05/+0.01/+0.02% - koi ★ nahi, 5 din bhi sab ~+0.2% (aam tezi). Ek din ka toot kuch nahi batata; Kachhua 10 din ki naali + lamba rukna hai - farq wahi.
- **Kis TF par candle ka rang chalta hai? (12 Oct, JAS TF-Rang Ginti r2, OANDA:XAUUSD, 2000 se, doji nahi):** 1m-4H RUKH RAKHE -1.8 se -4.0 (±0.6-1.1) ★ = rang halka sa PALAT-ta; **1D -5.7 ±2.4 ★ (bhi palat-ta)**; 1W +1.5 ±5.4 = shor. **DURUSTI:** r1 ka '1D +5 / 1W +17 = rukh chalta' 1970s ke purane data ki milawat thi - galat nikla. Matlab: kisi bhi TF par 'pichli candle ka rang' agli ka andaza nahi deta (farq 2-6%, spread se chhota). Kachhua candle ka rang nahi, 10 din ki naali ka toot + hafton rukna hai - us ka saboot alag (Swing Fail: toot ~72-75% aage jata hai). Hari %: 1D 52.5%, 1W 55.5% = gold ki lambi tezi.
- **Swap: Specification ka number = asal katauti NAHI** (11 Oct durusti, user: "Muslim mulkon mein
  Exness swap nahi kaat-ta"). Saboot: demo 472716649 ki 18 gold lots (9 Oct Jumma ko khuli,
  Jumma ka rollover guzra) - equity - balance = -89.03 = sirf Profit column, yani swap 0,
  halanke spec mein gold BUY -513.2 likha hai. Swap-free account par spec phir bhi number
  dikhata hai. Neeche wali BTC baat isi liye SHAK mein hai: pakka tab jab raat-bhar BTC/US500
  position ke **Swap column** mein asal number dikhe (Trade tab -> right-click -> Columns -> Swap).
  Tester (Radar EA) spec ka swap kaat-ta hai - is liye faisle 'bina swap' par sahi the.
- (10 Oct, ab shak mein) **BTC ki BUY lots par swap katta hai - live cent par bhi** (BTCUSDc
  Specification): swap long -1763.7 points, short 0. 0.01 lot BUY = -0.18 USC
  roz, 0.78 lot = -13.8 USC roz (~-96 hafta, Jumma teen guna) = qeemat ka ~7.7%
  saal. Method ka "intezar muft hai (swap-free)" GOLD par sahi, BTC BUY par
  nahi - BTC ki BUY lots lambi jami rakhna har din paisa leta hai. SELL muft.
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
| `JasTideRadarEA.mq5` e1 | **Radar r3 ke qaide ka EA, ek chart se 9 market**, USD hadd 3, gold+silver ek, 1% risk (broker ka hisaab), SL server par + roz aage. Default SIRF DIKHANA. Tester ke aakhir mein Journal mein R ka hisaab + pehle se likha qaida | **Compile ✅ (9 Oct). Tester ✅ QAIDA PASS (10 Oct): 2019 se 414 trades, +40.39R bina swap, girawat 12.7R - magar BTC +44.2R, baqi 7 market -3.9R.** **DEMO CHALU 11 Oct ~21:10 PKT** - demo 472716649, XAUUSDm Daily chart, InpTrade true, 9 markets, panel 'TRADE CHALU'. Faisla kam az kam 3 mahine + 15 band trades ke baad (~Jan 2027). Live cent par BTC hai (BUY swap katta hai) - live ka faisla demo ke baad |
| `JasOrbEA.mq5` o1 | **Opening Range Breakout** (Crabel 1990): NY ki pehli 15m candle ka toot, SL doosra kinara, 15:50 NY band, din mein ek, 1% | Compile ✅. **Tester FAIL (11 Oct, gold 2019-26): 1995 trades, Exp -0.083R (±0.063), PF 0.86, -165R, 1/8 saal musbat = sabit nuqsan.** Demo/live nahi |
| `strategies/jas_rsi2_test.pine` c1 | **Connors RSI(2)**, 1D: SMA200 rukh, RSI(2) <10 BUY / >90 SELL, SMA5 par band, SL 3 ATR, 1%. QAIDA row khud PASS/FAIL | Compile ✅. **Gold FAIL (2000 se +0.005R ±0.048 = sifar).** **S&P (OANDA:SPX500USD 2003-26) PASS: 257 trades, +0.114R (±0.049), dono daur musbat, DD 3% - magar chhota (~1.2R saal).** Agla: live par US500? phir demo |
| `JasRsi2EA.mq5` c1 | RSI(2) ka EA, sirf US500 Daily (demo 472716649, Radar ke saath, magic alag) | **Compile ✅ (11 Oct raat, 0 errors)**. Live cent par **US500c hai** (11 Oct) - live sirf demo qaida PASS ke baad, user se poochh kar |
| `JasTideEA.mq5` t4 | Turtle/Donchian 1D, ek position, SL, 1% risk | Compile ✅. MT5 test t3: 132 trades, PF 1.23, DD 46% (Pine: 458, PF 1.56, DD 21%). Shak: demo swap. t4 swap alag ginta hai - **test baqi** |
| `docs/tide_rehnuma.html` | Tide Seekh ki Roman Urdu guide ([artifact](https://claude.ai/artifact/5w4xy7FcTuCnQqxbb3A6C2)): qaide, panel rows, roz ka kaam, MT5 order/SL, naap, demo plan | ✅ 8 Oct |
| `indicators/jas_tide_smc.pine` + `strategies/jas_tide_smc_test.pine` s1 | **Tide ka ishara (1D, naapa hua) + SMC nishan sirf dikhawa** (MA21/63, BOS/CHOCH, DZ/SZ, FVG, LGB - Tide ki taraf gehre, ulte halke; koi filter nahi), mashwara BTC 4H. Tester: faisla 1D, amal chart TF par (1D = seekh_test jaisa; 15m = wohi daily faisla, SL har 15m) - aakhri 6 trades table mein taake 1D vs 15m milayein | Tester compile ✅, **BTC 1D (2009-2026): 164 trades, jeet 47.6%, PF 3.84, DD 5.3%** (purane jungli BTC saal shamil). **1D = 1h = 30m (2026, cent tak) - qaida PASS.** Indicator s1 compile ✅ (BTC 4H, 164 trades = tester); s1.1 (table ki 7+2 durustiyan, engine wahi) compile ✅ 1D/4H/1h/15m - table har TF par ek, aakhri trade tester se ek. **s2.2 (11 Oct): har TF par Tide dabba (shart / 1R risk / abhi / nateeja) + 'MT5 MEIN' row + lot - compile ✅ BTC 1H (164 / 2019 se 81 SABIT); s2.4 (likhai abhi ki qeemat par label mein) compile ✅ BTC 1H, wahi numbers (11 Oct 19:30)** |
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
