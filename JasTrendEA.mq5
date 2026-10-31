//====================================================================
//===  BUILD t4   <<< PANEL PAR YAHI NUMBER AANA CHAHIYE >>>
//====================================================================
//+------------------------------------------------------------------+
//|                                                   JasTrendEA.mq5 |
//|  JAS TREND - Supertrend 10/3 daily, SIRF BUY (Koshish #26 tokri  |
//|  ASLI PASS) ka FTMO EA. Python FTMO test #27 (tools/ftmo_test.py) |
//|  ki chuni setting: risk 1%, server SL 4 x ATR(10), TP nahi.       |
//|  2019+ asli data: 94 challenge -> 80 pass, 0 fail (~32 mahine).   |
//|  JasIbsEA i3 jaisa dhaancha: daily candle EA khud H1 se banata    |
//|  hai, 17:00 New York par band (TV / OANDA / Python test jaisi).   |
//|                                                                  |
//|  QAWAID (har daily candle par, 17:00 NY se InpPreMin pehle):     |
//|   1) Supertrend(3, 10) - TradingView ta.supertrend jaisa (RMA ATR)|
//|   2) BUY: Supertrend NEECHE se UPAR palta (is candle par). Sirf   |
//|      BUY, short kabhi nahi.                                       |
//|   3) Band: Supertrend UPAR se NEECHE palta = usi waqt band.       |
//|   4) SL server par: entry - 4 x ATR(10) (signal candle). TP nahi. |
//|   5) SL lagne ke baad nayi BUY sirf NAYE palte par (Python jaisa).|
//|   6) Lot = 1% risk (lot hadd 2.00). HAR MARKET par ek position.   |
//|   7) EA lagne ke baad pehli candle par nayi trade nahi.          |
//|                                                                  |
//|  FTMO PEHRA (InpStartBal > 0 ho to): equity target par = sab band |
//|  + EA ruk jata (4 din ki shart khud dekhein); din ka nuksan       |
//|  InpDayStopPct (CET aadhi raat ke balance se) = sab band, us din |
//|  nayi nahi; kul nuksan InpMaxDdPct = sab band + EA ruk jata.     |
//|  Pehra sirf IS EA ki trades band karta hai (equity poore account |
//|  ki dekhta hai).                                                  |
//|                                                                  |
//|  Markets: Exness XAUUSD,XAGUSD,US500,USTEC (suffix auto = 'm').  |
//|  FTMO: InpSymbols = XAUUSD,XAGUSD,US500.cash,US100.cash, suffix   |
//|  khali (ya auto, XAUUSD chart par). Swing account (weekend).     |
//|  InpTrade false = SIRF DIKHANA.                                   |
//|  t2 (28 Oct): pehra ki har baat Journal mein (Tester mein bhi) +  |
//|  shuru mein pehra ki settings; "market closed" par is waqt dobara |
//|  koshish nahi (agli session khulne par); faisla na ho sake to     |
//|  minute baad dobara (Tester tez). Trading ke qaide t1 wale hi.    |
//|  t3 (29 Oct): InpTfH = 4 -> 4H candle (H1 se, NY 17:00 se jura:  |
//|  17,21,01,05,09,13 NY) = Koshish #34 4H TOKRI ASLI PASS (2019+    |
//|  641 tr +0.208R). Hifazati SL 6 x ATR(4H) = 2R (Python: 2019+     |
//|  kabhi nahi laga, nateeja wahi). InpTfH = 24 -> purana daily      |
//|  (#27 FTMO: tab InpSlMult 4). Faisla candle band se InpPreMin     |
//|  pehle. Nayi magic 20261029 (t2 daily 20261028 alag chalta hai).  |
//|                                                                  |
//|  NO grid / NO martingale / NO hedging / NO averaging.            |
//+------------------------------------------------------------------+
#property copyright "JAS-SNIPER-BOT"
#property version   "1.00"

#include <Trade\Trade.mqh>
#define EA_BUILD "t4"          // har nayi file par ye number barhta hai
// t4 (31 Oct 2026): FTMO #49 ASLI PASS ki setting DEFAULT - 4H, SL 6 ATR, risk 0.75%, lot hadd 20,
//     FTMO pehra 100000 (target 10 / din 4 / kul 8), TRADE true. Sirf FTMO demo 474832446 ke liye.
#define MAXM 10

CTrade trade;

// String chunne ka kaam if se - "cond ? \"\" : \"...\"" MetaEditor mein shak wala hai.
string Pick(bool c, string a, string b) { if(c) return(a); return(b); }

//--------------------------- INPUTS -----------------------------------
input group "=== 0 - Markets ==="
input string InpSymbols    = "XAUUSD,XAGUSD,US500,USTEC"; // Markets (comma se). FTMO: XAUUSD,XAGUSD,US500.cash,US100.cash
input string InpSuffix     = "auto";   // Suffix (Exness demo m) - auto = chart ke symbol se, FTMO khali

input group "=== 1 - Qawaid (Python #27 jaise - mat badlein) ==="
input int    InpAtrLen     = 10;       // Supertrend ATR length
input double InpStMult     = 3.0;      // Supertrend multiplier
input int    InpTfH        = 4;        // Candle: 4 = 4H (#34 ASLI PASS), 24 = daily (#26/#27)
input double InpSlMult     = 6.0;      // Server SL (x ATR): 4H = 6 (hifazat 2R), daily FTMO #27 = 4

input group "=== 2 - Risk ==="
input bool   InpTrade      = true;     // TRADE KARE? false = sirf dikhaye (Tester mein hamesha trade)
input double InpRiskPct    = 0.75;     // Har trade ka risk (% balance) - #49: 0.75
input double InpMaxRiskPct = 2.0;      // Sab se chhoti lot ka risk is % se zyada = trade nahi
input double InpMaxLot     = 20.0;     // Lot ki hadd (hifazat) - $100k par 20

input group "=== 3 - FTMO pehra (shuru balance 0 = band) ==="
input double InpStartBal   = 100000.0; // Challenge ka shuru balance (FTMO 100000). 0 = pehra band
input double InpTargetPct  = 10.0;     // Target % (Phase 1 = 10, Phase 2 = 5) - pahunche to sab band, EA ruk jaye
input double InpDayStopPct = 4.0;      // Din ka nuksan % (FTMO 5) - is par sab band, us din nayi nahi
input double InpMaxDdPct   = 8.0;      // Kul nuksan % (FTMO 10) - is par sab band, EA ruk jaye

input group "=== 4 - Amal ==="
input int    InpBars       = 1200;     // Kitni daily candles parhni
input int    InpSlippage   = 50;       // Max slippage (points)
input int    InpMagic      = 20261029; // Magic number (t2 daily = 20261028)
input datetime InpStatFrom = D'2019.01.01'; // Tester: hisaab is tareekh se khuli trades ka
input int    InpServerGMT  = -1;       // Broker server ka GMT farq (-1 = auto, Exness = 0)
input int    InpPreMin     = 5;        // 17:00 NY se kitne minute pehle faisla

//--------------------------- HAAL (har market ka alag) ---------------
int      g_n = 0;
string   g_suffix = "";
string   g_base[MAXM];
string   g_sym[MAXM];
bool     g_have[MAXM];
string   g_label = "";
datetime g_lastD1[MAXM];       // NY session (din) jis ke shuru par mukammal candle dekh li
int      g_dstY = 0;
datetime g_dstA = 0, g_dstB = 0;
int      g_euY = 0;
datetime g_euA = 0, g_euB = 0;
datetime g_doneT[MAXM];        // aakhri candle jis par faisla ho gaya
datetime g_failT[MAXM];
bool     g_initBar[MAXM];      // EA lagne ke baad pehli candle: sirf band ki jaanch, nayi trade nahi
string   g_state[MAXM];
// panel ke liye aakhri candle ki values
double   g_c[MAXM], g_st[MAXM], g_atr[MAXM];
bool     g_up[MAXM];
datetime g_barT[MAXM];
string   S = "";               // abhi kis market ka kaam ho raha hai (sab chhote kaam isi par)
int      g_i = 0;              // S ka number (g_sym mein)
string   g_lastAct = "abhi kuch nahi";
double   g_totR    = 0.0;
string   g_statsTxt = "EA ki band trades: 0";
bool     g_statsDirty = true;
datetime g_lastStats = 0;
// FTMO pehra
string   g_gv = "";            // GlobalVariable ka shuru naam (account + magic)
int      g_dayId = 0;          // CET din (yyyymmdd)
double   g_dayBal = 0.0;       // CET aadhi raat ka balance
bool     g_dayStop = false;    // aaj din ki hadd lag gayi
int      g_stop = 0;           // 1 = target poora, 2 = kul hadd - EA ruk gaya
string   g_guardTxt = "";

struct TPos
  {
   long     id;
   int      dir;
   double   pin;
   double   isl;
   double   vin;
   double   vout;
   double   prof;
   double   swap;
   double   comm;
   datetime t0;
   datetime cl;
   int      why;     // 1 = SL, 2 = Supertrend / pehra / haath
   int      sday;    // comment ka signal din (yyyymmdd)
   double   pout;    // band deals ka (qeemat x lot) jor - ausat band qeemat ke liye
  };

//+------------------------------------------------------------------+
//|  CHHOTE KAAM                                                     |
//+------------------------------------------------------------------+
datetime AddSec(datetime t, long s) { return((datetime)((long)t + s)); }

int YMD(datetime t)
  {
   MqlDateTime s;
   TimeToStruct(t, s);
   return(s.year * 10000 + s.mon * 100 + s.day);
  }

double Base() { return(AccountInfoDouble(ACCOUNT_BALANCE)); }

// Server ka GMT farq (ghante). -1 = auto: live par server - GMT; Tester mein 0 (Exness data)
int GmtOff()
  {
   if(InpServerGMT != -1) return(InpServerGMT);
   if(MQLInfoInteger(MQL_TESTER) != 0) return(0);
   long d = (long)TimeTradeServer() - (long)TimeGMT();
   return((int)MathRound(d / 3600.0));
  }

//+------------------------------------------------------------------+
//|  NEW YORK WAQT (JasIbsEA i3 se) - US DST: March 2nd Sun - Nov 1st |
//+------------------------------------------------------------------+
datetime NthSunday(int year, int mon, int n)
  {
   MqlDateTime s;
   ZeroMemory(s);
   s.year = year;
   s.mon  = mon;
   s.day  = 1;
   datetime d1 = StructToTime(s);
   MqlDateTime w;
   TimeToStruct(d1, w);
   int add = (7 - w.day_of_week) % 7;
   return(AddSec(d1, (long)(add + 7 * (n - 1)) * 86400));
  }

bool UsDst(datetime utc)
  {
   MqlDateTime s;
   TimeToStruct(utc, s);
   if(s.year != g_dstY)
     {
      g_dstY = s.year;
      g_dstA = AddSec(NthSunday(s.year, 3, 2), 7 * 3600);
      g_dstB = AddSec(NthSunday(s.year, 11, 1), 6 * 3600);
     }
   return(utc >= g_dstA && utc < g_dstB);
  }

datetime ServerToNy(datetime srv)
  {
   datetime utc = AddSec(srv, -(long)GmtOff() * 3600);
   if(UsDst(utc)) return(AddSec(utc, -4 * 3600));
   return(AddSec(utc, -5 * 3600));
  }

datetime NyToServer(datetime ny)
  {
   datetime utc = AddSec(ny, 4 * 3600);
   if(!UsDst(utc)) utc = AddSec(ny, 5 * 3600);
   return(AddSec(utc, (long)GmtOff() * 3600));
  }

// NY waqt -> session ka din (00:00). 17:00 NY ke baad = agla din (TV / OANDA daily candle)
datetime SessDay(datetime ny)
  {
   long x = (long)ny + 7 * 3600;
   return((datetime)(x - x % 86400));
  }

// Session (din) kis server waqt par shuru hui = pichhle din 17:00 NY
datetime SessStart(datetime day) { return(NyToServer(AddSec(day, -7 * 3600))); }

// t3: candle ki lambai (sec) - 4H ya daily
long BlkSec() { return((long)InpTfH * 3600); }
// NY waqt -> candle ki chabi: session din (00:00) + 4H block (0..5) x 4 ghante. Daily = SessDay
datetime BarKey(datetime ny)
  {
   datetime d = SessDay(ny);
   if(InpTfH >= 24) return(d);
   long x = ((long)ny + 7 * 3600) % 86400;
   return(AddSec(d, (x / BlkSec()) * BlkSec()));
  }
datetime DayOf(datetime key) { return((datetime)((long)key - (long)key % 86400)); }
// candle kis server waqt par shuru hui
datetime BarStart(datetime key) { return(AddSec(SessStart(DayOf(key)), (long)key % 86400)); }
// comment ka number: daily = yyyymmdd, 4H = yyyymmdd x 10 + block
int BarId(datetime key)
  {
   if(InpTfH >= 24) return(YMD(key));
   return(YMD(key) * 10 + (int)(((long)key % 86400) / BlkSec()));
  }

//+------------------------------------------------------------------+
//|  CET / CEST (FTMO ka din) - EU DST: March aakhri Sun - Oct aakhri |
//+------------------------------------------------------------------+
datetime LastSunday(int year, int mon)
  {
   MqlDateTime s;
   ZeroMemory(s);
   s.year = year;
   s.mon  = mon + 1;
   if(mon == 12) { s.year = year + 1; s.mon = 1; }
   s.day  = 1;
   datetime d = AddSec(StructToTime(s), -86400);    // mahine ka aakhri din
   MqlDateTime w;
   TimeToStruct(d, w);
   return(AddSec(d, -(long)w.day_of_week * 86400));
  }

int CetDay(datetime srv)
  {
   datetime utc = AddSec(srv, -(long)GmtOff() * 3600);
   MqlDateTime s;
   TimeToStruct(utc, s);
   if(s.year != g_euY)
     {
      g_euY = s.year;
      g_euA = AddSec(LastSunday(s.year, 3), 3600);
      g_euB = AddSec(LastSunday(s.year, 10), 3600);
     }
   long off = 3600;
   if(utc >= g_euA && utc < g_euB) off = 7200;
   return(YMD(AddSec(utc, off)));
  }

double MinStop()
  {
   long a = SymbolInfoInteger(S, SYMBOL_TRADE_STOPS_LEVEL);
   long b = SymbolInfoInteger(S, SYMBOL_TRADE_FREEZE_LEVEL);
   long lvl = MathMax(a, b);
   return((double)lvl * SymbolInfoDouble(S, SYMBOL_POINT));
  }

// Qeemat broker ke tick par gol (warna "invalid stops")
double NormPx(double v)
  {
   double ts = SymbolInfoDouble(S, SYMBOL_TRADE_TICK_SIZE);
   if(ts > 0.0) v = MathRound(v / ts) * ts;
   return(NormalizeDouble(v, (int)SymbolInfoInteger(S, SYMBOL_DIGITS)));
  }

string Px(double v) { return(DoubleToString(v, (int)SymbolInfoInteger(S, SYMBOL_DIGITS))); }

// Market abhi chal raha hai? (taza tick, qeemat maujood)
bool MarketLive()
  {
   MqlTick tk;
   if(!SymbolInfoTick(S, tk)) return(false);
   if(tk.bid <= 0.0 || tk.ask <= 0.0) return(false);
   return(TimeCurrent() - tk.time < 600);
  }

bool Is247()
  {
   return(StringFind(S, "BTC") >= 0 || StringFind(S, "ETH") >= 0);
  }

// 1% risk ki lot. riskPct = asal risk. 0 = trade nahi.
double LotFor(int dir, double price, double slv, double &riskPct)
  {
   riskPct = 0.0;
   double loss = 0.0;
   ENUM_ORDER_TYPE ot = ORDER_TYPE_BUY;
   if(dir == -1) ot = ORDER_TYPE_SELL;
   if(!OrderCalcProfit(ot, S, 1.0, price, slv, loss)) return(0.0);
   loss = MathAbs(loss);
   double base = Base();
   if(loss <= 0.0 || base <= 0.0) return(0.0);
   double step = SymbolInfoDouble(S, SYMBOL_VOLUME_STEP);
   double mn   = SymbolInfoDouble(S, SYMBOL_VOLUME_MIN);
   double mx   = SymbolInfoDouble(S, SYMBOL_VOLUME_MAX);
   if(step <= 0.0) step = 0.01;
   double lots = MathFloor(base * InpRiskPct / 100.0 / loss / step + 1e-9) * step;
   if(lots < mn - 1e-12)
     {
      riskPct = mn * loss / base * 100.0;
      if(riskPct > InpMaxRiskPct) return(0.0);   // chhoti se chhoti lot bhi bohot bari
      lots = mn;
     }
   if(lots > mx) lots = mx;
   if(lots > InpMaxLot) lots = InpMaxLot;
   int vd = 0;
   while(vd < 8 && MathAbs(step * MathPow(10, vd) - MathRound(step * MathPow(10, vd))) > 1e-9) vd++;
   lots = NormalizeDouble(lots, vd);
   riskPct = lots * loss / base * 100.0;
   return(lots);
  }

// Comment: "TRD <signal din yyyymmdd> <shuru ka SL>"
void ParseCmt(string c, int &day, double &isl)
  {
   day = 0;
   isl = 0.0;
   string p[];
   int n = StringSplit(c, StringGetCharacter(" ", 0), p);
   if(n >= 3 && p[0] == "TRD")
     {
      day = (int)StringToInteger(p[1]);
      isl = StringToDouble(p[2]);
     }
  }

// EA ki khuli position (is market par). day = comment ka signal din (0 = nahi mila)
bool FindPos(ulong &tk, int &dir, double &op, double &sl, int &day, datetime &t0)
  {
   for(int k = PositionsTotal() - 1; k >= 0; k--)
     {
      ulong t = PositionGetTicket(k);
      if(t == 0) continue;
      if(PositionGetString(POSITION_SYMBOL) != S) continue;
      if(PositionGetInteger(POSITION_MAGIC) != InpMagic) continue;
      tk  = t;
      dir = 1;
      if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL) dir = -1;
      op  = PositionGetDouble(POSITION_PRICE_OPEN);
      sl  = PositionGetDouble(POSITION_SL);
      t0  = (datetime)PositionGetInteger(POSITION_TIME);
      double isl = 0.0;
      ParseCmt(PositionGetString(POSITION_COMMENT), day, isl);
      return(true);
     }
   return(false);
  }

bool HasPos()
  {
   ulong    tk = 0;
   int      dir = 0, day = 0;
   double   op = 0.0, sl = 0.0;
   datetime t0 = 0;
   return(FindPos(tk, dir, op, sl, day, t0));
  }

// Is signal din par trade pehle khul chuki? (restart ke baad dobara nahi)
bool SigUsed(int day)
  {
   datetime now = TimeCurrent();
   if(!HistorySelect(AddSec(now, -20 * 86400), AddSec(now, 60))) return(false);
   int nd = HistoryDealsTotal();
   for(int k = nd - 1; k >= 0; k--)
     {
      ulong t = HistoryDealGetTicket(k);
      if(t == 0) continue;
      if(HistoryDealGetInteger(t, DEAL_MAGIC) != InpMagic) continue;
      if(HistoryDealGetString(t, DEAL_SYMBOL) != S) continue;
      if(HistoryDealGetInteger(t, DEAL_ENTRY) != DEAL_ENTRY_IN) continue;
      int    dd  = 0;
      double isl = 0.0;
      ParseCmt(HistoryDealGetString(t, DEAL_COMMENT), dd, isl);
      if(dd == day) return(true);
     }
   return(false);
  }

// Python #27: jis din SL laga us din nayi nahi (naya palta hi chahiye)
bool SlHitSince(datetime since)
  {
   if(!HistorySelect(since, AddSec(TimeCurrent(), 60))) return(false);
   int nd = HistoryDealsTotal();
   for(int k = nd - 1; k >= 0; k--)
     {
      ulong t = HistoryDealGetTicket(k);
      if(t == 0) continue;
      if(HistoryDealGetInteger(t, DEAL_MAGIC) != InpMagic) continue;
      if(HistoryDealGetString(t, DEAL_SYMBOL) != S) continue;
      if(HistoryDealGetInteger(t, DEAL_ENTRY) == DEAL_ENTRY_IN) continue;
      if(HistoryDealGetInteger(t, DEAL_REASON) != DEAL_REASON_SL) continue;
      if((datetime)HistoryDealGetInteger(t, DEAL_TIME) >= since) return(true);
     }
   return(false);
  }

void Note(string s, bool always = false)
  {
   g_lastAct = TimeToString(TimeCurrent(), TIME_DATE | TIME_MINUTES) + " " + S + " " + s;
   if(always || MQLInfoInteger(MQL_TESTER) == 0)
      Print("JAS TREND " + EA_BUILD + " | " + g_lastAct);
  }

bool ClosePos(ulong tk, string why)
  {
   trade.SetTypeFillingBySymbol(S);
   if(trade.PositionClose(tk))
     {
      Note(StringFormat("BAND (%s) @ %s", why, Px(trade.ResultPrice())));
      g_statsDirty = true;
      return(true);
     }
   g_failT[g_i] = TimeCurrent();
   if(trade.ResultRetcode() == TRADE_RETCODE_MARKET_CLOSED) g_failT[g_i] = AddSec(TimeCurrent(), 900);   // bazaar khulne tak
   PrintFormat("JAS TREND %s | %s band nahi hui: %d %s", EA_BUILD, S, trade.ResultRetcode(), trade.ResultRetcodeDescription());
   return(false);
  }

//+------------------------------------------------------------------+
//|  DAILY CANDLES (JasIbsEA i3) - H1 se, 17:00 NY par band. T = din  |
//|  (NY tareekh 00:00). Sat/Sun ki chhoti candle agle din mein.      |
//|  withNow = chalti session bhi (close = abhi ki qeemat).           |
//+------------------------------------------------------------------+
int LoadBars(datetime &T[], double &H[], double &L[], double &C[], bool withNow)
  {
   MqlRates rt[];
   int got = CopyRates(S, PERIOD_H1, 0, InpBars * 24 + 48, rt);
   if(got <= 0) return(0);
   ArrayResize(T, got);
   ArrayResize(H, got);
   ArrayResize(L, got);
   ArrayResize(C, got);
   bool nonstop = Is247();
   datetime nowDay = BarKey(ServerToNy(TimeCurrent()));
   int  m = 0;
   bool pend = false;
   double pH = 0.0, pL = 0.0;
   for(int k = 0; k < got; k++)
     {
      datetime d = BarKey(ServerToNy(rt[k].time));
      MqlDateTime st;
      TimeToStruct(d, st);
      bool wkend = (!nonstop) && (st.day_of_week == 0 || st.day_of_week == 6);
      if(wkend)
        {
         if(!pend) { pH = rt[k].high; pL = rt[k].low; pend = true; }
         else      { pH = MathMax(pH, rt[k].high); pL = MathMin(pL, rt[k].low); }
         continue;
        }
      if(m > 0 && T[m - 1] == d)
        {
         H[m - 1] = MathMax(H[m - 1], rt[k].high);
         L[m - 1] = MathMin(L[m - 1], rt[k].low);
         C[m - 1] = rt[k].close;
         continue;
        }
      T[m] = d;
      H[m] = rt[k].high;
      L[m] = rt[k].low;
      C[m] = rt[k].close;
      if(pend)
        {
         H[m] = MathMax(pH, H[m]);
         L[m] = MathMin(pL, L[m]);
         pend = false;
        }
      m++;
     }
   // sab se purani session adhoori ho sakti hai (H1 ki ginti wahan khatam) - chhor do
   int from = 1;
   if(m > 0 && T[m - 1] == nowDay && !withNow) m--;   // chalti session nahi chahiye
   if(withNow && (m == 0 || T[m - 1] != nowDay)) return(0);
   m -= from;
   if(m < 0) m = 0;
   for(int k = 0; k < m; k++)
     {
      T[k] = T[k + from];
      H[k] = H[k + from];
      L[k] = L[k + from];
      C[k] = C[k + from];
     }
   ArrayResize(T, m);
   ArrayResize(H, m);
   ArrayResize(L, m);
   ArrayResize(C, m);
   return(m);
  }

// Pine ta.atr jaisa (true range ka RMA, pehli value SMA se). 0 = abhi nahi bana
void CalcAtr(const double &H[], const double &L[], const double &C[], int m, int len, double &A[])
  {
   ArrayResize(A, m);
   for(int k = 0; k < m; k++) A[k] = 0.0;
   double s = 0.0, a = 0.0;
   for(int k = 0; k < m; k++)
     {
      double tr = H[k] - L[k];
      if(k > 0) tr = MathMax(tr, MathMax(MathAbs(H[k] - C[k - 1]), MathAbs(L[k] - C[k - 1])));
      if(k < len)
        {
         s += tr;
         if(k == len - 1) { a = s / len; A[k] = a; }
         continue;
        }
      a = (a * (len - 1) + tr) / len;
      A[k] = a;
     }
  }

// Pine ta.supertrend(mult, len): UP[k] = rukh upar (Pine dir < 0), ST[k] = line. ATR na ho = 0
void CalcSt(const double &H[], const double &L[], const double &C[], const double &A[], int m,
            bool &UP[], double &ST[])
  {
   ArrayResize(UP, m);
   ArrayResize(ST, m);
   double lo = 0.0, hi = 0.0, st = 0.0;
   bool   first = true;
   for(int k = 0; k < m; k++)
     {
      UP[k] = false;
      ST[k] = 0.0;
      if(A[k] <= 0.0) continue;
      double src = (H[k] + L[k]) / 2.0;
      double lb  = src - InpStMult * A[k];
      double ub  = src + InpStMult * A[k];
      int    d   = 1;
      if(!first)
        {
         if(!(lb > lo || C[k - 1] < lo)) lb = lo;
         if(!(ub < hi || C[k - 1] > hi)) ub = hi;
         if(st == hi) { if(C[k] > ub) d = -1; else d = 1; }
         else         { if(C[k] < lb) d = 1;  else d = -1; }
        }
      first = false;
      if(d == -1) st = lb;
      else        st = ub;
      lo = lb;
      hi = ub;
      UP[k] = (d == -1);
      ST[k] = st;
     }
  }

//+------------------------------------------------------------------+
//|  ENTRY (sirf BUY)                                                |
//+------------------------------------------------------------------+
// false = dobara koshish (order fail); true = kaam ho gaya ya chhor diya
bool TryOpen(double c, double atr, int day, bool canTrade)
  {
   double slv = NormPx(c - InpSlMult * atr);
   MqlTick t;
   if(!SymbolInfoTick(S, t)) return(false);
   double px  = t.ask;
   double gap = t.bid - slv;
   if(gap <= MinStop() + SymbolInfoDouble(S, SYMBOL_POINT))
     {
      Note(StringFormat("BUY CHHOOTI: qeemat SL %s ke bohot qareeb / paar", Px(slv)));
      return(true);
     }
   double rp = 0.0;
   double lots = LotFor(1, px, slv, rp);
   if(lots <= 0.0)
     {
      Note(StringFormat("BUY CHHOOTI: chhoti lot bhi %.1f%% se zyada risk", InpMaxRiskPct));
      return(true);
     }
   if(!canTrade)
     {
      Note(StringFormat("BUY HOTA (sirf dikhana) %.2f @ %s | SL %s, risk %.2f%%", lots, Px(px), Px(slv), rp));
      return(true);
     }
   string cmt = StringFormat("TRD %d %s", day, Px(slv));
   trade.SetTypeFillingBySymbol(S);
   bool ok = trade.Buy(lots, S, 0.0, slv, 0.0, cmt);
   if(ok && trade.ResultRetcode() == TRADE_RETCODE_DONE)
     {
      g_statsDirty = true;
      Note(StringFormat("KHULI BUY %.2f @ %s | SL %s, risk %.2f%%", lots, Px(trade.ResultPrice()), Px(slv), rp));
      return(true);
     }
   g_failT[g_i] = TimeCurrent();
   if(trade.ResultRetcode() == TRADE_RETCODE_MARKET_CLOSED) g_failT[g_i] = AddSec(TimeCurrent(), 900);   // bazaar khulne tak
   PrintFormat("JAS TREND %s | %s BUY nahi khuli: %d %s", EA_BUILD, S, trade.ResultRetcode(), trade.ResultRetcodeDescription());
   return(HasPos());   // broker ka jawab jo bhi ho, position bani = kaam ho gaya
  }

//+------------------------------------------------------------------+
//|  MARKET CHUNO - S aur g_i set (sab chhote kaam S par chalte hain)  |
//+------------------------------------------------------------------+
void Use(int i) { g_i = i; S = g_sym[i]; }

int SymIdx(string sym)
  {
   for(int i = 0; i < g_n; i++) if(g_sym[i] == sym) return(i);
   return(-1);
  }

//+------------------------------------------------------------------+
//|  FAISLA - market i ki har daily candle par ek dafa                |
//|  false = abhi nahi ho saka (data / market band / order fail)     |
//+------------------------------------------------------------------+
bool Decide(int i, bool canTrade, bool withNow)
  {
   Use(i);
   datetime T[];
   double   H[], L[], C[];
   int m = LoadBars(T, H, L, C, withNow);
   int need = InpAtrLen * 3 + 5;
   if(m < need)
     {
      g_state[i] = StringFormat("candles kam hain (%d, chahiye %d) - History load ho rahi hai", m, need);
      return(false);
     }
   double A[], ST[];
   bool   UP[];
   CalcAtr(H, L, C, m, InpAtrLen, A);
   CalcSt(H, L, C, A, m, UP, ST);
   int k = m - 1;
   g_barT[i] = T[k];
   g_c[i]    = C[k];
   g_atr[i]  = A[k];
   g_st[i]   = ST[k];
   g_up[i]   = UP[k];
   if(T[k] == g_doneT[i]) return(true);             // ye candle pehle dekh li
   if(g_atr[i] <= 0.0 || ST[k - 1] <= 0.0) return(false);
   if(!MarketLive()) return(false);                // market khulne par

   ulong    tk = 0;
   int      dir = 0, pday = 0;
   double   op = 0.0, sl = 0.0;
   datetime t0 = 0;
   bool     has = FindPos(tk, dir, op, sl, pday, t0);
   bool     closedNow = false;
   if(has && !UP[k])
     {
      if(canTrade)
        {
         if(!ClosePos(tk, "Supertrend NEECHE palta")) return(false);
         closedNow = true;
        }
      else Note("band hona chahiye (Supertrend NEECHE) - Algo Trading band hai");
      has = HasPos();
     }
   bool flipUp = (UP[k] && !UP[k - 1]);
   if(g_initBar[i])
     {
      g_initBar[i] = false;
      if(!has) Note(StringFormat("EA laga: %s ki candle par nayi trade nahi (der se entry nahi) - agli band candle se", TimeToString(T[k], TIME_DATE)));
     }
   else if(!has && !closedNow && flipUp)
     {
      int day = BarId(T[k]);
      if(g_stop > 0 || g_dayStop)
         Note(StringFormat("BUY palta %s magar FTMO pehra laga hai - nayi nahi", TimeToString(T[k], TIME_DATE)), true);
      else if(SlHitSince(BarStart(T[k])))
         Note(StringFormat("BUY palta %s magar is candle par SL laga tha - nayi nahi", TimeToString(T[k], TIME_DATE)));
      else if(!SigUsed(day))
         if(!TryOpen(g_c[i], g_atr[i], day, canTrade)) return(false);
     }
   g_doneT[i] = T[k];
   return(true);
  }

//+------------------------------------------------------------------+
//|  FTMO PEHRA - har tick par (InpStartBal > 0)                      |
//+------------------------------------------------------------------+
void CloseAll(string why, bool canTrade)
  {
   for(int i = 0; i < g_n; i++)
     {
      if(!g_have[i]) continue;
      Use(i);
      ulong    tk = 0;
      int      dir = 0, pday = 0;
      double   op = 0.0, sl = 0.0;
      datetime t0 = 0;
      if(!FindPos(tk, dir, op, sl, pday, t0)) continue;
      if(canTrade && TimeCurrent() - g_failT[i] > 60) ClosePos(tk, why);   // fail ho to minute baad (closed = bazaar khulne par)
     }
  }

void Guard(bool canTrade)
  {
   if(InpStartBal <= 0.0)
     {
      g_guardTxt = "FTMO pehra: band (shuru balance 0)";
      return;
     }
   double eq  = AccountInfoDouble(ACCOUNT_EQUITY);
   double bal = Base();
   int    day = CetDay(TimeCurrent());
   if(day != g_dayId)
     {
      // naya CET din: aadhi raat ka balance (restart par wahi din ho to purana yaad)
      double gd = 0.0, gb = 0.0;
      if(GlobalVariableGet(g_gv + "D", gd) && (int)gd == day && GlobalVariableGet(g_gv + "B", gb))
         g_dayBal = gb;
      else
        {
         g_dayBal = bal;
         GlobalVariableSet(g_gv + "D", day);
         GlobalVariableSet(g_gv + "B", bal);
        }
      g_dayId   = day;
      g_dayStop = false;
     }
   double dayFloor = g_dayBal - InpDayStopPct / 100.0 * InpStartBal;
   double ddFloor  = InpStartBal * (1.0 - InpMaxDdPct / 100.0);
   double target   = InpStartBal * (1.0 + InpTargetPct / 100.0);
   if(g_stop == 0 && eq >= target)
     {
      g_stop = 1;
      GlobalVariableSet(g_gv + "S", 1);
      S = "";
      Note(StringFormat("TARGET POORA: equity %.2f >= %.2f - sab band, EA ruk gaya", eq, target), true);
     }
   if(g_stop == 0 && eq <= ddFloor)
     {
      g_stop = 2;
      GlobalVariableSet(g_gv + "S", 2);
      S = "";
      Note(StringFormat("KUL HADD: equity %.2f <= %.2f - sab band, EA ruk gaya", eq, ddFloor), true);
     }
   if(!g_dayStop && g_stop == 0 && eq <= dayFloor)
     {
      g_dayStop = true;
      S = "";
      Note(StringFormat("DIN KI HADD: equity %.2f <= %.2f - sab band, aaj nayi nahi", eq, dayFloor), true);
     }
   if(g_stop > 0 || g_dayStop) CloseAll(Pick(g_stop == 1, "target", Pick(g_stop == 2, "kul hadd", "din ki hadd")), canTrade);
   string st = "chalu";
   if(g_stop == 1)  st = "TARGET POORA - EA ruka (FTMO ke 4 din khud check karein)";
   if(g_stop == 2)  st = "KUL HADD - EA ruka";
   if(g_stop == 0 && g_dayStop) st = "DIN KI HADD - aaj nayi nahi";
   g_guardTxt = StringFormat("FTMO pehra: %s | target %.0f | din ka farsh %.0f (CET %d ka balance %.0f) | kul farsh %.0f",
                             st, target, dayFloor, g_dayId, g_dayBal, ddFloor);
  }

//+------------------------------------------------------------------+
//|  HISAAB - EA ki band trades R mein (sab markets mila kar)        |
//+------------------------------------------------------------------+
void Stats(bool doPrint)
  {
   g_statsDirty = false;
   if(!HistorySelect(0, AddSec(TimeCurrent(), 86400))) return;
   int  nd = HistoryDealsTotal();
   TPos ps[];
   int  pm[];                                     // har position kis market ki
   int  np = 0;
   for(int k = 0; k < nd; k++)
     {
      ulong t = HistoryDealGetTicket(k);
      if(t == 0) continue;
      if(HistoryDealGetInteger(t, DEAL_MAGIC) != InpMagic) continue;
      int mi = SymIdx(HistoryDealGetString(t, DEAL_SYMBOL));
      if(mi < 0) continue;
      long id = HistoryDealGetInteger(t, DEAL_POSITION_ID);
      int  x  = -1;
      for(int j = np - 1; j >= 0; j--) if(ps[j].id == id) { x = j; break; }
      double vol = HistoryDealGetDouble(t, DEAL_VOLUME);
      if(HistoryDealGetInteger(t, DEAL_ENTRY) == DEAL_ENTRY_IN)
        {
         if(x >= 0) continue;
         np++;
         ArrayResize(ps, np);
         ArrayResize(pm, np);
         x = np - 1;
         pm[x] = mi;
         int    dday = 0;
         double isl  = 0.0;
         ParseCmt(HistoryDealGetString(t, DEAL_COMMENT), dday, isl);
         ps[x].id   = id;
         ps[x].dir  = 1;
         if(HistoryDealGetInteger(t, DEAL_TYPE) != DEAL_TYPE_BUY) ps[x].dir = -1;
         ps[x].pin  = HistoryDealGetDouble(t, DEAL_PRICE);
         ps[x].isl  = isl;
         ps[x].vin  = vol;
         ps[x].vout = 0.0;
         ps[x].prof = 0.0;
         ps[x].swap = HistoryDealGetDouble(t, DEAL_SWAP);
         ps[x].comm = HistoryDealGetDouble(t, DEAL_COMMISSION);
         ps[x].t0   = (datetime)HistoryDealGetInteger(t, DEAL_TIME);
         ps[x].cl   = 0;
         ps[x].why  = 2;
         ps[x].sday = dday;
         ps[x].pout = 0.0;
        }
      else if(x >= 0)
        {
         ps[x].vout += vol;
         ps[x].pout += HistoryDealGetDouble(t, DEAL_PRICE) * vol;
         ps[x].prof += HistoryDealGetDouble(t, DEAL_PROFIT);
         ps[x].swap += HistoryDealGetDouble(t, DEAL_SWAP);
         ps[x].comm += HistoryDealGetDouble(t, DEAL_COMMISSION);
         if(HistoryDealGetInteger(t, DEAL_REASON) == DEAL_REASON_SL) ps[x].why = 1;
         if(ps[x].cl == 0 && ps[x].vout >= ps[x].vin - 1e-8)
            ps[x].cl = (datetime)HistoryDealGetInteger(t, DEAL_TIME);
        }
     }

   int    n = 0, win = 0, nSL = 0, nEa = 0, noSL = 0;
   double sumR = 0.0, sumQ = 0.0, sumP = 0.0, sumN = 0.0, sumC = 0.0;
   double cum = 0.0, peak = 0.0, dd = 0.0;
   int    pkY = 0, ddA = 0, ddB = 0;
   int    yrY[];
   double yrR[];
   int    yrN[];
   int    ny = 0;
   int    mN[MAXM];
   double mR[MAXM];
   for(int j = 0; j < MAXM; j++) { mN[j] = 0; mR[j] = 0.0; }
   string tl[];                                   // har trade ki line (Journal, sirf Tester ke aakhir mein)
   int    ntl = 0;
   // band hone ki tarteeb se (girawat sahi ho - kai market ki trades aage peeche band hoti hain)
   int ord[];
   int no = 0;
   for(int x = 0; x < np; x++)
     {
      if(ps[x].cl == 0) continue;                 // abhi khuli
      int at = no;
      while(at > 0 && ps[ord[at - 1]].cl > ps[x].cl) at--;
      no++;
      ArrayResize(ord, no);
      for(int j = no - 1; j > at; j--) ord[j] = ord[j - 1];
      ord[at] = x;
     }
   for(int q = 0; q < no; q++)
     {
      int x = ord[q];
      if(MQLInfoInteger(MQL_TESTER) != 0 && ps[x].t0 < InpStatFrom) continue;
      if(ps[x].isl <= 0.0) { noSL++; continue; }  // comment nahi mila - R nahi gin sakte
      ENUM_ORDER_TYPE ot = ORDER_TYPE_BUY;
      if(ps[x].dir == -1) ot = ORDER_TYPE_SELL;
      double risk = 0.0;
      if(!OrderCalcProfit(ot, g_sym[pm[x]], ps[x].vin, ps[x].pin, ps[x].isl, risk)) { noSL++; continue; }
      risk = MathAbs(risk);
      if(risk <= 0.0) { noSL++; continue; }
      double r = (ps[x].prof + ps[x].swap + ps[x].comm) / risk;
      n++;
      mN[pm[x]]++;
      mR[pm[x]] += r;
      if(r > 0.0) { win++; sumP += r; }
      else        sumN += -r;
      sumR += r;
      sumQ += r * r;
      sumC += (ps[x].swap + ps[x].comm) / risk;
      if(ps[x].why == 1) nSL++;
      else               nEa++;
      if(doPrint)
        {
         double pxo = 0.0;
         if(ps[x].vout > 0.0) pxo = ps[x].pout / ps[x].vout;
         int dg = (int)SymbolInfoInteger(g_sym[pm[x]], SYMBOL_DIGITS);
         ntl++;
         ArrayResize(tl, ntl);
         tl[ntl - 1] = StringFormat("TRADE %d | %s | signal %d | khuli %s @ %s | band %s @ %s | %+.2fR | %s",
                                    n, g_sym[pm[x]], ps[x].sday,
                                    TimeToString(ps[x].t0, TIME_DATE | TIME_MINUTES), DoubleToString(ps[x].pin, dg),
                                    TimeToString(ps[x].cl, TIME_DATE | TIME_MINUTES), DoubleToString(pxo, dg),
                                    r, Pick(ps[x].why == 1, "SL", "Supertrend"));
        }
      MqlDateTime st;
      TimeToStruct(ps[x].cl, st);
      cum += r;
      if(cum > peak) { peak = cum; pkY = st.year; }
      if(peak - cum > dd) { dd = peak - cum; ddA = pkY; ddB = st.year; }
      int yi = -1;
      for(int j = 0; j < ny; j++) if(yrY[j] == st.year) { yi = j; break; }
      if(yi < 0)
        {
         ny++;
         ArrayResize(yrY, ny);
         ArrayResize(yrR, ny);
         ArrayResize(yrN, ny);
         yi = ny - 1;
         yrY[yi] = st.year;
         yrR[yi] = 0.0;
         yrN[yi] = 0;
        }
      yrR[yi] += r;
      yrN[yi]++;
     }
   g_totR = sumR;
   double ex  = 0.0;
   double se2 = 0.0;
   if(n > 0) ex = sumR / n;
   if(n > 1) se2 = 2.0 * MathSqrt(MathMax(sumQ - sumR * sumR / n, 0.0) / (n - 1)) / MathSqrt((double)n);
   double pf = 0.0;
   if(sumN > 0.0) pf = sumP / sumN;
   string mt = "";
   for(int j = 0; j < g_n; j++) mt += StringFormat("%s %d %+.2fR  ", g_sym[j], mN[j], mR[j]);
   g_statsTxt = StringFormat("EA ki band trades: %d | jeet %d | Exp %+.3fR (+-%.3f) | kul %+.2fR | swap+comm %+.2fR",
                             n, win, ex, se2, sumR, sumC);
   if(g_n > 1) g_statsTxt += "\n" + mt;
   if(!doPrint) return;

   double winPct = 0.0;
   if(n > 0) winPct = 100.0 * win / n;
   string yt = "";
   int    yPos = 0;
   for(int j = 0; j < ny; j++)
     {
      yt += StringFormat("%d %+.1fR (%d)  ", yrY[j], yrR[j], yrN[j]);
      if(yrR[j] > 0.0) yPos++;
     }
   int j0 = ntl - 20;
   if(j0 < 0) j0 = 0;
   for(int j = j0; j < ntl; j++)
      PrintFormat("JAS TREND %s | %s", EA_BUILD, tl[j]);
   PrintFormat("JAS TREND %s | %s | SAAL: %s| musbat %d/%d", EA_BUILD, g_label, yt, yPos, ny);
   PrintFormat("JAS TREND %s | %s | MARKET: %s", EA_BUILD, g_label, mt);
   PrintFormat("JAS TREND %s | %s | BAND: Supertrend %d | SL %d | bina comment %d", EA_BUILD, g_label, nEa, nSL, noSL);
   PrintFormat("JAS TREND %s | %s | KUL: %d trades | jeet %.1f%% | Exp %+.3fR (+-%.3f = 2SE) | PF %.2f | kul %+.2fR | girawat %.1fR (%d-%d) | swap+commission %+.2fR",
               EA_BUILD, g_label, n, winPct, ex, se2, pf, sumR, dd, ddA, ddB, sumC);
   PrintFormat("JAS TREND %s | %s | hisaab %s se | R = server SL (%.1f x ATR, %s candle)", EA_BUILD, g_label,
               TimeToString(InpStatFrom, TIME_DATE), InpSlMult, Pick(InpTfH >= 24, "D1", "4H"));
  }

//+------------------------------------------------------------------+
//|  PANEL                                                           |
//+------------------------------------------------------------------+
void Panel(bool canTrade)
  {
   string mode = Pick(canTrade, "TRADE CHALU",
                      Pick(InpTrade, "TRADE BAND - Algo Trading hara karein", "SIRF DIKHANA (InpTrade false)"));
   if(MQLInfoInteger(MQL_TESTER) != 0) mode = "TESTER";
   double base = Base();
   string s = "=== JAS TREND  " + EA_BUILD + "  ===  " + mode + "\n";
   s += StringFormat("Candle %s | Risk %.2f%% = %.2f har market | SL %.1f x ATR | lot hadd %.2f | suffix '%s' | %d market | magic %d | GMT %+d\n",
                     Pick(InpTfH >= 24, "D1", "4H"), InpRiskPct, base * InpRiskPct / 100.0, InpSlMult, InpMaxLot, g_suffix, g_n, InpMagic, GmtOff());
   s += g_guardTxt + "\n";
   for(int i = 0; i < g_n; i++)
     {
      Use(i);
      if(!g_have[i])
        {
         s += g_sym[i] + " | broker par NAHI mila - chhor diya\n";
         continue;
        }
      string ln = g_sym[i] + " | ";
      if(g_barT[i] > 0 && g_st[i] > 0.0)
         ln += StringFormat("%s | Supertrend %s (line %s) | ", TimeToString(g_barT[i], TIME_DATE | TIME_MINUTES),
                            Pick(g_up[i], "UPAR", "NEECHE"), Px(g_st[i]));
      s += ln + g_state[i] + "\n";
     }
   s += g_statsTxt + "\n";
   s += "Aakhri kaam: " + g_lastAct;
   Comment(s);
  }

//+------------------------------------------------------------------+
//|  HAR TICK                                                        |
//+------------------------------------------------------------------+
void Pass()
  {
   datetime now = TimeCurrent();
   bool tester = (MQLInfoInteger(MQL_TESTER) != 0);
   bool canTrade = tester || (InpTrade && TerminalInfoInteger(TERMINAL_TRADE_ALLOWED) != 0 &&
                              MQLInfoInteger(MQL_TRADE_ALLOWED) != 0);
   Guard(canTrade);
   datetime ny     = ServerToNy(now);
   datetime nowDay = BarKey(ny);
   MqlDateTime dt;
   TimeToStruct(DayOf(nowDay), dt);
   long into   = (((long)ny + 7 * 3600) % 86400) % BlkSec();   // candle shuru hue kitne sec
   bool preWin = (into >= BlkSec() - (long)InpPreMin * 60 && dt.day_of_week >= 1 && dt.day_of_week <= 5);
   for(int i = 0; i < g_n; i++)
     {
      if(!g_have[i]) continue;
      Use(i);
      if(now - g_failT[i] <= 60) continue;       // order fail / market closed (g_failT aage bhi ho sakta) / faisla na hua
      // nayi session shuru hui: pichhli mukammal candle ka faisla na hua ho (chhutti / EA baad mein laga)
      if(nowDay != g_lastD1[i])
        {
         if(Decide(i, canTrade, false)) g_lastD1[i] = nowDay;
         else if(g_failT[i] < now) g_failT[i] = now;   // data / bazaar band: minute baad dobara (har tick nahi)
        }
      // 17:00 NY se InpPreMin minute pehle: chalti candle par faisla (TV close jaisa, Jumma bhi)
      if(preWin && g_doneT[i] != nowDay) Decide(i, canTrade, true);
     }
   if(tester && MQLInfoInteger(MQL_VISUAL_MODE) == 0) return;

   for(int i = 0; i < g_n; i++)
     {
      if(!g_have[i]) continue;
      Use(i);
      ulong    tk = 0;
      int      dir = 0, pday = 0;
      double   op = 0.0, sl = 0.0;
      datetime t0 = 0;
      if(FindPos(tk, dir, op, sl, pday, t0))
        {
         double rNow = 0.0;
         double risk = MathAbs(op - sl);
         MqlTick t;
         if(SymbolInfoTick(S, t) && risk > 0.0)
           {
            if(dir == 1) rNow = (t.bid - op) / risk;
            else         rNow = (op - t.ask) / risk;
           }
         g_state[i] = StringFormat("%s khuli @ %s | SL %s | abhi %+.2fR | band: Supertrend NEECHE palte",
                                   Pick(dir == 1, "BUY", "SELL"), Px(op), Px(sl), rNow);
        }
      else if(g_st[i] > 0.0)
        {
         if(g_up[i]) g_state[i] = "intezar: nayi BUY sirf jab Supertrend NEECHE se UPAR palte";
         else        g_state[i] = StringFormat("intezar: close line %s ke upar = BUY", Px(g_st[i]));
        }
     }
   if(g_statsDirty || now - g_lastStats > 300)
     {
      g_lastStats = now;
      Stats(false);
     }
   Panel(canTrade);
  }

//+------------------------------------------------------------------+
string DetectSuffix()
  {
   if(InpSuffix != "auto") return(InpSuffix);
   string cs = _Symbol;
   for(int i = 0; i < g_n; i++)
     {
      int len = StringLen(g_base[i]);
      if(StringLen(cs) >= len && StringSubstr(cs, 0, len) == g_base[i])
         return(StringSubstr(cs, len));
     }
   return("");
  }

int OnInit()
  {
   if(InpAtrLen < 2 || InpStMult <= 0.0 || InpSlMult <= 0.0)
     {
      Print("ERROR: qawaid ke number ghalat hain.");
      return(INIT_PARAMETERS_INCORRECT);
     }
   if(InpTfH != 4 && InpTfH != 24)
     {
      Print("ERROR: InpTfH sirf 4 (4H) ya 24 (daily).");
      return(INIT_PARAMETERS_INCORRECT);
     }
   if(InpPreMin < 1 || InpPreMin > 50)
     {
      Print("ERROR: InpPreMin 1 se 50 ke darmiyan hona chahiye.");
      return(INIT_PARAMETERS_INCORRECT);
     }
   if(InpRiskPct <= 0.0 || InpRiskPct > 3.0)
     {
      Print("ERROR: InpRiskPct 0 se 3 ke darmiyan hona chahiye.");
      return(INIT_PARAMETERS_INCORRECT);
     }
   if(InpStartBal < 0.0 || InpTargetPct <= 0.0 || InpDayStopPct <= 0.0 || InpMaxDdPct <= 0.0)
     {
      Print("ERROR: FTMO pehra ke number ghalat hain.");
      return(INIT_PARAMETERS_INCORRECT);
     }
   // markets: InpSymbols (comma se) + suffix; khali = sirf chart ka symbol
   string parts[];
   int cnt = StringSplit(InpSymbols, StringGetCharacter(",", 0), parts);
   g_n = 0;
   for(int k = 0; k < cnt && g_n < MAXM; k++)
     {
      string b = parts[k];
      StringTrimLeft(b);
      StringTrimRight(b);
      if(StringLen(b) == 0) continue;
      g_base[g_n] = b;
      g_n++;
     }
   if(g_n == 0)
     {
      g_n = 1;
      g_base[0] = _Symbol;
      g_suffix  = "";
     }
   else g_suffix = DetectSuffix();
   g_label = "";
   for(int i = 0; i < g_n; i++)
     {
      g_sym[i]     = g_base[i] + g_suffix;
      if(g_n == 1 && StringLen(InpSymbols) == 0) g_sym[i] = _Symbol;
      g_have[i]    = SymbolSelect(g_sym[i], true);
      if(!g_have[i]) PrintFormat("JAS TREND %s | %s broker par nahi mila - chhor diya", EA_BUILD, g_sym[i]);
      g_lastD1[i]  = 0;
      g_doneT[i]   = 0;
      g_failT[i]   = 0;
      g_initBar[i] = true;
      g_state[i]   = "shuru ho raha hai";
      g_c[i]       = 0.0;
      g_st[i]      = 0.0;
      g_atr[i]     = 0.0;
      g_up[i]      = false;
      g_barT[i]    = 0;
      g_label     += Pick(i == 0, "", "+") + g_sym[i];
     }
   // FTMO pehra ki yaad (restart ke baad bhi): account + magic
   g_gv = StringFormat("JASTR_%I64d_%d_", AccountInfoInteger(ACCOUNT_LOGIN), InpMagic);
   g_stop = 0;
   double gs = 0.0;
   if(InpStartBal > 0.0 && GlobalVariableGet(g_gv + "S", gs)) g_stop = (int)gs;
   if(InpStartBal > 0.0)
      PrintFormat("JAS TREND %s | FTMO pehra CHALU: shuru %.0f | target %.1f%% = %.0f | din %.1f%% | kul %.1f%% = %.0f",
                  EA_BUILD, InpStartBal, InpTargetPct, InpStartBal * (1.0 + InpTargetPct / 100.0), InpDayStopPct,
                  InpMaxDdPct, InpStartBal * (1.0 - InpMaxDdPct / 100.0));
   else PrintFormat("JAS TREND %s | FTMO pehra BAND (shuru balance %.0f)", EA_BUILD, InpStartBal);
   if(g_stop > 0) PrintFormat("JAS TREND %s | FTMO pehra pehle se ruka hai (%d). Naye challenge par GlobalVariable %sS mitayein (F3).", EA_BUILD, g_stop, g_gv);
   g_dayId   = 0;
   g_dayStop = false;
   trade.SetExpertMagicNumber(InpMagic);
   trade.SetDeviationInPoints(InpSlippage);
   trade.LogLevel(LOG_LEVEL_ERRORS);
   if(MQLInfoInteger(MQL_TESTER) == 0)
     {
      if(!EventSetTimer(30)) Print("Timer nahi laga - sirf tick par chalega.");
     }
   Comment("=== JAS TREND  " + EA_BUILD + " ===\nshuru ho raha hai - candles parh raha hai...");
   return(INIT_SUCCEEDED);
  }

void OnDeinit(const int reason)
  {
   EventKillTimer();
   Comment("");
  }

void OnTick()  { Pass(); }
void OnTimer() { Pass(); }

void OnTradeTransaction(const MqlTradeTransaction &trans, const MqlTradeRequest &request, const MqlTradeResult &result)
  {
   if(trans.type == TRADE_TRANSACTION_DEAL_ADD) g_statsDirty = true;
  }

//+------------------------------------------------------------------+
//| SIRF TESTER: kul hisaab Journal mein. Wapas: kul R.               |
//+------------------------------------------------------------------+
double OnTester()
  {
   Stats(true);
   PrintFormat("JAS TREND %s | %s", EA_BUILD, g_guardTxt);
   return(g_totR);
  }
//+------------------------------------------------------------------+
