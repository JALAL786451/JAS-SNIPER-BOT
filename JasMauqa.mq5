//+------------------------------------------------------------------+
//|  JAS MAUQA   -   build m2  (3 Nov 2026)                          |
//|  m2 = DeskView ka zaroori STATUS + mauqa par KHUD YES/NO popup   |
//|       (Algo hara ho to), 15 min wait, tickets 180/200 bachao.    |
//|  m1 = button wala (InpDikhana) - hataya.                         |
//|                                                                  |
//|  EA. KHUD KOI NAYI LOT NAHI KHOLTA. Sirf chart ke symbol par.    |
//|  STATUS (hamesha): KUL P/L, equity, NET lot, $1 = kitna,         |
//|    stop out door, barabar ka price, BUY/SELL ginti+ausat,        |
//|    tickets (khuli + pending) / 200.                              |
//|  MAUQA (sirf MUSBAT, tarteeb):                                   |
//|    A) BARI SELL KAM : sab se bari SELL + ek BUY, Close By > hadd |
//|    B) JORI          : koi SELL + BUY, Close By > hadd            |
//|    C) FAIDE WALI TICKET band > hadd (tickets 180+ ho to C nahi)  |
//|  Algo HARA  -> mauqa mile to popup: detail + YES / NO.           |
//|              YES = sirf wahi ek kaam. NO = kuch nahi.            |
//|              Agla popup kam az kam 15 min baad.                  |
//|  Algo LAAL  -> sirf status, popup nahi.                          |
//+------------------------------------------------------------------+
#property copyright "JAS"
#property version   "2.00"

#include <Trade\Trade.mqh>

#define S_BUILD "m2"

input double InpMinFaida = 20.0;   // C) Ticket ka faida kam az kam (USC)
input double InpMinJori  = 5.0;    // A/B) Jori (Close By) ka nateeja kam az kam (USC)
input int    InpHadd     = 200;    // Broker ticket hadd (khuli + pending)
input int    InpBachao   = 180;    // Is se zyada tickets = laal + sirf jori (ticket ghatane wali)
input int    InpWaitMin  = 15;     // Popup ke baad agla popup kitne minute baad
input bool   InpPush     = true;   // Popup ke waqt phone push bhi

CTrade trade;

struct PInfo { ulong t; long typ; double vol; double open; double pnl; };

datetime gNext = 0;

string Pick(bool c, string a, string b) { if(c) return(a); return(b); }
string Px(double v) { return(DoubleToString(v, (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS))); }
string M(double v)  { return(DoubleToString(v, 2)); }

double Vpp()
  {
   double tv = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);
   double ts = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);
   if(ts <= 0) return(0);
   return(tv / ts);   // 1 lot par qeemat 1.0 hile to kitna (account currency)
  }

int Gather(PInfo &a[])
  {
   ArrayResize(a, 0);
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      ulong t = PositionGetTicket(i);
      if(t == 0 || PositionGetString(POSITION_SYMBOL) != _Symbol) continue;
      int n = ArraySize(a);
      ArrayResize(a, n + 1);
      a[n].t = t;
      a[n].typ = PositionGetInteger(POSITION_TYPE);
      a[n].vol = PositionGetDouble(POSITION_VOLUME);
      a[n].open = PositionGetDouble(POSITION_PRICE_OPEN);
      a[n].pnl = PositionGetDouble(POSITION_PROFIT) + PositionGetDouble(POSITION_SWAP);
     }
   return(ArraySize(a));
  }

bool AlgoOn() { return(TerminalInfoInteger(TERMINAL_TRADE_ALLOWED) && MQLInfoInteger(MQL_TRADE_ALLOWED)); }

string Desc(ulong t)
  {
   if(!PositionSelectByTicket(t)) return(StringFormat("#%I64u (band ho chuki)", t));
   return(StringFormat("#%I64u %s %.2f @ %s  (abhi %s)", t, Pick(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL, "SELL", "BUY"),
                       PositionGetDouble(POSITION_VOLUME), Px(PositionGetDouble(POSITION_PRICE_OPEN)),
                       M(PositionGetDouble(POSITION_PROFIT) + PositionGetDouble(POSITION_SWAP))));
  }

void Run()
  {
   PInfo a[];
   int n = Gather(a);
   double vpp = Vpp();
   double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   // ---- STATUS
   double kul = 0, bl = 0, sl = 0, bo = 0, so = 0, bp = 0, sp = 0;
   int bc = 0, sc = 0, big = -1;
   for(int i = 0; i < n; i++)
     {
      kul += a[i].pnl;
      if(a[i].typ == POSITION_TYPE_BUY) { bc++; bl += a[i].vol; bo += a[i].vol * a[i].open; bp += a[i].pnl; }
      else
        {
         sc++; sl += a[i].vol; so += a[i].vol * a[i].open; sp += a[i].pnl;
         if(big < 0 || a[i].vol > a[big].vol) big = i;
        }
     }
   double net = bl - sl;
   double eq = AccountInfoDouble(ACCOUNT_EQUITY);
   double mg = AccountInfoDouble(ACCOUNT_MARGIN);
   double soLvl = AccountInfoDouble(ACCOUNT_MARGIN_SO_SO);
   double perD = net * vpp;                       // qeemat $1 upar = itna (manfi = nuqsan)
   string be = "-", door = "-";
   if(MathAbs(perD) > 1e-9)
     {
      be = Px(bid - kul / perD);
      double free = eq - mg * soLvl / 100.0;
      double d = free / MathAbs(perD);
      door = StringFormat("~%s door (qeemat ~%s)", DoubleToString(d, 3), Px(bid - (net > 0 ? 1 : -1) * d));
     }
   int tk = PositionsTotal() + OrdersTotal();
   bool full = tk > InpBachao;
   string s = StringFormat("=== JAS MAUQA %s ===  %s  |  Algo %s  |  nayi lot KABHI nahi kholta\n", S_BUILD, _Symbol, Pick(AlgoOn(), "HARA = mauqa par YES/NO", "LAAL = sirf status"));
   s += StringFormat("KUL P/L %s   EQUITY %s\n", M(kul), M(eq));
   s += StringFormat("NET %+.2f lot: qeemat $1 %s = %s\n", net, Pick(net >= 0, "gire", "chadhe"), M(MathAbs(perD)));
   s += StringFormat("STOP OUT: %s\n", door);
   s += StringFormat("BARABAR KA PRICE: %s   (abhi %s)\n", be, Px(bid));
   s += StringFormat("BUY  : ginti %d  lots %.2f  ausat %s  P/L %s\n", bc, bl, Pick(bl > 0, Px(bl > 0 ? bo / bl : 0), "-"), M(bp));
   s += StringFormat("SELL : ginti %d  lots %.2f  ausat %s  P/L %s\n", sc, sl, Pick(sl > 0, Px(sl > 0 ? so / sl : 0), "-"), M(sp));
   s += StringFormat("TICKETS: %d / %d  (bachao %d)  %s\n\n", tk, InpHadd, InpBachao, Pick(full, "!!! ZYADA - sirf jori (ticket ghatao)", "theek"));
   // ---- MAUQA
   ulong aS = 0, aB = 0, jS = 0, jB = 0, cT = 0;
   double aV = 0, jV = 0, cV = 0;
   for(int i = 0; i < n; i++)
     {
      if(a[i].pnl >= InpMinFaida && a[i].pnl > cV) { cT = a[i].t; cV = a[i].pnl; }
      if(a[i].typ != POSITION_TYPE_SELL) continue;
      for(int j = 0; j < n; j++)
        {
         if(a[j].typ != POSITION_TYPE_BUY) continue;
         double r = (a[i].open - a[j].open) * MathMin(a[i].vol, a[j].vol) * vpp;
         if(r < InpMinJori) continue;
         if(r > jV) { jS = a[i].t; jB = a[j].t; jV = r; }
         if(i == big && r > aV) { aS = a[i].t; aB = a[j].t; aV = r; }
        }
     }
   if(full) { cT = 0; cV = 0; }
   s += Pick(aS > 0, StringFormat("A) BARI SELL KAM: SELL #%I64u + BUY #%I64u = +%s", aS, aB, M(aV)), "A) Bari SELL ki musbat jori: abhi nahi") + "\n";
   s += Pick(jS > 0, StringFormat("B) JORI: SELL #%I64u + BUY #%I64u = +%s", jS, jB, M(jV)), "B) Musbat jori: abhi nahi") + "\n";
   s += Pick(cT > 0, StringFormat("C) FAIDE WALI TICKET #%I64u = +%s", cT, M(cV)), StringFormat("C) Faide wali ticket (>= %s): %s", M(InpMinFaida), Pick(full, "band (tickets zyada)", "abhi nahi"))) + "\n";
   int wait = (int)(gNext - TimeCurrent());
   s += Pick(wait > 0, StringFormat("Agla popup %d min baad", wait / 60 + 1), "Popup tayyar");
   Comment(s);
   // ---- POPUP (sirf Algo hara, wait khatam, mauqa ho)
   if(!AlgoOn() || TimeCurrent() < gNext) return;
   int kind = 0; ulong t1 = 0, t2 = 0; double v = 0; string nm = "";
   if(aS > 0)      { kind = 1; t1 = aS; t2 = aB; v = aV; nm = "A) BARI SELL KAM"; }
   else if(jS > 0) { kind = 1; t1 = jS; t2 = jB; v = jV; nm = "B) JORI"; }
   else if(cT > 0) { kind = 2; t1 = cT; v = cV; nm = "C) FAIDE WALI TICKET"; }
   if(kind == 0) return;
   gNext = TimeCurrent() + InpWaitMin * 60;
   bool demo = AccountInfoInteger(ACCOUNT_TRADE_MODE) == ACCOUNT_TRADE_MODE_DEMO;
   string d = StringFormat("Account %I64d  (%s)\n\n%s\n\n", AccountInfoInteger(ACCOUNT_LOGIN), Pick(demo, "DEMO", "LIVE - ASLI PAISA"), nm);
   if(kind == 1)
      d += StringFormat("%s\n%s\n\nClose By (spread nahi, nayi lot nahi)\nNateeja: +%s\nKyun: SELL ki qeemat BUY se upar = jori musbat\nTickets: %d -> %d ya %d\n",
                        Desc(t1), Desc(t2), M(v), tk, tk - 2, tk - 1);
   else
      d += StringFormat("%s\n\nBazaar par band\nFaida pakka: +%s\nTickets: %d -> %d\nDhyan: is se NET lot badlega\n", Desc(t1), M(v), tk, tk - 1);
   if(InpPush) SendNotification(StringFormat("JAS MAUQA %s: %s +%s - MT5 par YES/NO", _Symbol, nm, M(v)));
   int ans = MessageBox(d + "\nKarna hai?", "JAS MAUQA " + S_BUILD + "  -  " + _Symbol, MB_YESNO | MB_ICONQUESTION | MB_DEFBUTTON2);
   if(ans != IDYES) { Print("JAS MAUQA ", S_BUILD, ": NO - ", nm); return; }
   if(!AlgoOn() || !PositionSelectByTicket(t1) || (kind == 1 && !PositionSelectByTicket(t2)))
     { MessageBox("Algo laal ho gaya ya lot badal gayi - kuch nahi kiya.", "JAS MAUQA " + S_BUILD, MB_OK | MB_ICONWARNING); return; }
   bool ok;
   if(kind == 1) ok = trade.PositionCloseBy(t1, t2);
   else          ok = trade.PositionClose(t1);
   string r = StringFormat("%s: %s  (%d %s)", nm, Pick(ok, "HO GAYA", "FAIL"), (int)trade.ResultRetcode(), trade.ResultRetcodeDescription());
   Print("JAS MAUQA ", S_BUILD, ": ", r);
   MessageBox(r, "JAS MAUQA " + S_BUILD + " - nateeja", MB_OK);
  }

int OnInit()
  {
   gNext = TimeCurrent() + 60;   // lagate hi popup nahi - 1 min baad
   EventSetTimer(3);
   Run();
   return(INIT_SUCCEEDED);
  }

void OnDeinit(const int reason) { EventKillTimer(); Comment(""); }
void OnTimer() { Run(); }
void OnTick()  { }
//+------------------------------------------------------------------+
