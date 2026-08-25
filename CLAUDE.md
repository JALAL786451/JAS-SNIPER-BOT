# JAS-SNIPER-BOT — kaam karne ka tareeqa

Ye file har session ke shuru mein khud-ba-khud parhi jati hai.
Jalal ko ye baatein baar baar na kehni parein, is liye yahan likh di gayi hain.

## Zaban

Roman Urdu mein jawab dein. Technical terms (breakeven, lots, indicator,
pull request) angrezi mein hi rehne dein — tarjuma na karein.

## Code hamesha one-click copy page ke tor per dein

**Ye sab se ahem qaida hai.** Jab bhi koi script, indicator, EA ya code
diya jaye — chahe naya ho ya update — usay **Artifact page** ki soorat mein
publish karein jis mein:

- ek bara **"Copy all code"** button ho jo poori file clipboard per le jaye
- copy hone per saaf confirmation dikhe ("Copied")
- code ek scroll hone wale panel mein ho, page khud side mein scroll na ho
- file ka naam upar likha ho (jaise `indicators/smc_coach_pro_v2.pine`)
- lines aur size ka andaza ho

Terminal mein code ka dher na daalein aur sirf file path bata kar na chhorein.
Jalal ise TradingView ya MetaEditor mein paste karta hai — copy button laazmi hai.

**Copy karne ke liye hamesha Sniper File Vault istemal karein** — usi mein taza
code hota hai:
https://claude.ai/code/artifact/ab86eceb-0d6e-4577-8af7-112f521012b0

Ye do purane page isi tarz per bane hain, magar in per code purana ho sakta hai.
Inhein tab update karein jab saari pending tabdeeliyan aik saath lagayi jayen:
- SMC Coach Pro v2 — https://claude.ai/code/artifact/5f57e7a1-7bd1-4a2d-a4b8-1bf2fa008612
- XAUUSD Scalper Scripts — https://claude.ai/code/artifact/fd5e297c-37bf-4b13-b3ee-48cd0c6470ff

Purana artifact update karte waqt **wahi URL** istemal karein (`url` parameter),
naya link na banayen.

## Tabdeeliyan ek saath karein, tukron mein nahi

Jalal chhoti chhoti tabdeeliyan alag alag nahi karwata. Farmaishein
`CHANGE-REQUESTS.md` mein jama karte jayen aur **sirf tab lagayen jab woh
saaf kahe ke ab kar do**. Bin kahe koi file na badlein.

## Account ki tafseel

- Broker account **cent (USC)** hai — symbol `XAUUSDc`
- MT5 mein jo number dikhta hai uska **asal dollar 1/100** hai
  (49,666.86 USC = $496.67)
- Position panel **hedging** account maanta hai (buy aur sell aik saath)

## Files

| File | Kya hai |
|---|---|
| `indicators/smc_coach_pro_v2.pine` | TradingView SMC indicator (Pine v5) |
| `mt5/jas_sniper_ea.mq5` | MT5 bot (Expert Advisor) — ALERT / SEMI / AUTO |
| `mt5/mt5_position_panel.mq5` | MT5 live position + breakeven panel |
| `sniper_backtest.pine` | Purana backtest script |
| `CHANGE-REQUESTS.md` | Farmaishein — jama ho rahi hain, abhi lagai nahi gayin |

## Guides

- MT5 Demo Lab — https://claude.ai/code/artifact/923cbc5b-3f94-4ad1-8900-f6b8bff6321e
- Sniper File Vault (dono files, one-click copy — TAZA) — https://claude.ai/code/artifact/ab86eceb-0d6e-4577-8af7-112f521012b0
- SL aur TP kahan lagayen — https://claude.ai/code/artifact/7742beb0-b6af-4988-941e-e173c7d6eedd
