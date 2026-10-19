#!/usr/bin/env python3
"""Prepara data.js per il prototipo dell'app a partire dai dati reali del progetto.

- parole HSK 1 dal programma ufficiale 2025 (hsk2025/hsk2025.json) con italiano ed emoji
  (hsk2025/l1_units.txt se esiste, altrimenti hsk2025/l1_words_input.txt);
- per ogni parola, l'esempio più breve del libro (content/, cheatsheet/) che usa solo
  caratteri del livello 1;
- toni per carattere (per colorare hanzi e pinyin).

Uso:  ../.venv/bin/python build_data.py
"""
import glob
import json
import os
import re
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)
sys.path.insert(0, ROOT)
from build_vocab import syllables, tone  # noqa: E402

UNITS = [
    ('问答个人基本信息', 'Presentarsi', '👋',
     ['Dire nome, nazionalità ed età', 'Parlare della famiglia e degli amici',
      'Dire cosa ti piace e cosa sai fare']),
    ('问答事件信息', 'Date, orari e numeri', '🗓️',
     ['Dire data e ora', 'Dare un numero di telefono', 'Dire dove e quando succede qualcosa']),
    ('问答物品信息', 'Gli oggetti', '🎒',
     ['Nominare oggetti di casa e di scuola', 'Dire quanti sono, se grandi o piccoli',
      'Dire di chi è un oggetto']),
    ('问答天气', 'Il tempo atmosferico', '🌦️',
     ['Chiedere che tempo fa', 'Dire se fa caldo o freddo, se piove o nevica']),
    ('问答环境信息', 'Luoghi e ambienti', '🏫',
     ['Descrivere un luogo: grande, piccolo, bello', 'Dire dove si trova qualcosa']),
    ('日常言语交往', 'Saluti e cortesia', '🙏',
     ['Salutare, ringraziare, scusarsi', 'Fare una richiesta semplice', 'Rispondere al telefono']),
    ('问答饮食喜好', 'Cibo e gusti', '🍜',
     ['Dire cosa ti piace mangiare e bere', 'Ordinare al ristorante, parlare dei pasti']),
    ('问答出行信息', 'Spostamenti', '🚕',
     ['Dire come vai al lavoro o a scuola', 'Chiedere la strada']),
    ('问答商品信息', 'Fare acquisti', '🛒',
     ['Chiedere il prezzo', 'Dire cosa vuoi comprare']),
    ('告知生病、探病', 'Salute', '🤒',
     ['Dire che stai male', 'Augurare a qualcuno di riposarsi']),
    ('交流休闲活动', 'Tempo libero', '🎬',
     ['Parlare di hobby: leggere, cantare, guardare film']),
    ('介绍学习情况', 'Lo studio', '📚',
     ['Dire cosa studi e dove', 'Leggere un orario delle lezioni']),
    ('交流学校情况、课后活动', 'La scuola e il doposcuola', '🧑‍🏫',
     ['Parlare di insegnanti e compagni', 'Dire cosa fai dopo le lezioni']),
    ('交流工作信息', 'Il lavoro', '💼',
     ['Dire che lavoro fai, dove e quando']),
    ('问答中国传统饮食', 'La cucina cinese', '🥟',
     ['Parlare di 包子, 饺子, 面条儿 e tè', 'Leggere un menù semplice']),
]

UNIT_PY = ['wèndá gèrén jīběn xìnxī', 'wèndá shìjiàn xìnxī', 'wèndá wùpǐn xìnxī', 'wèndá tiānqì', 'wèndá huánjìng xìnxī', 'rìcháng yányǔ jiāowǎng', 'wèndá yǐnshí xǐhào', 'wèndá chūxíng xìnxī', 'wèndá shāngpǐn xìnxī', 'gàozhī shēngbìng, tànbìng', 'jiāoliú xiūxián huódòng', 'jièshào xuéxí qíngkuàng', 'jiāoliú xuéxiào qíngkuàng, kèhòu huódòng', 'jiāoliú gōngzuò xìnxī', 'wèndá Zhōngguó chuántǒng yǐnshí']

# punti grammaticali dell'HSK 1 (raggruppati dal 语法大纲 ufficiale), con l'unità in cui si studiano
GRAMMAR = [
    ('shi', 1, 'La frase con 是 shì', 'A è B: identità e categoria'),
    ('ma', 1, 'Domande con 吗 ma', 'Trasforma una frase in una domanda sì/no'),
    ('shenme', 1, 'Parole interrogative: 什么 shénme, 谁 shéi, 哪儿 nǎr', 'Domande aperte senza cambiare l\'ordine'),
    ('ne', 1, 'E tu? Domande con 呢 ne', 'Ripetere la domanda: «e tu?»'),
    ('you', 1, 'Avere: 有 yǒu e 没有 méiyǒu', 'Possesso ed esistenza'),
    ('num', 2, 'Numeri, date e ore', '年 nián, 月 yuè, 号 hào, 点 diǎn, 分 fēn'),
    ('cl', 3, 'Numero + classificatore + nome', '个 ge, 本 běn, 杯 bēi, 块 kuài…'),
    ('de', 3, 'Il possesso con 的 de', '我的书 wǒ de shū'),
    ('hen', 4, 'Aggettivi con 很 hěn', 'Nessun «essere» davanti all\'aggettivo'),
    ('zai', 5, 'Dove: 在 zài + luogo + 上 shàng / 里 lǐ', 'Essere in un luogo e posizioni'),
    ('neng', 6, 'Modali: 会 huì, 能 néng, 可以 kěyǐ, 想 xiǎng, 要 yào', 'Sapere, potere, volere'),
    ('le', 7, 'Azione compiuta: 了 le', 'Dopo il verbo e a fine frase'),
    ('liandong', 8, 'Due verbi in fila', '去 qù + luogo + fare qualcosa'),
    ('qian', 9, 'Prezzi: 块 kuài, 元 yuán, 多少钱 duōshao qián', 'Chiedere e dire quanto costa'),
    ('zhengzai', 11, 'In corso: 在 zài / 正在 zhèngzài + V (+ 呢 ne)', 'Sto facendo…'),
    ('ye', 13, 'Anche e tutti: 也 yě, 都 dōu, 还 hái', 'Posizione prima del verbo'),
]


def pinyin_segments(py, sy):
    """[[testo, tono], …] che coprono tutto il pinyin; tono -1 = separatore."""
    if not sy:
        return [[py, -1]]
    out, rest = [], py
    for _, syl in sy:
        i = rest.lower().find(syl.lower())
        if i < 0:
            return [[py, -1]]
        if i:
            out.append([rest[:i], -1])
        out.append([rest[i:i + len(syl)], tone(syl)])
        rest = rest[i + len(syl):]
    if rest:
        out.append([rest, -1])
    return out


def load_words():
    data = json.load(open(os.path.join(ROOT, 'hsk2025', 'hsk2025.json'), encoding='utf-8'))
    l1 = [w for w in data['words'] if w['level'] == 1]
    src = os.path.join(ROOT, 'hsk2025', 'l1_units.txt')
    extra = {}
    if os.path.exists(src):
        for line in open(src, encoding='utf-8'):
            p = [x.strip() for x in line.split('|')]
            if len(p) == 6:
                extra[int(p[0])] = {'unit': int(p[3]), 'it': p[4], 'emoji': '' if p[5] == '-' else p[5]}
    else:
        for line in open(os.path.join(ROOT, 'hsk2025', 'l1_words_input.txt'), encoding='utf-8'):
            p = [x.strip() for x in line.split('|')]
            if len(p) == 6:
                extra[int(p[0])] = {'unit': 1 + (int(p[0]) * 7) % 15, 'it': p[4],
                                    'emoji': '' if p[5] in ('-', '') else p[5]}
    return l1, extra, data['recognition_chars']['一级']


def examples():
    out = []
    for f in sorted(glob.glob(os.path.join(ROOT, 'content', '*.txt'))) + \
            sorted(glob.glob(os.path.join(ROOT, 'cheatsheet', '*.txt'))):
        for line in open(f, encoding='utf-8'):
            if line.startswith('ex:'):
                p = [x.strip().replace('**', '') for x in line[3:].split(' | ')]
                if len(p) == 3 and 'A：' not in p[0] and all(p):
                    out.append(p)
    return out


def main():
    l1, extra, l1chars_list = load_words()
    l1chars = set(l1chars_list)
    exs = examples()
    l1_word_chars = set(''.join(w['hanzi'] for w in l1))
    allowed = l1chars | l1_word_chars
    words = []
    for w in l1:
        e = extra.get(w['n'], {})
        sy = syllables(w['hanzi'], w['pinyin'])
        tones = [tone(s) for _, s in sy] if sy else []
        pyseg = pinyin_segments(w['pinyin'], sy)
        best = None
        for hz, py, it in exs:
            han = re.findall(r'[一-鿿]', hz)
            if w['hanzi'] in hz and 3 <= len(han) <= 12 and all(c in allowed for c in han):
                if best is None or len(hz) < len(best[0]):
                    best = (hz, py, it)
        words.append({'n': w['n'], 'hz': w['hanzi'], 'py': w['pinyin'], 'pos': w['pos'],
                      'it': e.get('it', ''), 'emoji': e.get('emoji', ''), 'unit': e.get('unit', 1),
                      'tones': tones, 'pyseg': pyseg, 'ex': best})
    units = [{'n': i + 1, 'cn': cn, 'cnpy': UNIT_PY[i], 'it': it, 'emoji': em, 'cando': cd,
              'words': sum(1 for w in words if w['unit'] == i + 1)}
             for i, (cn, it, em, cd) in enumerate(UNITS)]
    # caratteri del livello 1 con la lettura presa dalle parole (più affidabile del dizionario)
    reading = {}
    for w in sorted(words, key=lambda w: len(w['hz'])):
        segs = [s for s in w['pyseg'] if s[1] >= 0]
        if len(segs) == len(w['hz']):
            for c, (syl, _) in zip(w['hz'], segs):
                reading.setdefault(c, syl.lower())
    from pypinyin import pinyin as _pinyin
    chars1 = [{'c': c, 'py': reading.get(c) or _pinyin(c)[0][0],
               'words': [w['hz'] for w in words if c in w['hz']][:6]}
              for c in l1chars_list]
    levels = [
        {'id': '1', 'cn': '一级', 'words': 300, 'new': 300, 'chars': 246, 'tag': 'Principiante'},
        {'id': '2', 'cn': '二级', 'words': 500, 'new': 200, 'chars': 371, 'tag': 'Principiante'},
        {'id': '3', 'cn': '三级', 'words': 1000, 'new': 500, 'chars': 655, 'tag': 'Elementare'},
        {'id': '4', 'cn': '四级', 'words': 2000, 'new': 1000, 'chars': 1096, 'tag': 'Intermedio'},
        {'id': '5', 'cn': '五级', 'words': 3600, 'new': 1600, 'chars': 1527, 'tag': 'Intermedio'},
        {'id': '6', 'cn': '六级', 'words': 5400, 'new': 1800, 'chars': 1940, 'tag': 'Avanzato'},
        {'id': '7–9', 'cn': '七—九级', 'words': 11000, 'new': 5600, 'chars': 3088, 'tag': 'Superiore'},
    ]
    grammar = [{'id': g[0], 'unit': g[1], 'title': g[2], 'sub': g[3]} for g in GRAMMAR]
    js = 'window.DATA = ' + json.dumps({'levels': levels, 'units': units, 'words': words,
                                         'grammar': grammar, 'chars': chars1},
                                        ensure_ascii=False) + ';\n'
    open(os.path.join(HERE, 'data.js'), 'w', encoding='utf-8').write(js)
    with_ex = sum(1 for w in words if w['ex'])
    print(f'{len(words)} parole, {with_ex} con esempio, unità: {[u["words"] for u in units]}')


if __name__ == '__main__':
    main()
