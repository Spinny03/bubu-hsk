import json,re,hashlib
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2]
d=json.loads((ROOT/'ios/Bubu/Resources/curriculum.json').read_text());out={};provenance={}
# Tutti i caratteri mostrati dall'app: 246 da riconoscere, 100 da scrivere, quelli presenti nelle 300 parole.
chars=[c['hanzi'] for c in d['characters']]
for h in [c['hanzi'] for c in d['writingCharacters']]+[h for w in d['words'] for h in w['hanzi']]:
 if '一'<=h<='鿿' and h not in chars:chars.append(h)
for c in chars:
 p=ROOT/'app_prototype/vendor/hanzi'/f'{c}.json'
 if not p.exists():p=ROOT/'ios/Content/strokes-extra'/f'{c}.json'
 data=json.loads(p.read_text())
 # Non includere radStrokes, radicali o scomposizioni: qui solo grafica (Arphic Public License).
 out[c]={'strokes':data['strokes'],'medians':data['medians']}
 provenance[c]=hashlib.sha256(p.read_bytes()).hexdigest()
 for stroke in data['strokes']:assert set(re.findall('[A-Za-z]',stroke))<=set('MLQCZ'),(c,stroke)
assert len(out)==253 and all(c['hanzi'] in out for c in d['writingCharacters'])
(ROOT/'ios/Bubu/Resources/strokes.json').write_text(json.dumps(out,ensure_ascii=False,separators=(',',':'))+'\n')
(ROOT/'ios/Content/strokes-provenance.json').write_text(json.dumps(provenance,ensure_ascii=False,indent=2)+'\n')
print(f'{len(out)} caratteri con tratti e mediane. Nessuna scomposizione inclusa.')
