#!/usr/bin/env python3
"""Static sanity checker for Pine Script v6 sources.

Not a compiler - TradingView is the only Pine compiler that exists. This
catches the failure classes that actually bite when you cannot compile:
typos in identifiers, unbalanced brackets, tabs, bad block indentation,
accidental line wrapping, and `:=` on a name that was never declared.
"""
import re
import sys

KEYWORDS = {
    'if', 'else', 'for', 'to', 'by', 'in', 'while', 'switch', 'break',
    'continue', 'return', 'var', 'varip', 'type', 'enum', 'method', 'import',
    'export', 'and', 'or', 'not', 'true', 'false', 'na', 'series', 'simple',
    'const', 'input',
}

TYPES = {'int', 'float', 'bool', 'string', 'color', 'line', 'label', 'box',
         'table', 'linefill', 'polyline', 'array', 'matrix', 'map', 'chart'}

NAMESPACES = {
    'ta', 'math', 'str', 'array', 'matrix', 'map', 'color', 'box', 'line',
    'label', 'table', 'linefill', 'polyline', 'chart', 'strategy', 'syminfo',
    'timeframe', 'barstate', 'session', 'dayofweek', 'input', 'request',
    'ticker', 'currency', 'order', 'plot', 'shape', 'location', 'size',
    'position', 'text', 'display', 'format', 'scale', 'xloc', 'yloc',
    'extend', 'alert', 'adjustment', 'earnings', 'dividends', 'splits',
    'log', 'runtime', 'timezone', 'font', 'hline', 'math',
}

BUILTIN_VARS = {
    'open', 'high', 'low', 'close', 'volume', 'hl2', 'hlc3', 'ohlc4', 'hlcc4',
    'time', 'time_close', 'time_tradingday', 'bar_index', 'last_bar_index',
    'last_bar_time', 'timenow', 'year', 'month', 'weekofyear', 'dayofmonth',
    'hour', 'minute', 'second', 'na',
}

BUILTIN_FUNCS = {
    'indicator', 'strategy', 'library', 'plot', 'plotshape', 'plotchar',
    'plotarrow', 'plotcandle', 'plotbar', 'fill', 'bgcolor', 'barcolor',
    'hline', 'alertcondition', 'alert', 'nz', 'na', 'fixnan', 'int', 'float',
    'bool', 'string', 'color', 'max_bars_back', 'timestamp',
}

KNOWN = KEYWORDS | TYPES | NAMESPACES | BUILTIN_VARS | BUILTIN_FUNCS


def strip_noise(text):
    """Blank out string literals and comments, preserving line structure."""
    out, i, n = [], 0, len(text)
    while i < n:
        c = text[i]
        if c == '"' or c == "'":
            q = c
            i += 1
            while i < n and text[i] != q:
                if text[i] == '\\':
                    i += 1
                i += 1
            i += 1
            out.append('""')
        elif c == '/' and i + 1 < n and text[i + 1] == '/':
            while i < n and text[i] != '\n':
                i += 1
        else:
            out.append(c)
            i += 1
    return ''.join(out)


def main(path):
    raw = open(path, encoding='utf-8').read()
    raw_lines = raw.split('\n')
    problems = []

    if not raw_lines[0].strip().startswith('//@version='):
        problems.append('line 1: missing //@version= directive')

    for i, ln in enumerate(raw_lines, 1):
        if '\t' in ln:
            problems.append(f'line {i}: contains a TAB - Pine wants spaces only')
        if ln.rstrip() != ln and ln.strip():
            problems.append(f'line {i}: trailing whitespace')

    code = strip_noise(raw)
    code_lines = code.split('\n')

    # --- bracket balance, whole file and per statement ----------------------
    depth = 0
    for i, ln in enumerate(code_lines, 1):
        start = depth
        for c in ln:
            if c in '([':
                depth += 1
            elif c in ')]':
                depth -= 1
            if depth < 0:
                problems.append(f'line {i}: closing bracket with nothing open')
                depth = 0
        if start == 0 and depth != 0 and ln.strip():
            problems.append(
                f'line {i}: statement wraps to the next line (unbalanced bracket). '
                f'Pine continuation indentation is error-prone - keep it on one line.')
    if depth != 0:
        problems.append(f'end of file: {depth} bracket(s) never closed')

    # --- indentation --------------------------------------------------------
    for i, ln in enumerate(code_lines, 1):
        if not ln.strip():
            continue
        indent = len(ln) - len(ln.lstrip(' '))
        if indent % 4 != 0:
            problems.append(f'line {i}: indent of {indent} is not a multiple of 4')

    # --- collect declared names --------------------------------------------
    declared = set()
    # user functions + their parameters
    for m in re.finditer(r'(?m)^([A-Za-z_]\w*)\s*\(([^)]*)\)\s*=>', code):
        declared.add(m.group(1))
        for part in m.group(2).split(','):
            part = part.strip()
            if part:
                declared.add(re.split(r'[\s=]+', part)[-1] if '=' in part
                             else part.split()[-1])
    # types and their fields
    for m in re.finditer(r'(?m)^type\s+([A-Za-z_]\w*)\s*$', code):
        declared.add(m.group(1))
    for m in re.finditer(r'(?m)^\s+[A-Za-z_][\w<>]*\s+([A-Za-z_]\w*)\s*$', code):
        declared.add(m.group(1))
    # loop counters
    for m in re.finditer(r'\bfor\s+([A-Za-z_]\w*)\s*(?:=|\bin\b)', code):
        declared.add(m.group(1))
    # assignments, typed or bare, at any indent
    decl_re = re.compile(
        r'(?m)^\s*(?:var\s+|varip\s+)?'
        r'(?:(?:int|float|bool|string|color|line|label|box|table|'
        r'array<[^>]*>|map<[^>]*>|matrix<[^>]*>|[A-Z]\w*)\s+)?'
        r'([A-Za-z_]\w*)\s*(?::=|=)(?!=)')
    for m in decl_re.finditer(code):
        declared.add(m.group(1))

    # --- usage check --------------------------------------------------------
    # drop named arguments (`foo(bar = 1)`) so they are not read as identifiers
    usage_src = re.sub(r'#[0-9a-fA-F]{6,8}', ' ', code)  # hex colour literals
    usage_src = re.sub(r'(?<=[(,])\s*[A-Za-z_]\w*\s*=(?!=)', ' ', usage_src)
    # drop member access - `x.field` members are validated by Pine, not here
    usage_src = re.sub(r'\.\s*[A-Za-z_]\w*', '', usage_src)

    unknown = {}
    for m in re.finditer(r'\b[A-Za-z_]\w*\b', usage_src):
        name = m.group(0)
        if name in KNOWN or name in declared:
            continue
        ln = usage_src[:m.start()].count('\n') + 1
        unknown.setdefault(name, []).append(ln)

    for name, lines in sorted(unknown.items()):
        problems.append(f'undeclared identifier "{name}" used at line(s) '
                        f'{", ".join(str(x) for x in lines[:6])}')

    # --- `:=` must target something already declared ------------------------
    for m in re.finditer(r'(?m)^\s*([A-Za-z_]\w*)\s*:=', code):
        if m.group(1) not in declared:
            ln = code[:m.start()].count('\n') + 1
            problems.append(f'line {ln}: ":=" assigns to undeclared "{m.group(1)}"')

    print(f'--- {path} ---')
    print(f'{len(raw_lines)} lines, {len(declared)} declared names')
    if problems:
        print(f'\n{len(problems)} issue(s):')
        for p in problems:
            print('  !', p)
        return 1
    print('\nNo structural issues found.')
    return 0


if __name__ == '__main__':
    sys.exit(main(sys.argv[1]))
