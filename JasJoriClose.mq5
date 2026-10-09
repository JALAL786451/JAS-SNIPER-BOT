//+------------------------------------------------------------------+
//|  JAS JORI CLOSE   -   build s1                                   |
//|                                                                  |
//|  YE SCRIPT HAI, EA NAHI. MetaEditor mein "Scripts" folder mein   |
//|  banayein. Ek dafa chalta hai, kaam kar ke khud band ho jata hai.|
//|                                                                  |
//|  Kya karta hai:                                                  |
//|  Chart ke symbol ki SAB SE BARI lot (aap ki 1.50 SELL) ko ulti   |
//|  taraf ki un lots ke saath "CLOSE BY" karta hai jo JasDeskView   |
//|  ki "BARI LOT KI JORI" chunta hai - bilkul wohi qaida, wohi      |
//|  tarteeb. Lot barabar, is liye kitab har lamhe jami rehti hai.   |
//|                                                                  |
//|  Kya NAHI karta:                                                 |
//|    - koi nayi lot nahi kholta (TRADE_ACTION_DEAL ka naam nahi)   |
//|    - bazaar par kuch band nahi karta - sirf CLOSE BY             |
//|    - ek bhi Close By fail ho to wahin ruk jata hai               |
//|    - jori adhoori ho ya nateeja InpMinResult se kam ho to        |
//|      shuru hi nahi karta                                         |
//|                                                                  |
//|  Chalne se pehle EK dafa poochta hai (Yes / No, pehle se No).    |
//+------------------------------------------------------------------+
#property copyright "JAS"
#property version   "1.00"
#property script_show_inputs

#define S_BUILD "s1"

input double InpMinResult = 0.0;   // Jori ka andazan nateeja is se kam ho to mat karo
input int    InpDelayMs   = 200;   // Do Close By ke darmiyan kitne milli-second

string Px(double v) { return(DoubleToString(v, (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS))); }
string M(double v)  { return(DoubleToString(v, 2)); }
string Pick(bool c, string a, string b) { if(c) return(a); return(b); }

//--- is chart ke symbol ki sab lots
int Collect(ulong &tk[], int &ty[], double &vol[], double &px[], double &pl[])
  {
   int n = PositionsTotal();
   ArrayResize(tk, n); ArrayResize(ty, n); ArrayResize(vol, n);
   ArrayResize(px, n); ArrayResize(pl, n);
   int c = 0;
   for(int i = 0; i < n; i++)
     {
      ulong t = PositionGetTicket(i);
      if(t == 0) continue;
      if(PositionGetString(POSITION_SYMBOL) != _Symbol) continue;
      tk[c]  = t;
      ty[c]  = (int)PositionGetInteger(POSITION_TYPE);
      vol[c] = PositionGetDouble(POSITION_VOLUME);
      px[c]  = PositionGetDouble(POSITION_PRICE_OPEN);
      pl[c]  = PositionGetDouble(POSITION_PROFIT) + PositionGetDouble(POSITION_SWAP);
      c++;
     }
   ArrayResize(tk, c); ArrayResize(ty, c); ArrayResize(vol, c);
   ArrayResize(px, c); ArrayResize(pl, c);
   return(c);
  }

//--- JasDeskView v4.2 ka PickBigPair - jyon ka tyon, taake panel aur
//--- script hamesha EK hi jori chunein
int PickBigPair(const int &ty[], const double &vol[], const double &px[], const double &pl[],
                int c, int &big, int &sel[], double &target, double &matched)
  {
   big = -1; target = 0.0; matched = 0.0;
   ArrayResize(sel, 0);
   for(int i = 0; i < c; i++)
      if(big < 0 || vol[i] > vol[big] + 1e-8
         || (MathAbs(vol[i] - vol[big]) < 1e-8 && pl[i] < pl[big]))
         big = i;
   if(big < 0) return(0);

   bool bigBuy = (ty[big] == POSITION_TYPE_BUY);
   int  cand[]; ArrayResize(cand, c);
   int  nc = 0;
   for(int i = 0; i < c; i++)
     {
      if(i == big || ty[i] == ty[big]) continue;
      cand[nc] = i; nc++;
     }
   for(int a = 0; a < nc - 1; a++)
      for(int d = a + 1; d < nc; d++)
        {
         bool swap = bigBuy ? (px[cand[d]] > px[cand[a]]) : (px[cand[d]] < px[cand[a]]);
         if(swap) { int t = cand[a]; cand[a] = cand[d]; cand[d] = t; }
        }

   double step = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);
   if(step <= 0.0) step = 0.01;
   long want = (long)MathRound(vol[big] / step);
   long got  = 0;
   int  n    = 0;
   ArrayResize(sel, nc);
   for(int k = 0; k < nc && got < want; k++)
     {
      long u = (long)MathRound(vol[cand[k]] / step);
      if(got + u > want) continue;
      sel[n] = cand[k]; n++;
      got += u;
     }
   ArrayResize(sel, n);
   target  = vol[big];
   matched = got * step;
   return(n);
  }

//--- bari lot abhi bhi khuli hai? (partial Close By ke baad bhi ticket wohi rehta hai,
//--- phir bhi identifier se dhoond lo)
bool SelectBig(ulong ticket, long ident)
  {
   if(PositionSelectByTicket(ticket)) return(true);
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      if(PositionGetTicket(i) == 0) continue;
      if(PositionGetInteger(POSITION_IDENTIFIER) == ident) return(true);
     }
   return(false);
  }

//+------------------------------------------------------------------+
void OnStart()
  {
   PrintFormat("JAS JORI CLOSE %s shuru | %s", S_BUILD, _Symbol);

   if(AccountInfoInteger(ACCOUNT_MARGIN_MODE) != ACCOUNT_MARGIN_MODE_RETAIL_HEDGING)
     {
      MessageBox("Ye account HEDGE nahi hai - Close By mumkin nahi.\nKuch nahi kiya.",
                 "JAS JORI CLOSE " + S_BUILD, MB_OK | MB_ICONSTOP);
      return;
     }

   ulong tk[]; int ty[]; double vol[], px[], pl[];
   int c = Collect(tk, ty, vol, px, pl);
   if(c <= 0)
     {
      MessageBox("Is chart (" + _Symbol + ") par koi lot nahi.\nKuch nahi kiya.",
                 "JAS JORI CLOSE " + S_BUILD, MB_OK | MB_ICONINFORMATION);
      return;
     }

   int    big;
   int    sel[];
   double target, matched;
   int n = PickBigPair(ty, vol, px, pl, c, big, sel, target, matched);
   if(big < 0 || n <= 0)
     {
      MessageBox("Bari lot ke khilaf ulti taraf koi lot nahi.\nKuch nahi kiya.",
                 "JAS JORI CLOSE " + S_BUILD, MB_OK | MB_ICONINFORMATION);
      return;
     }
   if(MathAbs(matched - target) > 1e-8)
     {
      MessageBox(StringFormat("Poori jori nahi banti: %.2f chahiye, sirf %.2f mili.\n"
                              + "Adhoori jori se kitab jami nahi rahegi - kuch nahi kiya.",
                              target, matched),
                 "JAS JORI CLOSE " + S_BUILD, MB_OK | MB_ICONSTOP);
      return;
     }

   //--- andazan nateeja: abhi ke P/L ka jorh, aur Close By ka (khulne ke price ka farq, spread nahi)
   bool   bigBuy = (ty[big] == POSITION_TYPE_BUY);
   double tv     = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);
   double ts     = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);
   double perPt  = (ts > 0.0) ? tv / ts : 0.0;
   double plNow  = pl[big];
   double byEst  = 0.0;
   for(int k = 0; k < n; k++)
     {
      int i = sel[k];
      plNow += pl[i];
      double diff = bigBuy ? (px[i] - px[big]) : (px[big] - px[i]);
      byEst += diff * vol[i] * perPt;
     }
   double lotBuy = 0.0, lotSell = 0.0;
   for(int i = 0; i < c; i++)
     {
      if(ty[i] == POSITION_TYPE_BUY) lotBuy += vol[i];
      else                           lotSell += vol[i];
     }
   double net = lotBuy - lotSell;

   if(byEst < InpMinResult)
     {
      MessageBox(StringFormat("Jori ka andazan nateeja %s hai - InpMinResult (%s) se kam.\nKuch nahi kiya.",
                              M(byEst), M(InpMinResult)),
                 "JAS JORI CLOSE " + S_BUILD, MB_OK | MB_ICONSTOP);
      return;
     }

   if(!TerminalInfoInteger(TERMINAL_TRADE_ALLOWED) || !MQLInfoInteger(MQL_TRADE_ALLOWED))
     {
      MessageBox("Algo Trading ki ijazat nahi hai.\n"
                 + "Toolbar ka 'Algo Trading' HARA karein, aur script lagate waqt\n"
                 + "Common tab mein 'Allow Algo Trading' par tick lagayein.\nKuch nahi kiya.",
                 "JAS JORI CLOSE " + S_BUILD, MB_OK | MB_ICONSTOP);
      return;
     }

   //--- poori list Experts tab mein, pehli 12 khirki mein
   string list = "";
   for(int k = 0; k < n; k++)
     {
      int i = sel[k];
      string row = StringFormat("#%I64u %s %.2f @ %s  %s", tk[i],
                                Pick(ty[i] == POSITION_TYPE_BUY, "BUY", "SELL"),
                                vol[i], Px(px[i]), M(pl[i]));
      Print("  jori: ", row);
      if(k < 12) list += "   " + row + "\n";
     }
   if(n > 12) list += StringFormat("   ... aur %d (poori list: Toolbox -> Experts)\n", n - 12);

   string msg = "";
   msg += StringFormat("BARI LOT:  #%I64u %s %.2f @ %s   (%s)\n\n",
                       tk[big], Pick(bigBuy, "BUY", "SELL"), vol[big], Px(px[big]), M(pl[big]));
   msg += StringFormat("Is ke khilaf CLOSE BY: %d %s, kul %.2f lot\n",
                       n, Pick(bigBuy, "SELL", "BUY"), matched);
   msg += list + "\n";
   msg += StringFormat("Andazan nateeja (Close By, spread nahi):  %s %s\n",
                       M(byEst), AccountInfoString(ACCOUNT_CURRENCY));
   msg += StringFormat("Abhi bazaar par band karte to:            %s\n\n", M(plNow));
   msg += StringFormat("NET  %+.2f  ->  %+.2f   (kitab jami rahegi)\n", net, net);
   msg += StringFormat("Band hongi: %d position.  Bachengi: %d.\n\n", n + 1, c - n - 1);
   msg += "Koi nayi lot NAHI khulegi. Ek bhi Close By fail hui to wahin ruk jayega.\n\n";
   msg += "Karna hai?";

   int ans = MessageBox(msg, "JAS JORI CLOSE " + S_BUILD + "  -  " + _Symbol,
                        MB_YESNO | MB_ICONWARNING | MB_DEFBUTTON2);
   if(ans != IDYES)
     {
      Print("JAS JORI CLOSE: user ne NO kaha - kuch nahi kiya.");
      return;
     }

   //--- amal
   double balStart = AccountInfoDouble(ACCOUNT_BALANCE);
   ulong  bigTk    = tk[big];
   long   bigId    = 0;
   if(PositionSelectByTicket(bigTk)) bigId = PositionGetInteger(POSITION_IDENTIFIER);
   int    done     = 0;
   string stopWhy  = "";

   for(int k = 0; k < n; k++)
     {
      int i = sel[k];
      if(!SelectBig(bigTk, bigId)) { stopWhy = "bari lot ab khuli nahi mili"; break; }
      ulong bigNow = PositionGetInteger(POSITION_TICKET);
      if(!PositionSelectByTicket(tk[i]))
        { stopWhy = StringFormat("#%I64u ab khuli nahi mili", tk[i]); break; }

      MqlTradeRequest rq;
      MqlTradeResult  rs;
      ZeroMemory(rq);
      ZeroMemory(rs);
      rq.action      = TRADE_ACTION_CLOSE_BY;
      rq.position    = bigNow;
      rq.position_by = tk[i];
      rq.symbol      = _Symbol;

      bool ok = OrderSend(rq, rs);
      if(!ok || (rs.retcode != TRADE_RETCODE_DONE && rs.retcode != TRADE_RETCODE_PLACED))
        {
         stopWhy = StringFormat("#%I64u par Close By nahi hua: retcode %u (%s)",
                                tk[i], rs.retcode, rs.comment);
         break;
        }
      done++;
      PrintFormat("  Close By %d/%d: #%I64u + #%I64u  theek", done, n, bigNow, tk[i]);
      if(InpDelayMs > 0) Sleep(InpDelayMs);
     }

   Sleep(500);
   double balEnd = AccountInfoDouble(ACCOUNT_BALANCE);

   string rep = StringFormat("Close By ho gaye: %d / %d\n", done, n);
   rep += StringFormat("Balance: %s -> %s   (farq %s)\n", M(balStart), M(balEnd), M(balEnd - balStart));
   if(stopWhy != "")
      rep += "\nRUK GAYA: " + stopWhy + "\n"
             + "Jo ho chuka woh barabar lot par hua - kitab ab bhi jami hai.\n"
             + "JasDeskView mein NET check kar lein.";
   else
      rep += "\nPoori jori band. JasDeskView mein NET 0 aur nayi tasveer dekh lein.";
   Print("JAS JORI CLOSE: ", rep);
   int flags = MB_OK | MB_ICONINFORMATION;
   if(stopWhy != "") flags = MB_OK | MB_ICONWARNING;
   MessageBox(rep, "JAS JORI CLOSE " + S_BUILD + "  -  nateeja", flags);
  }
//+------------------------------------------------------------------+
