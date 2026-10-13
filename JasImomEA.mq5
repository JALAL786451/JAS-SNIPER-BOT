//====================================================================
//===  BUILD m1   <<< PANEL PAR YAHI NUMBER AANA CHAHIYE >>>
//====================================================================
//+------------------------------------------------------------------+
//|                                                    JasImomEA.mq5 |
//|  JAS IMOM - Intraday Momentum (Gao, Han, Li, Zhou 2018, Journal   |
//|  of Financial Economics "Market intraday momentum"; BTC par bhi   |
//|  Shen, Urquhart, Wang 2022). Naye test qaide ki KOSHISH #9         |
//|  (13 Oct, user 'D'). SIRF TESTER - demo/live NAHI.                |
//|  Ek chart (BTCUSDm behtar - 24/7 ticks) se 9 market, M30 qaide.   |
//|                                                                  |
//|  QAWAID (har market, sirf Peer-Jumma, NY waqt - DST khud):        |
//|   1) r1 = qeemat 10:00 NY / pichhle kaam ke din ki 16:00 NY - 1    |
//|      (Gao: raat + pehla aadha ghanta). Jumma -> Peer.             |
//|   2) 15:30 NY par r1 ke rukh mein trade (r1 > 0 BUY, < 0 SELL).    |
//|   3) 16:00 NY par band. SL = 1 x ATR(14) M30 (pichhli band        |
//|      candle) = 1R. TP nahi. Din mein ek.                          |
//|   4) Data na mile (chhutti / gap > 10 min) = us din trade nahi.   |
//|   5) Har market ek position, 1% risk.                             |
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

input string   InpSymbols   = "XAUUSD,XAGUSD,BTCUSD,ETHUSD,EURUSD,GBPUSD,AUDUSD,USDJPY,USDCHF"; // Markets (suffix chart se)
input string   InpSuffix    = "auto";  // Suffix - auto = chart ke symbol se
input int      InpServerGMT = 0;       // Broker server ka GMT farq (Exness = 0)
input double   InpSlAtr     = 1.0;     // SL: x ATR(14) M30
input double   InpRiskPct   = 1.0;     // Risk % balance
input double   InpMaxLot    = 2.00;    // Lot hadd
input int      InpMagic     = 20261019; // Magic
input datetime InpStatFrom  = D'2021.01.01'; // Hisaab is tareekh se

string   g_sym[NM];
bool     g_ok[NM];
int      g_atr[NM];
int      g_done[NM];   // NY din (yyyymmdd) jis par entry ki koshish ho chuki
int      g_n = 0;
int      g_dstY = 0;
datetime g_dstA = 0, g_dstB = 0;

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

// NY din ki 00:00 + ghanta:minute -> server waqt
datetime NyAt(datetime nyMidnight, int h, int m) { return(NyToServer(AddSec(nyMidnight, (long)h * 3600 + m * 60))); }

// M1 candle jo server waqt t par shuru hui us ka close (10 min se zyada farq = na mila)
bool PriceAt(string s, datetime t, double &px)
  {
   int sh = iBarShift(s, PERIOD_M1, t, false);
   if(sh < 0) return(false);
   datetime bt = iTime(s, PERIOD_M1, sh);
   if(bt == 0 || bt > t || t - bt > 600) return(false);
   px = iClose(s, PERIOD_M1, sh);
   return(px > 0.0);
  }

bool FindPos(string s, ulong &tk, datetime &ot)
  {
   for(int k = PositionsTotal() - 1; k >= 0; k--)
     {
      ulong t = PositionGetTicket(k);
      if(t == 0) continue;
      if(PositionGetString(POSITION_SYMBOL) != s || PositionGetInteger(POSITION_MAGIC) != InpMagic) continue;
      tk = t;
      ot = (datetime)PositionGetInteger(POSITION_TIME);
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

void Check(int i, datetime srv)
  {
   string s = g_sym[i];
   datetime ny = ServerToNy(srv);
   MqlDateTime d;
   TimeToStruct(ny, d);
   int mins = d.hour * 60 + d.min;
   datetime mid = AddSec(ny, -(long)(d.hour * 3600 + d.min * 60 + d.sec));
   // 1) band: 16:00 NY ke baad, ya pichhle din ki bachi hui
   ulong tk = 0;
   datetime ot = 0;
   if(FindPos(s, tk, ot))
     {
      if(mins >= 16 * 60 || YMD(ServerToNy(ot)) != YMD(ny)) trade.PositionClose(tk);
      return;
     }
   // 2) entry: Peer-Jumma, 15:30-15:45 NY, din mein ek
   if(d.day_of_week < 1 || d.day_of_week > 5) return;
   if(mins < 15 * 60 + 30 || mins >= 15 * 60 + 45) return;
   int day = YMD(ny);
   if(g_done[i] == day) return;
   g_done[i] = day;
   double p10 = 0.0, pPrev = 0.0;
   if(!PriceAt(s, NyAt(mid, 9, 59), p10)) return;
   int back = (d.day_of_week == 1) ? 3 : 1;
   if(!PriceAt(s, NyAt(AddSec(mid, -(long)back * 86400), 15, 59), pPrev)) return;
   double r1 = p10 / pPrev - 1.0;
   if(r1 == 0.0) return;
   int dir = r1 > 0.0 ? 1 : -1;
   double a[];
   if(CopyBuffer(g_atr[i], 0, 1, 1, a) != 1 || a[0] <= 0.0) return;
   MqlTick t;
   if(!SymbolInfoTick(s, t)) return;
   double px  = (dir == 1) ? t.ask : t.bid;
   int    dg  = (int)SymbolInfoInteger(s, SYMBOL_DIGITS);
   double sl  = NormalizeDouble(px - dir * InpSlAtr * a[0], dg);
   double lot = LotFor(s, dir, px, sl);
   if(lot <= 0.0) return;
   string cmt = "IM " + DoubleToString(sl, dg);
   trade.SetTypeFillingBySymbol(s);
   if(dir == 1) trade.Buy(lot, s, 0.0, sl, 0.0, cmt);
   else         trade.Sell(lot, s, 0.0, sl, 0.0, cmt);
  }

void Pass()
  {
   datetime srv = TimeCurrent();
   for(int i = 0; i < g_n; i++) if(g_ok[i]) Check(i, srv);
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
      g_sym[g_n]  = b + suf;
      g_ok[g_n]   = SymbolSelect(g_sym[g_n], true);
      g_done[g_n] = YMD(ServerToNy(TimeCurrent()));   // pehla din: entry nahi (adhoora din)
      g_atr[g_n]  = INVALID_HANDLE;
      if(g_ok[g_n])
        {
         g_atr[g_n] = iATR(g_sym[g_n], PERIOD_M30, 14);
         if(g_atr[g_n] == INVALID_HANDLE) g_ok[g_n] = false;
        }
      if(!g_ok[g_n]) PrintFormat("JAS IMOM %s | %s nahi mila - chhor diya", EA_BUILD, g_sym[g_n]);
      else           PrintFormat("JAS IMOM %s | market %d: %s", EA_BUILD, g_n + 1, g_sym[g_n]);
      g_n++;
     }
   trade.SetExpertMagicNumber(InpMagic);
   trade.SetDeviationInPoints(50);
   trade.LogLevel(LOG_LEVEL_ERRORS);
   EventSetTimer(30);
   if(MQLInfoInteger(MQL_TESTER) == 0) Print("DHYAN: JAS IMOM sirf Tester imtihan ke liye - demo/live NAHI.");
   return(INIT_SUCCEEDED);
  }

void OnDeinit(const int reason)
  {
   EventKillTimer();
   for(int i = 0; i < g_n; i++) if(g_atr[i] != INVALID_HANDLE) IndicatorRelease(g_atr[i]);
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
         if(StringFind(c, "IM ") == 0) isl = StringToDouble(StringSubstr(c, 3));
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
   PrintFormat("JAS IMOM %s | MARKET: %s", EA_BUILD, mt);
   PrintFormat("JAS IMOM %s | SAAL: %s", EA_BUILD, ys);
   PrintFormat("JAS IMOM %s | KUL: %d trades | Exp %+.3fR (+-%.3f = 2SE) bina swap | kul %+.2fR | swap %+.2fR", EA_BUILD, n, exA, seA, sum, sw);
   PrintFormat("JAS IMOM %s | QAIDA: ausat %+.3fR, musbat %d/%d (chahiye %d), mila Exp - 2SE %+.3f -> %s", EA_BUILD, avg, pos, km, need, exA - seA,
               pass ? "PASS - IMTIHAN 2025-aaj" : "FAIL - Intraday Momentum band");
   return(sum);
  }
//+------------------------------------------------------------------+
