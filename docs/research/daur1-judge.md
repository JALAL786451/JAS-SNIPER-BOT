# Research judge report (1 Nov 2026), on research1/REPORT_for_judge.md
No 2019+ backtest or price computation was run. Sources were read through WebFetch, or from the agent's downloaded PDFs (research1/dl_*). The repo was only read.

## Verdicts
- C1 local pre-holiday x 7 non-US index: KEEP (rank 1). Different events from #59/#67, almost no tuned parameters, daily data, FTMO-safe. The edge is thin and most of it is Japan and HK.
- C2 Gotobi long 03:00 to 09:55 JST: REJECT as the rules are written. There is no evidence after 2020 (Bessho ends Dec 2020), so it fails the <=H1 rule. It is the only intraday idea worth a waiver: KEEP only if the Chief or user explicitly waives that rule (rank 2).
- C3 Gotobi short after the fix: REJECT. It is a single 3-year preprint, and the conditional short also works on non-Gotobi days (PF 1.20), so it is mostly the generic post-fix reversal, which KMW show decaying. The 12:00 exit and the 09:00 filter are ad hoc. Fold it into C2 later if C2 passes.
- C4 BTC 21-23 UTC: REJECT. The hour was picked from 24, in-sample, with no costs, and 2022-23 was "rough". FTMO's crypto commission of 0.0325%/side (0.065% RT, VERIFIED) is about 70-80% of the gross ~0.08-0.09%/trade. Entry falls on the rollover. TALAASH data runs only May 2017 to 2018.
- C5 oil D-5 to D-1 before US holidays: REJECT. The window was chosen from a D-5..D+5 plot on 2006-2024, which includes IMTIHAN. It comes from a blog, with no costs and no OOS. Dukascopy oil starts in 2013, which gives about 55 trades (<100). Holidays that fall on a Friday give a Friday-close entry, which clashes with FTMO's gap rule. Oil has tail risk (#69).
- C6 FX fix W: REJECT. KMW find net returns negative at full spread, below 5%/yr by 2018-19, and no evidence after 2020. The agent also rejected it.

(details in the handback message)

## Judge ka C1 pre-registration (poora)
- Universe (#67 jaisa, badalna mana): TVC:NI225, TVC:HSI, ASX:XJO, TVC:UKX, XETR:DAX, EURONEXT:PX1, TVC:SX5E.
- Calendar: exchange_calendars XTKS/XHKG/XASX/XLON/XETR/XPAR (SX5E = TARGET) ki SCHEDULED chuttiyan; ad-hoc (typhoon, rainstorm, < 5 din pehle elaan) NAHI.
  P = ek ya zyada weekday bandish se pehle aakhri local session; N = baad ki pehli. Waqia chhoro agar #59 list ki scheduled NYSE chutti [P-4 cal din, N+1] mein ho.
- Trade: P-1 close BUY, P close SELL (P aadha din = asli close). Sirf BUY, ek index ek position. SL 3 x ATR20 daily = 1R, gap = open.
- Kharcha: JasSpreadNaap local close ke waqt x 1.5 har taraf; na naapa ho to HK50/JP225/AUS200 0.03%, Europe 0.02% har taraf. Swap 3%/saal.
- SE x k, k = sqrt(ausat trades fi waqia-tareekh) (sirf calendar se), pehle se.
- TALAASH 2005-2018 (TV cash daily) PASS = sab: N >= 100; Exp - 2kSE > 0; ausat >= 2 x usi index/saal ka daily drift; (index x saal, >= 2 tr) musbat > 50%;
  NI225 aur HSI dono Exp > 0. Dukascopy H1 CFD 2012-18 (#68 timing) ka rukh same ho (jaanch, shart nahi).
- IMTIHAN 2019-01..2026-10 EK dafa: N >= 30, Exp - 2kSE > 0, >= 2x drift. Phir FTMO jor #68 + C1: risk 0.10/0.15/0.25 (2012-18 #60/#68 shart), 2019+ fail 0, pass >= 83, median < 10.8.

## C2 Gotobi (sirf waiver par) - Dukascopy USDJPY M1 bid/ask, 03:00 JST ask entry, 09:55 JST bid exit, SL 1xATR20, TALAASH 2005-18 N>=100, Exp-2SE>0, 8/14 saal,
Gotobi ausat >= 2 x sab Tue-Fri usi window ka ausat (placebo); IMTIHAN 2019+ + MT5 asli ticks 2021+.
