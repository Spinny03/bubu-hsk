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

La copertura di una parola richiede le tre direzioni e almeno due risposte corrette separate da 20 ore per ciascuna. Le ripetizioni immediate non gonfiano il conteggio. Le 70 righe di grammatica sono mappate in `Content/grammar_map.tsv` alle pagine PDF 386–388 del programma e a estratti di `content/`; il quiz misura la comprensione di un esempio, non certifica l’intera struttura. Gli estratti del libro possono superare il lessico HSK 1 e sono dichiarati come approfondimento.

Rigenerazione e verifiche:

```sh
.venv/bin/python ios/Scripts/import_grammar.py
.venv/bin/python check_pinyin.py ios/Content/grammar_pinyin.txt
.venv/bin/python check_cs_pinyin.py ios/Content/grammar_pinyin.txt
```

Entrambi i controlli danno zero segnalazioni sul nuovo corpus. Test: obbligo dei toni, letture alternative, salvataggio di eventi e scadenze, ripetizioni immediate, 70 collegamenti alle fonti; UI: fronte senza emoji, retro dopo la risposta, rifiuto del pinyin senza tono, navigazione grammatica. Voci di sistema e appropriatezza pedagogica di tutti gli estratti richiedono ancora revisione umana.

## Blocco 3: esame, piazzamento e banca originale

- Simulazione: avvio temporizzato, due letture automatiche, pause 10/15 secondi configurabili, nessun riascolto né feedback; variante carta con 3 minuti per trascrivere le risposte. Lettura: 20 minuti, navigazione, segnalibri e risposte mancanti. Le interruzioni invalidano la prova per la stima.
- Allenamento: riascolto, voce rallentata e correzione subito dopo la risposta. Il fattore di velocità di AVSpeechSynthesizer è provvisorio, non una misura acustica certificata.
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
