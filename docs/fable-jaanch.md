# FABLE 5.2 se AZAD JAANCH (user 17 Nov, 66vi) - "4 EA, instruments aur qaidon ka doosra imtihan, taake bharosa mazboot ho"

**Chalane ka tareeqa (user):** nayi chat -> model **Fable 5.2** chuno -> "TRADING" -> phir likho: **"docs/fable-jaanch.md wala kaam karo"**.
Fable ke paas 11 Dec tak. Ek hi chat mein poora; agent / workflow NAHI (limit). Roman Urdu jawab.

## Fable ke liye hidayat (AZAD rehna zaroori)
1. **Pehle khud jaancho, phir hamare nateeje parho.** `docs/khud-nazar.md` sec 5-6, `docs/k9-jor-tajziya.md` ko apna kaam KHATAM hone tak NA kholo
   (warna jaanch azad nahi rahti). Purane PASS ke number sirf `docs/trading-pakki.md` 1-NAYA qaida se lo.
2. **Code ki jaanch (bug dhoondo, tabdeeli NAHI):** 4 EA jo FTMO demo 474832446 par chal rahe:
   t5 = `JasTrendEA.mq5` (4H Supertrend, sirf BUY, XAU/XAG/US500/USTEC, 0.75%), i6 = `JasIbsEA.mq5` (IBS, US500+USTEC, 1%),
   k2 = `JasKhirkiEA.mq5` (non-US index khirki, 0.15%), e2 = `JasTideRadarEA.mq5` Kachhua (BUY+SELL 12 market, 0.25%).
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

## Yaad-dihani ki SETTING (scheduled task - repo ke bahar chalti hai, yahan sirf likha hai)
- Naam: **"Fable reset - K22 jaanch yaad"**, id `trig_01WQ6xUWyy2M3ej1MVJFbZom`, Claude ne 17 Nov (66vi) lagaya, EK dafa chalegi.
- Waqt: **Itwar 22 Nov 2026, 2:05 AM PKT** (21 Nov 21:05 UTC) - hafte ki limit reset (2 AM) ke foran baad, purani chat mein.
- Matan: "Fable 5.2 ab reset ho gaya. Nayi chat kholein, model Fable 5.2 chunein, 'TRADING' likhein - K22 (ye file) khud shuru."
- Badalna / band karna ho to Claude chat mein kahein (scheduled task update / delete) - user ki ijazat se.
- User 19 Nov (70vi): Fable mehnga; magar 4 EA (t5 4/5 haar, i6) ki tasdeeq isi se - reminder WAHI rahe.

## 70vi (19-20 Nov) ke naye kaagaz - sirf hidayat 6 (aakhir) mein milane ke liye, pehle NA kholo
- Demo report 20 Nov: `data/demo_474832446/ReportHistory_20261120.xlsx` (t5 5 band 1 jeet -1,310; i6 4 band 2 jeet -846; e2 3 SELL khuli +627).
- Gold 1D chup daur mein 4 EA: `tools/gold_khamosh_sahara.py` (e2 > i6 > k2 sahara, t5 har daur manfi); `docs/sawal-jawab.md` 19 Nov lines.
- US500 17 Nov se D1 SMA200 ke neeche (khud-nazar sec 6 ka qaida: t5 US ka khatra asli) - V2 test FAIL tha; is par apni raye do.
- Paisa bachao: jo hisaab upar ke kaagaz mein hai wo DOBARA na chalao, sirf milao.
- **72vi (21 Nov) EMA 50/200 4H + "roz 1 trade" jaanch:** `docs/research/ema-21nov/README.md` (+ `code/`, `data/`). **Fable ke liye sawal (hidayat 6 mein, pehle NA kholo):**
  (a) kya EMA 50/200 4H sirf BUY (XAU + USATECH) t5 ka dohra hai (G6: corr 0.46-0.62, ~60% waqt wahi BUY) - 5th EA banana chahiye ya nahi?
  (b) US index par t5 + i6 + (5th) = 4-5 BUY ek din - khatra.
  (c) ~1,500+ tests ke baad "roz 1 trade koi edge nahi" ka nateeja aur multiple-testing ki raye; (d) FTMO P1 10% ke liye 9% CAGR / DD -22% wala basket kitna kamzor.
