//+------------------------------------------------------------------+
//|  JAS DESK VIEW   -   build v3.1                                  |
//|                                                                  |
//|  SIRF DEKHNE KA PANEL. YE TRADE NAHI KARTA.                      |
//|                                                                  |
//|  Is file mein trade ka EK BHI HUKM NAHI hai, aur koi include     |
//|  bhi nahi - sirf MT5 ke apne parhne wale functions.              |
//|                                                                  |
//|  KHUD CHECK KAREIN (MetaEditor mein Ctrl+F):                     |
//|    "OrderSend"     -> sirf isi comment mein milega               |
//|    "ositionClose"  -> sirf isi comment mein milega               |
//|    "#include"      -> ek bhi nahi                                |
//|    "OBJ_BUTTON"    -> ek bhi nahi (koi button hai hi nahi)       |
//|  Jo function istemal hue hain woh sab "Get" wale hain:           |
//|  PositionGetTicket / PositionGetDouble / PositionGetInteger      |
//|  AccountInfoDouble / SymbolInfoDouble - ye sirf PARHTE hain.     |
//|                                                                  |
//|  Ye sirf parhta hai ke kitni lots khuli hain aur un ka hisaab    |
//|  chart par likh deta hai. Account ko haath nahi lagata.          |
//|                                                                  |
//|  Kisi bhi symbol par chalta hai (XAUUSDm, XAUUSDc, BTCUSD...)    |
//|  aur kisi bhi lot ko ginta hai - EA ki ho ya aap ke haath ki.    |
//+------------------------------------------------------------------+
#property copyright "JAS"
#property version   "1.00"

#define EA_BUILD "v3.1"

input group "=== Dikhane ke liye ==="
input bool InpShowSizes = true;   // Lot ke size ke hisaab se toor kar dikhao
input bool InpShowWorst = true;   // Sab se buri lots ki list bhi dikhao
input int  InpWorstHowMany = 5;   // Kitni buri lots dikhani hain

input group "=== Chart par lakeerein ==="
input bool  InpDrawKey     = true;            // Ahem lakeerein (ausat buy/sell, barabar ka price)
input bool  InpDrawEachLot = true;            // Har lot ki apni lakeer bhi
input int   InpMaxLotLines = 60;              // Zyada se zyada itni lot-lakeerein (chart saaf rahe)
input color InpColBuy      = clrDodgerBlue;   // BUY ka rang
input color InpColSell     = clrTomato;       // SELL ka rang
input color InpColBE       = clrGold;         // Barabar ke price ka rang
input color InpColWorst    = clrMagenta;      // Sab se buri lot ka rang

input group "=== Nikalne ka plan ==="
input bool InpShowPlan = true;    // Jori bana kar nikalne ka plan dikhao


//--- poori kitab ka naqsha
struct Book
  {
   int    nBuy, nSell;          // ginti
   double lotBuy, lotSell;      // lots
   double plBuy, plSell;        // paisa
   double sumDirLot;            // sum( dir * openPrice * lots )
   double avgBuy, avgSell;      // ausat khulne ka price
   int    nWin, nLose;          // faide / nuqsan wali ginti
   double plWin, plLose;        // faide / nuqsan ka paisa
   double worstPL, bestPL;
  };

string g_ccy = "";
ulong  g_sig = 0;       // kitab badli ya nahi - lakeerein tabhi dobara banti hain

//+------------------------------------------------------------------+
int OnInit()
  {
   g_ccy = AccountInfoString(ACCOUNT_CURRENCY);
   EventSetTimer(1);            // market band ho to bhi panel chalta rahe
   // Toolbox -> Experts tab mein ye line aani chahiye. Agar panel nazar
   // na aaye magar ye line ho, to EA zinda hai - masla sirf dikhne ka hai.
   PrintFormat("JAS DESK VIEW %s chal raha hai | chart %s | is par %d lot | poore account par %d | currency %s",
               EA_BUILD, _Symbol, CountOn(_Symbol), PositionsTotal(), g_ccy);
   Draw();
   return(INIT_SUCCEEDED);
  }

void OnDeinit(const int reason)
  {
   EventKillTimer();
   Comment("");
   ObjectsDeleteAll(0, "JDV_");
   // Timeframe ya setting badalne par MT5 EA dobara load nahi karta, sirf
   // OnDeinit/OnInit chalata hai - g_sig purana reh jata. Lakeerein upar mit
   // chuki hain, is liye yaad bhi mita do taake agli dafa dobara banein.
   g_sig = 0;
  }

void OnTick()  { Draw(); }
void OnTimer() { Draw(); }

//+------------------------------------------------------------------+
int CountOn(string sym)
  {
   int n = 0;
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      if(PositionGetTicket(i) == 0) continue;
      if(sym != "" && PositionGetString(POSITION_SYMBOL) != sym) continue;
      n++;
     }
   return(n);
  }

string OtherSymbols()
  {
   string s = "";
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      if(PositionGetTicket(i) == 0) continue;
      string sym = PositionGetString(POSITION_SYMBOL);
      if(sym == _Symbol) continue;
      if(StringFind(s, sym) < 0)
         s += (s == "" ? "" : ", ") + sym;
     }
   return(s);
  }

//+------------------------------------------------------------------+
void ReadBook(Book &b)
  {
   b.nBuy = 0; b.nSell = 0; b.lotBuy = 0; b.lotSell = 0;
   b.plBuy = 0; b.plSell = 0; b.sumDirLot = 0;
   b.avgBuy = 0; b.avgSell = 0;
   b.nWin = 0; b.nLose = 0; b.plWin = 0; b.plLose = 0;
   b.worstPL = 0; b.bestPL = 0;
   double wBuy = 0, wSell = 0;
   bool   first = true;

   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      if(PositionGetTicket(i) == 0) continue;
      if(PositionGetString(POSITION_SYMBOL) != _Symbol) continue;
      double v  = PositionGetDouble(POSITION_VOLUME);
      double px = PositionGetDouble(POSITION_PRICE_OPEN);
      // Exness ke in accounts par commission sifar hai (statement se gina).
      double pl = PositionGetDouble(POSITION_PROFIT) + PositionGetDouble(POSITION_SWAP);

      if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY)
        { b.nBuy++;  b.lotBuy  += v; b.plBuy  += pl; wBuy  += px * v; b.sumDirLot += px * v; }
      else
        { b.nSell++; b.lotSell += v; b.plSell += pl; wSell += px * v; b.sumDirLot -= px * v; }

      if(pl >= 0.0) { b.nWin++;  b.plWin  += pl; }
      else          { b.nLose++; b.plLose += pl; }

      if(first) { b.worstPL = pl; b.bestPL = pl; first = false; }
      if(pl < b.worstPL) b.worstPL = pl;
      if(pl > b.bestPL)  b.bestPL  = pl;
     }
   b.avgBuy  = (b.lotBuy  > 0) ? wBuy  / b.lotBuy  : 0;
   b.avgSell = (b.lotSell > 0) ? wSell / b.lotSell : 0;
  }

//--- har 1.0 qeemat ki harkat par, 1.00 lot par, kitna paisa
double MoneyPerPoint()
  {
   double tv = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);
   double ts = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);
   if(ts <= 0.0) return(0.0);
   return(tv / ts);
  }

string Px(double v) { return(DoubleToString(v, (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS))); }
string M(double v)  { return(DoubleToString(v, 2)); }

//--- sab se buri N lots, nuqsan ki tarteeb mein
string WorstList(int want)
  {
   int    n = PositionsTotal();
   if(n <= 0) return("");
   double pl[]; ulong tk[]; double vol[]; int typ[];
   ArrayResize(pl, n); ArrayResize(tk, n); ArrayResize(vol, n); ArrayResize(typ, n);
   int cnt = 0;
   for(int i = 0; i < n; i++)
     {
      ulong t = PositionGetTicket(i);
      if(t == 0) continue;
      if(PositionGetString(POSITION_SYMBOL) != _Symbol) continue;
      pl[cnt]  = PositionGetDouble(POSITION_PROFIT) + PositionGetDouble(POSITION_SWAP);
      tk[cnt]  = t;
      vol[cnt] = PositionGetDouble(POSITION_VOLUME);
      typ[cnt] = (int)PositionGetInteger(POSITION_TYPE);
      cnt++;
     }
   if(cnt <= 0) return("");

   string s = "";
   int shown = (want < cnt) ? want : cnt;
   bool used[]; ArrayResize(used, cnt); ArrayInitialize(used, false);
   for(int k = 0; k < shown; k++)
     {
      int    pick = -1;
      double low  = 0;
      for(int i = 0; i < cnt; i++)
        {
         if(used[i]) continue;
         if(pick < 0 || pl[i] < low) { pick = i; low = pl[i]; }
        }
      if(pick < 0) break;
      used[pick] = true;
      s += StringFormat("   #%I64u  %s %.2f   %s\n",
                        tk[pick], (typ[pick] == POSITION_TYPE_BUY ? "BUY " : "SELL"),
                        vol[pick], M(pl[pick]));
     }
   return(s);
  }


//+------------------------------------------------------------------+
//|  EK TARAF (buy ya sell) ko LOT KE SIZE ke hisaab se toro.         |
//|  Yani: 0.01 ki kitni, 0.05 ki kitni, 1.00 ki kitni - har size ka  |
//|  alag hisaab, ginti + kul lots + us group ka paisa.               |
//+------------------------------------------------------------------+
string SizeBreak(int wantType)
  {
   int n = PositionsTotal();
   if(n <= 0) return("");

   double sz[];   // har alag size (0.01, 0.05, 1.00 ...)
   int    ct[];   // us size ki kitni lots khuli hain
   double vl[];   // us size ka kul volume
   double pl[];   // us size ka kul paisa
   ArrayResize(sz, n); ArrayResize(ct, n); ArrayResize(vl, n); ArrayResize(pl, n);
   int groups = 0;

   for(int i = 0; i < n; i++)
     {
      if(PositionGetTicket(i) == 0) continue;
      if(PositionGetString(POSITION_SYMBOL) != _Symbol) continue;
      if((int)PositionGetInteger(POSITION_TYPE) != wantType) continue;

      double v = PositionGetDouble(POSITION_VOLUME);
      double p = PositionGetDouble(POSITION_PROFIT) + PositionGetDouble(POSITION_SWAP);

      int at = -1;
      for(int g = 0; g < groups; g++)
         if(MathAbs(sz[g] - v) < 1e-8) { at = g; break; }
      if(at < 0)
        { at = groups; sz[at] = v; ct[at] = 0; vl[at] = 0; pl[at] = 0; groups++; }

      ct[at]++; vl[at] += v; pl[at] += p;
     }
   if(groups <= 0) return("   (koi nahi)\n");

   // chhoti size pehle
   for(int a = 0; a < groups - 1; a++)
      for(int bi = a + 1; bi < groups; bi++)
         if(sz[bi] < sz[a])
           {
            double t1 = sz[a]; sz[a] = sz[bi]; sz[bi] = t1;
            int    t2 = ct[a]; ct[a] = ct[bi]; ct[bi] = t2;
            double t3 = vl[a]; vl[a] = vl[bi]; vl[bi] = t3;
            double t4 = pl[a]; pl[a] = pl[bi]; pl[bi] = t4;
           }

   string s = "";
   for(int g = 0; g < groups; g++)
      s += StringFormat("   %5.2f  x %3d  =  %6.2f lot    %12s\n",
                        sz[g], ct[g], vl[g], M(pl[g]));
   return(s);
  }


//+------------------------------------------------------------------+
//|  KITAB KO AIK JAGAH JAMA KARO (sirf is chart ke symbol ki lots)   |
//|  Teen alag jagah yehi loop chahiye tha, is liye ek hi dafa.       |
//+------------------------------------------------------------------+
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

//+------------------------------------------------------------------+
//|  CHART PAR LAKEEREIN                                              |
//+------------------------------------------------------------------+
void HLine(string name, double price, color col, int width, int style, string text)
  {
   string n = "JDV_" + name;
   if(ObjectFind(0, n) < 0) ObjectCreate(0, n, OBJ_HLINE, 0, 0, price);
   ObjectSetDouble (0, n, OBJPROP_PRICE, price);
   ObjectSetInteger(0, n, OBJPROP_COLOR, col);
   ObjectSetInteger(0, n, OBJPROP_WIDTH, width);
   ObjectSetInteger(0, n, OBJPROP_STYLE, style);
   ObjectSetInteger(0, n, OBJPROP_BACK, true);
   ObjectSetInteger(0, n, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, n, OBJPROP_HIDDEN, true);
   ObjectSetString (0, n, OBJPROP_TEXT, text);
   ObjectSetString (0, n, OBJPROP_TOOLTIP, text);
  }

void DrawLines(Book &b, double net)
  {
   ulong tk[]; int ty[]; double vol[], px[], pl[];
   int c = Collect(tk, ty, vol, px, pl);

   // kitab badli hai ya nahi - har second lakeerein dobara banane se
   // chart jhilmilata hai, is liye sirf tabdeeli par banti hain.
   ulong sig = (ulong)c;
   for(int i = 0; i < c; i++) sig += tk[i];
   if(sig == g_sig) return;
   g_sig = sig;

   ObjectsDeleteAll(0, "JDV_");
   if(c <= 0) return;

   if(InpDrawKey)
     {
      if(b.lotBuy  > 0) HLine("AVGBUY",  b.avgBuy,  InpColBuy,  2, STYLE_SOLID,
                              "Ausat BUY " + DoubleToString(b.lotBuy, 2) + " lot");
      if(b.lotSell > 0) HLine("AVGSELL", b.avgSell, InpColSell, 2, STYLE_SOLID,
                              "Ausat SELL " + DoubleToString(b.lotSell, 2) + " lot");
      if(MathAbs(net) > 1e-8)
        {
         double be = b.sumDirLot / net;
         HLine("BE", be, InpColBE, 2, STYLE_DASH, "BARABAR KA PRICE (yahan kitab sifar)");
        }
      // sab se buri lot
      int worst = -1;
      for(int i = 0; i < c; i++)
         if(worst < 0 || pl[i] < pl[worst]) worst = i;
      if(worst >= 0)
         HLine("WORST", px[worst], InpColWorst, 2, STYLE_DOT,
               "SAB SE BURI: " + (ty[worst] == POSITION_TYPE_BUY ? "BUY " : "SELL ")
               + DoubleToString(vol[worst], 2) + "  " + M(pl[worst]));
     }

   if(InpDrawEachLot)
     {
      int shown = (c < InpMaxLotLines) ? c : InpMaxLotLines;
      for(int i = 0; i < shown; i++)
        {
         bool isBuy = (ty[i] == POSITION_TYPE_BUY);
         HLine("L" + IntegerToString((long)tk[i]), px[i], isBuy ? InpColBuy : InpColSell, 1, STYLE_DOT,
               (isBuy ? "BUY " : "SELL ") + DoubleToString(vol[i], 2)
               + " @ " + Px(px[i]) + "   " + M(pl[i]));
        }
     }
  }

//+------------------------------------------------------------------+
//|  NIKALNE KA PLAN                                                  |
//|  Qaida (user ne khud chuna): BURI lot ko FAIDE wali lots se       |
//|  dhaanp kar nikalo. Buri lot kitab se chali jaye, nateeja sifar   |
//|  ya thora plus rahe, aur kul lots kam ho jayein.                  |
//+------------------------------------------------------------------+
string PlanText(Book &b, double tot, double basket)
  {
   ulong tk[]; int ty[]; double vol[], px[], pl[];
   int c = Collect(tk, ty, vol, px, pl);
   if(c <= 0) return("");

   // nuqsan wali: sab se buri pehle.  faide wali: sab se achi pehle.
   int    li[];
   int    wi[];
   int    nl = 0, nw = 0;
   ArrayResize(li, c); ArrayResize(wi, c);
   for(int i = 0; i < c; i++)
     {
      if(pl[i] < 0) { li[nl] = i; nl++; }
      else          { wi[nw] = i; nw++; }
     }
   for(int a = 0; a < nl - 1; a++)
      for(int d = a + 1; d < nl; d++)
         if(pl[li[d]] < pl[li[a]]) { int t = li[a]; li[a] = li[d]; li[d] = t; }
   for(int a = 0; a < nw - 1; a++)
      for(int d = a + 1; d < nw; d++)
         if(pl[wi[d]] > pl[wi[a]]) { int t = wi[a]; wi[a] = wi[d]; wi[d] = t; }

   double allWin = 0; for(int i = 0; i < nw; i++) allWin += pl[wi[i]];

   string s = "--- NIKALNE KA PLAN (buri lot ko faide wali se dhaanp kar) ---\n";

   if(nl <= 0)
     {
      s += "Koi lot nuqsan mein nahi. Sab band karne par " + M(basket) + " milega.\n\n";
      return(s);
     }

   //--- PLAN A: sirf sab se buri lot nikalni hai ---------------------
   int    bad   = li[0];
   double need  = -pl[bad];
   double got   = 0.0, cutVol = vol[bad];
   int    used  = 0;
   for(int i = 0; i < nw && got < need; i++)
     { got += pl[wi[i]]; cutVol += vol[wi[i]]; used++; }

   s += StringFormat("PLAN A - sirf sab se buri lot nikalein\n");
   s += StringFormat("  Buri lot : #%I64u %s %.2f   %s\n",
                     tk[bad], (ty[bad] == POSITION_TYPE_BUY ? "BUY " : "SELL"),
                     vol[bad], M(pl[bad]));
   if(got < need)
     {
      s += StringFormat("  Poora faida (%s) bhi is lot ko nahi dhaanp sakta (chahiye %s).\n",
                        M(allWin), M(need));
      s += StringFormat("  Kami: %s\n\n", M(need - got));
     }
   else
     {
      s += StringFormat("  Iske saath %d faide wali lots band karein (+%s)\n", used, M(got));
      s += StringFormat("  NATEEJA  : %s        (sifar ke qareeb = maqsad poora)\n", M(got + pl[bad]));
      s += StringFormat("  Nikal jayengi : %d position, %.2f lot\n", used + 1, cutVol);
      s += StringFormat("  Bachegi       : %d position, %.2f lot, P/L %s\n\n",
                        c - used - 1, tot - cutVol, M(basket - got - pl[bad]));
     }

   //--- PLAN B: jitna faida maujood hai, utni buri lots -------------
   double pool = allWin, eaten = 0.0, cutVolB = 0.0;
   int    nBad = 0;
   for(int i = 0; i < nl; i++)
     {
      if(eaten + (-pl[li[i]]) > pool) break;
      eaten += -pl[li[i]];
      cutVolB += vol[li[i]];
      nBad++;
     }
   s += StringFormat("PLAN B - jitna faida maujood hai, utni buri lots nikalein\n");
   s += StringFormat("  Kul faida : %s   (%d position)\n", M(allWin), nw);
   if(nBad <= 0)
      s += "  Sab se buri lot bhi poore faide se bari hai - PLAN A dekhein.\n\n";
   else
     {
      double volAll = cutVolB; for(int i = 0; i < nw; i++) volAll += vol[wi[i]];
      s += StringFormat("  Is se %d sab se buri lots dhaank sakte hain (%s)\n", nBad, M(-eaten));
      s += StringFormat("  NATEEJA  : %s\n", M(allWin - eaten));
      s += StringFormat("  Nikal jayengi : %d position, %.2f lot\n", nBad + nw, volAll);
      s += StringFormat("  Bachegi       : %d position, %.2f lot, P/L %s\n\n",
                        c - nBad - nw, tot - volAll, M(basket - (allWin - eaten)));
     }
   return(s);
  }

//+------------------------------------------------------------------+
void Draw()
  {
   Book b; ReadBook(b);
   double net    = b.lotBuy - b.lotSell;
   double tot    = b.lotBuy + b.lotSell;
   double basket = b.plBuy + b.plSell;
   int    nTot   = b.nBuy + b.nSell;
   double perPt  = MoneyPerPoint();
   double bid    = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   double bal    = AccountInfoDouble(ACCOUNT_BALANCE);
   double eq     = AccountInfoDouble(ACCOUNT_EQUITY);
   double mgn    = AccountInfoDouble(ACCOUNT_MARGIN);
   double freeM  = AccountInfoDouble(ACCOUNT_MARGIN_FREE);
   double mlvl   = AccountInfoDouble(ACCOUNT_MARGIN_LEVEL);

   string s = "=== JAS DESK VIEW  " + EA_BUILD + " ===   " + _Symbol + "   (" + g_ccy + ")\n";
   s += "YE TRADE NAHI KARTA - sirf ginti. Koi lot kholega na band karega.\n\n";

   //--- koi lot hi nahi ------------------------------------------------
   if(nTot <= 0)
     {
      int allN = PositionsTotal();
      if(allN == 0)
         s += "Is account par koi lot khuli nahi hai.\n";
      else
        {
         s += StringFormat("Is chart (%s) par koi lot nahi.\n", _Symbol);
         s += StringFormat("MAGAR account par %d lot khuli hain: %s\n", allN, OtherSymbols());
         s += "   >> Us symbol ka chart kholein aur wahan ye EA lagayein <<\n";
        }
      Comment(s);
      DrawLines(b, 0.0);
      return;
     }

   //--- A) WOHI GINTI JO BROKER KE 'CLOSE ALL' DIALOG MEIN AATI HAI ----
   s += "--- Jaisi ginti broker ke Close-All dialog mein aati hai ---\n";
   s += StringFormat("Sab band karein      %3d lot   %12s %s\n", nTot,   M(basket),   g_ccy);
   s += StringFormat("Faide wali band      %3d lot   %12s\n",    b.nWin,  M(b.plWin));
   s += StringFormat("Nuqsan wali band     %3d lot   %12s\n",    b.nLose, M(b.plLose));
   s += StringFormat("BUY  band karein     %3d lot   %12s\n",    b.nBuy,  M(b.plBuy));
   s += StringFormat("SELL band karein     %3d lot   %12s\n\n",  b.nSell, M(b.plSell));

   //--- B) WOH JO DIALOG NAHI BATATA: LOTS, AUSAT, HAR LOT PAR -------
   s += "--- Jo dialog NAHI batata ---\n";
   s += StringFormat("BUY  : ginti %d   lots %.2f   ausat %s   har lot par %s\n",
                     b.nBuy, b.lotBuy, Px(b.avgBuy),
                     M(b.nBuy  > 0 ? b.plBuy  / b.nBuy  : 0.0));
   s += StringFormat("SELL : ginti %d   lots %.2f   ausat %s   har lot par %s\n",
                     b.nSell, b.lotSell, Px(b.avgSell),
                     M(b.nSell > 0 ? b.plSell / b.nSell : 0.0));
   s += StringFormat("NET lots %+.2f      KUL lots %.2f\n", net, tot);

   if(MathAbs(net) < 1e-8)
      s += "  >> Kitab JAM hai. NET 0 - qeemat kahin bhi jaye, kitab nahi badlegi.\n\n";
   else if(net > 0)
      s += "  >> Kitab LONG hai. Qeemat UPAR jaye to kitab behtar hogi.\n\n";
   else
      s += "  >> Kitab SHORT hai. Qeemat NEECHE jaye to kitab behtar hogi.\n\n";

   //--- B2) LOT KE SIZE KE HISAAB SE -----------------------------------
   if(InpShowSizes)
     {
      s += "--- Lot ke SIZE ke hisaab se (size x ginti = kul lot) ---\n";
      s += StringFormat("BUY  (ginti %d, kul %.2f lot)\n", b.nBuy, b.lotBuy);
      s += SizeBreak((int)POSITION_TYPE_BUY);
      s += StringFormat("SELL (ginti %d, kul %.2f lot)\n", b.nSell, b.lotSell);
      s += SizeBreak((int)POSITION_TYPE_SELL);
      s += "\n";
     }

   //--- C) BARABAR KA PRICE -------------------------------------------
   if(MathAbs(net) < 1e-8)
     {
      s += "BARABAR KA PRICE: koi nahi - NET 0 hai.\n";
      s += "  Nikalne ka ek hi raasta: ek taraf band karna.\n\n";
     }
   else
     {
      double be = b.sumDirLot / net;
      s += StringFormat("BARABAR KA PRICE: %s   (abhi %s)\n", Px(be), Px(bid));
      s += StringFormat("  Qeemat ko %s taraf %s chalna hoga.\n\n",
                        (be > bid ? "UPAR" : "NEECHE"), Px(MathAbs(be - bid)));
     }

   //--- D) EK TARAF BAND KARNE KE BAAD KITNI HARKAT CHAHIYE -----------
   if(b.lotBuy > 0 && b.lotSell > 0 && perPt > 0.0)
     {
      s += "--- Agar ek taraf band karein ---\n";
      if(b.plSell < 0)
         s += StringFormat("BUY band  (%s milega): sell %.2f bachegi, usay %s neeche chahiye\n",
                           M(b.plBuy), b.lotSell, Px(MathAbs(b.plSell) / (b.lotSell * perPt)));
      if(b.plBuy < 0)
         s += StringFormat("SELL band (%s milega): buy %.2f bachegi, usay %s upar chahiye\n",
                           M(b.plSell), b.lotBuy, Px(MathAbs(b.plBuy) / (b.lotBuy * perPt)));
      s += "\n";
     }

   //--- D2) NIKALNE KA PLAN -------------------------------------------
   if(InpShowPlan) s += PlanText(b, tot, basket);

   //--- E) SAB SE BURI LOTS -------------------------------------------
   if(InpShowWorst)
     {
      string w = WorstList(InpWorstHowMany);
      if(w != "")
        {
         s += StringFormat("--- Sab se buri %d lots ---\n", InpWorstHowMany) + w;
         s += StringFormat("   (sab se buri %s, sab se achi %s)\n\n", M(b.worstPL), M(b.bestPL));
        }
     }

   //--- F) ACCOUNT AUR KHATRA -----------------------------------------
   s += "--- Account ---\n";
   s += StringFormat("Balance %s %s    Equity %s\n", M(bal), g_ccy, M(eq));
   s += StringFormat("Margin  %s    Free %s    Level %.1f%%\n", M(mgn), M(freeM), mlvl);

   // ACCOUNT_MARGIN_SO_SO double hai, integer nahi.
   // SO_MODE batata hai ke woh percent mein hai ya paise mein.
   long   soMode = AccountInfoInteger(ACCOUNT_MARGIN_SO_MODE);
   double soVal  = AccountInfoDouble(ACCOUNT_MARGIN_SO_SO);
   if(soMode != ACCOUNT_STOPOUT_MODE_PERCENT) soVal = 0.0;
   if(soVal <= 0.0) soVal = 50.0;

   if(MathAbs(net) < 1e-8)
      s += "Stop out: qeemat se nahi ho sakta (NET 0). Sirf swap khata rahega.\n";
   else if(mgn > 0.0 && perPt > 0.0)
     {
      double eqMin = mgn * soVal / 100.0;
      double room  = (eq - eqMin) / (MathAbs(net) * perPt);
      if(room > 0)
         s += StringFormat("Stop out %.0f%% par. Qeemat %s khilaf jaye to wahan pohnchegi.\n",
                           soVal, Px(room));
      else
         s += StringFormat("KHATRA: stop out %.0f%% ke bohot qareeb hain.\n", soVal);
     }

   Comment(s);
   DrawLines(b, net);
  }
//+------------------------------------------------------------------+
