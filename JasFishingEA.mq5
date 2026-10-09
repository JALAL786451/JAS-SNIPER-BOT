//====================================================================
//===  BUILD f1   <<< PANEL PAR YAHI NUMBER AANA CHAHIYE >>>
//====================================================================
//+------------------------------------------------------------------+
//|                                                 JasFishingEA.mq5 |
//|  User (Jalal) ki apni Fishing method, 9 Oct 2026 ko khud bataye   |
//|  qaide par. User ka dard: "dhyan bhatak jata hai, andaza ghalat   |
//|  ho jata hai, jaldi mein ghalat lot lag jati hai - EA ye kare".   |
//|  User ne hedge khud naam le kar manga (is session mein).          |
//|                                                                  |
//|  QAIDE - sab faasle gold ki QEEMAT mein ($). 0.01 lot par $1 =    |
//|  demo (USD) par $1, cent account par 1 USC:                       |
//|   F1 Khali kitab: qeemat $1.50 kisi taraf chale aur H1 rukh usi   |
//|      taraf ho -> usi taraf 0.01 (naya chakkar).                   |
//|   F2 Akeli lot spread ke baad +$1 -> band, naya chakkar.          |
//|   F3 Chalti lot -$3.50 -> ulti 0.01 (hedge), kitab jami.          |
//|   F4 Kitab mein (ek se zyada lots) chalti taraf ki koi lot +$5 ->  |
//|      band, kitab jami.                                            |
//|   F5 Jami kitab: qeemat $1.50 chale -> us taraf ki faide wali lot |
//|      (+$1 se zyada) band aur usi taraf nayi (hedge SARKAO). Koi   |
//|      faide mein na ho to rukh ke saath nayi 0.01 (chalti lot).    |
//|   F6 Chakkar ka kul nateeja (band + khula) +1 ho -> CLOSE ALL.    |
//|                                                                  |
//|  HIFAZAT: sirf apni (magic) lots - haath ki ya doosre EA ki lots  |
//|  ko nahi chhoota. Lot hamesha 0.01. Positions ki hadd 20 (sirf    |
//|  nayi chalti lot rukti hai, hedge kabhi nahi). Spread $0.50 se    |
//|  zyada = nayi lot nahi. Equity (attach ke waqt ki) 90% = sab jami |
//|  aur EA ruk. Jumma 19:00 (server) se nayi lot nahi, 20:00 se jami.|
//|                                                                  |
//|  Ye qaide NAAPE NAHI gaye. Pehle Strategy Tester, phir demo.      |
//|  LIVE par nahi jab tak dono saaf na hon. Koi SL / TP nahi.        |
//+------------------------------------------------------------------+
#property copyright "JAS-SNIPER-BOT"
#property version   "1.00"
#property strict

#include <Trade\Trade.mqh>
#define EA_BUILD "f1"          // har nayi file par ye number barhta hai
#define MAXP     300           // zyada se zyada positions jo EA ginta hai

CTrade trade;

// String chunne ka kaam if se - "cond ? \"\" : \"...\"" MetaEditor mein shak wala hai.
string Pick(bool c, string a, string b) { if(c) return(a); return(b); }

//--------------------------- INPUTS -----------------------------------
input group "=== 1 - Lot aur rukh ==="
input bool            InpTrade    = true;       // true = asal kaam; false = sirf panel par batao
input double          InpLot      = 0.01;       // Har lot (kabhi 0.01 se bari nahi)
input bool            InpUseTrend = true;       // Nayi chalti lot sirf rukh ke saath
input ENUM_TIMEFRAMES InpTrendTF  = PERIOD_H1;  // Rukh kis timeframe se
input int             InpTrendEMA = 50;         // Rukh ki EMA

input group "=== 2 - Faasle (gold ki qeemat mein, $) ==="
input double InpDirMove = 1.5;    // Harkat: qeemat kitne $ chale tab kaam (F1, F5)
input double InpTP1     = 1.0;    // Akeli lot kitne $ faide par band - spread ke baad (F2)
input double InpTPBook  = 5.0;    // Kitab mein chalti taraf ki lot kitne $ par band (F4)
input double InpHedgeAt = 3.5;    // Chalti lot kitne $ nuqsan mein ho to hedge (F3)

input group "=== 3 - Close All (F6) ==="
input double InpCloseAll = 1.0;   // Chakkar ka kul (band + khula) itna faida = sab band (account currency)

input group "=== 4 - Hifazat ==="
input int    InpMaxPos     = 20;    // Zyada se zyada positions (nayi chalti lot rukti hai, hedge nahi)
input double InpMaxSpread  = 0.50;  // Spread ($) is se zyada to nayi lot nahi
input double InpEqHaltPct  = 90.0;  // Equity (attach ke waqt ki) is % se neeche: sab jami + ruk
input int    InpFriNoStart = 19;    // Jumma ko is ghante (server) se nayi chalti lot nahi
input int    InpFriFlat    = 20;    // Jumma ko is ghante se kitab jami
input int    InpPauseSec   = 5;     // Do kaam ke darmiyan kam az kam second

input group "=== 5 - Baqi ==="
input int  InpMagic = 20261010;   // EA ki apni lots ka nishan (sirf inhi ko chhoota hai)
input bool InpCsv   = true;       // Har kaam MQL5\Files\JasFishing_<symbol>.csv mein

//--------------------------- GLOBAL STATE ------------------------------
int      g_hEma    = INVALID_HANDLE;
double   g_ref     = 0.0;      // harkat yahan se naapi jati hai
datetime g_cycle   = 0;        // chakkar kab shuru hua (0 = khali kitab)
double   g_cycReal = 0.0;      // is chakkar mein band lots ka nateeja
double   g_eq0     = 0.0;      // attach ke waqt equity
datetime g_lastAct = 0;
bool     g_halted  = false;
bool     g_tester  = false;
string   g_last    = "abhi kuch nahi";
string   g_msg     = "";
int      g_maxPos  = 0;
double   g_lastFlo = 0.0;

// ginti
int    g_n1  = 0;  double g_s1  = 0.0;   // F2 akeli lot band
int    g_nB  = 0;  double g_sB  = 0.0;   // F4 kitab mein band
int    g_nS  = 0;  double g_sS  = 0.0;   // F5 sarkao
int    g_nH  = 0;                         // F3 hedge
int    g_nCA = 0;  double g_sCA = 0.0;   // F6 Close All
int    g_nOp = 0;                         // F1/F5 nayi chalti lot

// EA ki apni positions (har tick par taza)
int      g_cnt = 0;
int      g_nb  = 0;
int      g_ns  = 0;
ulong    g_tk[MAXP];
int      g_dir[MAXP];
double   g_op[MAXP];
double   g_pp[MAXP];     // qeemat mein faida ($), spread ke baad
double   g_pm[MAXP];     // paise mein (profit + swap)
long     g_tms[MAXP];    // khulne ka waqt (milli-second)

//+------------------------------------------------------------------+
//|  CHHOTE KAAM                                                     |
//+------------------------------------------------------------------+
string Px(double v) { return(DoubleToString(v, _Digits)); }
string M(double v)  { return(StringFormat("%+.2f", v)); }

string GVN(string k) { return("JFE" + IntegerToString(InpMagic) + _Symbol + k); }
void   SV(string k, double v) { GlobalVariableSet(GVN(k), v); }
double GV(string k, double d)
  {
   if(GlobalVariableCheck(GVN(k))) return(GlobalVariableGet(GVN(k)));
   return(d);
  }

string TrendName(int t) { return(Pick(t == 1, "UPAR", Pick(t == -1, "NEECHE", "saaf nahi"))); }

bool FridayAfter(int hour)
  {
   MqlDateTime t;
   TimeToStruct(TimeCurrent(), t);
   return(t.day_of_week == 5 && t.hour >= hour);
  }

// H1 rukh: band candle EMA50 ke upar aur EMA 3 candle se upar ja rahi = UPAR
int Trend()
  {
   if(g_hEma == INVALID_HANDLE) return(0);
   double e[];
   ArraySetAsSeries(e, true);
   if(CopyBuffer(g_hEma, 0, 1, 4, e) != 4) return(0);
   double c1 = iClose(_Symbol, InpTrendTF, 1);
   if(c1 <= 0.0) return(0);
   if(c1 > e[0] && e[0] > e[3]) return(1);
   if(c1 < e[0] && e[0] < e[3]) return(-1);
   return(0);
  }

void Log(string what)
  {
   g_last = TimeToString(TimeCurrent(), TIME_DATE | TIME_SECONDS) + "  " + what;
   if(g_tester) return;                       // tester mein sirf aakhri hisaab
   Print("JAS FISHING " + EA_BUILD + " | " + what);
   if(!InpCsv) return;
   int h = FileOpen("JasFishing_" + _Symbol + ".csv",
                    FILE_READ | FILE_WRITE | FILE_CSV | FILE_ANSI | FILE_SHARE_READ, ',');
   if(h == INVALID_HANDLE) return;
   if(FileSize(h) == 0)
      FileWrite(h, "build", "time", "kaam", "lots", "chakkar", "equity");
   if(FileSeek(h, 0, SEEK_END))
      FileWrite(h, EA_BUILD, TimeToString(TimeCurrent(), TIME_DATE | TIME_SECONDS), what,
                IntegerToString(g_cnt), DoubleToString(g_cycReal, 2),
                DoubleToString(AccountInfoDouble(ACCOUNT_EQUITY), 2));
   FileClose(h);
  }

//+------------------------------------------------------------------+
//|  EA KI APNI LOTS                                                 |
//+------------------------------------------------------------------+
void Collect(double bid, double ask)
  {
   g_cnt = 0;
   g_nb  = 0;
   g_ns  = 0;
   for(int i = PositionsTotal() - 1; i >= 0 && g_cnt < MAXP; i--)
     {
      ulong t = PositionGetTicket(i);
      if(t == 0 || !PositionSelectByTicket(t)) continue;
      if(PositionGetString(POSITION_SYMBOL) != _Symbol) continue;
      if(PositionGetInteger(POSITION_MAGIC) != InpMagic) continue;
      int d = 1;
      if(PositionGetInteger(POSITION_TYPE) != POSITION_TYPE_BUY) d = -1;
      double op = PositionGetDouble(POSITION_PRICE_OPEN);
      g_tk[g_cnt]  = t;
      g_dir[g_cnt] = d;
      g_op[g_cnt]  = op;
      g_pp[g_cnt]  = bid - op;
      if(d == -1) g_pp[g_cnt] = op - ask;
      g_pm[g_cnt]  = PositionGetDouble(POSITION_PROFIT) + PositionGetDouble(POSITION_SWAP);
      g_tms[g_cnt] = PositionGetInteger(POSITION_TIME_MSC);
      if(d == 1) g_nb++;
      else       g_ns++;
      g_cnt++;
     }
   if(g_cnt > g_maxPos) g_maxPos = g_cnt;
  }

// is taraf ki sab se nayi lot (chalti lot)
int Newest(int side)
  {
   int  best = -1;
   long tm   = 0;
   for(int i = 0; i < g_cnt; i++)
      if(g_dir[i] == side && (best < 0 || g_tms[i] > tm)) { best = i; tm = g_tms[i]; }
   return(best);
  }

// is taraf ki sab se zyada faide wali lot
int Best(int side)
  {
   int best = -1;
   for(int i = 0; i < g_cnt; i++)
      if(g_dir[i] == side && (best < 0 || g_pp[i] > g_pp[best])) best = i;
   return(best);
  }

bool OpenLot(int d, string why)
  {
   g_lastAct = TimeCurrent();
   trade.SetTypeFillingBySymbol(_Symbol);
   bool ok = false;
   if(d == 1) ok = trade.Buy(InpLot, _Symbol, 0.0, 0.0, 0.0, "JasFishing " + EA_BUILD);
   else       ok = trade.Sell(InpLot, _Symbol, 0.0, 0.0, 0.0, "JasFishing " + EA_BUILD);
   uint rc = trade.ResultRetcode();
   if(!ok || (rc != TRADE_RETCODE_DONE && rc != TRADE_RETCODE_DONE_PARTIAL && rc != TRADE_RETCODE_PLACED))
     {
      if(!g_tester)
         PrintFormat("JAS FISHING %s | %s nahi khuli: %d %s", EA_BUILD, Pick(d == 1, "BUY", "SELL"),
                     rc, trade.ResultRetcodeDescription());
      return(false);
     }
   Log(StringFormat("nayi %s 0.01 @ %s - %s", Pick(d == 1, "BUY", "SELL"), Px(trade.ResultPrice()), why));
   return(true);
  }

bool CloseLot(int i, string why)
  {
   g_lastAct = TimeCurrent();
   trade.SetTypeFillingBySymbol(_Symbol);
   if(!trade.PositionClose(g_tk[i]))
     {
      if(!g_tester)
         PrintFormat("JAS FISHING %s | #%I64u band nahi hui: %d %s", EA_BUILD, g_tk[i],
                     trade.ResultRetcode(), trade.ResultRetcodeDescription());
      return(false);
     }
   Log(StringFormat("%s 0.01 band @ %s, %s - %s", Pick(g_dir[i] == 1, "BUY", "SELL"),
                    Px(trade.ResultPrice()), M(g_pm[i]), why));
   return(true);
  }

//+------------------------------------------------------------------+
//|  DIMAGH - qaide F1..F6                                           |
//+------------------------------------------------------------------+
void Brain(double mid, double spr, int net, double flo, int tr, double eqPct)
  {
   //--- F6: chakkar ka kul (band + khula) faide mein = Close All
   double cyc = g_cycReal + flo;
   if(g_cnt >= 2 && cyc >= InpCloseAll)
     {
      int n = g_cnt;
      for(int i = g_cnt - 1; i >= 0; i--) CloseLot(i, "F6 Close All");
      g_nCA++;
      g_sCA += cyc;
      Log(StringFormat("CLOSE ALL: %d lots, chakkar %s", n, M(cyc)));
      g_ref = mid;
      SV("ref", g_ref);
      return;
     }

   //--- hifazat: equity ki hadd ya Jumma raat = kitab jami
   if(eqPct <= InpEqHaltPct) g_halted = true;
   if(g_halted || FridayAfter(InpFriFlat))
     {
      if(net != 0)
        {
         int hd = 1;
         if(net > 0) hd = -1;
         if(OpenLot(hd, Pick(g_halted, "hifazat: equity", "hifazat: Jumma")))
           { g_nH++; g_ref = mid; SV("ref", g_ref); }
         return;
        }
      g_msg = Pick(g_halted, StringFormat("RUKA: equity %.1f%% (hadd %.0f%%)", eqPct, InpEqHaltPct),
                   "Jumma: kitab jami, nayi lot nahi");
      return;
     }

   //--- chalti lot (NET 0 nahi)
   if(net != 0)
     {
      int d = 1;
      if(net < 0) d = -1;
      int a = Newest(d);
      if(a < 0) return;
      if(g_cnt == 1 && g_pp[a] >= InpTP1)
        {
         // F2: akeli lot +$1
         double got = g_pm[a];
         if(CloseLot(a, "F2 akeli lot faide mein"))
           { g_n1++; g_s1 += got; g_ref = mid; SV("ref", g_ref); }
         return;
        }
      if(g_cnt > 1)
        {
         // F4: kitab mein chalti taraf ki koi lot +$5
         int b = Best(d);
         if(b >= 0 && g_pp[b] >= InpTPBook)
           {
            double got = g_pm[b];
            if(CloseLot(b, "F4 kitab mein faide wali"))
              { g_nB++; g_sB += got; g_ref = mid; SV("ref", g_ref); }
            return;
           }
        }
      if(g_pp[a] <= -InpHedgeAt)
        {
         // F3: chalti lot -$3.50 = hedge
         if(OpenLot(-d, "F3 hedge"))
           { g_nH++; g_ref = mid; SV("ref", g_ref); }
         return;
        }
      double tp = InpTP1;
      if(g_cnt > 1) tp = InpTPBook;
      g_msg = StringFormat("chalti %s %s: abhi %s$ | band %s par | hedge %s par",
                           Pick(d == 1, "BUY", "SELL"), Px(g_op[a]), M(g_pp[a]),
                           Px(g_op[a] + d * tp), Px(g_op[a] - d * InpHedgeAt));
      return;
     }

   //--- NET 0: khali ya jami kitab - harkat ka intezar
   double mv = mid - g_ref;
   if(MathAbs(mv) < InpDirMove)
     {
      g_msg = StringFormat("%s: intezar - upar %s / neeche %s", Pick(g_cnt == 0, "KHALI kitab", "kitab JAMI"),
                           Px(g_ref + InpDirMove), Px(g_ref - InpDirMove));
      return;
     }
   int dd = 1;
   if(mv < 0) dd = -1;

   // F5 SARKAO: us taraf ki faide wali lot band, usi taraf nayi (kitab jami rahe)
   if(g_cnt > 0)
     {
      int b = Best(dd);
      if(b >= 0 && g_pp[b] >= InpTP1)
        {
         double got = g_pm[b];
         if(CloseLot(b, "F5 sarkao"))
           {
            g_nS++;
            g_sS += got;
            OpenLot(dd, "F5 sarkao - wapas jami");
            g_ref = mid;
            SV("ref", g_ref);
           }
         return;
        }
     }

   // F1 / F5: nayi chalti lot, sirf rukh ke saath
   if(InpUseTrend && tr != dd)
     {
      g_msg = StringFormat("harkat %s magar rukh %s - lot nahi, naye sire se naap", Pick(dd == 1, "upar", "neeche"),
                           TrendName(tr));
      g_ref = mid;
      SV("ref", g_ref);
      return;
     }
   if(g_cnt >= InpMaxPos)            { g_msg = StringFormat("Rok: positions %d (hadd %d)", g_cnt, InpMaxPos); return; }
   if(spr > InpMaxSpread)            { g_msg = "Rok: spread bara " + Px(spr); return; }
   if(FridayAfter(InpFriNoStart))    { g_msg = "Rok: Jumma - nayi lot nahi"; return; }

   if(g_cnt == 0)
     {
      g_cycle   = TimeCurrent();
      g_cycReal = 0.0;
      SV("cycle", (double)g_cycle);
      SV("cycReal", g_cycReal);
     }
   if(OpenLot(dd, Pick(g_cnt == 0, "F1 naya chakkar", "F5 rukh ke saath nayi")))
     {
      g_nOp++;
      g_ref = mid;
      SV("ref", g_ref);
     }
  }

//+------------------------------------------------------------------+
//|  PANEL                                                           |
//+------------------------------------------------------------------+
void Panel(double spr, int net, double flo, int tr, double eqPct)
  {
   string st = "KHALI";
   if(g_cnt > 0 && net == 0) st = "JAMI";
   if(net != 0) st = Pick(g_cnt == 1, "AKELI LOT", "CHALTI LOT (kitab mein)");
   string s = "=== JAS FISHING  " + EA_BUILD + " ===   " + _Symbol + " (" + AccountInfoString(ACCOUNT_CURRENCY) + ")\n";
   s += Pick(InpTrade, "ASAL KAAM", "SIRF DIKHANA") + "   |   rukh " + EnumToString(InpTrendTF) + ": " + TrendName(tr)
        + "   |   spread " + Px(spr) + "\n";
   s += StringFormat("Kitab (sirf EA ki): BUY %d  SELL %d  NET %+.2f   |   haal: %s\n", g_nb, g_ns, net * InpLot, st);
   s += StringFormat("Chakkar ka nateeja (band + khula): %s   |   Close All jab %s\n", M(g_cycReal + flo), M(InpCloseAll));
   s += "Abhi: " + g_msg + "\n\n";
   s += StringFormat("Akeli band (F2): %d (%s)   Kitab mein band (F4): %d (%s)\n", g_n1, M(g_s1), g_nB, M(g_sB));
   s += StringFormat("Sarkao (F5): %d (%s)   Hedge (F3): %d   Nayi lot: %d\n", g_nS, M(g_sS), g_nH, g_nOp);
   s += StringFormat("Close All (F6): %d (%s)   |   sab se zyada positions: %d\n", g_nCA, M(g_sCA), g_maxPos);
   s += StringFormat("EQUITY attach se (poora account): %s  (%.1f%%)   <- ASAL SCORE\n",
                     M(AccountInfoDouble(ACCOUNT_EQUITY) - g_eq0), eqPct);
   s += "Aakhri: " + g_last;
   Comment(s);
  }

//+------------------------------------------------------------------+
void Work()
  {
   double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   if(bid <= 0.0 || ask <= 0.0) return;
   double mid = (bid + ask) / 2.0;
   double spr = ask - bid;
   Collect(bid, ask);
   int net = g_nb - g_ns;            // 0.01 ki ginti mein
   double flo = 0.0;
   for(int i = 0; i < g_cnt; i++) flo += g_pm[i];
   g_lastFlo = flo;
   if(g_cnt == 0 && g_cycle != 0) { g_cycle = 0; SV("cycle", 0.0); }
   if(g_ref <= 0.0) { g_ref = mid; SV("ref", g_ref); }
   int    tr    = Trend();
   double eqPct = 100.0;
   if(g_eq0 > 0.0) eqPct = AccountInfoDouble(ACCOUNT_EQUITY) / g_eq0 * 100.0;

   g_msg = "";
   bool can = InpTrade && TerminalInfoInteger(TERMINAL_TRADE_ALLOWED) != 0 && MQLInfoInteger(MQL_TRADE_ALLOWED) != 0;
   if(!InpTrade)                               g_msg = "SIRF DIKHANA - koi lot nahi";
   else if(!can)                               g_msg = "Algo Trading band hai - button HARA karein";
   else if(TimeCurrent() - g_lastAct < InpPauseSec) g_msg = "thehrao";
   else Brain(mid, spr, net, flo, tr, eqPct);

   if(!g_tester || MQLInfoInteger(MQL_VISUAL_MODE) != 0) Panel(spr, net, flo, tr, eqPct);
  }

//+------------------------------------------------------------------+
int OnInit()
  {
   if(InpLot <= 0.0 || InpLot > 0.01 + 1e-9)
     { Print("ERROR: lot sirf 0.01 tak (user ka qaida)."); return(INIT_PARAMETERS_INCORRECT); }
   if(InpDirMove <= 0.0 || InpTP1 <= 0.0 || InpTPBook <= 0.0 || InpHedgeAt <= 0.0)
     { Print("ERROR: faasle 0 se bare hon."); return(INIT_PARAMETERS_INCORRECT); }
   g_tester = (MQLInfoInteger(MQL_TESTER) != 0);
   trade.SetExpertMagicNumber(InpMagic);
   trade.SetDeviationInPoints(50);
   trade.LogLevel(LOG_LEVEL_ERRORS);
   g_hEma = iMA(_Symbol, InpTrendTF, InpTrendEMA, 0, MODE_EMA, PRICE_CLOSE);
   if(g_hEma == INVALID_HANDLE) { Print("ERROR: EMA ka handle nahi bana."); return(INIT_FAILED); }
   g_ref     = GV("ref", 0.0);
   g_cycle   = (datetime)GV("cycle", 0.0);
   g_cycReal = GV("cycReal", 0.0);
   g_eq0     = AccountInfoDouble(ACCOUNT_EQUITY);
   g_halted  = false;
   g_lastAct = 0;
   Comment("=== JAS FISHING  " + EA_BUILD + " ===\nshuru ho raha hai...");
   return(INIT_SUCCEEDED);
  }

void OnDeinit(const int reason)
  {
   if(g_hEma != INVALID_HANDLE) IndicatorRelease(g_hEma);
   Comment("");
  }

void OnTick() { Work(); }

// Band hone wali har lot ka nateeja chakkar mein jorna (F6 ke liye)
void OnTradeTransaction(const MqlTradeTransaction &trans, const MqlTradeRequest &request, const MqlTradeResult &result)
  {
   if(trans.type != TRADE_TRANSACTION_DEAL_ADD) return;
   if(!HistoryDealSelect(trans.deal)) return;
   if(HistoryDealGetInteger(trans.deal, DEAL_MAGIC) != InpMagic) return;
   if(HistoryDealGetString(trans.deal, DEAL_SYMBOL) != _Symbol) return;
   g_cycReal += HistoryDealGetDouble(trans.deal, DEAL_PROFIT) + HistoryDealGetDouble(trans.deal, DEAL_SWAP)
                + HistoryDealGetDouble(trans.deal, DEAL_COMMISSION);
   SV("cycReal", g_cycReal);
  }

//+------------------------------------------------------------------+
//| SIRF TESTER: aakhri hisaab Journal mein. Wapas: kul faida.        |
//+------------------------------------------------------------------+
double OnTester()
  {
   double profit = TesterStatistics(STAT_PROFIT);
   double ddMoney = TesterStatistics(STAT_EQUITY_DD);
   double ddPct   = TesterStatistics(STAT_EQUITYDD_PERCENT);
   PrintFormat("JAS FISHING %s | GINTI: akeli band %d (%s) | kitab mein band %d (%s) | sarkao %d (%s) | hedge %d | nayi lot %d | Close All %d (%s)",
               EA_BUILD, g_n1, M(g_s1), g_nB, M(g_sB), g_nS, M(g_sS), g_nH, g_nOp, g_nCA, M(g_sCA));
   PrintFormat("JAS FISHING %s | KITAB: sab se zyada positions %d | aakhir mein khuli %d lots, khula %s",
               EA_BUILD, g_maxPos, g_cnt, M(g_lastFlo));
   PrintFormat("JAS FISHING %s | KUL: faida %s | equity ki sab se gehri girawat %s (%.1f%%)",
               EA_BUILD, M(profit), M(-ddMoney), ddPct);
   return(profit);
  }
//+------------------------------------------------------------------+
