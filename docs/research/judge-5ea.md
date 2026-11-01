# Judge: jas_5ea.pine p1 -> p2 (1 Nov 2026)

**Verdict: READY for TV** (compile risk kam; 1 logic fix + 1 likhai fix). pinecheck saaf.

## Fixes (p2)
1. L234-257 `f_core`: S2 (din ke close) ab B1 entry (agli 4H open) se PEHLE dekhi jati hai; B1 khule to S2 usi open
   par band (judge #73 fix 2). p1 isay "ruki" ginta tha. Python port: US500 2018-12-26 + 9 trade 2019+ (same-block cut, ~0R).
2. L29, L660: SELL note "TALAASH 2012-18" -> "<2019" (XAU/XAG 2003 se, index 2012 se).
3. Build p2: L2, L39, L41 (+ L19 note, L144 comment).

## Logic (f_core ka Python port, Dukascopy 4H blocks, Python truth se)
B1: XAU 436/436, XAG 383/383, US500 287/287, USTEC 299/299 (entry + exit + qeemat). S1 (SMA200 gate + tarjeeh):
113/136/32/40 = 100%. B2: 333/333, 337/337. S2 TALAASH = judge-73 ka theek kiya hua (USTEC 2012-12-27, US500 2018-12-26).
B3 = k2 engine line ba line (sirf muddat filter + wapasi badli). Kharcha, swap, R, PnL %, DD %, muddat: sahi.

## Repaint: saaf
Wapas haal sirf [1] + is candle ka open / time / time_tradingday -> 1m..4H par lookahead_on safe; 4H se bara chart
lookahead_off; nishan barstate.isconfirmed. Ginti: tuple 12+12+24+24+42 = 114/127, request 11, lakeer/label <= 10 (hadd 20),
plotshape 10, table 9 x 26 (aakhri row 25).

## Baqi khatra (compile par kam)
- L94 `lookahead = LA` (simple ternary): docs ke mutabiq simple chalta hai.
- L152 `var array<float>` request.security ke andar (reference scripts mein sirf UDT tha).
- L50 timestamp 1900 (1970 se pehle); L89 timenow request ke andar (sirf 10 SAAL).
Error aaye to line number + screenshot bhejein.
- Data: OANDA din = 17:00 NY maana (time_tradingday). SL 4H candle par (Python H1): gap wali trade mein thora farq.
  L663 jaisi lambi merged line table ko chaura kar sakti hai. 1m chart = chhoti history.
