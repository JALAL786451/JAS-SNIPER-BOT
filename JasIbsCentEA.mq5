//====================================================================
//===  BUILD c1   <<< PANEL PAR YAHI NUMBER AANA CHAHIYE >>>
//====================================================================
//+------------------------------------------------------------------+
//|                                                 JasIbsCentEA.mq5 |
//|  c1 (2 Nov 2026): JasIbsEA i6 ki CENT copy - Koshish #81 ASLI PASS|
//|  (2019+ 401 tr, $1000 par +$382, girawat $37). Qaide i6 wahi;   |
//|  sirf LOT: $10 risk (cent par khud 1000 USC) x martingale 1.5x,  |
//|  3 qadam (1, 1.5, 2.25) har market alag; balance < $800 = nayi   |
//|  trade nahi. FTMO pehra BAND. User ne MARTINGALE naam le kar     |
//|  maanga (2 Nov). Grid / hedging / averaging NAHI.                |
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
//|   5) Lot = $10 risk x martingale qadam. HAR MARKET par ek position.|
//|      Sunday ki chhoti candle Monday mein mila di jati hai.        |
//|   6) Bahar wale din nayi nahi: jis candle par band hua (IBS / 5   |
//|      din / SL laga) us candle ke signal par nayi trade nahi.      |
//|   7) EA lagne ke baad pehli candle par nayi trade nahi (der se    |
//|      entry nahi); band ki jaanch hoti hai.                       |
//|                                                                  |
//|  InpTrade false = SIRF DIKHANA. Tester ke aakhir mein Journal    |
//|  mein R ka hisaab (sirf maloomat - Exness ka index data chhota). |
//|  i2 (14 Oct): Journal mein har trade ki ek line (TRADE: signal   |
//|  din, khuli, band, R) - strategies/jas_ibs_test.pine ki list se  |
//|  din-ba-din milane ke liye. Trading ke qaide i1 wale hi.         |
//|  i3 (27 Oct): daily candle ab EA khud H1 se banata hai, 17:00     |
//|  New York par band (TV / OANDA jaisi; US DST khud, JasImomEA se). |
//|  i6: faisla 16:15 NY par (Python ka din ka close, candle 16:15 par |
//|  kati) - Jumma bhi. Chhutti / tick na aaye to bazaar khulne par   |
//|  mukammal candle se (i2 jaisa). Pehra poore account par.          |
//|                                                                  |
//|  NO grid / NO hedging / NO averaging. Martingale sirf 3 qadam.   |
//+------------------------------------------------------------------+
#property copyright "JAS-SNIPER-BOT"
#property version   "1.00"

#include <Trade\Trade.mqh>
#define EA_BUILD "c1"          // har nayi file par ye number barhta hai
#define EA_NAME  "JAS IBS CENT"
// c1 (2 Nov 2026): Koshish #81 - i6 + $ risk + martingale (1.5x, 3 qadam) + $800 account stop, cent account.
// i6 (1 Nov 2026, judge 3 = Python se farq theek): (1) din ki candle 16:15 NY par kati (Python ka
//     Dukascopy data 16:15-18:00 NY khali) - candle M15 se; faisla 16:15 NY par (16:55 nahi);
//     (2) restart: nayi trade usi din band nahi hoti (age >= 1), 15 min ke andar late entry;
//     (3) lot pakke InpStartBal ($100k) par; (4) comment gum ho to din ki ginti theek;
//     (5) PEHRA POORE account par (JasTrendEA t5 wala code, ek GlobalVariable): din 4% + target,
//     kul hadd band (user 1 Nov: "1").
// i5 (31 Oct 2026): FTMO #53 ASLI PASS - IBS ab US500 AUR USTEC, risk 1% (har trade). 2019+ FTMO 83 pass / 0 fail.
// i4 (31 Oct 2026): FTMO #49 ASLI PASS ki setting DEFAULT - US500, risk 2%, lot hadd 20, TRADE true.
//     Sirf FTMO demo 474832446 ke liye (JasTrendEA t4 ke saath).
#define MAXM 10

CTrade trade;

// String chunne ka kaam if se - "cond ? \"\" : \"...\"" MetaEditor mein shak wala hai.
string Pick(bool c, string a, string b) { if(c) return(a); return(b); }

//--------------------------- INPUTS -----------------------------------
input group "=== 0 - Markets ==="
input string InpSymbols    = "US500,USTEC";  // Markets (comma se). KHALI = sirf chart ka symbol. #53: US500,USTEC
input string InpSuffix     = "auto";   // Suffix (Exness demo m, cent c) - auto = chart ke symbol se

input group "=== 1 - Qawaid (Pine b2 jaise - mat badlein) ==="
input double InpIbsLo      = 0.2;      // BUY: IBS is se kam
input double InpIbsHi      = 0.8;      // Band: IBS is se zyada
input int    InpMaxDays    = 5;        // Band: zyada se zyada din (band candles)
input int    InpTrendLen   = 200;      // Rukh: SMA
input int    InpAtrLen     = 14;       // ATR length
input double InpSlMult     = 3.0;      // SL (x ATR) - hifazat

input group "=== 2 - Risk ==="
input bool   InpTrade      = true;     // TRADE KARE? false = sirf dikhaye (Tester mein hamesha trade)
input double InpRiskUsd    = 10.0;     // Shuru risk har trade (US DOLLAR; cent account par khud x100 USC) - #81: 10
input bool   InpMart       = true;     // Martingale: haar ke baad agli trade bari (#81: true)
input double InpMartMult   = 1.5;      // Martingale guna (#81: 1.5)
input int    InpMartSteps  = 3;        // Qadam (#81: 3 = 1, 1.5, 2.25 phir wapas 1)
input double InpAcctStopUsd = 800.0;   // Balance is US$ se kam = nayi trade NAHI (#81: 800)
input double InpMaxRiskX   = 2.0;      // Sab se chhoti lot ka risk chahiye se is guna zyada = trade nahi
input double InpMaxLot     = 20.0;     // Lot ki hadd (hifazat)

input group "=== 3 - Amal ==="
input int    InpBars       = 1200;     // Kitni daily candles parhni
input int    InpSlippage   = 50;       // Max slippage (points)
input int    InpMagic      = 20261102; // Magic number (cent, i6 se alag)
input datetime InpStatFrom = D'2019.01.01'; // Tester: hisaab is tareekh se khuli trades ka
input int    InpServerGMT  = 0;        // Broker server ka GMT farq (Exness = 0)
input string InpCutSyms    = "US500,USTEC"; // In ki din ki candle InpCutMinNY par kati (Python Dukascopy jaisa)
input int    InpCutMinNY   = 975;      // Faisla + kat ka waqt NY minute (975 = 16:15); 16:15-17:00 ka data nahi

input group "=== 4 - FTMO pehra (POORE account par, JasTrendEA t5 jaisa) ==="
input double InpStartBal   = 0.0;      // c1: 0 = FTMO pehra BAND (cent). Challenge ka shuru balance (FTMO 100000) - lot isi par (Python). 0 = pehra band, lot = balance
input double InpTargetPct  = 10.0;     // Target % (Phase 1 = 10, Phase 2 = 5) - SAB band, dono EA ruk jayein
input double InpDayStopPct = 4.0;      // Din ka nuksan % (FTMO 5) - SAB band (dono EA), us din nayi nahi
input double InpMaxDdPct   = 0.0;      // Kul nuksan % par hamesha band - 0 = BAND (user 1 Nov: "1"; FTMO 10)
input string InpGuardMagics = "20261102"; // Pehra in magic ki trades band kare (Trend + IBS)

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
// i6: FTMO pehra (poora account)
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

// c1: US$ -> account currency (cent = USC = x100)
double UsdToAcct(double usd)
  {
   string cur = AccountInfoString(ACCOUNT_CURRENCY);
   if(cur == "USC" || cur == "USc" || cur == "usc") return(usd * 100.0);
   return(usd);
  }

// c1: martingale qadam (0, 1, 2 ...) = isi market + magic ki lagatar haari band trades % InpMartSteps
int MartStep()
  {
   if(!InpMart || InpMartSteps <= 1) return(0);
   if(!HistorySelect(0, TimeCurrent() + 60)) return(0);
   int k = 0;
   for(int i = HistoryDealsTotal() - 1; i >= 0; i--)
     {
      ulong t = HistoryDealGetTicket(i);
      if(t == 0) continue;
      if(HistoryDealGetString(t, DEAL_SYMBOL) != S) continue;
      if(HistoryDealGetInteger(t, DEAL_MAGIC) != InpMagic) continue;
      long en = HistoryDealGetInteger(t, DEAL_ENTRY);
      if(en != DEAL_ENTRY_OUT && en != DEAL_ENTRY_OUT_BY) continue;
      double p = HistoryDealGetDouble(t, DEAL_PROFIT) + HistoryDealGetDouble(t, DEAL_SWAP)
                 + HistoryDealGetDouble(t, DEAL_COMMISSION);
      if(p < 0.0) k++;
      else break;
     }
   return(k % InpMartSteps);
  }

double MartFactor(int st) { return(MathPow(InpMartMult, st)); }

//+------------------------------------------------------------------+
//|  NEW YORK WAQT (JasImomEA se) - US DST: March 2nd Sun - Nov 1st Sun|
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
   datetime utc = AddSec(srv, -(long)InpServerGMT * 3600);
   if(UsDst(utc)) return(AddSec(utc, -4 * 3600));
   return(AddSec(utc, -5 * 3600));
  }

datetime NyToServer(datetime ny)
  {
   datetime utc = AddSec(ny, 4 * 3600);
   if(!UsDst(utc)) utc = AddSec(ny, 5 * 3600);
   return(AddSec(utc, (long)InpServerGMT * 3600));
  }

//+------------------------------------------------------------------+
//|  CET / CEST (FTMO ka din) - JasTrendEA se                         |
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
   datetime utc = AddSec(srv, -(long)InpServerGMT * 3600);
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

// NY waqt -> session ka din (00:00). 17:00 NY ke baad = agla din (TV / OANDA daily candle)
datetime SessDay(datetime ny)
  {
   long x = (long)ny + 7 * 3600;
   return((datetime)(x - x % 86400));
  }

// Session (din) kis server waqt par shuru hui = pichhle din 17:00 NY
datetime SessStart(datetime day) { return(NyToServer(AddSec(day, -7 * 3600))); }

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
   double want = UsdToAcct(InpRiskUsd) * MartFactor(MartStep());   // c1: risk paise (account currency)
   if(loss <= 0.0 || base <= 0.0 || want <= 0.0) return(0.0);
   double step = SymbolInfoDouble(S, SYMBOL_VOLUME_STEP);
   double mn   = SymbolInfoDouble(S, SYMBOL_VOLUME_MIN);
   double mx   = SymbolInfoDouble(S, SYMBOL_VOLUME_MAX);
   if(step <= 0.0) step = 0.01;
   double lots = MathFloor(want / loss / step + 1e-9) * step;
   if(lots < mn - 1e-12)
     {
      riskPct = mn * loss / base * 100.0;
      if(mn * loss > InpMaxRiskX * want) return(0.0);   // chhoti se chhoti lot bhi bohot bari
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
      Print("JAS IBS CENT " + EA_BUILD + " | " + g_lastAct);
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
   PrintFormat("JAS IBS CENT %s | %s band nahi hui: %d %s", EA_BUILD, S, trade.ResultRetcode(), trade.ResultRetcodeDescription());
   return(false);
  }

//+------------------------------------------------------------------+
//|  DAILY CANDLES (i3) - H1 se, 17:00 NY par band. T = session ka din |
//|  (NY tareekh 00:00, TV ki tareekh). Sat/Sun ki chhoti candle agle |
//|  din mein (24/7 symbol BTC/ETH par nahi). withNow = chalti session|
//|  bhi (close = abhi ki qeemat); false = sirf mukammal sessions.    |
//+------------------------------------------------------------------+
// i6: InpCutSyms wala market? (base naam, suffix ke bagair)
bool IsCutSym()
  {
   string p[];
   int n = StringSplit(InpCutSyms, StringGetCharacter(",", 0), p);
   for(int k = 0; k < n; k++)
     {
      string b = p[k];
      StringTrimLeft(b);
      StringTrimRight(b);
      if(StringLen(b) > 0 && b == g_base[g_i]) return(true);
     }
   return(false);
  }

int LoadBars(datetime &T[], double &H[], double &L[], double &C[], bool withNow)
  {
   MqlRates rt[];
   // i6: M15 se (16:15 NY ka kat H1 mein nahi ho sakta); history poori load na ho to abhi nahi
   if(!SeriesInfoInteger(S, PERIOD_M15, SERIES_SYNCHRONIZED)) return(0);
   int got = CopyRates(S, PERIOD_M15, 0, MathMin(InpBars * 96 + 192, 99000), rt);
   if(got <= 0) return(0);
   ArrayResize(T, got);
   ArrayResize(H, got);
   ArrayResize(L, got);
   ArrayResize(C, got);
   bool nonstop = Is247();
   bool cut = IsCutSym();
   datetime nowDay = SessDay(ServerToNy(TimeCurrent()));
   int  m = 0;
   bool pend = false;
   double pH = 0.0, pL = 0.0;
   for(int k = 0; k < got; k++)
     {
      datetime nyk = ServerToNy(rt[k].time);
      if(cut)
        {
         long mn = ((long)nyk % 86400) / 60;
         if(mn >= InpCutMinNY && mn < 17 * 60) continue;   // Python data mein ye waqt nahi
        }
      datetime d = SessDay(nyk);
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
      else        after = (SessStart(T[j]) > AddSec(t0, -2 * 3600));   // i6: session t0 ke baad shuru hui
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
   string gv = StringFormat("JASIBSC_STOP_%I64d_%d", AccountInfoInteger(ACCOUNT_LOGIN), InpMagic);
   if(Base() < UsdToAcct(InpAcctStopUsd) && !GlobalVariableCheck(gv)) GlobalVariableSet(gv, 1.0);   // Python jaisa: hamesha ke liye
   if(GlobalVariableCheck(gv))
     {
      Note(StringFormat("BUY CHHOOTI: ACCOUNT STOP (hamesha; GV mita kar hi dobara) - balance %.2f, hadd %.2f (US$ %.0f)", Base(), UsdToAcct(InpAcctStopUsd), InpAcctStopUsd));
      return(true);
     }
   int mst = MartStep();
   double rp = 0.0;
   double lots = LotFor(1, px, slv, rp);
   if(lots <= 0.0)
     {
      Note(StringFormat("BUY CHHOOTI: chhoti lot bhi %.1f guna se zyada risk", InpMaxRiskX));
      return(true);
     }
   if(!canTrade)
     {
      Note(StringFormat("BUY HOTA (sirf dikhana) %.2f @ %s | SL %s, risk %.2f%%, qadam %d", lots, Px(px), Px(slv), rp, mst + 1));
      return(true);
     }
   string cmt = StringFormat("IBS %d %s", day, Px(slv));
   trade.SetTypeFillingBySymbol(S);
   bool ok = trade.Buy(lots, S, 0.0, slv, 0.0, cmt);
   if(ok && trade.ResultRetcode() == TRADE_RETCODE_DONE)
     {
      g_statsDirty = true;
      Note(StringFormat("KHULI BUY %.2f @ %s | SL %s, risk %.2f%%, qadam %d", lots, Px(trade.ResultPrice()), Px(slv), rp, mst + 1));
      return(true);
     }
   g_failT[g_i] = TimeCurrent();
   PrintFormat("JAS IBS CENT %s | %s BUY nahi khuli: %d %s", EA_BUILD, S, trade.ResultRetcode(), trade.ResultRetcodeDescription());
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
//|  FAISLA - market i ki har daily candle par ek dafa: 17:00 NY se   |
//|  thora pehle (withNow) ya der se mukammal candle par              |
//|  false = abhi nahi ho saka (data / market band / order fail)     |
//+------------------------------------------------------------------+
bool Decide(int i, bool canTrade, bool withNow)
  {
   Use(i);
   // i6: pehle market (bazaar band = candles parhne ki zaroorat nahi, minute baad dobara)
   if(!MarketLive()) return(false);
   // der wala faisla (agli session): tick nayi session ka ho (rozana break se pehle wala nahi)
   datetime nowNy = ServerToNy(TimeCurrent());
   MqlTick ft;
   if(!SymbolInfoTick(S, ft)) return(false);
   if(!withNow && (datetime)ft.time < SessStart(SessDay(nowNy))) return(false);
   datetime T[];
   double   H[], L[], C[];
   int m = LoadBars(T, H, L, C, withNow);
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
      if(g_age[i] >= 1 && (hiIbs || old))            // i6: signal din khud band nahi karta (restart)
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
   // i6: EA lagne ke baad pehla faisla - kat ke 15 min ke andar (16:15-16:30 NY) ho to entry, warna der se nahi
   bool skipInit = false;
   if(g_initBar[i])
     {
      long mnow  = ((long)nowNy % 86400) / 60;
      bool inWin = (mnow >= InpCutMinNY && mnow < 17 * 60);
      if(withNow) { g_initBar[i] = false; skipInit = (mnow > InpCutMinNY + 15); }
      else        { skipInit = true; if(!inWin) g_initBar[i] = false; }   // kat ki khirki mein aaj wala faisla baqi
     }
   if(skipInit)
     {
      if(!has) Note(StringFormat("EA laga: %s ki candle par nayi trade nahi (der se entry nahi) - agli band candle se", TimeToString(T[k], TIME_DATE)));
     }
   else if(!has && !closedNow)
     {
      if(g_ibs[i] >= 0.0 && g_ibs[i] < InpIbsLo && g_c[i] > g_smaT[i])
        {
         int day = YMD(T[k]);
         datetime since = SessStart(T[k]);            // Monday: Sunday raat wala hissa bhi isi candle ka
         if(g_stop > 0 || g_dayStop)
            Note(StringFormat("BUY signal %s magar FTMO pehra laga hai - nayi nahi", TimeToString(T[k], TIME_DATE)));
         else if(SlHitSince(since))
            Note(StringFormat("BUY signal %s magar is candle par SL laga tha - Pine jaisa nayi nahi", TimeToString(T[k], TIME_DATE)));
         else if(!SigUsed(day))
            if(!TryOpen(g_c[i], g_atr[i], day, canTrade)) return(false);
        }
     }
   g_doneT[i] = T[k];
   return(true);
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
                                    r, Pick(ps[x].why == 1, "SL", "IBS/5 din"));
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
   // aakhri 20 trades ki lines pehle - taake Journal ke aakhir mein trades + KUL saath hon
   int j0 = ntl - 20;
   if(j0 < 0) j0 = 0;
   for(int j = j0; j < ntl; j++)
      PrintFormat("JAS IBS CENT %s | %s", EA_BUILD, tl[j]);
   PrintFormat("JAS IBS CENT %s | %s | SAAL: %s| musbat %d/%d", EA_BUILD, g_label, yt, yPos, ny);
   PrintFormat("JAS IBS CENT %s | %s | MARKET: %s", EA_BUILD, g_label, mt);
   PrintFormat("JAS IBS CENT %s | %s | BAND: IBS/%d din %d | SL %d | bina comment %d",
               EA_BUILD, g_label, InpMaxDays, nEa, nSL, noSL);
   PrintFormat("JAS IBS CENT %s | %s | KUL: %d trades | jeet %.1f%% | Exp %+.3fR (+-%.3f = 2SE) | PF %.2f | kul %+.2fR | girawat %.1fR (%d-%d) | swap+commission %+.2fR",
               EA_BUILD, g_label, n, winPct, ex, se2, pf, sumR, dd, ddA, ddB, sumC);
   PrintFormat("JAS IBS CENT %s | %s | hisaab %s se | Tester = sirf MALOOMAT (faisla TradingView ASLI PASS + demo ka qaida)",
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
   string s = "=== JAS IBS CENT  " + EA_BUILD + "  ===  " + mode + "\n";
   s += StringFormat("Risk US$ %.2f (= %.0f %s) x martingale %s | stop US$ %.0f | suffix '%s' | %d market | magic %d | faisla %02d:%02d NY\n",
                     InpRiskUsd, UsdToAcct(InpRiskUsd), AccountInfoString(ACCOUNT_CURRENCY),
                     Pick(InpMart, StringFormat("%.1fx %d qadam", InpMartMult, InpMartSteps), "BAND"),
                     InpAcctStopUsd, g_suffix, g_n, InpMagic, InpCutMinNY / 60, InpCutMinNY % 60);
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
   Guard(canTrade);
   datetime ny     = ServerToNy(now);
   datetime nowDay = SessDay(ny);
   MqlDateTime nt, dt;
   TimeToStruct(ny, nt);
   TimeToStruct(nowDay, dt);
   int  mins   = nt.hour * 60 + nt.min;
   // i6: 16:15 NY (kat) se 17:00 tak: aaj ki candle mukammal (Python ka close) = faisla
   bool cutWin = (mins >= InpCutMinNY && mins < 17 * 60 && dt.day_of_week >= 1 && dt.day_of_week <= 5);
   for(int i = 0; i < g_n; i++)
     {
      if(!g_have[i]) continue;
      Use(i);
      if(now - g_failT[i] <= 60) continue;
      // nayi session shuru hui: pichhli mukammal candle ka faisla na hua ho (chhutti / EA baad mein laga)
      if(nowDay != g_lastD1[i])
        {
         if(Decide(i, canTrade, false)) g_lastD1[i] = nowDay;
         else if(g_failT[i] < now) g_failT[i] = now;   // bazaar band / data: minute baad dobara
        }
      // i6: 16:15 NY par aaj ki (kati hui) candle par faisla - Python ka din ka close (Jumma bhi)
      if(cutWin && IsCutSym() && g_doneT[i] != nowDay)
        {
         if(!Decide(i, canTrade, true) && g_failT[i] < now) g_failT[i] = now;
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
   if(InpCutMinNY < 9 * 60 + 30 || InpCutMinNY >= 17 * 60)
     {
      Print("ERROR: InpCutMinNY 570 (09:30) se 1019 (16:59) ke darmiyan hona chahiye.");
      return(INIT_PARAMETERS_INCORRECT);
     }
   if(InpStartBal < 0.0 || InpTargetPct <= 0.0 || InpDayStopPct <= 0.0 || InpMaxDdPct < 0.0)
     {
      Print("ERROR: FTMO pehra ke number ghalat hain.");
      return(INIT_PARAMETERS_INCORRECT);
     }
   if(InpRiskUsd <= 0.0 || InpMartMult < 1.0 || InpMartMult > 2.0 || InpMartSteps < 1 || InpMartSteps > 5 || InpAcctStopUsd < 0.0)
     {
      Print("ERROR: InpRiskUsd > 0, InpMartMult 1-2, InpMartSteps 1-5, InpAcctStopUsd >= 0 hona chahiye.");
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
      if(!g_have[i]) PrintFormat("JAS IBS CENT %s | %s broker par nahi mila - chhor diya", EA_BUILD, g_sym[i]);
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
   PehraInit();
   trade.SetExpertMagicNumber(InpMagic);
   trade.SetDeviationInPoints(InpSlippage);
   trade.LogLevel(LOG_LEVEL_ERRORS);
   if(MQLInfoInteger(MQL_TESTER) == 0)
     {
      if(!EventSetTimer(30)) Print("Timer nahi laga - sirf tick par chalega.");
     }
   Comment("=== JAS IBS CENT  " + EA_BUILD + " ===\nshuru ho raha hai - daily candles parh raha hai...");
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
