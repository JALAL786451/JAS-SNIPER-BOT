//====================================================================
//===  BUILD tk1   <<< PANEL PAR YAHI NUMBER AANA CHAHIYE >>>
//====================================================================
//+------------------------------------------------------------------+
//|                                                  JasTokriEA.mq5 |
//|  JAS TOKRI - user Jalal ki apni Tokri (fishing + dhaal), us ke   |
//|  qaide Q1-Q13 (docs/tokri_naqsha.md). Fishing lots + ulti dhaal  |
//|  (hedge) user ne 5 Nov 2026 is chat mein naam le kar maangi.     |
//|  Python sim: tools/tokri_sim.py 1,0.5,10,5,10,1,1,10             |
//|   2010-18 +13.1% (gehra -3.6%) | 2019-26 +14.0% (gehra -8.7%)    |
//|   MT5 TESTER ABHI NAHI. Pehle tester -> demo, LIVE NAHI.          |
//|                                                                  |
//|  Har H1 candle band hone par (sim jaisa):                        |
//|  MOOD = Naqsha Rukh: close > EMA50 > EMA200 + Supertrend(10,3)   |
//|    upar = UPAR, ulta NEECHE, warna MILA. 1D = pichhla band din,  |
//|    4H = pichhli band 4H candle. ATR = din ka ATR14 (RMA).        |
//|  F1 FISHING taraf: 4H Supertrend upar = BUY; 4H Supertrend neeche |
//|     + 1D NEECHE = SELL (Q1); warna nayi fishing nahi.             |
//|  F2 nayi 0.01 jab usi taraf ki har khuli fishing se >= 1 ATR door |
//|     (ya koi na ho), kul fishing < 10, khula nuqsan < 5% (BARDASHT)|
//|  F3 har fishing ka TP server par = +0.5 ATR. SL nahi.            |
//|  D1 DHAAL (Q2,Q6,Q7,Q8): basket (ek taraf ki fishing) ka nuqsan   |
//|     har mazeed 200 (account currency) par EK 0.01 ulti lot, sirf |
//|     jab 1D + 4H dono basket ke khilaf, aur 2 din (48 H1) ki       |
//|     low/high se wapasi < 1 ATR. Dhaal max 10.                    |
//|  D2 (Q9) 4H Supertrend basket ki taraf mude = dhaal BAND.         |
//|  H  AAKHRI HADD: khula nuqsan >= 10% (shuru equity) = SAB BAND.   |
//|  Sirf apni magic ki lots; haath ki trade ko nahi chhoota.        |
//|  Har lot 0.01 (hadd InpLot, max 0.01). Martingale NAHI.          |
//+------------------------------------------------------------------+
#property copyright "JAS"
#property version   "1.00"
#property strict

#include <Trade/Trade.mqh>
CTrade trade;

#define EA_BUILD "tk1"

input bool   InpTrade      = true;      // Trade kare (false = sirf panel)
input long   InpMagic      = 20261105;  // Magic
input double InpLot        = 0.01;      // Har lot (max 0.01)
input double InpGapAtr     = 1.0;       // F2: nayi fishing kitne din-ATR door
input double InpTpAtr      = 0.5;       // F3: fishing TP (din-ATR)
input int    InpMaxFish    = 10;        // F2: fishing lots hadd
input double InpBardasht   = 5.0;       // F2: khula nuqsan % par nayi fishing band
input double InpDhaalStep  = 200.0;     // D1: har itne nuqsan par ek dhaal (account currency, cent = USC)
input int    InpMaxDhaal   = 10;        // D1: dhaal hadd
input double InpBounceAtr  = 1.0;       // D1 (Q8): wapasi >= itne ATR = dhaal nahi
input double InpHaddPct    = 10.0;      // H: khula nuqsan % = sab band
input double InpBaseEq     = 0.0;       // shuru equity (0 = EA lagte waqt ki equity, yaad rakhta hai)
input double InpMaxSpread  = 1.0;       // nayi lot nahi agar spread $ se zyada

string Pick(bool c, string a, string b) { if(c) return(a); return(b); }

double   g_base = 0.0;
datetime g_lastH1 = 0;
int      g_stops = 0;
string   g_msg = "";
// mood
int    g_d1 = 0, g_r4 = 0, g_s4 = 0;
double g_atr = 0.0;

//--- EMA (adjust=False jaisa: pehli close se shuru)
void Ema(const double &c[], int n, int len, double &out[])
{
   ArrayResize(out, n);
   double a = 2.0 / (len + 1.0);
   out[0] = c[0];
   for(int i = 1; i < n; i++) out[i] = a * c[i] + (1.0 - a) * out[i - 1];
}

//--- Rates purane se naye (index 0 = sab se purana), sirf BAND candles
int Rates(ENUM_TIMEFRAMES tf, int cnt, MqlRates &r[])
{
   ArraySetAsSeries(r, false);
   int got = CopyRates(_Symbol, tf, 1, cnt, r);   // shift 1 = chalti candle nahi
   return(got);
}

//--- Supertrend(10,3) RMA ATR, TradingView jaisa. dir[i] = +1 / -1
void SuperT(const MqlRates &r[], int n, int p, double m, int &dir[], double &atr[])
{
   ArrayResize(dir, n); ArrayResize(atr, n);
   double U = 0, D = 0;
   for(int i = 0; i < n; i++)
   {
      double tr = r[i].high - r[i].low;
      if(i > 0) tr = MathMax(tr, MathMax(MathAbs(r[i].high - r[i - 1].close), MathAbs(r[i].low - r[i - 1].close)));
      atr[i] = (i == 0) ? tr : atr[i - 1] + (tr - atr[i - 1]) / p;
      double hl2 = (r[i].high + r[i].low) / 2.0;
      double up = hl2 - m * atr[i], dn = hl2 + m * atr[i];
      if(i == 0) { U = up; D = dn; dir[i] = 1; continue; }
      double pU = U, pD = D;
      U = (r[i - 1].close > pU) ? MathMax(up, pU) : up;
      D = (r[i - 1].close < pD) ? MathMin(dn, pD) : dn;
      if(dir[i - 1] == -1 && r[i].close > pD) dir[i] = 1;
      else if(dir[i - 1] == 1 && r[i].close < pU) dir[i] = -1;
      else dir[i] = dir[i - 1];
   }
}

//--- Rukh (+1 / -1 / 0) aur Supertrend dir aakhri band candle ka
bool Mood(ENUM_TIMEFRAMES tf, int &rukh, int &st, double &atr14)
{
   MqlRates r[];
   int n = Rates(tf, 600, r);
   if(n < 250) return(false);
   double c[]; ArrayResize(c, n);
   for(int i = 0; i < n; i++) c[i] = r[i].close;
   double e50[], e200[]; Ema(c, n, 50, e50); Ema(c, n, 200, e200);
   int dir[]; double a10[]; SuperT(r, n, 10, 3.0, dir, a10);
   int k = n - 1;
   st = dir[k];
   rukh = 0;
   if(c[k] > e50[k] && e50[k] > e200[k] && st > 0) rukh = 1;
   if(c[k] < e50[k] && e50[k] < e200[k] && st < 0) rukh = -1;
   // ATR14 RMA
   double a = r[0].high - r[0].low;
   for(int i = 1; i < n; i++)
   {
      double tr = MathMax(r[i].high - r[i].low, MathMax(MathAbs(r[i].high - r[i - 1].close), MathAbs(r[i].low - r[i - 1].close)));
      a += (tr - a) / 14.0;
   }
   atr14 = a;
   return(true);
}

//--- apni positions
struct Pos { ulong tk; int dir; double open; double pl; bool dhaal; };
int MyPos(Pos &p[])
{
   ArrayResize(p, 0);
   for(int i = PositionsTotal() - 1; i >= 0; i--)
   {
      ulong tk = PositionGetTicket(i);
      if(tk == 0) continue;
      if(PositionGetString(POSITION_SYMBOL) != _Symbol) continue;
      if(PositionGetInteger(POSITION_MAGIC) != InpMagic) continue;
      int n = ArraySize(p); ArrayResize(p, n + 1);
      p[n].tk = tk;
      p[n].dir = (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY) ? 1 : -1;
      p[n].open = PositionGetDouble(POSITION_PRICE_OPEN);
      p[n].pl = PositionGetDouble(POSITION_PROFIT) + PositionGetDouble(POSITION_SWAP);
      p[n].dhaal = (StringFind(PositionGetString(POSITION_COMMENT), "DHAAL") >= 0);
   }
   return(ArraySize(p));
}

double Lot()
{
   double l = MathMin(InpLot, 0.01);
   double mn = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN), st = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);
   if(st > 0) l = MathFloor(l / st + 1e-9) * st;
   return(MathMax(l, mn));
}

bool Open(int dir, double tp, string cmt)
{
   if(!InpTrade || !TerminalInfoInteger(TERMINAL_TRADE_ALLOWED) || !MQLInfoInteger(MQL_TRADE_ALLOWED))
   { g_msg = "Algo Trading band - " + cmt + " nahi khuli"; return(false); }
   double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK), bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   if(ask - bid > InpMaxSpread) { g_msg = StringFormat("spread %.2f zyada - %s nahi", ask - bid, cmt); return(false); }
   if(tp > 0)
   {
      long   lvl = SymbolInfoInteger(_Symbol, SYMBOL_TRADE_STOPS_LEVEL);
      double pt  = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
      double px  = (dir == 1) ? ask : bid;
      if(MathAbs(tp - px) < (lvl + 10) * pt) tp = 0;
      tp = NormalizeDouble(tp, (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS));
   }
   bool ok = (dir == 1) ? trade.Buy(Lot(), _Symbol, 0, 0, tp, cmt) : trade.Sell(Lot(), _Symbol, 0, 0, tp, cmt);
   if(!ok) PrintFormat("TOKRI %s: %s fail %d", EA_BUILD, cmt, trade.ResultRetcode());
   return(ok);
}

bool ClosePos(ulong tk, string why)
{
   if(!InpTrade) return(false);
   bool ok = trade.PositionClose(tk);
   PrintFormat("TOKRI %s: band #%I64u (%s) %s", EA_BUILD, tk, why, Pick(ok, "ok", "FAIL"));
   return(ok);
}

//--- 48 H1 band candles ki low / high
void Range48(double &lo, double &hi)
{
   MqlRates r[]; int n = Rates(PERIOD_H1, 48, r);
   lo = DBL_MAX; hi = -DBL_MAX;
   for(int i = 0; i < n; i++) { lo = MathMin(lo, r[i].low); hi = MathMax(hi, r[i].high); }
}

void OnH1()
{
   int r1, s1; double a1, a4;
   if(!Mood(PERIOD_D1, r1, s1, a1) || !Mood(PERIOD_H4, g_r4, g_s4, a4)) { g_msg = "history kam (D1/H4 250+ candle chahiye)"; return; }
   g_d1 = r1; g_atr = a1;
   MqlRates h[]; if(Rates(PERIOD_H1, 1, h) < 1) return;
   double c = h[0].close;
   Pos p[]; int n = MyPos(p);

   // D2 (Q9): 4H basket ki taraf mude = dhaal band
   for(int i = 0; i < n; i++)
      if(p[i].dhaal && g_s4 == -p[i].dir) ClosePos(p[i].tk, "Q9 4H mura");
   n = MyPos(p);

   // H: aakhri hadd
   double flo = 0; for(int i = 0; i < n; i++) flo += p[i].pl;
   if(InpHaddPct > 0 && flo <= -InpHaddPct * g_base / 100.0)
   {
      for(int i = 0; i < n; i++) ClosePos(p[i].tk, "AAKHRI HADD");
      g_stops++; g_msg = StringFormat("AAKHRI HADD: khula %.0f - sab band", flo);
      return;
   }

   // F1/F2 fishing
   int side = 0;
   if(g_s4 == 1) side = 1;
   else if(g_s4 == -1 && g_d1 == -1) side = -1;
   int nf = 0; for(int i = 0; i < n; i++) if(!p[i].dhaal) nf++;
   if(side != 0 && nf < InpMaxFish && flo > -InpBardasht * g_base / 100.0)
   {
      double near = DBL_MAX;
      for(int i = 0; i < n; i++) if(!p[i].dhaal && p[i].dir == side) near = MathMin(near, MathAbs(c - p[i].open));
      if(near >= InpGapAtr * g_atr)
      {
         double px = (side == 1) ? SymbolInfoDouble(_Symbol, SYMBOL_ASK) : SymbolInfoDouble(_Symbol, SYMBOL_BID);
         Open(side, px + side * InpTpAtr * g_atr, Pick(side == 1, "TOKRI FISH B", "TOKRI FISH S"));
         n = MyPos(p);
      }
   }

   // D1 dhaal
   double lo, hi; Range48(lo, hi);
   for(int bs = 1; bs >= -1; bs -= 2)
   {
      double lb = 0; int nb = 0, nd = 0, ndAll = 0;
      for(int i = 0; i < n; i++)
      {
         if(p[i].dhaal) { ndAll++; if(p[i].dir == -bs) nd++; continue; }
         if(p[i].dir == bs) { lb += p[i].pl; nb++; }
      }
      if(nb == 0 || ndAll >= InpMaxDhaal) continue;
      bool against = (g_d1 == -bs && g_r4 == -bs);
      double bounce = (bs == 1) ? (c - MathMin(lo, h[0].low)) : (MathMax(hi, h[0].high) - c);
      if(against && lb <= -InpDhaalStep * (nd + 1) && bounce < InpBounceAtr * g_atr)
      {
         if(Open(-bs, 0, Pick(bs == 1, "TOKRI DHAAL S", "TOKRI DHAAL B"))) n = MyPos(p);
      }
   }
}

string MoodTx(int v) { return(Pick(v > 0, "UPAR", Pick(v < 0, "NEECHE", "MILA"))); }

void Panel()
{
   Pos p[]; int n = MyPos(p);
   int fb = 0, fs = 0, db = 0, ds = 0; double flo = 0;
   for(int i = 0; i < n; i++)
   {
      flo += p[i].pl;
      if(p[i].dhaal) { if(p[i].dir == 1) db++; else ds++; }
      else           { if(p[i].dir == 1) fb++; else fs++; }
   }
   string s = "";
   s += StringFormat("JAS TOKRI %s | %s | magic %I64d | %s\n", EA_BUILD, _Symbol, InpMagic,
                     Pick(InpTrade && TerminalInfoInteger(TERMINAL_TRADE_ALLOWED) != 0, "TRADE CHALU", "TRADE BAND"));
   s += StringFormat("MOOD: 1D %s | 4H %s (Supertrend %s) | din ATR %.2f\n", MoodTx(g_d1), MoodTx(g_r4), Pick(g_s4 > 0, "upar", "neeche"), g_atr);
   s += StringFormat("FISHING: BUY %d  SELL %d (hadd %d) | DHAAL: SELL %d  BUY %d (hadd %d)\n", fb, fs, InpMaxFish, ds, db, InpMaxDhaal);
   s += StringFormat("Khula %.2f | bardasht -%.0f | AAKHRI HADD -%.0f | shuru %.2f | hadd lagi %d\n",
                     flo, InpBardasht * g_base / 100.0, InpHaddPct * g_base / 100.0, g_base, g_stops);
   s += g_msg;
   Comment(s);
}

int OnInit()
{
   trade.SetExpertMagicNumber(InpMagic);
   trade.SetDeviationInPoints(50);
   string gv = StringFormat("JASTOKRI_BASE_%I64d", InpMagic);
   if(InpBaseEq > 0) g_base = InpBaseEq;
   else if(GlobalVariableCheck(gv) && !MQLInfoInteger(MQL_TESTER)) g_base = GlobalVariableGet(gv);
   else { g_base = AccountInfoDouble(ACCOUNT_EQUITY); if(!MQLInfoInteger(MQL_TESTER)) GlobalVariableSet(gv, g_base); }
   if(InpLot > 0.01) Print("TOKRI: lot 0.01 se zyada nahi - 0.01 hi lagegi");
   PrintFormat("JAS TOKRI %s shuru | %s | shuru equity %.2f", EA_BUILD, _Symbol, g_base);
   g_lastH1 = iTime(_Symbol, PERIOD_H1, 0);   // lagte hi pehli candle par trade nahi
   Panel();
   return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason) { Comment(""); }

void OnTick()
{
   datetime t = iTime(_Symbol, PERIOD_H1, 0);
   if(t != 0 && t != g_lastH1)
   {
      g_lastH1 = t;
      g_msg = "";
      OnH1();
   }
   static datetime lp = 0;
   if(TimeCurrent() - lp >= 5) { lp = TimeCurrent(); Panel(); }
}

double OnTester()
{
   double dd = TesterStatistics(STAT_EQUITY_DDREL_PERCENT);
   double pr = TesterStatistics(STAT_PROFIT);
   if(dd <= 0) dd = 1;
   return(pr / dd);
}
