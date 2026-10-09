#!/usr/bin/env python3
"""JasBasketEA_BTC.mq5 ko JasBasketEA.mq5 se banata hai.

Gold wali file asal hai. BTC wali sirf uski nakal hai jis mein paise wale
number 100 se taqseem hain, kyunke BTC ki 0.01 lot gold ki 0.01 lot se
sau guna kam hilti hai (statement se naapa: gold 100 USC per $1 per lot,
BTC 1.0). Magic number bhi alag hai taake dono ek doosre ki lots na ginen.

Chalane ka tareeqa:  python3 tools/make_btc.py
"""
import re, sys, pathlib

SRC = pathlib.Path("JasBasketEA.mq5")
DST = pathlib.Path("JasBasketEA_BTC.mq5")

# input ka naam -> BTC wali value.  Gold wali value comment mein likhi jayegi.
CHANGES = {
    "InpCloseAllProfit": "0.5",
    "InpLegProfit":      "0.14",
    "InpPairMinProfit":  "0.05",
    "InpMagic":          "20260929",
}

def main():
    if not SRC.exists():
        sys.exit("JasBasketEA.mq5 nahi mili")
    t = SRC.read_text()

    done = {}
    def swap(m):
        name = m.group("name")
        if name not in CHANGES:
            return m.group(0)
        old, new = m.group("val"), CHANGES[name]
        done[name] = (old, new)
        cmt = (m.group("cmt") or "").lstrip("/ ").strip()
        tail = ("  |  " + cmt) if cmt else ""
        return "%s%s%s%s// GOLD par: %s%s" % (
            m.group("head"), name, m.group("gap"), new + ";" + " " * 3,
            old.strip(), tail)

    pat = re.compile(
        r"(?P<head>input\s+\w+\s+)(?P<name>\w+)(?P<gap>\s*=\s*)(?P<val>[^;]+);[ \t]*(?P<cmt>//[^\n]*)?")
    t = pat.sub(swap, t)

    missing = [k for k in CHANGES if k not in done]
    if missing:
        sys.exit("ye input nahi mile: " + ", ".join(missing))

    # naam aur build ki nishani
    t = t.replace('#define EA_BUILD "', '#define EA_BUILD "btc-', 1)
    t = re.sub(r'^//===  BUILD (\S+)', lambda m: "//===  BUILD btc-" + m.group(1), t,
               count=1, flags=re.M)
    t = t.replace("JasBasketEA.mq5", "JasBasketEA_BTC.mq5")
    t = t.replace("=== JAS BASKET EA  ", "=== JAS BASKET EA (BTC)  ")
    t = t.replace(
        "//|  Jalal ki apni basket method - machine par, uski ghaltiyon ke     |",
        "//|  BTC ke liye. JasBasketEA.mq5 se KHUD BANI hai - ise haath se      |\n"
        "//|  mat badlein. Gold wali file badal kar tools/make_btc.py chalayein.|")

    DST.write_text(t)
    print("bana:", DST)
    for k, (o, n) in done.items():
        print("  %-20s %-10s -> %s" % (k, o.strip(), n))

main()
