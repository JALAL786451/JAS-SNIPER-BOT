//====================================================================
//===  BUILD k4   <<< PANEL PAR YAHI NUMBER AANA CHAHIYE >>>
//====================================================================
//+------------------------------------------------------------------+
//|  JasChakkarEA.mq5  -  "trend ko dost bana kar"                    |
//|                                                                   |
//|  User ke qaide (3 Oct 2026, khud naam le kar manga):              |
//|   Q0  Koi lot / jori NUQSAN par band nahi - sirf 0 ya faida.      |
//|   Q1  Rukh (H1 EMA50) ke KHILAF kabhi jhukao nahi.                |
//|   Q2  Rukh ke saath jhukao, ek 0.01 fi step:                      |
//|       rukh upar -> faide wali SELL 0.01 band, warna nayi BUY 0.01 |
//|       rukh neeche -> faide wali BUY 0.01 band, warna nayi SELL    |
//|   Q3  NET kabhi InpMaxNet (0.05) se zyada nahi.                   |
//|   Q4  Nayi lot kabhi 0.01 se bari nahi.                           |
//|   Q5  Hedge (NET 0) fauran: qeemat behtareen jagah se 1 step      |
//|       ulti aaye, rukh badle/saaf na rahe, news aaye, ya Jumma.    |
//|       Hedge ke liye bhi pehle faide wali lot band, warna nayi.    |
//|       Hedge ke baad thori der (InpHedgePauseSec) phir rukh dekho. |
//|   Q6  Bari lot (> 0.01) ki JORI: ulti taraf ki barabar lot,       |
//|       Close By, sab se zyada faide wali jori - nateeja >= 0.      |
//|   Q7  Seconds ka hisaab: har jhukao kitne second khula raha,      |
//|       panel aur CSV mein.                                         |
//|   Q9  CLOSE ALL (user ka apna qaida, 4 Oct): is symbol ki SAARI    |
//|       lots ka mila hua P/L InpCloseAll tak pohnche to sab band,   |
//|       phir khali kitab se rukh ke hisaab se naya setup.           |
//|       (Q0 akeli lot ke liye hai; Close All mila kar faide mein.)  |
//|   Q8  Equity (attach ke waqt ki equity se): 95% par naya jhukao   |
//|       band, 90% par sab hedge aur EA ruk jata hai.                |
//|                                                                   |
//|  Jhukao ka nateeja = jhukao shuru se band tak equity ka farq      |
//|  (baqi kitab jami hai, is liye farq jhukao ka hai).               |
//|  Ye qaide NAAPE NAHI gaye - demo + CSV isi liye.                  |
//|  Hedge account chahiye. Koi SL / TP nahi.                         |
//+------------------------------------------------------------------+
#property copyright "JAS-SNIPER-BOT"
#property version   "3.00"

#include <Trade\Trade.mqh>

#define K_BUILD "k4"

input group "=== 1 - Jhukao ==="
input bool   InpTrade         = true;     // true = asal kaam; false = sirf panel par batao
input double InpLot           = 0.01;     // Har lot (kabhi bari nahi)
input double InpMaxNet        = 0.05;     // NET (BUY - SELL) ki hadd
input double InpMinClose      = 0.0;      // Akeli lot kam az kam itne faide mein ho tab band (0 = barabar)
input int    InpPauseSec      = 30;       // Do kaam ke darmiyan kam az kam second
input int    InpHedgePauseSec = 300;      // Hedge ke baad kitne second ruk kar phir jhukao
input int    InpMaxHedgeUnits = 60;       // Ek hedge mein zyada se zyada kitni 0.01 (is se zyada = haath se)

input group "=== 2 - Step ==="
input double          InpStep         = 5.0;        // GOLD: kitne DOLLAR
input double          InpStepAtr      = 1.0;        // BAQI (BTC): ATR ka kitna guna
input ENUM_TIMEFRAMES InpAtrTF        = PERIOD_M15; // ATR kis timeframe ka
input double          InpMaxSpreadPct = 15.0;       // Spread step ke kitne % se zyada ho to naya jhukao nahi

input group "=== 3 - Rukh ==="
input ENUM_TIMEFRAMES InpTrendTF   = PERIOD_H1;  // Rukh kis timeframe se
input int             InpTrendEMA  = 50;         // EMA kitni
input int             InpSlopeBars = 3;          // EMA ka jhukaav kitni candles par

input group "=== 3b - Close All (Q9) ==="
input bool   InpUseCloseAll = true;    // Saari lots mila kar faide mein hon to Close All
input double InpCloseAll    = 30.0;    // Kitne faide par (account ki currency) - demo par user +30 par karta hai

input group "=== 4 - Jori (bari lot) ==="
input bool   InpJori      = true;    // Bari lot ki jori Close By se
input double InpMinJori   = 0.0;     // Jori ka nateeja kam az kam (0 = barabar)
input int    InpJoriDelay = 200;     // Do Close By ke darmiyan milli-second

input group "=== 5 - Equity (attach ke waqt ki equity ka %) ==="
input double InpEqStopPct = 95.0;    // Is se neeche naya jhukao band
input double InpEqHaltPct = 90.0;    // Is se neeche sab hedge aur EA ruk jaye
input bool   InpResume    = false;   // true = ruka hua EA chalu + equity ka naya buniyadi number

input group "=== 6 - News (L10) ==="
input bool   InpUseNews      = true;  // Bari news se pehle hedge, news ke waqt jhukao nahi
input int    InpNewsBefore   = 30;    // News se kitne minute pehle
input int    InpNewsAfter    = 60;    // News ke kitne minute baad tak
input string InpNewsCurrency = "USD"; // Kis mulk ki news (khali = sab)

input group "=== 7 - Jumma (sirf jo market weekend band hoti hai) ==="
input int    InpFriNoStart = 19;      // Jumma ko is ghante (server) se naya jhukao nahi
input int    InpFriFlat    = 20;      // Jumma ko is ghante se hedge

input group "=== 8 - Baqi ==="
input long   InpMagic      = 260210;  // EA ki khud kholi hui lot ka nishan
input bool   InpLines      = true;    // Chart par hedge ki lakeer
input bool   InpCsv        = true;    // Har jhukao MQL5\Files\JasChakkar_<symbol>.csv mein
input bool   InpResetStats = false;   // true = ginti saaf (phir false kar dein)

CTrade   trade;
int      hEma = INVALID_HANDLE, hAtr = INVALID_HANDLE;

//--- haal (GlobalVariables mein)
bool     g_halted   = false;
double   g_eqBase   = 0.0;
bool     g_epOn     = false;   // jhukao chal raha hai
int      g_epSide   = 0;       // +1 BUY ki taraf, -1 SELL ki taraf
datetime g_epStart  = 0;
double   g_epEq     = 0.0;     // jhukao shuru par equity
double   g_epMax    = 0.0;     // sab se bara NET
double   g_peak     = 0.0;     // behtareen qeemat (trailing)
double   g_lastAdd  = 0.0;     // aakhri unit kahan lagi
double   g_step     = 0.0;
datetime g_hedgeAt  = 0;
int      g_epW = 0, g_epL = 0, g_epN = 0;
double   g_epSum = 0.0;
long     g_epSecs = 0;
int      g_jN = 0;    double g_jSum = 0.0;
int      g_cN = 0;    double g_cSum = 0.0;   // akeli faide wali lots band
int      g_oN = 0;                           // nayi lots kholi
int      g_caN = 0;   double g_caSum = 0.0;  // Close All
bool     g_closing = false;                  // Close All adhoora - agle tick par jari

datetime g_lastAct = 0, g_lastTry = 0;
string   g_msg = "Shuru", g_last = "";
int      g_trend = 0;
bool     g_247 = false;

bool     g_newsBlock = false, g_newsSoon = false, g_newsOK = false;
datetime g_newsAt = 0, g_newsLast = 0;
string   g_newsName = "";

string Pick(bool c, string a, string b) { if(c) return(a); return(b); }
string M(double v)  { return(DoubleToString(v, 2)); }
string Px(double v) { return(DoubleToString(v, (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS))); }
string TrendName(int t) { if(t > 0) return("UPAR"); if(t < 0) return("NEECHE"); return("SAAF NAHI"); }
string DirName(int d)   { if(d > 0) return("BUY taraf"); if(d < 0) return("SELL taraf"); return("jami"); }
int    Sgn(double v)    { if(v > 1e-6) return(1); if(v < -1e-6) return(-1); return(0); }

string Key(string n) { return("JCK3_" + IntegerToString(AccountInfoInteger(ACCOUNT_LOGIN)) + "_" + _Symbol + "_" + n); }
double GV(string n, double d) { string k = Key(n); if(GlobalVariableCheck(k)) return(GlobalVariableGet(k)); return(d); }
void   SV(string n, double v) { GlobalVariableSet(Key(n), v); }

void Save()
  {
   SV("halted", g_halted ? 1 : 0); SV("eqBase", g_eqBase);
   SV("epOn", g_epOn ? 1 : 0); SV("epSide", g_epSide); SV("epStart", (double)g_epStart);
   SV("epEq", g_epEq); SV("epMax", g_epMax); SV("peak", g_peak); SV("lastAdd", g_lastAdd);
   SV("step", g_step); SV("hedgeAt", (double)g_hedgeAt);
   SV("epW", g_epW); SV("epL", g_epL); SV("epN", g_epN); SV("epSum", g_epSum); SV("epSecs", (double)g_epSecs);
   SV("jN", g_jN); SV("jSum", g_jSum); SV("cN", g_cN); SV("cSum", g_cSum); SV("oN", g_oN); SV("caN", g_caN); SV("caSum", g_caSum);
  }

void Load()
  {
   g_halted = GV("halted", 0) > 0.5;  g_eqBase = GV("eqBase", 0.0);
   g_epOn = GV("epOn", 0) > 0.5;      g_epSide = (int)GV("epSide", 0);
   g_epStart = (datetime)GV("epStart", 0); g_epEq = GV("epEq", 0.0); g_epMax = GV("epMax", 0.0);
   g_peak = GV("peak", 0.0); g_lastAdd = GV("lastAdd", 0.0); g_step = GV("step", 0.0);
   g_hedgeAt = (datetime)GV("hedgeAt", 0);
   g_epW = (int)GV("epW", 0); g_epL = (int)GV("epL", 0); g_epN = (int)GV("epN", 0);
   g_epSum = GV("epSum", 0.0); g_epSecs = (long)GV("epSecs", 0);
   g_jN = (int)GV("jN", 0); g_jSum = GV("jSum", 0.0);
   g_cN = (int)GV("cN", 0); g_cSum = GV("cSum", 0.0); g_oN = (int)GV("oN", 0); g_caN = (int)GV("caN", 0); g_caSum = GV("caSum", 0.0);
  }

void ResetStats()
  {
   string n[] = {"epW", "epL", "epN", "epSum", "epSecs", "jN", "jSum", "cN", "cSum", "oN", "caN", "caSum"};
   for(int i = 0; i < ArraySize(n); i++) GlobalVariableDel(Key(n[i]));
  }

bool IsGold() { return(StringFind(_Symbol, "XAU") >= 0 || StringFind(_Symbol, "GOLD") >= 0); }
bool Is247()  { datetime f, t; return(SymbolInfoSessionTrade(_Symbol, SATURDAY, 0, f, t) && t > f); }

double StepNow()
  {
   if(IsGold()) return(InpStep);
   double a[1];
   if(hAtr == INVALID_HANDLE || CopyBuffer(hAtr, 0, 1, 1, a) < 1) return(0.0);
   return(a[0] * InpStepAtr);
  }

int TrendNow()
  {
   if(hEma == INVALID_HANDLE) return(0);
   double e[];
   ArraySetAsSeries(e, true);
   if(CopyBuffer(hEma, 0, 1, InpSlopeBars + 1, e) < InpSlopeBars + 1) return(0);
   double c = iClose(_Symbol, InpTrendTF, 1);
   if(c <= 0.0) return(0);
   if(c > e[0] && e[0] > e[InpSlopeBars]) return(1);
   if(c < e[0] && e[0] < e[InpSlopeBars]) return(-1);
   return(0);
  }

void Book(double &buy, double &sell, int &nb, int &ns)
  {
   buy = 0.0; sell = 0.0; nb = 0; ns = 0;
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      ulong t = PositionGetTicket(i);
      if(t == 0 || PositionGetString(POSITION_SYMBOL) != _Symbol) continue;
      double v = PositionGetDouble(POSITION_VOLUME);
      if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY) { buy += v; nb++; }
      else                                                       { sell += v; ns++; }
     }
  }

double NetNow() { double b, s; int nb, ns; Book(b, s, nb, ns); return(b - s); }

//--- faide wali 0.01: SELL mein sab se NEECHE wali, BUY mein sab se UPAR wali
//--- (taake SELL upar aur BUY neeche bachein)
ulong PickProfit(long type, double &pl)
  {
   ulong best = 0; double bp = 0.0; pl = 0.0;
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      ulong t = PositionGetTicket(i);
      if(t == 0 || PositionGetString(POSITION_SYMBOL) != _Symbol) continue;
      if(PositionGetInteger(POSITION_TYPE) != type) continue;
      if(MathAbs(PositionGetDouble(POSITION_VOLUME) - InpLot) > 1e-8) continue;
      double pr = PositionGetDouble(POSITION_PROFIT) + PositionGetDouble(POSITION_SWAP);
      if(pr < InpMinClose) continue;
      double p = PositionGetDouble(POSITION_PRICE_OPEN);
      bool better = (type == POSITION_TYPE_SELL) ? (p < bp) : (p > bp);
      if(best == 0 || better) { best = t; bp = p; pl = pr; }
     }
   return(best);
  }

bool Ok(bool sent)
  {
   uint rc = trade.ResultRetcode();
   if(sent && (rc == TRADE_RETCODE_DONE || rc == TRADE_RETCODE_PLACED)) return(true);
   g_msg = "Order nahi chala: " + IntegerToString((int)rc) + " " + trade.ResultRetcodeDescription();
   Print("JAS CHAKKAR: ", g_msg);
   return(false);
  }

//--- NET ko dir (+1 / -1) taraf 0.01 hilao: pehle faide wali ulti lot band, warna nayi
bool Unit(int dir, string &what)
  {
   long   opp = (dir > 0) ? POSITION_TYPE_SELL : POSITION_TYPE_BUY;
   double pl;
   ulong  tk = PickProfit(opp, pl);
   if(tk > 0)
     {
      if(!Ok(trade.PositionClose(tk))) return(false);
      g_cN++; g_cSum += pl;
      what = StringFormat("%s 0.01 band (%s)", Pick(dir > 0, "SELL", "BUY"), M(pl));
      return(true);
     }
   bool sent = (dir > 0) ? trade.Buy(InpLot, _Symbol, 0.0, 0.0, 0.0, "JasChakkar " + K_BUILD)
                         : trade.Sell(InpLot, _Symbol, 0.0, 0.0, 0.0, "JasChakkar " + K_BUILD);
   if(!Ok(sent)) return(false);
   g_oN++;
   what = "nayi " + Pick(dir > 0, "BUY", "SELL") + " 0.01";
   return(true);
  }

//+------------------------------------------------------------------+
//|  CSV                                                              |
//+------------------------------------------------------------------+
void Csv(string kind, double res, long secs, string why)
  {
   if(!InpCsv) return;
   int h = FileOpen("JasChakkar_" + _Symbol + ".csv",
                    FILE_READ | FILE_WRITE | FILE_CSV | FILE_ANSI | FILE_SHARE_READ, ',');
   if(h == INVALID_HANDLE) return;
   if(FileSize(h) == 0)
      FileWrite(h, "build", "time", "kind", "side", "seconds", "max_net", "step", "result", "why");
   FileSeek(h, 0, SEEK_END);
   FileWrite(h, K_BUILD, TimeToString(TimeCurrent(), TIME_DATE | TIME_SECONDS), kind,
             DirName(g_epSide), (long)secs, DoubleToString(g_epMax, 2), Px(g_step), M(res), why);
   FileClose(h);
  }

//+------------------------------------------------------------------+
//|  Jhukao shuru / khatam                                            |
//+------------------------------------------------------------------+
void EpStart(int side, double px)
  {
   g_epOn = true; g_epSide = side; g_epStart = TimeCurrent();
   g_epEq = AccountInfoDouble(ACCOUNT_EQUITY); g_epMax = 0.0;
   g_peak = px; g_lastAdd = px; g_step = StepNow();
  }

void EpEnd(string why)
  {
   if(!g_epOn) return;
   double res  = AccountInfoDouble(ACCOUNT_EQUITY) - g_epEq;
   long   secs = (long)(TimeCurrent() - g_epStart);
   g_epN++; g_epSum += res; g_epSecs += secs;
   if(res >= 0.0) g_epW++; else g_epL++;
   g_last = StringFormat("Jhukao %s khatam (%s): %d second, max NET %.2f -> %s%s",
                         DirName(g_epSide), why, (int)secs, g_epMax, Pick(res >= 0.0, "+", ""), M(res));
   Print("JAS CHAKKAR: ", g_last);
   Csv("jhukao", res, secs, why);
   g_epOn = false; g_epSide = 0;
   g_hedgeAt = TimeCurrent();
  }

//--- NET ko 0 karo, abhi isi waqt (pause nahi)
bool HedgeAll(string why)
  {
   double net = NetNow();
   int units = (int)MathRound(MathAbs(net) / InpLot);
   if(units == 0) { EpEnd(why); Save(); return(true); }
   if(!InpTrade)  { g_msg = "SIRF DIKHANA: abhi hedge hota (" + why + ")"; return(false); }
   if(units > InpMaxHedgeUnits)
     { g_msg = StringFormat("NET %+.2f bohot bara - %d lot ka hedge haath se karein", net, units); return(false); }
   int dir = -Sgn(net);
   string w = "";
   for(int i = 0; i < units; i++)
     {
      if(!Unit(dir, w)) { Save(); return(false); }
     }
   g_lastAct = TimeCurrent();
   EpEnd(why);
   g_msg = "Hedge: kitab jami (" + why + ")";
   Save();
   return(true);
  }

//+------------------------------------------------------------------+
//|  Q6 - bari lot ki jori (Close By), sirf nateeja >= InpMinJori     |
//+------------------------------------------------------------------+
bool TryJori()
  {
   if(!InpJori || !InpTrade) return(false);
   int n = PositionsTotal();
   ulong tk[]; long ty[]; double vol[], px[];
   ArrayResize(tk, n); ArrayResize(ty, n); ArrayResize(vol, n); ArrayResize(px, n);
   int c = 0;
   for(int i = 0; i < n; i++)
     {
      ulong t = PositionGetTicket(i);
      if(t == 0 || PositionGetString(POSITION_SYMBOL) != _Symbol) continue;
      tk[c] = t; ty[c] = PositionGetInteger(POSITION_TYPE);
      vol[c] = PositionGetDouble(POSITION_VOLUME); px[c] = PositionGetDouble(POSITION_PRICE_OPEN);
      c++;
     }
   double step = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);
   if(step <= 0.0) step = 0.01;

   for(int b = 0; b < c; b++)
     {
      if(vol[b] <= InpLot + 1e-8) continue;          // sirf bari lot
      bool bigBuy = (ty[b] == POSITION_TYPE_BUY);
      // ulti taraf, sab se faide wali pehle (bari SELL: sasti BUY pehle; bari BUY: mehngi SELL pehle)
      int cand[]; ArrayResize(cand, c); int nc = 0;
      for(int i = 0; i < c; i++) if(i != b && ty[i] != ty[b]) { cand[nc] = i; nc++; }
      for(int a = 0; a < nc - 1; a++)
         for(int d = a + 1; d < nc; d++)
           {
            bool sw = bigBuy ? (px[cand[d]] > px[cand[a]]) : (px[cand[d]] < px[cand[a]]);
            if(sw) { int t = cand[a]; cand[a] = cand[d]; cand[d] = t; }
           }
      long want = (long)MathRound(vol[b] / step), got = 0;
      int  sel[]; ArrayResize(sel, nc); int ns = 0;
      double res = 0.0;
      bool   calcOk = true;
      for(int k = 0; k < nc && got < want; k++)
        {
         int i = cand[k];
         long u = (long)MathRound(vol[i] / step);
         if(got + u > want) continue;
         double r = 0.0;
         // jori ka nateeja = do lots ke khulne ke price ka farq
         bool calc = bigBuy ? OrderCalcProfit(ORDER_TYPE_SELL, _Symbol, vol[i], px[i], px[b], r)
                            : OrderCalcProfit(ORDER_TYPE_BUY,  _Symbol, vol[i], px[i], px[b], r);
         if(!calc) { calcOk = false; break; }
         sel[ns] = i; ns++; got += u; res += r;
        }
      if(!calcOk || got != want || res < InpMinJori) continue;   // hisaab nahi bana, adhoori ya nuqsan wali jori - nahi

      long bigId = 0;
      if(PositionSelectByTicket(tk[b])) bigId = PositionGetInteger(POSITION_IDENTIFIER);
      int done = 0;
      for(int k = 0; k < ns; k++)
        {
         ulong bigNow = 0;
         if(PositionSelectByTicket(tk[b])) bigNow = tk[b];
         else
            for(int j = PositionsTotal() - 1; j >= 0; j--)
              {
               ulong t = PositionGetTicket(j);
               if(t > 0 && PositionGetInteger(POSITION_IDENTIFIER) == bigId) { bigNow = t; break; }
              }
         if(bigNow == 0 || !PositionSelectByTicket(tk[sel[k]])) break;
         MqlTradeRequest rq; MqlTradeResult rs;
         ZeroMemory(rq); ZeroMemory(rs);
         rq.action = TRADE_ACTION_CLOSE_BY; rq.position = bigNow;
         rq.position_by = tk[sel[k]]; rq.symbol = _Symbol;
         if(!OrderSend(rq, rs) || (rs.retcode != TRADE_RETCODE_DONE && rs.retcode != TRADE_RETCODE_PLACED))
           { Print("JAS CHAKKAR: jori Close By ruka, retcode ", rs.retcode); break; }
         done++;
         if(InpJoriDelay > 0) Sleep(InpJoriDelay);
        }
      g_jN++; g_jSum += res;
      g_last = StringFormat("JORI: %s %.2f @ %s + %d lots, %d/%d Close By, andaza %s",
                            Pick(bigBuy, "BUY", "SELL"), vol[b], Px(px[b]), ns, done, ns, M(res));
      Print("JAS CHAKKAR: ", g_last);
      Csv("jori", res, 0, StringFormat("%d/%d", done, ns));
      g_lastAct = TimeCurrent();
      Save();
      return(true);                                    // ek waqt mein ek jori
     }
   return(false);
  }

//+------------------------------------------------------------------+
//|  News                                                             |
//+------------------------------------------------------------------+
void RefreshNews()
  {
   datetime now = TimeCurrent();
   if(now - g_newsLast < 60) return;
   g_newsLast = now; g_newsBlock = false; g_newsSoon = false; g_newsOK = false;
   g_newsAt = 0; g_newsName = "";
   if(!InpUseNews) return;
   MqlCalendarValue v[];
   int n = CalendarValueHistory(v, now - 6 * 3600, now + 12 * 3600, NULL, InpNewsCurrency);
   if(n <= 0) { n = CalendarValueHistory(v, now - 6 * 3600, now + 12 * 3600); if(n <= 0) return; }
   g_newsOK = true;
   datetime bestAt = 0; string bestName = "";
   for(int i = 0; i < n; i++)
     {
      MqlCalendarEvent e;
      if(!CalendarEventById(v[i].event_id, e) || e.importance != CALENDAR_IMPORTANCE_HIGH) continue;
      datetime at = v[i].time;
      if(now >= at - (datetime)(InpNewsBefore * 60) && now <= at + (datetime)(InpNewsAfter * 60))
        { g_newsBlock = true; g_newsSoon = (now < at); g_newsAt = at; g_newsName = e.name; return; }
      if(at > now && (bestAt == 0 || at < bestAt)) { bestAt = at; bestName = e.name; }
     }
   g_newsAt = bestAt; g_newsName = bestName;
  }

bool FridayAfter(int hour)
  {
   if(g_247) return(false);
   MqlDateTime t; TimeToStruct(TimeCurrent(), t);
   return(t.day_of_week == 5 && t.hour >= hour);
  }

//+------------------------------------------------------------------+
//|  Q9 - Close All                                                   |
//+------------------------------------------------------------------+
double BookPL()
  {
   double pl = 0.0;
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      ulong t = PositionGetTicket(i);
      if(t == 0 || PositionGetString(POSITION_SYMBOL) != _Symbol) continue;
      pl += PositionGetDouble(POSITION_PROFIT) + PositionGetDouble(POSITION_SWAP);
     }
   return(pl);
  }

bool TryCloseAll()
  {
   double b, sl; int nb, ns;
   Book(b, sl, nb, ns);
   int n = nb + ns;
   if(n == 0) { g_closing = false; return(false); }
   double pl = BookPL();
   if(!g_closing && pl < InpCloseAll) return(false);
   if(!InpTrade) { g_msg = StringFormat("SIRF DIKHANA: abhi Close All hota (%s)", M(pl)); return(false); }
   if(TimeCurrent() - g_lastTry < 2) return(true);
   g_lastTry = TimeCurrent();

   double balBefore = AccountInfoDouble(ACCOUNT_BALANCE);
   if(!g_closing) { g_closing = true; SV("caStartBal", balBefore); SV("caStartAt", (double)TimeCurrent()); SV("caLots", n); }
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      ulong t = PositionGetTicket(i);
      if(t == 0 || PositionGetString(POSITION_SYMBOL) != _Symbol) continue;
      if(!trade.PositionClose(t)) Print("JAS CHAKKAR: Close All #", t, " nahi hua: ", trade.ResultRetcode());
     }
   Book(b, sl, nb, ns);
   if(nb + ns > 0)
     {
      g_msg = StringFormat("Close All jari: %d lots baqi", nb + ns);
      return(true);
     }
   double res  = AccountInfoDouble(ACCOUNT_BALANCE) - GV("caStartBal", balBefore);
   long   secs = (long)(TimeCurrent() - (datetime)GV("caStartAt", (double)TimeCurrent()));
   int    lots = (int)GV("caLots", n);
   g_closing = false;
   g_caN++; g_caSum += res;
   EpEnd("Close All");
   g_hedgeAt = 0;                                   // khali kitab: naya setup fauran
   g_last = StringFormat("CLOSE ALL: %d lots, nateeja %s%s (%d second)", lots, Pick(res >= 0.0, "+", ""), M(res), (int)secs);
   Print("JAS CHAKKAR: ", g_last);
   Csv("closeall", res, secs, IntegerToString(lots) + " lots");
   g_lastAct = TimeCurrent();
   g_msg = "Close All ho gaya. Rukh dekh kar naya setup.";
   Save();
   return(true);
  }

//+------------------------------------------------------------------+
//|  Dimagh                                                           |
//+------------------------------------------------------------------+
void Brain(double net, double bid, double ask, double eqPct)
  {
   int    sn  = Sgn(net);
   double stp = StepNow();

   //--- Q9: Close All - saari lots mila kar faide mein
   if(InpUseCloseAll && TryCloseAll()) return;

   //--- Q8: equity ki aakhri hadd
   if(eqPct <= InpEqHaltPct && !g_halted)
     {
      g_halted = true;
      HedgeAll("equity " + DoubleToString(eqPct, 1) + "%");
      g_msg = StringFormat("RUKA: equity %.1f%% (hadd %.0f%%). InpResume = true se chalu.", eqPct, InpEqHaltPct);
      Save();
      return;
     }
   if(g_halted)
     {
      if(sn != 0) HedgeAll("ruka hua");
      g_msg = StringFormat("RUKA: equity hadd. InpResume = true se chalu (abhi %.1f%%).", eqPct);
      return;
     }

   //--- jhukao chal raha hai: trailing aur hedge ki wajah
   if(sn != 0)
     {
      if(!g_epOn) EpStart(sn, sn > 0 ? bid : ask);     // pehle se jhuki kitab = jhukao
      g_epSide = sn;
      g_epMax  = MathMax(g_epMax, MathAbs(net));
      if(g_step <= 0.0) g_step = stp;
      if(sn > 0) g_peak = MathMax(g_peak, bid); else g_peak = MathMin(g_peak, ask);

      string why = "";
      if(sn > 0 && bid <= g_peak - g_step)           why = "1 step ulti chaal";
      else if(sn < 0 && ask >= g_peak + g_step)      why = "1 step ulti chaal";
      else if(g_trend != sn)                         why = "rukh " + TrendName(g_trend);
      else if(MathAbs(net) > InpMaxNet + 1e-6)       why = "NET hadd se zyada";
      else if(g_newsBlock && g_newsSoon)             why = "news: " + g_newsName;
      else if(FridayAfter(InpFriFlat))               why = "Jumma";
      if(why != "") { HedgeAll(why); return; }
     }

   //--- Q6: jori (NET nahi badalti)
   if(TimeCurrent() - g_lastAct >= InpPauseSec && TryJori()) return;

   //--- Q2: rukh ke saath agla 0.01
   if(g_trend == 0)                         { g_msg = Pick(sn == 0, "Intezar: rukh saaf nahi", "Jhukao chal raha"); return; }
   if(sn != 0 && sn != g_trend)             return;   // upar hedge ho chuka hoga
   if(MathAbs(net) + InpLot > InpMaxNet + 1e-6) { g_msg = "Jhukao poora (NET hadd). Trailing chal raha."; return; }
   if(eqPct <= InpEqStopPct)                { g_msg = StringFormat("Rok: equity %.1f%% - naya jhukao nahi", eqPct); return; }
   if(g_newsBlock)                          { g_msg = "Rok: news - " + g_newsName; return; }
   if(FridayAfter(InpFriNoStart))           { g_msg = "Rok: Jumma"; return; }
   if(stp <= 0.0)                           { g_msg = "Rok: ATR nahi mila"; return; }
   if(ask - bid > stp * InpMaxSpreadPct / 100.0) { g_msg = "Rok: spread bara"; return; }
   if(TimeCurrent() - g_lastAct < InpPauseSec)    { g_msg = "Thehrao"; return; }
   if(sn == 0 && TimeCurrent() - g_hedgeAt < InpHedgePauseSec)
     { g_msg = StringFormat("Hedge ke baad thehrao: %d second", (int)(InpHedgePauseSec - (TimeCurrent() - g_hedgeAt))); return; }

   double px = (g_trend > 0) ? ask : bid;
   if(sn != 0)
     {
      bool next = (g_trend > 0) ? (px >= g_lastAdd + g_step) : (px <= g_lastAdd - g_step);
      if(!next)
        { g_msg = StringFormat("Agli 0.01 jab qeemat %s", Px(g_trend > 0 ? g_lastAdd + g_step : g_lastAdd - g_step)); return; }
     }
   if(!InpTrade) { g_msg = "SIRF DIKHANA: abhi " + DirName(g_trend) + " 0.01 hota"; return; }
   if(!TerminalInfoInteger(TERMINAL_TRADE_ALLOWED) || !MQLInfoInteger(MQL_TRADE_ALLOWED))
     { g_msg = "Algo Trading band hai - button HARA karein"; return; }
   if(TimeCurrent() - g_lastTry < 3) return;
   g_lastTry = TimeCurrent();

   if(sn == 0) EpStart(g_trend, px);
   string w = "";
   if(!Unit(g_trend, w)) return;
   g_lastAdd = px;
   g_lastAct = TimeCurrent();
   g_msg = "Jhukao: " + w;
   PrintFormat("JAS CHAKKAR: %s @ %s, rukh %s", w, Px(px), TrendName(g_trend));
   Save();
  }

//+------------------------------------------------------------------+
//|  Panel                                                            |
//+------------------------------------------------------------------+
void Panel(double buy, double sell, int nb, int ns, double bid, double ask, double eqPct)
  {
   string cur = AccountInfoString(ACCOUNT_CURRENCY);
   double net = buy - sell;
   double stp = (g_epOn && g_step > 0.0) ? g_step : StepNow();
   string s = "";
   s += "=== JAS CHAKKAR  " + K_BUILD + " ===   " + _Symbol + " (" + cur + ")" + Pick(g_247, " [24/7]", "") + "\n";
   s += Pick(InpTrade, "ASAL KAAM chalu", "SIRF DIKHANA") + "   |   trend ko dost, nuqsan par band nahi\n";
   s += "Rukh " + EnumToString(InpTrendTF) + ": " + TrendName(g_trend)
        + StringFormat("   step %s   spread %s\n", Px(stp), Px(ask - bid));
   s += StringFormat("Equity %.1f%% (rok %.0f / band %.0f)%s\n", eqPct, InpEqStopPct, InpEqHaltPct, Pick(g_halted, "  RUKA", ""));
   s += "\n";
   s += StringFormat("Kitab: BUY %d (%.2f)  SELL %d (%.2f)  NET %+.2f / hadd %.2f\n", nb, buy, ns, sell, net, InpMaxNet);
   if(g_epOn)
     {
      s += StringFormat("JHUKAO: %s, %d second se, max NET %.2f\n", DirName(g_epSide), (int)(TimeCurrent() - g_epStart), g_epMax);
      s += StringFormat("  Abhi tak: %s   |   hedge agar qeemat %s\n",
                        M(AccountInfoDouble(ACCOUNT_EQUITY) - g_epEq),
                        Px(g_epSide > 0 ? g_peak - g_step : g_peak + g_step));
     }
   else s += "JHUKAO: nahi (kitab jami)\n";
   s += "  " + g_msg + "\n";
   s += "\n";
   s += StringFormat("Jhukao: %d (jeet %d / haar %d)  kul %s  ausat %s  ausat %d sec\n",
                     g_epN, g_epW, g_epL, M(g_epSum), M(g_epN > 0 ? g_epSum / g_epN : 0.0),
                     (int)(g_epN > 0 ? g_epSecs / g_epN : 0));
   s += StringFormat("Faide wali 0.01 band: %d (%s)   nayi 0.01: %d\n", g_cN, M(g_cSum), g_oN);
   s += StringFormat("Jori: %d (%s)\n", g_jN, M(g_jSum));
   s += StringFormat("Close All: %d (%s)   |   hadd +%s, abhi %s\n", g_caN, M(g_caSum), M(InpCloseAll), M(BookPL()));
   if(g_last != "") s += "Aakhri: " + g_last + "\n";
   s += "\n";
   if(!InpUseNews)       s += "News: band (input)\n";
   else if(!g_newsOK)    s += "News: calendar nahi mila\n";
   else if(g_newsBlock)  s += "News: ABHI ROK - " + g_newsName + "\n";
   else if(g_newsAt > 0) s += "News: agli " + TimeToString(g_newsAt, TIME_DATE | TIME_MINUTES) + " " + g_newsName + "\n";
   else                  s += "News: agle 12 ghante mein koi bari nahi\n";
   Comment(s);
  }

void DrawLine()
  {
   if(!InpLines || !g_epOn || g_step <= 0.0) { ObjectDelete(0, "JCK_hedge"); return; }
   double p = (g_epSide > 0) ? g_peak - g_step : g_peak + g_step;
   if(ObjectFind(0, "JCK_hedge") < 0) ObjectCreate(0, "JCK_hedge", OBJ_HLINE, 0, 0, p);
   ObjectSetDouble(0, "JCK_hedge", OBJPROP_PRICE, p);
   ObjectSetInteger(0, "JCK_hedge", OBJPROP_COLOR, clrOrange);
   ObjectSetInteger(0, "JCK_hedge", OBJPROP_STYLE, STYLE_DASH);
   ObjectSetInteger(0, "JCK_hedge", OBJPROP_SELECTABLE, false);
   ObjectSetString(0, "JCK_hedge", OBJPROP_TOOLTIP, "Yahan hedge (kitab jami)");
  }

//+------------------------------------------------------------------+
void Work()
  {
   RefreshNews();
   g_trend = TrendNow();
   double buy, sell; int nb, ns;
   Book(buy, sell, nb, ns);
   double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   double eq  = AccountInfoDouble(ACCOUNT_EQUITY);
   if(g_eqBase <= 0.0) { g_eqBase = eq; Save(); }
   double eqPct = (g_eqBase > 0.0) ? eq / g_eqBase * 100.0 : 100.0;

   if(AccountInfoInteger(ACCOUNT_MARGIN_MODE) != ACCOUNT_MARGIN_MODE_RETAIL_HEDGING)
      g_msg = "Ye account HEDGE nahi - EA kuch nahi karega";
   else if(bid > 0.0)
      Brain(buy - sell, bid, ask, eqPct);

   Book(buy, sell, nb, ns);
   DrawLine();
   Panel(buy, sell, nb, ns, bid, ask, eqPct);
  }

int OnInit()
  {
   trade.SetExpertMagicNumber(InpMagic);
   trade.SetDeviationInPoints(50);
   trade.SetTypeFillingBySymbol(_Symbol);
   if(InpLot <= 0.0 || InpMaxNet < InpLot || InpStep <= 0.0 || InpStepAtr <= 0.0 || InpSlopeBars < 1
      || InpEqHaltPct >= InpEqStopPct)
     {
      Alert("JAS CHAKKAR: inputs theek nahi (Lot, MaxNet, Step, Equity %)");
      return(INIT_PARAMETERS_INCORRECT);
     }
   hEma = iMA(_Symbol, InpTrendTF, InpTrendEMA, 0, MODE_EMA, PRICE_CLOSE);
   hAtr = iATR(_Symbol, InpAtrTF, 14);
   if(hEma == INVALID_HANDLE || hAtr == INVALID_HANDLE) { Alert("JAS CHAKKAR: EMA/ATR nahi bana"); return(INIT_FAILED); }

   if(InpResetStats) ResetStats();
   Load();
   if(InpResume) { g_halted = false; g_eqBase = AccountInfoDouble(ACCOUNT_EQUITY); Save(); }
   g_247 = Is247();
   PrintFormat("JAS CHAKKAR %s shuru | %s | equity buniyad %s | ruka %s | 24/7 %s",
               K_BUILD, _Symbol, M(g_eqBase), Pick(g_halted, "haan", "nahi"), Pick(g_247, "haan", "nahi"));
   EventSetTimer(1);
   Work();
   return(INIT_SUCCEEDED);
  }

void OnDeinit(const int reason)
  {
   EventKillTimer();
   if(hEma != INVALID_HANDLE) IndicatorRelease(hEma);
   if(hAtr != INVALID_HANDLE) IndicatorRelease(hAtr);
   ObjectDelete(0, "JCK_hedge");
   Comment("");
  }

void OnTick()  { Work(); }
void OnTimer() { Work(); }
//+------------------------------------------------------------------+
