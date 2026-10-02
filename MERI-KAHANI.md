# MERI KAHANI — har nayi chat yahan se shuru kare

Ye file is liye hai ke chat full ya reset ho to Jalal ko apni kahani **0 se na
dohrani pare**. Har nayi chat pehle ye file, phir `ABHI-KAHAN-HAIN.md` parhe.
Tafseel ke liye: `METHOD.md` (method + naape hue number), `EA-LAWS.md`
(qanoon), `EA-QAWAID.md`, `EA-CHECKLIST.md`.

Aakhri update: 2 October 2026.

---

## 1. Main kaun hoon, aur kaise baat karni hai

- Naam Jalal. Pakistan (PKT, UTC+5). Gold (XAUUSD) trader, taqreeban 1.5 saal.
- **Roman Urdu**, chhota aur saaf. Hamesha **"aap"**, kabhi "tu/tera" nahi.
- **SBS** = ek waqt mein ek qadam. Har qadam ke baad main **"D"** likhta hoon.
- **Pehle poochho, phir file banao.** File ke baad sawal nahi.
- Mushkil baat ho to **misaal aur table** se, lambi tehreer se nahi.
- Link hamesha **click hone wala** do (markdown link), aur raw link mein
  commit hash wala bhi do (GitHub kabhi purani copy dikhata hai).
- Mujhe baar baar "aaraam karo" mat kaho - jab thakunga khud bata doonga.
- Main ab MT5 par kaafi theek kaam kar leta hoon (compile, chart par lagana,
  Strategy Tester).

## 2. Accounts

| | Number | Qisam | Note |
|---|---|---|---|
| **LIVE** | 253687618 | Exness MT5 **StandardCent**, `XAUUSDc`, USC, Hedge, 1:2000 | **Swap-free (Islamic)**. 0.01 lot = $1 harkat par 1 USC |
| **DEMO** | 472540009 | Exness-MT5Trial16, `XAUUSDm`, **USD** standard, Hedge | Swap lagta hai: BUY -513.2 points/lot/din (~-$51), Budh 3x, SELL 0 |

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

## 5. Mere tools (repo mein) - kya hai, kis haal mein

| File | Kya karta hai | Haal |
|---|---|---|
| `JasDeskView.mq5` v4.2 | **Sirf parhta hai.** Close-All ginti, lots by size, ausat, NET, BARI LOT KI JORI, PLAN A/B + "NET baad mein" | ✅ Live par chal raha. Kami: "ek taraf band" line sirf ek taraf ka fasla batati hai, poori kitab ka nahi |
| `JasJoriClose.mq5` s1 | **Script.** Bari lot ki lot-barabar jori **Close By** se band, ek Yes/No | ✅ Demo 150/150, **live 64/64 (+550.70 USC, 1 Oct)**. Abhi sasti BUY pehle chunta hai - user upar wali BUY pehle chahta hai (option banana baqi) |
| `JasTideEA.mq5` t4 | Turtle/Donchian 1D, ek position, SL, 1% risk | Compile ✅. MT5 test t3: 132 trades, PF 1.23, DD 46% (Pine: 458, PF 1.56, DD 21%). Shak: demo swap. t4 swap alag ginta hai - **test baqi** |
| `indicators/smc_coach_pro_v2.pine` | SMC dashboard | **Agla kaam** - naqsha `ABHI-KAHAN-HAIN.md` mein manzoor |
| `JasBasketEA.mq5` b20 | Meri method ka EA, sirf apni (magic) lots | Haath ki lots ko nahi chhoota |
| `JasDesk.mq5` | Button wala desk | User ne MT5 se hata diya |

## 6. Kaam ke qaide jo seekhe gaye (dobara ghalti na ho)

- MQL5 `StringFormat("sirf likhai")` → **error**. Kam az kam ek value chahiye.
- String `cond ? "" : "..."` se bacho, `Pick()` helper use karo.
- Har file ki pehli line par **build number**, panel par bhi wahi.
- Script **Scripts** ya Experts folder - dono chalte hain (nishan alag hota hai).
- Live par script/EA chalane se pehle: Algo Trading hara, kaam ke baad **laal**.
  JasDeskView ko Algo Trading ki zarurat nahi (Allow Algo Trading khali).
- Cloud session MQL5 compile nahi kar sakta - user F7 karta hai, error ka
  screenshot bhejta hai.

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
