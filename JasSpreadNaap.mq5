// JasSpreadNaap s1 - sirf NAAP, koi trade nahi (31 Oct 2026) - Koshish #54 ka asli kharcha
//+------------------------------------------------------------------+
//| Exness Demo MT5: Navigator > Scripts > JasSpreadNaap ko kisi bhi |
//| chart par khench kar chhorein > OK. 1-3 minute (ticks aate hain).|
//| Pichhle 20 kaam ke din ke ASLI ticks se spread (ask - bid),      |
//| waqt ke hisaab se ausat:                                         |
//|  - NY 09:30-16:00 (cash session)                                 |
//|  - faisle ka waqt: 10:00, 10:30 ... 16:00 NY ka pehla minute     |
//|  - 10 mein 9 dafa is se kam (90%)                                |
//| Python test ka kharcha 0.03% har taraf = 0.060% aana-jana.       |
//| Koi OrderSend nahi. Algo Trading ki zaroorat nahi.               |
//+------------------------------------------------------------------+
#property copyright "JAS"
#property version   "1.00"
#property script_show_inputs

input string InpSymbols = "US500m,USTECm,XAUUSDm,XAGUSDm"; // Symbols (comma)
input int    InpDays    = 20;                               // Kitne kaam ke din

string BUILD = "s1";
#define NB 3                                   // 0 poora din, 1 NY 09:30-16:00, 2 faisle ka waqt
#define HB 3001                                // spread histogram (points)

double g_w[NB];
double g_s[NB];
double g_p[NB];
double g_h[NB][HB];
string g_txt = "";

void AddLine(string s)
  {
   g_txt += s + "\n";
   Print(s);
  }

datetime NthSunday(int y, int mon, int nth)
  {
   datetime d1 = StringToTime(StringFormat("%04d.%02d.01", y, mon));
   MqlDateTime a;
   TimeToStruct(d1, a);
   int first = 1 + (7 - a.day_of_week) % 7;
   return (datetime)((long)d1 + (long)(first - 1 + 7 * (nth - 1)) * 86400);
  }

bool UsDst(datetime utc)
  {
   MqlDateTime d;
   TimeToStruct(utc, d);
   datetime st = NthSunday(d.year, 3, 2) + 7 * 3600;     // 02:00 EST = 07:00 UTC
   datetime en = NthSunday(d.year, 11, 1) + 6 * 3600;    // 02:00 EDT = 06:00 UTC
   return utc >= st && utc < en;
  }

void Add(int b, double spr, double rel, double w, double pt)
  {
   g_w[b] += w;
   g_s[b] += spr * w;
   g_p[b] += rel * w;
   int k = (int)MathRound(spr / pt);
   if(k < 0)
      k = 0;
   if(k >= HB)
      k = HB - 1;
   g_h[b][k] += w;
  }

double P90(int b, double pt)
  {
   if(g_w[b] <= 0)
      return 0;
   double c = 0;
   for(int k = 0; k < HB; k++)
     {
      c += g_h[b][k];
      if(c >= 0.9 * g_w[b])
         return k * pt;
     }
   return (HB - 1) * pt;
  }

void Measure(string s, long off)
  {
   if(!SymbolSelect(s, true))
     {
      AddLine(StringFormat("%s: symbol nahi mila (Market Watch mein naam dekhein)", s));
      return;
     }
   double pt = SymbolInfoDouble(s, SYMBOL_POINT);
   int dg = (int)SymbolInfoInteger(s, SYMBOL_DIGITS);
   if(pt <= 0)
      pt = MathPow(10, -dg);
   for(int b = 0; b < NB; b++)
     {
      g_w[b] = 0;
      g_s[b] = 0;
      g_p[b] = 0;
      for(int k = 0; k < HB; k++)
         g_h[b][k] = 0;
     }
   int days = 0;
   long nt = 0;
   double lastMid = 0;
   datetime now = TimeTradeServer();
   datetime d0 = (datetime)((long)now - (long)now % 86400);
   MqlTick t[];
   for(int back = 1; back <= InpDays * 2 + 14 && days < InpDays && !IsStopped(); back++)
     {
      datetime ds = (datetime)((long)d0 - (long)back * 86400);
      Comment(StringFormat("JasSpreadNaap %s: %s  din %d / %d  (ticks aa rahe hain...)", BUILD, s, days, InpDays));
      int n = -1;
      for(int tr = 0; tr < 3 && n < 0; tr++)
        {
         n = CopyTicksRange(s, t, COPY_TICKS_INFO, (ulong)ds * 1000, (ulong)(ds + 86400) * 1000 - 1);
         if(n < 0)
            Sleep(2000);
        }
      if(n < 2)
         continue;
      long nyOff = (UsDst((datetime)((long)ds - off + 43200)) ? -4 : -5) * 3600;
      bool had = false;
      for(int i = 0; i < n - 1; i++)
        {
         if(t[i].bid <= 0 || t[i].ask < t[i].bid)
            continue;
         double w = (double)(t[i + 1].time_msc - t[i].time_msc);
         if(w <= 0)
            continue;
         if(w > 60000)
            w = 60000;
         double spr = t[i].ask - t[i].bid;
         double mid = (t[i].ask + t[i].bid) / 2.0;
         long ny = (long)(t[i].time_msc / 1000) - off + nyOff;
         int mod = (int)((((ny % 86400) + 86400) % 86400) / 60);
         Add(0, spr, spr / mid, w, pt);
         if(mod >= 570 && mod < 960)
           {
            Add(1, spr, spr / mid, w, pt);
            had = true;
           }
         if(mod >= 600 && mod <= 960 && mod % 30 == 0)
            Add(2, spr, spr / mid, w, pt);
         lastMid = mid;
         nt++;
        }
      if(had)
         days++;
     }
   if(g_w[1] <= 0)
     {
      AddLine(StringFormat("%s: NY session ke ticks nahi mile (din %d) - Somwar dobara chalayein", s, days));
      return;
     }
   double aN = g_s[1] / g_w[1];
   double pN = 100.0 * g_p[1] / g_w[1];
   double aF = aN;
   double pF = pN;
   if(g_w[2] > 0)
     {
      aF = g_s[2] / g_w[2];
      pF = 100.0 * g_p[2] / g_w[2];
     }
   double aD = g_s[0] / g_w[0];
   double pD = 100.0 * g_p[0] / g_w[0];
   AddLine(StringFormat("%s   (qeemat %s, %d din, %s ticks)", s, DoubleToString(lastMid, dg), days, IntegerToString(nt)));
   AddLine(StringFormat("     NY 9:30-16:00 ausat %s = %.4f%%", DoubleToString(aN, dg), pN));
   AddLine(StringFormat("     faisle ke waqt %s = %.4f%%   (10 mein 9 dafa <= %s)", DoubleToString(aF, dg), pF,
                        DoubleToString(P90(2, pt), dg)));
   AddLine(StringFormat("     poora din %s = %.4f%%   |   Python 0.060%% = %.1f guna", DoubleToString(aD, dg), pD,
                        0.06 / MathMax(pF, 0.000001)));
  }

void OnStart()
  {
   long off = (long)MathRound((double)((long)TimeTradeServer() - (long)TimeGMT()) / 3600.0) * 3600;
   AddLine(StringFormat("JAS SPREAD NAAP %s - pichhle %d din ke asli ticks (server UTC%+d)", BUILD, InpDays, (int)(off / 3600)));
   AddLine(StringFormat("Python test ka kharcha: 0.03%% har taraf = %.3f%% aana-jana", 0.06));
   AddLine(StringFormat("%s", " "));
   string syms[];
   int ns = StringSplit(InpSymbols, ',', syms);
   for(int k = 0; k < ns && !IsStopped(); k++)
     {
      string s = syms[k];
      StringTrimLeft(s);
      StringTrimRight(s);
      if(s == "")
         continue;
      Measure(s, off);
     }
   Comment(g_txt);
   MessageBox(g_txt, "JasSpreadNaap " + BUILD, MB_OK | MB_ICONINFORMATION);
  }
