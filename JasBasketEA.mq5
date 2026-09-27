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
input double InpCloseAllProfit = 50.0;   // Basket kitne par Close All (naapa hua: darmiyana 54.80)
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
input group "=== 10 - Spike par hedge (L17) ==="
input bool   InpUseSpikeHedge = true;  // Spike aaye to kitab hedge (net sifar)
input double InpSpikeMult     = 3.0;   // Spike = ek candle mein kitne qadam
input bool   InpSpikeOverCap  = false; // Hedge ke liye KUL lots ki hadd tor do?

input group "=== 9 - News (L10) ==="
input bool   InpUseNews      = true;   // Bari news ke waqt nayi lot band
input int    InpNewsBefore   = 30;     // News se kitne minute pehle
input int    InpNewsAfter    = 5;      // News ke baad kitne minute
input string InpNewsCurrency = "USD";  // Kis mulk ki news (khali = sab)

input group "=== 8 - Bachao aur faide wali lot ==="
input bool   InpCloseWinners = true;   // Faide wali lot akeli band kar do
input double InpLegProfit    = 14.0;   // Ek lot ka faida (naapa hua: ausat 13.98)
input bool   InpUseDefence   = true;   // Khilaf jane par ulti lot
input double InpDefenceMult  = 3.5;    // Kitne qadam khilaf jane par (gold: 3.5 x $1 = $3.50)

input group "=== 7 - Qadam aur bara rukh ==="
input bool   InpUseStep     = true;    // Nayi lot sirf tab jab qeemat ek qadam door ho
input double InpStepMult    = 1.0;     // Qadam = ATR ka kitna hissa
input int    InpAtrLen      = 14;      // ATR ki lambai
input double InpGoldStep    = 1.00;    // Gold par aap ka apna qadam (dollar)
input bool   InpUseTrendTF  = true;    // Bara rukh dekhein
input ENUM_TIMEFRAMES InpTrendTF = PERIOD_M5;  // Bara rukh kis TF se
input int    InpTrendEma    = 50;      // Bare rukh ki EMA

input group "=== 6 - Amal ==="
input bool   InpAllowNewLots   = true;   // Naye lots lagana chalu
input bool   InpAllowFreeze    = true;   // Kitab barabar karna chalu
input bool   InpAllowCloseAll  = true;   // Close All chalu
input bool   InpAutoUnfreeze   = false;  // Phase 6 KHUD karna (default: sirf batana)
input double InpUnfreezeRatio  = 5.0;    // Kholna kitna guna behtar ho tab
input int    InpMinSecsBetween = 3;      // Do orderon ke darmiyan kam az kam second
input int    InpSlippage       = 50;
input ulong  InpMagic          = 20260928;

#define EA_BUILD "b17"          // har nayi file par ye number barhta hai

CTrade        trade;
CPositionInfo pos;
int      hFast = INVALID_HANDLE, hSlow = INVALID_HANDLE;
int      hAtr  = INVALID_HANDLE, hTrend = INVALID_HANDLE;
datetime g_lastBar = 0, g_lastAction = 0;
datetime g_lastOrder = 0;
string   g_say = "";
double   g_step = 0, g_near = -1;
double   g_defDist = 0, g_worstAgainst = 0;
bool     g_newsBlock = false, g_newsOK = false;
datetime g_newsAt = 0, g_newsLast = 0;
string   g_newsName = "";
int      g_newsErr = 0, g_newsAll = 0, g_newsHigh = 0;
bool     g_spikeHedge = false, g_spikeNow = false;
int      g_htf = 0;

//+------------------------------------------------------------------+
int OnInit()
  {
   if(AccountInfoInteger(ACCOUNT_MARGIN_MODE) != ACCOUNT_MARGIN_MODE_RETAIL_HEDGING)
      Print("Khabardar: ye EA hedging account ke liye hai.");

   hFast = iMA(_Symbol, PERIOD_CURRENT, InpEmaFast, 0, MODE_EMA, PRICE_CLOSE);
   hSlow = iMA(_Symbol, PERIOD_CURRENT, InpEmaSlow, 0, MODE_EMA, PRICE_CLOSE);
   hAtr   = iATR(_Symbol, PERIOD_CURRENT, InpAtrLen);
   hTrend = iMA(_Symbol, InpTrendTF, InpTrendEma, 0, MODE_EMA, PRICE_CLOSE);
   if(hFast == INVALID_HANDLE || hSlow == INVALID_HANDLE ||
      hAtr  == INVALID_HANDLE || hTrend == INVALID_HANDLE)
     {
      Print("Indicator handle nahi bana.");
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
   if(hAtr  != INVALID_HANDLE) IndicatorRelease(hAtr);
   if(hTrend != INVALID_HANDLE) IndicatorRelease(hTrend);
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
//|  L10 - bari news ke waqt nayi lot nahi                            |
//|  MT5 ka calendar live mein milta hai, Strategy Tester mein nahi.  |
//+------------------------------------------------------------------+
void RefreshNews()
  {
   datetime now = TimeCurrent();
   if(now - g_newsLast < 60) return;          // minute mein ek dafa kaafi
   g_newsLast  = now;
   g_newsBlock = false;
   g_newsOK    = false;
   g_newsAt    = 0;
   g_newsName  = "";
   if(!InpUseNews) return;

   MqlCalendarValue v[];
   ResetLastError();
   int n = CalendarValueHistory(v, now - 6 * 3600, now + 12 * 3600,
                                NULL, InpNewsCurrency);
   g_newsErr = GetLastError();
   g_newsAll = n;
   if(n <= 0)                                 // currency ke saath kuch nahi mila
     {
      ResetLastError();
      n = CalendarValueHistory(v, now - 6 * 3600, now + 12 * 3600);
      g_newsErr = GetLastError();
      g_newsAll = n;
      if(n <= 0) return;
     }
   g_newsOK = true;
   g_newsHigh = 0;

   datetime bestAt = 0; string bestName = "";
   for(int i = 0; i < n; i++)
     {
      MqlCalendarEvent e;
      if(!CalendarEventById(v[i].event_id, e))      continue;
      if(e.importance != CALENDAR_IMPORTANCE_HIGH)  continue;
      g_newsHigh++;

      datetime at   = v[i].time;
      datetime from = at - (datetime)(InpNewsBefore * 60);
      datetime to   = at + (datetime)(InpNewsAfter  * 60);
      if(now >= from && now <= to)
        {
         g_newsBlock = true;
         g_newsAt    = at;
         g_newsName  = e.name;
         return;                              // abhi band - bas yahi kaafi
        }
      if(at > now && (bestAt == 0 || at < bestAt)) { bestAt = at; bestName = e.name; }
     }
   g_newsAt   = bestAt;                       // agli bari news
   g_newsName = bestName;
  }

//--- ek qadam kitna bara: gold par aap ka apna, warna ATR se -------
double StepSize()
  {
   if(StringFind(_Symbol, "XAU") >= 0 || StringFind(_Symbol, "GOLD") >= 0)
      return(InpGoldStep);
   double a[1];
   if(CopyBuffer(hAtr, 0, 1, 1, a) < 1) return(0);
   return(a[0] * InpStepMult);
  }

//+------------------------------------------------------------------+
//|  L21 - hedge BAND kar ke, lot laga kar nahi                       |
//|  40 buy aur 30 sell hain to 10 buy band karo: 30 aur 30.          |
//|  Jo 10 chunni hain un mein faida aur nuqsan mila kar, taake band  |
//|  karne se kitab par zarb na parey. Kul lots BARHTI nahi, GHATTI   |
//|  hain - is liye hadd ka koi masla nahi.                           |
//+------------------------------------------------------------------+
int HedgeByClosing(double netLot)
  {
   int need = (int)MathRound(MathAbs(netLot) / InpLot);
   if(need <= 0) return(0);
   bool heavyIsBuy = (netLot > 0);

   ulong  tk[];  double pf[];
   int    n = 0;
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      if(!pos.SelectByIndex(i))          continue;
      if(pos.Symbol() != _Symbol)        continue;
      if(pos.Magic()  != (long)InpMagic) continue;
      if((pos.PositionType() == POSITION_TYPE_BUY) != heavyIsBuy) continue;
      ArrayResize(tk, n + 1); ArrayResize(pf, n + 1);
      tk[n] = pos.Ticket();
      pf[n] = pos.Profit() + pos.Swap();
      n++;
     }
   if(n < need) need = n;
   if(need <= 0) return(0);

   // faide ke hisaab se tarteeb: sab se acha pehle, sab se bura aakhir mein
   for(int a = 1; a < n; a++)
     {
      ulong  kt = tk[a]; double kp = pf[a];
      int    b  = a - 1;
      while(b >= 0 && pf[b] < kp) { pf[b + 1] = pf[b]; tk[b + 1] = tk[b]; b--; }
      pf[b + 1] = kp; tk[b + 1] = kt;
     }

   // ek acha, ek bura - chalta hua jorh sifar ke qareeb rakho
   double run = 0; int done = 0, lo = 0, hi = n - 1;
   while(done < need && lo <= hi)
     {
      int pick = (run < 0) ? lo : hi;      // ghata hai to acha lo, warna bura
      if(trade.PositionClose(tk[pick])) { run += pf[pick]; done++; }
      if(pick == lo) lo++; else hi--;
     }
   if(done > 0)
      Print("L21: hedge band kar ke - ", done, " lot, jorh ",
            DoubleToString(run, 2));
   return(done);
  }

//--- L17: abhi spike chal raha hai? -------------------------------
bool SpikeNow()
  {
   if(!InpUseSpikeHedge) return(false);
   double st = StepSize();
   if(st <= 0) return(false);
   double hi = iHigh(_Symbol, PERIOD_CURRENT, 0);
   double lo = iLow (_Symbol, PERIOD_CURRENT, 0);
   if(hi <= 0 || lo <= 0) return(false);
   return((hi - lo) >= st * InpSpikeMult);
  }

//--- sab se qareeb khuli lot kitni door hai ------------------------
double NearestLegDistance(double px)
  {
   double best = -1;
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      if(!pos.SelectByIndex(i))          continue;
      if(pos.Symbol() != _Symbol)        continue;
      if(pos.Magic()  != (long)InpMagic) continue;
      double d = MathAbs(px - pos.PriceOpen());
      if(best < 0 || d < best) best = d;
     }
   return(best);          // -1 = koi lot nahi
  }

//--- bara rukh: +1 upar, -1 neeche, 0 pata nahi --------------------
int TrendTF()
  {
   if(!InpUseTrendTF) return(0);
   double e[1];
   if(CopyBuffer(hTrend, 0, 1, 1, e) < 1) return(0);
   double px = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   if(px > e[0]) return(1);
   if(px < e[0]) return(-1);
   return(0);
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
   RefreshNews();

   //--- L17: spike -> kitab hedge karo, band mat karo ---------------
   g_spikeNow = SpikeNow();
   if(g_spikeNow && MathAbs(netLot) > InpLot / 2.0)
     {
      // L21 sirf tab jab DONO taraf lots hon. Ek taraf wali kitab par
      // "zyada wali taraf band karo" ka matlab "sab band karo" ban jata
      // hai - aur spike mein sab band karna wohi hai jo mana kiya gaya.
      int shut = (nBuy > 0 && nSell > 0) ? HedgeByClosing(netLot) : 0;
      if(shut > 0)
         g_say += StringFormat("SPIKE - hedge: %d lot band, net ab sifar.\n", shut);
      else
        {
         bool capOK = InpSpikeOverCap ||
                      (totLot + InpLot <= InpMaxTotalLots + 1e-8);
         if(capOK)
           {
            g_spikeHedge = true;
            g_say += "SPIKE - hedge: ulti lot laga raha hoon.\n";
            OpenLot((netLot > 0) ? -1 : 1, "L17: spike hedge");
            g_spikeHedge = false;
           }
         else
            g_say += "SPIKE - hedge nahi ho saka (KUL lots hadd par).\n";
        }
     }

   if(g_spikeNow)
     {
      Report(nBuy, nSell, lotBuy, lotSell, netLot, totLot, basket, equity, floorEq,
             minsEnd, sumPxDirLot, bid);
      return;                                  // spike ke dauran kuch band nahi
     }

   //--- Q7: basket poori band -------------------------------------
   if(InpAllowCloseAll && totLot > 0 && basket >= InpCloseAllProfit)
     {
      CloseAll("Q7: basket " + DoubleToString(basket, 2) + " >= " +
               DoubleToString(InpCloseAllProfit, 2));
      return;
     }

   //--- aap ka qaida 3: faide wali lot band ------------------------
   if(CloseWinners()) return;

   //--- Q8: jori bana kar band - faida + sab se buri lot -----------
   if(InpUsePairClose && nBuy + nSell >= 2)
      if(TryPairClose()) return;

   //--- Q6: market band hone se pehle kitab barabar ----------------
   bool flattenNow = (InpFlattenBeforeClose && minsEnd > 0 && minsEnd <= InpFlattenMinutes);
   if(flattenNow && MathAbs(netLot) > InpLot / 2.0)
     {
      Balance(netLot, totLot, "Q6: market " + IntegerToString(minsEnd) + " min mein band");
     }

   //--- aap ka qaida 4: pehli lot khilaf gayi -> ulti lot ----------
   int    worstDir = 0;
   double worstAgainst = WorstAgainst(bid, worstDir);
   double defDist = StepSize() * InpDefenceMult;
   g_defDist = defDist; g_worstAgainst = worstAgainst;
   if(InpUseDefence && worstDir != 0 && defDist > 0 &&
      worstAgainst >= defDist - 1e-8)
     {
      // ulti taraf, magar sirf agar us taraf abhi kam lots hain
      double sameSide = (worstDir > 0) ? lotBuy : lotSell;
      double oppSide  = (worstDir > 0) ? lotSell : lotBuy;
      if(oppSide < sameSide - 1e-8)
        {
         g_say += StringFormat("Bachao: lot %.2f khilaf (hadd %.2f) - ulti lot.\n",
                               worstAgainst, defDist);
         Balance(worstDir * 1.0, totLot, "Bachao: " +
                 DoubleToString(worstAgainst, 2) + " khilaf");
        }
     }

   //--- Q3: net ki hadd -> sirf ulti taraf -------------------------
   bool netAtCap = (MathAbs(netLot) >= InpMaxNetLots - 1e-8);
   if(InpAllowFreeze && netAtCap && MathAbs(netLot) > InpLot / 2.0)
     {
      Balance(netLot, totLot, "Q3: net " + DoubleToString(netLot, 2) + " hadd par");
     }

   //--- naye lots (Q2) ---------------------------------------------
   double step   = StepSize();
   double nearD  = NearestLegDistance(bid);
   int    ema    = Direction();        // chart ki EMA20/50 - sirf madad ke liye
   int    htf    = TrendTF();          // bara rukh - YAHI faisla karta hai (L1)
   int    dir    = (htf != 0) ? htf : ema;
   bool   stepOK  = (!InpUseStep) || step <= 0 || nearD < 0 || (nearD >= step - 1e-8);
   bool   trendOK = (dir != 0);
   g_step = step; g_near = nearD; g_htf = htf;

   datetime btNow = iTime(_Symbol, PERIOD_CURRENT, 0);
   bool gapOK = (g_lastAction == 0) ||
                (Bars(_Symbol, PERIOD_CURRENT, g_lastAction, btNow) >= InpBarsBetween);

   // kaun si rok chal rahi hai - andaza nahi, likh kar batao
   string blk = "";
   if(!InpAllowNewLots)                             blk += "naye lots band; ";
   if(equity <= floorEq)                            blk += "equity hadd par; ";
   if(totLot + InpLot > InpMaxTotalLots + 1e-8)     blk += "KUL lots hadd par; ";
   if(netAtCap)                                     blk += "NET hadd par (sirf bachao); ";
   if(flattenNow)                                   blk += "market band hone wali; ";
   if(g_newsBlock)                                  blk += "news; ";
   if(!trendOK)                                     blk += "rukh pata nahi; ";
   if(!stepOK)                                      blk += StringFormat("qadam %.2f/%.2f; ", nearD, step);
   if(!gapOK)                                       blk += "candle ka faasla; ";
   g_say += (blk == "") ? "Sab saaf - agli candle par lot lagegi.\n"
                        : ("Ruka hua: " + blk + "\n");

   datetime bt = btNow;
   if(bt != g_lastBar)
     {
      g_lastBar = bt;
      bool equityOK = (equity > floorEq);
      bool roomOK   = (totLot + InpLot * InpBurst <= InpMaxTotalLots + 1e-8);

      if(InpAllowNewLots && equityOK && roomOK && gapOK && !flattenNow &&
         !netAtCap && trendOK && stepOK && dir != 0)
        {
         for(int k = 0; k < InpBurst; k++)
            OpenLot(dir, "Q2: fishing, qadam " + DoubleToString(step, 2));
         g_lastAction = bt;
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
   if(g_newsBlock && !g_spikeHedge) return;           // L10 (spike hedge ki istisna: L17)
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
void Balance(double netLot, double totLot, string why)
  {
   if(!InpAllowFreeze) return;
   if(totLot + InpLot > InpMaxTotalLots + 1e-8)      // kul lots ki hadd
     {
      g_say += "KUL lots hadd par (" + DoubleToString(totLot, 2) + ") - ab sirf INTEZAR.\n";
      return;
     }
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

//--- faide wali lot akeli band (aap ka qaida 3) --------------------
bool CloseWinners()
  {
   if(!InpCloseWinners) return(false);
   if(TimeCurrent() - g_lastOrder < InpMinSecsBetween) return(false);
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      if(!pos.SelectByIndex(i))          continue;
      if(pos.Symbol() != _Symbol)        continue;
      if(pos.Magic()  != (long)InpMagic) continue;
      if(pos.Profit() + pos.Swap() < InpLegProfit) continue;
      g_lastOrder = TimeCurrent();
      Print("Faide wali lot band: ", DoubleToString(pos.Profit() + pos.Swap(), 2));
      trade.PositionClose(pos.Ticket());
      return(true);
     }
   return(false);
  }

//--- sab se buri lot kitni door khilaf gayi -----------------------
double WorstAgainst(double bid, int &dirOfWorst)
  {
   double worst = 0; dirOfWorst = 0;
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      if(!pos.SelectByIndex(i))          continue;
      if(pos.Symbol() != _Symbol)        continue;
      if(pos.Magic()  != (long)InpMagic) continue;
      bool isBuy = (pos.PositionType() == POSITION_TYPE_BUY);
      double d = isBuy ? (pos.PriceOpen() - bid) : (bid - pos.PriceOpen());
      if(d > worst) { worst = d; dirOfWorst = isBuy ? 1 : -1; }
     }
   return(worst);          // 0 = koi lot khilaf nahi
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
   string s = "=== JAS BASKET EA  " + EA_BUILD + " ===\n";
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
         bool   flat       = (MathAbs(netLot) <= 1e-8);
         double needFrozen = flat ? -1
                             : MathAbs(basket) / (MathAbs(netLot) * perPt);
         double lotOne     = (netLot > 0) ? lotBuy : lotSell;
         double needOpen   = (lotOne > 1e-8)
                             ? MathAbs(basket) / (lotOne * perPt) : -1;
         if(needOpen > 0 && basket < 0 && nBuy > 0 && nSell > 0)
           {
            s += "\nPhase 6 ka hisaab:\n";
            if(flat)
               s += "  Jami hui kitab  : NET 0 - qeemat se KABHI nahi nikalti\n";
            else
               s += StringFormat("  Jami hui kitab  : qeemat %.1f chahiye\n", needFrozen);
            s += StringFormat("  Ek taraf band   : qeemat %.1f chahiye\n", needOpen);
            if(flat || needOpen * InpUnfreezeRatio < needFrozen)
               s += "  >> KHOLNA BOHOT BEHTAR HAI <<\n";
           }
        }
     }
   if(g_spikeNow)
      s += "SPIKE         : << CHAL RAHA HAI - sirf hedge >>\n";

   if(!InpUseNews)
      s += "News          : dekha nahi ja raha\n";
   else if(!g_newsOK)
      s += StringFormat("News          : calendar nahi mila (error %d)\n", g_newsErr);
   else if(g_newsBlock)
      s += StringFormat("News          : << BAND >> %s (%s)\n",
                        g_newsName, TimeToString(g_newsAt, TIME_MINUTES));
   else if(g_newsAt > 0)
      s += StringFormat("News          : agli %s (%s)\n",
                        g_newsName, TimeToString(g_newsAt, TIME_DATE | TIME_MINUTES));
   else
      s += StringFormat("News          : koi bari nahi (%d mein se %d bari)\n",
                        g_newsAll, g_newsHigh);

   s += StringFormat("Bachao par    : %.2f     abhi khilaf: %.2f\n",
                     g_defDist, g_worstAgainst);
   s += StringFormat("Qadam         : %.2f     qareeb tareen lot: %s\n",
                     g_step, (g_near < 0 ? "koi nahi" : DoubleToString(g_near, 2)));
   s += StringFormat("Bara rukh (%s): %s\n", EnumToString(InpTrendTF),
                     (g_htf > 0 ? "UPAR" : (g_htf < 0 ? "NEECHE" : "pata nahi")));

   double spread = SymbolInfoDouble(_Symbol, SYMBOL_ASK) - bid;
   double perPt2 = MoneyPerPoint(1.0);
   if(totLot > 0 && perPt2 > 0)
      s += StringFormat("Spread ka bojh: %.2f  (%d lots par)\n",
                        spread * totLot * perPt2, nBuy + nSell);

   if(g_say != "") s += "\n" + g_say;
   Comment(s);
  }
//+------------------------------------------------------------------+
