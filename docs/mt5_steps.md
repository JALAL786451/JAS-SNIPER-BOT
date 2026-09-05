# MT5 + MetaEditor — qadam ba qadam (yaad karne ke liye)

Ye file is liye likhi gayi hai ke MT5 mein sab se zyada waqt **file dhoondne**
mein zaya hota hai, code likhne mein nahi. Neeche har cheez ki jagah tay hai.

---

## HISSA 1 — Folder kahan hain

MT5 apni files Windows ke ek chhupe hue folder mein rakhta hai. Us ka poora
raasta aisa hota hai:

```
C:\Users\<aap ka naam>\AppData\Roaming\MetaQuotes\Terminal\<lambi hash>\
```

Wo `<lambi hash>` har install ka alag hota hai — jaise `D0E8209F77C8CF37AD8BF550E51FF075`.

### Sab se ahem usool

> **Is folder ko kabhi haath se na dhoondein.**
> Hamesha MetaTrader ke andar se kholein: **File → Open Data Folder**

Wajah: aksar computers par MT5 ke **do** data folder ban jate hain (ek purana
install ka, ek naye ka). MetaEditor ek dikhata hai, MetaTrader doosra parhta
hai. File compile ho jati hai magar terminal ko nazar nahi aati.

**MetaEditor ke Navigator se jo folder khulta hai us par bharosa na karein.**

### Andar kya kya hai

```
<data folder>\
│
├─ MQL5\
│   ├─ Experts\        ← EA (.mq5 aur .ex5) YAHAN
│   ├─ Indicators\     ← indicators
│   ├─ Scripts\        ← ek baar chalne wale scripts
│   ├─ Include\        ← Trade\Trade.mqh waghera (library)
│   ├─ Files\          ← EA jo files parhta/likhta hai
│   ├─ Logs\           ← EA ke apne logs
│   └─ Presets\        ← .set files (settings ki copy)
│
├─ config\             ← terminal ki settings — HAATH NA LAGAYEN
├─ tester\             ← Strategy Tester ka cache
└─ logs\               ← terminal ke logs
```

| Cheez | Jagah |
|---|---|
| Source file (`.mq5`) | `MQL5\Experts\` |
| Compiled file (`.ex5`) | `MQL5\Experts\` (khud banti hai) |
| Compile ka log | usi jagah, `<naam>.log` |
| Settings ki copy (`.set`) | `MQL5\Presets\` |
| Config | `config\` — na chhuein |

---

## HISSA 2 — Nayi EA file lagane ke 9 qadam

### 1. Data folder kholein

MetaTrader 5 → menu **File** → **Open Data Folder**

Explorer ki khirki khul jayegi. **Yehi asal folder hai.**

*Check:* address bar mein `MetaQuotes\Terminal\<hash>` nazar aana chahiye.

---

### 2. Experts tak jayen

Us khirki mein: **MQL5** par double-click → **Experts** par double-click

*Check:* address bar ab `...\MQL5\Experts` dikha raha ho.

---

### 3. File yahan rakhein

Apni `.mq5` file **copy** kar ke yahan **paste** karein.

Cut na karein — asal copy apne project folder (Documents\JAS-BOT) mein rehne dein.

*Check:* file list mein aap ki file nazar aa rahi ho.

---

### 4. MetaEditor kholein — magar isi file se

Us `.mq5` file par **right-click → Open with → MetaEditor**

Ya: MetaTrader mein **Tools → MetaQuotes Language Editor** (F4)

**Zaroori:** MetaEditor ke andar file kholte waqt bhi usi raaste se kholein.
Navigator mein jo "Experts" dikh raha hai wo doosra folder ho sakta hai.

*Check:* MetaEditor ki title bar mein file ka poora raasta dekhen — us mein
wohi `<hash>` hona chahiye jo step 1 mein tha.

---

### 5. Compile karein

MetaEditor mein **F7** dabayen (laptop par shayad **Fn + F7**)

Ya toolbar par **Compile** ka button.

*Check:* neeche "Errors" khirki mein likha aaye:
```
0 error(s), 0 warning(s)
```

**Agar errors aayen:** unhein parhen. Har line mein file ka naam, line number
aur masla likha hota hai. Theek karke dobara F7. Zero tak dohrayen.

---

### 6. .ex5 bani ya nahi — check karein

Wapas `MQL5\Experts` folder mein jayen.

Ab wahan **do** files honi chahiye:
```
meri_ea.mq5     ← source
meri_ea.ex5     ← compiled  ← YE ZAROORI HAI
```

`.ex5` ki **tareekh aur waqt abhi ka** hona chahiye.

*Agar `.ex5` nahi bani ya purani tareekh ki hai:* aap ne ghalat folder mein
compile kiya hai. Step 1 se dobara shuru karein.

---

### 7. MetaTrader ko batayen

MetaTrader mein Navigator (**Ctrl + N**) → **Expert Advisors** par
right-click → **Refresh**

*Check:* list mein aap ki EA ka naam aa jaye.

*Agar ab bhi nahi aaya:* MetaTrader **band karke dobara kholein**.
*Phir bhi nahi:* ghalat folder — step 1 se dobara.

---

### 8. Strategy Tester chalayen

**Ctrl + R** → neeche Tester khulega → **Settings** tab

| Khana | Kya bharein |
|---|---|
| Expert | apni EA chunein |
| Symbol | `XAUUSDm` (Exness par `m` lagta hai) |
| Period | `M15` waghera |
| Date | jo arsa test karna ho |
| Deposit | jitna account farz karna ho |
| Modelling | "Every tick based on real ticks" (sab se theek) |

Phir **Start**.

---

### 9. Inputs check karein

Tester ke **Inputs** tab mein dekh lein ke jo values aap ne source mein likhi
thin, wohi dikh rahi hain.

**Agar purani values dikh rahi hain:** MT5 ne settings file ke **naam** se
yaad rakhi hui hain. Do hal:

1. Inputs tab mein right-click → **Defaults** (ye `.ex5` se dobara parhta hai)
2. Kaam na kare to **file ka naam badal dein** (`meri_ea_v2.mq5`), dobara
   compile karein, aur naye naam wali chunein. Naya naam = koi purani yaad nahi.

---

## HISSA 3 — Masle aur un ke hal

| Masla | Asal wajah | Hal |
|---|---|---|
| Compile 0 errors, magar EA list mein nahi | Do data folder | Step 1: File → Open Data Folder |
| `#include <Trade\Trade.mqh>` nahi milta | File `MQL5\Experts` se bahar hai | File ko `MQL5\Experts` mein le jayen |
| Inputs purane dikhte hain | MT5 ka cache (file ke naam se) | Defaults, ya file ka naam badlein |
| `.ex5` nahi bani | Compile hua hi nahi, ya doosre folder mein | `.ex5` ki tareekh dekhen |
| EA chart par laga magar trade nahi karta | AutoTrading band hai | Toolbar ka **AutoTrading** button hara karein |
| Chart ke kone mein 😔 ka chehra | AutoTrading band, ya EA ne mana kiya | Journal tab parhen |
| "invalid stops" error | SL/TP broker ki kam se kam doori se qareeb | `SYMBOL_TRADE_STOPS_LEVEL` dekhein; XAUUSDm 3-digit hai, 300 points = $0.30 |

---

## HISSA 4 — Zubani yaad rakhne wali cheezen

**Chaar shortcut:**

| | |
|---|---|
| **F4** | MetaEditor kholo |
| **F7** | Compile karo |
| **Ctrl + R** | Strategy Tester kholo |
| **Ctrl + N** | Navigator kholo |

**Teen usool:**

1. **Folder hamesha MetaTrader se kholo** (File → Open Data Folder), MetaEditor se kabhi nahi
2. **`.mq5` file hamesha `MQL5\Experts` mein**, kahin aur nahi
3. **Purani settings chipak jayen to file ka naam badal do**

**Ek jumla jo poora amal yaad dila deta hai:**

> Data folder kholo → Experts mein file rakho → F7 → `.ex5` ki tareekh dekho
> → Navigator refresh → Ctrl+R → Inputs check karo

---

## HISSA 5 — Repo ke apne tools (Windows)

Agar aap ne repo clone kiya hua hai to ye khud bhi kaam karte hain:

```
tools\compile.bat                       :: sab .mq5 compile karo
tools\compile.bat TrendMomentumEA.mq5   :: sirf ek

tools\backtest.bat TrendMomentumEA
```

`compile.bat` khud `metaeditor64.exe` dhoond leta hai, log banata hai
(`<naam>.log.txt`, UTF-8 mein parhne ke qabil), aur errors ginti ke sath
dikhata hai.
