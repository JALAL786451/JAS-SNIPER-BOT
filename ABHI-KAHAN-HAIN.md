# ABHI KAHAN HAIN — nayi chat ke liye

**Pehchan ka code: `JAS-DESK-V3-0110`**

Agar nayi chat mein ye code diya jaye, to Claude yeh file parhe aur wahin se kaam shuru kare.

## Aakhri kaam (1 October 2026)

- **`JasDeskView.mq5` build v4.2** — sirf parhne wala panel. Trade NAHI karta.
  - v4: BARI LOT KI JORI (lot barabar, kitab jami rahe) + har plan ke saath "NET baad mein" aur KHATRA line
  - v3.1: timeframe/setting badalne par lakeerein gayab ho jati thin (`g_sig` OnDeinit mein reset nahi hota tha) - theek kiya
  - Abhi baqi (chhota): lakeer ke tooltip ka P/L sirf lot khulne/band hone par naya hota hai
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

1. JasDeskView v4.2 compile + LIVE `XAUUSDc` chart par (sirf parhta hai) - panel par "v4.2" likha aaye (v4/v4.1 ke 2 errors: StringFormat bina value ke - PLAN A/B ki heading. v4.2 mein theek)
2. User ki live hedged kitab (1 Oct): 112 lots, 102 BUY / 10 SELL, Close All -2,771 USC, equity 43,102, kitab JAMI (NET ~0, har taraf ~2.0 lot - screenshots se andaza). Ek SELL **1.50** lot ki hai - user ko upar jane par isi ka dar hai. User ka faisla: pehle v4 laga kar asli number dekhna, phir 1.50 SELL ko us ke NEECHE wali BUY (1.50 lot barabar) se dhaanp kar nikalna. Jumma 2 Oct NFP 5:30 PM PKT - jami kitab ko news kuch nahi karti, khuli ko kar sakti hai
3. L23 cool-off (Close All ke baad thehrao) — user ne jawab nahi diya
4. `JasTideEA.mq5` t2 kabhi compile nahi hua

## Usage (1 October)

- Gold hourly routine ab **din mein 1 dafa** (Peer-Jumma 6:05 PM PKT), message sirf ahem din par. Cowork usage isi se tha.
- "Usage credits" switch user ke account par OFF hai - extra paisa nahi katta. $100 wala message muft cloud credit tha.

## Kaam ka tareeqa (user ne kaha)

- **Pehle poochho, phir file banao** — file ke baad sawal nahi
- SBS = ek qadam, user "D" likhe, phir agla
- Roman Urdu, chhota aur saaf
- Branch: `claude/gifted-faraday-zs7wcz`
