//====================================================================
//===  BUILD o1   <<< PANEL PAR YAHI NUMBER AANA CHAHIYE >>>
//====================================================================
//+------------------------------------------------------------------+
//|                                                     JasOrbEA.mq5 |
//|  JAS ORB - Opening Range Breakout. Toby Crabel (1990) ka mashhoor |
//|  intraday qaida, Claude ka apna design nahi.                     |
//|  Naqsha + pehle se likha qaida: docs/orb_naqsha.md (11 Oct 2026).|
//|                                                                  |
//|  QAWAID (pehle se tay - mat badlein):                            |
//|   1) Range = New York ki pehli 15m candle (9:30-9:45 NY waqt).    |
//|      US DST (garmi/sardi ka waqt) EA khud ginta hai.             |
//|   2) 9:45 ke baad qeemat (bid) range ke HIGH ke upar = BUY,       |
//|      LOW ke neeche = SELL - jo pehle ho. Din mein ek trade.       |
//|   3) SL = range ka doosra kinara (server par).                   |
//|   4) TP nahi. 15:50 NY waqt par band - raat ko trade nahi.       |
//|   5) Lot = 1% risk (broker ka OrderCalcProfit). Sirf Peer-Jumma.  |
//|   6) Koi filter nahi (rukh / ATR / din).                         |
//|                                                                  |
//|  Tester ke aakhir mein Journal mein: KUL (trades, jeet, Exp R     |
//|  +- 2SE, PF, kul R, girawat), SAAL, BAND, DIN aur QAIDA PASS/FAIL.|
//|  Tester ko bina Visual mode chalayein (warna Journal lines nahi). |
//|                                                                  |
//|  NO grid / NO martingale / NO averaging. Ek waqt mein ek position.|
//+------------------------------------------------------------------+
#property copyright "JAS-SNIPER-BOT"
#property version   "1.00"

#include <Trade\Trade.mqh>
#define EA_BUILD "o1"          // har nayi file par ye number barhta hai

CTrade trade;

// String chunne ka kaam if se - "cond ? \"\" : \"...\"" MetaEditor mein shak wala hai.
string Pick(bool c, string a, string b) { if(c) return(a); return(b); }

//--------------------------- INPUTS -----------------------------------
input group "=== 1 - Waqt (NY - mat badlein) ==="
input int    InpServerGMT  = 0;        // Broker server ka GMT farq (Exness = 0)
input int    InpOpenHour   = 9;        // Range shuru: ghanta (NY waqt)
input int    InpOpenMin    = 30;       // Range shuru: minute (range = yahan se pehli 15m candle)
input int    InpExitHour   = 15;       // Band: ghanta (NY waqt)
input int    InpExitMin    = 50;       // Band: minute

input group "=== 2 - Risk ==="
input bool   InpTrade      = false;    // TRADE KARE? false = sirf dikhaye (Tester mein hamesha trade)
input double InpRiskPct    = 1.0;      // Har trade ka risk (% balance)
input double InpMaxRiskPct = 2.0;      // Sab se chhoti lot ka risk is % se zyada = trade nahi
input double InpMaxLot     = 1.00;     // Lot ki hadd (hifazat)

input group "=== 3 - Amal ==="
input int    InpSlippage   = 50;       // Max slippage (points)
input int    InpMagic      = 20261011; // Magic number
input datetime InpStatFrom = D'2019.01.01'; // Hisaab is tareekh se khuli trades ka
input bool   InpVerbose    = false;    // Tester mein har trade Journal mein likho

//--------------------------- HAAL -------------------------------------
int      g_day     = 0;        // NY din (yyyymmdd)
bool     g_dayWk   = false;    // ye din Peer-Jumma hai
bool     g_haveRng = false;
double   g_hi      = 0.0;
double   g_lo      = 0.0;
int      g_dayRes  = 0;        // 0 kuch nahi, 1 trade, 2 SL qareeb, 3 lot, 4 sirf dikhaya
datetime g_failT   = 0;
string   g_state   = "shuru ho raha hai";
string   g_lastAct = "abhi kuch nahi";
// din ki ginti (CHHOOTI)
int      g_noBar   = 0;        // range ki candle nahi mili (chhutti / data)
int      g_noBreak = 0;        // range bani, toot nahi hua
int      g_skipStop = 0;       // SL broker ki hadd se qareeb
int      g_skipLot = 0;        // chhoti lot bhi risk se bari
// hisaab
double   g_totR    = 0.0;
string   g_statsTxt = "EA ki band trades: 0";
bool     g_statsDirty = true;
datetime g_lastStats = 0;
// DST ka cache
int      g_dstY    = 0;
datetime g_dstA    = 0;
datetime g_dstB    = 0;

struct TPos
  {
   long     id;
   int      dir;
   double   pin;     // entry qeemat
   double   isl;     // shuru ka SL (comment se)
   double   vin;
   double   vout;
   double   prof;
   double   swap;
   double   comm;
   datetime t0;      // entry waqt
   datetime cl;      // band waqt (0 = khuli)
   int      why;     // 1 = SL, 2 = waqt / haath
  };

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

// Mahine ka n-wan Itwaar, 00:00
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
   int add = (7 - w.day_of_week) % 7;    // pehla Itwaar
   return(AddSec(d1, (long)(add + 7 * (n - 1)) * 86400));
  }

// US garmi ka waqt: March ka doosra Itwaar 07:00 UTC se November ka pehla Itwaar 06:00 UTC tak
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

string HM(datetime t) { return(TimeToString(t, TIME_MINUTES)); }

// NY waqt -> PKT (UTC+5) likhai ke liye
string Pkt(datetime ny)
  {
   datetime srv = NyToServer(ny);
   return(HM(AddSec(srv, (long)(5 - InpServerGMT) * 3600)));
  }

//+------------------------------------------------------------------+
//|  BROKER                                                          |
//+------------------------------------------------------------------+
double Base() { return(AccountInfoDouble(ACCOUNT_BALANCE)); }

double MinStop()
  {
   long a = SymbolInfoInteger(_Symbol, SYMBOL_TRADE_STOPS_LEVEL);
   long b = SymbolInfoInteger(_Symbol, SYMBOL_TRADE_FREEZE_LEVEL);
   long lvl = MathMax(a, b);
   return((double)lvl * SymbolInfoDouble(_Symbol, SYMBOL_POINT));
  }

// Qeemat broker ke tick par gol (warna "invalid stops")
double NormPx(double v)
  {
   double ts = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);
   if(ts > 0.0) v = MathRound(v / ts) * ts;
   return(NormalizeDouble(v, (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS)));
  }

string Px(double v) { return(DoubleToString(v, (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS))); }

// 1% risk ki lot. riskPct = asal risk. 0 = trade nahi.
double LotFor(int dir, double price, double slv, double &riskPct)
  {
   riskPct = 0.0;
   double loss = 0.0;
   ENUM_ORDER_TYPE ot = ORDER_TYPE_BUY;
   if(dir == -1) ot = ORDER_TYPE_SELL;
   if(!OrderCalcProfit(ot, _Symbol, 1.0, price, slv, loss)) return(0.0);
   loss = MathAbs(loss);
   double base = Base();
   if(loss <= 0.0 || base <= 0.0) return(0.0);
   double step = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);
   double mn   = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
   double mx   = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX);
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

// Comment: "ORB <NY din yyyymmdd> <shuru ka SL>"
void ParseCmt(string c, int &day, double &isl)
  {
   day = 0;
   isl = 0.0;
   string p[];
   int n = StringSplit(c, StringGetCharacter(" ", 0), p);
   if(n >= 3 && p[0] == "ORB")
     {
      day = (int)StringToInteger(p[1]);
      isl = StringToDouble(p[2]);
     }
  }

bool FindPos(ulong &tk, int &dir, double &op, double &sl, int &day)
  {
   for(int k = PositionsTotal() - 1; k >= 0; k--)
     {
      ulong t = PositionGetTicket(k);
      if(t == 0) continue;
      if(PositionGetString(POSITION_SYMBOL) != _Symbol) continue;
      if(PositionGetInteger(POSITION_MAGIC) != InpMagic) continue;
      tk  = t;
      dir = 1;
      if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL) dir = -1;
      op  = PositionGetDouble(POSITION_PRICE_OPEN);
      sl  = PositionGetDouble(POSITION_SL);
      double isl = 0.0;
      ParseCmt(PositionGetString(POSITION_COMMENT), day, isl);
      if(day == 0) day = YMD(ServerToNy((datetime)PositionGetInteger(POSITION_TIME)));
      return(true);
     }
   return(false);
  }

// Is NY din par EA pehle trade kar chuka? (restart ke baad yaad)
bool TradedOn(int day)
  {
   datetime now = TimeCurrent();
   if(!HistorySelect(AddSec(now, -3 * 86400), AddSec(now, 60))) return(false);
   int nd = HistoryDealsTotal();
   for(int k = nd - 1; k >= 0; k--)
     {
      ulong t = HistoryDealGetTicket(k);
      if(t == 0) continue;
      if(HistoryDealGetInteger(t, DEAL_MAGIC) != InpMagic) continue;
      if(HistoryDealGetString(t, DEAL_SYMBOL) != _Symbol) continue;
      if(HistoryDealGetInteger(t, DEAL_ENTRY) != DEAL_ENTRY_IN) continue;
      if(YMD(ServerToNy((datetime)HistoryDealGetInteger(t, DEAL_TIME))) == day) return(true);
     }
   return(false);
  }

void Note(string s)
  {
   g_lastAct = TimeToString(TimeCurrent(), TIME_DATE | TIME_MINUTES) + " " + s;
   if(MQLInfoInteger(MQL_TESTER) == 0 || InpVerbose)
      Print("JAS ORB " + EA_BUILD + " | " + g_lastAct);
  }

void ClosePos(ulong tk, string why)
  {
   trade.SetTypeFillingBySymbol(_Symbol);
   if(trade.PositionClose(tk))
     {
      Note(StringFormat("BAND (%s) @ %s", why, Px(trade.ResultPrice())));
      g_statsDirty = true;
     }
   else
     {
      g_failT = TimeCurrent();
      PrintFormat("JAS ORB %s | band nahi hui: %d %s", EA_BUILD, trade.ResultRetcode(), trade.ResultRetcodeDescription());
     }
  }

//+------------------------------------------------------------------+
//|  ENTRY                                                           |
//+------------------------------------------------------------------+
void TryOpen(int d, const MqlTick &t, bool canTrade)
  {
   double slv = g_lo;
   if(d == -1) slv = g_hi;
   slv = NormPx(slv);
   double px = t.ask;
   if(d == -1) px = t.bid;
   string side = Pick(d == 1, "BUY", "SELL");

   // SL broker ki hadd se door hona chahiye (BUY: bid se neeche, SELL: ask se upar)
   double gap = t.bid - slv;
   if(d == -1) gap = slv - t.ask;
   if(gap <= MinStop() + SymbolInfoDouble(_Symbol, SYMBOL_POINT))
     {
      g_dayRes = 2;
      g_skipStop++;
      Note(StringFormat("%s CHHOOTI: SL %s qeemat se bohot qareeb (range %s)", side, Px(slv), Px(g_hi - g_lo)));
      return;
     }
   double rp = 0.0;
   double lots = LotFor(d, px, slv, rp);
   if(lots <= 0.0)
     {
      g_dayRes = 3;
      g_skipLot++;
      Note(StringFormat("%s CHHOOTI: chhoti lot bhi %.1f%% se zyada risk", side, InpMaxRiskPct));
      return;
     }
   if(!canTrade)
     {
      g_dayRes = 4;
      Note(StringFormat("%s HOTA (sirf dikhana) %.2f @ %s | SL %s, risk %.2f%%", side, lots, Px(px), Px(slv), rp));
      return;
     }
   string cmt = StringFormat("ORB %d %s", g_day, Px(slv));
   trade.SetTypeFillingBySymbol(_Symbol);
   bool ok = false;
   if(d == 1) ok = trade.Buy(lots, _Symbol, 0.0, slv, 0.0, cmt);
   else       ok = trade.Sell(lots, _Symbol, 0.0, slv, 0.0, cmt);
   if(ok && trade.ResultRetcode() == TRADE_RETCODE_DONE)
     {
      g_dayRes = 1;
      g_statsDirty = true;
      Note(StringFormat("KHULI %s %.2f @ %s | SL %s, risk %.2f%% | range %s - %s",
                        side, lots, Px(trade.ResultPrice()), Px(slv), rp, Px(g_lo), Px(g_hi)));
     }
   else
     {
      g_failT = TimeCurrent();
      PrintFormat("JAS ORB %s | %s nahi khuli: %d %s", EA_BUILD, side, trade.ResultRetcode(), trade.ResultRetcodeDescription());
     }
  }

//+------------------------------------------------------------------+
//|  HISAAB - band trades R mein                                     |
//+------------------------------------------------------------------+
void Stats(bool doPrint)
  {
   g_statsDirty = false;
   if(!HistorySelect(0, AddSec(TimeCurrent(), 86400))) return;
   int  nd = HistoryDealsTotal();
   TPos ps[];
   int  np = 0;
   for(int k = 0; k < nd; k++)
     {
      ulong t = HistoryDealGetTicket(k);
      if(t == 0) continue;
      if(HistoryDealGetInteger(t, DEAL_MAGIC) != InpMagic) continue;
      if(HistoryDealGetString(t, DEAL_SYMBOL) != _Symbol) continue;
      long id = HistoryDealGetInteger(t, DEAL_POSITION_ID);
      int  x  = -1;
      for(int j = np - 1; j >= 0; j--) if(ps[j].id == id) { x = j; break; }
      double vol = HistoryDealGetDouble(t, DEAL_VOLUME);
      if(HistoryDealGetInteger(t, DEAL_ENTRY) == DEAL_ENTRY_IN)
        {
         if(x >= 0) continue;
         np++;
         ArrayResize(ps, np);
         x = np - 1;
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

   int    n = 0, win = 0, nSL = 0, nTime = 0, noSL = 0, nBuy = 0;
   double sumR = 0.0, sumQ = 0.0, sumP = 0.0, sumN = 0.0, sumC = 0.0, rBuy = 0.0;
   double cum = 0.0, peak = 0.0, dd = 0.0;
   int    pkY = 0, ddA = 0, ddB = 0;
   int    yrY[];
   double yrR[];
   int    yrN[];
   int    ny = 0;
   for(int x = 0; x < np; x++)
     {
      if(ps[x].cl == 0) continue;                 // abhi khuli
      if(ps[x].t0 < InpStatFrom) continue;
      if(ps[x].isl <= 0.0) { noSL++; continue; }  // comment nahi mila - R nahi gin sakte
      ENUM_ORDER_TYPE ot = ORDER_TYPE_BUY;
      if(ps[x].dir == -1) ot = ORDER_TYPE_SELL;
      double risk = 0.0;
      if(!OrderCalcProfit(ot, _Symbol, ps[x].vin, ps[x].pin, ps[x].isl, risk)) { noSL++; continue; }
      risk = MathAbs(risk);
      if(risk <= 0.0) { noSL++; continue; }
      double r = (ps[x].prof + ps[x].swap + ps[x].comm) / risk;
      n++;
      if(r > 0.0) { win++; sumP += r; }
      else        sumN += -r;
      sumR += r;
      sumQ += r * r;
      sumC += (ps[x].swap + ps[x].comm) / risk;
      if(ps[x].why == 1) nSL++;
      else               nTime++;
      if(ps[x].dir == 1) { nBuy++; rBuy += r; }
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
   g_statsTxt = StringFormat("EA ki band trades: %d | jeet %d | Exp %+.3fR (+-%.3f) | kul %+.2fR | girawat %.1fR",
                             n, win, ex, se2, sumR, dd);
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
   bool pass = (n >= 500 && ex - se2 > 0.0 && yPos >= 5);
   int nSell = n - nBuy;
   PrintFormat("JAS ORB %s | %s | SAAL: %s| musbat %d/%d", EA_BUILD, _Symbol, yt, yPos, ny);
   PrintFormat("JAS ORB %s | %s | BAND: SL %d | waqt %d | BUY %d %+.1fR | SELL %d %+.1fR | bina comment %d",
               EA_BUILD, _Symbol, nSL, nTime, nBuy, rBuy, nSell, sumR - rBuy, noSL);
   PrintFormat("JAS ORB %s | %s | DIN: range candle nahi mili %d | range nahi tooti %d | SL bohot qareeb %d | lot bari %d",
               EA_BUILD, _Symbol, g_noBar, g_noBreak, g_skipStop, g_skipLot);
   PrintFormat("JAS ORB %s | %s | KUL: %d trades | jeet %.1f%% | Exp %+.3fR (+-%.3f = 2SE) | PF %.2f | kul %+.2fR | girawat %.1fR (%d-%d) | swap+commission %+.2fR",
               EA_BUILD, _Symbol, n, winPct, ex, se2, pf, sumR, dd, ddA, ddB, sumC);
   PrintFormat("JAS ORB %s | %s | hisaab %s se | QAIDA (pehle se likha, faisla sirf XAUUSD par): trades >= 500, Exp - 2SE > 0 (%+.3f), musbat saal >= 5 -> %s",
               EA_BUILD, _Symbol, TimeToString(InpStatFrom, TIME_DATE), ex - se2,
               Pick(pass, "PASS - agla qadam demo", "FAIL - ORB nahi, settings NAHI badalni"));
  }

//+------------------------------------------------------------------+
//|  PANEL                                                           |
//+------------------------------------------------------------------+
void Panel(bool canTrade, datetime ny, datetime rS, datetime xT)
  {
   string mode = Pick(canTrade, "TRADE CHALU",
                      Pick(InpTrade, "TRADE BAND - Algo Trading hara karein", "SIRF DIKHANA (InpTrade false)"));
   if(MQLInfoInteger(MQL_TESTER) != 0) mode = "TESTER";
   double base = Base();
   string s = "=== JAS ORB  " + EA_BUILD + "  ===  " + mode + "\n";
   s += StringFormat("%s | Risk %.2f%% = %.2f | lot hadd %.2f\n", _Symbol, InpRiskPct, base * InpRiskPct / 100.0, InpMaxLot);
   s += StringFormat("NY waqt %s (PKT %s) | range %s-%s NY (PKT %s) | band %s NY (PKT %s)\n",
                     HM(ny), Pkt(ny), HM(rS), HM(AddSec(rS, 15 * 60)), Pkt(rS), HM(xT), Pkt(xT));
   if(g_haveRng)
      s += StringFormat("Aaj ki range: %s - %s (%s) | BUY > %s | SELL < %s\n", Px(g_lo), Px(g_hi), Px(g_hi - g_lo), Px(g_hi), Px(g_lo));
   s += "Haal: " + g_state + "\n";
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
   datetime ny  = ServerToNy(now);
   int      day = YMD(ny);
   datetime ny0 = (datetime)((long)ny / 86400 * 86400);
   datetime rS  = AddSec(ny0, (long)InpOpenHour * 3600 + (long)InpOpenMin * 60);   // range shuru (NY)
   datetime rE  = AddSec(rS, 15 * 60);                                              // range khatam
   datetime xT  = AddSec(ny0, (long)InpExitHour * 3600 + (long)InpExitMin * 60);   // band ka waqt

   // 1) naya NY din: pichhle din ki ginti, phir aaj ka haal
   if(day != g_day)
     {
      if(g_day != 0 && g_dayWk)
        {
         if(!g_haveRng)        g_noBar++;
         else if(g_dayRes == 0) g_noBreak++;
        }
      MqlDateTime w;
      TimeToStruct(ny, w);
      g_day     = day;
      g_dayWk   = (w.day_of_week >= 1 && w.day_of_week <= 5);
      g_haveRng = false;
      g_hi      = 0.0;
      g_lo      = 0.0;
      g_dayRes  = 0;
      if(TradedOn(day)) g_dayRes = 1;
     }

   // 2) khuli position: din badla ya band ka waqt = band
   ulong  tk = 0;
   int    dir = 0, pday = 0;
   double op = 0.0, sl = 0.0;
   bool   has = FindPos(tk, dir, op, sl, pday);
   if(has && (pday != day || ny >= xT) && now - g_failT > 60)
     {
      if(canTrade) ClosePos(tk, "waqt");
      has = FindPos(tk, dir, op, sl, pday);
     }

   // 3) range: pehli 15m candle band hone ke baad
   if(g_dayWk && !g_haveRng && ny >= rE && ny < xT)
     {
      datetime srvS = NyToServer(rS);
      int sh = iBarShift(_Symbol, PERIOD_M15, srvS, true);
      if(sh >= 0 && iTime(_Symbol, PERIOD_M15, sh) == srvS)
        {
         g_hi = iHigh(_Symbol, PERIOD_M15, sh);
         g_lo = iLow(_Symbol, PERIOD_M15, sh);
         if(g_hi > g_lo) g_haveRng = true;
        }
     }

   // 4) entry: range ka toot, din mein ek dafa
   if(g_dayWk && g_haveRng && g_dayRes == 0 && !has && ny >= rE && ny < xT && now - g_failT > 60)
     {
      MqlTick t;
      if(SymbolInfoTick(_Symbol, t) && t.bid > 0.0)
        {
         if(t.bid > g_hi)      TryOpen(1, t, canTrade);
         else if(t.bid < g_lo) TryOpen(-1, t, canTrade);
        }
      has = FindPos(tk, dir, op, sl, pday);
      if(has) g_dayRes = 1;                 // broker ka jawab jo bhi ho, position hai = aaj ki trade
     }

   // 5) haal ki likhai + panel
   if(tester && MQLInfoInteger(MQL_VISUAL_MODE) == 0) return;
   if(has)
     {
      MqlTick t;
      double rNow = 0.0;
      double risk = MathAbs(op - sl);       // ORB ka SL kabhi nahi sarakta = shuru ka SL
      if(SymbolInfoTick(_Symbol, t) && risk > 0.0)
        {
         if(dir == 1) rNow = (t.bid - op) / risk;
         else         rNow = (op - t.ask) / risk;
        }
      g_state = StringFormat("%s khuli @ %s | SL %s | abhi %+.2fR | %s NY par band",
                             Pick(dir == 1, "BUY", "SELL"), Px(op), Px(sl), rNow, HM(xT));
     }
   else if(!g_dayWk)          g_state = "Hafta / Itwaar - NY band, aaj trade nahi";
   else if(g_dayRes == 1)     g_state = "Aaj ki trade ho chuki - kal";
   else if(g_dayRes == 2)     g_state = "Aaj trade nahi: SL qeemat se bohot qareeb tha";
   else if(g_dayRes == 3)     g_state = "Aaj trade nahi: chhoti lot bhi risk se bari";
   else if(g_dayRes == 4)     g_state = "Aaj ka toot dikha diya (sirf dikhana)";
   else if(ny >= xT)          g_state = "Aaj range nahi tooti - kal";
   else if(ny < rS)           g_state = StringFormat("Range ka intezar: %s NY (PKT %s)", HM(rS), Pkt(rS));
   else if(ny < rE)           g_state = "Range ban rahi hai (pehli 15m candle)";
   else if(!g_haveRng)        g_state = "Range ki candle nahi mili (chhutti ya data)";
   else                       g_state = "Toot ka intezar";
   if(g_statsDirty || now - g_lastStats > 300)
     {
      g_lastStats = now;
      Stats(false);
     }
   Panel(canTrade, ny, rS, xT);
  }

//+------------------------------------------------------------------+
int OnInit()
  {
   if(InpRiskPct <= 0.0 || InpRiskPct > 3.0)
     {
      Print("ERROR: InpRiskPct 0 se 3 ke darmiyan hona chahiye.");
      return(INIT_PARAMETERS_INCORRECT);
     }
   if(InpOpenHour * 60 + InpOpenMin + 15 >= InpExitHour * 60 + InpExitMin)
     {
      Print("ERROR: band ka waqt range ke baad hona chahiye.");
      return(INIT_PARAMETERS_INCORRECT);
     }
   trade.SetExpertMagicNumber(InpMagic);
   trade.SetDeviationInPoints(InpSlippage);
   trade.LogLevel(LOG_LEVEL_ERRORS);
   g_day = 0;
   if(MQLInfoInteger(MQL_TESTER) == 0)
     {
      if(!EventSetTimer(10)) Print("Timer nahi laga - sirf tick par chalega.");
     }
   Comment("=== JAS ORB  " + EA_BUILD + " ===\nshuru ho raha hai...");
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
