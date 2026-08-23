//+------------------------------------------------------------------+
//|  mt5_position_panel.mq5                                          |
//|  MT5 INDICATOR — live panel + breakeven line                      |
//+------------------------------------------------------------------+
//
//  CHART PAR KYA DIKHAYEGA (sab live, har tick par update):
//
//     Kitni positions khuli hain   — buy aur sell alag alag
//     Kul lots                     — buy, sell, net
//     Average entry                — buy ka aur sell ka
//     Kul profit / loss            — profit + swap
//     🟡 BREAKEVEN line            — wo price jahan poora basket sifar par aata hai
//     Average entry lines          — buy ka (green), sell ka (red)
//
//  Breakeven wo cheez hai jo MT5 khud nahi batata. Us line ke upar poora
//  basket faide mein, neeche nuqsan mein.
//
//  LAGANE KA TAREEQA:
//     MetaEditor mein paste -> Compile (F7) -> MT5 ke Navigator mein
//     "Indicators" ke neeche milega -> chart par drag karein.
//
//+------------------------------------------------------------------+
#property copyright "JAS-SNIPER-BOT"
#property version   "1.00"
#property indicator_chart_window
#property indicator_plots   0
#property indicator_buffers 0

//--- inputs
input bool   OnlyThisSymbol = true;                 // Sirf is chart ka symbol
input bool   ShowBreakeven  = true;                 // Breakeven line
input bool   ShowAvgLines   = true;                 // Average entry lines
input color  ColBE          = clrGold;              // Breakeven line ka rang
input color  ColBuy         = clrLime;              // BUY ka rang
input color  ColSell        = clrTomato;            // SELL ka rang
input color  ColText        = clrWhite;             // Panel text ka rang
input int    PanelX         = 12;                   // Panel — kinare se doori
input int    PanelY         = 28;                   // Panel — upar se doori
input int    FontSize       = 14;                   // Font size (bara = zyada bara)
input string FontName       = "Consolas Bold";      // Font ("Arial Bold" bhi chalega)

//--- object names
#define PFX  "JASPANEL_"
#define LN_BE   PFX + "BE"
#define LN_ABUY PFX + "AVGBUY"
#define LN_ASEL PFX + "AVGSELL"

#define ROWS 8

//+------------------------------------------------------------------+
int OnInit()
  {
   IndicatorSetString(INDICATOR_SHORTNAME, "Position Panel");
   BuildLabels();
   EventSetMillisecondTimer(400);
   Refresh();
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   EventKillTimer();
   ObjectsDeleteAll(0, PFX);
   ChartRedraw();
  }
//+------------------------------------------------------------------+
void OnTimer()
  {
   Refresh();
  }
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
   Refresh();
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Panel ki khali rows banata hai                                    |
//+------------------------------------------------------------------+
void BuildLabels()
  {
   for(int r = 0; r < ROWS; r++)
     {
      string nm = PFX + "ROW" + (string)r;
      if(ObjectFind(0, nm) < 0)
         ObjectCreate(0, nm, OBJ_LABEL, 0, 0, 0);

      ObjectSetInteger(0, nm, OBJPROP_CORNER,    CORNER_LEFT_UPPER);
      ObjectSetInteger(0, nm, OBJPROP_XDISTANCE, PanelX);
      ObjectSetInteger(0, nm, OBJPROP_YDISTANCE, PanelY + r * (FontSize + 7));
      ObjectSetInteger(0, nm, OBJPROP_FONTSIZE,  FontSize);
      ObjectSetString(0,  nm, OBJPROP_FONT,      FontName);
      ObjectSetInteger(0, nm, OBJPROP_COLOR,     ColText);
      ObjectSetInteger(0, nm, OBJPROP_SELECTABLE,false);
      ObjectSetInteger(0, nm, OBJPROP_HIDDEN,    true);
      ObjectSetInteger(0, nm, OBJPROP_BACK,      false);
      ObjectSetString(0,  nm, OBJPROP_TEXT,      " ");   // space, warna MT5 "Label" dikha deta hai
     }
  }
//+------------------------------------------------------------------+
void SetRow(const int r, const string txt, const color clr)
  {
   string nm = PFX + "ROW" + (string)r;
   ObjectSetString(0,  nm, OBJPROP_TEXT,  txt);
   ObjectSetInteger(0, nm, OBJPROP_COLOR, clr);
  }
//+------------------------------------------------------------------+
//| Horizontal line banata / hataata hai                              |
//+------------------------------------------------------------------+
void SetHLine(const string nm, const bool on, const double price,
              const color clr, const int width, const ENUM_LINE_STYLE style)
  {
   if(!on || price <= 0.0)
     {
      if(ObjectFind(0, nm) >= 0)
         ObjectDelete(0, nm);
      return;
     }

   if(ObjectFind(0, nm) < 0)
      ObjectCreate(0, nm, OBJ_HLINE, 0, 0, price);

   ObjectSetDouble(0,  nm, OBJPROP_PRICE,      price);
   ObjectSetInteger(0, nm, OBJPROP_COLOR,      clr);
   ObjectSetInteger(0, nm, OBJPROP_WIDTH,      width);
   ObjectSetInteger(0, nm, OBJPROP_STYLE,      style);
   ObjectSetInteger(0, nm, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, nm, OBJPROP_HIDDEN,     true);
   ObjectSetInteger(0, nm, OBJPROP_BACK,       true);
  }
//+------------------------------------------------------------------+
//| Asal hisaab aur panel update                                      |
//+------------------------------------------------------------------+
void Refresh()
  {
   string chartSym = _Symbol;
   int    d        = (int)SymbolInfoInteger(chartSym, SYMBOL_DIGITS);
   string cur      = AccountInfoString(ACCOUNT_CURRENCY);

   int    nBuy = 0, nSell = 0;
   double buyLots = 0.0, sellLots = 0.0;
   double buyNot  = 0.0, selNot   = 0.0;
   double buyPL   = 0.0, selPL    = 0.0;

   int total = PositionsTotal();

   for(int i = 0; i < total; i++)
     {
      ulong ticket = PositionGetTicket(i);
      if(ticket == 0)
         continue;
      if(!PositionSelectByTicket(ticket))
         continue;

      string sym = PositionGetString(POSITION_SYMBOL);
      if(OnlyThisSymbol && sym != chartSym)
         continue;

      long   type   = PositionGetInteger(POSITION_TYPE);
      double volume = PositionGetDouble(POSITION_VOLUME);
      double price  = PositionGetDouble(POSITION_PRICE_OPEN);
      double pl     = PositionGetDouble(POSITION_PROFIT) +
                      PositionGetDouble(POSITION_SWAP);

      if(type == POSITION_TYPE_BUY)
        {
         nBuy++;
         buyLots += volume;
         buyNot  += volume * price;
         buyPL   += pl;
        }
      else
        {
         nSell++;
         sellLots += volume;
         selNot   += volume * price;
         selPL    += pl;
        }
     }

   int    found   = nBuy + nSell;
   double netLots = buyLots - sellLots;
   double totalPL = buyPL + selPL;

   double avgBuy  = (buyLots  > 0) ? buyNot / buyLots  : 0.0;
   double avgSell = (sellLots > 0) ? selNot / sellLots : 0.0;

   bool   haveBE = (MathAbs(netLots) > 0.0000001);
   double be     = haveBE ? (buyNot - selNot) / netLots : 0.0;

   //--- lines
   SetHLine(LN_BE,   ShowBreakeven && haveBE,        be,     ColBE,   2, STYLE_SOLID);
   SetHLine(LN_ABUY, ShowAvgLines  && buyLots  > 0,  avgBuy, ColBuy,  1, STYLE_DOT);
   SetHLine(LN_ASEL, ShowAvgLines  && sellLots > 0,  avgSell,ColSell, 1, STYLE_DOT);

   //--- panel
   color plCol = (totalPL >= 0) ? ColBuy : ColSell;

   SetRow(0, StringFormat("%s   —   %d open position%s",
                          chartSym, found, (found == 1 ? "" : "s")), ColText);

   SetRow(1, StringFormat("BUY   %2d   lots %6.2f   avg %s",
                          nBuy, buyLots,
                          (buyLots > 0 ? DoubleToString(avgBuy, d) : "—")), ColBuy);

   SetRow(2, StringFormat("SELL  %2d   lots %6.2f   avg %s",
                          nSell, sellLots,
                          (sellLots > 0 ? DoubleToString(avgSell, d) : "—")), ColSell);

   SetRow(3, StringFormat("NET        lots %6.2f", netLots), ColText);

   SetRow(4, " ", ColText);   // khali line (space), warna "Label" nazar aata hai

   if(haveBE)
     {
      double last = SymbolInfoDouble(chartSym, SYMBOL_BID);
      double away = last - be;
      SetRow(5, StringFormat("BREAKEVEN  %s   (%s%s)",
                             DoubleToString(be, d),
                             (away >= 0 ? "+" : ""),
                             DoubleToString(away, d)), ColBE);
     }
   else
      SetRow(5, "BREAKEVEN  —  buy aur sell barabar hain", ColBE);

   SetRow(6, StringFormat("P/L   buy %.2f   sell %.2f", buyPL, selPL), ColText);
   SetRow(7, StringFormat("TOTAL  %.2f %s", totalPL, cur), plCol);

   ChartRedraw();
  }
//+------------------------------------------------------------------+
