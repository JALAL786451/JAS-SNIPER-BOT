#!/bin/bash
# Stop: har jawab ke baad badli files KHUD commit + push (chat bhool jaye tab bhi kaam GitHub par). User ijazat 2 Nov.
cd "$CLAUDE_PROJECT_DIR" 2>/dev/null || exit 0
[ -z "$(git status --porcelain)" ] && exit 0
git add -A && git commit -q -m "auto-save (Stop hook): $(date -u +%F' '%H:%M) UTC" >/dev/null 2>&1
timeout 40 git push -q origin HEAD:claude/jas-desk-v3-0110-yu3w2h >/dev/null 2>&1
exit 0
