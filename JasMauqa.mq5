//+------------------------------------------------------------------+
//|  JAS MAUQA   -   build m3  (3 Nov 2026)                          |
//|  m6 = HIFAZAT: C mein bari SELL kabhi nahi; C/D sirf jab NET +0.10 |
//|       se zyada na barhe, NET max 0.80, stop out >= 400 $; naya D =  |
//|       bari SELL profit mein ho to 0.10 part close                |
//|  m5 = PRICE LADDER: gold -25/+25/+50/+100/breakeven par kitni   |
//|       ticket profit mein + TOTAL (InpLadder, InpStep)           |
//|  m4 = panel + popup aasan English (ON/OFF, PROFIT/LOSS, PAIR)   |
//|  m3 = bara font panel (InpFont), rang, faide/nuqsan wali ginti   |
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
//|  Algo ON    -> mauqa mile to popup: detail + YES / NO.           |
//|              YES = sirf wahi ek kaam. NO = kuch nahi.            |
//|              Agla popup kam az kam 15 min baad.                  |
//|  Algo OFF   -> sirf status, popup nahi.                          |
//+------------------------------------------------------------------+
#property copyright "JAS"
#property version   "6.00"

#include <Trade\Trade.mqh>

#define S_BUILD "m6"

input double InpMinFaida = 20.0;   // C) Ticket ka faida kam az kam (USC)
input double InpMinJori  = 5.0;    // A/B) Jori (Close By) ka nateeja kam az kam (USC)
input int    InpHadd     = 200;    // Broker ticket hadd (khuli + pending)
input int    InpBachao   = 180;    // Is se zyada tickets = laal + sirf jori (ticket ghatane wali)
input int    InpWaitMin  = 15;     // Popup ke baad agla popup kitne minute baad
input double InpNetMove  = 0.10;   // HIFAZAT: ek kaam se |NET| zyada se zyada itna barhe
input double InpMaxNet   = 0.80;   // HIFAZAT: |NET| is se upar na jaye (abhi zyada ho to barhe nahi)
input double InpMinDoor  = 400.0;  // HIFAZAT: stop out kam az kam itne $ door rahe
input double InpPartLot  = 0.10;   // D) Bari SELL profit mein ho to ek dafa kitni lot kam
input bool   InpPush     = true;   // Popup ke waqt phone push bhi
input int    InpFont     = 13;     // Panel ka font (bara = 14-16)
input bool   InpLadder   = true;   // PRICE LADDER dikhao
input double InpStep     = 25.0;   // LADDER ka qadam ($): -1, +1, +2, +4 qadam + breakeven

CTrade trade;

struct PInfo { ulong t; long typ; double vol; double open; double pnl; };

datetime gNext = 0;
int gRow = 0;

void Ln(string tx, color c)
  {
   string nm = "JM_L" + IntegerToString(gRow);
   if(ObjectFind(0, nm) < 0)
     {
      ObjectCreate(0, nm, OBJ_LABEL, 0, 0, 0);
      ObjectSetInteger(0, nm, OBJPROP_CORNER, CORNER_LEFT_UPPER);
      ObjectSetInteger(0, nm, OBJPROP_SELECTABLE, false);
      ObjectSetString(0, nm, OBJPROP_FONT, "Consolas");
     }
   ObjectSetInteger(0, nm, OBJPROP_XDISTANCE, 12);
   ObjectSetInteger(0, nm, OBJPROP_YDISTANCE, 22 + gRow * (int)(InpFont * 2.0));
   ObjectSetInteger(0, nm, OBJPROP_FONTSIZE, InpFont);
   ObjectSetInteger(0, nm, OBJPROP_COLOR, c);
   ObjectSetString(0, nm, OBJPROP_TEXT, tx);
   gRow++;
  }

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

// HIFAZAT: naya NET (|n2|) zyada na barhe aur stop out door InpMinDoor se kam na ho
bool Safe(double n2, double n1, double freeE, double vpp)
  {
   if(MathAbs(n2) > MathAbs(n1) + InpNetMove + 1e-9) return(false);
   if(MathAbs(n2) > MathMax(InpMaxNet, MathAbs(n1)) + 1e-9) return(false);
   if(MathAbs(n2) * vpp <= 1e-9) return(true);
   return(freeE / (MathAbs(n2) * vpp) >= InpMinDoor);
  }

bool AlgoOn() { return(TerminalInfoInteger(TERMINAL_TRADE_ALLOWED) && MQLInfoInteger(MQL_TRADE_ALLOWED)); }

string Desc(ulong t)
  {
   if(!PositionSelectByTicket(t)) return(StringFormat("#%I64u (already closed)", t));
   return(StringFormat("#%I64u %s %.2f @ %s  (now %s)", t, Pick(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL, "SELL", "BUY"),
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
   double kul = 0, bl = 0, sl = 0, bo = 0, so = 0, bp = 0, sp = 0, fp = 0, lp = 0, fl = 0, ll = 0;
   int bc = 0, sc = 0, big = -1, fc = 0, lc = 0;
   for(int i = 0; i < n; i++)
     {
      kul += a[i].pnl;
      if(a[i].pnl >= 0) { fc++; fl += a[i].vol; fp += a[i].pnl; } else { lc++; ll += a[i].vol; lp += a[i].pnl; }
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
   double perD = net * vpp;
   string be = "-", door = "-";
   if(MathAbs(perD) > 1e-9)
     {
      be = Px(bid - kul / perD);
      double free = eq - mg * soLvl / 100.0;
      double d = free / MathAbs(perD);
      door = StringFormat("%s away (price %s)", DoubleToString(d, 1), Px(bid - (net > 0 ? 1 : -1) * d));
     }
   int tk = PositionsTotal() + OrdersTotal();
   bool full = tk > InpBachao;
   double freeE = eq - mg * soLvl / 100.0;
   // ---- MAUQA
   ulong aS = 0, aB = 0, jS = 0, jB = 0, cT = 0;
   double aV = 0, jV = 0, cV = 0;
   for(int i = 0; i < n; i++)
     {
      if(i != big && a[i].pnl >= InpMinFaida && a[i].pnl > cV)
        {
         double na_ = (a[i].typ == POSITION_TYPE_BUY) ? net - a[i].vol : net + a[i].vol;
         if(Safe(na_, net, freeE, vpp)) { cT = a[i].t; cV = a[i].pnl; }
        }
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
   // D) BARI SELL profit mein: thori lot kam (hifazat ke andar)
   ulong dT = 0; double dLot = 0, dV = 0;
   if(big >= 0 && a[big].pnl > 0)
     {
      double stp = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP), mnv = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
      double x = MathFloor(MathMin(InpPartLot, a[big].vol - mnv) / stp + 1e-9) * stp;
      double pv = a[big].pnl * x / a[big].vol;
      if(x >= mnv && pv >= InpMinJori && Safe(net + x, net, freeE, vpp)) { dT = a[big].t; dLot = NormalizeDouble(x, 2); dV = pv; }
     }
   int wait = (int)(gNext - TimeCurrent());
   // ---- PANEL (bara font, rang)
   color cG = clrLime, cR = clrTomato, cW = clrWhite, cY = clrGold, cC = clrAqua;
   gRow = 0;
   Ln(StringFormat("JAS MAUQA %s  -  %s  -  Algo %s", S_BUILD, _Symbol, Pick(AlgoOn(), "ON (YES/NO popup)", "OFF (only status)")), AlgoOn() ? cG : cY);
   Ln(StringFormat("TOTAL P/L  %s        EQUITY  %s", M(kul), M(eq)), kul >= 0 ? cG : cR);
   Ln(StringFormat("PROFIT  %d ticket  %.2f lot   +%s", fc, fl, M(fp)), cG);
   Ln(StringFormat("LOSS    %d ticket  %.2f lot   %s", lc, ll, M(lp)), cR);
   Ln(StringFormat("BUY   %d ticket  %.2f lot  avg %s   P/L %s", bc, bl, Pick(bl > 0, Px(bl > 0 ? bo / bl : 0), "-"), M(bp)), bp >= 0 ? cG : cR);
   Ln(StringFormat("SELL  %d ticket  %.2f lot  avg %s   P/L %s", sc, sl, Pick(sl > 0, Px(sl > 0 ? so / sl : 0), "-"), M(sp)), sp >= 0 ? cG : cR);
   Ln(StringFormat("NET %+.2f lot  -  price $1 %s = %s", net, Pick(net >= 0, "down", "up"), M(-MathAbs(perD))), cC);
   Ln(StringFormat("BREAKEVEN PRICE  %s   (now %s)", be, Px(bid)), cC);
   Ln("STOP OUT  " + door, cY);
   // PRICE LADDER: qeemat P par kitni lots profit mein + TOTAL (NET se seedha hisaab, swap / spread nahi)
   if(InpLadder && n > 0)
     {
      double lv[6];
      lv[0] = bid - InpStep; lv[1] = bid + InpStep; lv[2] = bid + 2 * InpStep; lv[3] = bid + 4 * InpStep;
      lv[4] = (MathAbs(perD) > 1e-9) ? bid - kul / perD : 0; lv[5] = 0;
      for(int q = 0; q < 5; q++)
        {
         double P = lv[q];
         if(P <= 0) continue;
         int pc = 0;
         for(int i = 0; i < n; i++)
            if((a[i].typ == POSITION_TYPE_BUY && a[i].open < P) || (a[i].typ == POSITION_TYPE_SELL && a[i].open > P)) pc++;
         double tot = kul + perD * (P - bid);
         string tag = Pick(q == 4, "  <- BREAKEVEN", "");
         Ln(StringFormat("LADDER  gold %s (%+.0f) -> %d ticket profit, TOTAL %s%s", Px(P), P - bid, pc, M(tot), tag), tot >= 0 ? cG : (q == 0 ? cR : cC));
        }
     }
   Ln(StringFormat("TICKETS  %d / %d   (bachao %d)  %s", tk, InpHadd, InpBachao, Pick(full, "TOO MANY - only pair close", "OK")), full ? cR : cW);
   Ln(Pick(aS > 0, StringFormat("A) BIG SELL REDUCE  #%I64u + #%I64u  = +%s", aS, aB, M(aV)), "A) Big SELL reduce: none now"), aS > 0 ? cG : cW);
   Ln(Pick(jS > 0, StringFormat("B) PAIR CLOSE  #%I64u + #%I64u  = +%s", jS, jB, M(jV)), "B) Pair close: none now"), jS > 0 ? cG : cW);
   Ln(Pick(dT > 0, StringFormat("D) BIG SELL PART CLOSE  #%I64u  %.2f lot  = +%s  (NET %+.2f -> %+.2f)", dT, dLot, M(dV), net, net + dLot), "D) Big SELL part close: none now (SELL loss ya hifazat)"), dT > 0 ? cG : cW);
   Ln(Pick(cT > 0, StringFormat("C) PROFIT TICKET CLOSE  #%I64u  = +%s", cT, M(cV)), "C) Profit ticket close: " + Pick(full, "OFF (too many tickets)", "none now (big SELL kabhi nahi)")), cT > 0 ? cG : cW);
   Ln(StringFormat("HIFAZAT: NET max %.2f | ek kaam se +%.2f | stop out min %s $ door", InpMaxNet, InpNetMove, DoubleToString(InpMinDoor, 0)), cY);
   Ln(Pick(wait > 0, StringFormat("Next popup in %d min", wait / 60 + 1), "Popup READY"), cW);
   for(int k = gRow; k < 30; k++) ObjectDelete(0, "JM_L" + IntegerToString(k));
   // ---- POPUP (sirf Algo hara, wait khatam, mauqa ho)
   if(!AlgoOn() || TimeCurrent() < gNext) return;
   int kind = 0; ulong t1 = 0, t2 = 0; double v = 0; string nm = "";
   if(aS > 0)      { kind = 1; t1 = aS; t2 = aB; v = aV; nm = "A) BIG SELL REDUCE"; }
   else if(jS > 0) { kind = 1; t1 = jS; t2 = jB; v = jV; nm = "B) PAIR CLOSE"; }
   else if(dT > 0) { kind = 3; t1 = dT; v = dV; nm = "D) BIG SELL PART CLOSE"; }
   else if(cT > 0) { kind = 2; t1 = cT; v = cV; nm = "C) PROFIT TICKET CLOSE"; }
   if(kind == 0) return;
   gNext = TimeCurrent() + InpWaitMin * 60;
   bool demo = AccountInfoInteger(ACCOUNT_TRADE_MODE) == ACCOUNT_TRADE_MODE_DEMO;
   string d = StringFormat("Account %I64d  (%s)\n\n%s\n\n", AccountInfoInteger(ACCOUNT_LOGIN), Pick(demo, "DEMO", "LIVE - ASLI PAISA"), nm);
   if(kind == 1)
      d += StringFormat("%s\n%s\n\nClose By (no spread, no new lot)\nResult: +%s\nWhy: SELL price above BUY price = profit pair\nTickets: %d -> %d or %d\n",
                        Desc(t1), Desc(t2), M(v), tk, tk - 2, tk - 1);
   else if(kind == 3)
      d += StringFormat("%s\n\nPart close %.2f lot at market (baqi %s wahin)\nProfit lock: +%s\nNET %+.2f -> %+.2f (hifazat ke andar)\nNote: equity foran nahi barhti - floating profit balance mein pakka hota hai\n",
                        Desc(t1), dLot, "SELL", M(v), net, net + dLot);
   else
      d += StringFormat("%s\n\nClose at market\nProfit: +%s\nTickets: %d -> %d\nNET change hifazat ke andar\n", Desc(t1), M(v), tk, tk - 1);
   if(InpPush) SendNotification(StringFormat("JAS MAUQA %s: %s +%s - YES/NO on MT5", _Symbol, nm, M(v)));
   int ans = MessageBox(d + "\nDo it?", "JAS MAUQA " + S_BUILD + "  -  " + _Symbol, MB_YESNO | MB_ICONQUESTION | MB_DEFBUTTON2);
   if(ans != IDYES) { Print("JAS MAUQA ", S_BUILD, ": NO - ", nm); return; }
   if(!AlgoOn() || !PositionSelectByTicket(t1) || (kind == 1 && !PositionSelectByTicket(t2)))
     { MessageBox("Algo OFF or ticket changed - nothing done.", "JAS MAUQA " + S_BUILD, MB_OK | MB_ICONWARNING); return; }
   bool ok;
   if(kind == 1) ok = trade.PositionCloseBy(t1, t2);
   else if(kind == 3) ok = trade.PositionClosePartial(t1, dLot);
   else          ok = trade.PositionClose(t1);
   string r = StringFormat("%s: %s  (%d %s)", nm, Pick(ok, "DONE", "FAIL"), (int)trade.ResultRetcode(), trade.ResultRetcodeDescription());
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

void OnDeinit(const int reason) { EventKillTimer(); ObjectsDeleteAll(0, "JM_L"); Comment(""); }
void OnTimer() { Run(); }
void OnTick()  { }
//+------------------------------------------------------------------+
