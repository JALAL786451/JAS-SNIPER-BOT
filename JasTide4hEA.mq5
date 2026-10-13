//====================================================================
//===  BUILD h1   <<< PANEL PAR YAHI NUMBER AANA CHAHIYE >>>
//====================================================================
//+------------------------------------------------------------------+
//|                                                  JasTide4hEA.mq5 |
//|  JAS TIDE 4H - Kachhua (Tide 1 / Radar r3) ke WAHI qaide, magar   |
//|  toot 4H candles par (user 13 Oct: 'TF 4H se bara nahi, din mein  |
//|  kam az kam ek trade'). Naye test qaide ki KOSHISH #13.           |
//|  SIRF TESTER - demo/live NAHI. Ek chart se 9 market.              |
//|                                                                  |
//|  QAWAID (har market, har nayi H4 candle par, pichhli BAND candle s):|
//|   1) Rukh = D1 EMA50 vs EMA200 (pichhla band din) - Tide wala.     |
//|   2) BUY: close[s] > s se pehle ki 10 H4 candles ka high + rukh     |
//|      upar; SELL ulta. ATR(14, H4) >= 0.10% qeemat (Tide ka 0.25%   |
//|      daily / sqrt(6)). Spread > 0.10R = intezar (Radar EA jaisa).  |
//|   3) SL = entry se 2 x ATR(14, H4) = 1R (server par).              |
//|   4) SL sirf aage: s se pehle ki 5 H4 candles ka low (BUY) / high; |
//|      close us ke paar = band. D1 rukh palta = band. Bahar wali     |
//|      candle par nayi nahi.                                        |
//|   5) Har market ek position, 1% risk. USD hadd NAHI (har market    |
//|      alag naapna - VB/Grail jaisa).                               |
//|  QAIDA (TALAASH 2021-2024): 9 market ka ausat Exp > 0 AUR          |
//|  >= 6/9 musbat AUR mila Exp - 2SE > 0 = PASS -> IMTIHAN 2025-aaj.  |
//|                                                                  |
//|  NO grid / NO martingale / NO averaging. Har market ek position. |
//+------------------------------------------------------------------+
#property copyright "JAS-SNIPER-BOT"
#property version   "1.00"

#include <Trade\Trade.mqh>
#define EA_BUILD "h1"
#define NM 10

CTrade trade;

input string   InpSymbols   = "XAUUSD,XAGUSD,BTCUSD,ETHUSD,EURUSD,GBPUSD,AUDUSD,USDJPY,USDCHF"; // Markets (suffix chart se)
input string   InpSuffix    = "auto";  // Suffix - auto = chart ke symbol se
input int      InpEntryLen  = 10;      // Naali: kitni H4 candle
input int      InpExitLen   = 5;       // SL sarakna: kitni H4 candle
input int      InpAtrLen    = 14;      // ATR (H4)
input double   InpAtrMult   = 2.0;     // Shuru ka SL (x ATR)
input int      InpEmaFast   = 50;      // Rukh EMA fast (D1)
input int      InpEmaSlow   = 200;     // Rukh EMA slow (D1)
input double   InpMinAtrPct = 0.10;    // Kam az kam ATR(H4) % qeemat
input double   InpMaxSpreadR = 0.10;   // Spread 1R ke is hisse se zyada = intezar
input double   InpRiskPct   = 1.0;     // Risk % balance
input double   InpMaxLot    = 1.00;    // Lot hadd
input int      InpMagic     = 20261021; // Magic
input datetime InpStatFrom  = D'2021.01.01'; // Hisaab is tareekh se

string   g_sym[NM];
bool     g_ok[NM];
datetime g_bar[NM];
int      g_atr[NM], g_ef[NM], g_es[NM];
int      g_n = 0;

bool FindPos(string s, ulong &tk, int &dir, double &sl, double &tp)
  {
   for(int k = PositionsTotal() - 1; k >= 0; k--)
     {
      ulong t = PositionGetTicket(k);
      if(t == 0) continue;
      if(PositionGetString(POSITION_SYMBOL) != s || PositionGetInteger(POSITION_MAGIC) != InpMagic) continue;
      tk  = t;
      dir = (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY) ? 1 : -1;
      sl  = PositionGetDouble(POSITION_SL);
      tp  = PositionGetDouble(POSITION_TP);
      return(true);
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

// D1 rukh: pichhle band din ki EMA50 vs EMA200 (1 upar, -1 neeche, 0 pata nahi)
int Rukh(int i)
  {
   double f[], s[];
   if(CopyBuffer(g_ef[i], 0, 1, 1, f) != 1 || CopyBuffer(g_es[i], 0, 1, 1, s) != 1) return(0);
   if(f[0] > s[0]) return(1);
   if(f[0] < s[0]) return(-1);
   return(0);
  }

void NewBar(int i)
  {
   string s  = g_sym[i];
   int    dg = (int)SymbolInfoInteger(s, SYMBOL_DIGITS);
   double c  = iClose(s, PERIOD_H4, 1);
   if(c <= 0.0) return;
   int rk = Rukh(i);
   // --- khuli position: rukh palta / sarakta SL ---
   ulong tk = 0;
   int dir = 0;
   double sl = 0.0, tp = 0.0;
   if(FindPos(s, tk, dir, sl, tp))
     {
      if(rk != 0 && rk != dir) { trade.PositionClose(tk); return; }
      int    lo = iLowest(s, PERIOD_H4, MODE_LOW, InpExitLen, 2);
      int    hi = iHighest(s, PERIOD_H4, MODE_HIGH, InpExitLen, 2);
      if(lo < 0 || hi < 0) return;
      double nsl = (dir == 1) ? MathMax(sl, iLow(s, PERIOD_H4, lo)) : MathMin(sl, iHigh(s, PERIOD_H4, hi));
      if((dir == 1 && c <= nsl) || (dir == -1 && c >= nsl)) { trade.PositionClose(tk); return; }
      nsl = NormalizeDouble(nsl, dg);
      if(MathAbs(nsl - sl) > SymbolInfoDouble(s, SYMBOL_POINT) * 0.5) trade.PositionModify(tk, nsl, tp);
      return;
     }
   // --- khali: toot ---
   if(rk == 0) return;
   int hb = iHighest(s, PERIOD_H4, MODE_HIGH, InpEntryLen, 2);
   int lb = iLowest(s, PERIOD_H4, MODE_LOW, InpEntryLen, 2);
   if(hb < 0 || lb < 0) return;
   double a[];
   if(CopyBuffer(g_atr[i], 0, 1, 1, a) != 1 || a[0] <= 0.0) return;
   if(a[0] / c * 100.0 < InpMinAtrPct) return;
   int d = 0;
   if(rk == 1 && c > iHigh(s, PERIOD_H4, hb))      d = 1;
   else if(rk == -1 && c < iLow(s, PERIOD_H4, lb)) d = -1;
   if(d == 0) return;
   MqlTick t;
   if(!SymbolInfoTick(s, t)) return;
   double r = InpAtrMult * a[0];
   if(t.ask - t.bid > InpMaxSpreadR * r) return;
   double px  = (d == 1) ? t.ask : t.bid;
   double isl = NormalizeDouble(px - d * r, dg);
   double lot = LotFor(s, d, px, isl);
   if(lot <= 0.0) return;
   string cmt = "T4 " + DoubleToString(isl, dg);
   trade.SetTypeFillingBySymbol(s);
   if(d == 1) trade.Buy(lot, s, 0.0, isl, 0.0, cmt);
   else       trade.Sell(lot, s, 0.0, isl, 0.0, cmt);
  }

void Pass()
  {
   for(int i = 0; i < g_n; i++)
     {
      if(!g_ok[i]) continue;
      datetime b0 = iTime(g_sym[i], PERIOD_H4, 0);
      if(b0 == 0 || b0 == g_bar[i]) continue;
      g_bar[i] = b0;
      NewBar(i);
     }
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
      g_bar[g_n]    = iTime(g_sym[g_n], PERIOD_H4, 0);   // pehli adhoori candle par kuch nahi
      g_atr[g_n]    = INVALID_HANDLE;
      g_ef[g_n]     = INVALID_HANDLE;
      g_es[g_n]     = INVALID_HANDLE;
      if(g_ok[g_n])
        {
         g_atr[g_n] = iATR(g_sym[g_n], PERIOD_H4, InpAtrLen);
         g_ef[g_n]  = iMA(g_sym[g_n], PERIOD_D1, InpEmaFast, 0, MODE_EMA, PRICE_CLOSE);
         g_es[g_n]  = iMA(g_sym[g_n], PERIOD_D1, InpEmaSlow, 0, MODE_EMA, PRICE_CLOSE);
         if(g_atr[g_n] == INVALID_HANDLE || g_ef[g_n] == INVALID_HANDLE || g_es[g_n] == INVALID_HANDLE) g_ok[g_n] = false;
        }
      if(!g_ok[g_n]) PrintFormat("JAS TIDE4H %s | %s nahi mila - chhor diya", EA_BUILD, g_sym[g_n]);
      else           PrintFormat("JAS TIDE4H %s | market %d: %s", EA_BUILD, g_n + 1, g_sym[g_n]);
      g_n++;
     }
   trade.SetExpertMagicNumber(InpMagic);
   trade.SetDeviationInPoints(50);
   trade.LogLevel(LOG_LEVEL_ERRORS);
   EventSetTimer(60);
   if(MQLInfoInteger(MQL_TESTER) == 0) Print("DHYAN: JAS TIDE4H sirf Tester imtihan ke liye - demo/live NAHI.");
   return(INIT_SUCCEEDED);
  }

void OnDeinit(const int reason)
  {
   EventKillTimer();
   for(int i = 0; i < g_n; i++)
     {
      if(g_atr[i] != INVALID_HANDLE) IndicatorRelease(g_atr[i]);
      if(g_ef[i] != INVALID_HANDLE)  IndicatorRelease(g_ef[i]);
      if(g_es[i] != INVALID_HANDLE)  IndicatorRelease(g_es[i]);
     }
  }

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
         if(StringFind(c, "T4 ") == 0) isl = StringToDouble(StringSubstr(c, 3));
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
   PrintFormat("JAS TIDE4H %s | MARKET: %s", EA_BUILD, mt);
   PrintFormat("JAS TIDE4H %s | SAAL: %s", EA_BUILD, ys);
   PrintFormat("JAS TIDE4H %s | KUL: %d trades | Exp %+.3fR (+-%.3f = 2SE) bina swap | kul %+.2fR | swap %+.2fR", EA_BUILD, n, exA, seA, sum, sw);
   PrintFormat("JAS TIDE4H %s | QAIDA: ausat %+.3fR, musbat %d/%d (chahiye %d), mila Exp - 2SE %+.3f -> %s", EA_BUILD, avg, pos, km, need, exA - seA,
               pass ? "PASS - IMTIHAN 2025-aaj" : "FAIL - Kachhua 4H band");
   return(sum);
  }
//+------------------------------------------------------------------+
