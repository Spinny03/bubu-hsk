# Bùbù 步步 — il cinese per il nuovo HSK, passo dopo passo

Materiali di studio in italiano per il cinese mandarino e il prototipo di un'app iOS di preparazione
al **nuovo esame HSK** (programma ufficiale 2025, esame dal 2026). Tutto è scritto per italiani:
spiegazioni, traduzioni, errori tipici.

> Progetto indipendente, non affiliato né approvato da Chinese Testing International (CTI / 汉考国际)
> o dal Center for Language Education and Cooperation (CLEC). «HSK» è un marchio dei rispettivi titolari.

## Cosa c'è

| File | Contenuto |
|---|---|
| [Grammatica_cinese_mandarino.pdf](Grammatica_cinese_mandarino.pdf) | Grammatica completa (587 pagine): 49 capitoli dalla pronuncia alle frasi complesse, oltre 1.200 gruppi di esempi con caratteri, pinyin e traduzione |
| [Cheatsheet_grammatica_cinese.pdf](Cheatsheet_grammatica_cinese.pdf) | Tutta la grammatica in 11 pagine, pinyin accanto a ogni carattere |
| [Vocabolario_HSK1-3_esame2026.pdf](Vocabolario_HSK1-3_esame2026.pdf) | Le 1.000 parole del programma d'esame 2025 (HSK 1–3), per livello, con immagini e toni a colori |
| [Vocabolario_illustrato_cinese.pdf](Vocabolario_illustrato_cinese.pdf) | 1.136 parole essenziali divise in 33 temi |
| [Vocabolario_HSK1-3_quadro2021.pdf](Vocabolario_HSK1-3_quadro2021.pdf) | Liste del quadro di riferimento 2021 (GF0025-2021): **non** è il programma d'esame |
| [Bubu_prototipo.html](Bubu_prototipo.html) | Prototipo navigabile dell'app (un solo file, si apre nel browser) |
| [PROPOSTA_APP.md](PROPOSTA_APP.md) | Proposta dell'app: struttura, tecnologie, piano |
| [reports/](reports/) | Rassegna della ricerca su come si studiano le lingue e come prepararsi all'HSK, con le correzioni da fare al prototipo |

## Struttura del repository

| Cartella / file | Ruolo |
|---|---|
| `content/` | Sorgenti della grammatica (formato descritto in `SPEC_CONTENUTI.md`) |
| `cheatsheet/` | Sorgenti del cheatsheet (`SPEC_EXTRA.md`, `SPEC_CHEATSHEET_V2.md`) |
| `vocab/` | Vocabolario per temi (parola, pinyin, italiano, emoji, livello) |
| `hsk2025/` | Dati del programma d'esame 2025 (`hsk2025.json`), unità dell'HSK 1, traduzioni |
| `hsk/` | Liste del quadro 2021 tradotte (storico) |
| `app_prototype/` | Prototipo dell'app: `app.js` (schermate), `build_data.py` (dati), `build_single.py` (file unico) |
| `research_notes/` | Note di ricerca dietro al report |
| `build_pdf.py`, `build_cheatsheet.py`, `build_vocab.py` | Impaginatori dei PDF (ReportLab) |
| `check_pinyin.py`, `check_cs_pinyin.py` | Controlli automatici del pinyin |

## Rigenerare i materiali

Servono Python 3.11+ e i font di sistema Liberation, DejaVu, WenQuanYi Zen Hei e Noto Color Emoji
(su Ubuntu: `fonts-liberation fonts-dejavu fonts-wqy-zenhei fonts-noto-color-emoji`).

```bash
python3 -m venv .venv
.venv/bin/pip install -r requirements.txt

.venv/bin/python build_pdf.py                 # grammatica completa
.venv/bin/python build_cheatsheet.py          # cheatsheet
.venv/bin/python build_vocab.py               # vocabolario per temi
.venv/bin/python check_pinyin.py              # controlla il pinyin degli esempi
.venv/bin/python check_cs_pinyin.py           # pinyin accanto a ogni carattere del cheatsheet
```

Per il vocabolario d'esame e i dati dell'app serve il programma ufficiale (non incluso, vedi sotto):

```bash
# scarica il programma in hsk2025/HSK_kaoshi_dagang_2025.pdf, poi:
cd hsk2025 && ../.venv/bin/python parse_syllabus.py && ../.venv/bin/python build_vocab_2025.py
cd ../app_prototype && ../.venv/bin/python build_data.py && ../.venv/bin/python build_single.py
```

## Documenti ufficiali (non inclusi)

- Programma d'esame **HSK 考试大纲** (CLEC, 2025-11, in vigore dal 2026-07):
  [PDF](https://hsk.cn-bj.ufileos.com/3.0/%E6%96%B0%E7%89%88HSK%E8%80%83%E8%AF%95%E5%A4%A7%E7%BA%B21219.pdf)
- **新版HSK（1-6级）考试结构与样题示例** (汉考国际, 2025-12):
  [PDF](https://confucio.unimc.it/it/certificazioni/HSK16.pdf)
- Prove d'esempio ufficiali con chiavi e audio:
  [ZIP, 395 MB](https://hsk-sample-1409982902.cos.ap-beijing.myqcloud.com/HSK3.0.zip)

Le domande d'esame dell'app devono essere originali: i materiali ufficiali servono solo come riferimento
per formato, tempi e pause.

Componenti di terze parti del prototipo: vedi [app_prototype/vendor/LICENSES.md](app_prototype/vendor/LICENSES.md).

## App iOS nativa

Il progetto SwiftUI (iOS 17+) è in [ios/](ios/README.md). Apri `ios/Bubu.xcodeproj` con Xcode.
