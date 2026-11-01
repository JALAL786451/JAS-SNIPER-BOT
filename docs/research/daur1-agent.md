# Research agent report (1 Nov 2026) - candidates for FTMO plan (literature only, no 2019+ backtests)

| # | Candidate | Market / TF | Trades/mo | agent P(pass) |
|---|---|---|---|---|
| C1 | Local (non-US) exchange holidays, pre-holiday day long | JP225, HK50, AUS200, UK100, DE40, FR40, EU50 daily | ~2 | 0.35 |
| C2 | Gotobi long before Tokyo fix | USDJPY 03:00->09:55 JST on 5/10 days (Tue-Fri) | ~5 | 0.25 |
| C3 | Gotobi short after fix (only if 09:00 > 03:00 price) | USDJPY 09:55->12:00 JST | ~3 | 0.20 |
| C4 | BTC 21:00-23:00 UTC hour effect long | BTCUSD daily 2h | ~30 | 0.15 |
| C5 | Oil before US holidays D-5 close -> D-1 close long | USOIL, UKOIL daily | ~1.6 | 0.15 |
| C6 | FX fix "W" (SELL EURUSD 08:00->14:15 Frankfurt; BUY 16:03 London -> 16:30 NY), also GBPUSD | H1-ish | ~84 | 0.10 (fails our <=H1 post-2020 evidence rule) |

Rules details:
- C1: scheduled exchange holidays only (XTKS/XHKG/XASX/XLON/XETR/XPAR via exchange_calendars), cluster of holiday weekdays, P = last session before, BUY close of P-1, exit close of P (CFD: first H1 after local cash close), skip if any NYSE closure in [P-4 cal days, N+1] (to separate from #59/#67). Stop 3xATR20 D1. Count 2005-18 ~23/yr total (JP 9.1, HK 6.4, AU 2.6, UK 2.1, DE 1.3, EU50 1.3, FR 0.7).
- C2: g in {5,10,15,20,25,30, month-end if <30 days}; weekend/JP holiday/Dec31-Jan3 -> previous Tokyo business day; skip Mondays. BUY 03:00 JST, exit 09:55 JST. Stop 1xATR20 D1. Cost 1.5x0.0085% ~1.9 pips RT.
- C3: same days; if 09:00 JST price > 03:00 price, SELL 09:55 -> exit 12:00 JST.
- C4: BUY 21:00 UTC exit 23:00 UTC every day incl weekends. Stop 1xATR20. Sits on broker rollover.
- C5: NYSE calendar from #59; BUY close D-5, exit close D-1. Stop 3xATR20. WTI/Brent correlated (SE x1.4).

Claimed sources:
- Vidal-Garcia & Vidal (2025) "The Holiday Effect", SSRN 5073776 (1990-2024; Asian pre-holiday returns ~7x normal) https://papers.ssrn.com/sol3/papers.cfm?abstract_id=5073776
- Carchano & Pardo (2015) Rev. Esp. Fin. Cont. 44(2):134-145 https://producciocientifica.uv.es/documentos/5eb09eb3299952764113bbdb
- Chong, Hudson, Keasey & Littler (2005) JIMF 24(8) - pre-holiday effect weakened (UK, HK) https://ideas.repec.org/a/eee/jimfin/v24y2005i8p1226-1236.html
- McGuinness (2005) Applied Financial Economics https://ideas.repec.org/a/taf/apfiec/v15y2005i16p1107-1123.html
- Yuan & Gupta (2014) QREF https://ideas.repec.org/a/eee/quaeco/v54y2014i4p529-537.html
- Quantpedia pre-holiday page https://quantpedia.com/strategies/pre-holiday-effect
- Bessho, Sugimoto & Suzuki (2023) arXiv 2301.13204 (EBS 2018-2020: Gotobi long N=185 PF 1.46 win 0.60 after spread; short N=113 PF 2.09 win 0.57) https://arxiv.org/abs/2301.13204
- Ito & Yamada (2017) JIE 109 / NBER w22820 https://www.nber.org/papers/w22820
- Ibaraki Univ / Monex Gotobi (ZAi FX 2019): up-rate 58-63% after 2-pip spread, Aug 2010-Jul 2018 https://zai.diamond.jp/articles/-/319691
- Krohn, Mueller & Whelan (2024) JF 79(1) FX fix W https://www.bankofcanada.ca/wp-content/uploads/2021/10/swp2021-48.pdf
- Quantpedia BTC hour (2022: Gemini 2015-22 ~33%/yr maxDD -22%) https://quantpedia.com/are-there-seasonal-intraday-or-overnight-anomalies-in-bitcoin/
- Quantpedia BTC update (2023: 40.6%/yr, rough 2022-23) https://quantpedia.com/the-seasonality-of-bitcoin/
- Quantpedia oil pre-holiday (Dujava 2024, USO 2006-2024) https://quantpedia.com/pre-holiday-effect-in-commodities/
- Brusa, Savor & Wilson 2020 Review of Finance (pre-ECB/BoJ drift - Fed only? unverified, rejected by agent)

Agent's own honesty note: edges per trade small (+0.02..+0.07R); could not reach 50+/month honestly.
