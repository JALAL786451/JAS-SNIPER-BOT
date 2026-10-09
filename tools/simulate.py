#!/usr/bin/env python3
"""Line-for-line Python port of the Pine logic, so the ALGORITHM can be tested
even though the Pine compiler only exists inside TradingView.

Mirrors xauusd_combined_indicator.pine: same EMA bias, same pivot/BOS/CHoCH
state machine, same FVG lifecycle, same entry gating. If an invariant breaks
here, it breaks on the chart too.
"""
import random


class Sim:
    def __init__(self, fast=20, slow=50, swing=10, atr_len=14,
                 fvg_min_atr=0.25, choch_valid=25, cooldown=8,
                 grace=0, one_per_choch=True):
        self.fast, self.slow, self.swing, self.atr_len = fast, slow, swing, atr_len
        self.fvg_min_atr, self.choch_valid = fvg_min_atr, choch_valid
        self.cooldown, self.grace, self.one_per_choch = cooldown, grace, one_per_choch
        self.reset()

    def reset(self):
        self.o, self.h, self.l, self.c = [], [], [], []
        self.ema_f = self.ema_s = None
        self.atr = None
        self.swing_high = self.swing_high_bar = None
        self.swing_low = self.swing_low_bar = None
        self.sh_broken = self.sl_broken = True
        self.sh_swept = self.sl_swept = True
        self.trend = 0
        self.pending_dir, self.pending_bar = 0, None
        self.choch_dir, self.choch_bar = 0, None
        self.obs, self.fvgs = [], []
        self.last_signal_bar, self.signalled_choch = None, None
        self.events = []

    # -- helpers -------------------------------------------------------------
    def _ema(self, prev, price, length):
        a = 2.0 / (length + 1)
        return price if prev is None else (price - prev) * a + prev

    def _pivot(self, series, n, high):
        """ta.pivothigh / ta.pivotlow: confirmed n bars after the fact."""
        i = len(series) - 1 - n
        if i - n < 0:
            return None
        v = series[i]
        for j in range(i - n, i + n + 1):
            if j == i:
                continue
            if high and series[j] >= v:
                return None
            if not high and series[j] <= v:
                return None
        return v

    # -- one bar -------------------------------------------------------------
    def step(self, o, h, l, c):
        self.o.append(o); self.h.append(h); self.l.append(l); self.c.append(c)
        i = len(self.c) - 1

        # ATR (Wilder, as ta.atr)
        if i == 0:
            tr = h - l
            self.atr = tr
        else:
            pc = self.c[i - 1]
            tr = max(h - l, abs(h - pc), abs(l - pc))
            self.atr = (self.atr * (self.atr_len - 1) + tr) / self.atr_len

        # ---- MODULE 1: EMA bias
        self.ema_f = self._ema(self.ema_f, c, self.fast)
        self.ema_s = self._ema(self.ema_s, c, self.slow)
        ema_top, ema_bot = max(self.ema_f, self.ema_s), min(self.ema_f, self.ema_s)
        bias = 1 if c > ema_top else (-1 if c < ema_bot else 0)
        bias_bull, bias_bear = bias == 1, bias == -1

        # ---- MODULE 2: swings
        ph = self._pivot(self.h, self.swing, True)
        pl = self._pivot(self.l, self.swing, False)
        if ph is not None:
            self.swing_high, self.swing_high_bar = ph, i - self.swing
            self.sh_broken = self.sh_swept = False
        if pl is not None:
            self.swing_low, self.swing_low_bar = pl, i - self.swing
            self.sl_broken = self.sl_swept = False

        bos_bull = bos_bear = choch_bull = choch_bear = False
        if self.swing_high is not None and not self.sh_broken and c > self.swing_high:
            if self.trend <= 0:
                choch_bull = True
            else:
                bos_bull = True
            self.trend, self.sh_broken = 1, True
        if self.swing_low is not None and not self.sl_broken and c < self.swing_low:
            if self.trend >= 0:
                choch_bear = True
            else:
                bos_bear = True
            self.trend, self.sl_broken = -1, True

        broke_up, broke_down = bos_bull or choch_bull, bos_bear or choch_bear

        # sweeps (must not fire when the level was actually broken)
        if (not self.sh_swept and not self.sh_broken and self.swing_high is not None
                and h > self.swing_high and c < self.swing_high):
            self.sh_swept = True
            self.events.append(('sweep_high', i))
        if (not self.sl_swept and not self.sl_broken and self.swing_low is not None
                and l < self.swing_low and c > self.swing_low):
            self.sl_swept = True
            self.events.append(('sweep_low', i))

        # order blocks
        def push_ob(bull):
            off = None
            limit = min(30, i)
            for k in range(1, limit + 1):
                opp = self.c[i - k] < self.o[i - k] if bull else self.c[i - k] > self.o[i - k]
                if opp:
                    off = k
                    break
            if off is not None:
                self.obs.append({'top': self.h[i - off], 'bot': self.l[i - off],
                                 'bull': bull, 'mitigated': False})
                if len(self.obs) > 6:
                    self.obs.pop(0)

        if broke_up:
            push_ob(True)
        if broke_down:
            push_ob(False)
        for ob in self.obs:
            if not ob['mitigated']:
                if (c < ob['bot']) if ob['bull'] else (c > ob['top']):
                    ob['mitigated'] = True

        # ---- MODULE 3: FVG
        min_gap = self.atr * self.fvg_min_atr
        if i >= 2:
            if l > self.h[i - 2] and self.c[i - 1] > self.o[i - 1] and (l - self.h[i - 2]) >= min_gap:
                self.fvgs.append({'top': l, 'bot': self.h[i - 2], 'left': i - 2,
                                  'bull': True, 'state': 0, 'dead': False, 'born': i})
                if len(self.fvgs) > 12:
                    self.fvgs.pop(0)
            if h < self.l[i - 2] and self.c[i - 1] < self.o[i - 1] and (self.l[i - 2] - h) >= min_gap:
                self.fvgs.append({'top': self.l[i - 2], 'bot': h, 'left': i - 2,
                                  'bull': False, 'state': 0, 'dead': False, 'born': i})
                if len(self.fvgs) > 12:
                    self.fvgs.pop(0)

        in_bull_fvg = in_bear_fvg = False
        open_fvgs = 0
        for f in self.fvgs:
            if f['dead']:
                continue
            prev = f['state']
            matured = i - f['left'] > 2
            if matured:
                if f['bull']:
                    if l <= f['bot']:
                        f['state'] = 2
                    elif l <= f['top'] and f['state'] == 0:
                        f['state'] = 1
                else:
                    if h >= f['top']:
                        f['state'] = 2
                    elif h >= f['bot'] and f['state'] == 0:
                        f['state'] = 1
            if f['state'] < prev:
                raise AssertionError(f'bar {i}: FVG state went backwards')
            if f['state'] < 2:
                open_fvgs += 1
                if matured and l <= f['top'] and h >= f['bot']:
                    if f['bull']:
                        in_bull_fvg = True
                    else:
                        in_bear_fvg = True

        # ---- MODULE 4: CHoCH confirmation + entry
        if choch_bull:
            self.pending_dir, self.pending_bar = 1, i
        if choch_bear:
            self.pending_dir, self.pending_bar = -1, i

        if self.pending_dir != 0 and self.pending_bar is not None:
            if i - self.pending_bar > self.grace:
                self.pending_dir = 0
            elif self.pending_dir == 1 and bias_bull:
                self.choch_dir, self.choch_bar, self.pending_dir = 1, i, 0
            elif self.pending_dir == -1 and bias_bear:
                self.choch_dir, self.choch_bar, self.pending_dir = -1, i, 0

        age = None if self.choch_bar is None else i - self.choch_bar
        fresh = age is not None and age <= self.choch_valid
        choch_bull_active = fresh and self.choch_dir == 1
        choch_bear_active = fresh and self.choch_dir == -1

        raw_buy = bias_bull and choch_bull_active and in_bull_fvg
        raw_sell = bias_bear and choch_bear_active and in_bear_fvg

        cooldown_ok = (self.last_signal_bar is None
                       or i - self.last_signal_bar >= self.cooldown)
        choch_unused = (not self.one_per_choch or self.signalled_choch is None
                        or self.signalled_choch != self.choch_bar)

        buy = raw_buy and cooldown_ok and choch_unused
        sell = raw_sell and cooldown_ok and choch_unused
        if buy or sell:
            self.last_signal_bar, self.signalled_choch = i, self.choch_bar
            self.events.append(('BUY' if buy else 'SELL', i))

        return {
            'i': i, 'bias': bias, 'bos_bull': bos_bull, 'bos_bear': bos_bear,
            'choch_bull': choch_bull, 'choch_bear': choch_bear,
            'choch_active': self.choch_dir if fresh else 0,
            'in_bull_fvg': in_bull_fvg, 'in_bear_fvg': in_bear_fvg,
            'open_fvgs': open_fvgs, 'buy': buy, 'sell': sell, 'trend': self.trend,
        }
