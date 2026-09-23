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

---

## The first measured result — 3,872 orders, roughly 22 Jun to 21 Sep 2026

He showed the Exness app's own Performance page. This is the first time the
method has been measured rather than described, and it is his own live money,
not a backtest. The numbers, as the app reports them:

| | |
|---|---|
| Total orders | **3,872** |
| Profitable | **2,906 (75.1%)** |
| Unprofitable | 966 (24.9%) |
| Gross profit | **+$3,592.75** |
| Gross loss | **-$3,771.15** |
| Net | **-$178.40** |
| Trading cost shown by the app | $0.00 |
| Trading volume | **$4,513,133** |
| Balance | $706 → **$528.18 equity** (**-25%**) |

Derived from those:

- **Average win $1.24. Average loss $3.90.** The average loss is **3.16x the
  average win**.
- **Profit factor 0.953** — just under break-even.
- The equity curve rises to about $715 and then falls to ~$500 over roughly
  six weeks, recovering to $528. The account's worst drawdown is the one it is
  still in.

### Why this matters

**A 75% win rate lost money.** Three wins do not cover one loss when the loss
is 3.16x the size. This is the mirror image of the Donchian strategy tested in
this repo (`strategies/jas_tide_v1.pine`), which wins only 40% of the time,
wins 2.1x what it loses, and is profitable over 458 trades. Win rate is not
the variable that decides the outcome; the ratio of average win to average
loss is.

This is a direct consequence of the method as documented above: no stop loss
means a losing leg is held until it comes back or until the basket is unwound
at a loss, while winners are closed at a few dollars. The method *manufactures*
small wins and large losses. That is what the 3.16x is.

### The cost estimate — do not treat the app's "$0.00" as the real cost

The app reports trading cost as $0.00 because this is a spread-only account:
the cost is inside the fills, not a separate line. From the reported volume:

```
$4,513,133 x ($0.26 / ~$4,300)  ≈  $273 of spread
Net result                       =  -$178
Implied result before spread     ≈  +$95
```

So on this sample the method's *direction* was roughly break-even to slightly
positive, and **the spread is what made it negative**. At about 92 orders per
day over ~42 trading days, each order carries roughly $0.07 of spread against
an average win of $1.24 — about 6% of every win, paid 3,872 times.

The $0.26 spread is an assumption; the real figure varied. The direction of
the finding is robust, the exact number is not.

### What this points at

Two changes, both measurable, neither of which requires abandoning the method:

1. **Fewer orders.** Same approach, a fraction of the clicks. Cutting order
   count by two-thirds cuts roughly $180 of cost on this sample.
2. **Cap the size of a loss.** If the average loss were brought down to the
   size of the average win, the same 3,872 trades at the same 75% win rate
   return roughly **+$2,395** instead of -$178.

The second is the larger effect by far, and it is the one the method as
written resists, because it has no stop by design. Do not graft a stop onto
his method on your own initiative — it is his call. Record the arithmetic and
let him decide.

### Correction — the 3,872 orders span TWO different account types

He corrected this the next day, and it changes the reading above materially.
The section above treated the whole sample as one regime. It is not.

- He started at **$707 on a USD Standard account.**
- He traded that down to **$489**.
- **At $489 he switched to a Cent Standard account**, and has since brought it
  back to **$528.18**.

| Period | Account | Result |
|---|---|---|
| Start → switch | **USD Standard** | $707 → $489 = **-$218 (-30.8%)** |
| Switch → now | **Cent Standard** | $489 → $528 = **+$39 (+8.0%)** |

**The entire loss belongs to the Standard-account period. Since moving to the
cent account he is up.**

What this does to the figures above:

- **The average win $1.24 / average loss $3.90 and the 3.16x ratio are not
  reliable as stated.** They average across both regimes, and a cent-account
  trade is a hundredth the USD size of a Standard-account one. The $3.90
  average loss is dominated by the Standard period; it is not a property of
  the method, it is a property of the lot size relative to the account.
- **The $273 spread estimate is likewise mixed** and should not be quoted as a
  single number until the two periods are separated.
- What does survive: 0.10 lots on a **Standard** account with ~$700 is roughly
  $10 per dollar of gold, so a normal $20 day is 30% of the account. That is
  what the -30.8% is. On the cent account the same 0.10 lot is 10 USC per
  dollar — a hundred times smaller — and the drawdown problem largely goes
  away. This is the arithmetic that the "Points vs digits"/lot-size warnings
  in CLAUDE.md are about, and here it is visible in live equity.

He diagnosed and fixed this himself, before any of it was analysed here. The
account-type switch is the single largest risk improvement in the record so
far, and it was his call.

**If this sample is ever re-analysed, split it at $489 first.** Any
conclusion drawn across the whole 3,872 orders is comparing two different
instruments.

---

## 17 August 2026 — the negative balance, and what it says about the method

He raised a dispute with Exness over this basket and kept the reply. Account
**252706674, MT5 Standard** (not the cent account — see the lot arithmetic
below). The broker's own figures, from their email:

| | |
|---|---|
| 5 positions closed manually, 20:43:45–20:43:58 GMT | **+$30.53** |
| 81 positions closed by one Close All at 20:44:20 GMT | **+$885.42** |
| Total realised | **+$915.95** |
| **Account balance immediately before the closure** | **−$264.72** |
| Balance after | **+$651.23** |

His screenshots of the moment before closing show **86 open**, floating
**+$915.44**, and the app's headline figure reading **650.72 USD**. Those
reconcile exactly: the headline was **equity**, not balance.

```
Equity 650.72  =  Balance (−264.72)  +  Floating (+915.46)
```

The Close All dialog at that moment offered **+915.46**; the fills actually
returned **+915.95**, i.e. **49 cents better** than quoted. Execution was not
the problem.

### Which account, proved from the lot size

The average winning position was **+$18.22** at **0.01 lot**.

- Standard: 0.01 lot = 1 oz, so $1 of gold = $1. A +$18.22 winner needs an $18
  move. Plausible.
- Cent: 0.01 lot = $0.01 per $1 of gold. A +$18.22 winner would need gold to
  move **$1,822**. Impossible.

So this is the **Standard** period, before the switch at $489.

### The mechanism this exposes — the important part

A **negative balance with positive equity** is the signature of this method
under stress. It happens because:

1. Losing legs get closed (or the basket gets partially unwound). Those losses
   are **realised** — they come straight off the balance.
2. Winning legs are **kept open**. Their profit is **unrealised** — it sits in
   equity, not balance.
3. Repeat that enough and the balance goes below zero while the app still
   shows a comfortable positive number, because the app's headline is equity.

On 17 August the account was standing **entirely on unrealised profit in open
positions. There was no floor underneath it.** Had gold moved the other way
that night, the +$915 would have drained and there was nothing below it — the
basket would only have gone deeper, with no way out.

He survived and closed at +$915.95. **That was survival, not skill**, and the
distinction matters: the same setup with gold moving the other way ends the
account.

### What was NOT answered

Exness answered the question *"was the close executed correctly?"* — and
demonstrably it was. They did **not** answer *"how did the balance reach
−$264.72 in the first place?"* That is the question that actually matters, and
it is still open. Anyone picking this up later should note:

- The path to a negative balance is unexplained by the email.
- Whether negative-balance protection should have applied, and why the account
  was not stopped out earlier, is unexplained.
- Whether swap on 86 positions held across days contributed is unexplained.
  The Performance page reports "Trading cost 0.00", which is worth probing.

**Do not tell him the matter is settled.** The execution is settled. The
history that produced −$264.72 is not.

---

## 23 September 2026 — the full statement arrived. The −$264.72 is now settled.

Jalal supplied the complete statement for account **252706674** (Standard,
USD, 1:2000), period 13 Aug – 23 Sep 2026. It covers the entire life of that
account. The parsed rows reconcile to the statement's own printed total of
−119.24 exactly, so every number below is the broker's, not an estimate.

### The whole account, in four days

| | |
|---|---|
| Deposit | $706.70 (14 Aug 10:55) |
| Withdrawal | $587.46 (18 Aug 00:45) |
| Closed Trade P/L | **−$119.24** |
| Final balance | $0.00 |
| Trades | 367, on only 4 days (14, 16, 17, 18 Aug) — 271 of them on 17 Aug |
| Win rate | 194/367 = 52.9% |
| Profit factor | 0.944 (gross win $2,011.65, gross loss −$2,130.89) |
| Avg win / avg loss | $10.37 vs −$12.32 (0.84×) |
| Stop loss used | **0 of 367** |
| Take profit used | 4 of 367 |
| Swap | $0.00 |
| Commission | $0.00 |
| Peak balance | **$1,001.78** at 17 Aug 02:59 |

### The minute-by-minute balance on 17 August

Reconstructed by applying each closed trade's profit in close-time order,
starting from the $706.70 deposit:

```
17 Aug 02:59   1,001.78   <- peak, +42% on deposit
17 Aug 12:01     940.58
17 Aug 18:45     746.59
17 Aug 19:52     -81.06   <- first time negative
17 Aug 20:22    -286.55   <- lowest point
17 Aug 20:38    -264.72   <- the figure in his screenshot, to the cent
17 Aug 20:44     651.23   <- the figure in Exness's reply, to the cent
18 Aug 00:06     587.46
18 Aug 00:45       0.00   <- withdrawn
```

Between 18:45 and 20:43 he closed 97 positions one at a time for
−$1,020.93. Seventy-four of those were **sells**: −$1,399.40. Those realised
losses hit balance immediately. The 81 remaining positions were still open
and showing +$885 of *unrealised* profit, which sits only in equity. That is
why the app's headline read +650 while the balance line read −264.72. At
20:44 the basket closed for +$885.42 and balance became $651.23.

**Exness's arithmetic was correct.** Their reply matches the statement to the
cent. The negative balance was real, temporary, and caused by the order in
which positions were closed — not by a broker error.

### What the statement actually says about the method

Exness answered the question he asked. The statement answers the one that
matters more:

- He was **$1,001.78 at 3am on 17 August** — up 42% on a $706.70 deposit —
  and $0 by the next midnight. The account did not die on a bad day. It died
  by giving back a good one.
- Gold rose from about 4372 to 4420 on 17 August, roughly **+$48**. He was
  carrying a stop-less sell ladder into it. Six of the ten largest losses are
  0.01-lot sells opened between 23:55 and 00:11 and held **over 20 hours**
  each, closed −$44 to −$46.
- Losers were held longer than winners here too: 442 min vs 410 min.
- 0 stop losses on 367 trades. Nothing in this account limited a loss except
  his own decision to close.
- Trading cost genuinely was zero. Swap $0.00, commission $0.00 across all
  367 trades. The cost was not the broker.

The Fishing Lots method did not lose to spread, swap, or the broker. At 52.9%
wins and a 0.84 win/loss size ratio, the profit factor is 0.944 — it loses
slowly and by design, and then one un-stopped ladder against a $48 trend
settles it in an evening.

**This matter is now settled, on both sides.** Exness's figures check out,
and the account's own record shows what took the money.

---

## 23 September 2026 — what he worked out for himself

Written down in his words, because the day will come when he needs to read it
back:

> "Ab mujhe poora ehsaas hai is gold aur trading ka — ke profit just
> discipline mein hai."
>
> "Trading mein patience ka khel hai sab. Kahani chhoti hai, bas ruk ruk kar
> sunte jaana hai. Sabr o tehammul. Aur jitni story suni, utna munafa milta
> hai. Lekin jo jaldi mein ho, woh is room mein jaye nahi to acha hai."

His own records back this, twice over.

**The measured timeframe result.** Tested on two unrelated broker feeds, the
same shape appeared both times — the longer the story, the better the outcome:

| Timeframe | Win rate |
|---|---|
| 1M | 37.5% |
| 1H | 42.0% |
| 4H | 43.8% |
| 1D | 49.7% |

**The Standard account.** 52.9% of 367 trades were on the right side. The
reading was not the problem. Profit factor was still 0.944, because there was
not one stop loss in 367 trades, and losers were held longer than winners
(442 min vs 410 min).

### The one correction this needs

His phrase is right but must be aimed correctly, or it becomes the exact habit
that emptied the account. In the Standard account he was *already* patient —
with the wrong thing:

- Winners held **410 minutes**
- Losers held **442 minutes**

Patience with a position that is going your way is the thing that pays. The
same patience applied to one going against you is just an un-stopped loss
waiting on hope. Six of that account's ten largest losses were 0.01-lot sells
held **over 20 hours** into a rising market.

So the rule that follows from his own sentence is:

> **Sit through the whole story while it is being told. Walk out the moment
> the story turns out to be a different one.**

A stop loss is not impatience. It is how you find out the story changed.
