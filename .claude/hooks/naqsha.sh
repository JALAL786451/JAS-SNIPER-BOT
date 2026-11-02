#!/bin/bash
# SessionStart: har nayi chat ke shuru mein MACHINE khud ye context mein daalti hai (chat ki yaad par nahi). User ijazat 2 Nov.
cd "$CLAUDE_PROJECT_DIR" 2>/dev/null || exit 0
echo "=== KHUD-BA-KHUD (hook) - nayi chat ka PEHLA jawab MT5 NAQSHA table dikhaye, user tasdeeq kare ==="
awk '/^## 0\. MT5 NAQSHA/{f=1} f&&/^$/{exit} f' TRADING.md
sed -n '/^## 5\. PICHLI CHAT/,/^## 6/p' TRADING.md | sed '$d'
sed -n '/^4\. ABHI/,/^5\. BANK/p' KAHANI.txt | sed '$d'
echo "=== aakhri 5 commit ==="
git log --oneline -5
exit 0
