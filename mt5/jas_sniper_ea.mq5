//+------------------------------------------------------------------+
//|                                              jas_sniper_ea.mq5   |
//|                                                                  |
//|  JAS SNIPER EA v1 — XAUUSD structure + trend bot                 |
//|                                                                  |
//|  Andaz (Mode):                                                   |
//|    ALERT  — sirf ittila deta hai, kuch nahi karta                |
//|    SEMI   — signal per chart per button aata hai, aap dabate ho  |
//|    AUTO   — khud trade kholta aur band karta hai                 |
//|                                                                  |
//|  Risk engine broker se asal contract specs parhta hai, is liye   |
//|  cent (USC) aur standard dono per theek chalta hai. Agar sab se  |
//|  choti lot bhi aap ki risk limit se barh jaye to trade NAHI leta.|
//|                                                                  |
//|  PEHLE DEMO PER. DemoOnly = true rehne dein jab tak aap khud     |
//|  natije se mutmain na ho jayen.                                  |
//+------------------------------------------------------------------+
#property copyright "JAS Sniper"
#property version   "1.00"
#property strict

#include <Trade\Trade.mqh>

//============================ INPUTS =================================

enum ENUM_BOT_MODE
  {
   BOT_ALERT = 0,  // ALERT — sirf ittila
   BOT_SEMI  = 1,  // SEMI  — aap ki manzoori se
   BOT_AUTO  = 2   // AUTO  — khud trade kare
  };

input ENUM_BOT_MODE Mode            = BOT_SEMI;  // Andaz
input bool   DemoOnly               = true;      // Sirf demo account per chale
input long   MagicNumber            = 786451;    // Magic number

// ---- Risk ----
input double RiskPercent            = 2.0;       // Risk fi trade (%)
input double MaxDailyLossPercent    = 6.0;       // Din ka zyada se zyada nuqsan (%)
input int    MaxTradesPerDay        = 3;         // Din mein zyada se zyada trades
input int    MaxOpenPositions       = 1;         // Aik waqt mein khuli positions

// ---- Stop / Target ----
input int    AtrPeriod              = 14;        // ATR period
input double SlBufferAtr            = 0.25;      // SL buffer (x ATR)
input double MinSlAtr               = 0.60;      // SL kam az kam (x ATR)
input double MaxSlAtr               = 3.50;      // SL zyada se zyada (x ATR)
input int    SlSwingLookback        = 10;        // Structure SL ke liye bars
input double Tp1R                   = 1.0;       // TP1 (R)
input double Tp2R                   = 2.0;       // TP2 (R)
input double Tp3R                   = 3.0;       // TP3 (R)
input double Tp1ClosePercent        = 50.0;      // TP1 per kitni % band karein
input bool   BreakevenAfterTp1      = true;      // TP1 ke baad SL breakeven per

// ---- Structure / Trend ----
input int    PivotLR                = 3;         // Pivot L/R (swings)
input int    StructLookback         = 6;         // BOS ke baad kitne bars tak entry
input int    EmaFast                = 20;        // EMA fast
input int    EmaSlow                = 50;        // EMA slow
input bool   UseAdx                 = true;      // ADX filter
input int    AdxPeriod              = 14;        // ADX period
input double AdxMin                 = 18.0;      // ADX kam az kam

// ---- HTF confluence ----
input bool             UseHtf       = true;              // HTF confluence
input ENUM_TIMEFRAMES  Htf1         = PERIOD_H4;         // HTF 1
input ENUM_TIMEFRAMES  Htf2         = PERIOD_D1;         // HTF 2
input bool             HtfBothMustAgree = false;         // Dono HTF muttafiq hon

// ---- Score gate ----
input bool   UseScore               = true;      // Score se signal rokein
input int    MinScore               = 60;        // Kam az kam score (0-100)

// ---- Guards ----
input double MaxSpreadPoints        = 400;       // Spread is se zyada ho to na trade kare
input int    CooldownBars           = 5;         // Do signals ke darmiyan bars
input bool   UseSession             = true;      // Sirf chuni hui sessions mein
input int    SessionStartHour       = 7;         // Session shuru (server time)
input int    SessionEndHour         = 20;        // Session khatam (server time)
input int    ConfirmExpiryBars      = 3;         // SEMI: button kitne bars tak zinda rahe

// ---- Panel ----
input int    PanelX                 = 12;        // Panel — bayen se doori
input int    PanelY                 = 210;       // Panel — upar se doori
input int    PanelFontSize          = 11;        // Panel font size

//============================ GLOBALS ================================

CTrade   trade;

int      hEmaF = INVALID_HANDLE, hEmaS = INVALID_HANDLE;
int      hAtr  = INVALID_HANDLE, hAdx  = INVALID_HANDLE;
int      hEmaF1 = INVALID_HANDLE, hEmaS1 = INVALID_HANDLE;
int      hEmaF2 = INVALID_HANDLE, hEmaS2 = INVALID_HANDLE;

datetime g_lastBarTime   = 0;
int      g_lastSignalBar = -10000;
int      g_barCounter    = 0;

// pending confirmation (SEMI mode)
bool     g_pending       = false;
int      g_pendDir       = 0;        // +1 buy, -1 sell
double   g_pendEntry = 0, g_pendSl = 0, g_pendTp1 = 0, g_pendTp2 = 0, g_pendTp3 = 0;
double   g_pendLots      = 0;
int      g_pendScore     = 0;
int      g_pendBar       = 0;

// live position bookkeeping
ulong    g_ticket        = 0;
double   g_tp1 = 0, g_tp2 = 0, g_entry = 0;
bool     g_hit1 = false, g_hit2 = false;

// daily counters
int      g_day           = -1;
double   g_dayStartEquity = 0;
int      g_dayTrades     = 0;
bool     g_dayBlocked    = false;

string   g_msg           = "";

#define PFX   "JASEA_"
#define BTN_B "JASEA_btnBuy"
#define BTN_S "JASEA_btnSell"
#define BTN_X "JASEA_btnSkip"

//============================ INIT ===================================

int OnInit()
  {
   trade.SetExpertMagicNumber(MagicNumber);
   trade.SetDeviationInPoints(30);
   trade.SetTypeFillingBySymbol(_Symbol);

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
     }

   if(hEmaF == INVALID_HANDLE || hEmaS == INVALID_HANDLE ||
      hAtr  == INVALID_HANDLE || hAdx  == INVALID_HANDLE)
     {
      Print("Indicator handles ban nahi sake.");
      return(INIT_FAILED);
     }

   if(DemoOnly && AccountInfoInteger(ACCOUNT_TRADE_MODE) != ACCOUNT_TRADE_MODE_DEMO)
     {
      Print("DemoOnly = true hai magar ye demo account nahi. EA band.");
      Alert("JAS Sniper EA: ye demo account nahi. Settings mein DemoOnly band karein.");
      return(INIT_FAILED);
     }

   ResetDay();
   Print("JAS Sniper EA chalu — mode: ", ModeName());
   return(INIT_SUCCEEDED);
  }

void OnDeinit(const int reason)
  {
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

//============================ HELPERS ================================

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
   return(true);
  }

void ResetDay()
  {
   MqlDateTime dt;
   TimeToStruct(TimeCurrent(), dt);
   g_day            = dt.day;
   g_dayStartEquity = AccountInfoDouble(ACCOUNT_EQUITY);
   g_dayTrades      = 0;
   g_dayBlocked     = false;
  }

void CheckDayRollover()
  {
   MqlDateTime dt;
   TimeToStruct(TimeCurrent(), dt);
   if(dt.day != g_day) ResetDay();
  }

bool InSession()
  {
   if(!UseSession) return(true);
   MqlDateTime dt;
   TimeToStruct(TimeCurrent(), dt);
   if(SessionStartHour <= SessionEndHour)
      return(dt.hour >= SessionStartHour && dt.hour < SessionEndHour);
   return(dt.hour >= SessionStartHour || dt.hour < SessionEndHour);
  }

double SpreadPoints()
  {
   return((double)SymbolInfoInteger(_Symbol, SYMBOL_SPREAD));
  }

//--- swings ---------------------------------------------------------

bool IsPivotHigh(const int shift)
  {
   double h = iHigh(_Symbol, _Period, shift);
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
   for(int i = 1; i <= PivotLR; i++)
     {
      if(iLow(_Symbol, _Period, shift + i) <= l) return(false);
      if(iLow(_Symbol, _Period, shift - i) <= l) return(false);
     }
   return(true);
  }

// Aakhri confirmed swing high. Milne per true.
bool LastSwingHigh(double &price, int &barShift)
  {
   for(int s = PivotLR + 1; s < 200; s++)
      if(IsPivotHigh(s))
        { price = iHigh(_Symbol, _Period, s); barShift = s; return(true); }
   return(false);
  }

bool LastSwingLow(double &price, int &barShift)
  {
   for(int s = PivotLR + 1; s < 200; s++)
      if(IsPivotLow(s))
        { price = iLow(_Symbol, _Period, s); barShift = s; return(true); }
   return(false);
  }

// SlSwingLookback bars mein sab se neechi low / sab se unchi high
double LowestLow(const int count)
  {
   double lo = iLow(_Symbol, _Period, 1);
   for(int i = 2; i <= count; i++)
     {
      double v = iLow(_Symbol, _Period, i);
      if(v < lo) lo = v;
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

//--- HTF ------------------------------------------------------------

int HtfBias()   // +1 up, -1 down, 0 mixed / off
  {
   if(!UseHtf) return(0);

   double f1 = Buf(hEmaF1, 0, 1), s1 = Buf(hEmaS1, 0, 1);
   double f2 = Buf(hEmaF2, 0, 1), s2 = Buf(hEmaS2, 0, 1);
   if(f1 == 0.0 || s1 == 0.0 || f2 == 0.0 || s2 == 0.0) return(0);

   bool up1 = (f1 > s1), up2 = (f2 > s2);
   bool dn1 = (f1 < s1), dn2 = (f2 < s2);

   if(HtfBothMustAgree)
     {
      if(up1 && up2) return(1);
      if(dn1 && dn2) return(-1);
      return(0);
     }
   if(up1 || up2) { if(!(dn1 && dn2)) return(1); }
   if(dn1 || dn2) { if(!(up1 && up2)) return(-1); }
   return(0);
  }

//============================ RISK ===================================

// SL ke faasle se lots nikalta hai — broker ke asal specs se.
// Na ho sake to 0 lautata hai (yani trade na lein).
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

   // 1 lot per is SL ka nuqsan
   double lossPerLot = (slDistance / tickSize) * tickValue;
   if(lossPerLot <= 0.0) { why = "Nuqsan ka hisaab nahi bana"; return(0.0); }

   double lots = riskMoney / lossPerLot;

   // step per neeche ki taraf round — risk kabhi barhna nahi chahiye
   lots = MathFloor(lots / volStep + 0.0000001) * volStep;
   lots = NormalizeDouble(lots, 2);

   if(lots < volMin - 0.0000001)
     {
      double minRisk = volMin * lossPerLot;
      why = StringFormat("Sab se choti lot (%.2f) per risk %.2f banta hai, aap ki had %.2f hai",
                         volMin, minRisk, riskMoney);
      return(0.0);
     }
   if(lots > volMax) lots = volMax;

   return(lots);
  }

//============================ SCORE ==================================

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

//============================ SIGNAL =================================

// dir: +1 buy, -1 sell, 0 kuch nahi
int FindSignal(double &sl, double &tp1, double &tp2, double &tp3, int &score)
  {
   sl = tp1 = tp2 = tp3 = 0.0; score = 0;

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

   // --- BOS: kya pichle StructLookback bars mein swing tooti? ---
   bool bosUp = false, bosDn = false;
   for(int i = 1; i <= StructLookback; i++)
     {
      double c = iClose(_Symbol, _Period, i);
      if(c > swHigh) bosUp = true;
      if(c < swLow)  bosDn = true;
     }

   // --- momentum: EMA fast ka retest ---
   double lo1 = iLow(_Symbol, _Period, 1);
   double hi1 = iHigh(_Symbol, _Period, 1);
   double tol = 0.45 * atr;
   bool retestUp = (lo1 <= emaF + tol && iClose(_Symbol,_Period,1) > emaF);
   bool retestDn = (hi1 >= emaF - tol && iClose(_Symbol,_Period,1) < emaF);

   bool trendUp = (emaF > emaS);
   bool trendDn = (emaF < emaS);

   // zone "fresh" — swing abhi hali mein bani ho
   bool freshUp = (slBar <= 40);
   bool freshDn = (shBar <= 40);

   int dir = 0;
   if(trendUp && bosUp && retestUp && htf >= 0) dir =  1;
   if(trendDn && bosDn && retestDn && htf <= 0) dir = -1;
   if(dir == 0) return(0);

   score = BuildScore(dir, (dir > 0 ? bosUp : bosDn),
                      (dir > 0 ? retestUp : retestDn),
                      htf, adx, (dir > 0 ? freshUp : freshDn));

   if(UseScore && score < MinScore) return(0);

   // --- stop: structure + ATR buffer, phir clamp ---
   double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   double entry = (dir > 0 ? ask : bid);

   double raw;
   if(dir > 0) raw = LowestLow(SlSwingLookback)   - SlBufferAtr * atr;
   else        raw = HighestHigh(SlSwingLookback) + SlBufferAtr * atr;

   double dist = MathAbs(entry - raw);
   double minD = MinSlAtr * atr;
   double maxD = MaxSlAtr * atr;
   if(dist < minD) dist = minD;
   if(dist > maxD) dist = maxD;

   // broker ki kam az kam SL doori ka ehtram
   double stopsLevel = (double)SymbolInfoInteger(_Symbol, SYMBOL_TRADE_STOPS_LEVEL)
                       * SymbolInfoDouble(_Symbol, SYMBOL_POINT);
   if(dist < stopsLevel) dist = stopsLevel * 1.2;

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

//============================ POSITIONS ==============================

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

void ManageOpenPosition()
  {
   if(g_ticket == 0) return;
   if(!PositionSelectByTicket(g_ticket))
     {
      g_ticket = 0; g_hit1 = false; g_hit2 = false;
      return;
     }

   long   type = PositionGetInteger(POSITION_TYPE);
   double vol  = PositionGetDouble(POSITION_VOLUME);
   double open = PositionGetDouble(POSITION_PRICE_OPEN);
   double cur  = (type == POSITION_TYPE_BUY)
                 ? SymbolInfoDouble(_Symbol, SYMBOL_BID)
                 : SymbolInfoDouble(_Symbol, SYMBOL_ASK);

   bool reached1 = (type == POSITION_TYPE_BUY) ? (cur >= g_tp1) : (cur <= g_tp1);

   if(!g_hit1 && reached1 && g_tp1 > 0.0)
     {
      double volStep = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);
      double volMin  = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
      double part    = vol * Tp1ClosePercent / 100.0;
      part = NormalizeDouble(MathFloor(part / volStep + 0.0000001) * volStep, 2);

      // sirf tab hissa band karein jab dono taraf volMin bach jaye
      if(part >= volMin && (vol - part) >= volMin)
        {
         if(trade.PositionClosePartial(g_ticket, part))
            Print("TP1 per ", DoubleToString(part,2), " lots band.");
        }
      g_hit1 = true;

      if(BreakevenAfterTp1)
        {
         double tp = PositionGetDouble(POSITION_TP);
         if(trade.PositionModify(g_ticket, open, tp))
            Print("SL breakeven per aa gaya.");
        }
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

   g_ticket = trade.ResultOrder();
   if(g_ticket == 0)
     {
      // kuch brokers deal ticket lautate hain — position dhoond lein
      for(int i = PositionsTotal() - 1; i >= 0; i--)
        {
         ulong t = PositionGetTicket(i);
         if(t == 0 || !PositionSelectByTicket(t)) continue;
         if(PositionGetString(POSITION_SYMBOL) != _Symbol) continue;
         if(PositionGetInteger(POSITION_MAGIC) != MagicNumber) continue;
         g_ticket = t; break;
        }
     }

   g_hit1 = false; g_hit2 = false;
   g_dayTrades++;
   g_msg = StringFormat("Trade khuli — %s %.2f lots", (dir > 0 ? "BUY" : "SELL"), lots);
   Print(g_msg);
  }

//============================ BUTTONS ================================

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
      MakeButton(BTN_B, StringFormat("BUY  %.2f lots", g_pendLots), y, C'20,110,70');
   else
      MakeButton(BTN_S, StringFormat("SELL %.2f lots", g_pendLots), y, C'150,45,30');

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
      int    dir  = g_pendDir;
      double lots = g_pendLots, sl = g_pendSl, tp3v = g_pendTp3;
      g_tp1 = g_pendTp1; g_tp2 = g_pendTp2; g_entry = g_pendEntry;
      CancelPending("");
      OpenTrade(dir, lots, sl, tp3v);
     }
  }

//============================ PANEL ==================================

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
   double eq   = AccountInfoDouble(ACCOUNT_EQUITY);
   double dayPl = eq - g_dayStartEquity;
   double dayPct = (g_dayStartEquity > 0.0) ? (dayPl / g_dayStartEquity * 100.0) : 0.0;
   string cur = AccountInfoString(ACCOUNT_CURRENCY);

   SetLabel(0, "JAS SNIPER  —  " + ModeName() +
               (DemoOnly ? "  [demo only]" : "  [LIVE]"), clrGold);

   SetLabel(1, StringFormat("Equity  %.2f %s   |  Din %+.2f (%+.2f%%)",
                            eq, cur, dayPl, dayPct),
            (dayPl >= 0 ? clrLime : clrTomato));

   SetLabel(2, StringFormat("Trades aaj  %d / %d   |  Spread %.0f",
                            g_dayTrades, MaxTradesPerDay, SpreadPoints()), clrWhite);

   if(g_dayBlocked)
      SetLabel(3, "RUKA HUA — din ki had lag gayi", clrTomato);
   else if(g_ticket != 0)
      SetLabel(3, StringFormat("Position khuli  |  TP1 %s  %s",
                               DoubleToString(g_tp1, _Digits),
                               (g_hit1 ? "(lag gaya)" : "")), clrAqua);
   else if(g_pending)
      SetLabel(3, StringFormat("SIGNAL  %s  score %d  —  button dabayen",
                               (g_pendDir > 0 ? "BUY" : "SELL"), g_pendScore), clrYellow);
   else
      SetLabel(3, "Setup ka intezaar...", clrSilver);

   SetLabel(4, g_msg, clrSilver);
   ChartRedraw();
  }

//============================ TICK ===================================

void OnTick()
  {
   CheckDayRollover();
   ManageOpenPosition();

   // din ki nuqsan ki had
   double eq = AccountInfoDouble(ACCOUNT_EQUITY);
   if(g_dayStartEquity > 0.0)
     {
      double lossPct = (g_dayStartEquity - eq) / g_dayStartEquity * 100.0;
      if(lossPct >= MaxDailyLossPercent && !g_dayBlocked)
        {
         g_dayBlocked = true;
         g_msg = "Din ki nuqsan ki had lag gayi — aaj aur trade nahi.";
         Print(g_msg);
         CancelPending("");
        }
     }

   if(!IsNewBar())
     {
      DrawPanel();
      return;
     }

   // pending confirmation ki miyaad
   if(g_pending && (g_barCounter - g_pendBar) >= ConfirmExpiryBars)
      CancelPending("Signal ki miyaad khatam — button hata diya.");

   DrawPanel();

   //--- naye signal ke liye rukawatein ---
   if(g_dayBlocked)                                   return;
   if(g_pending)                                      return;
   if(CountOurPositions() >= MaxOpenPositions)        return;
   if(g_dayTrades >= MaxTradesPerDay)                 return;
   if(!InSession())                                   return;
   if(SpreadPoints() > MaxSpreadPoints)               return;
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

   g_lastSignalBar = g_barCounter;

   string line = StringFormat("%s  score %d  |  Entry %s  SL %s  TP1 %s  |  %.2f lots",
                              (dir > 0 ? "BUY" : "SELL"), score,
                              DoubleToString(entry, _Digits),
                              DoubleToString(sl,    _Digits),
                              DoubleToString(tp1,   _Digits), lots);

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

   // AUTO
   g_tp1 = tp1; g_tp2 = tp2; g_entry = entry;
   OpenTrade(dir, lots, sl, tp3);
  }
//+------------------------------------------------------------------+
