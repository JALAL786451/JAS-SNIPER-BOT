//====================================================================
//===  BUILD d3   <<< PANEL PAR YAHI NUMBER AANA CHAHIYE >>>
//====================================================================
//+------------------------------------------------------------------+
//|  JasDesk.mq5                                                      |
//|  Phansi hui kitab ka control panel.                               |
//|                                                                   |
//|  Ye EA TRADE NAHI KARTA. Ye sirf batata hai ke aap kahan khare    |
//|  hain aur har raaste ki keemat kya hai. Button tabhi chalte hain  |
//|  jab aap khud InpAllowButtons chalu karein.                       |
//|                                                                   |
//|  ZARURI: ye kisi bhi lot ko ginta hai - EA ki ho ya aap ke haath  |
//|  se lagai hui - magar sirf ISI chart ke symbol ki.                |
//+------------------------------------------------------------------+
#property copyright "JAS-SNIPER-BOT"
#property version   "1.00"
#property strict

#include <Trade\Trade.mqh>
#include <Trade\PositionInfo.mqh>

#define EA_BUILD "d3"

input group "=== Dikhane ke liye ==="
input int    InpFont        = 9;        // Likhai ka size
input color  InpTextColor   = clrWhite; // Likhai ka rang
input int    InpX           = 10;       // Panel bayein se kitna door
input int    InpY           = 20;       // Panel upar se kitna door

input group "=== Button (khatre wala hissa) ==="
input bool   InpAllowButtons = false;   // Button chalu karein? (band = sirf dekhna)
input int    InpConfirmSecs  = 6;       // Dobara click karne ki mohlat (second)
input int    InpSlippage     = 50;      // Max slippage (points)

CTrade        trade;
CPositionInfo pos;

//--- kitab ka poora naqsha
struct Book
  {
   int    nBuy, nSell;
   double lotBuy, lotSell;
   double plBuy, plSell;
   double sumDirLot;      // sum( dir * openPrice * lots )
   double avgBuy, avgSell;
   ulong  worstTk;  double worstPL;
   ulong  bestTk;   double bestPL;
  };

string   g_armed = "";      // kaun sa button armed hai
datetime g_armedAt = 0;

//+------------------------------------------------------------------+
int OnInit()
  {
   trade.SetDeviationInPoints(InpSlippage);
   trade.SetTypeFillingBySymbol(_Symbol);
   if(InpAllowButtons) MakeButtons();
   EventSetTimer(1);          // market band ho to bhi panel chalta rahe
   // Toolbox -> Experts tab mein ye line aani chahiye. Agar panel nazar na
   // aaye magar ye line ho, to EA zinda hai aur masla sirf dikhne ka hai.
   PrintFormat("JAS DESK %s chal raha hai | chart ka symbol %s | is par %d lot | poore account par %d",
               EA_BUILD, _Symbol, CountOn(_Symbol), PositionsTotal());
   Draw();
   return(INIT_SUCCEEDED);
  }

void OnDeinit(const int reason)
  {
   EventKillTimer();
   Comment("");
   ObjectsDeleteAll(0, "JD_");
  }

//--- kisi bhi symbol par kitni lots khuli hain
int CountOn(string sym)
  {
   int n = 0;
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      if(!pos.SelectByIndex(i)) continue;
      if(sym != "" && pos.Symbol() != sym) continue;
      n++;
     }
   return(n);
  }

//--- doosre symbols par kya para hai, naam ke saath
string OtherSymbols()
  {
   string s = "";
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      if(!pos.SelectByIndex(i))   continue;
      if(pos.Symbol() == _Symbol) continue;
      if(StringFind(s, pos.Symbol()) < 0)
         s += (s == "" ? "" : ", ") + pos.Symbol();
     }
   return(s);
  }

//+------------------------------------------------------------------+
void ReadBook(Book &b)
  {
   b.nBuy = 0; b.nSell = 0; b.lotBuy = 0; b.lotSell = 0;
   b.plBuy = 0; b.plSell = 0; b.sumDirLot = 0;
   b.avgBuy = 0; b.avgSell = 0;
   b.worstTk = 0; b.worstPL = DBL_MAX;
   b.bestTk  = 0; b.bestPL  = -DBL_MAX;
   double wBuy = 0, wSell = 0;

   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      if(!pos.SelectByIndex(i))     continue;
      if(pos.Symbol() != _Symbol)   continue;
      double v  = pos.Volume();
      double px = pos.PriceOpen();
      double pl = pos.Profit() + pos.Swap() + pos.Commission();

      if(pos.PositionType() == POSITION_TYPE_BUY)
        { b.nBuy++;  b.lotBuy  += v; b.plBuy  += pl; wBuy  += px * v; b.sumDirLot += px * v; }
      else
        { b.nSell++; b.lotSell += v; b.plSell += pl; wSell += px * v; b.sumDirLot -= px * v; }

      if(pl < b.worstPL) { b.worstPL = pl; b.worstTk = pos.Ticket(); }
      if(pl > b.bestPL)  { b.bestPL  = pl; b.bestTk  = pos.Ticket(); }
     }
   b.avgBuy  = (b.lotBuy  > 0) ? wBuy  / b.lotBuy  : 0;
   b.avgSell = (b.lotSell > 0) ? wSell / b.lotSell : 0;
   if(b.worstPL == DBL_MAX)  b.worstPL = 0;
   if(b.bestPL  == -DBL_MAX) b.bestPL  = 0;
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

//+------------------------------------------------------------------+
void OnTick()   { Draw(); }
void OnTimer()  { Draw(); }

//+------------------------------------------------------------------+
void Draw()
  {
   Book b; ReadBook(b);
   double net    = b.lotBuy - b.lotSell;
   double tot    = b.lotBuy + b.lotSell;
   double basket = b.plBuy + b.plSell;
   double perPt  = MoneyPerPoint();
   double bid    = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   double bal    = AccountInfoDouble(ACCOUNT_BALANCE);
   double eq     = AccountInfoDouble(ACCOUNT_EQUITY);
   double mgn    = AccountInfoDouble(ACCOUNT_MARGIN);
   double freeM  = AccountInfoDouble(ACCOUNT_MARGIN_FREE);
   double mlvl   = AccountInfoDouble(ACCOUNT_MARGIN_LEVEL);

   string s = "=== JAS DESK  " + EA_BUILD + " ===   " + _Symbol + "\n";
   s += "(ye EA trade nahi karta - sirf hisaab)\n\n";

   s += StringFormat("BUY  : %d lot  %.2f   ausat %s   P/L %s\n",
                     b.nBuy, b.lotBuy, Px(b.avgBuy), M(b.plBuy));
   s += StringFormat("SELL : %d lot  %.2f   ausat %s   P/L %s\n",
                     b.nSell, b.lotSell, Px(b.avgSell), M(b.plSell));
   s += StringFormat("NET  : %+.2f      KUL %.2f      KITAB %s\n\n",
                     net, tot, M(basket));

   //--- BARABAR KA PRICE (break even) ------------------------------
   if(tot <= 0.0)
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
     }
   else if(MathAbs(net) < 1e-8)
     {
      s += "BARABAR KA PRICE: koi nahi - NET 0 hai.\n";
      s += "  Kitab JAM chuki hai. Qeemat kahin bhi jaye, " + M(basket) + " nahi badlega.\n";
      s += "  Nikalne ka ek hi raasta: ek taraf band karna.\n";
     }
   else
     {
      double be = b.sumDirLot / net;
      s += StringFormat("BARABAR KA PRICE: %s   (abhi %s, faasla %s)\n",
                        Px(be), Px(bid), Px(MathAbs(be - bid)));
      s += StringFormat("  Qeemat ko %s taraf %s chalna hoga.\n\n",
                        (be > bid ? "UPAR" : "NEECHE"), Px(MathAbs(be - bid)));
     }

   //--- HAR RAASTE KI KEEMAT ---------------------------------------
   if(tot > 0.0 && perPt > 0.0)
     {
      s += "--- Har raaste ki keemat ABHI ---\n";
      s += StringFormat("1. Sab band karein      : %s\n", M(basket));
      s += StringFormat("2. Sirf BUY band karein : %s   (bachegi %.2f sell)\n",
                        M(b.plBuy), b.lotSell);
      s += StringFormat("3. Sirf SELL band karein: %s   (bachegi %.2f buy)\n",
                        M(b.plSell), b.lotBuy);
      s += StringFormat("4. Sab se buri lot band : %s\n", M(b.worstPL));
      s += StringFormat("5. Achi + buri jori band: %s\n\n", M(b.bestPL + b.worstPL));

      // ek taraf band karne ke baad kitni harkat chahiye
      if(b.lotBuy > 0 && b.lotSell > 0)
        {
         double leftS = b.plSell, leftB = b.plBuy;
         if(b.lotSell > 0 && leftS < 0)
            s += StringFormat("  BUY band kar ke: sell %.2f bachegi, usay %s chahiye\n",
                              b.lotSell, Px(MathAbs(leftS) / (b.lotSell * perPt)));
         if(b.lotBuy > 0 && leftB < 0)
            s += StringFormat("  SELL band kar ke: buy %.2f bachegi, usay %s chahiye\n",
                              b.lotBuy, Px(MathAbs(leftB) / (b.lotBuy * perPt)));
         s += "\n";
        }
     }

   //--- ACCOUNT AUR KHATRA -----------------------------------------
   s += "--- Account ---\n";
   s += StringFormat("Balance %s    Equity %s\n", M(bal), M(eq));
   s += StringFormat("Margin  %s    Free %s    Level %.1f%%\n", M(mgn), M(freeM), mlvl);

   // ACCOUNT_MARGIN_SO_SO double hai, integer nahi - AccountInfoDouble se aata hai.
   // Aur SO_MODE batata hai ke woh percent mein hai ya paise mein.
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
      s += StringFormat("Stop out %.0f%% par. Qeemat %s tak khilaf jaye to wahan pohnchega.\n",
                        soVal, Px(room));
     }

   if(InpAllowButtons)
     {
      s += "\nButton CHALU hain. Ek dafa click = tayyar, dobara click = ho jayega.";
      if(g_armed != "")
         s += "\n>> " + g_armed + " TAYYAR HAI - pakka karne ke liye dobara click <<";
     }
   else
      s += "\nButton BAND hain (sirf dekhne ka panel).";

   Comment(s);
  }

//+------------------------------------------------------------------+
void MakeButton(string name, string text, int row)
  {
   string n = "JD_" + name;
   if(ObjectFind(0, n) < 0)
      ObjectCreate(0, n, OBJ_BUTTON, 0, 0, 0);
   ObjectSetInteger(0, n, OBJPROP_XDISTANCE, InpX);
   ObjectSetInteger(0, n, OBJPROP_YDISTANCE, InpY + row * 26);
   ObjectSetInteger(0, n, OBJPROP_XSIZE, 200);
   ObjectSetInteger(0, n, OBJPROP_YSIZE, 22);
   ObjectSetInteger(0, n, OBJPROP_CORNER, CORNER_RIGHT_UPPER);
   ObjectSetString (0, n, OBJPROP_TEXT, text);
   ObjectSetInteger(0, n, OBJPROP_FONTSIZE, InpFont);
   ObjectSetInteger(0, n, OBJPROP_BGCOLOR, clrDimGray);
   ObjectSetInteger(0, n, OBJPROP_COLOR, clrWhite);
   ObjectSetInteger(0, n, OBJPROP_STATE, false);
  }

void MakeButtons()
  {
   MakeButton("BUY",   "1. BUY side band karo",   0);
   MakeButton("SELL",  "2. SELL side band karo",  1);
   MakeButton("ALL",   "3. SAB band karo",        2);
   MakeButton("WORST", "4. Sab se buri lot band", 3);
   MakeButton("PAIR",  "5. Achi + buri jori band", 4);
   MakeButton("FLAT",  "6. NET sifar karo",       5);
  }

//+------------------------------------------------------------------+
void OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam)
  {
   if(id != CHARTEVENT_OBJECT_CLICK) return;
   if(StringFind(sparam, "JD_") != 0) return;
   ObjectSetInteger(0, sparam, OBJPROP_STATE, false);
   if(!InpAllowButtons) return;

   string what = StringSubstr(sparam, 3);

   if(g_armed != what || (TimeCurrent() - g_armedAt) > InpConfirmSecs)
     {
      g_armed   = what;
      g_armedAt = TimeCurrent();
      Draw();
      return;
     }

   g_armed = "";
   Book b; ReadBook(b);

   if(what == "BUY")   CloseSide(true);
   if(what == "SELL")  CloseSide(false);
   if(what == "ALL")   { CloseSide(true); CloseSide(false); }
   if(what == "WORST" && b.worstTk > 0) trade.PositionClose(b.worstTk);
   if(what == "PAIR")
     {
      if(b.bestTk  > 0) trade.PositionClose(b.bestTk);
      if(b.worstTk > 0 && b.worstTk != b.bestTk) trade.PositionClose(b.worstTk);
     }
   if(what == "FLAT")  Flatten();
   Draw();
  }

//+------------------------------------------------------------------+
void CloseSide(bool buySide)
  {
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      if(!pos.SelectByIndex(i))   continue;
      if(pos.Symbol() != _Symbol) continue;
      bool isBuy = (pos.PositionType() == POSITION_TYPE_BUY);
      if(isBuy != buySide) continue;
      trade.PositionClose(pos.Ticket());
     }
  }

//--- NET sifar: zyada wali taraf se utni lots band jitna net hai,
//--- aur un mein achi aur buri dono mila kar.
void Flatten()
  {
   Book b; ReadBook(b);
   double net = b.lotBuy - b.lotSell;
   if(MathAbs(net) < 1e-8) return;
   bool heavyIsBuy = (net > 0);
   double togo = MathAbs(net);

   ulong tk[]; double pf[], vl[];
   int n = 0;
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      if(!pos.SelectByIndex(i))   continue;
      if(pos.Symbol() != _Symbol) continue;
      if((pos.PositionType() == POSITION_TYPE_BUY) != heavyIsBuy) continue;
      ArrayResize(tk, n + 1); ArrayResize(pf, n + 1); ArrayResize(vl, n + 1);
      tk[n] = pos.Ticket();
      pf[n] = pos.Profit() + pos.Swap() + pos.Commission();
      vl[n] = pos.Volume();
      n++;
     }
   if(n == 0) return;

   // faide ke hisaab se tarteeb: acha pehle, bura aakhir mein
   for(int a = 1; a < n; a++)
     {
      ulong  kt = tk[a]; double kp = pf[a], kv = vl[a];
      int    c  = a - 1;
      while(c >= 0 && pf[c] < kp)
        { pf[c+1] = pf[c]; tk[c+1] = tk[c]; vl[c+1] = vl[c]; c--; }
      pf[c+1] = kp; tk[c+1] = kt; vl[c+1] = kv;
     }

   double run = 0; int lo = 0, hi = n - 1;
   while(togo > 1e-8 && lo <= hi)
     {
      int pick = (run < 0) ? lo : hi;   // ghata hai to acha lo, warna bura
      if(vl[pick] <= togo + 1e-8 && trade.PositionClose(tk[pick]))
        { run += pf[pick]; togo -= vl[pick]; }
      if(pick == lo) lo++; else hi--;
     }
   Print("JAS DESK: NET sifar - jorh ", DoubleToString(run, 2));
  }
//+------------------------------------------------------------------+
