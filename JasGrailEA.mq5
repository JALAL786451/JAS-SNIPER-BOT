//====================================================================
//===  BUILD g1   <<< PANEL PAR YAHI NUMBER AANA CHAHIYE >>>
//====================================================================
//+------------------------------------------------------------------+
//|                                                   JasGrailEA.mq5 |
//|  JAS GRAIL - "Holy Grail" (Raschke & Connors, Street Smarts 1995)|
//|  Naye test qaide ki KOSHISH #1 (13 Oct). SIRF TESTER - demo NAHI.|
//|  Ek chart (gold, chart ki TF) se do market: XAUUSD + XAGUSD.      |
//|  User: H1 aur H4 par alag alag chalaye = 4 jodiyan.              |
//|                                                                  |
//|  QAWAID (har market, chart ki TF, sirf BAND candle):             |
//|   1) ADX(14) > 30 (mazboot trend); +DI > -DI = upar, warna neeche |
//|   2) Pullback: band candle EMA20 ko chhoo le (upar: low <= EMA)    |
//|   3) Entry: AGLI candle mein pullback candle ke high ka toot      |
//|      (neeche: low ka toot). Agli candle mein na toota = khatam.  |
//|   4) SL = pullback candle ka low (neeche: high) = 1R              |
//|   5) TP = setup se pehle 20 candle ka high (neeche: low).         |
//|      TP entry se 0.5R se kam door = trade nahi.                   |
//|   6) Har market ek position, 1% risk.                             |
//|  QAIDA (TALAASH 2021-2024): 4 jodi ka ausat Exp > 0, >= 3/4       |
//|  musbat, mila Exp - 2SE > 0 = PASS -> IMTIHAN 2025-aaj ek dafa.   |
//|                                                                  |
//|  NO grid / NO martingale / NO averaging. Har market ek position. |
//+------------------------------------------------------------------+
#property copyright "JAS-SNIPER-BOT"
#property version   "1.00"

#include <Trade\Trade.mqh>
#define EA_BUILD "g1"
#define NM 2

CTrade trade;

input string   InpSymbols  = "XAUUSD,XAGUSD"; // Markets (suffix chart se)
input int      InpAdxLen   = 14;      // ADX length
input double   InpAdxMin   = 30.0;    // ADX is se upar
input int      InpEmaLen   = 20;      // EMA length
input int      InpSwingLen = 20;      // TP: pichhle kitne candle ka high/low
input double   InpMinTpR   = 0.5;     // TP kam az kam itne R
input double   InpRiskPct  = 1.0;     // Risk % balance
input double   InpMaxLot   = 2.00;    // Lot hadd
input int      InpMagic    = 20261015; // Magic
input datetime InpStatFrom = D'2021.01.01'; // Hisaab is tareekh se

string   g_sym[NM];
bool     g_ok[NM];
int      g_adx[NM], g_ema[NM];
datetime g_last[NM];
int      g_dir[NM];        // setup: +1 / -1 / 0
double   g_trig[NM], g_sl[NM], g_tp[NM];
datetime g_setBar[NM];     // setup kis candle par bana (agli candle tak zinda)
int      g_n = 0;

bool HasPos(string s)
  {
   for(int k = PositionsTotal() - 1; k >= 0; k--)
     {
      ulong t = PositionGetTicket(k);
      if(t == 0) continue;
      if(PositionGetString(POSITION_SYMBOL) == s && PositionGetInteger(POSITION_MAGIC) == InpMagic) return(true);
     }
   return(false);
  }

double LotFor(string s, int d, double px, double sl)
  {
   double loss = 0.0;
   if(!OrderCalcProfit(d == 1 ? ORDER_TYPE_BUY : ORDER_TYPE_SELL, s, 1.0, px, sl, loss)) return(0.0);
   loss = MathAbs(loss);
   double bal = AccountInfoDouble(ACCOUNT_BALANCE);
   if(loss <= 0.0 || bal <= 0.0) return(0.0);
   double step = SymbolInfoDouble(s, SYMBOL_VOLUME_STEP);
   double mn   = SymbolInfoDouble(s, SYMBOL_VOLUME_MIN);
   if(step <= 0.0) step = 0.01;
   double lots = MathFloor(bal * InpRiskPct / 100.0 / loss / step + 1e-9) * step;
   if(lots < mn) return(0.0);
   if(lots > InpMaxLot) lots = InpMaxLot;
   return(NormalizeDouble(lots, 2));
  }

// nayi band candle par setup dhoondo
void NewBar(int i)
  {
   string s = g_sym[i];
   g_dir[i] = 0;
   if(HasPos(s)) return;
   double adx[1], pdi[1], mdi[1], ema[1];
   if(CopyBuffer(g_adx[i], 0, 1, 1, adx) != 1) return;
   if(CopyBuffer(g_adx[i], 1, 1, 1, pdi) != 1) return;
   if(CopyBuffer(g_adx[i], 2, 1, 1, mdi) != 1) return;
   if(CopyBuffer(g_ema[i], 0, 1, 1, ema) != 1) return;
   if(adx[0] <= InpAdxMin) return;
   double h = iHigh(s, _Period, 1), l = iLow(s, _Period, 1);
   if(h <= 0.0 || l <= 0.0) return;
   int d = (pdi[0] > mdi[0]) ? 1 : -1;
   if(d == 1 && l > ema[0]) return;     // pullback ne EMA nahi chhui
   if(d == -1 && h < ema[0]) return;
   int hi = iHighest(s, _Period, MODE_HIGH, InpSwingLen, 2);
   int lo = iLowest(s, _Period, MODE_LOW, InpSwingLen, 2);
   if(hi < 0 || lo < 0) return;
   g_dir[i]    = d;
   g_trig[i]   = (d == 1) ? h : l;
   g_sl[i]     = (d == 1) ? l : h;
   g_tp[i]     = (d == 1) ? iHigh(s, _Period, hi) : iLow(s, _Period, lo);
   g_setBar[i] = iTime(s, _Period, 0);
  }

void Check(int i)
  {
   string s = g_sym[i];
   datetime b = iTime(s, _Period, 0);
   if(b == 0) return;
   if(b != g_last[i]) { g_last[i] = b; NewBar(i); }
   int d = g_dir[i];
   if(d == 0) return;
   if(b != g_setBar[i]) { g_dir[i] = 0; return; }   // sirf agli candle
   MqlTick t;
   if(!SymbolInfoTick(s, t)) return;
   double px = (d == 1) ? t.ask : t.bid;
   bool hit = (d == 1) ? (t.ask > g_trig[i]) : (t.bid < g_trig[i]);
   if(!hit) return;
   g_dir[i] = 0;                                     // ek setup = ek koshish
   if(HasPos(s)) return;
   double r = MathAbs(px - g_sl[i]);
   if(r <= 0.0) return;
   if((d == 1 && px <= g_sl[i]) || (d == -1 && px >= g_sl[i])) return;
   if(d * (g_tp[i] - px) < InpMinTpR * r) return;
   int    dg  = (int)SymbolInfoInteger(s, SYMBOL_DIGITS);
   double sl  = NormalizeDouble(g_sl[i], dg);
   double tp  = NormalizeDouble(g_tp[i], dg);
   double lot = LotFor(s, d, px, sl);
   if(lot <= 0.0) return;
   string cmt = "GR " + DoubleToString(sl, dg);
   trade.SetTypeFillingBySymbol(s);
   if(d == 1) trade.Buy(lot, s, 0.0, sl, tp, cmt);
   else       trade.Sell(lot, s, 0.0, sl, tp, cmt);
  }

void OnTick()
  {
   for(int i = 0; i < g_n; i++) if(g_ok[i]) Check(i);
  }

int OnInit()
  {
   string parts[];
   int cnt = StringSplit(InpSymbols, StringGetCharacter(",", 0), parts);
   string suf = "";
   if(cnt > 0)
     {
      string b0 = parts[0];
      StringTrimLeft(b0);
      StringTrimRight(b0);
      if(StringSubstr(_Symbol, 0, StringLen(b0)) == b0) suf = StringSubstr(_Symbol, StringLen(b0));
     }
   g_n = 0;
   for(int k = 0; k < cnt && g_n < NM; k++)
     {
      string b = parts[k];
      StringTrimLeft(b);
      StringTrimRight(b);
      if(StringLen(b) == 0) continue;
      g_sym[g_n]  = b + suf;
      g_ok[g_n]   = SymbolSelect(g_sym[g_n], true);
      g_adx[g_n]  = iADX(g_sym[g_n], _Period, InpAdxLen);
      g_ema[g_n]  = iMA(g_sym[g_n], _Period, InpEmaLen, 0, MODE_EMA, PRICE_CLOSE);
      if(g_adx[g_n] == INVALID_HANDLE || g_ema[g_n] == INVALID_HANDLE) g_ok[g_n] = false;
      if(!g_ok[g_n]) PrintFormat("JAS GRAIL %s | %s nahi mila - chhor diya", EA_BUILD, g_sym[g_n]);
      g_last[g_n] = 0;
      g_dir[g_n]  = 0;
      g_n++;
     }
   trade.SetExpertMagicNumber(InpMagic);
   trade.SetDeviationInPoints(50);
   trade.LogLevel(LOG_LEVEL_ERRORS);
   if(MQLInfoInteger(MQL_TESTER) == 0) Print("DHYAN: JAS GRAIL sirf Tester imtihan ke liye - demo/live NAHI.");
   return(INIT_SUCCEEDED);
  }

void OnDeinit(const int reason) { }

//+------------------------------------------------------------------+
//| TESTER: har market + mila hua, R bina swap                        |
//+------------------------------------------------------------------+
double OnTester()
  {
   if(!HistorySelect(0, TimeCurrent() + 86400)) return(0.0);
   int nd = HistoryDealsTotal();
   int    mN[NM], yN = 0, n = 0;
   double mS[NM], mQ[NM], sum = 0.0, sq = 0.0, sw = 0.0;
   int    yr[];
   double yR[];
   for(int i = 0; i < NM; i++) { mN[i] = 0; mS[i] = 0.0; mQ[i] = 0.0; }
   for(int k = 0; k < nd; k++)
     {
      ulong t = HistoryDealGetTicket(k);
      if(t == 0 || HistoryDealGetInteger(t, DEAL_MAGIC) != InpMagic) continue;
      if(HistoryDealGetInteger(t, DEAL_ENTRY) != DEAL_ENTRY_OUT) continue;
      string s = HistoryDealGetString(t, DEAL_SYMBOL);
      int mi = -1;
      for(int i = 0; i < g_n; i++) if(g_sym[i] == s) mi = i;
      if(mi < 0) continue;
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
         if(StringFind(c, "GR ") == 0) isl = StringToDouble(StringSubstr(c, 3));
         break;
        }
      if(dir == 0 || isl <= 0.0 || t0 < InpStatFrom) continue;
      double risk = 0.0;
      if(!OrderCalcProfit(dir == 1 ? ORDER_TYPE_BUY : ORDER_TYPE_SELL, s, HistoryDealGetDouble(t, DEAL_VOLUME), pin, isl, risk)) continue;
      risk = MathAbs(risk);
      if(risk <= 0.0) continue;
      double r = (HistoryDealGetDouble(t, DEAL_PROFIT) + HistoryDealGetDouble(t, DEAL_COMMISSION) + comIn) / risk;
      sw += HistoryDealGetDouble(t, DEAL_SWAP) / risk;
      mN[mi]++; mS[mi] += r; mQ[mi] += r * r;
      n++; sum += r; sq += r * r;
      MqlDateTime d;
      TimeToStruct((datetime)HistoryDealGetInteger(t, DEAL_TIME), d);
      int yi = -1;
      for(int q = 0; q < yN; q++) if(yr[q] == d.year) yi = q;
      if(yi < 0) { yN++; ArrayResize(yr, yN); ArrayResize(yR, yN); yi = yN - 1; yr[yi] = d.year; yR[yi] = 0.0; }
      yR[yi] += r;
     }
   string tf = EnumToString(_Period);
   string mt = "";
   for(int i = 0; i < g_n; i++)
     {
      double ex = mN[i] > 0 ? mS[i] / mN[i] : 0.0;
      double se = mN[i] > 1 ? 2.0 * MathSqrt(MathMax(mQ[i] - mS[i] * mS[i] / mN[i], 0.0) / (mN[i] - 1)) / MathSqrt((double)mN[i]) : 0.0;
      mt += StringFormat("%s %d trades Exp %+.3fR (+-%.3f)  ", g_sym[i], mN[i], ex, se);
     }
   string ys = "";
   for(int q = 0; q < yN; q++) ys += StringFormat("%d %+.1fR  ", yr[q], yR[q]);
   double exA = n > 0 ? sum / n : 0.0;
   double seA = n > 1 ? 2.0 * MathSqrt(MathMax(sq - sum * sum / n, 0.0) / (n - 1)) / MathSqrt((double)n) : 0.0;
   PrintFormat("JAS GRAIL %s | %s | MARKET: %s", EA_BUILD, tf, mt);
   PrintFormat("JAS GRAIL %s | %s | SAAL: %s", EA_BUILD, tf, ys);
   PrintFormat("JAS GRAIL %s | %s | KUL: %d trades | Exp %+.3fR (+-%.3f = 2SE) bina swap | kul %+.2fR | swap %+.2fR",
               EA_BUILD, tf, n, exA, seA, sum, sw);
   return(sum);
  }
//+------------------------------------------------------------------+
