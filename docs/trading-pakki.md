# TRADING - pakki baatein (13 Oct tak `TRADING-MERI-KAHANI.md` thi)

Nayi chat pehle `TRADING.md` parhti hai; ye file sirf zaroorat par (`grep` se). Tafseel:
`METHOD.md` (method + naape hue number), `EA-LAWS.md`, `EA-QAWAID.md`, `EA-CHECKLIST.md`,
sabaq ke poore number `docs/sabaq-tafseel.md`.

Aakhri update: 13 Oct 2026 raat (saatvi chat). Kaam ki branch `claude/jas-desk-v3-0110-yu3w2h`.

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
- **Usage (13 Oct raat, chhati chat ke baad):** hafte ki limit 71% (reset Itwar 18 Oct 02:00 PKT), session 32% (reset Budh 02:00). 'Usage by product: Claude Code 100%' = istemal ka HISSA (sara Claude Code se), limit nahi. Pehle: 12-13 Oct 56%. Is chat mein ek 8-agent jaanch hui thi. Limit 50% se upar ho to agent/workflow bilkul nahi, chahe 'ultracode' chalu ho.
- **Baar baar reminder NAHI (12 Oct raat):** jawab ke aakhir mein '19 Oct demo panels' jaisi yaad dihani mat do. Sirf user ki request par mashwara + us request ka agla qadam.
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

## 1-NAYA. Test ka naya qaida (13 Oct, user 'D' - purane 'har koshish band' ki jagah)

User: "koshish jaari rahegi jab tak PASS na aaye". Qaida:
1. Har naya idea sirf **2021-01-01 se 2024-12-31** (TALAASH data) par - jitne idea chahein, settings bhi badal sakte hain.
2. Jo TALAASH par PASS (trades >= 100, Exp - 2SE > 0, saal ka hissa musbat), woh **2025-01-01 se aaj** (IMTIHAN data) par **ek dafa**, bina kisi tabdeeli.
3. IMTIHAN par Exp > 0 aur trades >= 30 = **ASLI PASS** -> demo. IMTIHAN FAIL = woh idea band (IMTIHAN data dekh kar tabdeeli MANA - warna woh bhi talaash ban jata hai).
4. Har koshish ginti mein likhi jaye (`TRADING.md` sec 8). 13 Oct tak gold intraday: 8 FAIL (purane qaide se).
4b. **TradingView (lamba daily data) par (13 Oct):** TALAASH = data shuru se 2018, IMTIHAN = 2019 se aaj (ek dafa). MT5 Exness par wahi 2021-24 / 2025-aaj (Exness data 2021 se; index ka Sep 2025 se).
4c. **Ek market chunna (13 Oct, user ka sawal + #15):** TALAASH mein nateeja dekh kar market chunna jaiz, magar tab IMTIHAN SAKHT: Exp - 2SE > 0 (sirf Exp > 0 nahi). Isi tarah IBS S&P ASLI PASS hua.
5. 2025-26 gold ki bari tezi ka daur hai - IMTIHAN par sirf BUY wala idea ittefaq se acha lag sakta hai; BUY/SELL alag dekhna.

## 1a. Maqsad aur dil ki baat (11 Oct raat)

- User trading se **ghar (kitchen) ka mahana kharcha** nikalna chahta hai, isi liye baar baar intraday/15m poochta hai. Claude ne hisaab dikhaya: live ~$430 par sabit tareeqe (~5-10%/saal) = mahine ka ~1,000 Rs; is capital par kharcha trading se mumkin nahi; dabao = bari lot (1.15 ghalti, August USD account).
- **User ka faisla: koshish isi mein jaari** - kuch paisa hai, kuch dost interested hain; 'raasta sahi nikal aaye to isi se baqi kaam'. Claude: faisla user ka; doston ka paisa sirf demo qaida PASS ke baad, aur unke APNE account mein (paisa un ka, faisla un ka).
- YouTube/podcast/championship: sab jhoot nahi, magar survivorship bias; asli pehchan = saalon ka verified record (Myfxbook) + risk/girawat ki khuli baat.
- Is chat ke sawal-jawab: Hunt bhai (sabaq, tareeqa nahi); RSI2 vs Kachhua ulte hain (dip vs breakout) - gold trend wala = Kachhua, S&P = RSI2; Darwinex SP500 = wahi S&P chhota data (doosri tasdeeq).

## 1b. Live kitab ka haal (aakhri naap 9 Oct - poora `docs/sabaq-tafseel.md` mein)

- 9 Oct 4:16 PM (Exness mobile): 167 position (BUY 103 / SELL 64), **Fully hedged (NET 0)**,
  Close All **-4,845.48 USC**, equity **43,409.42**. 2 Oct se kitab ~3 guna bari hui.
- **1.15 SELL @ 4174.488 ghalti se lagi** (0.05 lagani thi). User: **"ab mashware se kaam
  karunga"**. MT5 + mobile par One-click BAND, default lot 0.01.
- User ka iraada (2 Oct): SELL khatam, BUY rakho - tukdon mein (har dafa 0.20 se zyada nahi),
  "ek band, ek khule", news ke waqt kuch nahi.

## 2. Accounts

| | Number | Qisam | Note |
|---|---|---|---|
| **LIVE** | 253687618 | Exness MT5 **StandardCent**, `XAUUSDc`, USC, Hedge, 1:2000 | **Swap-free (Islamic)**. 0.01 lot = $1 harkat par 1 USC. **56 symbols** (XAUUSDc, BTCUSDc, ETH, EURUSDc, USDJPYc...; 10 Oct). **BTCUSDc:** 0.01 lot = $1 par 0.01 USC, 24/7, **swap long -1763.7 points = BUY 1 lot -17.6 USC/din (Jumma 3x), swap short 0** (ye Specification ka number hai; **asal katauti pakki NAHI** - durusti sec 4 "Swap" aur `docs/sabaq-tafseel.md`) |
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

## 4. Pakke sabaq (ek line har ek - poore number `docs/sabaq-tafseel.md` mein, grep se)

**Kitab / method:**
- Jami kitab ka nuqsan "bori" hai - kis lot ko kis se band karo, KUL wahi. Nateeja = (ausat SELL - ausat BUY) x lots, qeemat se nahi badalta.
- Kitab sirf "band karo, phir behtar jagah kholo" se behtar hoti hai; sirf naya kholne se ausat girta hai, nuqsan nahi.
- Kam lot khuli = kam khatra, magar wapsi lambi. Asal score EQUITY hai, band hue faide nahi.
- Jeet ki ginti nahi, jeet/haar ka SIZE: 75% jeet (Chakkar 94%) phir bhi nuqsan. Martingale / grid / lot doubling nahi (August USD account).
- Sabr jeet wali trade mein, haar wali mein nahi; SL = "kahani badal gayi". News (NFP, CPI, FOMC): 30 min pehle se ~1 ghanta baad tak nayi lot nahi (L10).
- Swap: Specification ka number = asal katauti NAHI (gold par 0 saabit, 11 Oct). BTC BUY ka swap shak mein - Swap column dekh kar pakka.
- Guzara: chhote account par kisi system se nahi; kamai capital se barhti hai, risk barhane se nahi.
- Bara TF behtar (user ka data): 1D 49.7% > 4H 43.8% > 1H 42% > 1m 37.5%.

**Test ka tareeqa:**
- 72 trades se faisla nahi. Settings ghuma kar 10 dafa aazmao to ek qismat se PASS - qaida test se PEHLE likho, har koshish gino.
- Chhota number badla aur nateeja aadha (Tide 2: 55/20 -> 51/17) = nateeja qismat par khara.
- TradingView ka PASS broker (MT5) data par dobara jaancho. IMTIHAN data chhupa rahe. MT5 Tester purane Inputs yaad rakhta hai.
- Tester ki "144 trades" = har trade ke 2 tukre (TP1 + baqi); asal ginti entries ki.
- Mashhoor kitaab / paper = zamanat nahi (Holy Grail, Gao Intraday Momentum, Crabel ORB - sab FAIL).

**Jo chala (sirf daily par):**
- Kachhua (Tide 1) gold: 50 saal, 459 trades, har daur musbat (2019 se +0.30R, ~+2% saal). 2R par aadhi band karna nuqsan deh.
- Kachhua BTC: TradingView +0.58R aur MT5 +44R - do data ek jaise. ETH, NZDCAD, forex par SABIT NAHI. 1D faisla chhoti TF par chalao = wohi nateeja.
- Radar 9 market r3 PASS (~+6.8R saal, girawat 14.9R), MT5 par bhi PASS magar faida zyada tar BTC se. Tide 2 (55/20) MT5 par girawat zyada = Tide 1 hi rahega.
- Kachhua commodity tokri ASLI PASS (#6). Kachhua 4H FAIL (#13) - trend ka faida bari TF par.
- RSI(2): S&P SABIT (+0.114R), baqi index bal-bal PASS; gold, forex, commodity par sifar.
- IBS sirf S&P ASLI PASS (#15, IMTIHAN sakht +0.029). 10 index par kinare par FAIL (#14); TOM chhota, FAIL (#5).

- **Test se pehle code ko qaide se line-ba-line milao** (29 Oct #40: code mein qaide se bahar VWAP slope shart thi - tasheeh, phir bhi FAIL).
- Dukascopy datafeed cloud (Claude) ko rokta hai; laptop par bhi 4 saath request = rok. Aahista (1 file + waqfa) chalao (29 Oct).

**Jo nahi chala:**
- Gold intraday 14 idea FAIL: Pro Box, SMC Trend, Seerhi, Fishing f1, Chakkar k4, ORB, SMC Scalp (15m/1H/4H), MTF, #30 raat/din waqt H1, #31 H4 RSI2 pullback (dono bina kharcha bhi 0/manfi), #32 daily rukh + H1 EMA20 entry (chhota SL = swap bhaari, jeet 9%), #22 Fib OTE 15m (QDM M1 2021-24, bina kharcha bhi -0.06R), #33 JAS Trend t2 4H/1H/15m (4H Exp-2SE -0.004 bal baal; edge TF ke saath ghatta), #36 HTF+AOI+M30 engulfing (bina kharcha +0.01R). #39 TV Momentum strategy H1 tokri (bina kharcha bhi -0.09R). Index: #38 failed breakdown kal H/L NY open H1 (bina kharcha +0.02R). #40 VWAP H1 (+0.01), #41 Gao-Han-Li-Zhou H1 proxy (+0.03), #42 US index raat drift (bina kharcha +0.03R raat vs +0.006 din = asar ASLI, magar kharcha + swap 0.07R > edge). Jitni chhoti trade, utna bara spread R mein.
- **#34 (28 Oct) JAS Trend t2 4H TOKRI (XAU, XAG, US500, USTEC) ASLI PASS**: TALAASH <2019 Exp-2SE +0.002, IMTIHAN 2019+ 641 tr +0.208R (Exp-2SE +0.085), 4/4 market. Akela gold 4H FAIL, tokri PASS = zyada market, chhoti TF nahi.
- Holy Grail (#1-2), Volatility Breakout (#3), Ichimoku (#7-8), Intraday Momentum (#9), Cointegration / jori (#10-11), user ka 15m $1/$2 (#12: 89,203 trades, jeet 59.8% < 66.7%, -18,446 USD).
- Ginti scripts sab ITTEFAQ: swing fail (toot ~72% aage jata hai = asli), kal-toot, candle ka rang, wick, numayan candle, FVG. Ghanta ginti: shaam 6-9 PKT sab se zyada harkat - risk ke liye, rukh ke liye nahi.
- Jori (Close By) se kul P/L / equity NAHI badalti - sirf kaun sa nuqsan pakka ho aur kaun si lot bache. Jori se pehle BACHI kitab dekho (14 Oct: bina nuqsan jori neeche wali BUY kha jati).
- **0/faida qaida + gold bullish (16 Oct):** qeemat ke paas 0.01 SELL = dip par BUY ka zakheera: dip par faide wali SELL band = NET BUY neeche (had 0.10); oopar jaane par nayi 0.01 SELL = faida taala. Hedge mein faide wali lot hamesha trend ki taraf hoti hai - usay band karna NET ko trend ke khilaf karta hai.
- **Balance vs Equity (16 Oct):** asal paisa = EQUITY. Balance sirf band trades ka hisaab; Close All par balance utar kar equity ke barabar ho jata hai (50,089 -> 43,743 USC). Hedge (NET 0) mein equity har qeemat par wahi.
- **Sab band karna ho to Multiple Close By, Close All nahi (16 Oct):** Close By mein spread nahi - 1.33/1.33 lot par ~27 USC bachat (cent). USD account par yahi $27 hota.
- Claude (16 Oct): har faisle par saare raaste khud saamne rakho (jori: QAREEB / sasti / mehngi) - user ke kehne ka intezar nahi. User ne QAREEB khud sujhaya, Claude ko pehle batana chahiye tha.
- Hunt bhai (1980 chandi): bara yaqeen + udhaar + SL nahi = arab-patti bhi doob jate hain.
- AAINA (19 Oct): TV ~5000 candles (5m = 1 mahina); 10 qareebi ka ausat = qismat (1 minute mein -1.09% -> +0.56%) - hamesha SAB mauqon ka ausat + 2SE; gold 5m/15m/1D nishani = shor.
- AAINA SAAYA record (20 Oct, a12): 15m 99 saaye = bunyaad (sikka), kal 1D rang 15m ko kuch nahi batata; 1D 100 saaye +8 -> 300 saaye +5 (hadd ±6) = shor. Chhoti ginti ka farq ginti barhne par ghatta; muqabla hamesha ISI muddat ke bunyaad se.
- Claude (20 Oct): AAINA ka agla build hamesha USI file mein tweak (a12 -> a13, sab purana qaim) - user ne alag 200 line script rad ki.
- AAINA AGLI (20 Oct, a14): 15m agli candle rang ~sikka (51.6% vs 49.6%, hadd ±1.9); 1D 54% vs 51% sirf kal ke 1D rang se - 1W/1M kuch nahi jodte. Bari TF ka faida chhoti candle mein sqrt(ginti) patla (1D->15m ~10x). Record jori (paired) hadd se.
- EA suffix "auto" (20 Oct): EA ko apni market list wale chart par lagao (Rsi2 XPTUSDm par = 3 market "nahi mila"); EA dobara lagao to Inputs (markets, magic, TRADE) check - Commodity gold list par chal raha tha.
- AAINA 1D andaza (21 Oct): 2019+ Strategy Tester PF 0.968 (spread se pehle ~0) - faida sirf purane dor ka; Pine aaina se trade NAHI, sirf dekhna.
- TOKRI (28 Oct, #26): ek market par Exp-2SE kinare par (gold 1D -0.01R) = trades kam, idea bekaar nahi; wahi qaida 6 market = 931 tr PASS, IMTIHAN +0.214R. Tweak se nahi, zyada MARKET se.

- Asli spread (Exness Demo, 31 Oct, `JasSpreadNaap`): US500 0.40, USTEC 1.12, gold 0.24 = 0.004-0.006% - Python ka 0.03%/taraf 10-16 guna zyada tha; chandi mehngi (0.044%). Chhoti TF ke FAIL dobara (pehle se likh kar).

## 5. Mere tools

Har file ki ek line `CLAUDE.md` mein, lambi kahani `docs/files-tafseel.md` mein, purani tools
table `docs/sabaq-tafseel.md` mein. Khule chhote kaam: JasDeskView ki "ek taraf band" line sirf
ek taraf ka fasla batati hai; JasJoriClose abhi sasti BUY pehle chunta hai - user upar wali BUY
pehle chahta hai (option banana baqi).

## 5b. User ke trading qaide jo EA mein jaate hain (3-4 Oct)

- **Nuqsan par kabhi band nahi** - akeli lot ho ya jori, sirf 0 ya faida. Jab koi choice ho, woh chuno jo 0/faida de.
- **Close All** jab SELL + BUY mila kar faida ho, phir rukh dekh kar naya setup.
- **Trend is our friend** - rukh ke khilaf lot nahi. Lot kabhi 0.01 se bari nahi.
- Hedge zaroorat par, magar zyada der nahi. Seconds ka hisaab.
- Equity ka khayal sab se upar.

- **User ka faisla (17 Oct):** koi EA / Pine qaidon ke khilaf live par kabhi nahi; live sirf 6 mahine demo nateeje ke baad. Claude pehle live ka mashwara na de.

## 6. Kaam ke qaide jo seekhe gaye (dobara ghalti na ho)
(MQL5 ke qaide - StringFormat, Pick(), build number, cloud compile - `CLAUDE.md` mein.)

- Script **Scripts** ya Experts folder - dono chalte hain (nishan alag hota hai).
- Live par script/EA chalane se pehle: Algo Trading hara, kaam ke baad **laal**.
  JasDeskView ko Algo Trading ki zarurat nahi (Allow Algo Trading khali).
- MetaEditor warning "return value of 'OrderCalcProfit' should be checked" ko bhi theek karo - na theek ho to hisaab 0 maan kar ghalat faisla ho sakta hai.
- User Claude app par chat karta hai; lambi chat + bohot screenshots se tokens jaldi khatam hote hain. Bara kaam ho to nayi chat.
- **Chhota jawab (A / B / D) aaye aur do sawal khule hon to ek line mein
  poochho kis ka jawab hai.** 7 Oct: "A" SMC Pine script ka tha, Claude ne
  EA ka samjha aur ghalat file bana di (wapas li gayi).

## 7. Routines / settings (claude.ai par)

- Gold update: **din mein 1 dafa**, Peer-Jumma 6:05 PM PKT, message sirf ahem
  din par (pehle har ghante thi - usage kha rahi thi).
- "Usage credits" switch OFF. $100 cloud credit muft mila (claim karna).
  "Full reset" muft button Oct 22 tak.
- **Usage naap (13 Oct, saatvi chat):** nayi chat shuru hote hi ~1 lakh token - app ki apni
  hidayat + tools ~40-60k, files ~15k (MERI-KAHANI 43 KB thi, ab 14 KB), har tool qadam par
  poori chat dobara parhi jati hai. Chat **Opus + xhigh** par khuli thi - rozmarra ke liye
  effort medium/high, chhote kaam Sonnet. Nayi chat `main` par khulti hai (files wahan nahi) -
  kaam ki branch dhoondne mein 3-4 faltu qadam.
- Lambi chat zyada usage khati hai - kaam bara ho to **nayi chat** + code:
  `TRADING — repo JALAL786451/JAS-SNIPER-BOT, branch claude/jas-desk-v3-0110-yu3w2h. Sirf TRADING.md parho aur wahin se shuru karo.`

## 8. Ye file kaise zinda rahe

Chat ke aakhir ka qaida `TRADING.md` sec 9 mein. Yahan sirf PAKKI baatein (kam badalti hain);
naya sabaq sec 4 mein EK line, poore number `docs/sabaq-tafseel.md` mein.
- **Koshish na rokna (31 Oct, user):** Claude ne "bas, ab ruk jao" kaha; user ne mana kiya aur "teacher" misaal di (ek formula, sab ke liye ek sakht paper, behtareen chuno, phir naya paper) -> #52 USTEC IBS SELECT -> #53 FTMO 83/0 (#49 69/14 se behtar). Sabaq: haar ki ginti nahi, nateeja dekho.
