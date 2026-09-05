# Forward test log — smc_simple

Paper trades only. No money is at risk in anything recorded here.

The point of this file is to answer one question with data instead of
memory: does the script hold up on candles that did not exist when it was
built? The backtest said profit factor 1.217 over 275 trades on 4H across
three years. That number describes the past. This file is the future.

## How to use it

Add a row when a signal appears. Fill in the outcome when the panel says
KHATAM. Do not delete losing rows, and do not change the settings while the
log is running — a log taken under changing rules measures nothing.

Judge nothing before 20 trades. A run of three losses is ordinary at this
win rate; so is a run of three wins.

## Settings under test (frozen)

| Setting | Value |
|---|---|
| Timeframe | **15M** (changed from 4H — see below) |
| Cooldown bars | 8 |
| TP1 partial | 0 |
| HTF filter | OFF |
| Date filter | OFF |
| Feed | OANDA:XAUUSD |
| Account this is sized for | $500, 0.01 lot, about 1.6% risk per trade |

The timeframe moved from 4H to 15M on 2026-09-05, not because 15M tested
better in isolation but because 4H is unreachable: its stop is about $90, so
1% risk needs a $9,000 account. Forward testing a configuration the account
cannot trade would measure nothing anyone can act on.

15M earned the move on evidence, not convenience. Its profit factor is 1.292
over 647 trades, and the settings it ran were chosen on 1H and 4H and carried
over unchanged, which makes 15M an out-of-sample check on those choices.
BUY made +2,893.68 and SELL +2,891.28 — within $2.40 of each other, so the
edge is not a bet on the direction gold happened to travel. Against that, the
whole sample is three months, and no more 15M history is available to test.

## Trades

| # | Date | TF | Side | Route | Entry | SL | TP2 | Risk $ | Outcome |
|---|---|---|---|---|---|---|---|---|---|
| 1 | 2026-09-04 | D | SELL | MA20 retest | 4328.405 | 4508.888 | 3967.440 | 180.48 | SL |
| 2 | 2026-09-04 | 4H | BUY | MA20 retest | 4493.535 | 4403.145 | 4674.315 | 90.39 | SL |
| 3 | 2026-09-04 | 1H | SELL | breakdown | 4393.770 | 4484.038 | 4213.235 | 90.27 | open |

## Human calls logged alongside, for comparison

Two people gave a view on gold the same day. Neither stated a stop, so the
stop column is what their own chart implies, not what they said.

| # | Date | Source | Side | Entry | Implied SL | Target | Outcome |
|---|---|---|---|---|---|---|---|
| A | 2026-09-04 | 15M chart | BUY | ~4406 | ~4340 | 4520 | open |
| B | 2026-09-04 | 1D chart | BUY | ~4484 | ~4240 | 4565 | open |
| C | 2026-09-04 | 15M chart | BUY limit 4430 | 4430 | 4417 (stated) | ~4470 | pending fill |
| D | 2026-09-05 | **the user's own call** | UP | ~4429.83 | 4282.63 (proposed) | 4697.105 | open, deadline 2026-09-19 |

## Observations to revisit later, not to act on now

- Both losses so far came through the **MA20 retest** route; the breakdown
  route produced the one trade still open. Two samples prove nothing. If the
  same pattern is still there after 20+ trades, test `useRetest = false`
  once on the full three-year 4H window and accept whatever it says.
- Both losses happened in the same whipsaw: gold fell about $90 and took
  back about $50 within a day. Breakout systems lose on both sides of that.
  This is a known weakness, already priced into the 1.217.
- Call D is the user's own first prediction: gold takes out the 4,697.105
  high. Written down with a level that makes it wrong (a break of 4,282.625)
  and a date, because without both it is not checkable. The deadline matters
  more than it looks: gold has trended up for three years, so "it eventually
  makes a new high" is close to always true given unlimited time, and a
  prediction that cannot fail teaches nothing about the person who made it.
- Call C is the only one of the three whose author stated a stop, so it is
  the only one that can be scored honestly. Its stop is $13 against a day
  whose range was $155 — about 8% of it. At 1% account risk that sizes to
  0.07 lot, seven times the 1H signal's size. The dollar risk is the same by
  construction; what changes is how often it is lost. A tight stop is not a
  small risk, it is a frequent one.
- Daily signals carry stops around $180. On a $10,000 account at 1% risk
  that is 0.0055 lot, below Exness's 0.01 minimum. **Daily is not tradeable
  on this account size** — the smallest allowed position is already 2% risk.
