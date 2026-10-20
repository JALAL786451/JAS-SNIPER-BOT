# TRADING — har nayi chat SIRF ye ek file parhe

**Nayi chat ka message (copy-paste):**
sirf `TRADING` (ye branch 14 Oct se GitHub default - nayi chat seedha yahin khulti hai).
Agar kabhi kaam na kare to lamba: `TRADING — repo JALAL786451/JAS-SNIPER-BOT, branch claude/jas-desk-v3-0110-yu3w2h. Sirf TRADING.md parho aur wahin se shuru karo.`

Aakhri update: 20 Oct 2026 shaam (18vi chat). Ye file **~8 KB se lambi NA ho**. Baqi sab
sirf zaroorat par, poori file nahi - `grep` se:
- `docs/trading-pakki.md` - accounts, user ki method, har pakka sabaq ki ek line, live kitab
- `docs/sabaq-tafseel.md` - sabaq ke poore number
- `docs/purana-haal.md` - purana haal, koshish 1-15 ke pehle se likhe qaide
- `docs/roznamcha/README.md` - **din ba din** (har tareekh ki file, git commits): user "X tareekh tak peechhe jao" kahe to yahin se
- `docs/files-tafseel.md` - har file ki lambi kahani; files ki list bhi yahin; `CLAUDE.md` - sirf EA/MQL5 qaide

Purani files mein `TRADING-MERI-KAHANI` likha ho = ab `docs/trading-pakki.md`;
`TRADING-ABHI-KAHAN-HAIN` = ab ye file (purana hissa `docs/purana-haal.md`).

---

## 1. User aur baat ka tareeqa (saari hidayat: `grep -i <lafz> docs/roznamcha/HIDAYAT.md`, poori nahi)

- Jalal, Pakistan (PKT, UTC+5), gold trader. **Roman Urdu**, chhota, **"aap"**, misaal + table.
- **SBS:** ek qadam, user "D" likhta hai; pehle poochho phir file. **Faisle Claude kare** - A/B/C nahi, sirf AGLA EK QADAM.
- Link click wala + commit hash raw link. Yaad-dihani / "aaraam karo" / ehtiyat ka lecture NAHI. Chart saaf (extra BAND).
- **Live KABHI nahi** jab tak 6 mahine demo nateeja na ho (user 17 Oct) - Claude live ka mashwara na de.
- **Pata na ho:** andaza nahi - poochho "roznamcha mein X tareekh dekhun?" (ek din). EA kaam: pehle `CLAUDE.md`.

## 2. Usage bachao

- Hafte ki limit **80%** (14 Oct; reset Itwar 18 Oct 02:00 PKT). Agent / workflow sirf jab
  user naam le kar maange; 50%+ par bilkul nahi.
- Nayi chat ~1 lakh token se shuru hoti hai (app ki apni hidayat ~40-60k). Effort **medium/high**
  (xhigh nahi), chhota kaam Sonnet. Har tool qadam par poori chat dobara parhi jati hai -
  kam qadam, chhote jawab, bari file `grep` se. **~15-20 message ya kaam khatam = user "chat khatam"
  likhe -> sec 5 likh kar push -> nayi chat "TRADING"** (chat bharne / summary ka intezar NAHI).

## 3. Accounts (tafseel `docs/trading-pakki.md` sec 2)

| | Number | Kya |
|---|---|---|
| LIVE | 253687618 | Exness StandardCent, XAUUSDc, USC, swap-free, Hedge, 1:2000. Koi EA nahi |
| DEMO | 472716649 | Exness-MT5Trial16, USD, Hedge - saare EA demo yahin |

Doosre demo: 472540009, 474651829 Pro. EA wale chart ke saath live par login kabhi nahi.

## 4. Test ka qaida (13 Oct - badalna mana)

1. Naya idea sirf **TALAASH** data par: MT5 2021-2024, TradingView shuru-2018. Jitni koshish chahein.
2. TALAASH PASS (trades >= 100, Exp - 2SE > 0, saal ka hissa musbat) -> **IMTIHAN** (MT5 2025-aaj /
   TV 2019-aaj) **ek dafa**, bina tabdeeli. IMTIHAN data tab tak chhupa.
3. IMTIHAN Exp > 0 + trades >= 30 = **ASLI PASS** -> demo. Nateeja dekh kar market chuna to IMTIHAN
   sakht: **Exp - 2SE > 0**. IMTIHAN FAIL = idea band.
4. Qaida test se PEHLE likho; har koshish sec 8 ki ginti mein. Gold 2025-26 tezi: BUY/SELL alag dekho.

## 5. PICHLI CHAT (har chat ke aakhir mein sirf ye hissa naya likho)

**Kitab (16 Oct, LIVE):** 183 pos, NET 0, balance 50,089, equity ~43,743 - har lot `data/kitab/JasDeskView_XAUUSDc_2026-10-16_1230.csv`.
**20 Oct shaam (18vi chat):** demo 3 EA theek (SS ✅, sec 7). VPS (~$10-15) user abhi NAHI lega - us ki baat band.
a12 natija (17vi): 15m saaya = bunyaad (sikka), 1D 300 saaye +5 (hadd ±6) = shor (`docs/trading-pakki.md` sec 4).
**AAINA a13 = a12 ki TWEAK, wahi file `indicators/jas_aaina.pine` (1062 lines, raw `1eae50b`).** User: alag chhoti script
NAHI ("800+ ko 200+ bana diya" - maine alag `jas_aaina_agli.pine` banayi thi, delete). Har agla build isi file mein.
a13 = **Settings 6 AGLI candle:** har band candle par isi nishani (default "Sirf Rang"; TF 15m/1H/4H/1D + TF 5 1W band) ke
pichhle mauqon mein AGLI candle hari/laal % + ausat high/low/close (open se) -> aage saaya candle + label "AGLI 15m: HARI x%
· n mauqe · bunyaad y%" (rang sirf andaze ki taraf bunyaad se 2SE, warna saleti "shor"); chalti candle par halka "ABHI
chalti"; pichli 20 candles par ✔/✖ (tooltip); Record dabba qatar "AGLI candle: sab" + "AGLI: sirf rang wale" vs bunyaad
(hamesha zyada wala rang). Sirf pichhla data. pinecheck ✅ + 5 reviewer jaanch (5 chhoti theek). **TV compile BAAQI.**
**AGLI CHAT - user a13 SS bhejega. Jaanch:** (1) error/warning? (2) saaya candle + label + ✔/✖ dikhe; "andaza nahi" =
mauqe < 30 (agMin); (3) record 2 qataren: % vs bunyaad, neela sirf 30+ aur 2SE - 15m par umeed ~bunyaad (a12 sabaq);
(4) nishan a12 ke labels par charhe? Timeout -> agMk / recN kam. **Tweak (ek waqt ek, user "D"):** AGLI 1D chart par (dam
daily mein), TF 5 1W chalu, agMode "Settings 1 jaisa", "sirf rang wale" ka ausat chal spread ke muqable (15m spread kha jata).
**User ka maqsad:** a12/a13 se 15m par Kachhua jaisa P/L, trades zyada, DD kam - "a100 tak". Asal faisla 10 saal data
(koshish #23 qaida - draft is chat mein: 1D EMA50/200 band candle rukh + 15m 20-candle toot, SL 2ATR, 10 ulta toot band,
TALAASH Dukascopy 2015-24 trades >= 300, Exp-2SE > 0, 7/10 saal, DD < 1D Kachhua; IMTIHAN 2025+ sakht) - user "D" baqi.
**User ka (jab chahe):** QDM export (Generic bar, M1, Timezone Original): USATECHIDXUSD 2023-24, XAUUSD 2021-22, XAUUSD 2023-24 (+ #23 ke liye XAUUSD 2015-2020) ->
upload -> Python #21 (`JasOrb5EA`, UTC->NY) phir #22. 2025+ mat kholo.
**Koshish #22 qaida (18 Oct, badalna mana) - Fib OTE (`jas_fib_swing.pine` f5):** XAUUSD 15m, swing 1H pivot 5 (band candle),
entry 0.618 limit, SL swing + 5% swing, TP 1.272, intraday, 1 trade ek waqt / 1 fi leg, risk 1%, ek candle SL+TP = SL, spread
asli se zyada. TALAASH 2021-24: trades >= 100, Exp - 2SE > 0. TV pehli nazar (gold 58 trade +2.7R, bina spread) = IMTIHAN SAKHT.
**Koshish #21 qaida (17 Oct, badalna mana):** sirf USTEC 5m (`JasOrb5EA.mq5` o1). Exness USTECm data sirf 2025.09.21 se = Dukascopy (QDM).
Data 2021-22 repo mein `data/ustec/USTEC_M1_2021-2022_dukascopy.zip` (sirf Bid = spread fixed, zyada rakho).

## 6. RUKA HUA: JasIbsEA i3 (daily candle 17:00 NY) - naqsha `docs/purana-haal.md` ("RUKA HUA ... i3")

## 7. Demo (472716649) aur IBS ka haal

| EA | Chart | Magic | Markets | Haal 20 Oct (SS ✅) |
|---|---|---|---|---|
| JasTideRadarEA e1 (Kachhua) | XAUUSDm D1 | 20261009 | XAU, XAG, EUR, GBP, AUD, JPY, CHF, US500, BTC | TRADE CHALU, suffix 'm'. USDJPYm BUY 0.33 @ 158.527, SL 157.543. Chhooti (EA band tha): XAG SELL, EUR SELL. USDJPYm chart wala dusra EA hatana tha (ek magic = ek chart) |
| JasRsi2EA c2 | US500m D1 | 20261012 | US500, USTEC, US30 | Pehle XPTUSDm par tha (suffix '' = 3 market "nahi mila") -> US500m, TRADE CHALU, intezar |
| JasTideRadarEA e1 (Commodity) | XPTUSDm D1 | 20261018 | USOIL, UKOIL, XNGUSD, XCUUSD, XPTUSD, XPDUSD | Inputs gold wale ho gaye the -> theek. USOIL BUY 0.05 @ 93.810, SL 88.987 (+0.78R). Chhooti: UKOIL BUY, XPT SELL, XPD SELL |

- Har EA ka faisla: kam az kam **6 mahine** (user 17 Oct, ~Apr 2027) + 10-15 band trades, har trade TV se mile. **Mila ✅ (user, pehle):** demo ki khuli trade TV Pine par bhi dikhi.
- IBS #15 (S&P ASLI PASS) ki tafseel + IBS demo qaida: `docs/purana-haal.md` (grep "IBS demo qaida").

## 8. Koshish ginti (tafseel `docs/purana-haal.md`, grep "Koshish ginti 17 Oct")

1-5 FAIL · **6 Kachhua commodity ASLI PASS (demo)** · 7-14 FAIL · **15 IBS S&P ASLI PASS (JasIbsEA)** ·
16 order flow SIKKA · 17 SELL band/dobara FAIL · 18 MA 63/91 + EMA 63/93, 20/50 (MT5) FAIL · 19 SMC: LGB/FVG FAIL, DZ/SZ 4H MT5 baqi ·
20 Kitab Tukda FAIL · **21 ORB USTEC 5m - data 2021-22 mila, 2023-24 baqi** · **22 Fib OTE gold 15m - data ka intezar**.
Faida sirf daily par mila; zyada trades chahiye to zyada MARKET, chhoti TF nahi.

## 9. Chat ke aakhir mein (ye file zinda rahe)

- Sec 5 "PICHLI CHAT" naya likho (2-4 line: kya hua, agla kaam, "D" baqi ya nahi); kaam badla to sec 6-7.
- Naya pakka sabaq -> `docs/trading-pakki.md` sec 4 mein EK line, poore number `docs/sabaq-tafseel.md`.
- Naya pakka jawab -> `docs/sawal-jawab.md` mein EK line. Phir `python3 tools/roznamcha.py` (din ki file + FEHRIST.txt).
- Ye file 8 KB se lambi ho to purana hissa `docs/purana-haal.md` mein. `docs/files-tafseel.md` ki chhoti list mein nayi
  file ki ek line. Commit + push - apni branch AUR default `claude/jas-desk-v3-0110-yu3w2h` dono par.
