//====================================================================
//===  BUILD tk2   <<< PANEL PAR YAHI NUMBER AANA CHAHIYE >>>
//====================================================================
//+------------------------------------------------------------------+
//|                                                  JasTokriEA.mq5 |
//|  JAS TOKRI tk2 - Jalal ka apna GOLD BASKET (docs/tokri_naqsha.md |
//|  Q14-Q22). User ne naam le kar basket + hedge (dono taraf lot)   |
//|  maanga (5-7 Nov 2026, "EA HER SOORAT CHAHIYE", test NAHI).      |
//|  ISLIYE: sirf DEMO par pehle. Sim tk2 (2005-26) = account khatam |
//|  hua tha jab gold ek taraf $30-100 bhaaga. AAKHRI HADD zaroor ON. |
//|                                                                  |
//|  Qaide (har tick, 1 second mein ek dafa):                        |
//|  R  RUKH = AUTO (4H Supertrend 10,3) ya user button BUY / SELL   |
//|     (Q22: rukh chart dekh kar). Rukh taraf = HEAVY lot 0.02,      |
//|     doosri taraf = LIGHT lot 0.01 (Q17: lot BARHTI NAHI).         |
//|  1  Tokri khali = rukh taraf ek lot.                              |
//|  2  Qeemat aakhri lot se InpStep $ chale (Q16: $2):               |
//|     MOM  = chaal ki taraf nayi lot (Q16)                          |
//|     ULTA = high par SELL / low par BUY (Q20)                      |
//|     usi taraf ki koi lot InpStep/2 ke andar ho to nahi.           |
//|  3  Har lot ka TP server par = open +/- InpTp $ (Q18-19: jo       |
//|     faide mein aaye band). SL NAHI (Q21).                         |
//|  4  CLOSE ALL: tokri NET >= InpBasketClose (Q14/Q21).             |
//|  5  BARDASHT: khula nuqsan >= InpBardasht % = nayi lot NAHI.      |
//|  6  AAKHRI HADD: khula nuqsan >= InpHaddPct % = SAB BAND + STOP   |
//|     (user START dabaye tab dobara).                              |
//|  Sirf apni magic; haath ki trade ko nahi chhoota. Hedge account. |
//+------------------------------------------------------------------+
#property copyright "JAS"
#property version   "2.00"
#property strict

#include <Trade/Trade.mqh>
CTrade trade;

#define EA_BUILD "tk2"

enum ENUM_RUKH { RUKH_AUTO = 0, RUKH_BUY = 1, RUKH_SELL = -1 };
enum ENUM_MODE { MODE_MOM = 0, MODE_ULTA = 1 };

input bool      InpTrade       = true;       // Trade kare (false = sirf panel)
input long      InpMagic       = 20261107;   // Magic
input ENUM_RUKH InpRukh        = RUKH_AUTO;  // Rukh: AUTO (4H Supertrend) / BUY / SELL (button se bhi)
input ENUM_MODE InpMode        = MODE_MOM;   // MOM = chaal ki taraf (Q16), ULTA = high SELL / low BUY (Q20)
input double    InpLotHeavy    = 0.02;       // Rukh taraf lot (max 0.02)
input double    InpLotLight    = 0.01;       // Doosri taraf lot (max 0.02)
input double    InpStep        = 2.0;        // Nayi lot: aakhri lot se kitne $ (gold price)
input double    InpTp          = 1.0;        // Har lot TP: kitne $ faida (gold price), spread ke baad
input double    InpBasketClose = 0.5;        // CLOSE ALL jab tokri NET >= itna (account currency)
input int       InpMaxTickets  = 30;         // Kul khuli lots hadd
input double    InpBardasht    = 5.0;        // Khula nuqsan % equity = nayi lot NAHI
input double    InpHaddPct     = 10.0;       // AAKHRI HADD: khula nuqsan % = SAB BAND + STOP
input double    InpBaseEq      = 0.0;        // Shuru equity (0 = EA lagte waqt ki, yaad rakhta hai)
input double    InpMaxSpread   = 0.60;       // Spread $ se zyada = nayi lot nahi
input int       InpMinSec      = 10;         // Do lot ke beech kam az kam second

string Pick(bool c, string a, string b) { if(c) return(a); return(b); }

double   g_base   = 0.0;
int      g_rukhSel = 0;     // 0 auto, 1 buy, -1 sell (button)
bool     g_halt   = false;  // aakhri hadd ke baad STOP
int      g_st4    = 0;      // 4H Supertrend
datetime g_last4  = 0;
datetime g_lastOpen = 0;
int      g_stops  = 0;
string   g_msg    = "";
string   GV(string k) { return(StringFormat("JASTOKRI2_%s_%I64d", k, InpMagic)); }

//--- 4H Supertrend(10,3) RMA, aakhri BAND candle (TradingView jaisa)
int Super4H()
{
   MqlRates r[];
   ArraySetAsSeries(r, false);
   int n = CopyRates(_Symbol, PERIOD_H4, 1, 400, r);
   if(n < 50) return(0);
   double atr = 0, U = 0, D = 0; int dir = 1;
   for(int i = 0; i < n; i++)
   {
      double tr = r[i].high - r[i].low;
      if(i > 0) tr = MathMax(tr, MathMax(MathAbs(r[i].high - r[i - 1].close), MathAbs(r[i].low - r[i - 1].close)));
      atr = (i == 0) ? tr : atr + (tr - atr) / 10.0;
      double hl2 = (r[i].high + r[i].low) / 2.0;
      double up = hl2 - 3.0 * atr, dn = hl2 + 3.0 * atr;
      if(i == 0) { U = up; D = dn; continue; }
      double pU = U, pD = D;
      U = (r[i - 1].close > pU) ? MathMax(up, pU) : up;
      D = (r[i - 1].close < pD) ? MathMin(dn, pD) : dn;
      if(dir == -1 && r[i].close > pD) dir = 1;
      else if(dir == 1 && r[i].close < pU) dir = -1;
   }
   return(dir);
}

int Rukh()
{
   if(g_rukhSel != 0) return(g_rukhSel);
   return(g_st4);
}

//--- apni positions
struct Pos { ulong tk; int dir; double open; double vol; double pl; datetime t; };
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
      p[n].tk   = tk;
      p[n].dir  = (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY) ? 1 : -1;
      p[n].open = PositionGetDouble(POSITION_PRICE_OPEN);
      p[n].vol  = PositionGetDouble(POSITION_VOLUME);
      p[n].pl   = PositionGetDouble(POSITION_PROFIT) + PositionGetDouble(POSITION_SWAP);
      p[n].t    = (datetime)PositionGetInteger(POSITION_TIME);
   }
   return(ArraySize(p));
}

double NormLot(double l)
{
   l = MathMin(l, 0.02);                    // Q17: 0.01 / 0.02 se zyada KABHI nahi
   double mn = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN), st = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);
   if(st > 0) l = MathFloor(l / st + 1e-9) * st;
   return(MathMax(l, mn));
}

bool TradeOk()
{
   return(InpTrade && TerminalInfoInteger(TERMINAL_TRADE_ALLOWED) != 0 && MQLInfoInteger(MQL_TRADE_ALLOWED) != 0);
}

bool Open(int dir, string cmt)
{
   if(!TradeOk()) { g_msg = "Algo OFF - " + cmt + " nahi khuli"; return(false); }
   double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK), bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   if(ask - bid > InpMaxSpread) { g_msg = StringFormat("Spread %.2f zyada - Wait", ask - bid); return(false); }
   int    dg  = (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS);
   double pt  = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
   long   lvl = SymbolInfoInteger(_Symbol, SYMBOL_TRADE_STOPS_LEVEL);
   double tpd = MathMax(InpTp, (lvl + 10) * pt);
   double tp  = (dir == 1) ? ask + tpd : bid - tpd;
   tp = NormalizeDouble(tp, dg);
   double lot = NormLot((dir == Rukh()) ? InpLotHeavy : InpLotLight);
   bool ok = (dir == 1) ? trade.Buy(lot, _Symbol, 0, 0, tp, cmt) : trade.Sell(lot, _Symbol, 0, 0, tp, cmt);
   if(ok) g_lastOpen = TimeCurrent();
   else   PrintFormat("TOKRI %s: %s fail %d", EA_BUILD, cmt, trade.ResultRetcode());
   return(ok);
}

void CloseAll(string why)
{
   if(!TradeOk()) { g_msg = "Algo OFF - Close All nahi hua"; return; }
   Pos p[]; int n = MyPos(p);
   for(int i = 0; i < n; i++)
   {
      bool ok = trade.PositionClose(p[i].tk);
      PrintFormat("TOKRI %s: Close #%I64u (%s) %s", EA_BUILD, p[i].tk, why, Pick(ok, "ok", "FAIL"));
   }
}

void Work()
{
   Pos p[]; int n = MyPos(p);
   double net = 0; for(int i = 0; i < n; i++) net += p[i].pl;

   // 6 AAKHRI HADD
   if(n > 0 && InpHaddPct > 0 && net <= -InpHaddPct * g_base / 100.0)
   {
      CloseAll("AAKHRI HADD");
      g_halt = true; g_stops++;
      GlobalVariableSet(GV("HALT"), 1);
      g_msg = StringFormat("AAKHRI HADD: Loss %.2f - sab Close, EA STOP (START dabayein)", net);
      return;
   }
   // 4 CLOSE ALL faide mein
   if(n >= 2 && net >= InpBasketClose)
   {
      CloseAll("CLOSE ALL net faida");
      g_msg = StringFormat("CLOSE ALL: Net +%.2f", net);
      return;
   }
   if(g_halt) return;
   // 5 BARDASHT
   if(InpBardasht > 0 && net <= -InpBardasht * g_base / 100.0) { g_msg = "BARDASHT: nayi lot NAHI - Wait"; return; }
   if(n >= InpMaxTickets) { g_msg = "Lot hadd puri - Wait"; return; }
   if(TimeCurrent() - g_lastOpen < InpMinSec) return;

   int rk = Rukh();
   double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID), ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   double mid = (bid + ask) / 2.0;

   // 1 tokri khali
   if(n == 0)
   {
      if(rk != 0) Open(rk, Pick(rk == 1, "TOKRI B1", "TOKRI S1"));
      return;
   }
   // 2 aakhri lot se doori
   int last = 0;
   for(int i = 1; i < n; i++) if(p[i].t > p[last].t) last = i;
   double mv = mid - p[last].open;
   if(MathAbs(mv) < InpStep) return;
   int chaal = (mv > 0) ? 1 : -1;
   int dir   = (InpMode == MODE_MOM) ? chaal : -chaal;
   for(int i = 0; i < n; i++)
      if(p[i].dir == dir && MathAbs(mid - p[i].open) < InpStep / 2.0) return;   // usi jagah pehle se lot
   Open(dir, Pick(dir == 1, "TOKRI B", "TOKRI S"));
}

//--- panel + buttons
void Btn(string name, string txt, int x, int y, color bg)
{
   if(ObjectFind(0, name) < 0) ObjectCreate(0, name, OBJ_BUTTON, 0, 0, 0);
   ObjectSetInteger(0, name, OBJPROP_CORNER, CORNER_RIGHT_LOWER);
   ObjectSetInteger(0, name, OBJPROP_XDISTANCE, x);
   ObjectSetInteger(0, name, OBJPROP_YDISTANCE, y);
   ObjectSetInteger(0, name, OBJPROP_XSIZE, 90);
   ObjectSetInteger(0, name, OBJPROP_YSIZE, 24);
   ObjectSetString(0, name, OBJPROP_TEXT, txt);
   ObjectSetInteger(0, name, OBJPROP_BGCOLOR, bg);
   ObjectSetInteger(0, name, OBJPROP_COLOR, clrWhite);
   ObjectSetInteger(0, name, OBJPROP_STATE, false);
}

void Buttons()
{
   Btn("TK_AUTO", "RUKH AUTO", 290, 60, g_rukhSel == 0 ? clrDodgerBlue : clrDimGray);
   Btn("TK_BUY",  "RUKH BUY",  195, 60, g_rukhSel == 1  ? clrGreen : clrDimGray);
   Btn("TK_SELL", "RUKH SELL", 100, 60, g_rukhSel == -1 ? clrRed   : clrDimGray);
   Btn("TK_CLOSE", "CLOSE ALL", 290, 30, clrMaroon);
   Btn("TK_STOP", Pick(g_halt, "START", "STOP"), 195, 30, g_halt ? clrGreen : clrDarkOrange);
}

void Panel()
{
   Pos p[]; int n = MyPos(p);
   int nb = 0, ns = 0; double vb = 0, vs = 0, net = 0;
   for(int i = 0; i < n; i++)
   {
      net += p[i].pl;
      if(p[i].dir == 1) { nb++; vb += p[i].vol; } else { ns++; vs += p[i].vol; }
   }
   int rk = Rukh();
   string s = "";
   s += StringFormat("JAS TOKRI %s | %s | magic %I64d | %s\n", EA_BUILD, _Symbol, InpMagic,
                     Pick(g_halt, "STOP", Pick(TradeOk(), "Algo ON", "Algo OFF")));
   s += StringFormat("RUKH: %s (%s) | 4H Supertrend %s | Mode %s\n",
                     Pick(rk > 0, "BUY", Pick(rk < 0, "SELL", "-")), Pick(g_rukhSel == 0, "AUTO", "button"),
                     Pick(g_st4 > 0, "BUY", Pick(g_st4 < 0, "SELL", "-")), Pick(InpMode == MODE_MOM, "MOM", "ULTA"));
   s += StringFormat("BUY %d ticket %.2f lot | SELL %d ticket %.2f lot | NET lot %.2f\n", nb, vb, ns, vs, vb - vs);
   s += StringFormat("Total P/L %.2f | Close All at +%.2f | Bardasht -%.0f | AAKHRI HADD -%.0f\n",
                     net, InpBasketClose, InpBardasht * g_base / 100.0, InpHaddPct * g_base / 100.0);
   s += StringFormat("Step $%.2f | TP $%.2f | Lot %.2f / %.2f | shuru equity %.2f | hadd lagi %d\n",
                     InpStep, InpTp, NormLot(InpLotHeavy), NormLot(InpLotLight), g_base, g_stops);
   s += g_msg;
   Comment(s);
   Buttons();
}

void OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam)
{
   if(id != CHARTEVENT_OBJECT_CLICK) return;
   if(sparam == "TK_AUTO") g_rukhSel = 0;
   else if(sparam == "TK_BUY") g_rukhSel = 1;
   else if(sparam == "TK_SELL") g_rukhSel = -1;
   else if(sparam == "TK_CLOSE")
   {
      if(MessageBox("Is EA ki SAARI lots Close karein?", "JAS TOKRI", MB_YESNO | MB_ICONQUESTION) == IDYES) CloseAll("user CLOSE ALL");
   }
   else if(sparam == "TK_STOP")
   {
      g_halt = !g_halt;
      GlobalVariableSet(GV("HALT"), g_halt ? 1 : 0);
      g_msg = Pick(g_halt, "STOP: nayi lot NAHI (khuli TP / Close All par chalti rahengi)", "START: EA chalu");
   }
   else return;
   GlobalVariableSet(GV("RUKH"), g_rukhSel);
   Panel();
   ChartRedraw();
}

int OnInit()
{
   if(AccountInfoInteger(ACCOUNT_MARGIN_MODE) != ACCOUNT_MARGIN_MODE_RETAIL_HEDGING)
   { Alert("JAS TOKRI: ye EA sirf HEDGE account par chalta hai"); return(INIT_FAILED); }
   trade.SetExpertMagicNumber(InpMagic);
   trade.SetDeviationInPoints(50);
   bool tester = (MQLInfoInteger(MQL_TESTER) != 0);
   if(InpBaseEq > 0) g_base = InpBaseEq;
   else if(GlobalVariableCheck(GV("BASE")) && !tester) g_base = GlobalVariableGet(GV("BASE"));
   else { g_base = AccountInfoDouble(ACCOUNT_EQUITY); if(!tester) GlobalVariableSet(GV("BASE"), g_base); }
   g_rukhSel = (int)InpRukh;
   if(!tester && InpRukh == RUKH_AUTO && GlobalVariableCheck(GV("RUKH"))) g_rukhSel = (int)GlobalVariableGet(GV("RUKH"));
   g_halt = (!tester && GlobalVariableCheck(GV("HALT")) && GlobalVariableGet(GV("HALT")) > 0);
   if(InpLotHeavy > 0.02 || InpLotLight > 0.02) Print("TOKRI: lot 0.02 se zyada nahi lagegi (Q17)");
   g_st4 = Super4H();
   PrintFormat("JAS TOKRI %s shuru | %s | shuru equity %.2f", EA_BUILD, _Symbol, g_base);
   Panel();
   return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason)
{
   Comment("");
   ObjectDelete(0, "TK_AUTO"); ObjectDelete(0, "TK_BUY"); ObjectDelete(0, "TK_SELL");
   ObjectDelete(0, "TK_CLOSE"); ObjectDelete(0, "TK_STOP");
}

void OnTick()
{
   datetime t4 = iTime(_Symbol, PERIOD_H4, 0);
   if(t4 != 0 && t4 != g_last4) { g_last4 = t4; g_st4 = Super4H(); }
   static datetime lw = 0;
   if(TimeCurrent() != lw)
   {
      lw = TimeCurrent();
      g_msg = (StringFind(g_msg, "AAKHRI") >= 0 || StringFind(g_msg, "CLOSE ALL") >= 0) ? g_msg : "";
      Work();
   }
   static datetime lp = 0;
   if(TimeCurrent() - lp >= 2) { lp = TimeCurrent(); Panel(); }
}

double OnTester()
{
   double dd = TesterStatistics(STAT_EQUITY_DDREL_PERCENT);
   double pr = TesterStatistics(STAT_PROFIT);
   if(dd <= 0) dd = 1;
   return(pr / dd);
}
