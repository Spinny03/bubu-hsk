"""Parole per la Sfida: hsk2025/final/hsk{1,2,3}.txt (traduzioni del progetto) → Resources/game-words.json.

Hanzi, pinyin e livello vengono confrontati con la lista ufficiale (hsk2025.json, programma 2025-11).
"""
import json, re
from pathlib import Path
from pypinyin import lazy_pinyin, Style

ROOT = Path(__file__).resolve().parents[2]
# HSK 1: le traduzioni del catalogo dell'app, che hanno già il pinyin accanto ai classificatori.
catalog = {w['hanzi']: w['italian'] for w in json.loads((ROOT / 'ios/Bubu/Resources/curriculum.json').read_text())['words']}
# Letture da dizionario dove pypinyin sbaglia: 只 classificatore è zhī; parole con tono neutro scritte unite.
READINGS = {'只': 'zhī', '上面': 'shàngmian', '前面': 'qiánmian', '桌子': 'zhuōzi'}
def annotate(text):
    # Ogni testo cinese con il pinyin accanto, come in import_content.py: «(辆)» → «(辆 liàng)».
    return re.sub(r'[\u3400-\u9fff]+', lambda m: m[0] + ' ' + (READINGS.get(m[0]) or ' '.join(lazy_pinyin(m[0], style=Style.TONE))), text)
official = json.loads((ROOT / 'hsk2025/hsk2025.json').read_text())['words']
by_level = {}
for w in official:
    by_level.setdefault(w['level'], []).append(w)
out = []
for level in (1, 2, 3):
    rows = [l for l in (ROOT / f'hsk2025/final/hsk{level}.txt').read_text(encoding='utf-8').splitlines() if l.strip() and not l.startswith('@')]
    assert len(rows) == len(by_level[level]), (level, len(rows))
    for line, ref in zip(rows, by_level[level]):
        hanzi, pinyin, italian, _emoji, lvl = [x.strip() for x in line.split('|')]
        assert hanzi == ref['hanzi'] and int(lvl) == level, (line, ref['hanzi'])
        # Il pinyin ufficiale prevale sulla trascrizione del file di lavoro.
        italian = catalog[hanzi] if level == 1 else annotate(italian)
        out.append({'hanzi': hanzi, 'pinyin': ref['pinyin'], 'italian': italian, 'level': level})
assert [sum(w['level'] == l for w in out) for l in (1, 2, 3)] == [300, 200, 500]
(ROOT / 'ios/Bubu/Resources/game-words.json').write_text(json.dumps(out, ensure_ascii=False, separators=(',', ':')) + '\n')
print(f'{len(out)} parole: 300 HSK 1, 200 HSK 2, 500 HSK 3.')
