//+------------------------------------------------------------------+
//|                                                   JasTideEA.mq5  |
//|  JAS Tide v1.1 ka MT5 tarjuma — Donchian breakout + HTF filter   |
//|                                                                  |
//|  YE STRATEGIES/JAS_TIDE_V1.PINE KA HU-BA-HU TARJUMA HAI.         |
//|  Pine par TradingView Strategy Tester ka natija (XAUUSD 1D,      |
//|  saara data, 10/5/14/2.0/D/50/200/1%/2R/0.25):                   |
//|     458 trades | 40.17% jeet | PF 1.564 | Max DD 20.64%          |
//|  2014-2019 (phansa daur): 45 trades | PF 1.205 | DD 4.47%        |
//|  Agar is EA ka MT5 backtest in se BOHOT mukhtalif aaye to kahin  |
//|  tarjume mein farq hai — pehle wajah dhoondein, tab bharosa.      |
//|                                                                  |
//|  QAWAID (sirf chaar):                                            |
//|   1) BUY : band candle ka close pichhli N candle ke sab se       |
//|            ooncha high tore, AUR D1 par EMA50 > EMA200           |
//|   2) SELL: iska ulta                                             |
//|   3) Stop: entry se ATR x 2.0 — aur sirf AAGE sarakta hai        |
//|   4) Nikalna: 2R par aadha band, baqi ulte Donchian par          |
//|                                                                  |
//|  NO grid / NO martingale / NO hedging / NO averaging.            |
//|  Aik waqt mein sirf AIK position.                                |
//|                                                                  |
//|  REPAINT NAHI: har faisla BAND ho chuki candle par hota hai      |
//|  (naya bar banne par), aur D1 ka EMA shift 1 se parha jata hai.  |
//+------------------------------------------------------------------+
#property copyright "JAS-SNIPER-BOT"
#property version   "1.00"
#property strict

#include <Trade\Trade.mqh>
CTrade trade;

//--------------------------- INPUTS -----------------------------------
input group "=== 1 · Qawaid ==="
input int    InpEntryLen       = 10;      // Breakout: kitni candle ka high/low tore
input int    InpExitLen        = 5;       // Exit: kitni candle ka ulta high/low
input int    InpAtrPeriod      = 14;      // ATR period
input double InpAtrMult        = 2.0;     // Shuru ka stop (x ATR)

input group "=== 2 · Bara timeframe ka filter ==="
input bool   InpUseHTF         = true;    // HTF filter lagao
input ENUM_TIMEFRAMES InpHtfTF = PERIOD_D1; // Bara timeframe
input int    InpHtfFast        = 50;      // HTF EMA fast
input int    InpHtfSlow        = 200;     // HTF EMA slow
input bool   InpExitOnHtfFlip  = true;    // HTF palat jaye to nikal jao

input group "=== 3 · Risk (jaan boojh kar tang — khud na barhayein) ==="
input double InpRiskPercent    = 1.0;     // Har trade par risk (% balance)
input bool   InpUsePartial     = true;    // 2R par aadha band karo
input double InpPartialR       = 2.0;     // Aadha band karne ka R
input double InpMaxLot         = 1.00;    // Lot ki hadd (hifazat)

input group "=== 4 · Chop filter ==="
input bool   InpUseAtrFloor    = true;    // Bohot susti mein trade na karo
input double InpMinAtrPercent  = 0.25;    // Kam az kam ATR (% price ka)

input group "=== 5 · Amal ==="
input int    InpSlippagePoints = 50;      // Max slippage (points)
input int    InpMagicNumber    = 20260917; // Magic number

//--------------------------- GLOBAL STATE ------------------------------
int      g_atrHandle   = INVALID_HANDLE;
int      g_htfFastH    = INVALID_HANDLE;
int      g_htfSlowH    = INVALID_HANDLE;
datetime g_lastBarTime = 0;
bool     g_skipFirstBar = true;           // attach wale bar par trade nahi

double   g_entryPx     = 0.0;             // is trade ki entry
double   g_initR       = 0.0;             // shuru ka stop faasla (1R)
double   g_initVol     = 0.0;             // entry ki poori maqdaar
bool     g_partialDone = false;           // aadha band ho chuka?

//+------------------------------------------------------------------+
int OnInit()
  {
   if(InpEntryLen < 2 || InpExitLen < 2)
     {
      Print("ERROR: InpEntryLen aur InpExitLen 2 se kam nahi ho sakte.");
      return(INIT_PARAMETERS_INCORRECT);
     }
   if(InpRiskPercent <= 0.0 || InpRiskPercent > 5.0)
     {
      Print("ERROR: InpRiskPercent 0 se 5 ke darmiyan hona chahiye.");
      return(INIT_PARAMETERS_INCORRECT);
     }

   trade.SetExpertMagicNumber(InpMagicNumber);
   trade.SetDeviationInPoints(InpSlippagePoints);
   trade.SetTypeFillingBySymbol(_Symbol);
   trade.LogLevel(LOG_LEVEL_ERRORS);

   g_atrHandle = iATR(_Symbol, PERIOD_CURRENT, InpAtrPeriod);
   g_htfFastH  = iMA(_Symbol, InpHtfTF, InpHtfFast, 0, MODE_EMA, PRICE_CLOSE);
   g_htfSlowH  = iMA(_Symbol, InpHtfTF, InpHtfSlow, 0, MODE_EMA, PRICE_CLOSE);

   if(g_atrHandle == INVALID_HANDLE || g_htfFastH == INVALID_HANDLE || g_htfSlowH == INVALID_HANDLE)
     {
      Print("ERROR: indicator handle nahi bana.");
      return(INIT_FAILED);
     }

   g_lastBarTime  = iTime(_Symbol, PERIOD_CURRENT, 0);
   g_skipFirstBar = true;
   SyncStateWithPosition();
   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   if(g_atrHandle != INVALID_HANDLE) IndicatorRelease(g_atrHandle);
   if(g_htfFastH  != INVALID_HANDLE) IndicatorRelease(g_htfFastH);
   if(g_htfSlowH  != INVALID_HANDLE) IndicatorRelease(g_htfSlowH);
  }

//+------------------------------------------------------------------+
//| Naya bar bana? Har faisla sirf band candle par hota hai.          |
//+------------------------------------------------------------------+
bool IsNewBar()
  {
   datetime t = iTime(_Symbol, PERIOD_CURRENT, 0);
   if(t == 0) return(false);
   if(t == g_lastBarTime) return(false);
   g_lastBarTime = t;
   return(true);
  }

//+------------------------------------------------------------------+
//| Is EA ki apni position (symbol + magic)                          |
//+------------------------------------------------------------------+
bool HasPosition(long &type, double &volume, double &openPrice, double &sl)
  {
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      ulong ticket = PositionGetTicket(i);
      if(ticket == 0) continue;
      if(!PositionSelectByTicket(ticket)) continue;
      if(PositionGetString(POSITION_SYMBOL) != _Symbol) continue;
      if(PositionGetInteger(POSITION_MAGIC) != InpMagicNumber) continue;
      type      = PositionGetInteger(POSITION_TYPE);
      volume    = PositionGetDouble(POSITION_VOLUME);
      openPrice = PositionGetDouble(POSITION_PRICE_OPEN);
      sl        = PositionGetDouble(POSITION_SL);
      return(true);
     }
   return(false);
  }

//+------------------------------------------------------------------+
//| Terminal restart ya reattach ke baad state wapas jorna            |
//+------------------------------------------------------------------+
void SyncStateWithPosition()
  {
   long   type; double vol, openPx, sl;
   if(HasPosition(type, vol, openPx, sl))
     {
      g_entryPx = openPx;
      if(g_initR <= 0.0) g_initR = MathAbs(openPx - sl);
      if(g_initVol <= 0.0) g_initVol = vol;
     }
   else
     {
      g_entryPx     = 0.0;
      g_initR       = 0.0;
      g_initVol     = 0.0;
      g_partialDone = false;
     }
  }

//+------------------------------------------------------------------+
//| Broker ki minimum stop distance (points -> price)                 |
//+------------------------------------------------------------------+
double MinStopDistance()
  {
   long stopsLevel = SymbolInfoInteger(_Symbol, SYMBOL_TRADE_STOPS_LEVEL);
   long freezeLvl  = SymbolInfoInteger(_Symbol, SYMBOL_TRADE_FREEZE_LEVEL);
   long lvl        = MathMax(stopsLevel, freezeLvl);
   return((double)lvl * _Point);
  }

//+------------------------------------------------------------------+
//| Risk se lot nikalna. Stop jitna door, lot utna chhota.            |
//+------------------------------------------------------------------+
double LotFromRisk(double stopDistPrice)
  {
   if(stopDistPrice <= 0.0) return(0.0);

   double tickValue = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);
   double tickSize  = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);
   if(tickValue <= 0.0 || tickSize <= 0.0) return(0.0);

   double riskMoney  = AccountInfoDouble(ACCOUNT_BALANCE) * InpRiskPercent / 100.0;
   double lossPerLot = (stopDistPrice / tickSize) * tickValue;
   if(lossPerLot <= 0.0) return(0.0);

   double lots = riskMoney / lossPerLot;

   double minLot  = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
   double maxLot  = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX);
   double lotStep = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);
   if(lotStep <= 0.0) lotStep = 0.01;

   lots = MathFloor(lots / lotStep) * lotStep;
   if(lots < minLot) return(0.0);              // risk itna chhota ke min lot bhi zyada hai
   if(lots > maxLot) lots = maxLot;
   if(lots > InpMaxLot) lots = InpMaxLot;      // hamari apni hifazati hadd

   return(NormalizeDouble(lots, 2));
  }

//+------------------------------------------------------------------+
//| HTF ka rukh — shift 1, yani BAND ho chuki daily candle            |
//+------------------------------------------------------------------+
bool HtfBull(bool &ok)
  {
   ok = false;
   if(!InpUseHTF) { ok = true; return(true); }   // filter band = dono taraf ijazat

   double f[], s[];
   if(CopyBuffer(g_htfFastH, 0, 1, 1, f) != 1) return(false);
   if(CopyBuffer(g_htfSlowH, 0, 1, 1, s) != 1) return(false);
   ok = true;
   return(f[0] > s[0]);
  }

//+------------------------------------------------------------------+
//| 2R par aadha band — har tick par, kyunki Pine mein ye limit order |
//| hai jo candle ke beech bhar jata hai.                             |
//+------------------------------------------------------------------+
void CheckPartialOnTick()
  {
   if(!InpUsePartial || g_partialDone) return;
   if(g_initR <= 0.0 || g_entryPx <= 0.0) return;

   long posType; double posVol, posOpen, posSL;
   if(!HasPosition(posType, posVol, posOpen, posSL)) return;

   if(g_initVol > 0.0 && posVol < g_initVol * 0.9) { g_partialDone = true; return; }

   bool   isBuy  = (posType == POSITION_TYPE_BUY);
   double target = isBuy ? (g_entryPx + g_initR * InpPartialR)
                         : (g_entryPx - g_initR * InpPartialR);
   double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   bool   hit = isBuy ? (bid >= target) : (ask <= target);
   if(!hit) return;

   double lotStep = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);
   double minLot  = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
   if(lotStep <= 0.0) lotStep = 0.01;

   double half = MathFloor((posVol / 2.0) / lotStep) * lotStep;
   if(half < minLot || (posVol - half) < minLot)
     {
      g_partialDone = true;   // itni chhoti position ke aadha nahi ho sakta
      return;
     }
   if(trade.PositionClosePartial(_Symbol, NormalizeDouble(half, 2)))
     {
      g_partialDone = true;
      Print("2R par aadha band kiya.");
     }
  }

//+------------------------------------------------------------------+
void OnTick()
  {
   // Aadha band karne wala 2R ka target HAR TICK par dekha jata hai. Pine
   // mein ye limit order hai jo candle ke beech mein bhar jata hai - agar
   // yahan sirf candle band hone par dekhte to natija backtest se alag hota.
   CheckPartialOnTick();

   if(!IsNewBar()) return;

   if(g_skipFirstBar) { g_skipFirstBar = false; SyncStateWithPosition(); return; }
   if(!TerminalInfoInteger(TERMINAL_TRADE_ALLOWED)) return;
   if(!MQLInfoInteger(MQL_TRADE_ALLOWED)) return;
   if(!SymbolInfoInteger(_Symbol, SYMBOL_TRADE_MODE)) return;

   //--- ATR: shift 1 (band candle)
   double atrBuf[];
   if(CopyBuffer(g_atrHandle, 0, 1, 1, atrBuf) != 1) return;
   double atr = atrBuf[0];
   if(atr <= 0.0) return;

   //--- Donchian levels. Pine mein [1] laga hai, yani MOJOODA candle shamil
   //    nahi. MT5 mein band candle shift 1 hai, is liye levels shift 2 se
   //    ginte hain — warna candle apna hi high tor deti aur har bar signal
   //    ban jata.
   int hiIdx = iHighest(_Symbol, PERIOD_CURRENT, MODE_HIGH, InpEntryLen, 2);
   int loIdx = iLowest (_Symbol, PERIOD_CURRENT, MODE_LOW,  InpEntryLen, 2);
   int hiExIdx = iHighest(_Symbol, PERIOD_CURRENT, MODE_HIGH, InpExitLen, 2);
   int loExIdx = iLowest (_Symbol, PERIOD_CURRENT, MODE_LOW,  InpExitLen, 2);
   if(hiIdx < 0 || loIdx < 0 || hiExIdx < 0 || loExIdx < 0) return;

   double hiBrk  = iHigh(_Symbol, PERIOD_CURRENT, hiIdx);
   double loBrk  = iLow (_Symbol, PERIOD_CURRENT, loIdx);
   double hiExit = iHigh(_Symbol, PERIOD_CURRENT, hiExIdx);
   double loExit = iLow (_Symbol, PERIOD_CURRENT, loExIdx);

   double closed = iClose(_Symbol, PERIOD_CURRENT, 1);
   if(closed <= 0.0) return;

   bool htfOk = false;
   bool bull  = HtfBull(htfOk);
   if(!htfOk) return;                    // HTF data abhi taiyar nahi
   bool bullOK = (!InpUseHTF) || bull;
   bool bearOK = (!InpUseHTF) || (!bull);

   double atrPct = atr / closed * 100.0;
   bool   liveOk = (!InpUseAtrFloor) || (atrPct >= InpMinAtrPercent);

   long   posType; double posVol, posOpen, posSL;
   bool   inPos = HasPosition(posType, posVol, posOpen, posSL);

   if(inPos)
      ManageOpenPosition(posType, posVol, posOpen, posSL, atr, hiExit, loExit, bull);
   else
     {
      // position band ho chuki — purani yaadein saaf
      g_entryPx = 0.0; g_initR = 0.0; g_initVol = 0.0; g_partialDone = false;

      if(!liveOk) return;
      if(closed > hiBrk && bullOK) OpenTrade(true,  atr);
      else if(closed < loBrk && bearOK) OpenTrade(false, atr);
     }
  }

//+------------------------------------------------------------------+
void OpenTrade(bool isBuy, double atr)
  {
   double stopDist = atr * InpAtrMult;
   double minDist  = MinStopDistance();
   if(stopDist < minDist) stopDist = minDist;   // broker ki hadd ka ehtiram
   if(stopDist <= 0.0) return;

   double lots = LotFromRisk(stopDist);
   if(lots <= 0.0)
     {
      Print("Trade nahi khuli: risk se nikla lot minimum se kam hai. Balance barhayein ya risk % barhayein (soch samajh kar).");
      return;
     }

   double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   int    dig = (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS);

   double price = isBuy ? ask : bid;
   double sl    = isBuy ? (price - stopDist) : (price + stopDist);
   sl = NormalizeDouble(sl, dig);

   bool ok = isBuy ? trade.Buy(lots, _Symbol, 0.0, sl, 0.0, "JAS Tide")
                   : trade.Sell(lots, _Symbol, 0.0, sl, 0.0, "JAS Tide");
   if(!ok)
     {
      PrintFormat("Order fail: retcode=%d  %s", trade.ResultRetcode(), trade.ResultRetcodeDescription());
      return;
     }

   g_entryPx     = price;
   g_initR       = stopDist;
   g_initVol     = lots;
   g_partialDone = false;

   PrintFormat("%s khuli @ %s | SL %s | lot %.2f | 1R = %s",
               isBuy ? "BUY" : "SELL",
               DoubleToString(price, dig), DoubleToString(sl, dig), lots,
               DoubleToString(stopDist, dig));
  }

//+------------------------------------------------------------------+
//| Khuli position: stop sirf AAGE sarakta hai, kabhi peeche nahi.    |
//+------------------------------------------------------------------+
void ManageOpenPosition(long posType, double posVol, double posOpen, double posSL,
                        double atr, double hiExit, double loExit, bool bull)
  {
   int    dig  = (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS);
   double ask  = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   double bid  = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   double minD = MinStopDistance();

   if(g_entryPx <= 0.0) g_entryPx = posOpen;
   if(g_initR   <= 0.0) g_initR   = MathAbs(posOpen - posSL);
   if(g_initVol <= 0.0) g_initVol = posVol;

   // aadha band ho chuka? maqdaar ghatne se pata chalta hai
   if(!g_partialDone && g_initVol > 0.0 && posVol < g_initVol * 0.9)
      g_partialDone = true;

   bool isBuy = (posType == POSITION_TYPE_BUY);

   //--- HTF palat gaya to nikal jao
   if(InpExitOnHtfFlip && InpUseHTF)
     {
      if((isBuy && !bull) || (!isBuy && bull))
        {
         trade.PositionClose(_Symbol);
         Print("HTF palta — position band.");
         return;
        }
     }

   //--- Stop ka ratchet: sirf trade ke haq mein
   double newSL = posSL;
   if(isBuy)
     {
      double cand = loExit;
      if(cand > newSL) newSL = cand;
      if(bid - newSL < minD) newSL = bid - minD;    // broker ki hadd
      if(newSL <= posSL) return;                    // behtar nahi hua
     }
   else
     {
      double cand = hiExit;
      if(cand < newSL || newSL == 0.0) newSL = cand;
      if(newSL - ask < minD) newSL = ask + minD;
      if(posSL != 0.0 && newSL >= posSL) return;
     }

   newSL = NormalizeDouble(newSL, dig);
   if(MathAbs(newSL - posSL) < _Point) return;

   if(!trade.PositionModify(_Symbol, newSL, 0.0))
      PrintFormat("SL modify fail: retcode=%d %s", trade.ResultRetcode(), trade.ResultRetcodeDescription());
  }
//+------------------------------------------------------------------+
