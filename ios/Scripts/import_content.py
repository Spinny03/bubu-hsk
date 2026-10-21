#!/usr/bin/env python3
"""Import deterministico: le liste ufficiali restano immutate; nessun font PDF richiesto."""
import ast, hashlib, json, re, sys
from pathlib import Path
ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT))
from check_pinyin import check_line
from pypinyin import lazy_pinyin, Style
OUT = ROOT / 'ios/Bubu/Resources'

def main():
    official = json.loads((ROOT/'hsk2025/hsk2025.json').read_text())
    prototype = json.loads((ROOT/'app_prototype/data.js').read_text().removeprefix('window.DATA = ').rstrip(';\n'))
    extras = {}
    for line in (ROOT/'hsk2025/l1_units.txt').read_text().splitlines():
        n,hz,py,unit,it,emoji = [s.strip() for s in line.split('|')]
        extras[int(n)] = dict(hz=hz,unit=int(unit),it=it,emoji='' if emoji=='-' else emoji)
    words=[]
    for w in official['words']:
        if w['level'] != 1: continue
        e=extras[w['n']]
        assert e['hz']==w['hanzi']
        # Le parentesi con classificatori nelle traduzioni ricevono il pinyin.
        # 只 come classificatore si legge zhī (pypinyin dà zhǐ).
        it=re.sub(r'[\u3400-\u9fff]+',lambda m:m[0]+' '+({'只':'zhī'}.get(m[0]) or ' '.join(lazy_pinyin(m[0],style=Style.TONE))),e['it'])
        words.append(dict(id=w['n'],hanzi=w['hanzi'],pinyin=w['pinyin'],category=w['pos'],unit=e['unit'],italian=it,emoji=e['emoji']))
    assert len(words)==300 and len({w['id'] for w in words})==300
    assert not [(w['hanzi'],[p for py in w['pinyin'].split('/') for p in check_line(w['hanzi'],py)]) for w in words if [p for py in w['pinyin'].split('/') for p in check_line(w['hanzi'],py)]]
    units=[]
    for u in prototype['units']:
        goals=[re.sub(r'[\u3400-\u9fff]+',lambda m:m[0]+' '+' '.join(lazy_pinyin(m[0],style=Style.TONE)),s) for s in u['cando']]
        units.append(dict(id=u['n'],title=u['it'],hanzi=u['cn'],pinyin=u['cnpy'],goals=goals))
    assert len(units)==15 and set(w['unit'] for w in words)==set(range(1,16))
    readings={c['c']:c['py'] for c in prototype['chars']}
    # Le letture del prototipo vengono dalle parole: in 便宜 piányi o 朋友 péngyou il secondo carattere è neutro.
    # Da solo il carattere ha il tono di dizionario (Unicode 18.0 Unihan, kMandarin); le particelle restano neutre.
    readings.update({'得':'dé','服':'fú','候':'hòu','欢':'huān','亮':'liàng','识':'shí','西':'xī','息':'xī','系':'xì','宜':'yí','友':'yǒu','子':'zǐ'})
    writing=[c['char'] for c in official['writing_chars'] if c['list']=='一级）~（二级']
    assert len(writing)==100
    chars=[dict(id=c,hanzi=c,pinyin=readings.get(c) or lazy_pinyin(c,style=Style.TONE)[0],writing=c in writing) for c in official['recognition_chars']['一级']]
    assert len(chars)==246
    # La lista di scrittura contiene caratteri che non sono nella lista di riconoscimento HSK 1.
    writing_chars=[dict(id=c,hanzi=c,pinyin=readings.get(c) or lazy_pinyin(c,style=Style.TONE)[0],writing=True) for c in writing]
    payload=dict(version='2025-11 / 2025-12',words=words,units=units,characters=chars,writingCharacters=writing_chars)
    OUT.mkdir(parents=True,exist_ok=True)
    (OUT/'curriculum.json').write_text(json.dumps(payload,ensure_ascii=False,indent=2)+'\n')
    hashes={str(p.relative_to(ROOT)):hashlib.sha256(p.read_bytes()).hexdigest() for p in [ROOT/'hsk2025/hsk2025.json',ROOT/'hsk2025/l1_units.txt']}
    (OUT/'provenance.json').write_text(json.dumps(dict(sources=hashes,syllabus='2025-11',format='2025-12',words=300,characters=246,writing=100,units=15),indent=2)+'\n')
    print('Import: 300 parole, 246 caratteri, 100 da scrivere, 15 unità. Pinyin: OK.')

if __name__=='__main__': main()
