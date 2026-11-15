# K4 - Fable ke liye HUKM-NAMA (57vi chat, 15 Nov 2026; user Jalal ne kaha "Fable se K4 karwao, poori maharat se, ek hi dafa mein final")

Aap (Fable) ek alag cloud session mein ho. User ne saaf kaha: test aisa ho ke baad mein afsos na ho aur DOBARA na karna pare.
Isliye poori maharat lagao, magar sirf data aur saboot par - andaza NAHI. Zabaan: Roman Urdu, chhota, "aap".

## 0. Pehle parho (sirf ye; poori repo nahi)
- `CLAUDE.md` (hard rules), `docs/tokri_naqsha.md` (POORA - Q1-Q23, tk1/tk2 nateeje, tester ka swap sabaq),
  `JasTokriEA.mq5` sirf header + inputs (line 1-60) = tk2 ke qaide, `tools/tokri_asli.py` + `tools/tokri_asli.c` (purana sim),
  `METHOD.md` (user ka Fishing Lots tareeqa - samajhne ke liye).
- Purana nateeja (yaad rakho): tk2 sim gold H1 2005-26 = 240/240 variant ACCOUNT KHATAM; wajah: intezar wali lots gold ki
  $30-100 ek-taraf chaal mein jama. tk2 ka rukh = 4H Supertrend (10,3) jo bar bar palatta.

## 1. Sawal (K4) - sirf ek
Kya tokri (tk2 qaide) ka RUKH agar **Turtle 55/20** se ho to tokri bari ek-taraf chaal mein BACH jaati hai aur kamati hai?
- Rukh UPAR: daily close/high pichhle 55 BAND din ki high toore. Rukh NEECHE: 55 din ki low toore.
- Rukh KHATAM: ulti taraf 20 BAND din ki toot (UPAR rukh mein 20 din ki low toote).
- Rukh taraf lot 0.02 (HEAVY), doosri taraf 0.01 (LIGHT). Lot kabhi nahi barhti (martingale NAHI).
- Daily candle = 17:00 New York par band (`tools/ftmo_test.py` session_day jaisa). Sirf BAND din - lookahead NAHI.

## 2. Jo user ne NAHI bataya ("?") - khud faisla NAHI, har ek ke variant chalao aur alag dikhao
- (a) Rukh KHATAM ho aur nayi 55 toot na ho (beech ka waqt): 3 variant - (i) dono taraf 0.01, (ii) nayi lot band, sirf TP/basket,
  (iii) pichhla rukh hi chalta rahe. Report mein user ke liye saaf likho kaunsa behtar aur kyun.
- (b) Breakout "close" se ya "high/low" chhoone se: dono chalao.
- (c) Rukh palte to purani ulti-taraf ki khuli lots ka kya: tk2 jaisa (khuli rahein) + ek variant "rukh palte par purani bhari taraf ki
  nuqsan wali lots band" - sirf naap, faisla user ka.
Koi aur "?" mile to wahi tareeqa: variant + report mein "user se poochna".

## 3. Data (sirf repo ka; naya download NAHI)
- MAIN: gold **M1 2009-2026**: `data/histdata/XAUUSD_M1_20xx_NY.zip` (2009-18, waqt EST = NY standard, DST nahi - dhyan),
  `data/qdm/M1/XAUUSD_M1_2019.zip, 2020, 2025, 2026` (UTC), `data/qdm/XAUUSD_M1_2021_24.zip` (waqt zone khud jaancho).
  Saalon ke jor par khaali ya do-guna data jaancho (gap/overlap report karo).
- EXTRA: gold H1 2005-2008 `data/ftmo/XAU_XAG_H1_dukascopy.zip` (sirf rukh / bari chaal ka andaza; $2 step H1 par kaccha).
- Daily candles M1 se banao; Turtle ke liye 55 din ka warm-up.

## 4. Account + kharcha (asli LIVE jaisa)
- LIVE 253687618 = Exness Standard Cent, swap-free. 0.01 lot = 1 USC har $1 gold. Shuru equity **38,000 USC**
  (aur ek run $1000 = 100,000 USC, purane sim se mel ke liye).
- Spread/fees: $0.24 har 0.01 lot (Q14/Q18). Sensitivity: $0.35. Swap MAIN = 0 (swap-free); ek run tester-jaisa swap ke saath.
- tk2 qaide (`JasTokriEA.mq5` inputs): Step $2, TP $1 (spread ke baad), basket CLOSE ALL NET >= 0.5, max 30 lots,
  BARDASHT 5% khula nuqsan = nayi lot nahi, AAKHRI HADD 10% = sab band + STOP. Sim mein STOP ke baad: agle din naye sire se
  (ginti + har dafa ka nuqsan alag dikhao) - aur "pehli dafa hadd kab lagi" bhi.
- Risk hadd (5% / 10% / lot 0.02) khud se NAHI barhana. Chhota karna = sirf variant, faisla user ka.

## 5. Qaida PEHLE se likha (CHUNAO / IMTIHAN) - nateeja dekh kar badalna MANA
- CHUNAO 2009-2017: variant (sec 2) + chhota parda: Step $1.5/2/3, TP $0.5/1/2, Turtle 55/20 + 40/20 + 20/10. Sirf yahan chuno.
- IMTIHAN 2018-2026: chuna hua EK variant EK dafa. Doosre variant imtihan mein sirf "jaankari" likh kar.
- **PASS** (sab zaroori): (1) IMTIHAN mein kharcha ke baad nafa > 0; (2) CHUNAO bhi > 0; (3) AAKHRI HADD 4 saal mein <= 1 dafa;
  (4) equity ki sab se gehri girawat (khula nuqsan shamil) <= 15%; (5) >= 60% saal musbat; (6) purane tk2 (4H Supertrend rukh,
  wahi data/kharcha) se behtar; (7) **saada mukabla** se behtar: sirf Turtle rukh par EK 0.02 lot (tokri ke baghair, 20 din toot par band)
  - agar saada behtar ho to sach likho: "faida tokri ka nahi, sirf rukh ka".
- FAIL ho to seedha FAIL likho. "Thoda badal ke pass" MANA.

## 6. Bachao - wo galtiyan jin se test dobara karna parta hai (har ek ki jaanch report mein ✅/❌)
1. Lookahead: aaj ki toot aaj ke close se pehle nahi; rukh agle din se. Ek run rukh 1 din aur der se = nateeja kitna badla.
2. M1 ke andar raasta: O-H-L-C aur O-L-H-C dono; MAIN = bura (pessimistic) wala.
3. TP + step spread ke saath (BUY ask par khule, bid par band).
4. Waqt zone: histdata EST vs QDM UTC -> sab NY 17:00 din par; jor ke saal (2018/19, 2020/21, 2024/25) jaancho.
5. Purana nateeja dobara banao (sanity): tk2 4H Supertrend rukh ab bhi khatam/haar dikhaye; na dikhaye to wajah dhoondo pehle.
6. Haath se jaanch: 3 basket (ek jeet, ek hadd, ek lamba) ka log - har lot khulna/band, P/L - report mein.
7. Weekend gap aur Monday open par SL/hadd: gap se nuqsan poora gino.
8. Margin: Exness cent 1:2000 / stop-out - khuli lots ki margin kabhi had se upar? (zyada lots par).
9. 2013 crash, Mar 2020, 2022, 2025-26 ka $2000->4000+ - har ek mein tokri ka haal alag dikhao.
10. Fixed $2 step jab gold $1000 vs $4000: saal ke hisaab se lots/din ginti dikhao (step chhota/bara ho jata hai) - sirf naap.

## 7. Apni JAANCH (aap khud, kaam ke baad) - report ka alag hissa "Fable ki jaanch"
- Har nateeja do tareeqe se: code dobara chala ke same number? ek alag chhota hisaab (pandas) se 1 saal ka cross-check.
- Sec 6 ki 10 baatein ✅/❌ ke saath.
- Jis cheez par yaqeen kam ho: likho kyun aur kitna asar ho sakta.

## 8. Mashwara - SIRF jahan intehai zaroori (max 5 nuqte)
Sirf wo baat jis ke na hone par test ghalat faisle tak le jaye, ya K5 (EA) mein bara khatra ho. Aam tajaweez NAHI.

## 9. Kaam ki hadd
- Kaam sirf branch `claude/k4-tokri-turtle` par (is branch se nikalo). Default/ye branch, `KAAM.md`, `TRADING.md`, koi `.mq5` NAHI chhoona.
- Nayi files: `tools/k4_tokri_turtle.py` (+ `.c` agar tez chahiye), nateeja `docs/k4-tokri-turtle.md`.
- K5 (EA banana) NAHI - sirf likho "tk3 ko kya chahiye" agar PASS.
- Grid/martingale/hedge kisi EA mein NAHI daalna (ye sirf user ke tareeqe ka TEST hai).
- Commit + push; aakhir mein session mein 10 line khulasa: PASS/FAIL, main table, sab se bari 3 baatein.

## 10. Report `docs/k4-tokri-turtle.md` ka dhaancha
1. Ek line faisla (PASS/FAIL). 2. Qaide jaise chalaye + "?" ke variant. 3. Main table: tk2-4H | Turtle variant(s) | saada 0.02 -
   CHUNAO / IMTIHAN: nafa %, gehri girawat %, hadd ginti, musbat saal, trades. 4. Saal-ba-saal. 5. Bare waqiat (sec 6.9).
6. Sec 6 checklist. 7. Fable ki jaanch. 8. Zaroori mashwara (<=5). 9. User ke liye sawal (sirf "?" wale).
