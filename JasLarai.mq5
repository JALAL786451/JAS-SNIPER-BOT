//+------------------------------------------------------------------+
//|  JAS LARAI   -   build j1  (16 Nov 2026)                          |
//|  Bunyad: JasMauqa m8.4 (JasMauqa_m84.mq5 - us ki tareekh wahin).  |
//|  User 16 Nov: "EA bohot saari lots mein ghus kar profit wali     |
//|  lots close kare, jori profit mein close kare, aur loss ko       |
//|  DEEWAR ki soorat mein against lot open kare" + jaldi mein       |
//|  dohri lot lag jati hai.                                         |
//|  j1 = m8.4 ka poora panel / hifazat / popup WAHI, + 4 naye kaam: |
//|   1) A / B jori (Close By, nafe wali, NET wahi) KHUD - popup     |
//|      nahi (InpAutoJori). Nateeja InpAutoMax se bara = popup.     |
//|   2) C profit ticket KHUD (InpAutoC) - SIRF jab |NET| na barhe;  |
//|      NET barhta ho to wahi purana popup. Dhaal kabhi nahi.       |
//|   3) W) DEEWAR (InpWall, default OFF): NET khula ho aur qeemat   |
//|      NET wali sab se nayi lots ki ausat se InpWallDist khilaf    |
//|      chali jaye -> ULTI lot (NET tak, InpWallMaxLot tak) market  |
//|      par, NET 0 ki taraf. NET se zyada KABHI nahi. InpWallAsk    |
//|      true = pehle YES/NO. Deewar nuqsan ROKTI hai, wapas nahi    |
//|      lati.                                                       |
//|   4) X) DOHRI LOT: wahi taraf + wahi lot InpDupSec second mein   |
//|      dobara lage -> popup "ghalti? YES = band".                  |
//|  N / E / D / H = m8.4 jaise (popup). Deewar ke siwa KOI nayi lot |
//|  nahi. Sirf chart ke symbol par. Pehle DEMO.                     |
//+------------------------------------------------------------------+
#property copyright "JAS"
#property version   "1.00"

#include <Trade\Trade.mqh>

#define S_BUILD "j1"

input double InpMinFaida = 20.0;   // C) Ticket ka faida kam az kam (USC)
input double InpMinJori  = 5.0;    // A/B) Jori (Close By) ka nateeja kam az kam (USC)
input int    InpHadd     = 200;    // Broker ticket hadd (khuli + pending)
input int    InpBachao   = 180;    // Is se zyada tickets = laal + sirf jori (ticket ghatane wali)
input int    InpWaitMin  = 15;     // Popup ke baad agla popup kitne minute baad
input double InpNetMove  = 0.10;   // HIFAZAT: ek kaam se |NET| zyada se zyada itna barhe
input double InpMaxNet   = 0.80;   // HIFAZAT: |NET| is se upar na jaye (abhi zyada ho to barhe nahi)
input double InpMinDoor  = 400.0;  // HIFAZAT: stop out kam az kam itne $ door rahe
input bool   InpPartD    = false;  // D) Bari SELL part close ka mashwara (false = BAND: bari SELL dhaal hai)
input int    InpPopFont  = 12;     // POPUP ka font (m7.5: 12 = chhota; bara = 16-20)
input bool   InpPopRight = true;   // m7.4 POPUP chart ke daayen (panel na dhake); false = baayen
input bool   InpPopLow   = true;   // m7.5 POPUP neeche kone mein (chart ka beech khula); false = upar
input double InpPartLot  = 0.10;   // D) Bari SELL profit mein ho to ek dafa kitni lot kam
input bool   InpHedge    = false;  // H) HEDGE LADDER chalu (BUY band kar ke NET 0 tak). false = sirf plan dikhao
input bool   InpHAuto    = false;  // H) true = khud band kare (sote waqt); false = har qadam YES/NO
input double InpHStep    = 10.0;   // H) har kitne $ girne par
input double InpHLot     = 0.05;   // H) har qadam kitni BUY lot band
input double InpHStart   = 0.0;    // H) pehla qadam is qeemat par (0 = bari SELL ki qeemat - InpHStep)
input bool   InpHReset   = false;  // H) true = qadam ginti 0 se (EA lagate waqt ek dafa)
input bool   InpPush     = true;   // Popup ke waqt phone push bhi
input int    InpFont     = 13;     // Panel ka font (bara = 14-16)
input bool   InpLadder   = true;   // PRICE LADDER dikhao
input double InpStep     = 25.0;   // LADDER ka qadam ($): -1, +1, +2, +4 qadam + breakeven
input bool   InpA        = true;   // m8.2 A) NUQSAN wali bari lot kam popup (faide wali dhaal kabhi nahi; false = A band)
input bool   InpRukh     = true;   // m7.3 RUKH 1D + 4H dikhao, badle to popup
input bool   InpNews     = true;   // m7.3 NEWS alarm (sirf bari / HIGH khabar)
input string InpNewsCur  = "USD";  // NEWS: kis currency ki khabar (gold = USD)
input int    InpNews1    = 30;     // NEWS: pehla alarm kitne minute pehle
input int    InpNews2    = 5;      // NEWS: doosra alarm kitne minute pehle
input bool   InpClean    = true;   // m7.7 MT5 ki "autotrade #..." lakeerein chart se khud mitao
input double InpBigLot   = 0.10;   // m7.7 is se bari lot = laal WARNING (sirf likhai, kuch band nahi)
input double InpBeNet    = 0.05;   // m7.8 NET is se kam = breakeven number nahi, "TALA-BAND" likho
input bool   InpLog      = true;   // m8.1 LOG file likho (MQL5\Files)
input int    InpLogMin   = 15;     // m8.1 snapshot har kitne minute
input bool   InpWReset   = false;  // m8.0 WASOOLI ginti 0 se (EA lagate waqt ek dafa true)
input bool   InpN        = true;   // m8.3 N) NET WAHI jori popup (chhoti SELL + nuqsan wali BUY, Close By)
input double InpNMaxLoss = 10.0;   // m8.3 N) har 0.01 lot par zyada se zyada nuqsan (USC)
input double InpNetCap   = 0.20;   // m8.4 NET is par / upar = N aur E popup pehle + laal chetawni "nayi BUY mat kholo"
input bool   InpCapB     = true;   // m8.4 NET InpNetCap se UPAR ho to B) jori band + C) sirf BUY ticket
input bool   InpE        = true;   // m8.3 E) BARABAR KAAT popup (bari BUY + dhaal, barabar lot)
input double InpELot     = 0.05;   // m8.3 E) ek dafa kitni lot dono se
input double InpShieldMin = 0.89;  // m8.3 DHAAL (bari SELL) ka kam se kam baqi lot
input int    InpEWaitMin = 60;     // m8.3 E) NO ke baad dobara kitne minute baad
input bool   InpAutoJori = true;   // j1 1) A / B jori (nafe wali, NET wahi) KHUD band - popup nahi
input bool   InpAutoC    = true;   // j1 2) C profit ticket KHUD band - sirf jab |NET| na barhe
input double InpAutoMax  = 1000.0; // j1 KHUD sirf jab nateeja is se kam ho; bara = popup (0 = hadd nahi)
input int    InpAutoSec  = 60;     // j1 do KHUD kaamon ke darmiyan kam az kam second
input bool   InpWall     = false;  // j1 3) DEEWAR chalu (ulti lot khol kar NET 0 ki taraf). false = sirf hisaab
input bool   InpWallAsk  = true;   // j1 DEEWAR se pehle YES/NO popup (false = KHUD)
input double InpWallDist = 15.0;   // j1 DEEWAR: qeemat nayi lots ki ausat se kitni khilaf jaye (gold 15, BTC 1000)
input double InpWallMinNet = 0.03; // j1 DEEWAR: |NET| is se kam ho to nahi
input double InpWallMaxLot = 1.00; // j1 DEEWAR: ek dafa zyada se zyada lot (NET se zyada kabhi nahi)
input bool   InpDup      = true;   // j1 4) DOHRI LOT popup (wahi taraf + wahi lot foran dobara)
input int    InpDupSec   = 10;     // j1 DOHRI: kitne second ke andar dobara lage to
input long   InpMagic    = 20261116; // j1 DEEWAR wali lot ka magic

CTrade trade;

struct PInfo { ulong t; long typ; double vol; double open; double pnl; datetime tm; long mag; };

datetime gNext = 0;
// m7.2 chart POPUP (MessageBox ka font nahi badalta - is liye apna dabba)
int      gPend = 0;        // 0 = kuch nahi, 1 = Close By, 2 = close, 3 = part close
ulong    gP1 = 0, gP2 = 0;
double   gPLot = 0, gPV = 0;   // m8.0 gPV = popup ka nateeja (wasooli ke liye)
double   gPVb = 0;             // m8.3 E) sirf BUY hisse ka nateeja
datetime gENext = 0;           // m8.3 E) NO ke baad agla waqt
string   gPNm = "";
bool     gPopOn = false;
datetime gPopT = 0;
string gHis = "";   // m7.6 popup ke liye hisaab
int gRow = 0;
string gPTx = "";   // m8.1 panel ki likhai (log ke liye)
datetime gLogT = 0;
datetime gAutoNext = 0;    // j1 agla KHUD kaam
datetime gWallNext = 0;    // j1 agli deewar / deewar popup
int      gWDir = 0;        // j1 popup wali deewar: -1 = SELL, +1 = BUY
string   gKnown = "";      // j1 pichhli dafa ki tickets (dohri lot ke liye)
bool     gKnownInit = false;
ulong    gDupT = 0;        // j1 dohri lot wali ticket (popup baqi)

void Ln(string tx, color c)
  {
   gPTx += tx + "\r\n";   // m8.1
   string nm = "JM_L" + IntegerToString(gRow);
   if(ObjectFind(0, nm) < 0)
     {
      ObjectCreate(0, nm, OBJ_LABEL, 0, 0, 0);
      ObjectSetInteger(0, nm, OBJPROP_CORNER, CORNER_LEFT_UPPER);
      ObjectSetInteger(0, nm, OBJPROP_SELECTABLE, false);
      ObjectSetString(0, nm, OBJPROP_FONT, "Consolas");
     }
   ObjectSetInteger(0, nm, OBJPROP_XDISTANCE, 12);
   ObjectSetInteger(0, nm, OBJPROP_YDISTANCE, 22 + gRow * (int)(InpFont * 2.0));
   ObjectSetInteger(0, nm, OBJPROP_FONTSIZE, InpFont);
   ObjectSetInteger(0, nm, OBJPROP_COLOR, c);
   ObjectSetString(0, nm, OBJPROP_TEXT, tx);
   gRow++;
  }

string Pick(bool c, string a, string b) { if(c) return(a); return(b); }
string Sg(double v) { return(Pick(v >= 0, "+", "") + DoubleToString(v, 2)); }   // m8.3 nishan ke saath

// m8.3 ticket se lot kam (poori ho to poori band)
bool ClosePart(ulong t, double lot)
  {
   if(!PositionSelectByTicket(t)) return(false);
   double v = PositionGetDouble(POSITION_VOLUME);
   if(lot >= v - 1e-9) return(trade.PositionClose(t));
   return(trade.PositionClosePartial(t, NormalizeDouble(lot, 2)));
  }

void PopHide() { ObjectsDeleteAll(0, "JM_P"); gPopOn = false; ChartRedraw(); }

void PopTx(string nm, int x, int y, string tx, string font, int fs, color c)
  {
   ObjectCreate(0, nm, OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, nm, OBJPROP_CORNER, CORNER_LEFT_UPPER);
   ObjectSetInteger(0, nm, OBJPROP_XDISTANCE, x);
   ObjectSetInteger(0, nm, OBJPROP_YDISTANCE, y);
   ObjectSetInteger(0, nm, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, nm, OBJPROP_BACK, false);
   ObjectSetInteger(0, nm, OBJPROP_ZORDER, 101);
   ObjectSetString(0, nm, OBJPROP_FONT, font);
   ObjectSetInteger(0, nm, OBJPROP_FONTSIZE, fs);
   ObjectSetInteger(0, nm, OBJPROP_COLOR, c);
   ObjectSetString(0, nm, OBJPROP_TEXT, tx);
  }

void PopBtn(string nm, int x, int y, int w, int h, string tx, color bg)
  {
   ObjectCreate(0, nm, OBJ_BUTTON, 0, 0, 0);
   ObjectSetInteger(0, nm, OBJPROP_CORNER, CORNER_LEFT_UPPER);
   ObjectSetInteger(0, nm, OBJPROP_XDISTANCE, x);
   ObjectSetInteger(0, nm, OBJPROP_YDISTANCE, y);
   ObjectSetInteger(0, nm, OBJPROP_XSIZE, w);
   ObjectSetInteger(0, nm, OBJPROP_YSIZE, h);
   ObjectSetInteger(0, nm, OBJPROP_BGCOLOR, bg);
   ObjectSetInteger(0, nm, OBJPROP_COLOR, clrWhite);
   ObjectSetInteger(0, nm, OBJPROP_BORDER_COLOR, clrWhite);
   ObjectSetString(0, nm, OBJPROP_FONT, "Arial Black");
   ObjectSetInteger(0, nm, OBJPROP_FONTSIZE, InpPopFont + 2);
   ObjectSetString(0, nm, OBJPROP_TEXT, tx);
   ObjectSetInteger(0, nm, OBJPROP_STATE, false);
   ObjectSetInteger(0, nm, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, nm, OBJPROP_ZORDER, 102);
  }

// body ki har line alag label; mauqa ka naam / Profit / LIVE = mota rangeen
void PopShow(string title, string body, bool ask)
  {
   PopHide();
   // OBJ_LABEL ki likhai 63 harf tak - lambi line ko lafzon par tod do (58)
   string raw[], ln[];
   int nr = StringSplit(body, '\n', raw), n = 0;
   for(int i = 0; i < nr; i++)
     {
      string rest = raw[i];
      do
        {
         string part = rest;
         if(StringLen(rest) > 58)
           {
            int cut = 58;
            while(cut > 20 && StringGetCharacter(rest, cut) != ' ') cut--;
            if(cut <= 20) { part = StringSubstr(rest, 0, 58); rest = StringSubstr(rest, 58); }
            else          { part = StringSubstr(rest, 0, cut); rest = StringSubstr(rest, cut + 1); }
           }
         else rest = "";
         ArrayResize(ln, n + 1); ln[n++] = part;
        }
      while(StringLen(rest) > 0);
     }
   int fs = MathMax(10, InpPopFont), lh = (int)(fs * 2.1);
   int maxc = StringLen(title);
   for(int i = 0; i < n; i++) maxc = MathMax(maxc, StringLen(ln[i]));
   int w = MathMax(400, (int)(maxc * fs * 0.85) + 50);   // m7.5 chhota
   int hBody = 0;
   for(int i = 0; i < n; i++) hBody += (StringLen(ln[i]) == 0 ? lh / 2 : lh);
   int x0 = 30;
   if(InpPopRight)   // m7.4: daayen kinare se 70 px andar (qeemat ki patti chhod kar)
      x0 = MathMax(30, (int)ChartGetInteger(0, CHART_WIDTH_IN_PIXELS) - w - 70);
   int y0 = 40, h = 30 + lh + 10 + hBody + 20 + lh * 2 + 20;
   if(InpPopLow)   // m7.5: neeche kone mein, waqt ki patti se 30 px upar
      y0 = MathMax(40, (int)ChartGetInteger(0, CHART_HEIGHT_IN_PIXELS) - h - 30);
   string bg = "JM_P_BG";
   ObjectCreate(0, bg, OBJ_RECTANGLE_LABEL, 0, 0, 0);
   ObjectSetInteger(0, bg, OBJPROP_CORNER, CORNER_LEFT_UPPER);
   ObjectSetInteger(0, bg, OBJPROP_XDISTANCE, x0);
   ObjectSetInteger(0, bg, OBJPROP_YDISTANCE, y0);
   ObjectSetInteger(0, bg, OBJPROP_XSIZE, w);
   ObjectSetInteger(0, bg, OBJPROP_YSIZE, h);
   ObjectSetInteger(0, bg, OBJPROP_BGCOLOR, C'18,22,30');
   ObjectSetInteger(0, bg, OBJPROP_BORDER_TYPE, BORDER_FLAT);
   ObjectSetInteger(0, bg, OBJPROP_COLOR, clrGold);
   ObjectSetInteger(0, bg, OBJPROP_WIDTH, 3);
   ObjectSetInteger(0, bg, OBJPROP_BACK, false);
   ObjectSetInteger(0, bg, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, bg, OBJPROP_ZORDER, 100);
   int y = y0 + 15;
   PopTx("JM_P_T", x0 + 20, y, title, "Arial Black", fs + 2, clrGold);
   y += lh + 10;
   for(int i = 0; i < n; i++)
     {
      if(StringLen(ln[i]) == 0) { y += lh / 2; continue; }
      string f = "Arial Bold"; int z = fs; color c = clrWhite;
      if(gPNm != "" && StringFind(ln[i], gPNm) >= 0)                          { f = "Arial Black"; z = fs + 4; c = clrYellow; }
      else if(StringFind(ln[i], "LIVE") >= 0)                                 { f = "Arial Black"; c = clrTomato; }
      else if(StringFind(ln[i], "Profit") == 0 || StringFind(ln[i], "Result") == 0 || StringFind(ln[i], "DONE") >= 0) { f = "Arial Black"; z = fs + 2; c = clrLime; }
      else if(StringFind(ln[i], "FAIL") >= 0 || StringFind(ln[i], "OFF") >= 0) { f = "Arial Black"; c = clrTomato; }
      else if(StringFind(ln[i], "NET") == 0 || StringFind(ln[i], "Tickets") == 0) c = clrAqua;
      PopTx("JM_P_L" + IntegerToString(i), x0 + 20, y, ln[i], f, z, c);
      y += lh;
     }
   y += 20;
   int bw = 170, bh = (int)(lh * 1.6);
   if(ask)
     {
      PopBtn("JM_P_YES", x0 + 20, y, bw, bh, "YES", C'0,130,60');
      PopBtn("JM_P_NO", x0 + 40 + bw, y, bw, bh, "NO", C'180,30,30');
     }
   else
      PopBtn("JM_P_OK", x0 + 20, y, bw, bh, "OK", C'40,90,160');
   gPopOn = true;
   gPopT = TimeCurrent();
   ChartRedraw();
  }

void DoPend()
  {
   int kind = gPend; ulong t1 = gP1, t2 = gP2; string nm = gPNm;
   gPend = 0;
   if(kind == 0) { PopHide(); return; }
   if(!AlgoOn() || (kind != 5 && !PositionSelectByTicket(t1)) || ((kind == 1 || kind == 4) && !PositionSelectByTicket(t2)))
     { PopShow("JAS LARAI " + S_BUILD, "Algo OFF or ticket changed\nnothing done.", false); return; }
   bool ok; double got = gPV; string ex = "";
   if(kind == 1) ok = trade.PositionCloseBy(t1, t2);
   else if(kind == 3) ok = trade.PositionClosePartial(t1, gPLot);
   else if(kind == 4)   // m8.3 E) pehle BUY, phir dhaal SELL
     {
      ok = ClosePart(t1, gPLot);
      if(ok && !ClosePart(t2, gPLot)) { got = gPVb; ex = StringFormat("LIVE: BUY %.2f kat gayi, SELL nahi kati - NET %.2f kam, khud dekhein", gPLot, gPLot); }
     }
   else if(kind == 5) ok = WallOpen(gWDir, gPLot);   // j1 deewar
   else          ok = trade.PositionClose(t1);
   string r = StringFormat("%s: %s  (%d %s)", nm, Pick(ok, "DONE", "FAIL"), (int)trade.ResultRetcode(), trade.ResultRetcodeDescription());
   Print("JAS LARAI ", S_BUILD, ": ", r);
   LogEv("YES -> " + r + "  nateeja ~" + M(got));   // m8.1
   if(ex != "") LogEv(ex);
   gLogT = 0;
   if(ok) GlobalVariableSet(WKey(), Wasool() + got);   // m8.0 WASOOLI (m8.3: N / E ka nuqsan ghat-ta hai)
   PopShow("JAS LARAI " + S_BUILD + " - NATEEJA", nm + "\n" + Pick(ok, "DONE", "FAIL") + StringFormat("  (%d %s)", (int)trade.ResultRetcode(), trade.ResultRetcodeDescription()) + Pick(ex == "", "", "\n" + ex), false);
  }
// j1 DEEWAR: ulti lot market par. Dobara jaanch - lot abhi ke NET se zyada KABHI nahi.
bool WallOpen(int dir, double lot)
  {
   double wb = 0, ws = 0;
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      ulong t = PositionGetTicket(i);
      if(t == 0 || PositionGetString(POSITION_SYMBOL) != _Symbol) continue;
      if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY) wb += PositionGetDouble(POSITION_VOLUME); else ws += PositionGetDouble(POSITION_VOLUME);
     }
   double nt = wb - ws;
   if(lot <= 0 || (dir < 0 && nt < lot - 1e-9) || (dir > 0 && -nt < lot - 1e-9))
     { Print(StringFormat("JAS LARAI deewar RAD: NET %+.2f badal gaya, lot %.2f nahi lagi", nt, lot)); return(false); }
   bool ok = (dir < 0) ? trade.Sell(lot, _Symbol, 0, 0, 0, "LARAI deewar") : trade.Buy(lot, _Symbol, 0, 0, 0, "LARAI deewar");
   uint rc = trade.ResultRetcode();
   return(ok && (rc == TRADE_RETCODE_DONE || rc == TRADE_RETCODE_PLACED || rc == TRADE_RETCODE_DONE_PARTIAL));
  }

// j1 KHUD kaam (popup ke baghair): kind 1 = Close By jori, 2 = ticket band
void AutoDo(int kind, ulong t1, ulong t2, double v, string nm)
  {
   bool ok = (kind == 1) ? trade.PositionCloseBy(t1, t2) : trade.PositionClose(t1);
   string r = StringFormat("%s  #%I64u + #%I64u: %s  (%d %s)", nm, t1, t2, Pick(ok, "DONE", "FAIL"), (int)trade.ResultRetcode(), trade.ResultRetcodeDescription());
   Print("JAS LARAI ", S_BUILD, " KHUD: ", r);
   LogEv("KHUD -> " + r + "  nateeja ~" + M(v));
   gLogT = 0;
   if(ok) GlobalVariableSet(WKey(), Wasool() + v);
   gAutoNext = TimeCurrent() + (ok ? MathMax(5, InpAutoSec) : 300);   // FAIL = 5 minute ruk
  }

string Px(double v) { return(DoubleToString(v, (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS))); }
string M(double v)  { return(DoubleToString(v, 2)); }

double Vpp()
  {
   double tv = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);
   double ts = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);
   if(ts <= 0) return(0);
   return(tv / ts);   // 1 lot par qeemat 1.0 hile to kitna (account currency)
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
      a[n].tm = (datetime)PositionGetInteger(POSITION_TIME);
      a[n].mag = PositionGetInteger(POSITION_MAGIC);
     }
   return(ArraySize(a));
  }

// HIFAZAT: naya NET (|n2|) zyada na barhe aur stop out door InpMinDoor se kam na ho
bool Safe(double n2, double n1, double freeE, double vpp)
  {
   if(MathAbs(n2) > MathAbs(n1) + InpNetMove + 1e-9) return(false);
   if(MathAbs(n2) > MathMax(InpMaxNet, MathAbs(n1)) + 1e-9) return(false);
   if(MathAbs(n2) * vpp <= 1e-9) return(true);
   return(freeE / (MathAbs(n2) * vpp) >= InpMinDoor);
  }

string WKey() { return(StringFormat("JM_WASOOL_%I64d_%s", AccountInfoInteger(ACCOUNT_LOGIN), _Symbol)); }
double Wasool() { return(GlobalVariableCheck(WKey()) ? GlobalVariableGet(WKey()) : 0); }
string GvKey() { return(StringFormat("JM_HSTEP_%I64d_%s", AccountInfoInteger(ACCOUNT_LOGIN), _Symbol)); }
int    HSteps() { return(GlobalVariableCheck(GvKey()) ? (int)GlobalVariableGet(GvKey()) : 0); }
void   HSet(int k) { GlobalVariableSet(GvKey(), k); }

// H) BUY band karo (lot tak): pehle bari SELL se NEECHE wali (SELL ke sab se qareeb pehle),
//    phir SELL se UPAR wali - SELL ke sab se QAREEB pehle (sab se upar wali NAHI) - user 3 Nov
double HClose(double want, double sOpen)
  {
   double done = 0, mnv = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN), stp = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);
   for(int pass = 0; pass < 2 && done < want - 1e-9; pass++)
     {
      for(int guard = 0; guard < 50 && done < want - 1e-9; guard++)
        {
         ulong best = 0; double bo = 0, bv = 0;
         for(int i = PositionsTotal() - 1; i >= 0; i--)
           {
            ulong t = PositionGetTicket(i);
            if(t == 0 || PositionGetString(POSITION_SYMBOL) != _Symbol || PositionGetInteger(POSITION_TYPE) != POSITION_TYPE_BUY) continue;
            double o = PositionGetDouble(POSITION_PRICE_OPEN);
            if(pass == 0 && o >= sOpen) continue;          // pehla daur: sirf SELL se neeche wali
            bool better = (pass == 0) ? (o > bo) : (o < bo);   // dono daur: SELL ke qareeb wali pehle
            if(best == 0 || better) { best = t; bo = o; bv = PositionGetDouble(POSITION_VOLUME); }
           }
         if(best == 0) break;
         double x = MathMin(bv, want - done);
         x = MathFloor(x / stp + 1e-9) * stp;
         if(x < mnv) break;
         bool ok = (x >= bv - 1e-9) ? trade.PositionClose(best) : trade.PositionClosePartial(best, NormalizeDouble(x, 2));
         Print(StringFormat("JAS LARAI H: BUY #%I64u %.2f @ %s band %s (%d)", best, x, DoubleToString(bo, _Digits), ok ? "OK" : "FAIL", (int)trade.ResultRetcode()));
         if(!ok) return(done);
         done += x;
        }
     }
   return(done);
  }

bool AlgoOn() { return(TerminalInfoInteger(TERMINAL_TRADE_ALLOWED) && MQLInfoInteger(MQL_TRADE_ALLOWED)); }

string Desc(ulong t)
  {
   if(!PositionSelectByTicket(t)) return(StringFormat("#%I64u (already closed)", t));
   return(StringFormat("#%I64u %s %.2f @ %s  (now %s)", t, Pick(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL, "SELL", "BUY"),
                       PositionGetDouble(POSITION_VOLUME), Px(PositionGetDouble(POSITION_PRICE_OPEN)),
                       M(PositionGetDouble(POSITION_PROFIT) + PositionGetDouble(POSITION_SWAP))));
  }

// ---- m7.3 RUKH: band candles (index 1 se). 1 = UP, -1 = DOWN, 0 = MILA. stDir = Supertrend(10,3)
// tools/tokri_q8q9.py rukh() jaisa: close > EMA50 > EMA200 + ST up = UP (ulta = DOWN)
int Rukh(ENUM_TIMEFRAMES tf, int &stDir)
  {
   MqlRates r[];
   ArraySetAsSeries(r, false);
   int n = CopyRates(_Symbol, tf, 1, 600, r);
   stDir = 0;
   if(n < 250) return(0);
   double a = 0, e50 = r[0].close, e200 = r[0].close, U = 0, D = 0;
   int d = 1;
   for(int i = 0; i < n; i++)
     {
      double tr = r[i].high - r[i].low;
      if(i > 0) tr = MathMax(tr, MathMax(MathAbs(r[i].high - r[i - 1].close), MathAbs(r[i].low - r[i - 1].close)));
      a = (i == 0) ? tr : a + (tr - a) / 10.0;
      if(i > 0) { e50 += (r[i].close - e50) * 2.0 / 51.0; e200 += (r[i].close - e200) * 2.0 / 201.0; }
      double hl2 = (r[i].high + r[i].low) / 2.0, up = hl2 - 3.0 * a, dn = hl2 + 3.0 * a;
      if(i == 0) { U = up; D = dn; continue; }
      double pU = U, pD = D, pc = r[i - 1].close;
      U = (pc > pU) ? MathMax(up, pU) : up;
      D = (pc < pD) ? MathMin(dn, pD) : dn;
      if(d == -1 && r[i].close > pD) d = 1;
      else if(d == 1 && r[i].close < pU) d = -1;
     }
   stDir = d;
   double c = r[n - 1].close;
   if(c > e50 && e50 > e200 && d > 0) return(1);
   if(c < e50 && e50 < e200 && d < 0) return(-1);
   return(0);
  }

string UD(int v) { return(Pick(v > 0, "UP", Pick(v < 0, "DOWN", "MILA"))); }

int      gSigPrev = 99;
string   gNoPairs = "";   // m7.3: jis jori par NO kaha, wo dobara nahi (EA chalne tak)
string   gNoTk = "";      // m7.9: jis C ticket par NO / jawab nahi, wo dobara nahi
void NoMark()
  {
   if(gPend == 1) { if(StringLen(gNoPairs) > 3000) gNoPairs = ""; gNoPairs += StringFormat("|%I64u_%I64u|", gP1, gP2); }
   if(gPend == 2) { if(StringLen(gNoTk) > 3000) gNoTk = ""; gNoTk += StringFormat("|%I64u|", gP1); }
   if(gPend == 4) gENext = TimeCurrent() + InpEWaitMin * 60;   // m8.3
  }

string   gNewsLn = "", gNewsDone = "";
datetime gNewsT = 0;

// NEWS: har 30 sec calendar dekho; agli bari khabar panel par, 30 / 5 min pehle popup + push
void NewsCheck(double net)
  {
   if(!InpNews) { gNewsLn = "NEWS alarm: band (InpNews)"; return; }
   if(TimeCurrent() - gNewsT < 30 && gNewsT > 0) return;
   gNewsT = TimeCurrent();
   datetime now = TimeTradeServer();
   MqlCalendarValue v[];
   int k = CalendarValueHistory(v, now - 60, now + 12 * 3600, NULL, InpNewsCur);
   datetime best = 0; string bn = "";
   for(int i = 0; i < k; i++)
     {
      MqlCalendarEvent ev;
      if(!CalendarEventById(v[i].event_id, ev) || ev.importance != CALENDAR_IMPORTANCE_HIGH) continue;
      if(v[i].time < now) continue;
      if(best == 0 || v[i].time < best) { best = v[i].time; bn = ev.name; }
      int mins = (int)((v[i].time - now) / 60);
      int stg = (mins < InpNews2) ? InpNews2 : ((mins < InpNews1) ? InpNews1 : 0);
      if(stg == 0) continue;
      string key = StringFormat("|%I64u_%d|", v[i].id, stg);
      if(StringFind(gNewsDone, key) >= 0) continue;
      if(StringLen(gNewsDone) > 3000) gNewsDone = "";
      gNewsDone += key + StringFormat("|%I64u_%d|", v[i].id, InpNews1);   // 5 min wala aaya to 30 wala dobara nahi
      int lots = (int)MathRound(MathAbs(net) / 0.01);
      string body = StringFormat("%s BARI KHABAR: %s\nWaqt %s (server)  -  %d min baqi\n\nDaam seconds mein upar-neeche ho sakta hai, spread khulega.\nNET %+.2f lot  =  %d x 0.01 dhaal se NET 0\nSpread abhi: %s $\n\nEA khud koi lot nahi kholega - faisla aap ka.",
                                 InpNewsCur, ev.name, TimeToString(v[i].time, TIME_MINUTES), mins, net, lots,
                                 DoubleToString(SymbolInfoInteger(_Symbol, SYMBOL_SPREAD) * _Point, 2));
      if(InpPush) SendNotification(StringFormat("JAS LARAI NEWS: %s %s %d min mein - NET %+.2f", InpNewsCur, ev.name, mins, net));
      PlaySound("alert2.wav");
      if(!gPopOn) { gPNm = ""; PopShow(StringFormat("NEWS ALARM  -  %d min", mins), body, false); }
     }
   if(best == 0) gNewsLn = StringFormat("NEWS: agle 12 ghante %s ki bari khabar nahi", InpNewsCur);
   else          gNewsLn = StringFormat("NEWS: %s  %s  (%d min baad)", bn, TimeToString(best, TIME_MINUTES), (int)((best - now) / 60));
  }

// m8.1 LOG: waqiat (jorta) + snapshot (har dafa naya)
void LogEv(string tx)
  {
   if(!InpLog) return;
   int h = FileOpen("JasLarai_" + _Symbol + "_waqiat.txt", FILE_READ | FILE_WRITE | FILE_TXT | FILE_ANSI);
   if(h == INVALID_HANDLE) return;
   FileSeek(h, 0, SEEK_END);
   FileWriteString(h, TimeToString(TimeCurrent(), TIME_DATE | TIME_SECONDS) + "  " + tx + "\r\n");
   FileClose(h);
  }

void LogSnap(PInfo &a[], int n)
  {
   if(!InpLog) return;
   int h = FileOpen("JasLarai_" + _Symbol + ".txt", FILE_WRITE | FILE_TXT | FILE_ANSI);
   if(h == INVALID_HANDLE) return;
   FileWriteString(h, StringFormat("JAS LARAI %s LOG  %s  server %s  account %I64d\r\n", S_BUILD, _Symbol,
                   TimeToString(TimeCurrent(), TIME_DATE | TIME_SECONDS), AccountInfoInteger(ACCOUNT_LOGIN)));
   FileWriteString(h, StringFormat("bid %s  balance %s  equity %s  wasooli %s\r\n\r\n--- PANEL ---\r\n",
                   Px(SymbolInfoDouble(_Symbol, SYMBOL_BID)), M(AccountInfoDouble(ACCOUNT_BALANCE)), M(AccountInfoDouble(ACCOUNT_EQUITY)), M(Wasool())));
   FileWriteString(h, gPTx);
   FileWriteString(h, StringFormat("\r\n--- KHULI TICKETS (%d) qeemat upar se neeche ---\r\nticket  type  lot  open  P/L  open_time\r\n", n));
   int ix[]; ArrayResize(ix, n);
   for(int i = 0; i < n; i++) ix[i] = i;
   for(int i = 1; i < n; i++)   // insertion sort: open price DESC
     { int k = ix[i], j = i - 1; while(j >= 0 && a[ix[j]].open < a[k].open) { ix[j + 1] = ix[j]; j--; } ix[j + 1] = k; }
   for(int q = 0; q < n; q++)
     {
      int i = ix[q];
      string ot = "-";
      if(PositionSelectByTicket(a[i].t)) ot = TimeToString((datetime)PositionGetInteger(POSITION_TIME), TIME_DATE | TIME_SECONDS);
      FileWriteString(h, StringFormat("%I64u  %s  %.2f  %s  %s  %s\r\n", a[i].t, Pick(a[i].typ == POSITION_TYPE_BUY, "BUY ", "SELL"), a[i].vol, Px(a[i].open), M(a[i].pnl), ot));
     }
   FileClose(h);
   gLogT = TimeCurrent();
  }

void Run()
  {
   if(InpClean && ObjectsTotal(0, -1, -1) > 0) ObjectsDeleteAll(0, "autotrade");
   PInfo a[];
   int n = Gather(a);
   // j1 4) DOHRI LOT: nayi ticket (pichhli dafa nahi thi) jo wahi taraf + wahi lot ki ticket ke InpDupSec second baad lagi
   if(InpDup)
     {
      string kn = "";
      for(int i = 0; i < n; i++)
        {
         string ky = StringFormat("|%I64u|", a[i].t);
         kn += ky;
         if(!gKnownInit || StringFind(gKnown, ky) >= 0 || a[i].mag == InpMagic) continue;
         for(int j = 0; j < n; j++)
            if(j != i && a[j].typ == a[i].typ && MathAbs(a[j].vol - a[i].vol) < 1e-9 && a[j].t < a[i].t && a[i].tm >= a[j].tm && a[i].tm - a[j].tm <= InpDupSec)
              { gDupT = a[i].t; break; }
        }
      gKnown = kn; gKnownInit = true;
     }
   double vpp = Vpp();
   double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   // ---- STATUS
   double kul = 0, bl = 0, sl = 0, bo = 0, so = 0, bp = 0, sp = 0, fp = 0, lp = 0, fl = 0, ll = 0;
   double fbl = 0, fsl = 0, fbp = 0, fsp = 0;   // m7.6 profit wali BUY / SELL lot + faida
   int bc = 0, sc = 0, big = -1, bigB = -1, fc = 0, lc = 0;   // m8.0 bigB = sab se bari BUY
   for(int i = 0; i < n; i++)
     {
      kul += a[i].pnl;
      if(a[i].pnl >= 0)
        {
         fc++; fl += a[i].vol; fp += a[i].pnl;
         if(a[i].typ == POSITION_TYPE_BUY) { fbl += a[i].vol; fbp += a[i].pnl; } else { fsl += a[i].vol; fsp += a[i].pnl; }
        }
      else { lc++; ll += a[i].vol; lp += a[i].pnl; }
      if(a[i].typ == POSITION_TYPE_BUY)
        {
         bc++; bl += a[i].vol; bo += a[i].vol * a[i].open; bp += a[i].pnl;
         if(bigB < 0 || a[i].vol > a[bigB].vol) bigB = i;
        }
      else
        {
         sc++; sl += a[i].vol; so += a[i].vol * a[i].open; sp += a[i].pnl;
         if(big < 0 || a[i].vol > a[big].vol) big = i;
        }
     }
   double net = bl - sl;
   double eq = AccountInfoDouble(ACCOUNT_EQUITY);
   double mg = AccountInfoDouble(ACCOUNT_MARGIN);
   double soLvl = AccountInfoDouble(ACCOUNT_MARGIN_SO_SO);
   double perD = net * vpp;
   string be = "-", door = "-";
   if(MathAbs(perD) > 1e-9)
     {
      be = Px(bid - kul / perD);
      double free = eq - mg * soLvl / 100.0;
      double d = free / MathAbs(perD);
      door = StringFormat("%s away (price %s)", DoubleToString(d, 1), Px(bid - (net > 0 ? 1 : -1) * d));
     }
   // m7.7: DOOSRE symbol (isi account par) ka NET + har $1 ka asar
   string oth = ""; double bigV = 0; int bigN = 0;
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      ulong t = PositionGetTicket(i);
      if(t == 0) continue;
      string sy = PositionGetString(POSITION_SYMBOL);
      if(sy == _Symbol || StringFind(oth, "|" + sy + "|") >= 0) continue;
      oth += "|" + sy + "|";
     }
   string othTx = "";
   string parts[]; int np = StringSplit(oth, '|', parts);
   for(int k = 0; k < np; k++)
     {
      if(parts[k] == "") continue;
      double ob = 0, os = 0;
      for(int i = PositionsTotal() - 1; i >= 0; i--)
        {
         ulong t = PositionGetTicket(i);
         if(t == 0 || PositionGetString(POSITION_SYMBOL) != parts[k]) continue;
         if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY) ob += PositionGetDouble(POSITION_VOLUME); else os += PositionGetDouble(POSITION_VOLUME);
        }
      double ots = SymbolInfoDouble(parts[k], SYMBOL_TRADE_TICK_SIZE);
      double ov = (ots > 0) ? SymbolInfoDouble(parts[k], SYMBOL_TRADE_TICK_VALUE) / ots : 0;
      othTx += StringFormat("|DOOSRA %s NET %+.2f  ($1 = %s)", parts[k], ob - os, M(MathAbs(ob - os) * ov));
     }
   double bigP = 0;   // m8.0 bari lot ka khula nuqsan / nafa
   for(int i = 0; i < n; i++) if(a[i].vol > InpBigLot + 1e-9) { bigN++; bigV = MathMax(bigV, a[i].vol); bigP += a[i].pnl; }
   double mlv = AccountInfoDouble(ACCOUNT_MARGIN_LEVEL);
   int tk = PositionsTotal() + OrdersTotal();
   bool full = tk > InpBachao;
   double freeE = eq - mg * soLvl / 100.0;
   // ---- MAUQA
   ulong aS = 0, aB = 0, jS = 0, jB = 0, cT = 0;
   double cN2 = 0;   // j1 C ke baad NET
   double aV = 0, jV = 0, cV = 0; string aNm = "";
   // m8.3: dhaal = sab se bari SELL (> InpBigLot); N jori; wasooli = N / E ka budget
   ulong nS = 0, nB = 0; double nV = 0, nD = 0;
   double wBud = Wasool(), lot1 = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
   bool dhOn = (big >= 0 && a[big].vol > InpBigLot + 1e-9);
   bool capHit = NormalizeDouble(net, 2) >= InpNetCap - 1e-9;              // m8.4 NET hadd par
   bool capOver = InpCapB && NormalizeDouble(net, 2) > InpNetCap + 1e-9;   // m8.4 NET hadd se upar
   for(int i = 0; i < n; i++)
     {
      if(i != big && i != bigB && a[i].pnl >= InpMinFaida && a[i].pnl > cV && StringFind(gNoTk, StringFormat("|%I64u|", a[i].t)) < 0 && !(capOver && a[i].typ == POSITION_TYPE_SELL))
        {
         double na_ = (a[i].typ == POSITION_TYPE_BUY) ? net - a[i].vol : net + a[i].vol;
         if(Safe(na_, net, freeE, vpp)) { cT = a[i].t; cV = a[i].pnl; cN2 = na_; }
        }
      if(a[i].typ != POSITION_TYPE_SELL) continue;
      if(dhOn && i == big) continue;   // m8.3 dhaal ko A / B / N kabhi nahi
      for(int j = 0; j < n; j++)
        {
         if(a[j].typ != POSITION_TYPE_BUY) continue;
         double r = (a[i].open - a[j].open) * MathMin(a[i].vol, a[j].vol) * vpp;
         if(StringFind(gNoPairs, StringFormat("|%I64u_%I64u|", a[i].t, a[j].t)) >= 0) continue;   // m7.3 NO = dobara nahi
         if(r < InpMinJori)
           {
            // m8.3 N) NET wahi: nuqsan wali BUY, farq chhota (sab se chhota farq pehle), wasooli ke andar
            double dd = a[j].open - a[i].open;
            if(InpN && a[j].pnl < 0 && dd * lot1 * vpp <= InpNMaxLoss + 1e-9 && wBud + r >= -1e-9 && (nS == 0 || dd < nD))
              { nS = a[i].t; nB = a[j].t; nV = r; nD = dd; }
            continue;
           }
         if(r > jV) { jS = a[i].t; jB = a[j].t; jV = r; }
         // m8.2: A = bari lot (> InpBigLot) jo NUQSAN mein ho - Close By, NET wahi; faide wali bari lot = dhaal
         bool bS = (a[i].vol > InpBigLot + 1e-9 && a[i].pnl < 0), bB = (a[j].vol > InpBigLot + 1e-9 && a[j].pnl < 0);
         if(InpA && (bS || bB) && r > aV) { aS = a[i].t; aB = a[j].t; aV = r; aNm = Pick(bB && !bS, "A) BARI BUY KAM", "A) BARI SELL KAM"); }
        }
     }
   if(full) { cT = 0; cV = 0; }
   // D) BARI SELL profit mein: thori lot kam (hifazat ke andar)
   ulong dT = 0; double dLot = 0, dV = 0;
   if(InpPartD && big >= 0 && a[big].pnl > 0 && !InpHedge)
     {
      double stp = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP), mnv = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
      double x = MathFloor(MathMin(InpPartLot, a[big].vol - mnv) / stp + 1e-9) * stp;
      double pv = a[big].pnl * x / a[big].vol;
      if(x >= mnv && pv >= InpMinJori && Safe(net + x, net, freeE, vpp)) { dT = a[big].t; dLot = NormalizeDouble(x, 2); dV = pv; }
     }
   // m8.3 E) BARABAR KAAT: sab se bari nuqsan wali BUY + dhaal, dono se barabar lot (market), NET wahi
   ulong eB = 0, eS = 0; double eLot = 0, eV = 0, eVb = 0;
   if(InpE && dhOn && bigB >= 0 && a[bigB].vol > InpBigLot + 1e-9 && a[bigB].pnl < 0 && a[bigB].open > a[big].open && TimeCurrent() >= gENext)
     {
      double est = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);
      double ex_ = MathMin(InpELot, MathMin(a[bigB].vol, a[big].vol - InpShieldMin));
      if(est > 0) ex_ = MathFloor(ex_ / est + 1e-9) * est;
      if(ex_ >= lot1 - 1e-9 && lot1 > 0)
        {
         eVb = a[bigB].pnl * ex_ / a[bigB].vol;
         double ev_ = eVb + a[big].pnl * ex_ / a[big].vol;
         if(wBud + ev_ >= -1e-9) { eB = a[bigB].t; eS = a[big].t; eLot = NormalizeDouble(ex_, 2); eV = ev_; }
        }
     }
   int wait = (int)(gNext - TimeCurrent());
   // ---- PANEL (bara font, rang)
   color cG = clrLime, cR = clrTomato, cW = clrWhite, cY = clrGold, cC = clrAqua;
   gRow = 0; gPTx = "";
   Ln(StringFormat("JAS LARAI %s  -  %s  -  Algo %s", S_BUILD, _Symbol, Pick(AlgoOn(), "ON (KHUD + popup)", "OFF (only status)")), AlgoOn() ? cG : cY);
   Ln(StringFormat("TOTAL P/L  %s        EQUITY  %s", M(kul), M(eq)), kul >= 0 ? cG : cR);
   Ln(StringFormat("PROFIT  %d ticket  %.2f lot   +%s", fc, fl, M(fp)), cG);
   Ln(StringFormat("LOSS    %d ticket  %.2f lot   %s", lc, ll, M(lp)), cR);
   Ln(StringFormat("BUY   %d ticket  %.2f lot  avg %s   P/L %s", bc, bl, Pick(bl > 0, Px(bl > 0 ? bo / bl : 0), "-"), M(bp)), bp >= 0 ? cG : cR);
   Ln(StringFormat("SELL  %d ticket  %.2f lot  avg %s   P/L %s", sc, sl, Pick(sl > 0, Px(sl > 0 ? so / sl : 0), "-"), M(sp)), sp >= 0 ? cG : cR);
   Ln(StringFormat("NET %+.2f lot  -  price $1 %s = %s", net, Pick(net >= 0, "down", "up"), M(-MathAbs(perD))), cC);
   // m7.5: poora hisaab + barabar karne ke liye kitna (sirf likhai, EA khud lot nahi kholta)
   double gap = MathAbs(NormalizeDouble(net, 2));
   Ln(StringFormat("NET = BUY %.2f - SELL %.2f = %+.2f  ->  %s", bl, sl, net,
      Pick(gap < 0.005, "barabar (0)", StringFormat("%s %.2f zyada | barabar: NAYI %s %.2f kholo ya PURANI %s %.2f close", Pick(net > 0, "BUY", "SELL"), gap, Pick(net > 0, "SELL", "BUY"), gap, Pick(net > 0, "BUY", "SELL"), gap))), clrYellow);
   // m7.6: profit utha lo to kya bachega + hedge kitna (SIRF HISAAB, EA khud lot nahi kholta)
   double rB = bl - fbl, rS = sl - fsl, rN = NormalizeDouble(rB - rS, 2), rG = MathAbs(rN);
   bool rBad = rG > InpMaxNet + 1e-9;
   string hz = Pick(rG < 0.005, "barabar (0) - hedge ki zaroorat nahi",
               StringFormat("NAYI %s %.2f lot kholo -> NET 0   (ya PURANI %s %.2f lot close karo)", Pick(rN > 0, "SELL", "BUY"), rG, Pick(rN > 0, "BUY", "SELL"), rG));
   Ln(StringFormat("PROFIT split:  BUY %.2f lot (+%s)  |  SELL %.2f lot (+%s)", fbl, M(fbp), fsl, M(fsp)), cG);
   Ln(StringFormat("AGAR SARE PROFIT TICKET CLOSE -> baqi BUY %.2f / SELL %.2f  =  NET %+.2f%s", rB, rS, rN,
      Pick(rG < 0.005, "", Pick(rN > 0, " (BUY zyada)", " (SELL zyada)"))), rBad ? cR : clrYellow);
   if(rG > InpBigLot + 1e-9) hz = "[BARI LOT - MAT] " + hz;
   Ln("HEDGE: " + hz + Pick(rBad, StringFormat("   !! NET %.2f > %.2f: PEHLE HEDGE, PHIR PROFIT CLOSE", rG, InpMaxNet), ""), rBad ? cR : clrYellow);
   gHis = StringFormat("--- HISAAB (sirf likhai, faisla aap ka) ---\nNET abhi %+.2f  (BUY %.2f - SELL %.2f)\nAgar sare profit ticket close: baqi BUY %.2f / SELL %.2f = NET %+.2f\nHedge: %s%s\n",
                       net, bl, sl, rB, rS, rN, hz, Pick(rBad, StringFormat("\n!! NET %.2f hadd %.2f se upar - PEHLE HEDGE, PHIR PROFIT CLOSE", rG, InpMaxNet), ""));
   bool tala = MathAbs(net) < InpBeNet - 1e-9;   // m7.8
   if(tala) Ln(StringFormat("BREAKEVEN: NET %+.2f ~0 -> nuqsan %s TALA-BAND (qeemat se nahi badlega)", net, M(kul)), cY);
   else     Ln(StringFormat("BREAKEVEN PRICE  %s   (now %s)  = yahan sab ka TOTAL 0", be, Px(bid)), cC);
   Ln("STOP OUT  " + door + Pick(othTx == "", "", " *"), cY);
   Ln(Pick(mg > 0, StringFormat("MARGIN LEVEL %s %% (poora account; stop out %s %%)", DoubleToString(mlv, 0), DoubleToString(soLvl, 0)), "MARGIN LEVEL - (margin 0)"), (mg > 0 && mlv < 3 * soLvl) ? cR : cW);
   if(othTx != "")
     {
      string ol[]; int no = StringSplit(othTx, '|', ol);
      for(int k = 0; k < no; k++) if(ol[k] != "") Ln(ol[k], cC);
      Ln("* stop out = doosra symbol na hile to. Asli = MARGIN LEVEL", cW);
     }
   if(bigN > 0) Ln(StringFormat("!! BARI LOT %d tk > %.2f (max %.2f): nuqsan mein mat kaato", bigN, InpBigLot, bigV), cR);
   // PRICE LADDER: qeemat P par kitni lots profit mein + TOTAL (NET se seedha hisaab, swap / spread nahi)
   if(InpLadder && n > 0)
     {
      double lv[6];
      lv[0] = bid - InpStep; lv[1] = bid + InpStep; lv[2] = bid + 2 * InpStep; lv[3] = bid + 4 * InpStep;
      lv[4] = (MathAbs(perD) > 1e-9) ? bid - kul / perD : 0; lv[5] = 0;
      for(int q = 0; q < 5; q++)
        {
         double P = lv[q];
         if(P <= 0 || (q == 4 && tala)) continue;
         int pc = 0;
         for(int i = 0; i < n; i++)
            if((a[i].typ == POSITION_TYPE_BUY && a[i].open < P) || (a[i].typ == POSITION_TYPE_SELL && a[i].open > P)) pc++;
         double tot = kul + perD * (P - bid);
         string tag = Pick(q == 4, "  <- BREAKEVEN", "");
         Ln(StringFormat("LADDER  " + _Symbol + " %s (%+.0f) -> %d ticket profit, TOTAL %s%s", Px(P), P - bid, pc, M(tot), tag), tot >= 0 ? cG : (q == 0 ? cR : cC));
        }
     }
   Ln(StringFormat("TICKETS  %d / %d   (bachao %d)  %s", tk, InpHadd, InpBachao, Pick(full, "TOO MANY - only pair close", "OK")), full ? cR : cW);
   Ln(Pick(aS > 0, StringFormat("%s  #%I64u + #%I64u  = +%s", aNm, aS, aB, M(aV)), "A) Bari lot kam: abhi nahi (nuqsan wali bari lot + nafe ki jori chahiye)"), aS > 0 ? cG : cW);
   Ln(Pick(jS > 0 && !capOver, StringFormat("B) PAIR CLOSE  #%I64u + #%I64u  = +%s", jS, jB, M(jV)), Pick(capOver, StringFormat("B) Pair close: BAND - NET %+.2f hadd se upar, nayi BUY khud band karein", net), "B) Pair close: none now")), (jS > 0 && !capOver) ? cG : (capOver ? cR : cW));
   Ln(Pick(nS > 0, StringFormat("N) NET WAHI JORI  #%I64u + #%I64u  = %s", nS, nB, Sg(nV)), Pick(InpN, StringFormat("N) NET wahi jori: abhi nahi (hadd %s har 0.01 / wasooli)", M(InpNMaxLoss)), "N) NET wahi jori: BAND")), nS > 0 ? cG : cW);
   Ln(Pick(eB > 0, StringFormat("E) BARABAR KAAT  BUY #%I64u + dhaal #%I64u  %.2f lot  = %s", eB, eS, eLot, Sg(eV)), Pick(InpE, StringFormat("E) Barabar kaat: abhi nahi (wasooli kam / dhaal %.2f se kam nahi)", InpShieldMin), "E) Barabar kaat: BAND")), eB > 0 ? cG : cW);
   Ln(Pick(dT > 0, StringFormat("D) BIG SELL PART CLOSE  #%I64u  %.2f lot  = +%s  (NET %+.2f -> %+.2f)", dT, dLot, M(dV), net, net + dLot), Pick(InpPartD, "D) Big SELL part close: none now (SELL loss ya hifazat)", "D) Big SELL part close: BAND (dhaal nahi kaatni)")), dT > 0 ? cG : cW);
   Ln(Pick(cT > 0, StringFormat("C) PROFIT TICKET CLOSE  #%I64u  = +%s", cT, M(cV)), "C) Profit ticket close: " + Pick(full, "OFF (too many tickets)", "none now (big SELL kabhi nahi)")), cT > 0 ? cG : cW);
   // j1 KHUD ke qabil? (nateeja InpAutoMax ke andar; C sirf jab |NET| na barhe)
   bool aAuto = InpAutoJori && (InpAutoMax <= 0 || aV <= InpAutoMax);
   bool jAuto = InpAutoJori && (InpAutoMax <= 0 || jV <= InpAutoMax);
   bool cAuto = InpAutoC && cT > 0 && MathAbs(cN2) <= MathAbs(net) + 1e-9 && (InpAutoMax <= 0 || cV <= InpAutoMax);
   Ln(StringFormat("KHUD (%s): jori A/B %s | profit ticket C %s | hadd %s | N / E / D = popup", S_BUILD, Pick(InpAutoJori, "ON", "popup"), Pick(InpAutoC, "ON (NET na barhe)", "popup"), Pick(InpAutoMax > 0, M(InpAutoMax), "nahi")), cY);
   // j1 3) DEEWAR ka hisaab: NET wali taraf ki sab se NAYI tickets (|NET| lot tak) ki ausat qeemat
   double wLot = 0, wRef = 0, wGone = 0; int wDir = 0;
   double wAn = MathAbs(NormalizeDouble(net, 2));
   string wMd = Pick(InpWall, Pick(InpWallAsk, "ON (popup)", "ON KHUD"), "OFF (sirf hisaab)");
   if(wAn >= InpWallMinNet - 1e-9)
     {
      long wSide = (net > 0) ? POSITION_TYPE_BUY : POSITION_TYPE_SELL;
      double wNeed = wAn, wSv = 0, wSo = 0; string wUsed = "";
      for(int g = 0; g < n && wNeed > 1e-9; g++)
        {
         int wb = -1;
         for(int i = 0; i < n; i++)
           {
            if(a[i].typ != wSide || StringFind(wUsed, StringFormat("|%d|", i)) >= 0) continue;
            if(wb < 0 || a[i].tm > a[wb].tm) wb = i;
           }
         if(wb < 0) break;
         wUsed += StringFormat("|%d|", wb);
         double wx = MathMin(a[wb].vol, wNeed);
         wSv += wx; wSo += wx * a[wb].open; wNeed -= wx;
        }
      if(wSv > 0)
        {
         wRef = wSo / wSv;
         wGone = (net > 0) ? wRef - bid : SymbolInfoDouble(_Symbol, SYMBOL_ASK) - wRef;
         double wStp = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP), wMnv = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
         double wl = MathMin(wAn, InpWallMaxLot);
         if(wStp > 0) wl = MathFloor(wl / wStp + 1e-9) * wStp;
         bool wHit = (wGone >= InpWallDist - 1e-9 && wl >= wMnv - 1e-9 && wMnv > 0);
         if(wHit) { wLot = NormalizeDouble(wl, 2); wDir = (net > 0) ? -1 : 1; }
         Ln(StringFormat("DEEWAR %s: NET %+.2f nayi lots ausat %s | khilaf %s / hadd %s -> %s", wMd, net, Px(wRef), M(wGone), M(InpWallDist),
            Pick(wHit, StringFormat("%s %.2f lot", Pick(net > 0, "SELL", "BUY"), wl), "abhi nahi")), wHit ? cR : cW);
        }
      else Ln(StringFormat("DEEWAR %s: NET %+.2f - hisaab nahi bana", wMd, net), cW);
     }
   else Ln(StringFormat("DEEWAR %s: NET %+.2f chhota (< %.2f) - zaroorat nahi", wMd, net, InpWallMinNet), cW);
   // m8.0 WASOOLI: popup se pakka nafa vs khula nuqsan (sirf hisaab)
   double wz = Wasool();
   Ln(StringFormat("WASOOLI ~+%s | khula %s | bari lot %s", M(wz), M(kul), M(bigP)), wz > 0 ? cG : cW);
   Ln("RASTA: N jori (NET wahi) + E barabar kaat + 0.01 fishing, bari lot NAHI", cY);
   Ln(StringFormat("NET ROK %.2f: %s", InpNetCap, Pick(capOver, "NET hadd se UPAR - B band, nayi BUY mat kholo, khuli nayi BUY khud band karein", Pick(capHit, "NET hadd par - nayi BUY mat kholo, pehle N / E", "theek"))), capHit ? cR : cW);
   Ln(StringFormat("SAFETY: NET max %.2f | +%.2f per step | stop out >= %s", InpMaxNet, InpNetMove, DoubleToString(InpMinDoor, 0)), cY);
   Ln(Pick(wait > 0, StringFormat("Next popup in %d min", wait / 60 + 1), "Popup READY"), cW);
   Ln(Pick(InpLog, "LOG: MQL5\\Files\\JasLarai_" + _Symbol + ".txt", "LOG: band"), cW);   // m8.1
   // ---- m7.3 RUKH + NEWS (sirf dikhana / yaad-dihani - koi trade nahi)
   if(InpRukh)
     {
      int s1, s4; int d1 = Rukh(PERIOD_D1, s1); Rukh(PERIOD_H4, s4);
      int sig = (d1 > 0 && s4 > 0) ? 1 : ((d1 < 0 && s4 < 0) ? -1 : 0);
      string sg = Pick(sig > 0, "fishing BUY: OK", Pick(sig < 0, "nayi BUY NAHI (dono DOWN)", "nayi BUY NAHI - intezar"));
      Ln(StringFormat("RUKH  1D %s | 4H %s  ->  %s", UD(d1), UD(s4), sg), sig > 0 ? cG : (sig < 0 ? cR : cY));
      if(gSigPrev != 99 && sig != gSigPrev && !gPopOn)
        {
         gPNm = "";
         PopShow("RUKH BADLA  -  " + _Symbol, StringFormat("1D %s  |  4H %s\n\n%s\n\nSabaq (tokri sim): fishing BUY sirf jab 1D UP + 4H UP.\nUpar wale mood mein bari SELL nahi, dhaal 0.01 se.",
                 UD(d1), UD(s4), Pick(sig > 0, "Ab fishing BUY ki ijazat.", "Ab nayi fishing BUY mat kholo.")), false);
         if(InpPush) SendNotification(StringFormat("JAS LARAI RUKH: 1D %s 4H %s - %s", UD(d1), UD(s4), sg));
        }
      gSigPrev = sig;
     }
   NewsCheck(net);
   if(InpNews) Ln(gNewsLn, cY);
   for(int k = gRow; k < 50; k++) ObjectDelete(0, "JM_L" + IntegerToString(k));
   // m8.1 LOG snapshot (har InpLogMin, YES ke baad foran)
   if(InpLog && TimeCurrent() - gLogT >= InpLogMin * 60) LogSnap(a, n);
   // ---- H) HEDGE LADDER
   if(big >= 0)
     {
      double hs = InpHStart > 0 ? InpHStart : a[big].open - InpHStep;
      int k = HSteps();
      double nextP = hs - k * InpHStep;
      int left = (int)MathCeil(MathMax(net, 0) / InpHLot - 1e-9);
      string md = Pick(!InpHedge, "OFF (sirf plan)", Pick(InpHAuto, "ON AUTO", "ON YES/NO"));
      Ln(StringFormat("HEDGE LADDER %s | next %s (BUY %.2f band) | %d qadam baqi | NET %+.2f -> 0 @ ~%s",
                      md, Px(nextP), InpHLot, left, net, Px(nextP - (left - 1) * InpHStep)), InpHedge ? cY : cW);
      if(InpHedge && net > 1e-9 && bid <= nextP && AlgoOn())
        {
         bool go = InpHAuto;
         if(!go)
            go = MessageBox(StringFormat("HEDGE LADDER qadam %d\n\n" + _Symbol + " %s <= %s\nBUY %.2f band (pehle SELL %s se neeche wali, phir SELL se upar wali - SELL ke qareeb pehle)\nNET %+.2f -> %+.2f\nNayi lot NAHI. Wapsi par wapas NAHI khulegi.\n\nDo it?",
                                    k + 1, Px(bid), Px(nextP), MathMin(InpHLot, net), Px(a[big].open), net, MathMax(net - InpHLot, 0)),
                            "JAS LARAI " + S_BUILD + " - HEDGE", MB_YESNO | MB_ICONWARNING | MB_DEFBUTTON2) == IDYES;
         if(go)
           {
            double d = HClose(MathMin(InpHLot, net), a[big].open);
            if(d > 0) HSet(k + 1);
            if(InpPush) SendNotification(StringFormat("JAS LARAI HEDGE: " + _Symbol + " %s, BUY %.2f band, NET ~%+.2f", Px(bid), d, net - d));
           }
         else
            HSet(k + 1);   // NO = ye qadam chhor do, agla $%.0f neeche
         return;
        }
     }
   // ---- j1 KHUD: A / B jori aur C ticket (popup ke baghair, har InpAutoSec par ek)
   if(AlgoOn() && TimeCurrent() >= gAutoNext)
     {
      if(aS > 0 && aAuto && (aV >= jV || capOver)) { AutoDo(1, aS, aB, aV, aNm); return; }
      if(jS > 0 && jAuto && !capOver)              { AutoDo(1, jS, jB, jV, "B) PAIR CLOSE"); return; }
      if(cAuto)                                    { AutoDo(2, cT, 0, cV, "C) PROFIT TICKET CLOSE"); return; }
     }
   // ---- j1 W) DEEWAR
   if(AlgoOn() && InpWall && wLot > 0 && TimeCurrent() >= gWallNext)
     {
      if(!InpWallAsk)
        {
         gWallNext = TimeCurrent() + 60;
         bool wok = WallOpen(wDir, wLot);
         string wr = StringFormat("W) DEEWAR %s %.2f: %s  (%d %s)", Pick(wDir < 0, "SELL", "BUY"), wLot, Pick(wok, "DONE", "FAIL"), (int)trade.ResultRetcode(), trade.ResultRetcodeDescription());
         Print("JAS LARAI ", S_BUILD, " KHUD: ", wr);
         LogEv("KHUD -> " + wr + StringFormat("  (NET %+.2f, ausat %s)", net, Px(wRef)));
         gLogT = 0;
         if(InpPush) SendNotification("JAS LARAI " + _Symbol + ": " + wr);
         return;
        }
      if(!gPopOn)
        {
         gWallNext = TimeCurrent() + InpWaitMin * 60;
         gPend = 5; gP1 = 0; gP2 = 0; gPLot = wLot; gWDir = wDir; gPNm = "W) DEEWAR"; gPV = 0; gPVb = 0;
         LogEv(StringFormat("POPUP W) DEEWAR %s %.2f  (NET %+.2f, ausat %s)", Pick(wDir < 0, "SELL", "BUY"), wLot, net, Px(wRef)));
         if(InpPush) SendNotification(StringFormat("JAS LARAI %s: DEEWAR %s %.2f - YES/NO on MT5", _Symbol, Pick(wDir < 0, "SELL", "BUY"), wLot));
         PlaySound("alert.wav");
         PopShow("JAS LARAI " + S_BUILD + "  -  " + _Symbol,
                 StringFormat("Account %I64d\n\nW) DEEWAR\n\nNET %+.2f, nayi lots ki ausat %s\nQeemat %s khilaf gayi (hadd %s)\n\nNAYI %s %.2f lot market par -> NET %+.2f\nNuqsan yahin ruk jayega (tala-band), wapas nahi aayega.\n\nDo it?",
                              AccountInfoInteger(ACCOUNT_LOGIN), net, Px(wRef), M(wGone), M(InpWallDist), Pick(wDir < 0, "SELL", "BUY"), wLot, net + wDir * wLot), true);
         return;
        }
     }
   // ---- POPUP (sirf Algo hara, wait khatam, mauqa ho)
   // m7.2: popup khula ho to naya nahi; der tak jawab na aaye (InpWaitMin) to khud band = NO
   if(gPopOn)
     {
      if(TimeCurrent() - gPopT > InpWaitMin * 60) { if(gPend != 0) { Print("JAS LARAI ", S_BUILD, ": jawab nahi = NO - ", gPNm); LogEv("JAWAB NAHI = NO - " + gPNm); NoMark(); } gPend = 0; PopHide(); }
      return;
     }
   // j1 X) DOHRI LOT popup (15 minute ke intezar se azad)
   if(gDupT > 0 && AlgoOn())
     {
      ulong xT = gDupT; gDupT = 0;
      if(PositionSelectByTicket(xT))
        {
         gPend = 2; gP1 = xT; gP2 = 0; gPLot = 0; gPNm = "X) DOHRI LOT"; gPVb = 0;
         gPV = PositionGetDouble(POSITION_PROFIT) + PositionGetDouble(POSITION_SWAP);
         LogEv(StringFormat("POPUP X) DOHRI LOT  #%I64u  = %s  (NET %+.2f)", xT, Sg(gPV), net));
         PlaySound("alert.wav");
         PopShow("JAS LARAI " + S_BUILD + "  -  " + _Symbol,
                 StringFormat("X) DOHRI LOT\n\n%s\n\nIsi taraf wahi lot %d second ke andar dobara lagi.\nGhalti se lagi?\nYES = sirf YE ticket market par band (abhi %s)\nNO = rehne do", Desc(xT), InpDupSec, Sg(gPV)), true);
         return;
        }
     }
   if(!AlgoOn() || TimeCurrent() < gNext) return;
   int kind = 0; ulong t1 = 0, t2 = 0; double v = 0; string nm = "";
   // m8.4: Close By se equity nahi badalti - B ka "bara nafa" purani SELL ka pehle se bana nafa hai.
   // Asal khatra NET hai: NET hadd par N / E pehle; hadd se upar B band (nayi BUY + purani SELL jori nahi).
   if(capHit && nS > 0) { kind = 1; t1 = nS; t2 = nB; v = nV; nm = "N) NET WAHI JORI"; }
   else if(capHit && eB > 0) { kind = 4; t1 = eB; t2 = eS; v = eV; nm = "E) BARABAR KAAT"; }
   else if(aS > 0 && !aAuto && (aV >= jV || capOver)) { kind = 1; t1 = aS; t2 = aB; v = aV; nm = aNm; }   // m8.2 A/B mein bara pehle
   else if(jS > 0 && !jAuto && !capOver) { kind = 1; t1 = jS; t2 = jB; v = jV; nm = "B) PAIR CLOSE"; }
   else if(nS > 0) { kind = 1; t1 = nS; t2 = nB; v = nV; nm = "N) NET WAHI JORI"; }
   else if(eB > 0) { kind = 4; t1 = eB; t2 = eS; v = eV; nm = "E) BARABAR KAAT"; }
   else if(dT > 0) { kind = 3; t1 = dT; v = dV; nm = "D) BIG SELL PART CLOSE"; }
   else if(cT > 0 && !cAuto) { kind = 2; t1 = cT; v = cV; nm = "C) PROFIT TICKET CLOSE"; }
   if(kind == 0) return;
   gNext = TimeCurrent() + InpWaitMin * 60;
   bool demo = AccountInfoInteger(ACCOUNT_TRADE_MODE) == ACCOUNT_TRADE_MODE_DEMO;
   string d = StringFormat("Account %I64d  (%s)\n\n%s\n\n", AccountInfoInteger(ACCOUNT_LOGIN), Pick(demo, "DEMO", "LIVE - ASLI PAISA"), nm);
   if(kind == 1)
      d += StringFormat("%s\n%s\n\nClose By (no spread, no new lot)\nResult: %s\nWhy: %s\nTickets: %d -> %d or %d\n",
                        Desc(t1), Desc(t2), Sg(v), Pick(v >= InpMinJori, "SELL price above BUY price = profit pair", "NET wahi, nuqsan wali BUY kam (ye nuqsan balance mein pakka)"), tk, tk - 2, tk - 1);
   else if(kind == 4)   // m8.3
      d += StringFormat("%s\n%s\n\nDono se %.2f lot market par band (pehle BUY, phir SELL)\nResult: %s\nNET wahi %+.2f | dhaal baqi %.2f (hadd %.2f)\nWasooli %s -> %s\n",
                        Desc(t1), Desc(t2), eLot, Sg(v), net, a[big].vol - eLot, InpShieldMin, M(wBud), M(wBud + v));
   else if(kind == 3)
      d += StringFormat("%s\n\nPart close %.2f lot at market (baqi %s wahin)\nProfit lock: +%s\nNET %+.2f -> %+.2f (hifazat ke andar)\nNote: equity foran nahi barhti - floating profit balance mein pakka hota hai\n",
                        Desc(t1), dLot, "SELL", M(v), net, net + dLot);
   else
      d += StringFormat("%s\n\nClose at market\nProfit: +%s\nTickets: %d -> %d\nNET change hifazat ke andar\n", Desc(t1), M(v), tk, tk - 1);
   if(InpPush) SendNotification(StringFormat("JAS LARAI %s: %s %s - YES/NO on MT5", _Symbol, nm, Sg(v)));
   gPend = kind; gP1 = t1; gP2 = t2; gPLot = (kind == 4) ? eLot : dLot; gPNm = nm; gPV = v; gPVb = eVb;
   LogEv(StringFormat("POPUP %s  #%I64u + #%I64u  = %s  (NET %+.2f)", nm, t1, t2, Sg(v), net));   // m8.1
   PlaySound("alert.wav");
   PopShow("JAS LARAI " + S_BUILD + "  -  " + _Symbol, d + "\n" + gHis + "\nDo it?", true);
  }

void OnChartEvent(const int id, const long &lp, const double &dp, const string &sp)
  {
   if(id != CHARTEVENT_OBJECT_CLICK) return;
   if(sp == "JM_P_YES")     { ObjectSetInteger(0, sp, OBJPROP_STATE, false); DoPend(); }
   else if(sp == "JM_P_NO")
     {
      Print("JAS LARAI ", S_BUILD, ": NO - ", gPNm);
      LogEv("NO - " + gPNm);   // m8.1
      NoMark();   // m7.3 / m7.9: ye jori / ticket dobara nahi
      gPend = 0; PopHide();
     }
   else if(sp == "JM_P_OK") { PopHide(); }
  }

int OnInit()
  {
   gNext = TimeCurrent() + 60;   // lagate hi popup nahi - 1 min baad
   gAutoNext = TimeCurrent() + 60;   // j1 lagate hi KHUD kaam nahi - 1 min baad
   gWallNext = TimeCurrent() + 60;
   trade.SetExpertMagicNumber(InpMagic);
   trade.SetTypeFillingBySymbol(_Symbol);
   if(InpHReset) HSet(0);
   if(InpWReset) GlobalVariableSet(WKey(), 0);
   EventSetTimer(3);
   Run();
   return(INIT_SUCCEEDED);
  }

void OnDeinit(const int reason) { EventKillTimer(); ObjectsDeleteAll(0, "JM_L"); ObjectsDeleteAll(0, "JM_P"); Comment(""); }
void OnTimer() { Run(); }
void OnTick()  { }
//+------------------------------------------------------------------+
