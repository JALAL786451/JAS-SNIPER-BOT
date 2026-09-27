//+------------------------------------------------------------------+
//|  JasBasketEA.mq5                                                  |
//|  Jalal ki apni basket method - machine par, uski ghaltiyon ke     |
//|  baghair. Qawaid EA-QAWAID.md mein likhe hain.                    |
//|                                                                   |
//|  ZARURI: hedging account chahiye (Exness Cent theek hai).         |
//|  Koi SL, koi TP - ye is method ka usool hai, bhool nahi.          |
//|                                                                   |
//|  Har number input hai. Aap chalte hue badal sakte hain.           |
//|  Har hissa alag se band ho sakta hai, EA band kiye baghair.       |
//+------------------------------------------------------------------+
#property copyright "JAS-SNIPER-BOT"
#property version   "1.00"

#include <Trade\Trade.mqh>
#include <Trade\PositionInfo.mqh>

//--- 1. Lots (Q1, Q2) ---------------------------------------------
input group "=== 1 - Lots ==="
input double InpLot            = 0.01;   // Har lot ka size (kabhi nahi barhta)
input int    InpBurst          = 1;      // Ek baar mein kitni lots
input int    InpBarsBetween    = 1;      // Do jhundon ke darmiyan kam az kam candles

//--- 2. Hadd (Q3, Q10) --------------------------------------------
input group "=== 2 - Hadd (ye EA ko rokti hain) ==="
input double InpMaxNetLots     = 0.20;   // Net (buy - sell) ki hadd
input double InpMaxTotalLots   = 1.00;   // Kul lots ki hadd (dono taraf mila kar)
input double InpEquityFloorPct = 90.0;   // Equity, balance ke is % se neeche -> naye lots band

//--- 3. Faida (Q7, Q8) --------------------------------------------
input group "=== 3 - Faida lena ==="
input double InpCloseAllProfit = 50.0;   // Basket kitne (account currency) par Close All
input bool   InpUsePairClose   = true;   // Beech mein jori bana kar band karna
input double InpPairMinProfit  = 5.0;    // Jori ka kam az kam faida

//--- 4. Market band hone se pehle (Q6) ----------------------------
input group "=== 4 - Market band hone se pehle ==="
input bool   InpFlattenBeforeClose = true; // Band hone se pehle kitab barabar
input int    InpFlattenMinutes     = 30;   // Kitne minute pehle

//--- 5. Rukh (Q2) -------------------------------------------------
input group "=== 5 - Rukh (fishing) ==="
input int    InpEmaFast        = 20;
input int    InpEmaSlow        = 50;

//--- 6. Amal ------------------------------------------------------
input group "=== 6 - Amal ==="
input bool   InpAllowNewLots   = true;   // Naye lots lagana chalu
input bool   InpAllowFreeze    = true;   // Kitab barabar karna chalu
input bool   InpAllowCloseAll  = true;   // Close All chalu
input bool   InpAutoUnfreeze   = false;  // Phase 6 KHUD karna (default: sirf batana)
input double InpUnfreezeRatio  = 5.0;    // Kholna kitna guna behtar ho tab
input int    InpMinSecsBetween = 3;      // Do orderon ke darmiyan kam az kam second
input int    InpSlippage       = 50;
input ulong  InpMagic          = 20260928;

CTrade        trade;
CPositionInfo pos;
int      hFast = INVALID_HANDLE, hSlow = INVALID_HANDLE;
datetime g_lastBar = 0, g_lastAction = 0;
datetime g_lastOrder = 0;
string   g_say = "";

//+------------------------------------------------------------------+
int OnInit()
  {
   if(AccountInfoInteger(ACCOUNT_MARGIN_MODE) != ACCOUNT_MARGIN_MODE_RETAIL_HEDGING)
      Print("Khabardar: ye EA hedging account ke liye hai.");

   hFast = iMA(_Symbol, PERIOD_CURRENT, InpEmaFast, 0, MODE_EMA, PRICE_CLOSE);
   hSlow = iMA(_Symbol, PERIOD_CURRENT, InpEmaSlow, 0, MODE_EMA, PRICE_CLOSE);
   if(hFast == INVALID_HANDLE || hSlow == INVALID_HANDLE)
     {
      Print("EMA handle nahi bana.");
      return(INIT_FAILED);
     }

   trade.SetExpertMagicNumber(InpMagic);
   trade.SetDeviationInPoints(InpSlippage);
   trade.SetTypeFillingBySymbol(_Symbol);

   g_lastBar     = iTime(_Symbol, PERIOD_CURRENT, 0);
   return(INIT_SUCCEEDED);
  }

void OnDeinit(const int reason)
  {
   if(hFast != INVALID_HANDLE) IndicatorRelease(hFast);
   if(hSlow != INVALID_HANDLE) IndicatorRelease(hSlow);
   Comment("");
  }

//+------------------------------------------------------------------+
//|  KITAB GINNA - sab kuch yahan se                                  |
//+------------------------------------------------------------------+
void ReadBook(int &nBuy, int &nSell, double &lotBuy, double &lotSell,
              double &plBuy, double &plSell, double &sumPxDirLot)
  {
   nBuy = 0; nSell = 0; lotBuy = 0; lotSell = 0; plBuy = 0; plSell = 0;
   sumPxDirLot = 0;
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      if(!pos.SelectByIndex(i))                continue;
      if(pos.Symbol() != _Symbol)              continue;
      if(pos.Magic()  != (long)InpMagic)       continue;
      double v  = pos.Volume();
      double pl = pos.Profit() + pos.Swap();
      double px = pos.PriceOpen();
      if(pos.PositionType() == POSITION_TYPE_BUY)
        { nBuy++;  lotBuy  += v; plBuy  += pl; sumPxDirLot += px * v; }
      else
        { nSell++; lotSell += v; plSell += pl; sumPxDirLot -= px * v; }
     }
  }

double MoneyPerPoint(double lots)
  {
   double tv = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);
   double ts = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);
   if(ts <= 0) return(0);
   return(lots * tv / ts);          // har 1.0 qeemat ki harkat par kitna paisa
  }

double NormLot(double l)
  {
   double st = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);
   double mn = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
   double mx = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX);
   if(st <= 0) st = 0.01;
   double r = MathFloor(l / st + 0.5) * st;
   if(r < mn) r = mn;
   if(r > mx) r = mx;
   return(NormalizeDouble(r, 2));
  }

//+------------------------------------------------------------------+
//|  Q6 - market band hone mein kitne minute                          |
//+------------------------------------------------------------------+
int MinutesToSessionEnd()
  {
   MqlDateTime t; TimeToStruct(TimeCurrent(), t);
   int nowSec = t.hour * 3600 + t.min * 60 + t.sec;
   int day    = (int)t.day_of_week;
   int carry  = 0;                       // is din se pehle kitne minute guzre

   // Aaj se le kar 7 din tak: pehla asli khala dhoondo.
   // Agar session 23:59 par khatam ho aur agle din 00:00 par shuru ho,
   // to market band nahi hui - woh sirf din badalna hai (BTC 24/7).
   for(int d = 0; d < 8; d++)
     {
      int wd = (day + d) % 7;
      datetime from, to;
      int endSec = -1;                   // is din ka aakhri session kab khatam

      for(int s = 0; s < 8; s++)
        {
         if(!SymbolInfoSessionTrade(_Symbol, (ENUM_DAY_OF_WEEK)wd, s, from, to)) break;
         int fSec = (int)from, tSec = (int)to;
         if(d == 0 && tSec < nowSec) continue;     // aaj ka guzra hua session

         // agar is session se pehle khala hai aur hum us khale mein hain -> market abhi band hai
         if(endSec >= 0 && fSec > endSec + 60) return(0);
         if(d == 0 && s == 0 && fSec > nowSec)      return(0);
         if(endSec < 0 || tSec > endSec) endSec = tSec;
        }

      if(endSec < 0) return(0);          // is din koi session nahi -> band

      // din ke aakhir tak chala? to agle din dekho ke woh 00:00 se shuru hota hai ya nahi
      if(endSec < 86340)                 // 23:59 se pehle khatam -> yahi asli band hai
         return(carry + (endSec - (d == 0 ? nowSec : 0)) / 60);

      datetime nf, nt;
      int nwd = (day + d + 1) % 7;
      if(!SymbolInfoSessionTrade(_Symbol, (ENUM_DAY_OF_WEEK)nwd, 0, nf, nt))
         return(carry + (endSec - (d == 0 ? nowSec : 0)) / 60);   // agla din band -> asli band
      if((int)nf > 60)                   // agla din 00:00 se shuru nahi -> asli band
         return(carry + (endSec - (d == 0 ? nowSec : 0)) / 60);

      carry += (86400 - (d == 0 ? nowSec : 0)) / 60;   // din jurta gaya, aage dekho
     }

   return(-1);                           // 7 din tak koi khala nahi -> 24/7
  }

//+------------------------------------------------------------------+
void OnTick()
  {
   int    nBuy, nSell;
   double lotBuy, lotSell, plBuy, plSell, sumPxDirLot;
   ReadBook(nBuy, nSell, lotBuy, lotSell, plBuy, plSell, sumPxDirLot);

   double netLot  = lotBuy - lotSell;
   double totLot  = lotBuy + lotSell;
   double basket  = plBuy + plSell;
   double equity  = AccountInfoDouble(ACCOUNT_EQUITY);
   double balance = AccountInfoDouble(ACCOUNT_BALANCE);
   double floorEq = balance * InpEquityFloorPct / 100.0;
   int    minsEnd = MinutesToSessionEnd();
   double bid     = SymbolInfoDouble(_Symbol, SYMBOL_BID);

   g_say = "";

   //--- Q7: basket poori band -------------------------------------
   if(InpAllowCloseAll && totLot > 0 && basket >= InpCloseAllProfit)
     {
      CloseAll("Q7: basket " + DoubleToString(basket, 2) + " >= " +
               DoubleToString(InpCloseAllProfit, 2));
      return;
     }

   //--- Q8: jori bana kar band - faida + sab se buri lot -----------
   if(InpUsePairClose && nBuy + nSell >= 2)
      if(TryPairClose()) return;

   //--- Q6: market band hone se pehle kitab barabar ----------------
   bool flattenNow = (InpFlattenBeforeClose && minsEnd > 0 && minsEnd <= InpFlattenMinutes);
   if(flattenNow && MathAbs(netLot) > InpLot / 2.0)
     {
      Balance(netLot, "Q6: market " + IntegerToString(minsEnd) + " min mein band");
      return;
     }

   //--- Q3: net ki hadd -> sirf ulti taraf -------------------------
   bool netAtCap = (MathAbs(netLot) >= InpMaxNetLots - 1e-8);
   if(InpAllowFreeze && netAtCap && MathAbs(netLot) > InpLot / 2.0)
     {
      Balance(netLot, "Q3: net " + DoubleToString(netLot, 2) + " hadd par");
      return;
     }

   //--- naye lots (Q2) ---------------------------------------------
   datetime bt = iTime(_Symbol, PERIOD_CURRENT, 0);
   if(bt != g_lastBar)
     {
      g_lastBar = bt;
      bool equityOK = (equity > floorEq);
      bool roomOK   = (totLot + InpLot * InpBurst <= InpMaxTotalLots + 1e-8);
      bool gapOK    = (g_lastAction == 0) ||
                      (Bars(_Symbol, PERIOD_CURRENT, g_lastAction, bt) >= InpBarsBetween);
      if(InpAllowNewLots && equityOK && roomOK && gapOK && !flattenNow && !netAtCap)
        {
         int dir = Direction();
         if(dir != 0)
           {
            for(int k = 0; k < InpBurst; k++)
               OpenLot(dir, "Q2: fishing, EMA" + IntegerToString(InpEmaFast) +
                       (dir > 0 ? " > EMA" : " < EMA") + IntegerToString(InpEmaSlow));
            g_lastAction = bt;
           }
        }
      else if(!equityOK)
         g_say += "Equity hadd par - naye lots band.\n";
     }

   Report(nBuy, nSell, lotBuy, lotSell, netLot, totLot, basket, equity, floorEq,
          minsEnd, sumPxDirLot, bid);
  }

//+------------------------------------------------------------------+
int Direction()
  {
   double f[2], s[2];
   if(CopyBuffer(hFast, 0, 1, 2, f) < 2) return(0);
   if(CopyBuffer(hSlow, 0, 1, 2, s) < 2) return(0);
   if(f[1] > s[1]) return(1);
   if(f[1] < s[1]) return(-1);
   return(0);
  }

void OpenLot(int dir, string why)
  {
   if(TimeCurrent() - g_lastOrder < InpMinSecsBetween) return;
   g_lastOrder = TimeCurrent();
   double l = NormLot(InpLot);
   bool ok = (dir > 0) ? trade.Buy(l, _Symbol, 0, 0, 0, why)
                       : trade.Sell(l, _Symbol, 0, 0, 0, why);
   if(!ok)
      Print("Lot nahi lagi: ", trade.ResultRetcodeDescription());
   else
      Print(why, " | ", (dir > 0 ? "BUY " : "SELL "), DoubleToString(l, 2));
  }

//--- net ko sifar ki taraf lana: ek ulti lot ----------------------
void Balance(double netLot, string why)
  {
   if(!InpAllowFreeze) return;
   int dir = (netLot > 0) ? -1 : 1;
   OpenLot(dir, why);
  }

void CloseAll(string why)
  {
   Print("CLOSE ALL - ", why);
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      if(!pos.SelectByIndex(i))          continue;
      if(pos.Symbol() != _Symbol)        continue;
      if(pos.Magic()  != (long)InpMagic) continue;
      trade.PositionClose(pos.Ticket());
     }
  }

//+------------------------------------------------------------------+
//|  Q8 - sab se achi aur sab se buri lot ek saath band               |
//|  Akeli faide wali band karne se kitab mein sirf buri lots bachti  |
//|  hain. Jori bana kar band karne se faida bhi milta hai aur sab se |
//|  buri lot bhi nikal jaati hai.                                    |
//+------------------------------------------------------------------+
bool TryPairClose()
  {
   ulong  bestT = 0, worstT = 0;
   double bestP = -DBL_MAX, worstP = DBL_MAX;
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      if(!pos.SelectByIndex(i))          continue;
      if(pos.Symbol() != _Symbol)        continue;
      if(pos.Magic()  != (long)InpMagic) continue;
      double pl = pos.Profit() + pos.Swap();
      if(pl > bestP)  { bestP  = pl; bestT  = pos.Ticket(); }
      if(pl < worstP) { worstP = pl; worstT = pos.Ticket(); }
     }
   if(bestT == 0 || worstT == 0 || bestT == worstT) return(false);
   if(bestP <= 0) return(false);
   if(bestP + worstP < InpPairMinProfit) return(false);

   if(TimeCurrent() - g_lastOrder < InpMinSecsBetween) return(false);
   g_lastOrder = TimeCurrent();
   Print("Q8: jori band - faida ", DoubleToString(bestP, 2),
         " + sab se buri ", DoubleToString(worstP, 2),
         " = ", DoubleToString(bestP + worstP, 2));
   bool a = trade.PositionClose(bestT);
   bool b = trade.PositionClose(worstT);
   return(a || b);
  }

//+------------------------------------------------------------------+
//|  Q9 + Q11 - chart par sab kuch likh kar batao                     |
//+------------------------------------------------------------------+
void Report(int nBuy, int nSell, double lotBuy, double lotSell, double netLot,
            double totLot, double basket, double equity, double floorEq,
            int minsEnd, double sumPxDirLot, double bid)
  {
   string s = "=== JAS BASKET EA ===\n";
   s += StringFormat("Buy  %d lot (%.2f)   Sell %d lot (%.2f)\n",
                     nBuy, lotBuy, nSell, lotSell);
   s += StringFormat("NET  %+.2f  (hadd %.2f)    KUL %.2f (hadd %.2f)\n",
                     netLot, InpMaxNetLots, totLot, InpMaxTotalLots);
   s += StringFormat("Kitab ka haal : %.2f     Close All par: %.2f\n",
                     basket, InpCloseAllProfit);
   s += StringFormat("Balance       : %.2f\n", AccountInfoDouble(ACCOUNT_BALANCE));
   s += StringFormat("Equity        : %.2f     hadd: %.2f%s\n",
                     equity, floorEq, (equity <= floorEq ? "  << RUKA HUA" : ""));

   if(minsEnd > 0)
      s += StringFormat("Market band   : %d minute mein\n", minsEnd);
   else if(minsEnd == 0)
      s += "Market        : ABHI BAND\n";
   else
      s += "Market        : 24/7 (band nahi hoti)\n";

   //--- Q9: kholna behtar hai ya jamna? ---------------------------
   if(totLot > 0)
     {
      double perPt = MoneyPerPoint(1.0);
      if(perPt > 0)
        {
         double needFrozen = (MathAbs(netLot) > 1e-8)
                             ? MathAbs(basket) / (MathAbs(netLot) * perPt) : -1;
         double lotOne  = (netLot > 0) ? lotBuy : lotSell;
         double needOpen = (lotOne > 1e-8)
                           ? MathAbs(basket) / (lotOne * perPt) : -1;
         if(needFrozen > 0 && needOpen > 0)
           {
            s += "\nPhase 6 ka hisaab:\n";
            s += StringFormat("  Jami hui kitab  : qeemat %.1f chahiye\n", needFrozen);
            s += StringFormat("  Ek taraf band   : qeemat %.1f chahiye\n", needOpen);
            if(needOpen * InpUnfreezeRatio < needFrozen)
               s += "  >> KHOLNA BOHOT BEHTAR HAI <<\n";
           }
        }
     }
   if(g_say != "") s += "\n" + g_say;
   Comment(s);
  }
//+------------------------------------------------------------------+
