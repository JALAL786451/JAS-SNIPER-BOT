//+------------------------------------------------------------------+
//| HedgeBasketEA.mq5                                                |
//|                                                                   |
//| Hedge-account basket EA.                                          |
//|                                                                   |
//| Every order goes out with SL = 0 and TP = 0. There is no          |
//| PositionModify anywhere in this file, so no stop or target is     |
//| ever attached after the fact either. Profit and loss are judged   |
//| ONLY across the whole basket: every open position on the traded   |
//| symbol carrying this EA's magic number.                           |
//|                                                                   |
//| No breakeven. No trailing. No scalping logic. No indicators.      |
//| Lot growth is off by default: InpLotMultiplier is 1.0, so every   |
//| level is the same size until you change it yourself.              |
//+------------------------------------------------------------------+
#property copyright "HedgeBasketEA"
#property version   "1.00"
#property strict

#include <Trade\Trade.mqh>
CTrade trade;

//+------------------------------------------------------------------+
//| Inputs                                                            |
//+------------------------------------------------------------------+
enum ENUM_FIRST_DIR
{
   FIRST_BUY  = 0,   // BUY
   FIRST_SELL = 1    // SELL
};

input group "=== Symbol and identity ==="
input string InpSymbol              = "XAUUSD";   // Symbol to trade. Leave EMPTY to use the chart's symbol
input long   InpMagic               = 909001;     // Magic number
input string InpComment             = "HedgeBasket";

input group "=== Sizing ==="
input double InpLot                 = 0.01;       // First lot
input double InpLotMultiplier       = 1.0;        // 1.0 = every level the same size. Above 1.0 IS martingale
input double InpMaxLot              = 0.10;       // Refuse any single order larger than this
input int    InpMaxPositions        = 6;          // Refuse to open past this many open positions

input group "=== Grid ==="
input ENUM_FIRST_DIR InpFirstDirection = FIRST_BUY;   // Direction of the very first trade
input int    InpHedgeDistancePoints = 200;        // Points against the LAST entry before the opposite side opens

input group "=== Basket exits (the only exits that exist) ==="
input double InpTargetProfitMoney   = 1.0;        // Close the whole basket at this profit, account currency
input double InpMaxBasketLossMoney  = 20.0;       // Close the whole basket at this loss, then stop for the day

input group "=== Execution ==="
input int    InpMaxSpreadPoints     = 50;         // Refuse to open while the spread is wider than this
input ulong  InpSlippagePoints      = 30;         // Max deviation
input bool   InpTradeOnFriday       = true;       // false = open nothing on Friday. Open baskets are still managed

//+------------------------------------------------------------------+
//| Globals                                                           |
//+------------------------------------------------------------------+
string   gSym          = "";
double   gPoint        = 0.0;
int      gDigits       = 0;
double   gTickSize     = 0.0;
double   gVolMin       = 0.0;
double   gVolMax       = 0.0;
double   gVolStep      = 0.0;
bool     gInitFailed   = false;

bool     gHalted       = false;   // set after a max-loss close, cleared on a new broker day
int      gHaltDay      = -1;
int      gHaltMonth    = -1;
int      gHaltYear     = -1;

ENUM_ORDER_TYPE_FILLING gFilling = ORDER_FILLING_IOC;

// Commission lives on deals, not on positions, so it is summed from
// history once per position and then cached.
ulong    gCommTicket[];
double   gCommValue[];

//+------------------------------------------------------------------+
//| Small helpers                                                     |
//+------------------------------------------------------------------+
void Log(string msg) { Print("[HedgeBasket] ", msg); }

double NormalizePrice(double price)
{
   if(gTickSize > 0.0) price = MathRound(price / gTickSize) * gTickSize;
   return NormalizeDouble(price, gDigits);
}

double NormalizeLots(double lots)
{
   double step = (gVolStep > 0.0) ? gVolStep : 0.01;
   double v    = MathFloor(lots / step + 0.5) * step;
   if(v < gVolMin) v = gVolMin;
   if(gVolMax > 0.0 && v > gVolMax) v = gVolMax;

   int d = 0;
   double t = step;
   while(t < 1.0 && d < 8) { t *= 10.0; d++; }
   return NormalizeDouble(v, d);
}

int SpreadPoints()
{
   return (int)SymbolInfoInteger(gSym, SYMBOL_SPREAD);
}

bool IsFridayNow()
{
   MqlDateTime dt;
   TimeToStruct(TimeCurrent(), dt);
   return (dt.day_of_week == 5);
}

//+------------------------------------------------------------------+
//| Commission for one position, summed from its deals and cached    |
//+------------------------------------------------------------------+
double CommissionFor(ulong posTicket)
{
   int n = ArraySize(gCommTicket);
   for(int i = 0; i < n; i++)
      if(gCommTicket[i] == posTicket) return gCommValue[i];

   long   posID = PositionGetInteger(POSITION_IDENTIFIER);
   double comm  = 0.0;

   if(HistorySelectByPosition(posID))
   {
      int deals = HistoryDealsTotal();
      for(int i = 0; i < deals; i++)
      {
         ulong d = HistoryDealGetTicket(i);
         if(d > 0) comm += HistoryDealGetDouble(d, DEAL_COMMISSION);
      }
   }

   ArrayResize(gCommTicket, n + 1);
   ArrayResize(gCommValue,  n + 1);
   gCommTicket[n] = posTicket;
   gCommValue[n]  = comm;
   return comm;
}

void PruneCommissionCache()
{
   int n = ArraySize(gCommTicket);
   if(n == 0) return;

   ulong  kt[];
   double kv[];
   int    k = 0;

   for(int i = 0; i < n; i++)
   {
      if(PositionSelectByTicket(gCommTicket[i]))
      {
         ArrayResize(kt, k + 1);
         ArrayResize(kv, k + 1);
         kt[k] = gCommTicket[i];
         kv[k] = gCommValue[i];
         k++;
      }
   }
   ArrayResize(gCommTicket, k);
   ArrayResize(gCommValue,  k);
   for(int i = 0; i < k; i++) { gCommTicket[i] = kt[i]; gCommValue[i] = kv[i]; }
}

//+------------------------------------------------------------------+
//| Is this selected position one of ours?                            |
//+------------------------------------------------------------------+
bool IsOurs()
{
   if(PositionGetString(POSITION_SYMBOL) != gSym) return false;
   return (PositionGetInteger(POSITION_MAGIC) == InpMagic);
}

//+------------------------------------------------------------------+
//| Basket state, gathered in one pass                                |
//+------------------------------------------------------------------+
void BasketState(int &count, double &buyLots, double &sellLots, double &profit,
                 double &lastEntry, long &lastType)
{
   count = 0; buyLots = 0.0; sellLots = 0.0; profit = 0.0;
   lastEntry = 0.0; lastType = -1;
   long newest = 0;

   for(int i = PositionsTotal() - 1; i >= 0; i--)
   {
      ulong ticket = PositionGetTicket(i);
      if(ticket == 0) continue;
      if(!PositionSelectByTicket(ticket)) continue;
      if(!IsOurs()) continue;

      long   type = PositionGetInteger(POSITION_TYPE);
      double vol  = PositionGetDouble(POSITION_VOLUME);

      // profit + swap first, then commission (which touches history selection)
      double p = PositionGetDouble(POSITION_PROFIT) + PositionGetDouble(POSITION_SWAP);
      p += CommissionFor(ticket);
      profit += p;

      if(type == POSITION_TYPE_BUY) buyLots += vol; else sellLots += vol;

      long t = (long)PositionGetInteger(POSITION_TIME_MSC);
      if(t >= newest)
      {
         newest    = t;
         lastEntry = PositionGetDouble(POSITION_PRICE_OPEN);
         lastType  = type;
      }
      count++;
   }
}

//+------------------------------------------------------------------+
//| Sending, with the retcode printed every time and a filling-mode  |
//| fallback if the broker rejects the one detected at init.         |
//+------------------------------------------------------------------+
bool SendMarket(bool isBuy, double lots)
{
   ENUM_ORDER_TYPE_FILLING modes[3];
   modes[0] = gFilling;
   modes[1] = (gFilling == ORDER_FILLING_IOC) ? ORDER_FILLING_FOK : ORDER_FILLING_IOC;
   modes[2] = ORDER_FILLING_RETURN;

   for(int m = 0; m < 3; m++)
   {
      trade.SetTypeFilling(modes[m]);

      double price = isBuy ? SymbolInfoDouble(gSym, SYMBOL_ASK)
                           : SymbolInfoDouble(gSym, SYMBOL_BID);
      price = NormalizePrice(price);

      // SL and TP are hard zeros. They are never set here and never added later.
      bool ok = isBuy ? trade.Buy (lots, gSym, price, 0.0, 0.0, InpComment)
                      : trade.Sell(lots, gSym, price, 0.0, 0.0, InpComment);

      uint rc = trade.ResultRetcode();
      Log(StringFormat("%s %.2f lots @ %s  ->  retcode=%u (%s)  filling=%s",
                       isBuy ? "BUY" : "SELL", lots,
                       DoubleToString(price, gDigits), rc,
                       trade.ResultRetcodeDescription(),
                       EnumToString(modes[m])));

      if(ok) { gFilling = modes[m]; return true; }

      // 10030 is "unsupported filling mode". Anything else is a real refusal.
      if(rc != TRADE_RETCODE_INVALID_FILL) return false;
      Log("Filling mode rejected, trying the next one.");
   }
   return false;
}

//+------------------------------------------------------------------+
//| Close the ENTIRE basket. Never one side, never one leg.          |
//+------------------------------------------------------------------+
void CloseBasket(string why)
{
   Log("=== CLOSING WHOLE BASKET: " + why + " ===");

   for(int pass = 0; pass < 3; pass++)
   {
      bool any = false;
      for(int i = PositionsTotal() - 1; i >= 0; i--)
      {
         ulong ticket = PositionGetTicket(i);
         if(ticket == 0) continue;
         if(!PositionSelectByTicket(ticket)) continue;
         if(!IsOurs()) continue;

         any = true;
         bool ok = trade.PositionClose(ticket, InpSlippagePoints);
         Log(StringFormat("close #%I64u -> retcode=%u (%s)",
                          ticket, trade.ResultRetcode(),
                          trade.ResultRetcodeDescription()));
         if(!ok) Log("close failed, will retry");
      }
      if(!any) break;
   }
}

//+------------------------------------------------------------------+
//| Halt handling. A max-loss close stops trading until the broker's |
//| date rolls over, or until the EA is taken off and put back on.   |
//+------------------------------------------------------------------+
void SetHalted()
{
   MqlDateTime dt;
   TimeToStruct(TimeCurrent(), dt);
   gHalted    = true;
   gHaltDay   = dt.day;
   gHaltMonth = dt.mon;
   gHaltYear  = dt.year;
   Log("Trading halted for the rest of the broker day.");
}

void ClearHaltOnNewDay()
{
   if(!gHalted) return;
   MqlDateTime dt;
   TimeToStruct(TimeCurrent(), dt);
   if(dt.day != gHaltDay || dt.mon != gHaltMonth || dt.year != gHaltYear)
   {
      gHalted = false;
      Log("New broker day. Trading resumed.");
   }
}

//+------------------------------------------------------------------+
//| Init                                                              |
//+------------------------------------------------------------------+
int OnInit()
{
   gInitFailed = false;

   //--- symbol
   gSym = (StringLen(InpSymbol) > 0) ? InpSymbol : _Symbol;

   if(!SymbolSelect(gSym, true))
   {
      Log("Symbol " + gSym + " could not be selected in Market Watch.");
      gInitFailed = true;
      return(INIT_FAILED);
   }

   //--- hedge account, the one hard requirement
   ENUM_ACCOUNT_MARGIN_MODE mm =
      (ENUM_ACCOUNT_MARGIN_MODE)AccountInfoInteger(ACCOUNT_MARGIN_MODE);
   if(mm != ACCOUNT_MARGIN_MODE_RETAIL_HEDGING)
   {
      Print("This EA needs a HEDGE account.");
      gInitFailed = true;
      return(INIT_FAILED);
   }

   //--- trading permissions
   if(!AccountInfoInteger(ACCOUNT_TRADE_ALLOWED))
   {
      Log("Trading is not allowed on this account.");
      gInitFailed = true;
      return(INIT_FAILED);
   }
   if(!MQLInfoInteger(MQL_TRADE_ALLOWED))
   {
      Log("Algo Trading is off. Turn on the Algo Trading button in the terminal.");
      gInitFailed = true;
      return(INIT_FAILED);
   }
   long tradeMode = SymbolInfoInteger(gSym, SYMBOL_TRADE_MODE);
   if(tradeMode == SYMBOL_TRADE_MODE_DISABLED)
   {
      Log("Trading is disabled for " + gSym + ".");
      gInitFailed = true;
      return(INIT_FAILED);
   }

   //--- symbol properties, none of them hardcoded
   gPoint    = SymbolInfoDouble(gSym, SYMBOL_POINT);
   gDigits   = (int)SymbolInfoInteger(gSym, SYMBOL_DIGITS);
   gTickSize = SymbolInfoDouble(gSym, SYMBOL_TRADE_TICK_SIZE);
   gVolMin   = SymbolInfoDouble(gSym, SYMBOL_VOLUME_MIN);
   gVolMax   = SymbolInfoDouble(gSym, SYMBOL_VOLUME_MAX);
   gVolStep  = SymbolInfoDouble(gSym, SYMBOL_VOLUME_STEP);

   if(gPoint <= 0.0)
   {
      Log("Could not read the point size for " + gSym + ".");
      gInitFailed = true;
      return(INIT_FAILED);
   }

   //--- filling mode
   int fm = (int)SymbolInfoInteger(gSym, SYMBOL_FILLING_MODE);
   string fmName = "";
   if((fm & SYMBOL_FILLING_FOK) != 0)      { gFilling = ORDER_FILLING_FOK; fmName = "FOK"; }
   else if((fm & SYMBOL_FILLING_IOC) != 0) { gFilling = ORDER_FILLING_IOC; fmName = "IOC"; }
   else                                     { gFilling = ORDER_FILLING_RETURN; fmName = "RETURN"; }

   trade.SetExpertMagicNumber((ulong)InpMagic);
   trade.SetDeviationInPoints(InpSlippagePoints);
   trade.SetTypeFilling(gFilling);
   trade.SetAsyncMode(false);

   //--- print every input, as asked
   Log("--------------------------------------------------");
   Log("HedgeBasketEA starting");
   Log(StringFormat("Symbol               : %s", gSym));
   Log(StringFormat("Magic                : %I64d", InpMagic));
   Log(StringFormat("Comment              : %s", InpComment));
   Log(StringFormat("Lot                  : %.2f", InpLot));
   Log(StringFormat("Lot multiplier       : %.2f%s", InpLotMultiplier,
                    InpLotMultiplier > 1.0 ? "   <-- MARTINGALE IS ON" : "   (same lot every level)"));
   Log(StringFormat("Max lot per order    : %.2f", InpMaxLot));
   Log(StringFormat("Max positions        : %d", InpMaxPositions));
   Log(StringFormat("First direction      : %s", InpFirstDirection == FIRST_BUY ? "BUY" : "SELL"));
   Log(StringFormat("Hedge distance       : %d points = %s in price",
                    InpHedgeDistancePoints,
                    DoubleToString(InpHedgeDistancePoints * gPoint, gDigits)));
   Log(StringFormat("Target profit        : %.2f %s", InpTargetProfitMoney,
                    AccountInfoString(ACCOUNT_CURRENCY)));
   Log(StringFormat("Max basket loss      : %.2f %s", InpMaxBasketLossMoney,
                    AccountInfoString(ACCOUNT_CURRENCY)));
   Log(StringFormat("Max spread           : %d points", InpMaxSpreadPoints));
   Log(StringFormat("Slippage             : %I64u points", InpSlippagePoints));
   Log(StringFormat("Trade on Friday      : %s", InpTradeOnFriday ? "yes" : "no"));
   Log("--------------------------------------------------");
   Log(StringFormat("Digits %d, point %s, tick size %s",
                    gDigits, DoubleToString(gPoint, 8), DoubleToString(gTickSize, 8)));
   Log(StringFormat("Volume min %.2f, max %.2f, step %.2f", gVolMin, gVolMax, gVolStep));
   Log(StringFormat("Filling mode detected: %s", fmName));
   Log("Every order goes out with SL=0 and TP=0. Exits are basket-only.");
   Log("--------------------------------------------------");

   return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason)
{
   Comment("");
}

//+------------------------------------------------------------------+
//| Chart readout                                                     |
//+------------------------------------------------------------------+
void ShowComment(int count, double buyLots, double sellLots, double profit)
{
   string s = "";
   s += "HedgeBasketEA   " + gSym + "\n";
   s += "-----------------------------\n";
   s += StringFormat("Spread      : %d points\n", SpreadPoints());
   s += StringFormat("Buy lots    : %.2f\n", buyLots);
   s += StringFormat("Sell lots   : %.2f\n", sellLots);
   s += StringFormat("Positions   : %d / %d\n", count, InpMaxPositions);
   s += StringFormat("Basket P/L  : %.2f %s\n", profit, AccountInfoString(ACCOUNT_CURRENCY));
   s += StringFormat("Target      : %.2f    Max loss: %.2f\n",
                     InpTargetProfitMoney, InpMaxBasketLossMoney);
   s += "-----------------------------\n";
   s += gHalted ? "STATUS      : HALTED until the next broker day\n"
                : "STATUS      : running\n";
   s += "SL and TP   : always 0\n";
   Comment(s);
}

//+------------------------------------------------------------------+
//| Tick                                                              |
//+------------------------------------------------------------------+
void OnTick()
{
   if(gInitFailed) return;

   ClearHaltOnNewDay();

   int    count;
   double buyLots, sellLots, profit, lastEntry;
   long   lastType;
   BasketState(count, buyLots, sellLots, profit, lastEntry, lastType);

   ShowComment(count, buyLots, sellLots, profit);

   //--- 1. basket exits come first, and they always close everything
   if(count > 0)
   {
      if(profit >= InpTargetProfitMoney)
      {
         Log(StringFormat("Basket profit %.2f reached the target %.2f",
                          profit, InpTargetProfitMoney));
         CloseBasket("TARGET");
         PruneCommissionCache();
         return;
      }
      if(InpMaxBasketLossMoney > 0.0 && profit <= -InpMaxBasketLossMoney)
      {
         Log(StringFormat("Basket loss %.2f hit the limit %.2f",
                          profit, -InpMaxBasketLossMoney));
         CloseBasket("MAX LOSS");
         SetHalted();
         PruneCommissionCache();
         return;
      }
   }

   //--- 2. nothing new opens while halted
   if(gHalted) return;

   //--- 3. nor on a Friday when that is switched off
   if(!InpTradeOnFriday && IsFridayNow()) return;

   //--- 4. nor while the spread is too wide
   int sp = SpreadPoints();
   if(sp > InpMaxSpreadPoints) return;

   //--- 5. first trade of a fresh basket
   if(count == 0)
   {
      double lots = NormalizeLots(InpLot);
      if(lots > InpMaxLot + 0.0000001)
      {
         Log(StringFormat("First lot %.2f is above the max lot %.2f. Nothing opened.",
                          lots, InpMaxLot));
         return;
      }
      Log("Opening the first trade of a new basket.");
      SendMarket(InpFirstDirection == FIRST_BUY, lots);
      return;
   }

   //--- 6. add the opposite side once price has run against the LAST entry
   if(count >= InpMaxPositions)  return;
   if(lastType < 0)              return;

   double dist = InpHedgeDistancePoints * gPoint;
   double bid  = SymbolInfoDouble(gSym, SYMBOL_BID);
   double ask  = SymbolInfoDouble(gSym, SYMBOL_ASK);

   bool trigger = false;
   bool wantBuy = false;

   if(lastType == POSITION_TYPE_BUY)
   {
      // the last entry was a buy, so "against" means price falling
      if(bid <= lastEntry - dist) { trigger = true; wantBuy = false; }
   }
   else
   {
      // the last entry was a sell, so "against" means price rising
      if(ask >= lastEntry + dist) { trigger = true; wantBuy = true; }
   }

   if(!trigger) return;

   // Level sizing. At a multiplier of 1.0 this is InpLot every time, which
   // is the default and is NOT a martingale. Above 1.0 each level is larger
   // than the one before it, which is.
   double lots = NormalizeLots(InpLot * MathPow(InpLotMultiplier, (double)count));

   if(lots > InpMaxLot + 0.0000001)
   {
      Log(StringFormat("Next lot %.2f would pass the max lot %.2f. Not opening.",
                       lots, InpMaxLot));
      return;
   }

   Log(StringFormat("Price ran %d points against the last entry %s. Opening the opposite side.",
                    InpHedgeDistancePoints, DoubleToString(lastEntry, gDigits)));
   SendMarket(wantBuy, lots);
}
