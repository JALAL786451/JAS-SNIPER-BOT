// JasBarExport x1 - sirf DATA likhta hai, koi trade nahi (16 Oct 2026)
//+------------------------------------------------------------------+
//| Strategy Tester ke andar chalayein: har band M1 candle ki line   |
//| saal-wise CSV mein (Common\Files\<symbol>_M1_<saal>.csv).        |
//| Wohi format jo Ctrl+U > Export Bars deta hai (tab se alag).      |
//| Tester: XAUUSDc, M1, 2021.01.01 - 2024.12.31, "1 minute OHLC".   |
//| Koi OrderSend nahi, koi position nahi.                           |
//+------------------------------------------------------------------+
#property copyright "JAS"
#property version   "1.00"

string   BUILD   = "x1";
int      g_h     = INVALID_HANDLE;
int      g_year  = 0;
datetime g_last  = 0;
long     g_lines = 0;

void OpenYear(int y)
  {
   if(g_h != INVALID_HANDLE)
      FileClose(g_h);
   string fn = _Symbol + "_M1_" + IntegerToString(y) + ".csv";
   g_h = FileOpen(fn, FILE_WRITE | FILE_CSV | FILE_ANSI | FILE_COMMON, '\t');
   if(g_h == INVALID_HANDLE)
     {
      Print("JasBarExport ", BUILD, ": file nahi khuli ", fn, " error ", GetLastError());
      return;
     }
   FileWrite(g_h, "<DATE>", "<TIME>", "<OPEN>", "<HIGH>", "<LOW>", "<CLOSE>", "<TICKVOL>", "<VOL>", "<SPREAD>");
   g_year = y;
   Print("JasBarExport ", BUILD, ": nayi file ", fn);
  }

int OnInit()
  {
   Comment(StringFormat("JasBarExport %s - sirf data likhta hai, trade nahi", BUILD));
   return(INIT_SUCCEEDED);
  }

void OnTick()
  {
   datetime t0 = iTime(_Symbol, PERIOD_M1, 0);
   if(t0 == 0 || t0 == g_last)
      return;
   bool first = (g_last == 0);
   g_last = t0;
   if(first)
      return;                       // pehli candle adhoori ho sakti hai
   MqlRates r[];
   if(CopyRates(_Symbol, PERIOD_M1, 1, 1, r) != 1)
      return;
   MqlDateTime dt;
   TimeToStruct(r[0].time, dt);
   if(dt.year != g_year)
      OpenYear(dt.year);
   if(g_h == INVALID_HANDLE)
      return;
   FileWrite(g_h,
             TimeToString(r[0].time, TIME_DATE),
             TimeToString(r[0].time, TIME_SECONDS),
             DoubleToString(r[0].open, _Digits),
             DoubleToString(r[0].high, _Digits),
             DoubleToString(r[0].low, _Digits),
             DoubleToString(r[0].close, _Digits),
             IntegerToString(r[0].tick_volume),
             IntegerToString(r[0].real_volume),
             IntegerToString(r[0].spread));
   g_lines++;
  }

void OnDeinit(const int reason)
  {
   if(g_h != INVALID_HANDLE)
      FileClose(g_h);
   Print("JasBarExport ", BUILD, ": kul ", g_lines, " lines likhi. Files: ",
         TerminalInfoString(TERMINAL_COMMONDATA_PATH), "\\Files");
   Comment("");
  }
