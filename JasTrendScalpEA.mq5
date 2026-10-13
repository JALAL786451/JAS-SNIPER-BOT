//====================================================================
//===  BUILD s1   <<< PANEL PAR YAHI NUMBER AANA CHAHIYE >>>
//====================================================================
//+------------------------------------------------------------------+
//|                                              JasTrendScalpEA.mq5 |
//|  JAS 15M SCALP - user ka apna idea (13 Oct, KOSHISH #12):        |
//|  15m par rukh ke saath 0.01, $1 par faida band, $2 par nuqsan.    |
//|  SIRF TESTER - demo/live NAHI (pehle se likha qaida PASS ho to    |
//|  demo ka qaida alag likha jayega).                               |
//|                                                                  |
//|  QAWAID (chart ka symbol, M15):                                  |
//|   1) Rukh = pichhli BAND M15 candle par EMA20 vs EMA50            |
//|      (user ki METHOD.md wali EMA 20/50). Upar = BUY, neeche = SELL.|
//|   2) Har nayi M15 candle ke shuru mein, agar koi position nahi:   |
//|      rukh ke saath 0.01 (lot kabhi 0.01 se zyada nahi).           |
//|   3) TP = entry se $1 qeemat, SL = entry se $2 qeemat (server     |
//|      par). Bas - koi hedge, koi doosri lot nahi.                  |
//|  Hisaab: 1R = $2 (SL). Breakeven ke liye jeet > 66.7% chahiye.    |
//|  QAIDA (TALAASH 2021-2024): trades >= 100 AUR Exp - 2SE > 0       |
//|  (bina swap) AUR >= 3/4 saal musbat = PASS -> IMTIHAN 2025-aaj.   |
//|                                                                  |
//|  NO grid / NO martingale / NO averaging. Ek waqt mein ek 0.01.    |
//+------------------------------------------------------------------+
#property copyright "JAS-SNIPER-BOT"
#property version   "1.00"

#include <Trade\Trade.mqh>
#define EA_BUILD "s1"

CTrade trade;

input double   InpLot      = 0.01;    // Lot (0.01 se zyada NAHI)
input double   InpTpUsd    = 1.0;     // Faida band: $ qeemat ki harkat
input double   InpSlUsd    = 2.0;     // Nuqsan band: $ qeemat ki harkat
input int      InpEmaFast  = 20;      // Rukh EMA fast
input int      InpEmaSlow  = 50;      // Rukh EMA slow
input int      InpMagic    = 20261020; // Magic
input datetime InpStatFrom = D'2021.01.01'; // Hisaab is tareekh se

int      g_ef = INVALID_HANDLE, g_es = INVALID_HANDLE;
datetime g_bar = 0;

bool HavePos()
  {
   for(int k = PositionsTotal() - 1; k >= 0; k--)
     {
      ulong t = PositionGetTicket(k);
      if(t == 0) continue;
      if(PositionGetString(POSITION_SYMBOL) == _Symbol && PositionGetInteger(POSITION_MAGIC) == InpMagic) return(true);
     }
   return(false);
  }

void OnTick()
  {
   datetime b0 = iTime(_Symbol, PERIOD_M15, 0);
   if(b0 == 0 || b0 == g_bar) return;
   g_bar = b0;                                    // sirf nayi M15 candle par
   if(HavePos()) return;
   double f[], s[];
   if(CopyBuffer(g_ef, 0, 1, 1, f) != 1 || CopyBuffer(g_es, 0, 1, 1, s) != 1) return;
   if(f[0] == s[0]) return;
   int d = f[0] > s[0] ? 1 : -1;
   MqlTick t;
   if(!SymbolInfoTick(_Symbol, t)) return;
   int    dg  = (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS);
   double px  = d == 1 ? t.ask : t.bid;
   double tp  = NormalizeDouble(px + d * InpTpUsd, dg);
   double sl  = NormalizeDouble(px - d * InpSlUsd, dg);
   double lot = MathMin(InpLot, 0.01);
   string cmt = "SC " + DoubleToString(sl, dg);
   trade.SetTypeFillingBySymbol(_Symbol);
   if(d == 1) trade.Buy(lot, _Symbol, 0.0, sl, tp, cmt);
   else       trade.Sell(lot, _Symbol, 0.0, sl, tp, cmt);
  }

int OnInit()
  {
   if(InpLot > 0.01) Print("JAS SCALP: InpLot 0.01 se zyada tha - 0.01 hi chalegi.");
   g_ef = iMA(_Symbol, PERIOD_M15, InpEmaFast, 0, MODE_EMA, PRICE_CLOSE);
   g_es = iMA(_Symbol, PERIOD_M15, InpEmaSlow, 0, MODE_EMA, PRICE_CLOSE);
   if(g_ef == INVALID_HANDLE || g_es == INVALID_HANDLE) return(INIT_FAILED);
   trade.SetExpertMagicNumber(InpMagic);
   trade.SetDeviationInPoints(50);
   trade.LogLevel(LOG_LEVEL_ERRORS);
   g_bar = iTime(_Symbol, PERIOD_M15, 0);        // pehli adhoori candle par entry nahi
   if(MQLInfoInteger(MQL_TESTER) == 0) Print("DHYAN: JAS SCALP sirf Tester imtihan ke liye - demo/live NAHI.");
   return(INIT_SUCCEEDED);
  }

void OnDeinit(const int reason)
  {
   if(g_ef != INVALID_HANDLE) IndicatorRelease(g_ef);
   if(g_es != INVALID_HANDLE) IndicatorRelease(g_es);
  }

//+------------------------------------------------------------------+
//| TESTER: R (1R = SL), jeet %, saal, QAIDA                          |
//+------------------------------------------------------------------+
double OnTester()
  {
   if(!HistorySelect(0, TimeCurrent() + 86400)) return(0.0);
   int nd = HistoryDealsTotal();
   int    n = 0, w = 0, yN = 0;
   double sum = 0.0, sq = 0.0, sw = 0.0, money = 0.0;
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
         if(StringFind(c, "SC ") == 0) isl = StringToDouble(StringSubstr(c, 3));
         break;
        }
      if(dir == 0 || isl <= 0.0 || t0 < InpStatFrom) continue;
      double risk = 0.0;
      if(!OrderCalcProfit(dir == 1 ? ORDER_TYPE_BUY : ORDER_TYPE_SELL, _Symbol, HistoryDealGetDouble(t, DEAL_VOLUME), pin, isl, risk)) continue;
      risk = MathAbs(risk);
      if(risk <= 0.0) continue;
      double pl = HistoryDealGetDouble(t, DEAL_PROFIT) + HistoryDealGetDouble(t, DEAL_COMMISSION) + comIn;
      double r  = pl / risk;
      money += pl;
      sw    += HistoryDealGetDouble(t, DEAL_SWAP) / risk;
      n++; sum += r; sq += r * r;
      if(r > 0.0) w++;
      MqlDateTime d;
      TimeToStruct((datetime)HistoryDealGetInteger(t, DEAL_TIME), d);
      int yi = -1;
      for(int q = 0; q < yN; q++) if(yr[q] == d.year) yi = q;
      if(yi < 0) { yN++; ArrayResize(yr, yN); ArrayResize(yR, yN); yi = yN - 1; yr[yi] = d.year; yR[yi] = 0.0; }
      yR[yi] += r;
     }
   string ys = "";
   int ypos = 0;
   for(int q = 0; q < yN; q++) { ys += StringFormat("%d %+.1fR  ", yr[q], yR[q]); if(yR[q] > 0.0) ypos++; }
   double ex = n > 0 ? sum / n : 0.0;
   double se = n > 1 ? 2.0 * MathSqrt(MathMax(sq - sum * sum / n, 0.0) / (n - 1)) / MathSqrt((double)n) : 0.0;
   double need = InpSlUsd / (InpSlUsd + InpTpUsd) * 100.0;
   int yNeed = (int)MathCeil(yN * 3.0 / 4.0);
   bool pass = (n >= 100 && ex - se > 0.0 && yN > 0 && ypos >= yNeed);
   PrintFormat("JAS SCALP %s | SAAL: %s", EA_BUILD, ys);
   PrintFormat("JAS SCALP %s | KUL: %d trades | jeet %.1f%% (breakeven %.1f%%) | Exp %+.3fR (+-%.3f = 2SE) bina swap | kul %+.1fR = %+.2f paisa | swap %+.2fR",
               EA_BUILD, n, n > 0 ? 100.0 * w / n : 0.0, need, ex, se, sum, money, sw);
   PrintFormat("JAS SCALP %s | QAIDA: trades %d (>=100), Exp - 2SE %+.3f (>0), musbat saal %d/%d (chahiye %d) -> %s", EA_BUILD, n, ex - se, ypos, yN, yNeed,
               pass ? "PASS - IMTIHAN 2025-aaj" : "FAIL - idea band");
   return(sum);
  }
//+------------------------------------------------------------------+
