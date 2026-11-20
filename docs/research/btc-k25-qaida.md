# K25 - BTC script ka qaida: Python test (21 Nov 2026, 73vi)

User (21 Nov): "strategy pehle Python par test kar ke us ke baad script banaein jo reality based ho".
Shikayat (b1.1 SS): BUY / SELL bohot der se, chaal ka chhota hissa.

## Qaida TEST SE PEHLE likha (badalna mana)

Market sirf BTCUSD (user ne BTC kaha). Data = `tools/ftmo76.py load_btc()` (Bitstamp daily 2014-11 se 2017-05-08 tak,
phir Dukascopy H1 -> din 00:00 UTC, hafte ke 7 din = TradingView BTC / script jaisa; #76 wala 17:00 NY + Sat/Sun Peer mein sirf K0 ki maloomat).
(ye line test chalane se PEHLE badli - wajah: "reality based" = jo din script / chart dekhta hai.) Kharcha 0.05% har taraf; swap 20%/saal (#76 jaisa) + 0% sirf maloomat.
Har trade ka R = (faida - kharcha - swap) / shuru ki SL doori. Entry = din ke close par (Python), SL din ke andar H1 se.

5 umeedwar (zyada NAHI - zyada aazmana = qismat ka jeetna):
| # | Naam | Entry | Band |
|---|---|---|---|
| K0 | Kachhua 10/5 + EMA (b1.1 / e2 abhi) | close > 10 din high (BUY) / < 10 din low (SELL), EMA50/200 rukh, ATR >= 0.25% | SL 2xATR, roz 5 din low/high tak sarke; EMA ulta; close SL paar |
| K1 | Kachhua 10/5 BINA EMA | K0 jaisa, EMA rok NAHI ("jaldi") | K0 jaisa magar EMA ulta wala band NAHI |
| K2 | Turtle 20/10 + EMA | 20 din toot | 10 din low/high tak sarke, baqi K0 jaisa |
| K3 | Turtle 55/20 + EMA (Tide 2) | 55 din toot | 20 din low/high tak sarke, baqi K0 jaisa |
| K4 | 1D Supertrend(10,3) hamesha andar | close par Supertrend mude -> us taraf | ulta mude (close) -> band + ulti trade. R = entry se ST lakeer |

**Hisse:** TALAASH 2015-01..2018-12 (chunao) | IMTIHAN 2019-01..2026-10 (EK dafa, chuna hua; imaandari: K0 / K3 BTC 2019+ pehle Radar mein dekhe = aadha dekha).

**Chunao (TALAASH):** Exp R > 0 aur trades >= 15; in mein se sab se zyada KUL R / girawat-R (R:DD). Barabar ho to K0 (pehle se chalta).
**PASS (IMTIHAN):** chuna hua Exp R > 0, KUL R > 0, aur K0 se R:DD kam NAHI (warna K0 hi rehta - script b1.1 wahi).
**"Der se / chhota" ka naap (sirf maloomat):** entry par qeemat pichhle 20 din ke ulte kinare se kitne % door (der), trade ne chaal ka
kitna hissa pakra = faida / sab se bari favourable harkat (MFE) - jeetne wali trades mein.

G-darwaza (`test-se-pehle-shartein.md`): G1 trend factor (Moskowitz 2012, crypto par Liu-Tsyvinski 2021) | G2 trend-pichhe-chalne
walon ki der se qeemat chalti | G3 daily | G4 Exness + FTMO BTCUSD | G5 BTC akela = 100 trade NAHI (kamzori, likhi) | G6 e2 mein BTC
pehle se (K0 = wahi) | G7 kharcha 0.05% + swap | G8 yahi | G9 sirf script / e2 BTC hissa | G10 P(koi K0 se behtar + IMTIHAN pass) ~25%.

## Nateeja (21 Nov, `python3 tools/btc_k25.py`, data 2014-11-28..2026-10-29, swap 20%)
| | TALAASH 2015-18: n / Exp R / KUL R / DD R / R:DD | IMTIHAN 2019-26: n / Exp R / KUL R / DD R / R:DD | din | der% | pakra% |
|---|---|---|---|---|---|
| K0 Kachhua 10/5+EMA | 33 / +1.73 / +57.1 / 2.7 / 21.4 | 77 / +0.52 (+-0.23) / +39.7 / 4.5 / 8.9 | 12 | 15 | 49 |
| K1 10/5 bina EMA | 58 / +1.05 / +60.7 / 3.8 / 16.0 | 157 / +0.23 / +35.8 / 9.2 / 3.9 | 11 | 15 | 47 |
| **K2 Turtle 20/10+EMA** | 18 / +2.48 / +44.7 / 1.8 / **24.6** | 43 / **+0.84** (+-0.37) / +36.1 / 3.8 / **9.6** | 21 | 19 | 52 |
| K3 55/20+EMA | **12 trade < 15 = chunao se bahar** | 23 / +2.94 (+-2.37) / +67.7 / 2.8 / 23.9 (ek trade 53.9R) | 40 | 23 | 48 |
| K4 1D Supertrend | 31 / +0.66 / +20.5 / 3.5 / 5.8 | 67 / +0.58 / +38.9 / 11.2 / 3.5 | 41 | 18 | 52 |

**FAISLA (qaide se):** chunao = K2 (R:DD 24.6 sab se zyada, n >= 15). IMTIHAN: Exp +0.84 > 0, KUL +36.1 > 0, R:DD 9.6 >= K0 8.9 = **PASS (kamzor)**.
Imaandari: K2 aur K0 ka farq shor ke andar (SE 0.37 / 0.23); BTC akela = trade kam (G5). K3 IMTIHAN mein sab se acha magar ek 2020-21 trade par khara + TALAASH mein 12 trade = qaide se bahar.
**User ki shikayat ka jawab:** "jaldi" wale (K1 bina EMA, K4 Supertrend) entry ki der KAM NAHI karte (der 15-18% vs K0 15%), trade dugne, Exp aadha, girawat dugni.
Har trend qaida chaal ka ~50% hi pakarta (pakra% 47-52). Haqeeqat: der se aana + aadha pakarna = trend ka mizaj; bari trade (K2: 21 din, K3: 40 din) se faida.
Agla: script b2 = K2 (20/10). e2 EA BTC par abhi K0 (10/5) - b2 aur e2 kabhi alag ishara denge (EA badalna = alag faisla, user se).

### Baad ki MALOOMAT (21 Nov, user SS: "Aug BUY aur Nov SELL miss") - DEKHA HUA data, PASS NAHI kehla sakta
K2 20/10 BINA EMA: 2015-18 29 tr +1.74R kul +50.3 DD 2.0 | 2019-26 86 tr +0.56R kul +47.9 DD 7.2 (EMA wala 43 tr +0.84R kul +36.1 DD 3.8).
Bina EMA 2026: Aug 20 BUY 69,271 -> Sep 11 76,211 +2.16R pakarta (EMA wala miss), magar Jan / Mar / Jul / Sep 4 jhoote -0.35..-1R.
Matlab: EMA rok = mor (V) par der / miss, magar chop mein bachao. Faisla user ka; naya saaf data nahi bacha -> sirf demo se pata chalega.
