#!/usr/bin/env python3
"""Koshish #70 (C1, 1 Nov 2026) - local (non-US) chutti se pehle wala din: 7 index ke waqiat (sirf CALENDAR, koi qeemat nahi).
Qaida: docs/purana-haal.md grep "Koshish #70 qaida" (judge daur 1, docs/research/daur1-judge.md).
Output: har index ki entry (P-1) > exit (P) list (Pine ke liye string) + k = sqrt(ausat trade fi entry-tareekh, 2005-2018).

  pip install exchange_calendars==4.13.2 ; python3 tools/c1_calendar.py [--pine]
"""
import bisect
import datetime as D
import sys

import exchange_calendars as xc
import pandas as pd

from ftmo60 import hol

# ad-hoc (pehle se maloom NAHI: typhoon / rainstorm / system band) - exchange_calendars adhoc list se haath se chune
UNSCHED = {'XHKG': ['2008-08-06', '2008-08-22', '2011-09-29', '2013-08-14', '2016-08-02', '2016-10-21', '2017-08-23',
                    '2020-10-13', '2021-10-13', '2023-07-17', '2024-09-06'],
           'XTKS': ['2020-10-01']}
IDX = [('DAX', 'XETR'), ('UKX', 'XLON'), ('PX1', 'XPAR'), ('SX5E', 'TARGET'), ('NI225', 'XTKS'), ('XJO', 'XASX'), ('HSI', 'XHKG')]
A, B = D.date(2005, 1, 1), D.date(2026, 12, 31)


def easter(y):
    a, b, c = y % 19, y // 100, y % 100
    d, e = b // 4, b % 4
    f = (b + 8) // 25
    g = (b - f + 1) // 3
    h = (19 * a + b - d - g + 15) % 30
    i, k = c // 4, c % 4
    l = (32 + 2 * e + 2 * i - h - k) % 7
    m = (a + 11 * h + 22 * l) // 451
    n = h + l - 7 * m + 114
    return D.date(y, n // 31, n % 31 + 1)


def sessions(code):
    days = [d.date() for d in pd.bdate_range('2004-06-01', '2027-01-31')]
    if code == 'TARGET':                      # Jan 1, Good Friday, Easter Monday, May 1, Dec 25, Dec 26
        cl = set()
        for y in range(2004, 2028):
            e = easter(y)
            cl |= {D.date(y, 1, 1), e - D.timedelta(days=2), e + D.timedelta(days=1), D.date(y, 5, 1), D.date(y, 12, 25), D.date(y, 12, 26)}
        return [d for d in days if d not in cl]
    cal = xc.get_calendar(code, start='2004-06-01', end='2027-02-15')
    ss = set(pd.DatetimeIndex(cal.sessions_in_range(cal.first_session, cal.last_session)).date)
    ss |= {D.date.fromisoformat(x) for x in UNSCHED.get(code, [])}       # ad-hoc band din = pehle se session samjho
    return sorted(d for d in days if d in ss)


def events(code):
    sd = sessions(code)
    ss = set(sd)
    out = []
    for i in range(2, len(sd) - 1):
        p, nxt = sd[i], sd[i + 1]
        gap = [d for d in pd.bdate_range(p + D.timedelta(days=1), nxt - D.timedelta(days=1))]
        if not gap:                                   # P ke baad koi weekday bandish nahi
            continue
        lo, hi = p - D.timedelta(days=4), nxt + D.timedelta(days=1)
        if any(hol(lo + D.timedelta(days=j)) for j in range((hi - lo).days + 1)):
            continue                                  # NYSE chutti qareeb = #59 / #67 ka ilaqa
        if A <= sd[i - 1] <= B:
            out.append((sd[i - 1], p))
    return out


def main():
    ev = {nm: events(code) for nm, code in IDX}
    cnt = {}
    for nm, e in ev.items():
        for a, _ in e:
            if a.year <= 2018:
                cnt[a] = cnt.get(a, 0) + 1
    k = (sum(cnt.values()) / len(cnt)) ** 0.5
    if '--pine' in sys.argv:
        for nm, e in ev.items():
            print(f'// {nm}: {len(e)}')
            print(f'string EV_{nm} = "' + ','.join(f'{a:%Y%m%d}>{b:%Y%m%d}' for a, b in e) + ',"')
        print(f'ADJ = {k:.3f}')
        return
    for nm, e in ev.items():
        t = [x for x in e if x[0].year <= 2018]
        print(f'{nm:5s} 2005-18: {len(t):3d} ({len(t) / 14:.1f}/saal)  kul 2005-26: {len(e)}  misaal: {[(str(a), str(b)) for a, b in t[:3]]}')
    print(f'k = sqrt({sum(cnt.values())}/{len(cnt)}) = {k:.3f}')


if __name__ == '__main__':
    main()
