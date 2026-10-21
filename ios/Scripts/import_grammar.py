#!/usr/bin/env python3
"""Collega tutte le 70 righe di HSK 1 ai testi originali in content/.
Le pagine del programma sono 386–388 nel PDF (383–385 stampate).
I testi estratti restano consultabili, il quiz riguarda l'esempio selezionato.
"""
import json,re,sys
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2];sys.path.insert(0,str(ROOT))
from check_pinyin import check_line
from check_cs_pinyin import check_text
from pypinyin import lazy_pinyin,Style
HAN=re.compile(r'[\u3400-\u9fff]+')

def annotate(text):
    text=text.replace('**','').lstrip('! ').strip()
    # Annota solo le sequenze prive di una lettura corrispondente già presente.
    for m in reversed(list(HAN.finditer(text))):
        rest=text[m.start():]
        if check_text(rest.split('。')[0]):
            # check_text può segnalare una sequenza successiva; verifica la prima soltanto.
            from check_cs_pinyin import AFTER,pattern
            from check_pinyin import plain
            a=AFTER.match(text,m.end());py=a.group(2) if a else ''
            flat=plain(re.sub(r'[^A-Za-zÀ-ɏü]','',py))
            if not re.match(pattern(list(m[0])),flat):
                text=text[:m.end()]+' '+' '.join(lazy_pinyin(m[0],style=Style.TONE))+text[m.end():]
    return text

def main():
    rows=[l.split('|') for l in (ROOT/'ios/Content/grammar_map.tsv').read_text().splitlines() if l]
    assert len(rows)==70,len(rows)
    lessons=[]
    for n,(title,file,keyword,unit) in enumerate(rows,1):
        lines=(ROOT/'content'/file).read_text().splitlines()
        sections=[]
        headings=[i for i,l in enumerate(lines) if l.startswith('#')]
        for i in headings:
            depth=len(lines[i])-len(lines[i].lstrip('#'))
            end=next((j for j in headings if j>i and len(lines[j])-len(lines[j].lstrip('#'))<=depth),len(lines))
            sections.append(lines[i:end])
        # Preferisce una sezione che contiene il termine nel titolo, poi nel corpo.
        candidates=sorted(sections,key=lambda s:(keyword.lower() not in s[0].lower(),not any(keyword.lower() in l.lower() for l in s)))
        examples=[];body=[];selected=None
        for section in candidates:
            ex=[]
            for line in section:
                if line.startswith('ex:'):
                    p=[x.strip().replace('**','') for x in line[3:].split(' | ')]
                    if len(p)==3 and 3<=sum(map(len,HAN.findall(p[0])))<=30 and not check_line(p[0],p[1]): ex.append(p)
            paragraphs=[l for l in section if l and not l.startswith(('#','|','ex:','no:','=','- '))]
            if ex and paragraphs:
                examples=ex[:3];body=[annotate(p) for p in paragraphs[:2]];selected=section[0];break
        if not examples:
            for line in lines:
                if line.startswith('ex:'):
                    p=[x.strip().replace('**','') for x in line[3:].split(' | ')]
                    if len(p)==3 and not check_line(p[0],p[1]): examples.append(p)
            body=[annotate(l) for l in lines if l and not l.startswith(('#','|','ex:','no:','=','- '))][:2]
            examples=examples[:3];selected=lines[0]
        assert examples,(n,file)
        # Le traduzioni sono la chiave del quiz di comprensione della struttura.
        # Le domande non pretendono di certificare l'intera riga alla sola lettura.
        clean_examples=[dict(hanzi=e[0],pinyin=e[1],italian=annotate(e[2])) for e in examples]
        lessons.append(dict(id=n,title=title,unit=int(unit),source='content/'+file,sourceHeading=annotate(selected.lstrip('# ')),syllabusPage=386 if n<=27 else 387 if n<=58 else 388,body='\n\n'.join(body),examples=clean_examples))
    payload=dict(lessons=lessons)
    (ROOT/'ios/Bubu/Resources/grammar.json').write_text(json.dumps(payload,ensure_ascii=False,indent=2)+'\n')
    # Corpus per i due controlli ufficiali del progetto.
    corpus=[]
    for l in lessons:
        corpus += [l['title'],l['body'],l['sourceHeading']]
        corpus += ['ex: '+e['hanzi']+' | '+e['pinyin']+' | '+e['italian'] for e in l['examples']]
    (ROOT/'ios/Content/grammar_pinyin.txt').write_text('\n'.join(corpus)+'\n')
    print(f'{len(lessons)} righe grammaticali collegate ai testi del libro.')
if __name__=='__main__':main()
