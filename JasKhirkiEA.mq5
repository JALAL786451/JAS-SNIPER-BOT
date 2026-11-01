//====================================================================
//===  BUILD k2   <<< PANEL PAR YAHI NUMBER AANA CHAHIYE >>>
//====================================================================
//+------------------------------------------------------------------+
//|                                                  JasKhirkiEA.mq5 |
//|  JAS KHIRKI - US (NYSE) chutti ki khirki, 7 NON-US index par.     |
//|  Koshish #67 (TV: TALAASH 2140 tr, 2019+ 505 tr jeet 64%) +       |
//|  #68 FTMO (Python tools/ftmo68.py): #53 + khirki 0.15% har index  |
//|  = 2019+ 83 pass / 0 fail, median 10.8 mahine (11.7 se).          |
//|                                                                  |
//|  QAWAID (Python ftmo68.khirki_trades jaisa):                     |
//|   H = NYSE chutti (pehle se maloom calendar), P = H se pehle      |
//|   aakhri NYSE din. Index ka LOCAL din E jis ka agla weekday = P   |
//|   (P NYSE din, P ke baad wala weekday = H): us din local cash     |
//|   close ke baad pehli H1 ke waqt BUY (DE/FR/EU50 18:00 Berlin,     |
//|   UK 17:00 London, JP 15:00 Tokyo, AUS 16:00 Sydney, HK 16:00).    |
//|   Band: pehla local din >= H, usi waqt. SL server par 3 x ATR20    |
//|   (local din ki daily candles, pichhla din) = 1R. Sirf BUY.        |
//|   Risk 0.15% InpStartBal ($100k) har index. Har market ek trade.  |
//|  FTMO PEHRA: JasTrendEA t5 / JasIbsEA i6 wala code (poora account,|
//|  ek GlobalVariable JASPH_<login>_).                                |
//|                                                                  |
//|  Kisi bhi chart par (misaal DE30m H1). Exness = suffix 'm'.       |
//|  NO grid / NO martingale / NO hedging / NO averaging.            |
//+------------------------------------------------------------------+
#property copyright "JAS-SNIPER-BOT"
#property version   "1.00"

#include <Trade\Trade.mqh>
#define EA_BUILD "k2"          // har nayi file par ye number barhta hai
#define EA_NAME  "JAS KHIRKI"
// k1 (1 Nov 2026): pehla build - #68 ASLI PASS ki setting default, sirf FTMO demo 474832446 (t5 + i6 ke saath).
#define MAXM 10

CTrade trade;

// String chunne ka kaam if se - "cond ? \"\" : \"...\"" MetaEditor mein shak wala hai.
string Pick(bool c, string a, string b) { if(c) return(a); return(b); }

//--------------------------- INPUTS -----------------------------------
input group "=== 0 - Markets (#67 / #68 - mat badlein) ==="
input string InpSymbols   = "DE30,UK100,FR40,STOXX50,JP225,AUS200,HK50"; // Markets (comma se)
input string InpZones     = "EU,UK,EU,EU,JP,AU,HK";                       // Har market ka waqt: EU (Berlin/Paris), UK, JP, AU (Sydney), HK
input string InpEntryMin  = "1080,1020,1080,1080,900,960,960";             // Local minute (18:00 = 1080): entry + band ka waqt
input string InpSuffix    = "auto";   // Suffix (Exness m) - auto = chart ke symbol se

input group "=== 1 - Qawaid (#67 - mat badlein) ==="
input int    InpAtrLen    = 20;       // ATR length (local din ki candles)
input double InpSlMult    = 3.0;      // SL (x ATR) = 1R
input int    InpLateMin   = 60;       // Entry waqt ke baad kitne minute tak entry (Python: us H1 ki open)

input group "=== 2 - Risk ==="
input bool   InpTrade      = true;    // TRADE KARE? false = sirf dikhaye
input double InpRiskPct    = 0.15;    // Har index trade ka risk (% InpStartBal) - #68: 0.15
input double InpMaxRiskPct = 0.30;    // Sab se chhoti lot ka risk is % se zyada = trade nahi (k2: 0.50 se kam)
input double InpMaxLot     = 20.0;    // Lot ki hadd (hifazat)

input group "=== 3 - FTMO pehra (POORE account par, JasTrendEA t5 jaisa) ==="
input double InpStartBal   = 100000.0; // Challenge ka shuru balance (FTMO 100000) - lot isi par (Python). 0 = pehra band, lot = balance
input double InpTargetPct  = 10.0;     // Target % (Phase 1 = 10, Phase 2 = 5) - SAB band, sab EA ruk jayein
input double InpDayStopPct = 4.0;      // Din ka nuksan % (FTMO 5) - SAB band (sab EA), us din nayi nahi
input double InpMaxDdPct   = 0.0;      // Kul nuksan % par hamesha band - 0 = BAND (user 1 Nov: "1"; FTMO 10)
input string InpGuardMagics = "20261029,20261022,20261101"; // Pehra in magic ki trades band kare (Trend + IBS + Khirki)

input group "=== 4 - Amal ==="
input int    InpSlippage   = 50;       // Max slippage (points)
input int    InpMagic      = 20261101; // Magic number
input int    InpServerGMT  = 0;        // Server GMT farq: Exness = 0 | FTMO = -2 (GMT+2, US DST mein +3, khud)

//--------------------------- HAAL -------------------------------------
int      g_n = 0;
string   g_suffix = "";
string   g_base[MAXM];
string   g_sym[MAXM];
string   g_zone[MAXM];
int      g_emin[MAXM];
bool     g_have[MAXM];
datetime g_failT[MAXM];
int      g_doneH[MAXM];          // k2: is waqia (H) par BUY abhi khuli - dobara nahi
string   g_state[MAXM];
string   S = "";
int      g_i = 0;
string   g_lastAct = "abhi kuch nahi";
bool     g_statsDirty = true;
// FTMO pehra (JasTrendEA t5 / JasIbsEA i6 jaisa)
string   g_pg = "";
long     g_gm[8];
int      g_gmN = 0;
datetime g_pehraT = 0;
int      g_dayId = 0;
double   g_dayBal = 0.0;
bool     g_dayStop = false;
int      g_stop = 0;
string   g_guardTxt = "";
int      g_euY = 0;
datetime g_euA = 0, g_euB = 0;

//+------------------------------------------------------------------+
//|  WAQT                                                            |
//+------------------------------------------------------------------+
datetime AddSec(datetime t, long s) { return((datetime)((long)t + s)); }

int YMD(datetime t)
  {
   MqlDateTime s;
   TimeToStruct(t, s);
   return(s.year * 10000 + s.mon * 100 + s.day);
  }

int Dow(datetime t)
  {
   MqlDateTime s;
   TimeToStruct(t, s);
   return(s.day_of_week);              // 0 = Itwar ... 6 = Hafta
  }

datetime MkDate(int y, int m, int d)
  {
   MqlDateTime s;
   ZeroMemory(s);
   s.year = y;
   s.mon  = m;
   s.day  = d;
   return(StructToTime(s));
  }

datetime LastSunday(int year, int mon)
  {
   int y2 = year, m2 = mon + 1;
   if(mon == 12) { y2 = year + 1; m2 = 1; }
   datetime d = AddSec(MkDate(y2, m2, 1), -86400);   // mahine ka aakhri din
   return(AddSec(d, -(long)Dow(d) * 86400));
  }

datetime FirstSunday(int year, int mon)
  {
   datetime d1 = MkDate(year, mon, 1);
   int add = (7 - Dow(d1)) % 7;
   return(AddSec(d1, (long)add * 86400));
  }

// k2: -2 = FTMO server (New York close: GMT+2, US DST mein GMT+3) - har waqt apna farq
bool UsDstUtc(datetime utc)
  {
   MqlDateTime s;
   TimeToStruct(utc, s);
   datetime a = AddSec(FirstSunday(s.year, 3), (7 + 7 * 24) * 3600);   // March doosra Itwar 07:00 UTC
   datetime b = AddSec(FirstSunday(s.year, 11), 6 * 3600);             // Nov pehla Itwar 06:00 UTC
   return(utc >= a && utc < b);
  }

datetime ServerToUtc(datetime srv)
  {
   if(InpServerGMT == -2)
     {
      datetime u = AddSec(srv, -3 * 3600);
      return(UsDstUtc(u) ? u : AddSec(srv, -2 * 3600));
     }
   return(AddSec(srv, -(long)InpServerGMT * 3600));
  }

// UTC -> market ka local waqt. EU / UK: EU DST (March aakhri Itwar - Oct aakhri Itwar, 01:00 UTC).
// AU (Sydney): DST Oct pehla Itwar 02:00 AEST (= Hafta 16:00 UTC) se April pehla Itwar 03:00 AEDT (= Hafta 16:00 UTC).
datetime LocalTime(datetime utc, string zone)
  {
   MqlDateTime s;
   TimeToStruct(utc, s);
   if(zone == "JP") return(AddSec(utc, 9 * 3600));
   if(zone == "HK") return(AddSec(utc, 8 * 3600));
   if(zone == "EU" || zone == "UK")
     {
      datetime a = AddSec(LastSunday(s.year, 3), 3600);
      datetime b = AddSec(LastSunday(s.year, 10), 3600);
      bool dst = (utc >= a && utc < b);
      long off = 0;
      if(zone == "EU") off = 3600;
      if(dst) off += 3600;
      return(AddSec(utc, off));
     }
   if(zone == "AU")
     {
      datetime st = AddSec(FirstSunday(s.year, 10), -8 * 3600);   // Hafta 16:00 UTC
      datetime en = AddSec(FirstSunday(s.year, 4), -8 * 3600);
      bool dst = (utc >= st || utc < en);
      return(AddSec(utc, (long)(dst ? 11 : 10) * 3600));
     }
   return(utc);
  }

int CetDay(datetime srv)
  {
   datetime utc = ServerToUtc(srv);
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

//+------------------------------------------------------------------+
//|  NYSE CALENDAR (Python tools/ftmo60.py hol() jaisa, 1971+)        |
//+------------------------------------------------------------------+
void Easter(int y, int &mo, int &dd)
  {
   int a = y % 19, b = y / 100, c = y % 100;
   int d = b / 4, e = b % 4;
   int f = (b + 8) / 25;
   int g = (b - f + 1) / 3;
   int h = (19 * a + b - d - g + 15) % 30;
   int i = c / 4, k = c % 4;
   int l = (32 + 2 * e + 2 * i - h - k) % 7;
   int m = (a + 11 * h + 22 * l) / 451;
   int n = h + l - 7 * m + 114;
   mo = n / 31;
   dd = n % 31 + 1;
  }

// dt = din (00:00). NYSE ki pehle se maloom chutti?
bool NyseHol(datetime dt)
  {
   MqlDateTime s;
   TimeToStruct(dt, s);
   int y = s.year, m = s.mon, d = s.day, w = s.day_of_week;   // 0 = Itwar
   bool wk  = (w >= 1 && w <= 5);
   bool mon = (w == 1);
   bool fri = (w == 5);
   bool h = false;
   if(m == 1)       h = (d == 1 && wk) || (d == 2 && mon) || (y >= 1998 && mon && d >= 15 && d <= 21);
   else if(m == 2)  h = mon && d >= 15 && d <= 21;
   else if(m == 5)  h = mon && d >= 25;
   else if(m == 6)  h = y >= 2022 && ((d == 19 && wk) || (d == 18 && fri) || (d == 20 && mon));
   else if(m == 7)  h = (d == 4 && wk) || (d == 3 && fri) || (d == 5 && mon);
   else if(m == 9)  h = mon && d <= 7;
   else if(m == 11) h = (w == 4 && d >= 22 && d <= 28) || ((y == 1972 || y == 1976 || y == 1980) && w == 2 && d >= 2 && d <= 8);
   else if(m == 12) h = (d == 25 && wk) || (d == 24 && fri) || (d == 26 && mon);
   if(!h && fri && (m == 3 || m == 4))
     {
      int em = 0, ed = 0;
      Easter(y, em, ed);
      datetime gf = AddSec(MkDate(y, em, ed), -2 * 86400);
      h = (YMD(gf) == YMD(dt));
     }
   return(h);
  }

datetime NextWeekday(datetime d)
  {
   datetime p = AddSec(d, 86400);
   while(Dow(p) == 0 || Dow(p) == 6) p = AddSec(p, 86400);
   return(p);
  }

// #67 f_win: local din E (00:00) ka agla weekday P NYSE din ho aur P ke baad wala weekday NYSE chutti H = H (yyyymmdd), warna 0
int WinH(datetime e)
  {
   datetime p = NextWeekday(e);
   if(NyseHol(p)) return(0);
   datetime q = NextWeekday(p);
   if(NyseHol(q)) return(YMD(q));
   return(0);
  }

//+------------------------------------------------------------------+
//|  CHHOTE KAAM                                                     |
//+------------------------------------------------------------------+
double MinStop()
  {
   long a = SymbolInfoInteger(S, SYMBOL_TRADE_STOPS_LEVEL);
   long b = SymbolInfoInteger(S, SYMBOL_TRADE_FREEZE_LEVEL);
   return((double)MathMax(a, b) * SymbolInfoDouble(S, SYMBOL_POINT));
  }

double NormPx(double v)
  {
   double ts = SymbolInfoDouble(S, SYMBOL_TRADE_TICK_SIZE);
   if(ts > 0.0) v = MathRound(v / ts) * ts;
   return(NormalizeDouble(v, (int)SymbolInfoInteger(S, SYMBOL_DIGITS)));
  }

string Px(double v) { return(DoubleToString(v, (int)SymbolInfoInteger(S, SYMBOL_DIGITS))); }

// taza tick (2 min ke andar) - market isi waqt chal raha hai
bool MarketLive()
  {
   MqlTick tk;
   if(!SymbolInfoTick(S, tk)) return(false);
   if(tk.bid <= 0.0 || tk.ask <= 0.0) return(false);
   return(TimeCurrent() - tk.time < 120);
  }

double LotFor(double price, double slv, double &riskPct)
  {
   riskPct = 0.0;
   double loss = 0.0;
   if(!OrderCalcProfit(ORDER_TYPE_BUY, S, 1.0, price, slv, loss)) return(-1.0);   // k2: ghalti = dobara koshish
   loss = MathAbs(loss);
   double base = AccountInfoDouble(ACCOUNT_BALANCE);
   if(InpStartBal > 0.0) base = InpStartBal;      // Python jaisa pakka $100k
   if(loss <= 0.0 || base <= 0.0) return(0.0);
   double step = SymbolInfoDouble(S, SYMBOL_VOLUME_STEP);
   double mn   = SymbolInfoDouble(S, SYMBOL_VOLUME_MIN);
   double mx   = SymbolInfoDouble(S, SYMBOL_VOLUME_MAX);
   if(step <= 0.0) step = 0.01;
   double lots = MathFloor(base * InpRiskPct / 100.0 / loss / step + 1e-9) * step;
   if(lots < mn - 1e-12)
     {
      riskPct = mn * loss / base * 100.0;
      if(riskPct > InpMaxRiskPct) return(0.0);
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

// Comment: "KHI <H yyyymmdd> <shuru ka SL>"
int CmtH(string c)
  {
   string p[];
   int n = StringSplit(c, StringGetCharacter(" ", 0), p);
   if(n >= 2 && p[0] == "KHI") return((int)StringToInteger(p[1]));
   return(0);
  }

bool FindPos(ulong &tk, int &hy, datetime &t0)
  {
   for(int k = PositionsTotal() - 1; k >= 0; k--)
     {
      ulong t = PositionGetTicket(k);
      if(t == 0) continue;
      if(PositionGetString(POSITION_SYMBOL) != S) continue;
      if(PositionGetInteger(POSITION_MAGIC) != InpMagic) continue;
      tk = t;
      hy = CmtH(PositionGetString(POSITION_COMMENT));
      t0 = (datetime)PositionGetInteger(POSITION_TIME);
      return(true);
     }
   return(false);
  }

// Is waqia (H) par trade pehle khul chuki? (SL / restart ke baad dobara nahi - Python: ek waqia ek trade)
bool SigUsed(int hy)
  {
   datetime now = TimeCurrent();
   if(!HistorySelect(AddSec(now, -30 * 86400), AddSec(now, 60))) return(false);
   for(int k = HistoryDealsTotal() - 1; k >= 0; k--)
     {
      ulong t = HistoryDealGetTicket(k);
      if(t == 0) continue;
      if(HistoryDealGetInteger(t, DEAL_MAGIC) != InpMagic) continue;
      if(HistoryDealGetString(t, DEAL_SYMBOL) != S) continue;
      if(HistoryDealGetInteger(t, DEAL_ENTRY) != DEAL_ENTRY_IN) continue;
      if(CmtH(HistoryDealGetString(t, DEAL_COMMENT)) == hy) return(true);
     }
   return(false);
  }

void Note(string s)
  {
   g_lastAct = TimeToString(TimeCurrent(), TIME_DATE | TIME_MINUTES) + " " + S + " " + s;
   Print(EA_NAME + " " + EA_BUILD + " | " + g_lastAct);
  }

// ATR (RMA, pehli value SMA) LOCAL din ki daily candles par (H1 se), aaj ka din chhor kar = pichhle mukammal din ka
double DailyAtr(string zone, int todayYmd)
  {
   MqlRates r[];
   if(!SeriesInfoInteger(S, PERIOD_H1, SERIES_SYNCHRONIZED)) return(0.0);   // k2: History poori aaye
   int n = CopyRates(S, PERIOD_H1, 0, 24 * 320, r);
   if(n < 5000) return(0.0);                                                // k2: 960 se 5000 (ATR Python jaisa)
   double H[], L[], C[];
   ArrayResize(H, n);
   ArrayResize(L, n);
   ArrayResize(C, n);
   int m = 0, last = -1;
   for(int k = 0; k < n; k++)
     {
      int d = YMD(LocalTime(ServerToUtc(r[k].time), zone));
      if(d >= todayYmd) break;
      if(d != last)
        {
         H[m] = r[k].high;
         L[m] = r[k].low;
         C[m] = r[k].close;
         m++;
         last = d;
        }
      else
        {
         H[m - 1] = MathMax(H[m - 1], r[k].high);
         L[m - 1] = MathMin(L[m - 1], r[k].low);
         C[m - 1] = r[k].close;
        }
     }
   if(m < InpAtrLen + 5) return(0.0);
   double s = 0.0, a = 0.0;
   for(int k = 1; k < m; k++)                       // pehla din adhoora ho sakta hai - k = 1 se
     {
      double tr = MathMax(H[k] - L[k], MathMax(MathAbs(H[k] - C[k - 1]), MathAbs(L[k] - C[k - 1])));
      if(k <= InpAtrLen)
        {
         s += tr;
         if(k == InpAtrLen) a = s / InpAtrLen;
         continue;
        }
      a = (a * (InpAtrLen - 1) + tr) / InpAtrLen;
     }
   return(a);
  }

//+------------------------------------------------------------------+
//|  HAR MARKET KA KAAM                                              |
//+------------------------------------------------------------------+
void Use(int i) { g_i = i; S = g_sym[i]; }

void Work(int i, bool canTrade)
  {
   Use(i);
   datetime loc  = LocalTime(ServerToUtc(TimeCurrent()), g_zone[i]);
   int      today = YMD(loc);
   int      lmin = (int)(((long)loc % 86400) / 60);
   datetime day0 = AddSec(loc, -((long)loc % 86400));
   ulong    tk = 0;
   int      hy = 0;
   datetime t0 = 0;
   if(FindPos(tk, hy, t0))
     {
      // k2: comment badla / kata ho to H entry ke local din se dobara (WinH)
      datetime le = LocalTime(ServerToUtc(t0), g_zone[i]);
      int      ey = YMD(le);
      if(hy < ey || hy > YMD(AddSec(le, 14 * 86400)))
         hy = WinH(AddSec(le, -((long)le % 86400)));
      // Band: pehla local din >= H, entry wale waqt (Python: wohi H1)
      bool due  = (hy > 0 && today >= hy && lmin >= g_emin[i]);
      bool late = (TimeCurrent() - t0 > 12 * 86400);      // hifazat: 12 din se zyada nahi
      g_state[i] = StringFormat("BUY khuli (waqia %d) - band: local din >= %d, %02d:%02d par", hy, hy, g_emin[i] / 60, g_emin[i] % 60);
      if((due || late) && MarketLive() && TimeCurrent() - g_failT[i] > 60)
        {
         if(!canTrade) { Note("band hona chahiye - Algo Trading band hai"); return; }
         trade.SetTypeFillingBySymbol(S);
         if(trade.PositionClose(tk))
           {
            Note(StringFormat("BAND (%s) @ %s", Pick(due, "khirki poori", "12 din hifazat"), Px(trade.ResultPrice())));
            g_statsDirty = true;
           }
         else
           {
            g_failT[i] = TimeCurrent();
            PrintFormat("%s %s | %s band nahi hui: %d %s", EA_NAME, EA_BUILD, S, trade.ResultRetcode(), trade.ResultRetcodeDescription());
           }
        }
      return;
     }
   int dw = Dow(loc);
   int h  = 0;
   if(dw >= 1 && dw <= 5) h = WinH(day0);
   if(h == 0)
     {
      g_state[i] = "intezar: aaj khirki ka din nahi";
      return;
     }
   g_state[i] = StringFormat("AAJ khirki ka din (chutti %d) - BUY %02d:%02d local par", h, g_emin[i] / 60, g_emin[i] % 60);
   if(lmin < g_emin[i] || lmin >= g_emin[i] + InpLateMin) return;
   if(!MarketLive() || TimeCurrent() - g_failT[i] <= 60) return;
   if(g_stop > 0 || g_dayStop)
     {
      g_state[i] = "khirki ka waqt magar FTMO pehra laga hai - nayi nahi";
      return;
     }
   if(g_doneH[i] == h || SigUsed(h)) return;
   double atr = DailyAtr(g_zone[i], today);
   if(atr <= 0.0)
     {
      g_state[i] = "ATR nahi bana (History kam) - dobara";
      g_failT[i] = TimeCurrent();
      return;
     }
   MqlTick t;
   if(!SymbolInfoTick(S, t)) return;
   double slv = NormPx(t.bid - InpSlMult * atr);
   if(t.bid - slv <= MinStop() + SymbolInfoDouble(S, SYMBOL_POINT))
     {
      Note(StringFormat("BUY CHHOOTI: SL %s bohot qareeb", Px(slv)));
      g_failT[i] = AddSec(TimeCurrent(), 3600);
      return;
     }
   double rp = 0.0;
   double lots = LotFor(t.ask, slv, rp);
   if(lots < 0.0)
     {
      g_state[i] = "lot ka hisaab nahi bana (OrderCalcProfit) - 60 s baad dobara";
      g_failT[i] = TimeCurrent();
      return;
     }
   if(lots <= 0.0)
     {
      Note(StringFormat("BUY CHHOOTI: chhoti lot bhi %.2f%% se zyada risk", InpMaxRiskPct));
      g_failT[i] = AddSec(TimeCurrent(), 3600);
      return;
     }
   if(!canTrade)
     {
      Note(StringFormat("BUY HOTA (sirf dikhana) %.2f @ %s | SL %s, risk %.2f%%", lots, Px(t.ask), Px(slv), rp));
      g_failT[i] = AddSec(TimeCurrent(), 3600);
      return;
     }
   string cmt = StringFormat("KHI %d %s", h, Px(slv));
   trade.SetTypeFillingBySymbol(S);
   if(trade.Buy(lots, S, 0.0, slv, 0.0, cmt) && trade.ResultRetcode() == TRADE_RETCODE_DONE)
     {
      g_doneH[i] = h;
      g_statsDirty = true;
      Note(StringFormat("KHULI BUY %.2f @ %s | SL %s (3 x ATR %s), risk %.2f%% | chutti %d", lots, Px(trade.ResultPrice()), Px(slv), Px(atr), rp, h));
     }
   else
     {
      g_failT[i] = TimeCurrent();
      PrintFormat("%s %s | %s BUY nahi khuli: %d %s", EA_NAME, EA_BUILD, S, trade.ResultRetcode(), trade.ResultRetcodeDescription());
     }
  }

//+------------------------------------------------------------------+
//|  FTMO PEHRA - POORE account par (JasTrendEA t5 + JasIbsEA i6 ek   |
//|  jaisa code, ek hi GlobalVariable "JASPH_<login>_"): target ya    |
//|  din ki hadd = InpGuardMagics wali SAB trades band (dono EA ki),  |
//|  aur dono EA nayi nahi kholte. Kul hadd sirf InpMaxDdPct > 0 par.  |
//+------------------------------------------------------------------+
bool GuardMagic(long mg)
  {
   for(int k = 0; k < g_gmN; k++) if(g_gm[k] == mg) return(true);
   return(false);
  }

void PehraCloseAll(string why, bool canTrade)
  {
   if(!canTrade) return;
   for(int k = PositionsTotal() - 1; k >= 0; k--)
     {
      ulong t = PositionGetTicket(k);
      if(t == 0) continue;
      if(!GuardMagic(PositionGetInteger(POSITION_MAGIC))) continue;
      string sym = PositionGetString(POSITION_SYMBOL);
      trade.SetTypeFillingBySymbol(sym);
      if(trade.PositionClose(t))
         PrintFormat("%s %s | PEHRA (%s): %s band @ %s", EA_NAME, EA_BUILD, why, sym,
                     DoubleToString(trade.ResultPrice(), (int)SymbolInfoInteger(sym, SYMBOL_DIGITS)));
      else
         PrintFormat("%s %s | PEHRA (%s): %s band nahi hui: %d %s", EA_NAME, EA_BUILD, why, sym,
                     trade.ResultRetcode(), trade.ResultRetcodeDescription());
     }
   g_statsDirty = true;
  }

void Guard(bool canTrade)
  {
   if(InpStartBal <= 0.0)
     {
      g_guardTxt = "FTMO pehra: band (shuru balance 0)";
      return;
     }
   double eq  = AccountInfoDouble(ACCOUNT_EQUITY);
   double bal = AccountInfoDouble(ACCOUNT_BALANCE);
   int    day = CetDay(TimeCurrent());
   double gv  = 0.0;
   if(day != g_dayId)
     {
      // naya CET din: aadhi raat ka balance (doosra EA / restart pehle likh chuka ho to wahi)
      double gd = 0.0, gb = 0.0;
      if(GlobalVariableGet(g_pg + "D", gd) && (int)gd == day && GlobalVariableGet(g_pg + "B", gb))
         g_dayBal = gb;
      else
        {
         g_dayBal = bal;
         GlobalVariableSet(g_pg + "D", day);
         GlobalVariableSet(g_pg + "B", bal);
         GlobalVariablesFlush();
        }
      g_dayId = day;
     }
   // doosre EA ne pehra lagaya ho to yahan bhi (din ki hadd aaj ke din tak, stop hamesha)
   g_dayStop = (GlobalVariableGet(g_pg + "X", gv) && (int)gv == g_dayId);
   if(GlobalVariableGet(g_pg + "S", gv) && (int)gv > g_stop) g_stop = (int)gv;
   double dayFloor = g_dayBal - InpDayStopPct / 100.0 * InpStartBal;
   double target   = InpStartBal * (1.0 + InpTargetPct / 100.0);
   double ddFloor  = 0.0;
   if(InpMaxDdPct > 0.0) ddFloor = InpStartBal * (1.0 - InpMaxDdPct / 100.0);
   if(g_stop == 0 && eq >= target)
     {
      g_stop = 1;
      GlobalVariableSet(g_pg + "S", 1);
      GlobalVariablesFlush();
      PrintFormat("%s %s | TARGET POORA: equity %.2f >= %.2f - SAB band, dono EA ruk gaye", EA_NAME, EA_BUILD, eq, target);
     }
   if(g_stop == 0 && InpMaxDdPct > 0.0 && eq <= ddFloor)
     {
      g_stop = 2;
      GlobalVariableSet(g_pg + "S", 2);
      GlobalVariablesFlush();
      PrintFormat("%s %s | KUL HADD: equity %.2f <= %.2f - SAB band, dono EA ruk gaye", EA_NAME, EA_BUILD, eq, ddFloor);
     }
   if(!g_dayStop && g_stop == 0 && eq <= dayFloor)
     {
      g_dayStop = true;
      GlobalVariableSet(g_pg + "X", g_dayId);
      GlobalVariablesFlush();
      PrintFormat("%s %s | DIN KI HADD: equity %.2f <= %.2f - SAB band, aaj (CET %d) nayi nahi", EA_NAME, EA_BUILD, eq, dayFloor, g_dayId);
     }
   if((g_stop > 0 || g_dayStop) && TimeCurrent() - g_pehraT >= 30)
     {
      g_pehraT = TimeCurrent();
      PehraCloseAll(Pick(g_stop == 1, "target", Pick(g_stop == 2, "kul hadd", "din ki hadd")), canTrade);
     }
   string st = "chalu";
   if(g_stop == 1)  st = "TARGET POORA - dono EA ruke (FTMO ke 4 din khud check karein)";
   if(g_stop == 2)  st = "KUL HADD - dono EA ruke";
   if(g_stop == 0 && g_dayStop) st = "DIN KI HADD - aaj nayi nahi (dono EA)";
   string kul = "kul hadd band";
   if(InpMaxDdPct > 0.0) kul = StringFormat("kul farsh %.0f", ddFloor);
   g_guardTxt = StringFormat("FTMO pehra (poora account): %s | target %.0f | din ka farsh %.0f (CET %d ka balance %.0f) | %s",
                             st, target, dayFloor, g_dayId, g_dayBal, kul);
  }

// OnInit: pehra ki magic list + GlobalVariable ka naam + pichhla stop
void PehraInit()
  {
   string mp[];
   int mc = StringSplit(InpGuardMagics, StringGetCharacter(",", 0), mp);
   g_gmN = 0;
   for(int k = 0; k < mc && g_gmN < 8; k++)
     {
      string b = mp[k];
      StringTrimLeft(b);
      StringTrimRight(b);
      if(StringLen(b) == 0) continue;
      g_gm[g_gmN] = StringToInteger(b);
      g_gmN++;
     }
   if(!GuardMagic(InpMagic) && g_gmN < 8) { g_gm[g_gmN] = InpMagic; g_gmN++; }
   g_pg = StringFormat("JASPH_%I64d_", AccountInfoInteger(ACCOUNT_LOGIN));
   g_stop = 0;
   double gs = 0.0;
   if(InpStartBal > 0.0 && GlobalVariableGet(g_pg + "S", gs)) g_stop = (int)gs;
   g_dayId   = 0;
   g_dayStop = false;
   g_pehraT  = 0;
   if(InpStartBal > 0.0)
      PrintFormat("%s %s | FTMO pehra CHALU (poora account, magic %s): shuru %.0f | target %.1f%% = %.0f | din %.1f%% | kul %s",
                  EA_NAME, EA_BUILD, InpGuardMagics, InpStartBal, InpTargetPct, InpStartBal * (1.0 + InpTargetPct / 100.0), InpDayStopPct,
                  Pick(InpMaxDdPct > 0.0, StringFormat("%.1f%% = %.0f", InpMaxDdPct, InpStartBal * (1.0 - InpMaxDdPct / 100.0)), "band"));
   else PrintFormat("%s %s | FTMO pehra BAND (shuru balance %.0f)", EA_NAME, EA_BUILD, InpStartBal);
   if(g_stop > 0) PrintFormat("%s %s | FTMO pehra pehle se ruka hai (%d). Naye challenge / naye account par GlobalVariable %sS mitayein (F3).",
                              EA_NAME, EA_BUILD, g_stop, g_pg);
  }

//+------------------------------------------------------------------+
//|  PANEL + HAR TICK                                                |
//+------------------------------------------------------------------+
void Panel(bool canTrade)
  {
   string mode = Pick(canTrade, "TRADE CHALU",
                      Pick(InpTrade, "TRADE BAND - Algo Trading hara karein", "SIRF DIKHANA (InpTrade false)"));
   double base = AccountInfoDouble(ACCOUNT_BALANCE);
   if(InpStartBal > 0.0) base = InpStartBal;
   string s = "=== JAS KHIRKI  " + EA_BUILD + "  ===  " + mode + "\n";
   s += StringFormat("Risk %.2f%% = %.2f har index | lot hadd %.2f | suffix '%s' | %d market | magic %d | GMT %s\n",
                     InpRiskPct, base * InpRiskPct / 100.0, InpMaxLot, g_suffix, g_n, InpMagic, Pick(InpServerGMT == -2, "FTMO +2/+3", IntegerToString(InpServerGMT)));
   s += g_guardTxt + "\n";
   for(int i = 0; i < g_n; i++)
     {
      if(!g_have[i]) { s += g_sym[i] + " | broker par NAHI mila - chhor diya\n"; continue; }
      datetime loc = LocalTime(ServerToUtc(TimeCurrent()), g_zone[i]);
      s += StringFormat("%s | %s %s | ", g_sym[i], g_zone[i], TimeToString(loc, TIME_DATE | TIME_MINUTES)) + g_state[i] + "\n";
     }
   s += "Aakhri kaam: " + g_lastAct;
   Comment(s);
  }

void Pass()
  {
   bool canTrade = (InpTrade && TerminalInfoInteger(TERMINAL_TRADE_ALLOWED) != 0 && MQLInfoInteger(MQL_TRADE_ALLOWED) != 0);
   if(MQLInfoInteger(MQL_TESTER) != 0) canTrade = true;
   Guard(canTrade);
   for(int i = 0; i < g_n; i++)
     {
      if(!g_have[i]) continue;
      Work(i, canTrade);
     }
   Panel(canTrade);
  }

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
   // chart kisi aur market ka (misaal US500m): uska 'm' wala hissa
   string known[] = {"US500", "USTEC", "XAUUSD", "US30"};
   for(int k = 0; k < ArraySize(known); k++)
     {
      int len = StringLen(known[k]);
      if(StringLen(cs) >= len && StringSubstr(cs, 0, len) == known[k]) return(StringSubstr(cs, len));
     }
   return("");
  }

int OnInit()
  {
   if(InpAtrLen < 2 || InpSlMult <= 0.0 || InpLateMin < 1 || InpRiskPct <= 0.0 || InpRiskPct > 1.0)
     {
      Print("ERROR: qawaid / risk ke number ghalat hain.");
      return(INIT_PARAMETERS_INCORRECT);
     }
   if(InpStartBal < 0.0 || InpTargetPct <= 0.0 || InpDayStopPct <= 0.0 || InpMaxDdPct < 0.0)
     {
      Print("ERROR: FTMO pehra ke number ghalat hain.");
      return(INIT_PARAMETERS_INCORRECT);
     }
   string ps[], pz[], pm[];
   int ns = StringSplit(InpSymbols, StringGetCharacter(",", 0), ps);
   int nz = StringSplit(InpZones, StringGetCharacter(",", 0), pz);
   int nm = StringSplit(InpEntryMin, StringGetCharacter(",", 0), pm);
   if(ns != nz || ns != nm || ns < 1 || ns > MAXM)
     {
      Print("ERROR: InpSymbols, InpZones, InpEntryMin ki ginti barabar honi chahiye (1-10).");
      return(INIT_PARAMETERS_INCORRECT);
     }
   g_n = 0;
   for(int k = 0; k < ns; k++)
     {
      string b = ps[k], z = pz[k], e = pm[k];
      StringTrimLeft(b); StringTrimRight(b);
      StringTrimLeft(z); StringTrimRight(z);
      StringTrimLeft(e); StringTrimRight(e);
      if(z != "EU" && z != "UK" && z != "JP" && z != "AU" && z != "HK")
        {
         Print("ERROR: InpZones mein sirf EU, UK, JP, AU, HK.");
         return(INIT_PARAMETERS_INCORRECT);
        }
      g_base[g_n] = b;
      g_zone[g_n] = z;
      g_emin[g_n] = (int)StringToInteger(e);
      g_n++;
     }
   g_suffix = DetectSuffix();
   for(int i = 0; i < g_n; i++)
     {
      g_sym[i]   = g_base[i] + g_suffix;
      g_have[i]  = SymbolSelect(g_sym[i], true);
      g_failT[i] = 0;
      g_doneH[i] = 0;
      g_state[i] = "shuru ho raha hai";
      if(!g_have[i]) PrintFormat("%s %s | %s broker par nahi mila - chhor diya", EA_NAME, EA_BUILD, g_sym[i]);
     }
   PehraInit();
   trade.SetExpertMagicNumber(InpMagic);
   trade.SetDeviationInPoints(InpSlippage);
   trade.LogLevel(LOG_LEVEL_ERRORS);
   if(MQLInfoInteger(MQL_TESTER) == 0)
      if(!EventSetTimer(30)) Print("Timer nahi laga - sirf tick par chalega.");
   Comment("=== JAS KHIRKI  " + EA_BUILD + " ===\nshuru ho raha hai...");
   return(INIT_SUCCEEDED);
  }

void OnDeinit(const int reason)
  {
   EventKillTimer();
   Comment("");
  }

void OnTick()  { Pass(); }
void OnTimer() { Pass(); }
//+------------------------------------------------------------------+
