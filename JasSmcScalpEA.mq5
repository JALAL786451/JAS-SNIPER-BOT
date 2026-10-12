//====================================================================
//===  BUILD m1   <<< PANEL PAR YAHI NUMBER AANA CHAHIYE >>>
//====================================================================
//+------------------------------------------------------------------+
//|                                                JasSmcScalpEA.mq5 |
//|  SMC Coach Scalp sc6.2 (strategies/smc_coach_scalp_test.pine) ke |
//|  qaide MT5 par - SIRF zyada data par EK imtihan ke liye (12 Oct).|
//|  TradingView 15m par sirf 3 mahine data tha (+0.122R +-0.279).   |
//|                                                                  |
//|  Qaide Pine jaise (mat badlein):                                 |
//|   - Swing pivot 3/3, BOS/CHOCH sirf close se, ek swing = ek toot |
//|   - Toot par ulta swing = zone (+-0.15 ATR), aakhri 10           |
//|   - Rukh: EMA50 > EMA100 aur ADX(14) >= 18 (ulta = SELL)         |
//|   - 4H YA 1D ka rukh saath (pichli band candle)                  |
//|   - DXY EMA8-EMA21 ulta (gold BUY = DXY neeche)                  |
//|   - Supertrend(10, 3) saath                                      |
//|   - Ishara A: zone touch + 3 candle mein toot + rukh + (FVG/LGB) |
//|   - Ishara B: toot + rukh + close swing ke 0.1 ATR paar + (bari  |
//|     candle >= 0.95 ATR ya FVG/LGB); ya 20 candle mein EMA50 retest|
//|   - Dono taraf ishara = kuch nahi                                |
//|   - Entry agli candle par, SL 1.5 ATR, TP 2R, ulta ishara = band |
//|   - 1% risk. Ek waqt mein ek position.                           |
//|                                                                  |
//|  QAIDA (pehle se likha, Pine wala): XAUUSD 15m, trades >= 100 aur|
//|  Exp - 2SE > 0 = PASS. Hisaab InpStatFrom se.                    |
//|  Journal mein nateeja: Tester bina Visual mode.                  |
//|                                                                  |
//|  Pine se farq (jaan boojh kar nahi, majboori): EMA/RMA ka shuru  |
//|  ka beej (warmup ke baad mit jata hai), broker ka data/spread,   |
//|  DXY symbol broker par na ho to filter BAND (Journal mein likha).|
//|                                                                  |
//|  NO grid / NO martingale / NO averaging / NO hedge.              |
//+------------------------------------------------------------------+
#property copyright "JAS-SNIPER-BOT"
#property version   "1.00"

#include <Trade\Trade.mqh>
#define EA_BUILD "m1"

CTrade trade;

string Pick(bool c, string a, string b) { if(c) return(a); return(b); }

//--------------------------- INPUTS -----------------------------------
input group "=== 1 - Qaide (Pine jaise - mat badlein) ==="
input int    InpPivot      = 3;        // Swing pivot L/R
input int    InpMaxZones   = 10;       // Aakhri kitne zone
input double InpZonePad    = 0.15;     // Zone padding (x ATR)
input int    InpStructLB   = 3;        // Toot kitni candle pehle tak
input int    InpEmaFast    = 50;       // EMA fast
input int    InpEmaSlow    = 100;      // EMA slow
input double InpAdxMin     = 18.0;     // ADX kam az kam
input double InpBrkBuf     = 0.10;     // Breakout buffer (x ATR)
input double InpImpulse    = 0.95;     // Bari candle >= ATR x
input double InpRetestTol  = 0.45;     // Retest tolerance (x ATR)
input int    InpRetestWin  = 20;       // Retest window (candle)
input int    InpStPeriod   = 10;       // Supertrend ATR
input double InpStMult     = 3.0;      // Supertrend multiplier
input double InpSlAtr      = 1.5;      // SL (x ATR14)
input double InpTpR        = 2.0;      // TP (R)
input string InpDxy        = "";       // DXY symbol ("" = khud dhoondo)

input group "=== 2 - Risk ==="
input bool   InpTrade      = false;    // TRADE KARE? false = sirf dikhaye (Tester mein hamesha trade)
input double InpRiskPct    = 1.0;      // Har trade ka risk (% balance)
input double InpMaxRiskPct = 2.0;      // Sab se chhoti lot ka risk is se zyada = trade nahi
input double InpMaxLot     = 5.00;     // Lot ki hadd (hifazat)

input group "=== 3 - Amal ==="
input int    InpWarm       = 3000;     // Shuru mein kitni purani candles se haal banaye
input int    InpSlippage   = 50;       // Max slippage (points)
input int    InpMagic      = 20261013; // Magic number
input datetime InpStatFrom = D'2019.01.01'; // Hisaab is tareekh se

//--------------------------- ENGINE -----------------------------------
// EMA fast/slow + Pine ta.dmi (RMA) ka ADX - rukh ke liye
struct TEng
  {
   int    n;
   double ef, es, trR, pR, mR, adx;
   double ph, pl, pc;
  };

void EngReset(TEng &e) { e.n = 0; e.ef = 0; e.es = 0; e.trR = 0; e.pR = 0; e.mR = 0; e.adx = 0; e.ph = 0; e.pl = 0; e.pc = 0; }

double Rma(double prev, double v, int len, int n) { if(n <= 1) return(v); return((prev * (len - 1) + v) / len); }

void EngUpdate(TEng &e, double h, double l, double c)
  {
   if(e.n == 0)
     {
      e.ef = c; e.es = c;
      e.ph = h; e.pl = l; e.pc = c;
      e.n = 1;
      return;
     }
   e.n++;
   double tr  = MathMax(h - l, MathMax(MathAbs(h - e.pc), MathAbs(l - e.pc)));
   double up  = h - e.ph;
   double dn  = e.pl - l;
   double pdm = 0.0, mdm = 0.0;
   if(up > dn && up > 0) pdm = up;
   if(dn > up && dn > 0) mdm = dn;
   int k = e.n - 1;
   e.trR = Rma(e.trR, tr, 14, k);
   e.pR  = Rma(e.pR, pdm, 14, k);
   e.mR  = Rma(e.mR, mdm, 14, k);
   double plus = 0.0, minus = 0.0;
   if(e.trR > 0) { plus = 100.0 * e.pR / e.trR; minus = 100.0 * e.mR / e.trR; }
   double sum = plus + minus;
   if(sum == 0) sum = 1;
   e.adx = Rma(e.adx, 100.0 * MathAbs(plus - minus) / sum, 14, k);
   e.ef += 2.0 / (InpEmaFast + 1) * (c - e.ef);
   e.es += 2.0 / (InpEmaSlow + 1) * (c - e.es);
   e.ph = h; e.pl = l; e.pc = c;
  }

int EngDir(const TEng &e)
  {
   if(e.n < 2) return(0);
   if(e.ef > e.es && e.adx >= InpAdxMin) return(1);
   if(e.ef < e.es && e.adx >= InpAdxMin) return(-1);
   return(0);
  }

//--------------------------- HAAL -------------------------------------
TEng     g_ch, g_h4, g_d1;
datetime g_h4T = 0, g_d1T = 0;
string   g_dxy = "";
bool     g_dxyOk = false;
double   g_dx8 = 0, g_dx21 = 0;
int      g_dxN = 0;
datetime g_dxT = 0;

int      g_bar = 0;            // kitni candle chal chuki
double   g_atr14 = 0, g_atr10 = 0, g_pc = 0;
double   g_stUp = 0, g_stDn = 0;
int      g_stTr = 1;
bool     g_stInit = false;

double   g_lastHi = 0, g_lastLo = 0;
bool     g_haveHi = false, g_haveLo = false;
bool     g_hiBrk = true, g_loBrk = true;
int      g_tStruct = 0;
int      g_upBar = -1, g_dnBar = -1;

double   g_zTop[], g_zBot[];
bool     g_zSup[];
int      g_zN = 0;

bool     g_buy = false, g_sell = false;
string   g_why = "";
datetime g_lastBar = 0;

// trade hisaab
ulong    g_posId = 0;
double   g_posRisk = 0;
datetime g_posT = 0;
double   g_R[];
datetime g_RT[];
int      g_nR = 0;
int      g_skipStop = 0, g_skipLot = 0, g_both = 0, g_opp = 0;

//+------------------------------------------------------------------+
double H(int s) { return(iHigh(_Symbol, _Period, s)); }
double L(int s) { return(iLow(_Symbol, _Period, s)); }
double C(int s) { return(iClose(_Symbol, _Period, s)); }
double O(int s) { return(iOpen(_Symbol, _Period, s)); }

bool IsPH(int c)
  {
   double v = H(c);
   for(int k = 1; k <= InpPivot; k++)
      if(H(c + k) >= v || H(c - k) > v) return(false);
   return(true);
  }
bool IsPL(int c)
  {
   double v = L(c);
   for(int k = 1; k <= InpPivot; k++)
      if(L(c + k) <= v || L(c - k) < v) return(false);
   return(true);
  }

// Bari TF ka rukh: chart candle t wali bari candle se PICHLI band candle
int HtfDir(TEng &e, datetime &lastT, ENUM_TIMEFRAMES tf, datetime t)
  {
   int idx = iBarShift(_Symbol, tf, t, false);
   if(idx < 0) return(0);
   int need = idx + 1;
   datetime T = iTime(_Symbol, tf, need);
   if(T == 0) return(0);
   if(T > lastT)
     {
      int from;
      if(lastT == 0) from = MathMin(need + 800, iBars(_Symbol, tf) - 1);
      else           from = iBarShift(_Symbol, tf, lastT, false) - 1;
      for(int s = from; s >= need; s--)
         EngUpdate(e, iHigh(_Symbol, tf, s), iLow(_Symbol, tf, s), iClose(_Symbol, tf, s));
      lastT = T;
     }
   return(EngDir(e));
  }

// DXY EMA8 - EMA21 usi TF par, candle t tak (Pine lookahead_off jaisa)
double DxyDir(datetime t)
  {
   int idx = iBarShift(g_dxy, _Period, t, false);
   if(idx < 0) return(0.0);
   datetime T = iTime(g_dxy, _Period, idx);
   if(T > g_dxT)
     {
      int from;
      if(g_dxT == 0) from = MathMin(idx + 500, iBars(g_dxy, _Period) - 1);
      else           from = iBarShift(g_dxy, _Period, g_dxT, false) - 1;
      for(int s = from; s >= idx; s--)
        {
         double c = iClose(g_dxy, _Period, s);
         if(g_dxN == 0) { g_dx8 = c; g_dx21 = c; }
         else { g_dx8 += 2.0 / 9.0 * (c - g_dx8); g_dx21 += 2.0 / 22.0 * (c - g_dx21); }
         g_dxN++;
        }
      g_dxT = T;
     }
   return(g_dx8 - g_dx21);
  }

void AddZone(double px, bool sup)
  {
   double pad = g_atr14 * InpZonePad;
   if(g_zN >= InpMaxZones)
     {
      for(int k = 1; k < g_zN; k++) { g_zTop[k - 1] = g_zTop[k]; g_zBot[k - 1] = g_zBot[k]; g_zSup[k - 1] = g_zSup[k]; }
      g_zN--;
     }
   g_zTop[g_zN] = px + pad;
   g_zBot[g_zN] = px - pad;
   g_zSup[g_zN] = sup;
   g_zN++;
  }

bool Touch(bool sup, double h, double l)
  {
   for(int k = g_zN - 1; k >= 0; k--)
      if(g_zSup[k] == sup) return(h >= g_zBot[k] && l <= g_zTop[k]);
   return(false);
  }

//+------------------------------------------------------------------+
//|  Ek band candle (shift s) - Pine ki tarteeb mein                 |
//+------------------------------------------------------------------+
void ProcessBar(int s, bool warm)
  {
   double h = H(s), l = L(s), c = C(s), o = O(s);
   g_bar++;
   // ATR (RMA) 14 aur 10
   double tr = h - l;
   if(g_bar > 1) tr = MathMax(tr, MathMax(MathAbs(h - g_pc), MathAbs(l - g_pc)));
   g_atr14 = Rma(g_atr14, tr, 14, g_bar);
   g_atr10 = Rma(g_atr10, tr, InpStPeriod, g_bar);

   // Supertrend
   double src = (h + l) / 2.0;
   double up = src - InpStMult * g_atr10;
   double dn = src + InpStMult * g_atr10;
   double up1 = up, dn1 = dn;
   if(g_stInit) { up1 = g_stUp; dn1 = g_stDn; }
   if(g_stInit && g_pc > up1) up = MathMax(up, up1);
   if(g_stInit && g_pc < dn1) dn = MathMin(dn, dn1);
   if(g_stTr == -1 && c > dn1) g_stTr = 1;
   else if(g_stTr == 1 && c < up1) g_stTr = -1;
   g_stUp = up; g_stDn = dn; g_stInit = true;
   g_pc = c;

   // Rukh (chart TF)
   EngUpdate(g_ch, h, l, c);
   int trend = EngDir(g_ch);

   // Swings
   if(IsPH(s + InpPivot)) { g_lastHi = H(s + InpPivot); g_haveHi = true; g_hiBrk = false; }
   if(IsPL(s + InpPivot)) { g_lastLo = L(s + InpPivot); g_haveLo = true; g_loBrk = false; }
   bool swBuy  = g_haveHi && !g_hiBrk && h > g_lastHi && c < g_lastHi;
   bool swSell = g_haveLo && !g_loBrk && l < g_lastLo && c > g_lastLo;
   bool above  = g_haveHi && !g_hiBrk && c > g_lastHi;
   bool below  = g_haveLo && !g_loBrk && c < g_lastLo;
   if(above) g_hiBrk = true;
   if(below) g_loBrk = true;
   bool upEv = false, dnEv = false;
   if(above) { upEv = true; g_tStruct = 1; }
   if(below) { dnEv = true; g_tStruct = -1; }
   if(upEv) g_upBar = g_bar;
   if(dnEv) g_dnBar = g_bar;
   int bsUp = -1, bsDn = -1;
   if(g_upBar >= 0) bsUp = g_bar - g_upBar;
   if(g_dnBar >= 0) bsDn = g_bar - g_dnBar;
   bool recUp = bsUp >= 0 && bsUp <= InpStructLB;
   bool recDn = bsDn >= 0 && bsDn <= InpStructLB;

   // Zones
   if(upEv && g_haveLo) AddZone(g_lastLo, true);
   if(dnEv && g_haveHi) AddZone(g_lastHi, false);

   g_buy = false; g_sell = false;
   if(warm) return;

   // FVG / LGB
   bool fvgUp = l > H(s + 2);
   bool fvgDn = h < L(s + 2);
   bool lgbUp = swBuy, lgbDn = swSell;

   datetime t = iTime(_Symbol, _Period, s);
   int d4 = HtfDir(g_h4, g_h4T, PERIOD_H4, t);
   int dD = HtfDir(g_d1, g_d1T, PERIOD_D1, t);
   bool htfL = (d4 == 1) || (dD == 1);
   bool htfS = (d4 == -1) || (dD == -1);
   bool dxL = true, dxS = true;
   if(g_dxyOk)
     {
      double dd = DxyDir(t);
      dxL = dd < 0; dxS = dd > 0;
     }

   double atr = g_atr14;
   bool sigB = Touch(true, h, l)  && recUp && trend == 1  && (fvgUp || lgbDn) && htfL && dxL;
   bool sigS = Touch(false, h, l) && recDn && trend == -1 && (fvgDn || lgbUp) && htfS && dxS;
   bool brkU = recUp && trend == 1  && g_haveHi && c > g_lastHi + atr * InpBrkBuf && ((h - l) >= atr * InpImpulse || fvgUp || lgbDn);
   bool brkD = recDn && trend == -1 && g_haveLo && c < g_lastLo - atr * InpBrkBuf && ((h - l) >= atr * InpImpulse || fvgDn || lgbUp);
   bool rtU  = trend == 1  && bsUp >= 0 && bsUp <= InpRetestWin && MathAbs(l - g_ch.ef) <= atr * InpRetestTol && c > g_ch.ef && c > o;
   bool rtD  = trend == -1 && bsDn >= 0 && bsDn <= InpRetestWin && MathAbs(h - g_ch.ef) <= atr * InpRetestTol && c < g_ch.ef && c < o;
   bool mbB = (brkU || rtU) && htfL && dxL;
   bool mbS = (brkD || rtD) && htfS && dxS;
   g_buy  = (sigB || mbB) && g_stTr == 1;
   g_sell = (sigS || mbS) && g_stTr == -1;
   g_why = StringFormat("rukh %d | 4H %d 1D %d | ST %d | toot %s",
                        trend, d4, dD, g_stTr, Pick(g_tStruct == 1, "UP", Pick(g_tStruct == -1, "DN", "-")));
  }

//+------------------------------------------------------------------+
//|  BROKER                                                          |
//+------------------------------------------------------------------+
double NormPx(double v)
  {
   double ts = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);
   if(ts > 0.0) v = MathRound(v / ts) * ts;
   return(NormalizeDouble(v, (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS)));
  }

double MinStop()
  {
   long lvl = MathMax(SymbolInfoInteger(_Symbol, SYMBOL_TRADE_STOPS_LEVEL), SymbolInfoInteger(_Symbol, SYMBOL_TRADE_FREEZE_LEVEL));
   return((double)lvl * SymbolInfoDouble(_Symbol, SYMBOL_POINT));
  }

double LotFor(int dir, double price, double slv, double &riskMoney)
  {
   riskMoney = 0.0;
   double loss = 0.0;
   ENUM_ORDER_TYPE ot = ORDER_TYPE_BUY;
   if(dir == -1) ot = ORDER_TYPE_SELL;
   if(!OrderCalcProfit(ot, _Symbol, 1.0, price, slv, loss)) return(0.0);
   loss = MathAbs(loss);
   double base = AccountInfoDouble(ACCOUNT_BALANCE);
   if(loss <= 0.0 || base <= 0.0) return(0.0);
   double step = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);
   double mn   = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
   double mx   = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX);
   if(step <= 0.0) step = 0.01;
   double lots = MathFloor(base * InpRiskPct / 100.0 / loss / step + 1e-9) * step;
   if(lots < mn - 1e-12)
     {
      if(mn * loss / base * 100.0 > InpMaxRiskPct) return(0.0);
      lots = mn;
     }
   if(lots > mx) lots = mx;
   if(lots > InpMaxLot) lots = InpMaxLot;
   int vd = 0;
   while(vd < 8 && MathAbs(step * MathPow(10, vd) - MathRound(step * MathPow(10, vd))) > 1e-9) vd++;
   lots = NormalizeDouble(lots, vd);
   riskMoney = lots * loss;
   return(lots);
  }

bool FindPos(ulong &tk, int &dir)
  {
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      ulong t = PositionGetTicket(i);
      if(t == 0) continue;
      if(PositionGetString(POSITION_SYMBOL) != _Symbol) continue;
      if(PositionGetInteger(POSITION_MAGIC) != InpMagic) continue;
      tk = t;
      dir = 1;
      if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL) dir = -1;
      return(true);
     }
   return(false);
  }

// Band hui position ka R hisaab mein
void CheckClosed()
  {
   if(g_posId == 0) return;
   ulong tk = 0; int dir = 0;
   if(FindPos(tk, dir)) return;
   double p = 0.0;
   if(HistorySelectByPosition(g_posId))
     {
      for(int k = HistoryDealsTotal() - 1; k >= 0; k--)
        {
         ulong d = HistoryDealGetTicket(k);
         if(d == 0) continue;
         p += HistoryDealGetDouble(d, DEAL_PROFIT) + HistoryDealGetDouble(d, DEAL_SWAP) + HistoryDealGetDouble(d, DEAL_COMMISSION);
        }
     }
   if(g_posRisk > 0.0 && g_posT >= InpStatFrom)
     {
      g_nR++;
      ArrayResize(g_R, g_nR);
      ArrayResize(g_RT, g_nR);
      g_R[g_nR - 1]  = p / g_posRisk;
      g_RT[g_nR - 1] = TimeCurrent();
     }
   g_posId = 0;
   g_posRisk = 0.0;
  }

void Act(bool canTrade)
  {
   CheckClosed();
   ulong tk = 0; int dir = 0;
   bool have = FindPos(tk, dir);
   if(have)
     {
      if((dir == 1 && g_sell) || (dir == -1 && g_buy))
        {
         g_opp++;
         if(canTrade) trade.PositionClose(tk);
         CheckClosed();
        }
      return;
     }
   if(g_buy && g_sell) { g_both++; return; }
   if(!g_buy && !g_sell) return;
   if(!canTrade) return;
   int d = 1;
   if(g_sell) d = -1;
   double c1 = C(1);
   double sd = g_atr14 * InpSlAtr;
   if(sd <= 0.0) return;
   double sl = NormPx(c1 - d * sd);
   double tp = NormPx(c1 + d * sd * InpTpR);
   MqlTick t;
   if(!SymbolInfoTick(_Symbol, t)) return;
   double px = t.ask;
   if(d == -1) px = t.bid;
   double ms = MinStop();
   // Gap ki wajah se SL/TP ghalat taraf ho gaye = trade nahi (gin lo)
   if((d == 1 && (sl >= t.bid - ms || tp <= t.ask + ms)) || (d == -1 && (sl <= t.ask + ms || tp >= t.bid - ms)))
     { g_skipStop++; return; }
   double risk = 0.0;
   double lots = LotFor(d, px, sl, risk);
   if(lots <= 0.0) { g_skipLot++; return; }
   bool ok;
   if(d == 1) ok = trade.Buy(lots, _Symbol, 0.0, sl, tp, "SC6 " + EA_BUILD);
   else       ok = trade.Sell(lots, _Symbol, 0.0, sl, tp, "SC6 " + EA_BUILD);
   if(!ok) return;
   ulong ptk = 0; int pd = 0;
   if(FindPos(ptk, pd) && PositionSelectByTicket(ptk))
     {
      g_posId   = (ulong)PositionGetInteger(POSITION_IDENTIFIER);
      g_posRisk = risk;
      g_posT    = TimeCurrent();
     }
  }

//+------------------------------------------------------------------+
//|  NATEEJA                                                         |
//+------------------------------------------------------------------+
void Stats()
  {
   int n = g_nR, win = 0;
   double sum = 0, sq = 0, gp = 0, gl = 0, cum = 0, peak = 0, dd = 0;
   int    yrY[]; double yrR[]; int yrN[]; int ny = 0;
   for(int k = 0; k < n; k++)
     {
      double r = g_R[k];
      sum += r; sq += r * r;
      if(r > 0) { win++; gp += r; } else gl += -r;
      cum += r;
      if(cum > peak) peak = cum;
      if(peak - cum > dd) dd = peak - cum;
      MqlDateTime st; TimeToStruct(g_RT[k], st);
      int yi = -1;
      for(int j = 0; j < ny; j++) if(yrY[j] == st.year) { yi = j; break; }
      if(yi < 0) { ny++; ArrayResize(yrY, ny); ArrayResize(yrR, ny); ArrayResize(yrN, ny); yi = ny - 1; yrY[yi] = st.year; yrR[yi] = 0; yrN[yi] = 0; }
      yrR[yi] += r; yrN[yi]++;
     }
   double ex = 0, se2 = 0, pf = 0, wp = 0;
   if(n > 0) { ex = sum / n; wp = 100.0 * win / n; }
   if(n > 1) se2 = 2.0 * MathSqrt(MathMax(sq - sum * sum / n, 0.0) / (n - 1)) / MathSqrt((double)n);
   if(gl > 0) pf = gp / gl;
   string yt = "";
   int yPos = 0;
   for(int j = 0; j < ny; j++) { yt += StringFormat("%d %+.1fR (%d)  ", yrY[j], yrR[j], yrN[j]); if(yrR[j] > 0) yPos++; }
   bool pass = n >= 100 && ex - se2 > 0.0;
   PrintFormat("JAS SMC SCALP %s | %s %s | SAAL: %s| musbat %d/%d (sirf maloomat)", EA_BUILD, _Symbol, EnumToString(_Period), yt, yPos, ny);
   PrintFormat("JAS SMC SCALP %s | DXY: %s | chhooti: SL ghalat taraf %d, lot %d | dono ishare %d | ulta band %d",
               EA_BUILD, Pick(g_dxyOk, g_dxy, "NAHI MILA - filter BAND (Pine se farq)"), g_skipStop, g_skipLot, g_both, g_opp);
   PrintFormat("JAS SMC SCALP %s | KUL: %d trades | jeet %.1f%% | Exp %+.3fR (+-%.3f = 2SE) | PF %.2f | kul %+.2fR | girawat %.1fR",
               EA_BUILD, n, wp, ex, se2, pf, sum, dd);
   PrintFormat("JAS SMC SCALP %s | hisaab %s se | QAIDA (pehle se likha): trades >= 100, Exp - 2SE > 0 (%+.3f) -> %s",
               EA_BUILD, TimeToString(InpStatFrom, TIME_DATE), ex - se2,
               Pick(pass, "PASS - agla qadam demo", "FAIL - settings NAHI badalni"));
  }

//+------------------------------------------------------------------+
int OnInit()
  {
   trade.SetExpertMagicNumber(InpMagic);
   trade.SetDeviationInPoints(InpSlippage);
   ArrayResize(g_zTop, InpMaxZones);
   ArrayResize(g_zBot, InpMaxZones);
   ArrayResize(g_zSup, InpMaxZones);
   EngReset(g_ch); EngReset(g_h4); EngReset(g_d1);

   string cands[] = {"DXY", "DXYm", "DXYc", "USDX", "USDXm", "DX"};
   if(InpDxy != "") { g_dxy = InpDxy; g_dxyOk = SymbolSelect(g_dxy, true); }
   else
      for(int k = 0; k < ArraySize(cands); k++)
         if(SymbolSelect(cands[k], true)) { g_dxy = cands[k]; g_dxyOk = true; break; }
   if(!g_dxyOk) Print("JAS SMC SCALP: DXY symbol NAHI MILA - DXY filter BAND (Pine se farq). InpDxy mein naam likhein.");

   int bars = Bars(_Symbol, _Period);
   int from = MathMin(InpWarm, bars - 2 * InpPivot - 5);
   for(int s = from; s >= 1; s--) ProcessBar(s, true);
   g_lastBar = iTime(_Symbol, _Period, 0);
   Comment("JAS SMC SCALP ", EA_BUILD, " | tayyar");
   return(INIT_SUCCEEDED);
  }

void OnDeinit(const int reason)
  {
   Comment("");
  }

void OnTick()
  {
   datetime t0 = iTime(_Symbol, _Period, 0);
   if(t0 == g_lastBar) return;
   g_lastBar = t0;
   ProcessBar(1, false);
   bool canTrade = InpTrade || (bool)MQLInfoInteger(MQL_TESTER);
   Act(canTrade);
   Comment("JAS SMC SCALP ", EA_BUILD, " | ", Pick(canTrade, "TRADE CHALU", "SIRF DIKHANA"),
           " | ishara: ", Pick(g_buy && g_sell, "DONO - kuch nahi", Pick(g_buy, "BUY", Pick(g_sell, "SELL", "-"))),
           "\n", g_why, "\nband trades ", g_nR);
  }

double OnTester()
  {
   CheckClosed();
   Stats();
   return(g_nR);
  }
