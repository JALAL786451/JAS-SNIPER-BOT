# The Fishing Lots method, as the trader actually runs it

Captured 10 September from live screenshots and the trader's own account of
what he does and why. This replaces every earlier guess. Where something is
still unspecified it says so rather than filling the gap.

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
