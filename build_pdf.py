#!/usr/bin/env python3
"""Impagina «Grammatica completa del cinese mandarino» in PDF.

Legge i file content/*.txt (in ordine alfabetico) scritti nel formato descritto in
SPEC_CONTENUTI.md e produce Grammatica_cinese_mandarino.pdf.

Uso:  .venv/bin/python build_pdf.py [--check] [--content DIR] [--out FILE]
"""
import argparse
import glob
import os
import re
import sys
import unicodedata
from xml.sax.saxutils import escape

import reportlab.platypus.paragraph as rl_paragraph
from reportlab.lib import colors
from reportlab.lib.enums import TA_CENTER, TA_JUSTIFY, TA_LEFT, TA_RIGHT
from reportlab.lib.pagesizes import A4
from reportlab.lib.styles import ParagraphStyle
from reportlab.lib.units import mm
from reportlab.pdfbase import pdfmetrics
from reportlab.pdfbase.ttfonts import TTFont
from reportlab.platypus import (BaseDocTemplate, CondPageBreak, Flowable, Frame, KeepTogether,
                                NextPageTemplate,
                                PageBreak, PageTemplate, Paragraph, Spacer, Table,
                                TableStyle)
from reportlab.platypus.tableofcontents import TableOfContents

BASE = os.path.dirname(os.path.abspath(__file__))

# --------------------------------------------------------------------------- font
LIB = '/usr/share/fonts/truetype/liberation/'
DJV = '/usr/share/fonts/truetype/dejavu/'
WQY = '/usr/share/fonts/truetype/wqy/wqy-zenhei.ttc'


def _reg(name, path, **kw):
    pdfmetrics.registerFont(TTFont(name, path, **kw))


_reg('Sans', LIB + 'LiberationSans-Regular.ttf')
_reg('Sans-Bold', LIB + 'LiberationSans-Bold.ttf')
_reg('Sans-Italic', LIB + 'LiberationSans-Italic.ttf')
_reg('Sans-BoldItalic', LIB + 'LiberationSans-BoldItalic.ttf')
pdfmetrics.registerFontFamily('Sans', normal='Sans', bold='Sans-Bold',
                              italic='Sans-Italic', boldItalic='Sans-BoldItalic')
_reg('Sym', DJV + 'DejaVuSans.ttf')
_reg('Sym-Bold', DJV + 'DejaVuSans-Bold.ttf')
pdfmetrics.registerFontFamily('Sym', normal='Sym', bold='Sym-Bold',
                              italic='Sym', boldItalic='Sym-Bold')
_reg('CJK', WQY, subfontIndex=0)
pdfmetrics.registerFontFamily('CJK', normal='CJK', bold='CJK', italic='CJK', boldItalic='CJK')

COVERAGE = {n: set(pdfmetrics.getFont(n).face.charToGlyph) for n in ('Sans', 'Sym', 'CJK')}

# La punteggiatura cinese non deve mai iniziare una riga (kinsoku).
rl_paragraph.ALL_CANNOT_START = rl_paragraph.ALL_CANNOT_START + '，。、？！：；）》〉」』”’…·～%'

# --------------------------------------------------------------------------- colori e misure
ACCENT = colors.HexColor('#A3202E')
ACCENT_DARK = colors.HexColor('#6E1420')
INK = colors.HexColor('#1E1E1E')
GREY = colors.HexColor('#5C5C5C')
LIGHT_RULE = colors.HexColor('#D9CFC4')
FORMULA_BG = colors.HexColor('#FBF1E1')
EX_BG = colors.HexColor('#F4F4F2')
EX_RULE = colors.HexColor('#B9B4AD')
NO_BG = colors.HexColor('#FBE9E9')
NO_RED = colors.HexColor('#B3261E')
OK_GREEN = colors.HexColor('#2E7D4F')
NOTE_BG = colors.HexColor('#E8F0F8')
NOTE_BLUE = colors.HexColor('#2C6AA0')
ZEBRA = colors.HexColor('#FAF6F0')
HL = '#B5262E'   # evidenziazione del punto grammaticale negli esempi

PAGE_W, PAGE_H = A4
MARGIN_L = MARGIN_R = 20 * mm
MARGIN_T = 22 * mm
MARGIN_B = 20 * mm
FRAME_W = PAGE_W - MARGIN_L - MARGIN_R

BOOK_TITLE = 'Grammatica completa del cinese mandarino'

# --------------------------------------------------------------------------- stili
S = {}
S['body'] = ParagraphStyle('body', fontName='Sans', fontSize=10, leading=14.3, textColor=INK,
                           alignment=TA_JUSTIFY, spaceAfter=5, wordWrap='CJK')
S['bullet'] = ParagraphStyle('bullet', parent=S['body'], leftIndent=15, bulletIndent=4,
                             spaceAfter=2.5, bulletFontName='Sans', bulletColor=ACCENT)
S['part_label'] = ParagraphStyle('part_label', fontName='Sans-Bold', fontSize=14, leading=18,
                                 textColor=ACCENT, alignment=TA_CENTER, spaceAfter=10)
S['part_title'] = ParagraphStyle('part_title', fontName='Sans-Bold', fontSize=27, leading=34,
                                 textColor=INK, alignment=TA_CENTER, wordWrap='CJK')
S['ch_label'] = ParagraphStyle('ch_label', fontName='Sans-Bold', fontSize=10.5, leading=13,
                               textColor=ACCENT, spaceAfter=4)
S['ch_title'] = ParagraphStyle('ch_title', fontName='Sans-Bold', fontSize=22, leading=27,
                               textColor=ACCENT_DARK, spaceAfter=6, wordWrap='CJK')
S['h2'] = ParagraphStyle('h2', fontName='Sans-Bold', fontSize=13.5, leading=17.5,
                         textColor=ACCENT, spaceBefore=13, spaceAfter=6, keepWithNext=1,
                         wordWrap='CJK')
S['h3'] = ParagraphStyle('h3', fontName='Sans-Bold', fontSize=11, leading=14.5, textColor=INK,
                         spaceBefore=9, spaceAfter=4, keepWithNext=1, wordWrap='CJK')
S['formula_label'] = ParagraphStyle('formula_label', fontName='Sans-Bold', fontSize=7.3,
                                    leading=9.5, textColor=ACCENT)
S['formula'] = ParagraphStyle('formula', fontName='Sans-Bold', fontSize=10.5, leading=15,
                              textColor=colors.HexColor('#3B1212'), wordWrap='CJK')
S['note'] = ParagraphStyle('note', fontName='Sans', fontSize=9.5, leading=13.4, textColor=INK,
                           wordWrap='CJK', spaceAfter=2)
S['ex_hz'] = ParagraphStyle('ex_hz', fontName='Sans', fontSize=11.5, leading=15, textColor=INK,
                            wordWrap='CJK')
S['no_hz'] = ParagraphStyle('no_hz', parent=S['ex_hz'], textColor=NO_RED)
S['ex_py'] = ParagraphStyle('ex_py', fontName='Sans-Italic', fontSize=8.8, leading=11.4,
                            textColor=GREY, wordWrap='CJK')
S['ex_tr'] = ParagraphStyle('ex_tr', fontName='Sans', fontSize=9.3, leading=12.2, textColor=INK,
                            wordWrap='CJK')
S['no_tr'] = ParagraphStyle('no_tr', parent=S['ex_tr'], fontName='Sans-Italic', textColor=NO_RED)
S['cell'] = ParagraphStyle('cell', fontName='Sans', fontSize=8.8, leading=11.8, textColor=INK,
                           wordWrap='CJK')
S['cell_head'] = ParagraphStyle('cell_head', parent=S['cell'], fontName='Sans-Bold',
                                textColor=colors.white)
S['header'] = ParagraphStyle('header', fontName='Sans', fontSize=7.8, leading=9.5, textColor=GREY)
S['header_r'] = ParagraphStyle('header_r', parent=S['header'], alignment=TA_RIGHT,
                               textColor=ACCENT)

TOC_STYLES = [
    ParagraphStyle('toc0', fontName='Sans-Bold', fontSize=10.5, leading=14, textColor=ACCENT,
                   spaceBefore=9, spaceAfter=2, leftIndent=0, wordWrap='CJK'),
    ParagraphStyle('toc1', fontName='Sans-Bold', fontSize=9.6, leading=12.6, textColor=INK,
                   spaceBefore=3, leftIndent=6, firstLineIndent=0, wordWrap='CJK'),
    ParagraphStyle('toc2', fontName='Sans', fontSize=8.4, leading=10.6, textColor=GREY,
                   leftIndent=24, wordWrap='CJK'),
]

# --------------------------------------------------------------------------- testo e font
WARNINGS = []
MISSING = set()


def warn(msg):
    WARNINGS.append(msg)


def is_cjk(ch):
    o = ord(ch)
    return (0x2E80 <= o <= 0x2FFF or 0x3000 <= o <= 0x303F or 0x3040 <= o <= 0x30FF
            or 0x3100 <= o <= 0x312F or 0x31C0 <= o <= 0x31EF or 0x3400 <= o <= 0x4DBF
            or 0x4E00 <= o <= 0x9FFF or 0xF900 <= o <= 0xFAFF or 0xFE30 <= o <= 0xFE4F
            or 0xFF00 <= o <= 0xFFEF)


def font_for(ch):
    """Font da usare per un carattere (None = font del paragrafo)."""
    if is_cjk(ch):
        return 'CJK'
    o = ord(ch)
    if o < 0x80 or o in COVERAGE['Sans']:
        return None
    if o in COVERAGE['Sym']:
        return 'Sym'
    if o in COVERAGE['CJK']:
        return 'CJK'
    MISSING.add(ch)
    return None


TAG_RE = re.compile(r'(<[^>]+>)')


def apply_fonts(markup):
    """Avvolge in <font name=…> i tratti di testo che il font latino non copre."""
    out = []
    for part in TAG_RE.split(markup):
        if not part:
            continue
        if part.startswith('<'):
            out.append(part)
            continue
        cur, buf = None, ''
        for ch in part:
            f = font_for(ch)
            if f != cur and buf:
                out.append(buf if cur is None else f'<font name="{cur}">{buf}</font>')
                buf = ''
            cur = f
            buf += ch
        if buf:
            out.append(buf if cur is None else f'<font name="{cur}">{buf}</font>')
    return ''.join(out)


BOLD_RE = re.compile(r'\*\*(.+?)\*\*')
ITAL_RE = re.compile(r'(?<![\w*])\*(?=\S)(.+?)(?<=\S)\*(?![\w*])')


def inline(text, highlight=False):
    s = escape(unicodedata.normalize('NFC', text))
    if highlight:
        s = BOLD_RE.sub(rf'<font color="{HL}"><b>\1</b></font>', s)
    else:
        s = BOLD_RE.sub(r'<b>\1</b>', s)
    s = ITAL_RE.sub(r'<i>\1</i>', s)
    return apply_fonts(s)


def plain(text):
    return unicodedata.normalize('NFC', text).replace('**', '').replace('*', '')


def para(markup, style, raw=None, **kw):
    try:
        return Paragraph(markup, style, **kw)
    except Exception as e:  # markup malformato: ripiego su testo semplice
        warn(f'markup non valido ({e}): {raw or markup[:80]!r}')
        return Paragraph(apply_fonts(escape(plain(raw or markup))), style, **kw)


def P(text, style, highlight=False, **kw):
    return para(inline(text, highlight), style, raw=text, **kw)


def vlen(s):
    return sum(2 if is_cjk(c) else 1 for c in plain(s))


TONE_ONLY_PINYIN = set('āēīōūǖǎěǐǒǔǚĀĒĪŌŪǍĚǏǑǓǕǗǙǛǘǜ')


def looks_like_pinyin(s):
    return any(c in TONE_ONLY_PINYIN for c in s)


# --------------------------------------------------------------------------- flowable speciali
class Rule(Flowable):
    def __init__(self, width, thickness=0.8, color=ACCENT, space_before=2, space_after=10):
        super().__init__()
        self.width, self.thickness, self.color = width, thickness, color
        self.spaceBefore, self.spaceAfter = space_before, space_after

    def wrap(self, aw, ah):
        return self.width, self.thickness

    def draw(self):
        self.canv.setStrokeColor(self.color)
        self.canv.setLineWidth(self.thickness)
        self.canv.line(0, 0, self.width, 0)


class Marker(Flowable):
    """Flowable invisibile che registra segnalibro, voce d'indice e intestazione."""

    def __init__(self, level, toc_text, key, outline, header=None, suppress_header=False):
        super().__init__()
        self.info = (level, toc_text, key, outline, header, suppress_header)
        self.keepWithNext = 1

    def wrap(self, aw, ah):
        return 0, 0

    def draw(self):
        pass


# --------------------------------------------------------------------------- parsing
def parse_line(line):
    s = line.strip()
    if not s:
        return ('blank', None)
    if s.startswith('@ ') or s == '@':
        return ('part', s[1:].strip())
    if s.startswith('### '):
        return ('h3', s[4:].strip())
    if s.startswith('## '):
        return ('h2', s[3:].strip())
    if s.startswith('# '):
        return ('h1', s[2:].strip())
    if s.startswith('= ') or s == '=':
        return ('formula', s[1:].strip())
    low = s[:3].lower()
    if low in ('ex:', 'no:'):
        body = s[3:].strip()
        fields = [f.strip() for f in body.split(' | ')]
        if len(fields) != 3:
            fields = [f.strip() for f in body.split('|')]
        if len(fields) == 2:
            fields = ([fields[0], fields[1], ''] if looks_like_pinyin(fields[1])
                      else [fields[0], '', fields[1]])
        elif len(fields) == 1:
            fields = [fields[0], '', '']
        elif len(fields) > 3:
            warn(f'esempio con {len(fields)} campi: {s[:90]!r}')
            fields = [fields[0], fields[1], ' | '.join(fields[2:])]
        return ('ex' if low == 'ex:' else 'no', fields)
    if s.startswith('- ') or s == '-':
        return ('bullet', s[1:].strip())
    if s.startswith('! ') or s == '!':
        return ('note', s[1:].strip())
    if s.startswith('|'):
        inner = s.strip()
        if inner.endswith('|'):
            inner = inner[:-1]
        cells = [c.strip() for c in inner[1:].split('|')]
        if all(re.fullmatch(r':?-{2,}:?', c) or not c for c in cells):
            return ('blank', None)  # riga separatrice in stile Markdown: ignorata
        return ('row', cells)
    return ('text', s)


MERGEABLE = {'formula': 'formula', 'ex': 'examples', 'no': 'examples',
             'note': 'note', 'row': 'table'}


def parse(text):
    """Restituisce la lista di blocchi (tipo, dati)."""
    blocks = []
    pending_text = []

    def flush_text():
        if pending_text:
            blocks.append(('text', ' '.join(pending_text)))
            pending_text.clear()

    last_kind = None
    for line in text.splitlines():
        kind, data = parse_line(line)
        if kind == 'blank':
            flush_text()
            if last_kind == 'row':
                last_kind = None   # una riga vuota chiude la tabella
            continue
        if kind == 'text':
            pending_text.append(data)
            last_kind = 'text'
            continue
        flush_text()
        group = MERGEABLE.get(kind)
        if group and blocks and blocks[-1][0] == group and last_kind in (
                ('ex', 'no') if group == 'examples' else (kind,)):
            blocks[-1][1].append((kind, data) if group == 'examples' else data)
        elif group:
            blocks.append((group, [(kind, data)] if group == 'examples' else [data]))
        else:
            blocks.append((kind, data))
        last_kind = kind
    flush_text()
    return blocks


# --------------------------------------------------------------------------- costruzione dei blocchi
def formula_box(lines):
    data = [[P('STRUTTURA', S['formula_label'])]]
    data += [[P(l, S['formula'])] for l in lines]
    t = Table(data, colWidths=[FRAME_W], hAlign='LEFT')
    t.setStyle(TableStyle([
        ('BACKGROUND', (0, 0), (-1, -1), FORMULA_BG),
        ('LINEBEFORE', (0, 0), (0, -1), 3, ACCENT),
        ('LEFTPADDING', (0, 0), (-1, -1), 11),
        ('RIGHTPADDING', (0, 0), (-1, -1), 8),
        ('TOPPADDING', (0, 0), (-1, 0), 5),
        ('BOTTOMPADDING', (0, 0), (-1, 0), 0),
        ('TOPPADDING', (0, 1), (-1, -1), 1.5),
        ('BOTTOMPADDING', (0, 1), (-1, -1), 1.5),
        ('BOTTOMPADDING', (0, -1), (-1, -1), 6),
    ]))
    return [Spacer(1, 3), KeepTogether([t]), Spacer(1, 7)]


EX_SPLIT = 0.58   # frazione della larghezza per hanzi + pinyin nel formato a due colonne


def text_width(text, size, italic=False):
    base = 'Sans-Italic' if italic else 'Sans'
    return sum(pdfmetrics.stringWidth(ch, font_for(ch) or base, size) for ch in plain(text))


def examples_box(items):
    left_w = FRAME_W * EX_SPLIT - 10 - 6
    two_col = all(text_width(hz, 11.5) + 16 <= left_w and text_width(py, 8.8, True) <= left_w
                  for _, (hz, py, tr) in items)
    red, green = NO_RED.hexval().replace('0x', '#'), OK_GREEN.hexval().replace('0x', '#')
    seen_wrong = False
    rows, styles = [], []
    for i, (kind, (hz, py, tr)) in enumerate(items):
        wrong = kind == 'no'
        seen_wrong = seen_wrong or wrong
        if wrong:
            mark = f'<font name="Sym" color="{red}">✗</font>&nbsp;'
        else:
            mark = f'<font name="Sym" color="{green}">✓</font>&nbsp;' if seen_wrong else ''
        hz_p = para(mark + inline(hz, True), S['no_hz' if wrong else 'ex_hz'], raw=hz)
        py_p = P(py, S['ex_py'], True) if py else None
        tr_p = P(tr, S['no_tr' if wrong else 'ex_tr']) if tr else None
        if two_col:
            rows.append([[hz_p] + ([py_p] if py_p else []), [tr_p] if tr_p else ''])
        else:
            rows.append([[x for x in (hz_p, py_p, tr_p) if x]])
        styles.append(('BACKGROUND', (0, i), (-1, i), NO_BG if wrong else EX_BG))
    widths = [FRAME_W * EX_SPLIT, FRAME_W * (1 - EX_SPLIT)] if two_col else [FRAME_W]
    t = Table(rows, colWidths=widths, hAlign='LEFT')
    style = [
        ('LINEBEFORE', (0, 0), (0, -1), 2.2, EX_RULE),
        ('VALIGN', (0, 0), (-1, -1), 'TOP'),
        ('LEFTPADDING', (0, 0), (-1, -1), 10),
        ('RIGHTPADDING', (0, 0), (-1, -1), 6),
        ('TOPPADDING', (0, 0), (-1, -1), 3),
        ('BOTTOMPADDING', (0, 0), (-1, -1), 4),
        ('LINEBELOW', (0, 0), (-1, -2), 0.9, colors.white),
    ]
    if two_col:
        style += [('LEFTPADDING', (1, 0), (1, -1), 4), ('TOPPADDING', (1, 0), (1, -1), 4.6)]
    t.setStyle(TableStyle(style + styles))
    return [Spacer(1, 2), t, Spacer(1, 7)]


def note_box(lines):
    cells = []
    for i, l in enumerate(lines):
        label = (f'<font name="Sans-Bold" color="{NOTE_BLUE.hexval().replace("0x", "#")}">Nota</font>'
                 '&nbsp;&nbsp;' if i == 0 else '')
        cells.append(para(label + inline(l), S['note'], raw=l))
    t = Table([[c] for c in cells], colWidths=[FRAME_W], hAlign='LEFT')
    t.setStyle(TableStyle([
        ('BACKGROUND', (0, 0), (-1, -1), NOTE_BG),
        ('LINEBEFORE', (0, 0), (0, -1), 3, NOTE_BLUE),
        ('LEFTPADDING', (0, 0), (-1, -1), 11),
        ('RIGHTPADDING', (0, 0), (-1, -1), 8),
        ('TOPPADDING', (0, 0), (-1, -1), 1.5),
        ('BOTTOMPADDING', (0, 0), (-1, -1), 1.5),
        ('TOPPADDING', (0, 0), (-1, 0), 6),
        ('BOTTOMPADDING', (0, -1), (-1, -1), 5),
    ]))
    return [Spacer(1, 3), t, Spacer(1, 8)]


def table_block(rows):
    ncol = max(len(r) for r in rows)
    for r in rows:
        if len(r) != ncol:
            warn(f'tabella con righe di lunghezza diversa: {" | ".join(r)[:80]!r}')
    rows = [r + [''] * (ncol - len(r)) for r in rows]
    weights = []
    for c in range(ncol):
        lens = [vlen(r[c]) for r in rows]
        mx, avg = max(lens), sum(lens) / len(lens)
        weights.append(max(7.0, 0.55 * min(mx, 70) + 0.45 * avg))
    total = sum(weights)
    widths = [FRAME_W * w / total for w in weights]
    need = [min(max(12 * mm, max(longest_word(r[c], ri == 0) for ri, r in enumerate(rows))),
                FRAME_W * 0.42) for c in range(ncol)]
    if sum(need) < FRAME_W:   # nessuna parola spezzata a metà, se c'è spazio
        for _ in range(4):
            deficit = sum(max(0.0, need[i] - widths[i]) for i in range(ncol))
            if deficit < 0.5:
                break
            donors = [i for i in range(ncol) if widths[i] > need[i]]
            slack = sum(widths[i] - need[i] for i in donors)
            take = min(deficit, slack)
            for i in donors:
                widths[i] -= take * (widths[i] - need[i]) / slack
            for i in range(ncol):
                widths[i] = max(widths[i], need[i])
        scale = FRAME_W / sum(widths)
        widths = [w * scale for w in widths]
    data = []
    for ri, r in enumerate(rows):
        st = S['cell_head'] if ri == 0 else S['cell']
        data.append([P(c, st) for c in r])
    t = Table(data, colWidths=widths, repeatRows=1, hAlign='LEFT')
    style = [
        ('BACKGROUND', (0, 0), (-1, 0), ACCENT),
        ('VALIGN', (0, 0), (-1, -1), 'TOP'),
        ('GRID', (0, 0), (-1, -1), 0.4, LIGHT_RULE),
        ('LEFTPADDING', (0, 0), (-1, -1), 5),
        ('RIGHTPADDING', (0, 0), (-1, -1), 5),
        ('TOPPADDING', (0, 0), (-1, -1), 3.2),
        ('BOTTOMPADDING', (0, 0), (-1, -1), 4),
    ]
    for ri in range(2, len(rows), 2):
        style.append(('BACKGROUND', (0, ri), (-1, ri), ZEBRA))
    t.setStyle(TableStyle(style))
    return [Spacer(1, 4), t, Spacer(1, 9)]


def longest_word(cell, bold):
    font = 'Sans-Bold' if bold else 'Sans'
    best = 0.0
    for word in plain(cell).split():
        if not any(is_cjk(ch) for ch in word):
            best = max(best, pdfmetrics.stringWidth(word, font, 8.8))
    return best + 11


ROMAN = ['I', 'II', 'III', 'IV', 'V', 'VI', 'VII', 'VIII', 'IX', 'X', 'XI', 'XII']
ORDINALI = ['prima', 'seconda', 'terza', 'quarta', 'quinta', 'sesta', 'settima', 'ottava',
            'nona', 'decima']


class Builder:
    def __init__(self):
        self.story = []
        self.part_no = 0
        self.chapter_no = 0
        self.appendix = False
        self.appendix_no = 0
        self.section_no = 0
        self.chapter_label = None
        self.key_no = 0
        self.fresh_page = True    # siamo all'inizio di una pagina vuota?
        self.stats = {'part': 0, 'h1': 0, 'h2': 0, 'h3': 0, 'examples': 0, 'table': 0,
                      'formula': 0, 'note': 0}

    def key(self):
        self.key_no += 1
        return f'k{self.key_no}'

    def add(self, *fl):
        self.story.extend(fl)
        self.fresh_page = False

    def new_page(self):
        if not self.fresh_page:
            self.story.append(PageBreak())
        self.fresh_page = True

    def part(self, title):
        self.new_page()
        if title.lower().startswith('appendic'):
            self.appendix = True
            label, toc = 'APPENDICI', title
        else:
            label = f'PARTE {ORDINALI[self.part_no].upper()}' if self.part_no < len(ORDINALI) else 'PARTE'
            toc = f'Parte {ROMAN[self.part_no]} – {title}'
            self.part_no += 1
        self.story.append(Marker(0, inline(toc), self.key(), plain(toc), header=None,
                                 suppress_header=True))
        self.story += [Spacer(1, 75 * mm), P(label, S['part_label']),
                       Rule(40 * mm, 1.2, ACCENT, 0, 14), P(title, S['part_title'])]
        self.story[-2].hAlign = 'CENTER'
        self.story.append(PageBreak())
        self.fresh_page = True

    def chapter(self, title):
        self.new_page()
        self.section_no = 0
        if self.appendix:
            letter = chr(ord('A') + self.appendix_no)
            self.appendix_no += 1
            self.chapter_label = letter
            label, toc = f'APPENDICE {letter}', f'{letter}. {title}'
            header = f'Appendice {letter} · {title}'
        else:
            self.chapter_no += 1
            self.chapter_label = str(self.chapter_no)
            label, toc = f'CAPITOLO {self.chapter_no}', f'{self.chapter_no}. {title}'
            header = f'{self.chapter_no}. {title}'
        self.story.append(Marker(1, inline(toc), self.key(), plain(toc), header=header,
                                 suppress_header=True))
        self.add(Spacer(1, 14 * mm), P(label, S['ch_label']), P(title, S['ch_title']),
                 Rule(FRAME_W, 1.0, ACCENT, 2, 12))

    def section(self, title):
        if self.chapter_label is None:
            self.chapter('Senza titolo')
        self.section_no += 1
        num = f'{self.chapter_label}.{self.section_no}'
        p = para(f'{num}&nbsp;&nbsp;{inline(title)}', S['h2'], raw=title)
        m = Marker(2, f'{num}&nbsp;&nbsp;{inline(title)}', self.key(), f'{num} {plain(title)}')
        self.add(CondPageBreak(30 * mm), m, p)

    def build(self, blocks):
        for kind, data in blocks:
            if kind in self.stats:
                self.stats[kind] += 1
            if kind == 'part':
                self.part(data)
            elif kind == 'h1':
                self.chapter(data)
            elif kind == 'h2':
                self.section(data)
            elif kind == 'h3':
                self.add(CondPageBreak(20 * mm), P(data, S['h3']))
            elif kind == 'text':
                self.add(P(data, S['body']))
            elif kind == 'bullet':
                self.add(P(data, S['bullet'], bulletText='•'))
            elif kind == 'formula':
                self.add(*formula_box(data))
            elif kind == 'examples':
                self.add(*examples_box(data))
            elif kind == 'note':
                self.add(*note_box(data))
            elif kind == 'table':
                self.add(*table_block(data))
            else:
                warn(f'blocco sconosciuto {kind}')


# --------------------------------------------------------------------------- documento
class GrammarDoc(BaseDocTemplate):
    def __init__(self, filename, **kw):
        super().__init__(filename, pagesize=A4, leftMargin=MARGIN_L, rightMargin=MARGIN_R,
                         topMargin=MARGIN_T, bottomMargin=MARGIN_B, title=BOOK_TITLE,
                         author='Claude', subject='Grammatica del cinese mandarino in italiano',
                         **kw)
        self.cur_header = ''
        self.suppress_header = False
        frame = Frame(MARGIN_L, MARGIN_B, FRAME_W, PAGE_H - MARGIN_T - MARGIN_B, id='main',
                      leftPadding=0, rightPadding=0, topPadding=0, bottomPadding=0)
        cover_frame = Frame(0, 0, PAGE_W, PAGE_H, id='cover')
        self.addPageTemplates([
            PageTemplate('cover', [cover_frame], onPage=draw_cover),
            PageTemplate('normal', [frame], onPageEnd=draw_header_footer),
        ])

    def afterFlowable(self, fl):
        if isinstance(fl, Marker):
            level, toc_text, key, outline, header, suppress = fl.info
            self.canv.bookmarkPage(key)
            self.canv.addOutlineEntry(outline, key, level=level, closed=level >= 1)
            if toc_text is not None:
                self.notify('TOCEntry', (level, toc_text, self.page, key))
            if header is not None:
                self.cur_header = header
            if suppress:
                self.suppress_header = True


def draw_cover(c, doc):
    c.saveState()
    c.setFillColor(ACCENT)
    c.rect(0, PAGE_H * 0.43, PAGE_W, PAGE_H * 0.57, stroke=0, fill=1)
    c.setFillColor(ACCENT_DARK)
    c.rect(0, PAGE_H * 0.43, PAGE_W, 4 * mm, stroke=0, fill=1)
    c.setFillColor(colors.white)
    c.setFont('CJK', 88)
    c.drawCentredString(PAGE_W / 2, PAGE_H * 0.69, '汉语语法')
    c.setFont('Sans', 14)
    c.drawCentredString(PAGE_W / 2, PAGE_H * 0.69 - 42, 'Hànyǔ yǔfǎ')
    c.setFillColor(INK)
    c.setFont('Sans-Bold', 31)
    c.drawCentredString(PAGE_W / 2, PAGE_H * 0.33, 'Grammatica completa')
    c.drawCentredString(PAGE_W / 2, PAGE_H * 0.33 - 38, 'del cinese mandarino')
    c.setStrokeColor(ACCENT)
    c.setLineWidth(1.2)
    c.line(PAGE_W / 2 - 25 * mm, PAGE_H * 0.33 - 56, PAGE_W / 2 + 25 * mm, PAGE_H * 0.33 - 56)
    c.setFillColor(GREY)
    c.setFont('Sans', 12.5)
    c.drawCentredString(PAGE_W / 2, PAGE_H * 0.33 - 80,
                        'Regole, strutture ed esempi dal livello base all’avanzato (HSK 1–6)')
    c.setFont('Sans', 11)
    c.drawCentredString(PAGE_W / 2, PAGE_H * 0.33 - 98,
                        'Caratteri semplificati · pinyin · traduzione italiana')
    c.setFont('Sans', 9.5)
    c.drawCentredString(PAGE_W / 2, 18 * mm, 'Ottobre 2026')
    c.restoreState()


def draw_header_footer(c, doc):
    page = c.getPageNumber()
    c.saveState()
    if doc.suppress_header:
        doc.suppress_header = False
    else:
        y = PAGE_H - MARGIN_T + 7 * mm
        left = Paragraph(apply_fonts(escape(BOOK_TITLE)), S['header'])
        right = Paragraph(apply_fonts(escape(doc.cur_header)), S['header_r'])
        left.wrapOn(c, FRAME_W * 0.45, 20)
        left.drawOn(c, MARGIN_L, y)
        right.wrapOn(c, FRAME_W * 0.55, 20)
        right.drawOn(c, MARGIN_L + FRAME_W * 0.45, y)
        c.setStrokeColor(LIGHT_RULE)
        c.setLineWidth(0.5)
        c.line(MARGIN_L, y - 2.2 * mm, MARGIN_L + FRAME_W, y - 2.2 * mm)
    c.setFont('Sans', 8.5)
    c.setFillColor(GREY)
    c.drawCentredString(PAGE_W / 2, 11 * mm, str(page))
    c.restoreState()


def build_story(blocks):
    story = [Spacer(1, 1), NextPageTemplate('normal'), PageBreak()]
    toc = TableOfContents(levelStyles=TOC_STYLES, dotsMinLevel=1)
    story.append(Marker(0, None, 'indice', 'Indice', header='Indice', suppress_header=True))
    story += [Spacer(1, 14 * mm), P('Indice', S['ch_title']), Rule(FRAME_W, 1.0, ACCENT, 2, 10),
              toc]
    b = Builder()
    b.fresh_page = False
    b.build(blocks)
    return story + b.story, b.stats


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--check', action='store_true', help='solo analisi, nessun PDF')
    ap.add_argument('--content', default=os.path.join(BASE, 'content'))
    ap.add_argument('--out', default=os.path.join(BASE, 'Grammatica_cinese_mandarino.pdf'))
    args = ap.parse_args()

    files = sorted(glob.glob(os.path.join(args.content, '*.txt')))
    if not files:
        sys.exit(f'nessun file in {args.content}')
    text = ''
    for f in files:
        with open(f, encoding='utf-8-sig') as fh:
            text += fh.read().rstrip('\n') + '\n\n'
    blocks = parse(text)
    story, stats = build_story(blocks)
    print(f'{len(files)} file, {len(text.splitlines())} righe — ' +
          ', '.join(f'{k}: {v}' for k, v in stats.items()))
    if not args.check:
        doc = GrammarDoc(args.out)
        doc.multiBuild(story)
        print(f'PDF scritto: {args.out} ({doc.page} pagine)')
    for w in WARNINGS:
        print('ATTENZIONE:', w)
    if MISSING:
        print('ATTENZIONE: glifi mancanti:', ' '.join(sorted(MISSING)))


if __name__ == '__main__':
    main()
