//====================================================================
//===  BUILD d1   <<< PANEL PAR YAHI NUMBER AANA CHAHIYE >>>
//====================================================================
//+------------------------------------------------------------------+
//|                                                  JasFishDemo.mq5 |
//|  DEMO ke liye fishing EA (11 Nov 2026, user: "pehle demo, phir   |
//|  real - direct risk nahi").                                      |
//|                                                                  |
//|  QAIDE - sab faasle gold ki QEEMAT mein ($). 0.01 lot par $1 =   |
//|  demo (USD) par $1, cent account par 1 USC:                      |
//|   1. Qeemat pichhle nishan se InpStep ($10) hile -> nishan naya. |
//|   2. Ulti taraf 0.01: qeemat GIRI to BUY, CHARHI to SELL -       |
//|      lekin sirf jab wo taraf H1 rukh (EMA50) ke SAATH ho.        |
//|   3. Har lot ka apna TP (InpTP $20) aur SL (InpSL $20), order    |
//|      ke saath hi lag jata hai. EA baad mein lot ko nahi chherta. |
//|   4. Ek waqt mein zyada se zyada InpMaxPos (5) lots.             |
//|                                                                  |
//|  HIFAZAT: lot kabhi 0.01 se bari nahi. Averaging / martingale /  |
//|  hedge NAHI. Sirf apni (magic) lots. REAL account par trade nahi |
//|  (InpDemoOnly). Spread zyada = nayi lot nahi. Equity (lagate     |
//|  waqt ki) InpEqHaltPct % se neeche = apni lots band + EA ruk.    |
//|  Jumma InpFriNoStart baje (server) se nayi lot nahi.             |
//|                                                                  |
//|  NAAP (Claude, M1 daam, spread 0.25): 2025 +624, 2026 +2600      |
//|  (0.01 lot, USC) lekin 2019-2024 mein 4 saal nuqsan. Ye PAKKA    |
//|  NAHI - is liye sirf demo. Asal jawab Strategy Tester + demo.    |
//+------------------------------------------------------------------+
#property copyright "JAS"
#property version   "1.00"

#include <Trade\Trade.mqh>
#define EA_BUILD "d1"

CTrade trade;

string Pick(bool c, string a, string b) { if(c) return(a); return(b); }

//--------------------------- INPUTS -----------------------------------
input bool            InpTrade      = true;       // true = asal kaam; false = sirf panel
input bool            InpDemoOnly   = true;       // true = REAL account par koi trade nahi
input double          InpLot        = 0.01;       // Har lot (0.01 se bari kabhi nahi)
input double          InpStep       = 10.0;       // Qeemat kitne $ hile tab nayi lot ka mauqa
input double          InpTP         = 20.0;       // Har lot ka nafa ($)
input double          InpSL         = 20.0;       // Har lot ke nuqsan ki hadd ($)
input int             InpMaxPos     = 5;          // Ek waqt mein zyada se zyada lots
input bool            InpUseTrend   = true;       // Sirf rukh ke saath (girawat par BUY sirf UP rukh mein)
input ENUM_TIMEFRAMES InpTrendTF    = PERIOD_H1;  // Rukh kis timeframe se
input int             InpTrendEMA   = 50;         // Rukh ki EMA
input double          InpMaxSpread  = 0.50;       // Spread ($) is se zyada to nayi lot nahi
input double          InpEqHaltPct  = 90.0;       // Equity (lagate waqt ki) is % se neeche: lots band + ruk
input int             InpFriNoStart = 19;         // Jumma ko is ghante (server) se nayi lot nahi
input bool            InpReset      = false;      // true = ginti / ruka hua nishan saaf (ek dafa lagate waqt)
input int             InpMagic      = 20261111;   // EA ki apni lots ka nishan

//--------------------------- GLOBAL STATE ------------------------------
int      hEma   = INVALID_HANDLE;
double   gRef   = 0;
string   gLast  = "abhi koi mauqa nahi aaya";
double   gReal  = 0;
int      gDone  = 0;
datetime gRealT = 0;

string Key(string k) { return(StringFormat("JFD_%s_%I64d_%s", k, AccountInfoInteger(ACCOUNT_LOGIN), _Symbol)); }
string M2(double v)  { return(DoubleToString(v, 2)); }
string Px(double v)  { return(DoubleToString(v, (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS))); }

bool IsMine()
  {
   return(PositionGetString(POSITION_SYMBOL) == _Symbol && PositionGetInteger(POSITION_MAGIC) == InpMagic);
  }

// apni khuli lots ki ginti + khula nafa / nuqsan
int Mine(double &flo)
  {
   int n = 0;
   flo = 0;
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      ulong t = PositionGetTicket(i);
      if(t == 0 || !IsMine()) continue;
      n++;
      flo += PositionGetDouble(POSITION_PROFIT) + PositionGetDouble(POSITION_SWAP);
     }
   return(n);
  }

void CloseMine()
  {
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      ulong t = PositionGetTicket(i);
      if(t == 0 || !IsMine()) continue;
      trade.PositionClose(t);
     }
  }

// rukh: 1 = UP, -1 = DOWN, 0 = pata nahi
int Trend()
  {
   double b[1];
   if(CopyBuffer(hEma, 0, 0, 1, b) != 1) return(0);
   double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   if(bid > b[0]) return(1);
   if(bid < b[0]) return(-1);
   return(0);
  }

// EA ki band lots ka kul nateeja (lagane ke waqt se) - har 30 second mein ek dafa
void CalcReal()
  {
   if(gRealT > 0 && TimeCurrent() - gRealT < 30) return;
   gRealT = TimeCurrent();
   datetime t0 = (datetime)GlobalVariableGet(Key("T0"));
   if(!HistorySelect(t0, TimeCurrent() + 86400)) return;
   long ids[];
   int k = 0, tot = HistoryDealsTotal();
   for(int i = 0; i < tot; i++)
     {
      ulong d = HistoryDealGetTicket(i);
      if(d == 0) continue;
      if(HistoryDealGetString(d, DEAL_SYMBOL) != _Symbol) continue;
      if(HistoryDealGetInteger(d, DEAL_MAGIC) != InpMagic) continue;
      if(HistoryDealGetInteger(d, DEAL_ENTRY) != DEAL_ENTRY_IN) continue;
      ArrayResize(ids, k + 1);
      ids[k] = HistoryDealGetInteger(d, DEAL_POSITION_ID);
      k++;
     }
   double s = 0;
   int done = 0;
   for(int i = 0; i < tot; i++)
     {
      ulong d = HistoryDealGetTicket(i);
      if(d == 0) continue;
      if(HistoryDealGetString(d, DEAL_SYMBOL) != _Symbol) continue;
      if(HistoryDealGetInteger(d, DEAL_ENTRY) == DEAL_ENTRY_IN) continue;
      long pid = HistoryDealGetInteger(d, DEAL_POSITION_ID);
      bool mine = false;
      for(int j = 0; j < k; j++)
         if(ids[j] == pid) { mine = true; break; }
      if(!mine) continue;
      s += HistoryDealGetDouble(d, DEAL_PROFIT) + HistoryDealGetDouble(d, DEAL_SWAP) + HistoryDealGetDouble(d, DEAL_COMMISSION);
      done++;
     }
   gReal = s;
   gDone = done;
  }

bool OpenLot(int d, double bid, double ask)
  {
   double lot = MathMax(SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN), MathMin(InpLot, 0.01));
   int dg = (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS);
   bool ok = false;
   if(d > 0)
      ok = trade.Buy(lot, _Symbol, 0.0, NormalizeDouble(ask - InpSL, dg), NormalizeDouble(ask + InpTP, dg), "JFD");
   else
      ok = trade.Sell(lot, _Symbol, 0.0, NormalizeDouble(bid + InpSL, dg), NormalizeDouble(bid - InpTP, dg), "JFD");
   uint rc = trade.ResultRetcode();
   bool good = (ok && (rc == TRADE_RETCODE_DONE || rc == TRADE_RETCODE_PLACED));
   Print(StringFormat("JasFishDemo %s: %s 0.01 %s (%d %s)", EA_BUILD, Pick(d > 0, "BUY", "SELL"), Pick(good, "khuli", "NAHI khuli"), (int)rc, trade.ResultRetcodeDescription()));
   return(good);
  }

void Run()
  {
   double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID), ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   if(bid <= 0 || ask <= 0) return;
   double mid = (bid + ask) / 2.0, flo = 0;
   int n = Mine(flo);
   bool demo = (AccountInfoInteger(ACCOUNT_TRADE_MODE) == ACCOUNT_TRADE_MODE_DEMO);
   bool halt = GlobalVariableCheck(Key("HALT"));
   double eq0 = GlobalVariableGet(Key("EQ0")), eq = AccountInfoDouble(ACCOUNT_EQUITY);
   bool can = (InpTrade && (demo || !InpDemoOnly));
   if(can && !halt && eq0 > 0 && eq < eq0 * InpEqHaltPct / 100.0)
     {
      GlobalVariableSet(Key("HALT"), 1);
      halt = true;
      CloseMine();
      Print(StringFormat("JasFishDemo %s: equity %s < %s%% - lots band, EA ruk gaya", EA_BUILD, M2(eq), DoubleToString(InpEqHaltPct, 0)));
     }
   int tr = Trend();
   MqlDateTime dt;
   TimeToStruct(TimeCurrent(), dt);
   bool fri = (dt.day_of_week == 5 && dt.hour >= InpFriNoStart);
   bool algo = (TerminalInfoInteger(TERMINAL_TRADE_ALLOWED) && MQLInfoInteger(MQL_TRADE_ALLOWED));

   string why = "";
   if(!InpTrade) why = "InpTrade false - sirf panel";
   else if(InpDemoOnly && !demo) why = "ye REAL account hai - EA sirf DEMO par trade karta hai";
   else if(halt) why = StringFormat("equity %s%% se neeche gayi thi - dobara ke liye InpReset true", DoubleToString(InpEqHaltPct, 0));
   else if(!algo) why = "Algo Trading band hai";

   if(gRef <= 0) gRef = mid;
   double mv = mid - gRef;
   if(MathAbs(mv) >= InpStep)
     {
      int d = 1;
      if(mv > 0) d = -1;          // charhi to SELL, giri to BUY
      gRef = mid;
      GlobalVariableSet(Key("REF"), gRef);
      string skip = why;
      if(skip == "" && InpUseTrend && tr != d) skip = "rukh ke khilaf";
      if(skip == "" && n >= InpMaxPos)         skip = "lots ki hadd poori";
      if(skip == "" && ask - bid > InpMaxSpread) skip = "spread zyada";
      if(skip == "" && fri)                    skip = "Jumma shaam";
      if(skip == "")
        {
         bool ok = OpenLot(d, bid, ask);
         gLast = StringFormat("%s  %s @ %s  %s", TimeToString(TimeCurrent(), TIME_MINUTES), Pick(d > 0, "BUY", "SELL"), Px(mid), Pick(ok, "khuli", "order FAIL"));
         if(ok) n++;
        }
      else
         gLast = StringFormat("%s  %s ka mauqa @ %s chhora: %s", TimeToString(TimeCurrent(), TIME_MINUTES), Pick(d > 0, "BUY", "SELL"), Px(mid), skip);
     }

   CalcReal();
   string tx = "";
   tx += StringFormat("JAS FISH DEMO  BUILD %s  -  %s  -  %s\n", EA_BUILD, _Symbol, Pick(demo, "DEMO account", "REAL account"));
   tx += StringFormat("Qaida: qadam $%s | nafa $%s | nuqsan hadd $%s | lot 0.01 | hadd %d lots\n", M2(InpStep), M2(InpTP), M2(InpSL), InpMaxPos);
   tx += StringFormat("Rukh (%s EMA%d): %s\n", EnumToString(InpTrendTF), InpTrendEMA, Pick(tr > 0, "UP - sirf girawat par BUY", Pick(tr < 0, "DOWN - sirf charhai par SELL", "pata nahi")));
   tx += StringFormat("Nishan %s | agla BUY mauqa %s | agla SELL mauqa %s\n", Px(gRef), Px(gRef - InpStep), Px(gRef + InpStep));
   tx += StringFormat("Khuli lots %d / %d | khula %s\n", n, InpMaxPos, M2(flo));
   tx += StringFormat("Band lots %d | pakka nateeja %s | kul (pakka + khula) %s\n", gDone, M2(gReal), M2(gReal + flo));
   tx += StringFormat("Equity %s (lagate waqt %s, rok %s)\n", M2(eq), M2(eq0), M2(eq0 * InpEqHaltPct / 100.0));
   tx += StringFormat("Aakhri kaam: %s\n", gLast);
   tx += StringFormat("%s\n", Pick(why == "", "Sab saaf", "Ruka hua: " + why));
   Comment(tx);
  }

int OnInit()
  {
   trade.SetExpertMagicNumber(InpMagic);
   trade.SetDeviationInPoints(50);
   trade.SetTypeFillingBySymbol(_Symbol);
   hEma = iMA(_Symbol, InpTrendTF, InpTrendEMA, 0, MODE_EMA, PRICE_CLOSE);
   if(hEma == INVALID_HANDLE) return(INIT_FAILED);
   if(InpReset)
     {
      GlobalVariableDel(Key("EQ0"));
      GlobalVariableDel(Key("HALT"));
      GlobalVariableDel(Key("REF"));
      GlobalVariableDel(Key("T0"));
     }
   if(!GlobalVariableCheck(Key("EQ0"))) GlobalVariableSet(Key("EQ0"), AccountInfoDouble(ACCOUNT_EQUITY));
   if(!GlobalVariableCheck(Key("T0")))  GlobalVariableSet(Key("T0"), (double)TimeCurrent());
   double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID), ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   double mid = (bid + ask) / 2.0;
   gRef = mid;
   if(GlobalVariableCheck(Key("REF")))
     {
      double r = GlobalVariableGet(Key("REF"));
      if(r > 0 && MathAbs(mid - r) < 3.0 * InpStep) gRef = r;   // purana nishan sirf jab qareeb ho
     }
   EventSetTimer(2);
   Run();
   return(INIT_SUCCEEDED);
  }

void OnDeinit(const int reason)
  {
   EventKillTimer();
   if(hEma != INVALID_HANDLE) IndicatorRelease(hEma);
   Comment("");
  }

void OnTick()  { Run(); }
void OnTimer() { Run(); }
//+------------------------------------------------------------------+
