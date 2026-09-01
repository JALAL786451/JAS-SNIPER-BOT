//+------------------------------------------------------------------+
//|                                          TrendMomentumEA.mq5     |
//|  Simple, single-concept EA: EMA Trend + Tick-Volume Momentum     |
//|                                                                  |
//|  LOGIC (as agreed):                                              |
//|   1) Trend filter  -> price vs EMA(50) decides bias (buy/sell)   |
//|   2) Momentum confirm -> tick-volume spike + strong candle body  |
//|   3) Entry only when both align                                  |
//|   4) Fixed lot, fixed SL/TP, max 1 open trade, max daily loss cap|
//|   5) NO grid / NO martingale / NO hedging                        |
//|                                                                  |
//|  v1.01 fixes (logic waisi hi hai, sirf bugs theek kiye):         |
//|   - EMA handle ab sirf ek dafa banta hai (har tick par nahi)     |
//|   - Open trades ginte waqt symbol bhi check hota hai             |
//|   - Attach wale bar par turant trade nahi khulti                 |
//|   - SL/TP broker ki minimum distance se check hote hain          |
//|   - Filling mode + slippage set, aur trading-allowed check       |
//+------------------------------------------------------------------+
#property copyright "Built per user spec"
#property version   "1.01"
#property strict

#include <Trade\Trade.mqh>
CTrade trade;

//--------------------------- INPUT PARAMETERS ------------------------
input group "=== Trade Basics ==="
input double InpLotSize            = 0.01;    // Fixed lot size
input int    InpSL_Points          = 300;     // Stop Loss in points
input int    InpTP_Points          = 450;     // Take Profit in points (>= 1.5x SL suggested)
input int    InpSlippagePoints     = 50;      // Max allowed slippage (points)
input int    InpMagicNumber        = 20260901;// Magic number

input group "=== Trend Filter ==="
input int    InpEmaPeriod          = 50;      // EMA period for trend bias
input ENUM_TIMEFRAMES InpTrendTF   = PERIOD_M15; // Timeframe used for trend bias

input group "=== Momentum / Volume Confirmation ==="
input int    InpVolLookback        = 20;      // Bars used to compute average tick volume
input double InpVolSpikeMultiplier = 1.5;     // Current volume must exceed avg * this multiplier
input double InpMinBodyPercent     = 60.0;    // Candle body must be >= this % of its full range
input ENUM_TIMEFRAMES InpEntryTF   = PERIOD_M5;  // Timeframe used for entry confirmation

input group "=== Risk Management (hard limits) ==="
input double InpMaxDailyLossUSD    = 20.0;    // Stop trading for the day after this loss
input int    InpMaxOpenTrades      = 1;       // Max concurrent trades from this EA
input int    InpMaxTradesPerDay    = 5;       // Max new trades opened per day

input group "=== Session Filter (optional, server time) ==="
input bool   InpUseSessionFilter   = false;   // Enable/disable session restriction
input int    InpSessionStartHour   = 7;       // Server hour to start trading
input int    InpSessionEndHour     = 20;      // Server hour to stop trading

//--------------------------- GLOBAL STATE -----------------------------
datetime g_currentDay      = 0;
double   g_dayStartEquity  = 0.0;
int      g_tradesToday     = 0;
bool     g_dailyLossHit    = false;

int      g_emaHandle       = INVALID_HANDLE;  // ek dafa banta hai, har tick par nahi
datetime g_lastBarTime     = 0;
bool     g_skipFirstBar    = true;            // attach wale bar par signal nahi

//+------------------------------------------------------------------+
int OnInit()
  {
   trade.SetExpertMagicNumber(InpMagicNumber);
   trade.SetDeviationInPoints(InpSlippagePoints);
   trade.SetTypeFillingBySymbol(_Symbol);
   trade.LogLevel(LOG_LEVEL_ERRORS);

   //--- EMA handle sirf yahan banega, aur OnDeinit mein release hoga
   g_emaHandle = iMA(_Symbol, InpTrendTF, InpEmaPeriod, 0, MODE_EMA, PRICE_CLOSE);
   if(g_emaHandle == INVALID_HANDLE)
     {
      Print("EMA handle nahi bana. Error=", GetLastError());
      return(INIT_FAILED);
     }

   if(InpVolLookback < 2)
     {
      Print("InpVolLookback kam se kam 2 hona chahiye.");
      return(INIT_FAILED);
     }

   CheckStopDistances();

   if(!MQLInfoInteger(MQL_TRADE_ALLOWED))
      Print("Khabardar: terminal mein Algo Trading button band hai.");
   if(!AccountInfoInteger(ACCOUNT_TRADE_EXPERT))
      Print("Khabardar: is account par algo trading server side band hai.");

   ResetDailyState();
   Print("TrendMomentumEA initialized. Magic=", InpMagicNumber);
   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   if(g_emaHandle != INVALID_HANDLE)
      IndicatorRelease(g_emaHandle);
   Print("TrendMomentumEA deinitialized. Reason=", reason);
  }

//+------------------------------------------------------------------+
//| Broker ki minimum stop distance (price mein)                      |
//+------------------------------------------------------------------+
double MinStopDistance()
  {
   double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
   double stops = (double)SymbolInfoInteger(_Symbol, SYMBOL_TRADE_STOPS_LEVEL)  * point;
   double freez = (double)SymbolInfoInteger(_Symbol, SYMBOL_TRADE_FREEZE_LEVEL) * point;
   return(MathMax(stops, freez));
  }

//+------------------------------------------------------------------+
//| Init par bata do ke SL/TP broker ke hisaab se chalenge ya nahi    |
//+------------------------------------------------------------------+
void CheckStopDistances()
  {
   double point  = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
   int    digits = (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS);
   double minD   = MinStopDistance();
   double slDist = InpSL_Points * point;
   double tpDist = InpTP_Points * point;

   PrintFormat("%s: digits=%d point=%.5f | SL %d points = %.2f | TP %d points = %.2f | broker minimum = %.2f",
               _Symbol, digits, point,
               InpSL_Points, slDist, InpTP_Points, tpDist, minD);

   if(minD > 0.0 && (slDist < minD || tpDist < minD))
     {
      int needPoints = (int)MathCeil(minD / point);
      PrintFormat("KHABARDAR: SL/TP broker ki minimum distance (%d points) se chhote hain. "
                  "EA khud barha dega, magar behtar hai aap InpSL_Points ko %d se upar rakhein.",
                  needPoints, needPoints);
      Alert("TrendMomentumEA: SL/TP bohot chhote hain. Kam se kam ", needPoints, " points rakhein.");
     }
  }

//+------------------------------------------------------------------+
//| Reset daily counters when a new trading day starts                |
//+------------------------------------------------------------------+
void ResetDailyState()
  {
   MqlDateTime dt;
   TimeToStruct(TimeCurrent(), dt);
   dt.hour = 0; dt.min = 0; dt.sec = 0;
   datetime today = StructToTime(dt);

   if(today != g_currentDay)
     {
      g_currentDay     = today;
      g_dayStartEquity = AccountInfoDouble(ACCOUNT_EQUITY);
      g_tradesToday    = 0;
      g_dailyLossHit   = false;
      Print("New trading day detected. Start equity=", g_dayStartEquity);
     }
  }

//+------------------------------------------------------------------+
//| Check daily loss limit                                            |
//+------------------------------------------------------------------+
bool DailyLossLimitReached()
  {
   double currentEquity = AccountInfoDouble(ACCOUNT_EQUITY);
   double lossSoFar = g_dayStartEquity - currentEquity;

   if(lossSoFar >= InpMaxDailyLossUSD)
     {
      if(!g_dailyLossHit)
         Print("MAX DAILY LOSS HIT. Loss so far=", lossSoFar, " Limit=", InpMaxDailyLossUSD, ". No new trades today.");
      g_dailyLossHit = true;
      return(true);
     }
   return(false);
  }

//+------------------------------------------------------------------+
//| Session filter check                                              |
//+------------------------------------------------------------------+
bool WithinSession()
  {
   if(!InpUseSessionFilter) return(true);

   MqlDateTime dt;
   TimeToStruct(TimeCurrent(), dt);

   if(InpSessionStartHour <= InpSessionEndHour)
      return(dt.hour >= InpSessionStartHour && dt.hour < InpSessionEndHour);
   else // session wraps midnight
      return(dt.hour >= InpSessionStartHour || dt.hour < InpSessionEndHour);
  }

//+------------------------------------------------------------------+
//| Count open trades placed by this EA on THIS symbol                |
//+------------------------------------------------------------------+
int CountOpenTrades()
  {
   int count = 0;
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      ulong ticket = PositionGetTicket(i);
      if(ticket == 0) continue;
      if(PositionGetString(POSITION_SYMBOL) != _Symbol) continue;
      if(PositionGetInteger(POSITION_MAGIC) != InpMagicNumber) continue;
      count++;
     }
   return(count);
  }

//+------------------------------------------------------------------+
//| STEP 1: Trend bias from EMA on InpTrendTF                         |
//| Returns: 1 = buy bias, -1 = sell bias, 0 = no bias                |
//+------------------------------------------------------------------+
int GetTrendBias()
  {
   if(g_emaHandle == INVALID_HANDLE) return(0);

   double emaBuf[];
   ArraySetAsSeries(emaBuf, true);
   if(CopyBuffer(g_emaHandle, 0, 0, 1, emaBuf) < 1)
     {
      Print("EMA buffer copy fail. Error=", GetLastError());
      return(0);
     }
   double ema = emaBuf[0];
   if(ema <= 0.0) return(0);

   double close = iClose(_Symbol, InpTrendTF, 0);
   if(close <= 0.0) return(0);

   if(close > ema) return(1);   // buy bias
   if(close < ema) return(-1);  // sell bias
   return(0);
  }

//+------------------------------------------------------------------+
//| STEP 2: Momentum confirmation on InpEntryTF                       |
//| Checks: last CLOSED candle has volume spike + strong body,        |
//| and candle direction matches requested bias direction              |
//+------------------------------------------------------------------+
bool MomentumConfirms(int biasDirection)
  {
   long volArr[];
   ArraySetAsSeries(volArr, true);
   if(CopyTickVolume(_Symbol, InpEntryTF, 1, InpVolLookback + 1, volArr) < InpVolLookback + 1)
      return(false);

   long currentVol = volArr[0];
   long sumVol = 0;
   for(int i = 1; i <= InpVolLookback; i++)
      sumVol += volArr[i];
   double avgVol = (double)sumVol / InpVolLookback;

   if(avgVol <= 0) return(false);
   bool volumeSpike = ((double)currentVol >= avgVol * InpVolSpikeMultiplier);

   double open  = iOpen(_Symbol, InpEntryTF, 1);
   double close = iClose(_Symbol, InpEntryTF, 1);
   double high  = iHigh(_Symbol, InpEntryTF, 1);
   double low   = iLow(_Symbol, InpEntryTF, 1);

   double range = high - low;
   if(range <= 0) return(false);

   double body = MathAbs(close - open);
   double bodyPercent = (body / range) * 100.0;
   bool strongBody = (bodyPercent >= InpMinBodyPercent);

   bool candleBullish = (close > open);
   bool candleBearish = (close < open);

   bool directionMatches = false;
   if(biasDirection == 1 && candleBullish) directionMatches = true;
   if(biasDirection == -1 && candleBearish) directionMatches = true;

   if(volumeSpike && strongBody && directionMatches)
     {
      PrintFormat("Momentum confirmed: dir=%d vol=%I64d avgVol=%.1f bodyPct=%.1f",
                  biasDirection, currentVol, avgVol, bodyPercent);
      return(true);
     }
   return(false);
  }

//+------------------------------------------------------------------+
//| Place the trade with fixed SL/TP                                  |
//+------------------------------------------------------------------+
void ExecuteTrade(int direction)
  {
   double point  = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
   int    digits = (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS);

   double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   if(ask <= 0.0 || bid <= 0.0)
     {
      Print("Price nahi mila, trade skip.");
      return;
     }

   //--- SL/TP broker ki minimum distance se chhote na hon
   double minD   = MinStopDistance();
   double slDist = InpSL_Points * point;
   double tpDist = InpTP_Points * point;
   if(minD > 0.0)
     {
      if(slDist < minD) slDist = minD;
      if(tpDist < minD) tpDist = minD;
     }

   double sl = 0.0, tp = 0.0, price = 0.0;
   bool ok = false;

   if(direction == 1) // BUY
     {
      price = ask;
      sl = NormalizeDouble(price - slDist, digits);
      tp = NormalizeDouble(price + tpDist, digits);
      ok = trade.Buy(InpLotSize, _Symbol, 0.0, sl, tp, "TrendMomentumEA");
     }
   else if(direction == -1) // SELL
     {
      price = bid;
      sl = NormalizeDouble(price + slDist, digits);
      tp = NormalizeDouble(price - tpDist, digits);
      ok = trade.Sell(InpLotSize, _Symbol, 0.0, sl, tp, "TrendMomentumEA");
     }
   else
      return;

   if(ok)
     {
      g_tradesToday++;
      PrintFormat("Trade opened. dir=%d price=%.*f sl=%.*f tp=%.*f tradesToday=%d",
                  direction, digits, price, digits, sl, digits, tp, g_tradesToday);
     }
   else
     {
      PrintFormat("Trade FAILED. dir=%d retcode=%d (%s)",
                  direction, trade.ResultRetcode(), trade.ResultRetcodeDescription());
     }
  }

//+------------------------------------------------------------------+
//| Main tick handler                                                  |
//+------------------------------------------------------------------+
void OnTick()
  {
   ResetDailyState();

   //--- sirf naye bar par kaam karo
   datetime currentBarTime = iTime(_Symbol, InpEntryTF, 0);
   if(currentBarTime == 0 || currentBarTime == g_lastBarTime)
      return;
   g_lastBarTime = currentBarTime;

   //--- attach wale pehle bar par signal nahi (adhoora data)
   if(g_skipFirstBar)
     {
      g_skipFirstBar = false;
      return;
     }

   if(!MQLInfoInteger(MQL_TRADE_ALLOWED))
      return;

   if(DailyLossLimitReached())
      return;

   if(!WithinSession())
      return;

   if(g_tradesToday >= InpMaxTradesPerDay)
      return;

   if(CountOpenTrades() >= InpMaxOpenTrades)
      return;

   int bias = GetTrendBias();
   if(bias == 0)
      return;

   if(!MomentumConfirms(bias))
      return;

   ExecuteTrade(bias);
  }
//+------------------------------------------------------------------+
