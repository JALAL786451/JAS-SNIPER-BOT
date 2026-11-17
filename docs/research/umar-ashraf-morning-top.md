# Umar Ashraf - "Morning Top" + 5 stage roadmap (64vi, 17 Nov 2026)

Source: YouTube https://www.youtube.com/watch?v=IUo5AwmsE9A (podcast). Khulasa user ne Gemini se liya (Claude ne video nahi dekhi).

## Strategy (Gemini khulasa)
- US index futures / stocks (ES, NQ, TSLA), 9:30-10:30 ET.
- Din GAP DOWN khule. Open ke baad rally aaye magar follow-through na ho (volume / buyers kamzor).
- Resistance par qeemat flat, tape slow / selling -> SHORT (institutions bech rahe).
- Chhoro: bari news (Fed / Powell) ya market 3-4 din se lagatar gir rahi ho.
- Roadmap: 1 market + 1 session, risk 0.5-1%, din mein max 3 trade, 11:00 ke baad band; 3 saal backtest; R mein hisaab;
  size 20-30% ke qadam se. Roz: pre-market plan, har 15 min note, post-market review.

## Test (K14, `tools/k14_morning_top_test.py`, US500 + USTEC M1 2012-26)
Orderflow / tape CFD data mein NAHI -> sirf qeemat wala hissa, qaide test se pehle likhe (script docstring).
| | 2012-18 | 2019-26 |
|---|---|---|
| US500 asal (gap + 3-din skip, 2R) | 241 tr -0.193R | 345 tr -0.222R |
| USTEC asal | 306 tr -0.299R | 397 tr -0.246R |
| Bina gap (placebo) US500 / USTEC | -0.099R / -0.134R | -0.117R / -0.091R |
**FAIL** - har version, dono market, dono daur minus. Gap down wale din placebo se BHI bure = gap ke baad index aksar
upar hi jata (SELL ulta). Uska asal hunar = tape parhna (aankh / tajurba), jo qeemat ke qaide mein nahi aata.
Kaam ki baatein (EA mein pehle se): chhota risk, din ki hadd, R mein hisaab, backtest -> demo -> live.
