# KAAM - Jalal ka EK register (har nayi chat ko hook KHUD dikhata hai)

Qaida (user 9 Nov, 51vi): user kuch bhi bataye (faisla, khabar, "ye kaam kyun") -> USI jawab mein yahan likho, chat khatam ka intezar NAHI.
Kaam ho jaye -> "HUA" + tareekh, agli chat mein neeche "Hue" mein. Chhota rakho (~3 KB). Tafseel doosri files mein, yahan ek line.

## Pehle jawab mein KHUD (user ko yaad na dilana pare)
1. MT5 naqsha table (TRADING.md sec 0) - user tasdeeq.
2. Neeche "Khule kaam" se AGLA kaam khud batao + salah (user se "kya karein?" mat poochho).
3. 1 nayi maloomat (Claude / AI / FTMO / data) - `docs/nayi-maloomat.md` mein na ho. Bata kar wahan likho.
4. "Chat khatam" sirf ~15 USER message ke baad.

## Pakki baatein (bhoolna mana)
- FTMO swap-free email: JAWAB AA CHUKA (5 Nov, user ne dikhaya): Islamic clients ko milta, extra fee nahi, sab symbols. Khareedne se pehle "Swing 2-Step 100k par?" likhwana baqi.
- US500/USTEC M1 2012-26 (QDM) user ne **Tide (Kachhua) ko FTMO mein shamil karne** ke liye diya (user 9 Nov). Jaanch HUI (49vi): saaf.
- Gold M1 2019/20/25/26 bhi QDM se user ne diya (7 Nov) - Tokri / Turtle test ke liye.
- Plan: `docs/pdf/JAS_FTMO_Plan_Monday.pdf` sec 5 (Monday list). Tokri qaide: `docs/tokri_naqsha.md`.
- Risk hadd khud se NAHI barhana. Backtest -> demo -> live.

- FundingPips email (8 Nov, Sarim): trade kholne/badalne/band karne wala EA MANA (account band); VPN/VPS MANA; Evaluation mein weekend hold OK, Master par overnight/weekend NAHI (Swing add-on se OK); Swap-free add-on +10% qeemat, SIRF forex + metals (index/energy/crypto par swap), khareed ke waqt hi. => hamare EA (t5/i6/k2) wahan NAHI chal sakte; EA plan sirf FTMO.

- 9 Nov SS: LIVE 253687618 par JasMauqa **m7.6 BTCUSDc H4** (equity 37,976.56, P/L -2315.63, 147 ticket, NET +0.15). Popup A: Close By SELL 2.43@74872.15 + BUY 2.20@74389.22 = +1062.45, NET wahi. Ladder label "gold" likha (BTC par) = chhota label bug.
- 9 Nov report (31 Oct-9 Nov, user PDF chat mein; repo mein NAHI): balance 44,863, equity 37,398, floating -7,466. KHULI gold BUY 4.26@4074.20 / SELL 4.34@4065.95 (NET SELL 0.08, gold ~4124); BTC BUY 2.92@75607 / SELL 2.76@74450 (NET BUY 0.16). BAND: gold SELL -41,790 (bari SELL 1-4 lot = sara nuqsan), gold BUY +33,350, BTC +2,551. Bure din 2 Nov -5,867, 4 Nov -5,958.
- 9 Nov: JasMauqa m7.6 ab DO chart par (BTCUSDc H4 + XAUUSDc H4) ✅. Gold panel: BUY 4.23@4074.72 / SELL 4.30@4066.09, NET SELL 0.07, breakeven 3529.98, P/L -4110. Panel ki "HEDGE: NAYI BUY 3.96 lot" line = bari lot = MAT (report sabaq). C) akeli profit ticket close = NET badalta -> A/B (Close By) behtar.
- 9 Nov raat: user ne Claude Code course ki 19 cheezon ka SS diya, kal poochega "kya ye kiye?" -> jawab `docs/claude-code-19.md` (5 ✅ 8 ⚠ 6 ❌).
- 9 Nov raat (52vi): user thaka, aaram. Subah wapas aayein to: K1 (D:\JAS_DRIVE.bat + schtasks SS) -> K4 qaide (user 'haan'). K3 + K10 HUE. Gold + BTC dono TALA-BAND (NET ~0).

## Khule kaam (tarteeb = user ki marzi; upar wala pehle)
| # | Kaam | Kyun (user) | Haal |
|---|---|---|---|
| K1 | D:\JAS = GitHub ka copy (`tools/JAS_DRIVE.bat`), Windows roz khud pull (0 token). Cloud chat D: seedha nahi parh sakti (Remote Control folder list khali) -> GitHub = pul | user 9 Nov: "D drive, nayi chat wahan se" | user SBS kar raha |
| K2 | Tide (Kachhua) FTMO mein: US500/USTEC par test (M1 data isi liye) | user 9 Nov | baqi - qaida pehle likho |
| K3 | Gold M1 2019/20/25/26 jaanch (gap, timezone) | Tokri/Turtle test ka data | HUA ✅ 9 Nov (52vi) `tools/gold_m1_jaanch.py`: saaf - 0 ghalat bar, UTC (Sunday 22:00 garmi / 23:00 sardi), gap sirf US chhutti; 2026 = 4 Nov tak; 2021_24 se mel |
| K4 | Tokri + Turtle 55/20 rukh test (55 din toot = rukh, 20 din ulti toot = khatam; rukh 0.02 / doosri 0.01) | user 9 Nov | user "haan" qaide par baqi |
| K5 | Tokri EA tk2 "perfect": F7 0 error -> demo 472716649 (LIVE nahi) | user: "EA her soorat chahiye" | baqi |
| K6 | LIVE report se user ka asli tareeqa (naqsha, test nahi) | user haan 7 Nov | baqi |
| K7 | Faisle: Kachhua e1 0.25% FTMO demo? B1 ya B2 pehle? | PDF hafta 1 | user se poochna |
| K9 | JasMauqa m7.7 BANA (9 Nov, user "haan"): F7 ✅ DONO chart par chal raha (9 Nov SS: margin level 236960%, Exness stop out 0%, DOOSRA line sahi, BARI LOT gold 4 tk max 3.53). Test: autotrade 27 objects = settings se ruki; m7.7 phir bhi mitata. (a) "autotrade #" trendline (MT5 khud har trade par banata, switch nahi; BTC chart par 1311 objects) har minute mitao; (b) LIVE par BTC + XAU dono ki lots (user 9 Nov). EA sirf chart ka symbol ginta (L269) magar equity poore account ki -> STOP OUT door (L445-447) sirf BTC NET se = GHALAT jab dono khule. + ladder label "gold" BTC par. (c) salah: 0.10 se bari lot par sirf WARNING (rokna nahi). Code jaancha 9 Nov: A/B Close By hisaab SAHI (r=(S-B)*minLot, NET wahi), equity nahi barhti. | user 9 Nov | HUA ✅ |
| K10 | JasMauqa m7.8: NET < 0.05 par BREAKEVEN number nahi -> "TALA-BAND" (user 9 Nov "bana dein"; breakeven samjhaya, sawal-jawab mein) | user 9 Nov | HUA ✅ 9 Nov: F7 0 error, BTC chart SS par TALA-BAND line sahi |
| K11 | JasMauqa m7.9 SOTE WAQT: InpAuto (A/B Close By khud YES, NET wahi), InpAutoC (C khud, default false), D kabhi khud nahi; jawab na aaye = NO + dobara nahi (user 10 Nov) | user 10 Nov | BANA - user F7 + pehli AUTO jaagte hue dekhe |
| K8 | TV Store update ho to robocopy dobara (TV Bridge) | 50vi | jab update aaye |

## Hue (aakhri 5)
- 9 Nov (52vi): FTMO demo i6 US500 BUY 2.81 qaide se band (IBS 0.90) +584.73; balance 99,494, equity 100,053.90.
- 9 Nov (52vi): LIVE SS: equity 38,995.64 (report 37,398 se +1,598), gold -8540 NET +0.01 tala-band, BTC -3439 NET BUY 0.31; khula nuqsan kul ~-11,980.
- 9 Nov (52vi): FTMO demo SS #2: equity 100,088.60, 3 khuli +1179.33 (sab plus), target baqi 9911.
- 9 Nov: Naqsha+5EA j3.2 TV par (0 error, user paste). FTMO demo SS (equity 99,559).
- 9 Nov: US500/USTEC M1 2019-20 jaanch saaf (49vi).
