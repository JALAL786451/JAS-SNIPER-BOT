//+------------------------------------------------------------------+
//|                                                JAS_Sniper_EA.mq5 |
//|                    JAS SNIPER BOT — HTF Filter + Engulfing Entry |
//|                                                                  |
//|  MQL5 port of sniper_backtest.pine. Same model:                  |
//|    HTF EMA trend filter -> engulfing entry -> ATR/swing stop     |
//|    -> R-multiple target -> breakeven at 1R -> % risk sizing.     |
//|  Defaults are tuned for XAUUSD on M15/H1 with an H4 filter.      |
//+------------------------------------------------------------------+
#property copyright "JAS-SNIPER-BOT"
#property link      "https://github.com/JALAL786451/JAS-SNIPER-BOT"
#property version   "1.00"

#include <Trade\Trade.mqh>

//--- Stop-loss placement style
enum ENUM_STOP_MODE
  {
   STOP_SWING = 0,  // Swing (low/high of the signal pair)
   STOP_ATR   = 1   // ATR distance from entry
  };

//+------------------------------------------------------------------+
//| Inputs                                                           |
//+------------------------------------------------------------------+
input group "1 - HTF Trend Filter"
input bool            InpUseHTF        = true;        // Enable HTF filter
input ENUM_TIMEFRAMES InpHTF           = PERIOD_H4;   // Higher timeframe
input int             InpHtfEmaLen     = 50;          // HTF EMA length

input group "2 - Engulfing Signal"
input int    InpAtrLen      = 14;    // ATR length
input bool   InpReqBigger   = true;  // Body must exceed previous body
input double InpMinBodyATR  = 0.3;   // Min body size (x ATR), 0 = off

input group "3 - Risk Management"
input ENUM_STOP_MODE InpStopMode   = STOP_SWING; // Stop-loss mode
input double InpSlAtrMult  = 1.5;   // ATR stop multiplier
input double InpSwingBuf   = 0.25;  // Swing stop buffer (x ATR)
input double InpRR         = 2.0;   // Take-profit (R multiple)
input bool   InpUseRiskQty = true;  // Size position by % risk
input double InpRiskPct    = 1.0;   // Risk per trade (% of equity)
input double InpFixedLots  = 0.01;  // Fixed lots (when % sizing is off)
input bool   InpUseBE      = true;  // Move stop to breakeven
input double InpBeTrigR    = 1.0;   // Breakeven trigger (R)

input group "4 - Session Filter (BROKER SERVER TIME)"
input bool InpUseSession = true;  // Trade only inside session
input int  InpSessStart  = 9;     // Session start hour (server time)
input int  InpSessEnd    = 22;    // Session end hour (server time)
input bool InpSkipFriday = false; // Skip Fridays

input group "5 - Execution"
input ulong InpMagic          = 786451; // Magic number
input ulong InpSlippagePoints = 30;     // Max slippage (points)
input int   InpMaxSpreadPts   = 60;     // Max spread to enter (points), 0 = off
input bool  InpVerboseLog     = true;   // Print diagnostics

//+------------------------------------------------------------------+
//| Globals                                                          |
//+------------------------------------------------------------------+
CTrade   g_trade;
int      g_hAtr    = INVALID_HANDLE;
int      g_hHtfEma = INVALID_HANDLE;
datetime g_lastBar = 0;

//+------------------------------------------------------------------+
int OnInit()
  {
   if(InpHtfEmaLen < 2 || InpAtrLen < 1 || InpRR <= 0.0)
     {
      Print("ERROR: invalid input values.");
      return(INIT_PARAMETERS_INCORRECT);
     }

   if(InpUseHTF && PeriodSeconds(InpHTF) <= PeriodSeconds(PERIOD_CURRENT))
     {
      Print("ERROR: the HTF filter must be HIGHER than the chart timeframe. ",
            "Attach this EA to M15 or H1 while the filter stays on H4.");
      return(INIT_PARAMETERS_INCORRECT);
     }

   g_hAtr = iATR(_Symbol, PERIOD_CURRENT, InpAtrLen);
   if(g_hAtr == INVALID_HANDLE)
     {
      Print("ERROR: cannot create ATR handle, code ", GetLastError());
      return(INIT_FAILED);
     }

   if(InpUseHTF)
     {
      g_hHtfEma = iMA(_Symbol, InpHTF, InpHtfEmaLen, 0, MODE_EMA, PRICE_CLOSE);
      if(g_hHtfEma == INVALID_HANDLE)
        {
         Print("ERROR: cannot create HTF EMA handle, code ", GetLastError());
         return(INIT_FAILED);
        }
     }

   g_trade.SetExpertMagicNumber(InpMagic);
   g_trade.SetDeviationInPoints((ulong)InpSlippagePoints);
   g_trade.SetTypeFillingBySymbol(_Symbol);
   g_trade.LogLevel(LOG_LEVEL_ERRORS);

   PrintFormat("JAS Sniper EA ready on %s %s | digits=%d point=%.*f stops_level=%d",
               _Symbol, EnumToString((ENUM_TIMEFRAMES)Period()),
               _Digits, _Digits, _Point,
               (int)SymbolInfoInteger(_Symbol, SYMBOL_TRADE_STOPS_LEVEL));
   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   if(g_hAtr    != INVALID_HANDLE) IndicatorRelease(g_hAtr);
   if(g_hHtfEma != INVALID_HANDLE) IndicatorRelease(g_hHtfEma);
  }

//+------------------------------------------------------------------+
void OnTick()
  {
   ManageOpenPosition();          // breakeven runs on every tick

   datetime bar = iTime(_Symbol, PERIOD_CURRENT, 0);
   if(bar == g_lastBar)           // entries only once per closed bar
      return;
   g_lastBar = bar;

   CheckForEntry();
  }

//+------------------------------------------------------------------+
//| Helpers                                                          |
//+------------------------------------------------------------------+
bool ReadBuffer(const int handle, const int shift, double &value)
  {
   double buf[];
   if(CopyBuffer(handle, 0, shift, 1, buf) < 1)
      return(false);
   value = buf[0];
   return(value != EMPTY_VALUE && value > 0.0);
  }

bool HasOpenPosition()
  {
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      ulong ticket = PositionGetTicket(i);
      if(ticket == 0) continue;
      if(PositionGetString(POSITION_SYMBOL) == _Symbol &&
         PositionGetInteger(POSITION_MAGIC) == (long)InpMagic)
         return(true);
     }
   return(false);
  }

bool InTradingSession()
  {
   if(!InpUseSession)
      return(true);

   MqlDateTime t;
   TimeToStruct(TimeCurrent(), t);              // broker server time

   if(t.day_of_week == 0 || t.day_of_week == 6) // weekend
      return(false);
   if(InpSkipFriday && t.day_of_week == 5)
      return(false);

   if(InpSessStart == InpSessEnd)
      return(true);                             // 24h
   if(InpSessStart < InpSessEnd)
      return(t.hour >= InpSessStart && t.hour < InpSessEnd);
   return(t.hour >= InpSessStart || t.hour < InpSessEnd); // window wraps midnight
  }

bool SpreadOK()
  {
   if(InpMaxSpreadPts <= 0)
      return(true);
   long spread = SymbolInfoInteger(_Symbol, SYMBOL_SPREAD);
   return(spread <= InpMaxSpreadPts);
  }

//--- Broker's minimum stop distance in price units
double MinStopDistance()
  {
   long stopsLevel = SymbolInfoInteger(_Symbol, SYMBOL_TRADE_STOPS_LEVEL);
   double dist = (double)stopsLevel * _Point;
   double spread = (double)SymbolInfoInteger(_Symbol, SYMBOL_SPREAD) * _Point;
   return(MathMax(dist, spread));               // never tighter than the spread
  }

//--- Lots such that a stop-out costs exactly InpRiskPct of equity
double CalculateLots(const double riskDistance)
  {
   if(!InpUseRiskQty)
      return(NormalizeLots(InpFixedLots));
   if(riskDistance <= 0.0)
      return(0.0);

   double tickValue = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);
   double tickSize  = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);
   if(tickValue <= 0.0 || tickSize <= 0.0)
     {
      Print("WARNING: broker tick value/size unavailable, falling back to fixed lots.");
      return(NormalizeLots(InpFixedLots));
     }

   double lossPerLot = (riskDistance / tickSize) * tickValue;
   if(lossPerLot <= 0.0)
      return(0.0);

   double riskCash = AccountInfoDouble(ACCOUNT_EQUITY) * InpRiskPct / 100.0;
   return(NormalizeLots(riskCash / lossPerLot));
  }

double NormalizeLots(const double lots)
  {
   double minLot  = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
   double maxLot  = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX);
   double lotStep = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);
   if(lotStep <= 0.0)
      lotStep = 0.01;

   double v = MathFloor(lots / lotStep) * lotStep;
   v = MathMax(minLot, MathMin(maxLot, v));
   return(NormalizeDouble(v, 2));
  }

//--- Enough free margin for this order?
bool MarginOK(const ENUM_ORDER_TYPE type, const double lots, const double price)
  {
   double margin = 0.0;
   if(!OrderCalcMargin(type, _Symbol, lots, price, margin))
      return(false);
   return(margin < AccountInfoDouble(ACCOUNT_MARGIN_FREE) * 0.9);
  }

//+------------------------------------------------------------------+
//| Entry logic                                                      |
//+------------------------------------------------------------------+
void CheckForEntry()
  {
   if(HasOpenPosition() || !InTradingSession() || !SpreadOK())
      return;
   if(Bars(_Symbol, PERIOD_CURRENT) < InpAtrLen + 5)
      return;

   double atr;
   if(!ReadBuffer(g_hAtr, 1, atr))
      return;

   //--- Bar 1 is the just-closed signal candle, bar 2 the one before it.
   double o1 = iOpen(_Symbol,  PERIOD_CURRENT, 1);
   double c1 = iClose(_Symbol, PERIOD_CURRENT, 1);
   double h1 = iHigh(_Symbol,  PERIOD_CURRENT, 1);
   double l1 = iLow(_Symbol,   PERIOD_CURRENT, 1);
   double o2 = iOpen(_Symbol,  PERIOD_CURRENT, 2);
   double c2 = iClose(_Symbol, PERIOD_CURRENT, 2);
   double h2 = iHigh(_Symbol,  PERIOD_CURRENT, 2);
   double l2 = iLow(_Symbol,   PERIOD_CURRENT, 2);
   if(o1 <= 0.0 || o2 <= 0.0)
      return;

   double body     = MathAbs(c1 - o1);
   double prevBody = MathAbs(c2 - o2);
   bool   bodyOK   = (!InpReqBigger || body > prevBody) &&
                     (InpMinBodyATR <= 0.0 || body >= InpMinBodyATR * atr);

   bool bullEngulf = (c1 > o1) && (c2 < o2) && (c1 >= o2) && (o1 <= c2) && bodyOK;
   bool bearEngulf = (c1 < o1) && (c2 > o2) && (c1 <= o2) && (o1 >= c2) && bodyOK;
   if(!bullEngulf && !bearEngulf)
      return;

   //--- HTF trend: read the LAST CLOSED higher-timeframe bar (shift 1), never the forming one.
   bool htfBull = true, htfBear = true;
   if(InpUseHTF)
     {
      double htfEma;
      if(!ReadBuffer(g_hHtfEma, 1, htfEma))
         return;
      double htfClose = iClose(_Symbol, InpHTF, 1);
      if(htfClose <= 0.0)
         return;
      htfBull = (htfClose > htfEma);
      htfBear = (htfClose < htfEma);
     }

   if(bullEngulf && htfBull)
      OpenTrade(ORDER_TYPE_BUY, atr, l1, l2, h1, h2);
   else if(bearEngulf && htfBear)
      OpenTrade(ORDER_TYPE_SELL, atr, l1, l2, h1, h2);
  }

//+------------------------------------------------------------------+
void OpenTrade(const ENUM_ORDER_TYPE type, const double atr,
               const double l1, const double l2,
               const double h1, const double h2)
  {
   bool   isBuy = (type == ORDER_TYPE_BUY);
   double entry = isBuy ? SymbolInfoDouble(_Symbol, SYMBOL_ASK)
                        : SymbolInfoDouble(_Symbol, SYMBOL_BID);
   if(entry <= 0.0)
      return;

   double sl;
   if(InpStopMode == STOP_ATR)
      sl = isBuy ? entry - atr * InpSlAtrMult : entry + atr * InpSlAtrMult;
   else
      sl = isBuy ? MathMin(l1, l2) - atr * InpSwingBuf
                 : MathMax(h1, h2) + atr * InpSwingBuf;

   double risk = isBuy ? (entry - sl) : (sl - entry);
   if(risk <= 0.0)
     {
      if(InpVerboseLog) Print("Signal skipped: stop would sit on the wrong side of price.");
      return;
     }

   //--- Respect the broker's minimum stop distance; widen and keep the R ratio intact.
   double minDist = MinStopDistance();
   if(risk < minDist)
     {
      risk = minDist;
      sl   = isBuy ? entry - risk : entry + risk;
     }

   double tp   = isBuy ? entry + risk * InpRR : entry - risk * InpRR;
   double lots = CalculateLots(risk);
   if(lots <= 0.0)
     {
      Print("Signal skipped: calculated lot size is zero. Equity ",
            AccountInfoDouble(ACCOUNT_EQUITY), ", risk distance ", risk);
      return;
     }
   if(!MarginOK(type, lots, entry))
     {
      Print("Signal skipped: not enough free margin for ", lots, " lots.");
      return;
     }

   sl = NormalizeDouble(sl, _Digits);
   tp = NormalizeDouble(tp, _Digits);

   bool ok = isBuy ? g_trade.Buy(lots, _Symbol, 0.0, sl, tp, "JAS Sniper")
                   : g_trade.Sell(lots, _Symbol, 0.0, sl, tp, "JAS Sniper");

   if(!ok)
      PrintFormat("Order FAILED: retcode=%d (%s)", g_trade.ResultRetcode(),
                  g_trade.ResultRetcodeDescription());
   else if(InpVerboseLog)
      PrintFormat("%s %.2f lots @ %.*f | SL %.*f | TP %.*f | risk %.*f (%.2f%% equity)",
                  isBuy ? "BUY" : "SELL", lots, _Digits, entry,
                  _Digits, sl, _Digits, tp, _Digits, risk, InpRiskPct);
  }

//+------------------------------------------------------------------+
//| Breakeven management                                             |
//+------------------------------------------------------------------+
void ManageOpenPosition()
  {
   if(!InpUseBE)
      return;

   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      ulong ticket = PositionGetTicket(i);
      if(ticket == 0) continue;
      if(PositionGetString(POSITION_SYMBOL) != _Symbol) continue;
      if(PositionGetInteger(POSITION_MAGIC) != (long)InpMagic) continue;

      double entry = PositionGetDouble(POSITION_PRICE_OPEN);
      double sl    = PositionGetDouble(POSITION_SL);
      double tp    = PositionGetDouble(POSITION_TP);
      if(tp <= 0.0)
         continue;

      //--- Recover the original 1R distance from the target, so a restarted
      //--- EA still knows where breakeven sits.
      double initRisk = MathAbs(tp - entry) / InpRR;
      if(initRisk <= 0.0)
         continue;

      long   type    = PositionGetInteger(POSITION_TYPE);
      bool   isBuy   = (type == POSITION_TYPE_BUY);
      double current = isBuy ? SymbolInfoDouble(_Symbol, SYMBOL_BID)
                             : SymbolInfoDouble(_Symbol, SYMBOL_ASK);
      double minDist = MinStopDistance();

      if(isBuy)
        {
         if(sl >= entry) continue;                                  // already at/above BE
         if(current < entry + initRisk * InpBeTrigR) continue;       // not 1R yet
         if(current - entry < minDist) continue;                     // too close to modify
         if(g_trade.PositionModify(ticket, NormalizeDouble(entry, _Digits), tp) && InpVerboseLog)
            Print("Stop moved to breakeven on ticket ", ticket);
        }
      else
        {
         if(sl > 0.0 && sl <= entry) continue;
         if(current > entry - initRisk * InpBeTrigR) continue;
         if(entry - current < minDist) continue;
         if(g_trade.PositionModify(ticket, NormalizeDouble(entry, _Digits), tp) && InpVerboseLog)
            Print("Stop moved to breakeven on ticket ", ticket);
        }
     }
  }
//+------------------------------------------------------------------+
