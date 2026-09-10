# The Fishing Lots method, as the trader actually runs it

Captured 10 September from live screenshots and the trader's own account of
what he does and why. This replaces every earlier guess. Where something is
still unspecified it says so rather than filling the gap.

## Why this method at all, in the trader's own reasoning

This is his own question, one nobody had asked him, and the answer is the
foundation the rest of it stands on.

About a year and a half of trading, with a seven month gap in the middle.

His reasoning runs like this. The market is international and millions are
trading it at the same moment. Almost all of them use the same three or
four well known approaches, and liquidity, fair value gaps and reversals
are the important parts of those. So trading is a calculation game, and
what decides the outcome is whose calculation works faster, because the
market already holds every timeframe and every pip of the data.

From which he draws the conclusion the whole method rests on: **your
technique has to be different from everyone else's.**

And then the specific edge he believes he has, stated plainly:

> my lots are small and carry no stop loss and no take profit, and the big
> players hunting liquidity do not care about my small lot

That is the heart of it. A stop loss is a resting order that can be hunted.
A large position is worth hunting. He has neither. He is deliberately too
small and too quiet to be worth anyone's attention, and he treats that
invisibility as the edge rather than as a limitation. He says fair value
gaps give him the same benefit.

He fishes on top of all of this, and he calculates while he fishes.

**Where the method costs him.** The platform can show the combined weight
of the lots, how many 0.01 sells against how many buys, but reading it and
working it out takes him three or four seconds. During the ordinary fishing
that is fine. The moment a reversal traps him, calculation suddenly matters
enormously and those seconds are expensive.

He also describes a specific fear response. After four or five fishing
trades in the same direction a large reversal arrives, in his words, to
scare him. He answers it by leaving a gap in the fishing, waiting for the
reversal, and then using that direction too.

But often he gets trapped anyway, and then he has to make himself far more
careful to manage the chart.

**Which is exactly why he wants the EA.** Not to replace his judgement. To
do the calculating at machine speed, because a bot computes instantly, and
because every candle is being driven by a system far stronger than any one
participant.

## The account, and why it matters

Exness cent account, balances shown in USC where one USC is one US cent.
One lot is one ounce, so a 0.01 lot moves one USC for every dollar gold
moves. Position numbers can be read directly: a leg at -2.98 means gold
went $2.98 the wrong way on it.

Leverage 1:2000. Spread 0.26, fees about 0.26 USC.

**Swap is zero.** The account is swap-free. This is not a detail, it is
structural. Holding a position costs nothing but time, which is what makes
the waiting phase below possible at all. Remove swap-free and the method
changes completely.

## Phase 1 — Fishing

Read direction from EMA 20 and EMA 50 on the 1-minute chart. Open a lot.
Close it at about one dollar of profit, or at least comfortably above the
fees. Then read the moving averages again and repeat.

This is the normal state and it is where the name comes from. Cast a line,
take the fish, cast again.

### Lot size is not fixed at 0.01

Lots of 0.02 and 0.10 appear alongside the 0.01 ones. A 0.10 lot moves ten
USC for every dollar gold moves. See the worked example at the end of this
document for a basket run entirely at that size, and question 59 on the
question list, which asks him directly whether 0.10 is now normal.

## Phase 2 — Trouble arrives

After three or four lots in the same direction a reversal hits.

First response is to **wait**. Nothing else.

If a single lot reaches about **three dollars of loss**, that is the signal
to stop waiting blindly and start looking. At that point the trader opens
the multi-timeframe read down the left of the chart, 1 minute out to 1
week, and checks liquidity grabs and fair value gaps across them.

He will let the loss run to about **four dollars** while deciding.

## Phase 3 — Turning

When the multi-timeframe read says the move is no longer sensible to fight,
he **changes the direction** of new lots.

When that new direction shows instability, he places **recovery lots** in
it. Alongside those he continues placing lots against, the ones that take
the loss.

Through all of this he is watching two numbers at once: how many lots are
on each side, and what the equity can carry.

## Phase 4 — The freeze

This is the centre of the whole method.

He works out how many buy or sell lots are needed to make the two sides
**balance**. When that point is reached he stops adding against-lots and
lets the book sit hedged.

Once balanced, the combined result stops moving. Gold can go anywhere it
likes and the number does not change. Not up, not down.

## Phase 5 — Waiting, including sleeping

With the book frozen and swap at zero, waiting is free. There is no
pressure from the clock and no pressure from price.

If the reversal is slow in coming he goes to sleep. This is a deliberate
part of the method, not a lapse. A frozen book with no swap cost cannot
deteriorate.

## Phase 6 — The unwind

When the reversal finally arrives he closes the **hedge lots** at a small
loss, in the region of 0.03 to 0.05.

That releases the other side, which is now positioned to run into profit,
and it runs.

Then the book eventually goes out with Close All on a combined positive,
and Phase 1 starts again.

## What makes this work, stated plainly

Gold moves hard. Fighting it with a fixed stop means being stopped out
constantly. Instead the method never uses a stop at all, and buys time
instead: freeze the book, pay nothing to hold it, and wait for a reversal
that gold reliably provides sooner or later.

The trader's own summary: because it is gold, controlling equity against it
is a must, and it takes constant attention.

## A correction I owe: the signal was never tested

Earlier in this project the Pine tester reported that the entry signal
performed worse than a coin flip, on both the one-minute and five-minute
charts, and that finding was stated firmly. It was wrong, and it was wrong
because of what was actually being measured.

What I tested was my own port: an EMA 20 against 50 read, a three-candle
fair value gap, and a pivot-based liquidity sweep. Three conditions.

What the real script requires before it will take a trade, listed by its own
Teacher panel under "BUY missing":

- demand zone touch or breakout
- trend up
- a recent break of structure or change of character
- an up fair value gap or an up liquidity grab
- the dollar index filter
- Supertrend up
- a confluence score of at least 60, where it was showing 30
- room to the first target, refused when an opposing zone sits too close

Eight gates, not three. The score gate alone rejects most setups. My port
had no score gate at all, so it took every weak setup the real script would
have thrown away. A version that accepts everything scoring badly against
one that accepts only the best is not a test of the idea.

And the script keeps its own record. The virtual tracker on the chart, which
computes expectancy as the sum of R multiples divided by the number of
closed trades, reads:

| measure | value |
|---|---|
| tracked trades | 59 |
| first target hit rate | 54.2% |
| expectancy | +0.41 R per trade |

Positive expectancy, and measured on the FIXED script. That was checked
rather than assumed: the screenshot's dashboard header reads "BOARD gates
(closed): EMA20/50 | sepATR | FVG/LGB/SR: live bar", and that wording exists
only in v2.1. The pre-fix file says "DASHBOARD (closed)" there, and the
"FVG/LGB/SR: live bar" half is itself one of the fixes, added so the header
states which columns read the live bar and which read the closed one.

So the ten bugs were already out when these numbers were produced.

Two honest limits remain. Fifty nine trades is a small sample. And it is
measured across whatever history the chart had loaded rather than forward,
so it is a backtest on that window. Evidence, not proof. But it is real
evidence, and it points the opposite way from my finding.

The correct statement is that the signal has not been tested here yet. The
thing that failed the coin-flip comparison was my simplification of it.

## What the EA is actually for

Not judgement. Endurance.

The trader already has a panel on his MT5 chart showing breakeven and the
combined weight of the lots, so the arithmetic that used to cost him three
or four seconds now costs under one. That problem is solved. The remaining
problem is a different kind entirely.

His own words for it: hand it to the one who never tires.

Look at what the method asks of a person. A frozen book has to be held,
sometimes for weeks, without touching it. Through that whole time the
temptation is to interfere, and the fear is that this time the reversal
never comes. A human gets tired, gets scared, and acts. A bot holds the
position for a month with exactly the same indifference it had in the
first minute.

He puts it more sharply than that:

> the trading platform is itself a bot, and only a bot can face it, and
> that too over weeks

So the machine's contribution is not that it is cleverer than him. It is
that it does not get tired, does not get frightened, and does not get
bored. Those are the three things that cost a discretionary trader money
during a long wait, and they are exactly the three a program does not have.

### What that demands from the design

**Manual control is not a fallback, it is a feature.** He wants to be able
to stop the automatic side, set something by hand, and then hand it back,
without restarting anything and without the bot fighting him for control.
Any design where taking over means switching the EA off is the wrong
design.

**The transfer is gradual, not a switch.** He intends to move himself onto
the bot piece by piece, watching until he trusts each piece, rather than
handing over everything at once. So each part has to be independently
switchable.

**He wants to watch without tension, and take notes.** While the bot runs
he wants to see anything it does that goes against his method, so it can be
corrected. That means the EA has to say out loud what it is doing and why,
not merely do it.

## What is mechanical and could be automated

- Never setting a stop loss or a take profit on any order
- Reading EMA 20 against EMA 50 for the fishing direction
- Closing a fishing lot at a set profit above fees
- Counting the loss on a lot and raising an alert at three dollars
- Computing exactly how many lots balance the book, and placing them
- Recognising that the book is balanced and therefore frozen
- Closing everything at once on a combined positive

## What is NOT yet defined

- **The reversal signal itself.** Liquidity grabs and fair value gaps
  across 1 minute to 1 week are consulted, but which combination counts as
  a reversal has never been written down. This is the largest gap.
- **Recovery lots versus against-lots.** Both are placed during Phase 3.
  What decides which one goes on, and how many, is not specified.
- **The equity rule.** Equity is watched constantly, but the actual limit
  that stops him adding has not been named.
- **The worst case ever seen.** Most lots open at once, and the deepest the
  book has ever gone. Never measured.

## Where the risk actually sits

Not in the frozen phase. A balanced book with zero swap is genuinely inert
and can wait indefinitely.

The risk lives in two narrower windows.

**Before the freeze**, while against-lots are still being added and the
sides are not yet balanced. Every lot added here deepens an unhedged
drawdown. If gold runs far enough fast enough, the freeze point arrives
later and deeper than intended, or equity runs out before it arrives.

**Just after the unwind**, when the hedge legs have been closed and the
remaining side is naked again. If the reversal was a false one, the book is
exposed with no protection and the whole cycle restarts from worse.

Both windows are measurable. Neither has been measured yet.

## Worked example — one closed basket, 10 September

The first live basket captured with its exact numbers, from the Exness app's
Closed tab. It is Phase 6 into Phase 1: the whole book taken out together on a
combined positive.

| Side | Lot | Open | Close | Result |
|---|---|---|---|---|
| Buy  | 0.10 | 4362.951 | 4370.298 | +73.50 USC |
| Buy  | 0.10 | 4366.963 | 4370.298 | +33.40 USC |
| Buy  | 0.10 | 4370.163 | 4370.298 |  +1.40 USC |
| Buy  | 0.10 | 4374.481 | 4370.298 | -41.80 USC |
| Sell | 0.02 | 4363.407 | 4370.558 | -14.30 USC |

Net of these five legs: **+52.20 USC**. Day total on the same screen:
**+740.00 USC**, so this basket is one of several that day.

What the numbers show, beyond what was already written down:

- **The buys are a ladder, not one entry.** 4362.951 / 4366.963 / 4370.163 /
  4374.481 — spacing 4.01, 3.20, 4.32 dollars. So the gap between added lots
  sits around **$3 to $4.30**, which is the first measured value for a spacing
  that "What is NOT yet defined" listed as unknown. Note it is close to the
  three-dollar mark that Phase 2 names as the point where a single lot's loss
  makes him start looking.
- **All four buys close at one price, 4370.298.** That is Close All on the
  basket, not four separate exits. The basket is the unit that is managed and
  the unit that is closed — a single leg being red at exit (-41.80 on the
  4374.481 buy) is irrelevant as long as the combination is positive.
- **The counter-leg is closed at a loss to release the rest.** The 0.02 sell
  from 4363.407 is taken out at -14.30 while the buys are taken out at +108.30
  gross. This is exactly the Phase 6 unwind, and it is the first time the cost
  of it has been measured: about 27% of the basket's gross profit went on the
  counter-leg.
- **The counter-leg is a fifth the size of a buy leg** (0.02 against 0.10),
  and it closes 0.26 higher than the buys (4370.558 vs 4370.298), i.e. one
  spread later — a separate click, moments after.

**One thing here does not match the method as recorded above.** The rest of
this document says the lots are 0.01 and that being small is the edge: "my
lots are small and carry no stop loss and no take profit, and the big players
hunting liquidity do not care about my small lot". This basket runs **0.10 per
buy leg, ten times that**, with a 0.02 counter-leg. On a cent account 0.10 lot
is 10 USC per dollar of gold, so a $10 adverse move on four such legs is 400
USC. Whether 0.10 is now the normal fishing lot, or this was a deliberately
larger session, changes both the equity arithmetic and the "too small to be
worth hunting" premise. It is an open question, not a correction — the
screenshot alone cannot say which.

Neither can it say, from the Closed tab alone: how long the basket was held,
how deep it went before the reversal, or whether the 4374.481 buy was a
fishing lot or a recovery lot. Those need the Open tab or the equity curve.
