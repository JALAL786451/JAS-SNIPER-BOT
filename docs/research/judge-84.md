# Judge #84 (Chief Justice, 2 Nov) - gold range bars GATE

**Faisla: CLEAN (koi bug jo nateeja badle nahi). GATE FAIL qaim.**

## 1. colours() - range bar banana
- Aam raasta sahi: close >= open -> O,L,H,C; warna O,H,L,C (`up_first = C<O`). Qaida + research Sec 3 ke mutabiq.
- Bar band jab q >= lo+R (upar) / q <= hi-R (neeche); close lo+R / hi-R; naya bar usi close par khulta (o=hi=lo=close);
  `while` loop se ek minute / ek gap mein kai bar. Rang = close vs bar open (range = R ki wajah se hamesha toot ki taraf). Sahi.
- Sanity: khalis random walk (integer ticks, M1 nahi) R=6, 143K bar, 2 seed: k=1..5 sab 49.3-50.3% (SE 0.1-0.5%).
  Builder mein 50% ki taraf ya door koi jhukaav NAHI.
- Note (bug nahi): "ULTA" code mein har candle ka raasta ulat deta hai (up candle O,H,L,C; down O,L,H,C), jabke
  research Sec 3.6 "always O->H->L->C" kehta hai. Maine literal "hamesha O,H,L,C" bhi chalaya: koi cell paar nahi
  (behtareen $20 k=2 53.5%). Faisla nahi badalta.
- Synthetic random walk ko 20-tick M1 bana kar: aam 50.7% vs ulta 52.1% (k=1) = sirf raasta badalne se +1.4pt
  "continuation". Asli data mein bhi ulta 1-2pt upar. Purana-haal ka sabaq ("edge = data banane ka tareeqa") saabit.

## 2. stats()
- run = i par khatam hone wali ek-rang qatar; run >= k par agla bar same ginta. Brute-force (har i par pichle k bar
  barabar?) se milaya: k=3,5 bilkul same, k=1 mein sirf i=0 ka 1 sample chhoota (9575 vs 9576) - be-asar.
- iid sikka 300K: k=1..5 49.9-50.1%. SE binomial sahi. `i >= k-1` faltu hai, nuqsan nahi.
- k = "kam az kam k" (run >= k). "Bilkul k" (run == k) bhi chalaya: koi cell paar nahi (qareeb-tareen $20 k=5 35.8%,
  n=~50, margin -0.2pt = shor, aur ek akela cell 30 mein se).

## 3. Gate faisla vs likha qaida
- Hurdle 0.24/R (4.8 / 2.4 / 1.2pt) sahi. Aam raasta par |p-0.5| - 2SE - hurdle: SAB 15 cell manfi
  (behtareen $20 k=2 -1.9pt, $10 k=5 -2.3pt). Is liye ulta-raasta shart ka sawal hi nahi uthta.
- Farq (bug nahi): code ulta raasta par bhi 2SE+hurdle maangta hai; qaida sirf "wahi taraf + <30% girawat". Code
  zyada sakht, magar aam raasta khud fail -> nateeja same. keep = |p1-.5| >= 0.7|p0-.5| = qaida ka <30% girawat. Sahi.

## 4. Data
- `load(range(2009, 2014))` = 2009-2013 sirf. dt column check: 2009 276K, 2010-13 ~346-355K, kul 1,684,528. 2014+ nahi.
  Maine bhi 2019+ kuch load nahi kiya.

## Nateeja
CLEAN. Run dobara (27 s) wahi aankre jo purana-haal mein. GATE FAIL qaim; A + B BAND sahi.
