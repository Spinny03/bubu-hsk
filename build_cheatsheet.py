#!/usr/bin/env python3
"""Impagina il cheatsheet di grammatica: A4 orizzontale, tre colonne, formato compatto.

Legge cheatsheet/*.txt (stesso formato di riga di SPEC_CONTENUTI.md, vedi SPEC_EXTRA.md)
e produce Cheatsheet_grammatica_cinese.pdf.

Uso:  .venv/bin/python build_cheatsheet.py [--out FILE]
"""
import argparse
import glob
import os
import re
import sys

from reportlab.lib import colors
from reportlab.lib.pagesizes import A4, landscape
from reportlab.lib.styles import ParagraphStyle
from reportlab.lib.units import mm
from reportlab.platypus import (BaseDocTemplate, Frame, KeepTogether, PageTemplate, Spacer, Table,
                                TableStyle)

import build_pdf as bp
import check_cs_pinyin as cs
from build_pdf import (ACCENT, ACCENT_DARK, EX_BG, EX_RULE, FORMULA_BG, GREY, INK, LIGHT_RULE,
                       NO_BG, NO_RED, NOTE_BG, NOTE_BLUE, OK_GREEN, ZEBRA, P, inline, para, vlen)

BASE = os.path.dirname(os.path.abspath(__file__))
PAGE_W, PAGE_H = landscape(A4)
M = 9 * mm
GAP = 6 * mm
TOP = 15 * mm
COLS = 3
COL_W = (PAGE_W - 2 * M - (COLS - 1) * GAP) / COLS
TITLE = 'Cheatsheet di grammatica cinese'

S = {}
S['h1'] = ParagraphStyle('h1', fontName='Sans-Bold', fontSize=10.5, leading=13, textColor=colors.white,
                         wordWrap='CJK')
S['h2'] = ParagraphStyle('h2', fontName='Sans-Bold', fontSize=8.4, leading=10.4, textColor=ACCENT,
                         spaceBefore=4.5, spaceAfter=1.5, keepWithNext=1, wordWrap='CJK')
S['body'] = ParagraphStyle('body', fontName='Sans', fontSize=7.2, leading=9.1, textColor=INK,
                           spaceAfter=1.5, wordWrap='CJK')
S['bullet'] = ParagraphStyle('bullet', parent=S['body'], leftIndent=8, bulletIndent=1.5,
                             spaceAfter=0.6, bulletFontName='Sans', bulletColor=ACCENT)
S['formula'] = ParagraphStyle('formula', fontName='Sans-Bold', fontSize=7.6, leading=10,
                              textColor=colors.HexColor('#3B1212'), wordWrap='CJK')
S['ex_hz'] = ParagraphStyle('ex_hz', fontName='Sans', fontSize=8.4, leading=10.6, textColor=INK,
                            wordWrap='CJK')
S['no_hz'] = ParagraphStyle('no_hz', parent=S['ex_hz'], textColor=NO_RED)
S['ex_sub'] = ParagraphStyle('ex_sub', fontName='Sans', fontSize=6.6, leading=8.2, textColor=GREY,
                             wordWrap='CJK')
S['note'] = ParagraphStyle('note', fontName='Sans', fontSize=6.9, leading=8.8, textColor=INK,
                           wordWrap='CJK')
S['cell'] = ParagraphStyle('cell', fontName='Sans', fontSize=6.7, leading=8.3, textColor=INK,
                           wordWrap='CJK')
S['cell_head'] = ParagraphStyle('cell_head', parent=S['cell'], fontName='Sans-Bold',
                                textColor=colors.white)
HEX = lambda c: c.hexval().replace('0x', '#')
PY_COLOR = '#6B6B6B'


def mark_pinyin(text):
    """Segna con \\x01…\\x02 il pinyin che segue ogni parola cinese (verrà reso grigio corsivo)."""
    out, pos = [], 0
    for m in cs.RUN.finditer(text):
        a = cs.AFTER.match(text, m.end())
        if not a:
            continue
        chars = re.findall(rf'[{cs.HZ}]', m.group())
        py, start = a.group(2), a.start(2)
        letters = [(i, c) for i, c in enumerate(py) if re.match(r"[A-Za-zÀ-ɏ̀-ͯü]", c)]
        flat = cs.plain(''.join(c for _, c in letters)).lower()
        mm_ = re.match(cs.pattern(chars), flat)
        if not mm_ or not mm_.end():
            continue
        end = start + letters[mm_.end() - 1][0] + 1
        out.append(text[pos:start] + '\x01' + text[start:end] + '\x02')
        pos = end
    out.append(text[pos:])
    return ''.join(out)


def cs_inline(text, highlight=False, color=PY_COLOR):
    s = inline(mark_pinyin(text), highlight)
    return s.replace('\x01', f'<font color="{color}"><i>').replace('\x02', '</i></font>')


def PX(text, style, light=False):
    return para(cs_inline(text, color='#F3D9DC' if light else PY_COLOR), style, raw=text)


def h1_bar(text):
    t = Table([[PX(text, S['h1'], light=True)]], colWidths=[COL_W])
    t.setStyle(TableStyle([('BACKGROUND', (0, 0), (-1, -1), ACCENT_DARK),
                           ('LEFTPADDING', (0, 0), (-1, -1), 5), ('TOPPADDING', (0, 0), (-1, -1), 2.5),
                           ('BOTTOMPADDING', (0, 0), (-1, -1), 3.5)]))
    t.keepWithNext = 1
    return [Spacer(1, 5), t, Spacer(1, 1)]


def boxed(cells, bg, rule, rule_w=2):
    t = Table([[c] for c in cells], colWidths=[COL_W])
    t.setStyle(TableStyle([('BACKGROUND', (0, 0), (-1, -1), bg),
                           ('LINEBEFORE', (0, 0), (0, -1), rule_w, rule),
                           ('LEFTPADDING', (0, 0), (-1, -1), 5), ('RIGHTPADDING', (0, 0), (-1, -1), 3),
                           ('TOPPADDING', (0, 0), (-1, -1), 0.8), ('BOTTOMPADDING', (0, 0), (-1, -1), 0.8),
                           ('TOPPADDING', (0, 0), (-1, 0), 2.5), ('BOTTOMPADDING', (0, -1), (-1, -1), 2.5)]))
    return [Spacer(1, 1.5), t, Spacer(1, 2.5)]


def examples(items):
    rows, style, seen_wrong = [], [], False
    for i, (kind, (hz, py, tr)) in enumerate(items):
        wrong = kind == 'no'
        seen_wrong = seen_wrong or wrong
        mark = ''
        if wrong:
            mark = f'<font name="Sym" color="{HEX(NO_RED)}">✗</font>&nbsp;'
        elif seen_wrong:
            mark = f'<font name="Sym" color="{HEX(OK_GREEN)}">✓</font>&nbsp;'
        hz_p = para(mark + inline(hz, True), S['no_hz' if wrong else 'ex_hz'], raw=hz)
        sub = ' · '.join(x for x in (f'<i>{inline(py, True)}</i>' if py else '',
                                      inline(tr) if tr else '') if x)
        cell = [hz_p] + ([para(sub, S['ex_sub'], raw=py + tr)] if sub else [])
        rows.append([cell])
        style.append(('BACKGROUND', (0, i), (-1, i), NO_BG if wrong else EX_BG))
    t = Table(rows, colWidths=[COL_W])
    t.setStyle(TableStyle([('LINEBEFORE', (0, 0), (0, -1), 1.6, EX_RULE),
                           ('LEFTPADDING', (0, 0), (-1, -1), 5), ('RIGHTPADDING', (0, 0), (-1, -1), 3),
                           ('TOPPADDING', (0, 0), (-1, -1), 1.6), ('BOTTOMPADDING', (0, 0), (-1, -1), 2.2),
                           ('LINEBELOW', (0, 0), (-1, -2), 0.6, colors.white)] + style))
    return [Spacer(1, 1), t, Spacer(1, 2.5)]


def table(rows):
    ncol = max(len(r) for r in rows)
    rows = [r + [''] * (ncol - len(r)) for r in rows]
    weights = []
    for c in range(ncol):
        lens = [vlen(r[c]) for r in rows]
        weights.append(max(5.0, 0.6 * min(max(lens), 40) + 0.4 * sum(lens) / len(lens)))
    widths = [COL_W * w / sum(weights) for w in weights]
    data = [[PX(c, S['cell_head'] if ri == 0 else S['cell'], light=ri == 0) for c in r] for ri, r in enumerate(rows)]
    t = Table(data, colWidths=widths, repeatRows=1)
    style = [('BACKGROUND', (0, 0), (-1, 0), ACCENT), ('VALIGN', (0, 0), (-1, -1), 'TOP'),
             ('GRID', (0, 0), (-1, -1), 0.3, LIGHT_RULE),
             ('LEFTPADDING', (0, 0), (-1, -1), 2.5), ('RIGHTPADDING', (0, 0), (-1, -1), 2.5),
             ('TOPPADDING', (0, 0), (-1, -1), 1.3), ('BOTTOMPADDING', (0, 0), (-1, -1), 2)]
    style += [('BACKGROUND', (0, ri), (-1, ri), ZEBRA) for ri in range(2, len(rows), 2)]
    t.setStyle(TableStyle(style))
    return [Spacer(1, 1.5), t, Spacer(1, 3)]


def story_from(blocks):
    story, hold = [], []   # titoli (# e ##) da tenere uniti al primo blocco che segue
    for kind, data in blocks:
        if kind in ('h1', 'part'):
            hold += h1_bar(data)
            continue
        if kind in ('h2', 'h3'):
            hold.append(PX(data, S['h2']))
            continue
        start = len(story)
        if kind == 'text':
            story.append(PX(data, S['body']))
        elif kind == 'bullet':
            story.append(para(cs_inline(data), S['bullet'], raw=data, bulletText='•'))
        elif kind == 'formula':
            story += boxed([PX(l, S['formula']) for l in data], FORMULA_BG, ACCENT)
        elif kind == 'note':
            lab = f'<font name="Sans-Bold" color="{HEX(NOTE_BLUE)}">!</font>&nbsp;'
            story += boxed([para((lab if i == 0 else '') + cs_inline(l), S['note'], raw=l)
                            for i, l in enumerate(data)], NOTE_BG, NOTE_BLUE)
        elif kind == 'examples':
            story += examples(data)
        elif kind == 'table':
            story += table(data)
        if hold:
            story[start:] = [KeepTogether(hold + story[start:], maxHeight=40 * mm)]
            hold = []
        elif kind in ('formula', 'note'):   # i riquadri brevi non si spezzano
            story[start:] = [KeepTogether(story[start:])]
    return story + hold


def decorate(c, doc):
    c.saveState()
    c.setFillColor(ACCENT)
    c.rect(0, PAGE_H - 9 * mm, PAGE_W, 9 * mm, stroke=0, fill=1)
    c.setFillColor(colors.white)
    c.setFont('Sans-Bold', 10)
    c.drawString(M, PAGE_H - 6 * mm, TITLE)
    c.setFont('CJK', 10)
    c.drawRightString(PAGE_W - M - 22 * mm, PAGE_H - 6 * mm, '汉语语法速查表')
    c.setFont('Sans', 8)
    c.drawRightString(PAGE_W - M, PAGE_H - 6 * mm, f'pag. {doc.page}')
    c.setStrokeColor(LIGHT_RULE)
    c.setLineWidth(0.4)
    for i in range(1, COLS):
        x = M + i * COL_W + (i - 0.5) * GAP
        c.line(x, M, x, PAGE_H - TOP)
    c.restoreState()


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--out', default=os.path.join(BASE, 'Cheatsheet_grammatica_cinese.pdf'))
    args = ap.parse_args()
    files = sorted(glob.glob(os.path.join(BASE, 'cheatsheet', '*.txt')))
    if not files:
        sys.exit('nessun file in cheatsheet/')
    blocks = []
    for f in files:
        blocks += bp.parse(open(f, encoding='utf-8').read())
    doc = BaseDocTemplate(args.out, pagesize=(PAGE_W, PAGE_H), leftMargin=M, rightMargin=M,
                          topMargin=TOP, bottomMargin=M, title=TITLE, author='',
                          subject='Grammatica del cinese mandarino in sintesi')
    frames = [Frame(M + i * (COL_W + GAP), M, COL_W, PAGE_H - TOP - M, id=f'c{i}',
                    leftPadding=0, rightPadding=0, topPadding=0, bottomPadding=0) for i in range(COLS)]
    doc.addPageTemplates([PageTemplate(id='p', frames=frames, onPage=decorate)])
    doc.build(story_from(blocks))
    for w in bp.WARNINGS:
        print('ATTENZIONE:', w, file=sys.stderr)
    if bp.MISSING:
        print('caratteri senza glifo:', ''.join(sorted(bp.MISSING)), file=sys.stderr)
    from pypdf import PdfReader
    print(f'PDF scritto: {args.out} ({len(PdfReader(args.out).pages)} pagine)')


if __name__ == '__main__':
    main()
