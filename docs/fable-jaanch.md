# FABLE 5.2 se AZAD JAANCH (user 17 Nov, 66vi) - "4 EA, instruments aur qaidon ka doosra imtihan, taake bharosa mazboot ho"

**Chalane ka tareeqa (user):** nayi chat -> model **Fable 5.2** chuno -> "TRADING" -> phir likho: **"docs/fable-jaanch.md wala kaam karo"**.
Fable ke paas 11 Dec tak. Ek hi chat mein poora; agent / workflow NAHI (limit). Roman Urdu jawab.

## Fable ke liye hidayat (AZAD rehna zaroori)
1. **Pehle khud jaancho, phir hamare nateeje parho.** `docs/khud-nazar.md` sec 5-6, `docs/k9-jor-tajziya.md` ko apna kaam KHATAM hone tak NA kholo
   (warna jaanch azad nahi rahti). Purane PASS ke number sirf `docs/trading-pakki.md` 1-NAYA qaida se lo.
2. **Code ki jaanch (bug dhoondo, tabdeeli NAHI):** 4 EA jo FTMO demo 474832446 par chal rahe:
   t5 = `JasTrendEA.mq5` (4H Supertrend, sirf BUY, XAU/XAG/US500/USTEC, 0.75%), i6 = `JasIbsEA.mq5` (IBS, US500+USTEC, 1%),
   k2 = `JasKhirkiEA.mq5` (non-US index khirki, 0.15%), e2 = Kachhua (BUY+SELL 12 market, 0.25%).
   Python model: `tools/ftmo_test.py`, `ftmo_4h.py`, `ftmo68.py`, `ftmo99.py`, `ftmo53_asli.py` (FTMO sim), `jor105.py`.
   Dekho: look-ahead (aaj ke close se aaj trade), entry/exit qeemat, kharcha, SL, slot / ek market ek trade, FTMO din-hadd hisaab, MQL5 vs Python farq.
3. **Qaidon ki jaanch:** TALAASH / IMTIHAN / ASLI PASS (`docs/trading-pakki.md` 1-NAYA 1-8). Kya ye shart ittefaqi PASS rok sakti hai?
   ~105 koshish ke baad 8 PASS = multiple testing; IMTIHAN 2019+ kai dafa dekha. Apna sakht tareeqa tajweez karo (masalan Deflated Sharpe, White reality check, walk-forward).
4. **Instruments:** har EA ke market kyun - mel (correlation), ek taraf jhukao (sab BUY), US index par t5+i6 dohra daao, kharcha. Data: `data/` (QDM / Dukascopy H1).
5. **Apna test khud likho** `tools/fable_*.py` mein (purani file NAHI badalni). Demo milaan: `data/demo_474832446/` + `tools/milaan_k10.py`.
6. **Aakhir mein** hamare nateeje (`docs/khud-nazar.md`) se milao: kahan mile, kahan farq, kaun sahi aur kyun.

## Hadd (bhoolna mana)
- Purane EA / Pine mein KOI tabdeeli NAHI; risk hadd NAHI barhani; grid / martingale / hedge NAHI.
- Nateeja `docs/fable-jaanch-nateeja.md` mein: (a) bug list (sangeen pehle), (b) har EA: bharosa haan / shak / nahi + wajah,
  (c) qaide ki kamzori + behtar qaida, (d) user ke liye 5-line khulasa Roman Urdu mein. Phir EK commit + push.
