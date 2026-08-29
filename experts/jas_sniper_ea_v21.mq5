//+------------------------------------------------------------------+
//|                                        jas_sniper_ea_v21.mq5     |
//|  JAS SNIPER EA v2.1 — XAUUSD structure + trend (safety patch)    |
//|                                                                  |
//|  v2.1 patches (v2.00 ke bugs):                                   |
//|    - Hard stop / daily loss ab khuli position BAND karti hai     |
//|    - Counters GlobalVariables mein — restart se reset nahi       |
//|    - Din YYYYMMDD se (sirf dt.day nahi)                          |
//|    - True breakeven = open ± (spread + buffer)                   |
//|    - Restart ke baad TP2/trail comment/GV se wapas aate hain     |
//|    - HTF mixed ab trade BLOCK karta hai                          |
//|    - Commission + fill slippage risk check                       |
//|    - Friday cutoff + weekend: nayi entry nahi                    |
//|    - SEMI click per lots/SL dubara hisaab                        |
//|    - Attach wale bar per signal nahi                             |
//|    - Spread points nahi, price (gold-safe)                       |
//|                                                                  |
//|  YE EA HEDGE YA AVERAGE KAR HI NAHI SAKTA.                       |
//|  DemoOnly default true. LIVE se pehle false karein.              |
//+------------------------------------------------------------------+
#property copyright "JAS Sniper"
#property version   "2.10"
#property strict

#include <Trade\Trade.mqh>

enum ENUM_BOT_MODE
  {
   BOT_ALERT = 0,
   BOT_SEMI  = 1,
   BOT_AUTO  = 2
  };

input group "=== Andaz ==="
input ENUM_BOT_MODE Mode            = BOT_SEMI;
input bool   DemoOnly               = true;
input long   MagicNumber            = 786451;
input bool   ClearHardStop          = false;     // true: purana BAND hata kar dobara start

input group "=== Risk ==="
input double RiskPercent            = 1.0;
input double MaxDailyLossPercent    = 6.0;
input int    MaxTradesPerDay        = 3;
input int    MaxConsecutiveLosses   = 3;
input double MaxTotalDDPercent      = 20.0;
input double MaxMarginUsePercent    = 30.0;
input double CommissionPerLot       = 0.0;       // round-trip, account currency (Raw/Zero pe bharo)
input double MaxRiskSlippageMult    = 1.25;      // fill ke baad risk itne x se zyada to close
input bool   FlattenOnHardStop      = true;      // BAND per khuli trade band karo
input bool   FlattenOnDailyLoss     = true;      // din ki had per khuli trade band karo

input group "=== Stop / Target ==="
input int    AtrPeriod              = 14;
input double SlBufferAtr            = 0.25;
input double MinSlAtr               = 0.60;
input double MaxSlAtr               = 3.50;
input int    SlSwingLookback        = 10;
input double Tp1R                   = 1.0;
input double Tp2R                   = 2.0;
input double Tp3R                   = 3.0;
input double Tp1ClosePercent        = 50.0;
input double Tp2ClosePercent        = 50.0;
input bool   BreakevenAfterTp1      = true;
input int    BeBufferPoints         = 20;        // BE spread ke UPAR itne points (gold ~ $0.20 if digits=2)
input bool   TrailAfterTp2          = true;
input double TrailAtr               = 1.50;

input group "=== Structure / Trend ==="
input int    PivotLR                = 3;
input int    StructLookback         = 6;
input int    EmaFast                = 20;
input int    EmaSlow                = 50;
input bool   UseAdx                 = true;
input int    AdxPeriod              = 14;
input double AdxMin                 = 18.0;

input group "=== HTF confluence ==="
input bool             UseHtf       = true;
input ENUM_TIMEFRAMES  Htf1         = PERIOD_H4;
input ENUM_TIMEFRAMES  Htf2         = PERIOD_D1;
input bool             HtfBothMustAgree = true;  // v2.1 default: dono HTF same direction

input group "=== Score gate ==="
input bool   UseScore               = true;
input int    MinScore               = 70;

input group "=== Guards ==="
input double MaxSpreadPrice         = 0.60;      // gold: $0.60 (0 = MaxSpreadPoints use karo)
input double MaxSpreadPoints        = 60;
input int    MaxSlippagePoints      = 40;
input int    CooldownBars           = 5;
input bool   UseSession             = true;
input int    SessionStartHour       = 8;
input int    SessionEndHour         = 20;
input bool   BlockFridayLate        = true;
input int    FridayCutoffHour       = 18;        // server time — is ke baad Friday entry nahi
input bool   BlockWeekend           = true;      // Sat/Sun nayi entry nahi
input int    ConfirmExpiryBars      = 3;

input group "=== Panel ==="
input int    PanelX                 = 12;
input int    PanelY                 = 210;
input int    PanelFontSize          = 11;

CTrade   trade;

int      hEmaF = INVALID_HANDLE, hEmaS = INVALID_HANDLE;
int      hAtr  = INVALID_HANDLE, hAdx  = INVALID_HANDLE;
int      hEmaF1 = INVALID_HANDLE, hEmaS1 = INVALID_HANDLE;
int      hEmaF2 = INVALID_HANDLE, hEmaS2 = INVALID_HANDLE;

datetime g_lastBarTime   = 0;
int      g_lastSignalBar = -10000;
int      g_barCounter    = 0;
bool     g_skipFirstBar  = true;

bool     g_pending       = false;
int      g_pendDir       = 0;
double   g_pendEntry = 0, g_pendSl = 0, g_pendTp1 = 0, g_pendTp2 = 0, g_pendTp3 = 0;
double   g_pendLots      = 0;
int      g_pendScore     = 0;
int      g_pendBar       = 0;

ulong    g_ticket        = 0;
double   g_tp1 = 0, g_tp2 = 0, g_tp3 = 0, g_entry = 0, g_riskDist = 0;
bool     g_hit1 = false, g_hit2 = false;

int      g_day            = -1;          // YYYYMMDD
double   g_dayStartEquity = 0;
int      g_dayTrades      = 0;
bool     g_dayBlocked     = false;
double   g_startEquity    = 0;
double   g_peakEquity     = 0;
int      g_consecLoss     = 0;
bool     g_hardStop       = false;
string   g_stopReason     = "";
string   g_msg            = "";

#define PFX   "JASEA_"
#define BTN_B "JASEA_btnBuy"
#define BTN_S "JASEA_btnSell"
#define BTN_X "JASEA_btnSkip"

string Gv(const string key)
  {
   return("JAS21_" + IntegerToString(MagicNumber) + "_" + _Symbol + "_" + key);
  }

void GvSet(const string key, const double v)
  {
   GlobalVariableSet(Gv(key), v);
  }

double GvGet(const string key, const double def=0.0)
  {
   string n = Gv(key);
   if(!GlobalVariableCheck(n)) return(def);
   return(GlobalVariableGet(n));
  }

void PersistRuntime()
  {
   GvSet("peak",   g_peakEquity);
   GvSet("consec", (double)g_consecLoss);
   GvSet("day",    (double)g_day);
   GvSet("dayEq",  g_dayStartEquity);
   GvSet("dayN",   (double)g_dayTrades);
   GvSet("dayBlk", g_dayBlocked ? 1.0 : 0.0);
   GvSet("hard",   g_hardStop ? 1.0 : 0.0);
  }

void PersistTrade()
  {
   GvSet("ticket", (double)g_ticket);
   GvSet("tp1",    g_tp1);
   GvSet("tp2",    g_tp2);
   GvSet("tp3",    g_tp3);
   GvSet("entry",  g_entry);
   GvSet("risk",   g_riskDist);
   GvSet("hit1",   g_hit1 ? 1.0 : 0.0);
   GvSet("hit2",   g_hit2 ? 1.0 : 0.0);
  }

void ClearTradePersist()
  {
   GvSet("ticket", 0);
   GvSet("tp1", 0); GvSet("tp2", 0); GvSet("tp3", 0);
   GvSet("entry", 0); GvSet("risk", 0);
   GvSet("hit1", 0); GvSet("hit2", 0);
  }

int TodayYmd()
  {
   MqlDateTime dt;
   TimeToStruct(TimeCurrent(), dt);
   return(dt.year * 10000 + dt.mon * 100 + dt.day);
  }

int OnInit()
  {
   trade.SetExpertMagicNumber(MagicNumber);
   trade.SetDeviationInPoints(MaxSlippagePoints);
   trade.SetTypeFillingBySymbol(_Symbol);
   trade.LogLevel(LOG_LEVEL_ERRORS);

   hEmaF = iMA(_Symbol, _Period, EmaFast, 0, MODE_EMA, PRICE_CLOSE);
   hEmaS = iMA(_Symbol, _Period, EmaSlow, 0, MODE_EMA, PRICE_CLOSE);
   hAtr  = iATR(_Symbol, _Period, AtrPeriod);
   hAdx  = iADX(_Symbol, _Period, AdxPeriod);

   if(UseHtf)
     {
      hEmaF1 = iMA(_Symbol, Htf1, EmaFast, 0, MODE_EMA, PRICE_CLOSE);
      hEmaS1 = iMA(_Symbol, Htf1, EmaSlow, 0, MODE_EMA, PRICE_CLOSE);
      hEmaF2 = iMA(_Symbol, Htf2, EmaFast, 0, MODE_EMA, PRICE_CLOSE);
      hEmaS2 = iMA(_Symbol, Htf2, EmaSlow, 0, MODE_EMA, PRICE_CLOSE);
      if(hEmaF1 == INVALID_HANDLE || hEmaS1 == INVALID_HANDLE ||
         hEmaF2 == INVALID_HANDLE || hEmaS2 == INVALID_HANDLE)
        {
         Print("HTF indicator handles ban nahi sake.");
         return(INIT_FAILED);
        }
     }

   if(hEmaF == INVALID_HANDLE || hEmaS == INVALID_HANDLE ||
      hAtr  == INVALID_HANDLE || hAdx  == INVALID_HANDLE)
     {
      Print("Indicator handles ban nahi sake.");
      return(INIT_FAILED);
     }

   if(SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE) <= 0.0 ||
      SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE)  <= 0.0 ||
      SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP)      <= 0.0)
     {
      Print("Broker se ", _Symbol, " ke contract specs nahi mile. EA band.");
      Alert("JAS Sniper: ", _Symbol, " ke specs nahi mile. Market Watch mein symbol khol kar dobara try karein.");
      return(INIT_FAILED);
     }

   if(DemoOnly && AccountInfoInteger(ACCOUNT_TRADE_MODE) != ACCOUNT_TRADE_MODE_DEMO)
     {
      Print("DemoOnly = true hai magar ye demo account nahi. EA band.");
      Alert("JAS Sniper EA: ye demo account nahi. Settings mein DemoOnly = false karein.");
      return(INIT_FAILED);
     }

   if(!AccountInfoInteger(ACCOUNT_TRADE_EXPERT))
      Print("Khabardar: is account per algo trading band hai (server side).");
   if(!MQLInfoInteger(MQL_TRADE_ALLOWED))
      Print("Khabardar: terminal mein Algo Trading button band hai.");

   g_startEquity = AccountInfoDouble(ACCOUNT_EQUITY);
   g_peakEquity  = g_startEquity;
   g_day         = TodayYmd();
   g_dayStartEquity = g_startEquity;

   double savedDay = GvGet("day", -1);
   if((int)savedDay == g_day)
     {
      g_dayStartEquity = GvGet("dayEq", g_dayStartEquity);
      g_dayTrades      = (int)GvGet("dayN", 0);
      g_dayBlocked     = (GvGet("dayBlk", 0) > 0.5);
     }
   else
     {
      g_dayTrades  = 0;
      g_dayBlocked = false;
     }

   double savedPeak = GvGet("peak", 0);
   if(savedPeak > g_peakEquity) g_peakEquity = savedPeak;
   g_consecLoss = (int)GvGet("consec", 0);

   if(ClearHardStop)
     {
      g_hardStop = false;
      g_stopReason = "";
      GvSet("hard", 0);
     }
   else if(GvGet("hard", 0) > 0.5)
     {
      g_hardStop   = true;
      g_stopReason = "pehle se saved BAND (ClearHardStop = true karke restart)";
     }

   if(AdoptPosition())
      Print("Pehle se khuli position adopt kar li — ticket ", g_ticket);

   PersistRuntime();

   PrintFormat("JAS Sniper EA v2.1 chalu — %s | %s | %s | risk %.2f%% | %s",
               ModeName(), _Symbol,
               (AccountInfoInteger(ACCOUNT_TRADE_MODE) == ACCOUNT_TRADE_MODE_DEMO ? "DEMO" : "LIVE"),
               RiskPercent, AccountInfoString(ACCOUNT_CURRENCY));

   if(Mode == BOT_AUTO)
      Alert("JAS Sniper v2.1: AUTO chalu — ", _Symbol, " ",
            (AccountInfoInteger(ACCOUNT_TRADE_MODE) == ACCOUNT_TRADE_MODE_DEMO ? "DEMO" : "LIVE ACCOUNT"),
            ", risk ", DoubleToString(RiskPercent, 2), "%");

   return(INIT_SUCCEEDED);
  }

void OnDeinit(const int reason)
  {
   PersistRuntime();
   PersistTrade();
   ObjectsDeleteAll(0, PFX);
   IndicatorRelease(hEmaF); IndicatorRelease(hEmaS);
   IndicatorRelease(hAtr);  IndicatorRelease(hAdx);
   if(UseHtf)
     {
      IndicatorRelease(hEmaF1); IndicatorRelease(hEmaS1);
      IndicatorRelease(hEmaF2); IndicatorRelease(hEmaS2);
     }
   ChartRedraw();
  }

string ModeName()
  {
   if(Mode == BOT_ALERT) return("ALERT");
   if(Mode == BOT_SEMI)  return("SEMI");
   return("AUTO");
  }

double Buf(const int handle, const int buffer, const int shift)
  {
   double v[];
   if(CopyBuffer(handle, buffer, shift, 1, v) < 1) return(0.0);
   return(v[0]);
  }

bool IsNewBar()
  {
   datetime t = iTime(_Symbol, _Period, 0);
   if(t == g_lastBarTime) return(false);
   g_lastBarTime = t;
   g_barCounter++;
   if(g_skipFirstBar)
     {
      g_skipFirstBar = false;
      return(false);
     }
   return(true);
  }

void ResetDay()
  {
   g_day            = TodayYmd();
   g_dayStartEquity = AccountInfoDouble(ACCOUNT_EQUITY);
   g_dayTrades      = 0;
   g_dayBlocked     = false;
   PersistRuntime();
  }

void CheckDayRollover()
  {
   if(TodayYmd() != g_day) ResetDay();
  }

bool InSession()
  {
   MqlDateTime dt;
   TimeToStruct(TimeCurrent(), dt);

   if(BlockWeekend && (dt.day_of_week == 0 || dt.day_of_week == 6))
      return(false);
   if(BlockFridayLate && dt.day_of_week == 5 && dt.hour >= FridayCutoffHour)
      return(false);

   if(!UseSession) return(true);
   if(SessionStartHour <= SessionEndHour)
      return(dt.hour >= SessionStartHour && dt.hour < SessionEndHour);
   return(dt.hour >= SessionStartHour || dt.hour < SessionEndHour);
  }

double SpreadPrice()
  {
   double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   if(ask <= 0.0 || bid <= 0.0) return(1e9);
   return(ask - bid);
  }

bool SpreadOK()
  {
   double spr = SpreadPrice();
   double cap = (MaxSpreadPrice > 0.0) ? MaxSpreadPrice
                                       : MaxSpreadPoints * SymbolInfoDouble(_Symbol, SYMBOL_POINT);
   return(spr <= cap);
  }

int VolDigits()
  {
   double step = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);
   int    d    = 0;
   while(step < 1.0 && d < 8) { step *= 10.0; d++; }
   return(d);
  }

double MinStopDistance()
  {
   double pt = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
   double s  = (double)SymbolInfoInteger(_Symbol, SYMBOL_TRADE_STOPS_LEVEL)  * pt;
   double f  = (double)SymbolInfoInteger(_Symbol, SYMBOL_TRADE_FREEZE_LEVEL) * pt;
   return(MathMax(s, f));
  }

bool CloseAllOurs()
  {
   bool ok = true;
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      ulong t = PositionGetTicket(i);
      if(t == 0 || !PositionSelectByTicket(t)) continue;
      if(PositionGetString(POSITION_SYMBOL) != _Symbol) continue;
      if(PositionGetInteger(POSITION_MAGIC) != MagicNumber) continue;
      if(!trade.PositionClose(t))
        {
         Print("Close fail: ", trade.ResultRetcodeDescription());
         ok = false;
        }
     }
   g_ticket = 0;
   g_hit1 = false; g_hit2 = false;
   g_tp1 = 0; g_tp2 = 0; g_tp3 = 0; g_riskDist = 0;
   ClearTradePersist();
   return(ok);
  }

void HardStop(const string reason)
  {
   if(g_hardStop) return;
   g_hardStop   = true;
   g_stopReason = reason;
   g_msg        = "BAND — " + reason;
   Print("HARD STOP: ", reason);
   Alert("JAS Sniper BAND: ", reason);
   CancelPending("");
   if(FlattenOnHardStop)
     {
      if(CloseAllOurs())
         Print("Hard stop: khuli position band kar di.");
      else
         Print("Hard stop: position band nahi hui — manually close karein.");
     }
   PersistRuntime();
  }

bool IsPivotHigh(const int shift)
  {
   double h = iHigh(_Symbol, _Period, shift);
   if(h <= 0.0) return(false);
   for(int i = 1; i <= PivotLR; i++)
     {
      if(iHigh(_Symbol, _Period, shift + i) >= h) return(false);
      if(iHigh(_Symbol, _Period, shift - i) >= h) return(false);
     }
   return(true);
  }

bool IsPivotLow(const int shift)
  {
   double l = iLow(_Symbol, _Period, shift);
   if(l <= 0.0) return(false);
   for(int i = 1; i <= PivotLR; i++)
     {
      if(iLow(_Symbol, _Period, shift + i) <= l) return(false);
      if(iLow(_Symbol, _Period, shift - i) <= l) return(false);
     }
   return(true);
  }

int SwingScanLimit()
  {
   int lim = Bars(_Symbol, _Period) - PivotLR - 2;
   if(lim > 200) lim = 200;
   return(lim);
  }

bool LastSwingHigh(double &price, int &barShift)
  {
   int maxBar = SwingScanLimit();
   for(int s = PivotLR + 1; s < maxBar; s++)
      if(IsPivotHigh(s))
        { price = iHigh(_Symbol, _Period, s); barShift = s; return(true); }
   return(false);
  }

bool LastSwingLow(double &price, int &barShift)
  {
   int maxBar = SwingScanLimit();
   for(int s = PivotLR + 1; s < maxBar; s++)
      if(IsPivotLow(s))
        { price = iLow(_Symbol, _Period, s); barShift = s; return(true); }
   return(false);
  }

double LowestLow(const int count)
  {
   double lo = iLow(_Symbol, _Period, 1);
   for(int i = 2; i <= count; i++)
     {
      double v = iLow(_Symbol, _Period, i);
      if(v > 0.0 && v < lo) lo = v;
     }
   return(lo);
  }

double HighestHigh(const int count)
  {
   double hi = iHigh(_Symbol, _Period, 1);
   for(int i = 2; i <= count; i++)
     {
      double v = iHigh(_Symbol, _Period, i);
      if(v > hi) hi = v;
     }
   return(hi);
  }

int HtfBias()
  {
   if(!UseHtf) return(0);

   double f1 = Buf(hEmaF1, 0, 1), s1 = Buf(hEmaS1, 0, 1);
   double f2 = Buf(hEmaF2, 0, 1), s2 = Buf(hEmaS2, 0, 1);
   if(f1 == 0.0 || s1 == 0.0 || f2 == 0.0 || s2 == 0.0) return(0);

   int b1 = (f1 > s1) ? 1 : ((f1 < s1) ? -1 : 0);
   int b2 = (f2 > s2) ? 1 : ((f2 < s2) ? -1 : 0);

   if(HtfBothMustAgree)
     {
      if(b1 == 1  && b2 == 1)  return(1);
      if(b1 == -1 && b2 == -1) return(-1);
      return(0);
     }

   if(b1 + b2 > 0) return(1);
   if(b1 + b2 < 0) return(-1);
   return(0);
  }

double LotsForRisk(const double slDistance, string &why)
  {
   why = "";
   if(slDistance <= 0.0) { why = "SL faasla sifar"; return(0.0); }

   double tickValue = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);
   double tickSize  = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);
   double volMin    = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
   double volMax    = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX);
   double volStep   = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);

   if(tickValue <= 0.0 || tickSize <= 0.0 || volStep <= 0.0)
     { why = "Broker specs nahi mile"; return(0.0); }

   double balance   = AccountInfoDouble(ACCOUNT_BALANCE);
   double riskMoney = balance * RiskPercent / 100.0;

   double lossPerLot = (slDistance / tickSize) * tickValue;
   if(CommissionPerLot > 0.0) lossPerLot += CommissionPerLot;
   if(lossPerLot <= 0.0) { why = "Nuqsan ka hisaab nahi bana"; return(0.0); }

   double lots = riskMoney / lossPerLot;
   int vd = VolDigits();
   lots = MathFloor(lots / volStep + 0.0000001) * volStep;
   lots = NormalizeDouble(lots, vd);

   if(lots < volMin - 0.0000001)
     {
      double minRisk = volMin * lossPerLot;
      why = StringFormat("Sab se choti lot (%s) per risk %.2f banta hai, aap ki had %.2f hai",
                         DoubleToString(volMin, vd), minRisk, riskMoney);
      return(0.0);
     }
   if(lots > volMax) lots = NormalizeDouble(volMax, vd);
   return(lots);
  }

bool MarginOK(const int dir, const double lots, const double price, string &why)
  {
   double need = 0.0;
   ENUM_ORDER_TYPE ot = (dir > 0) ? ORDER_TYPE_BUY : ORDER_TYPE_SELL;
   if(!OrderCalcMargin(ot, _Symbol, lots, price, need))
     { why = "Margin ka hisaab nahi bana"; return(false); }

   double freeM = AccountInfoDouble(ACCOUNT_MARGIN_FREE);
   double cap   = freeM * MaxMarginUsePercent / 100.0;
   if(need > cap)
     {
      why = StringFormat("Margin chahiye %.2f, had %.2f (free %.2f)", need, cap, freeM);
      return(false);
     }
   return(true);
  }

double LossMoney(const double slDistance, const double lots)
  {
   double tickValue = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);
   double tickSize  = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);
   if(tickValue <= 0.0 || tickSize <= 0.0) return(0.0);
   double v = (slDistance / tickSize) * tickValue * lots;
   if(CommissionPerLot > 0.0) v += CommissionPerLot * lots;
   return(v);
  }

int BuildScore(const int dir, const bool bos, const bool momo,
               const int htf, const double adx, const bool freshZone)
  {
   int score = 0;
   double f = Buf(hEmaF, 0, 1), s = Buf(hEmaS, 0, 1);
   if(dir > 0 && f > s) score += 20;
   if(dir < 0 && f < s) score += 20;
   if(bos)  score += 15;
   if(momo) score += 15;
   if(htf == dir && htf != 0) score += 20;
   if(UseAdx && adx >= AdxMin) score += 15;
   else if(!UseAdx)            score += 15;
   if(freshZone) score += 15;
   if(score > 100) score = 100;
   return(score);
  }

int FindSignal(double &sl, double &tp1, double &tp2, double &tp3, int &score)
  {
   sl = tp1 = tp2 = tp3 = 0.0; score = 0;
   if(Bars(_Symbol, _Period) < 250) return(0);

   double atr = Buf(hAtr, 0, 1);
   if(atr <= 0.0) return(0);

   double emaF = Buf(hEmaF, 0, 1);
   double emaS = Buf(hEmaS, 0, 1);
   double adx  = Buf(hAdx, 0, 1);
   if(emaF == 0.0 || emaS == 0.0) return(0);
   if(UseAdx && adx < AdxMin) return(0);

   double swHigh = 0, swLow = 0;
   int    shBar = 0, slBar = 0;
   if(!LastSwingHigh(swHigh, shBar)) return(0);
   if(!LastSwingLow(swLow, slBar))   return(0);

   int htf = HtfBias();

   bool bosUp = false, bosDn = false;
   int  upWin = StructLookback; if(upWin > shBar - 1) upWin = shBar - 1;
   int  dnWin = StructLookback; if(dnWin > slBar - 1) dnWin = slBar - 1;
   for(int i = 1; i <= upWin; i++)
      if(iClose(_Symbol, _Period, i) > swHigh) { bosUp = true; break; }
   for(int i = 1; i <= dnWin; i++)
      if(iClose(_Symbol, _Period, i) < swLow)  { bosDn = true; break; }

   double lo1  = iLow(_Symbol, _Period, 1);
   double hi1  = iHigh(_Symbol, _Period, 1);
   double cl1  = iClose(_Symbol, _Period, 1);
   double tol  = 0.45 * atr;
   bool retestUp = (lo1 <= emaF + tol && cl1 > emaF);
   bool retestDn = (hi1 >= emaF - tol && cl1 < emaF);
   bool trendUp = (emaF > emaS);
   bool trendDn = (emaF < emaS);
   bool freshUp = (slBar <= 40);
   bool freshDn = (shBar <= 40);

   int dir = 0;
   if(trendUp && bosUp && retestUp && (!UseHtf || htf ==  1)) dir =  1;
   if(trendDn && bosDn && retestDn && (!UseHtf || htf == -1)) dir = -1;
   if(dir == 0) return(0);

   score = BuildScore(dir, (dir > 0 ? bosUp : bosDn),
                      (dir > 0 ? retestUp : retestDn),
                      htf, adx, (dir > 0 ? freshUp : freshDn));
   if(UseScore && score < MinScore) return(0);

   double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   if(ask <= 0.0 || bid <= 0.0) return(0);
   double entry = (dir > 0 ? ask : bid);

   double raw;
   if(dir > 0) raw = LowestLow(SlSwingLookback)   - SlBufferAtr * atr;
   else        raw = HighestHigh(SlSwingLookback) + SlBufferAtr * atr;

   double dist = MathAbs(entry - raw);
   double minD = MinSlAtr * atr;
   double maxD = MaxSlAtr * atr;
   if(dist < minD) dist = minD;
   if(dist > maxD) dist = maxD;

   double stopsLevel = MinStopDistance();
   if(dist < stopsLevel * 1.2) dist = stopsLevel * 1.2;

   sl  = (dir > 0 ? entry - dist : entry + dist);
   tp1 = (dir > 0 ? entry + dist * Tp1R : entry - dist * Tp1R);
   tp2 = (dir > 0 ? entry + dist * Tp2R : entry - dist * Tp2R);
   tp3 = (dir > 0 ? entry + dist * Tp3R : entry - dist * Tp3R);

   int d = (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS);
   sl  = NormalizeDouble(sl,  d);
   tp1 = NormalizeDouble(tp1, d);
   tp2 = NormalizeDouble(tp2, d);
   tp3 = NormalizeDouble(tp3, d);
   return(dir);
  }

int CountOurPositions()
  {
   int n = 0;
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      ulong t = PositionGetTicket(i);
      if(t == 0 || !PositionSelectByTicket(t)) continue;
      if(PositionGetString(POSITION_SYMBOL) != _Symbol) continue;
      if(PositionGetInteger(POSITION_MAGIC) != MagicNumber) continue;
      n++;
     }
   return(n);
  }

bool AdoptPosition()
  {
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      ulong t = PositionGetTicket(i);
      if(t == 0 || !PositionSelectByTicket(t)) continue;
      if(PositionGetString(POSITION_SYMBOL) != _Symbol) continue;
      if(PositionGetInteger(POSITION_MAGIC) != MagicNumber) continue;

      g_ticket = t;
      g_entry  = PositionGetDouble(POSITION_PRICE_OPEN);
      double slNow = PositionGetDouble(POSITION_SL);
      double tpNow = PositionGetDouble(POSITION_TP);
      long   type  = PositionGetInteger(POSITION_TYPE);
      int    dir   = (type == POSITION_TYPE_BUY) ? 1 : -1;

      ulong savedT = (ulong)GvGet("ticket", 0);
      if(savedT == t)
        {
         g_tp1      = GvGet("tp1", 0);
         g_tp2      = GvGet("tp2", 0);
         g_tp3      = GvGet("tp3", tpNow);
         g_riskDist = GvGet("risk", 0);
         g_hit1     = (GvGet("hit1", 0) > 0.5);
         g_hit2     = (GvGet("hit2", 0) > 0.5);
         if(g_entry <= 0.0) g_entry = GvGet("entry", g_entry);
        }
      else
        {
         g_tp3 = tpNow;
         if(slNow > 0.0)
           {
            g_riskDist = MathAbs(g_entry - slNow);
            g_hit1 = (dir > 0) ? (slNow >= g_entry - _Point)
                               : (slNow <= g_entry + _Point);
            if(g_hit1)
              {
               g_hit2 = true;
               g_tp1  = 0;
               g_tp2  = 0;
              }
            else
              {
               g_tp1 = g_entry + dir * g_riskDist * Tp1R;
               g_tp2 = g_entry + dir * g_riskDist * Tp2R;
               g_hit2 = false;
              }
           }
         else
           {
            g_riskDist = 0;
            g_hit1 = true;
            g_hit2 = true;
            g_tp1 = 0; g_tp2 = 0;
           }
        }

      double cur = (dir > 0) ? SymbolInfoDouble(_Symbol, SYMBOL_BID)
                             : SymbolInfoDouble(_Symbol, SYMBOL_ASK);
      if(g_tp2 > 0.0)
        {
         bool past2 = (dir > 0) ? (cur >= g_tp2) : (cur <= g_tp2);
         if(past2) { g_hit1 = true; g_hit2 = true; }
        }
      PersistTrade();
      return(true);
     }
   return(false);
  }

double TrueBE(const long type, const double open)
  {
   double spr = SpreadPrice();
   double buf = BeBufferPoints * SymbolInfoDouble(_Symbol, SYMBOL_POINT);
   if(type == POSITION_TYPE_BUY)  return(open + spr + buf);
   return(open - spr - buf);
  }

bool SafeModify(const double newSl, const double newTp)
  {
   if(!PositionSelectByTicket(g_ticket)) return(false);

   long   type = PositionGetInteger(POSITION_TYPE);
   double cur  = (type == POSITION_TYPE_BUY)
                 ? SymbolInfoDouble(_Symbol, SYMBOL_BID)
                 : SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   double minD = MinStopDistance();
   int    d    = (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS);

   double sl = newSl;
   if(sl > 0.0)
     {
      if(type == POSITION_TYPE_BUY  && sl > cur - minD) return(false);
      if(type == POSITION_TYPE_SELL && sl < cur + minD) return(false);
     }
   sl = NormalizeDouble(sl, d);
   return(trade.PositionModify(g_ticket, sl, NormalizeDouble(newTp, d)));
  }

void ManageOpenPosition()
  {
   if(g_ticket == 0) return;
   if(!PositionSelectByTicket(g_ticket))
     {
      g_ticket = 0; g_hit1 = false; g_hit2 = false;
      g_tp1 = 0; g_tp2 = 0; g_tp3 = 0; g_riskDist = 0;
      ClearTradePersist();
      return;
     }

   long   type = PositionGetInteger(POSITION_TYPE);
   double vol  = PositionGetDouble(POSITION_VOLUME);
   double open = PositionGetDouble(POSITION_PRICE_OPEN);
   double curTp = PositionGetDouble(POSITION_TP);
   double cur  = (type == POSITION_TYPE_BUY)
                 ? SymbolInfoDouble(_Symbol, SYMBOL_BID)
                 : SymbolInfoDouble(_Symbol, SYMBOL_ASK);

   double volStep = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);
   double volMin  = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
   int    vd      = VolDigits();

   if(!g_hit1 && g_tp1 > 0.0)
     {
      bool reached = (type == POSITION_TYPE_BUY) ? (cur >= g_tp1) : (cur <= g_tp1);
      if(reached)
        {
         double part = NormalizeDouble(
                          MathFloor(vol * Tp1ClosePercent / 100.0 / volStep + 0.0000001) * volStep, vd);
         if(part >= volMin && (vol - part) >= volMin)
           {
            if(trade.PositionClosePartial(g_ticket, part))
               PrintFormat("TP1 — %s lots band.", DoubleToString(part, vd));
           }
         g_hit1 = true;
         PersistTrade();

         if(BreakevenAfterTp1)
           {
            double be = TrueBE(type, open);
            if(SafeModify(be, curTp))
               Print("SL true-breakeven per aa gaya (spread+buffer).");
            else
               Print("Breakeven abhi nahi lag saka (price stop level ke qareeb hai).");
           }
        }
     }

   if(g_hit1 && !g_hit2 && g_tp2 > 0.0)
     {
      bool reached = (type == POSITION_TYPE_BUY) ? (cur >= g_tp2) : (cur <= g_tp2);
      if(reached)
        {
         if(!PositionSelectByTicket(g_ticket)) return;
         vol = PositionGetDouble(POSITION_VOLUME);
         double part = NormalizeDouble(
                          MathFloor(vol * Tp2ClosePercent / 100.0 / volStep + 0.0000001) * volStep, vd);
         if(part >= volMin && (vol - part) >= volMin)
           {
            if(trade.PositionClosePartial(g_ticket, part))
               PrintFormat("TP2 — %s lots band.", DoubleToString(part, vd));
           }
         g_hit2 = true;
         PersistTrade();
        }
     }

   if(g_hit2 && TrailAfterTp2)
     {
      double atr = Buf(hAtr, 0, 1);
      if(atr > 0.0)
        {
         if(!PositionSelectByTicket(g_ticket)) return;
         double slNow = PositionGetDouble(POSITION_SL);
         double want  = (type == POSITION_TYPE_BUY) ? cur - TrailAtr * atr
                                                    : cur + TrailAtr * atr;
         bool better = (type == POSITION_TYPE_BUY)
                       ? (slNow <= 0.0 || want > slNow + _Point)
                       : (slNow <= 0.0 || want < slNow - _Point);
         if(better) SafeModify(want, PositionGetDouble(POSITION_TP));
        }
     }
  }

void RecheckFillRisk(const int dir)
  {
   if(g_ticket == 0 || !PositionSelectByTicket(g_ticket)) return;
   double open = PositionGetDouble(POSITION_PRICE_OPEN);
   double sl   = PositionGetDouble(POSITION_SL);
   double lots = PositionGetDouble(POSITION_VOLUME);
   if(sl <= 0.0) return;

   double dist = MathAbs(open - sl);
   double loss = LossMoney(dist, lots);
   double cap  = AccountInfoDouble(ACCOUNT_BALANCE) * RiskPercent / 100.0 * MaxRiskSlippageMult;
   if(loss > cap && cap > 0.0)
     {
      PrintFormat("Fill risk %.2f had %.2f se zyada — position band.", loss, cap);
      trade.PositionClose(g_ticket);
      g_msg = "Fill slippage: risk had se zyada, trade band.";
      g_ticket = 0;
      ClearTradePersist();
     }
  }

void OpenTrade(const int dir, const double lots,
               const double sl, const double tp3v)
  {
   bool ok;
   if(dir > 0) ok = trade.Buy (lots, _Symbol, 0.0, sl, tp3v, "JAS Sniper");
   else        ok = trade.Sell(lots, _Symbol, 0.0, sl, tp3v, "JAS Sniper");

   if(!ok)
     {
      g_msg = "Order nahi gaya: " + IntegerToString(trade.ResultRetcode())
              + " " + trade.ResultRetcodeDescription();
      Print(g_msg);
      return;
     }

   g_ticket = 0;
   ulong deal = trade.ResultDeal();
   if(deal > 0 && HistoryDealSelect(deal))
      g_ticket = (ulong)HistoryDealGetInteger(deal, DEAL_POSITION_ID);
   if(g_ticket == 0 || !PositionSelectByTicket(g_ticket))
     {
      g_ticket = trade.ResultOrder();
      if(g_ticket == 0 || !PositionSelectByTicket(g_ticket))
        {
         g_ticket = 0;
         AdoptPosition();
        }
     }

   g_hit1 = false; g_hit2 = false;
   g_dayTrades++;
   PersistRuntime();
   PersistTrade();
   RecheckFillRisk(dir);

   g_msg = StringFormat("Trade khuli — %s %s lots", (dir > 0 ? "BUY" : "SELL"),
                        DoubleToString(lots, VolDigits()));
   Print(g_msg);
  }

void OnTradeTransaction(const MqlTradeTransaction &trans,
                        const MqlTradeRequest    &request,
                        const MqlTradeResult     &result)
  {
   if(trans.type != TRADE_TRANSACTION_DEAL_ADD) return;
   if(trans.deal == 0) return;
   if(!HistoryDealSelect(trans.deal)) return;
   if(HistoryDealGetString(trans.deal, DEAL_SYMBOL) != _Symbol) return;
   if(HistoryDealGetInteger(trans.deal, DEAL_MAGIC) != MagicNumber) return;

   long entryType = HistoryDealGetInteger(trans.deal, DEAL_ENTRY);
   if(entryType != DEAL_ENTRY_OUT && entryType != DEAL_ENTRY_OUT_BY) return;

   ulong pid = (ulong)HistoryDealGetInteger(trans.deal, DEAL_POSITION_ID);
   if(pid == 0) return;
   if(PositionSelectByTicket(pid)) return;

   double total = 0.0;
   if(HistorySelectByPosition(pid))
     {
      int n = HistoryDealsTotal();
      for(int i = 0; i < n; i++)
        {
         ulong d = HistoryDealGetTicket(i);
         if(d == 0) continue;
         total += HistoryDealGetDouble(d, DEAL_PROFIT)
                + HistoryDealGetDouble(d, DEAL_SWAP)
                + HistoryDealGetDouble(d, DEAL_COMMISSION);
        }
     }

   if(total < 0.0) g_consecLoss++;
   else if(total > 0.0) g_consecLoss = 0;

   PrintFormat("Position %I64u band — nateeja %.2f | musalsal losses %d",
               pid, total, g_consecLoss);

   if(g_ticket == pid)
     {
      g_ticket = 0; g_hit1 = false; g_hit2 = false;
      g_tp1 = 0; g_tp2 = 0; g_tp3 = 0; g_riskDist = 0;
      ClearTradePersist();
     }

   PersistRuntime();

   if(MaxConsecutiveLosses > 0 && g_consecLoss >= MaxConsecutiveLosses)
      HardStop(StringFormat("Musalsal %d losses", g_consecLoss));
  }

void MakeButton(const string name, const string text,
                const int y, const color bg)
  {
   if(ObjectFind(0, name) < 0)
      ObjectCreate(0, name, OBJ_BUTTON, 0, 0, 0);
   ObjectSetInteger(0, name, OBJPROP_CORNER,    CORNER_LEFT_UPPER);
   ObjectSetInteger(0, name, OBJPROP_XDISTANCE, PanelX);
   ObjectSetInteger(0, name, OBJPROP_YDISTANCE, y);
   ObjectSetInteger(0, name, OBJPROP_XSIZE,     150);
   ObjectSetInteger(0, name, OBJPROP_YSIZE,     28);
   ObjectSetInteger(0, name, OBJPROP_BGCOLOR,   bg);
   ObjectSetInteger(0, name, OBJPROP_COLOR,     clrWhite);
   ObjectSetInteger(0, name, OBJPROP_FONTSIZE,  PanelFontSize);
   ObjectSetString (0, name, OBJPROP_FONT,      "Arial Bold");
   ObjectSetString (0, name, OBJPROP_TEXT,      text);
   ObjectSetInteger(0, name, OBJPROP_STATE,     false);
   ObjectSetInteger(0, name, OBJPROP_HIDDEN,    true);
  }

void ShowConfirmButtons()
  {
   int y = PanelY + 130;
   if(g_pendDir > 0)
      MakeButton(BTN_B, StringFormat("BUY  %s lots", DoubleToString(g_pendLots, VolDigits())), y, C'20,110,70');
   else
      MakeButton(BTN_S, StringFormat("SELL %s lots", DoubleToString(g_pendLots, VolDigits())), y, C'150,45,30');
   MakeButton(BTN_X, "SKIP", y + 32, C'70,70,70');
   ChartRedraw();
  }

void ClearConfirmButtons()
  {
   ObjectDelete(0, BTN_B);
   ObjectDelete(0, BTN_S);
   ObjectDelete(0, BTN_X);
   ChartRedraw();
  }

void CancelPending(const string reason)
  {
   g_pending = false;
   g_pendDir = 0;
   ClearConfirmButtons();
   if(reason != "") g_msg = reason;
  }

void OnChartEvent(const int id, const long &lparam,
                  const double &dparam, const string &sparam)
  {
   if(id != CHARTEVENT_OBJECT_CLICK) return;
   if(!g_pending) return;

   if(sparam == BTN_X)
     { CancelPending("Aap ne SKIP kiya."); return; }

   if(sparam == BTN_B || sparam == BTN_S)
     {
      int dir = g_pendDir;
      double sl, tp1, tp2, tp3;
      int score = 0;
      int nowDir = FindSignal(sl, tp1, tp2, tp3, score);
      if(nowDir != dir)
        {
         CancelPending("Signal click tak khatam / reverse ho gaya.");
         return;
        }

      double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
      double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
      double entry = (dir > 0 ? ask : bid);
      string why = "";
      double lots = LotsForRisk(MathAbs(entry - sl), why);
      if(lots <= 0.0 || !MarginOK(dir, lots, entry, why))
        {
         CancelPending("Click per risk/margin fail — " + why);
         return;
        }
      if(!SpreadOK())
        {
         CancelPending("Spread ab had se zyada.");
         return;
        }

      g_tp1 = tp1; g_tp2 = tp2; g_tp3 = tp3; g_entry = entry;
      g_riskDist = MathAbs(entry - sl);
      CancelPending("");
      OpenTrade(dir, lots, sl, tp3);
     }
  }

void SetLabel(const int row, const string txt, const color clr)
  {
   string nm = "JASEA_lbl" + IntegerToString(row);
   if(ObjectFind(0, nm) < 0)
     {
      ObjectCreate(0, nm, OBJ_LABEL, 0, 0, 0);
      ObjectSetInteger(0, nm, OBJPROP_CORNER,     CORNER_LEFT_UPPER);
      ObjectSetInteger(0, nm, OBJPROP_XDISTANCE,  PanelX);
      ObjectSetInteger(0, nm, OBJPROP_YDISTANCE,  PanelY + row * (PanelFontSize + 6));
      ObjectSetInteger(0, nm, OBJPROP_FONTSIZE,   PanelFontSize);
      ObjectSetString (0, nm, OBJPROP_FONT,       "Consolas Bold");
      ObjectSetInteger(0, nm, OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, nm, OBJPROP_HIDDEN,     true);
     }
   ObjectSetString (0, nm, OBJPROP_TEXT,  txt);
   ObjectSetInteger(0, nm, OBJPROP_COLOR, clr);
  }

void DrawPanel()
  {
   double eq     = AccountInfoDouble(ACCOUNT_EQUITY);
   double dayPl  = eq - g_dayStartEquity;
   double dayPct = (g_dayStartEquity > 0.0) ? (dayPl / g_dayStartEquity * 100.0) : 0.0;
   double ddPct  = (g_peakEquity > 0.0) ? ((g_peakEquity - eq) / g_peakEquity * 100.0) : 0.0;
   string cur    = AccountInfoString(ACCOUNT_CURRENCY);
   bool   isDemo = (AccountInfoInteger(ACCOUNT_TRADE_MODE) == ACCOUNT_TRADE_MODE_DEMO);

   SetLabel(0, "JAS SNIPER v2.1  —  " + ModeName() + "  [" + (isDemo ? "DEMO" : "LIVE") + "]  " + _Symbol,
            (isDemo ? clrGold : clrOrangeRed));
   SetLabel(1, StringFormat("Equity  %.2f %s   |  Din %+.2f (%+.2f%%)  |  DD %.1f%%",
                            eq, cur, dayPl, dayPct, ddPct),
            (dayPl >= 0 ? clrLime : clrTomato));
   SetLabel(2, StringFormat("Trades aaj %d/%d  |  Musalsal loss %d/%d  |  Spread %.2f",
                            g_dayTrades, MaxTradesPerDay,
                            g_consecLoss, MaxConsecutiveLosses, SpreadPrice()), clrWhite);

   if(g_hardStop)
      SetLabel(3, "BAND — " + g_stopReason, clrRed);
   else if(g_dayBlocked)
      SetLabel(3, "RUKA HUA — din ki had lag gayi", clrTomato);
   else if(g_ticket != 0)
      SetLabel(3, StringFormat("Position khuli  |  TP1 %s %s  TP2 %s",
                               DoubleToString(g_tp1, _Digits), (g_hit1 ? "OK" : "  "),
                               (g_hit2 ? "OK" : "-")), clrAqua);
   else if(g_pending)
      SetLabel(3, StringFormat("SIGNAL  %s  score %d  —  button dabayen",
                               (g_pendDir > 0 ? "BUY" : "SELL"), g_pendScore), clrYellow);
   else
      SetLabel(3, "Setup ka intezaar...", clrSilver);

   SetLabel(4, (g_msg == "" ? " " : g_msg), clrSilver);
   ChartRedraw();
  }

int MaxOpenPositionsEffective() { return(1); }

void OnTick()
  {
   CheckDayRollover();
   ManageOpenPosition();

   double eq = AccountInfoDouble(ACCOUNT_EQUITY);
   if(eq > g_peakEquity)
     {
      g_peakEquity = eq;
      PersistRuntime();
     }

   if(!g_hardStop && g_peakEquity > 0.0 && MaxTotalDDPercent > 0.0)
     {
      double ddPct = (g_peakEquity - eq) / g_peakEquity * 100.0;
      if(ddPct >= MaxTotalDDPercent)
         HardStop(StringFormat("Kul drawdown %.1f%% (had %.1f%%)", ddPct, MaxTotalDDPercent));
     }

   if(g_dayStartEquity > 0.0 && !g_dayBlocked)
     {
      double lossPct = (g_dayStartEquity - eq) / g_dayStartEquity * 100.0;
      if(lossPct >= MaxDailyLossPercent)
        {
         g_dayBlocked = true;
         g_msg = "Din ki nuqsan ki had lag gayi — aaj aur trade nahi.";
         Print(g_msg);
         CancelPending("");
         if(FlattenOnDailyLoss) CloseAllOurs();
         PersistRuntime();
        }
     }

   if(!IsNewBar())
     {
      DrawPanel();
      return;
     }

   if(g_pending && (g_barCounter - g_pendBar) >= ConfirmExpiryBars)
      CancelPending("Signal ki miyaad khatam — button hata diya.");

   DrawPanel();

   if(g_hardStop)                                      return;
   if(g_dayBlocked)                                    return;
   if(g_pending)                                       return;
   if(!MQLInfoInteger(MQL_TRADE_ALLOWED))              return;
   if(CountOurPositions() >= MaxOpenPositionsEffective()) return;
   if(g_dayTrades >= MaxTradesPerDay)                  return;
   if(!InSession())                                    return;
   if(!SpreadOK())                                     return;
   if((g_barCounter - g_lastSignalBar) < CooldownBars) return;

   double sl, tp1, tp2, tp3;
   int    score = 0;
   int    dir = FindSignal(sl, tp1, tp2, tp3, score);
   if(dir == 0) return;

   double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   double entry = (dir > 0 ? ask : bid);

   string why = "";
   double lots = LotsForRisk(MathAbs(entry - sl), why);
   if(lots <= 0.0)
     {
      g_msg = "Trade chhori — " + why;
      Print(g_msg);
      g_lastSignalBar = g_barCounter;
      return;
     }
   if(!MarginOK(dir, lots, entry, why))
     {
      g_msg = "Trade chhori — " + why;
      Print(g_msg);
      g_lastSignalBar = g_barCounter;
      return;
     }

   g_lastSignalBar = g_barCounter;

   string line = StringFormat("%s  score %d  |  Entry %s  SL %s  TP1 %s  |  %s lots",
                              (dir > 0 ? "BUY" : "SELL"), score,
                              DoubleToString(entry, _Digits),
                              DoubleToString(sl,    _Digits),
                              DoubleToString(tp1,   _Digits),
                              DoubleToString(lots, VolDigits()));

   if(Mode == BOT_ALERT)
     {
      g_msg = "SIGNAL — " + line;
      Alert("JAS Sniper: ", line);
      Print(g_msg);
      return;
     }

   if(Mode == BOT_SEMI)
     {
      g_pending   = true;
      g_pendDir   = dir;
      g_pendEntry = entry;
      g_pendSl    = sl;
      g_pendTp1   = tp1;
      g_pendTp2   = tp2;
      g_pendTp3   = tp3;
      g_pendLots  = lots;
      g_pendScore = score;
      g_pendBar   = g_barCounter;
      g_msg       = "Manzoori ka intezaar — " + line;
      ShowConfirmButtons();
      Alert("JAS Sniper: ", line, " — chart per button dabayen");
      return;
     }

   g_tp1 = tp1; g_tp2 = tp2; g_tp3 = tp3; g_entry = entry;
   g_riskDist = MathAbs(entry - sl);
   OpenTrade(dir, lots, sl, tp3);
  }
//+------------------------------------------------------------------+
