# Swap se market chunao + FTMO / Exness swap-free (4 Nov 2026)

Sirf research, koi backtest nahi, 2019+ data nahi chhua.
**(V)** = official page par khud parha (URL neeche). **(A)** = andaza / kitab ki baat, yahan tasdeeq nahi.

## 0. Chhota jawab
- Aap ka idea = **carry factor** (zero-swap wali taraf = futures roll ka faida wali taraf). Ye pehle se C1d ki "swap shart" hai.
- CFD par broker faide wali taraf ko **0** deta hai, + nahi. Is liye ye qaida **sirf kharcha hatata hai, edge nahi deta**.
- Sakht qaida gold / index par aksar **SHORT** chunta hai, jab ke in ka asli faida LONG mein hai. Is liye: swap ko **kharche** ki tarah hisaab mein daalo, rukh (direction) chunne ke liye nahi.
- FTMO par swap-free / Islamic account ka **koi official page nahi mila**. FTMO swap leta hai (V).
- Exness: Pakistan Islamic list mein hai. **Poore PA ke sab instruments par 0 swap** (V).

## 1. Swap kahan se aata hai
| Cheez | Swap ka formula (asaan) | Aam taur par kaun deta |
|---|---|---|
| Tel, gas, copper | futures roll (F1 vs F2) + broker markup | contango: long deta; backwardation: short deta |
| Gold, silver | USD sood - lease rate + markup | long hamesha deta; short ~0 ya chhota |
| Index (US500, UK100...) | long: -(sood + markup) + dividend; short: +(sood - markup) - dividend | long deta; short sood ke hisaab se |
| DE30 | total-return index (dividend andar) -> sirf sood +- markup | long deta; short chhota |
| BTC | crypto funding + markup | live spec: long -1763.7 pt, short 0 (repo, `trading-pakki.md`) |

Exness index dividend **alag** cash entry hai: buy ko milta, sell se kat-ta, 22:00 UTC (V). Triple swap: metal Budh, index Jumma, energy mein triple nahi (V).

## 2. Kya swap ka nishan (sign) badalta hai? (1990-2018)
| Market | Purana haal | Kitni dafa palta | Pakka? |
|---|---|---|---|
| WTI / Brent | 1984-92 mein >= 70% waqt backwardation. Contango: 1998-99, 2005-07, 2009-10, 2015-17. Backwardation: 2000-04 zyada, 2018 | regime mahino se saalon tak; 1990-2018 mein ~6-8 bari dafa | 70% wali baat EDHEC (Till) ne L&R 1995 se li (V nahi, secondary); baqi (A) |
| Natural gas | zyada tar contango, sardi ke mahine mehnge (mausami) | har saal mausami jhool; long aam taur par deta | (A) |
| Copper | 1982-2004 roll **+2.9%/saal** (zyada backwardation); 1998-2003 aur 2009-18 aksar halka contango | tight / surplus ke saath 1-3 saal mein | roll number Erb-Harvey PDF (V) |
| Gold / silver | 1982-2004 roll **-4.9% / -5.6% saal** = long ko nuqsan, lagbhag hamesha contango | bohat kam; sood ~0 (2009-15) par long swap chhota | Erb-Harvey PDF (V) |
| Index | sood vs dividend; 2009-15 sood ~0 -> short bhi deta tha; markup ki wajah se aksar dono taraf deti | sood ke saath (saalon mein) | (A) |

**Nateeja:** gold/silver ka nishan pakka hai. Tel, gas, copper ka nishan **palat-ta hai** (mahino-saalon mein). Is liye "aaj ka screenshot" 1990-2018 ke test ka qaida nahi ban sakta. Har mahine dobara dekhna hoga.

## 3. Kya ye carry factor hai? Test kaise ho?
- Haan. Koijen et al 2018 "Carry", Gorton-Rouwenhorst, Erb-Harvey: backwardation wali commodity aage behtar. Erb-Harvey (1982-2004): musbat roll wali commodities +4.2%/saal, manfi wali -4.6%. Is 9% farq mein **7.5% roll** se aaya, sirf **1.4% qeemat (spot)** se (V).
- CFD par faide wali taraf ka swap 0 hai = roll ka 7.5% nahi milta. Bachta sirf ~1.4% spot wala hissa (kharche se pehle). Yahi wajah thi C1d BANK ki.
- **Purani swap history ke baghair proxy:** carry = (F1 - F2) / F2 mahine ke aakhir. TradingView: `NYMEX:CL1!/CL2!`, `ICEEUR:BRN1!/BRN2!`, `NYMEX:NG1!/NG2!` (gas mausami hai, behtar F1 vs 12 mahine baad wala), `COMEX:HG1!/HG2!`, `COMEX:GC1!/GC2!`, `CME_MINI:ES1!/ES2!`. Back-adjust **band**, F1 aur F2 ek hi din ke. Doosra proxy: 12 mahine ka spot momentum (backwardation ke saath chalta hai) (A).
- TALAASH sirf **2018 tak** ka data. P&L CFD jaisa: sirf spot qeemat ka badlao (roll nahi), zero-swap wali taraf.

## 4. Imandar faisla
- Swap chunao strategy ko **mazboot nahi karta**, sirf **kharcha hatata** hai. Kamzor system (kharche se pehle 0) is se PASS nahi banta: #74 (-0.041R kharche se pehle), #88-95.
- Aap ki baat **kuch sahi** hai: #73 SELL mein swap ne faida kha liya; #96 mein tel swap 5% maana tha, asal 19-37% (SELL par).
- Kharcha R mein (har trade): **swap %/saal x din/365 x (qeemat / SL ka faasla)**.
  Misaal: gold long, swap 6%/saal (andaza), 14 din, SL 3% door -> 0.06 x 14/365 x 33 = **~0.08R**. Edge 0.2-0.3R ho to ye bada hissa hai.

## 5. Hamare markets: aap ke qaide par kaun si taraf "jaiz" (swap wale account par, aam haal)
| Market | LONG | SHORT | Note |
|---|---|---|---|
| XAU, XAG | nahi (long deta) | haan | asli faida long trend (t5); SELL test FAIL (#73) |
| US500, USTEC | nahi (sood + markup) | aksar haan | equity premium long mein hai |
| DE30, UK100, FR40, STOXX50, AUS200, HK50 | nahi | aksar haan / chhota | JP225: yen sood kam -> dono taraf markup |
| USOIL, UKOIL (abhi) | haan (0) | nahi (-19% / -37%) | backwardation tak; palat sakta hai |
| XNG (abhi) | nahi (-100%+) | haan (0) | contango |
| XCU (abhi) | nahi (~-16%) | haan (0) | contango |
| BTC | nahi (spec -1763.7) | haan (0) | |

Matlab sakht qaida hamare sab se achhe LONG systems (t5, IBS, k2) ko rok deta. Is liye: **swap = kharcha**, rukh = strategy ka.

## 6. FTMO swap-free / Islamic? (Sawal 2a)
| Baat | Haal | Source |
|---|---|---|
| Swap-free / Islamic ka FAQ | **Nahi mila.** FTMO ke 129 English FAQ (sitemap, 4 Nov 2026) mein swap-free / Islamic / halal ka koi page nahi | (V) ftmo.com/faq-sitemap.xml |
| Swing account | leverage 1:30, news + weekend pabandi nahi, sirf 2-Step. **Swap-free ka zikr nahi** (page 6 Oct 2026) | (V) [Swing FAQ](https://ftmo.com/en/faq/what-is-the-swing-account-type-and-how-does-it-work/) |
| Swap lagta hai? | **Haan.** "Overnight rollover swaps are subject to regular changes ... your responsibility to check these swap[s] ... specification" (2 Nov 2026) | (V) [Trading update](https://ftmo.com/en/blog/trading-updates/trading-update-2-nov-2026/) |
| "Swing = swap-free" | TradersUnion kehta hai haan, Propvator kehta hai nahi | **(A) - official tasdeeq nahi** |
| Pakistan, fees, holding hadd | koi Islamic option nahi dikha, to ye sawal lagu nahi | - |

Pakka karne ke liye: support@ftmo.com se poochein (email FTMO FAQ page par hai).

## 7. Exness swap-free (Sawal 2b)
| Baat | Haal | Source |
|---|---|---|
| Pakistan | Islamic list mein hai, status **khud-ba-khud** | (V) [Islamic countries](https://get.exness.help/hc/en-us/articles/18055079599132-Swap-free-status-Islamic-countries) (22 Sep 2026) |
| Instruments | "All trading instruments ... zero or no swap" = gold, tel, gas, copper, index, BTC sab | (V) wahi page |
| Kitne account | poore Personal Area (PA) ke **sab account types** | (V) wahi page |
| Fee / din ki hadd | koi admin fee ya din ki hadd nahi likhi | (V) wahi page |
| Ghair-Islamic swap-free | sirf list: forex, XAU, XAG, XPT, USOIL, UKOIL, sab crypto, sab index; baqi metal/energy (gas, copper) par swap. Algorithm cancel kar sakta hai. Islamic <-> ghair-Islamic badal nahi sakte | (V) [Swap-free status](https://get.exness.help/hc/en-us/articles/4402341895570-Swap-free-status) |
| Index dividend | alag entry; Islamic par bhi lagta hai ya nahi, likha nahi | (V) [Dividends](https://get.exness.help/hc/en-us/articles/6546089955996) - Islamic par **pakka nahi** |
| Demo | official baat nahi mili. Aap ke demo SS mein swap dikh raha = demo par Islamic nahi lagta (aap ka mushahida) | (A) |
| "Extended swap-free" | ye lafz ab ke pages mein nahi; Pakistan ko poora Islamic milta hai | (V) |

**Bari baat:** aap ke live Exness PA par swap **dono taraf 0** hai. Wahan aap ka qaida bekar hai, har rukh muft. Magar 0 ka matlab roll ka faida bhi nahi, sirf spot qeemat. Cent account par tel/gas/index hain ya nahi, MT5 mein dekhein (56 symbols, pakka nahi).

## 8. FTMO plan #68 par asar (Sawal 2c)
FTMO swap-free nahi deta (jitna pages se pata chala), to:
| Hissa | Kitna der | Swap ka asar |
|---|---|---|
| t5 trend 4H (XAU XAG US500 USTEC, sirf BUY) | din se hafte | **sab se zyada.** Long swap har din, gold/silver Budh 3x, index Jumma 3x. ~0.05-0.1R / trade (andaza) |
| i6 IBS daily | 1-3 din | chhota |
| k2 chutti ki khirki (7 index) | kuch din | chhota; DE30 par dividend nahi |
| Swing account | weekend rakh sakte | swap **phir bhi lagta** hai |

## 9. Sab se faida-mand agla qadam
FTMO free trial MT5 mein **Specification ke screenshot**: XAUUSD, XAGUSD, US500.cash, US100.cash + 7 k2 index (swap long / short + triple din). Phir #68 ke hisaab mein asal swap daalein (test sirf CHUNAO, IMTIHAN dobara nahi). Saath mein support@ftmo.com se ek sawal: "Pakistan ke liye swap-free account hai?"

Sources: [Erb-Harvey 2006 PDF](https://people.duke.edu/~charvey/Research/Working_Papers/W77_The_tactical_and.pdf) · [EDHEC Till (tel curve)](https://risk.edhec.edu/publications/importance-structural-shape-crude-oil) · [Exness About swap](https://get.exness.help/hc/en-us/articles/360014709151-About-swap)
