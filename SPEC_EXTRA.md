SPECIFICA COMUNE — materiali aggiuntivi alla «Grammatica completa del cinese mandarino»
Tutto in ITALIANO per italofoni; cinese mandarino standard, caratteri semplificati.
Convenzioni pinyin: identiche a SPEC_CONTENUTI.md (sezione "Pinyin conventions"): segni tonali, mai numeri;
segmentazione standard (xuésheng, Zhōngguó, kàn shū); tono neutro senza segno (yīfu, xǐhuan, dōngxi);
一/不 marcati come pronunciati (yí ge, bú shì); sandhi del terzo tono NON marcato.

A) CHEATSHEET (cartella cheatsheet/) — stesso formato di riga di SPEC_CONTENUTI.md, ma:
- "# Titolo" = blocco tematico (NON va a pagina nuova), "## Titolo" = punto grammaticale; niente "@" e niente "###".
- Estrema concisione: è un foglio di ripasso, non un libro. Per ogni punto: 1 riga di spiegazione al massimo,
  la/le strutture "=", UN esempio "ex:" breve (max ~12 caratteri cinesi), eventuale "no:" solo per errori
  davvero tipici. Preferisci tabelle compatte (max 4 colonne, celle < 30 caratteri) per i confronti.
- Le traduzioni negli ex: brevissime. Niente frasi introduttive, niente rimandi ad altri capitoli.
- Deve coprire TUTTA la grammatica del libro (vedi l'indice in SPEC_CONTENUTI.md), nessun argomento escluso.

B) VOCABOLARIO ILLUSTRATO (cartella vocab/) — formato:
@ Nome del tema | 🍎                 → inizio di un tema, con l'emoji del tema
汉字 | pinyin | italiano | emoji | livello
  · livello = 1, 2, 3 o 4 (livello HSK 2.0 approssimativo della parola)
  · emoji = UNA sola emoji Unicode standard (preferibilmente un solo code point, versione Unicode ≤ 13)
    che evochi IN MODO CHIARO il significato (苹果 → 🍎, 医生 → 🧑‍⚕️ va bene, 跑 → 🏃).
    Se non esiste un'emoji che faccia capire subito la parola, metti "-" (meglio nessuna immagine che una
    fuorviante). Per parole astratte si può usare un'emoji evocativa solo se l'associazione è immediata
    (高兴 → 😄, 冷 → 🥶, 大 / 小 → no).
  · italiano: traduzione breve (max ~30 caratteri); per i verbi l'infinito; più significati separati da ", ".
  · per i nomi aggiungi il classificatore principale tra parentesi nell'italiano solo se non è 个,
    nella forma «libro (本)».
- Una parola per riga, niente duplicati all'interno della tua parte, niente righe vuote dentro un tema.
- Ordina le parole all'interno del tema dalle più utili alle meno utili.
- Il pinyin delle parole isolate ha l'iniziale minuscola (tranne nomi propri); 一/不 dentro le parole marcati come pronunciati (yìqǐ, yídìng, bú cuò).
