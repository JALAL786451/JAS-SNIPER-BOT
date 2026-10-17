//===  BUILD o1   <<< PANEL / JOURNAL PAR YAHI NUMBER AANA CHAHIYE >>>
//+------------------------------------------------------------------+
//|                                                    JasOrb5EA.mq5 |
//|  JAS ORB5 - 5 minute Opening Range Breakout.                      |
//|  Research: Zarattini & Aziz (2023) "Can Day Trading Really Be    |
//|  Profitable?" (QQQ, 5m ORB). KOSHISH #21 (17 Oct, user 'D').     |
//|  SIRF TESTER - demo/live NAHI.                                   |
//|                                                                  |
//|  QAWAID (paper jaisa, chart ka symbol - USTECm):                 |
//|   1) NY 09:30 ki pehli M5 candle. Hari = BUY, laal = SELL,       |
//|      doji (close == open) = us din trade nahi.                   |
//|   2) Entry doosri candle ke khulne par (09:35 NY ke baad pehla   |
//|      tick, 09:45 tak - der ho to us din nahi).                   |
//|   3) SL = pehli candle ka doosra kinara (BUY = low) = 1R.        |
//|      TP = 10R. Warna 16:00 NY par band. Din mein ek trade.       |
//|   4) Risk 1% balance, leverage had 4x (paper wali).              |
//|   5) Peer-Jumma, US DST khud. Exness server = GMT+0.            |
//|  QAIDA (TALAASH 2021-2024): trades >= 100 AUR Exp - 2SE > 0     |
//|  AUR aadhe se zyada saal musbat = PASS -> IMTIHAN 2025-aaj.      |
//|                                                                  |
//|  NO grid / NO martingale / NO averaging. Ek position.           |
//+------------------------------------------------------------------+
#property copyright "JAS-SNIPER-BOT"
#property version   "1.00"

#include <Trade\Trade.mqh>
#define EA_BUILD "o1"

CTrade trade;

input int      InpServerGMT = 0;        // Broker server ka GMT farq (Exness = 0)
input double   InpTpR       = 10.0;     // TP (x R) - paper: 10
input double   InpRiskPct   = 1.0;      // Risk % balance - paper: 1
input double   InpMaxLev    = 4.0;      // Leverage had - paper: 4x
input int      InpMagic     = 20261023; // Magic
input datetime InpStatFrom  = D'2021.01.01'; // Hisaab is tareekh se

int      g_done = 0;     // NY din (yyyymmdd) jis ka faisla ho chuka
int      g_dstY = 0;
datetime g_dstA = 0, g_dstB = 0;
int      g_doji = 0, g_noBar = 0, g_late = 0, g_badSl = 0, g_noLot = 0, g_capped = 0;

datetime AddSec(datetime t, long s) { return((datetime)((long)t + s)); }

int YMD(datetime t)
  {
   MqlDateTime s;
   TimeToStruct(t, s);
   return(s.year * 10000 + s.mon * 100 + s.day);
  }

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

bool FindPos(ulong &tk, datetime &ot)
  {
   for(int k = PositionsTotal() - 1; k >= 0; k--)
     {
      ulong t = PositionGetTicket(k);
      if(t == 0) continue;
      if(PositionGetString(POSITION_SYMBOL) != _Symbol || PositionGetInteger(POSITION_MAGIC) != InpMagic) continue;
      tk = t;
      ot = (datetime)PositionGetInteger(POSITION_TIME);
      return(true);
     }
   return(false);
  }

// 1% risk ki lot, phir leverage had (4x equity) - jo chhoti ho
double LotFor(int d, double px, double sl)
  {
   double loss = 0.0, half = 0.0;
   ENUM_ORDER_TYPE ot = (d == 1) ? ORDER_TYPE_BUY : ORDER_TYPE_SELL;
   if(!OrderCalcProfit(ot, _Symbol, 1.0, px, sl, loss)) return(0.0);
   loss = MathAbs(loss);
   double bal = AccountInfoDouble(ACCOUNT_BALANCE);
   double eq  = AccountInfoDouble(ACCOUNT_EQUITY);
   if(loss <= 0.0 || bal <= 0.0) return(0.0);
   double step = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);
   double mn   = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
   double mx   = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX);
   if(step <= 0.0) step = 0.01;
   double lots = bal * InpRiskPct / 100.0 / loss;
   // 1 lot ki poori qeemat (notional): qeemat aadhi hone ka nuqsan x 2
   if(OrderCalcProfit(ORDER_TYPE_BUY, _Symbol, 1.0, px, px * 0.5, half) && half != 0.0)
     {
      double cap = InpMaxLev * eq / (2.0 * MathAbs(half));
      if(lots > cap) { lots = cap; g_capped++; }
     }
   lots = MathFloor(lots / step + 1e-9) * step;
   if(mx > 0.0 && lots > mx) lots = mx;
   if(lots < mn) return(0.0);
   return(NormalizeDouble(lots, 2));
  }

void Check()
  {
   datetime srv = TimeCurrent();
   datetime ny  = ServerToNy(srv);
   MqlDateTime d;
   TimeToStruct(ny, d);
   int mins = d.hour * 60 + d.min;
   datetime mid = AddSec(ny, -(long)(d.hour * 3600 + d.min * 60 + d.sec));
   // 1) band: 16:00 NY ke baad, ya pichhle din ki bachi hui
   ulong tk = 0;
   datetime ot = 0;
   if(FindPos(tk, ot))
     {
      if(mins >= 16 * 60 || YMD(ServerToNy(ot)) != YMD(ny)) trade.PositionClose(tk);
      return;
     }
   // 2) entry: Peer-Jumma, 09:35-09:45 NY, din mein ek faisla
   if(d.day_of_week < 1 || d.day_of_week > 5) return;
   int day = YMD(ny);
   if(g_done == day || mins < 9 * 60 + 35) return;
   g_done = day;
   if(mins >= 9 * 60 + 45) { g_late++; return; }
   datetime b0 = NyToServer(AddSec(mid, 9 * 3600 + 30 * 60));
   int sh = iBarShift(_Symbol, PERIOD_M5, b0, true);
   if(sh < 0 || iTime(_Symbol, PERIOD_M5, sh) != b0) { g_noBar++; return; }
   double o = iOpen(_Symbol, PERIOD_M5, sh), c = iClose(_Symbol, PERIOD_M5, sh);
   double h = iHigh(_Symbol, PERIOD_M5, sh), l = iLow(_Symbol, PERIOD_M5, sh);
   if(c == o) { g_doji++; return; }
   int dir = (c > o) ? 1 : -1;
   MqlTick t;
   if(!SymbolInfoTick(_Symbol, t)) return;
   int    dg  = (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS);
   double pt  = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
   double px  = (dir == 1) ? t.ask : t.bid;
   double sl  = NormalizeDouble(dir == 1 ? l : h, dg);
   double rk  = dir * (px - sl);
   double lvl = (double)SymbolInfoInteger(_Symbol, SYMBOL_TRADE_STOPS_LEVEL) * pt;
   if(rk <= 0.0 || rk <= lvl) { g_badSl++; return; }   // qeemat SL ke paar ya broker ki had se qareeb
   double tp  = NormalizeDouble(px + dir * InpTpR * rk, dg);
   double lot = LotFor(dir, px, sl);
   if(lot <= 0.0) { g_noLot++; return; }
   string cmt = "ORB " + DoubleToString(sl, dg);
   trade.SetTypeFillingBySymbol(_Symbol);
   if(dir == 1) trade.Buy(lot, _Symbol, 0.0, sl, tp, cmt);
   else         trade.Sell(lot, _Symbol, 0.0, sl, tp, cmt);
  }

void OnTick()  { Check(); }
void OnTimer() { Check(); }

int OnInit()
  {
   g_done = YMD(ServerToNy(TimeCurrent()));   // pehla din: faisla nahi (adhoora din)
   trade.SetExpertMagicNumber(InpMagic);
   trade.SetDeviationInPoints(50);
   trade.LogLevel(LOG_LEVEL_ERRORS);
   EventSetTimer(30);
   PrintFormat("JAS ORB5 %s | %s | TP %.1fR, risk %.1f%%, leverage had %.1fx", EA_BUILD, _Symbol, InpTpR, InpRiskPct, InpMaxLev);
   if(MQLInfoInteger(MQL_TESTER) == 0) Print("DHYAN: JAS ORB5 sirf Tester imtihan ke liye - demo/live NAHI.");
   return(INIT_SUCCEEDED);
  }

void OnDeinit(const int reason) { EventKillTimer(); }

//+------------------------------------------------------------------+
//| TESTER: R har trade ke SL se, kharcha samet (bina swap)           |
//+------------------------------------------------------------------+
double OnTester()
  {
   if(!HistorySelect(0, TimeCurrent() + 86400)) return(0.0);
   int nd = HistoryDealsTotal();
   int    n = 0, win = 0, nTp = 0, nSl = 0, nEod = 0, yN = 0;
   double sum = 0.0, sq = 0.0, sw = 0.0, gp = 0.0, gl = 0.0;
   int    yr[];
   double yR[];
   for(int k = 0; k < nd; k++)
     {
      ulong t = HistoryDealGetTicket(k);
      if(t == 0 || HistoryDealGetInteger(t, DEAL_MAGIC) != InpMagic) continue;
      if(HistoryDealGetInteger(t, DEAL_ENTRY) != DEAL_ENTRY_OUT) continue;
      long pid = HistoryDealGetInteger(t, DEAL_POSITION_ID);
      double pin = 0.0, isl = 0.0, comIn = 0.0;
      datetime t0 = 0;
      int dir = 0;
      for(int j = k - 1; j >= 0; j--)
        {
         ulong u = HistoryDealGetTicket(j);
         if(HistoryDealGetInteger(u, DEAL_POSITION_ID) != pid || HistoryDealGetInteger(u, DEAL_ENTRY) != DEAL_ENTRY_IN) continue;
         pin   = HistoryDealGetDouble(u, DEAL_PRICE);
         comIn = HistoryDealGetDouble(u, DEAL_COMMISSION);
         t0    = (datetime)HistoryDealGetInteger(u, DEAL_TIME);
         dir   = (HistoryDealGetInteger(u, DEAL_TYPE) == DEAL_TYPE_BUY) ? 1 : -1;
         string c = HistoryDealGetString(u, DEAL_COMMENT);
         if(StringFind(c, "ORB ") == 0) isl = StringToDouble(StringSubstr(c, 4));
         break;
        }
      if(dir == 0 || isl <= 0.0 || t0 < InpStatFrom) continue;
      double risk = 0.0;
      if(!OrderCalcProfit(dir == 1 ? ORDER_TYPE_BUY : ORDER_TYPE_SELL, _Symbol, HistoryDealGetDouble(t, DEAL_VOLUME), pin, isl, risk)) continue;
      risk = MathAbs(risk);
      if(risk <= 0.0) continue;
      double pl = HistoryDealGetDouble(t, DEAL_PROFIT) + HistoryDealGetDouble(t, DEAL_COMMISSION) + comIn;
      double r  = pl / risk;
      sw += HistoryDealGetDouble(t, DEAL_SWAP) / risk;
      n++; sum += r; sq += r * r;
      if(r > 0.0) { win++; gp += r; } else gl -= r;
      long rsn = HistoryDealGetInteger(t, DEAL_REASON);
      if(rsn == DEAL_REASON_TP) nTp++;
      else if(rsn == DEAL_REASON_SL) nSl++;
      else nEod++;
      MqlDateTime d;
      TimeToStruct((datetime)HistoryDealGetInteger(t, DEAL_TIME), d);
      int yi = -1;
      for(int q = 0; q < yN; q++) if(yr[q] == d.year) yi = q;
      if(yi < 0) { yN++; ArrayResize(yr, yN); ArrayResize(yR, yN); yi = yN - 1; yr[yi] = d.year; yR[yi] = 0.0; }
      yR[yi] += r;
     }
   string ys = "";
   int yPos = 0;
   for(int q = 0; q < yN; q++) { ys += StringFormat("%d %+.1fR  ", yr[q], yR[q]); if(yR[q] > 0.0) yPos++; }
   double ex = n > 0 ? sum / n : 0.0;
   double se = n > 1 ? 2.0 * MathSqrt(MathMax(sq - sum * sum / n, 0.0) / (n - 1)) / MathSqrt((double)n) : 0.0;
   double pf = gl > 0.0 ? gp / gl : 0.0;
   bool pass = (n >= 100 && ex - se > 0.0 && yPos * 2 > yN);
   PrintFormat("JAS ORB5 %s | SAAL: %s", EA_BUILD, ys);
   PrintFormat("JAS ORB5 %s | KUL: %d trades | jeet %.1f%% | PF %.2f | Exp %+.3fR (+-%.3f = 2SE) bina swap | kul %+.2fR | swap %+.2fR",
               EA_BUILD, n, n > 0 ? 100.0 * win / n : 0.0, pf, ex, se, sum, sw);
   PrintFormat("JAS ORB5 %s | BAND: TP %d | SL %d | 16:00 %d", EA_BUILD, nTp, nSl, nEod);
   PrintFormat("JAS ORB5 %s | CHHOOTE DIN: doji %d | candle na mili %d | der %d | SL had se qareeb %d | lot nahi %d | leverage had lagi %d",
               EA_BUILD, g_doji, g_noBar, g_late, g_badSl, g_noLot, g_capped);
   PrintFormat("JAS ORB5 %s | QAIDA: trades %d (chahiye 100), Exp - 2SE %+.3f, musbat saal %d/%d -> %s", EA_BUILD, n, ex - se, yPos, yN,
               pass ? "PASS - IMTIHAN 2025-aaj" : "FAIL - ORB band");
   return(sum);
  }
//+------------------------------------------------------------------+
