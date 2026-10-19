REVISIONE DEL CHEATSHEET (versione 2) — richiesta dell'utente: «più comprensibile, senza spazi bianchi
inutili, mettere sempre il pinyin con i caratteri».

Riscrivi i TUOI file in cheatsheet/ (sovrascrivili) mantenendo TUTTI gli argomenti e il formato di riga
(SPEC_CONTENUTI.md + SPEC_EXTRA.md sezione A). Regole nuove, obbligatorie:

1) PINYIN SEMPRE. Ogni parola o espressione cinese in QUALSIASI riga che non sia ex:/no: (titoli ##,
   testo, elenchi "-", note "!", strutture "=", celle di tabella) va seguita SUBITO dal suo pinyin:
     ## La particella 了 le
     = S + 把 bǎ + O + V + altro
     = 虽然 suīrán …… 但是 dànshì ……
     - 很 hěn davanti all'aggettivo è quasi obbligatorio
     | 我喝茶 wǒ hē chá | …
   Per parole spezzate da ……, metti il pinyin dopo ciascun pezzo (come sopra) oppure dopo tutto
   ("一……就 yī……jiù"). Il pinyin segue le convenzioni di SPEC_CONTENUTI.md (toni, segmentazione,
   tono neutro, 一/不 come pronunciati). Il carattere singolo citato come voce grammaticale ha la sua
   lettura base (了 le, 得 de, 着 zhe, 过 guo, 一 yī, 不 bù) salvo quando mostri il cambio tonale.
   NON usare il pinyin tra parentesi in mezzo a parole italiane in modo che si confonda: scrivi
   «汉字 pinyin» e poi l'italiano.
   I titoli "#" dei blocchi tematici restano SOLO in italiano (niente cinese).

2) PIÙ COMPRENSIBILE.
   - Ogni punto "##" inizia con UNA frase in italiano semplice che dice A COSA SERVE / QUANDO SI USA
     (es. «Serve a dire che un'azione è finita.»). Niente gergo non spiegato.
   - Usa solo le abbreviazioni S, V, O, Agg, N, Num, CL, Avv, Prep, Luogo, Tempo
     (vengono spiegate in una legenda iniziale). Niente altre sigle (no "V1/V2" senza spiegazione,
     no "OD", no "PERF").
   - Nelle tabelle colonne con intestazioni chiare in italiano, max 4 colonne; una colonna "Esempio"
     contiene esempio + pinyin + (se c'è spazio) traduzione breve, oppure metti l'esempio in una riga ex:.
   - Gli esempi ex: hanno SEMPRE tutti e tre i campi (hanzi | pinyin | traduzione italiana).
   - Ogni esempio deve essere breve e quotidiano.

3) NIENTE SPAZI BIANCHI INUTILI: frasi brevi, niente righe vuote ripetute, niente blocchi di sola
   introduzione. Non allungare: la lunghezza totale dei tuoi file deve restare simile a quella attuale
   (±15%); il pinyin aggiuntivo va compensato tagliando parole superflue.

CONTROLLI (devono dare 0 segnalazioni sui tuoi file prima di finire):
  cd .
  .venv/bin/python check_cs_pinyin.py cheatsheet/<tuoi file>      # caratteri senza pinyin / pinyin errato
  .venv/bin/python check_pinyin.py cheatsheet/<tuoi file>         # pinyin degli esempi ex:/no:
  .venv/bin/python build_pdf.py --check --content cheatsheet      # formato
(I controlli automatici conoscono le letture del dizionario, non il contesto: se segnalano un falso
positivo — es. lettere latine come «AA制» — lascialo e indicalo nella risposta.)
Non toccare file di altri. Risposta finale: file riscritti, righe prima/dopo, segnalazioni residue.
