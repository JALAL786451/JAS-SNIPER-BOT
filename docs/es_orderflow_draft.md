# ES Order Flow Draft aur Script ka Dhancha

Tareekh: 2026-10-14

## 1. Maqsad aur hadood

Yeh draft Carmine Rosato ki video ke usool se Pine Script ka dhancha banata hai, TradingView Free plan par XAUUSD ke liye. Video ES futures ke asli order flow par hai, is liye kai cheezein yahan sirf andaza hongi.

- Pehle script ke nateeje chart par dekhna, phir wahi soch MT5 EA mein le jana.
- XAUUSD ke saath silver (XAGUSD) aur USDJPY jaise pairs ko filter ki tarah dekhna.
- Purani SMC/FVG script is draft mein shamil nahi; sirf video ke usool hain.
- Carmine ke natayej (8R, 10R, mahine ka munafa) uske apne daawe hain aur ES par hain. Gold par wahi nateeja milna zaroori nahi, is liye pehle history par test karein.
- Yeh video ka khulasa aur script ka dhancha hai, trading salah nahi. Coding tool ko dene ke liye Section 8 se shuru karein.

## 2. Lafzon ka matlab

Video ke yeh lafz script ke har hisse mein aayenge.

| Lafz | Asaan matlab |
| --- | --- |
| Passive order | Limit order: kisi price par intezaar karta hai. Bid = khareedne ka, offer (ask) = bechne ka. |
| Aggressive order | Market order: abhi ke price par foran khareedta ya bechta hai. |
| Delta | Aggressive khareed minus aggressive farokht. Plus = khareedar zor mein, minus = farokht karne wale. |
| Absorption | Bohat volume aaya lekin price nahi hili: saamne wala passive order sab jazb kar raha hai. |
| Stop run | Price low ya high ke stops tod kar foran ulti taraf palat jaye. |
| Failed breakdown | Price pichle low ke neeche gayi lekin foran wapas oopar aa gayi (reclaim). |
| Volume tail | High ya low par bohat kam volume: wahan dilchaspi nahi rahi, aksar palatne ki nishani. |
| P-shape, B-shape | Volume ka nakshaa. P = volume oopar jama (oopar khareedne wale phans sakte hain), B = volume neeche jama. |
| Level of interest | Woh price jahan kai wajhein milti hain: pichle din ka high/low, open price, consolidation. |
| Zero print | Price ka woh hissa jahan koi trade nahi hua. Carmine ke mutabiq market wahan wapas aati hai. |
| Low volume node (LVN) | Woh area jahan kam volume trade hua. Carmine isay target banata hai. |
| R | Stop ka faasla. 4R = risk ka 4 guna faida. |
| CLC | Context (halaat), Location (jagah), Confirmation (tasdeeq). |

## 3. Video ke usool

Video ka mool khayal: price tab hilti hai jab aggressive log saamne ke passive orders ko khatam kar dein, aur nahi hilti jab passive orders unhein rok lein.

1. **Wall ke saamne kamzor hamla.** 5710 par 111 passive sellers the aur sirf 77 aggressive buyers aaye; market neeche gayi (9 May).
2. **Absorption.** Bohat volume ke bawajood price na hile to doosri taraf koi bada passive khiladi hai. 12 Feb ko 258 contracts bikay lekin market nahi giri, aur bounce hua.
3. **Stop run.** Consolidation ka low tootay aur foran reclaim ho, saath volume tail ho, to woh low asli ban jata hai. Jis high ya low par bohat volume bane, wahan baad mein dobara break aa sakta hai.
4. **Sirf level of interest par dekhna.** Range ke beech (chop zone) mein bids aur asks ka koi matlab nahi; wahan trade nahi.
5. **CLC.** Sirf bara volume ya bara order dekh kar trade nahi: context, location aur confirmation teeno chahiye.
6. **Entry order flow ke signal par, candle close par nahi.** 12 Feb mein 3 point ke risk par 20.6 point mile. 5-minute candle ka intezaar karte to reward risk se bhi chhota reh jata.
7. **Risk ek jaisa, size stop ke hisaab se.** Carmine ka risk $3,300 se $4,500 raha. Uske mutabiq risk-reward win rate se zyada ahem hai: 30-33% win rate ke hafte mein bhi woh green raha.
8. **Chase nahi.** Tasdeeq achi ho lekin stop door ho (live session mein 12 point), to trade chhor dein.
9. **Reaction, prediction nahi.** Levels pehle se tay hon, aur ek line in the sand bhi: woh toote to analysis ulta ho jata hai. Plan poora hone ke baad ki harkat naya trade idea hai.
10. **Doosre markets se jaanch.** ES ne low toda lekin NASDAQ ne apna low nahi toda aur VIX ne saath nahi diya, to breakdown nakli nikla (live session mein 6699 par long).
11. **Khabar ke waqt trade nahi.** Bari khabar (jaise 10 baje New York ka data) se pehle position ya naya trade jua hai.

## 4. Setups (qaide)

Video ke saare trades chaar qaidon mein aate hain; har qaide mein level, tasdeeq, entry, stop aur target alag likhe hain.

### Qaida 1: Failed breakdown ya breakout (stop run)

- **Kab:** price kisi level of interest par ho: pichle din ka low, balance range low, pre-market low, ya market structure demand (girawat, phir base, phir rally ka consolidation wala hissa). Wahan consolidation bani ho ya girawat tez ho (2 Sept: bade level ke upar toot kar close na ho paya, phir 90 point girawat bina relief ke 2-hour demand tak aayi, aur wahan volume barh gaya).
- **Tasdeeq:** level ya consolidation low tootay, bids fill hon, bara volume aaye, volume tail bane, phir price foran level ke andar reclaim kare. B-shape ya positive delta outlier (12 Feb: 222 contracts) saath ho to behtar.
- **Entry:** reclaim ke foran baad, signal par.
- **Stop:** tootay hue low ke thora neeche (video mein ES par 3 se 8 point).
- **Target:** agla level of interest ya LVN (video mein 11 se 50 point; planned 3.5R se 10R). Jo level har koi dekh sakta hai (jahan sab ke stops hon) use target ki tarah lein, pakka support ya resistance nahi (22 May).

### Qaida 2: Passive wall aur phanse hue traders (rejection)

- **Kab:** price supply ya bade offer wale level par ho (5714 aur 5710, 5670 se 5700, live session mein 6680).
- **Tasdeeq:** bara aggressive buying lekin price aage na barhe (111 passive ke saamne 77 aggressive); P-shape; delta ka ulta ho jana; consolidation ka tootna.
- **Entry:** structure tootne par. Pop par short lene se stop chhota aur reward bara milta hai.
- **Stop:** high of day ya consolidation ke oopar (video mein 3 se 5 point).
- **Target:** neeche demand ya zero print (video mein 6 se 32 point).
- **Sabaq:** 5677 ke pehle trade mein timing theek nahi thi aur stop hit hua (-$3,300). Carmine ne analysis nahi chhora aur doosre trade mein $25,000 (7.6R) mila. 9 May mein bhi pehla entry breakeven raha aur doosra target tak gaya.

### Qaida 3: Pullback jo aggressive selling ke bawajood tika rahe

- **Kab:** rally ke baad pullback open price, VWAP ya consolidation par.
- **Tasdeeq:** bohat aggressive selling lekin price na gire (live session: open price hold; 12 Feb: 6044 par 258 contracts); upar ka level abhi test nahi hua (magnet); B-shape.
- **Entry aur stop:** hold hone par; stop chhota (live session mein 2 point).
- **Target:** upar ka level (live session mein 6714 se 6716, phir 6719).
- **Nota:** market oopar jaakar consolidate kare to woh bearish nahi hai; market us move ko qabool kar rahi hai. Value oopar shift ho rahi ho (price oopar volume bana rahi ho) to pullback par long ka rujhaan hota hai.

### Qaida 4 (baad mein): Zero print magnet

Tezi se bani woh jagah jahan koi trade nahi hua, price ko wapas bulati hai; Carmine ise target banata hai (live session: 6674.5). Asli volume data ke baghair banana mushkil hai, is liye pehle version mein nahi.

### Trade ka intezam

- Pehle target par 75% band, baqi ka stop breakeven par. Runners Carmine ko pasand nahi.
- Target se tez nikle to pehli kamzori par nikalna.
- Loss ya breakeven ke baad tasdeeq dobara aaye to dobara entry (9 May aur 5677 dono mein hui).

### Video ke trades (Carmine ke daawe)

| Misal | Qaida | Entry aur stop | Nateeja |
| --- | --- | --- | --- |
| 9 May: 5714 supply | 2 | short 5706 | 20 ES, $20,000, 4.5R (pehla entry breakeven) |
| 22 May: pichle din ka low 5846 | 1 | long 5844, stop 5840 se 5841 | 30 ES, $35,625, 23.75 point, kareeb 8R |
| 12 Feb: consolidation low 6036 | 1 | long kareeb 6037, stop 6034 | 30 ES, $30,937.50, 20.6 point |
| 5677 supply, pehla | 2 | short kareeb 5670 | -$3,300 |
| 5677 supply, doosra | 2 | short 5677, stop 5682 | $25,000, 7.6R |
| 4875 market structure demand | 1 | long kareeb 4870, stop 5 se 8 point | 7 ES, $27,000, kareeb 8R |
| 2 Sept: demand 6389 | 1 | long 6390, stop kareeb 6 point | planned kareeb 3.5R; asal nateeja saaf nahi |
| Live: 6708 | 3 | long, stop 2 point | kareeb 4R |
| Live: 6680 | 2 | short, stop 3 point | kareeb 3R |
| Live: 6699 | 1 | long 6699, stop 6696 | kareeb 4R |

## 5. Script ka dhancha

Script aath hisson se banegi aur teen darwaze paar karne par hi signal degi. Meri tajweez: pehle indicator (levels aur signals), phir strategy (backtest), phir MT5 EA.

Flow: Data (XAUUSD + 1-minute candles) -> Levels tay karna -> Darwaza 1: price level ke paas? -> Order flow ke andaze -> Darwaza 2: tasdeeq mili? (doosre pairs ki jaanch yahan shamil) -> Darwaza 3: RR theek hai? -> Entry, stop, target -> Alert aur backtest. Kisi darwaze par jawab nahi ho to koi trade nahi.

Teen darwaze hain: level ke paas hona, tasdeeq milna, aur RR theek hona; kisi mein bhi fail hone par koi trade nahi.

1. **Settings:** chart timeframe, andar ka timeframe (1 minute), session ka waqt, doosre pairs ki list, risk, minimum RR.
2. **Levels:** pichle din ka high, low aur close; Asian ya London session ka high aur low (video ka pre-market); din ka open aur VWAP; consolidation (balance) range; market structure demand aur supply; din ka high aur low.
3. **Order flow ke andaze:** delta, volume outlier, volume tail, absorption, P aur B shape. Yeh 1-minute andar ki candles se banenge, asli nahi.
4. **Price ki tasdeeq:** failed breakdown ya breakout, consolidation ka stop run, structure break. Yeh asli price par chalti hain.
5. **Tasdeeq (CLC):** level ke paas hona zaroori; range ke beech koi signal nahi; kam az kam do tasdeeq, ek price ki aur ek order flow andaze ki.
6. **Trade ka hisaab:** entry signal par, stop tootay extreme ke paar, target agla level, minimum RR, size = risk bhaga stop ka faasla, pehle target par 75% band.
7. **Doosre pairs ka filter:** XAGUSD aur USDJPY par wohi failed-breakdown jaanch. XAUUSD ka breakdown tab nakli ho sakta hai jab doosre pairs saath na toote. Silver aam taur par gold ke saath chalta hai; USDJPY ka rishta alag ho sakta hai, is liye 'saath' aur 'ulta' ka option rakhein.
8. **Dikhana aur alerts:** levels, signal ke labels, chop zone ka rang, alerts; backtest mein har qaide ka R alag.

### Tajweez shuda numbers

Video mein yeh number nahi diye gaye; yeh meri tajweez hain, test ke baad badalne ke liye.

| Cheez | Tajweez | Kyun |
| --- | --- | --- |
| Chart timeframe | 5 minute, andar 1 minute | Free plan par aam taur par sab se chhota data 1 minute ka hota hai |
| Session | New York open ke baad pehle 2 ghante: 18:30 se 20:30 PKT (amreeka mein DST ke dauran), warna 19:30 se 21:30 PKT | Video ke zyada tar trades wahin hain |
| ATR | 14 bars | Gold aur ES ke point alag hain, faasle ATR mein napne hain |
| Volume outlier | pichle 20 bars ke average ka 2 guna | Video ke outlier ka andaza |
| Volume tail | high ya low ke qareeb range ke bahari 20% mein volume, bar ke kul volume ka 15% se kam | Kam volume ka andaza |
| Absorption | volume average ka 1.5 guna, range 0.5 ATR se chhoti, delta ek taraf | Volume zyada, price nahi hili |
| Failed breakdown | level ke neeche kam az kam 0.1 ATR jaye, 3 bars ke andar wapas oopar close | Stop run aur reclaim |
| Stop | tootay extreme se 0.2 ATR door | Video ke 2 se 6 point ke chhote stop jaisa |
| Minimum RR | 3 | Video ke planned trades 3.5R se 10R |
| Pehle target par nikasi | 75% | Carmine ka tareeqa |
| Level ke paas | level se 0.5 ATR ke andar | Location ka andaza |
| Doosre pairs ka filter | Qaida 1 mein: doosra pair apna level na tode to hi signal; saath ya ulta ka option | Video ka NASDAQ aur VIX wala khayal |
| Backtest ka risk | account ka 1% har trade | Sirf test ke liye; asli account ka risk aap khud tay karein |
| Ek din mein trades ki had | 3 | Video mein kam aur chuninda trades par zor hai |

## 6. Asli, andaza ya mumkin nahi

Price aur level wali cheezein asli chalengi; delta aur absorption jaisi cheezein sirf andaza hongi; DOM aur heat map ka data TradingView Free aur MT5 par hai hi nahi.

| Video ki cheez | TradingView Free (XAUUSD) | MT5 (Exness) |
| --- | --- | --- |
| Levels (pichla din, session, open, range) | Asli | Asli |
| Failed breakdown, stop run, structure break | Asli | Asli |
| Stop, target, RR, position size | Asli | Asli |
| Volume outlier | Andaza (tick volume) | Andaza (tick volume) |
| Delta | Andaza | Andaza |
| Absorption | Andaza | Andaza |
| Volume tail, P aur B shape | Andaza (1-minute andar ki candles) | Andaza (M1 candles) |
| Exhaustion (high par 3 tick bina bid trade) | Bohat kamzor andaza | Bohat kamzor andaza |
| Zero print | Mushkil, baad mein | Mushkil, baad mein |
| DOM, heat map, passive wall (111 ke saamne 77), spoofing | Mumkin nahi | Mumkin nahi |
| Tape ki raftaar | Mumkin nahi | Mumkin nahi |

Gold aur forex ka volume aam taur par tick volume hota hai: price kitni dafa badla, asli contracts nahi. Is liye delta ko andaze ki tarah hi lein.

TradingView ka built-in footprint tool Free plan par shayad nahi milta, is liye 1-minute candles istemal hongi; aap ke plan ki hadood script likhte waqt TradingView docs se confirm karni hongi. MT5 ke tester mein chhote timeframe ki history kam milti hai (aap ne bataya), is liye order flow ke andaze wahan kamzor test honge. Pehle TradingView par chalayein.

## 7. Shak wali baatein aur tay kiye gaye faislay

Transcript auto-captions se hai, is liye kuch aankde dhundle hain; neeche woh likhe hain, phir woh faislay jo meri tajweez par tay kar diye gaye hain.

### Dhundle ya aapas mein takrate aankde

- **May ka munafa:** captions mein $23,000 likha hai (0:12 aur 26:36), lekin 9 aur 22 May ke sirf do trade milake $55,625 bante hain. Voice se mile text mein $203,000 tha, jo zyada qareeb lagta hai. Pakka nahi.
- **2 Sept ka trade (3:40:19):** 289 points bola gaya, jo mumkin nahi lagta; 6 point stop aur 3.5R ke hisaab se kareeb 20 se 21 point banta hai.
- **22 May (37:24):** bola gaya risk 4 point (Discord message mein stop 5840 ke neeche), lekin trade journal mein stop 5841 aur planned 10R hai (kareeb 3 point).
- **12 Feb (49:54):** bola gaya target 6060 (23 point), screenshot mein 6056 (planned 6.33R). Entry ka aankda 5037 asal mein 6037 hai.
- **5677 ke trades (57:54 se 1:04:40):** entry aur stop ke aankde (73, 76, 70, 82) mix hain. Pakka sirf: doosra trade 5677 par, stop 5682, $25,000, 7.6R; pehla loss $3,300.
- **4875 ka trade (1:04:51 se 1:11:30):** entry aur stop kareeb ke hain (4870 se 4875), exact nahi.
- **NASDAQ aur ES (3:05:44 se 3:08:30 aur 3:24:07):** transcript mein kamzor aur mazboot ke lafz ulat-palat hain. Asal baat: ES ne low toda, NASDAQ ne nahi, aur VIX ne saath nahi diya.
- **Exhaustion** ki tareef (3:19:39: high par 3 ya zyada tick bina bid trade) Carmine ki apni hai.

### Faislay (meri tajweez par tay; aap badal sakte hain)

1. Chart timeframe: 5 minute, andar ka data 1 minute.
2. Pehla version XAUUSD par; silver aur USDJPY ka filter shamil, lekin band kiya ja sake.
3. Session: New York open ke baad pehle 2 ghante; London ka option band rakha jaye.
4. Risk: sirf backtest ke liye account ka 1% har trade; asli account ka risk aap khud tay karein.
5. Pehle target par 75% nikasi aur baqi ka stop breakeven par; sirf ek target ka option bhi.

## 8. Coding tool ke liye hidayat

Is draft se TradingView Free plan ke liye Pine Script (sab se naya version, v6 ya naya) ka indicator banayein; strategy (backtest) wala version us ke baad. Section 5 ki numbers table aur Section 7 ke faislay lagu hain; har number input hona chahiye.

1. **Data:** main chart XAUUSD; doosre pairs XAGUSD aur USDJPY `request.security` se. Order flow ke andaze 1-minute andar ki candles (`request.security_lower_tf`) se banayein. Asli bid ask volume nahi hai, is liye chart par saaf likhein ke yeh andaze hain.
2. **Signal tab banta hai jab teeno hon:** (a) price kisi level of interest ke paas ho (0.5 ATR ke andar); (b) Section 4 ke Qaida 1, 2 ya 3 ki price wali shart poori ho; (c) kam az kam ek order flow andaza (delta, volume tail, absorption, P ya B shape) usi taraf ho. Range ke beech wale signal (a) se hi band ho jate hain.
3. **Signal rukta hai jab:** session ke bahar ho, RR 3 se kam ho, ya ek din ke trades ki had (3) poori ho jaye.
4. **Doosre pairs:** Qaida 1 mein tab hi signal jab XAGUSD (ya USDJPY, jo chuna ho) apna level na toda ho; woh bhi toote to breakdown asli maan kar signal band. Saath ya ulta ka input rakhein.
5. **Entry, stop, target:** entry signal wali candle ke close par. Stop us extreme se 0.2 ATR door jise tootna signal ghalat kar de (Qaida 1: tootay hue low ya high; Qaida 2: rejection ka high ya low; Qaida 3: pullback ka low ya high). Target signal ki taraf ka agla level of interest. Size = risk bhaga stop ka faasla. Pehle target par 75% band, baqi ka stop breakeven par.
6. **Repaint nahi:** signal sirf band candle par bane; doosre pairs ya bade timeframe ka data `barmerge.lookahead_off` ke saath lein.
7. **Output:** levels ki lines, signal ke labels (qaide ka number aur long ya short), chop zone ka rang (woh hissa jo kisi level ke 0.5 ATR ke andar na ho), alerts, aur ek chhoti table (signals ki ginti, har qaide ka R).
8. **Jo na banayein:** DOM, heat map, spoofing, zero print (Section 6).
9. **Code mein nishani:** har hissa ke upar comment mein draft ka qaida ya section likhein (jaise Qaida 1), taake draft se mel khana asaan ho.
10. **Test:** banne ke baad kuch dino ka chart dekh kar check karein ke levels aur signals Section 4 ke qaidon se mel khate hain; phir strategy version mein har qaide ka R alag napein.
