//====================================================================
//===  BUILD k1   <<< PANEL PAR YAHI NUMBER AANA CHAHIYE >>>
//====================================================================
//+------------------------------------------------------------------+
//|  JasChakkarEA.mq5                                                 |
//|                                                                   |
//|  SELL ko upar le jane ka chakkar - ek waqt mein sirf 0.01.        |
//|  User ne 2 Oct 2026 ko khud manga aur manzoor kiya.               |
//|                                                                   |
//|  Ek chakkar:                                                      |
//|   1. Kitab jami ho (NET 0) to ek FAIDE WALI SELL 0.01 band        |
//|      (sab se neeche wali, taake SELL ka ausat upar jaye).         |
//|   2. Intezar. Kitab sirf 0.01 BUY ki taraf jhuki hai.             |
//|   3. Gold $5 UPAR  -> nayi SELL 0.01  = +5  (jeet)                |
//|      Gold $5 NEECHE -> nayi SELL 0.01 = -5  (haar)                |
//|      Dono soorat mein kitab phir jami.                            |
//|                                                                   |
//|  Kya NAHI karta:                                                  |
//|    - BUY ko kabhi haath nahi lagata                               |
//|    - 0.01 ke ilawa kisi SELL ko band nahi karta (0.05 waghera nahi)|
//|    - ek waqt mein ek se zyada chakkar nahi                        |
//|    - kitab jami na ho to shuru nahi karta                         |
//|    - koi SL / TP nahi                                             |
//|  Hedge account chahiye.                                           |
//+------------------------------------------------------------------+
#property copyright "JAS-SNIPER-BOT"
#property version   "1.00"

#include <Trade\Trade.mqh>

#define K_BUILD "k1"

input group "=== 1 - Chakkar ==="
input bool   InpTrade      = true;    // true = asal kaam; false = sirf panel par batao
input double InpLot        = 0.01;    // Chakkar ki lot (sirf isi size ki SELL band hogi)
input double InpStep       = 5.0;     // Gold kitne DOLLAR upar/neeche jaye, phir nayi SELL
input double InpMinProfit  = 1.0;     // SELL kam az kam itne faide mein ho tab band (account ki currency)
input int    InpPauseSec   = 60;      // Do chakkar ke darmiyan kitne second
input double InpMaxSpread  = 0.50;    // Spread (dollar) is se zyada ho to naya chakkar nahi

input group "=== 2 - Hadd (EA ko rokti hain) ==="
input int    InpMaxLossRow = 5;       // Lagatar itne chakkar haare to ruk jao
input double InpStopSum    = -50.0;   // Chakkar ka kul nateeja is se neeche jaye to ruk jao
input bool   InpResetStats = false;   // true = purani ginti (jeet/haar/kul) saaf kar ke shuru

input group "=== 3 - News (L10) ==="
input bool   InpUseNews      = true;  // Bari news ke waqt naya chakkar nahi
input int    InpNewsBefore   = 30;    // News se kitne minute pehle
input int    InpNewsAfter    = 60;    // News ke kitne minute baad tak
input string InpNewsCurrency = "USD"; // Kis mulk ki news (khali = sab)

input group "=== 4 - Jumma (market band hone se pehle) ==="
input int    InpFriNoStart = 19;      // Jumma ko is ghante (server waqt) se naya chakkar nahi
input int    InpFriFlat    = 20;      // Jumma ko is ghante se chakkar khula ho to SELL khol kar kitab jami

input group "=== 5 - Baqi ==="
input long   InpMagic      = 260210;  // EA ki khud kholi hui SELL ka nishan
input bool   InpLines      = true;    // Chart par upar/neeche ki lakeerein

CTrade   trade;

//--- haal (GlobalVariables mein mehfooz, taake EA dobara lagne par yaad rahe)
int      g_phase   = 0;      // 0 = tayyar, 1 = SELL band, intezar
double   g_ref     = 0.0;    // jis price par SELL band hui (Ask)
double   g_closedOpen = 0.0; // band hui SELL kahan khuli thi
int      g_wins    = 0;
int      g_losses  = 0;
int      g_lossRow = 0;
double   g_sum     = 0.0;    // chakkar ka kul nateeja (sirf +5/-5 wala hissa)
double   g_banked  = 0.0;    // band ki gayi SELL ka faida (balance mein gaya)

datetime g_lastAct = 0;
datetime g_lastTry = 0;
string   g_msg     = "Shuru";
string   g_last    = "";

bool     g_newsBlock = false, g_newsOK = false;
datetime g_newsAt = 0, g_newsLast = 0;
string   g_newsName = "";

string Pick(bool c, string a, string b) { if(c) return(a); return(b); }
string M(double v)  { return(DoubleToString(v, 2)); }
string Px(double v) { return(DoubleToString(v, (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS))); }

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
   GlobalVariableSet(Key("ref"),    g_ref);
   GlobalVariableSet(Key("open"),   g_closedOpen);
   GlobalVariableSet(Key("wins"),   g_wins);
   GlobalVariableSet(Key("losses"), g_losses);
   GlobalVariableSet(Key("row"),    g_lossRow);
   GlobalVariableSet(Key("sum"),    g_sum);
   GlobalVariableSet(Key("banked"), g_banked);
  }

void Load()
  {
   g_phase      = (int)GV("phase", 0);
   g_ref        = GV("ref", 0.0);
   g_closedOpen = GV("open", 0.0);
   g_wins       = (int)GV("wins", 0);
   g_losses     = (int)GV("losses", 0);
   g_lossRow    = (int)GV("row", 0);
   g_sum        = GV("sum", 0.0);
   g_banked     = GV("banked", 0.0);
  }

//--- $1 ki harkat par InpLot ka paisa (account ki currency mein)
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

//--- is symbol ki kitab: BUY lots, SELL lots
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

//--- sab se NEECHE khuli 0.01 SELL jo kam az kam InpMinProfit faide mein ho
ulong PickSell(double &openPx, double &pl)
  {
   ulong best = 0; openPx = 0.0; pl = 0.0;
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      ulong t = PositionGetTicket(i);
      if(t == 0) continue;
      if(PositionGetString(POSITION_SYMBOL) != _Symbol) continue;
      if(PositionGetInteger(POSITION_TYPE) != POSITION_TYPE_SELL) continue;
      if(MathAbs(PositionGetDouble(POSITION_VOLUME) - InpLot) > 1e-8) continue;
      double p  = PositionGetDouble(POSITION_PRICE_OPEN);
      double pr = PositionGetDouble(POSITION_PROFIT) + PositionGetDouble(POSITION_SWAP);
      if(pr < InpMinProfit) continue;
      if(best == 0 || p < openPx) { best = t; openPx = p; pl = pr; }
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
   MqlDateTime t; TimeToStruct(TimeCurrent(), t);
   return(t.day_of_week == 5 && t.hour >= hour);
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
   HLine("JCK_up",  g_ref + InpStep, clrLimeGreen, STYLE_DASH, "Yahan nayi SELL = JEET");
   HLine("JCK_ref", g_ref,           clrSilver,    STYLE_DOT,  "Yahan SELL band hui thi");
   HLine("JCK_dn",  g_ref - InpStep, clrTomato,    STYLE_DASH, "Yahan nayi SELL = HAAR");
  }

//+------------------------------------------------------------------+
//|  Chakkar ka doosra hissa: nayi SELL khol kar kitab phir jami      |
//+------------------------------------------------------------------+
void Reopen(string why)
  {
   if(TimeCurrent() - g_lastTry < 10) return;
   g_lastTry = TimeCurrent();

   if(!trade.Sell(InpLot, _Symbol, 0.0, 0.0, 0.0, "JasChakkar " + K_BUILD))
     {
      g_msg = "Nayi SELL nahi khuli: " + IntegerToString((int)trade.ResultRetcode())
              + " " + trade.ResultRetcodeDescription() + " - 10 second baad phir";
      Print("JAS CHAKKAR: ", g_msg);
      return;
     }
   uint rc = trade.ResultRetcode();
   if(rc != TRADE_RETCODE_DONE && rc != TRADE_RETCODE_PLACED)
     {
      g_msg = "Nayi SELL nahi khuli: " + IntegerToString((int)rc) + " " + trade.ResultRetcodeDescription();
      Print("JAS CHAKKAR: ", g_msg);
      return;
     }

   double px = trade.ResultPrice();
   if(px <= 0.0) px = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   double res = 0.0;
   if(!OrderCalcProfit(ORDER_TYPE_SELL, _Symbol, InpLot, px, g_ref, res))
      res = (px - g_ref) * MoneyPerDollar();

   g_sum += res;
   if(res >= 0.0) { g_wins++;   g_lossRow = 0; }
   else           { g_losses++; g_lossRow++;   }

   g_last = StringFormat("%s: SELL band %s, nayi SELL %s -> %s %s",
                         why, Px(g_ref), Px(px), Pick(res >= 0.0, "+", ""), M(res));
   Print("JAS CHAKKAR: ", g_last);
   g_phase   = 0;
   g_ref     = 0.0;
   g_lastAct = TimeCurrent();
   g_msg     = "Kitab phir jami. Agla chakkar thori der mein.";
   Save();
  }

//+------------------------------------------------------------------+
//|  Chakkar ka pehla hissa: faide wali SELL band                     |
//+------------------------------------------------------------------+
void TryStart(double net, double spread)
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
   if(spread > InpMaxSpread)
     { g_msg = StringFormat("Intezar: spread %.2f bara hai (hadd %.2f)", spread, InpMaxSpread); return; }
   if(TimeCurrent() - g_lastAct < InpPauseSec)
     { g_msg = StringFormat("Thehrao: %d second", (int)(InpPauseSec - (TimeCurrent() - g_lastAct))); return; }

   double op, pl;
   ulong tk = PickSell(op, pl);
   if(tk == 0)
     { g_msg = StringFormat("Intezar: koi %.2f SELL %s+ faide mein nahi", InpLot, M(InpMinProfit)); return; }

   if(!InpTrade)
     { g_msg = StringFormat("SIRF DIKHANA: abhi #%I64u SELL @ %s (%s) band hoti", tk, Px(op), M(pl)); return; }
   if(!TerminalInfoInteger(TERMINAL_TRADE_ALLOWED) || !MQLInfoInteger(MQL_TRADE_ALLOWED))
     { g_msg = "Algo Trading band hai - toolbar ka button HARA karein"; return; }
   if(TimeCurrent() - g_lastTry < 10) return;
   g_lastTry = TimeCurrent();

   if(!trade.PositionClose(tk))
     {
      g_msg = "SELL band nahi hui: " + IntegerToString((int)trade.ResultRetcode()) + " " + trade.ResultRetcodeDescription();
      Print("JAS CHAKKAR: ", g_msg);
      return;
     }
   uint rc = trade.ResultRetcode();
   if(rc != TRADE_RETCODE_DONE && rc != TRADE_RETCODE_PLACED)
     {
      g_msg = "SELL band nahi hui: " + IntegerToString((int)rc) + " " + trade.ResultRetcodeDescription();
      Print("JAS CHAKKAR: ", g_msg);
      return;
     }

   double px = trade.ResultPrice();
   if(px <= 0.0) px = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   g_ref        = px;
   g_closedOpen = op;
   g_banked    += pl;
   g_phase      = 1;
   g_lastAct    = TimeCurrent();
   g_msg        = "SELL band. Ab intezar: upar ya neeche.";
   PrintFormat("JAS CHAKKAR: #%I64u SELL @ %s band @ %s (%s). Upar %s / neeche %s",
               tk, Px(op), Px(px), M(pl), Px(g_ref + InpStep), Px(g_ref - InpStep));
   Save();
  }

//+------------------------------------------------------------------+
//|  Panel                                                            |
//+------------------------------------------------------------------+
void Panel(double buy, double sell, int nb, int ns, double bid, double spread)
  {
   double per = MoneyPerDollar();
   string cur = AccountInfoString(ACCOUNT_CURRENCY);
   string s = "";
   s += "=== JAS CHAKKAR  " + K_BUILD + " ===   " + _Symbol + "  (" + cur + ")\n";
   s += Pick(InpTrade, "ASAL KAAM chalu", "SIRF DIKHANA - koi trade nahi") + "\n";
   s += StringFormat("Chakkar: lot %.2f | $%.2f upar = +%s | $%.2f neeche = -%s\n",
                     InpLot, InpStep, M(InpStep * per), InpStep, M(InpStep * per));
   s += "\n";
   s += StringFormat("Kitab: BUY %d (%.2f)  SELL %d (%.2f)  NET %+.2f\n", nb, buy, ns, sell, buy - sell);
   s += StringFormat("Qeemat %s   spread %.2f\n", Px(bid), spread);
   s += "\n";
   if(g_phase == 1)
     {
      double now = 0.0;
      if(!OrderCalcProfit(ORDER_TYPE_SELL, _Symbol, InpLot, bid, g_ref, now)) now = (bid - g_ref) * per;
      s += "HAAL: SELL BAND - intezar\n";
      s += StringFormat("  Band hui: khuli %s, band %s\n", Px(g_closedOpen), Px(g_ref));
      s += StringFormat("  UPAR   %s  -> nayi SELL (jeet)\n", Px(g_ref + InpStep));
      s += StringFormat("  NEECHE %s  -> nayi SELL (haar)\n", Px(g_ref - InpStep));
      s += StringFormat("  Abhi khulti to: %s%s\n", Pick(now >= 0.0, "+", ""), M(now));
     }
   else
      s += "HAAL: TAYYAR\n";
   s += "  " + g_msg + "\n";
   s += "\n";
   s += StringFormat("Chakkar: jeet %d  haar %d  (lagatar haar %d/%d)\n", g_wins, g_losses, g_lossRow, InpMaxLossRow);
   s += StringFormat("Chakkar ka kul: %s%s %s   (ruk jayega %s par)\n", Pick(g_sum >= 0.0, "+", ""), M(g_sum), cur, M(InpStopSum));
   s += StringFormat("Band SELL ka faida (balance mein): %s\n", M(g_banked));
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

   double buy, sell; int nb, ns;
   Book(buy, sell, nb, ns);
   double net    = buy - sell;
   double bid    = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   double ask    = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   double spread = ask - bid;

   if(AccountInfoInteger(ACCOUNT_MARGIN_MODE) != ACCOUNT_MARGIN_MODE_RETAIL_HEDGING)
      g_msg = "Ye account HEDGE nahi - EA kuch nahi karega";
   else if(bid > 0.0)
     {
      if(g_phase == 1)
        {
         if(MathAbs(net) < 1e-6)
           {
            // user ne haath se SELL khol kar kitab jami kar di
            g_phase = 0; g_ref = 0.0; g_lastAct = TimeCurrent();
            g_msg   = "Kitab haath se jami ho gayi - chakkar khatam (gina nahi)";
            Print("JAS CHAKKAR: ", g_msg);
            Save();
           }
         else if(bid >= g_ref + InpStep)  Reopen("JEET");
         else if(bid <= g_ref - InpStep)  Reopen("HAAR");
         else if(FridayAfter(InpFriFlat)) Reopen("JUMMA");
         else if(MathAbs(net - InpLot) > 1e-6)
            g_msg = StringFormat("Dhyan: NET %+.2f hai, %.2f hona chahiye tha (haath se lot?)", net, InpLot);
         else
            g_msg = "SELL band. Intezar: upar ya neeche.";
        }
      else
         TryStart(net, spread);
     }

   DrawLines();
   Panel(buy, sell, nb, ns, bid, spread);
  }

//+------------------------------------------------------------------+
int OnInit()
  {
   trade.SetExpertMagicNumber(InpMagic);
   trade.SetDeviationInPoints(50);
   trade.SetTypeFillingBySymbol(_Symbol);

   if(InpResetStats)
     {
      GlobalVariableDel(Key("wins"));
      GlobalVariableDel(Key("losses"));
      GlobalVariableDel(Key("row"));
      GlobalVariableDel(Key("sum"));
      GlobalVariableDel(Key("banked"));
     }
   Load();
   if(InpLot <= 0.0 || InpStep <= 0.0)
     {
      Alert("JAS CHAKKAR: InpLot aur InpStep 0 se bare hon");
      return(INIT_PARAMETERS_INCORRECT);
     }
   PrintFormat("JAS CHAKKAR %s shuru | %s | haal %d | ref %s", K_BUILD, _Symbol, g_phase, Px(g_ref));
   EventSetTimer(1);
   Work();
   return(INIT_SUCCEEDED);
  }

void OnDeinit(const int reason)
  {
   EventKillTimer();
   ObjectDelete(0, "JCK_up"); ObjectDelete(0, "JCK_dn"); ObjectDelete(0, "JCK_ref");
   Comment("");
  }

void OnTick()  { Work(); }
void OnTimer() { Work(); }
//+------------------------------------------------------------------+
