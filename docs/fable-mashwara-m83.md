# Fable se mashwara: gold ka bojh (SELL 3.31 + BUY 2.50) kaise kam ho

(Jalal ki taraf se. Jawab Roman Urdu mein, chhota aur saaf. Saath 4 file: JasMauqa_XAUUSDc.txt,
JasMauqa_XAUUSDc_waqiat.txt, JasMauqa_BTCUSDc.txt, JasMauqa_BTCUSDc_waqiat.txt = EA ka panel + har khuli ticket + popup log.)

## Account
- Exness LIVE, Standard **Cent** (USC), swap-free, hedging allowed, Close By chalta hai.
- 10 Nov 22:27 PKT: balance 64,606.69, equity ~38,560 USC, margin level ~90,000%.
- Gold (XAUUSDc): 1 lot par $1 = 100 USC.

## Gold ka haal (file mein har ticket)
- BUY 28 ticket 3.89 lot avg 4121.812 (P/L -39,495) / SELL 12 ticket 3.69 lot avg 4066.640 (P/L +17,018).
- NET +0.20 lot = nuqsan -22,477 taqreeban **tala-band** (gold $1 = sirf 20 USC). Gold ~4020.
- Do bari lot: **BUY 2.50 @4117.416** (-24,283) aur **SELL 3.31 @4063.571** (+14,249, "dhaal").
- Baqi zyada tar 0.01-0.35 ki BUY 4122-4144 par, aur chhoti SELL 4102-4110 + 4058-4065 par.

## Mera tareeqa (badalna nahi)
- Main khud haath se 0.01 lot "fishing" karta hoon (laddered, hedged basket - meri apni method).
- EA "JasMauqa m8.2" khud koi trade NAHI kholta. Sirf popup deta hai, YES/NO mera:
  - B) jori: nafe wali SELL ka tukra + nuqsan wali BUY ka tukra **Close By** (nateeja hamesha +, NET wahi). 10 Nov: 13 YES = ~+1,250.
  - A) bari lot kam: nuqsan wali bari lot ko nafe wali chhoti ticket se jorna (sirf jab nateeja +).
  - C) akeli profit ticket band - main NO karta (NET badalta).
- Qaide: nayi bari lot (>0.10) NAHI, NET hadd 0.80, SELL 3.31 ko EA kabhi nahi chhoota.

## Ab tak ka hisaab (Claude ne lagaya - jaanch karein)
Close By nateeja = (SELL open - BUY open) x lot x 100, abhi ke daam se azad.
- SELL 3.31 + BUY 2.50 = **-13,461.25** (equity wahi, sirf balance mein pakka).
- SELL 3.31 + 4063.571 se UPAR wali koi bhi BUY = nuqsan (0.05@4108.705 = -225.67; poori 3.31 = -18,077).
- SELL 3.31 + 4063.571 se NEECHE wali 0.01 BUY (~4022) = +~40 har jori.
- Lekin wahi 0.01 BUY purani SELL @4108-4110 ke saath = +~88 (behtar). Wo SELL tukre ~0.22 lot baqi.

## Claude ka khayal (m8.3, abhi bana nahi)
1. Pehle SELL @4108-4110 ke tukre B joriyan mein khatam hon (+88 har).
2. Phir SELL 3.31 ko 0.01 tukron mein: gold 4063 se neeche khuli nayi 0.01 BUY + 0.01 SELL 3.31 = Close By (+~40). NET wahi.
3. BUY 2.50 ke liye A: jab gold 4117 se upar ho aur wahan SELL khule.

## Mere sawal
1. Upar ka hisaab sahi hai? Koi galti?
2. SELL 3.31 ko 0.01 tukron mein kaatna (kadam 2) samajhdari hai ya dhaal kamzor karna khatra hai? Kis hadd tak (masalan kam se kam kitni SELL rehni chahiye)?
3. BUY 2.50 @4117 ka bojh kam karne ka koi aur behtar, mehfooz raasta (bina nayi bari lot, bina NET barhaye)?
4. Kya "sab Close By kar ke saaf karna" (equity wahi) aur nayi shuru karna behtar hai, ya basket rakh kar B wasooli?
5. Gold ~4020, 1D rukh neeche, 4H mila-jula. Kya ye kisi faisle ko badalta hai?
Jawab: har sawal 2-4 line, number ke saath. Andaza ho to "andaza" likhein.

---
## DOOSRA MESSAGE (sirf jab mashwara "haan" ho) - JasMauqa.mq5 (m8.2) attach karke
Is mashware ke mutabiq m8.3 bana do. Qaide:
- **Poori file NAHI** - sirf badle / naye functions + kahan lagane hain (function ka naam). Token bachao.
- EA khud koi nayi trade NAHI kholta; sirf popup YES/NO + Close By. Grid / martingale / averaging NAHI.
- Pehli line + panel par build "m8.3". StringFormat mein kam az kam ek value; string ke liye `cond ? "" : "..."` nahi, Pick() helper.
- Naya input: dhaal SELL ke tukre ka kam se kam baqi lot (default jo aap salah dein), dhaal ki jori sirf jab nateeja + aur pehle 4108-4110 wale SELL tukre khatam.
- MT5 build par F7 0 error hona chahiye (main compile karunga, Claude repo mein jaanchega).
