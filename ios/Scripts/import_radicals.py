"""Radicali colorati: unisce il radicale Unihan all'annotazione dei tratti di questo progetto.

Uso:
  python ios/Scripts/import_radicals.py [--unihan Unihan_IRGSources.txt --cjk CJKRadicals.txt --zip Unihan.zip] [--preview DIR]
Con --unihan rigenera l'estratto versionato in Content/unihan-radicals.txt; senza, usa l'estratto.
Nessun dato di Make Me a Hanzi (LGPL) viene usato: gli indici dei tratti sono annotati a mano in Content/radicals.tsv.
"""
import argparse, hashlib, json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
CONTENT = ROOT / 'ios/Content'
ap = argparse.ArgumentParser()
ap.add_argument('--unihan'); ap.add_argument('--cjk'); ap.add_argument('--zip'); ap.add_argument('--preview')
args = ap.parse_args()

strokes = json.loads((ROOT / 'ios/Bubu/Resources/strokes.json').read_text())
chars = list(strokes)
extract = CONTENT / 'unihan-radicals.txt'
if args.unihan:
    wanted = set(chars)
    lines = [l for l in open(args.unihan, encoding='utf-8') if l.startswith('U+') and l.split('\t')[1] in ('kRSUnicode', 'kTotalStrokes')
             and chr(int(l.split('\t')[0][2:], 16)) in wanted]
    radicals = [l for l in open(args.cjk, encoding='utf-8') if l[:1].isdigit()]
    header = ['# Estratto da Unicode 18.0.0 Unihan (Unihan_IRGSources.txt) e CJKRadicals.txt, Unicode License v3.',
              '# https://www.unicode.org/Public/18.0.0/ucd/Unihan.zip', f'# sha256 Unihan.zip {hashlib.sha256(open(args.zip, "rb").read()).hexdigest()}',
              f'# sha256 CJKRadicals.txt {hashlib.sha256(open(args.cjk, "rb").read()).hexdigest()}']
    extract.write_text('\n'.join(header) + '\n' + ''.join(sorted(lines)) + ''.join('R\t' + l for l in radicals))

rs, known = {}, set()
for line in extract.read_text(encoding='utf-8').splitlines():
    if line.startswith('U+'):
        cp, field, value = line.split('\t')
        if field == 'kRSUnicode': rs[chr(int(cp[2:], 16))] = value.split()[0]
    elif line.startswith('R\t'):
        known.add(line.split('\t')[1].split(';')[0].strip())

forms = {}
for line in (CONTENT / 'radical_forms.tsv').read_text(encoding='utf-8').splitlines():
    if line and not line.startswith('#'):
        rad, form, canonical, pinyin, count, meaning = line.split('\t')
        assert rad in known, rad
        forms[f'{rad}|{form}'] = {'radical': rad, 'form': form, 'canonical': canonical, 'pinyin': pinyin, 'strokes': int(count), 'meaning': meaning}

result, annotated = {}, set()
for line in (CONTENT / 'radicals.tsv').read_text(encoding='utf-8').splitlines():
    if not line or line.startswith('#'): continue
    char, rad, form, spec, note = (line.split('\t') + [''])[:5]
    n = len(strokes[char]['strokes'])
    unihan_rad, residual = rs[char].split('.')
    assert rad == unihan_rad, (char, rad, rs[char])
    key = f'{rad}|{form}'; assert key in forms, (char, key)
    k = n - int(residual)
    if spec == 'whole': indices = list(range(n))
    elif spec == 'prefix': indices = list(range(k))
    elif spec == 'suffix': indices = list(range(n - k, n))
    elif spec.startswith('split:'):
        p = int(spec[6:]); indices = list(range(p)) + list(range(n - (k - p), n))
    else: indices = [int(x) for x in spec.split(',')]
    assert indices and all(0 <= i < n for i in indices) and len(set(indices)) == len(indices), (char, indices)
    # Il numero di tratti deve corrispondere alla forma; gli scarti da Unihan sono ammessi solo se annotati.
    assert len(indices) == forms[key]['strokes'], (char, form, indices)
    assert len(indices) == k or note, (char, 'conteggio Unihan', k, len(indices))
    result[char] = {'radical': key, 'strokes': indices}
    annotated.add(char)
assert annotated == set(chars), set(chars) ^ annotated
used = {v['radical'] for v in result.values()}
out = {'forms': {k: {x: v[x] for x in ('form', 'canonical', 'pinyin', 'meaning')} for k, v in forms.items() if k in used}, 'characters': result}
(ROOT / 'ios/Bubu/Resources/radicals.json').write_text(json.dumps(out, ensure_ascii=False, separators=(',', ':')) + '\n')
print(f'{len(result)} caratteri, {len(used)} forme di radicale.')

if args.preview:
    from PIL import Image, ImageDraw, ImageFont
    font = ImageFont.truetype('/System/Library/Fonts/Hiragino Sans GB.ttc', 16)
    cell, cols = 120, 12
    rows = (len(chars) + cols - 1) // cols
    sheet = Image.new('RGB', (cols * cell, rows * cell), 'white'); draw = ImageDraw.Draw(sheet)
    for i, char in enumerate(chars):
        x0, y0 = (i % cols) * cell, (i // cols) * cell
        red = set(result[char]['strokes'])
        for j, median in enumerate(strokes[char]['medians']):
            pts = [(x0 + 10 + px * 0.09, y0 + 22 + (900 - py) * 0.09) for px, py in median]
            draw.line(pts, fill=(166, 48, 60) if j in red else (40, 40, 40), width=5, joint='curve')
            draw.text(pts[0], str(j), fill=(0, 120, 220), font=ImageFont.truetype('/System/Library/Fonts/Helvetica.ttc', 10))
        draw.text((x0 + 4, y0 + 2), f'{char} {forms[result[char]["radical"]]["form"]}', fill='black', font=font)
    Path(args.preview).mkdir(parents=True, exist_ok=True)
    sheet.save(Path(args.preview) / 'radicali.png')
