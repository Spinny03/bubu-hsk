#!/usr/bin/env python3
"""Impagina il vocabolario illustrato: schede con emoji, hanzi e pinyin colorati per tono.

Legge vocab/*.txt (formato in SPEC_EXTRA.md, sezione B) e produce Vocabolario_illustrato_cinese.pdf.
Le emoji sono disegnate da Noto Color Emoji con Pillow e messe in cache in vocab/.emoji/.

Uso:  .venv/bin/python build_vocab.py [--out FILE]
"""
import argparse
import glob
import os
import re
import sys
import unicodedata

from PIL import Image, ImageDraw, ImageFont
from reportlab.lib import colors
from reportlab.lib.enums import TA_CENTER
from reportlab.lib.pagesizes import A4
from reportlab.lib.styles import ParagraphStyle
from reportlab.lib.units import mm
from reportlab.lib.utils import ImageReader
from reportlab.platypus import (BaseDocTemplate, Flowable, Frame, NextPageTemplate, PageBreak,
                                PageTemplate, Paragraph, Spacer)

import build_pdf as bp
from build_pdf import ACCENT, ACCENT_DARK, GREY, INK, LIGHT_RULE, inline, para
from check_pinyin import HAN, plain as toneless, readings

BASE = os.path.dirname(os.path.abspath(__file__))
EMOJI_FONT = '/usr/share/fonts/truetype/noto/NotoColorEmoji.ttf'
CACHE = os.path.join(BASE, 'vocab', '.emoji')
TITLE = 'Vocabolario illustrato del cinese mandarino'

PAGE_W, PAGE_H = A4
M = 12 * mm
TOP = 17 * mm
COLS = 4
GAP = 3 * mm
CARD_W = (PAGE_W - 2 * M - (COLS - 1) * GAP) / COLS
CARD_H = 38 * mm

TONE_COLORS = {1: '#D1342F', 2: '#E08A00', 3: '#2E8B3A', 4: '#2C62B8', 0: '#7A7A7A'}
TONE_OF = {}
for vowel, marks in {'a': 'āáǎà', 'e': 'ēéěè', 'i': 'īíǐì', 'o': 'ōóǒò', 'u': 'ūúǔù',
                     'ü': 'ǖǘǚǜ'}.items():
    for t, ch in enumerate(marks, 1):
        TONE_OF[ch] = t
        TONE_OF[ch.upper()] = t

S = {
    'hz': ParagraphStyle('hz', fontName='CJK', fontSize=19, leading=23, alignment=TA_CENTER),
    'hz_big': ParagraphStyle('hz_big', fontName='CJK', fontSize=27, leading=32, alignment=TA_CENTER),
    'py': ParagraphStyle('py', fontName='Sans-Bold', fontSize=9.6, leading=11.5, alignment=TA_CENTER),
    'it': ParagraphStyle('it', fontName='Sans', fontSize=8.2, leading=9.8, alignment=TA_CENTER,
                         textColor=INK, wordWrap='CJK'),
    'theme': ParagraphStyle('theme', fontName='Sans-Bold', fontSize=17, leading=21,
                            textColor=ACCENT_DARK),
    'legend': ParagraphStyle('legend', fontName='Sans', fontSize=9, leading=13, textColor=INK),
    'letters': ParagraphStyle('letters', fontName='Sans', fontSize=12, leading=18, leftIndent=8),
    'toc': ParagraphStyle('toc', fontName='Sans', fontSize=10.5, leading=16, textColor=INK),
}
WARN = []


# --------------------------------------------------------------------------- emoji
_font = None


def emoji_image(e):
    """PNG ritagliato dell'emoji (None se il font non la disegna come un unico glifo)."""
    global _font
    os.makedirs(CACHE, exist_ok=True)
    path = os.path.join(CACHE, '-'.join(f'{ord(c):x}' for c in e) + '.png')
    if os.path.exists(path):
        return path if os.path.getsize(path) else None
    _font = _font or ImageFont.truetype(EMOJI_FONT, 109)
    im = Image.new('RGBA', (400, 160), (0, 0, 0, 0))
    ImageDraw.Draw(im).text((10, 10), e, font=_font, embedded_color=True)
    box = im.getbbox()
    if not box or (box[2] - box[0]) > 150:   # vuota, o sequenza resa come più glifi affiancati
        open(path, 'wb').close()
        return None
    im.crop(box).save(path)
    return path


# --------------------------------------------------------------------------- toni
def syllables(hz, py):
    """Allinea il pinyin ai caratteri: lista di (carattere, sillaba) o None."""
    chars = HAN.findall(hz)
    if len(chars) != len(hz) or not chars:
        return None
    toned = re.sub(r"[^a-zA-ZüÀ-ɏ]", '', unicodedata.normalize('NFC', py))
    alts = [readings(c) | {'r'} if c == '儿' else readings(c) for c in chars]
    pat = ''.join('(' + '|'.join(sorted({re.escape(toneless(a)) for a in al}, key=len, reverse=True))
                  + ')' for al in alts)
    m = re.fullmatch(pat, toneless(toned))
    if not m:
        return None
    return [(c, toned[m.start(i + 1):m.end(i + 1)]) for i, c in enumerate(chars)]


def tone(syl):
    return next((TONE_OF[c] for c in syl if c in TONE_OF), 0)


def colored_hanzi(hz, sylls):
    if not sylls:
        return inline(hz)
    return ''.join(f'<font name="CJK" color="{TONE_COLORS[tone(s)]}">{c}</font>' for c, s in sylls)


def colored_pinyin(py, sylls):
    if not sylls:
        return inline(py)
    out, rest = [], unicodedata.normalize('NFC', py)
    for _, s in sylls:   # colora ogni sillaba lasciando spazi e trattini come sono
        i = rest.lower().find(s.lower())
        if i < 0:
            return inline(py)
        out.append(bp.escape(rest[:i]))
        out.append(f'<font color="{TONE_COLORS[tone(s)]}">{bp.escape(rest[i:i + len(s)])}</font>')
        rest = rest[i + len(s):]
    out.append(bp.escape(rest))
    return bp.apply_fonts(''.join(out))


# --------------------------------------------------------------------------- flowable
class CardRow(Flowable):
    def __init__(self, words):
        super().__init__()
        self.words = words

    def wrap(self, aw, ah):
        return PAGE_W - 2 * M, CARD_H + GAP

    def draw(self):
        c = self.canv
        for i, w in enumerate(self.words):
            x, y = i * (CARD_W + GAP), GAP
            c.setFillColor(colors.white)
            c.setStrokeColor(LIGHT_RULE)
            c.setLineWidth(0.6)
            c.roundRect(x, y, CARD_W, CARD_H, 2.5 * mm, stroke=1, fill=1)
            # livello HSK
            c.setFillColor(colors.HexColor('#EFE7DD'))
            c.roundRect(x + CARD_W - 11 * mm, y + CARD_H - 5.6 * mm, 9.5 * mm, 4 * mm, 1.2 * mm,
                        stroke=0, fill=1)
            c.setFillColor(GREY)
            c.setFont('Sans-Bold', 6.3)
            c.drawCentredString(x + CARD_W - 6.25 * mm, y + CARD_H - 4.6 * mm, f'HSK {w["lvl"]}')
            img = emoji_image(w['emoji']) if w['emoji'] else None
            if w['emoji'] and not img:
                WARN.append(f'emoji non disponibile per {w["hz"]}: {w["emoji"]}')
            sylls = syllables(w['hz'], w['py'])
            hz_style = S['hz'] if img or len(w['hz']) > 4 else S['hz_big']
            paras = [Paragraph(colored_hanzi(w['hz'], sylls), hz_style),
                     Paragraph(colored_pinyin(w['py'], sylls), S['py']),
                     para(inline(w['it']), S['it'], raw=w['it'])]
            side = 12.5 * mm if img else 0
            hs = [p.wrap(CARD_W - 4 * mm, CARD_H)[1] for p in paras]
            total = side + (1 * mm if img else 0) + sum(hs) + 0.6 * mm * (len(hs) - 1)
            top = y + (CARD_H + total) / 2 - 0.5 * mm   # contenuto centrato in verticale
            if img:
                c.drawImage(ImageReader(img), x + (CARD_W - side) / 2, top - side, side, side,
                            mask='auto', preserveAspectRatio=True, anchor='c')
                top -= side + 1 * mm
            for p, h in zip(paras, hs):
                p.drawOn(c, x + 2 * mm, top - h)
                top -= h + 0.6 * mm


class ThemeHeader(Flowable):
    def __init__(self, title, emoji, key):
        super().__init__()
        self.title, self.emoji, self.key = title, emoji, key

    def wrap(self, aw, ah):
        return aw, 16 * mm

    def draw(self):
        c = self.canv
        c.bookmarkPage(self.key)
        c.addOutlineEntry(self.title, self.key, level=0)
        c.setFillColor(colors.HexColor('#FBF1E1'))
        c.roundRect(0, 2 * mm, PAGE_W - 2 * M, 13 * mm, 2.5 * mm, stroke=0, fill=1)
        c.setFillColor(ACCENT)
        c.rect(0, 2 * mm, 1.4 * mm, 13 * mm, stroke=0, fill=1)
        img = emoji_image(self.emoji) if self.emoji else None
        tx = 5 * mm
        if img:
            c.drawImage(ImageReader(img), tx, 3.5 * mm, 10 * mm, 10 * mm, mask='auto',
                        preserveAspectRatio=True, anchor='c')
            tx += 13 * mm
        p = Paragraph(inline(self.title), S['theme'])
        p.wrap(PAGE_W - 2 * M - tx, 13 * mm)
        p.drawOn(c, tx, 6 * mm)


class LetterBar(Flowable):
    """Separatore alfabetico (iniziale del pinyin) dentro un livello HSK."""

    def __init__(self, letter, key):
        super().__init__()
        self.letter, self.key = letter, key
        self.keepWithNext = 1

    def wrap(self, aw, ah):
        return aw, 8 * mm

    def draw(self):
        c = self.canv
        c.bookmarkHorizontal(self.key, 0, 8 * mm)
        c.setFillColor(ACCENT)
        c.circle(3.2 * mm, 4.4 * mm, 3.2 * mm, stroke=0, fill=1)
        c.setFillColor(colors.white)
        c.setFont('Sans-Bold', 10)
        c.drawCentredString(3.2 * mm, 3.1 * mm, self.letter)
        c.setStrokeColor(LIGHT_RULE)
        c.setLineWidth(0.6)
        c.line(8.5 * mm, 4.4 * mm, PAGE_W - 2 * M, 4.4 * mm)


def initial(py):
    return toneless(py.strip()[:1]).upper() or '?'


# --------------------------------------------------------------------------- parsing e documento
def load(src):
    themes = []
    for f in sorted(glob.glob(os.path.join(src, '*.txt'))):
        for n, line in enumerate(open(f, encoding='utf-8'), 1):
            s = line.strip()
            if not s or s.startswith('#'):
                continue
            if s.startswith('@'):
                title, _, e = s[1:].partition('|')
                themes.append({'title': title.strip(), 'emoji': e.strip(), 'words': []})
                continue
            parts = [x.strip() for x in s.split('|')]
            if len(parts) != 5 or not themes:
                WARN.append(f'{os.path.basename(f)}:{n}: riga non valida: {s[:60]}')
                continue
            hz, py, it, e, lvl = parts
            themes[-1]['words'].append({'hz': hz, 'py': py, 'it': it,
                                        'emoji': '' if e in ('-', '') else e, 'lvl': lvl})
    return themes


def decorate(c, doc):
    c.saveState()
    c.setFont('Sans', 7.8)
    c.setFillColor(GREY)
    c.drawString(M, PAGE_H - 10 * mm, TITLE)
    c.setFillColor(ACCENT)
    c.drawRightString(PAGE_W - M, PAGE_H - 10 * mm, getattr(doc, 'theme', ''))
    c.setStrokeColor(LIGHT_RULE)
    c.line(M, PAGE_H - 11.5 * mm, PAGE_W - M, PAGE_H - 11.5 * mm)
    c.setFillColor(GREY)
    c.drawCentredString(PAGE_W / 2, 7 * mm, str(doc.page))
    c.restoreState()


def cover(c, doc):
    c.saveState()
    c.setFillColor(ACCENT)
    c.rect(0, PAGE_H * 0.45, PAGE_W, PAGE_H * 0.55, stroke=0, fill=1)
    c.setFillColor(colors.white)
    c.setFont('CJK', 64)
    c.drawCentredString(PAGE_W / 2, PAGE_H * 0.72, '图解词汇')
    c.setFont('Sans', 13)
    c.drawCentredString(PAGE_W / 2, PAGE_H * 0.72 - 38, 'Tújiě cíhuì')
    emojis = ['🍎', '🐼', '🏠', '🚄', '☕', '📚', '🌙', '👨‍👩‍👧']
    side = 14 * mm
    x0 = PAGE_W / 2 - len(emojis) * (side + 4 * mm) / 2
    for i, e in enumerate(emojis):
        img = emoji_image(e)
        if img:
            c.drawImage(ImageReader(img), x0 + i * (side + 4 * mm), PAGE_H * 0.52, side, side,
                        mask='auto', preserveAspectRatio=True, anchor='c')
    c.setFillColor(INK)
    c.setFont('Sans-Bold', 26)
    c.drawCentredString(PAGE_W / 2, PAGE_H * 0.33, 'Vocabolario illustrato')
    c.drawCentredString(PAGE_W / 2, PAGE_H * 0.33 - 32, doc.title2)
    c.setFont('Sans', 11.5)
    c.setFillColor(GREY)
    c.drawCentredString(PAGE_W / 2, PAGE_H * 0.33 - 62, doc.subtitle)
    c.restoreState()


class VocabDoc(BaseDocTemplate):
    def afterFlowable(self, f):
        if isinstance(f, ThemeHeader):
            self.theme = f.title


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--out', default=os.path.join(BASE, 'Vocabolario_illustrato_cinese.pdf'))
    ap.add_argument('--src', default=os.path.join(BASE, 'vocab'))
    ap.add_argument('--title2', help='seconda riga del titolo in copertina')
    ap.add_argument('--subtitle', help='sottotitolo in copertina')
    ap.add_argument('--hsk', action='store_true',
                    help='sezioni = livelli HSK, parole in ordine alfabetico con separatori per lettera')
    args = ap.parse_args()
    themes = [t for t in load(args.src) if t['words']]
    if not themes:
        sys.exit('nessuna parola in vocab/')
    total = sum(len(t['words']) for t in themes)

    doc = VocabDoc(args.out, pagesize=A4, leftMargin=M, rightMargin=M, topMargin=TOP,
                   bottomMargin=12 * mm, title=TITLE, author='')
    if args.hsk:
        doc.title2 = 'HSK 1–3 (HSK 3.0)'
        doc.subtitle = 'Tutte le parole della lista ufficiale, livello per livello'
    else:
        doc.title2 = 'del cinese mandarino'
        doc.subtitle = f'{total} parole essenziali in {len(themes)} temi · HSK 1–4'
    doc.title2 = args.title2 or doc.title2
    doc.subtitle = args.subtitle or doc.subtitle
    frame = Frame(M, 12 * mm, PAGE_W - 2 * M, PAGE_H - TOP - 12 * mm, leftPadding=0,
                  rightPadding=0, topPadding=0, bottomPadding=0)
    doc.addPageTemplates([PageTemplate('cover', [frame], onPage=cover),
                          PageTemplate('page', [frame], onPageEnd=decorate)])

    story = [NextPageTemplate('page'), PageBreak()]
    legend = ' &nbsp; '.join(f'<font color="{TONE_COLORS[t]}"><b>{n}</b></font>' for t, n in
                             [(1, '1° tono'), (2, '2° tono'), (3, '3° tono'), (4, '4° tono'),
                              (0, 'tono neutro')])
    story += [Paragraph('<b>Come usare questo vocabolario</b>', S['theme']), Spacer(1, 4 * mm),
              Paragraph('Ogni scheda mostra la parola in caratteri semplificati, il pinyin, la '
                        'traduzione italiana e il livello HSK. Quando esiste, un\'immagine aiuta a '
                        'fissare la parola nella memoria visiva: guarda l\'immagine, pronuncia la '
                        'parola ad alta voce e solo dopo controlla la traduzione.', S['legend']),
              Spacer(1, 3 * mm),
              Paragraph('I caratteri e il pinyin sono colorati secondo il tono di ogni sillaba: '
                        + legend, S['legend']),
              Spacer(1, 3 * mm),
              Paragraph(bp.apply_fonts('Per i nomi, il classificatore è indicato tra parentesi '
                                       'quando non è 个 (per esempio «libro (本)»).'), S['legend']),
              Spacer(1, 8 * mm), Paragraph('<b>Livelli</b>' if args.hsk else '<b>Temi</b>', S['theme']), Spacer(1, 3 * mm)]
    for i, t in enumerate(themes):
        story.append(Paragraph(f'<a href="#t{i}" color="#1E1E1E">{inline(t["title"])}</a>'
                               f' <font color="#7A7A7A">· {len(t["words"])} parole</font>', S['toc']))
        if args.hsk:
            letters = sorted({initial(w['py']) for w in t['words']})
            story += [Paragraph(' &nbsp; '.join(f'<a href="#t{i}_{l}" color="#A3202E"><b>{l}</b></a>'
                                                for l in letters), S['letters']), Spacer(1, 4 * mm)]
    for i, t in enumerate(themes):
        story += [PageBreak(), ThemeHeader(t['title'], t['emoji'], f't{i}')]
        words = t['words']
        if args.hsk:   # ordine alfabetico del pinyin scelto, a parità di lettere per tono
            words = sorted(words, key=lambda w: (re.sub(r"[^a-zü]", '', toneless(w['py'])),
                                                 [tone(x) or 5 for x in w['py']]))
        groups = [[]]
        for w in words:
            if args.hsk and groups[-1] and initial(w['py']) != initial(groups[-1][-1]['py']):
                groups.append([])
            groups[-1].append(w)
        for ws in groups:
            if args.hsk:
                story.append(LetterBar(initial(ws[0]['py']), f't{i}_{initial(ws[0]["py"])}'))
            story += [CardRow(ws[j:j + COLS]) for j in range(0, len(ws), COLS)]
    doc.build(story)

    for w in WARN + bp.WARNINGS:
        print('ATTENZIONE:', w, file=sys.stderr)
    from pypdf import PdfReader
    print(f'{total} parole, {len(themes)} temi — PDF scritto: {args.out} '
          f'({len(PdfReader(args.out).pages)} pagine)')


if __name__ == '__main__':
    main()
