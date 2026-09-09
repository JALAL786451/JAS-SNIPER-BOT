//+------------------------------------------------------------------+
//| FishingLotsEA_v3.mq5                                             |
//|                                                                   |
//| v3 changes from v2 (all driven by ANSWERSforclaudecode.md):      |
//|   * EMA, not SMA (v2 said EMA in its notes but built SMA handles) |
//|   * Lot cap is now TOTAL VOLUME, not a count of positions        |
//|   * Hedges are tied to the specific position they hedge, and the  |
//|     pair closes together on combined net P/L - never leg by leg   |
//|   * Chain tracking is per-pair, not one global "hedged" flag      |
//|   * Strict pivots, matching Pine's ta.pivothigh / ta.pivotlow     |
//|   * Commission included in every profit decision                  |
//|   * Broker-date daily loss reset, not a rolling 24h window        |
//|   * Lot normalization, order-result checking, real logging        |
//|   * Netting-account detection (the hedge design cannot work there)|
//|   * Multi-timeframe inputs wired through every detection function |
//|                                                                   |
//| Auto-entry is still OFF by default, and testing says leave it     |
//| that way: the placeholder entry rule scored WORSE than random      |
//| entries on both the 1-minute and 5-minute charts. You open trades  |
//| manually; the EA manages them from there.                          |
//|                                                                    |
//| The management itself does work. Run over identical bars with the   |
//| same entries, hedging on finished at -245 against -599 with hedging |
//| off, and only 78 of that 354 difference is explained by trading     |
//| less often.                                                         |
//|                                                                   |
//| See pine-to-mql5-bridge-notes.md for what was ported from the     |
//| "SMC Coach - Pro v2" Pine Script and what was left out.           |
//+------------------------------------------------------------------+
#property copyright "Draft v3"
#property version   "3.10"
#property strict

#include <Trade\Trade.mqh>
CTrade trade;

//--- Marker written into every hedge's comment so a chain survives a
//--- terminal restart or a recompile. Format: HDG#<original ticket>.
#define HEDGE_TAG "HDG#"

//+------------------------------------------------------------------+
//| Inputs                                                            |
//+------------------------------------------------------------------+
input group "=== Core ==="
input double InpLotSize             = 0.01;   // Fixed lot size for normal trades (CONFIRMED)
input double InpProfitTargetUSD     = 0.50;   // Close a normal lot at this net profit ($) - tune on demo
input double InpMaxTotalVolume      = 0.06;   // Cap on SUMMED open volume, hedges included. 0 = off. PLACEHOLDER
input double InpMaxDailyLossUSD     = 20.0;   // Stop opening new trades past this daily loss ($). 0 = off. PLACEHOLDER
input int    InpMagicNumber         = 778899; // Tag for trades the EA itself opens
input bool   InpManageManualTrades  = true;   // true = manage every position on the symbol, yours included
input ulong  InpSlippagePoints      = 30;     // Max deviation in points - tune if orders get rejected

input group "=== Timeframes (multi-timeframe wiring) ==="
input ENUM_TIMEFRAMES InpTrendTF      = PERIOD_CURRENT; // EMA trend timeframe
input ENUM_TIMEFRAMES InpStructureTF  = PERIOD_CURRENT; // Higher timeframe used by the gate below
input bool   InpUseHTFGate          = false;  // true = a hedge also needs the structure TF to agree

input group "=== FVG / LGB scan timeframes ==="
// A losing trade is often NOT a trend change. It is a pullback caused by a
// liquidity grab or a gap on some OTHER timeframe, after which the original
// flow resumes. So the scan runs across several timeframes at once, and a
// favourable signal on ANY of them means hold rather than hedge.
input ENUM_TIMEFRAMES InpScanTF1      = PERIOD_CURRENT; // always scanned
input bool            InpUseScanTF2   = true;
input ENUM_TIMEFRAMES InpScanTF2      = PERIOD_M5;
input bool            InpUseScanTF3   = true;
input ENUM_TIMEFRAMES InpScanTF3      = PERIOD_M15;
input bool            InpUseScanTF4   = false;
input ENUM_TIMEFRAMES InpScanTF4      = PERIOD_H1;

input group "=== Trend ==="
input int    InpFastEMA             = 20;
input int    InpSlowEMA             = 50;
input bool   InpUseADX              = false;  // true = match the Pine script's ADX filter
input int    InpADXPeriod           = 14;
input double InpADXMin              = 18.0;

input group "=== FVG / Liquidity Grab (ported from SMC Coach Pro v2) ==="
input int    InpPivotLR             = 3;      // pivot lookback each side - the script's "Pivot L/R"
input int    InpPivotMaxLookback    = 200;    // how far back to hunt for the last confirmed pivot
input int    InpSignalWindowBars    = 1;      // 1 = faithful to Pine. 2-3 = signal stays valid longer

input group "=== Hedge ==="
input double InpHedgeLotMultiple    = 2.0;    // Hedge size relative to the position it hedges (CONFIRMED).
                                             // MEASURED: do not raise this. At 4.5 the basket reached its
                                             // floor 119 times instead of 48, because a larger hedge moves
                                             // the pair faster.
input double InpBasketTargetUSD     = 3.00;   // Close the pair once combined net P/L exceeds this.
                                             // MEASURED: at 0.00 the hedge bled money because every win
                                             // banked nothing. On the 1-minute chart it went from -480 at
                                             // 0.00 to -263 at 3.00 over the same data.
input double InpBasketMaxLossUSD    = 10.0;   // Hard floor: force-close the pair at this combined loss. 0 = off. PLACEHOLDER

input group "=== Stop Loss ==="
input bool   InpCandleCloseSL       = true;   // true = close-based SL, false = broker (wick) SL
input double InpSLDistanceUSD       = 3.0;    // SL distance in gold price $ from entry - tune on demo

input group "=== Costs ==="
input bool   InpIncludeCommission   = true;   // Subtract commission before calling anything profitable
input bool   InpAssumeRoundTurn     = true;   // true = double the entry commission to cover the exit too

input group "=== Re-entry after Take-Profit (auto-entry only) ==="
input bool   InpRequireMA20Pullback = true;

input group "=== Optional Auto-Entry (OFF by default) ==="
input bool   InpEnableAutoEntry     = false;

input group "=== Safety ==="
input bool   InpAllowNettingAccount = false;  // Leave false. The hedge design breaks on netting accounts
input bool   InpVerboseLog          = true;

//+------------------------------------------------------------------+
//| Globals                                                           |
//+------------------------------------------------------------------+
int      hFastEMA = INVALID_HANDLE;
int      hSlowEMA = INVALID_HANDLE;
int      hADX     = INVALID_HANDLE;
int      hStructFast = INVALID_HANDLE;
int      hStructSlow = INVALID_HANDLE;

bool     gInitFailed          = false;
datetime gLastBarTime         = 0;
#define MAX_SCAN_TF 4

bool     gWaitPullbackBuy     = false;
bool     gWaitPullbackSell    = false;

double   gDayStartEquity      = 0.0;
int      gDayStartDay         = -1;
int      gDayStartMonth       = -1;
int      gDayStartYear        = -1;

//--- Cached signal state, one slot per scanned timeframe. Each slot is
//--- recomputed only when that timeframe prints a new bar.
ENUM_TIMEFRAMES gScanTF[MAX_SCAN_TF];
datetime gScanLastBar[MAX_SCAN_TF];
bool     gScanBullFVG[MAX_SCAN_TF];
bool     gScanBearFVG[MAX_SCAN_TF];
bool     gScanSweepBuy[MAX_SCAN_TF];
bool     gScanSweepSell[MAX_SCAN_TF];
int      gScanCount = 0;

//--- Chain map, rebuilt from live positions every tick.
ulong    gChainHedge[];     // hedge ticket
ulong    gChainOwner[];     // the original position that hedge belongs to

//--- Remembers the last orphan hedge logged, so it is reported once
//--- rather than on every tick.
ulong    gLastOrphanLogged = 0;

//--- Commission cache. Commission is fixed once a position opens.
ulong    gCommTicket[];
double   gCommValue[];

//+------------------------------------------------------------------+
//| Logging                                                           |
//+------------------------------------------------------------------+
void Log(string msg)
{
   if(InpVerboseLog) Print("[FishingLots] ", msg);
}

void LogAlways(string msg)
{
   Print("[FishingLots] ", msg);
}

//+------------------------------------------------------------------+
//| Init                                                              |
//+------------------------------------------------------------------+
int OnInit()
{
   gInitFailed = false;

   // The whole hedge design assumes opposite positions can coexist.
   // On a netting account a "hedge" order silently reduces or reverses
   // the original position instead, which breaks everything below.
   ENUM_ACCOUNT_MARGIN_MODE marginMode =
      (ENUM_ACCOUNT_MARGIN_MODE)AccountInfoInteger(ACCOUNT_MARGIN_MODE);

   if(marginMode != ACCOUNT_MARGIN_MODE_RETAIL_HEDGING)
   {
      if(!InpAllowNettingAccount)
      {
         LogAlways("REFUSING TO START: this is not a hedging account.");
         LogAlways("On a netting account the hedge order reduces or reverses");
         LogAlways("the original position instead of sitting alongside it, so");
         LogAlways("the hold-vs-hedge logic cannot work at all.");
         LogAlways("Use a hedging account, or set InpAllowNettingAccount=true");
         LogAlways("if you understand that hedging will not behave as designed.");
         gInitFailed = true;
         return(INIT_FAILED);
      }
      LogAlways("WARNING: netting account detected. Hedging will NOT behave as designed.");
   }

   trade.SetExpertMagicNumber(InpMagicNumber);
   trade.SetDeviationInPoints(InpSlippagePoints);
   trade.SetTypeFillingBySymbol(_Symbol);

   hFastEMA = iMA(_Symbol, InpTrendTF, InpFastEMA, 0, MODE_EMA, PRICE_CLOSE);
   hSlowEMA = iMA(_Symbol, InpTrendTF, InpSlowEMA, 0, MODE_EMA, PRICE_CLOSE);
   hADX     = iADX(_Symbol, InpTrendTF, InpADXPeriod);

   if(hFastEMA == INVALID_HANDLE || hSlowEMA == INVALID_HANDLE || hADX == INVALID_HANDLE)
   {
      LogAlways("Failed to create trend indicator handles.");
      gInitFailed = true;
      return(INIT_FAILED);
   }

   if(InpUseHTFGate)
   {
      hStructFast = iMA(_Symbol, InpStructureTF, InpFastEMA, 0, MODE_EMA, PRICE_CLOSE);
      hStructSlow = iMA(_Symbol, InpStructureTF, InpSlowEMA, 0, MODE_EMA, PRICE_CLOSE);
      if(hStructFast == INVALID_HANDLE || hStructSlow == INVALID_HANDLE)
      {
         LogAlways("Failed to create structure-timeframe handles.");
         gInitFailed = true;
         return(INIT_FAILED);
      }
   }

   BuildScanList();
   ResetDailyBaseline();

   LogAlways("--------------------------------------------------");
   LogAlways("FishingLotsEA v3 started.");
   LogAlways(StringFormat("Symbol      : %s", _Symbol));
   LogAlways(StringFormat("Chart TF    : %s", EnumToString((ENUM_TIMEFRAMES)Period())));
   LogAlways(StringFormat("Trend TF    : %s", EnumToString(InpTrendTF)));
   string tfList = "";
   for(int i = 0; i < gScanCount; i++)
      tfList += (i > 0 ? ", " : "") + EnumToString(gScanTF[i]);
   LogAlways(StringFormat("Scan TFs    : %s", tfList));
   LogAlways(StringFormat("Structure TF: %s (gate %s)",
                          EnumToString(InpStructureTF), InpUseHTFGate ? "ON" : "OFF"));
   LogAlways(StringFormat("Volume cap  : %.2f   Daily loss cap: %.2f",
                          InpMaxTotalVolume, InpMaxDailyLossUSD));
   LogAlways(StringFormat("Basket target: %.2f   Basket max loss: %.2f",
                          InpBasketTargetUSD, InpBasketMaxLossUSD));
   LogAlways(StringFormat("Manage manual trades: %s   Auto-entry: %s",
                          InpManageManualTrades ? "YES" : "NO",
                          InpEnableAutoEntry ? "ON" : "OFF"));
   LogAlways("--------------------------------------------------");

   return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason)
{
   if(hFastEMA    != INVALID_HANDLE) IndicatorRelease(hFastEMA);
   if(hSlowEMA    != INVALID_HANDLE) IndicatorRelease(hSlowEMA);
   if(hADX        != INVALID_HANDLE) IndicatorRelease(hADX);
   if(hStructFast != INVALID_HANDLE) IndicatorRelease(hStructFast);
   if(hStructSlow != INVALID_HANDLE) IndicatorRelease(hStructSlow);
}

//+------------------------------------------------------------------+
//| Small helpers                                                     |
//+------------------------------------------------------------------+
bool IsNewBar()
{
   datetime t = iTime(_Symbol, PERIOD_CURRENT, 0);
   if(t == 0) return false;
   if(t != gLastBarTime) { gLastBarTime = t; return true; }
   return false;
}

double BufferValue(int handle, int shift)
{
   if(handle == INVALID_HANDLE) return 0.0;
   double buf[];
   ArraySetAsSeries(buf, true);
   if(CopyBuffer(handle, 0, shift, 1, buf) <= 0) return 0.0;
   return buf[0];
}

double NormalizeLots(double lots)
{
   double vmin  = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
   double vmax  = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX);
   double vstep = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);

   if(vstep <= 0.0) vstep = 0.01;
   if(vmin  <= 0.0) vmin  = vstep;

   double v = MathFloor(lots / vstep + 0.5) * vstep;
   if(v < vmin) v = vmin;
   if(vmax > 0.0 && v > vmax) v = vmax;

   int digits = 0;
   double s = vstep;
   while(s < 1.0 && digits < 8) { s *= 10.0; digits++; }

   return NormalizeDouble(v, digits);
}

// True when this position is one the EA is allowed to touch.
bool IsManagedPosition()
{
   if(PositionGetString(POSITION_SYMBOL) != _Symbol) return false;
   if(InpManageManualTrades) return true;
   return (PositionGetInteger(POSITION_MAGIC) == InpMagicNumber);
}

bool IsHedgePosition()
{
   string c = PositionGetString(POSITION_COMMENT);
   return (StringFind(c, HEDGE_TAG) >= 0);
}

// Reads the original ticket out of a hedge's comment, 0 if absent.
ulong HedgeOwnerFromComment()
{
   string c   = PositionGetString(POSITION_COMMENT);
   int    pos = StringFind(c, HEDGE_TAG);
   if(pos < 0) return 0;
   string tail = StringSubstr(c, pos + StringLen(HEDGE_TAG));
   return (ulong)StringToInteger(tail);
}

//+------------------------------------------------------------------+
//| Commission. MQL5 keeps it on deals, not on positions, so it has  |
//| to be summed from history and then cached.                       |
//+------------------------------------------------------------------+
double LookupCommission(ulong posTicket)
{
   int n = ArraySize(gCommTicket);
   for(int i = 0; i < n; i++)
      if(gCommTicket[i] == posTicket) return gCommValue[i];

   long posID = PositionGetInteger(POSITION_IDENTIFIER);
   double comm = 0.0;

   if(HistorySelectByPosition(posID))
   {
      int deals = HistoryDealsTotal();
      for(int i = 0; i < deals; i++)
      {
         ulong d = HistoryDealGetTicket(i);
         if(d > 0) comm += HistoryDealGetDouble(d, DEAL_COMMISSION);
      }
   }

   // Only the entry commission exists while the position is open.
   // Doubling it approximates the round turn so a "profitable" close
   // is not actually a net loss once the exit is charged.
   if(InpAssumeRoundTurn) comm *= 2.0;

   ArrayResize(gCommTicket, n + 1);
   ArrayResize(gCommValue,  n + 1);
   gCommTicket[n] = posTicket;
   gCommValue[n]  = comm;

   return comm;
}

void PruneCommissionCache()
{
   int n = ArraySize(gCommTicket);
   if(n == 0) return;

   ulong  keepT[];
   double keepV[];
   int    kept = 0;

   for(int i = 0; i < n; i++)
   {
      if(PositionSelectByTicket(gCommTicket[i]))
      {
         ArrayResize(keepT, kept + 1);
         ArrayResize(keepV, kept + 1);
         keepT[kept] = gCommTicket[i];
         keepV[kept] = gCommValue[i];
         kept++;
      }
   }

   ArrayResize(gCommTicket, kept);
   ArrayResize(gCommValue,  kept);
   for(int i = 0; i < kept; i++)
   {
      gCommTicket[i] = keepT[i];
      gCommValue[i]  = keepV[i];
   }
}

// Net floating result of the currently selected position, after swap
// and (optionally) commission.
double PositionNetPL(ulong ticket)
{
   double pl = PositionGetDouble(POSITION_PROFIT) + PositionGetDouble(POSITION_SWAP);
   if(InpIncludeCommission) pl += LookupCommission(ticket);
   return pl;
}

//+------------------------------------------------------------------+
//| Trend: EMA fast vs EMA slow, optional ADX filter.                |
//| 1 = up, -1 = down, 0 = unclear.                                  |
//+------------------------------------------------------------------+
int TrendFrom(int fastHandle, int slowHandle, bool applyADX)
{
   double fast = BufferValue(fastHandle, 0);
   double slow = BufferValue(slowHandle, 0);
   if(fast == 0.0 || slow == 0.0) return 0;
   if(applyADX && InpUseADX && BufferValue(hADX, 0) < InpADXMin) return 0;
   if(fast > slow) return 1;
   if(fast < slow) return -1;
   return 0;
}

int GetTrendDirection()
{
   return TrendFrom(hFastEMA, hSlowEMA, true);
}

int GetStructureDirection()
{
   if(!InpUseHTFGate) return 0;
   return TrendFrom(hStructFast, hStructSlow, false);
}

//+------------------------------------------------------------------+
//| FVG - ported from: bullGap = low > high[2], bearGap = high < low[2]|
//| shift 0 = still-forming bar, 1 = last closed bar.                 |
//+------------------------------------------------------------------+
bool BullFVG(ENUM_TIMEFRAMES tf, int shift)
{
   if(Bars(_Symbol, tf) < shift + 3) return false;
   double lo = iLow(_Symbol, tf, shift);
   double hi = iHigh(_Symbol, tf, shift + 2);
   if(lo == 0.0 || hi == 0.0) return false;
   return (lo > hi);
}

bool BearFVG(ENUM_TIMEFRAMES tf, int shift)
{
   if(Bars(_Symbol, tf) < shift + 3) return false;
   double hi = iHigh(_Symbol, tf, shift);
   double lo = iLow(_Symbol, tf, shift + 2);
   if(lo == 0.0 || hi == 0.0) return false;
   return (hi < lo);
}

//+------------------------------------------------------------------+
//| Pivots - ported from ta.pivothigh / ta.pivotlow(pivotLR, pivotLR).|
//| Pine treats an equal neighbour as disqualifying, so the tests are |
//| strict: any neighbour at or beyond the candidate kills it.        |
//+------------------------------------------------------------------+
bool IsPivotHigh(ENUM_TIMEFRAMES tf, int shift, int lr)
{
   if(shift - lr < 0) return false;
   if(Bars(_Symbol, tf) < shift + lr + 1) return false;

   double c = iHigh(_Symbol, tf, shift);
   if(c == 0.0) return false;

   for(int i = 1; i <= lr; i++)
   {
      if(iHigh(_Symbol, tf, shift - i) >= c) return false;
      if(iHigh(_Symbol, tf, shift + i) >= c) return false;
   }
   return true;
}

bool IsPivotLow(ENUM_TIMEFRAMES tf, int shift, int lr)
{
   if(shift - lr < 0) return false;
   if(Bars(_Symbol, tf) < shift + lr + 1) return false;

   double c = iLow(_Symbol, tf, shift);
   if(c == 0.0) return false;

   for(int i = 1; i <= lr; i++)
   {
      if(iLow(_Symbol, tf, shift - i) <= c) return false;
      if(iLow(_Symbol, tf, shift + i) <= c) return false;
   }
   return true;
}

// Most recent CONFIRMED pivot: it needs lr newer bars to its right
// before it counts, which is the same lag Pine has.
double LastPivotHigh(ENUM_TIMEFRAMES tf, int lr, int maxLookback)
{
   for(int s = lr; s <= maxLookback; s++)
      if(IsPivotHigh(tf, s, lr)) return iHigh(_Symbol, tf, s);
   return 0.0;
}

double LastPivotLow(ENUM_TIMEFRAMES tf, int lr, int maxLookback)
{
   for(int s = lr; s <= maxLookback; s++)
      if(IsPivotLow(tf, s, lr)) return iLow(_Symbol, tf, s);
   return 0.0;
}

//+------------------------------------------------------------------+
//| LGB (liquidity grab) - ported from:                              |
//|   sweepBuy  = high > lastHi and close < lastHi  (grabs buy-side) |
//|   sweepSell = low  < lastLo and close > lastLo  (grabs sell-side)|
//| Both legs are same-bar, matching the Pine source.                |
//+------------------------------------------------------------------+
bool LGB_SweepBuy(ENUM_TIMEFRAMES tf, int shift, double lastHi)
{
   if(lastHi == 0.0) return false;
   return (iHigh(_Symbol, tf, shift) > lastHi && iClose(_Symbol, tf, shift) < lastHi);
}

bool LGB_SweepSell(ENUM_TIMEFRAMES tf, int shift, double lastLo)
{
   if(lastLo == 0.0) return false;
   return (iLow(_Symbol, tf, shift) < lastLo && iClose(_Symbol, tf, shift) > lastLo);
}

//+------------------------------------------------------------------+
//| Signal refresh. The pivot hunt walks up to 200 bars, so it runs   |
//| once per signal-timeframe bar rather than on every tick.          |
//+------------------------------------------------------------------+
void BuildScanList()
{
   gScanCount = 0;

   gScanTF[gScanCount++] = InpScanTF1;
   if(InpUseScanTF2 && gScanCount < MAX_SCAN_TF) gScanTF[gScanCount++] = InpScanTF2;
   if(InpUseScanTF3 && gScanCount < MAX_SCAN_TF) gScanTF[gScanCount++] = InpScanTF3;
   if(InpUseScanTF4 && gScanCount < MAX_SCAN_TF) gScanTF[gScanCount++] = InpScanTF4;

   for(int i = 0; i < MAX_SCAN_TF; i++)
   {
      gScanLastBar[i]   = 0;
      gScanBullFVG[i]   = false;
      gScanBearFVG[i]   = false;
      gScanSweepBuy[i]  = false;
      gScanSweepSell[i] = false;
   }
}

void RefreshSignalsIfNeeded()
{
   int window = MathMax(1, InpSignalWindowBars);

   for(int i = 0; i < gScanCount; i++)
   {
      ENUM_TIMEFRAMES tf = gScanTF[i];

      // Each timeframe is recomputed only when IT prints a new bar. That is
      // also why a higher timeframe naturally holds its signal for longer:
      // a 15-minute grab stays live for the whole 15 minutes, which is the
      // "wait, and the original flow resumes" behaviour.
      datetime t = iTime(_Symbol, tf, 0);
      if(t == 0 || t == gScanLastBar[i]) continue;
      gScanLastBar[i] = t;

      double lastHi = LastPivotHigh(tf, InpPivotLR, InpPivotMaxLookback);
      double lastLo = LastPivotLow (tf, InpPivotLR, InpPivotMaxLookback);

      bool bull = false, bear = false, sBuy = false, sSell = false;

      for(int sh = 1; sh <= window; sh++)
      {
         if(BullFVG(tf, sh))               bull  = true;
         if(BearFVG(tf, sh))               bear  = true;
         if(LGB_SweepBuy (tf, sh, lastHi)) sBuy  = true;
         if(LGB_SweepSell(tf, sh, lastLo)) sSell = true;
      }

      gScanBullFVG[i]   = bull;
      gScanBearFVG[i]   = bear;
      gScanSweepBuy[i]  = sBuy;
      gScanSweepSell[i] = sSell;

      if(bull || bear || sBuy || sSell)
         Log(StringFormat("%s signals: bullFVG=%d bearFVG=%d sweepBuy=%d sweepSell=%d",
                          EnumToString(tf), bull, bear, sBuy, sSell));
   }
}

//--- Aggregates. A signal on ANY scanned timeframe counts.
bool AnyBullFVG()   { for(int i=0;i<gScanCount;i++) if(gScanBullFVG[i])   return true; return false; }
bool AnyBearFVG()   { for(int i=0;i<gScanCount;i++) if(gScanBearFVG[i])   return true; return false; }
bool AnySweepBuy()  { for(int i=0;i<gScanCount;i++) if(gScanSweepBuy[i])  return true; return false; }
bool AnySweepSell() { for(int i=0;i<gScanCount;i++) if(gScanSweepSell[i]) return true; return false; }

// True when some timeframe is showing a signal that favours this direction,
// which is the reason to sit through the drawdown instead of hedging it.
// The reason string names WHICH timeframe, so the log shows why it held.
bool FavourableSignal(long posType, string &reason)
{
   reason = "";

   for(int i = 0; i < gScanCount; i++)
   {
      bool   hit  = false;
      string what = "";

      if(posType == POSITION_TYPE_BUY)
      {
         if(gScanSweepSell[i])    { hit = true; what = "sell-side sweep"; }
         else if(gScanBullFVG[i]) { hit = true; what = "bull FVG"; }
      }
      else
      {
         if(gScanSweepBuy[i])     { hit = true; what = "buy-side sweep"; }
         else if(gScanBearFVG[i]) { hit = true; what = "bear FVG"; }
      }

      if(hit)
      {
         reason = StringFormat("%s on %s", what, EnumToString(gScanTF[i]));
         return true;
      }
   }
   return false;
}

//+------------------------------------------------------------------+
//| Daily loss cap, reset on the broker's date rolling over rather    |
//| than 24h after the EA happened to start.                          |
//+------------------------------------------------------------------+
void ResetDailyBaseline()
{
   MqlDateTime dt;
   TimeToStruct(TimeCurrent(), dt);
   gDayStartEquity = AccountInfoDouble(ACCOUNT_EQUITY);
   gDayStartDay    = dt.day;
   gDayStartMonth  = dt.mon;
   gDayStartYear   = dt.year;
}

void UpdateDailyBaseline()
{
   MqlDateTime dt;
   TimeToStruct(TimeCurrent(), dt);
   if(dt.day != gDayStartDay || dt.mon != gDayStartMonth || dt.year != gDayStartYear)
   {
      Log(StringFormat("Broker date changed. Daily loss baseline reset to %.2f",
                       AccountInfoDouble(ACCOUNT_EQUITY)));
      ResetDailyBaseline();
   }
}

bool DailyLossCapHit()
{
   if(InpMaxDailyLossUSD <= 0.0) return false;
   double loss = gDayStartEquity - AccountInfoDouble(ACCOUNT_EQUITY);
   return (loss >= InpMaxDailyLossUSD);
}

//+------------------------------------------------------------------+
//| Total open volume the EA is responsible for.                      |
//+------------------------------------------------------------------+
double OpenVolume()
{
   double vol = 0.0;
   for(int i = PositionsTotal() - 1; i >= 0; i--)
   {
      ulong ticket = PositionGetTicket(i);
      if(ticket == 0) continue;
      if(!PositionSelectByTicket(ticket)) continue;
      if(!IsManagedPosition()) continue;
      vol += PositionGetDouble(POSITION_VOLUME);
   }
   return vol;
}

bool VolumeCapAllows(double extra)
{
   if(InpMaxTotalVolume <= 0.0) return true;
   return (OpenVolume() + extra <= InpMaxTotalVolume + 0.0000001);
}

//+------------------------------------------------------------------+
//| Chain map. A hedge carries HDG#<original ticket> in its comment,  |
//| so pairs are rediscovered from live positions on every tick and   |
//| survive a restart or recompile without any saved state.           |
//+------------------------------------------------------------------+
void BuildChains()
{
   ArrayResize(gChainHedge, 0);
   ArrayResize(gChainOwner, 0);

   for(int i = PositionsTotal() - 1; i >= 0; i--)
   {
      ulong ticket = PositionGetTicket(i);
      if(ticket == 0) continue;
      if(!PositionSelectByTicket(ticket)) continue;
      if(!IsManagedPosition()) continue;
      if(!IsHedgePosition()) continue;

      ulong owner = HedgeOwnerFromComment();
      if(owner == 0) continue;

      // Only a pair whose BOTH legs are still open counts as a chain.
      // If the original is gone the hedge is orphaned: it falls back to
      // standalone management (its own profit target and candle-close SL)
      // rather than being force-closed at whatever it happens to sit at.
      if(!PositionSelectByTicket(owner))
      {
         if(ticket != gLastOrphanLogged)
         {
            gLastOrphanLogged = ticket;
            LogAlways(StringFormat(
               "ORPHAN HEDGE #%I64u: original #%I64u is gone. "
               "Falling back to standalone management.", ticket, owner));
         }
         continue;
      }

      // Guard against a comment that points somewhere unexpected.
      if(PositionGetString(POSITION_SYMBOL) != _Symbol) continue;

      int n = ArraySize(gChainHedge);
      ArrayResize(gChainHedge, n + 1);
      ArrayResize(gChainOwner, n + 1);
      gChainHedge[n] = ticket;
      gChainOwner[n] = owner;
   }
}

ulong FindHedgeFor(ulong originalTicket)
{
   for(int i = 0; i < ArraySize(gChainOwner); i++)
      if(gChainOwner[i] == originalTicket) return gChainHedge[i];
   return 0;
}

bool IsPartOfChain(ulong ticket)
{
   for(int i = 0; i < ArraySize(gChainHedge); i++)
      if(gChainHedge[i] == ticket || gChainOwner[i] == ticket) return true;
   return false;
}

//+------------------------------------------------------------------+
//| Order helpers with result checking                                |
//+------------------------------------------------------------------+
bool ClosePositionChecked(ulong ticket, string why)
{
   if(!PositionSelectByTicket(ticket)) return false;

   if(trade.PositionClose(ticket))
   {
      LogAlways(StringFormat("CLOSED #%I64u (%s). retcode=%u",
                             ticket, why, trade.ResultRetcode()));
      return true;
   }

   LogAlways(StringFormat("CLOSE FAILED #%I64u (%s). retcode=%u %s",
                          ticket, why, trade.ResultRetcode(),
                          trade.ResultRetcodeDescription()));
   return false;
}

//+------------------------------------------------------------------+
//| Candle-close stop loss.                                           |
//| Deliberately applies to manual trades too (that is the design).   |
//| It skips anything inside a chain: a chained pair is governed by   |
//| the basket target and the basket floor, and closing one leg on    |
//| its own would leave the other one naked.                          |
//+------------------------------------------------------------------+
void CheckCandleCloseSL()
{
   double prevClose = iClose(_Symbol, PERIOD_CURRENT, 1);
   if(prevClose == 0.0) return;

   ulong  toClose[];
   string reasons[];
   int    count = 0;

   for(int i = PositionsTotal() - 1; i >= 0; i--)
   {
      ulong ticket = PositionGetTicket(i);
      if(ticket == 0) continue;
      if(!PositionSelectByTicket(ticket)) continue;
      if(!IsManagedPosition()) continue;
      if(IsPartOfChain(ticket)) continue;

      long   type      = PositionGetInteger(POSITION_TYPE);
      double openPrice = PositionGetDouble(POSITION_PRICE_OPEN);
      bool   hit       = false;

      if(type == POSITION_TYPE_BUY  && prevClose <= openPrice - InpSLDistanceUSD) hit = true;
      if(type == POSITION_TYPE_SELL && prevClose >= openPrice + InpSLDistanceUSD) hit = true;

      if(hit)
      {
         ArrayResize(toClose, count + 1);
         ArrayResize(reasons, count + 1);
         toClose[count] = ticket;
         reasons[count] = StringFormat("candle-close SL, open %.2f prevClose %.2f",
                                       openPrice, prevClose);
         count++;
      }
   }

   for(int i = 0; i < count; i++)
      ClosePositionChecked(toClose[i], reasons[i]);
}

//+------------------------------------------------------------------+
//| Chained pairs: one combined decision for both legs.                |
//| The pair closes together once the combined net result clears the   |
//| basket target, or gets force-closed at the basket floor.           |
//+------------------------------------------------------------------+
void ManageChains()
{
   int chains = ArraySize(gChainHedge);

   for(int i = chains - 1; i >= 0; i--)
   {
      ulong hedgeT = gChainHedge[i];
      ulong ownerT = gChainOwner[i];

      if(!PositionSelectByTicket(ownerT)) continue;
      double ownerPL = PositionNetPL(ownerT);

      if(!PositionSelectByTicket(hedgeT)) continue;
      double hedgePL = PositionNetPL(hedgeT);

      double basket = ownerPL + hedgePL;

      if(basket > InpBasketTargetUSD)
      {
         LogAlways(StringFormat(
            "BASKET CLOSE (target): original #%I64u %.2f + hedge #%I64u %.2f = %.2f",
            ownerT, ownerPL, hedgeT, hedgePL, basket));
         ClosePositionChecked(hedgeT, "basket target");
         ClosePositionChecked(ownerT, "basket target");
         continue;
      }

      if(InpBasketMaxLossUSD > 0.0 && basket <= -InpBasketMaxLossUSD)
      {
         LogAlways(StringFormat(
            "BASKET STOP (floor %.2f): original #%I64u %.2f + hedge #%I64u %.2f = %.2f",
            InpBasketMaxLossUSD, ownerT, ownerPL, hedgeT, hedgePL, basket));
         ClosePositionChecked(hedgeT, "basket max loss");
         ClosePositionChecked(ownerT, "basket max loss");
      }
   }
}

//+------------------------------------------------------------------+
//| Standalone positions: each one takes its own small profit.        |
//| Anything inside a chain is skipped, it belongs to ManageChains.   |
//+------------------------------------------------------------------+
void ManageStandalonePositions()
{
   ulong toClose[];
   long  closedType[];
   int   count = 0;

   for(int i = PositionsTotal() - 1; i >= 0; i--)
   {
      ulong ticket = PositionGetTicket(i);
      if(ticket == 0) continue;
      if(!PositionSelectByTicket(ticket)) continue;
      if(!IsManagedPosition()) continue;
      if(IsPartOfChain(ticket)) continue;

      long   type = PositionGetInteger(POSITION_TYPE);
      double pl   = PositionNetPL(ticket);

      if(pl >= InpProfitTargetUSD)
      {
         ArrayResize(toClose,   count + 1);
         ArrayResize(closedType, count + 1);
         toClose[count]    = ticket;
         closedType[count] = type;
         count++;
      }
   }

   for(int i = 0; i < count; i++)
   {
      if(ClosePositionChecked(toClose[i], "profit target"))
      {
         if(closedType[i] == POSITION_TYPE_BUY)  gWaitPullbackBuy  = true;
         if(closedType[i] == POSITION_TYPE_SELL) gWaitPullbackSell = true;
      }
   }
}

//+------------------------------------------------------------------+
//| Hedge decision, evaluated once per bar.                           |
//|                                                                   |
//| Hold when a sweep or FVG has fired in the position's OWN favour:  |
//| that is the "LG tag = don't hedge" rule, the drawdown looks        |
//| temporary. Hedge only when the trend has actually flipped against  |
//| the position and no favourable signal is present.                  |
//+------------------------------------------------------------------+
void CheckHedgeDecisions()
{
   if(DailyLossCapHit()) return;

   int trend = GetTrendDirection();
   if(trend == 0) return;

   int structure = GetStructureDirection();

   ulong  needHedge[];
   double needVolume[];
   long   needType[];
   int    count = 0;

   for(int i = PositionsTotal() - 1; i >= 0; i--)
   {
      ulong ticket = PositionGetTicket(i);
      if(ticket == 0) continue;
      if(!PositionSelectByTicket(ticket)) continue;
      if(!IsManagedPosition()) continue;

      // 4.3: a hedge is never itself hedged. Single level only.
      if(IsHedgePosition()) continue;

      // Already has a live hedge -> nothing to decide.
      if(FindHedgeFor(ticket) != 0) continue;

      long   type = PositionGetInteger(POSITION_TYPE);
      double pl   = PositionNetPL(ticket);
      if(pl >= 0.0) continue;

      bool trendFlipped =
         (type == POSITION_TYPE_BUY  && trend == -1) ||
         (type == POSITION_TYPE_SELL && trend ==  1);

      if(!trendFlipped) continue;

      // A sweep or FVG back in OUR favour, on ANY scanned timeframe, means
      // the drawdown is a pullback rather than a trend change. Hold.
      string why = "";
      if(FavourableSignal(type, why))
      {
         Log(StringFormat(
            "HOLD #%I64u (%.2f): trend flipped on %s, but %s is still live. "
            "Treating this as a pullback, not a trend change.",
            ticket, pl, EnumToString(InpTrendTF), why));
         continue;
      }

      // Nothing favourable left anywhere: the grab or gap has finished and
      // the trend change is the real explanation. This is the hedge case.
      Log(StringFormat(
         "HEDGE CASE #%I64u (%.2f): trend flipped and no favourable signal "
         "remains on any scanned timeframe.", ticket, pl));

      // Optional higher-timeframe agreement before committing to a hedge.
      if(InpUseHTFGate && structure != 0 && structure != trend)
      {
         Log(StringFormat(
            "HOLD #%I64u (%.2f): %s structure (%d) disagrees with trend (%d)",
            ticket, pl, EnumToString(InpStructureTF), structure, trend));
         continue;
      }

      // Re-select: LookupCommission touched history selection in between.
      if(!PositionSelectByTicket(ticket)) continue;
      double vol = PositionGetDouble(POSITION_VOLUME);

      ArrayResize(needHedge,  count + 1);
      ArrayResize(needVolume, count + 1);
      ArrayResize(needType,   count + 1);
      needHedge[count]  = ticket;
      needVolume[count] = vol;
      needType[count]   = type;
      count++;
   }

   for(int i = 0; i < count; i++)
      OpenHedgeFor(needHedge[i], needVolume[i], needType[i]);
}

//+------------------------------------------------------------------+
//| Open a hedge for one specific position.                           |
//| 4.5: direction comes from the position being hedged, never from   |
//| "current trend" in isolation, so it stays unambiguous once more   |
//| than one position can be open.                                    |
//+------------------------------------------------------------------+
void OpenHedgeFor(ulong originalTicket, double originalVolume, long originalType)
{
   double lots = NormalizeLots(originalVolume * InpHedgeLotMultiple);

   if(!VolumeCapAllows(lots))
   {
      Log(StringFormat(
         "HEDGE SKIPPED for #%I64u: volume cap. open=%.2f + hedge=%.2f > cap=%.2f",
         originalTicket, OpenVolume(), lots, InpMaxTotalVolume));
      return;
   }

   string comment = HEDGE_TAG + IntegerToString((long)originalTicket);
   bool   ok      = false;

   if(originalType == POSITION_TYPE_BUY)
   {
      double price = SymbolInfoDouble(_Symbol, SYMBOL_BID);
      ok = trade.Sell(lots, _Symbol, price, 0.0, 0.0, comment);
   }
   else
   {
      double price = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
      ok = trade.Buy(lots, _Symbol, price, 0.0, 0.0, comment);
   }

   if(ok)
   {
      LogAlways(StringFormat(
         "HEDGE OPENED %.2f lots against #%I64u (%s). retcode=%u",
         lots, originalTicket,
         originalType == POSITION_TYPE_BUY ? "orig BUY -> hedge SELL"
                                           : "orig SELL -> hedge BUY",
         trade.ResultRetcode()));
   }
   else
   {
      // No flag is set on failure, so the next bar simply tries again.
      LogAlways(StringFormat(
         "HEDGE FAILED against #%I64u. retcode=%u %s",
         originalTicket, trade.ResultRetcode(), trade.ResultRetcodeDescription()));
   }
}

//+------------------------------------------------------------------+
bool PullbackConfirmed(bool forBuy)
{
   double ema     = BufferValue(hFastEMA, 1);
   double closeC1 = iClose(_Symbol, InpScanTF1, 1);
   double openC1  = iOpen (_Symbol, InpScanTF1, 1);
   double lowC1   = iLow  (_Symbol, InpScanTF1, 1);
   double highC1  = iHigh (_Symbol, InpScanTF1, 1);

   if(ema == 0.0 || closeC1 == 0.0) return false;

   if(forBuy)
      return (lowC1 <= ema) && (closeC1 > openC1) && (closeC1 > ema);

   return (highC1 >= ema) && (closeC1 < openC1) && (closeC1 < ema);
}

//+------------------------------------------------------------------+
//| Optional auto-entry, matching the script's "Confirm + (FVG or     |
//| LGB)" entry mode. OFF by default.                                 |
//+------------------------------------------------------------------+
void CheckAutoEntry()
{
   if(!InpEnableAutoEntry) return;
   if(DailyLossCapHit()) return;

   double lots = NormalizeLots(InpLotSize);
   if(!VolumeCapAllows(lots)) return;

   int trend = GetTrendDirection();
   if(trend == 0) return;

   if(InpUseHTFGate)
   {
      int structure = GetStructureDirection();
      if(structure != 0 && structure != trend) return;
   }

   bool momoUp = AnyBullFVG() || AnySweepSell();
   bool momoDn = AnyBearFVG() || AnySweepBuy();

   if(trend == 1 && momoUp)
   {
      if(gWaitPullbackBuy && InpRequireMA20Pullback && !PullbackConfirmed(true)) return;
      double price = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
      double sl    = InpCandleCloseSL ? 0.0 : price - InpSLDistanceUSD;
      if(trade.Buy(lots, _Symbol, price, sl, 0.0, "auto-buy"))
      {
         LogAlways(StringFormat("AUTO BUY %.2f lots. retcode=%u", lots, trade.ResultRetcode()));
         gWaitPullbackBuy = false;
      }
      else
      {
         LogAlways(StringFormat("AUTO BUY FAILED. retcode=%u %s",
                                trade.ResultRetcode(), trade.ResultRetcodeDescription()));
      }
   }
   else if(trend == -1 && momoDn)
   {
      if(gWaitPullbackSell && InpRequireMA20Pullback && !PullbackConfirmed(false)) return;
      double price = SymbolInfoDouble(_Symbol, SYMBOL_BID);
      double sl    = InpCandleCloseSL ? 0.0 : price + InpSLDistanceUSD;
      if(trade.Sell(lots, _Symbol, price, sl, 0.0, "auto-sell"))
      {
         LogAlways(StringFormat("AUTO SELL %.2f lots. retcode=%u", lots, trade.ResultRetcode()));
         gWaitPullbackSell = false;
      }
      else
      {
         LogAlways(StringFormat("AUTO SELL FAILED. retcode=%u %s",
                                trade.ResultRetcode(), trade.ResultRetcodeDescription()));
      }
   }
}

//+------------------------------------------------------------------+
void OnTick()
{
   if(gInitFailed) return;

   UpdateDailyBaseline();
   RefreshSignalsIfNeeded();
   BuildChains();

   // Profit decisions run on every tick so a small target is not missed.
   ManageChains();
   ManageStandalonePositions();

   // Structural decisions run once per bar: the signals they read only
   // change on a bar close, and gating them here also stops a rejected
   // hedge from being retried on every single tick.
   if(IsNewBar())
   {
      if(InpCandleCloseSL) CheckCandleCloseSL();
      CheckHedgeDecisions();
      CheckAutoEntry();
      PruneCommissionCache();
   }
}
