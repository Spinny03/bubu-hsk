#!/usr/bin/env python3
"""Cheatsheet: ogni parola cinese fuori dagli esempi (ex:/no:) deve essere seguita dal suo pinyin.

Cerca ogni sequenza di caratteri cinesi (anche spezzata da …… / ……) e controlla che subito dopo,
eventualmente tra parentesi, ci sia un pinyin che corrisponde sillaba per sillaba ai caratteri.
Le righe ex:/no: sono già controllate da check_pinyin.py.

Uso:  .venv/bin/python check_cs_pinyin.py [file ...]
"""
import glob
import os
import re
import sys
import unicodedata

from check_pinyin import plain, readings

BASE = os.path.dirname(os.path.abspath(__file__))
HZ = '㐀-鿿〇'
# sequenza cinese: caratteri, eventualmente uniti da …, ……, / e spazi
RUN = re.compile(rf'[{HZ}]+(?:\s*(?:…+|/|～|~)\s*[{HZ}]+)*(?:\s*…+)?')
PY_CHARS = r"A-Za-zÀ-ɏ̀-ͯü'’\-…\s/~～"
AFTER = re.compile(rf'\s*(\*\*)?\s*\(?\s*([{PY_CHARS}]+)')


def pattern(chars):
    return ''.join('(?:' + '|'.join(sorted({re.escape(plain(a)) for a in readings(c)}, key=len,
                                            reverse=True)) + ')' for c in chars)


def check_text(text):
    probs = []
    text = unicodedata.normalize('NFC', text.replace('**', ''))
    for m in RUN.finditer(text):
        chars = re.findall(rf'[{HZ}]', m.group())
        a = AFTER.match(text, m.end())
        py = a.group(2) if a else ''
        flat = plain(re.sub(r"[^A-Za-zÀ-ɏ̀-ͯü]", '', py)).lower()
        if not flat:
            probs.append(f'senza pinyin: {m.group()}')
        elif not re.match(pattern(chars), flat):
            probs.append(f'pinyin non corrispondente: {m.group()} {py.strip()}')
    return probs


def main():
    files = sys.argv[1:] or sorted(glob.glob(os.path.join(BASE, 'cheatsheet', '*.txt')))
    total = 0
    for f in files:
        for n, line in enumerate(open(f, encoding='utf-8'), 1):
            s = line.strip()
            if not s or s[:3].lower() in ('ex:', 'no:'):
                continue
            for p in check_text(s):
                total += 1
                print(f'{os.path.basename(f)}:{n}: {p}')
    print(f'\n{total} segnalazioni', file=sys.stderr)


if __name__ == '__main__':
    main()
