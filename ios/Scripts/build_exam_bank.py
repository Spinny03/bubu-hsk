#!/usr/bin/env python3
"""Banca originale a modelli: 8 forme riservate (320) + 480 quesiti di allenamento.
Non usa frasi delle prove ufficiali. Varianti generate da schemi trasparenti;
la revisione linguistica umana e la calibrazione NON sono implicite nel conteggio.
"""
import json,re,sys,random
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2];sys.path.insert(0,str(ROOT))
from check_pinyin import check_line,readings,plain
from pypinyin import lazy_pinyin,Style
DATA=json.loads((ROOT/'ios/Bubu/Resources/curriculum.json').read_text())
WORDS={w['hanzi']:w for w in DATA['words']};LEX=sorted(WORDS,key=len,reverse=True)
CORPUS=[];UNKNOWN=set()

def sentence(hanzi,italian=''):
    tokens=[];i=0;ids=[]
    while i<len(hanzi):
        if not re.match('[\u3400-\u9fff]',hanzi[i]):
            tokens.append(dict(hanzi=hanzi[i],pinyin=''));i+=1;continue
        word=next((w for w in LEX if hanzi.startswith(w,i)),hanzi[i])
        if word in WORDS:
            py=WORDS[word]['pinyin'].split('/')[0];ids.append(WORDS[word]['id'])
        else:
            UNKNOWN.add(word);py=' '.join(lazy_pinyin(word,style=Style.TONE))
        toned=re.sub(r'[^a-zA-ZüÀ-ɏ]','',py)
        pat=''.join('('+'|'.join(sorted({re.escape(plain(x)) for x in readings(ch)},key=len,reverse=True))+')' for ch in word)
        m=re.fullmatch(pat,plain(toned))
        assert m,(word,py)
        for j,c in enumerate(word):tokens.append(dict(hanzi=c,pinyin=toned[m.start(j+1):m.end(j+1)]))
        i+=len(word)
    # Sandhi scritto per 不 bù; i toni di dizionario restano nei vocaboli.
    for j,t in enumerate(tokens[:-1]):
        if t['hanzi']=='不' and any(c in tokens[j+1]['pinyin'] for c in 'àèìòùǜ'):t['pinyin']='bú'
        if t['hanzi']=='一' and (j==0 or tokens[j-1]['hanzi']!='第') and tokens[j+1]['hanzi'] in '个本杯件只口':
            t['pinyin']='yí' if any(c in tokens[j+1]['pinyin'] for c in 'àèìòùǜ') else 'yì'
    py=' '.join(t['pinyin'] if t['pinyin'] else t['hanzi'] for t in tokens)
    assert not check_line(hanzi,py),(hanzi,py,check_line(hanzi,py))
    CORPUS.append('ex: '+hanzi+' | '+py+' | '+(italian or 'Testo del quesito originale'))
    return dict(hanzi=hanzi,pinyin=py,italian=italian,tokens=tokens,wordIDs=sorted(set(ids)))

def textopt(key,hz,it):return dict(id=key,text=sentence(hz,it),symbol=None,count=1,label=it)
def picopt(key,obj,n):return dict(id=key,text=None,symbol=obj[2],count=n,label=f'{n} {obj[1]}')
OBJECTS=[('书','libri','book.closed','本'),('杯子','bicchieri','mug','个'),('手机','cellulari','iphone','个'),('电脑','computer','laptopcomputer','个'),('狗','cani','dog','只'),('猫','gatti','cat','只'),('车','auto','car','辆'),('衣服','vestiti','tshirt','件'),('椅子','sedie','chair','个'),('飞机','aerei','airplane','架')]
# 辆 liàng e 架 jià compaiono come classificatori negli apparati; evitiamo questi
# due oggetti nei testi d'esame HSK 1 finché non entrano nel lessico verificato.
OBJECTS=[o for o in OBJECTS if o[3] in WORDS]
NUM=['一','两','三','四','五'];NUMIT=['uno','due','tre','quattro','cinque']
PEOPLE=[('妈妈','la mamma'),('爸爸','il papà'),('哥哥','il fratello maggiore'),('姐姐','la sorella maggiore'),('弟弟','il fratello minore'),('妹妹','la sorella minore'),('老师',"l’insegnante"),('朋友',"l’amico"),('同学','il compagno di classe'),('医生','il medico')]
SUBJECTS=PEOPLE+[(f'我的{h}',f'il mio / la mia {it}') for h,it in PEOPLE]
PLACES=[('学校','scuola'),('医院','ospedale'),('公司','azienda'),('商店','negozio'),('饭店','ristorante'),('家','casa')]
PLACES=[p for p in PLACES if p[0] in WORDS]
TIMES=[('今天上午','questa mattina'),('今天下午','oggi pomeriggio'),('今天晚上','questa sera'),('明天上午','domani mattina'),('明天下午','domani pomeriggio')]
FORMS=[]
for form in range(20):
    rng=random.Random(202511+form);s,si=SUBJECTS[form];other,oi=PEOPLE[(form+3)%10]
    qs=[]
    def add(part,j,prompt,stimulus,options,answer,explanation,example=None,exampleAnswer=None):
        q=dict(id=f'f{form+1:02}-p{part}-q{j+1}',part=part,prompt=prompt,stimulus=stimulus,options=options,answer=answer,explanation=explanation,example=example,exampleAnswer=exampleAnswer,origin='originale · modelli IA',humanReviewed=False)
        q['wordIDs']=sorted(set(i for t in [prompt]+stimulus if t for i in t['wordIDs']))
        qs.append(q)
    # 1. Frase -> tre immagini (oggetto e quantità). Nessun testo visibile in ascolto.
    for j in range(5):
        obj=OBJECTS[(form+j)%len(OBJECTS)];n=(form//len(OBJECTS)+j)%5+1;num=NUM[n-1]
        h=f'{s}有{num}{obj[3]}{obj[0]}。';it=f'{si} ha {NUMIT[n-1]} {obj[1]}.'
        opts=[picopt('A',obj,n),picopt('B',OBJECTS[(form+j+1)%len(OBJECTS)],n),picopt('C',obj,n%5+1)]
        rng.shuffle(opts)
        # Le lettere seguono l'ordine a schermo; la chiave segue l'immagine.
        correct=next(k for k,o in enumerate(opts) if o['id']=='A')
        for k,o in enumerate(opts):o['id']='ABC'[k]
        add(1,j,None,[sentence(h,it)],opts,'ABC'[correct],f'La frase dice: {it} Le altre immagini cambiano l’oggetto oppure la quantità.')
    # 2. Domanda ascoltata -> risposta scritta: tipo di informazione richiesto.
    place,pi=PLACES[form%len(PLACES)];obj=OBJECTS[form%len(OBJECTS)];time,ti=TIMES[form%5]
    question_sets=[
        (f'{s}在哪儿工作？',f'Dove lavora {si}?',[(f'在{place}工作。',f'Lavora a/in {pi}.'),('三十岁。','Trent’anni.'),('五块钱。','Cinque yuan.')], 'Dove richiede un luogo; età e prezzo rispondono ad altre domande.'),
        (f'{s}的{obj[0]}多少钱？',f'Quanto costa l’oggetto di {si}?',[('十块钱。','Dieci yuan.'),('十点。','Le dieci.'),('十岁。','Dieci anni di età.')], 'La domanda chiede il prezzo: denaro, ora ed età usano unità diverse.'),
        (f'{time}{s}想吃什么？',f'Che cosa vuole mangiare {si} {ti}?',[('想吃面条儿。','Vuole mangiare spaghetti.'),('想喝水。','Vuole bere acqua.'),('想看书。','Vuole leggere.')], 'La domanda chiede che cosa mangiare, non bere o leggere.'),
        (f'{s}家有几口人？',f'Quante persone ci sono nella famiglia di {si}?',[('有四口人。','Ci sono quattro persone.'),('有四本书。','Ci sono quattro libri.'),('现在四点。','Ora sono le quattro.')], 'Il classificatore della famiglia richiede un numero di persone.'),
        (f'{s}{time}几点去{place}？',f'A che ora va {si} a/in {pi} {ti}?',[('八点去。','Va alle otto.'),('去学校。','Va a scuola.'),('是学生。','È studente.')], 'La domanda chiede un’ora. Un luogo o una professione non rispondono.')]
    for j,(h,it,choices,why) in enumerate(question_sets):
        order=list(range(3));rng.shuffle(order);opts=[textopt('ABC'[k],*choices[idx]) for k,idx in enumerate(order)]
        add(2,j,None,[sentence(h,it)],opts,'ABC'[order.index(0)],why)
    # 3. Cinque dialoghi, sei immagini condivise; F è consumata dall'esempio.
    objs=[OBJECTS[(form+j)%len(OBJECTS)] for j in range(6)];counts=[(form+j)%5+1 for j in range(6)]
    opts=[picopt('ABCDEF'[j],o,counts[j]) for j,o in enumerate(objs)]
    example=sentence(f'{s}有{NUM[counts[5]-1]}{objs[5][3]}{objs[5][0]}。',f'Esempio: {si} ha {counts[5]} {objs[5][1]}.')
    for j,obj in enumerate(objs[:5]):
        h=f'{s}有{obj[0]}吗？';a=f'有，{s}有{NUM[counts[j]-1]}{obj[3]}{obj[0]}。'
        add(3,j,None,[sentence(h,f'{si} ha {obj[1]}?'),sentence(a,f'Sì, ne ha {counts[j]}.')],opts,'ABCDEF'[j],f'Nel dialogo si nominano {counts[j]} {obj[1]}. Le altre immagini rappresentano oggetti diversi.',example,'F')
    # 4 e 8. Comprensione di brevi testi; il testo di lettura usa contesti diversi.
    for part in (4,8):
        a=PLACES[(form+(part==8))%len(PLACES)];b=PLACES[(form+2+(part==8))%len(PLACES)];c=PLACES[(form+3+(part==8))%len(PLACES)]
        n=(form+(part==8))%5;nn=(n+2)%5
        day='今天' if part==4 else '明天';otherday='明天' if part==4 else '今天'
        hour='上午' if part==4 else '下午';back='晚上' if part==4 else '下午'
        sets=[
            (f'{s}{day}去{a[0]}，{otherday}去{b[0]}。',f'{si} va a/in {a[1]} {"oggi" if part==4 else "domani"}, a/in {b[1]} l’altro giorno.',f'{s}{day}去哪儿？', 'Dove va nel giorno richiesto?',[a,b,c]),
            (f'{s}有{NUM[n]}个苹果，{other}有{NUM[nn]}个苹果。',f'{si} ha {NUMIT[n]} mele, {oi} ne ha {NUMIT[nn]}.',f'{s}有几个苹果？','Quante mele ha la persona richiesta?',[(NUM[n]+'个',NUMIT[n]),(NUM[nn]+'个',NUMIT[nn]),(NUM[(n+1)%5]+'个',NUMIT[(n+1)%5])]),
            (f'{s}{day}不喝茶，喝水。',f'{si} {"oggi" if part==4 else "domani"} non beve tè, beve acqua.',f'{s}{day}喝什么？','Che cosa beve?', [('水','acqua'),('茶','tè'),('牛奶','latte')]),
            (f'{s}{day}{hour}去学校，{back}回家。',f'{si} va a scuola {"la mattina" if part==4 else "il pomeriggio"}, torna a casa {"la sera" if part==4 else "il pomeriggio"}.',f'{s}{day}什么时候回家？','Quando torna a casa?',[(back,'sera' if part==4 else 'pomeriggio'),('上午','mattina'),('中午','mezzogiorno')]),
            (f'{s}{day}看书，{other}{day}看电视。',f'{si} legge e {oi} guarda la televisione nel giorno indicato.',f'{s}{day}做什么？','Che cosa fa la prima persona?',[('看书','legge'),('看电视','guarda la televisione'),('睡觉','dorme')])]
        for j,(h,it,q,qi,choices) in enumerate(sets):
            order=list(range(3));rng.shuffle(order);opts=[textopt('ABC'[k],*choices[idx]) for k,idx in enumerate(order)]
            prompt=sentence(q,qi)
            add(part,j,prompt,[sentence(h,it)],opts,'ABC'[order.index(0)],f'{it} Rispondi alla persona e al momento richiesti: le altre opzioni non corrispondono a quel dettaglio.')
    # 5. Frasi -> sei immagini condivise, diverse dal gruppo di ascolto.
    opts=[picopt('ABCDEF'[j],o,counts[(j+2)%6]) for j,o in enumerate(objs)]
    example=sentence(f'{other}买{NUM[counts[1]-1]}{objs[5][3]}{objs[5][0]}。','Esempio: compra gli oggetti rappresentati in F.')
    for j,obj in enumerate(objs[:5]):
        n=counts[(j+2)%6]
        add(5,j,sentence(f'{s}{time}买{NUM[n-1]}{obj[3]}{obj[0]}。',f'{si} compra {n} {obj[1]} {ti}.'),[],opts,'ABCDEF'[j],f'La frase indica l’acquisto di {n} {obj[1]}; le altre immagini non mostrano lo stesso oggetto.',example,'F')
    # 6. Banca condivisa di sei risposte, con l'esempio F.
    pairs=[(f'{s}{day}在哪儿？',f'在{place}。',f'Dove si trova {si}?',f'È a/in {pi}.'),
           (f'{s}今年几岁？',('三十' if form<10 else '四十')+('' if form%10==0 else ['零','一','二','三','四','五','六','七','八','九'][form%10])+'岁。',f'Quanti anni ha {si}?',f'{30+form} anni.'),
           (f'{s}的书多少钱？',f'{NUM[form%5]}块钱。','Quanto costa il libro?',f'{NUMIT[form%5]} yuan.'),
           (f'{s}{day}几点上课？',f'{NUM[form%5]}点。','A che ora inizia la lezione?',f'Alle {NUMIT[form%5]}.'),
           (f'{s}问：这个{obj[0]}是谁的？', '是我的。','Di chi è l’oggetto indicato?','È mio.')]
    opts=[textopt('ABCDEF'[j],a,it) for j,(_,a,_,it) in enumerate(pairs)]+[textopt('F','不冷，很热。','Non fa freddo, fa caldo.')]
    example=sentence(f'{time}冷吗？',f'Fa freddo {ti}?')
    for j,(h,a,it,ai) in enumerate(pairs):add(6,j,sentence(h,it),[],opts,'ABCDEF'[j],f'La domanda chiede: {it} La risposta adatta è: {ai} Le altre risposte danno un tipo di informazione diverso.',example,'F')
    # 7. Sei parole condivise per cinque frasi e un esempio.
    bank=[('在','essere in'),('有','avere'),('喝','bere'),('本','classificatore per libri'),('很','molto'),('和','e')]
    opts=[textopt('ABCDEF'[j],h,it) for j,(h,it) in enumerate(bank)]
    example=sentence(f'{s}（ ）{other}都是学生。','Esempio: le due persone sono entrambe studenti.')
    fills=[(f'{s}{time}（ ）{place}。',f'{si} si trova a/in {pi} {ti}.'),
           (f'{s}（ ）{NUM[form%5]}个杯子。',f'{si} ha {NUMIT[form%5]} bicchieri.'),
           (f'{s}{time}想（ ）茶。',f'{si} vuole bere tè {ti}.'),
           (f'这是{s}的{NUM[form%5]}（ ）书。',f'Questi sono i libri di {si}.'),
           (f'{s}的{obj[0]}（ ）大。',f'L’oggetto di {si} è grande.')]
    for j,(h,it) in enumerate(fills):add(7,j,sentence(h,it),[],opts,'ABCDEF'[j],f'{it} Qui serve {bank[j][1]}. Le altre parole della banca hanno una funzione diversa.',example,'F')
    qs.sort(key=lambda q:q['part'])
    assert len(qs)==40 and all(sum(q['part']==p for q in qs)==5 for p in range(1,9))
    FORMS.append(dict(id=form+1,reserved=form<8,questions=qs))
# Non contare la stessa domanda ripetuta come un nuovo contenuto.
sigs=[]
for f in FORMS:
 for q in f['questions']:
  sigs.append((q['part'],q['prompt']['hanzi'] if q['prompt'] else '',tuple(s['hanzi'] for s in q['stimulus'])))
assert len(set(sigs))==800,('duplicati',800-len(set(sigs)))
# Ricerca lessicale deterministica, non una verifica linguistica.
assert not UNKNOWN,sorted(UNKNOWN)
config=dict(readings=2,firstPauseSeconds=10,otherPauseSeconds=15,questionSlotSeconds=[28,34,36,34],personalDataSeconds=300,paperTransferSeconds=180,readingSeconds=1200,measurementSource='pause e ripetizioni misurate sui file ufficiali; non dichiarate da CTI',audio='AVSpeechSynthesizer provvisorio',humanReviewed=False)
(ROOT/'ios/Bubu/Resources/exam-bank.json').write_text(json.dumps(dict(config=config,forms=FORMS),ensure_ascii=False,indent=2)+'\n')
(ROOT/'ios/Content/exam_pinyin.txt').write_text('\n'.join(sorted(set(CORPUS)))+'\n')
print('800 quesiti originali a modelli: 320 riservati + 480 allenamento; nessuna revisione umana dichiarata.')
