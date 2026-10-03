//====================================================================
//===  BUILD k2   <<< PANEL PAR YAHI NUMBER AANA CHAHIYE >>>
//====================================================================
//+------------------------------------------------------------------+
//|  JasChakkarEA.mq5                                                 |
//|                                                                   |
//|  Jami kitab mein ek waqt mein SIRF 0.01 ka chakkar.               |
//|  User ne 2 Oct 2026 ko khud manga; 3 Oct ko BUY + SELL dono.      |
//|                                                                   |
//|  SELL chakkar (gold upar ki shart):                               |
//|    sab se NEECHE wali SELL 0.01 band -> qeemat STEP upar = nayi   |
//|    SELL (jeet) / STEP neeche = nayi SELL (haar). Kitab phir jami. |
//|  BUY chakkar (gold neeche ki shart):                              |
//|    sab se UPAR wali BUY 0.01 band -> qeemat STEP neeche = nayi    |
//|    BUY (jeet) / STEP upar = nayi BUY (haar). Kitab phir jami.     |
//|                                                                   |
//|  k1 ka sabaq (demo, 47 chakkar): chakkar asal mein 0.01 ki        |
//|  rukh wali shart hai. Is liye k2 mein AUTO: H1 rukh upar ho to    |
//|  SELL chakkar, neeche ho to BUY chakkar, saaf rukh na ho to       |
//|  intezar. Ye qaida NAAPA NAHI gaya - demo par har taraf ki alag   |
//|  ginti aur CSV isi liye hai.                                      |
//|                                                                   |
//|  Step: gold par $ (InpStep), baqi (BTC) par ATR x InpStepAtr.     |
//|  Spread step ke InpMaxSpreadPct % se zyada ho to naya chakkar     |
//|  nahi - kharcha qaboo mein.                                       |
//|                                                                   |
//|  Kya NAHI karta: lot nahi barhata, ek se zyada chakkar nahi,      |
//|  kitab jami na ho to shuru nahi, koi SL / TP nahi.                |
//|  Hedge account chahiye.                                           |
//+------------------------------------------------------------------+
#property copyright "JAS-SNIPER-BOT"
#property version   "2.00"

#include <Trade\Trade.mqh>

#define K_BUILD "k2"

enum ChakkarSide
  {
   SIDE_AUTO = 0,   // AUTO - H1 rukh se (upar = SELL, neeche = BUY)
   SIDE_SELL = 1,   // Sirf SELL chakkar
   SIDE_BUY  = 2    // Sirf BUY chakkar
  };

input group "=== 1 - Chakkar ==="
input bool        InpTrade        = true;       // true = asal kaam; false = sirf panel par batao
input ChakkarSide InpSide         = SIDE_AUTO;  // Kis taraf ka chakkar
input double      InpLot          = 0.01;       // Chakkar ki lot (sirf isi size ki lot band hogi)
input double      InpMinProfit    = -9999.0;    // Lot kam az kam itne faide mein ho tab band (-9999 = koi bhi)
input int         InpPauseSec     = 60;         // Do chakkar ke darmiyan kitne second

input group "=== 2 - Step (kitna chale, phir nayi lot) ==="
input double          InpStep        = 5.0;         // GOLD: kitne DOLLAR
input double          InpStepAtr     = 1.0;         // BAQI (BTC): ATR ka kitna guna
input ENUM_TIMEFRAMES InpAtrTF       = PERIOD_M15;  // ATR kis timeframe ka
input double          InpMaxSpreadPct = 15.0;       // Spread step ke kitne % se zyada ho to naya chakkar nahi

input group "=== 3 - Rukh (sirf AUTO mein) ==="
input ENUM_TIMEFRAMES InpTrendTF   = PERIOD_H1;  // Rukh kis timeframe se
input int             InpTrendEMA  = 50;         // EMA kitni
input int             InpSlopeBars = 3;          // EMA ka jhukaav kitni candles par

input group "=== 4 - Hadd (EA ko rokti hain) ==="
input int    InpMaxLossRow = 5;       // Lagatar itne chakkar haare to ruk jao
input double InpStopSum    = -50.0;   // Chakkar ka kul nateeja is se neeche jaye to ruk jao
input bool   InpResetStats = false;   // true = purani ginti saaf kar ke shuru (phir false kar dein)

input group "=== 5 - News (L10) ==="
input bool   InpUseNews      = true;  // Bari news ke waqt naya chakkar nahi
input int    InpNewsBefore   = 30;    // News se kitne minute pehle
input int    InpNewsAfter    = 60;    // News ke kitne minute baad tak
input string InpNewsCurrency = "USD"; // Kis mulk ki news (khali = sab)

input group "=== 6 - Jumma (sirf jo market weekend band hoti hai) ==="
input int    InpFriNoStart = 19;      // Jumma ko is ghante (server waqt) se naya chakkar nahi
input int    InpFriFlat    = 20;      // Jumma ko is ghante se chakkar khula ho to lot khol kar kitab jami

input group "=== 7 - Baqi ==="
input long   InpMagic      = 260210;  // EA ki khud kholi hui lot ka nishan
input bool   InpLines      = true;    // Chart par upar/neeche ki lakeerein
input bool   InpCsv        = true;    // Har chakkar MQL5\Files\JasChakkar_<symbol>.csv mein

CTrade   trade;
int      hEma = INVALID_HANDLE, hAtr = INVALID_HANDLE;

//--- haal (GlobalVariables mein mehfooz)
int      g_phase   = 0;      // 0 = tayyar, 1 = lot band, intezar
int      g_side    = 0;      // 1 = SELL chakkar, 2 = BUY chakkar
double   g_ref     = 0.0;    // jis price par lot band hui
double   g_step    = 0.0;    // is chakkar ka step (shuru mein jama)
double   g_closedOpen = 0.0;
datetime g_startAt = 0;
string   g_trendAt = "";
int      g_lossRow = 0;
double   g_sum     = 0.0;
double   g_banked  = 0.0;
int      g_wS = 0, g_lS = 0, g_wB = 0, g_lB = 0;
double   g_sS = 0.0, g_sB = 0.0;

datetime g_lastAct = 0;
datetime g_lastTry = 0;
string   g_msg     = "Shuru";
string   g_last    = "";
int      g_trend   = 0;      // +1 upar, -1 neeche, 0 saaf nahi
bool     g_247     = false;

bool     g_newsBlock = false, g_newsOK = false;
datetime g_newsAt = 0, g_newsLast = 0;
string   g_newsName = "";

string Pick(bool c, string a, string b) { if(c) return(a); return(b); }
string M(double v)  { return(DoubleToString(v, 2)); }
string Px(double v) { return(DoubleToString(v, (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS))); }
string SideName(int s) { if(s == 1) return("SELL"); if(s == 2) return("BUY"); return("-"); }
string TrendName(int t) { if(t > 0) return("UPAR"); if(t < 0) return("NEECHE"); return("SAAF NAHI"); }

string Key(string name)
  {
   return("JCK_" + IntegerToString(AccountInfoInteger(ACCOUNT_LOGIN)) + "_" + _Symbol + "_" + name);
  }
double GV(string name, double def)
  {
   string k = Key(name);
   if(GlobalVariableCheck(k)) return(GlobalVariableGet(k));
   return(def);
  }

void Save()
  {
   GlobalVariableSet(Key("phase"),  g_phase);
   GlobalVariableSet(Key("side"),   g_side);
   GlobalVariableSet(Key("ref"),    g_ref);
   GlobalVariableSet(Key("step"),   g_step);
   GlobalVariableSet(Key("open"),   g_closedOpen);
   GlobalVariableSet(Key("start"),  (double)g_startAt);
   GlobalVariableSet(Key("row"),    g_lossRow);
   GlobalVariableSet(Key("sum"),    g_sum);
   GlobalVariableSet(Key("banked"), g_banked);
   GlobalVariableSet(Key("wS"), g_wS); GlobalVariableSet(Key("lS"), g_lS); GlobalVariableSet(Key("sS"), g_sS);
   GlobalVariableSet(Key("wB"), g_wB); GlobalVariableSet(Key("lB"), g_lB); GlobalVariableSet(Key("sB"), g_sB);
  }

void Load()
  {
   g_phase      = (int)GV("phase", 0);
   g_side       = (int)GV("side", 1);   // k1 se aaye to SELL
   g_ref        = GV("ref", 0.0);
   g_step       = GV("step", 0.0);
   g_closedOpen = GV("open", 0.0);
   g_startAt    = (datetime)GV("start", 0.0);
   g_lossRow    = (int)GV("row", 0);
   g_sum        = GV("sum", 0.0);
   g_banked     = GV("banked", 0.0);
   g_wS = (int)GV("wS", 0); g_lS = (int)GV("lS", 0); g_sS = GV("sS", 0.0);
   g_wB = (int)GV("wB", 0); g_lB = (int)GV("lB", 0); g_sB = GV("sB", 0.0);
   // k1 ki ginti (sirf SELL thi) SELL ke khaane mein
   if(g_wS == 0 && g_lS == 0 && GlobalVariableCheck(Key("wins")))
     {
      g_wS = (int)GV("wins", 0); g_lS = (int)GV("losses", 0); g_sS = g_sum;
     }
   if(g_phase == 1 && g_step <= 0.0) g_step = InpStep;   // k1 ka khula chakkar
  }

void ResetStats()
  {
   string names[] = {"wins", "losses", "row", "sum", "banked", "wS", "lS", "sS", "wB", "lB", "sB"};
   for(int i = 0; i < ArraySize(names); i++) GlobalVariableDel(Key(names[i]));
  }

bool IsGold()
  {
   return(StringFind(_Symbol, "XAU") >= 0 || StringFind(_Symbol, "GOLD") >= 0);
  }

//--- symbol hafte ke din bhi chalta hai? (BTC) -> Jumma ka qaida nahi
bool Is247()
  {
   datetime f, t;
   return(SymbolInfoSessionTrade(_Symbol, SATURDAY, 0, f, t) && t > f);
  }

//--- $1 ki harkat par InpLot ka paisa
double MoneyPerDollar()
  {
   double p = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   double r = 0.0;
   if(p > 0.0 && OrderCalcProfit(ORDER_TYPE_BUY, _Symbol, InpLot, p, p + 1.0, r)) return(r);
   double tv = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);
   double ts = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);
   if(ts > 0.0) return(tv / ts * InpLot);
   return(0.0);
  }

//--- step abhi kitna (gold: fixed $, baqi: ATR)
double StepNow()
  {
   if(IsGold()) return(InpStep);
   double a[1];
   if(hAtr == INVALID_HANDLE || CopyBuffer(hAtr, 0, 1, 1, a) < 1) return(0.0);
   return(a[0] * InpStepAtr);
  }

//--- H1 rukh: band candle EMA ke upar aur EMA upar ja rahi = +1
int TrendNow()
  {
   if(hEma == INVALID_HANDLE) return(0);
   double e[];
   ArraySetAsSeries(e, true);
   if(CopyBuffer(hEma, 0, 1, InpSlopeBars + 1, e) < InpSlopeBars + 1) return(0);
   double c = iClose(_Symbol, InpTrendTF, 1);
   if(c <= 0.0) return(0);
   if(c > e[0] && e[0] > e[InpSlopeBars]) return(1);
   if(c < e[0] && e[0] < e[InpSlopeBars]) return(-1);
   return(0);
  }

void Book(double &buy, double &sell, int &nb, int &ns)
  {
   buy = 0.0; sell = 0.0; nb = 0; ns = 0;
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      ulong t = PositionGetTicket(i);
      if(t == 0) continue;
      if(PositionGetString(POSITION_SYMBOL) != _Symbol) continue;
      double v = PositionGetDouble(POSITION_VOLUME);
      if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY) { buy += v; nb++; }
      else                                                       { sell += v; ns++; }
     }
  }

//--- SELL chakkar: sab se NEECHE wali SELL. BUY chakkar: sab se UPAR wali BUY.
ulong PickPos(int side, double &openPx, double &pl)
  {
   ulong best = 0; openPx = 0.0; pl = 0.0;
   long want = (side == 1) ? POSITION_TYPE_SELL : POSITION_TYPE_BUY;
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      ulong t = PositionGetTicket(i);
      if(t == 0) continue;
      if(PositionGetString(POSITION_SYMBOL) != _Symbol) continue;
      if(PositionGetInteger(POSITION_TYPE) != want) continue;
      if(MathAbs(PositionGetDouble(POSITION_VOLUME) - InpLot) > 1e-8) continue;
      double p  = PositionGetDouble(POSITION_PRICE_OPEN);
      double pr = PositionGetDouble(POSITION_PROFIT) + PositionGetDouble(POSITION_SWAP);
      if(pr < InpMinProfit) continue;
      bool better = (side == 1) ? (p < openPx) : (p > openPx);
      if(best == 0 || better) { best = t; openPx = p; pl = pr; }
     }
   return(best);
  }

//+------------------------------------------------------------------+
//|  L10 - bari news ke waqt naya chakkar nahi                        |
//+------------------------------------------------------------------+
void RefreshNews()
  {
   datetime now = TimeCurrent();
   if(now - g_newsLast < 60) return;
   g_newsLast  = now;
   g_newsBlock = false;
   g_newsOK    = false;
   g_newsAt    = 0;
   g_newsName  = "";
   if(!InpUseNews) return;

   MqlCalendarValue v[];
   int n = CalendarValueHistory(v, now - 6 * 3600, now + 12 * 3600, NULL, InpNewsCurrency);
   if(n <= 0)
     {
      n = CalendarValueHistory(v, now - 6 * 3600, now + 12 * 3600);
      if(n <= 0) return;
     }
   g_newsOK = true;

   datetime bestAt = 0; string bestName = "";
   for(int i = 0; i < n; i++)
     {
      MqlCalendarEvent e;
      if(!CalendarEventById(v[i].event_id, e))     continue;
      if(e.importance != CALENDAR_IMPORTANCE_HIGH) continue;
      datetime at   = v[i].time;
      datetime from = at - (datetime)(InpNewsBefore * 60);
      datetime to   = at + (datetime)(InpNewsAfter  * 60);
      if(now >= from && now <= to)
        {
         g_newsBlock = true;
         g_newsAt    = at;
         g_newsName  = e.name;
         return;
        }
      if(at > now && (bestAt == 0 || at < bestAt)) { bestAt = at; bestName = e.name; }
     }
   g_newsAt   = bestAt;
   g_newsName = bestName;
  }

bool FridayAfter(int hour)
  {
   if(g_247) return(false);
   MqlDateTime t; TimeToStruct(TimeCurrent(), t);
   return(t.day_of_week == 5 && t.hour >= hour);
  }

//+------------------------------------------------------------------+
//|  CSV - har poora chakkar ek line                                  |
//+------------------------------------------------------------------+
void CsvWrite(double px, double res, string why)
  {
   if(!InpCsv) return;
   string fn = "JasChakkar_" + _Symbol + ".csv";
   int h = FileOpen(fn, FILE_READ | FILE_WRITE | FILE_CSV | FILE_ANSI | FILE_SHARE_READ, ',');
   if(h == INVALID_HANDLE) { Print("JAS CHAKKAR: CSV nahi khuli ", GetLastError()); return; }
   if(FileSize(h) == 0)
      FileWrite(h, "build", "start", "end", "minutes", "side", "trend", "closed_open",
                "ref", "step", "reopen", "result", "why");
   FileSeek(h, 0, SEEK_END);
   int mins = (g_startAt > 0) ? (int)((TimeCurrent() - g_startAt) / 60) : 0;
   FileWrite(h, K_BUILD,
             TimeToString(g_startAt, TIME_DATE | TIME_SECONDS),
             TimeToString(TimeCurrent(), TIME_DATE | TIME_SECONDS),
             mins, SideName(g_side), g_trendAt, Px(g_closedOpen),
             Px(g_ref), Px(g_step), Px(px), M(res), why);
   FileClose(h);
  }

//+------------------------------------------------------------------+
//|  Lakeerein                                                        |
//+------------------------------------------------------------------+
void HLine(string name, double price, color c, ENUM_LINE_STYLE st, string tip)
  {
   if(ObjectFind(0, name) < 0) ObjectCreate(0, name, OBJ_HLINE, 0, 0, price);
   ObjectSetDouble(0, name, OBJPROP_PRICE, price);
   ObjectSetInteger(0, name, OBJPROP_COLOR, c);
   ObjectSetInteger(0, name, OBJPROP_STYLE, st);
   ObjectSetInteger(0, name, OBJPROP_WIDTH, 1);
   ObjectSetInteger(0, name, OBJPROP_BACK, true);
   ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
   ObjectSetString(0, name, OBJPROP_TOOLTIP, tip);
  }

void DrawLines()
  {
   if(!InpLines || g_phase != 1)
     {
      ObjectDelete(0, "JCK_up"); ObjectDelete(0, "JCK_dn"); ObjectDelete(0, "JCK_ref");
      return;
     }
   bool sell = (g_side == 1);
   HLine("JCK_up",  g_ref + g_step, sell ? clrLimeGreen : clrTomato, STYLE_DASH,
         Pick(sell, "Yahan nayi SELL = JEET", "Yahan nayi BUY = HAAR"));
   HLine("JCK_ref", g_ref, clrSilver, STYLE_DOT, "Yahan lot band hui thi");
   HLine("JCK_dn",  g_ref - g_step, sell ? clrTomato : clrLimeGreen, STYLE_DASH,
         Pick(sell, "Yahan nayi SELL = HAAR", "Yahan nayi BUY = JEET"));
  }

//+------------------------------------------------------------------+
//|  Chakkar ka doosra hissa: nayi lot khol kar kitab phir jami       |
//+------------------------------------------------------------------+
void Reopen(string why)
  {
   if(TimeCurrent() - g_lastTry < 10) return;
   g_lastTry = TimeCurrent();

   bool sell = (g_side == 1);
   bool ok   = sell ? trade.Sell(InpLot, _Symbol, 0.0, 0.0, 0.0, "JasChakkar " + K_BUILD)
                    : trade.Buy (InpLot, _Symbol, 0.0, 0.0, 0.0, "JasChakkar " + K_BUILD);
   uint rc = trade.ResultRetcode();
   if(!ok || (rc != TRADE_RETCODE_DONE && rc != TRADE_RETCODE_PLACED))
     {
      g_msg = "Nayi " + SideName(g_side) + " nahi khuli: " + IntegerToString((int)rc) + " "
              + trade.ResultRetcodeDescription() + " - 10 second baad phir";
      Print("JAS CHAKKAR: ", g_msg);
      return;
     }

   double px = trade.ResultPrice();
   if(px <= 0.0) px = SymbolInfoDouble(_Symbol, sell ? SYMBOL_BID : SYMBOL_ASK);
   double res = 0.0;
   // SELL: px par nayi SELL, ref par band hui thi -> (px - ref). BUY: (ref - px).
   bool calc = sell ? OrderCalcProfit(ORDER_TYPE_SELL, _Symbol, InpLot, px, g_ref, res)
                    : OrderCalcProfit(ORDER_TYPE_BUY,  _Symbol, InpLot, px, g_ref, res);
   if(!calc) res = (sell ? (px - g_ref) : (g_ref - px)) * MoneyPerDollar();

   g_sum += res;
   bool win = (res >= 0.0);
   if(win) g_lossRow = 0; else g_lossRow++;
   if(sell) { if(win) g_wS++; else g_lS++; g_sS += res; }
   else     { if(win) g_wB++; else g_lB++; g_sB += res; }

   g_last = StringFormat("%s %s: band %s, nayi %s -> %s%s",
                         SideName(g_side), why, Px(g_ref), Px(px), Pick(win, "+", ""), M(res));
   Print("JAS CHAKKAR: ", g_last);
   CsvWrite(px, res, why);

   g_phase   = 0;
   g_ref     = 0.0;
   g_lastAct = TimeCurrent();
   g_msg     = "Kitab phir jami. Agla chakkar thori der mein.";
   Save();
  }

//+------------------------------------------------------------------+
//|  Chakkar ka pehla hissa: ek lot band                              |
//+------------------------------------------------------------------+
void TryStart(double net, double spread, double stepNow)
  {
   if(g_lossRow >= InpMaxLossRow)
     { g_msg = StringFormat("RUKA: lagatar %d haar. InpResetStats = true kar ke dobara lagayein.", g_lossRow); return; }
   if(g_sum <= InpStopSum)
     { g_msg = StringFormat("RUKA: kul nateeja %s, hadd %s. InpResetStats = true kar ke dobara lagayein.", M(g_sum), M(InpStopSum)); return; }
   if(MathAbs(net) > 1e-6)
     { g_msg = StringFormat("Intezar: kitab jami nahi (NET %+.2f). Jami ho to chakkar shuru.", net); return; }
   if(g_newsBlock)
     { g_msg = "Intezar: bari news - " + g_newsName; return; }
   if(FridayAfter(InpFriNoStart))
     { g_msg = "Intezar: Jumma, market band hone wali hai"; return; }
   if(stepNow <= 0.0)
     { g_msg = "Intezar: ATR abhi nahi mila"; return; }
   if(spread > stepNow * InpMaxSpreadPct / 100.0)
     { g_msg = StringFormat("Intezar: spread %s, step ka %.0f%% se zyada", Px(spread), InpMaxSpreadPct); return; }
   if(TimeCurrent() - g_lastAct < InpPauseSec)
     { g_msg = StringFormat("Thehrao: %d second", (int)(InpPauseSec - (TimeCurrent() - g_lastAct))); return; }

   int side = 0;
   if(InpSide == SIDE_SELL)      side = 1;
   else if(InpSide == SIDE_BUY)  side = 2;
   else if(g_trend > 0)          side = 1;
   else if(g_trend < 0)          side = 2;
   if(side == 0)
     { g_msg = "Intezar: H1 rukh saaf nahi (AUTO)"; return; }

   double op, pl;
   ulong tk = PickPos(side, op, pl);
   if(tk == 0)
     { g_msg = StringFormat("Intezar: koi %.2f %s nahi mili (shart %s)", InpLot, SideName(side), M(InpMinProfit)); return; }

   if(!InpTrade)
     { g_msg = StringFormat("SIRF DIKHANA: abhi #%I64u %s @ %s (%s) band hoti", tk, SideName(side), Px(op), M(pl)); return; }
   if(!TerminalInfoInteger(TERMINAL_TRADE_ALLOWED) || !MQLInfoInteger(MQL_TRADE_ALLOWED))
     { g_msg = "Algo Trading band hai - toolbar ka button HARA karein"; return; }
   if(TimeCurrent() - g_lastTry < 10) return;
   g_lastTry = TimeCurrent();

   bool ok = trade.PositionClose(tk);
   uint rc = trade.ResultRetcode();
   if(!ok || (rc != TRADE_RETCODE_DONE && rc != TRADE_RETCODE_PLACED))
     {
      g_msg = SideName(side) + " band nahi hui: " + IntegerToString((int)rc) + " " + trade.ResultRetcodeDescription();
      Print("JAS CHAKKAR: ", g_msg);
      return;
     }

   double px = trade.ResultPrice();
   if(px <= 0.0) px = SymbolInfoDouble(_Symbol, side == 1 ? SYMBOL_ASK : SYMBOL_BID);
   g_side       = side;
   g_ref        = px;
   g_step       = stepNow;
   g_closedOpen = op;
   g_banked    += pl;
   g_startAt    = TimeCurrent();
   g_trendAt    = TrendName(g_trend);
   g_phase      = 1;
   g_lastAct    = TimeCurrent();
   g_msg        = SideName(side) + " band. Ab intezar: upar ya neeche.";
   PrintFormat("JAS CHAKKAR: #%I64u %s @ %s band @ %s (%s). Step %s, rukh %s",
               tk, SideName(side), Px(op), Px(px), M(pl), Px(g_step), g_trendAt);
   Save();
  }

//+------------------------------------------------------------------+
//|  Panel                                                            |
//+------------------------------------------------------------------+
void Panel(double buy, double sell, int nb, int ns, double bid, double ask, double spread, double stepNow)
  {
   double per = MoneyPerDollar();
   string cur = AccountInfoString(ACCOUNT_CURRENCY);
   string side = "AUTO (H1 rukh)";
   if(InpSide == SIDE_SELL) side = "sirf SELL";
   if(InpSide == SIDE_BUY)  side = "sirf BUY";
   string s = "";
   s += "=== JAS CHAKKAR  " + K_BUILD + " ===   " + _Symbol + "  (" + cur + ")"
        + Pick(g_247, "  [24/7]", "") + "\n";
   s += Pick(InpTrade, "ASAL KAAM chalu", "SIRF DIKHANA - koi trade nahi") + "  |  " + side + "\n";
   s += StringFormat("Step abhi %s (= %s %s)  |  lot %.2f\n", Px(stepNow), M(stepNow * per), cur, InpLot);
   s += "Rukh " + EnumToString(InpTrendTF) + ": " + TrendName(g_trend) + "\n";
   s += "\n";
   s += StringFormat("Kitab: BUY %d (%.2f)  SELL %d (%.2f)  NET %+.2f\n", nb, buy, ns, sell, buy - sell);
   s += StringFormat("Qeemat %s   spread %s\n", Px(bid), Px(spread));
   s += "\n";
   if(g_phase == 1)
     {
      bool sl = (g_side == 1);
      double now = 0.0;
      if(sl) { if(!OrderCalcProfit(ORDER_TYPE_SELL, _Symbol, InpLot, bid, g_ref, now)) now = (bid - g_ref) * per; }
      else   { if(!OrderCalcProfit(ORDER_TYPE_BUY,  _Symbol, InpLot, ask, g_ref, now)) now = (g_ref - ask) * per; }
      s += "HAAL: " + SideName(g_side) + " BAND - intezar (rukh tha " + g_trendAt + ")\n";
      s += StringFormat("  Band hui: khuli %s, band %s, step %s\n", Px(g_closedOpen), Px(g_ref), Px(g_step));
      s += StringFormat("  UPAR   %s  -> nayi %s (%s)\n", Px(g_ref + g_step), SideName(g_side), Pick(sl, "jeet", "haar"));
      s += StringFormat("  NEECHE %s  -> nayi %s (%s)\n", Px(g_ref - g_step), SideName(g_side), Pick(sl, "haar", "jeet"));
      s += StringFormat("  Abhi khulti to: %s%s\n", Pick(now >= 0.0, "+", ""), M(now));
     }
   else
      s += "HAAL: TAYYAR\n";
   s += "  " + g_msg + "\n";
   s += "\n";
   s += StringFormat("SELL chakkar: jeet %d  haar %d  kul %s\n", g_wS, g_lS, M(g_sS));
   s += StringFormat("BUY  chakkar: jeet %d  haar %d  kul %s\n", g_wB, g_lB, M(g_sB));
   int n = g_wS + g_lS + g_wB + g_lB;
   s += StringFormat("KUL: %s%s %s  |  fi chakkar %s  |  lagatar haar %d/%d  (ruk jayega %s)\n",
                     Pick(g_sum >= 0.0, "+", ""), M(g_sum), cur,
                     M(n > 0 ? g_sum / n : 0.0), g_lossRow, InpMaxLossRow, M(InpStopSum));
   s += StringFormat("Band lots ka P/L (balance mein): %s\n", M(g_banked));
   if(g_last != "") s += "Aakhri: " + g_last + "\n";
   s += "\n";
   if(!InpUseNews)        s += "News: band (input)\n";
   else if(!g_newsOK)     s += "News: calendar nahi mila - news ka khud khayal rakhein\n";
   else if(g_newsBlock)   s += "News: ABHI ROK - " + g_newsName + "\n";
   else if(g_newsAt > 0)  s += "News: agli bari " + TimeToString(g_newsAt, TIME_DATE | TIME_MINUTES) + " " + g_newsName + "\n";
   else                   s += "News: agle 12 ghante mein koi bari nahi\n";
   Comment(s);
  }

//+------------------------------------------------------------------+
void Work()
  {
   RefreshNews();
   g_trend = TrendNow();

   double buy, sell; int nb, ns;
   Book(buy, sell, nb, ns);
   double net     = buy - sell;
   double bid     = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   double ask     = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   double spread  = ask - bid;
   double stepNow = StepNow();

   if(AccountInfoInteger(ACCOUNT_MARGIN_MODE) != ACCOUNT_MARGIN_MODE_RETAIL_HEDGING)
      g_msg = "Ye account HEDGE nahi - EA kuch nahi karega";
   else if(bid > 0.0)
     {
      if(g_phase == 1)
        {
         bool   sl   = (g_side == 1);
         double want = sl ? InpLot : -InpLot;   // SELL band = BUY ki taraf jhuki
         if(MathAbs(net) < 1e-6)
           {
            g_phase = 0; g_ref = 0.0; g_lastAct = TimeCurrent();
            g_msg   = "Kitab haath se jami ho gayi - chakkar khatam (gina nahi)";
            Print("JAS CHAKKAR: ", g_msg);
            Save();
           }
         else if(sl  && bid >= g_ref + g_step) Reopen("JEET");
         else if(sl  && bid <= g_ref - g_step) Reopen("HAAR");
         else if(!sl && ask <= g_ref - g_step) Reopen("JEET");
         else if(!sl && ask >= g_ref + g_step) Reopen("HAAR");
         else if(FridayAfter(InpFriFlat))      Reopen("JUMMA");
         else if(MathAbs(net - want) > 1e-6)
            g_msg = StringFormat("Dhyan: NET %+.2f hai, %+.2f hona chahiye tha (haath se lot?)", net, want);
         else
            g_msg = SideName(g_side) + " band. Intezar: upar ya neeche.";
        }
      else
         TryStart(net, spread, stepNow);
     }

   DrawLines();
   Panel(buy, sell, nb, ns, bid, ask, spread, stepNow);
  }

//+------------------------------------------------------------------+
int OnInit()
  {
   trade.SetExpertMagicNumber(InpMagic);
   trade.SetDeviationInPoints(50);
   trade.SetTypeFillingBySymbol(_Symbol);

   if(InpLot <= 0.0 || InpStep <= 0.0 || InpStepAtr <= 0.0 || InpSlopeBars < 1)
     {
      Alert("JAS CHAKKAR: Lot, Step, StepAtr aur SlopeBars 0 se bare hon");
      return(INIT_PARAMETERS_INCORRECT);
     }
   hEma = iMA(_Symbol, InpTrendTF, InpTrendEMA, 0, MODE_EMA, PRICE_CLOSE);
   hAtr = iATR(_Symbol, InpAtrTF, 14);
   if(hEma == INVALID_HANDLE || hAtr == INVALID_HANDLE)
     {
      Alert("JAS CHAKKAR: EMA/ATR nahi bana");
      return(INIT_FAILED);
     }

   if(InpResetStats) ResetStats();
   Load();
   g_247 = Is247();
   PrintFormat("JAS CHAKKAR %s shuru | %s | haal %d | %s | ref %s | 24/7 %s",
               K_BUILD, _Symbol, g_phase, SideName(g_side), Px(g_ref), Pick(g_247, "haan", "nahi"));
   EventSetTimer(1);
   Work();
   return(INIT_SUCCEEDED);
  }

void OnDeinit(const int reason)
  {
   EventKillTimer();
   if(hEma != INVALID_HANDLE) IndicatorRelease(hEma);
   if(hAtr != INVALID_HANDLE) IndicatorRelease(hAtr);
   ObjectDelete(0, "JCK_up"); ObjectDelete(0, "JCK_dn"); ObjectDelete(0, "JCK_ref");
   Comment("");
  }

void OnTick()  { Work(); }
void OnTimer() { Work(); }
//+------------------------------------------------------------------+
