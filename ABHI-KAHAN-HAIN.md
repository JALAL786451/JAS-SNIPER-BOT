# ABHI KAHAN HAIN — nayi chat ke liye

**Pehchan ka code: `JAS-DESK-V3-0110`**

Agar nayi chat mein ye code diya jaye, to Claude yeh file parhe aur wahin se kaam shuru kare.

## Aakhri kaam (1 October 2026)

- **`JasDeskView.mq5` build v3** — sirf parhne wala panel. Trade NAHI karta.
  - Close-All dialog wali ginti + dono taraf ke lots, lot SIZE ke hisaab se ginti
  - Ausat price, barabar ka price, NET kis taraf
  - Chart par lakeerein (ausat buy/sell, barabar, buri lot, har lot)
  - Nikalne ka plan: PLAN A (sab se buri lot ko faide wali se dhaanpo), PLAN B (kul faide se kitni buri lots nikal sakti hain)
  - **Abhi tak compile nahi hua.** User demo `XAUUSDm` par check karega aur screenshot bhejega.
- **`indicators/analogue_matcher_v2.pine` build a3** — "Aam taur par" aur "FARK" rows. Test ho raha tha.

## User ke faisle (in par dobara sawal na poochein)

- Cut ka maqsad: **buri lot ko faide wali se dhaanp kar nikalna**
- Agli lot kahan kholni hai: **abhi nahi**, sirf nikalne ka hisaab
- Demo account standard hai (`XAUUSDm`, USD). Live cent hai (`XAUUSDc`, USC)
- Swap nahi lagta (Islamic account)

## Baqi kaam

1. JasDeskView v3 demo par compile + screenshot
2. User ki live hedged kitab — koi faisla nahi hua
3. L23 cool-off (Close All ke baad thehrao) — user ne jawab nahi diya
4. `JasTideEA.mq5` t2 kabhi compile nahi hua

## Kaam ka tareeqa (user ne kaha)

- **Pehle poochho, phir file banao** — file ke baad sawal nahi
- SBS = ek qadam, user "D" likhe, phir agla
- Roman Urdu, chhota aur saaf
- Branch: `claude/gifted-faraday-zs7wcz`
