//+------------------------------------------------------------------+
//|  JAS JORI CLOSE   -   build s5                                   |
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

#define S_BUILD "s5"

input double InpMinResult = 0.0;   // Jori ka andazan nateeja is se kam ho to mat karo
input int    InpDelayMs   = 200;   // Do Close By ke darmiyan kitne milli-second
enum ETarteeb
  {
   T_NAZDEEK = 0, // Bari lot ki qeemat ke QAREEB (oopar + neeche), nateeja >= InpMinResult - s4
   T_BEHTAR  = 1, // Behtar price pehle (s1: bari SELL -> sasti BUY)
   T_MEHNGI  = 2  // Mehngi pehle (s2: bari SELL -> mehngi BUY)
  };
input ETarteeb InpTarteeb = T_NAZDEEK; // Ulti lots kis tarteeb se chunein
input int      InpJoriMax = 25;        // s5: ek chakkar mein zyada se zyada kitni joriyan (har jori >= InpMinResult)

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
                int c, const bool &used[], const bool &tried[],
                int &big, int &sel[], double &target, double &matched)
  {
   big = -1; target = 0.0; matched = 0.0;
   ArrayResize(sel, 0);
   for(int i = 0; i < c; i++)
      if(used[i] || tried[i]) continue;
      else if(big < 0 || vol[i] > vol[big] + 1e-8
         || (MathAbs(vol[i] - vol[big]) < 1e-8 && pl[i] < pl[big]))
         big = i;
   if(big < 0) return(0);

   bool bigBuy = (ty[big] == POSITION_TYPE_BUY);
   int  cand[]; ArrayResize(cand, c);
   int  nc = 0;
   for(int i = 0; i < c; i++)
     {
      if(i == big || ty[i] == ty[big] || used[i]) continue;
      cand[nc] = i; nc++;
     }
   for(int a = 0; a < nc - 1; a++)
      for(int d = a + 1; d < nc; d++)
        {
         // s1: behtar price pehle. s2: ulta (bari SELL -> mehngi BUY). s3: bari lot ki qeemat ke sab se qareeb pehle
         bool swap = bigBuy ? (px[cand[d]] > px[cand[a]]) : (px[cand[d]] < px[cand[a]]);
         if(InpTarteeb == T_MEHNGI) swap = bigBuy ? (px[cand[d]] < px[cand[a]]) : (px[cand[d]] > px[cand[a]]);
         if(InpTarteeb == T_NAZDEEK) swap = MathAbs(px[cand[d]] - px[big]) < MathAbs(px[cand[a]] - px[big]);
         if(swap) { int t = cand[a]; cand[a] = cand[d]; cand[d] = t; }
        }

   double step = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);
   if(step <= 0.0) step = 0.01;
   long want = (long)MathRound(vol[big] / step);
   long got  = 0;
   int  n    = 0;
   ArrayResize(sel, nc);

   // s4: QAREEB - sab se qareeb lots, magar nuqsan wali (ulti taraf) lots ki had (cap) ghata kar
   // jab tak nateeja InpMinResult tak na aa jaye. Pehla cap jo chale = sab se qareeb jaiz jori.
   if(InpTarteeb == T_NAZDEEK)
     {
      double tv = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);
      double ts = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);
      double pp = (ts > 0.0) ? tv / ts : 0.0;
      for(long cap = want; cap >= 0; cap--)
        {
         long   g = 0, bad = 0;
         int    m = 0;
         double res = 0.0;
         for(int k = 0; k < nc && g < want; k++)
           {
            int  i = cand[k];
            long u = (long)MathRound(vol[i] / step);
            if(g + u > want) continue;
            double diff = bigBuy ? (px[i] - px[big]) : (px[big] - px[i]);
            if(diff < 0.0 && bad + u > cap) continue;
            sel[m] = i; m++;
            g += u;
            if(diff < 0.0) bad += u;
            res += diff * vol[i] * pp;
           }
         if(g == want && res >= InpMinResult - 1e-9)
           {
            ArrayResize(sel, m);
            target  = vol[big];
            matched = g * step;
            return(m);
           }
        }
      // koi jaiz QAREEB jori nahi - neeche wala aam chunao (OnStart nateeja dekh kar rok dega)
     }
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

   double tv    = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);
   double ts    = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);
   double perPt = (ts > 0.0) ? tv / ts : 0.0;

   //--- s5: joriyon ka mansooba - har jori alag se >= InpMinResult, koi lot do joriyon mein nahi
   bool used[];  ArrayResize(used, c);  ArrayInitialize(used, false);
   bool tried[]; ArrayResize(tried, c); ArrayInitialize(tried, false);
   int    jBig[], jStart[], jCnt[], jAll[];
   double jRes[];
   int    nj = 0, nAll = 0, maxJ = MathMax(1, InpJoriMax);
   ArrayResize(jBig, maxJ); ArrayResize(jStart, maxJ); ArrayResize(jCnt, maxJ); ArrayResize(jRes, maxJ);
   ArrayResize(jAll, c);
   for(int guard = 0; guard < c && nj < maxJ; guard++)
     {
      int    big;
      int    sel[];
      double target, matched;
      int n = PickBigPair(ty, vol, px, pl, c, used, tried, big, sel, target, matched);
      if(big < 0) break;
      if(n <= 0 || MathAbs(matched - target) > 1e-8) { tried[big] = true; continue; }
      bool   bigBuy = (ty[big] == POSITION_TYPE_BUY);
      double est = 0.0;
      for(int k = 0; k < n; k++)
        {
         int i = sel[k];
         double diff = bigBuy ? (px[i] - px[big]) : (px[big] - px[i]);
         est += diff * vol[i] * perPt;
        }
      if(est < InpMinResult) { tried[big] = true; continue; }
      jBig[nj] = big; jStart[nj] = nAll; jCnt[nj] = n; jRes[nj] = est;
      used[big] = true;
      for(int k = 0; k < n; k++) { jAll[nAll] = sel[k]; nAll++; used[sel[k]] = true; }
      nj++;
     }
   if(nj == 0)
     {
      MessageBox(StringFormat("Koi jori %s ya behtar nateeje wali nahi bani.\nKuch nahi kiya.", M(InpMinResult)),
                 "JAS JORI CLOSE " + S_BUILD, MB_OK | MB_ICONINFORMATION);
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

   double lotBuy = 0.0, lotSell = 0.0, total = 0.0;
   for(int i = 0; i < c; i++)
     {
      if(ty[i] == POSITION_TYPE_BUY) lotBuy += vol[i];
      else                           lotSell += vol[i];
     }
   double net = lotBuy - lotSell;
   int    posBand = 0;
   string list = "";
   for(int j = 0; j < nj; j++)
     {
      int b = jBig[j];
      total   += jRes[j];
      posBand += jCnt[j] + 1;
      int up = 0;
      for(int k = 0; k < jCnt[j]; k++) if(px[jAll[jStart[j] + k]] > px[b]) up++;
      string row = StringFormat("%2d) #%I64u %s %.2f @ %s  + %d lot (oopar %d, neeche %d)  = %s", j + 1, tk[b],
                                Pick(ty[b] == POSITION_TYPE_BUY, "BUY", "SELL"), vol[b], Px(px[b]),
                                jCnt[j], up, jCnt[j] - up, M(jRes[j]));
      Print("  jori: ", row);
      for(int k = 0; k < jCnt[j]; k++)
        {
         int i = jAll[jStart[j] + k];
         PrintFormat("       #%I64u %s %.2f @ %s", tk[i], Pick(ty[i] == POSITION_TYPE_BUY, "BUY", "SELL"), vol[i], Px(px[i]));
        }
      if(j < 12) list += "   " + row + "\n";
     }
   if(nj > 12) list += StringFormat("   ... aur %d jori (poori list: Toolbox -> Experts)\n", nj - 12);

   string msg = "";
   msg += StringFormat("Tarteeb: %s  |  har jori >= %s\n\n",
                       Pick(InpTarteeb == T_NAZDEEK, "QAREEB", Pick(InpTarteeb == T_MEHNGI, "MEHNGI PEHLE", "BEHTAR PEHLE")),
                       M(InpMinResult));
   msg += StringFormat("JORIYAN: %d\n", nj);
   msg += list + "\n";
   msg += StringFormat("Kul andazan nateeja (Close By, spread nahi):  %s %s\n", M(total), AccountInfoString(ACCOUNT_CURRENCY));
   msg += StringFormat("NET  %+.2f  ->  %+.2f   (kitab jami rahegi)\n", net, net);
   msg += StringFormat("Band hongi: %d position.  Bachengi: %d.\n\n", posBand, c - posBand);
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
   int    done     = 0, need = nAll;
   string stopWhy  = "";
   for(int j = 0; j < nj && stopWhy == ""; j++)
     {
      ulong bigTk = tk[jBig[j]];
      long  bigId = 0;
      if(PositionSelectByTicket(bigTk)) bigId = PositionGetInteger(POSITION_IDENTIFIER);
      for(int k = 0; k < jCnt[j]; k++)
        {
         int i = jAll[jStart[j] + k];
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
         PrintFormat("  Close By %d/%d: #%I64u + #%I64u  theek", done, need, bigNow, tk[i]);
         if(InpDelayMs > 0) Sleep(InpDelayMs);
        }
     }

   Sleep(500);
   double balEnd = AccountInfoDouble(ACCOUNT_BALANCE);

   string rep = StringFormat("Close By ho gaye: %d / %d  (%d jori)\n", done, need, nj);
   rep += StringFormat("Balance: %s -> %s   (farq %s)\n", M(balStart), M(balEnd), M(balEnd - balStart));
   if(stopWhy != "")
      rep += "\nRUK GAYA: " + stopWhy + "\n"
             + "Jo ho chuka woh barabar lot par hua - kitab ab bhi jami hai.\n"
             + "JasDeskView mein NET check kar lein.";
   else
      rep += "\nSab joriyan band. JasDeskView mein NET 0 aur nayi tasveer dekh lein.";
   Print("JAS JORI CLOSE: ", rep);
   int flags = MB_OK | MB_ICONINFORMATION;
   if(stopWhy != "") flags = MB_OK | MB_ICONWARNING;
   MessageBox(rep, "JAS JORI CLOSE " + S_BUILD + "  -  nateeja", flags);
  }
//+------------------------------------------------------------------+
