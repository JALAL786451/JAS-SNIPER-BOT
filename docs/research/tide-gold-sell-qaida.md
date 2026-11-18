# Koshish #106s - Tide (Kachhua 1D) gold par SELL ka lambi history par alag naap (user 18 Nov "SELL lamba data test")

Qaida test se PEHLE likha aur commit kiya gaya. Nateeja dekhne ke baad badalna MANA hai.

## Sawal
Tide 1 BUY aur SELL dono deta hai (`indicators/jas_tide_radar.pine` line 166-169). Gold par BUY pakka hai.
Kya gold ki poori history par SELL bhi sabit hai? Agar haan, to gold script SELL bhi trade karegi.

## Qaide (Tide 1 radar jaise, koi tabdeeli nahi)
- Rukh: D1 EMA50 > EMA200 = sirf BUY, EMA50 < EMA200 = sirf SELL.
- Entry (band candle par): close pichhli 10 candle ke high se upar = BUY. Close pichhli 10 candle ke low se neeche = SELL.
- Bazaar susat na ho: ATR14 >= 0.25% qeemat.
- SL 2 x ATR14. Har din SL pichhli 5 candle ke low (SELL: high) tak sarakta hai.
- Band hone ki shartein:
  - Candle SL chhuye (gap ho to open par).
  - Ya D1 rukh palte (close par).
  - Ya close sarakte SL ke paar ho (close par).
- 2R par aadhi NAHI. Kharcha 0.005% har taraf. Swap nahi gina (FTMO / live cent swap-free).
- Data: TradingView OANDA:XAUUSD 1D, poori history. Script: `indicators/jas_tide_sell_naap.pine` s1. Trade nahi karti, sirf naap.

## Daur
1980 se pehle | 1980-2001 (gold ka 21 saal girta daur) | 2002-2018 | 2019+ (entry ke saal se).

## SELL PASS - teeno shartein lazmi
1. SELL kul trade >= 60.
2. SELL kul Exp - 2SE > 0.
3. 1980-2001 ke BAHAR ki SELL: Exp > 0 aur n >= 30. Is se faida sirf ek girte daur ka drift na ho.

- **PASS** = gold script mein SELL bhi trade (lot / SL).
- **FAIL** = SELL sirf ittila (Rehnuma r2 jaisa), trade sirf BUY.
- Koi setting nahi ghumai jayegi. Ek hi run, jo nikle wahi faisla.

## Imaandari note
Ye qaida likhne se PEHLE 2003-26 ka Dukascopy naap dekh liya gaya tha (Python, `tools/tide_ea_check.py` `pine_engine`, kharcha 0.005%):

| Gold 1D | 2003-2018 | 2019-2026 |
|---|---|---|
| BUY | 88 tr, +0.285R (SE 0.135), kul +25.1R | 54 tr, +0.394R (SE 0.231), kul +21.3R |
| SELL | 34 tr, +0.202R (SE 0.203), kul +6.9R | 8 tr, -0.218R (SE 0.201), kul -1.7R |

- Nayi maloomat sirf 2002 se pehle ka hissa degi (1970-2001).
- TV ke 2002-18 / 2019+ number upar wale ke qareeb aane chahiye (data source alag: OANDA vs Dukascopy). Bohot farq ho to pehle engine jaancho, faisla baad mein.

## NATEEJA
(user ke TV SS ke baad yahan)
