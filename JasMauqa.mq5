//+------------------------------------------------------------------+
//|  JAS MAUQA   -   build m1  (3 Nov 2026)                          |
//|                                                                  |
//|  EA (chart par chalta rehta hai). KHUD KOI TRADE NAHI KARTA.     |
//|  Har 2 second kitab dekhta hai aur FAIDE ka mauqa dikhata hai:   |
//|   1) FAIDE WALI TICKET : sab se zyada faide wali lot (>= hadd)   |
//|   2) BEHTAREEN JORI    : SELL + BUY Close By jis ka nateeja      |
//|                          musbat (SELL ki qeemat > BUY ki qeemat) |
//|   3) BARI SELL KAM     : sab se bari SELL ki behtareen musbat    |
//|                          jori - SELL ghat-ti hai, spread nahi    |
//|   4) TICKETS           : khuli + pending / Exness hadd 200;      |
//|                          hadd - 20 par laal + alert              |
//|  Har mauqe ke saath button. Button -> poori detail -> YES / NO.  |
//|  YES par sirf wahi EK kaam (PositionClose ya PositionCloseBy).   |
//|  InpDikhana = true (default): button sirf detail dikhata hai,    |
//|  kaam NAHI karta. Numbers DeskView se mila kar false karein.     |
//|  Sirf chart ke symbol ki lots (haath ki bhi). Naya lot NAHI.     |
//+------------------------------------------------------------------+
#property copyright "JAS"
#property version   "1.00"

#include <Trade\Trade.mqh>

#define S_BUILD "m1"

input bool   InpDikhana   = true;   // true = sirf dikhana (button kaam nahi karta); false = YES par kaam
input double InpMinFaida  = 20.0;   // 1) Ticket ka faida kam az kam (account currency, USC)
input double InpMinJori   = 5.0;    // 2/3) Jori ka nateeja kam az kam (USC)
input int    InpHadd      = 200;    // 4) Broker ki ticket hadd (khuli + pending)
input int    InpBachao    = 20;     // 4) Hadd se itni pehle warning
input bool   InpPush      = true;   // Naya mauqa aaye to Alert + phone push (15 min mein zyada se zyada ek)

CTrade trade;

struct PInfo { ulong t; long typ; double vol; double open; double pnl; };

ulong  g1 = 0, g2s = 0, g2b = 0, g3s = 0, g3b = 0;
double g1v = 0, g2v = 0, g3v = 0;
string gLast = "";
datetime gAlertT = 0;

string Pick(bool c, string a, string b) { if(c) return(a); return(b); }
string Px(double v) { return(DoubleToString(v, (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS))); }

double Vpp()
  {
   double tv = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);
   double ts = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);
   if(ts <= 0) return(0);
   return(tv / ts);   // 1 lot, qeemat 1.0 hile to kitna (account currency)
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

void Scan()
  {
   PInfo a[];
   int n = Gather(a);
   double vpp = Vpp();
   g1 = 0; g1v = 0; g2s = 0; g2b = 0; g2v = 0; g3s = 0; g3b = 0; g3v = 0;
   int big = -1;
   for(int i = 0; i < n; i++)
     {
      if(a[i].pnl >= InpMinFaida && a[i].pnl > g1v) { g1 = a[i].t; g1v = a[i].pnl; }
      if(a[i].typ == POSITION_TYPE_SELL && (big < 0 || a[i].vol > a[big].vol)) big = i;
     }
   for(int i = 0; i < n; i++)
     {
      if(a[i].typ != POSITION_TYPE_SELL) continue;
      for(int j = 0; j < n; j++)
        {
         if(a[j].typ != POSITION_TYPE_BUY) continue;
         double r = (a[i].open - a[j].open) * MathMin(a[i].vol, a[j].vol) * vpp;
         if(r >= InpMinJori && r > g2v) { g2s = a[i].t; g2b = a[j].t; g2v = r; }
         if(i == big && r >= InpMinJori && r > g3v) { g3s = a[i].t; g3b = a[j].t; g3v = r; }
        }
     }
   int tk = PositionsTotal() + OrdersTotal();
   bool warn = tk >= InpHadd - InpBachao;
   string s = StringFormat("=== JAS MAUQA %s ===  %s  |  %s  |  khud trade NAHI karta\n", S_BUILD, _Symbol, Pick(InpDikhana, "SIRF DIKHANA (button kaam nahi karega)", "YES par kaam karega"));
   s += StringFormat("Kitab: %d lot is symbol par | Equity %s\n\n", n, DoubleToString(AccountInfoDouble(ACCOUNT_EQUITY), 2));
   s += Pick(g1 > 0, StringFormat("1) FAIDE WALI TICKET  #%I64u  +%s  -> [1] band", g1, DoubleToString(g1v, 2)), StringFormat("1) Faide wali ticket: koi nahi (>= %s)", DoubleToString(InpMinFaida, 2))) + "\n";
   s += Pick(g2s > 0, StringFormat("2) BEHTAREEN JORI  SELL #%I64u + BUY #%I64u  = +%s  -> [2] Close By", g2s, g2b, DoubleToString(g2v, 2)), StringFormat("2) Jori: koi musbat nahi (>= %s)", DoubleToString(InpMinJori, 2))) + "\n";
   s += Pick(g3s > 0, StringFormat("3) BARI SELL KAM  SELL #%I64u + BUY #%I64u  = +%s  -> [3] Close By", g3s, g3b, DoubleToString(g3v, 2)), "3) Bari SELL ki koi musbat jori nahi") + "\n";
   s += StringFormat("4) TICKETS: %d / %d  %s\n", tk, InpHadd, Pick(warn, "!!! HADD KE QAREEB - nayi lot mat kholein, jori band karein", "theek"));
   Comment(s);
   string key = StringFormat("%I64u|%I64u|%I64u|%d", g1, g2s * 7 + g2b, g3s * 7 + g3b, (int)warn);
   if(InpPush && key != gLast && (g1 > 0 || g2s > 0 || g3s > 0 || warn) && TimeCurrent() - gAlertT >= 900)
     {
      gAlertT = TimeCurrent();
      string m = StringFormat("JAS MAUQA %s: 1) %s  2) %s  3) %s  tickets %d", _Symbol, DoubleToString(g1v, 2), DoubleToString(g2v, 2), DoubleToString(g3v, 2), tk);
      Alert(m);
      SendNotification(m);
     }
   gLast = key;
  }

void Btn(string nm, string tx, int y)
  {
   if(ObjectFind(0, nm) < 0)
      ObjectCreate(0, nm, OBJ_BUTTON, 0, 0, 0);
   ObjectSetInteger(0, nm, OBJPROP_CORNER, CORNER_LEFT_UPPER);
   ObjectSetInteger(0, nm, OBJPROP_XDISTANCE, 10);
   ObjectSetInteger(0, nm, OBJPROP_YDISTANCE, y);
   ObjectSetInteger(0, nm, OBJPROP_XSIZE, 150);
   ObjectSetInteger(0, nm, OBJPROP_YSIZE, 24);
   ObjectSetString(0, nm, OBJPROP_TEXT, tx);
   ObjectSetInteger(0, nm, OBJPROP_FONTSIZE, 9);
  }

int OnInit()
  {
   Btn("JM_B1", "[1] Ticket band", 140);
   Btn("JM_B2", "[2] Jori Close By", 168);
   Btn("JM_B3", "[3] Bari SELL kam", 196);
   EventSetTimer(2);
   Scan();
   return(INIT_SUCCEEDED);
  }

void OnDeinit(const int reason)
  {
   EventKillTimer();
   ObjectDelete(0, "JM_B1");
   ObjectDelete(0, "JM_B2");
   ObjectDelete(0, "JM_B3");
   Comment("");
  }

void OnTimer() { Scan(); }
void OnTick()  { }

bool Ask(string detail)
  {
   bool demo = AccountInfoInteger(ACCOUNT_TRADE_MODE) == ACCOUNT_TRADE_MODE_DEMO;
   string hdr = StringFormat("Account %I64d  (%s)\n\n", AccountInfoInteger(ACCOUNT_LOGIN), Pick(demo, "DEMO", "LIVE - ASLI PAISA"));
   if(InpDikhana)
     {
      MessageBox(hdr + detail + "\n\nSIRF DIKHANA mode: kuch nahi kiya.\n(Inputs mein InpDikhana = false karein to YES par kaam hoga.)", "JAS MAUQA " + S_BUILD, MB_OK | MB_ICONINFORMATION);
      return(false);
     }
   return(MessageBox(hdr + detail + "\n\nKarna hai?", "JAS MAUQA " + S_BUILD, MB_YESNO | MB_ICONQUESTION | MB_DEFBUTTON2) == IDYES);
  }

string Desc(ulong t)
  {
   if(!PositionSelectByTicket(t)) return(StringFormat("#%I64u (band ho chuki)", t));
   return(StringFormat("#%I64u %s %.2f @ %s  (abhi %s)", t, Pick(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL, "SELL", "BUY"),
                       PositionGetDouble(POSITION_VOLUME), Px(PositionGetDouble(POSITION_PRICE_OPEN)),
                       DoubleToString(PositionGetDouble(POSITION_PROFIT) + PositionGetDouble(POSITION_SWAP), 2)));
  }

void DoJori(ulong s, ulong b, double v, string what)
  {
   if(s == 0) { MessageBox("Abhi koi musbat jori nahi.", "JAS MAUQA " + S_BUILD, MB_OK); return; }
   string d = StringFormat("%s (Close By - spread nahi, koi nayi lot nahi)\n\n%s\n%s\n\nAndazan nateeja: +%s\nTickets: 2 kam (ya 1 agar lot barabar nahi)",
                           what, Desc(s), Desc(b), DoubleToString(v, 2));
   if(!Ask(d)) return;
   Scan();   // dobara pakka: jori abhi bhi musbat?
   if(!PositionSelectByTicket(s) || !PositionSelectByTicket(b))
     { MessageBox("Lot badal gayi - kuch nahi kiya.", "JAS MAUQA " + S_BUILD, MB_OK | MB_ICONWARNING); return; }
   bool ok = trade.PositionCloseBy(s, b);
   string r = StringFormat("Close By %s: %d %s", Pick(ok, "HO GAYA", "FAIL"), (int)trade.ResultRetcode(), trade.ResultRetcodeDescription());
   Print("JAS MAUQA ", S_BUILD, ": ", r);
   MessageBox(r, "JAS MAUQA " + S_BUILD + " - nateeja", MB_OK);
   Scan();
  }

void OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam)
  {
   if(id != CHARTEVENT_OBJECT_CLICK) return;
   ObjectSetInteger(0, sparam, OBJPROP_STATE, false);
   Scan();
   if(sparam == "JM_B1")
     {
      if(g1 == 0) { MessageBox("Abhi koi faide wali ticket hadd se upar nahi.", "JAS MAUQA " + S_BUILD, MB_OK); return; }
      ulong t = g1;
      if(!Ask(StringFormat("FAIDE WALI TICKET band (bazaar par)\n\n%s\n\nFaida pakka: +%s", Desc(t), DoubleToString(g1v, 2)))) return;
      if(!PositionSelectByTicket(t)) { MessageBox("Ticket band ho chuki - kuch nahi kiya.", "JAS MAUQA " + S_BUILD, MB_OK); return; }
      bool ok = trade.PositionClose(t);
      string r = StringFormat("Band %s: %d %s", Pick(ok, "HO GAYI", "FAIL"), (int)trade.ResultRetcode(), trade.ResultRetcodeDescription());
      Print("JAS MAUQA ", S_BUILD, ": ", r);
      MessageBox(r, "JAS MAUQA " + S_BUILD + " - nateeja", MB_OK);
      Scan();
     }
   else if(sparam == "JM_B2")
      DoJori(g2s, g2b, g2v, "BEHTAREEN JORI");
   else if(sparam == "JM_B3")
      DoJori(g3s, g3b, g3v, "BARI SELL KAM");
  }
//+------------------------------------------------------------------+
