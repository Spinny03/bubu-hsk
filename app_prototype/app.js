/* Bùbù 步步 — prototipo navigabile (dati reali: programma ufficiale HSK 2025, livello 1) */
(() => {
  const D = window.DATA;
  const $ = (s) => document.querySelector(s);
  const screen = $('#screen');
  const params = new URLSearchParams(location.search);
  if (params.get('shot')) document.body.classList.add('shot');

  // ---------------------------------------------------------------- stato finto ma plausibile
  const LEARNED_UNITS = 4;                          // unità 1–4 completate, la 5 in corso
  const known = (w) => w.unit <= LEARNED_UNITS;
  const mastery = (w) => (w.unit < LEARNED_UNITS ? 4 : w.unit === LEARNED_UNITS ? 3 : w.unit === 5 ? 1 : 0);
  const byHz = Object.fromEntries(D.words.map((w) => [w.hz, w]));
  const knownWords = D.words.filter(known).length;
  const knownChars = D.chars.filter((c) => c.words.some((h) => byHz[h] && known(byHz[h]))).length;

  // ---------------------------------------------------------------- icone
  const I = {
    levels: '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linejoin="round"><path d="M12 3 2.5 8 12 13l9.5-5z"/><path d="m2.5 12.5 9.5 5 9.5-5"/><path d="m2.5 16.5 9.5 5 9.5-5" opacity=".5"/></svg>',
    review: '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linejoin="round"><rect x="3.5" y="6" width="13" height="15" rx="3"/><path d="M8 3h9.5A3 3 0 0 1 20.5 6v12"/><path d="m7.5 13.5 2 2 4-4"/></svg>',
    exam: '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linejoin="round"><rect x="4.5" y="4" width="15" height="17.5" rx="3"/><path d="M9 4V2.8h6V4M8.5 10h7M8.5 14h7M8.5 18h4"/></svg>',
    search: '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.9" stroke-linecap="round"><circle cx="11" cy="11" r="6.5"/><path d="m16 16 4.5 4.5"/></svg>',
    profile: '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8"><circle cx="12" cy="8.5" r="4"/><path d="M4 20.5c1.3-3.8 4.4-5.5 8-5.5s6.7 1.7 8 5.5" stroke-linecap="round"/></svg>',
    back: '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.4" stroke-linecap="round" stroke-linejoin="round"><path d="M15 5l-7 7 7 7"/></svg>',
    chev: '<svg class="chev" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.4" stroke-linecap="round" stroke-linejoin="round"><path d="m9 5 7 7-7 7"/></svg>',
    speaker: '<svg viewBox="0 0 24 24" fill="currentColor"><path d="M4 9.5h3.5L12.5 5v14l-5-4.5H4z"/><path d="M15.5 8.5a5 5 0 0 1 0 7M18 6a8.5 8.5 0 0 1 0 12" fill="none" stroke="currentColor" stroke-width="1.9" stroke-linecap="round"/></svg>',
    mic: '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"><rect x="8.5" y="3" width="7" height="12" rx="3.5" fill="currentColor"/><path d="M5.5 11.5a6.5 6.5 0 0 0 13 0M12 18v3"/></svg>',
    play: '<svg viewBox="0 0 24 24" fill="#fff"><path d="M8 5.5v13l10.5-6.5z"/></svg>',
    x: '<svg viewBox="0 0 24 24" width="16" height="16" fill="none" stroke="currentColor" stroke-width="2.6" stroke-linecap="round"><path d="M6 6l12 12M18 6 6 18"/></svg>',
  };

  // ---------------------------------------------------------------- utilità
  const esc = (s) => String(s ?? '').replace(/[&<>"]/g, (c) => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;' }[c]));
  const hz = (w) => w.tones.length === [...w.hz].length
    ? [...w.hz].map((c, i) => `<span class="t${w.tones[i]}">${c}</span>`).join('') : esc(w.hz);
  const py = (w) => w.pyseg.map(([t, n]) => (n < 0 ? esc(t) : `<span class="t${n}">${esc(t)}</span>`)).join('');
  const hlEx = (text, target) => esc(text).split(esc(target)).join(`<span class="hl">${esc(target)}</span>`);
  const rel = (n) => n.toLocaleString('it-IT');
  const daysTo = (iso) => Math.ceil((new Date(iso) - new Date(new Date().toDateString())) / 864e5);

  let voice = null;
  const pickVoice = () => {
    const vs = speechSynthesis.getVoices();
    voice = vs.find((v) => /zh[-_]CN/i.test(v.lang)) || vs.find((v) => /^zh/i.test(v.lang)) || null;
  };
  if ('speechSynthesis' in window) { pickVoice(); speechSynthesis.onvoiceschanged = pickVoice; }
  const say = (text, rate = 0.85) => {
    if (!('speechSynthesis' in window)) return;
    const u = new SpeechSynthesisUtterance(text);
    u.lang = 'zh-CN'; u.rate = rate; if (voice) u.voice = voice;
    speechSynthesis.cancel(); speechSynthesis.speak(u);
  };
  window.say = say;

  const ring = (pct, size = 96, stroke = 10, color = 'var(--red)') => {
    const r = (size - stroke) / 2, c = 2 * Math.PI * r;
    return `<svg width="${size}" height="${size}"><circle cx="${size / 2}" cy="${size / 2}" r="${r}" stroke="var(--line2)" stroke-width="${stroke}" fill="none"/>
      <circle cx="${size / 2}" cy="${size / 2}" r="${r}" stroke="${color}" stroke-width="${stroke}" fill="none" stroke-linecap="round"
      stroke-dasharray="${c}" stroke-dashoffset="${c * (1 - pct / 100)}"/></svg>`;
  };
  const bar = (v, max, cls = '') => `<div class="bar ${cls}"><i style="width:${Math.round((100 * v) / max)}%"></i></div>`;
  const nav = (backTo, backLabel, title = '', act = '') => `<div class="navbar">
      <a class="back" href="#${backTo}">${I.back}${esc(backLabel)}</a><div class="nav-title">${title}</div>
      <div class="nav-act">${act}</div></div>`;
  const audioBtn = (text, cls = 'audio') => `<button class="${cls}" onclick="say('${esc(text)}')" aria-label="Ascolta">${I.speaker}</button>`;

  // ---------------------------------------------------------------- schermate
  const S = {};

  S.home = () => {
    const due = 24, days = daysTo('2026-12-13');
    const lv = D.levels.map((l, i) => {
      const cur = i === 0, pct = cur ? 38 : 0;
      const meta = i === 0 ? `${l.words} parole · ${l.chars} caratteri · 15 unità`
        : `+${rel(l.new)} parole (${rel(l.words)} in tutto) · ${rel(l.chars)} caratteri`;
      return `<a class="card level ${cur ? 'current' : ''}" href="#/level/${l.id}">
        <div class="lv-badge"><b>${l.id}</b><span>livello</span></div>
        <div class="grow"><div class="row" style="gap:8px"><span class="lv-name">HSK ${l.id}</span>
          <span class="pill ${cur ? 'red' : ''}" style="padding:2px 8px;font-size:11.5px">${l.tag}</span></div>
          <div class="lv-meta">${meta}</div>
          ${cur ? `<div class="row" style="gap:8px">${bar(pct, 100)}<span class="tiny bold">${pct}%</span></div>` : ''}
        </div>${I.chev}</a>`;
    }).join('');
    return `<div class="large-title">Livelli</div>
      <div class="subtitle">Buongiorno! Oggi ti servono circa 15 minuti.</div>
      <div class="today"><div class="seal">步</div>
        <div class="small" style="opacity:.85;font-weight:600">RIPASSO DI OGGI</div>
        <div class="row" style="align-items:baseline;gap:8px"><span class="big">${due}</span><span>carte · circa 8 min</span></div>
        <div class="split"><span>14 parole</span><span>6 caratteri</span><span>3 frasi</span><span>1 tono</span></div>
        <a class="btn" href="#/study/review">Inizia il ripasso</a></div>
      ${days > 0 ? `<div class="exam-strip">🗓️ <span><b>Nuovo HSK:</b> primo esame il 13 dicembre 2026 · tra ${days} giorni</span></div>` : ''}
      <div class="section-h">Il tuo percorso<small>HSK 3.0</small></div>
      ${lv}
      <div class="tiny muted" style="padding:2px 22px 10px">Parole e caratteri dal programma ufficiale HSK 考试大纲 kǎoshì dàgāng (2025).</div>`;
  };

  S.level = (id) => {
    const l = D.levels.find((x) => x.id === id) || D.levels[0];
    if (l.id !== '1') {
      return `${nav('/', 'Livelli', 'HSK ' + l.id)}<div class="large-title">HSK ${l.id} <span class="hz muted" style="font-size:22px">${l.cn}</span></div>
        <div class="subtitle">${rel(l.words)} parole in tutto · ${rel(l.chars)} caratteri</div>
        <div class="card pad"><b>Contenuti in preparazione</b><p class="muted small" style="margin:6px 0 0">
        Nel prototipo è completo solo l'HSK 1. Ogni livello avrà la stessa struttura: percorso per compiti,
        parole, caratteri, grammatica, pronuncia, ascolto, lettura ed esame simulato.</p></div>`;
    }
    const g = 6;
    return `${nav('/', 'Livelli', '', '···')}
      <div class="large-title">HSK 1 <span class="hz muted" style="font-size:22px">一级 yī jí</span></div>
      <div class="subtitle">Principiante · 15 unità · esame: 40 domande in 40 minuti</div>
      <div class="hero"><div class="ring">${ring(38)}<div class="val"><b>38%</b><span>pronto</span></div></div>
        <div class="cov">
          <div><div class="lab"><span>Parole</span><b>${knownWords}/300</b></div>${bar(knownWords, 300, 'jade')}</div>
          <div><div class="lab"><span>Caratteri</span><b>${knownChars}/246</b></div>${bar(knownChars, 246, 'gold')}</div>
          <div><div class="lab"><span>Grammatica</span><b>${g}/${D.grammar.length}</b></div>${bar(g, D.grammar.length, 'blue')}</div>
          <div><div class="lab"><span>Compiti</span><b>4/15</b></div>${bar(4, 15)}</div>
        </div></div>
      <a class="continue" href="#/unit/5"><div class="em">🏫</div><div class="grow">
        <div class="tiny" style="opacity:.7;font-weight:600">CONTINUA · UNITÀ 5</div><div class="bold">Luoghi e ambienti</div>
        <div class="tiny" style="opacity:.75">Passo 2 di 5 · Grammatica: 在 zài + luogo</div></div><div class="play">${I.play}</div></a>
      <div class="grid">
        <a class="tile wide" href="#/units/1"><div class="ic" style="background:var(--red-soft)">🧭</div>
          <div class="grow"><b>Percorso</b><br><span>15 unità = i 15 compiti ufficiali dell'esame</span></div>${I.chev}</a>
        <a class="tile" href="#/words/1"><div class="ic" style="background:var(--jade-soft)">📖</div><b>Parole</b><span>${knownWords} di 300 imparate</span></a>
        <a class="tile" href="#/chars/1"><div class="ic" style="background:var(--gold-soft)">✍️</div><b>Caratteri</b><span>246 da riconoscere</span></a>
        <a class="tile" href="#/grammar/1"><div class="ic" style="background:var(--blue-soft)">🧩</div><b>Grammatica</b><span>${D.grammar.length} punti, in italiano</span></a>
        <a class="tile" href="#/tones"><div class="ic" style="background:#F1E9FB">🎵</div><b>Pronuncia</b><span>Toni con grafico della voce</span></a>
        <a class="tile" href="#/listen"><div class="ic" style="background:#E6F4F6">🎧</div><b>Ascolto</b><span>15 dialoghi graduati</span></a>
        <a class="tile" href="#/read"><div class="ic" style="background:#F6EFE6">📰</div><b>Lettura</b><span>Testi con solo parole note</span></a>
        <a class="tile wide" href="#/exam/1" style="background:var(--ink);color:#fff;border-color:var(--ink)">
          <div class="ic" style="background:rgba(255,255,255,.12)">📝</div><div class="grow"><b>Esame simulato</b><br>
          <span style="color:rgba(255,255,255,.7)">Formato ufficiale 2026 · ultimo: 31/40</span></div>${I.chev}</a>
      </div>`;
  };

  S.units = () => {
    const rows = D.units.map((u) => {
      const done = u.n <= LEARNED_UNITS, now = u.n === 5;
      const gps = D.grammar.filter((g) => g.unit === u.n).length;
      return `<a class="unit ${now ? 'now' : ''}" href="#/unit/${u.n}"><div class="u-ic">${u.emoji}${done ? '<span class="ok">✓</span>' : ''}</div>
        <div class="grow"><div class="u-t">${u.n}. ${esc(u.it)}</div>
        <div class="u-s"><span class="hz">${u.cn}</span> ${esc(u.cnpy)}</div>
        <div class="u-s">${u.words} parole${gps ? ` · ${gps} grammatica` : ''}${now ? ' · <b style="color:var(--red)">in corso</b>' : ''}</div></div>${I.chev}</a>`;
    }).join('');
    return `${nav('/level/1', 'HSK 1', 'Percorso')}
      <div class="large-title" style="font-size:30px">Percorso HSK 1</div>
      <div class="subtitle">Ogni unità è uno dei 15 compiti del programma ufficiale: alla fine sai <b>fare</b> qualcosa, non solo riconoscere parole.</div>
      <div class="list">${rows}</div>`;
  };

  S.unit = (n) => {
    const u = D.units[(+n || 5) - 1];
    const ws = D.words.filter((w) => w.unit === u.n);
    const gps = D.grammar.filter((g) => g.unit === u.n);
    const done = u.n < 5, cur = u.n === 5;
    const st = (i) => (done || (cur && i === 0) ? 'done' : cur && i === 1 ? 'now' : '');
    const steps = [
      ['Parole', `${ws.length} parole · ripasso con ripetizione dilazionata`, `#/study/unit${u.n}`, '6 min'],
      ['Grammatica', gps.length ? gps.map((g) => g.title).join(' · ') : 'Ripasso delle strutture già viste', gps.length ? `#/gp/${gps[0].id}` : '#/grammar/1', '5 min'],
      ['Dialogo', 'Ascolta, leggi con o senza pinyin, ripeti', '#/listen', '4 min'],
      ['Pronuncia', 'Shadowing del dialogo con grafico dei toni', '#/tones', '3 min'],
      ['Mini-test', '10 domande nel formato dell\'esame', '#/examq', '5 min'],
    ].map(([t, s, href, min], i) => `<a class="step ${st(i)}" href="${href}"><div class="s-num">${st(i) === 'done' ? '✓' : i + 1}</div>
        <div class="grow"><div class="u-t">${t}</div><div class="u-s">${esc(s)}</div></div><span class="tiny muted">${min}</span>${I.chev}</a>`).join('');
    const chips = ws.slice(0, 9).map((w) => `<span class="pill" style="background:var(--paper)"><span class="hz" style="font-size:15px">${hz(w)}</span> <span style="font-weight:500">${py(w)}</span></span>`).join('');
    return `${nav('/units/1', 'Percorso', 'Unità ' + u.n)}
      <div class="u-hero"><div class="row"><div class="em">${u.emoji}</div><div class="grow">
        <div class="tiny muted bold">UNITÀ ${u.n} DI 15</div><div style="font-size:24px;font-weight:800;letter-spacing:-.3px">${esc(u.it)}</div>
        <div class="small muted"><span class="hz">${u.cn}</span> ${esc(u.cnpy)}</div></div></div>
        <div class="small bold" style="margin-top:14px">Alla fine saprai:</div>
        <ul class="cando">${u.cando.map((c) => `<li>${esc(c)}</li>`).join('')}</ul></div>
      <div class="section-h">5 passi · 23 minuti</div><div class="list">${steps}</div>
      <div class="section-h">Parole dell'unità<small>${ws.length}</small></div>
      <div style="display:flex;flex-wrap:wrap;gap:6px;padding:0 16px 16px">${chips}</div>`;
  };

  S.words = (lvl, filter = 'all') => {
    const groups = { all: D.words, known: D.words.filter(known), due: D.words.filter((w) => w.unit === LEARNED_UNITS || w.unit === 5), new: D.words.filter((w) => w.unit > 5) };
    const list = groups[filter] || D.words;
    const rows = list.map((w) => `<a class="li" href="#/word/${encodeURIComponent(w.hz)}">
        <div class="w-em">${w.emoji || '<span class="muted tiny">·</span>'}</div>
        <div class="w-hz hz">${hz(w)}</div>
        <div class="grow"><div class="w-py">${py(w)}</div><div class="w-it">${esc(w.it)}</div></div>
        <div class="mastery">${[1, 2, 3, 4].map((i) => `<i class="${mastery(w) >= i ? 'on' : ''}"></i>`).join('')}</div></a>`).join('');
    const chip = (k, label, n) => `<a class="chip ${filter === k ? 'on' : ''}" href="#/words/1/${k}">${label} ${n}</a>`;
    return `${nav('/level/1', 'HSK 1', '', '<span style="font-size:15px">Studia</span>')}
      <div class="large-title" style="font-size:30px">Parole HSK 1</div>
      <div class="subtitle">Le 300 parole del programma ufficiale, con toni a colori.</div>
      <div class="search">${I.search.replace('<svg', '<svg width="18" height="18"')}<input placeholder="Cerca in cinese, pinyin o italiano" oninput="filterWords(this.value)"></div>
      <div class="chips">${chip('all', 'Tutte', D.words.length)}${chip('known', 'Imparate', groups.known.length)}${chip('due', 'Da ripassare', groups.due.length)}${chip('new', 'Nuove', groups.new.length)}</div>
      <div class="list" id="wlist">${rows}</div>`;
  };
  window.filterWords = (q) => {
    q = q.trim().toLowerCase();
    const norm = (s) => s.normalize('NFD').replace(/[̀-ͯ]/g, '').toLowerCase();
    document.querySelectorAll('#wlist .li').forEach((el) => {
      el.style.display = !q || norm(el.textContent).includes(norm(q)) ? '' : 'none';
    });
  };

  // ---------------------------------------------------------------- studio (flashcard)
  let session = null;
  const startSession = (key) => {
    let cards;
    if (key === 'review') cards = D.words.filter((w) => w.unit === LEARNED_UNITS && w.emoji).slice(0, 14).concat(D.words.filter((w) => w.unit === 3).slice(0, 10));
    else if (key && key.startsWith('unit')) cards = D.words.filter((w) => w.unit === +key.slice(4));
    else cards = [byHz[decodeURIComponent(key)]].filter(Boolean);
    session = { key, cards: cards.length ? cards : D.words.slice(0, 20), i: 0, open: false, mode: 'rec' };
  };
  S.study = (key, flag) => {
    if (!session || session.key !== key) startSession(key);
    const s = session, w = s.cards[s.i % s.cards.length];
    if (flag === 'open' && !s.flagUsed) { s.open = true; s.flagUsed = true; }
    const front = s.mode === 'rec'
      ? `<div class="emo">${w.emoji || ''}</div><div class="big hz">${hz(w)}</div>`
      : `<div class="emo">${w.emoji || '❓'}</div><div class="it" style="font-size:26px;margin-top:22px">${esc(w.it)}</div>
         <div class="muted small" style="margin-top:6px">Scrivi o pronuncia la parola in cinese</div>`;
    const back = `${s.mode === 'rec' ? '' : `<div class="big hz">${hz(w)}</div>`}
        <div class="row" style="justify-content:center;gap:10px;margin-top:4px"><span class="py">${py(w)}</span>${audioBtn(w.hz)}</div>
        ${s.mode === 'rec' ? `<div class="it">${esc(w.it)}</div>` : ''}
        <div class="parts"><span>${esc(w.pos || 'espressione')}</span><span>Unità ${w.unit}</span>${w.hz.length > 1 ? `<span class="hz">${[...w.hz].join(' + ')}</span>` : ''}</div>
        ${w.ex ? `<div class="exbox"><div class="row"><div class="grow"><div class="hz">${hlEx(w.ex[0], w.hz)}</div>
          <div class="small muted" style="font-style:italic">${esc(w.ex[1])}</div><div class="small">${esc(w.ex[2])}</div></div>${audioBtn(w.ex[0], 'mini-audio')}</div></div>` : ''}`;
    const pct = Math.round((100 * s.i) / s.cards.length);
    return `<div class="session-top"><a class="x" href="#/level/1">${I.x}</a><div class="grow">${bar(s.i, s.cards.length, 'jade')}</div>
        <span class="small bold">${s.i + 1}/${s.cards.length}</span></div>
      <div class="chips" style="padding-bottom:4px">
        <button class="chip ${s.mode === 'rec' ? 'on' : ''}" onclick="setMode('rec')">Riconosci</button>
        <button class="chip ${s.mode === 'recall' ? 'on' : ''}" onclick="setMode('recall')">Ricorda</button>
        <button class="chip" onclick="say('${esc(w.hz)}')">Solo ascolto</button></div>
      <div class="flash" onclick="reveal()">
        <span class="pill mode ${s.mode === 'rec' ? 'jade' : 'blue'}">${s.mode === 'rec' ? 'Cinese → italiano' : 'Italiano → cinese'}</span>
        <span class="pill unitp">${pct}%</span>
        ${front}${s.open ? back : '<div class="tap">Pensa alla risposta, poi tocca per vederla</div>'}</div>
      ${s.open ? `<div class="rate">
        <button class="r1" onclick="rate(1)">Di nuovo<small>&lt; 1 min</small></button>
        <button class="r2" onclick="rate(2)">Difficile<small>8 min</small></button>
        <button class="r3" onclick="rate(3)">Bene<small>2 giorni</small></button>
        <button class="r4" onclick="rate(4)">Facile<small>5 giorni</small></button></div>` : ''}`;
  };
  window.reveal = () => { if (!session.open) { session.open = true; render(); say(session.cards[session.i].hz); } };
  window.rate = () => { session.i = (session.i + 1) % session.cards.length; session.open = false; render(); };
  window.setMode = (m) => { session.mode = m; session.open = false; render(); };

  S.word = (h) => S.study(h);

  // ---------------------------------------------------------------- ripasso
  S.review = () => {
    const days = [24, 18, 31, 12, 20, 9, 15];
    const names = ['Oggi', 'Dom', 'Lun', 'Mar', 'Mer', 'Gio', 'Ven'];
    const max = Math.max(...days);
    return `<div class="large-title">Ripasso</div>
      <div class="subtitle">Ti mostriamo ogni carta un attimo prima che tu la dimentichi (algoritmo FSRS).</div>
      <div class="today"><div class="seal">温</div>
        <div class="small" style="opacity:.85;font-weight:600">DA RIPASSARE OGGI</div>
        <div class="row" style="align-items:baseline;gap:8px"><span class="big">24</span><span>carte · circa 8 min</span></div>
        <a class="btn" href="#/study/review">Inizia</a></div>
      <div class="section-h">Cosa c'è nel ripasso</div>
      <div class="list">
        <div class="li"><div class="w-em">📖</div><div class="grow"><b>14 parole</b><div class="small muted">Significato ↔ cinese, con audio</div></div><span class="pill jade">14</span></div>
        <div class="li"><div class="w-em">✍️</div><div class="grow"><b>6 caratteri</b><div class="small muted">Riconoscere e, dall'HSK 2, scrivere</div></div><span class="pill gold">6</span></div>
        <div class="li"><div class="w-em">🧩</div><div class="grow"><b>3 frasi</b><div class="small muted">Ordine delle parole, 了 le, 在 zài + luogo</div></div><span class="pill blue">3</span></div>
        <div class="li"><div class="w-em">🎵</div><div class="grow"><b>1 coppia di toni</b><div class="small muted">mǎi «comprare» o mài «vendere»?</div></div><span class="pill red">1</span></div>
      </div>
      <div class="section-h">Prossimi 7 giorni</div>
      <div class="card pad"><div style="display:flex;align-items:flex-end;gap:10px;height:110px">
        ${days.map((d, i) => `<div style="flex:1;text-align:center"><div style="height:${(80 * d) / max}px;border-radius:8px;background:${i ? 'var(--line)' : 'var(--red)'}"></div>
          <div class="tiny muted" style="margin-top:6px">${names[i]}</div></div>`).join('')}</div>
        <div class="small muted" style="margin-top:10px">Sessioni brevi ogni giorno, niente vite da perdere: se salti un giorno le carte aspettano.</div></div>`;
  };

  // ---------------------------------------------------------------- grammatica
  S.grammar = () => {
    const rows = D.grammar.map((g, i) => `<a class="li" href="#/gp/${g.id}"><div class="s-num" style="${i < 6 ? 'background:var(--jade);color:#fff' : ''}">${i < 6 ? '✓' : i + 1}</div>
      <div class="grow"><div class="u-t">${esc(g.title)}</div><div class="u-s">${esc(g.sub)} · unità ${g.unit}</div></div>${I.chev}</a>`).join('');
    return `${nav('/level/1', 'HSK 1', 'Grammatica')}
      <div class="large-title" style="font-size:30px">Grammatica HSK 1</div>
      <div class="subtitle">I punti del programma ufficiale (语法大纲 yǔfǎ dàgāng), spiegati in italiano con gli errori tipici degli italiani.</div>
      <div class="list">${rows}</div>`;
  };

  const GP = {
    zai: {
      title: 'Dove si trova: 在 zài + luogo', unit: 5,
      why: 'Serve a dire <b>dove</b> si trova qualcuno o qualcosa, e dove si fa un\'azione. Il luogo va <b>prima</b> del verbo; le parole di posizione come 上 shàng «sopra» e 里 lǐ «dentro» vanno <b>dopo</b> il nome.',
      formulas: ['S + 在 zài + luogo', 'S + 在 zài + N + 上 shàng / 里 lǐ', 'S + 在 zài + luogo + V + O'],
      ex: [['我在家。', 'Wǒ zài jiā.', 'Sono a casa.', '在'], ['书在桌子上。', 'Shū zài zhuōzi shang.', 'Il libro è sul tavolo.', '在'],
        ['妈妈在医院里。', 'Māma zài yīyuàn li.', 'La mamma è in ospedale.', '在'], ['我在超市买水果。', 'Wǒ zài chāoshì mǎi shuǐguǒ.', 'Compro la frutta al supermercato.', '在']],
      wrong: [['我买水果在超市。', 'Wǒ mǎi shuǐguǒ zài chāoshì.', 'Il luogo non va in fondo come in italiano.'], ['我在超市买水果。', 'Wǒ zài chāoshì mǎi shuǐguǒ.', 'Compro la frutta al supermercato.']],
      tiles: ['水果', '我', '买', '超市', '在'], answer: '我在超市买水果',
      tilepy: { '水果': 'shuǐguǒ', '我': 'wǒ', '买': 'mǎi', '超市': 'chāoshì', '在': 'zài' },
      exam: 'All\'esame (ascolto, parte 4) capita spesso «说话人下午去哪里？ Shuōhuàrén xiàwǔ qù nǎli?» — «Dove va chi parla nel pomeriggio?».',
    },
    shi: {
      title: 'La frase con 是 shì', unit: 1,
      why: 'Serve a dire <b>chi o che cosa è</b> qualcuno: A 是 shì B. Non si usa davanti agli aggettivi: «sono stanco» è 我很累 wǒ hěn lèi, senza 是 shì.',
      formulas: ['A + 是 shì + B', 'A + 不是 bú shì + B', 'A + 是 shì + B + 吗 ma?'],
      ex: [['我是学生。', 'Wǒ shì xuésheng.', 'Sono uno studente.', '是'], ['他不是老师。', 'Tā bú shì lǎoshī.', 'Lui non è un insegnante.', '不是'],
        ['你是中国人吗？', 'Nǐ shì Zhōngguó rén ma?', 'Sei cinese?', '是']],
      wrong: [['我是很忙。', 'Wǒ shì hěn máng.', 'Davanti all\'aggettivo non si usa 是 shì.'], ['我很忙。', 'Wǒ hěn máng.', 'Sono impegnato.']],
      tiles: ['学生', '是', '我', '吗', '你'], answer: '你是学生吗',
      tilepy: { '学生': 'xuésheng', '是': 'shì', '我': 'wǒ', '吗': 'ma', '你': 'nǐ' },
      exam: 'All\'esame (lettura, parte 3) devi scegliere la parola che manca, per esempio «我（ ）一个哥哥。 Wǒ ( ) yí ge gēge.» → 有 yǒu, non 是 shì.',
    },
  };
  let built = [];
  S.gp = (id) => {
    const g = GP[id] || GP.zai;
    const exRow = ([h, p, t, target], mark = '') => `<div class="ex ${mark === '✗' ? 'wrong' : ''}">
        ${mark ? `<span class="mk" style="color:${mark === '✗' ? 'var(--red)' : 'var(--jade)'}">${mark}</span>` : ''}
        <div class="grow"><div class="hz">${target ? hlEx(h, target) : esc(h)}</div><div class="p">${esc(p)}</div><div class="t">${esc(t)}</div></div>${audioBtn(h, 'mini-audio')}</div>`;
    const ans = built.map((t) => `<span class="wt hz">${t}</span>`).join('');
    const tiles = g.tiles.map((t, i) => `<button class="wt hz ${built.includes(t) ? 'used' : ''}" onclick="pick(${i})">${t}<div class="tiny muted" style="font-family:var(--font)">${g.tilepy[t]}</div></button>`).join('');
    return `${nav('/grammar/1', 'Grammatica', '', '<span style="font-size:15px">Unità ' + g.unit + '</span>')}
      <div class="gp-title">${g.title.replace(/([一-鿿]+)/g, '<span class="hz" style="color:var(--red)">$1</span>')}</div>
      <div class="gp-why">${g.why}</div>
      ${g.formulas.map((f, i) => `<div class="formula">${i === 0 ? '<small>STRUTTURA</small>' : ''}${f.replace(/([一-鿿]+)/g, '<span class="hz">$1</span>')}</div>`).join('')}
      <div class="section-h">Esempi</div><div class="list">${g.ex.map((e) => exRow(e)).join('')}</div>
      <div class="section-h">Errore tipico degli italiani</div><div class="list">${exRow([...g.wrong[0], ''], '✗')}${exRow([...g.wrong[1], ''], '✓')}</div>
      <div class="section-h">Prova tu: riordina</div>
      <div class="card pad"><div class="answer">${ans || '<span class="muted small">Tocca le parole nell\'ordine giusto</span>'}</div>
        <div class="tiles">${tiles}</div>
        <div class="row" style="margin-top:14px;gap:8px"><button class="btn sm ghost" onclick="resetTiles()">Ricomincia</button><button class="btn sm" onclick="checkTiles('${id}')">Controlla</button></div>
        <div class="feedback" id="fb"></div></div>
      <div class="card pad small" style="background:var(--gold-soft);border-color:#F1E0BC">📝 <b>Nel test:</b> ${g.exam}</div>`;
  };
  window.pick = (i) => { const g = GP[route().arg] || GP.zai; const t = g.tiles[i]; if (!built.includes(t)) { built.push(t); render(); } };
  window.resetTiles = () => { built = []; render(); };
  window.checkTiles = (id) => {
    const g = GP[id] || GP.zai, ok = built.join('') === g.answer, fb = $('#fb');
    fb.className = 'feedback ' + (ok ? 'ok' : 'ko');
    fb.innerHTML = ok ? `✓ Giusto! <span class="hz">${g.answer}。</span> ${esc(g.ex.at(-1)[1])}` : '✗ Non ancora: ricorda che il luogo (o la domanda 吗 ma) ha un posto fisso. Riprova.';
    if (ok) say(g.answer);
  };

  // ---------------------------------------------------------------- pronuncia e toni
  let recState = 0;
  const contourPath = (pts, w = 330, h = 150) => pts.map(([x, y], i) => `${i ? 'L' : 'M'}${(x * w).toFixed(1)},${(h - ((y - 1) / 4) * (h - 20) - 10).toFixed(1)}`).join(' ');
  S.tones = (flag) => {
    if (flag === 'rec' && !S.tones.demo) { recState = 2; S.tones.demo = true; }
    const target = [[0.05, 2], [0.35, 1.1], [0.62, 1.2], [0.95, 4]];
    const user = [[0.05, 2.3], [0.3, 1.5], [0.6, 1.4], [0.8, 2.4], [0.95, 2.9]];
    const grid = [1, 2, 3, 4, 5].map((v) => `<line x1="0" x2="330" y1="${150 - ((v - 1) / 4) * 130 - 10}" y2="${150 - ((v - 1) / 4) * 130 - 10}" stroke="var(--line2)"/><text x="334" y="${154 - ((v - 1) / 4) * 130 - 10}" font-size="10" fill="#B0A69D">${v}</text>`).join('');
    const pairs = [['妈', 'mā', 1], ['麻', 'má', 2], ['马', 'mǎ', 3], ['骂', 'mà', 4]];
    return `${nav('/level/1', 'HSK 1', 'Pronuncia')}
      <div class="chips"><span class="chip on">Toni</span><span class="chip">Coppie minime</span><span class="chip">Sillabe (269)</span><span class="chip">Cambi tonali</span></div>
      <div class="tone-word"><div class="hz"><span class="t3">买</span></div>
        <div class="row" style="justify-content:center;gap:10px"><span class="py t3">mǎi</span>${audioBtn('买')}</div>
        <div class="muted small">comprare · 3° tono: scende e risale (214)</div></div>
      <div class="contour"><div class="legend"><span><i style="background:var(--t3)"></i>madrelingua</span><span><i style="background:var(--red)"></i>la tua voce</span></div>
        <svg viewBox="0 0 345 150" width="100%" height="150">${grid}
          <path d="${contourPath(target)}" fill="none" stroke="var(--t3)" stroke-width="5" stroke-linecap="round" stroke-linejoin="round" opacity=".85"/>
          ${recState === 2 ? `<path d="${contourPath(user)}" fill="none" stroke="var(--red)" stroke-width="3.5" stroke-dasharray="1 7" stroke-linecap="round"/>` : ''}
        </svg>
        ${recState === 2 ? `<div class="feedback ok" style="display:block;margin:4px 4px 6px">Quasi! Scendi bene, ma <b>risali troppo poco</b>: alla fine della parola il 3° tono torna su (fino a 4). <b>Punteggio tono: 72/100</b></div>`
          : '<div class="small muted" style="padding:4px 6px 8px">Ascolta, poi tieni premuto il microfono e ripeti: vedrai la tua curva sopra quella del madrelingua.</div>'}</div>
      <button class="mic ${recState === 1 ? 'rec' : ''}" onclick="record()">${I.mic}</button>
      <div class="center small muted" style="text-align:center;margin-bottom:14px">${recState === 1 ? 'Sto ascoltando…' : 'Tieni premuto per registrare'}</div>
      <div class="section-h">Quale hai sentito?<small onclick="quizTone()">▶︎ Ascolta</small></div>
      <div class="pairs" style="padding:0 16px 16px">${pairs.map(([c, p, t]) => `<button onclick="answerTone(this,${t})"><span class="t${t}">${p}</span><div class="tiny muted hz">${c}</div></button>`).join('')}</div>`;
  };
  let toneTarget = 3;
  window.quizTone = () => { toneTarget = 1 + Math.floor(Math.random() * 4); say(['妈', '麻', '马', '骂'][toneTarget - 1], 0.7); };
  window.answerTone = (el, t) => { el.classList.add(t === toneTarget ? 'ok' : 'ko'); };
  window.record = () => { recState = 1; render(); setTimeout(() => { recState = 2; render(); }, 1400); };

  // ---------------------------------------------------------------- caratteri
  S.chars = () => {
    const cells = D.chars.map((c) => {
      const k = c.words.some((h) => byHz[h] && known(byHz[h]));
      return `<a href="#/char/${encodeURIComponent(c.c)}" style="background:${k ? 'var(--jade-soft)' : 'var(--card)'};border:1px solid ${k ? '#CBE6D7' : 'var(--line2)'};border-radius:12px;padding:6px 0 4px;text-align:center">
        <div class="hz" style="font-size:24px;line-height:1.2">${c.c}</div><div class="tiny muted">${esc(c.py)}</div></a>`;
    }).join('');
    return `${nav('/level/1', 'HSK 1', 'Caratteri')}
      <div class="large-title" style="font-size:30px">Caratteri HSK 1</div>
      <div class="subtitle">246 caratteri da <b>riconoscere</b>. La scrittura a mano diventa obbligatoria dall'HSK 2 (100 caratteri).</div>
      <div class="chips"><span class="chip on">Tutti 246</span><span class="chip">Imparati ${knownChars}</span><span class="chip">Per radicale</span></div>
      <div style="display:grid;grid-template-columns:repeat(6,1fr);gap:6px;padding:0 16px 16px">${cells}</div>`;
  };
  S.char = (ch) => {
    ch = decodeURIComponent(ch || '好');
    const c = D.chars.find((x) => x.c === ch) || { c: ch, py: '', words: [] };
    const words = c.words.map((h) => byHz[h]).filter(Boolean);
    const info = { '好': ['女 nǚ «donna» + 子 zǐ «bambino»', 'Una donna con il suo bambino: una cosa <b>buona</b>.', 6, '女'],
      '爱': ['爫 zhǎo «mano» + 冖 mì «tetto» + 友 yǒu «amico»', 'Una mano che protegge un amico sotto un tetto: <b>amare</b>.', 10, '爫'] }[ch];
    return `${nav('/chars/1', 'Caratteri', '', '')}
      <div class="char-stage"><div class="grid-bg"><div id="hw"></div></div>
        <div class="row" style="gap:8px;margin-top:12px"><button class="btn sm ghost" onclick="hwAnimate()">▶︎ Ordine dei tratti</button><button class="btn sm" onclick="hwQuiz()">✍️ Scrivi tu</button></div></div>
      <div class="facts"><div class="fact"><b class="hz">${esc(c.py)}</b><span>lettura</span></div><div class="fact"><b>${info ? info[2] : '—'}</b><span>tratti</span></div><div class="fact"><b class="hz">${info ? info[3] : '—'}</b><span>radicale</span></div></div>
      ${info ? `<div class="card pad"><div class="small bold" style="margin-bottom:8px">Come è fatto</div><div class="comp"><div class="hz">${ch}</div><div class="grow small">${info[0]}<br><span class="muted">${info[1]}</span></div></div></div>` : ''}
      <div class="section-h">Parole HSK 1 con ${ch} ${esc(c.py)}<small>${words.length}</small></div>
      <div class="list">${words.map((w) => `<a class="li" href="#/word/${encodeURIComponent(w.hz)}"><div class="w-hz hz">${hz(w)}</div><div class="grow"><div class="w-py">${py(w)}</div><div class="w-it">${esc(w.it)}</div></div>${I.chev}</a>`).join('') || '<div class="li muted">—</div>'}</div>`;
  };
  let writer = null;
  const mountWriter = (ch) => {
    const el = $('#hw'); if (!el || !window.HanziWriter) return;
    writer = HanziWriter.create('hw', ch, {
      width: 230, height: 230, padding: 14, strokeColor: '#1F1A17', radicalColor: '#C23A2B',
      outlineColor: '#EFE5DC', delayBetweenStrokes: 220, strokeAnimationSpeed: 1.1, showCharacter: true,
      charDataLoader: (c, ok, ko) => (window.HANZI_DATA && window.HANZI_DATA[c] ? ok(window.HANZI_DATA[c])
        : fetch(`vendor/hanzi/${c}.json`).then((r) => r.json()).then(ok).catch(ko)),
    });
  };
  window.hwAnimate = () => writer && writer.animateCharacter();
  window.hwQuiz = () => writer && writer.quiz();

  // ---------------------------------------------------------------- ascolto e lettura
  const DIALOG = [['A', '请问，超市在哪儿？', 'Qǐngwèn, chāoshì zài nǎr?', 'Scusi, dov\'è il supermercato?'],
    ['B', '超市在医院后边。', 'Chāoshì zài yīyuàn hòubian.', 'Il supermercato è dietro l\'ospedale.'],
    ['A', '远吗？', 'Yuǎn ma?', 'È lontano?'],
    ['B', '不远，很近。', 'Bù yuǎn, hěn jìn.', 'No, è vicinissimo.'],
    ['A', '谢谢！', 'Xièxie!', 'Grazie!']];
  let showPy = true, showIt = false;
  S.listen = () => `${nav('/unit/5', 'Unità 5', 'Dialogo')}
      <div class="large-title" style="font-size:28px">Dov'è il supermercato?</div>
      <div class="subtitle">Unità 5 · usa solo parole che conosci già, più 2 nuove</div>
      <div class="chips"><button class="chip ${showPy ? 'on' : ''}" onclick="togglePy()">Pinyin</button><button class="chip ${showIt ? 'on' : ''}" onclick="toggleIt()">Traduzione</button><span class="chip">Velocità 0,8×</span></div>
      <div class="list">${DIALOG.map(([who, h, p, t]) => `<div class="ex"><span class="pill ${who === 'A' ? 'blue' : 'red'}" style="padding:3px 8px">${who}</span>
        <div class="grow"><div class="hz">${esc(h)}</div>${showPy ? `<div class="p">${esc(p)}</div>` : ''}${showIt ? `<div class="t">${esc(t)}</div>` : ''}</div>${audioBtn(h, 'mini-audio')}</div>`).join('')}</div>
      <div style="padding:0 16px 16px"><button class="btn" onclick="playDialog()">▶︎ Ascolta tutto il dialogo</button></div>
      <div class="card pad small">💡 Tocca una parola qualsiasi per vederne pinyin, significato e aggiungerla al ripasso.</div>`;
  window.togglePy = () => { showPy = !showPy; render(); };
  window.toggleIt = () => { showIt = !showIt; render(); };
  window.playDialog = () => say(DIALOG.map((d) => d[1]).join(''), 0.8);
  S.read = () => `${nav('/level/1', 'HSK 1', 'Lettura')}
      <div class="large-title" style="font-size:28px">Il mio amico 王明</div>
      <div class="subtitle">Wáng Míng · testo graduato HSK 1 · 98% di parole note</div>
      <div class="card pad"><div class="hz" style="font-size:21px;line-height:1.9">我有一个中国朋友，他叫王明。他是大学生，今年二十岁。他很喜欢喝茶，也喜欢看电影。<span style="background:var(--gold-soft);border-radius:4px">星期六</span>我们常常一起去看电影。</div>
        <div class="small muted" style="margin-top:10px;font-style:italic">Wǒ yǒu yí ge Zhōngguó péngyou, tā jiào Wáng Míng. Tā shì dàxuéshēng, jīnnián èrshí suì…</div></div>
      <div class="card pad"><div class="row"><div class="hz" style="font-size:30px">星期六</div><div class="grow"><b>xīngqīliù</b><div class="small muted">sabato · parola nuova</div></div><button class="btn sm">+ Ripasso</button></div></div>`;

  // ---------------------------------------------------------------- esame
  S.exam = () => {
    const parts = [['Ascolto', [['1', 'Ascolta una frase e scegli l\'immagine'], ['2', 'Ascolta la domanda e scegli la risposta'], ['3', 'Abbina il dialogo all\'immagine'], ['4', 'Ascolta e rispondi alla domanda']], 'circa 12 min'],
      ['Lettura', [['1', 'Abbina la frase all\'immagine'], ['2', 'Abbina domanda e risposta'], ['3', 'Completa con la parola giusta'], ['4', 'Leggi e rispondi alla domanda']], '20 min']];
    return `${nav('/level/1', 'HSK 1', 'Esame')}
      <div class="large-title" style="font-size:30px">Esame simulato HSK 1</div>
      <div class="subtitle">Stesso formato del nuovo esame (esempi ufficiali 2025-12, in vigore da luglio 2026): 40 domande, circa 40 minuti, pinyin sopra i caratteri.</div>
      ${parts.map(([name, ps, t]) => `<div class="section-h">${name}<small>${t}</small></div><div class="list"><table class="struct">
        ${ps.map(([n, d]) => `<tr><td style="width:72px;white-space:nowrap"><b>Parte ${n}</b></td><td>${d}</td><td style="text-align:right;color:var(--muted)">5</td></tr>`).join('')}</table></div>`).join('')}
      <div style="padding:6px 16px 6px;display:grid;gap:10px"><a class="btn" href="#/examq">Simulazione completa · 40 min</a><a class="btn ghost" href="#/examq">Allenati su una parte</a></div>
      <div class="section-h">Le tue simulazioni</div>
      <div class="list"><a class="li" href="#/examres"><div class="grow"><b>Simulazione 2</b><div class="small muted">12 ottobre · 38 min</div></div><span class="pill jade">31/40</span>${I.chev}</a>
        <div class="li"><div class="grow"><b>Simulazione 1</b><div class="small muted">28 settembre · 40 min</div></div><span class="pill gold">24/40</span></div></div>`;
  };
  const Q = [
    { part: 'Ascolto · Parte 1', n: 3, audio: '两杯茶', prompt: 'Ascolta e scegli l\'immagine giusta', opts: [['🍵', 'A'], ['🍵🍵', 'B'], ['🍵🍵🍵', 'C']], ok: 1 },
    { part: 'Lettura · Parte 3', n: 33, prompt: 'Scegli la parola che manca', sentence: [['Wǒ', '我'], ['', '（ &nbsp;&nbsp; ）'], ['yí', '一'], ['ge', '个'], ['gēge', '哥哥'], ['', '。']],
      opts: [['yǒu<br><span class="hz" style="font-size:26px">有</span>', 'A'], ['shì<br><span class="hz" style="font-size:26px">是</span>', 'B'], ['jiào<br><span class="hz" style="font-size:26px">叫</span>', 'C']], ok: 0 },
  ];
  let qi = 0, chosen = null;
  S.examq = (flag) => {
    if (flag === 'answered' && !S.examq.demo) { chosen = Q[qi].ok; S.examq.demo = true; }
    const q = Q[qi];
    const sent = q.sentence ? `<div style="display:flex;flex-wrap:wrap;gap:4px 8px;justify-content:center;margin:12px 0 16px">${q.sentence.map(([p, h]) => `<div style="text-align:center"><div class="tiny muted">${p || '&nbsp;'}</div><div class="hz" style="font-size:26px">${h}</div></div>`).join('')}</div>` : '';
    return `<div class="exam-top"><a class="x" href="#/exam/1">${I.x}</a><div class="grow">${bar(q.n, 40)}</div><span class="timer">38:12</span></div>
      <div style="padding:2px 20px 10px"><span class="pill red">${q.part}</span> <span class="small muted">Domanda ${q.n} di 40</span></div>
      <div class="q-card"><div class="bold" style="font-size:18px">${q.prompt}</div>
        ${q.audio ? `<div class="row" style="margin:16px 0;gap:12px"><button class="mic" style="width:58px;height:58px;margin:0" onclick="say('${q.audio}',0.8)">${I.play}</button><div class="small muted">Puoi ascoltare 2 volte, come all'esame vero.<br><b style="color:var(--ink)">Ascolti: 1/2</b></div></div>` : sent}
        <div class="options">${q.opts.map(([pic, l], i) => `<button class="opt ${chosen === i ? (i === q.ok ? 'ok' : 'ko') : chosen !== null && i === q.ok ? 'ok' : ''}" onclick="choose(${i})"><div class="pic">${pic}</div><div class="letter">${l}</div></button>`).join('')}</div>
        ${chosen !== null ? `<div class="feedback ${chosen === q.ok ? 'ok' : 'ko'}" style="display:block">${chosen === q.ok ? '✓ Giusto!' : '✗ Risposta giusta: ' + q.opts[q.ok][1]} ${q.audio ? '«两杯茶 liǎng bēi chá» = due tazze di tè. Nota il classificatore 杯 bēi.' : '«我有一个哥哥。 Wǒ yǒu yí ge gēge.» = Ho un fratello maggiore. «Avere» si dice con 有 yǒu, non con 是 shì.'}</div>` : ''}
      </div>
      <div style="padding:0 16px"><button class="btn ${chosen === null ? 'ghost' : ''}" onclick="nextQ()">${qi < Q.length - 1 ? 'Avanti' : 'Vedi il risultato'}</button></div>`;
  };
  window.choose = (i) => { if (chosen === null) { chosen = i; render(); } };
  window.nextQ = () => { if (qi < Q.length - 1) { qi++; chosen = null; render(); } else { qi = 0; chosen = null; location.hash = '#/examres'; } };
  S.examres = () => {
    const parts = [['Ascolto 1', 5, 5], ['Ascolto 2', 3, 5], ['Ascolto 3', 4, 5], ['Ascolto 4', 4, 5], ['Lettura 1', 5, 5], ['Lettura 2', 3, 5], ['Lettura 3', 4, 5], ['Lettura 4', 3, 5]];
    return `${nav('/exam/1', 'Esame', 'Risultato')}
      <div class="score"><b>31</b><span>/40</span><div class="muted small">Simulazione 2 · 38 minuti</div></div>
      <div class="hero" style="align-items:flex-start"><div class="ring">${ring(78, 96, 10, 'var(--jade)')}<div class="val"><b>78%</b><span>stima</span></div></div>
        <div class="grow small"><b>Sei sulla buona strada.</b><br><span class="muted">Il punto debole è la <b>parte 2</b> (domande e risposte): ripassa le parole interrogative 什么 shénme, 哪儿 nǎr, 几 jǐ.</span></div></div>
      <div class="section-h">Per parte</div>
      <div class="card pad" style="display:grid;gap:9px">${parts.map(([n, v, m]) => `<div><div class="lab row" style="justify-content:space-between;font-size:13px"><span>${n}</span><b>${v}/${m}</b></div>${bar(v, m, v === m ? 'jade' : v >= 4 ? 'gold' : '')}</div>`).join('')}</div>
      <div class="section-h">Aggiunte al ripasso<small>6</small></div>
      <div style="display:flex;flex-wrap:wrap;gap:6px;padding:0 16px 12px">${['医院', '时间', '哪儿', '几', '房间', '超市'].map((h) => byHz[h]).filter(Boolean).map((w) => `<span class="pill" style="background:var(--card);border:1px solid var(--line)"><span class="hz" style="font-size:15px">${hz(w)}</span><span>${py(w)}</span></span>`).join('')}</div>
      <div style="padding:0 16px 16px"><a class="btn" href="#/study/review">Ripassa gli errori</a></div>`;
  };

  // ---------------------------------------------------------------- cerca e profilo
  S.search = () => `<div class="large-title">Cerca</div>
      <div class="search">${I.search.replace('<svg', '<svg width="18" height="18"')}<input placeholder="caffè, kāfēi, 咖啡…" oninput="filterWords(this.value)" autofocus></div>
      <div class="chips"><span class="chip on">Parole</span><span class="chip">Caratteri</span><span class="chip">Grammatica</span><span class="chip">Frasi</span></div>
      <div class="list" id="wlist">${D.words.slice(0, 60).map((w) => `<a class="li" href="#/word/${encodeURIComponent(w.hz)}"><div class="w-hz hz">${hz(w)}</div><div class="grow"><div class="w-py">${py(w)}</div><div class="w-it">${esc(w.it)}</div></div><span class="pill">HSK 1</span></a>`).join('')}</div>`;
  S.profile = () => {
    const heat = Array.from({ length: 105 }, (_, i) => { const v = (i * 37) % 11; return `<i class="${i > 98 ? '' : v > 8 ? 'h4' : v > 6 ? 'h3' : v > 3 ? 'h2' : v > 1 ? 'h1' : ''}"></i>`; }).join('');
    const set = [['Pinyin', 'Sempre'], ['Colori dei toni', 'Attivi'], ['Voce', 'Femminile · 0,9×'], ['Spiegazioni', 'Italiano'], ['Promemoria', '19:30'], ['Sincronizza', 'iCloud']];
    return `<div class="large-title">Progressi</div><div class="subtitle">Misurati sul programma ufficiale, non su punti o vite.</div>
      <div class="stat3"><div><b>${knownWords}</b><span>parole</span></div><div><b>${knownChars}</b><span>caratteri</span></div><div><b>11 h</b><span>di studio</span></div></div>
      <div class="card pad"><div class="row" style="justify-content:space-between"><b>Ultime 15 settimane</b><span class="small muted">media 21 min/giorno</span></div><div class="heat" style="margin-top:10px">${heat}</div></div>
      <div class="card pad"><b>Previsione</b><div class="small muted" style="margin-top:4px">Con il ritmo attuale finisci l'HSK 1 verso il <b style="color:var(--ink)">5 dicembre</b>: in tempo per l'esame del 13 dicembre.</div></div>
      <div class="section-h">Impostazioni</div>
      <div class="list">${set.map(([a, b]) => `<div class="li"><div class="grow">${a}</div><span class="muted small">${b}</span>${I.chev}</div>`).join('')}</div>`;
  };

  // ---------------------------------------------------------------- note di design per schermata
  const NOTES = {
    home: ['Prima pagina: i livelli HSK 3.0', ['Ogni livello mostra i numeri <b>ufficiali</b> del programma 2025: parole e caratteri.', 'In alto il ripasso del giorno: è la cosa più importante da fare, quindi è la più visibile.', 'Il conto alla rovescia per l\'esame dà un obiettivo concreto, senza «serie» da non perdere.']],
    level: ['Dentro un livello', ['L\'anello «pronto» stima quanto sei preparato all\'esame, combinando parole, caratteri, grammatica e simulazioni.', 'Quattro barre di copertura del programma: sai sempre cosa manca.', '«Continua» ti riporta esattamente dove eri rimasto.', 'Tutto è diviso: percorso, parole, caratteri, grammatica, pronuncia, ascolto, lettura, esame.']],
    units: ['Il percorso = i 15 compiti ufficiali', ['Il programma HSK 1 è costruito su 15 compiti comunicativi (presentarsi, fare acquisti, chiedere la strada…).', 'Ogni unità corrisponde a un compito, con le parole e la grammatica che servono per farlo.']],
    unit: ['Un\'unità in 5 passi', ['Parole → grammatica → dialogo → pronuncia → mini-test in formato d\'esame.', '«Alla fine saprai» traduce in italiano gli obiettivi ufficiali del compito.', 'Circa 20–25 minuti: si fa in una sessione.']],
    words: ['Le 300 parole', ['Caratteri e pinyin colorati per tono (gli stessi colori dei PDF).', 'Barrette di padronanza calcolate dal ripasso.', 'Ricerca in cinese, pinyin senza accenti o italiano.']],
    study: ['Ripasso attivo, non «tocca la tessera»', ['Prima pensi alla risposta, poi la vedi: è il richiamo attivo, il metodo più efficace per memorizzare.', 'Due direzioni: cinese → italiano e italiano → cinese (la più difficile e utile).', 'I 4 pulsanti alimentano l\'algoritmo FSRS, che decide quando rivedere la carta.', 'Ogni parola ha una frase d\'esempio vera, scritta solo con caratteri HSK 1.']],
    review: ['Un unico ripasso per tutto', ['Parole, caratteri, frasi e toni nella stessa coda.', 'Niente vite né punizioni: se salti un giorno, le carte aspettano.']],
    grammar: ['Grammatica in italiano', ['I punti del programma ufficiale HSK 1, raggruppati e spiegati in italiano.', 'Il contenuto viene dal libro di grammatica che abbiamo già scritto.']],
    gp: ['Un punto di grammatica', ['A cosa serve, in una frase.', 'Struttura, esempi con audio e pinyin.', 'L\'errore tipico degli italiani, con la correzione.', 'Esercizio di ordine delle parole e collegamento con le domande d\'esame.']],
    tones: ['Toni con il grafico della voce', ['La curva del madrelingua e la tua, sovrapposte: le ricerche mostrano che vedere la curva dell\'intonazione aiuta a correggere i toni.', 'Coppie minime (mā / má / mǎ / mà) per allenare l\'orecchio.', 'Nel prototipo la registrazione è simulata.']],
    chars: ['Caratteri da riconoscere', ['I 246 caratteri ufficiali dell\'HSK 1; in verde quelli già incontrati.', 'L\'app spiega cosa chiede l\'esame: all\'HSK 1 niente scrittura, dall\'HSK 2 sì (100 caratteri).']],
    char: ['Un carattere', ['Animazione dell\'ordine dei tratti e prova di scrittura con il dito (dati open source Make Me a Hanzi).', 'Scomposizione in componenti con una storia per ricordarlo.', 'Tutte le parole HSK 1 che lo contengono.']],
    listen: ['Dialoghi graduati', ['Pinyin e traduzione si accendono e spengono: si parte con tutto e si toglie man mano.', 'Ogni parola è toccabile.']],
    read: ['Lettura comprensibile', ['Testi scritti solo con parole che conosci, più una o due nuove evidenziate.']],
    exam: ['Esame simulato', ['Stessa struttura del nuovo esame ufficiale: 4 parti di ascolto e 4 di lettura, 5 domande ciascuna.', 'Simulazione completa a tempo o allenamento su una parte.']],
    examq: ['Una domanda', ['Grafica come la prova vera, pinyin sopra i caratteri, due ascolti.', 'Spiegazione immediata dopo la risposta.']],
    examres: ['Risultato', ['Punteggio per parte e stima di preparazione.', 'Le parole sbagliate entrano da sole nel ripasso.']],
    search: ['Cerca', ['Un dizionario interno su tutto: parole, caratteri, grammatica e frasi.']],
    profile: ['Progressi', ['Progressi misurati sul programma ufficiale.', 'Previsione della data in cui sarai pronto.']],
  };
  const MAP = [['/', 'Livelli'], ['/level/1', 'HSK 1'], ['/units/1', 'Percorso'], ['/unit/5', 'Unità'], ['/words/1', 'Parole'], ['/study/unit5', 'Flashcard'],
    ['/grammar/1', 'Grammatica'], ['/gp/zai', 'Punto grammaticale'], ['/tones', 'Toni'], ['/chars/1', 'Caratteri'], ['/char/好', 'Carattere'],
    ['/listen', 'Dialogo'], ['/read', 'Lettura'], ['/exam/1', 'Esame'], ['/examq', 'Domanda'], ['/examres', 'Risultato'], ['/review', 'Ripasso'], ['/profile', 'Progressi']];

  // ---------------------------------------------------------------- router
  const route = () => {
    const parts = (location.hash.replace(/^#\/?/, '') || '').split('/').filter(Boolean);
    return { name: parts[0] || 'home', arg: parts[1], arg2: parts[2], path: '/' + parts.join('/') };
  };
  const TABS = [['/', 'Livelli', 'levels', ['home', 'level', 'units', 'unit', 'words', 'grammar', 'gp', 'tones', 'chars', 'char', 'listen', 'read', 'word']],
    ['/review', 'Ripasso', 'review', ['review']], ['/exam/1', 'Esame', 'exam', ['exam', 'examres']], ['/search', 'Cerca', 'search', ['search']], ['/profile', 'Progressi', 'profile', ['profile']]];
  const FULLSCREEN = ['study', 'examq'];

  let keepScroll = false, lastGp = null;
  function draw() {
    const r = route();
    const fn = S[r.name] || S.home;
    if (r.name === 'gp' && lastGp !== r.arg) { built = []; lastGp = r.arg; }
    screen.innerHTML = fn(r.arg, r.arg2);
    const full = FULLSCREEN.includes(r.name) || r.name === 'word';
    screen.classList.toggle('no-tab', full);
    const tb = $('#tabbar');
    tb.classList.toggle('hidden', full);
    tb.innerHTML = TABS.map(([href, label, ic, names]) => `<a class="tab ${names.includes(r.name) ? 'on' : ''}" href="#${href}">${I[ic]}${ic === 'review' ? '<span class="dot">24</span>' : ''}${label}</a>`).join('');
    const n = NOTES[r.name === 'word' ? 'study' : r.name] || NOTES.home;
    $('#notes').innerHTML = `<div class="brand"><div class="logo">步步</div><div><h1>Bùbù 步步</h1><div class="small muted">Prototipo · il cinese per l'HSK, passo dopo passo</div></div></div>
      <h2>${n[0]}</h2><ul>${n[1].map((x) => `<li>${x}</li>`).join('')}</ul>
      <h2>Tutte le schermate</h2><div class="map">${MAP.map(([h, l]) => `<a href="#${h}" class="${r.path === h || (h === '/' && r.name === 'home') ? 'on' : ''}">${l}</a>`).join('')}</div>
      <p class="small muted" style="margin-top:16px">Dati reali: 300 parole e 246 caratteri dell'HSK 1 dal programma ufficiale 2025; esempi dal nostro libro di grammatica. L'audio usa la sintesi vocale del browser.</p>`;
    if (r.name === 'char') mountWriter(decodeURIComponent(r.arg || '好'));
    if (!keepScroll) screen.scrollTop = 0;
  }
  // render(): aggiorna la schermata corrente senza tornare in cima (usato dalle interazioni)
  const render = () => { keepScroll = true; const y = screen.scrollTop; draw(); screen.scrollTop = y; keepScroll = false; };
  window.render = render;
  window.addEventListener('hashchange', () => { if (route().name !== 'study' && route().name !== 'word') session = null; draw(); });
  draw();
})();
