# K4 - Tokri (tk2 qaide) + Turtle rukh: nateeja (Fable, 15 Nov 2026)

Hukm: `docs/k4-fable-hukm.md`. Tool: `tools/k4_tokri_turtle.py` + `tools/k4_tokri_turtle.c` (engine) + `tools/k4_data.py` (data).
Har hukm ka kaccha output aur poori table (CSV): `docs/k4-natije/`. Ye sirf TEST hai - kisi EA mein kuch nahi badla.

## 1. Faisla: **FAIL**

Turtle rukh ke saath bhi tk2 tokri bari ek-taraf chaal mein **na bachti hai, na kamati hai**.
- CHUNAO (Jun 2009 - 2017): 324 variant mein se **0 nafe mein**, 253 mein account khatam. Sab se kam nuqsan = -34.9%.
- IMTIHAN (2018 - 5 Nov 2026): wahi EK chuna hua variant = **account khatam** (38,000 USC -> 0; May 2024 ya May 2025, raaste par).
  Baqi 323 variant (sirf jaankari): **324 mein se 324 account khatam**.

| # | Shart (hukm sec 5) | Nateeja (chuna hua variant, bura raasta) | |
|---|---|---|---|
| 1 | IMTIHAN nafa > 0 | -100% (account khatam) | ❌ |
| 2 | CHUNAO nafa > 0 | -34.9% | ❌ |
| 3 | AAKHRI HADD 4 saal mein <= 1 | 4 saal ki khirki mein CHUNAO 15, IMTIHAN 28 dafa | ❌ |
| 4 | gehri girawat <= 15% | CHUNAO 49.5%, IMTIHAN 100% | ❌ |
| 5 | >= 60% saal musbat | CHUNAO 3/9, IMTIHAN 1/9 | ❌ |
| 6 | purane tk2 (4H Supertrend) se behtar | CHUNAO haan (-34.9% vs -100%); IMTIHAN dono account khatam, Turtle sirf 1 se 3 saal der se | baraye naam |
| 7 | saada 0.02 lot se behtar | saada +4.07% (IMTIHAN), +1.02% (CHUNAO); tokri -100% / -34.9% | ❌ |

Shart 7 ka sach: **faida tokri ka nahi, sirf rukh ka** - aur wo bhi chhota. Tokri rukh ke faide ko kha jati hai.

## 2. Qaide jaise chalaye

- **Account:** LIVE jaisa cent, shuru 38,000 USC, 0.01 lot = $1 par 1 USC. Spread $0.24 (BUY ask par khuli, bid par band; SELL ulta). Swap 0.
- **Tokri** = `JasTokriEA.mq5` tk2 ka Work() lafz-ba-lafz: rukh taraf 0.02, doosri 0.01; aakhri lot se Step $ chaal par chaal ki taraf nayi
  lot; har lot ka TP; CLOSE ALL NET >= 0.5; max 30 lots; BARDASHT 5% (1,900 USC) = nayi lot nahi; AAKHRI HADD 10% (3,800 USC) = sab
  band, agle din naye sire se. Hadd ki buniyad shuru equity (EA yaad rakhta hai).
- **Rukh** = Turtle: din ki candle 17:00 New York par band; pichhle N BAND din ki high/low ki toot; rukh AGLE din ki pehli candle se.
- **Data:** gold M1 2009-2026 (62.3 lakh candle). Candle ke andar do raaste (O-H-L-C, O-L-H-C); har variant ka number dono mein se BURA.
- **Daur:** CHUNAO 1 Jun 2009 - 29 Dec 2017 (55 din warm-up ke baad), IMTIHAN 2 Jan 2018 - 5 Nov 2026. Har daur naya 38,000.
- **Chunao ka qaida nateeja dekhne se PEHLE** likha aur commit kiya (tool ke upar Q-a..Q-l, commit `b9d76f2`): "ahl" = nafa > 0, girawat
  <= 15%, hadd 4 saal mein <= 1, musbat saal >= 60%; ahl mein sab se bara nafa/girawat. Koi ahl na ho to sab se kam bura - wahi EK
  variant IMTIHAN mein EK dafa (taake poori tasveer rahe). CHUNAO ka nateeja IMTIHAN se pehle commit hua (`36bca18`).

### "?" ke variant (CHUNAO; 324 = 3 x 2 x 2 x Step 1.5/2/3 x TP 0.5/1/2 x Turtle 55/20, 40/20, 20/10)

| "?" | variant | bache (account khatam nahi) | sab se acha nafa | hadd (darmiyana) |
|---|---|---|---|---|
| (a) beech ka waqt | i dono taraf 0.01 | 20 / 108 | -49.5% | 21 |
| | ii nayi lot band | 35 / 108 | -42.8% | 19 |
| | iii pichhla rukh chalta rahe | 16 / 108 | -34.9% | 22 |
| (b) toot | close se | 36 / 162 | -34.9% | 20 |
| | high/low chhoone se | 35 / 162 | -48.4% | 21 |
| (c) rukh palte par | c1 purani lots khuli (tk2) | 29 / 162 | -49.1% | 27 |
| | c2 purani bhari taraf ki nuqsan wali band | 42 / 162 | -34.9% | 16 |
| Turtle | 55/20 - 40/20 - 20/10 | 15 - 20 - 36 / 108 | -51.4% / -54.6% / -34.9% | 20 / 21 / 20 |
| Step | $1.5 - $2 - $3 | 10 - 19 - 42 / 108 | -66.5% / -34.9% / -50.2% | 21 / 20 / 20 |
| TP | $0.5 - $1 - $2 | 0 - 13 - 58 / 108 | -99.8% / -64.2% / -34.9% | 16 / 21 / 25 |

- **(a) kaunsa behtar:** koi nahi - teeno fail. (ii) "nayi lot band" sab se kam bura (zyada bache, kam hadd) kyunke beech ke waqt mein nayi
  lots nahi banti = kam intezar wali lots. Farq nateeja nahi badalta.
- **(b)** close / chhoona: koi farq nahi. **(c)** c2 se hadd ginti kam (27 -> 16) magar wahi nuqsan rukh palte waqt kat jata hai
  (chune hue mein CHUNAO: c2 se -67,686 USC, hadd se -64,603 USC). Ek hi c2 band = -3,199 USC tak (2 Nov 2014).
- **Chuna hua** (koi nafe mein nahi -> sab se kam nuqsan): **Turtle 20/10, close, a-iii, c2, Step $2, TP $2.**
- Meri parhai jo hukm mein khuli thi (tool mein Q-g): c2 = jab rukh us taraf se hate (khatam ya palte) to us taraf ki nuqsan wali lots
  band; (i) mein khali tokri ki pehli lot = aakhri band qeemat se Step $ chaal ke baad, chaal ki taraf 0.01.

### Naya "?" jo jaanch mein mila (jaankari - K4 ka faisla F0 par hi hai)

tk2 ke code mein CLOSE ALL sirf KHULI lots ke P/L par hai, aur har lot ka TP us se pehle lag jata hai -> **tk2 (Step $2, TP $1) mein
CLOSE ALL dono daur mein 0 dafa chala.** (TP $2 par kabhi kabhi: chune hue mein 57-85 dafa, kul sirf +137 se +210 USC.)
User ki baat (Q14 / Q21 "CLOSE ALL faide mein") ke doosre matlab bhi wahi 324 variant par CHUNAO mein chalaye:

| khandan | variant | nafa > 0 | ahl | account khatam | sab se acha |
|---|---|---|---|---|---|
| F0 tk2 jaisa (K4) | 324 | 0 | 0 | 253 | -34.9% |
| F1 CLOSE ALL = tokri ka kul hisaab (band munafa + khula) | 324 | 0 | 0 | 262 | -32.3% |
| F2 lot ka TP nahi, sirf CLOSE ALL (Q21 lafz-ba-lafz) | 108 | 31 | 0 | 0 | +3.6% (8.6 saal mein; musbat saal 3/9 se zyada nahi) |
| F3 ULTA mode (Q20: high SELL / low BUY) | 324 | 2 | 0 | 224 | +22.9% (magar 20 hadd, girawat 27.6%) |

Koi khandan "ahl" nahi -> in ka IMTIHAN **nahi khola** (qaida Q-i). F2 account nahi urati magar kamati bhi nahi: 30 lots bhar kar
tokri jam jati hai aur mahinon koi trade nahi hoti.

## 3. Main table (bura raasta)

| | CHUNAO nafa | girawat | hadd | musbat saal | lots | IMTIHAN nafa | girawat | hadd | musbat saal | lots |
|---|---|---|---|---|---|---|---|---|---|---|
| **tk2-4H** Supertrend, Step $2 TP $1 | -100% (khatam May-Nov 2013) | 100% | 29 | 0/9 | 50,979 | -100% (khatam Feb 2022 - Mar 2023) | 100% | 33 | 0/9 | 60,437 |
| Turtle **55/20** close, a-i, c1, Step $2 TP $1 (hukm ka seedha matlab; jaankari) | -100% (khatam Apr 2013) | 100% | 23 | 1/9 | 40,925 | -100% (khatam Nov 2024 - Apr 2025) | 100% | 39 | 0/9 | 86,587 |
| **Turtle tokri CHUNA HUA** 20/10 close, a-iii, c2, Step $2 TP $2 | **-34.9%** | 49.5% | 18 | 3/9 | 42,974 | **-100%** (khatam 23 May 2024 / 12 May 2025) | 100% | 38 | 1/9 | 59,076 |
| **saada 0.02** lot, Turtle 20/10 (tokri ke baghair) | +1.02% | 2.77% | 0 | 5/9 | 69 | +4.07% | 6.44% | 0 | 5/9 | 65 |
| saada 0.02 lot, Turtle 55/20 | -1.01% | 3.77% | 0 | 4/9 | 35 | +7.54% | 6.49% | 0 | 6/9 | 29 |

Do raaste alag (chuna hua): CHUNAO -34.9% (O-H-L-C) / -21.1% (O-L-H-C); IMTIHAN dono account khatam (38 / 28 hadd).
Pehli hadd: tk2-4H 6 Oct 2009 aur 18 Jul 2018; chuna hua 4 Nov 2009 aur 18 Jul 2019. Har hadd = -3,800 USC (gap par zyada, sec 6.7).
EXTRA gold H1 2005-2008 (kaccha): tk2-4H -59.1% (14 hadd), Turtle 55/20 -39.3% (10), chuna hua -12.0% (5) - wahan bhi koi nafe mein nahi.

**Paisa kahan gaya** (chuna hua, raasta O-H-L-C, USC):

| | TP ki kamai | AAKHRI HADD | rukh palte par band (c2) | CLOSE ALL | aakhir mein khula | kul |
|---|---|---|---|---|---|---|
| CHUNAO | +120,478 (40,329 TP) | -64,603 (17 dafa) | -67,686 (817 lots) | +137 | -1,596 | **-13,269** |
| IMTIHAN | +171,534 (57,226 TP) | -144,407 (38 dafa) | -61,837 (641 lots) | +199 | -3,469 | **-37,980** |

Machhli pakarne (TP) ki kamai asli hai, magar **intezar wali lots ka nuqsan us se bara**. ~30% waqt tokri 30 lots par bhari rehti hai
(nayi lot nahi khul sakti), 13-16% waqt BARDASHT mein. tk2-4H mein bhi yahi: CHUNAO TP +66,939 vs hadd -102,646.

### 3b. Tashkhees: rukh agar GHAIB se bilkul sahi ho? (jaan boojh kar lookahead - sirf oopari hadd, K4 ka faisla nahi)

| rukh pehle se pata | tk2 (Step $2, TP $1) CHUNAO / IMTIHAN | Step $2 TP $2 + c2 CHUNAO / IMTIHAN | saada 0.02 lot CHUNAO / IMTIHAN |
|---|---|---|---|
| aaj ka din kis taraf band hoga | -63.5% (34 hadd) / account khatam (56) | +159.9% (4 hadd) / +329.9% (66 hadd, girawat 24.7%) | +111.8% / +218.2% (girawat 0.4% / 0.8%) |
| agle 5 din kis taraf | -35.7% (29) / account khatam (51) | +42.8% (11) / account khatam (90) | +56.5% / +97.4% |
| agle 20 din kis taraf | -59.4% (31) / account khatam (41) | -2.0% (19) / account khatam (53) | +26.8% / +58.8% |

**Matlab:** rukh 100% sahi ho tab bhi tk2 tokri fail. Masla rukh ka nahi, **tokri ke dhaanche ka** hai: intezar wali lot sirf apne TP ya
AAKHRI HADD par nikalti hai. Is liye kisi aur rukh-ishare (EMA, Supertrend, 1D, waghaira) ke saath yahi test dobara karne ki zaroorat nahi.
Sahi rukh ka faida saada lot kam girawat ke saath le leta hai; tokri sirf "aaj ka din" pehle se pata hone par (jo mumkin nahi) aage nikalti hai.

## 4. Saal-ba-saal

**(A) Musalsal run - chuna hua variant (USC; bracket = AAKHRI HADD ginti):**

| saal | O-H-L-C | O-L-H-C | saada 0.02 | | saal | O-H-L-C | O-L-H-C | saada 0.02 |
|---|---|---|---|---|---|---|---|---|
| 2009 (Jun se) | -1,202 (1) | -1,919 (1) | +51 | | 2018 | +1,873 (0) | +1,738 (0) | +194 |
| 2010 | -6,111 (1) | -5,022 (1) | -80 | | 2019 | -1,269 (1) | -682 (1) | +235 |
| 2011 | -6,340 (8) | -6,326 (8) | +507 | | 2020 | -1,244 (8) | -7,482 (9) | -606 |
| 2012 | -218 (2) | +2,933 (2) | +96 | | 2021 | -4,499 (2) | -14,594 (5) | -264 |
| 2013 | +2,430 (3) | +1,297 (3) | +314 | | 2022 | -5,230 (5) | -3,545 (5) | +250 |
| 2014 | +1,520 (0) | +1,558 (1) | -199 | | 2023 | -7,558 (4) | -4,052 (4) | -102 |
| 2015 | +3,742 (0) | +4,149 (0) | +58 | | 2024 | -1,073 (6) | -9,369 (4) KHATAM | -273 |
| 2016 | -3,073 (2) | -788 (2) | -150 | | 2025 | -18,980 (12) KHATAM | - | +110 |
| 2017 | -4,018 (0) | -3,919 (0) | -208 | | 2026 (5 Nov tak) | - | - | +2,001 |
| **CHUNAO** | **-13,269 (17)** | **-8,036 (18)** | **+388** | | **IMTIHAN** | **-37,980 (38)** | **-37,986 (28)** | **+1,545** |

tk2-4H (O-H-L-C): 2009 -4,321 (2), 2010 -7,534 (5), 2011 -14,617 (11), 2012 -3,405 (5), 2013 -8,153 (4) khatam | 2018 -1,359 (1),
2019 +566 (3), 2020 -19,148 (13), 2021 -16,590 (9), 2022 -1,472 (1) khatam.

**(B) Har saal ALAG (naya 38,000, khali tokri) - aur fixed $2 Step ka asar (bachao 10):**

| saal | gold close | din ki range $ | Turtle tokri nafa | hadd | lots/din | tk2-4H nafa | hadd | lots/din | saada 0.02 |
|---|---|---|---|---|---|---|---|---|---|
| 2009 | 1,096 | 17 | -5.0% | 1 | 14 | -15.1% | 3 | 27 | +0.13% |
| 2010 | 1,419 | 19 | -15.5% | 1 | 16 | -4.6% | 3 | 33 | -0.20% |
| 2011 | 1,565 | 29 | -22.7% | 8 | 44 | -44.2% | 11 | 74 | +1.33% |
| 2012 | 1,675 | 22 | -11.1% | 3 | 23 | -13.7% | 5 | 41 | +0.27% |
| 2013 | 1,204 | 25 | +1.1% | 3 | 25 | -31.9% | 7 | 43 | +0.82% |
| 2014 | 1,184 | 17 | -6.6% | 1 | 13 | -11.6% | 3 | 22 | -0.52% |
| 2015 | 1,061 | 16 | +5.9% | 0 | 12 | -12.4% | 3 | 19 | +0.15% |
| 2016 | 1,151 | 18 | -8.6% | 2 | 17 | -13.0% | 4 | 32 | -0.37% |
| 2017 | 1,302 | 12 | -15.5% | 0 | 11 | -8.0% | 2 | 14 | -0.55% |
| 2018 | 1,282 | 12 | +4.6% | 0 | 8 | -3.9% | 1 | 15 | +0.51% |
| 2019 | 1,517 | 15 | -3.4% | 1 | 12 | -7.8% | 3 | 27 | +0.62% |
| 2020 | 1,898 | 31 | -7.9% | 8 | 53 | -62.7% | 14 | 83 | -1.61% |
| 2021 | 1,829 | 24 | -35.3% | 5 | 29 | -38.9% | 8 | 53 | -0.73% |
| 2022 | 1,823 | 26 | -13.8% | 5 | 32 | -30.5% | 8 | 58 | +0.66% |
| 2023 | 2,063 | 24 | -11.4% | 3 | 26 | -43.2% | 8 | 45 | -0.29% |
| 2024 | 2,624 | 33 | -38.0% | 9 | 46 | -26.1% | 10 | 87 | -0.72% |
| 2025 | 4,319 | 61 | **account khatam** | 25 | 80 | **account khatam** | 26 | 162 | +0.29% |
| 2026 | 4,065 | 119 | **account khatam** | 57 | 282 | **account khatam** | 21 | 139 | +5.24% |

18 mein se Turtle tokri sirf 3 saal musbat (2013, 2015, 2018); tk2-4H 0 saal. $2 Step 2018 mein din ki range ka 1/6 tha, 2026 mein
1/60 -> roz 8 lots se 282 lots; 2025-26 jaise bazaar mein account usi saal khatam.

## 5. Bare waqiat (har ek ALAG run, naya 38,000)

| waqia | gold | Turtle rukh (din) | Turtle tokri | tk2-4H | saada 0.02 |
|---|---|---|---|---|---|
| 2013 crash (Apr-Jun) | 1,598 -> 1,234 | DOWN 62, koi nahi 3 (rukh sahi) | -12.7%, 3 hadd (pehli 15 Apr) | -16.7%, 3 hadd | +1.70% |
| Mar 2020 (15 Feb - 15 Apr) | 1,582 -> 1,451 -> 1,726 | UP 22, DOWN 16 | -1.8%, 3 hadd | -10.5%, 4 hadd | -0.35% |
| 2022 (poora saal) | 1,829 -> 2,070 -> 1,615 -> 1,823 | UP 116, DOWN 59 | -13.8%, 5 hadd | -30.5%, 8 hadd | +0.66% |
| 2025 (poora saal) | 2,625 -> 4,319 | UP 141, DOWN 20, koi nahi 97 | account khatam, 25 hadd | account khatam, 26 hadd | +0.29% |
| 2026 (5 Nov tak) | 4,324 -> 5,597 -> 4,065 | UP 92, DOWN 127 | account khatam, 57 hadd | account khatam, 21 hadd | +5.24% |

**Sab se saaf saboot:** taqreeban AADHI hadd tab lagi jab Turtle rukh SAHI taraf tha (chuna hua: CHUNAO 9 / 17, IMTIHAN 20 / 38;
Turtle 55/20: IMTIHAN 26 / 39). Halki (ulti) taraf ki 0.01 lots har wapasi par khulti hain, chaal wapas nahi aati, ~28 jama ho kar
-3,800 USC. Misaal 15 Apr 2013 (crash, rukh DOWN = sahi): 28 BUY 0.01 = -3,800 USC. Baqi aadhi mein rukh ghalat tha aur bhari 0.02
taraf phansi (~25 lots; misaal 16 Jan 2025: 28 SELL 0.02 = -3,800 USC). Yani rukh sahi ho ya ghalat, anjaam ek hi.

## 6. Bachao checklist (hukm sec 6)

1. ✅ **Lookahead:** rukh sirf pichhle BAND dinon se, agle din se laagu; alag likhe hisaab se 6 Turtle series barabar. Rukh 1 din aur der
   se: CHUNAO -42.7% (MAIN -34.9%), IMTIHAN wahi account khatam - nateeja nahi badla.
2. ✅ **M1 ke andar raasta:** dono chalaye, MAIN = bura. Rang wale do raaste bhi: CHUNAO -3.6% / -24.0%; IMTIHAN chaaron par account khatam.
3. ✅ **Spread:** BUY ask par / bid par band; TP spread ke baad. Spread $0.35: CHUNAO -66.8%, IMTIHAN khatam. Swap (tester jaisa, BUY
   -0.51 USC/0.01/raat): CHUNAO -85.3%, IMTIHAN khatam.
4. ✅ **Waqt zone - hukm ki ek baat GHALAT nikli:** histdata 2009-18 "EST bina DST" NAHI, **New York ka maqami waqt DST ke saath** hai
   (Dukascopy H1 se mel: sardi +5h, garmi +4h, har saal 2009-18). QDM sab UTC. Jor 2018/19, 2020/21, 2024/25: na gap na overlap. Ghaib kaam
   ke din 42 = sab Christmas / New Year / Good Friday. histdata ke 41 ghante Dukascopy se $3+ alag (zyada tar 2011 aur 2013); ek pakka
   bad tick 30 Nov 2018 21:59 UTC (+$12). In ko kaat kar bhi nateeja wahi (sec 7).
5. ✅ **Purana nateeja:** purana sim dobara chalaya = 240/240 account khatam. Naye engine mein tk2 (4H Supertrend): CHUNAO aur IMTIHAN
   dono mein account khatam; 100,000 USC par CHUNAO -22.0% (7 hadd).
6. ✅ **Haath se jaanch:** 3 basket neeche; poora log `docs/k4-natije/log.txt` (haath ke hisaab se farq 0).
7. ✅ **Weekend gap:** chhalang par hadd nayi qeemat par (poora nuqsan), TP ko gap ka faida NAHI diya. 438 hadd mein 5 "3,850 se bari";
   sab se bari **-5,991 USC (15.8%)** 1 Mar 2026 ke weekend gap (+$95) par -> AAKHRI HADD 10% par pakki nahi.
8. ✅ **Margin:** zyada se zyada 0.60 lot; margin 1:2000 par 155 USC, 1:200 par 1,551 USC (2026). Account zinda ho to margin level
   5,600%+. Margin kabhi masla nahi - masla nuqsan hai.
9. ✅ **Bare waqiat:** sec 5.
10. ✅ **Fixed $2 Step:** sec 4(B) - lots/din 8 (2018) se 282 (2026).

**3 basket (chuna hua, CHUNAO, O-H-L-C; 88 tokri = 67 jeet +21,418 USC, 21 haar -32,471 USC):**

```
JEET - tokri #1 (3 lots, 3 ghante)
 31 May 22:00 KHULI BUY  0.02 @ 978.49 (bid 978.25)
 31 May 22:52 KHULI SELL 0.01 @ 976.37            <- $2 neeche (mid 976.49)
 01 Jun 01:12 KHULI BUY  0.02 @ 979.61            <- SELL se $2+ upar, pehli BUY se $1 door
 01 Jun 01:16 CLOSE ALL bid 980.19: BUY (980.19-979.61)x2 = +1.16 | SELL (976.37-980.43)x1 = -4.06 | BUY (980.19-978.49)x2 = +3.40
              kul = +0.50 USC  (theek 0.5 par)

AAKHRI HADD - tokri #37 (263 lots, 20 ghante; gold 1,740 -> 1,636, rukh UP = ghalat)
 22 Sep 2011 21:00 KHULI BUY 0.02 @ 1740.02 ... 241 lots TP par band = +684.00 USC ...
 23 Sep 17:06 AAKHRI HADD bid 1635.75: 22 BUY 0.02 (khuli 1680.97 se 1755.10) = -3,800.42 USC
              misaal: (1635.75 - 1748.74) x 2 = -225.98 USC | tokri ka kul = -3,116.42 USC

LAMBI - tokri #65 (3,341 lots, 1 Oct 2013 - 2 Nov 2014 = 13 mahine, kabhi khali nahi hui)
 3,258 lots TP par = +9,796.00 USC | rukh palte par 83 lots band (c2) = -7,312.26 USC
 aakhri: 2 Nov 2014 ko 27 BUY 0.01 (khuli 1255.58 se 1321.14) bid 1170.21 par = -3,199.15 USC | tokri ka kul = +2,483.74 USC
```

## 7. Fable ki jaanch

- **Do tareeqe (a):** engine (C, sab hisaab cent-int) ke muqable mein ALAG likha Python "hawala" jo har cent par EA ka Work() chalata
  hai. 1 mahina x 8 variant (Mar 2015, Aug-Sep 2011), poora saal 2011 x 4 variant (31 se 74 hazaar line), aur chune hue variant ka
  poora saal 2013 dono raaston par (12-13 hazaar line): har lot ka khulna / band hona, equity, girawat **bilkul barabar**
  (`docs/k4-natije/ref_*.txt`).
- **Do tareeqe (b):** sab kuch dobara chalaya - CHUNAO ki 324 line aur IMTIHAN ka poora output byte-ba-byte wahi.
- Saada Turtle ka P/L din ke open se alag hisaab (pandas) = barabar (4 mein 4). 2015 ko doosre zariye (QDM) se badla: -34.6% (MAIN
  -34.9%); mashkook candle kaat kar: -37.5%.
- Shuru 100,000 USC (hukm ka doosra run): CHUNAO -17.9% (1 hadd), IMTIHAN account khatam (13 hadd, Jan 2026).
- Chhoti hadd wale variant (sirf naap): bhari lot bhi 0.01 = CHUNAO -23.4%, IMTIHAN khatam; max 10 lots = -22.2%, khatam; hadd 5% = khatam, khatam.
- **Jahan yaqeen kam hai:**
  1. *Candle ke andar raasta* (asli tick nahi): CHUNAO mein 4 raaste -3.6% se -34.9% tak = bara farq. Magar kisi raaste par nafa nahi
     aur IMTIHAN sab par khatam -> faisla nahi badalta, sirf "kitna bura" kaccha hai.
  2. *Spread hamesha $0.24 maana.* Asal mein khabar / rollover par spread phailta hai (EA 0.60 se upar nayi lot nahi kholta) -> sim
     machhli ki kamai ZYADA dikhata hai; asal is se bura hoga, behtar nahi.
  3. *histdata 2009-10 ki qeemat moti* (Dukascopy se ausat farq $0.27-0.42) -> CHUNAO ke pehle 2 saal kacche; 2011 ke baad theek.
  4. *Exness ki apni qeemat, 1-second, slippage* nahi -> chhota asar.
  5. *Hadd ke baad "agle din naye sire se"* (hukm). Agar hamesha STOP ho: pehli hadd CHUNAO 4 Nov 2009 (-7.5%), IMTIHAN 18 Jul 2019
     (-0.6%: 18 mahine mein +9.4% kamaya, ek hadd mein 10% gaya).
  6. MT5 tester mein nahi chala (cloud mein MT5 nahi; FAIL ke baad zaroorat bhi nahi).

## 8. Zaroori mashwara (5)

1. **tk2 ko LIVE par na lagayein.** Har saal alag chala kar: tk2 (4H Supertrend) 18 mein se 18 saal nuqsan, Turtle rukh ke saath bhi 15
   saal; 2025-26 jaise bazaar mein account usi saal khatam.
2. **K5 (Turtle rukh wala EA) na banayein** - aur kisi aur rukh ke saath bhi yahi dhaancha nahi: rukh perfect ho tab bhi fail (sec 3b).
3. **tk2 ka CLOSE ALL qaida chalta hi nahi** (0 dafa). Demo par tk2 dekhte waqt "tokri faide mein band" ki umeed na rakhein; do aur
   matlab (F1, F2) bhi CHUNAO mein fail.
4. **AAKHRI HADD 10% pakki nahi** - weekend gap par 15.8% tak gayi; aur $2 ka fixed Step aaj ke gold par roz 80-280 lots banata hai.
5. **Rukh ka faida saada lot se aata hai, tokri se nahi** (Turtle 0.02 lot: IMTIHAN +4% se +7.5%, girawat 6.5%). Trend ka kaam
   JasTrendEA pehle se kar raha hai; tokri us par jorne se faida ghat-ta hai.

## 9. User ke liye sawal (sirf "?" wale)

FAIL ki wajah se (a) / (b) / (c) ke jawab ab zaroori nahi - teeno / dono soorat fail hain. Sirf ye:
1. **"CLOSE ALL faide mein" se aap ka matlab?** (i) sirf khuli lots ka NET (tk2 code), (ii) tokri ka kul hisaab (band munafa + khula),
   (iii) lot ka TP hi nahi. Teeno test ho chuke (sab fail) - sirf record ke liye.
2. **Intezar wali lot aap haath se kab aur kaise nikalte hain?** (METHOD.md: "koi qaida nahi".) Jab tak ye lafzon mein na ho, koi EA
   ye hissa nahi kar sakta - aur isi hisse par saara nateeja khara hai.
3. **"$1000 = 100,000 USC"**: purana sim $1000 USD standard tha (0.01 lot = $1). Maine hukm ke lafz (cent, 100,000 USC) par chalaya; 38,000 aur 100,000 dono par FAIL.

## Dobara chalana

`python3 tools/k4_tokri_turtle.py data | ref 2011 | sanity | chunao F0 F1 F2 F3 | imtihan | jaankari | hasas | waqiat | tashreeh | ghaib | log`
(pehli dafa data jorne mein ~1 minute; cache `K4_CACHE` ya /tmp mein.)
