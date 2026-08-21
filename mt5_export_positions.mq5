//+------------------------------------------------------------------+
//|  mt5_export_positions.mq5                                        |
//|  MT5 SCRIPT — open positions ko TradingView wale format mein      |
//|  nikal deta hai, taake seedha copy-paste ho jaye.                 |
//+------------------------------------------------------------------+
//
//  KAAM KYA HAI:
//     Aapki saari open positions parh kar ye text banata hai:
//
//         buy 0.01 4355.759
//         buy 0.04 4470.677
//         sell 0.01 4573.640
//
//     Yehi format "MT5 Positions Overlay" wala Pine script mangta hai.
//
//  TEXT KAHAN MILEGA — do jagah:
//     1) File mein:  MQL5\Files\tv_positions.txt
//        (File -> Open Data Folder -> MQL5 -> Files)
//     2) Toolbox ke "Experts" tab mein — wahan se select karke Ctrl+C
//
//  LAGANE KA TAREEQA:
//     MetaEditor mein paste -> Compile (F7) -> MT5 ke Navigator mein
//     "Scripts" ke neeche milega -> chart par drag karein.
//
//+------------------------------------------------------------------+
#property copyright "JAS-SNIPER-BOT"
#property version   "1.00"
#property script_show_inputs
#property description "Open positions ko TradingView paste format mein nikalta hai"

input bool   OnlyThisSymbol = true;              // Sirf is chart ka symbol
input bool   WriteToFile    = true;              // File bhi banayein
input string FileName       = "tv_positions.txt";// File ka naam
input bool   ShowPopup      = true;              // Kaam ke baad popup dikhayein

//+------------------------------------------------------------------+
//| Ek position ki line banata hai                                    |
//+------------------------------------------------------------------+
string BuildLine(const long type, const double volume,
                 const double price, const int digits)
  {
   string side = (type == POSITION_TYPE_BUY) ? "buy" : "sell";
   return StringFormat("%s %s %s",
                       side,
                       DoubleToString(volume, 2),
                       DoubleToString(price, digits));
  }

//+------------------------------------------------------------------+
//| Script ka asal kaam                                               |
//+------------------------------------------------------------------+
void OnStart()
  {
   string chartSym = _Symbol;
   string out      = "";

   int    nBuy     = 0;
   int    nSell    = 0;
   double buyLots  = 0.0;
   double sellLots = 0.0;
   double buyNot   = 0.0;   // Σ (lot × entry)  buys
   double selNot   = 0.0;   // Σ (lot × entry)  sells
   double totalPL  = 0.0;   // profit + swap

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
      double profit = PositionGetDouble(POSITION_PROFIT);
      double swap   = PositionGetDouble(POSITION_SWAP);

      int digits = (int)SymbolInfoInteger(sym, SYMBOL_DIGITS);

      string line = BuildLine(type, volume, price, digits);
      out += line + "\r\n";

      if(type == POSITION_TYPE_BUY)
        {
         nBuy++;
         buyLots += volume;
         buyNot  += volume * price;
        }
      else
        {
         nSell++;
         sellLots += volume;
         selNot   += volume * price;
        }

      totalPL += profit + swap;
     }

   int found = nBuy + nSell;

   if(found == 0)
     {
      string msg = OnlyThisSymbol
                   ? StringFormat("%s par koi open position nahi mili.", chartSym)
                   : "Koi open position nahi mili.";
      Print(msg);
      if(ShowPopup)
         MessageBox(msg, "TV Export", MB_ICONINFORMATION);
      return;
     }

   // ---- breakeven: wo price jahan poora basket sifar par aata hai ----
   double netLots = buyLots - sellLots;
   double be      = 0.0;
   bool   haveBE  = (MathAbs(netLots) > 0.0000001);
   if(haveBE)
      be = (buyNot - selNot) / netLots;

   int    d       = (int)SymbolInfoInteger(chartSym, SYMBOL_DIGITS);
   double avgBuy  = (buyLots  > 0) ? buyNot / buyLots  : 0.0;
   double avgSell = (sellLots > 0) ? selNot / sellLots : 0.0;

   // ---- Experts tab mein chhaap dein (wahan se copy ho sakta hai) ----
   Print("================ TRADINGVIEW PASTE — START ================");
   string lines[];
   int n = StringSplit(out, '\n', lines);
   for(int i = 0; i < n; i++)
     {
      string ln = lines[i];
      StringReplace(ln, "\r", "");
      if(StringLen(ln) > 0)
         Print(ln);
     }
   Print("================= TRADINGVIEW PASTE — END =================");

   // ---- file bhi bana dein ----
   bool   fileOK   = false;
   string filePath = "";
   if(WriteToFile)
     {
      int h = FileOpen(FileName, FILE_WRITE | FILE_TXT | FILE_ANSI);
      if(h != INVALID_HANDLE)
        {
         FileWriteString(h, out);
         FileClose(h);
         fileOK   = true;
         filePath = TerminalInfoString(TERMINAL_DATA_PATH) +
                    "\\MQL5\\Files\\" + FileName;
         Print("File bani: ", filePath);
        }
      else
         Print("File nahi ban saki. Error: ", GetLastError());
     }

   // ---- summary ----
   string summary = StringFormat(
                       "Positions mil gayin: %d\n\n"
                       "BUY   %d   lots %.2f   avg %s\n"
                       "SELL  %d   lots %.2f   avg %s\n"
                       "NET   lots %.2f\n"
                       "BREAKEVEN  %s\n"
                       "Kul P/L  %.2f %s\n\n"
                       "Text yahan hai:\n"
                       "1) Toolbox -> Experts tab (select karke Ctrl+C)\n"
                       "%s",
                       found,
                       nBuy,  buyLots,  (buyLots  > 0 ? DoubleToString(avgBuy,  d) : "—"),
                       nSell, sellLots, (sellLots > 0 ? DoubleToString(avgSell, d) : "—"),
                       netLots,
                       (haveBE ? DoubleToString(be, d) : "— (buy aur sell barabar hain)"),
                       totalPL, AccountInfoString(ACCOUNT_CURRENCY),
                       (fileOK ? "2) File: " + filePath : "2) File nahi bani"));

   Print(summary);

   if(ShowPopup)
      MessageBox(summary, "TradingView Export", MB_ICONINFORMATION);
  }
//+------------------------------------------------------------------+
