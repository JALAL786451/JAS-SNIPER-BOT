//+------------------------------------------------------------------+
//|  JAS SARKAO   -   build z1  (3 Nov 2026)                         |
//|                                                                  |
//|  YE SCRIPT HAI, EA NAHI. MetaEditor mein "Scripts" folder mein   |
//|  banayein. Ek dafa chalta hai, kaam kar ke khud band ho jata hai.|
//|                                                                  |
//|  User ka "sarkao" (Fishing method, METHOD.md) - user ne 3 Nov    |
//|  khud manga: ek SELL ka kuch hissa band, wahi lot UPAR dobara.   |
//|                                                                  |
//|  Kya karta hai (sirf EK ticket par):                             |
//|   1) InpTicket wali SELL mein se InpCutLot band (partial close). |
//|      Baqi lot wahin, usi purani qeemat par khuli rehti hai.      |
//|   2) Wahi InpCutLot nayi SELL:                                   |
//|        InpUpar = 0   -> abhi bazaar par SELL (kul nateeja wahi,  |
//|                         sirf ticket ki qeemat badalti + spread)  |
//|        InpUpar > 0   -> SELL LIMIT = abhi ki Bid + InpUpar ($)   |
//|                         (qeemat wahan pahunche to khulegi)       |
//|   Nayi SELL ka SL / TP = purani ticket jaisa (0 ho to 0).        |
//|                                                                  |
//|  Kya NAHI karta: kisi aur ticket ko nahi chhoota, BUY par nahi   |
//|  chalta, cut lot >= poori lot ho to kuch nahi.                   |
//|  Chalne se pehle EK dafa poochta hai (Yes / No, pehle se No).    |
//|  PEHLE DEMO par chalayein.                                       |
//+------------------------------------------------------------------+
#property copyright "JAS"
#property version   "1.00"
#property script_show_inputs

#include <Trade\Trade.mqh>

#define S_BUILD "z1"

input ulong  InpTicket = 0;      // SELL ka ticket number (misaal 1986762364)
input double InpCutLot = 1.00;   // Kitni lot band karni hai (baqi wahin rahegi)
input double InpUpar   = 0.0;    // Nayi SELL: 0 = abhi bazaar par; > 0 = abhi ki qeemat se itne $ UPAR SELL LIMIT
input int    InpSlip   = 30;     // Qeemat ka farq (points) jo qabool hai

CTrade trade;

string Pick(bool c, string a, string b) { if(c) return(a); return(b); }

void OnStart()
  {
   if(InpTicket == 0)
     {
      MessageBox("Ticket number daalein (Inputs: InpTicket).\nKuch nahi kiya.", "JAS SARKAO " + S_BUILD, MB_OK | MB_ICONWARNING);
      return;
     }
   if(!PositionSelectByTicket(InpTicket))
     {
      MessageBox(StringFormat("Ticket #%I64u khuli nahi mili.\nKuch nahi kiya.", InpTicket), "JAS SARKAO " + S_BUILD, MB_OK | MB_ICONWARNING);
      return;
     }
   string sym  = PositionGetString(POSITION_SYMBOL);
   long   typ  = PositionGetInteger(POSITION_TYPE);
   double vol  = PositionGetDouble(POSITION_VOLUME);
   double open = PositionGetDouble(POSITION_PRICE_OPEN);
   double sl   = PositionGetDouble(POSITION_SL);
   double tp   = PositionGetDouble(POSITION_TP);
   double pnl  = PositionGetDouble(POSITION_PROFIT);
   int    dg   = (int)SymbolInfoInteger(sym, SYMBOL_DIGITS);
   if(typ != POSITION_TYPE_SELL)
     {
      MessageBox(StringFormat("Ticket #%I64u SELL nahi hai.\nKuch nahi kiya.", InpTicket), "JAS SARKAO " + S_BUILD, MB_OK | MB_ICONWARNING);
      return;
     }
   double step = SymbolInfoDouble(sym, SYMBOL_VOLUME_STEP);
   double mn   = SymbolInfoDouble(sym, SYMBOL_VOLUME_MIN);
   double cut  = MathFloor(InpCutLot / step + 1e-9) * step;
   cut = NormalizeDouble(cut, 2);
   if(cut < mn || cut >= vol - mn / 2.0)
     {
      MessageBox(StringFormat("Cut lot %.2f theek nahi (ticket ki lot %.2f, kam az kam %.2f, aur poori lot se kam honi chahiye).\nKuch nahi kiya.", cut, vol, mn),
                 "JAS SARKAO " + S_BUILD, MB_OK | MB_ICONWARNING);
      return;
     }
   if(!TerminalInfoInteger(TERMINAL_TRADE_ALLOWED) || !MQLInfoInteger(MQL_TRADE_ALLOWED))
     {
      MessageBox("Algo Trading ki ijazat nahi hai (upar Algo Trading button hara karein).\nKuch nahi kiya.", "JAS SARKAO " + S_BUILD, MB_OK | MB_ICONWARNING);
      return;
     }
   double bid   = SymbolInfoDouble(sym, SYMBOL_BID);
   double ask   = SymbolInfoDouble(sym, SYMBOL_ASK);
   double pt    = SymbolInfoDouble(sym, SYMBOL_POINT);
   double stopL = (double)SymbolInfoInteger(sym, SYMBOL_TRADE_STOPS_LEVEL) * pt;
   double cutPnl = pnl * cut / vol;
   double lim   = NormalizeDouble(bid + InpUpar, dg);
   if(InpUpar > 0 && lim - bid <= stopL)
     {
      MessageBox(StringFormat("SELL LIMIT %s abhi ki qeemat ke bohot qareeb (broker hadd %s).\nKuch nahi kiya.", DoubleToString(lim, dg), DoubleToString(stopL, dg)),
                 "JAS SARKAO " + S_BUILD, MB_OK | MB_ICONWARNING);
      return;
     }
   bool demo = AccountInfoInteger(ACCOUNT_TRADE_MODE) == ACCOUNT_TRADE_MODE_DEMO;
   string msg = StringFormat("Account %I64d  (%s)\n\nTicket #%I64u  SELL %.2f @ %s  (abhi %s)\n\n"
                             "1) %.2f band (bazaar par)  ~ %s %s pakka\n"
                             "2) %.2f baqi rahegi @ %s\n"
                             "3) Nayi SELL %.2f: %s\n\nKul nuqsan/faida is se nahi badalta - sirf jab nayi SELL behtar qeemat par lage.\n\nKarna hai?",
                             AccountInfoInteger(ACCOUNT_LOGIN), Pick(demo, "DEMO", "LIVE - ASLI PAISA"),
                             InpTicket, vol, DoubleToString(open, dg), DoubleToString(bid, dg),
                             cut, DoubleToString(cutPnl, 2), AccountInfoString(ACCOUNT_CURRENCY),
                             vol - cut, DoubleToString(open, dg),
                             cut, Pick(InpUpar > 0, "SELL LIMIT @ " + DoubleToString(lim, dg) + " (abhi se " + DoubleToString(InpUpar, 2) + " upar)", "abhi bazaar par ~" + DoubleToString(bid, dg)));
   int ans = MessageBox(msg, "JAS SARKAO " + S_BUILD + "  -  " + sym, MB_YESNO | MB_ICONQUESTION | MB_DEFBUTTON2);
   if(ans != IDYES)
     {
      Print("JAS SARKAO ", S_BUILD, ": user ne NO kaha - kuch nahi kiya");
      return;
     }
   trade.SetDeviationInPoints(InpSlip);
   trade.SetTypeFillingBySymbol(sym);
   if(!trade.PositionClosePartial(InpTicket, cut, InpSlip))
     {
      MessageBox(StringFormat("Partial close FAIL: %d %s\nNayi SELL NAHI lagi.", (int)trade.ResultRetcode(), trade.ResultRetcodeDescription()),
                 "JAS SARKAO " + S_BUILD, MB_OK | MB_ICONERROR);
      return;
     }
   double cp = trade.ResultPrice();
   bool ok;
   string cmt = "JAS SARKAO " + S_BUILD;
   if(InpUpar > 0)
      ok = trade.SellLimit(cut, lim, sym, sl, tp, ORDER_TIME_GTC, 0, cmt);
   else
      ok = trade.Sell(cut, sym, 0.0, sl, tp, cmt);
   double np = InpUpar > 0 ? lim : trade.ResultPrice();
   string rep = StringFormat("1) %.2f band @ %s\n", cut, DoubleToString(cp, dg));
   if(ok)
      rep += StringFormat("2) Nayi %s %.2f @ %s\n", Pick(InpUpar > 0, "SELL LIMIT", "SELL"), cut, DoubleToString(np, dg));
   else
      rep += StringFormat("2) Nayi SELL FAIL: %d %s  (%.2f band ho chuki - haath se lagayein)\n", (int)trade.ResultRetcode(), trade.ResultRetcodeDescription(), cut);
   Print("JAS SARKAO ", S_BUILD, ": ", rep);
   uint flg = MB_OK | MB_ICONERROR;
   if(ok)
      flg = MB_OK | MB_ICONINFORMATION;
   MessageBox(rep, "JAS SARKAO " + S_BUILD + "  -  nateeja", flg);
  }
//+------------------------------------------------------------------+
