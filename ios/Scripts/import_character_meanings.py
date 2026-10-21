"""Significato breve e immagine di ogni carattere: Content/character_meanings.tsv → Resources/character-meanings.json.

Le emoji sono quelle di sistema; «asset:nome» rimanda ai disegni originali in Bubu/Assets.xcassets/glyph-nome.imageset.
"""
import json, unicodedata
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
chars = list(json.loads((ROOT / 'ios/Bubu/Resources/strokes.json').read_text()))
words = {w['hanzi']: w for w in json.loads((ROOT / 'ios/Bubu/Resources/curriculum.json').read_text())['words']}
assets = ROOT / 'ios/Bubu/Assets.xcassets'
out = {}
for line in (ROOT / 'ios/Content/character_meanings.tsv').read_text(encoding='utf-8').splitlines():
    if not line or line.startswith('#'): continue
    hanzi, meaning, image, source = line.split('\t')
    assert meaning.strip() and image.strip(), hanzi
    if image.startswith('asset:'):
        name = image[6:]
        assert (assets / f'glyph-{name}.imageset' / f'glyph-{name}.svg').exists(), (hanzi, name)
    else:
        # Una sola emoji: nessuna lettera e nessun carattere cinese nell'immagine.
        assert not any(unicodedata.category(c).startswith('L') for c in image), (hanzi, image)
    if source.startswith('parola'):
        assert words[hanzi]['italian'] == meaning, hanzi
    out[hanzi] = {'meaning': meaning, 'image': image}
assert set(out) == set(chars), set(chars) ^ set(out)
(ROOT / 'ios/Bubu/Resources/character-meanings.json').write_text(json.dumps(out, ensure_ascii=False, separators=(',', ':')) + '\n')
print(f'{len(out)} caratteri, {sum(v["image"].startswith("asset:") for v in out.values())} disegni originali.')
