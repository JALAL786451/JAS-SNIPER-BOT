#!/bin/bash
# SessionStart (sirf startup / compact / clear): nayi chat ke shuru mein MACHINE khud ye context mein daalti hai. User ijazat 2 Nov.
# 16 Nov (user "haan", token bachat): resume par NAHI chalta; KAHANI / poori TRADING parhne ki zaroorat nahi - ye kaafi hai.
cd "$CLAUDE_PROJECT_DIR" 2>/dev/null || exit 0
echo "=== KHUD-BA-KHUD (hook) - PEHLA jawab: MT5 NAQSHA table + agla kaam. KAHANI.txt / poori TRADING.md NA parho (sirf grep) ==="
awk '/^## 0\. MT5 NAQSHA/{f=1} f&&/^$/{exit} f' TRADING.md
echo "=== KAAM.md (user ka register) ==="
cat KAAM.md
echo "=== TRADING.md sec 5: pichli chat ==="
sed -n '/^## 5\. PICHLI CHAT/,/^## 6/p' TRADING.md | sed '$d' | grep -v 'purana-haal.md` (grep' | head -12
exit 0
