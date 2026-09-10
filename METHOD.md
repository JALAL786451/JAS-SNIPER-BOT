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
