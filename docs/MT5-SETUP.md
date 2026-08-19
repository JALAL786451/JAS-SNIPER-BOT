# Exness MT5 Setup Guide (Roman Urdu)

Yeh guide 3 cheezein cover karti hai:
1. Laptop par Exness MT5 install aur login
2. `JAS_Sniper_EA.mq5` ko chalana
3. Strategy Tester mein backtest karna

---

## 0. Pehle yeh samajh lein — kaunsi cheez kahan chalti hai

| File | Kahan chalti hai | Kaam |
| --- | --- | --- |
| `sniper_backtest.pine` | **Sirf TradingView** | Chart par backtest, signal dekhna |
| `mql5/JAS_Sniper_EA.mq5` | **Sirf MetaTrader 5** | Exness par backtest **aur** live trading |

Dono mein **logic bilkul same** hai. Pine Script MetaTrader mein kabhi compile nahi hogi,
aur MQL5 TradingView mein nahi chalegi — yeh do alag duniyaein hain.

**Exness Terminal (web) aur Exness Trade (mobile) mein backtesting ka feature mojood
hi nahi hai.** Backtest sirf MT5 desktop (Windows) ya TradingView par hota hai.

---

## 1. MT5 install aur login

### Step 1 — Sahi jagah se download karein
Exness **Personal Area** (browser) → **Downloads / Platforms** → **MetaTrader 5 for Windows**.

> Kisi bhi doosri website se download na karein. Exness ki apni build mein saare Exness
> servers pehle se list hote hain; general build mein woh nahi milte.

### Step 2 — Apni account ki details nikaalein
Personal Area → **My Accounts** → apne USC account par click karein. Wahan se teen cheezein chahiye:

| Cheez | Misal | Note |
| --- | --- | --- |
| Account number | `123456789` | Yeh aapka **login** hai |
| Trading password | — | Personal Area ke password se **alag** hota hai |
| Server name | `Exness-MT5Real...` | Poora naam **copy** karein |

### Step 3 — Login
MT5 kholein → **File → Login to Trade Account**

| Field | Kya daalna hai |
| --- | --- |
| Login | Account **number** (email **nahi**) |
| Password | **Trading** password (Personal Area ka **nahi**) |
| Server | Personal Area se copy kiya hua exact server |

### Agar login fail ho — error ke hisaab se hal

| Neeche daayen kone mein likha aata hai | Wajah | Hal |
| --- | --- | --- |
| `Invalid account` | Login/password/server mein se koi ghalat, **ya account MT4 ka hai** | Personal Area mein confirm karein ke account MT5 ka hai; trading password reset karein |
| `Authorization failed` | Password ghalat | Personal Area → **Change trading password** |
| `No connection` / `Common error` | Firewall, antivirus, proxy ya ISP block | Mobile hotspot par try karein; `Tools → Options → Server` mein proxy **off**; MT5 ko firewall mein allow karein |
| Server list mein Exness hai hi nahi | Ghalat build download hui | Exness Personal Area se dobara download karein; ya `File → Open an Account` → search mein `Exness` likh kar scan |
| Account number type hi nahi ho raha | Investor password use ho raha hai | Investor password read-only hai — trading password chahiye |

> **Investor password** se login ho jata hai lekin trade nahi hoti — agar sab kuch dikh
> raha hai magar order place nahi ho rahi, to yahi wajah hai.

---

## 2. EA install karna

1. MT5 → **File → Open Data Folder**
2. `MQL5` → `Experts` folder kholein
3. `JAS_Sniper_EA.mq5` us folder mein copy karein
4. MT5 mein **Navigator** panel (Ctrl+N) → **Expert Advisors** par right-click → **Refresh**
5. EA par double-click → **MetaEditor** khulega → **Compile** (F7) dabayein
6. `0 errors, 0 warnings` aana chahiye

### Chart par lagana (live/demo trading)

1. **XAUUSD** chart kholein, timeframe **M15 ya H1** rakhein
   > ⚠️ H4 ya usse bara timeframe na rakhein — EA start hi nahi hoga, kyunke HTF filter
   > chart ke timeframe se **upar** hona zaroori hai.
2. Toolbar mein **Algo Trading** button ON karein (green ho jaye)
3. Navigator se EA ko chart par drag karein
4. `Common` tab → **Allow Algo Trading** par tick lagayein
5. `Inputs` tab → settings adjust karein → **OK**
6. Chart ke daayen upar kone mein 🙂 **smiley face** aana chahiye. Agar ❌ cross hai to
   Algo Trading off hai ya EA ne error diya hai — **Experts** tab (Ctrl+T) mein wajah likhi hogi.

---

## 3. Strategy Tester mein backtest

1. MT5 → **View → Strategy Tester** (ya `Ctrl+R`)
2. Settings bharein:

| Field | Value |
| --- | --- |
| Expert | `JAS_Sniper_EA` |
| Symbol | `XAUUSD` (aapke broker par `XAUUSDm` jaisa bhi ho sakta hai) |
| Period | **M15** ya **H1** |
| Modelling | **Every tick based on real ticks** (sab se sahi) |
| Date | Kam se kam **2-3 saal** |
| Deposit | Apni asal equity ke qareeb |
| Forward | `No` (pehli baar) |

3. **Start** dabayein
4. Pehli dafa MT5 Exness se history data download karega — **thora waqt lagega**, sabar karein
5. **Graph** tab equity curve dikhayega, **Backtest** tab poori report

### Report mein kya dekhein

| Metric | Kya theek hai |
| --- | --- |
| **Profit Factor** | 1.3 se upar |
| **Max Drawdown %** | Jitna kam ho utna acha — 20% se upar khatarnaak |
| **Total Trades** | 100 se kam ho to natija bharosemand nahi |
| **Recovery Factor** | 2 se upar behtar |

> **Sirf net profit mat dekhein.** 300% profit with 60% drawdown ka matlab hai ke real
> mein aap ka account beech raaste mein khatam ho jata.

---

## 4. Session settings ka masla (zaroori)

MT5 ka EA **broker ke server time** par chalta hai, aapke laptop ke time par nahi.
Exness ka server time aam tor par GMT+2 / GMT+3 hota hai (season ke hisaab se badalta hai).

Default `InpSessStart = 9`, `InpSessEnd = 22` — yeh **server time** hai aur mota-moti
London + New York hours cover karta hai.

**Apne server ka waqt aise check karein:** MT5 → **Market Watch** (Ctrl+M) ke upar
current time likha hota hai. Use apne local time se compare karein, phir farq ke hisaab
se `InpSessStart` / `InpSessEnd` adjust karein.

---

## 5. Cent (USC) account ke liye note

Cent account par balance cents mein dikhta hai, is liye:

- `InpUseRiskQty = true` rakhein — EA khud equity se lot size nikal lega, chahe cent ho ya dollar
- Lot size ki minimum limit (aam tor par 0.01) phir bhi lagoo hoti hai. Agar equity bohat kam
  hai to 1% risk 0.01 lot se bhi chhota nikle ga aur EA log mein likhega
  `calculated lot size is zero` — us soorat mein ya to `InpRiskPct` barhayein
  ya `InpUseRiskQty` off kar ke `InpFixedLots = 0.01` set karein.

---

## 6. Order jo hamesha follow karna hai

1. **Strategy Tester** par backtest — 2-3 saal ka data
2. **Demo account** par forward test — kam se kam 2-4 hafte, laptop chalta rehna chahiye
3. Uske baad **cent account** par sab se choti size
4. Sirf tab jab teeno steps ka natija consistent ho, size barhayein

Yeh EA abhi tak kisi bhi real market data par test nahi hua hai. Step 1 aur 2 skip
karna paisa zaya karne ka sab se tez tareeqa hai.
