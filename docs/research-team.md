# Research team (user 1 Nov 2026) - har talaash ka tareeqa

Kirdar: **1 Research agent** (dhoondta) -> **2 Research judge** (alag se jaanchta, rad karta) -> **3 Chief = main Claude
session** (chunta, user se "D", qaida PEHLE `docs/purana-haal.md` mein, test) -> **4 Code judges** (Pine / MQL5 / Python
code, repaint, Python se milan). Alag "chief agent" NAHI (tokens; chief ka kaam main session ka).

Kab: hafte ki limit theek ho (agents mehnge, ~100-300k token har ek). Session limit kam ho to reset ke baad.

## Sakht hadd (har agent prompt mein copy karo)

- **2019+ (IMTIHAN) ka koi nateeja NA dekho / NA chalao / NA download karo** - sirf entry < 2019 (1 Nov: research
  agent ne dekh liya tha = 5 ummeedwar aadhe dekhe hue).
- Repo READ-ONLY, sirf scratchpad mein likho. Koi commit / push nahi.
- Pehle se test hue (dobara NA): `TRADING.md` sec 8 + `docs/purana-haal.md` ("Koshish #" grep). Mukhtasar fail list:
  US index intraday paper wale (noise boundary, ORB, intraday momentum, VWAP, raat drift) - 2022 ke baad ghise;
  trend / IBS ke chhote TF (1H, 4H IBS); trend EU/Asia index, forex, oil, fasal, platinum/palladium/copper (kharcha);
  28 market taqat; jori / cointegration; akele share (drift); TOM; VIX stretch (drift); IBS mandi; Ichimoku; Williams VB;
  Holy Grail; RSI2 gold; squeeze/NR7; Fib OTE; SMC/FVG; gold ke waqt / session.
- Chal rahe (pass): trend 4H gold/chandi/US500/USTEC; IBS daily US500/USTEC; US chutti (SPX/NDX bank); US chutti
  ki khirki 7 non-US index (#67/#68).
- Asli kharcha (Exness, `JasSpreadNaap`): US500 0.40, USTEC 1.12, gold 0.24 (~0.005%), chandi 0.045%, platinum 0.25%,
  palladium 0.55%, copper 0.056%. Naya market = pehle naap.
- Shartein: TALAASH (< 2019) Exp - 2SE > 0 + saal > 50% + (long-only ho to) aam tezi (drift) ka 2 guna;
  IMTIHAN 2019+ EK dafa; FTMO jor alag test (fail na barhein).
- **Chhoti TF (<= H1):** asli spread se, 2020 ke baad chalne ka saboot (paper / doosre log), MT5 asli ticks test.

## Research agent - prompt ka dhancha

"You are a quantitative research assistant ... [sakht hadd upar se] ... Find N candidates. For each: name + sources
(author, year, venue, URL); evidence after 2015/2020 (from literature, NOT your own 2019+ backtest); why different
from the tested list; exact mechanical rules (entry, exit, stop, instruments, TF); trades/month; data needed
(TradingView / Dukascopy / MT5); main risks (cost, decay, overfit). Rank by P(pass strict OOS) x added trades."

## Research judge - prompt ka dhancha

"You are an independent RESEARCH JUDGE. Input: the research agent's report (paste). Do NOT run any 2019+ backtest.
For each candidate verify: citations exist and say what is claimed (WebFetch); post-2015 evidence real; rules
unambiguous and testable on our data; not a repeat of the tested list; costs realistic vs our measured spreads;
overfitting / data-snooping risk. Verdict per candidate: KEEP / REJECT with one-line reason, and a ranked KEEP list."

## Chief (main session)

Judge ki KEEP list -> user ko aasaan table + mashwara -> "D" -> qaida PEHLE -> test -> code judge -> nateeja darj
(sec 8 ginti, purana-haal). Pass ho to FTMO jor test, phir EA + MT5 judge, phir demo.
