//+------------------------------------------------------------------+
//|  JAS MAUQA   -   build m7.7  (9 Nov 2026)                         |
//|  m7.7 = (a) MT5 ki "autotrade #" lakeerein khud mitao (InpClean) |
//|         (b) DOOSRE symbol ka NET + account MARGIN LEVEL panel par|
//|             (BTC + gold ek account; stop out = baqi na hilein to)|
//|         (c) ladder / hedge popup par chart ka symbol ("gold" nahi)|
//|         (d) bari lot (> InpBigLot) par sirf WARNING, rokna nahi  |
//|         Koi trade qaida / hadd NAHI badla (user 9 Nov "haan m7.7")|
//|  m7.6 = PROFIT split BUY/SELL + "profit utha lo to NET kya" +    |
//|         hedge kitna (panel + popup). SIRF HISAAB, khud lot nahi. |
//|  m7.5 = NET ka poora hisaab (BUY - SELL = NET, barabar kaise) +  |
//|         POPUP chhota, neeche daayen kone mein (InpPopPos)        |
//|  m7.4 = POPUP chart ke DAAYEN (right) - panel nahi dhakta        |
//|         (InpPopRight true; false = purani jagah baayen). Sirf   |
//|         jagah badli, koi trade qaida nahi badla (user 5 Nov).   |
//|  m7.3 = RUKH: 1D (EMA50/200 + Supertrend) + 4H Supertrend(10,3) |
//|         panel par; fishing BUY sirf 1D UP + 4H UP (tokri sim     |
//|         FILT=1, user 5 Nov); rukh badle to OK popup. NEWS alarm: |
//|         USD bari khabar se 30 + 5 min pehle popup + push, dhaal  |
//|         ka hisaab (NET = kitni 0.01). KHUD KOI LOT NAHI.         |
//|         NO kaha to wahi jori dobara nahi; InpA false = A band.   |
//|  m7.2 = POPUP chart par BARA + BOLD (InpPopFont), mauqa ka naam  |
//|         peela mota, YES/NO bare button; D) default BAND         |
//|         (InpPartD false: bari SELL = dhaal, kaato mat; user 5 Nov)|
//|  m7.1 = H) tarteeb: SELL se neeche wali, phir SELL se UPAR wali      |
//|         (SELL ke qareeb pehle, sab se upar wali nahi)            |
//|  m7 = H) HEDGE LADDER (user 3 Nov, HEDGE naam le kar): bari SELL  |
//|       se har $10 neeche 0.05 BUY BAND (nayi lot nahi), pehle SELL |
//|       se neeche wali BUY, phir sab se upar wali; NET 0 par ruk.   |
//|       InpHedge false default; InpHAuto = sote waqt khud.          |
//|  m6 = HIFAZAT: C mein bari SELL kabhi nahi; C/D sirf jab NET +0.10 |
//|       se zyada na barhe, NET max 0.80, stop out >= 400 $; naya D =  |
//|       bari SELL profit mein ho to 0.10 part close                |
//|  m5 = PRICE LADDER: gold -25/+25/+50/+100/breakeven par kitni   |
//|       ticket profit mein + TOTAL (InpLadder, InpStep)           |
//|  m4 = panel + popup aasan English (ON/OFF, PROFIT/LOSS, PAIR)   |
//|  m3 = bara font panel (InpFont), rang, faide/nuqsan wali ginti   |
//|  m2 = DeskView ka zaroori STATUS + mauqa par KHUD YES/NO popup   |
//|       (Algo hara ho to), 15 min wait, tickets 180/200 bachao.    |
//|  m1 = button wala (InpDikhana) - hataya.                         |
//|                                                                  |
//|  EA. KHUD KOI NAYI LOT NAHI KHOLTA. Sirf chart ke symbol par.    |
//|  STATUS (hamesha): KUL P/L, equity, NET lot, $1 = kitna,         |
//|    stop out door, barabar ka price, BUY/SELL ginti+ausat,        |
//|    tickets (khuli + pending) / 200.                              |
//|  MAUQA (sirf MUSBAT, tarteeb):                                   |
//|    A) BARI SELL KAM : sab se bari SELL + ek BUY, Close By > hadd |
//|    B) JORI          : koi SELL + BUY, Close By > hadd            |
//|    C) FAIDE WALI TICKET band > hadd (tickets 180+ ho to C nahi)  |
//|  Algo ON    -> mauqa mile to popup: detail + YES / NO.           |
//|              YES = sirf wahi ek kaam. NO = kuch nahi.            |
//|              Agla popup kam az kam 15 min baad.                  |
//|  Algo OFF   -> sirf status, popup nahi.                          |
//+------------------------------------------------------------------+
#property copyright "JAS"
#property version   "7.30"

#include <Trade\Trade.mqh>

#define S_BUILD "m7.7"

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
input bool   InpA        = true;   // m7.3 A) BARI SELL KAM popup (false = kabhi nahi; bari SELL = dhaal)
input bool   InpRukh     = true;   // m7.3 RUKH 1D + 4H dikhao, badle to popup
input bool   InpNews     = true;   // m7.3 NEWS alarm (sirf bari / HIGH khabar)
input string InpNewsCur  = "USD";  // NEWS: kis currency ki khabar (gold = USD)
input int    InpNews1    = 30;     // NEWS: pehla alarm kitne minute pehle
input int    InpNews2    = 5;      // NEWS: doosra alarm kitne minute pehle
input bool   InpClean    = true;   // m7.7 MT5 ki "autotrade #..." lakeerein chart se khud mitao
input double InpBigLot   = 0.10;   // m7.7 is se bari lot = laal WARNING (sirf likhai, kuch band nahi)

CTrade trade;

struct PInfo { ulong t; long typ; double vol; double open; double pnl; };

datetime gNext = 0;
// m7.2 chart POPUP (MessageBox ka font nahi badalta - is liye apna dabba)
int      gPend = 0;        // 0 = kuch nahi, 1 = Close By, 2 = close, 3 = part close
ulong    gP1 = 0, gP2 = 0;
double   gPLot = 0;
string   gPNm = "";
bool     gPopOn = false;
datetime gPopT = 0;
string gHis = "";   // m7.6 popup ke liye hisaab
int gRow = 0;

void Ln(string tx, color c)
  {
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
   if(!AlgoOn() || !PositionSelectByTicket(t1) || (kind == 1 && !PositionSelectByTicket(t2)))
     { PopShow("JAS MAUQA " + S_BUILD, "Algo OFF or ticket changed\nnothing done.", false); return; }
   bool ok;
   if(kind == 1) ok = trade.PositionCloseBy(t1, t2);
   else if(kind == 3) ok = trade.PositionClosePartial(t1, gPLot);
   else          ok = trade.PositionClose(t1);
   string r = StringFormat("%s: %s  (%d %s)", nm, Pick(ok, "DONE", "FAIL"), (int)trade.ResultRetcode(), trade.ResultRetcodeDescription());
   Print("JAS MAUQA ", S_BUILD, ": ", r);
   PopShow("JAS MAUQA " + S_BUILD + " - NATEEJA", nm + "\n" + Pick(ok, "DONE", "FAIL") + StringFormat("  (%d %s)", (int)trade.ResultRetcode(), trade.ResultRetcodeDescription()), false);
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
         Print(StringFormat("JAS MAUQA H: BUY #%I64u %.2f @ %s band %s (%d)", best, x, DoubleToString(bo, _Digits), ok ? "OK" : "FAIL", (int)trade.ResultRetcode()));
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
      if(InpPush) SendNotification(StringFormat("JAS MAUQA NEWS: %s %s %d min mein - NET %+.2f", InpNewsCur, ev.name, mins, net));
      PlaySound("alert2.wav");
      if(!gPopOn) { gPNm = ""; PopShow(StringFormat("NEWS ALARM  -  %d min", mins), body, false); }
     }
   if(best == 0) gNewsLn = StringFormat("NEWS: agle 12 ghante %s ki bari khabar nahi", InpNewsCur);
   else          gNewsLn = StringFormat("NEWS: %s  %s  (%d min baad)", bn, TimeToString(best, TIME_MINUTES), (int)((best - now) / 60));
  }

void Run()
  {
   if(InpClean && ObjectsTotal(0, -1, -1) > 0) ObjectsDeleteAll(0, "autotrade");
   PInfo a[];
   int n = Gather(a);
   double vpp = Vpp();
   double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   // ---- STATUS
   double kul = 0, bl = 0, sl = 0, bo = 0, so = 0, bp = 0, sp = 0, fp = 0, lp = 0, fl = 0, ll = 0;
   double fbl = 0, fsl = 0, fbp = 0, fsp = 0;   // m7.6 profit wali BUY / SELL lot + faida
   int bc = 0, sc = 0, big = -1, fc = 0, lc = 0;
   for(int i = 0; i < n; i++)
     {
      kul += a[i].pnl;
      if(a[i].pnl >= 0)
        {
         fc++; fl += a[i].vol; fp += a[i].pnl;
         if(a[i].typ == POSITION_TYPE_BUY) { fbl += a[i].vol; fbp += a[i].pnl; } else { fsl += a[i].vol; fsp += a[i].pnl; }
        }
      else { lc++; ll += a[i].vol; lp += a[i].pnl; }
      if(a[i].typ == POSITION_TYPE_BUY) { bc++; bl += a[i].vol; bo += a[i].vol * a[i].open; bp += a[i].pnl; }
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
   for(int i = 0; i < n; i++) if(a[i].vol > InpBigLot + 1e-9) { bigN++; bigV = MathMax(bigV, a[i].vol); }
   double mlv = AccountInfoDouble(ACCOUNT_MARGIN_LEVEL);
   int tk = PositionsTotal() + OrdersTotal();
   bool full = tk > InpBachao;
   double freeE = eq - mg * soLvl / 100.0;
   // ---- MAUQA
   ulong aS = 0, aB = 0, jS = 0, jB = 0, cT = 0;
   double aV = 0, jV = 0, cV = 0;
   for(int i = 0; i < n; i++)
     {
      if(i != big && a[i].pnl >= InpMinFaida && a[i].pnl > cV)
        {
         double na_ = (a[i].typ == POSITION_TYPE_BUY) ? net - a[i].vol : net + a[i].vol;
         if(Safe(na_, net, freeE, vpp)) { cT = a[i].t; cV = a[i].pnl; }
        }
      if(a[i].typ != POSITION_TYPE_SELL) continue;
      for(int j = 0; j < n; j++)
        {
         if(a[j].typ != POSITION_TYPE_BUY) continue;
         double r = (a[i].open - a[j].open) * MathMin(a[i].vol, a[j].vol) * vpp;
         if(r < InpMinJori) continue;
         if(StringFind(gNoPairs, StringFormat("|%I64u_%I64u|", a[i].t, a[j].t)) >= 0) continue;   // m7.3 NO = dobara nahi
         if(r > jV) { jS = a[i].t; jB = a[j].t; jV = r; }
         if(InpA && i == big && r > aV) { aS = a[i].t; aB = a[j].t; aV = r; }
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
   int wait = (int)(gNext - TimeCurrent());
   // ---- PANEL (bara font, rang)
   color cG = clrLime, cR = clrTomato, cW = clrWhite, cY = clrGold, cC = clrAqua;
   gRow = 0;
   Ln(StringFormat("JAS MAUQA %s  -  %s  -  Algo %s", S_BUILD, _Symbol, Pick(AlgoOn(), "ON (YES/NO popup)", "OFF (only status)")), AlgoOn() ? cG : cY);
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
   Ln(StringFormat("BREAKEVEN PRICE  %s   (now %s)", be, Px(bid)), cC);
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
         if(P <= 0) continue;
         int pc = 0;
         for(int i = 0; i < n; i++)
            if((a[i].typ == POSITION_TYPE_BUY && a[i].open < P) || (a[i].typ == POSITION_TYPE_SELL && a[i].open > P)) pc++;
         double tot = kul + perD * (P - bid);
         string tag = Pick(q == 4, "  <- BREAKEVEN", "");
         Ln(StringFormat("LADDER  " + _Symbol + " %s (%+.0f) -> %d ticket profit, TOTAL %s%s", Px(P), P - bid, pc, M(tot), tag), tot >= 0 ? cG : (q == 0 ? cR : cC));
        }
     }
   Ln(StringFormat("TICKETS  %d / %d   (bachao %d)  %s", tk, InpHadd, InpBachao, Pick(full, "TOO MANY - only pair close", "OK")), full ? cR : cW);
   Ln(Pick(aS > 0, StringFormat("A) BIG SELL REDUCE  #%I64u + #%I64u  = +%s", aS, aB, M(aV)), "A) Big SELL reduce: none now"), aS > 0 ? cG : cW);
   Ln(Pick(jS > 0, StringFormat("B) PAIR CLOSE  #%I64u + #%I64u  = +%s", jS, jB, M(jV)), "B) Pair close: none now"), jS > 0 ? cG : cW);
   Ln(Pick(dT > 0, StringFormat("D) BIG SELL PART CLOSE  #%I64u  %.2f lot  = +%s  (NET %+.2f -> %+.2f)", dT, dLot, M(dV), net, net + dLot), Pick(InpPartD, "D) Big SELL part close: none now (SELL loss ya hifazat)", "D) Big SELL part close: BAND (dhaal nahi kaatni)")), dT > 0 ? cG : cW);
   Ln(Pick(cT > 0, StringFormat("C) PROFIT TICKET CLOSE  #%I64u  = +%s", cT, M(cV)), "C) Profit ticket close: " + Pick(full, "OFF (too many tickets)", "none now (big SELL kabhi nahi)")), cT > 0 ? cG : cW);
   Ln(StringFormat("SAFETY: NET max %.2f | +%.2f per step | stop out >= %s", InpMaxNet, InpNetMove, DoubleToString(InpMinDoor, 0)), cY);
   Ln(Pick(wait > 0, StringFormat("Next popup in %d min", wait / 60 + 1), "Popup READY"), cW);
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
         if(InpPush) SendNotification(StringFormat("JAS MAUQA RUKH: 1D %s 4H %s - %s", UD(d1), UD(s4), sg));
        }
      gSigPrev = sig;
     }
   NewsCheck(net);
   if(InpNews) Ln(gNewsLn, cY);
   for(int k = gRow; k < 45; k++) ObjectDelete(0, "JM_L" + IntegerToString(k));
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
                            "JAS MAUQA " + S_BUILD + " - HEDGE", MB_YESNO | MB_ICONWARNING | MB_DEFBUTTON2) == IDYES;
         if(go)
           {
            double d = HClose(MathMin(InpHLot, net), a[big].open);
            if(d > 0) HSet(k + 1);
            if(InpPush) SendNotification(StringFormat("JAS MAUQA HEDGE: " + _Symbol + " %s, BUY %.2f band, NET ~%+.2f", Px(bid), d, net - d));
           }
         else
            HSet(k + 1);   // NO = ye qadam chhor do, agla $%.0f neeche
         return;
        }
     }
   // ---- POPUP (sirf Algo hara, wait khatam, mauqa ho)
   // m7.2: popup khula ho to naya nahi; der tak jawab na aaye (InpWaitMin) to khud band = NO
   if(gPopOn)
     {
      if(TimeCurrent() - gPopT > InpWaitMin * 60) { if(gPend != 0) Print("JAS MAUQA ", S_BUILD, ": jawab nahi = NO - ", gPNm); gPend = 0; PopHide(); }
      return;
     }
   if(!AlgoOn() || TimeCurrent() < gNext) return;
   int kind = 0; ulong t1 = 0, t2 = 0; double v = 0; string nm = "";
   if(aS > 0)      { kind = 1; t1 = aS; t2 = aB; v = aV; nm = "A) BIG SELL REDUCE"; }
   else if(jS > 0) { kind = 1; t1 = jS; t2 = jB; v = jV; nm = "B) PAIR CLOSE"; }
   else if(dT > 0) { kind = 3; t1 = dT; v = dV; nm = "D) BIG SELL PART CLOSE"; }
   else if(cT > 0) { kind = 2; t1 = cT; v = cV; nm = "C) PROFIT TICKET CLOSE"; }
   if(kind == 0) return;
   gNext = TimeCurrent() + InpWaitMin * 60;
   bool demo = AccountInfoInteger(ACCOUNT_TRADE_MODE) == ACCOUNT_TRADE_MODE_DEMO;
   string d = StringFormat("Account %I64d  (%s)\n\n%s\n\n", AccountInfoInteger(ACCOUNT_LOGIN), Pick(demo, "DEMO", "LIVE - ASLI PAISA"), nm);
   if(kind == 1)
      d += StringFormat("%s\n%s\n\nClose By (no spread, no new lot)\nResult: +%s\nWhy: SELL price above BUY price = profit pair\nTickets: %d -> %d or %d\n",
                        Desc(t1), Desc(t2), M(v), tk, tk - 2, tk - 1);
   else if(kind == 3)
      d += StringFormat("%s\n\nPart close %.2f lot at market (baqi %s wahin)\nProfit lock: +%s\nNET %+.2f -> %+.2f (hifazat ke andar)\nNote: equity foran nahi barhti - floating profit balance mein pakka hota hai\n",
                        Desc(t1), dLot, "SELL", M(v), net, net + dLot);
   else
      d += StringFormat("%s\n\nClose at market\nProfit: +%s\nTickets: %d -> %d\nNET change hifazat ke andar\n", Desc(t1), M(v), tk, tk - 1);
   if(InpPush) SendNotification(StringFormat("JAS MAUQA %s: %s +%s - YES/NO on MT5", _Symbol, nm, M(v)));
   gPend = kind; gP1 = t1; gP2 = t2; gPLot = dLot; gPNm = nm;
   PlaySound("alert.wav");
   PopShow("JAS MAUQA " + S_BUILD + "  -  " + _Symbol, d + "\n" + gHis + "\nDo it?", true);
  }

void OnChartEvent(const int id, const long &lp, const double &dp, const string &sp)
  {
   if(id != CHARTEVENT_OBJECT_CLICK) return;
   if(sp == "JM_P_YES")     { ObjectSetInteger(0, sp, OBJPROP_STATE, false); DoPend(); }
   else if(sp == "JM_P_NO")
     {
      Print("JAS MAUQA ", S_BUILD, ": NO - ", gPNm);
      if(gPend == 1) { if(StringLen(gNoPairs) > 3000) gNoPairs = ""; gNoPairs += StringFormat("|%I64u_%I64u|", gP1, gP2); }   // m7.3: ye jori dobara nahi
      gPend = 0; PopHide();
     }
   else if(sp == "JM_P_OK") { PopHide(); }
  }

int OnInit()
  {
   gNext = TimeCurrent() + 60;   // lagate hi popup nahi - 1 min baad
   if(InpHReset) HSet(0);
   EventSetTimer(3);
   Run();
   return(INIT_SUCCEEDED);
  }

void OnDeinit(const int reason) { EventKillTimer(); ObjectsDeleteAll(0, "JM_L"); ObjectsDeleteAll(0, "JM_P"); Comment(""); }
void OnTimer() { Run(); }
void OnTick()  { }
//+------------------------------------------------------------------+
