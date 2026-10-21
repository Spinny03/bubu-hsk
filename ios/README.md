# Bùbù · app iOS

SwiftUI, iOS 17+, SwiftData locale. Il nome dell’app è Bùbù; HSK descrive soltanto l’esame preparato.
I contenuti sono inclusi nel bundle; i progressi sono separati dal catalogo e salvati sul dispositivo.

## Aprire e verificare

```sh
.venv/bin/python ios/Scripts/import_content.py
xcodegen generate --spec ios/project.yml
open ios/Bubu.xcodeproj
xcodebuild test -project ios/Bubu.xcodeproj -scheme Bubu \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=26.5' \
  -derivedDataPath ios/build CODE_SIGNING_ALLOWED=NO
```

Il progetto Xcode generato è versionato: XcodeGen serve solo per rigenerarlo quando cambia `project.yml`.
La build per un iPhone fisico richiede di scegliere il proprio team in Signing & Capabilities.

## Scelte

- SwiftUI e SwiftData: integrazione iOS, persistenza offline, nessun backend. Compromesso: solo piattaforme Apple.
- AVSpeechSynthesizer come voce provvisoria. La disponibilità delle voci dipende dal dispositivo; la qualità e i cambi tonali richiedono ascolto umano.
- FSRS Swift fissato al commit `4fbaf20184d62f82a9f44f343337c61a2c5483e9`, con parametri espliciti FSRS 6 (il default della libreria è ancora FSRS 5).
- AVAudioEngine/YIN e PencilKit per pratica locale. Nessuna registrazione deve lasciare il dispositivo.
- Il catalogo deriva da `hsk2025.json` e `l1_units.txt`, mai dal quadro 2021. Gli hash in `provenance.json` rendono verificabile la provenienza.

## Blocco 1: base

300 parole, 15 unità, 246 caratteri e lista completa di 100 caratteri da scrivere; ricerca, piano d’esame e impostazioni dei toni. La copertura parte da zero e non aumenta aprendo una pagina. Nessun punteggio di preparazione viene inventato in assenza di simulazioni.

Verificati: conteggi e identità dei dati, tutte le unità rappresentate, entrambe le letture ufficiali della parola con due alternative, build e navigazione automatizzata su iPhone 17 Pro / iOS 26.5. Screenshot in `evidence/`.

Limiti di questa prima PR: motore di studio, grammatica ed esame arrivano nelle PR successive. Non verificati dispositivo fisico, iOS 17 runtime, VoiceOver parlato e qualità audio.

Controlli Python esistenti: `check_pinyin.py` segnala 17 casi già presenti nel libro (riduplicazioni, letture alternative e parole miste latino/cinese); `check_cs_pinyin.py` segnala zero casi. L’importazione delle 300 parole ha zero errori controllando separatamente le letture alternative.

## Blocco 2: studio e grammatica

Il ripasso unisce carte di significato, audio, pinyin, riconoscimento e comprensione grammaticale. FSRS 6 riceve esiti oggettivi: errore → Again, corretto ma incerto → Hard, corretto → Good. Stato e risposta vengono salvati insieme dopo ogni verifica. Il richiamo del pinyin parte dall’italiano, così la lettura non viene suggerita; nei compiti di riconoscimento il pinyin resta accanto ai caratteri. Le emoji appaiono solo dopo la risposta.

La copertura di una parola richiede le tre direzioni e almeno due risposte corrette in giorni distinti, separate da almeno 20 ore per ciascuna. Le ripetizioni immediate non gonfiano il conteggio. Le 70 righe di grammatica sono mappate in `Content/grammar_map.tsv` alle pagine PDF 386–388 del programma e a estratti di `content/`; il quiz misura la comprensione di un esempio, non certifica l’intera struttura. Gli estratti del libro possono superare il lessico HSK 1 e sono dichiarati come approfondimento.

Rigenerazione e verifiche:

```sh
.venv/bin/python ios/Scripts/import_grammar.py
.venv/bin/python check_pinyin.py ios/Content/grammar_pinyin.txt
.venv/bin/python check_cs_pinyin.py ios/Content/grammar_pinyin.txt
```

Entrambi i controlli danno zero segnalazioni sul nuovo corpus. Test: obbligo dei toni, letture alternative, salvataggio di eventi e scadenze, ripetizioni immediate, 70 collegamenti alle fonti; UI: fronte senza emoji, retro dopo la risposta, rifiuto del pinyin senza tono, navigazione grammatica. Voci di sistema e appropriatezza pedagogica di tutti gli estratti richiedono ancora revisione umana.

## Blocco 3: esame, piazzamento e banca originale

- Simulazione: avvio temporizzato, due letture automatiche, pause 10/15 secondi configurabili, nessun riascolto né feedback; variante carta con 3 minuti per trascrivere le risposte. Lettura: 20 minuti, navigazione, segnalibri e risposte mancanti. Le interruzioni invalidano la prova per la stima.
- Allenamento: riascolto, voce rallentata e correzione subito dopo la risposta. La sintesi Apple viene salvata in una cache locale e riprodotta con AVAudioPlayer a velocità 0,8×; la simulazione usa 1×.
- Piazzamento: 20 quesiti (10 ascolto, 10 lettura), limite 15 minuti, risultati separati, tutte le unità accessibili.
- 800 varianti originali costruite da schemi in `Scripts/build_exam_bank.py`; 8 prove riservate non sovrapposte (320 quesiti), 480 di allenamento. Il lessico è controllato contro le 300 parole; banca e contenuti IA sono disattivabili nel piano. Le varianti NON equivalgono a 800 item calibrati: la revisione umana non è stata eseguita.
- La stima usa una distribuzione beta-binomiale per parte e un intervallo predittivo all’80% su 40 risposte. Considera solo la prima prova completata valida per ogni forma. È dichiarata sperimentale e poco affidabile; il 60% è esclusivamente una soglia provvisoria. Non include ancora un modello di difficoltà tarato né una previsione individuale alla data d’esame.

```sh
.venv/bin/python ios/Scripts/build_exam_bank.py
.venv/bin/python check_pinyin.py ios/Content/exam_pinyin.txt
.venv/bin/python check_cs_pinyin.py ios/Content/exam_pinyin.txt
```

Zero segnalazioni nei due controlli. Test: 800 ID unici, separazione 320/480, otto parti da cinque, banche condivise di sei opzioni e esempio consumato, politiche di navigazione e feedback, salvataggio, invalidazione per interruzione, intervalli e piazzamento 10+10. Un test accelerato attraversa tutta la variante carta e verifica passaggio alla lettura e consegna; il percorso accelerato è disponibile solo nelle build DEBUG e non è esposto nell’interfaccia.

Non eseguita una sessione completa di 40 minuti con ascolto umano. Audio Apple, immagini simboliche e pause configurate richiedono confronto sul dispositivo prima di presentare il simulatore come riproduzione acustica fedele.

## Blocco 4: pratica locale e interfaccia senza footer

Il footer fisso è stato rimosso su richiesta: fonte, versione e dicitura di non affiliazione sono nella sezione «Fonti e progetto» del piano, insieme alle licenze. Nessun testo legale occupa più il fondo delle schermate di studio.

- Voci Apple provvisorie, senza servizi esterni. I dialoghi alternano due voci quando il dispositivo le offre; con una sola voce si usa quella disponibile. Cache CAF locale, riproduzione reale a 0,8× in allenamento e 1× nelle prove. Il test audio verifica sintesi, salvataggio e completamento della riproduzione, non la correttezza linguistica.
- Pronuncia con AVAudioEngine e YIN: curva dell’altezza, calibrazione individuale, etichetta orientativa e consiglio concreto. Priorità al terzo tono, al cambio 3–3 e alle parole di due sillabe. Nessun voto su cento. Le parole non vengono segmentate automaticamente per sillaba: per quelle si mostra la curva e una guida, senza fingere una diagnosi.
- 100 caratteri con ordine dei tratti, animazione, guida disattivabile, canvas PencilKit e salvataggio locale. Controllo del carattere inserito con la tastiera cinese e storia mnemonica personale. Nessuna valutazione automatica della grafia.
- 15 dialoghi originali con pinyin, italiano facoltativo, domanda di comprensione e invio delle parole nuove al ripasso. L’ordinamento usa le parole distinte già verificate: è un’indicazione di accessibilità del testo, non una misura calibrata della sua difficoltà. Domande e dialoghi IA sono disattivabili nel piano.
- Pratica orale con registrazione privata, riascolto e cancellazione: ripetizione 10 secondi, descrizione 15 secondi, risposta 90 secondi dopo 3 minuti di preparazione. È pratica preparatoria; HSK 1 non prevede una prova orale e questo modulo non è un simulatore completo HSK 3.
- Mini-test delle unità, copertura solo dopo verifiche distanziate e ripasso unificato anche per i toni. Le schede di grammatica restano distinte dalle parole che condividono lo stesso ID numerico.

```sh
.venv/bin/python ios/Scripts/build_dialogues.py
.venv/bin/python ios/Scripts/import_strokes.py
.venv/bin/python check_pinyin.py ios/Content/dialogues_pinyin.txt
.venv/bin/python check_cs_pinyin.py ios/Content/dialogues_pinyin.txt
```

Grafica: 95 caratteri provengono dai file già presenti nel prototipo; i cinque mancanti da `hanzi-writer-data@2.0.1`. Sono conservati solo tratti e mediane, con hash in `Content/strokes-provenance.json`. La licenza Arphic completa è inclusa nell’app; questo modulo non usa le scomposizioni LGPL v3.

Suite finale: **17 test superati, zero errori** (13 test di logica/contenuti e 4 test UI).

Verifiche automatiche: YIN su segnali noti da 80 a 480 Hz e rifiuto del silenzio; 100 grafici con percorsi validi, 15 dialoghi entro il vocabolario, sintesi e riproduzione Apple, navigazione dei moduli e assenza del footer. I due controlli pinyin sul nuovo corpus danno zero segnalazioni. Gli screenshot da 12 a 18, rigenerati nel blocco 5, mostrano queste funzioni con il nuovo design.

Restano da verificare con persone: pronuncia Apple (letture multiple, toni neutri, cambi tonali), naturalezza e difficoltà degli 800 quesiti, qualità dei feedback sul microfono reale, scrittura con Apple Pencil, accessibilità con VoiceOver e Dynamic Type. Non è stata eseguita una prova reale completa di 40 minuti; i test temporali usano un orologio accelerato. Il target minimo è iOS 17, ma il runtime provato è iOS 26.5 sul simulatore.

## Blocco 5: design «quaderno e sigillo»

L’interfaccia passa da schermate SwiftUI standard a un sistema unico, definito in `App/Design.swift` e usato da tutte le funzioni.

- Colori: carta calda (`#F4F1EA`), superfici bianche senza bordi, inchiostro (`#1E2422`) per testo e azioni primarie. Il rosso del sigillo (`#A6303C`) resta all’identità, alla selezione e agli errori; il giada (`#1F6B57`) alle risposte corrette e all’avanzamento. Testo secondario `#5C6360`: almeno 5:1 su carta e bianco. I colori dei toni restano quelli standard e configurabili.
- Tipografia a tre voci: New York per titoli compatti, SF per l’interfaccia, PingFang SC esplicito per i caratteri (forme semplificate garantite, Dynamic Type con `relativeTo`). Il pinyin sta sopra i caratteri a circa metà della loro dimensione; nelle prove e nei dialoghi resta sopra ogni carattere, colorato secondo il piano.
- Motivi riconoscibili: sigillo 步步 accanto al nome Bùbù, griglia 田字格 dietro le parole grandi e nella scrittura, percorso come sequenza di passi collegati (步步, passo dopo passo).
- Componenti condivisi: gruppi di righe al posto di una scheda per riga, un pulsante primario a tutta larghezza, un solo stile di opzione con stati selezionata/corretta/errata/attenuata, banner di esito, interruttori a pastiglia, metri di avanzamento e intervallo 0–40 per la preparazione.
- Sessioni: durante ripasso e prove la barra delle schede è nascosta; dopo la risposta le opzioni restano visibili con la soluzione e la pagina scorre fino a «Continua». Simulazione e piazzamento mostrano solo la selezione, senza correzione anticipata.
- Testi: slogan e titoli grandi sostituiti da intestazioni compatte; copertura e preparazione restano sezioni separate. «Il mio piano → Fonti e progetto» contiene programma, versione dell’app, licenze e dicitura di non affiliazione. Nessun footer fisso.
- Accessibilità: testo con stili dinamici, griglie che passano a una colonna nelle taglie di accessibilità, bersagli di almeno 44 punti, stato delle opzioni annunciato da VoiceOver (selezionata, corretta, errata) e annuncio dell’esito dopo ogni risposta. La punteggiatura cinese non apre mai una riga nel testo con pinyin.

Persistenza, dati didattici, FSRS, regole di simulazione (audio automatico due volte, niente riascolto né correzione anticipata) e di allenamento (riascolto, 0,8×, correzione immediata) non cambiano. Il test UI del ripasso torna indietro prima di cambiare scheda, perché la barra delle schede è nascosta durante la sessione, e salva due nuove catture: `19-ripasso-errore` e `20-pinyin-correzione`.

Verificato: suite completa **17 test superati, zero errori** su iPhone 17 Pro / iOS 26.4; controllo visivo su iPhone 17 Pro / iOS 26.5 di home, livello, percorso, unità, parole, ripasso (fronte, retro, errore, pinyin), grammatica e quiz, esame nelle tre modalità con correzione dell’allenamento e lettura del piazzamento, toni, scrittura, dialoghi, orale e piano; Dynamic Type «accessibility-large» su home, livello e carta del pinyin. Screenshot 01–20 in `evidence/`.

Da verificare: VoiceOver parlato su dispositivo, taglie di accessibilità più grandi su tutte le schermate, iPad, iOS 17 reale e risultato della simulazione completa con la stima a intervallo popolata.

## Blocco 6: pinyin e IPA

Nuova sezione «Pinyin e IPA» in HSK 1 → Studia, collegata al dettaglio di ogni parola.

- Tabelle di 23 iniziali e 39 finali con trascrizione IPA, gruppo articolatorio e indicazione pratica per chi parla italiano; un punto rosso segnala i suoni che un italiano tende a leggere come nella propria lingua (b/p, d/t, g/k, j, q, x, zh, c, e, ü, -i, iu, ui, un, ian…).
- Toni con le lettere di Chao e il grafico dei cinque livelli nei colori scelti nel piano; 3° tono basso dentro la parola, 3°+3° → 2°+3°, tono neutro secondo il tono precedente.
- Scheda di ogni suono con descrizione e fino a otto parole HSK 1 che lo contengono, ciascuna con IPA e ascolto.
- Convertitore dal pinyin all’IPA: accetta segni di tono o numeri (`xie4xie5`), scompone ogni sillaba in iniziale, finale e tono e, se la grafia corrisponde, apre la parola.
- Nel dettaglio parola, sezione «Pronuncia» con trascrizione completa e sillabe collegate alle schede dei suoni.

Logica in `Core/PinyinIPA.swift`, senza dipendenze: segmentazione con apostrofi e regola delle sillabe che iniziano per vocale, controllo delle combinazioni iniziale-finale, grafie y/w e ü, sillabe apicali, erhua delle parole HSK 1. Trascrizione larga del cinese standard secondo Wikipedia «Pinyin» (oldid 1379787349), «Standard Chinese phonology» (oldid 1380933413) ed «Erhua» (oldid 1380844942), basate su Lee & Zee 2003, Duanmu 2007, Lin 2007; confronto con «Help:IPA/Mandarin» (oldid 1370474013); toni secondo Chao 1968. Il 3° tono a metà parola è scritto [˨˩] per convenzione didattica: le fonti non danno un valore unico (Help:IPA/Mandarin scrive [˩]). L’erhua è trascritto solo per le finali verificate nella voce «Erhua».

Dove stanno i dati: le tabelle (suoni, indicazioni in italiano, toni) sono costanti in `Core/PinyinIPA.swift`, come `ToneExercise`; la trascrizione di ogni parola è calcolata dal pinyin del catalogo e non viene salvata. La sezione non aggiunge dati utente: il testo del convertitore resta in memoria. Le fonti sono elencate anche in «Licenze e componenti». Le varianti regionali sono escluse e alcune parole hanno eccezioni di tono che la regola non copre.

Test: tutte le 300 parole (con entrambe le grafie di 谁) e i 246 caratteri si scompongono in una sillaba per carattere, erhua compreso; trascrizioni di riferimento (hǎo, nǐ hǎo, lǎoshī, zì, xué, qù, nǚ’ér, zhèr, yǒudiǎnr, miàntiáor…); grafie non valide rifiutate; numeri convertiti in segni di tono. Test UI: convertitore, parola collegata e scheda del suono, con screenshot 21–23.

## Blocco 7: radicali colorati

Il radicale di ogni carattere è disegnato nel rosso del sigillo, con i tratti in stile kai della grafia Arphic.

- Griglia dei 246 caratteri: ogni tessera mostra il carattere disegnato dai tratti, con il radicale in rosso, e apre la nuova scheda «Carattere».
- Scheda «Carattere»: carattere grande, ascolto, radicale con forma, carattere di riferimento, pinyin e significato in italiano, caratteri con lo stesso radicale, parole che lo contengono e collegamento alla scrittura.
- Scrittura: radicale in rosso nell’ordine dei tratti e, attenuato, nella guida della tela.
- Dettaglio parola: caratteri nella griglia 田字格 con il radicale colorato e sezione «Caratteri» collegata alle schede.

Dati, tutti nel bundle e generati da `Scripts/import_radicals.py`:
- `Resources/strokes.json` sostituisce `writing-strokes.json` e copre 253 caratteri (246 da riconoscere, 5 solo da scrivere, 店 e 饺 delle parole). È ancora soltanto grafica Arphic: tratti e mediane, hash in `Content/strokes-provenance.json`. 店 e 饺 vengono da `hanzi-writer-data@2.0.1`, come gli altri cinque extra.
- Numero e forma del radicale: Unicode 18.0 Unihan (`kRSUnicode`, sistema Kangxi con le forme semplificate) e `CJKRadicals.txt`, Unicode License v3 inclusa nell’app. L’estratto versionato `Content/unihan-radicals.txt` riporta l’hash di `Unihan.zip`.
- Tratti del radicale: annotazione originale di questo progetto in `Content/radicals.tsv`, secondo l’ordine dei tratti dello standard cinese; forme, pinyin e significati in `Content/radical_forms.tsv`. Le scomposizioni e i `radStrokes` di Make Me a Hanzi (LGPL v3) restano esclusi.

Lo script verifica che ogni carattere abbia il radicale indicato da Unihan, che il numero di tratti corrisponda alla forma (氵 3, 讠 2, 辶 3…) e ai tratti residui di Unihan. Sei caratteri contano i tratti in modo diverso da Unihan (以, 些, 哪, 猫, 都, 睡) e sono annotati esplicitamente. Tutti i 253 caratteri sono stati controllati visivamente su un’anteprima generata dallo script (`--preview`). Controllo incrociato, solo di verifica e senza includere dati: confronto con i `radStrokes` di hanzi-writer-data presenti nel prototipo. 191 caratteri su 199 coincidono. Quattro errori di questa annotazione sono stati corretti con la geometria dei tratti: in 起 e 超 il 走 si scrive per intero prima del componente a destra; in 年 la verticale parte dall’orizzontale in alto; in 也 il radicale è 乚, l’ultimo tratto. Tre differenze dipendono dal sistema di radicali (视 礻/见, 习 乙/冫, 书 乙/丨): qui vale Unihan. In 电 il radicale 田 comprende il 竖弯钩 che ne forma la verticale centrale.

Test: tutti i caratteri hanno radicale, pinyin e significato con tratti validi; casi di riferimento (好 女, 汉 氵, 这 辶, 国 囗 a cornice, 我 戈 intrecciato, 起 走 col tratto finale, 能 e 脑 con il radicale carne); test UI della griglia e della scheda con screenshot 24–25.

Da verificare con un insegnante: scelta del radicale nei caratteri dove il sistema Kangxi è poco intuitivo (年 干, 电 田, 九 乙) e significati brevi in italiano.

## Blocco 8: significato e immagine di ogni carattere

Ogni carattere ha un significato breve in italiano e un’immagine che ne suggerisce il senso a colpo d’occhio.

- Griglia dei caratteri: immagine piccola nell’angolo di ogni tessera.
- Scheda «Carattere»: immagine grande e significato sotto il carattere.
- Scrittura e dettaglio parola: significato con immagine accanto a ogni carattere.
- Riconoscimento nel ripasso: significato e immagine compaiono solo dopo la risposta, come le emoji delle parole.

Dati: `Content/character_meanings.tsv` → `Resources/character-meanings.json` (`Scripts/import_character_meanings.py`).
- 137 caratteri sono anche parole del catalogo: significato ed emoji della parola. Le 29 parole senza emoji ricevono un’immagine; 国 passa da 🏳️ (bandiera bianca) a 🗺️ solo per il carattere.
- 116 caratteri hanno un significato scritto per Bùbù, controllato sulle definizioni Unihan (`kDefinition`) e riferito all’uso nell’HSK 1; da rivedere come gli altri contenuti originali.
- Immagini: emoji di sistema Apple, offline. Dove non esiste un’emoji adatta, 12 disegni originali in SVG nello stesso stile (`Assets.xcassets/glyph-*`): 桌 tavolo, 千 1000, 的 possesso, 了 azione compiuta, 呢 «e tu?», 也 «+1», 都 tutti, 我 io e la famiglia dei classificatori «1 + oggetto» per 个, 件, 只, 条.

Lo script verifica che tutti i 253 caratteri abbiano significato e immagine, che i disegni esistano e che i significati presi dalle parole coincidano con il catalogo. L’asset catalog non contiene ancora l’icona dell’app (`ASSETCATALOG_COMPILER_APPICON_NAME` vuoto in `project.yml`).

Sviluppi ulteriori del report: calibrazione della difficoltà e previsione alla data d’esame, consolidamento finale guidato, scomposizioni didattiche dei caratteri, esercizi specifici HSK 2 e simulatore orale completo HSK 3. L’MVP non presenta queste capacità come già disponibili.
