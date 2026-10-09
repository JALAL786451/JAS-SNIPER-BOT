# MERI KAHANI — har nayi chat yahan se shuru kare

Ye file is liye hai ke chat full ya reset ho to Jalal ko apni kahani **0 se na
dohrani pare**. Har nayi chat pehle ye file, phir `ABHI-KAHAN-HAIN.md` parhe.
Tafseel ke liye: `METHOD.md` (method + naape hue number), `EA-LAWS.md`
(qanoon), `EA-QAWAID.md`, `EA-CHECKLIST.md`.

Aakhri update: 7 October 2026.

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
- Main ab MT5 par kaafi theek kaam kar leta hoon (compile, chart par lagana,
  Strategy Tester).

## 1b. Live kitab ka haal (2 Oct raat ~8 PM)

99 position, BUY 0.68 (ausat 4204.75) / SELL 0.68 (ausat 4162.05), **NET 0 (jami)**,
Close All **-2,920 USC** (subha -3,277 tha; user ne haath se SELL upar shift kiye).
Saara nuqsan 28 Sep ki **0.59 BUY @ ~4213** mein. Aaj ki lots theek jagah: SELL upar, BUY neeche. Saara nuqsan BUY mein; SELL taqreeban barabar. User ka
iraada: SELL khatam, BUY rakho - tukdon mein (har dafa 0.20 se zyada nahi),
"ek band, ek khule" (nayi lot tabhi jab purani band ho), news ke waqt kuch nahi.

## 2. Accounts

| | Number | Qisam | Note |
|---|---|---|---|
| **LIVE** | 253687618 | Exness MT5 **StandardCent**, `XAUUSDc`, USC, Hedge, 1:2000 | **Swap-free (Islamic)**. 0.01 lot = $1 harkat par 1 USC |
| **DEMO** | 472540009 | Exness-MT5Trial16, `XAUUSDm`, **USD** standard, Hedge | Contract spec mein BUY swap -513.2 points/lot/din likha mila tha (2 Oct), **magar user kehta hai gold par swap nahi katta (8 Oct)** - hisaab mein swap 0. Shak ho to MT5 ka Swap column dekho |

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

## 5. Mere tools (repo mein) - kya hai, kis haal mein

| File | Kya karta hai | Haal |
|---|---|---|
| `JasDeskView.mq5` v4.2 | **Sirf parhta hai.** Close-All ginti, lots by size, ausat, NET, BARI LOT KI JORI, PLAN A/B + "NET baad mein" | ✅ Live par chal raha. Kami: "ek taraf band" line sirf ek taraf ka fasla batati hai, poori kitab ka nahi |
| `JasJoriClose.mq5` s1 | **Script.** Bari lot ki lot-barabar jori **Close By** se band, ek Yes/No | ✅ Demo 150/150, **live 64/64 (+550.70 USC, 1 Oct)**. Abhi sasti BUY pehle chunta hai - user upar wali BUY pehle chahta hai (option banana baqi) |
| `JasTideEA.mq5` t4 | Turtle/Donchian 1D, ek position, SL, 1% risk | Compile ✅. MT5 test t3: 132 trades, PF 1.23, DD 46% (Pine: 458, PF 1.56, DD 21%). Shak: demo swap. t4 swap alag ginta hai - **test baqi** |
| `docs/tide_rehnuma.html` | Tide Seekh ki Roman Urdu guide ([artifact](https://claude.ai/artifact/5w4xy7FcTuCnQqxbb3A6C2)): qaide, panel rows, roz ka kaam, MT5 order/SL, naap, demo plan | ✅ 8 Oct |
| `indicators/jas_tide_seekh.pine` + `strategies/jas_tide_seekh_test.pine` | **Tide (kachhua 1D) ka seekhne wala panel** (8 Oct, user: B + nayi file): har qaida ✓/✗, plan, lot, sarakta SL, purane nateeje R mein, switch "2R par aadhi" (BAND = 458 wala). Strategy copy mein v1.1 ki kharabiyan durust | Bana, **compile baqi**. Pehle Tester, phir demo |
| `indicators/jas_seerhi.pine` + `strategies/jas_seerhi_test.pine` | **Top-down seekhne ka script** (8 Oct, user ne faisle Claude par chhore): 1D rukh (structure + trend line + MA) -> 1H pullback -> 1H entry, SL/TP1(aadhi+BE)/TP2, lot, har qadam ka ✓/✗ panel. Strategy copy Tester ke liye | Compile ✅ (8 Oct, s1.2 panel). **1H Tester 2025-26: 72 trades, -5.7%, PF 0.86 = koi edge sabit nahi.** Settings ki tuning nahi; agla jaanch wala tester (ABHI-KAHAN-HAIN) |
| `indicators/smc_coach_pro_v4.pine` | **v3 + Pine v6 + kharabiyan durust + PIP HISAAB** (1D/1H candle ka raasta pip mein + har pip par waqt/volume ka profile) | **v4.1 compile + chal raha (8 Oct)**, 1m/15m/1h/1D par number aapas mein milte hain. Sirf observation. v3 waisi rakhi hai |
| `indicators/smc_coach_pro_v3.pine` | SMC dashboard (pehle v2). Tables sirf 1m/15m par, 9 TF ki chalti candle, BUY/SELL pressure, MA21/63, chhupa tracker + expectancy line, MTF 90% aur 15m signal | ✅ Compile hua (2 Oct). Naye signal sirf TEST ke liye |
| `indicators/jas_pro_box.pine` + `strategies/jas_pro_box_test.pine` | Teen tareeqe (MA pullback / candle / SMC sweep) ki ginti | Sirf observation. 15m har jagah manfi; C·SMC 1H-4H musbat magar ginti kam. User ne kaha 1D results achhe nahi |
| `JasChakkarEA.mq5` k4 | **EA, "trend ko dost bana kar".** Rukh ke saath 0.01 jhukao (NET 0.05 tak), ulti chaal par hedge, nuqsan par kuch band nahi, bari lot ki faide wali jori, Close All +30. Qaide Q0-Q9 `ABHI-KAHAN-HAIN.md` mein | BTC demo par. k1 (gold, sirf SELL chakkar) aur k3a demo par chale; **k4 compile ka jawab baqi** |
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
  `JAS-DESK-V3-0110 — ABHI-KAHAN-HAIN.md parho aur wahin se shuru karo. Branch: claude/gifted-faraday-zs7wcz`

## 8. Ye file kaise zinda rahe

Har chat ke aakhir mein (ya koi bara faisla/nateeja aaye to foran) Claude:
- naya **faisla / nateeja / sabaq** yahan ya `ABHI-KAHAN-HAIN.md` mein likhe,
- `ABHI-KAHAN-HAIN.md` = **abhi kya chal raha hai** (badalta rehta hai),
- `MERI-KAHANI.md` = **pakki baatein** (kam badalti hain),
- commit + push kare.
