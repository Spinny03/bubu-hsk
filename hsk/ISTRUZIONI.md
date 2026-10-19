COMPITO: vocabolario HSK 3.0 illustrato, in ITALIANO per italofoni.

Input: un file hsk/input/<nome>.txt; ogni riga è una parola della lista ufficiale HSK 3.0:
  hanzi | letture pinyin candidate (da CC-CEDICT, sillabe staccate, separate da " / ") | significati in inglese | categorie grammaticali
Output: hsk/out/<nome>.txt (stesso nome), STESSO ORDINE dell'input, una riga per parola, nel formato:
  hanzi | pinyin | italiano | emoji | livello
(livello = il numero HSK del file: h1* → 1, h2* → 2, h3* → 3). Nessuna riga @, nessun commento, nessuna riga vuota.

PINYIN (regole obbligatorie)
- Scegli la lettura usata nel significato HSK comune (es. 便宜 piányi, non biànyí; 吧 ba; 啊 a; 大夫 dàifu).
  Ignora le letture che sono solo cognomi (Bái, Bǎi …) salvo che la parola sia un nome proprio.
- Segmentazione standard in una parola sola: àihào, xuésheng, Zhōngguó, péngyou (NON "ài hào").
  Le espressioni con spazio nell'ortografia standard restano separate (es. 对不起 duìbuqǐ, 不客气 bú kèqi, 下雨 xià yǔ).
- Tono neutro senza segno dove è standard nel parlato (xièxie, péngyou, yīfu, dōngxi, xǐhuan, rènshi, zhīdao,
  shíhou, piàoliang, míngbai, ba, ma, ne, le, de, zhe, guo, men, zi come suffisso).
- 一 e 不 marcati come pronunciati dentro le parole (yìqǐ, yídìng, yíyàng, yìdiǎnr, bú cuò, bù hǎo); 一 isolato yī.
- Sandhi del terzo tono NON marcato. Iniziale minuscola salvo nomi propri. Segni tonali, mai numeri.
- Se una parola ha due letture/significati entrambi frequenti e importanti a quel livello (es. 还 hái/huán,
  长 cháng/zhǎng, 得 de/děi, 觉 jiào/jué, 行 xíng/háng), puoi scrivere DUE righe consecutive, una per lettura.

ITALIANO
- Traduzione breve e naturale (max ~32 caratteri), i significati principali separati da ", ".
  Verbi all'infinito; parole grammaticali spiegate brevemente (es. 了 «particella: azione compiuta»,
  吗 «particella interrogativa», 个 «classificatore generico»).
- Per i nomi, il classificatore principale tra parentesi solo se non è 个: «libro (本)».

EMOJI
- UNA sola emoji Unicode standard che evochi IN MODO IMMEDIATO il significato (苹果 🍎, 跑 🏃, 下雨 🌧️,
  医生 🧑‍⚕️, 中国 🇨🇳, 高兴 😄). Se non ce n'è una chiara, scrivi "-": meglio nessuna immagine che una fuorviante.
  Per numeri 0–10 puoi usare le emoji 0️⃣…🔟.

CONTROLLO FINALE
- Verifica che il numero di righe dell'output sia uguale all'input (più eventuali righe doppie volute).
- Puoi verificare il pinyin con:
  cd . && .venv/bin/python -c "from pypinyin import pinyin; import sys; print(pinyin(sys.argv[1]))" 词语
  (pypinyin non applica toni neutri né cambi tonali di 一/不: giudica tu).
- Non toccare altri file. Risposta finale: solo il nome del file scritto, il numero di righe, ed eventuali parole dubbie.
