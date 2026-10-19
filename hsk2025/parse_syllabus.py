#!/usr/bin/env python3
"""Estrae dal «HSK 考试大纲» ufficiale (CLEC, 2025-11) i dati dei livelli 1–3:
parole (词汇大纲), caratteri da riconoscere (认读字), caratteri da scrivere (书写字).

Uso:  ../.venv/bin/python parse_syllabus.py   → hsk2025.json
"""
import json
import os
import re

from pypdf import PdfReader

HERE = os.path.dirname(os.path.abspath(__file__))
PDF = os.path.join(HERE, 'HSK_kaoshi_dagang_2025.pdf')
POS = r'(?:名|动|形|副|代|数|量|助|介|连|叹|拟声|前缀|后缀|、|（|）)+'
WORD = re.compile(rf'^(\d+) (\d)((?:（[\d\-]+）)*) (\S+?) (.+?)(?: ({POS}))?$')
CHAR = re.compile(r'^(\d+)\.\s*(\S)$')


def pages(reader, first, last):
    for i in range(first - 1, last):
        yield i + 1, reader.pages[i].extract_text() or ''


def main():
    r = PdfReader(PDF)
    words = []
    for _, text in pages(r, 80, 104):
        for line in text.splitlines():
            m = WORD.match(line.strip())
            if m and int(m.group(2)) <= 3:
                n, lvl, extra, hz, py, pos = m.groups()
                words.append({'n': int(n), 'level': int(lvl), 'hanzi': re.sub(r'\d+$', '', hz),
                              'sense': (re.search(r'(\d+)$', hz) or [None, None])[1],
                              'pinyin': py.strip(), 'pos': pos or '',
                              'also_level': re.findall(r'[\d\-]+', extra) if extra else []})
    chars, write = {}, []
    section = None
    for pno, text in pages(r, 353, 382):
        for line in text.splitlines():
            s = line.strip()
            m = re.match(r'HSK（(.+?)）(认读字|书写字)', s)
            if m:
                section = (m.group(1), m.group(2))
                continue
            c = CHAR.match(s)
            if c and section:
                if section[1] == '认读字':
                    chars.setdefault(section[0], []).append(c.group(2))
                else:
                    write.append({'list': section[0], 'char': c.group(2)})
    out = {'source': 'HSK 考试大纲, 中外语言交流合作中心, 2025-11 发布, 2026-07 实施',
           'words': words, 'recognition_chars': chars, 'writing_chars': write}
    json.dump(out, open(os.path.join(HERE, 'hsk2025.json'), 'w'), ensure_ascii=False, indent=1)
    from collections import Counter
    print('parole per livello:', dict(Counter(w['level'] for w in words)))
    print('caratteri da riconoscere:', {k: len(v) for k, v in chars.items()})
    print('caratteri da scrivere:', dict(Counter(w['list'] for w in write)))


if __name__ == '__main__':
    main()
