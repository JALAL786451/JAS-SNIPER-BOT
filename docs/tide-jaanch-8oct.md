# JAS Tide ki jaanch (8 Oct 2026) — naye panel se pehle

User ne 8 Oct shaam kaha: "458 trades wali 1D kachhua strategy par kaam karte hain".
Files: `strategies/jas_tide_v1.pine` (strategy v1.1, Pine v5), `indicators/jas_tide_signal.pine`
(haath wala signal, Pine v5), `JasTideEA.mq5` (t4). 4 jaanch agent + tasdeeq agent (kuch tasdeeq
usage limit ki wajah se nahi chal sake - neeche "pakki/shak" likha hai).

## Strategy (`strategies/jas_tide_v1.pine`) - kharabiyan

1. **PAKKI (2 tasdeeq, high): 2R par aadhi band KABHI nahi hoti.** Entry wali candle par
   `strategy.position_size` abhi 0 hota hai, to line ~158 ka check (`abs(position_size) < initQty*0.9`)
   `p1Done := true` kar deta hai -> `P1` exit kabhi lagta hi nahi. v1.1 (commit 5a7b81c) ne reset
   upar le ja kar ye paida kiya. **Yani 458 / 40.17% / PF 1.564 / DD 20.64% (aur 2014-19 ke 45 / PF 1.205)
   us system ka naap hai jo poori position SL/trail/HTF palta par band karta hai - 2R par aadhi NAHI.**
   Check: List of trades mein koi `P1` nahi; "2R par aadha band" untick karne se nateeja bilkul wahi.
   Fix: check mein `strategy.position_size != 0` shamil; behtar: partial ko `strategy.closedtrades`
   barhne se pehchano (size gol hone se bhi jhoota "aadhi band" na bane - Seerhi s1.1 wala sabaq).
2. **SHAK (tasdeeq mein ikhtilaf): P1 sirf limit (stop nahi) + XL sirf stop.** Agar TradingView
   exit qty reserve karta hai to SL lagne par sirf aadhi band hogi. Aaj asar nahi (P1 lagta hi nahi),
   magar #1 theek karte hi aa sakta hai. **Har haal mein mehfooz fix: P1 mein bhi `stop=stopPx`**
   (Seerhi ki tarah TP1 aur TP2 dono par stop).
3. Entry ke baad PEHLI candle par koi stop nahi (exit sirf `position_size != 0` hone par lagte hain).
   Fix: entry wali candle par hi `strategy.exit` (Seerhi s1.1 jaisa). Asar chhota.
4. Defaults 20/10 hain, magar 458 wala test **10/5** par tha (aur Properties/date range likhe nahi gaye).
5. `slippage = 26` ticks = OANDA (0.001 tick) par **$0.026**, comment $0.26 kehta hai. Commission 0, spread nahi.
6. Swap nahi ginta: live cent account swap-free (theek), demo USD par BUY ~ -$0.51/oz har raat (Budh 3x)
   -> 1D ki lambi trades par ~0.04-0.25R fi BUY.
7. "458 trades" = exit ke tukre (P1 kabhi nahi laga to abhi taqreeban = entries). 2014-19 ke 45 trades
   statistically kuch sabit nahi karte. Pura run in-sample t ~2-3 (settings chun kar), zyada faida
   gold ke bull daur se.

## MT5 EA (`JasTideEA.mq5` t4) vs Pine
- t3 ke paise wale number (PF 1.23, +8,515, DD 45.8%) **1% risk + $10k se mumkin nahi** (~$507 fi haar):
  us run ka risk/deposit dobara dekhna (2 tasdeeq: pakki).
- Test ka arsa alag (Pine saara data, MT5 2015-26) + Pine tukre ginta hai (pakki).
- MT5 demo swap har long raat (pakki). 0.01 lot rounding $10k par (risk < 1%, 0.01 ki aadhi nahi hoti,
  kuch trade chhoot-ti) - shak. Exness GMT+0 daily + Sunday candle vs OANDA 17:00 NY - shak.
  MT5 iATR (SMA) vs Pine ta.atr (RMA) - shak. EA mein 2R partial chalta hai, Pine mein nahi (#1).

## Signal indicator (`indicators/jas_tide_signal.pine`)
- Us ke qaide EA jaise hain (pehli tick se poori position par stop, 2R aadhi, 5 candle trail, HTF palta)
  - magar **458 wale Pine nateeje jaise NAHI** (wahan aadhi kabhi band nahi hui). "Wohi qawaid + 458"
  ka daawa sabit nahi.
- Panel ke jaal: trade khuli ho tab bhi BUY/SELL label/alert; trail ka SL qeemat ke upar aa sakta hai
  (MT5 rad karega); daily close (2-3 AM PKT) ke ghanton baad haath ki entry par purana entry/SL/lot;
  "STOP" ginti mein faide wali trail exits bhi.
- Pine v5, v6 port halka.

## Faisle (user)
- Tide par kaam: **B** = Seerhi jaisa seekhne wala panel.
- **2** = NAYI file `indicators/jas_tide_seekh.pine`; purani `jas_tide_signal.pine` waisi hi rahe.
- **BAQI SAWAL:** panel kaun sa system dikhaye? A) jo naapa gaya (2R par aadhi NAHI), B) jo likha tha
  (2R par aadhi), C) dono, switch se, default A + strategy mein bhi wahi switch (**Claude ka mashwara C**).
