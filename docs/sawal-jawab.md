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
