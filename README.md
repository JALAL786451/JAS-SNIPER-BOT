# JAS-SNIPER-BOT

XAUUSD (Gold) scalping bot — MTF wick/FVG zones + retest + MA trend confirm.

## Files

| File | Type | Kaam |
|---|---|---|
| `xauusd_scalper_v2.pine` | `indicator()` | Chart par zones + BUY/SELL signals + TP/SL boxes dikhata hai |
| `xauusd_scalper_v2_strategy.pine` | `strategy()` | Wahi logic, magar Strategy Tester mein backtest hota hai |
| `sniper_backtest.pine` | `strategy()` | Purana simple SMA 14/28 crossover test |

## Logic

```
15M ki pichli candle ke wick / FVG   ->  zone
Price zone mein wapas aaye           ->  retest
15M + 5M dono MA20/MA50 se confirm   ->  trend
1M ka unfilled wick touch + rejection close  ->  ENTRY
Exit: SL zone ke paar, TP = SL x Risk:Reward
```

Chart **1M** par rakhein.

## Chart par kaun sa box kya hai

| Box | Matlab |
|---|---|
| **Light YELLOW** | Bullish zone — 15M wick ya FVG. Yahan price wapas aaye to BUY dhoondte hain |
| **Light BLUE** | Bearish zone — 15M wick ya FVG. Yahan SELL dhoondte hain |
| **Green** | TP zone — entry se target tak |
| **Red** | SL zone — entry se stop tak |

Har box par uska naam likha hota hai (`15M WICK ▲ BUY zone` waghera), to guess karne ki zaroorat nahi.

**Zone box candle se chhota kyun hota hai?** Zone poori candle ka nahi banta — sirf **wick** ya **FVG gap** wale hisse ka banta hai. Is liye lambi candle box se bahar nikalti nazar aati hai. Ye normal hai.

## Settings

Sirf 3 — baaqi sab ATR (volatility) se khud adjust hota hai:

1. **Sensitivity** — `Conservative` / `Balanced` / `Aggressive`. Zone kitna bara ho aur rejection kitni strong chahiye
2. **Risk : Reward** — TP = SL ka itna guna (default 2.0)
3. **Session filter** — `Off` / `London only` / `NY only` / `London + NY`

Strategy file mein extra: risk per trade (% equity), date range, ek waqt mein 1 trade.

## Backtest karte waqt

Strategy Tester ke **Properties** tab mein Commission aur Slippage zaroor set karein. 1M scalping par spread ignore karein to results jhoot bolte hain.

## Repaint

`request.security()` har jagah `[1]` offset ke sath hai — sirf **confirmed** HTF candle use hoti hai, is liye signals repaint nahi karte.
