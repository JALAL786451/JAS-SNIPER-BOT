# HIDAYAT - user (Jalal) ki saari hidayat, ek line har ek

**Kab parho:** SIRF jab koi baat `CLAUDE.md` / `TRADING.md` mein na mile aur user ki marzi ka pata na ho.
Poori file NAHI - `grep -i <lafz> docs/roznamcha/HIDAYAT.md`. Tarteeb ki pehli shart: **TOKEN BACHANA** (user 18 Oct).
Nayi hidayat mile to yahan EK line jodo (lafz | hidayat | tareekh). Purani hidayat se takraye to nayi chalegi.

## A. Baat ka tareeqa

| Lafz | Hidayat | Kab |
|---|---|---|
| zabaan | Roman Urdu, chhota aur saaf, hamesha "aap" (tu/tera kabhi nahi). Misaal + table, lambi tehreer nahi. | pehle |
| SBS / D | Ek waqt ek qadam; user har qadam ke baad "D" likhta hai. Pehle poochho (naqsha), phir file. | pehle |
| faisle | A/B/C mat poochho - Claude khud mashwara le, bataye kya aur kyun, sirf AGLA EK QADAM. Sawal sirf paisa / account / na-palatne wali cheez par. | 8 Oct |
| chhota jawab | A/B/D aaye aur do sawal khule hon to ek line mein poochho kis ka jawab hai. | 7 Oct |
| link | Link click hone wala + commit hash wala raw link. | pehle |
| reminder | "Aaraam karo" / jawab ke aakhir mein yaad-dihani NAHI. "Ruk jayein" mat kaho - agla idea do. | 12 Oct |
| pata nahi | Andaza NAHI - saaf kaho "ye mujhe pata nahi", poochho "roznamcha mein X tareekh dekhun?" Ijazat par sirf EK DIN peechhe. | 17 Oct |
| lecture | Ehtiyat ka lecture har dafa NAHI - user khud 2 guna ehtiyat rakhta hai. Seedha kaam. | 17 Oct |

## B. Trading ke pakke faisle

| Lafz | Hidayat | Kab |
|---|---|---|
| live | Koi EA / Pine qaidon ke khilaf live par KABHI nahi. Live sirf 6 mahine ke demo nateeje ke baad. Claude "thoda live try" ka mashwara NA de. | 17 Oct |
| tarteeb | Hamesha backtest -> demo -> live. | pehle |
| test qaida | TALAASH -> IMTIHAN (ek dafa) -> demo. Qaida test se PEHLE likho, badalna mana. Tafseel `TRADING.md` sec 4. | 13 Oct |
| chart | Chart bilkul saaf: indicator sirf ishara; lakeerein / rang / tables settings mein BAND (default OFF). | 10 Oct |
| EA hard rules | Grid / martingale / hedging / averaging nahi (jab tak user naam le kar na maange); ek market ek position; risk limit khud na barhao. `CLAUDE.md`. | pehle |
| Fishing Lots | User ki apni method (hedged basket) - sahi bayan karo, EA mein mat daalo. `METHOD.md`. | pehle |
| settings | Pine / EA ki settings mein jo cheez user ne kahi ho wo PEHLE SE set karo (default). | 18 Oct |
| kitab | Mashhoor kitab ka qaida (Elder, Weinstein, Faber...) istemal ho sakta hai - shart: chart misguide na kare, repaint / kachcha na lage. 19 Oct: naye kaam mein purani JAS scripts se kuch NAHI - mashhoor kitab / mashhoor tareeqa (maslan Lorentzian kNN). | 18-19 Oct |
| table | Naye Pine ki table default BAND - chart ke nishan na chhupein; hisaab peechhe chale, setting se khule. | 19 Oct |
| tweak | AAINA (aur chalti script) ka agla build = USI file mein tweak, sab purana qaim; alag chhoti nayi script NAHI ("800+ ko 200+ bana diya"). | 20 Oct |
| VPS | Demo ke liye VPS ka kharcha abhi nahi - dobara mashwara mat do. | 20 Oct |
| pine test | TALAASH / IMTIHAN qaida EA ke liye hai. Pine par kaam ho to sirf YAAD dilao: "sahi nateeja MT5 ya (data milne par) Python se". Pine pass hone tak usi ko tweak karo; Python / MT5 / data ka kaam khud mat chhero - user khud kahega. | 21 Oct |
| discussion | User concept SAMJHA raha ho to kaam / agents shuru NAHI - pehle 2-3 line mein apni samajh likh kar poochho, user ke "D" ke baad kaam (a16 par tokens zaya, user naraz). | 21 Oct |
| agents | Agent / workflow sirf jab user USI kaam ke liye khud kahe; agle kaam par khud mat chalao. User tokens par sakht: chhote jawab, kam tool qadam, ek dafa sahi. | 27 Oct |
| agent judge | User (28 Oct): "agents laazmi hon / faida ho to use kar lein" - TV ko bhejne se pehle mushkil Pine / EA ki alag agent jaanch (judge) theek; ghalat dekha gaya = time + token dono zaya. | 28 Oct |
| SMC | Apna SMC script mat banao - TV ka LuxAlgo "Smart Money Concepts" saath lagao. Tide+SMC sirf Tide (SMC default band). | 27 Oct |
- Lambe kaam (download, ghanton wale) RAAT ko; din mein jab user fresh ho = FTMO ke qareeb le jaane wala kaam (29 Oct).
- Trading kitabein / research ka imaandar istemal, koi repaint nahi, poori imaandari (29 Oct).

## C. Token / usage bachao (sab se pehli tarjeeh)

| Lafz | Hidayat | Kab |
|---|---|---|
| agent | Agent / workflow sirf jab user naam le kar maange; hafte ki limit 50%+ ho to bilkul nahi (ultracode chalu ho tab bhi). | 11 Oct |
| chat lambi | ~15 message par Claude KHUD kahe "chat lambi ho gayi - 'chat khatam' likhein". | 14 Oct |
| chat khatam | `TRADING.md` sec 9 ki list, commit + push, phir FAURAN nayi chat (`create_session`, prompt "TRADING") - schedule nahi. | 17 Oct |
| effort | Effort medium/high (xhigh nahi), chhota kaam Sonnet. | 13 Oct |
| parhna | Bari file poori NAHI - `grep`. Sawal purana lage to pehle `docs/sawal-jawab.md`. | 14 Oct |
| hidayat file | Ye file sirf zaroorat par; jo cheez bila wajah parhi jaye wo neeche "Sirf zaroorat par" list mein. | 18 Oct |

## D. MQL5 / Pine kaam ke qaide (sirf EA / Pine likhte waqt grep "MQL5" ya "Pine")

- MQL5 + Pine: har file ki pehli line(on) mein build number, panel / title par bhi wahi.
- MQL5: `StringFormat("sirf likhai")` error deta hai - kam az kam ek value. String ke liye `cond ? "" : "..."` nahi, `Pick()` helper.
- MQL5: doori se pehle `SYMBOL_DIGITS` aur `SYMBOL_TRADE_STOPS_LEVEL` (3-digit gold par 300 points = $0.30).
- MQL5: `OrderCalcProfit` jaisi warning bhi theek karo (0 maan kar ghalat faisla).
- Pine: `request.security` tuple 127 se kam; v6 mein `ta.*` if ke bahar. Repaint nahi: HTF = `[1]` + `lookahead_on`, ishare `barstate.isconfirmed`.
- Pine: purani candle par nishan (line / box / label) = `xloc.bar_time` (WAQT) - `xloc.bar_index` 1650+ candle peeche = runtime error "historical offset beyond buffer" (aaina a5, Tide+SMC s2.12).
- Cloud (Linux) mein MT5 / TradingView nahi - compile yahan NAHI; `python3 tools/pinecheck.py <file>`. User F7 / TV par compile kar ke screenshot bhejta hai.
- Windows: `tools\compile.bat <file>` (0 errors tak), `tools\backtest.bat <EA>` - ek waqt ek input badlo.
- Live par EA / script se pehle Algo Trading hara, kaam ke baad laal.

## E. Sirf zaroorat par parho (bila wajah NAHI - sirf `grep`)

| File | Kab kholo |
|---|---|
| `docs/roznamcha/HIDAYAT.md` (ye) | user ki marzi ka pata na ho |
| `docs/trading-pakki.md` (15 KB) | accounts / method / pakka sabaq chahiye - sirf grep |
| `docs/purana-haal.md` | purana haal ya koshish ki tafseel - grep tareekh / "Koshish" |
| `docs/sabaq-tafseel.md` | kisi sabaq ke poore number |
| `docs/files-tafseel.md` | file dhoondni ho - grep file ka naam |
| `docs/roznamcha/<tareekh>.md` | user "X tareekh" kahe - ijazat se, ek din |
| `docs/screenshots/`, `*.html`, `data/` | bilkul zaroorat par |
