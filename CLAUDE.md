# JAS-SNIPER-BOT

MetaTrader 5 EAs aur TradingView Pine scripts (gold, index, commodity) - user Jalal ke liye.

**Har nayi chat (user KHUD kholta aur "TRADING" likhta hai):** ye branch GitHub ki default hai - fetch/checkout NAHI.
Hook MT5 table + `KAAM.md` + `TRADING.md` sec 5 KHUD dikhata hai = KAAFI: pehle jawab mein table + agla kaam seedha, user ko 0 se
batana na pare. `KAHANI.txt` / poori `TRADING.md` NA parho (user 16 Nov, token) - purani baat sirf `grep`. User ki har nayi baat USI waqt `KAAM.md` mein.
Roman Urdu, chhota aur saaf, "aap". Hamesha backtest -> demo -> live.
**Token bachao (reply se PEHLE):** sawal purana lage to pehle `grep -i <lafz> docs/sawal-jawab.md` - mile to wahi
jawab, aur kuch nahi parho. Na mile to `docs/roznamcha/FEHRIST.txt` se tareekh; pata na ho to kaho aur ijazat lo (ek din).

**KHUD NAZAR (user 17 Nov, sab se ahem):** har report / SS / test par bina pooche "Khud dekhi baatein" do: khatra, EA ka aapas mein takrao, backtest se farq, ajeeb cheez - kyun + kya karein. User ka miss = saal ka nuqsan.

## Usage bachao

- Ye file har message ke saath load hoti hai - **chhoti rakho** (~2 KB). Haal / nateeje / file list yahan NAHI.
- Haal + agla kaam `TRADING.md`; pakki baatein `docs/trading-pakki.md`.
- **Files ki list** (har file ki ek line) + lambi kahani: `docs/files-tafseel.md` - sirf `grep` se.
  Purana haal `docs/purana-haal.md`, sabaq ke number `docs/sabaq-tafseel.md`.
- Nayi file bane to uski ek line `docs/files-tafseel.md` ki "chhoti list" mein (yahan nahi).
- ~15 message ho jayein to Claude KHUD kahe: "chat lambi ho gayi - 'chat khatam' likhein, nayi chat sasti".
- **Chat khatam (HALKI, user 16 Nov "haan"):** `KAAM.md` (khule kaam taza, <=4 KB) + `TRADING.md` sec 5 (2-5 line, agla kaam) +
  naya jawab ho to `docs/sawal-jawab.md` EK line + `python3 tools/roznamcha.py` + EK commit + push (ye branch = default). Bas.
  `KAHANI.txt` sirf jab user kahe "poora hisaab" (Sec 3 mein 2-5 line + Sec 4; dobara BANANA MANA).
  **Nayi chat KHUD NAHI kholni** (`create_session` / schedule NAHI) - user khud kholta hai; usse sirf kaho: nayi chat mein "TRADING" likhein.
- Agent / workflow sirf jab user naam le kar maange; hafte ki limit 50%+ ho to bilkul nahi.
- **BANK yaad dilao (user 1 Nov):** `docs/bank.md` - FTMO pass, real account, trade barhana ya naya jor ki baat par user ko KHUD batao.
- **FTMO offer yaad dilao (user 1 Nov):** jab bhi FTMO khareedne / challenge / fees ki baat ho, aur har November (Black Friday) / December (New Year) wali chat mein, ftmo.com par chalu offer KHUD check karke batao. Paise sirf ftmo.com checkout par; code se qeemat waqai kam ho tab.
- **Nayi maloomat KHUD (user 7 Nov):** har chat mein 1-3 line nayi kaam ki cheez (tool, MCP, data, Claude/FTMO nayi baat) khud batao; detail sirf poochhne par. Bata chuke = `docs/nayi-maloomat.md`.
- User ki marzi / hidayat ka pata na ho (yahan + `TRADING.md` mein nahi) -> `grep -i <lafz> docs/roznamcha/HIDAYAT.md`. Poori file nahi.

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

EA / Pine likhne se PEHLE: `grep -A12 "^## D" docs/roznamcha/HIDAYAT.md` (build number, StringFormat/Pick,
points vs digits, repaint, cloud compile nahi -> `tools/pinecheck.py`, user F7/TV screenshot).
