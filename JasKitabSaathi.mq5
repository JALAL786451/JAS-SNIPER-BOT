// JasKitabSaathi x1 - khuli kitab ka saathi: status + Yes/No buttons. KHUD KOI TRADE NAHI, NAYI LOT KABHI NAHI (16 Oct 2026)
//+------------------------------------------------------------------+
//| Chart ke symbol (XAUUSDc) ki SAARI lots (haath ki bhi) dekhta hai.|
//|  - Panel: NET, equity, har $1 par USC, stop out andaza, faide    |
//|    wali lots, khule NET ka faida.                                |
//|  - Button "NET BUY / NET SELL kholo": ulti taraf ki sirf FAIDE    |
//|    wali lots band (InpNetLot), NET kabhi 0.50 se zyada nahi.     |
//|  - Button "NET 0 karo": NET wali taraf ki lots band (faide wali   |
//|    pehle) - nayi ulti lot NAHI kholta, kitab chhoti hoti hai.    |
//|  - Har button par pehle poora hisaab, phir Yes/No (pehle se No).  |
//|  - Khula NET +InpFaidaAlert USC par alert + mobile notification.  |
//| Sirf band karta hai (TRADE_ACTION_DEAL position ke saath).        |
//+------------------------------------------------------------------+
#property copyright "JAS"
#property version   "1.00"

#define BUILD "x1"

input double InpNetLot      = 0.10;  // NET kholne ka tukda (lot)
input double InpMaxNet      = 0.50;  // NET ki had (0.50 se zyada nahi chalegi)
input double InpFaidaAlert  = 50.0;  // Khula NET itne USC faide mein = alert
input bool   InpPush        = true;  // Mobile par notification (MetaQuotes ID chahiye)
input int    InpSlippage    = 30;    // Band karte waqt qeemat ki gunjaish (points)

string PFX = "JKS_";
double g_eq0      = 0.0;   // NET khulne waqt ki equity
bool   g_alerted  = false;
int    g_friDay   = -1;

string Pick(bool c, string a, string b) { if(c) return(a); return(b); }
string M(double v)  { return(DoubleToString(v, 2)); }
string Px(double v) { return(DoubleToString(v, (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS))); }
string GvName()     { return("JKS_EQ0_" + _Symbol); }

double MaxNet()     { return(MathMin(InpMaxNet, 0.50)); }   // had sirf kam ho sakti hai
double Step()       { double s = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP); if(s <= 0.0) s = 0.01; return(s); }
double PerDollarLot()
  {
   double tv = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);
   double ts = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);
   if(ts <= 0.0) return(0.0);
   return(tv / ts);                 // 1 lot, qeemat $1 = itne account-paise
  }

//--- kitab
ulong  L_tk[];
int    L_ty[];
double L_vol[], L_px[], L_pl[];
int    L_n = 0;

void Collect()
  {
   int n = PositionsTotal();
   ArrayResize(L_tk, n); ArrayResize(L_ty, n); ArrayResize(L_vol, n);
   ArrayResize(L_px, n); ArrayResize(L_pl, n);
   L_n = 0;
   for(int i = 0; i < n; i++)
     {
      ulong t = PositionGetTicket(i);
      if(t == 0) continue;
      if(PositionGetString(POSITION_SYMBOL) != _Symbol) continue;
      L_tk[L_n]  = t;
      L_ty[L_n]  = (int)PositionGetInteger(POSITION_TYPE);
      L_vol[L_n] = PositionGetDouble(POSITION_VOLUME);
      L_px[L_n]  = PositionGetDouble(POSITION_PRICE_OPEN);
      L_pl[L_n]  = PositionGetDouble(POSITION_PROFIT) + PositionGetDouble(POSITION_SWAP);
      L_n++;
     }
  }

double SideLots(int type, bool onlyProfit)
  {
   double s = 0.0;
   for(int i = 0; i < L_n; i++)
      if(L_ty[i] == type && (!onlyProfit || L_pl[i] >= 0.0)) s += L_vol[i];
   return(s);
  }

double NetNow() { return(SideLots(POSITION_TYPE_BUY, false) - SideLots(POSITION_TYPE_SELL, false)); }

//--- band karne ke liye lots chuno: sab se zyada faida (fi lot) pehle
ulong  C_tk[];
double C_vol[], C_pl[], C_px[];
int    C_n = 0;

double Choose(int type, double need, bool onlyProfit)
  {
   int idx[]; ArrayResize(idx, L_n);
   int m = 0;
   for(int i = 0; i < L_n; i++)
      if(L_ty[i] == type && (!onlyProfit || L_pl[i] >= 0.0)) { idx[m] = i; m++; }
   for(int a = 0; a < m - 1; a++)
      for(int d = a + 1; d < m; d++)
         if(L_pl[idx[d]] / L_vol[idx[d]] > L_pl[idx[a]] / L_vol[idx[a]])
           { int t = idx[a]; idx[a] = idx[d]; idx[d] = t; }

   double st   = Step();
   long   want = (long)MathRound(need / st);
   long   got  = 0;
   ArrayResize(C_tk, m); ArrayResize(C_vol, m); ArrayResize(C_pl, m); ArrayResize(C_px, m);
   C_n = 0;
   for(int k = 0; k < m && got < want; k++)
     {
      int  i    = idx[k];
      long have = (long)MathRound(L_vol[i] / st);
      long take = (have < want - got) ? have : (want - got);
      if(take <= 0) continue;
      C_tk[C_n]  = L_tk[i];
      C_vol[C_n] = take * st;
      C_pl[C_n]  = L_pl[i] * (double)take / (double)have;
      C_px[C_n]  = L_px[i];
      C_n++;
      got += take;
     }
   return(got * st);
  }

ENUM_ORDER_TYPE_FILLING Filling()
  {
   long f = SymbolInfoInteger(_Symbol, SYMBOL_FILLING_MODE);
   if((f & SYMBOL_FILLING_FOK) != 0) return(ORDER_FILLING_FOK);
   if((f & SYMBOL_FILLING_IOC) != 0) return(ORDER_FILLING_IOC);
   return(ORDER_FILLING_RETURN);
  }

bool CloseVol(ulong tk, double vol, string &err)
  {
   if(!PositionSelectByTicket(tk)) { err = StringFormat("#%I64u ab khuli nahi", tk); return(false); }
   long type = PositionGetInteger(POSITION_TYPE);
   MqlTradeRequest rq;
   MqlTradeResult  rs;
   ZeroMemory(rq);
   ZeroMemory(rs);
   rq.action       = TRADE_ACTION_DEAL;          // position ke saath = sirf BAND karna
   rq.position     = tk;
   rq.symbol       = _Symbol;
   rq.volume       = vol;
   rq.type         = (type == POSITION_TYPE_BUY) ? ORDER_TYPE_SELL : ORDER_TYPE_BUY;
   rq.price        = (type == POSITION_TYPE_BUY) ? SymbolInfoDouble(_Symbol, SYMBOL_BID)
                                                 : SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   rq.deviation    = InpSlippage;
   rq.type_filling = Filling();
   rq.comment      = "JKS " + BUILD;
   if(!OrderSend(rq, rs) || (rs.retcode != TRADE_RETCODE_DONE && rs.retcode != TRADE_RETCODE_PLACED))
     {
      err = StringFormat("#%I64u: retcode %u (%s)", tk, rs.retcode, rs.comment);
      return(false);
     }
   return(true);
  }

//--- stop out tak andazan doori ($) - margin ka hissa chhod kar
double StopOutDist(double net)
  {
   double k = PerDollarLot();
   if(MathAbs(net) < 1e-8 || k <= 0.0) return(0.0);
   return(AccountInfoDouble(ACCOUNT_EQUITY) / (MathAbs(net) * k));
  }

string ListChosen()
  {
   string s = "";
   for(int k = 0; k < C_n && k < 12; k++)
      s += StringFormat("   #%I64u %.2f @ %s  %s\n", C_tk[k], C_vol[k], Px(C_px[k]), M(C_pl[k]));
   if(C_n > 12) s += StringFormat("   ... aur %d (Toolbox -> Experts)\n", C_n - 12);
   return(s);
  }

double ChosenPL() { double s = 0.0; for(int k = 0; k < C_n; k++) s += C_pl[k]; return(s); }

bool Execute(string what)
  {
   if(!TerminalInfoInteger(TERMINAL_TRADE_ALLOWED) || !MQLInfoInteger(MQL_TRADE_ALLOWED))
     {
      MessageBox("Algo Trading band hai - toolbar ka 'Algo Trading' HARA karein.\nKuch nahi kiya.",
                 "JasKitabSaathi " + BUILD, MB_OK | MB_ICONSTOP);
      return(false);
     }
   double bal0 = AccountInfoDouble(ACCOUNT_BALANCE);
   int    done = 0;
   string err  = "";
   for(int k = 0; k < C_n; k++)
     {
      PrintFormat("JKS %s %s: band #%I64u %.2f", BUILD, what, C_tk[k], C_vol[k]);
      if(!CloseVol(C_tk[k], C_vol[k], err)) break;
      done++;
      Sleep(200);
     }
   Sleep(500);
   double bal1 = AccountInfoDouble(ACCOUNT_BALANCE);
   string rep = StringFormat("%s: %d / %d band\nBalance %s -> %s (farq %s)\n", what, done, C_n, M(bal0), M(bal1), M(bal1 - bal0));
   if(err != "") rep += "\nRUK GAYA: " + err + "\nJo ho chuka woh ho chuka - panel mein NET dekh lein.";
   Print("JKS ", rep);
   int flags = MB_OK | MB_ICONINFORMATION;
   if(err != "") flags = MB_OK | MB_ICONWARNING;
   MessageBox(rep, "JasKitabSaathi " + BUILD + " - nateeja", flags);
   return(err == "");
  }

//--- Button: NET kholo (dir +1 = BUY, -1 = SELL)
void DoOpenNet(int dir)
  {
   Collect();
   double cur    = NetNow();
   double newNet = cur + dir * InpNetLot;
   if(MathAbs(newNet) > MaxNet() + 1e-8)
     {
      MessageBox(StringFormat("NET %+.2f -> %+.2f hota - had %.2f se zyada.\nKuch nahi kiya.", cur, newNet, MaxNet()),
                 "JasKitabSaathi " + BUILD, MB_OK | MB_ICONSTOP);
      return;
     }
   int    closeType = (dir > 0) ? POSITION_TYPE_SELL : POSITION_TYPE_BUY;
   double got = Choose(closeType, InpNetLot, true);
   if(got <= 0.0)
     {
      MessageBox(StringFormat("%s ki koi lot faide mein nahi (0 ya zyada).\nAap ke qaide (sirf 0/faida) se NET nahi khul sakta. Kuch nahi kiya.",
                              Pick(dir > 0, "SELL", "BUY")),
                 "JasKitabSaathi " + BUILD, MB_OK | MB_ICONINFORMATION);
      return;
     }
   newNet = cur + dir * got;
   double k   = PerDollarLot();
   double pl  = ChosenPL();
   string msg = StringFormat("NET %s KHOLO - %s ki faide wali lots band (%.2f lot)\n\n", Pick(dir > 0, "BUY", "SELL"),
                             Pick(dir > 0, "SELL", "BUY"), got);
   if(got < InpNetLot - 1e-8)
      msg += StringFormat("(Sirf %.2f faide mein mili, %.2f nahi)\n", got, InpNetLot);
   msg += ListChosen() + "\n";
   msg += StringFormat("Band karne ka andazan nateeja: %s USC (balance mein)\n", M(pl));
   msg += StringFormat("NET  %+.2f  ->  %+.2f\n", cur, newNet);
   msg += StringFormat("Gold $1 %s = %s USC %s\n", Pick(dir > 0, "upar", "neeche"), M(MathAbs(newNet) * k), "faida (ulta = nuqsan)");
   msg += StringFormat("Stop out andazan ~$%.0f ulti chaal par\n\n", StopOutDist(newNet));
   msg += "Koi nayi lot NAHI khulegi. Wapas NET 0: 'NET 0 karo' button.\n\nKarna hai?";
   if(MessageBox(msg, "JasKitabSaathi " + BUILD, MB_YESNO | MB_ICONQUESTION | MB_DEFBUTTON2) != IDYES) return;
   bool wasZero = MathAbs(cur) < 1e-8;
   Execute("NET kholo");
   if(wasZero)
     {
      g_eq0 = AccountInfoDouble(ACCOUNT_EQUITY);
      GlobalVariableSet(GvName(), g_eq0);
      g_alerted = false;
     }
  }

//--- Button: NET 0 karo (NET wali taraf ki lots band, faide wali pehle)
void DoNetZero()
  {
   Collect();
   double cur = NetNow();
   if(MathAbs(cur) < 1e-8)
     {
      MessageBox("Kitab pehle se NET 0 hai. Kuch nahi kiya.", "JasKitabSaathi " + BUILD, MB_OK | MB_ICONINFORMATION);
      return;
     }
   int    closeType = (cur > 0) ? POSITION_TYPE_BUY : POSITION_TYPE_SELL;
   double got = Choose(closeType, MathAbs(cur), false);
   double pl  = ChosenPL();
   string msg = StringFormat("NET 0 KARO - %s ki lots band (%.2f lot, faide wali pehle)\n\n", Pick(cur > 0, "BUY", "SELL"), got);
   msg += ListChosen() + "\n";
   msg += StringFormat("Band karne ka andazan nateeja: %s USC\n", M(pl));
   if(g_eq0 > 0.0)
      msg += StringFormat("NET khulne ke baad se equity: %s USC\n", M(AccountInfoDouble(ACCOUNT_EQUITY) - g_eq0));
   msg += StringFormat("NET  %+.2f  ->  %+.2f  (kitab phir jami)\n\n", cur, cur - (cur > 0 ? got : -got));
   msg += "Koi nayi lot NAHI khulegi.\n\nKarna hai?";
   if(MessageBox(msg, "JasKitabSaathi " + BUILD, MB_YESNO | MB_ICONQUESTION | MB_DEFBUTTON2) != IDYES) return;
   Execute("NET 0");
  }

//--- buttons
void MakeButton(string name, string text, int y, color bg)
  {
   string n = PFX + name;
   if(ObjectFind(0, n) < 0) ObjectCreate(0, n, OBJ_BUTTON, 0, 0, 0);
   ObjectSetInteger(0, n, OBJPROP_CORNER, CORNER_RIGHT_UPPER);
   ObjectSetInteger(0, n, OBJPROP_XDISTANCE, 190);
   ObjectSetInteger(0, n, OBJPROP_YDISTANCE, y);
   ObjectSetInteger(0, n, OBJPROP_XSIZE, 180);
   ObjectSetInteger(0, n, OBJPROP_YSIZE, 28);
   ObjectSetInteger(0, n, OBJPROP_BGCOLOR, bg);
   ObjectSetInteger(0, n, OBJPROP_COLOR, clrWhite);
   ObjectSetInteger(0, n, OBJPROP_FONTSIZE, 9);
   ObjectSetString(0, n, OBJPROP_TEXT, text);
   ObjectSetInteger(0, n, OBJPROP_STATE, false);
  }

void Notify(string s)
  {
   Alert(s);
   if(InpPush) SendNotification(s);
  }

//--- har second: panel + alert
void Refresh()
  {
   Collect();
   double buy  = SideLots(POSITION_TYPE_BUY, false);
   double sell = SideLots(POSITION_TYPE_SELL, false);
   double net  = buy - sell;
   double eq   = AccountInfoDouble(ACCOUNT_EQUITY);
   double k    = PerDollarLot();
   double plAll = 0.0;
   for(int i = 0; i < L_n; i++) plAll += L_pl[i];

   // NET khulne waqt ki equity yaad rakho (restart ke baad bhi)
   if(MathAbs(net) < 1e-8)
     {
      g_eq0 = 0.0; g_alerted = false;
      if(GlobalVariableCheck(GvName())) GlobalVariableDel(GvName());
     }
   else if(g_eq0 <= 0.0)
     {
      if(GlobalVariableCheck(GvName())) g_eq0 = GlobalVariableGet(GvName());
      else { g_eq0 = eq; GlobalVariableSet(GvName(), g_eq0); }
     }
   double faida = (g_eq0 > 0.0) ? eq - g_eq0 : 0.0;

   string s = StringFormat("JAS KITAB SAATHI %s  -  %s   (khud trade NAHI, nayi lot NAHI)\n", BUILD, _Symbol);
   s += StringFormat("Positions %d  |  BUY %.2f  SELL %.2f  |  NET %+.2f (had %.2f)\n", L_n, buy, sell, net, MaxNet());
   s += StringFormat("Equity %s  |  Balance %s  |  Khula P/L %s\n", M(eq), M(AccountInfoDouble(ACCOUNT_BALANCE)), M(plAll));
   if(MathAbs(net) < 1e-8)
      s += "Kitab JAMI (NET 0) - qeemat kahin bhi jaye, kul wahi.\n";
   else
     {
      s += StringFormat("Gold $1 = %s USC  |  stop out andazan ~$%.0f ulti chaal par\n", M(MathAbs(net) * k), StopOutDist(net));
      s += StringFormat("NET khulne ke baad faida: %s USC  (alert %s par)\n", M(faida), M(InpFaidaAlert));
     }
   s += StringFormat("Faide wali lots:  SELL %.2f  |  BUY %.2f\n", SideLots(POSITION_TYPE_SELL, true), SideLots(POSITION_TYPE_BUY, true));
   if(MathAbs(net) < 1e-8)
     {
      if(SideLots(POSITION_TYPE_SELL, true) >= InpNetLot - 1e-8) s += StringFormat("MAUQA: %.2f SELL faide mein - 'NET BUY kholo' mumkin (rukh ka faisla aap ka)\n", InpNetLot);
      if(SideLots(POSITION_TYPE_BUY, true)  >= InpNetLot - 1e-8) s += StringFormat("MAUQA: %.2f BUY faide mein - 'NET SELL kholo' mumkin (rukh ka faisla aap ka)\n", InpNetLot);
     }

   // Jumma raat: NET khula ho to yaad dilao (ek dafa)
   MqlDateTime dt;
   TimeToStruct(TimeCurrent(), dt);
   if(dt.day_of_week == 5 && dt.hour >= 20 && MathAbs(net) > 1e-8)
     {
      s += "JUMMA RAAT: bazaar band hone wala - weekend gap se pehle NET 0 karein!\n";
      if(g_friDay != dt.day) { g_friDay = dt.day; Notify(StringFormat("JasKitabSaathi: Jumma raat, NET %+.2f khula hai - NET 0 karein", net)); }
     }

   // faida alert (ek dafa; aadhe se neeche aaye to dobara tayyar)
   if(MathAbs(net) > 1e-8)
     {
      if(!g_alerted && faida >= InpFaidaAlert)
        {
         g_alerted = true;
         int ct = (net > 0) ? POSITION_TYPE_BUY : POSITION_TYPE_SELL;
         Choose(ct, MathAbs(net), false);
         string tks = "";
         for(int kk = 0; kk < C_n && kk < 5; kk++) tks += StringFormat(" #%I64u", C_tk[kk]);
         Notify(StringFormat("JasKitabSaathi: faida +%.0f USC, NET %+.2f. Laptop 'NET 0 karo' ya mobile se band:%s", faida, net, tks));
        }
      if(g_alerted && faida < InpFaidaAlert / 2.0) g_alerted = false;
     }
   Comment(s);
  }

int OnInit()
  {
   MakeButton("BUY",  "NET BUY kholo",  30, clrSeaGreen);
   MakeButton("SELL", "NET SELL kholo", 62, clrFireBrick);
   MakeButton("ZERO", "NET 0 karo",     94, clrSteelBlue);
   EventSetTimer(1);
   Refresh();
   return(INIT_SUCCEEDED);
  }

void OnDeinit(const int reason)
  {
   EventKillTimer();
   ObjectsDeleteAll(0, PFX);
   Comment("");
  }

void OnTimer() { Refresh(); }
void OnTick()  { }

void OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam)
  {
   if(id != CHARTEVENT_OBJECT_CLICK) return;
   if(StringFind(sparam, PFX) != 0) return;
   ObjectSetInteger(0, sparam, OBJPROP_STATE, false);
   if(sparam == PFX + "BUY")  DoOpenNet(+1);
   if(sparam == PFX + "SELL") DoOpenNet(-1);
   if(sparam == PFX + "ZERO") DoNetZero();
   Refresh();
  }
