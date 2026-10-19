# Bùbù 步步 — proposta per un'app iOS per l'HSK

*«Il cinese per l'HSK, passo dopo passo.»* 步步 bùbù = passo dopo passo.
Prototipo navigabile: `Bubu_prototipo.html` (si apre con un doppio clic nel browser) oppure `app_prototype/`.
Tavola con le schermate principali: `app_prototype/tavola_design.png`.

## 1. L'idea in breve

Un'app **in italiano**, costruita **esattamente sul programma ufficiale del nuovo esame HSK**
(HSK 考试大纲 kǎoshì dàgāng, CLEC, pubblicato 2025-11, in vigore 2026-07, prima sessione mondiale
del nuovo esame il 13 dicembre 2026). La prima pagina mostra i livelli; dentro ogni livello trovi
tutto quello che chiede l'esame, diviso bene:

| Sezione | Cosa contiene (HSK 1) |
|---|---|
| Percorso | 15 unità = i **15 compiti comunicativi ufficiali** (presentarsi, date e orari, oggetti, meteo, luoghi, saluti, cibo, spostamenti, acquisti, salute, tempo libero, studio, scuola, lavoro, cucina cinese) |
| Parole | le **300 parole** ufficiali, con audio, toni a colori, immagine, frase d'esempio |
| Caratteri | i **246 caratteri** da riconoscere (scrittura obbligatoria dall'HSK 2: 100 caratteri) |
| Grammatica | i punti del 语法大纲 yǔfǎ dàgāng, spiegati in italiano con gli errori tipici degli italiani |
| Pronuncia | toni con grafico della voce, coppie minime, sillabe, cambi tonali |
| Ascolto e lettura | dialoghi e testi graduati scritti solo con parole già note |
| Esame simulato | **stesso formato del nuovo esame**: 4 parti di ascolto + 4 di lettura, 5 domande ciascuna, 40 domande in circa 40 minuti |

Più un **ripasso unico giornaliero** (parole, caratteri, frasi, toni) con l'algoritmo FSRS.

## 2. Cosa dice il programma ufficiale (verificato sui documenti)

- Parole per livello (cumulative): HSK 1 = 300 · HSK 2 = 500 · HSK 3 = 1000 · HSK 4 = 2000 ·
  HSK 5 = 3600 · HSK 6 = 5400 · HSK 7–9 = 11000.
- Caratteri da riconoscere (认读字): HSK 1 = 246, HSK 2 = +125, HSK 3 = +284.
  Caratteri da scrivere (书写字): 100 per HSK 1–2 (scrittura richiesta dall'HSK 2), +150 all'HSK 3.
- Formato HSK 1 (样题 2025-12): ascolto 20 domande (circa 12 min) + lettura 20 domande (20 min),
  pinyin sopra i caratteri. Ascolto: frase → immagine; domanda → risposta; dialogo → immagine;
  breve testo → domanda a 3 scelte. Lettura: frase → immagine; domanda → risposta; completa la frase;
  frase → domanda a 3 scelte.
- HSK 2: 60 domande (ascolto 25, lettura 25, scrittura 10). HSK 3: 70 domande (30 + 30 + 10).
- **Attenzione:** la lista del 2021 (GF0025-2021, 500/1272/2245 parole) è un *quadro di riferimento*,
  non il programma d'esame. Il PDF basato su quella è stato rinominato `Vocabolario_HSK1-3_quadro2021.pdf`;
  `Vocabolario_HSK1-3_esame2026.pdf` usa la lista d'esame 2025 (300 + 200 + 500 = 1000 parole).

## 3. Perché non è «come Duolingo»

| Duolingo e simili | Bùbù |
|---|---|
| Vocabolario non legato all'HSK | Copertura misurata sul programma ufficiale («sai 180/300 parole, 9/16 punti di grammatica») |
| Tocca la tessera giusta (riconoscimento) | Richiamo attivo: prima pensi/scrivi/dici, poi vedi la risposta |
| Vite, serie, punizioni | Nessuna vita: se salti un giorno le carte aspettano; obiettivo concreto = data dell'esame |
| Grammatica implicita | Spiegazioni chiare in italiano + errori tipici degli italiani |
| Niente toni veri | Curva della tua voce sovrapposta a quella del madrelingua |
| Niente caratteri scritti | Ordine dei tratti animato e scrittura con il dito (dall'HSK 2) |
| Prove generiche | Simulazioni nel formato esatto del nuovo esame, con correzione per parte |

Principi didattici dietro le scelte: richiamo attivo e ripetizione dilazionata (FSRS), input
comprensibile (testi con il 95–98% di parole note), istruzione esplicita della grammatica per adulti,
feedback visivo sull'intonazione (le ricerche con curve di pitch mostrano miglioramenti nei toni),
allenamento sul formato reale dell'esame.

## 4. Come costruirla

| Strada | Pro | Contro |
|---|---|---|
| **A. Expo / React Native** (consigliata per partire) | Si sviluppa da qui (Linux): build iOS nel cloud con EAS, prova sul tuo iPhone, poi TestFlight e App Store. Una sola base di codice anche per Android e web. | Funzioni molto native (widget, Apple Pencil avanzato) richiedono moduli nativi |
| **B. SwiftUI nativa** | Massima qualità iOS: PencilKit, widget, Live Activities, audio a bassa latenza | Serve un Mac con Xcode; solo Apple |
| **C. Web app (PWA)** | Prototipo più veloce, nessuna approvazione Apple | Limiti su audio, notifiche e microfono; non è nell'App Store |

Componenti principali (strada A): TypeScript, expo-router, expo-sqlite (contenuti e stato offline),
ts-fsrs (ripasso), audio pre-generato con voce neurale + expo-audio per registrare, modulo nativo per il
pitch (algoritmo YIN) per il grafico dei toni, react-native-svg con i dati di Make Me a Hanzi per i
tratti, sincronizzazione iCloud/CloudKit o Supabase in un secondo momento.

## 5. Contenuti: cosa abbiamo già

- Lista ufficiale 2025 dei livelli 1–3 con pinyin e categorie (`hsk2025/hsk2025.json`).
- Traduzioni italiane ed emoji per quasi tutte le 1000 parole.
- Grammatica completa in italiano (libro), cheatsheet, errori tipici, controlli automatici del pinyin.
- 246 caratteri HSK 1 con dati dei tratti (Make Me a Hanzi, licenza Arphic Public License: da citare).
- Da creare: audio (parole e frasi; costo con voce neurale: pochi euro), 15 dialoghi per livello,
  domande d'esame **originali** nel formato ufficiale (non copiare i 样题 ufficiali), frasi d'esempio
  aggiuntive (Tatoeba ha coppie cinese–italiano con licenza CC BY).

## 6. Piano

1. **Contenuti HSK 1** (1–2 settimane): 15 unità, audio, grammatica, 2 simulazioni d'esame.
2. **MVP** (4–6 settimane): livelli, percorso, parole con FSRS, grammatica, esame simulato, offline;
   TestFlight sul tuo iPhone.
3. **v1**: pronuncia con grafico dei toni, scrittura (HSK 2), lettura graduata, widget del ripasso.
4. **v2**: HSK 2–3, sincronizzazione, App Store.

Costi fissi: Apple Developer Program 99 $/anno (necessario per TestFlight e App Store). Expo ha un piano
gratuito per iniziare. Da verificare: uso del marchio «HSK» nel nome dell'app.
