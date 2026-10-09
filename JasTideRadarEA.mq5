//====================================================================
//===  BUILD e1   <<< PANEL PAR YAHI NUMBER AANA CHAHIYE >>>
//====================================================================
//+------------------------------------------------------------------+
//|                                              JasTideRadarEA.mq5  |
//|  JAS Tide Radar r3 ka MT5 EA - 9 market, ek chart se.            |
//|                                                                  |
//|  Radar (indicators/jas_tide_radar.pine, OANDA data) ne 9 Oct     |
//|  2026 ko pehle se likha qaida paas kiya: 2005 se girawat 14.9R,  |
//|  21 mein se 19 saal musbat, 2019 se ~+6.7R saal (488 trades).    |
//|  Ye EA wahi qaide broker (Exness) ke apne data par chalata hai:  |
//|  pehle Strategy Tester, phir DEMO. LIVE par nahi jab tak demo    |
//|  saaf na ho.                                                     |
//|                                                                  |
//|  QAWAID (radar r3 jaise; 2R par aadhi NAHI):                     |
//|   1) Rukh: D1 EMA50 > EMA200 = sirf BUY, neeche = sirf SELL      |
//|      (signal candle se pichhli candle ki EMA - radar jaisa)      |
//|   2) ATR(14) qeemat ka kam az kam 0.25%                          |
//|   3) Band candle ka close pichhli 10 candle ke sab se oonche     |
//|      high ke upar (SELL: sab se neeche low ke neeche).           |
//|      SL = us close se 2 ATR                                      |
//|   4) Har band candle par SL sirf aage: pichhli 5 candle ka low   |
//|      (SELL: high). Close SL ke paar, ya rukh palta = band        |
//|   5) Ek USD taraf ki zyada se zyada 3 trades. Gold + silver ek   |
//|      taraf mein ek hi (pehle gold)                               |
//|   6) Har trade 1% risk; lot broker ke apne hisaab se             |
//|                                                                  |
//|  Har nayi daily candle par us market ki candles shuru se dobara  |
//|  chalti hain - restart ke baad yaad khud wapas aati hai. Weekend |
//|  ki chhoti candle (Exness GMT+0 par Sunday) agle din mein mila   |
//|  di jati hai (BTC par nahi). Engine ki Python jaanch:            |
//|  tools/tide_ea_check.py. Sirf apni (magic) positions chhoota hai.|
//|                                                                  |
//|  NO grid / NO martingale / NO averaging. Har market par ek trade.|
//+------------------------------------------------------------------+
#property copyright "JAS-SNIPER-BOT"
#property version   "1.00"
#property strict

#include <Trade\Trade.mqh>
#define EA_BUILD "e1"          // har nayi file par ye number barhta hai
#define MAXM     12            // zyada se zyada markets

CTrade trade;

// String chunne ka kaam if se - "cond ? \"\" : \"...\"" MetaEditor mein shak wala hai.
string Pick(bool c, string a, string b) { if(c) return(a); return(b); }

//--------------------------- INPUTS -----------------------------------
input group "=== 1 - Markets ==="
input string InpSymbols    = "XAUUSD,XAGUSD,EURUSD,GBPUSD,AUDUSD,USDJPY,USDCHF,US500,BTCUSD"; // Markets (comma se, pehla = gold)
input string InpSuffix     = "auto";   // Suffix (Exness demo m, cent c) - auto = chart ke symbol se

input group "=== 2 - Qawaid (radar r3 jaise - mat badlein) ==="
input int    InpEntryLen   = 10;       // Naali: kitni candle ka high/low
input int    InpExitLen    = 5;        // SL sarakna: kitni candle
input int    InpAtrLen     = 14;       // ATR length
input double InpAtrMult    = 2.0;      // Shuru ka SL (x ATR)
input int    InpEmaFast    = 50;       // Rukh EMA fast
input int    InpEmaSlow    = 200;      // Rukh EMA slow
input double InpMinAtrPct  = 0.25;     // Kam az kam ATR (% qeemat ka)

input group "=== 3 - Hadd ==="
input int    InpUsdCap     = 3;        // Ek USD taraf ki zyada se zyada trades
input bool   InpMetalOne   = true;     // Gold + silver = ek trade (ek taraf mein)

input group "=== 4 - Risk ==="
input bool   InpTrade      = false;    // TRADE KARE? false = sirf dikhaye (pehli dafa)
input double InpRiskPct    = 1.0;      // Har trade ka risk (% balance)
input double InpBaseMoney  = 0.0;      // Risk kis raqam ka (0 = balance)
input double InpMaxRiskPct = 2.0;      // Sab se chhoti lot ka risk is % se zyada = trade nahi
input double InpMaxLot     = 1.00;     // Lot ki hadd (hifazat)
input double InpMaxSpreadR = 0.10;     // Spread 1R ke is hisse se zyada = intezar

input group "=== 5 - Amal ==="
input int    InpBars       = 1200;     // Har market ki kitni daily candles parhni
input int    InpWarm       = 260;      // Shuru ki candles sirf garam karne ke liye
input int    InpSlippage   = 50;       // Max slippage (points)
input int    InpMagic      = 20261009; // Magic number
input datetime InpStatFrom = D'2019.01.01'; // Tester: hisaab is tareekh se band trades ka (pehle ke saal garam karne ke liye)

//--------------------------- GLOBAL STATE ------------------------------
int      g_n = 0;
string   g_suffix = "";
string   g_base[MAXM];        // naam bina suffix
string   g_sym[MAXM];         // broker ka naam
bool     g_have[MAXM];        // broker par mila?
int      g_usd[MAXM];         // +1: BUY = USD neeche, -1: BUY = USD upar, 0: USD pair nahi
bool     g_metal[MAXM];
bool     g_crypto[MAXM];
datetime g_lastBar[MAXM];     // aakhri band candle jis par engine chala
bool     g_ready[MAXM];       // engine ka nateeja hai?
// engine ka nateeja (aakhri band candle tak) = radar ki trade
int      g_d[MAXM];           // 1 BUY, -1 SELL, 0 koi nahi
double   g_sl[MAXM];          // radar ka SL
int      g_sig[MAXM];         // trade ki signal candle (yyyymmdd)
int      g_age[MAXM];         // kitni band candles se
bool     g_newEnt[MAXM];      // aakhri band candle par nayi trade
string   g_ev[MAXM];          // aakhri band candle par kya hua
int      g_rk[MAXM];          // rukh (aakhri band candle ki EMA)
double   g_lvl[MAXM];         // agla toot
double   g_dist[MAXM];        // toot kitne ATR door (-1 = susat bazaar)
int      g_doneSig[MAXM];     // is signal par faisla ho chuka
string   g_note[MAXM];        // panel ke liye
datetime g_failT[MAXM];       // aakhri order fail ka waqt

int      g_skipCap   = 0;
int      g_skipMetal = 0;
int      g_skipLot   = 0;
string   g_lastAct   = "abhi kuch nahi";
datetime g_lastPass  = 0;
datetime g_t0        = 0;
bool     g_statsDirty = true;
string   g_statsTxt  = "";
double   g_totR      = 0.0;

struct TPos
  {
   long     id;
   int      mk;
   int      dir;
   double   pin;
   double   isl;
   double   vin;
   double   vout;
   double   pxv;
   double   prof;
   double   swap;
   double   comm;
   datetime cl;
  };

//+------------------------------------------------------------------+
//|  CHHOTE KAAM                                                     |
//+------------------------------------------------------------------+
int YMD(datetime t)
  {
   MqlDateTime st;
   TimeToStruct(t, st);
   return(st.year * 10000 + st.mon * 100 + st.day);
  }

// XXXUSD par BUY = USD neeche (+1), USDXXX par BUY = USD upar (-1),
// index / crypto = 0 (radar ka f_usd)
int UsdSide(string b)
  {
   if(StringFind(b, "SPX") >= 0 || StringFind(b, "NAS") >= 0 || StringFind(b, "US30") >= 0 ||
      StringFind(b, "US500") >= 0 || StringFind(b, "USTEC") >= 0 ||
      StringFind(b, "BTC") >= 0 || StringFind(b, "ETH") >= 0)
      return(0);
   if(StringFind(b, "USD") == 0) return(-1);
   int len = StringLen(b);
   if(len >= 3 && StringSubstr(b, len - 3) == "USD") return(1);
   return(0);
  }

bool IsMetal(string b)
  {
   return(StringFind(b, "XAU") >= 0 || StringFind(b, "XAG") >= 0 ||
          StringFind(b, "GOLD") >= 0 || StringFind(b, "SILVER") >= 0);
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
   return("");
  }

double Base()
  {
   if(InpBaseMoney > 0.0) return(InpBaseMoney);
   return(AccountInfoDouble(ACCOUNT_BALANCE));
  }

double MinStop(string sym)
  {
   long a = SymbolInfoInteger(sym, SYMBOL_TRADE_STOPS_LEVEL);
   long b = SymbolInfoInteger(sym, SYMBOL_TRADE_FREEZE_LEVEL);
   long lvl = MathMax(a, b);
   return((double)lvl * SymbolInfoDouble(sym, SYMBOL_POINT));
  }

// Qeemat broker ke tick par gol (warna "invalid stops")
double NormPx(string sym, double v)
  {
   double ts = SymbolInfoDouble(sym, SYMBOL_TRADE_TICK_SIZE);
   if(ts > 0.0) v = MathRound(v / ts) * ts;
   return(NormalizeDouble(v, (int)SymbolInfoInteger(sym, SYMBOL_DIGITS)));
  }

// Market abhi chal raha hai? (taza tick, qeemat maujood)
bool MarketLive(string sym)
  {
   MqlTick tk;
   if(!SymbolInfoTick(sym, tk)) return(false);
   if(tk.bid <= 0.0 || tk.ask <= 0.0) return(false);
   return(TimeCurrent() - tk.time < 600);
  }

// Position ka comment: "TD <signal yyyymmdd> <shuru ka SL>"
void ParseCmt(string c, int &sig, double &isl)
  {
   sig = 0;
   isl = 0.0;
   string p[];
   ushort sp = StringGetCharacter(" ", 0);
   int cnt = StringSplit(c, sp, p);
   if(cnt >= 3 && p[0] == "TD")
     {
      sig = (int)StringToInteger(p[1]);
      isl = StringToDouble(p[2]);
     }
  }

double MaxOf(const double &a[], int from, int to)
  {
   double v = a[from];
   for(int k = from + 1; k <= to; k++) if(a[k] > v) v = a[k];
   return(v);
  }

double MinOf(const double &a[], int from, int to)
  {
   double v = a[from];
   for(int k = from + 1; k <= to; k++) if(a[k] < v) v = a[k];
   return(v);
  }

// ATR = TradingView ta.atr (RMA, shuru mein seedha ausat)
void CalcAtr(const double &H[], const double &L[], const double &C[], int m, int len, double &A[])
  {
   ArrayResize(A, m);
   double sum = 0.0;
   for(int k = 0; k < m; k++)
     {
      double tr = H[k] - L[k];
      if(k > 0) tr = MathMax(tr, MathMax(MathAbs(H[k] - C[k - 1]), MathAbs(L[k] - C[k - 1])));
      if(k < len)
        {
         sum += tr;
         A[k] = 0.0;
         if(k == len - 1) A[k] = sum / len;
        }
      else
         A[k] = (A[k - 1] * (len - 1) + tr) / len;
     }
  }

// EMA, shuru ki candles par seedha ausat (hazar candle baad farq sifar)
void CalcEma(const double &C[], int m, int len, double &E[])
  {
   ArrayResize(E, m);
   double a = 2.0 / (len + 1.0);
   double sum = 0.0;
   for(int k = 0; k < m; k++)
     {
      if(k < len)
        {
         sum += C[k];
         E[k] = sum / (k + 1);
        }
      else
         E[k] = a * C[k] + (1.0 - a) * E[k - 1];
     }
  }

//+------------------------------------------------------------------+
//|  DAILY CANDLES: sirf BAND, weekend ki chhoti candle agle din mein |
//+------------------------------------------------------------------+
int LoadBars(int i, datetime &T[], double &O[], double &H[], double &L[], double &C[])
  {
   MqlRates rt[];
   int got = CopyRates(g_sym[i], PERIOD_D1, 1, InpBars, rt);   // 1 = chalti candle nahi
   if(got <= 0) return(0);
   ArrayResize(T, got);
   ArrayResize(O, got);
   ArrayResize(H, got);
   ArrayResize(L, got);
   ArrayResize(C, got);
   int m = 0;
   bool pend = false;
   double pO = 0.0, pH = 0.0, pL = 0.0;
   for(int k = 0; k < got; k++)
     {
      MqlDateTime st;
      TimeToStruct(rt[k].time, st);
      bool wkend = (!g_crypto[i]) && (st.day_of_week == 0 || st.day_of_week == 6);
      if(wkend)
        {
         if(!pend) { pO = rt[k].open; pH = rt[k].high; pL = rt[k].low; pend = true; }
         else      { pH = MathMax(pH, rt[k].high); pL = MathMin(pL, rt[k].low); }
         continue;
        }
      T[m] = rt[k].time;
      O[m] = rt[k].open;
      H[m] = rt[k].high;
      L[m] = rt[k].low;
      C[m] = rt[k].close;
      if(pend)
        {
         O[m] = pO;
         H[m] = MathMax(pH, H[m]);
         L[m] = MathMin(pL, L[m]);
         pend = false;
        }
      m++;
     }
   // aakhir mein weekend ki candle ho (Monday abhi band nahi) to chhor di
   ArrayResize(T, m);
   ArrayResize(O, m);
   ArrayResize(H, m);
   ArrayResize(L, m);
   ArrayResize(C, m);
   return(m);
  }

//+------------------------------------------------------------------+
//|  ENGINE - radar ka f_tide() line ba line.                         |
//|  Signal candle s: naali s-10..s-1, sarakta SL s-5..s-1, EMA s-1.  |
//+------------------------------------------------------------------+
bool RunEngine(int i)
  {
   datetime T[];
   double O[], H[], L[], C[];
   int m = LoadBars(i, T, O, H, L, C);
   int need = InpEmaSlow + InpEntryLen + 5;
   if(InpWarm > need) need = InpWarm;
   if(m < need + 5) return(false);

   double A[], EF[], ES[];
   CalcAtr(H, L, C, m, InpAtrLen, A);
   CalcEma(C, m, InpEmaFast, EF);
   CalcEma(C, m, InpEmaSlow, ES);
   int dg = (int)SymbolInfoInteger(g_sym[i], SYMBOL_DIGITS);

   int    d = 0, age = 0, sig = 0;
   double e = 0.0, r = 0.0, sl = 0.0;
   bool   newEnt = false;
   string ev = "";
   for(int s = need; s < m; s++)
     {
      double o  = O[s];
      double h  = H[s];
      double l  = L[s];
      double c  = C[s];
      double a  = A[s];
      double hb = MaxOf(H, s - InpEntryLen, s - 1);
      double lb = MinOf(L, s - InpEntryLen, s - 1);
      double hx = MaxOf(H, s - InpExitLen, s - 1);
      double lx = MinOf(L, s - InpExitLen, s - 1);
      double ef = EF[s - 1];
      double es = ES[s - 1];
      bool   cl = false, atC = false;
      double px = 0.0;
      string why = "";
      newEnt = false;
      ev = "";
      if(d != 0)
        {
         age++;
         // candle ke andar SL (gap ho to open par)
         if(d == 1 && l <= sl)       { px = MathMin(o, sl); cl = true; why = "SL"; }
         else if(d == -1 && h >= sl) { px = MathMax(o, sl); cl = true; why = "SL"; }
         // close par: D1 rukh palta
         if(!cl && ((d == 1 && ef < es) || (d == -1 && ef > es)))
           { px = c; cl = true; atC = true; why = "rukh palta"; }
         // close par: SL aage, close peeche ho to band
         if(!cl)
           {
            if(d == 1) sl = MathMax(sl, lx);
            else       sl = MathMin(sl, hx);
            if((d == 1 && c <= sl) || (d == -1 && c >= sl))
              { px = c; cl = true; atC = true; why = "close SL ke paar"; }
           }
        }
      if(cl)
        {
         ev = StringFormat("%s band (%s) %+.2fR", Pick(d == 1, "BUY", "SELL"), why, d * (px - e) / r);
         d = 0;
        }
      if(d == 0 && !atC && a > 0.0 && c > 0.0)
        {
         bool live = (a / c * 100.0 >= InpMinAtrPct);
         bool buy  = live && c > hb && ef > es;
         bool sell = live && c < lb && ef < es;
         if(buy || sell)
           {
            d   = 1;
            if(!buy) d = -1;
            e   = c;
            r   = InpAtrMult * a;
            sl  = c - d * r;
            age = 0;
            sig = YMD(T[s]);
            newEnt = true;
            if(ev != "") ev += " ; ";
            ev += StringFormat("nayi %s, SL %s", Pick(d == 1, "BUY", "SELL"), DoubleToString(sl, dg));
           }
        }
     }

   // aaj ke liye: rukh, agla toot aur faasla (radar jaisa)
   int last = m - 1;
   int rk = 0;
   if(EF[last] > ES[last]) rk = 1;
   if(EF[last] < ES[last]) rk = -1;
   double aT = A[last];
   bool   liveT = (aT > 0.0 && C[last] > 0.0 && aT / C[last] * 100.0 >= InpMinAtrPct);
   double lvl = 0.0;
   if(rk == 1)  lvl = MaxOf(H, last - InpEntryLen + 1, last);
   if(rk == -1) lvl = MinOf(L, last - InpEntryLen + 1, last);
   double nowPx = SymbolInfoDouble(g_sym[i], SYMBOL_BID);
   if(nowPx <= 0.0) nowPx = C[last];

   g_d[i]      = d;
   g_sl[i]     = sl;
   g_sig[i]    = sig;
   g_age[i]    = age;
   g_newEnt[i] = newEnt;
   g_ev[i]     = ev;
   g_rk[i]     = rk;
   g_lvl[i]    = lvl;
   g_dist[i]   = -1.0;
   if(liveT) g_dist[i] = MathAbs(lvl - nowPx) / aT;
   g_note[i]   = "";
   g_ready[i]  = true;
   return(true);
  }

//+------------------------------------------------------------------+
//|  POSITIONS                                                       |
//+------------------------------------------------------------------+
bool FindPos(int i, ulong &tk, int &dir, double &vol, double &op, double &sl, int &sig, double &isl)
  {
   for(int k = PositionsTotal() - 1; k >= 0; k--)
     {
      ulong t = PositionGetTicket(k);
      if(t == 0 || !PositionSelectByTicket(t)) continue;
      if(PositionGetString(POSITION_SYMBOL) != g_sym[i]) continue;
      if(PositionGetInteger(POSITION_MAGIC) != InpMagic) continue;
      tk  = t;
      dir = 1;
      if(PositionGetInteger(POSITION_TYPE) != POSITION_TYPE_BUY) dir = -1;
      vol = PositionGetDouble(POSITION_VOLUME);
      op  = PositionGetDouble(POSITION_PRICE_OPEN);
      sl  = PositionGetDouble(POSITION_SL);
      ParseCmt(PositionGetString(POSITION_COMMENT), sig, isl);
      if(isl <= 0.0) isl = sl;
      return(true);
     }
   return(false);
  }

int HeldDir(int j)
  {
   ulong  tk = 0;
   int    dir = 0, sig = 0;
   double vol = 0.0, op = 0.0, sl = 0.0, isl = 0.0;
   if(FindPos(j, tk, dir, vol, op, sl, sig, isl)) return(dir);
   return(0);
  }

// Is signal par pichhle 15 din mein trade khul chuki? (restart ke baad dobara na khule)
bool SigUsed(int i, int sig)
  {
   if(!HistorySelect(TimeCurrent() - 15 * 86400, TimeCurrent() + 86400)) return(false);
   int nd = HistoryDealsTotal();
   for(int k = nd - 1; k >= 0; k--)
     {
      ulong t = HistoryDealGetTicket(k);
      if(t == 0) continue;
      if(HistoryDealGetInteger(t, DEAL_MAGIC) != InpMagic) continue;
      if(HistoryDealGetString(t, DEAL_SYMBOL) != g_sym[i]) continue;
      if(HistoryDealGetInteger(t, DEAL_ENTRY) != DEAL_ENTRY_IN) continue;
      int    s2 = 0;
      double x  = 0.0;
      ParseCmt(HistoryDealGetString(t, DEAL_COMMENT), s2, x);
      if(s2 == sig) return(true);
     }
   return(false);
  }

// 1% risk ka lot - broker ka apna hisaab (OrderCalcProfit)
double LotFor(int i, int dir, double price, double slv, double &riskPct)
  {
   string sym = g_sym[i];
   riskPct = 0.0;
   double loss = 0.0;
   ENUM_ORDER_TYPE ot = ORDER_TYPE_BUY;
   if(dir == -1) ot = ORDER_TYPE_SELL;
   if(!OrderCalcProfit(ot, sym, 1.0, price, slv, loss)) return(0.0);
   loss = MathAbs(loss);
   double base = Base();
   if(loss <= 0.0 || base <= 0.0) return(0.0);
   double step = SymbolInfoDouble(sym, SYMBOL_VOLUME_STEP);
   double mn   = SymbolInfoDouble(sym, SYMBOL_VOLUME_MIN);
   double mx   = SymbolInfoDouble(sym, SYMBOL_VOLUME_MAX);
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

//+------------------------------------------------------------------+
//|  LOG - Journal + CSV (MQL5\Files\JasTideRadar_<account>.csv)      |
//+------------------------------------------------------------------+
void Log(int i, string what, int dir, double lots, double price, string note, bool toJournal)
  {
   int dg = (int)SymbolInfoInteger(g_sym[i], SYMBOL_DIGITS);
   string side = Pick(dir == 1, "BUY", Pick(dir == -1, "SELL", "-"));
   string line = StringFormat("%s %s %s %s %.2f @ %s | %s",
                              TimeToString(TimeCurrent(), TIME_DATE | TIME_MINUTES), g_sym[i], what, side,
                              lots, DoubleToString(price, dg), note);
   if(toJournal)
     {
      g_lastAct = line;
      Print("JAS TIDE RADAR " + EA_BUILD + " | " + line);
     }
   if(MQLInfoInteger(MQL_TESTER) != 0) return;   // tester mein sirf Journal
   string fn = "JasTideRadar_" + IntegerToString(AccountInfoInteger(ACCOUNT_LOGIN)) + ".csv";
   int h = FileOpen(fn, FILE_READ | FILE_WRITE | FILE_CSV | FILE_ANSI | FILE_SHARE_READ, ',');
   if(h != INVALID_HANDLE)
     {
      if(FileSize(h) == 0)
         FileWrite(h, "time", "symbol", "kaam", "rukh", "lot", "qeemat", "note");
      if(FileSeek(h, 0, SEEK_END))
         FileWrite(h, TimeToString(TimeCurrent(), TIME_DATE | TIME_MINUTES), g_sym[i], what, side,
                   DoubleToString(lots, 2), DoubleToString(price, dg), note);
      FileClose(h);
     }
  }

void ClosePos(int i, ulong tk, string why)
  {
   trade.SetTypeFillingBySymbol(g_sym[i]);
   if(trade.PositionClose(tk))
     {
      Log(i, "BAND", 0, 0.0, trade.ResultPrice(), why, true);
      g_statsDirty = true;
     }
   else
     {
      g_failT[i] = TimeCurrent();
      PrintFormat("JAS TIDE RADAR %s | %s band nahi hui: %d %s", EA_BUILD, g_sym[i],
                  trade.ResultRetcode(), trade.ResultRetcodeDescription());
     }
  }

//+------------------------------------------------------------------+
//|  KHULI TRADE: radar ki trade khatam = band, warna SL sirf aage    |
//+------------------------------------------------------------------+
void Manage(int i, bool canTrade)
  {
   ulong  tk = 0;
   int    dir = 0, sig = 0;
   double vol = 0.0, op = 0.0, sl = 0.0, isl = 0.0;
   if(!FindPos(i, tk, dir, vol, op, sl, sig, isl)) return;
   string sym  = g_sym[i];
   // comment na parha jaye (sig 0) to sirf rukh milao
   bool   same = (g_d[i] == dir) && (sig == 0 || sig == g_sig[i]);
   if(!canTrade)
     {
      if(!same) g_note[i] = "BAND KARNI HAI - trade band hai (Algo Trading?)";
      return;
     }
   if(!MarketLive(sym) || TimeCurrent() - g_failT[i] < 300) return;
   if(!same)
     {
      string why = "radar ki trade badal gayi";
      if(g_d[i] == 0 && g_ev[i] != "") why = g_ev[i];
      ClosePos(i, tk, why);
      return;
     }
   double pt   = SymbolInfoDouble(sym, SYMBOL_POINT);
   double want = NormPx(sym, g_sl[i]);
   double bid  = SymbolInfoDouble(sym, SYMBOL_BID);
   double ask  = SymbolInfoDouble(sym, SYMBOL_ASK);
   double minD = MinStop(sym);
   if(dir == 1)
     {
      if(want <= sl + pt / 2.0) return;                       // behtar nahi
      if(want >= bid - minD) { ClosePos(i, tk, "qeemat naye SL ke neeche"); return; }
     }
   else
     {
      if(sl > 0.0 && want >= sl - pt / 2.0) return;
      if(want <= ask + minD) { ClosePos(i, tk, "qeemat naye SL ke upar"); return; }
     }
   if(trade.PositionModify(tk, want, 0.0))
      Log(i, "SL", dir, vol, want, "sarakta SL", false);
   else
     {
      g_failT[i] = TimeCurrent();
      PrintFormat("JAS TIDE RADAR %s | %s SL nahi sarka: %d %s", EA_BUILD, sym,
                  trade.ResultRetcode(), trade.ResultRetcodeDescription());
     }
  }

//+------------------------------------------------------------------+
//|  NAYI TRADE: sirf jab aakhri band candle signal wali ho           |
//+------------------------------------------------------------------+
void TryEntry(int i, bool canTrade)
  {
   if(!g_newEnt[i] || g_d[i] == 0) return;
   if(g_doneSig[i] == g_sig[i]) return;
   string sym = g_sym[i];
   int    dir = g_d[i];
   string side = Pick(dir == 1, "BUY", "SELL");

   ulong  tk = 0;
   int    pd = 0, psig = 0;
   double pv = 0.0, po = 0.0, ps = 0.0, pis = 0.0;
   if(FindPos(i, tk, pd, pv, po, ps, psig, pis))
     {
      // isi signal ki trade pehle se khuli = kaam ho chuka; purani (band honi baqi) = intezar
      if(pd == dir && (psig == 0 || psig == g_sig[i])) g_doneSig[i] = g_sig[i];
      return;
     }
   if(canTrade && SigUsed(i, g_sig[i]))
     {
      g_doneSig[i] = g_sig[i];
      g_note[i] = "is signal par trade ho chuki";
      return;
     }

   // gold + silver: ek taraf mein ek waqt mein ek
   if(InpMetalOne && g_metal[i])
     {
      for(int j = 0; j < g_n; j++)
        {
         if(j == i || !g_metal[j]) continue;
         if(HeldDir(j) == dir)
           {
            g_doneSig[i] = g_sig[i];
            g_skipMetal++;
            g_note[i] = "CHHOOTI: " + g_sym[j] + " pehle se " + side + " (gold+silver ek)";
            Log(i, "CHHOOTI", dir, 0.0, 0.0, g_note[i], true);
            return;
           }
        }
     }
   // USD hadd: ek taraf ki zyada se zyada InpUsdCap
   int b = dir * g_usd[i];
   if(b != 0)
     {
      int cnt = 0;
      for(int j = 0; j < g_n; j++)
         if(j != i && HeldDir(j) * g_usd[j] == b) cnt++;
      if(cnt >= InpUsdCap)
        {
         g_doneSig[i] = g_sig[i];
         g_skipCap++;
         g_note[i] = StringFormat("CHHOOTI: USD-%s pehle se %d trades (hadd)", Pick(b > 0, "neeche", "upar"), cnt);
         Log(i, "CHHOOTI", dir, 0.0, 0.0, g_note[i], true);
         return;
        }
     }

   double bid = SymbolInfoDouble(sym, SYMBOL_BID);
   double ask = SymbolInfoDouble(sym, SYMBOL_ASK);
   double price = bid;
   if(dir == 1) price = ask;
   double slv = NormPx(sym, g_sl[i]);
   int    dg  = (int)SymbolInfoInteger(sym, SYMBOL_DIGITS);
   double rp  = 0.0;
   double lots = 0.0;
   if(price > 0.0) lots = LotFor(i, dir, price, slv, rp);

   if(!canTrade)
     {
      g_note[i] = StringFormat("AAJ KHOLTI (trade chalu hota): %s %.2f lot, SL %s, risk %.2f%%",
                               side, lots, DoubleToString(slv, dg), rp);
      return;
     }
   long mode = SymbolInfoInteger(sym, SYMBOL_TRADE_MODE);
   if(mode != SYMBOL_TRADE_MODE_FULL || !MarketLive(sym) || TimeCurrent() - g_failT[i] < 300)
     {
      g_note[i] = "nayi " + side + " - market khulte hi";
      return;
     }
   double minD = MinStop(sym);
   if((dir == 1 && slv >= bid - minD) || (dir == -1 && slv <= ask + minD))
     {
      g_doneSig[i] = g_sig[i];
      g_note[i] = "CHHOOTI: qeemat SL ke paar ja chuki";
      Log(i, "CHHOOTI", dir, 0.0, price, g_note[i], true);
      return;
     }
   double dist = MathAbs(price - slv);
   if(ask - bid > InpMaxSpreadR * dist)
     {
      g_note[i] = "nayi " + side + " - spread zyada, intezar";
      return;
     }
   if(lots <= 0.0)
     {
      g_doneSig[i] = g_sig[i];
      g_skipLot++;
      if(rp > 0.0) g_note[i] = StringFormat("CHHOOTI: sab se chhoti lot ka risk %.2f%% (hadd %.2f%%)", rp, InpMaxRiskPct);
      else         g_note[i] = "CHHOOTI: lot ka hisaab nahi bana";
      Log(i, "CHHOOTI", dir, 0.0, price, g_note[i], true);
      return;
     }

   string cmt = StringFormat("TD %d %s", g_sig[i], DoubleToString(slv, dg));
   trade.SetTypeFillingBySymbol(sym);
   bool ok = false;
   if(dir == 1) ok = trade.Buy(lots, sym, 0.0, slv, 0.0, cmt);
   else         ok = trade.Sell(lots, sym, 0.0, slv, 0.0, cmt);
   uint rc = trade.ResultRetcode();
   if(!ok || (rc != TRADE_RETCODE_DONE && rc != TRADE_RETCODE_DONE_PARTIAL && rc != TRADE_RETCODE_PLACED))
     {
      g_failT[i] = TimeCurrent();
      g_note[i] = StringFormat("order fail %d - 5 min baad phir", rc);
      PrintFormat("JAS TIDE RADAR %s | %s order fail: %d %s", EA_BUILD, sym, rc, trade.ResultRetcodeDescription());
      return;
     }
   g_doneSig[i] = g_sig[i];
   g_note[i] = "";
   g_statsDirty = true;
   Log(i, "KHULI", dir, lots, trade.ResultPrice(),
       StringFormat("SL %s, risk %.2f%%", DoubleToString(slv, dg), rp), true);
  }

//+------------------------------------------------------------------+
//|  HISAAB: EA ki band trades R mein (1R = shuru ka SL faasla)       |
//+------------------------------------------------------------------+
void Stats(bool doPrint)
  {
   g_statsDirty = false;
   if(!HistorySelect(0, TimeCurrent() + 86400)) return;
   int  nd = HistoryDealsTotal();
   TPos ps[];
   int  ord[];
   int  np = 0, no = 0;
   for(int k = 0; k < nd; k++)
     {
      ulong t = HistoryDealGetTicket(k);
      if(t == 0) continue;
      if(HistoryDealGetInteger(t, DEAL_MAGIC) != InpMagic) continue;
      string sym = HistoryDealGetString(t, DEAL_SYMBOL);
      int mk = -1;
      for(int j = 0; j < g_n; j++) if(g_sym[j] == sym) { mk = j; break; }
      if(mk < 0) continue;
      long id = HistoryDealGetInteger(t, DEAL_POSITION_ID);
      int  x  = -1;
      for(int j = np - 1; j >= 0; j--) if(ps[j].id == id) { x = j; break; }
      double vol = HistoryDealGetDouble(t, DEAL_VOLUME);
      double px  = HistoryDealGetDouble(t, DEAL_PRICE);
      if(HistoryDealGetInteger(t, DEAL_ENTRY) == DEAL_ENTRY_IN)
        {
         if(x >= 0) continue;
         np++;
         ArrayResize(ps, np);
         x = np - 1;
         int    sg  = 0;
         double isl = 0.0;
         ParseCmt(HistoryDealGetString(t, DEAL_COMMENT), sg, isl);
         ps[x].id   = id;
         ps[x].mk   = mk;
         ps[x].dir  = 1;
         if(HistoryDealGetInteger(t, DEAL_TYPE) != DEAL_TYPE_BUY) ps[x].dir = -1;
         ps[x].pin  = px;
         ps[x].isl  = isl;
         ps[x].vin  = vol;
         ps[x].vout = 0.0;
         ps[x].pxv  = 0.0;
         ps[x].prof = 0.0;
         ps[x].swap = HistoryDealGetDouble(t, DEAL_SWAP);
         ps[x].comm = HistoryDealGetDouble(t, DEAL_COMMISSION);
         ps[x].cl   = 0;
        }
      else if(x >= 0)
        {
         ps[x].pxv  += px * vol;
         ps[x].vout += vol;
         ps[x].prof += HistoryDealGetDouble(t, DEAL_PROFIT);
         ps[x].swap += HistoryDealGetDouble(t, DEAL_SWAP);
         ps[x].comm += HistoryDealGetDouble(t, DEAL_COMMISSION);
         if(ps[x].cl == 0 && ps[x].vout >= ps[x].vin - 1e-8)
           {
            ps[x].cl = (datetime)HistoryDealGetInteger(t, DEAL_TIME);
            no++;
            ArrayResize(ord, no);
            ord[no - 1] = x;
           }
        }
     }

   int    n = 0, win = 0;
   double sumR = 0.0, sumSw = 0.0, sumCm = 0.0;
   double cum = 0.0, peak = 0.0, dd = 0.0;
   datetime from = g_t0;
   if(InpStatFrom > from) from = InpStatFrom;
   MqlDateTime s0;
   TimeToStruct(from, s0);
   int    pkY = s0.year, ddA = 0, ddB = 0;
   int    yrY[];
   double yrR[];
   int    yrN[];
   int    ny = 0;
   double mkR[MAXM], mkS[MAXM];
   int    mkN[MAXM];
   ArrayInitialize(mkR, 0.0);
   ArrayInitialize(mkS, 0.0);
   ArrayInitialize(mkN, 0);
   for(int q = 0; q < no; q++)
     {
      int x = ord[q];
      double dist = MathAbs(ps[x].pin - ps[x].isl);
      if(dist <= 0.0 || ps[x].vout <= 0.0 || ps[x].cl < from) continue;
      double pout = ps[x].pxv / ps[x].vout;
      double r    = ps[x].dir * (pout - ps[x].pin) / dist;
      // ek R ke paise: isi trade ke faide se, warna broker ka hisaab
      double mpr = 0.0;
      double mv  = MathAbs(pout - ps[x].pin);
      if(mv > dist * 0.01) mpr = MathAbs(ps[x].prof) / mv * dist;
      else
        {
         double pr = 0.0;
         ENUM_ORDER_TYPE ot = ORDER_TYPE_BUY;
         if(ps[x].dir == -1) ot = ORDER_TYPE_SELL;
         if(OrderCalcProfit(ot, g_sym[ps[x].mk], ps[x].vin, ps[x].pin, ps[x].isl, pr)) mpr = MathAbs(pr);
        }
      double sw = 0.0, cm = 0.0;
      if(mpr > 0.0) { sw = ps[x].swap / mpr; cm = ps[x].comm / mpr; }
      n++;
      if(r > 0.0) win++;
      sumR  += r;
      sumSw += sw;
      sumCm += cm;
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
      mkN[ps[x].mk]++;
      mkR[ps[x].mk] += r;
      mkS[ps[x].mk] += sw;
     }
   g_totR = sumR;
   g_statsTxt = StringFormat("EA ki band trades: %d | jeet %d | kul %+.2fR (bina swap) | swap %+.2fR | girawat %.1fR",
                             n, win, sumR, sumSw, dd);
   if(!doPrint) return;

   double yrs = (double)(TimeCurrent() - from) / (365.25 * 86400.0);
   double perY = 0.0;
   if(yrs > 0.0) perY = sumR / yrs;
   double winPct = 0.0;
   if(n > 0) winPct = 100.0 * win / n;
   string yt = "";
   int    yPos = 0;
   for(int j = 0; j < ny; j++)
     {
      yt += StringFormat("%d %+.1fR (%d)  ", yrY[j], yrR[j], yrN[j]);
      if(yrR[j] > 0.0) yPos++;
     }
   string m1 = "", m2 = "";
   for(int j = 0; j < g_n; j++)
     {
      string one = StringFormat("%s %d %+.1fR swap %+.1fR  ", g_sym[j], mkN[j], mkR[j], mkS[j]);
      if(j < 5) m1 += one;
      else      m2 += one;
     }
   bool pass = (n >= 366 && n <= 610 && sumR >= 26.0 && dd <= 25.0);
   PrintFormat("JAS TIDE RADAR %s | MARKET: %s", EA_BUILD, m1);
   PrintFormat("JAS TIDE RADAR %s | MARKET: %s", EA_BUILD, m2);
   PrintFormat("JAS TIDE RADAR %s | SAAL: %s| musbat %d/%d", EA_BUILD, yt, yPos, ny);
   PrintFormat("JAS TIDE RADAR %s | CHHOOTI: USD hadd %d | gold+silver %d | lot %d", EA_BUILD, g_skipCap, g_skipMetal, g_skipLot);
   PrintFormat("JAS TIDE RADAR %s | KUL: %d trades | jeet %.0f%% | kul %+.2fR bina swap | saal ~%+.2fR | girawat %.1fR (%d-%d) | swap %+.2fR | commission %+.2fR",
               EA_BUILD, n, winPct, sumR, perY, dd, ddA, ddB, sumSw, sumCm);
   PrintFormat("JAS TIDE RADAR %s | hisaab %s se | QAIDA (pehle se likha; hisaab 2019.01.01 se aaj tak ho tab): trades 366-610, kul R bina swap >= +26R, girawat <= 25R -> %s",
               EA_BUILD, TimeToString(from, TIME_DATE), Pick(pass, "PASS - agla qadam demo", "FAIL - farq dhoondna, settings NAHI badalni"));
  }

//+------------------------------------------------------------------+
//|  PANEL                                                           |
//+------------------------------------------------------------------+
string Line(int i, double &openRisk, int &nDn, int &nUp)
  {
   string sym = g_sym[i];
   if(!g_have[i])  return(sym + ": broker par nahi mila - chhor diya");
   if(!g_ready[i]) return(sym + ": daily candles aa rahi hain...");
   int    dg = (int)SymbolInfoInteger(sym, SYMBOL_DIGITS);
   string rk = Pick(g_rk[i] == 1, "UPAR", Pick(g_rk[i] == -1, "NEECHE", "-"));
   string s  = sym + " | " + rk + " | ";
   ulong  tk = 0;
   int    dir = 0, sig = 0;
   double vol = 0.0, op = 0.0, sl = 0.0, isl = 0.0;
   if(FindPos(i, tk, dir, vol, op, sl, sig, isl))
     {
      double px = SymbolInfoDouble(sym, SYMBOL_BID);
      if(dir == -1) px = SymbolInfoDouble(sym, SYMBOL_ASK);
      double dist = MathAbs(op - isl);
      double rNow = 0.0;
      if(dist > 0.0) rNow = dir * (px - op) / dist;
      s += StringFormat("EA: %s %.2f @ %s | SL %s | abhi %+.2fR", Pick(dir == 1, "BUY", "SELL"), vol,
                        DoubleToString(op, dg), DoubleToString(sl, dg), rNow);
      int b = dir * g_usd[i];
      if(b > 0) nDn++;
      if(b < 0) nUp++;
      double pr = 0.0;
      ENUM_ORDER_TYPE ot = ORDER_TYPE_BUY;
      if(dir == -1) ot = ORDER_TYPE_SELL;
      if(sl > 0.0 && OrderCalcProfit(ot, sym, vol, op, sl, pr) && pr < 0.0) openRisk += -pr;
     }
   else if(g_d[i] != 0)
      s += StringFormat("radar: %s %d din, SL %s - EA ke paas nahi", Pick(g_d[i] == 1, "BUY", "SELL"),
                        g_age[i], DoubleToString(g_sl[i], dg));
   else if(g_dist[i] < 0.0)
      s += StringFormat("intezar - bazaar susat (ATR < %.2f%%)", InpMinAtrPct);
   else if(g_rk[i] != 0)
      s += StringFormat("intezar: %s %s (%.1f ATR door)", Pick(g_rk[i] == 1, "BUY upar", "SELL neeche"),
                        DoubleToString(g_lvl[i], dg), g_dist[i]);
   else
      s += "intezar";
   if(g_ev[i] != "")   s += " | kal: " + g_ev[i];
   if(g_note[i] != "") s += " | " + g_note[i];
   return(s);
  }

void Panel(bool canTrade)
  {
   if(g_statsDirty) Stats(false);
   double base = Base();
   string mode = "SIRF DIKHANA - trade nahi karta";
   if(InpTrade) mode = "TRADE BAND - Algo Trading hara karein";
   if(canTrade) mode = "TRADE CHALU";
   string s = StringFormat("=== JAS TIDE RADAR EA  %s ===   %s\n", EA_BUILD, mode);
   s += StringFormat("Risk %.2f%% = %.2f | USD hadd %d | gold+silver ek: %s | suffix '%s'\n",
                     InpRiskPct, base * InpRiskPct / 100.0, InpUsdCap, Pick(InpMetalOne, "haan", "nahi"), g_suffix);
   int    nDn = 0, nUp = 0;
   double openRisk = 0.0;
   for(int i = 0; i < g_n; i++) s += Line(i, openRisk, nDn, nUp) + "\n";
   double orPct = 0.0;
   if(base > 0.0) orPct = openRisk / base * 100.0;
   s += StringFormat("USD daao (EA ki trades): USD-neeche %d | USD-upar %d | khula khatra %.2f%%\n", nDn, nUp, orPct);
   s += g_statsTxt + "\n";
   s += StringFormat("Chhooti: USD hadd %d | gold+silver %d | lot %d\n", g_skipCap, g_skipMetal, g_skipLot);
   s += "Aakhri kaam: " + g_lastAct;
   Comment(s);
  }

//+------------------------------------------------------------------+
//|  HAR CHAKKAR: engine -> band/SL -> nayi trade -> panel            |
//+------------------------------------------------------------------+
void Pass()
  {
   datetime now = TimeCurrent();
   bool tester = (MQLInfoInteger(MQL_TESTER) != 0);
   int  gap = 20;
   if(tester) gap = 300;
   if(g_lastPass != 0 && now - g_lastPass < gap) return;
   g_lastPass = now;

   bool canTrade = tester || (InpTrade && TerminalInfoInteger(TERMINAL_TRADE_ALLOWED) != 0 &&
                              MQLInfoInteger(MQL_TRADE_ALLOWED) != 0);

   // 1) engine - sirf jab kisi market ki nayi band candle aaye
   for(int i = 0; i < g_n; i++)
     {
      if(!g_have[i]) continue;
      datetime t1 = iTime(g_sym[i], PERIOD_D1, 1);
      if(t1 == 0 || t1 == g_lastBar[i]) continue;
      if(RunEngine(i)) g_lastBar[i] = t1;
     }
   // 2) khuli trades pehle (band / SL), radar jaisa
   for(int i = 0; i < g_n; i++)
      if(g_have[i] && g_ready[i]) Manage(i, canTrade);
   // 3) nayi trades, list ki tarteeb se (pehle gold)
   for(int i = 0; i < g_n; i++)
      if(g_have[i] && g_ready[i]) TryEntry(i, canTrade);
   // 4) panel
   if(!tester || MQLInfoInteger(MQL_VISUAL_MODE) != 0) Panel(canTrade);
  }

//+------------------------------------------------------------------+
int OnInit()
  {
   if(InpEntryLen < 2 || InpExitLen < 2 || InpAtrLen < 2 || InpEmaFast < 2 || InpEmaSlow <= InpEmaFast)
     {
      Print("ERROR: qawaid ke number ghalat hain.");
      return(INIT_PARAMETERS_INCORRECT);
     }
   if(InpRiskPct <= 0.0 || InpRiskPct > 3.0)
     {
      Print("ERROR: InpRiskPct 0 se 3 ke darmiyan hona chahiye.");
      return(INIT_PARAMETERS_INCORRECT);
     }
   string parts[];
   ushort sep = StringGetCharacter(",", 0);
   int cnt = StringSplit(InpSymbols, sep, parts);
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
      Print("ERROR: koi market nahi.");
      return(INIT_PARAMETERS_INCORRECT);
     }
   g_suffix = DetectSuffix();
   for(int i = 0; i < g_n; i++)
     {
      g_sym[i]     = g_base[i] + g_suffix;
      g_have[i]    = SymbolSelect(g_sym[i], true);
      g_usd[i]     = UsdSide(g_base[i]);
      g_metal[i]   = IsMetal(g_base[i]);
      g_crypto[i]  = (StringFind(g_base[i], "BTC") >= 0 || StringFind(g_base[i], "ETH") >= 0);
      g_lastBar[i] = 0;
      g_ready[i]   = false;
      g_d[i]       = 0;
      g_sl[i]      = 0.0;
      g_sig[i]     = 0;
      g_age[i]     = 0;
      g_newEnt[i]  = false;
      g_ev[i]      = "";
      g_rk[i]      = 0;
      g_lvl[i]     = 0.0;
      g_dist[i]    = 0.0;
      g_doneSig[i] = 0;
      g_note[i]    = "";
      g_failT[i]   = 0;
      if(!g_have[i]) PrintFormat("JAS TIDE RADAR %s | %s broker par nahi mila - chhor diya", EA_BUILD, g_sym[i]);
     }
   trade.SetExpertMagicNumber(InpMagic);
   trade.SetDeviationInPoints(InpSlippage);
   trade.LogLevel(LOG_LEVEL_ERRORS);
   g_t0       = TimeCurrent();
   g_lastPass = 0;
   if(!EventSetTimer(30)) Print("Timer nahi laga - sirf tick par chalega.");
   Comment("=== JAS TIDE RADAR EA  " + EA_BUILD + " ===\nshuru ho raha hai - daily candles parh raha hai...");
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
//| SIRF TESTER: kul hisaab Journal mein. Wapas: kul R bina swap.     |
//+------------------------------------------------------------------+
double OnTester()
  {
   Stats(true);
   return(g_totR);
  }
//+------------------------------------------------------------------+
