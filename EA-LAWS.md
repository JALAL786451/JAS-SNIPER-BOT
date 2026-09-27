# JAS Basket EA — QANOON ki list

Ye chalti hui list hai. Jab bhi testing ke dauran koi aisi baat nikle jo
pehle nazar nahi aayi, woh yahan likhi jayegi — chhoti ho ya bari.

Har qanoon ke saath: **[AAPKA]** = aap ka apna qaida, **[NAAPA]** = aap ke
statement se naapa hua number, **[BACHAO]** = EA ko ghalti se rokne ke liye.

Status: ✅ = EA mein hai aur chal raha hai · ⏳ = abhi likhna hai · ❓ = pehle
aap se poochna hai

---

## Lots kab lagti hain

| # | Qanoon | Kis se | Status |
|---|---|---|---|
| L1 | Bara rukh (H1 EMA50) dekh kar **usi taraf** pehli lot. Ulti taraf hamla nahi | [AAPKA] | ✅ |
| L2 | Zoor usi taraf rahe to **ek qadam door** aur lot. Gold par qadam $1.00, baqi par ATR(14) | [AAPKA] | ✅ |
| L3 | Lot akeli faide mein aa jaye to **band kar do**, phir rukh dobara dekho | [AAPKA] | ✅ |
| L4 | Koi lot **3.5 qadam khilaf** chali jaye to **ulti lot** (gold par $3.50) | [AAPKA] | ✅ |
| L5 | Ulti lot sirf tab jab woh taraf **halki** ho — warna EA ulat kar doosra ambaar laga deta | [BACHAO] | ✅ |
| L6 | Lot ka size **kabhi nahi barhta** — 0.01. Statement: 1,661 / 1,964 trades 0.01 par | [NAAPA] | ✅ |

## Kab rukna hai

| # | Qanoon | Kis se | Status |
|---|---|---|---|
| L7 | **Net** (buy − sell) ki hadd 0.20. Us par pohnch kar sirf ulti taraf | [BACHAO] | ✅ |
| L8 | **Kul lots** ki hadd 1.00. Us par pohnch kar **koi lot nahi** — na seedhi na ulti, sirf INTEZAR | [BACHAO] | ✅ |
| L9 | **Equity** balance ke 90% se neeche jaye to naye lots band. Naapa: sab se neeche 90.95% | [NAAPA] | ✅ |
| L10 | **Bari news** (NFP, CPI, FOMC) se **30 minute pehle** se **5 minute baad** tak koi nayi lot nahi — na hamla, na bachao. Khuli lots **joon ki toon** | [AAPKA] | ✅ |

## Kab band karna hai

| # | Qanoon | Kis se | Status |
|---|---|---|---|
| L11 | Sab mila kar **+50** ho jaye to **Close All**. Naapa: 36 Close All ka darmiyana +54.80 | [NAAPA] | ✅ |
| L12 | Ek lot **+14** par akeli band. Naapa: 1,140 aisi lots ka ausat +13.98 | [NAAPA] | ✅ |
| L13 | Jori: sab se achi + sab se **buri** lot ek saath. Akeli achi band karne se kitab mein sirf buri bachti hain | [BACHAO] | ✅ |
| L14 | Koi **SL ya TP nahi**. Statement: 1,964 mein se 15 par SL, khuli 135 mein se 0 | [NAAPA] | ✅ |

## Spike (L17)

| # | Qanoon | Kis se | Status |
|---|---|---|---|
| L17 | **Spike** (ek candle ka phaila 3 qadam se bara) ke dauran **Close All nahi — hedge**. Net sifar kar do, phir spike chahe jitna bara ho, na faida na nuqsan | [AAPKA] | ✅ |
| L18 | Spike ke dauran **kuch band nahi hota** — Close All, faide wali lot, jori, teeno ruk jate hain | [AAPKA] | ✅ |
| L19 | Spike ka hedge **L10 (news) ki rok se guzar sakta hai** — sirf hedge, aur koi lot nahi | [AAPKA] | ✅ |
| L20 | Hedge se KUL lots barhti hain. Hadd **abhi bhi lagu** hai; torne ke liye `InpSpikeOverCap` chalu karna paregi | [BACHAO] | ✅ |
| L21 | **Hedge ke liye lot lagana zaroori nahi.** Zyada wali taraf se utni lots **band** kar do — 40 buy / 30 sell mein 10 buy band, ho gaya 30-30. Kul lots **ghatti** hain, barhti nahi, is liye L20 ka masla hi khatam | [AAPKA] | ✅ |
| L22 | Jo lots band karni hain un mein **faida aur nuqsan mila kar** chunni hain — ek acha, ek bura — taake band karne se kitab par zarb na parey | [AAPKA] | ✅ |

## Market ka waqt

| # | Qanoon | Kis se | Status |
|---|---|---|---|
| L15 | **24/7 symbol** (BTC) par "market band" ka qaida lagta hi nahi. Aadhi raat din badalna band hona nahi hai | [BACHAO] | ✅ |
| L16 | **Gold** par market band hone se 30 minute pehle kitab barabar | [AAPKA] | ✅ |

---

## Testing ke dauran jo pata chala

**Cent aur Standard ek jaise hain.** 0.01 lot gold par $1 ki harkat dono par
1 unit hai — farq sirf naam ka (USC / USD). Is liye $52,000 ka Standard demo
aap ke 52,000 USC account ka theek theek naqsha hai, aur cent demo ki zarurat
nahi. (Main ne pehle iska ulat kaha tha; woh ghalat tha.)

**Waqt se lot lagana ghalat tha.** Purana EA har M1 candle par ek lot lagata
tha — 90 minute mein 47 lots, kitab −$17.97, jis mein taqreeban **$4.70 sirf
spread** (1 lot = $0.10 BTC par). Qadam ka qaida (L2) isi liye aaya.

**Net bilkul 0 wali kitab kabhi wapas nahi aati.** Uska P/L qeemat se badalta
hi nahi. Nikalne ka ek hi raasta hai: ek taraf band karna. Panel ab ye saaf
likhta hai.

**MT5 ka news calendar EA ko LIVE milta hai**, Strategy Tester mein nahi —
main ne pehle iska ulat kaha tha. Is liye L10 apne aap chalta hai, waqt haath
se daalne ki zarurat nahi. Agar kisi terminal par calendar na mile to panel
likh deta hai "calendar nahi mila", taake khamoshi se har trade na le le.

**News ke waqt band hona sirf KHOLNE par hai.** Close All, faide wali lot aur
jori — ye teeno chalte rehte hain. Aap ne "joon ki toon rahne de" kaha tha,
jo main ne ye samjha ke kitab ko zabardasti barabar mat karo — faida lene se
mana nahi. Agar ghalat samjha to bata dein.

**Band kar ke hedge karna kholne se behtar hai.** Kul lots ghatti hain
(hadd ka masla nahi), spread kam lagta hai (70 mein se sirf 10 lots), aur sab
se buri lots kitab se nikal jati hain. EA ab pehle yahi koshish karta hai;
lot lagana sirf tab jab band karna mumkin na ho.

Magar **jorh hamesha sifar nahi hoga**. Agar nuqsan wali lots faide walon se
bohot bari hon, to band karne par kuch nuqsan nikelga. Ye hisaab hai, kharabi
nahi.

**Close All ka news se koi taluq nahi.** Agar news ke dauran bhi basket +50 ho
jaye to sab band ho jayega. Aap ne khud ye saaf kar diya.

**Har file par build number** (`b10` waghera) panel ki pehli line mein, taake
screenshot se pata chale ke kaun si file chal rahi hai.
