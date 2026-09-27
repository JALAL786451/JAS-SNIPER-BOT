# JAS Basket EA — qawaid ka masauda

Ye code nahi. Ye **fehrist** hai. Jalal isay parh kar har qaide par kahein
"haan" ya "nahi" — tab code likha jayega.

Do tarah ke qaide hain aur donon ka farq saaf rakha gaya hai:

- **[AAPKA]** — aapke apne 56 khule saudon se GINA gaya. Naqal.
- **[BEHTAR]** — aapne khud kaha ke EA aapki ghaltiyan na karey. Har aisa
  qaida kisi NAAPE HUE number par khara hai, meri raye par nahi.

---

## Hissa 1 — Lots lagana

### Q1. Lot ka size kabhi nahi barhta **[AAPKA]**
Har lot 0.01. Koi doubling nahi, koi martingale nahi.
*Sabut: aapki kitab mein 56 mein se 55 lots 0.01 ki hain.*

### Q2. Ek waqt mein ek jhund, ek ya kai lots **[AAPKA]**
*Sabut: 56 mein se 28 sauday pichhle se 60 second ke andar, 17 sirf 5
second ke andar. Aap ladder nahi, jhund lagate hain.*

### Q3. Net exposure ki hadd **[BEHTAR]**
Net (buy manfi sell) ek muqarrara hadd se ooper nahi jayega. Us hadd par
pohanchte hi EA sirf ULTI taraf lots lagayega.
*Wajah: aap khud 0.24 net tak gaye aur phir 25 minute mein 22 sell laga kar
use 0.01 par laye. EA ko itna door jaane hi nahi dena chahiye.*
**Aapka number chahiye:** net ki hadd kya ho? (aapki misal: 0.24 tak gaya)

---

## Hissa 2 — Kitab jamana (freeze)

### Q4. Jab hadd aa jaye, kitab barabar karo **[AAPKA]**
Ulti taraf itni lots lagao ke net sifar ho jaye.
*Sabut: 25 Sep, 14:06 se 14:31 — 0.24 se 0.01.*

### Q5. Jami hui kitab ko chhero mat **[AAPKA]**
Balanced kitab ka nuqsan barh nahi sakta. Us haalat mein EA kuch nahi karega
siwaye Q8 ke.

---

## Hissa 3 — Market band hone se pehle

### Q6. Market band hone se pehle kitab barabar kar do **[AAPKA]**
Gold band hone se pehle net sifar ke qareeb laya jayega.
*Sabut: abhi gold band hai — aapka net 0.02. BTC khuli hai — net 0.18.
Nau guna farq, aur ye faisla aap har weekend karte hain.*
*Naap: agar gold ki kitab BTC wale net par band hoti aur $50 ka gap aata,
nuqsan 900 USC hota. Aapke 0.02 par sirf 100 USC.*

---

## Hissa 4 — Faida lena

### Q7. Basket poori band, jab kul faida hadd par ho **[AAPKA]**
**Aapka number chahiye:** kitne USC par Close All?
*(METHOD.md ki 10 September wali basket +52.20 USC par band hui thi)*

### Q8. Beech mein faide wali lots band karna — **magar jori bana kar** **[BEHTAR]**
Aapne kaha: faida lo taake equity barhe aur nayi lots ki jagah bane. Theek.
**Magar EA akeli faide wali lot band nahi karega.**

EA ek faide wali lot ke saath **sab se buri nuqsan wali lot** bhi band karega,
BASHARTE dono ka mila kar natija **positive** ho.

*Wajah — ye aapke apne statement se naapa gaya hai:*
> *10-13 September, 110 trades: jeetne wali trade औsat **261 minute**
> rakhi gayi, haarne wali **421 minute**. 1.6 guna zyada.*

*Sirf faide wali nikalne se bachti sirf buri lots hain, aur kitab ka औsat
har baar bigarta hai. Jori bana kar band karne se: faida bhi milta hai, aur
sab se buri lot bhi nikal jaati hai. Kitab behtar hoti hai, buri nahi.*

---

## Hissa 5 — Kitab kholna (Phase 6)

### Q9. EA khud hisaab lagayega ke kholna behtar hai ya nahi **[BEHTAR]**
Har lamha do number:
- **Jami hui kitab** ko barabar aane ke liye qeemat kitni chahiye
- **Ek taraf band** kar dein to kitni chahiye

Jab doosra number pehle se **bohot** chhota ho, EA aagah karega — aur
(agar aap ijazat dein) khud kar dega.

*Abhi ke asli number: jami hui = gold +$669 chahiye. Sell side band karein
to = +$43. Pandrah guna aasan. Ye hisaab aap ko teen-chaar second leta hai,
EA ko sifar.*

---

## Hissa 6 — Equity ka pehra

### Q10. Equity ki hadd **[BEHTAR]**
Ek number jis ke neeche EA **nayi lots lagana band** kar dega — dono taraf.
Sirf kitab barabar karna jaari rahega.

*Wajah: METHOD.md mein likha hai "the actual limit that stops him adding has
not been named." Machine ke liye woh number likha hona lazmi hai, warna woh
kabhi nahi rukegi.*
**Aapka number chahiye.** Misal: equity shuru ke 90% par ruk jao.

### Q11. Har cheez likh kar batana **[AAPKA — METHOD.md se]**
> *"he wants to see anything it does that goes against his method, so it can
> be corrected. That means the EA has to say out loud what it is doing and
> why, not merely do it."*

EA har amal ka sabab likhega.

### Q12. Haath ka qabu, switch nahi **[AAPKA — METHOD.md se]**
> *"Manual control is not a fallback, it is a feature."*

Har hissa alag se band/chalu ho sakega, bina EA band kiye.

---

## Ab kya chahiye

**Teen number aap se:**
1. Q3 — net exposure ki hadd
2. Q7 — Close All ka faida (USC mein)
3. Q10 — equity ki hadd

**Aur ek file:**
Exness statement, **1 September se aaj tak**, account 253687618 — jis mein
"Deals" ka khana ho. Us se main Q3, Q7 aur Q10 khud naap loonga, aur aap ko
sirf haan ya nahi kehna paregi.

---

## Jo is EA mein NAHI hoga

- **Lot doubling / martingale** — aap khud nahi karte
- **Hadd ke baghair lots** — Q3 aur Q10 dono rokte hain
- **Akeli faide wali lot band karna** — Q8
- **Bina hisaab ke intezar** — Q9 har lamha dono raaste ka number dega
