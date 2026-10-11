# JAS RSI2 — naqsha (11 Oct 2026 raat, user ke "D" se pehle)

User: "Ek aur sahi, hamara kaam karte rehna hai - universal ya scalping."
Claude ka faisla: scalping nahi (gold par spread $0.20-0.30 chhote target
ka bara hissa kha jata hai; gold par 6 intraday koshishein manfi/sifar).
Universal + chhoti muddat wala, mashhoor aur likha hua idea:

## Idea: Connors RSI(2)

Larry Connors & Cesar Alvarez, "Short Term Trading Strategies That Work"
(2008). Soch: bare rukh ke andar 2-3 din ki tez girawat aksar wapas aati
hai. Kachhue ka ulat (wahan toot ke saath, yahan girawat ke khilaf, magar
bare rukh ke saath). Har market par wohi qaide.

| # | Qaida |
|---|---|
| 1 | **Rukh:** daily close SMA(200) ke upar = sirf BUY; neeche = sirf SELL |
| 2 | **Entry:** RSI(2) < 10 par daily close par BUY; RSI(2) > 90 par SELL |
| 3 | **Band:** BUY: close SMA(5) ke upar; SELL: close SMA(5) ke neeche (daily close par) |
| 4 | **SL (hifazat - asal kitaab mein nahi):** entry se 3 x ATR(14). Ye faasla = 1R, risk 1% |
| 5 | Ek position, koi averaging / add nahi |
| 6 | Kharcha 0.01% har taraf. Swap nahi gina (do-teen din ki trade) |

## Test: TradingView Pine strategy, 1D (daily data purana milta hai)

Markets: (a) **XAUUSD** - user ka market; (b) **OANDA:SPX500USD** -
Connors ka asal market (S&P 500). Table mein daur rows (1970-99 / 2000-18 /
2019-aaj) Tide tester jaisi, Exp ± 2SE.

## PEHLE SE LIKHA QAIDA (sakht - ye 7wi koshish hai, badalna mana)

Har market alag, **2000 se aaj tak**:
- trades >= 100, AUR
- **Exp - 2SE > 0**, AUR
- **2000-2018 aur 2019-aaj dono daur mein Exp > 0**.

Teeno = PASS (sirf us market ka demo). Warna FAIL. Settings ghuma kar
dobara nahi. Do market = do mauqe - is liye daur wali shart sakht rakhi.

## Imaandari

Kitaab ke number zyada tar US stocks / S&P par hain; gold par is ka koi
pakka saboot mujhe maloom nahi. Trades Kachhue se zyada (shayad mahine mein
1-2), magar roz nahi.
