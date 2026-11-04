//+------------------------------------------------------------------+
//|  JAS FTMO VIEW   -   build v1.0  (4 Nov 2026)                    |
//|                                                                  |
//|  INDICATOR HAI, EA NAHI. SIRF DEKHNE KA PANEL - TRADE NAHI KARTA.|
//|  Kisi bhi chart par EA ke SAATH lag jata hai (EA ko nahi hatata).|
//|                                                                  |
//|  KHUD CHECK KAREIN (MetaEditor mein Ctrl+F):                     |
//|    "OrderSend" / "ositionClose" / "#include" -> sirf isi comment |
//|  Sirf parhne wale functions: PositionGet*, AccountInfo*,         |
//|  SymbolInfo*, OrderCalcProfit (hisaab), GlobalVariableGet.       |
//|                                                                  |
//|  Dikhata hai (bara font, size aap ka):                           |
//|   - equity, FTMO target (110k), aaj ka farsh (EA ke pehra wala)  |
//|   - har khuli trade: EA naam (magic se), instrument, lot, entry, |
//|     SL, faida, R (SL ke nuqsan ke hisaab se)                     |
//|   - har EA ke market aur kitni trade khuli                       |
//+------------------------------------------------------------------+
#property copyright "JAS"
#property version   "1.00"
#property indicator_chart_window
#property indicator_plots 0

#define V_BUILD "v1.0"
#define PFX     "JFV_"

input int    InpFont      = 12;              // Font size (bara = 14, 16)
input string InpFontName  = "Consolas";      // Font (barabar chaurai wala behtar)
input ENUM_BASE_CORNER InpCorner = CORNER_LEFT_UPPER; // Panel kis kone mein
input int    InpX         = 10;              // Kone se door (daayen / baayen)
input int    InpY         = 20;              // Kone se door (upar / neeche)
input double InpStartBal  = 100000.0;        // Challenge shuru balance (EA jaisa)
input double InpTargetPct = 10.0;            // Target % (EA jaisa)
input double InpDayStopPct = 4.0;            // Din ka nuqsan % (EA jaisa)
input color  InpColHead   = clrGold;         // Sar-khi ka rang
input color  InpColText   = clrWhite;        // Aam likhai
input color  InpColPlus   = clrLime;         // Faida
input color  InpColMinus  = clrTomato;       // Nuqsan

string Pick(bool c, string a, string b) { if(c) return(a); return(b); }

string EaName(long magic)
  {
   if(magic == 20261029) return("t5");
   if(magic == 20261022) return("i6");
   if(magic == 20261101) return("k2");
   if(magic == 20261102) return("c1");
   if(magic == 0)        return("HAATH");
   return(StringFormat("m%I64d", magic));
  }

string Pad(string s, int n)
  {
   while(StringLen(s) < n) s = s + " ";
   return(s);
  }

string Px(string sym, double v)
  {
   return(DoubleToString(v, (int)SymbolInfoInteger(sym, SYMBOL_DIGITS)));
  }

int g_rows = 0;

void Row(int i, string txt, color c)
  {
   string nm = PFX + IntegerToString(i);
   if(ObjectFind(0, nm) < 0)
     {
      ObjectCreate(0, nm, OBJ_LABEL, 0, 0, 0);
      ObjectSetInteger(0, nm, OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, nm, OBJPROP_HIDDEN, true);
     }
   bool low = (InpCorner == CORNER_LEFT_LOWER || InpCorner == CORNER_RIGHT_LOWER);
   bool rgt = (InpCorner == CORNER_RIGHT_UPPER || InpCorner == CORNER_RIGHT_LOWER);
   int  step = (int)MathRound(InpFont * 1.8);
   ObjectSetInteger(0, nm, OBJPROP_CORNER, InpCorner);
   ObjectSetInteger(0, nm, OBJPROP_ANCHOR,
                    low ? (rgt ? ANCHOR_RIGHT_LOWER : ANCHOR_LEFT_LOWER) : (rgt ? ANCHOR_RIGHT_UPPER : ANCHOR_LEFT_UPPER));
   ObjectSetInteger(0, nm, OBJPROP_XDISTANCE, InpX);
   ObjectSetInteger(0, nm, OBJPROP_YDISTANCE, InpY + i * step);
   ObjectSetInteger(0, nm, OBJPROP_FONTSIZE, InpFont);
   ObjectSetString(0, nm, OBJPROP_FONT, InpFontName);
   ObjectSetInteger(0, nm, OBJPROP_COLOR, c);
   ObjectSetString(0, nm, OBJPROP_TEXT, txt);
  }

void Draw()
  {
   int    r   = 0;
   long   login = AccountInfoInteger(ACCOUNT_LOGIN);
   double eq  = AccountInfoDouble(ACCOUNT_EQUITY);
   double bal = AccountInfoDouble(ACCOUNT_BALANCE);
   double tgt = InpStartBal * (1.0 + InpTargetPct / 100.0);
   string pg  = StringFormat("JASPH_%I64d_", login);
   double gb  = 0.0;
   string floorTxt = "pata nahi (EA ne abhi din ka balance nahi likha)";
   if(GlobalVariableGet(pg + "B", gb) && gb > 0.0)
      floorTxt = DoubleToString(gb - InpDayStopPct / 100.0 * InpStartBal, 0);

   Row(r++, StringFormat("=== JAS FTMO VIEW %s | account %I64d ===", V_BUILD, login), InpColHead);
   Row(r++, StringFormat("Equity %.2f | Balance %.2f", eq, bal), InpColText);
   Row(r++, StringFormat("Target %.0f (baqi %.0f) | Aaj ka farsh %s", tgt, tgt - eq, floorTxt), InpColText);
   Row(r++, "EA    Instrument  Lot    Entry      SL         Faida      R", InpColHead);

   int    n = PositionsTotal(), cT = 0, cI = 0, cK = 0, cO = 0;
   double kul = 0.0;
   for(int i = 0; i < n; i++)
     {
      ulong tk = PositionGetTicket(i);
      if(tk == 0 || !PositionSelectByTicket(tk)) continue;
      string sym  = PositionGetString(POSITION_SYMBOL);
      long   mg   = PositionGetInteger(POSITION_MAGIC);
      long   typ  = PositionGetInteger(POSITION_TYPE);
      double vol  = PositionGetDouble(POSITION_VOLUME);
      double op   = PositionGetDouble(POSITION_PRICE_OPEN);
      double sl   = PositionGetDouble(POSITION_SL);
      double pr   = PositionGetDouble(POSITION_PROFIT) + PositionGetDouble(POSITION_SWAP);
      kul += pr;
      string ea = EaName(mg);
      if(ea == "t5") cT++;
      else if(ea == "i6") cI++;
      else if(ea == "k2") cK++;
      else cO++;
      string rTxt = "SL nahi";
      if(sl > 0.0)
        {
         double loss = 0.0;
         ENUM_ORDER_TYPE ot = (typ == POSITION_TYPE_BUY) ? ORDER_TYPE_BUY : ORDER_TYPE_SELL;
         if(OrderCalcProfit(ot, sym, vol, op, sl, loss) && MathAbs(loss) > 0.0)
            rTxt = StringFormat("%+.2f", pr / MathAbs(loss));
         else
            rTxt = "?";
        }
      string line = Pad(ea, 6) + Pad(sym + Pick(typ == POSITION_TYPE_BUY, " B", " S"), 12)
                    + Pad(DoubleToString(vol, 2), 7) + Pad(Px(sym, op), 11)
                    + Pad(Pick(sl > 0.0, Px(sym, sl), "-"), 11)
                    + Pad(StringFormat("%+.2f", pr), 11) + rTxt;
      Row(r++, line, pr >= 0.0 ? InpColPlus : InpColMinus);
     }
   if(n == 0) Row(r++, "Koi khuli trade nahi", InpColText);
   Row(r++, StringFormat("Kul: %d trade | %+.2f", n, kul), kul >= 0.0 ? InpColPlus : InpColMinus);
   Row(r++, StringFormat("t5 (%d) XAU XAG US500 USTEC | i6 (%d) US500 USTEC", cT, cI), InpColText);
   Row(r++, StringFormat("k2 (%d) DE30 UK100 FR40 STOXX50 JP225 AUS200 HK50 | doosri %d", cK, cO), InpColText);

   for(int j = r; j < g_rows; j++) ObjectDelete(0, PFX + IntegerToString(j));
   g_rows = r;
   ChartRedraw(0);
  }

int OnInit()
  {
   IndicatorSetString(INDICATOR_SHORTNAME, "JasFtmoView " + V_BUILD);
   EventSetTimer(1);
   Draw();
   return(INIT_SUCCEEDED);
  }

void OnDeinit(const int reason)
  {
   EventKillTimer();
   ObjectsDeleteAll(0, PFX);
   ChartRedraw(0);
  }

void OnTimer() { Draw(); }

int OnCalculate(const int rates_total, const int prev_calculated, const datetime &time[],
                const double &open[], const double &high[], const double &low[], const double &close[],
                const long &tick_volume[], const long &volume[], const int &spread[])
  {
   return(rates_total);
  }
//+------------------------------------------------------------------+
