import json,re,hashlib
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2]
d=json.loads((ROOT/'ios/Bubu/Resources/curriculum.json').read_text());out={};provenance={}
for ch in d['writingCharacters']:
 c=ch['hanzi'];p=ROOT/'app_prototype/vendor/hanzi'/f'{c}.json'
 if not p.exists():p=ROOT/'ios/Content/strokes-extra'/f'{c}.json'
 data=json.loads(p.read_text())
 # Non includere radStrokes, radicali o scomposizioni: il modulo usa solo grafica.
 out[c]={'strokes':data['strokes'],'medians':data['medians']}
 provenance[c]=hashlib.sha256(p.read_bytes()).hexdigest()
 for stroke in data['strokes']:assert set(re.findall('[A-Za-z]',stroke))<=set('MLQCZ'),(c,stroke)
assert len(out)==100
(ROOT/'ios/Bubu/Resources/writing-strokes.json').write_text(json.dumps(out,ensure_ascii=False,separators=(',',':'))+'\n')
(ROOT/'ios/Content/strokes-provenance.json').write_text(json.dumps(provenance,ensure_ascii=False,indent=2)+'\n')
print('100 caratteri con tratti e mediane. Nessuna scomposizione inclusa.')
