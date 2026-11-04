# Sawal-Jawab (user ke dohraye sawal) - pehle `grep -i <lafz> docs/sawal-jawab.md`

Har jawab 1-2 line. Naya pakka jawab mile to yahan EK line jodo (lafz | jawab | tareekh).

| Lafz | Jawab | Kab |
|---|---|---|
| TV | TradingView (chart, Pine, Strategy Tester). User ne kaha "TV" hi likho. | 17 Oct |
| VPS / laptop band | Laptop ya MT5 band = EA band (na trade khule na band ho). MQL5 VPS ~$10-15/mahina (Navigator -> account right-click -> Register Virtual Server -> Migrate; phir laptop Algo Trading band). User: demo ke liye abhi NAHI - dobara mat chhero. | 20 Oct |
| broker par nahi mila / suffix '' | EA suffix "auto" chart ke symbol se - chart EA ki apni list ka ho (Rsi2 = US500m, Commodity = XPTUSDm), warna suffix khali. | 20 Oct |
| a13 / AGLI candle | `jas_aaina.pine` Settings 6: agli chart candle hari/laal % (isi nishani ke mauqe) + saaya candle + ✔/✖ + record 2 qataren vs bunyaad. a12 ki tweak, alag file NAHI. | 20 Oct |
| CFD | Qeemat par sauda, asli cheez nahi (Exness USTECm). QQQ asli share. Chaal wahi, kharcha zyada. | 17 Oct |
| TP / Kachhua | Tide/Kachhua mein TP jaan boojh kar NAHI; sarakta SL (5 candle low). Bari jeet hi faida; 2R par band = nuqsan deh. | 17 Oct |
| JasTideEA vs JasTideRadarEA | JasTideEA purana (sirf gold, 2R aadhi band, kamzor) - hataya. JasTideRadarEA (9 market) demo par. TV "JAS Tide Test" = `jas_tide_seekh_test.pine` = Radar ke qaide. | 17 Oct |
| PASS EA | Demo: TideRadar (gold+8), TideRadar Commodity, Rsi2. Ruka: JasIbsEA i3. | 17 Oct |
| RSI2/IBS vs Tide | Ulti taraf trade NAHI - ulta MIZAAJ (dip vs toot), alag halaat mein kamate hain = tawazun. | 17 Oct |
| Ulta EA | NAHI: usi account par = 0 minus dugna kharcha (hedge); akela = jeetne wale ke khilaf. | 17 Oct |
| 15m / 30m TV test | TV par 15m/30m data sirf 3-5 mahine = test NAHI. Lamba test MT5 Tester / Python. | 17 Oct |
| 200 had | Exness Real 17 Oct se khuli + pending 200 max. 16 Oct: 183 pos. | 16 Oct |
| Hedge / jori | NET 0 = nuqsan ruka (swap-free). Jori se equity nahi barhti, sirf ginti kam. Qeemat ke paas SELL = zakheera, mat jorna. | 17 Oct |
| Live kab | 6 mahine demo ke baad hi; pehle live ka mashwara NAHI. | 17 Oct |
| Token / MB | 1 token ~4 harf. Nayi chat ~50-60k shuru (app ki hidayat). Lambi chat har message mehngi. | 17 Oct |
| Usage reset | Hafte ki limit Itwar 02:00 PKT reset. | 17 Oct |
| Website par Pine | Pine sirf TradingView par chalta; apni site par Python/JS mein dobara likhna padta. | 17 Oct |
| USTEC data | Exness USTECm sirf Sep 2025 se. QDM: Dukascopy USATECHIDXUSD M1 -> Export Generic bar format; 2021-22 repo `data/ustec/` mein (18 Oct), 2023-24 baqi. | 18 Oct |
| USTEC_x100m | Contract 100 (USTECm = 1). Qeemat wahi; USTECm lo. | 17 Oct |
| EMA vs SMA / 5000 | TV had 5000 candle; length <= 4990. EMA nayi candle ko zyada wazan. | 17 Oct |
| QuantDataManager / QDM | Free, `C:\QuantDataManager125\QuantDataManager.exe` (desktop shortcut nahi bana - koi masla nahi). License verify ✅ 17 Oct. | 17 Oct |
| Desktop access | Cloud chat aap ka PC nahi chala sakti; computer use mehnga + live MT5 ka khatra - user click kare, Claude bataye. | 17 Oct |
| Fib indicator / jas_fib_swing | `indicators/jas_fib_swing.pine` f5: 15m chart rakho (1m par history kam = trade kam). Table: AAJ = sirf aaj, "Sab din" = chart ki poori history. SL = 1% equity. | 18 Oct |
| Token zyada kyun / 800 token | Har tool qadam par poori chat (screenshots, code) dobara parhi jati hai. Lambi chat = har qadam mehnga. Kaam 1 qadam mein; ~15 msg par chat khatam. | 18 Oct |
| MT5 login / connect nahi | Net chale magar MT5 na jure = Exness server (weekend maintenance) ya ISP naka. Laptop + phone ek WiFi = ek raasta. Test: mobile data ya VPN (1.1.1.1). 18 Oct khud theek. | 18 Oct |
| 6 trillion / market band nuqsan | 6-7 trillion LEN-DEN hai, munafa nahi. Band = paisa wahin, sirf haath badalna ruka. Asal khatra Monday ka gap. | 18 Oct |
| Exp - 2SE | Exp = fi trade ausat R; SE = SD / jazar(trades) = qismat ki gunjaish; Exp - 2SE > 0 = ~95% yaqeen munafa qismat nahi. | 18 Oct |
| tokens nayi chat | Nayi chat pehla message ~1 lakh (40-60k app ki apni), phir sasti; lambi chat har message par sab dobara parhti hai. | 18 Oct |
| hidayat / marzi | User ki saari hidayat `docs/roznamcha/HIDAYAT.md` - sirf grep, jab yahan / TRADING.md mein na mile. | 18 Oct |
| 9 SELL ek qeemat / ek jagah kai ticket | Live 4179.94-4179.99: 9 SELL x 0.01, 9 Oct 10:45:37-38 server (PKT 3:45 PM), har ~0.25 sec, comment khaali = hamara EA / JasJoriClose NAHI, broker khud nahi kholta. User sirf Exness mobile app se kholta hai (MT5 se nahi) -> app ke kai tap / net atka (orders qatar mein). Pakka: Exness support se ticket 1915312656 ka source. CSV `data/kitab/`. | 18 Oct |
| TradeZella | Journal + manual replay backtest (paid). EA test ke liye zaroori nahi; free replay = TV Bar Replay. | 18 Oct |
| har TF chalti candle / current status | `indicators/jas_tf_live.pine` l2 (19 Oct, compile ✅): 1m-1M chalti candle - rang, chal, range, kahan, body, baqi; past nahi, sirf dekhna. | 19 Oct |
| Tide+SMC table transparent | `jas_tide_smc.pine` s2.9 (19 Oct): Settings 5 "Table transparent" + kitna (85). OB Radar r3 se legend transparent. | 19 Oct |
| abhi ki halat past mein kahan / Aaina | `indicators/jas_aaina.pine` a7: abhi ki TF nishani history mein -> agli N candles ka nateeja vs har candle (naap, peshgoi nahi). Chart: #1 label par mouse = purane mauqe ki tareekh; dabba = agli N candles; ABHI saleti = shor. | 19 Oct |
| StockBee / free strategy | stockbee.blogspot.com (Pradeep Bonde): Momentum Burst, Episodic Pivot, Market Monitor - US stocks ke liye, gold par seedha nahi. | 19 Oct |
| mashhoor kitab ka writer (pichli chat) | 13vi chat 18 Oct (EMA/SMA band): Elder (Trading for a Living - value zone), Weinstein (Secrets for Profiting... - 30 hafte SMA), Faber (10 mahine SMA). 14vi chat 19 Oct (Aaina): Lorentzian Classification = TV script (jdehorty), kitab nahi. | 19 Oct |
| Aaina dabba ban kar chala jata | Har tick par naqsha naya; abhi ki nishani (maslan 15m KAHAN) badle to mauqe badal jate. a8: band candle + "saaya". | 19 Oct |
| Saaya gayab / "0 mauqe" | Us band candle ki nishani ka koi purana mauqa (N candles poori) TV history mein nahi; a10 agli band candle par phir koshish karta hai. | 20 Oct |
| Saaya ✔ / ✖ | ✔ = N candles baad asal chal ka rukh saaye (qareebi #1-#3 ka ausat) jaisa; ✖ = ulat / barabar. Peshgoi nahi. | 20 Oct |
| Saaye ki moti / patli lakeer | Moti gehri = #1 (sab se milta purana mauqa), patli halki = #2/#3; rang teeno ke ausat se. Sab ek taraf = mutafiq, alag = ikhtilaf. | 20 Oct |
| 0/12 / saaye ki candles kis TF | Chart ki TF; N 2 = 12 candles (15m = 3 ghante, 1H = 12 ghante). 12vi candle band hote hi ✔/✖ (12/12 nahi dikhta). | 20 Oct |
| 1D candle mein 1m ka data | 10 D = ~13,800 1m candles, magar 1D sirf O/H/L/C - raasta (tarteeb) gum. Chhote TF ka backtest sirf asal M1 (Dukascopy) se. | 20 Oct |
| Aaj ki 1D se 15m follow | Dhoka (din band hone par pata) - sirf KAL ki band 1D. a12: 15m par 50% = kuch nahi batata. | 20 Oct |
| Saaya record / bunyaad | a11/a12 dabba (Settings 5). Bunyaad = isi muddat aankh band kar ke wahi rukh. Rang sirf 30+ saaye aur bunyaad se 2SE farq. 1D 300 saaye = shor. | 20 Oct |
| LGB / S-R / FVG se AAINA kharab? | Nahi - FVG/OB hain hi nahi; LGB/S-R sirf nishan, AGLI ka agKey sirf TF rang. | 20 Oct |
| 1W / 1M ko 1D ki buniyaad | 1D chart par 1D+1W 54.1%, 1D+1M 54.0% = sirf 1D 54.0% - kuch nahi joda. Buniyaad sirf kal ka 1D rang. | 20 Oct |
| Aaina spread ke baad | a15: 15m -$0.18/trade (spread se pehle ~+$0.12), 1D -$0.03 - $0.30 spread sab kha jata. | 21 Oct |
| Aaina strategy 1D | `jas_aaina_test` t2: 2019+ 1974 trades -$623 PF 0.968 (spread se pehle ~0) = FAIL; poori history -$922 PF 0.979. Tide ke saath milana bekaar. | 21 Oct |
| Aaina a16 khichdi | EMA + IBS + Kachhua + rang ek number = 432 nishani, samajh nahi aati, nateeja shor - hata di (a17/a18 = a15 + chart khaali). | 21 Oct |
| Tide+SMC versions | s2.8 `e48459b`, s2.9 `b35c676` (table transparent), s2.10 `364d2b4` (S/R), s2.12 `4e02fe9` (error theek, SMC default band). | 27 Oct |
| "historical offset beyond buffer" | Pine nishan purani candle se (bar_index 1650+ / 4000+ peeche) - xloc.bar_time (WAQT) se banao. | 27 Oct |
| SMC kaunsa | Apna nahi - TV ka LuxAlgo "Smart Money Concepts (SMC)" saath lagao; Tide+SMC sirf Tide (dabba + table + D1 EMA). | 27 Oct |
- FTMO EA se pass? -> `tools/ftmo_imkaan.py --preset ibs --preset kachhua --jaal`: IBS 2% + Kachhua 0.25% ~59% (36m), fail ~5%; asal dushman waqt. Fee demo 6 mahine baad (27 Oct).
- Supertrend / Trend Pro kaam karta hai? -> Akele gold par sabit nahi (#25 FAIL kinare par); 6 market tokri 1D sirf BUY = #26 ASLI PASS (IMTIHAN +0.214R). Indicator t2 demo ke liye, EA agla (28 Oct).
- Trend Pro / tokri FTMO ke liye? -> Haan, ek hissa; akele 1% risk: `ftmo_imkaan.py --system tokri_talaash:0.248:0.0645:1.97:1.76:0.418` 24m 42% pass / 22% fail, 60m 66% / 32%; IMTIHAN wale number (0.455R) 24m 67% / 3%. Correlation nahi gina (asal fail zyada). 1.8 trade/mahina = dheema. Multi-day / weekend hold: FTMO account type khud check. Agla: IBS ke saath --jaal (28 Oct).
- Cloud se data nikal sakte? -> NAHI: Dukascopy + Yahoo 429, Stooq reset. User QDM se export kare (5 qadam, H1 zip upload) (28 Oct).
- Claude QDM khud chalaye (computer use)? -> Desktop app Settings > This computer > Computer use ON; magar ~20-40 guna mehnga, user khud kare (28 Oct).
- Tokri SELL / SL? -> #26 sirf BUY; SELL #24/#17 FAIL; test mein server SL nahi (flip-down band); hifazati 2R sirf TALAASH par jaanch; TP nahi (28 Oct).
- Teeno system 1% FTMO? -> tokri+IBS+Kachhua Monte Carlo 12m dono pass 56%, fail 35%, ausat 5 mahine; 3m 13% / 11% (28 Oct).
- QDM se H1 export kaise? -> Export tab > Export to CSV (MT5 wala NAHI): All time, Timeframe H1, No Session, Original, "Generic bar format (comma delimited)"; ek symbol ek dafa. Download: Data sources > Dukascopy > M1, Update all (tareekh nahi poochhta, sab purana). File chat mein bhej sakte (zip/csv) - GitHub upload zaroori nahi (28 Oct).
- EA ke market aur kahan PASS? -> Tide Radar 9 (XAU, BTC pass; XAG commodity #6 mein; forex 5 SABIT NAHI) + Commodity Radar 6 (#6 ASLI PASS tokri); IBS sirf US500 (#15; 4 market Python #28 FAIL); RSI2 US500 (+0.114R) + USTEC/US30 (9 index bal-bal PASS). XAUUSDm chart par IBS/RSI2 suffix '' = market nahi milta -> US500m chart; panel "SIRF DIKHANA" = InpTrade false (28 Oct).
- JasTrendEA Tester Python se milta hai? -> haan: aakhri 20 mein 18 din ba din (28 Oct). Exness gold swap ~9%/saal = bhaari; FTMO swap dekhna; US500 lot hadd 2 = ~0.6% risk.
- JasTrend 1D / sirf BUY / SL? -> EA andar daily (17:00 NY) par faisla; SELL FAIL (#24, #17); TV #26 mein SL nahi tha, FTMO ke liye 4xATR hifazat (#27 SL ke saath hi PASS); Tester 44 mein 2 SL (28 Oct).
- Demo par JasTrend shuru balance 0 kyun? -> account par 5 EA, pehra poore account ki equity dekhta; FTMO par akela: 100000 / target 10 (P2 5) / din 4 / kul 8 (28 Oct).
- FTMO trial Gmail se restrict? -> naye Gmail se bypass nahi (ek shakhs ek profile, baad mein payout khatra); FTMO support (28 Oct).
- FTMO 1 mahine mein pass (1 EA)? -> NAHI (sabit edge se). `tools/ftmo_ek_mahina.py` 176 challenge 2012-26: JasTrend daily 1% = 163 pass / 0 fail magar 1 mahine mein 0%; 4H tokri 5% = 1 mahine mein 13.6% pass / 54.5% fail (jua). $400k = wahi % target, sirf fee bari (28 Oct).
- Tide Radar kitne instrument / trades? -> 15 (9 + 6 commodity), ~110 tr/saal = ~2/hafta. FTMO akela nahi: 1% par girawat 14.9% > 10% (28 Oct).
- FTMO samajh? -> payout har ~14 din, fee pehli payout ke saath wapas, funded par target nahi; masla EA ki raftaar (~5-6%/saal) (28 Oct).
- TV dabba 1D trades 4H se zyada? -> TV har TF par barabar candles deta: 1D ~40 saal, 4H ~2-3 saal; saal ke hisaab 4H ~4 guna tez (29 Oct).
- JAS Trend 4H pass? -> sirf 4 market TOKRI (#34), gold akela FAIL (#33). EA = JasTrendEA t3 (InpTfH 4, magic 20261029) (29 Oct).
- Carmine Rosato order flow podcast (transcript 29 Oct dobara)? -> wahi #16 video (14 Oct draft `docs/es_orderflow_draft.md`), gold par SIKKA; footprint/delta CFD par nahi. Qeemat wala hissa (failed breakdown / Turtle Soup) = #38 US index par (29 Oct).
- TV "Momentum strategy" 1H par behtar? -> TV kharcha 0 + ek market; Python #39 tokri 19737 tr -0.39R, gold 1H har length FAIL (29 Oct).
- VWAP trend / Gao-Han-Li-Zhou / raat ka drift / failed breakdown? -> #40 / #41 / #42 / #38 sab TALAASH FAIL; raat drift asli magar kharcha bara (29 Oct).
- QDM se kaunsa TF? -> 36 symbol H1 all time + 4 index (USA500, USATECH, USA30, DEU) M1 2021-aaj; list `docs/qdm-data-list.md` (29 Oct).
- Sab data ek click? -> laptop par `tools/JAS_DATA.bat` (Dukascopy seedha, resume); folder > address bar `cmd` > `JAS_DATA.bat`; raat ko, sleep Never (29 Oct).
- QDM ki .exe Claude ko doon? -> NAHI: cloud Linux + Dukascopy cloud ko rokta; QDM apna database format, bahar se file nahi (29 Oct).
- ".bat could harm your device"? -> Keep (Show more > Keep anyway); "Windows protected" -> More info > Run anyway. duka_get.py khud na kholo (Claude mein khulti) (29 Oct).
- Nayi chat Claude khud kyun nahi kholta kabhi? -> khudkar chain 8 chat tak (lineage depth 8); 8vi ke baad user khud kholo (sirf "TRADING" likho) = chain dobara 0 se (29 Oct).
- QDM / data ka folder? -> `tools/JAS_DATA_BG.bat` (QDM folder mein ya kahin bhi) = `D:\JAS_DATA\<INSTRUMENT>\`, peechhe chalta; QDM database bahar se nahi likh sakte (29 Oct).
- "Smart App Control blocked" .bat? -> right-click > Properties > Unblock tick > OK; SAC band NA karo (wapas on nahi hota). JAS_DATA_BG chal gaya: qdmcli nahi, Dukascopy py -3 (29 Oct).
- J Law (Chart Fanatics) multiple edge EA? -> #43 FAIL: 4 CFD par toot + kam volume pullback, daily 3 tr, 4H -0.11R; asal faida stocks catalyst/sector (29 Oct).
- JJ Simon 1m fair price (NQ) EA? -> #44 FAIL: 104 tr/mahina magar jeet 39.6% = tukka (38/25 barabari 39.7%), -0.135R; uska faida prop-firm hisaab (29 Oct).
- QDM se 34 ek saath file se? -> NAHI: QDM "Free version" (SS 29 Oct), bahar se file se nahi chalta; wahi kaam JAS_DATA_BG kar raha (har instrument D:\JAS_DATA\<naam>). Dono saath = Dukascopy zyada rokta. QDM mein M1: USA500/USATECH 2012-2026, XAU/XAG 2003-2026 (29 Oct).
- Mashhoor kitab wala naya? -> #45 Connors Double 7s (US500+USTEC daily, sirf BUY): TALAASH +0.20R, IMTIHAN +0.054R = ASLI PASS magar kamzor; IBS se milana baqi (29 Oct).
- Double 7 ka EA banayein? -> NAHI: 77% entries IBS/RSI2 (demo par) ke saath, mel 0.5-0.6 = nakal; naya khandaan chahiye (29 Oct).
- User ki 4 PDF (10 Most Profitable, 9 Advanced, Day Trading Guide, Swing Guide)? -> zyada tar pehle FAIL wali / penny stock / exit saaf nahi; #46 squeeze+NR7 test = FAIL (29 Oct).
- PDF "Introduction to Trading System Development" (WPI student project)? -> trend (S/R toot) + MA crossover har stock par optimize (= curve-fit, #18 FAIL); kaam ki baat "system of systems" = kai sabit EA mila kar, hamara mansooba yahi (29 Oct). Day Trading Guide dobara aayi (wahi file).
- Data tez kaise? -> QDM (free) GUI: faltu symbol hata kar 26 tick > Update selected = saal ba saal tez (30 Oct 02:33 chal pada); JAS_DATA_BG band (Dukascopy rok). Agla: QDM Export H1 -> zip -> GitHub data/duka/H1 (30 Oct).
- Demo EA ghaate mein? -> NAHI (30 Oct): 18 Oct se band EA trades +252 (USOIL +372, JPY SL -206), khuli IBS US500 -90; -31k History = haath wali trades. Jaanch: History > Custom period > Comment.
- Live laptop par kaise (EA wale MT5 se alag)? -> doosra MT5 `C:\Program Files\MetaTrader 5` (neela; peela EXNESS = demo+EA), Algo Trading laal + Options mein algo tick hata kar, File > Open an Account > Exness > existing: 253687618, server Exness-MT5Real34 (30 Oct). my.exness.com laptop par nahi khula. LOGIN HO GAYA (30 Oct) - "Invalid account" = password mein ek nishan ghalat (# ki jagah @).
- JAS_ZIP par bohot tab / computer atka? -> z2 ki ghalti: folder JAS_ZIP + JAS_ZIP.bat ek naam, "start" ne bat dobara chalai (chakkar). Task Manager: Windows Command Processor + PowerShell End task (MT5 nahi). z3 theek (ZIP_UPLOAD). Upload ke liye GitHub Sign in zaroori (31 Oct).
- 28 market 4H tokri se 100 tr/mahina? -> #47 FAIL: 4673 tr magar -0.021R; faida sirf gold/silver/US index, Europe/oil/forex manfi (31 Oct).
- Daily trend 28 market? -> #48 FAIL (-0.058R); dono TF par trend sirf gold/silver/US idx (+oil), Europe/forex manfi = zyada market bekaar (31 Oct).
- FTMO ka sab se achha mansooba? -> #49 ASLI PASS: JasTrend 4H (XAU, XAG, US500, USTEC) 0.75% + IBS US500 2%: 2019+ 94 challenge 69 pass / 14 fail, median 11 mahine, ~9 tr/mahina (31 Oct).
- #49 ka seedha nateeja? -> report49.py: 2019-aaj $100k = +69% (~8.8%/saal), max DD 14.5%, bura din -2.9%, 836 tr; 2012-18 sirf +7% (gold/silver manfi) (31 Oct).
- #49 2012 se aaj? -> $100k = +80% (~5.4%/saal), DD 15%, 15 mein 10 saal musbat; TV tokri dabba "SAB 2012-aaj" muddat (TV 4H data kam ho sakta) (31 Oct).
- FTMO demo kaise chal raha? -> 31 Oct: Exness Demo 474832446 par JasTrendEA t4 + JasIbsEA i4 TRADE CHALU; purani khuli trade (TV par dikhi) naye account par nahi - agle signal se milao (31 Oct).
- TV par 4H ka purana data? -> tokri dabba DAILY chart par lagao: request.security 240 ka data 2007 se aata hai (4H chart par sirf 2023) (31 Oct).
- Ulte chalne wale market ki tokri (gend wala idea)? -> #50 cross-sectional momentum (top 4 BUY / bottom 4 SELL har hafte) FAIL: ~10 tr/mahina, bina kharcha bhi 0, SELL manfi (31 Oct).
- Ek instrument par apna qaida? -> #51: 3 sabit khandaan x 28 = 84, sakht shart (3.24 SE) -> 0 bache; ek market ka data ittefaq se alag sabit karne ko kaafi nahi = tokri zaroori (31 Oct).
- Teacher wala tareeqa (behtareen chuno, naya paper do)? -> #52: top 5 (sab IBS) mein se USTEC IBS ASLI PASS (2019+ 207 tr, 71% jeet, 7/8 saal) (31 Oct).
- FTMO ka naya mansooba? -> #53: JasTrend 4H tokri 0.75% + IBS US500 + USTEC 1%: 2019+ 83 pass / 0 fail, 2012-aaj +92%, DD 13.4%, ~11 tr/mahina (31 Oct).
- Roz 1-3 trade wali (noise boundary #37)? -> M1 2021-24: ~38 tr/mahina, kharche se pehle +0.134R (asli edge) magar 0.03% kharche ke baad -0.047R = FAIL; asli spread naap kar #54 (31 Oct).
- TV strategy "Trades are required" / koi trade nahi? -> Pine v6 default margin 100%: strategy() mein margin_long = 1, margin_short = 1 (31 Oct).
- TV strategy SPX 2026 par -46%? -> sirf 2026 (IMTIHAN muddat), bina kharcha bhi -0.062R; 0.03% kharcha + 1% risk x 203 tr. "Umeed" wali baat Python 2021-24 (bina kharcha +0.134) ki thi (31 Oct).
- Asli spread kitna? -> `JasSpreadNaap` s1 (Exness Demo, 20 din ticks): US500 0.40, USTEC 1.12, gold 0.24, chandi 0.025; Python ka 0.03%/taraf 10-16 guna zyada tha (chandi 1.3x) (31 Oct).
- Noise boundary asli kharche se? -> #54 TALAASH PASS: 2021-24 1808 tr (~38/mahina), +0.113R, saal 4/4, jeet 42%; IMTIHAN QDM M1 2025+ baqi (31 Oct).
- Chutti se pehle wala din (calendar)? -> #59 ASLI PASS: SPX + NDX, 1971-2018 688 tr (is din +0.116% vs aam +0.044%), 2019+ 146 tr jeet 68% +0.155R; `indicators/jas_chutti.pine` h1 (1 Nov).
- FTMO kitne mahine mein pass? 3 mahine mein? -> #53 + khirki (2019+ sim, 70 challenge 24+ mahine data): 3 mahine 0%, 6 mahine 6%, 9 mahine 24%, 12 mahine 51%, 24 mahine 73%; median ~12, sab se tez 4; fail 0. Challenge / verification ka faida NAHI milta (virtual); FTMO Account (funded) par 80% (scaling 90% tak), fee pehli payout ke saath wapas; time limit nahi, har phase 4 din (web 1 Nov - FTMO site par tasdeeq) (1 Nov).
- Market ke bikne wale EA? (research agent, 1 Nov) -> 8 dekhe: 2-3 saal asli live + DD < 10% + bina grid/martingale wala EK bhi nahi mila. Sirf EEVCC Night Pro nazar (DD ~12%, do broker par +112% vs +21%, abhi manfi). Gold Reaper / Relax / NightVision / Luna / Night Hunter REJECT (DD 26-48%, Relax = Jumma gap); Waka Waka / Perceptrader = grid. FTMO: khareeda EA = bohot log ek jaise trade -> $400k "per strategy" qaida, account ruk sakta. Apna EA behtar.
- NinjaTrader? -> platform + US futures broker (EA nahi), NinjaScript C#; FTMO Futures alag program. Abhi MT5 hi (1 Nov).
- FTMO "gap trading" (forbidden page): band hone se <= 2 ghante pehle (>= 2 ghante band) trade kholna mana likha. MAGAR FAQ: Challenge/Verification + **Swing** account par weekend / news pabandi NAHI; Standard funded par hai. => Swing hi lena; khareedne se pehle FTMO support se likhwa lo (IBS 16:15 NY Jumma entry, chutti se pehle) (1 Nov).
- FTMO sizes / fees (1 Nov, 3rd-party sources, ftmo.com par tasdeeq): 2-step EUR 10k 89 (kuch 155 kehte) · 25k 250 · 50k 345 · 100k 540 · 200k 1080; Swing ki alag qeemat nahi mili. $400k = kul hadd (ek shakhs / strategy), single account max 200k. Fee pehli payout ke saath wapas. Chhota account: % wahi, magar 0.15% khirki 10k par = $15 risk - min lot se bara ho sakta. VPS: FTMO ka free VPS nahi mila; MQL5 VPS ~$10-15/mahina (asli challenge ke liye zaroori). Swing leverage ~1:30 (tasdeeq + margin FTMO free trial par).
- TradingView table mein instrument par click se chart khule? -> NAHI, TV Pine table click nahi leta; watchlist `docs/tv_watchlist_jas11.txt` (11 OANDA) se ek click (1 Nov).
- 2012 se 1m trades TradingView par apne data se? -> NAHI (TV bahar ka data nahi leta, 1m history chhoti); Python page B: https://claude.ai/artifact/8mv4nJR8T9rHUXGJvBHrMK (1 Nov).
- SELL wale EA? -> #73 TALAASH FAIL (228 tr -0.003R, swap kha gaya) - band; Pine mein sirf dekhne ko (1 Nov).
- OANDA:USTECH par jas_5ea error? -> OANDA:NAS100USD istemal karein (1 Nov).
- 3Commas Bot (EMA 21/50 cross, swing SL, 1:1) 2H par? -> #74 FAIL: 2409 tr -0.041R, kharche se pehle bhi 0 (2 Nov).
- TradingView Turtles (20/10 + 55/20, pyramiding 5) 83/0 mein? -> Kachhua hi hai; pyramiding/SL-nahi/SELL/do system = hamare qaide ke khilaf; nayi cheez sirf BTC (#76 bank) (2 Nov).
- Demo EA ne trade nahi li? -> normal: t5 sirf 4H palat par, i6 16:15 NY IBS < 0.2, k2 sirf US chutti (Thanksgiving 26 Nov); mahine 3-5 trade (2 Nov).
- Sab EA ka status ek saath? -> phone MT5 app (Exness-MT5Trial15, 474832446) Trade/History tab; PC Toolbox Trade/History/Experts; push notification EA mein nahi (Status EA ka idea) (2 Nov).
- JasDeskView daayen column nahi / chhupa? -> Navigator band (Ctrl+N); v5.6 lambi line torta; font 11 + InpShowLadder false + InpPairListMax 5 (+ InpShowSizes false) (2 Nov).
- Crash din ka ilaj news filter? -> NAHI: 2015/2018/2020 crash calendar par nahi the (FOMC filter fail); EA ka 4% din pehra hai magar sim mein shamil nahi -> #79 (2 Nov).
- FTMO waqt kam karna? -> research daur 6: naye market se kam; P2 1.5x FAIL (#77), pehra-shart akela FAIL (#78); agla #79 sim + 4% pehra (2 Nov).
- Cent demo nahi (Exness)? -> USD Standard demo $1000 kholo (1:2000), JasIbsCentEA c1 USD par khud $10 = $10 (cent par x100). Teesra MT5 alag folder mein (FTMO demo wala terminal na badlo) (2 Nov).
- JasIbsEA i6 hi kyun nahi? -> i6 mein martingale / $ risk nahi; c1 alag file + magic 20261102 = i6 (FTMO demo) par koi asar nahi (2 Nov).
- Cent par $1000 = 100,000 USC - EA $100k samjhega? -> NAHI: ACCOUNT_CURRENCY "USC" dekh kar $10 = 1000 USC, $800 stop = 80,000 USC. USD demo ka balance $1000 set karo (100k par stop kabhi nahi lagta) (2 Nov).
- Range bars (TV 1R/10R/1000R) par koi strategy? -> NAHI: research + #84 GATE FAIL (54.3% < 54.7%), TV khud kehta range strategy ghair-haqeeqi (3 Nov).
- Sab se pakki EMA + TF? -> 1D EMA200 (+EMA50 > EMA200 = rukh UPAR); entry waqt 4H (Supertrend mor, #34). 15m/1m EMA20/50 FAIL (#12, #82) (3 Nov).
- Sirf-BUY EA par FTMO aitraz? -> NAHI; qaide sirf nuqsan hadd / target / mana tareeqe; Swing account (3 Nov).
- BUY tokri ke ulte instrument? -> koi nahi 2012-18 (18 instrument corr +0.03..+0.49, bure din sab girte) - bachao sirf bure daur ki SELL (#85/#86) (3 Nov).
- Close By / BUY upar se neeche "sarkao" se kul P/L badalta? -> NAHI (NET wahi = hisaab wahi); hifazat sirf NET kam karne se (3 Nov).
- MT5 trade partial close? -> Trade tab double-click -> Volume mein band karne wali lot -> peela Close button (3 Nov).
- Recovery EA test "kuch na karo" se kyun? -> S - B = sirf EA ki apni trades ka P/L (basket dono mein same, kat jati); absolute equity mein gold ki tezi/girawat mil jati (#90: +7,382 mein +5,484 gold ka) (3 Nov).
- Live basket ka recovery EA (trend / hedge ladder / lock + 0.02 / raat / mausam)? -> #88-95 sab FAIL 0/9; behtar = NET +0.33 waise hi (swap-free, stop out ~$1000 door) (3 Nov).
- 15M ruki candle ka breakout rukh koi EMA batati? -> nahi: 2012-26 H1 839 ruki misaal, 4H rukh ke saath bhi 48/52 = sikka (3 Nov).
- Commodity swap (Exness, 4 Nov SS)? -> USOIL short -70 / UKOIL short -145.4 / XNG long -254.6 / XCU long -222.3 pt, doosri taraf 0 = roll ka faida nahi milta, nuqsan wali taraf ~19-100%+/saal -> C1d BANK, sirf C2 (#85) bacha (4 Nov).
- Swap 0 wali taraf hi trade (user idea)? -> = carry factor; CFD par achhi taraf ko 0 milta (credit nahi) -> sirf kharcha hat-ta, naya faida nahi; tel/gas/copper ki taraf mahino-saalon mein palat-ti; gold/index par sakht qaida BUY rok deta -> swap ko har trade ka kharcha gino. FTMO swap-free: FAQ mein nahi (Swing bhi nahi); Exness Pakistan: sab instrument khud swap-free (4 Nov, `docs/research/swap-chunao.md`).
