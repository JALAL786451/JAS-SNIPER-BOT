#!/usr/bin/env python3
"""docs/roznamcha/ dobara banao (git history se): har din ki file, README fehrist, FEHRIST.txt.
Chat ke aakhir mein: python3 tools/roznamcha.py  (pehle shallow ho to: git fetch --unshallow origin <branch>)"""
import subprocess, collections, os
os.chdir(os.path.join(os.path.dirname(__file__), '..'))
out = subprocess.check_output(['git', 'log', '--reverse', '--date=format:%Y-%m-%d %H:%M', '--format=%h|%ad|%s'], text=True).strip().split('\n')
days = collections.OrderedDict()
for l in out:
    h, d, s = l.split('|', 2)
    if not s.startswith('Merge'):
        days.setdefault(d[:10], []).append((h, d[11:], s))
os.makedirs('docs/roznamcha', exist_ok=True)
idx = ["# Roznamcha - din ba din kaam (git commits se, `tools/roznamcha.py` banata hai)", "",
       "Peechhe jana ho: yahan tareekh dhoondo -> us din ki file kholo -> zaroorat ho to `git show <hash>`.",
       "Lambi kahani `docs/purana-haal.md` mein (grep tareekh se). Is folder ki files sirf zaroorat par, poori nahi.", "",
       "| Din | Commits | File | Pehla / aakhri kaam |", "|---|---|---|---|"]
old, txt = [], ["JAS-SNIPER-BOT - TAREEKH KI FEHRIST (Notepad ke liye)",
                "Har din: kitne kaam + chand khaas kaam. Tafseel: docs/roznamcha/<tareekh>.md",
                "Nayi chat: user ijazat de to EK DIN peechhe dekho, phir poochho.", ""]
for d, L in days.items():
    S = [s for _, _, s in L]
    pick = list(dict.fromkeys([S[0]] + ([S[len(S) // 2]] if len(S) > 2 else []) + ([S[-1]] if len(S) > 1 else [])))
    txt += [f"{d}  ({len(S)} kaam)"] + ["   - " + s[:90] for s in pick] + [""]
    if d < '2026-10-01':
        old.append((d, L)); continue
    with open(f'docs/roznamcha/{d}.md', 'w') as f:
        f.write(f"# {d} - {len(L)} commits\n\n" + ''.join(f"- `{h}` {t} - {s}\n" for h, t, s in L))
    idx.append(f"| {d} | {len(L)} | `{d}.md` | {S[0][:60]} / {S[-1][:60]} |")
with open('docs/roznamcha/pehle-2026-09.md', 'w') as f:
    f.write("# Oct 2026 se pehle (2025-06 se 2026-09)\n")
    for d, L in old:
        f.write(f"\n## {d}\n" + ''.join(f"- `{h}` {t} - {s}\n" for h, t, s in L))
idx.insert(7, f"| Sep 2026 tak | {sum(len(L) for _, L in old)} | `pehle-2026-09.md` | shuru se 30 Sep tak |")
open('docs/roznamcha/README.md', 'w').write('\n'.join(idx) + '\n')
open('docs/roznamcha/FEHRIST.txt', 'w', newline='\r\n').write('\n'.join(txt))
print(f"roznamcha: {len(days)} din")
