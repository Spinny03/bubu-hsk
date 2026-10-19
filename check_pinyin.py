#!/usr/bin/env python3
"""Controlla che il pinyin degli esempi (ex:/no:) corrisponda agli hanzi.

Per ogni carattere cinese prende tutte le letture possibili da pypinyin e verifica
che la trascrizione contenga, nell'ordine, una lettura valida per ciascun carattere.
Segnala: sillabe che non corrispondono, toni non previsti dal dizionario.
Il tono neutro e le variazioni di 一/不 sono sempre ammessi.

Uso:  .venv/bin/python check_pinyin.py [file ...]
"""
import glob
import os
import re
import sys
import unicodedata

from pypinyin import Style, pinyin

BASE = os.path.dirname(os.path.abspath(__file__))
HAN = re.compile('[\u3400-\u9fff\u3007]')
EXTRA = {'〇': {'líng'}, '一': {'yī', 'yí', 'yì', 'yāo'}, '不': {'bù', 'bú'}, '儿': {'ér', 'r'},
         '哪': {'nǎ', 'něi', 'na'}, '那': {'nà', 'nèi'}, '这': {'zhè', 'zhèi'},
         '谁': {'shéi', 'shuí'}, '嗯': {'ng', 'ǹg', 'ńg', 'ňg', 'en', 'ēn', 'èn'}}


def plain(s):
    """Toglie i diacritici carattere per carattere (lunghezza invariata)."""
    out = []
    for ch in s:
        d = unicodedata.normalize('NFD', ch)
        out.append(''.join(c for c in d if unicodedata.category(c) != 'Mn') or ch)
    return ''.join(out).lower()


def readings(ch):
    r = set(pinyin(ch, style=Style.TONE, heteronym=True)[0]) | EXTRA.get(ch, set())
    return {x.lower() for x in r}


def check_line(hz, py):
    chars = HAN.findall(hz.replace('**', ''))
    if not chars or re.search(r'[0-9０-９]', hz):
        return []
    py = re.sub(r'(?<![A-Za-z])[A-Z]\s*:', ' ', py)  # etichette di dialogo A: B:
    toned = re.sub(r"[^a-zA-ZüÀ-ɏ̀-ͯ]", '', unicodedata.normalize('NFC', py)).lower()
    flat = plain(toned)
    alts = [readings(c) for c in chars]
    pat = ''.join('(' + '|'.join(sorted({re.escape(plain(a)) for a in al}, key=len, reverse=True)) + ')'
                  for al in alts)
    m = re.fullmatch(pat, flat)
    if not m:
        return ['sillabe non corrispondenti']
    probs = []
    for i, (c, al) in enumerate(zip(chars, alts)):
        syl = toned[m.start(i + 1):m.end(i + 1)]
        if syl == plain(syl):      # tono neutro: ammesso
            continue
        if syl not in al:
            probs.append(f'{c}: «{syl}» (dizionario: {"/".join(sorted(al))})')
    return probs


def main():
    files = sys.argv[1:] or sorted(glob.glob(os.path.join(BASE, 'content', '*.txt')))
    total = 0
    for f in files:
        for n, line in enumerate(open(f, encoding='utf-8'), 1):
            if not line.startswith(('ex:', 'no:')):
                continue
            parts = line[3:].split(' | ')
            if len(parts) != 3:
                continue
            for p in check_line(parts[0], parts[1]):
                total += 1
                print(f'{os.path.basename(f)}:{n}: {p}\n    {parts[0].strip()} | {parts[1].strip()}')
    print(f'\n{total} segnalazioni', file=sys.stderr)


if __name__ == '__main__':
    main()
