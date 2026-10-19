#!/usr/bin/env python3
"""Vocabolario illustrato HSK 1–3 secondo il programma d'esame ufficiale 2025 (300/500/1000 parole).

Traduzioni ed emoji riprese da hsk/out/ e vocab/ (stessa lettura del pinyin ufficiale quando possibile),
più hsk2025/missing_out.txt per le parole nuove. Il pinyin è quello ufficiale del 考试大纲.

Uso:  ../.venv/bin/python build_vocab_2025.py
"""
import glob
import json
import os
import subprocess
import sys
import unicodedata

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)


# voci che il programma ufficiale distingue per significato (stesso carattere, numero diverso)
SENSE = {
    33: ('ora (dell\'orologio); punto', '🕐'), 336: ('ordinare (cibo); toccare (lo schermo)', '-'),
    82: ('sapere (fare); potere (è probabile)', '-'), 683: ('riunione', '👥'),
    218: ('pronto? (al telefono); ehi', '📞'), 311: ('non (fare)! (divieto)', '🚫'),
    327: ('colpire; giocare (a palla); fare una telefonata', '👊'), 334: ('aspettare', '⏳'),
    350: ('passare, andare (di là)', '-'), 660: ('il passato', '-'),
    357: ('spendere (soldi, tempo)', '💸'), 358: ('fiore', '🌸'),
    403: ('lato, parte (前面, 上面)', '-'), 486: ('fermata, stazione', '🚏'), 966: ('stare in piedi', '🧍'),
    583: ('ottenere, ricevere', '-'),
}


def norm(s):
    return unicodedata.normalize('NFC', s).replace(' ', '').replace("'", '').lower()


def main():
    data = json.load(open(os.path.join(HERE, 'hsk2025.json'), encoding='utf-8'))
    tr = {}
    for f in sorted(glob.glob(os.path.join(ROOT, 'hsk', 'out', '*.txt'))) + \
            sorted(glob.glob(os.path.join(ROOT, 'vocab', '*.txt'))) + [os.path.join(HERE, 'missing_out.txt')]:
        if not os.path.exists(f):
            continue
        for line in open(f, encoding='utf-8'):
            p = [x.strip() for x in line.split('|')]
            if len(p) == 5:
                tr.setdefault(p[0], []).append(p)
    l1 = {}
    units = os.path.join(HERE, 'l1_units.txt')
    if os.path.exists(units):   # le traduzioni riviste dell'HSK 1 hanno la precedenza
        for line in open(units, encoding='utf-8'):
            p = [x.strip() for x in line.split('|')]
            if len(p) == 6:
                l1[int(p[0])] = (p[4], p[5])
    out_dir = os.path.join(HERE, 'final')
    os.makedirs(out_dir, exist_ok=True)
    missing = []
    for lvl in (1, 2, 3):
        lines = [f'@ HSK {lvl} | {lvl}️⃣']
        for w in (x for x in data['words'] if x['level'] == lvl):
            cands = tr.get(w['hanzi'], [])
            best = next((c for c in cands if norm(c[1]) == norm(w['pinyin'])), cands[0] if cands else None)
            it, em = (best[2], best[3]) if best else ('', '-')
            if w['n'] in l1:
                it, em = l1[w['n']]
            if w['n'] in SENSE:
                it, em = SENSE[w['n']]
            if not it:
                missing.append(w['hanzi'])
            lines.append(f"{w['hanzi']} | {w['pinyin']} | {it} | {em or '-'} | {lvl}")
        open(os.path.join(out_dir, f'hsk{lvl}.txt'), 'w', encoding='utf-8').write('\n'.join(lines) + '\n')
    if missing:
        print('senza traduzione:', ' '.join(missing))
    subprocess.run([sys.executable, os.path.join(ROOT, 'build_vocab.py'), '--hsk', '--src', out_dir,
                    '--out', os.path.join(ROOT, 'Vocabolario_HSK1-3_esame2026.pdf'),
                    '--title2', 'HSK 1–3 · esame dal 2026',
                    '--subtitle', 'Le 1000 parole del programma d\'esame ufficiale (2025), livello per livello'],
                   check=True)


if __name__ == '__main__':
    main()
