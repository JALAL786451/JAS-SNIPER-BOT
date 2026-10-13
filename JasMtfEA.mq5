//====================================================================
//===  BUILD f1   <<< PANEL PAR YAHI NUMBER AANA CHAHIYE >>>
//====================================================================
//+------------------------------------------------------------------+
//|                                                     JasMtfEA.mq5 |
//|  JAS MTF - user ke group ka idea (13 Oct): 1W,1D,4H,3H,2H,1H sab |
//|  bearish = 15m par SELL, sab bullish = BUY.                      |
//|  SIRF TESTER IMTIHAN (XAUUSDm M15, 2021 se). Live/demo NAHI.     |
//|                                                                  |
//|  QAWAID (pehle se likhe, naap se pehle - badalna mana):          |
//|   1) TF bearish = us TF ki aakhri BAND candle ka close EMA20 ke   |
//|      neeche (bullish = upar). TF: W1 D1 H4 H3 H2 H1 + M15.        |
//|   2) Saat ke saat ek taraf = SEEDH. Entry sirf PEHLI M15 candle   |
//|      par jab seedh bani (pichli candle par nahi thi).             |
//|   3) SL 1.5 x ATR(14, M15) = 1R, TP 2R. Ek position. 1% risk.     |
//|  QAIDA: trades >= 100, Exp(bina swap) - 2SE > 0, >= 4/6 saal      |
//|  musbat = PASS. Warna FAIL = idea band, settings NAHI badalni.   |
//|                                                                  |
//|  NO grid / NO martingale / NO averaging. Ek waqt mein ek position.|
//+------------------------------------------------------------------+
#property copyright "JAS-SNIPER-BOT"
#property version   "1.00"

#include <Trade\Trade.mqh>
#define EA_BUILD "f1"
#define NTF 7

CTrade trade;

input group "=== Qawaid (mat badlein) ==="
input int    InpEmaLen   = 20;       // EMA length (har TF)
input int    InpAtrLen   = 14;       // ATR length (M15)
input double InpSlAtr    = 1.5;      // SL = x ATR
input double InpTpR      = 2.0;      // TP = x R
input group "=== Risk ==="
input double InpRiskPct  = 1.0;      // Risk % balance
input double InpMaxLot   = 2.00;     // Lot hadd
input int    InpMagic    = 20261014; // Magic
input datetime InpStatFrom = D'2021.01.01'; // Hisaab is tareekh se

ENUM_TIMEFRAMES g_tf[NTF] = {PERIOD_W1, PERIOD_D1, PERIOD_H4, PERIOD_H3, PERIOD_H2, PERIOD_H1, PERIOD_M15};
string          g_tfn[NTF] = {"W1", "D1", "H4", "H3", "H2", "H1", "M15"};
int      g_ema[NTF];
int      g_atr = INVALID_HANDLE;
datetime g_lastBar = 0;
int      g_prevAlign = 0;
string   g_txt = "";

// +1 bullish, -1 bearish, 0 data nahi
int TfSide(int i)
  {
   double e[1];
   if(CopyBuffer(g_ema[i], 0, 1, 1, e) != 1) return(0);
   double c = iClose(_Symbol, g_tf[i], 1);
   if(c <= 0.0 || e[0] <= 0.0) return(0);
   if(c > e[0]) return(1);
   if(c < e[0]) return(-1);
   return(0);
  }

bool HasPos()
  {
   for(int k = PositionsTotal() - 1; k >= 0; k--)
     {
      ulong t = PositionGetTicket(k);
      if(t == 0) continue;
      if(PositionGetString(POSITION_SYMBOL) == _Symbol && PositionGetInteger(POSITION_MAGIC) == InpMagic) return(true);
     }
   return(false);
  }

double LotFor(int d, double px, double sl)
  {
   double loss = 0.0;
   ENUM_ORDER_TYPE ot = ORDER_TYPE_BUY;
   if(d == -1) ot = ORDER_TYPE_SELL;
   if(!OrderCalcProfit(ot, _Symbol, 1.0, px, sl, loss)) return(0.0);
   loss = MathAbs(loss);
   double bal = AccountInfoDouble(ACCOUNT_BALANCE);
   if(loss <= 0.0 || bal <= 0.0) return(0.0);
   double step = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);
   double mn   = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
   if(step <= 0.0) step = 0.01;
   double lots = MathFloor(bal * InpRiskPct / 100.0 / loss / step + 1e-9) * step;
   if(lots < mn) return(0.0);
   if(lots > InpMaxLot) lots = InpMaxLot;
   return(NormalizeDouble(lots, 2));
  }

void OnTick()
  {
   datetime b = iTime(_Symbol, PERIOD_M15, 0);
   if(b == 0 || b == g_lastBar) return;
   g_lastBar = b;
   int align = 0, s0 = TfSide(0);
   string st = "";
   bool ok = (s0 != 0);
   for(int i = 0; i < NTF; i++)
     {
      int s = TfSide(i);
      st += g_tfn[i] + (s == 1 ? "+ " : s == -1 ? "- " : "? ");
      if(s != s0) ok = false;
     }
   if(ok) align = s0;
   bool fresh = (align != 0 && align != g_prevAlign);
   g_prevAlign = align;
   g_txt = "=== JAS MTF " + EA_BUILD + " === " + st + "| seedh " + IntegerToString(align);
   if(MQLInfoInteger(MQL_TESTER) == 0 || MQLInfoInteger(MQL_VISUAL_MODE) != 0) Comment(g_txt);
   if(!fresh || HasPos()) return;
   double a[1];
   if(CopyBuffer(g_atr, 0, 1, 1, a) != 1 || a[0] <= 0.0) return;
   MqlTick t;
   if(!SymbolInfoTick(_Symbol, t)) return;
   int    d   = align;
   double px  = (d == 1) ? t.ask : t.bid;
   int    dg  = (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS);
   double r   = InpSlAtr * a[0];
   double sl  = NormalizeDouble(px - d * r, dg);
   double tp  = NormalizeDouble(px + d * InpTpR * r, dg);
   double lot = LotFor(d, px, sl);
   if(lot <= 0.0) return;
   string cmt = "MTF " + DoubleToString(sl, dg);
   trade.SetTypeFillingBySymbol(_Symbol);
   if(d == 1) trade.Buy(lot, _Symbol, 0.0, sl, tp, cmt);
   else       trade.Sell(lot, _Symbol, 0.0, sl, tp, cmt);
  }

int OnInit()
  {
   for(int i = 0; i < NTF; i++)
     {
      g_ema[i] = iMA(_Symbol, g_tf[i], InpEmaLen, 0, MODE_EMA, PRICE_CLOSE);
      if(g_ema[i] == INVALID_HANDLE) { Print("ERROR: EMA handle ", g_tfn[i]); return(INIT_FAILED); }
     }
   g_atr = iATR(_Symbol, PERIOD_M15, InpAtrLen);
   if(g_atr == INVALID_HANDLE) { Print("ERROR: ATR handle"); return(INIT_FAILED); }
   trade.SetExpertMagicNumber(InpMagic);
   trade.SetDeviationInPoints(50);
   trade.LogLevel(LOG_LEVEL_ERRORS);
   if(MQLInfoInteger(MQL_TESTER) == 0)
      Print("DHYAN: JAS MTF sirf Tester imtihan ke liye hai - live/demo par na lagayein.");
   return(INIT_SUCCEEDED);
  }

void OnDeinit(const int reason) { Comment(""); }

//+------------------------------------------------------------------+
//| TESTER: band trades R mein (bina swap), saal, QAIDA               |
//+------------------------------------------------------------------+
double OnTester()
  {
   if(!HistorySelect(0, TimeCurrent() + 86400)) return(0.0);
   int nd = HistoryDealsTotal();
   int n = 0, win = 0, yN = 0;
   double sum = 0.0, sq = 0.0, sw = 0.0, gp = 0.0, gl = 0.0;
   double cum = 0.0, pk = 0.0, dd = 0.0;
   int    yr[];
   double yR[];
   int    yC[];
   for(int k = 0; k < nd; k++)
     {
      ulong t = HistoryDealGetTicket(k);
      if(t == 0) continue;
      if(HistoryDealGetInteger(t, DEAL_MAGIC) != InpMagic) continue;
      if(HistoryDealGetInteger(t, DEAL_ENTRY) != DEAL_ENTRY_OUT) continue;
      long pid = HistoryDealGetInteger(t, DEAL_POSITION_ID);
      // entry deal dhoondo (price, SL comment, waqt)
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
         if(StringFind(c, "MTF ") == 0) isl = StringToDouble(StringSubstr(c, 4));
         break;
        }
      if(dir == 0 || isl <= 0.0 || t0 < InpStatFrom) continue;
      double vol = HistoryDealGetDouble(t, DEAL_VOLUME);
      double risk = 0.0;
      if(!OrderCalcProfit(dir == 1 ? ORDER_TYPE_BUY : ORDER_TYPE_SELL, _Symbol, vol, pin, isl, risk)) continue;
      risk = MathAbs(risk);
      if(risk <= 0.0) continue;
      double r = (HistoryDealGetDouble(t, DEAL_PROFIT) + HistoryDealGetDouble(t, DEAL_COMMISSION) + comIn) / risk;   // bina swap
      sw += HistoryDealGetDouble(t, DEAL_SWAP) / risk;
      n++;
      sum += r;
      sq  += r * r;
      if(r > 0.0) { win++; gp += r; } else gl -= r;
      cum += r;
      if(cum > pk) pk = cum;
      if(pk - cum > dd) dd = pk - cum;
      MqlDateTime s;
      TimeToStruct((datetime)HistoryDealGetInteger(t, DEAL_TIME), s);
      int yi = -1;
      for(int q = 0; q < yN; q++) if(yr[q] == s.year) { yi = q; break; }
      if(yi < 0) { yN++; ArrayResize(yr, yN); ArrayResize(yR, yN); ArrayResize(yC, yN); yi = yN - 1; yr[yi] = s.year; yR[yi] = 0.0; yC[yi] = 0; }
      yR[yi] += r;
      yC[yi]++;
     }
   double ex = (n > 0) ? sum / n : 0.0;
   double se2 = (n > 1) ? 2.0 * MathSqrt(MathMax(sq - sum * sum / n, 0.0) / (n - 1)) / MathSqrt((double)n) : 0.0;
   string ys = "";
   int yP = 0;
   for(int q = 0; q < yN; q++) { ys += StringFormat("%d %+.1fR (%d)  ", yr[q], yR[q], yC[q]); if(yR[q] > 0.0) yP++; }
   PrintFormat("JAS MTF %s | %s | SAAL: %s| musbat %d/%d", EA_BUILD, _Symbol, ys, yP, yN);
   PrintFormat("JAS MTF %s | %s | KUL: %d trades | jeet %.1f%% | Exp %+.3fR (+-%.3f = 2SE) bina swap | PF %.2f | kul %+.2fR | girawat %.1fR | swap %+.2fR",
               EA_BUILD, _Symbol, n, n > 0 ? 100.0 * win / n : 0.0, ex, se2, gl > 0 ? gp / gl : 0.0, sum, dd, sw);
   bool pass = (n >= 100 && ex - se2 > 0.0 && yP >= 4);
   PrintFormat("JAS MTF %s | QAIDA (trades >= 100, Exp - 2SE > 0, >= 4 saal musbat): %s", EA_BUILD, pass ? "PASS" : "FAIL - idea band, settings NAHI badalni");
   return(sum);
  }
//+------------------------------------------------------------------+
