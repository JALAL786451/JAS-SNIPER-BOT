# Andrea Cimi - Auction / Order Flow "Sniper Entry" (64vi, 17 Nov 2026)

Source: YouTube video (user ne Gemini khulasa paste kiya; link nahi diya). Fabio Valentini / Patrick Nill ka shagird.
Auzar: 5m bias + 1m entry, Volume Profile, Footprint, Big Trades bubbles (ES futures ka asli volume).

## 3 setup (Gemini khulasa)
1. Failed Auction: range ka high/low toote, wick mein bara volume absorb, qeemat aage na barhe -> ulta; TP range ki doosri taraf (VAH/VAL), SL wick ke peeche.
2. ORB + order flow: pehle 15 min ki range toote, body mein bare bubbles; TP agla liquidity / session H-L, SL breakout candle ke POC ke peeche.
3. Momentum ignition: news par ek taraf lagatar bare market orders (ES 4-5k contracts / candle) -> scalp, SL tight, jaldi BE.
Qaide: volume kam (ES < 2-3k) = breakout par bharosa nahi; bubbles wick mein = palatna, body mein = mazboot; range ho jaye to bias chhoro.

## Hamare test (qeemat wala hissa; footprint / asli volume CFD M1 mein NAHI)
| Setup | Test | Nateeja |
|---|---|---|
| 1 Failed auction | #38 `tools/fail_break_test.py` (29 Oct, kal H/L NY open, US500+USTEC) | FAIL 1390 tr -0.18R |
| 2 ORB 15m | K15 `tools/k15_orb15_index_test.py` US500+USTEC M1 2012-26 | FAIL: SL doosra kinara 2012-18 -0.12 / -0.07R, 2019-26 0.00 / +0.01R; BUY akela 2019-26 +0.04R magar 2012-18 minus (mazboot nahi) |
| 2 ORB (pehle) | gold 15m Crabel (11 Oct) -0.08R; USTEC 5m #21 FAIL | FAIL |
| 3 Momentum ignition | asli contract volume chahiye - test NAHI ho sakta | - |
Matlab: is ka edge footprint / tape parhne mein hai (aankh + asli futures volume), qeemat ke qaide mein nahi.
