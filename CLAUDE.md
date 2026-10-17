# JAS-SNIPER-BOT

MetaTrader 5 EAs aur TradingView Pine scripts (gold, index, commodity) - user Jalal ke liye.

**Har nayi chat (user likhe "TRADING"):** ye branch ab GitHub ki default hai - fetch/checkout NAHI,
seedha sirf `TRADING.md` parho (ek qadam), sec 5 = agla kaam. Kaam isi branch par commit + push (user, qaide, pichli chat, agla kaam) - baqi `grep` se.
Roman Urdu, chhota aur saaf, "aap". Hamesha backtest -> demo -> live.
**Token bachao (reply se PEHLE):** sawal purana lage to pehle `grep -i <lafz> docs/sawal-jawab.md` - mile to wahi
jawab, aur kuch nahi parho. Na mile to `docs/roznamcha/FEHRIST.txt` se tareekh; pata na ho to kaho aur ijazat lo (ek din).

## Usage bachao

- Ye file har message ke saath load hoti hai - **chhoti rakho** (~2 KB). Haal / nateeje / file list yahan NAHI.
- Haal + agla kaam `TRADING.md`; pakki baatein `docs/trading-pakki.md`.
- **Files ki list** (har file ki ek line) + lambi kahani: `docs/files-tafseel.md` - sirf `grep` se.
  Purana haal `docs/purana-haal.md`, sabaq ke number `docs/sabaq-tafseel.md`.
- Nayi file bane to uski ek line `docs/files-tafseel.md` ki "chhoti list" mein (yahan nahi).
- **Chat khatam** (user kahe, ya ~15-20 message): `TRADING.md` sec 9 ki list - sec 5 naya (<=8 KB), naye jawab
  `docs/sawal-jawab.md`, `python3 tools/roznamcha.py`, commit + push (default branch bhi). Har chat yahi kare.
- Agent / workflow sirf jab user naam le kar maange; hafte ki limit 50%+ ho to bilkul nahi.

## Hard rules for these EAs

Never add grid, martingale, hedging, or position averaging to any EA here
unless the user asks for it explicitly and by name in the current session.
Every EA holds at most one position per market at a time.

This rule is about the EAs in this repo, not a judgement on the user's own
Fishing Lots method (`METHOD.md`, a laddered, hedged basket by design). Describe
his method faithfully; do not graft it onto these EAs unasked.

Never widen a risk limit (risk percent, daily loss cap, max trades, drawdown
cap) on your own initiative. Those defaults are deliberate.

## MQL5 / Pine kaam ke qaide

- Har file ki pehli line par build number, panel par bhi wahi.
- `StringFormat("sirf likhai")` error deta hai - kam az kam ek value. String ke liye `cond ? "" : "..."` nahi, `Pick()` helper.
- Points vs digits: doori se pehle `SYMBOL_DIGITS` aur `SYMBOL_TRADE_STOPS_LEVEL` (3-digit gold par 300 points = $0.30).
- Pine: `request.security` tuple 127 se kam; v6 mein `ta.*` if ke bahar.
- Cloud (Linux) mein MT5 / TradingView nahi - compile yahan NAHI; `python3 tools/pinecheck.py <file>`
  se jaancho, user F7 / TradingView par compile kar ke screenshot bhejta hai. Windows: `tools\compile.bat <file>` (0 errors tak), `tools\backtest.bat <EA>` - ek waqt ek input badlo.
