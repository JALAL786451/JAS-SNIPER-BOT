# JAS Tide + SMC - naqsha (10 Oct 2026)

Halat: **manzoor ("D", 10 Oct raat) - BAN GAYA:** `indicators/jas_tide_smc.pine` s1 + user ki farmaish par Tester `strategies/jas_tide_smc_test.pine` s1 (faisla 1D, amal chart TF par - 1D vs 15m ka moqabla). Compile baqi. Faisle Claude ne kiye (MERI-KAHANI: faisle Claude kare).

User ka sawal (10 Oct raat): "Tide wali script gold par overall kaam karti hai (test kiya).
Tide ke hisaab se script bana dein, BTC chart par idea leta rahoon - MA21/63, DZ/SZ,
BOS/CHOCH aur LGB/FVG sab chart par, Tide wali script ke hisaab se."

## Buniyadi faisla

- **Ishara sirf Tide ka.** Naapa hua faida sirf Tide ke paas hai (BTC: Radar EA Tester 2019 se
  79 trades +44.2R bina swap; radar r1.1 puri history 118 trades +0.76R fi trade).
- **SMC hisse sirf dikhawa** (samajhne ke liye). Koi SMC filter Tide par NAHI - wo naya,
  bina naapa system ban jata (10 Oct faisla: "dono ko mila kar filter NAHI").
- "Tide ke hisaab se" = SMC ke nishan Tide ke rukh ke mutabiq rang: Tide ki taraf wale
  (BUY chalu ho to demand zone, bullish FVG, upar BOS) **gehre**, ulti taraf wale **halke/sleti**.

## Naqsha

| Hissa | Kya | Kis TF par |
|---|---|---|
| Tide (ishara) | Wohi qaide jo naape gaye: 10 din ka toot (band candle), D1 EMA50/200 rukh, ATR >= 0.25%, shuru SL 2 ATR, SL 5 din ke low/high se sirf aage, D1 rukh palte to bahar. BAND (2R par aadhi nahi). Repaint nahi ([1] + lookahead_on) | **Hamesha 1D** (`request.security`), chart koi bhi TF |
| Tide lakeerein | 10 din ki naali (upar/neeche toot ka level), khuli trade ho to entry + sarakta SL | chart par |
| MA21 / MA63 | EMA, chart TF ki | chart TF |
| BOS / CHOCH | Swing (pivot) toot ke chhote label | chart TF |
| DZ / SZ | Aakhri 3 demand + 3 supply zone (swing se), toot jaye to mit jaye | chart TF |
| FVG | Aakhri 3 khule gap (bhar jaye to mit jaye) | chart TF |
| LGB | Liquidity sweep: swing ke paar wick, close wapas andar - chhota nishan | chart TF |
| Table (chhoti) | Tide haal (BUY chalu / SELL chalu / intezar), entry, SL, abhi R, agla toot upar/neeche, D1 rukh, Tide ka purana naap is symbol par (trades, Exp R) | kone mein |

- Har SMC hissa settings mein band ho sakta hai; ginti kam (3-3) taake chart saaf rahe.
- Mashwara chart: **BTC 4H** (Tide faisla 1D se; 4H par SMC nishan parhne layak).
- Nayi file: `indicators/jas_tide_smc.pine` (Pine v6). Purani Tide / SMC files ko haath nahi.
- Jaanch: `tools/pinecheck.py` + Tide engine ka Python milaap (`tools/tide_ea_check.py` wala
  engine) taake 1D par trades radar jaise aayen. Cloud mein Pine compile nahi - user compile kare.
- Peshangoi nahi. Tide 60% haarta hai; kamai chand bari jeet se.
