import importlib.util,json
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2]
spec=importlib.util.spec_from_file_location('bank',ROOT/'ios/Scripts/build_exam_bank.py');bank=importlib.util.module_from_spec(spec);spec.loader.exec_module(bank)
rows=[
([('你好，我是学生。你呢？','Ciao, sono studente. E tu?'),('我也是学生。我学习汉语。','Anch’io sono studente. Studio cinese.')],'Che cosa studia la seconda persona?',['Cinese','Medicina','Non lo dice'],0),
([('我们今天几点上课？','A che ora abbiamo lezione oggi?'),('我们八点上课。','Abbiamo lezione alle otto.')],'A che ora inizia la lezione?',['Alle sette','Alle otto','Alle nove'],1),
([('你的杯子在哪儿？','Dov’è il tuo bicchiere?'),('在桌子上。我的杯子很小。','È sul tavolo. Il mio bicchiere è piccolo.')],'Dov’è il bicchiere?',['Sotto il tavolo','A scuola','Sul tavolo'],2),
([('今天冷吗？','Oggi fa freddo?'),('今天不冷。今天下雨。','Oggi non fa freddo. Piove.')],'Che tempo fa?',['Piove','Nevica','Non lo dice'],0),
([('学校在哪儿？','Dov’è la scuola?'),('学校在医院前边。','La scuola è davanti all’ospedale.')],'Dov’è la scuola?',['Dietro all’ospedale','Davanti all’ospedale','Dentro all’ospedale'],1),
([('谢谢你。','Grazie.'),('不客气。再见！','Prego. Arrivederci!')],'Quale situazione descrive il dialogo?',['Un acquisto','Una visita medica','Un ringraziamento e un saluto'],2),
([('早上你吃什么？','Che cosa mangi la mattina?'),('我吃鸡蛋，喝牛奶。','Mangio uova e bevo latte.')],'Che cosa beve la seconda persona?',['Latte','Tè','Acqua'],0),
([('你怎么去公司？','Come vai in azienda?'),('我坐出租车去公司。','Vado in azienda in taxi.')],'Quale mezzo usa?',['Aereo','Taxi','Treno'],1),
([('这本书多少钱？','Quanto costa questo libro?'),('十块钱。','Dieci yuan.'),('我要买这本书。','Voglio comprare questo libro.')],'Quanto costa il libro?',['Otto yuan','Cento yuan','Dieci yuan'],2),
([('我病了，今天想休息。','Oggi non sto bene. Voglio riposare.'),('你喝水吗？','Bevi dell’acqua?')],'Che cosa vuole fare la prima persona?',['Riposare','Studiare','Lavorare'],0),
([('你喜欢做什么？','Che cosa ti piace fare?'),('我喜欢看电影，也喜欢唱歌。','Mi piace guardare film e anche cantare.')],'Quali attività le piacciono?',['Leggere e nuotare','Guardare film e cantare','Lavorare e studiare'],1),
([('你学习什么？','Che cosa studi?'),('我学习汉语。我早上读书。','Studio cinese. Leggo la mattina.')],'Quando legge?',['La sera','Il pomeriggio','La mattina'],2),
([('我们的老师在哪儿？','Dov’è il nostro insegnante?'),('他在学校。他是我爸爸的朋友。','È a scuola. È un amico di mio padre.')],'Dov’è l’insegnante?',['A scuola','In ospedale','A casa'],0),
([('你在哪儿工作？','Dove lavori?'),('我在医院工作。我是医生。','Lavoro in ospedale. Sono medico.')],'Che lavoro fa la seconda persona?',['Insegnante','Medico','Non lo dice'],1),
([('你喜欢吃饺子吗？','Ti piace mangiare ravioli?'),('我喜欢吃饺子，也喜欢喝茶。','Mi piace mangiare ravioli e anche bere tè.')],'Che cosa le piace bere?',['Latte','Caffè','Tè'],2)
]
out=[]
for i,(lines,question,choices,answer) in enumerate(rows,1):
 converted=[bank.sentence(h,it) for h,it in lines]
 out.append(dict(id=i,title=bank.DATA['units'][i-1]['title'],lines=converted,question=question,choices=choices,answer=answer,wordIDs=sorted(set(w for l in converted for w in l['wordIDs']))))
assert not bank.UNKNOWN,sorted(bank.UNKNOWN)
(ROOT/'ios/Bubu/Resources/dialogues.json').write_text(json.dumps(out,ensure_ascii=False,indent=2)+'\n')
(ROOT/'ios/Content/dialogues_pinyin.txt').write_text('\n'.join('ex: '+l['hanzi']+' | '+l['pinyin']+' | '+l['italian'] for d in out for l in d['lines'])+'\n')
print('15 dialoghi originali, lessico HSK 1 verificato.')
