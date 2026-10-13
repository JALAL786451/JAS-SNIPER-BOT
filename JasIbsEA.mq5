//====================================================================
//===  BUILD i1   <<< PANEL PAR YAHI NUMBER AANA CHAHIYE >>>
//====================================================================
//+------------------------------------------------------------------+
//|                                                     JasIbsEA.mq5 |
//|  JAS IBS - Internal Bar Strength (Pagonidis 2013) ka MT5 EA.      |
//|  TradingView indicators/jas_ibs_radar.pine b1/b2 ke wohi qaide.  |
//|  Koshish #15 (13 Oct): sirf S&P, IMTIHAN SAKHT = ASLI PASS        |
//|  (TALAASH 320 trades +0.047; IMTIHAN 2019+ 190 trades +0.082R    |
//|  +-0.053, Exp - 2SE +0.029). Baqi 9 index ki tokri FAIL thi.     |
//|  JasRsi2EA c2 jaisa dhaancha: EK D1 chart, InpSymbols (default   |
//|  US500), suffix chart se khud (m/c). Kisi bhi DAILY chart par     |
//|  lagayein (jaise US500m D1 - RSI2 wale chart se ALAG chart).     |
//|  InpSymbols khali = sirf chart ka symbol.                        |
//|                                                                  |
//|  QAWAID (har nayi daily candle par, pichhli BAND candle se):     |
//|   1) IBS = (close - low) / (high - low)                           |
//|   2) Entry: IBS < 0.2 AUR close > SMA(200) = BUY. Sirf BUY.       |
//|   3) Band: kisi band candle ka IBS > 0.8, ya 5 din (5 band        |
//|      candles) poore - agle din ke shuru mein band.                |
//|   4) SL server par: signal close se 3 x ATR(14) (RMA) = 1R        |
//|   5) Lot = 1% risk (lot hadd 2.00). HAR MARKET par ek position.   |
//|      Sunday ki chhoti candle Monday mein mila di jati hai.        |
//|   6) Bahar wale din nayi nahi: jis candle par band hua (IBS / 5   |
//|      din / SL laga) us candle ke signal par nayi trade nahi.      |
//|   7) EA lagne ke baad pehli candle par nayi trade nahi (der se    |
//|      entry nahi); band ki jaanch hoti hai.                       |
//|                                                                  |
//|  InpTrade false = SIRF DIKHANA. Tester ke aakhir mein Journal    |
//|  mein R ka hisaab (sirf maloomat - Exness ka index data chhota). |
//|                                                                  |
//|  NO grid / NO martingale / NO averaging. Har market ek position. |
//+------------------------------------------------------------------+
#property copyright "JAS-SNIPER-BOT"
#property version   "1.00"

#include <Trade\Trade.mqh>
#define EA_BUILD "i1"          // har nayi file par ye number barhta hai
#define MAXM 10

CTrade trade;

// String chunne ka kaam if se - "cond ? \"\" : \"...\"" MetaEditor mein shak wala hai.
string Pick(bool c, string a, string b) { if(c) return(a); return(b); }

//--------------------------- INPUTS -----------------------------------
input group "=== 0 - Markets ==="
input string InpSymbols    = "US500";  // Markets (comma se). KHALI = sirf chart ka symbol
input string InpSuffix     = "auto";   // Suffix (Exness demo m, cent c) - auto = chart ke symbol se

input group "=== 1 - Qawaid (Pine b2 jaise - mat badlein) ==="
input double InpIbsLo      = 0.2;      // BUY: IBS is se kam
input double InpIbsHi      = 0.8;      // Band: IBS is se zyada
input int    InpMaxDays    = 5;        // Band: zyada se zyada din (band candles)
input int    InpTrendLen   = 200;      // Rukh: SMA
input int    InpAtrLen     = 14;       // ATR length
input double InpSlMult     = 3.0;      // SL (x ATR) - hifazat

input group "=== 2 - Risk ==="
input bool   InpTrade      = false;    // TRADE KARE? false = sirf dikhaye (Tester mein hamesha trade)
input double InpRiskPct    = 1.0;      // Har trade ka risk (% balance)
input double InpMaxRiskPct = 2.0;      // Sab se chhoti lot ka risk is % se zyada = trade nahi
input double InpMaxLot     = 2.00;     // Lot ki hadd (hifazat)

input group "=== 3 - Amal ==="
input int    InpBars       = 1200;     // Kitni daily candles parhni
input int    InpSlippage   = 50;       // Max slippage (points)
input int    InpMagic      = 20261022; // Magic number
input datetime InpStatFrom = D'2019.01.01'; // Tester: hisaab is tareekh se khuli trades ka

//--------------------------- HAAL (har market ka alag) ---------------
int      g_n = 0;
string   g_suffix = "";
string   g_base[MAXM];
string   g_sym[MAXM];
bool     g_have[MAXM];
string   g_label = "";
datetime g_lastD1[MAXM];       // broker ki aakhri band D1 candle (jo dekh li)
datetime g_doneT[MAXM];        // mili hui (Sunday ke baad) aakhri candle jis par faisla ho gaya
datetime g_failT[MAXM];
bool     g_initBar[MAXM];      // EA lagne ke baad pehli candle: sirf band ki jaanch, nayi trade nahi (der se entry nahi)
string   g_state[MAXM];
// panel ke liye aakhri band candle ki values
double   g_c[MAXM], g_ibs[MAXM], g_smaT[MAXM], g_atr[MAXM];
int      g_age[MAXM];          // khuli trade ke kitne din (band candles) guzre
datetime g_barT[MAXM];
string   S = "";               // abhi kis market ka kaam ho raha hai (sab chhote kaam isi par)
int      g_i = 0;              // S ka number (g_sym mein)
string   g_lastAct = "abhi kuch nahi";
double   g_totR    = 0.0;
string   g_statsTxt = "EA ki band trades: 0";
bool     g_statsDirty = true;
datetime g_lastStats = 0;

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
   int      why;     // 1 = SL, 2 = IBS / 5 din / haath
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

// Comment: "IBS <signal din yyyymmdd> <shuru ka SL>"
void ParseCmt(string c, int &day, double &isl)
  {
   day = 0;
   isl = 0.0;
   string p[];
   int n = StringSplit(c, StringGetCharacter(" ", 0), p);
   if(n >= 3 && p[0] == "IBS")
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

// Pine: jis candle par SL laga us candle par nayi nahi. Server ka SL is candle
// ke shuru (since) ke baad laga ho - ya baad mein, jab faisla der se ho - dono
// haalat mein Pine us candle par ya to bahar nikla ya andar tha = nayi nahi.
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

void Note(string s)
  {
   g_lastAct = TimeToString(TimeCurrent(), TIME_DATE | TIME_MINUTES) + " " + S + " " + s;
   if(MQLInfoInteger(MQL_TESTER) == 0)
      Print("JAS IBS " + EA_BUILD + " | " + g_lastAct);
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
   PrintFormat("JAS IBS %s | %s band nahi hui: %d %s", EA_BUILD, S, trade.ResultRetcode(), trade.ResultRetcodeDescription());
   return(false);
  }

//+------------------------------------------------------------------+
//|  DAILY CANDLES - Sunday/Saturday ki chhoti candle agle din mein   |
//|  (Radar EA ka LoadBars). 24/7 symbol (BTC/ETH) par nahi.          |
//+------------------------------------------------------------------+
int LoadBars(datetime &T[], double &H[], double &L[], double &C[])
  {
   MqlRates rt[];
   int got = CopyRates(S, PERIOD_D1, 1, InpBars, rt);   // 1 = chalti candle nahi
   if(got <= 0) return(0);
   ArrayResize(T, got);
   ArrayResize(H, got);
   ArrayResize(L, got);
   ArrayResize(C, got);
   bool nonstop = Is247();
   int  m = 0;
   bool pend = false;
   double pH = 0.0, pL = 0.0;
   for(int k = 0; k < got; k++)
     {
      MqlDateTime st;
      TimeToStruct(rt[k].time, st);
      bool wkend = (!nonstop) && (st.day_of_week == 0 || st.day_of_week == 6);
      if(wkend)
        {
         if(!pend) { pH = rt[k].high; pL = rt[k].low; pend = true; }
         else      { pH = MathMax(pH, rt[k].high); pL = MathMin(pL, rt[k].low); }
         continue;
        }
      T[m] = rt[k].time;
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
   // aakhir mein weekend ki candle ho (Monday abhi band nahi) to chhor di
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

double SmaAt(const double &C[], int k, int len)
  {
   if(k < len - 1) return(0.0);
   double s = 0.0;
   for(int j = k - len + 1; j <= k; j++) s += C[j];
   return(s / len);
  }

// Pine: (close - low) / (high - low); high == low = -1 (na)
double IbsAt(const double &H[], const double &L[], const double &C[], int k)
  {
   if(H[k] <= L[k]) return(-1.0);
   return((C[k] - L[k]) / (H[k] - L[k]));
  }

// Signal candle ke BAAD kitni band candles (k tak) guzrin = Pine ka _age.
// day = comment ka signal din; na mile to position khulne ka waqt (t0):
// woh candles jo t0 ke baad khatam huin.
int AgeBars(const datetime &T[], int k, int day, datetime t0)
  {
   int a = 0;
   for(int j = k; j >= 0; j--)
     {
      bool after = false;
      if(day > 0) after = (YMD(T[j]) > day);
      else        after = (AddSec(T[j], 86400) > t0);
      if(!after) break;
      a++;
     }
   return(a);
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
   string cmt = StringFormat("IBS %d %s", day, Px(slv));
   trade.SetTypeFillingBySymbol(S);
   bool ok = trade.Buy(lots, S, 0.0, slv, 0.0, cmt);
   if(ok && trade.ResultRetcode() == TRADE_RETCODE_DONE)
     {
      g_statsDirty = true;
      Note(StringFormat("KHULI BUY %.2f @ %s | SL %s, risk %.2f%%", lots, Px(trade.ResultPrice()), Px(slv), rp));
      return(true);
     }
   g_failT[g_i] = TimeCurrent();
   PrintFormat("JAS IBS %s | %s BUY nahi khuli: %d %s", EA_BUILD, S, trade.ResultRetcode(), trade.ResultRetcodeDescription());
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
//|  FAISLA - market i ki nayi band daily candle par ek dafa           |
//|  false = abhi nahi ho saka (data / market band / order fail)     |
//+------------------------------------------------------------------+
bool Decide(int i, bool canTrade)
  {
   Use(i);
   datetime T[];
   double   H[], L[], C[];
   int m = LoadBars(T, H, L, C);
   int need = MathMax(InpTrendLen, InpAtrLen + 1) + 5;
   if(m < need)
     {
      g_state[i] = StringFormat("daily candles kam hain (%d, chahiye %d) - History load ho rahi hai", m, need);
      return(false);
     }
   double A[];
   CalcAtr(H, L, C, m, InpAtrLen, A);
   int k = m - 1;
   g_barT[i] = T[k];
   g_c[i]    = C[k];
   g_ibs[i]  = IbsAt(H, L, C, k);
   g_atr[i]  = A[k];
   g_smaT[i] = SmaAt(C, k, InpTrendLen);
   if(T[k] == g_doneT[i]) return(true);             // ye candle pehle dekh li
   if(g_atr[i] <= 0.0 || g_smaT[i] <= 0.0) return(false);
   if(!MarketLive()) return(false);                // market khulne par

   ulong    tk = 0;
   int      dir = 0, pday = 0;
   double   op = 0.0, sl = 0.0;
   datetime t0 = 0;
   bool     has = FindPos(tk, dir, op, sl, pday, t0);
   bool     closedNow = false;
   g_age[i] = 0;
   if(has)
     {
      // Pine: _age += 1, phir IBS > 0.8 ya _age >= 5 = is candle ke close par band
      g_age[i] = AgeBars(T, k, pday, t0);
      bool hiIbs = (g_ibs[i] > InpIbsHi);
      bool old   = (g_age[i] >= InpMaxDays);
      if(hiIbs || old)
        {
         string why = Pick(hiIbs, StringFormat("IBS %.2f > %.2f", g_ibs[i], InpIbsHi),
                           StringFormat("%d din", g_age[i]));
         if(canTrade)
           {
            if(!ClosePos(tk, why)) return(false);
            closedNow = true;                         // Pine: usi din nayi nahi
           }
         else Note("band hona chahiye (" + why + ") - Algo Trading band hai");
         has = HasPos();
        }
     }
   if(g_initBar[i])
     {
      g_initBar[i] = false;
      if(!has) Note(StringFormat("EA laga: %s ki candle par nayi trade nahi (der se entry nahi) - agli band candle se", TimeToString(T[k], TIME_DATE)));
     }
   else if(!has && !closedNow)
     {
      if(g_ibs[i] >= 0.0 && g_ibs[i] < InpIbsLo && g_c[i] > g_smaT[i])
        {
         int day = YMD(T[k]);
         datetime since = T[k];
         if(k > 0) since = AddSec(T[k - 1], 86400);   // Monday: Sunday wala hissa bhi isi candle ka
         if(SlHitSince(since))
            Note(StringFormat("BUY signal %s magar is candle par SL laga tha - Pine jaisa nayi nahi", TimeToString(T[k], TIME_DATE)));
         else if(!SigUsed(day))
            if(!TryOpen(g_c[i], g_atr[i], day, canTrade)) return(false);
        }
     }
   g_doneT[i] = T[k];
   return(true);
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
        }
      else if(x >= 0)
        {
         ps[x].vout += vol;
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
   PrintFormat("JAS IBS %s | %s | SAAL: %s| musbat %d/%d", EA_BUILD, g_label, yt, yPos, ny);
   PrintFormat("JAS IBS %s | %s | MARKET: %s", EA_BUILD, g_label, mt);
   PrintFormat("JAS IBS %s | %s | BAND: IBS/%d din %d | SL %d | bina comment %d",
               EA_BUILD, g_label, InpMaxDays, nEa, nSL, noSL);
   PrintFormat("JAS IBS %s | %s | KUL: %d trades | jeet %.1f%% | Exp %+.3fR (+-%.3f = 2SE) | PF %.2f | kul %+.2fR | girawat %.1fR (%d-%d) | swap+commission %+.2fR",
               EA_BUILD, g_label, n, winPct, ex, se2, pf, sumR, dd, ddA, ddB, sumC);
   PrintFormat("JAS IBS %s | %s | hisaab %s se | Tester = sirf MALOOMAT (faisla TradingView ASLI PASS + demo ka qaida)",
               EA_BUILD, g_label, TimeToString(InpStatFrom, TIME_DATE));
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
   string s = "=== JAS IBS  " + EA_BUILD + "  ===  " + mode + "\n";
   s += StringFormat("Risk %.2f%% = %.2f har market | lot hadd %.2f | suffix '%s' | %d market | magic %d\n",
                     InpRiskPct, base * InpRiskPct / 100.0, InpMaxLot, g_suffix, g_n, InpMagic);
   for(int i = 0; i < g_n; i++)
     {
      Use(i);
      if(!g_have[i])
        {
         s += g_sym[i] + " | broker par NAHI mila - chhor diya\n";
         continue;
        }
      string ln = g_sym[i] + " | ";
      if(g_barT[i] > 0 && g_smaT[i] > 0.0)
         ln += StringFormat("%s | %s | IBS %s | ", TimeToString(g_barT[i], TIME_DATE),
                            Pick(g_c[i] > g_smaT[i], "SMA200 UPAR", "SMA200 NEECHE"),
                            Pick(g_ibs[i] >= 0.0, DoubleToString(g_ibs[i], 2), "-"));
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
   for(int i = 0; i < g_n; i++)
     {
      if(!g_have[i]) continue;
      Use(i);
      datetime t1 = iTime(S, PERIOD_D1, 1);
      if(t1 != 0 && t1 != g_lastD1[i] && now - g_failT[i] > 60)
        {
         if(Decide(i, canTrade)) g_lastD1[i] = t1;
        }
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
         g_state[i] = StringFormat("%s khuli @ %s | SL %s | abhi %+.2fR | din %d/%d | band: daily IBS > %.1f ya %d din",
                                   Pick(dir == 1, "BUY", "SELL"), Px(op), Px(sl), rNow, g_age[i], InpMaxDays, InpIbsHi, InpMaxDays);
        }
      else if(g_smaT[i] > 0.0)
        {
         if(g_c[i] > g_smaT[i]) g_state[i] = StringFormat("intezar: BUY jab daily close par IBS < %.1f", InpIbsLo);
         else                   g_state[i] = "SMA200 ke neeche - koi trade nahi (sirf BUY)";
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
   if(InpIbsLo <= 0.0 || InpIbsHi >= 1.0 || InpIbsLo >= InpIbsHi || InpMaxDays < 1 ||
      InpTrendLen < 10 || InpAtrLen < 2 || InpSlMult <= 0.0)
     {
      Print("ERROR: qawaid ke number ghalat hain.");
      return(INIT_PARAMETERS_INCORRECT);
     }
   if(InpRiskPct <= 0.0 || InpRiskPct > 3.0)
     {
      Print("ERROR: InpRiskPct 0 se 3 ke darmiyan hona chahiye.");
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
      if(!g_have[i]) PrintFormat("JAS IBS %s | %s broker par nahi mila - chhor diya", EA_BUILD, g_sym[i]);
      if(StringFind(g_sym[i], "US500") < 0)
         PrintFormat("DHYAN: IBS sirf S&P (US500) par ASLI PASS hua - %s par sabit NAHI (koshish #14 tokri FAIL).", g_sym[i]);
      g_lastD1[i]  = 0;
      g_doneT[i]   = 0;
      g_failT[i]   = 0;
      g_initBar[i] = true;
      g_state[i]   = "shuru ho raha hai";
      g_c[i]       = 0.0;
      g_ibs[i]     = -1.0;
      g_smaT[i]    = 0.0;
      g_atr[i]     = 0.0;
      g_age[i]     = 0;
      g_barT[i]    = 0;
      g_label     += Pick(i == 0, "", "+") + g_sym[i];
     }
   trade.SetExpertMagicNumber(InpMagic);
   trade.SetDeviationInPoints(InpSlippage);
   trade.LogLevel(LOG_LEVEL_ERRORS);
   if(MQLInfoInteger(MQL_TESTER) == 0)
     {
      if(!EventSetTimer(30)) Print("Timer nahi laga - sirf tick par chalega.");
     }
   Comment("=== JAS IBS  " + EA_BUILD + " ===\nshuru ho raha hai - daily candles parh raha hai...");
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
   return(g_totR);
  }
//+------------------------------------------------------------------+
