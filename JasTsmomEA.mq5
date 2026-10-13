//====================================================================
//===  BUILD m1   <<< PANEL PAR YAHI NUMBER AANA CHAHIYE >>>
//====================================================================
//+------------------------------------------------------------------+
//|                                                   JasTsmomEA.mq5 |
//|  JAS TSMOM - Time-Series Momentum (Moskowitz, Ooi & Pedersen,    |
//|  "Time Series Momentum", 2012). Naye test qaide ki KOSHISH #4    |
//|  (13 Oct). SIRF TESTER - demo/live NAHI.                         |
//|  Ek chart se 9 market, MAHANA qaide.                             |
//|                                                                  |
//|  QAWAID (har market):                                            |
//|   1) Har naye mahine (pehle din, din shuru hone ke 2 ghante baad, |
//|      non-crypto Sat/Sun nahi): pichhla mahina band close vs us se |
//|      12 mahine pehle ka close. Upar = BUY, neeche = SELL.         |
//|   2) Purani position band, nayi khuli - har mahina ek trade.      |
//|   3) SL hifazat = 2 x ATR(12) mahana = 1R (lot isi par 1%) -      |
//|      volatility ke hisaab se lot, paper jaisa. TP nahi.          |
//|   4) SL lag jaye to agle mahine tak kuch nahi.                    |
//|  QAIDA (TALAASH 2021-2024): 9 market ka ausat Exp > 0 AUR         |
//|  >= 6/9 musbat AUR mila Exp - 2SE > 0 = PASS -> IMTIHAN 2025-aaj. |
//|                                                                  |
//|  NO grid / NO martingale / NO averaging. Har market ek position. |
//+------------------------------------------------------------------+
#property copyright "JAS-SNIPER-BOT"
#property version   "1.00"

#include <Trade\Trade.mqh>
#define EA_BUILD "m1"
#define NM 10

CTrade trade;

input string   InpSymbols  = "XAUUSD,XAGUSD,BTCUSD,ETHUSD,EURUSD,GBPUSD,AUDUSD,USDJPY,USDCHF"; // Markets (suffix chart se)
input string   InpSuffix   = "auto";  // Suffix - auto = chart ke symbol se
input int      InpLookback = 12;      // Kitne mahine ka rukh
input int      InpAtrLen   = 12;      // ATR (mahana) length
input double   InpSlAtr    = 2.0;     // SL = x mahana ATR
input double   InpRiskPct  = 1.0;     // Risk % balance
input double   InpMaxLot   = 2.00;    // Lot hadd
input int      InpMagic    = 20261017; // Magic
input datetime InpStatFrom = D'2021.01.01'; // Hisaab is tareekh se

string   g_sym[NM];
bool     g_ok[NM], g_crypto[NM];
int      g_atr[NM];
datetime g_mon[NM];
int      g_n = 0;

bool FindPos(string s, ulong &tk)
  {
   for(int k = PositionsTotal() - 1; k >= 0; k--)
     {
      ulong t = PositionGetTicket(k);
      if(t == 0) continue;
      if(PositionGetString(POSITION_SYMBOL) == s && PositionGetInteger(POSITION_MAGIC) == InpMagic) { tk = t; return(true); }
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

int Dow(datetime t)
  {
   MqlDateTime s;
   TimeToStruct(t, s);
   return(s.day_of_week);
  }

void Check(int i)
  {
   string s = g_sym[i];
   datetime m0 = iTime(s, PERIOD_MN1, 0);
   if(m0 == 0 || m0 == g_mon[i]) return;
   if(g_mon[i] == 0) { g_mon[i] = m0; return; }      // test ka pehla (adhoora) mahina chhoro
   datetime now = TimeCurrent();
   datetime d0  = iTime(s, PERIOD_D1, 0);
   if(d0 == 0 || now - d0 < 2 * 3600) return;        // rollover ka spread guzarne do
   if(!g_crypto[i] && (Dow(now) == 0 || Dow(now) == 6)) return;
   MqlTick t;
   if(!SymbolInfoTick(s, t) || now - t.time > 600) return;
   // purani band
   ulong tk = 0;
   while(FindPos(s, tk)) { if(!trade.PositionClose(tk)) return; }
   g_mon[i] = m0;
   double c1  = iClose(s, PERIOD_MN1, 1);
   double c13 = iClose(s, PERIOD_MN1, 1 + InpLookback);
   double a[1];
   if(c1 <= 0.0 || c13 <= 0.0 || c1 == c13) return;
   if(CopyBuffer(g_atr[i], 0, 1, 1, a) != 1 || a[0] <= 0.0) return;
   int    d   = (c1 > c13) ? 1 : -1;
   double px  = (d == 1) ? t.ask : t.bid;
   int    dg  = (int)SymbolInfoInteger(s, SYMBOL_DIGITS);
   double sl  = NormalizeDouble(px - d * InpSlAtr * a[0], dg);
   if(sl <= 0.0) return;
   double lot = LotFor(s, d, px, sl);
   if(lot <= 0.0) return;
   string cmt = "TM " + DoubleToString(sl, dg);
   trade.SetTypeFillingBySymbol(s);
   if(d == 1) trade.Buy(lot, s, 0.0, sl, 0.0, cmt);
   else       trade.Sell(lot, s, 0.0, sl, 0.0, cmt);
  }

void Pass()
  {
   for(int i = 0; i < g_n; i++) if(g_ok[i]) Check(i);
  }

void OnTick()  { Pass(); }
void OnTimer() { Pass(); }

int OnInit()
  {
   string parts[];
   int cnt = StringSplit(InpSymbols, StringGetCharacter(",", 0), parts);
   string suf = "";
   if(InpSuffix != "auto") suf = InpSuffix;
   else
     {
      string known[] = {"XAUUSD", "XAGUSD", "BTCUSD", "ETHUSD", "EURUSD", "GBPUSD", "AUDUSD", "USDJPY", "USDCHF", "US500"};
      bool got = false;
      for(int k = 0; k < cnt && !got; k++)
        {
         string b0 = parts[k];
         StringTrimLeft(b0);
         StringTrimRight(b0);
         if(StringLen(b0) > 0 && StringLen(_Symbol) >= StringLen(b0) && StringSubstr(_Symbol, 0, StringLen(b0)) == b0)
           { suf = StringSubstr(_Symbol, StringLen(b0)); got = true; }
        }
      for(int k = 0; k < ArraySize(known) && !got; k++)
         if(StringLen(_Symbol) >= StringLen(known[k]) && StringSubstr(_Symbol, 0, StringLen(known[k])) == known[k])
           { suf = StringSubstr(_Symbol, StringLen(known[k])); got = true; }
     }
   g_n = 0;
   for(int k = 0; k < cnt && g_n < NM; k++)
     {
      string b = parts[k];
      StringTrimLeft(b);
      StringTrimRight(b);
      if(StringLen(b) == 0) continue;
      g_sym[g_n]    = b + suf;
      g_ok[g_n]     = SymbolSelect(g_sym[g_n], true);
      g_crypto[g_n] = (StringFind(b, "BTC") >= 0 || StringFind(b, "ETH") >= 0);
      g_atr[g_n]    = iATR(g_sym[g_n], PERIOD_MN1, InpAtrLen);
      if(g_atr[g_n] == INVALID_HANDLE) g_ok[g_n] = false;
      g_mon[g_n]    = 0;
      if(!g_ok[g_n]) PrintFormat("JAS TSMOM %s | %s nahi mila - chhor diya", EA_BUILD, g_sym[g_n]);
      else           PrintFormat("JAS TSMOM %s | market %d: %s", EA_BUILD, g_n + 1, g_sym[g_n]);
      g_n++;
     }
   trade.SetExpertMagicNumber(InpMagic);
   trade.SetDeviationInPoints(50);
   trade.LogLevel(LOG_LEVEL_ERRORS);
   EventSetTimer(60);
   if(MQLInfoInteger(MQL_TESTER) == 0) Print("DHYAN: JAS TSMOM sirf Tester imtihan ke liye - demo/live NAHI.");
   return(INIT_SUCCEEDED);
  }

void OnDeinit(const int reason) { EventKillTimer(); }

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
         if(StringFind(c, "TM ") == 0) isl = StringToDouble(StringSubstr(c, 3));
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
   string mt = "";
   int pos = 0, km = 0;
   double exSum = 0.0;
   for(int i = 0; i < g_n; i++)
     {
      double ex = mN[i] > 0 ? mS[i] / mN[i] : 0.0;
      double se = mN[i] > 1 ? 2.0 * MathSqrt(MathMax(mQ[i] - mS[i] * mS[i] / mN[i], 0.0) / (mN[i] - 1)) / MathSqrt((double)mN[i]) : 0.0;
      mt += StringFormat("%s %d Exp %+.3fR (+-%.3f)  ", g_sym[i], mN[i], ex, se);
      if(mN[i] > 0) { km++; exSum += ex; if(ex > 0.0) pos++; }
     }
   string ys = "";
   for(int q = 0; q < yN; q++) ys += StringFormat("%d %+.1fR  ", yr[q], yR[q]);
   double exA = n > 0 ? sum / n : 0.0;
   double seA = n > 1 ? 2.0 * MathSqrt(MathMax(sq - sum * sum / n, 0.0) / (n - 1)) / MathSqrt((double)n) : 0.0;
   double avg = km > 0 ? exSum / km : 0.0;
   int need = (int)MathCeil(km * 2.0 / 3.0);
   bool pass = (km > 0 && avg > 0.0 && pos >= need && exA - seA > 0.0);
   PrintFormat("JAS TSMOM %s | MARKET: %s", EA_BUILD, mt);
   PrintFormat("JAS TSMOM %s | SAAL: %s", EA_BUILD, ys);
   PrintFormat("JAS TSMOM %s | KUL: %d trades | Exp %+.3fR (+-%.3f = 2SE) bina swap | kul %+.2fR | swap %+.2fR", EA_BUILD, n, exA, seA, sum, sw);
   PrintFormat("JAS TSMOM %s | QAIDA: ausat %+.3fR, musbat %d/%d (chahiye %d), mila Exp - 2SE %+.3f -> %s", EA_BUILD, avg, pos, km, need, exA - seA,
               pass ? "PASS - IMTIHAN 2025-aaj" : "FAIL - TSMOM band");
   return(sum);
  }
//+------------------------------------------------------------------+
