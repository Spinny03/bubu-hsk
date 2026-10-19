# Design di un'app d'esame per il nuovo HSK (Bùbù 步步): concorrenti, apprendimento adattivo, engagement, simulazione d'esame, tecnologia

> Research notes, retrieved 2026-10-19. Written in English (some Italian UI strings) for the report writer.
> Evidence labels: **[measured]** = peer-reviewed / A-B test / official doc / data I pulled from an API; **[vendor]** = company claim; **[anecdotal]** = app-store reviews, forums, blog roundups; **[my analysis]** = calculation or inference done for these notes.
> Prototype facts referenced below come from `PROPOSTA_APP.md` and `app_prototype/app.js` (screens `S.home`, `S.level`, `S.study`, `S.review`, `S.tones`, `S.char`, `S.exam`, `S.examq`, `S.examres`, `S.profile`; tone colours in `styles.css`).

## 1. Competitive analysis: what HSK/Chinese apps offer as of October 2026, which are updated to the 2025 syllabus, and where they fall short

### Takeaway
The market is crowded but no app combines (a) explanations in Italian, (b) verified alignment with the 2025 考试大纲 (300/500/1000 words for HSK 1–3), (c) mock exams in the exact 2025‑12 format, and (d) an honest readiness estimate. Italian-UI apps (SuperChinese, SuperTest, ChineseSkill, Chinesimple, Duolingo) are either generic courses, still HSK 2.0-based, or fragmented. The functionally closest 2026 entrant (Gushi: FSRS, official syllabus, separate reading/listening placement, official-format mocks) has no Italian. Many "HSK 3.0" apps actually ship the 2021 GF0025-2021 lists rather than the 2025 exam syllabus. In reviews, the dominant complaint is paywalls and pricing (≈49% of low-star reviews sampled), followed by bugs, content errors, no placement or test-out, and unreliable AI or speech feedback.

### Cited Findings

#### Method and caveats
- App metadata (version dates, ratings, UI languages, descriptions) pulled 2026-10-19 from Apple's iTunes Search/Lookup API (Italian storefront plus US), e.g. [lookup HelloChinese IT](https://itunes.apple.com/lookup?id=1001507516&country=it). The field `languageCodesISO2A` lists **UI localisations**, which need not mean the course is taught from that language (see the HelloChinese conflict below). **[measured: API data]**
- Reviews come from App Store customer-review RSS feeds (2 pages × US/GB/IT per app), e.g. [HelloChinese US feed](https://itunes.apple.com/us/rss/customerreviews/page=1/id=1001507516/sortby=mostrecent/json). Reddit returned HTTP 403 to automated access, so no Reddit threads were read. All review evidence is **[anecdotal]**.

#### Official and quasi-official mock platforms
- CTI (汉考国际) launched official HSK 3.0 mock tests ("HSK Mock") on **4 Jan 2026** for levels 1–9, "strictly aligned with the official HSK 3.0 exam structure", in both paper-based and computer-based formats, on web, iOS and Android. A pilot of HSK 3.0 levels 1–6 ran at selected centres on **31 Jan 2026**. — [Shanghai Municipal Education Commission, 2026-01-07](https://edu.sh.gov.cn/study_en_hsk/20260107/5292266eca744a959c1db43237fbc185.html) **[official]**
- The iOS "HSK Mock" app is published by **Wo Hui Pte Ltd** (not CTI). It calls itself "the only HSK and YCT mock testing platform officially recognised by … CTI", offers "Real past papers", a free "Level testing" placement and a "Real exam format… developed with the exam board". It has 14 locales but no Italian; v3.0.1 dated 2026-09-03; 4 US ratings averaging 3.0. — [App Store IT](https://apps.apple.com/it/app/hsk-mock/id1624661903) **[vendor]**
- HSK Mock pricing: limited free access, then test codes at **$2.99–$17.95** valid one year; HSK 3.0 added Jan 2026. — [HSK University blog, updated 2026-10-02](https://hskuniversity.com/blog/free-hsk-mock-tests/) **[anecdotal; written by a competitor]**
- CTI's own iOS app is a dictionary (国际中文学习词典), last updated **2023-04-13**; it is not an exam-prep app. — [App Store IT](https://apps.apple.com/it/app/%E5%9B%BD%E9%99%85%E4%B8%AD%E6%96%87%E5%AD%A6%E4%B9%A0%E8%AF%8D%E5%85%B8/id6446336551)

#### Exam-prep specialists
- **SuperTest** (Shanghai Yuxuan; formerly "HSK Online"):
  - Italian is among its 13 UI languages. It offers "HSK mock exams or previous real HSK tests", "over 300,000 HSK practice questions", teacher essay correction, and a daily AI review.
  - Latest version 5.2.16 (2026-06-10) with generic notes and no mention of the new HSK. Rated 4.73★ (1,055 US).
  - US prices: PLUS **$15.99/month** or **$59.99/year**; lifetime $29.99–$109.99; "AI MAX" **$24.99/month**.
  - Sources: [App Store US](https://apps.apple.com/us/app/-/id1335503360), [App Store IT](https://apps.apple.com/it/app/app-per-i-hsk-test-supertest/id1335503360) **[vendor]**
- Conflicting sources on whether SuperTest supports the new HSK: "HSK 2.0 only, levels 1–6" per [HSK University (2026-10-02)](https://hskuniversity.com/blog/free-hsk-mock-tests/), versus "aligned with HSK 3.0" per [Languavibe roundup (2026-06-13)](https://languavibe.com/best-hsk-prep-apps/). The latter is an aggregator with affiliate disclosures. **[anecdotal, conflicting]**
- **Migii HSK**: "180+ HSK mock exams for all levels (1–6)", "320,000+ HSK questions", writing graded by "AI MiA", a level test, and 30/60/90-day study plans. — [App Store IT](https://apps.apple.com/it/app/chinese-hsk-learn-test-migii/id6444041413). Premium costs $14.99 per 3 months — [HSK University](https://hskuniversity.com/blog/free-hsk-mock-tests/) **[vendor]**
- **Hanzii**: "200+ full mock exams… HSK 1–9 (HSK 3.0), HSKK, TOCFL" and "AI-guided handwriting practice". 8 UI languages, no Italian. — [App Store IT](https://apps.apple.com/it/app/hanzii-learn-chinese-hsk/id1468400944) **[vendor]**
- **KaKa Chinese – PASS HSK**: v3.0.8 (2026-09-08) notes "Added new HSK 3.0 vocabulary". It advertises "50,000 HSK practice questions and authentic mock exams" and HSKK speaking practice with "Standard Audio Comparison". — [App Store IT](https://apps.apple.com/it/app/kaka-chinese-pass-hsk-exam/id6742166391) **[vendor]**
- **NEW HSK Mock Test** (Beijing Zhongke Chenfei; first release 2026-07-17):
  - Offers full papers from HSK 1 to HSK 7–9 "in the same order as the real exam", with an electronic score report on submission.
  - Carries the disclaimer: "Score reports are for learning reference only and do not represent, replace, or equal any official HSK score report".
  - v1.3.0 (2026-10-18) puts question-by-question explanations behind a paid unlock.
  - Source: [App Store IT](https://apps.apple.com/it/app/hsk3-0-mock-test/id6785017655) **[vendor]**
- **Gushi** (first release 2026-09-08) is the closest concept to Bùbù:
  - "Every word, character and grammar point comes from the official HSK 3.0 syllabus (考试大纲)… at chinesetest.cn".
  - Uses FSRS spaced repetition.
  - Its placement test "settles reading and listening separately".
  - "Tone drills that find the tone you keep missing and ask it more often".
  - "Full mock exams at every level, in the official format, and the HSKK"; 428 grammar points.
  - Character stories in English, German, Spanish and French only (no Italian).
  - Source: [App Store IT](https://apps.apple.com/it/app/gushi-learn-chinese-hsk-3-0/id6799015237) **[vendor]**
- New 2026 entrants with few or no ratings:
  - **Pass HSK** (2026-01): placement assessment, handwriting — [App Store](https://apps.apple.com/it/app/pass-hsk-learn-chinese/id6757735304)
  - **HSKLord** (2026-07): SRS over HSK 1–9 lists, weekly/monthly/annual plans, streaks — [App Store](https://apps.apple.com/it/app/hsklord/id6769130704) **[vendor]**

#### Generalist Chinese apps
- **HelloChinese**:
  - v7.6.6 (2026-10-17); 4.87★ (23,644 US) and 4.84★ (1,228 IT); 13 UI languages including Italian.
  - Aug 2026 notes: "Main Course 2.0… now covers 430+ grammar and 2,500+ words".
  - Offers speech recognition, handwriting and offline use.
  - US prices: **$11.99/month, $25.99/3 months, $69.99/year**.
  - Sources: [App Store US](https://apps.apple.com/us/app/-/id1001507516), [App Store IT](https://apps.apple.com/it/app/hellochinese-impara-il-cinese/id1001507516) **[vendor]**
  - **Conflict:** an Italian reviewer (2026-05-15) writes "Sto imparando il cinese dal portoghese perché l'italiano non è disponibile". Another (2025-03) was "waiting the Italian language". An older forum post also said Italian was unsupported. Interpretation: the UI is localised, but the course is apparently not taught from Italian. — [IT review feed](https://itunes.apple.com/it/rss/customerreviews/page=1/id=1001507516/sortby=mostrecent/json), [chinese-forums](https://www.chinese-forums.com/forums/topic/49944-hellochinese-%E2%80%93-new-chinese-mandarin-learning-app-learn-chinese-speak-chinese/?page=2) **[anecdotal]**
- **SuperChinese**:
  - 16 UI languages including Italian; AI tutor "CHAO"; tone correction with green/red feedback; 9 levels with 400+ lessons.
  - v6.8.3 (2026-09-25) added a "Review Center": "Smart Review: 3 minutes a day" and "Focused Review: choose your own vocabulary, grammar, mistakes or lessons".
  - US prices: PLUS **$11.99/month**, $42.99–$59.99/year, $139.99 lifetime; CHAO **$24.99/month** or **$109.99/year**.
  - Source: [App Store US](https://apps.apple.com/us/app/superchinese-learn-chinese/id1462500984) **[vendor]**
  - An Italian reviewer (2026-03-10): "Probabilmente la migliore per italiano - cinese". — [IT feed](https://itunes.apple.com/it/rss/customerreviews/page=1/id=1462500984/sortby=mostrecent/json) **[anecdotal]**
- **ChineseSkill**: Italian UI (17 languages); 4.83★ (15,383 US); "Speech recognition corrects your pronunciation and tones". — [App Store IT](https://apps.apple.com/it/app/chineseskill-impara-il-cinese/id777111034) **[vendor]**
- **Duolingo**: on **30 Apr 2025** it made Mandarin (and six other languages) "available to all 28 supported user interface languages", including Italian. These were part of 148 courses built with generative AI in under a year, which "primarily support beginner levels (CEFR A1–A2)". — [Duolingo IR release](https://investors.duolingo.com/news-releases/news-release-details/duolingo-launches-148-new-language-courses) (content via search extract; direct fetch returned 403) **[vendor]**
- **Du Chinese**: graded reader with 3000+ articles, audiobook mode and offline use; English UI only; v3.6.0 (2026-09-13). — [App Store IT](https://apps.apple.com/it/app/du-chinese-read-learn-chinese/id1052961520) **[vendor]**
- **Pleco**: dictionary, reader and flashcards; English UI only; audio uses "iOS' free built-in text-to-speech system". — [App Store IT](https://apps.apple.com/it/app/pleco-chinese-dictionary/id341922306) **[vendor]**
- **Skritter**:
  - Offers "HSK 1-6 & New HSK3.0 1-9 study decks"; English UI. v4.0.1 (2026-09-22) "Added optional daily study notification reminders". — [App Store IT](https://apps.apple.com/it/app/skritter-write-chinese/id1370892114) **[vendor]**
  - A July 2026 reviewer says it "automatically defaults to HSK 2.0". — [US feed](https://itunes.apple.com/us/rss/customerreviews/page=1/id=1370892114/sortby=mostrecent/json) **[anecdotal]**
- **Laoshi**:
  - Claims "pronunciation scored for sound and tone separately, character by character" and "HSK 2.0 and HSK 3.0 coverage". Rated 4.65★ overall, but the 52 most recent reviews average 3.06. — [App Store IT](https://apps.apple.com/it/app/laoshi-imparare-cinese-hsk/id1510215770)
  - A reviewer (2026-08-06, in Russian) says the app still uses "the old 2021 version with 500 words, while the new HSK 1 has 300 words". This is direct evidence of confusion between the 2021 standard and the 2025 syllabus. — [US feed](https://itunes.apple.com/us/rss/customerreviews/page=1/id=1510215770/sortby=mostrecent/json) **[anecdotal]**
- **"Vocabolario HSK 1-9"** (Italian UI, Aug 2026) markets itself as "Built for the 2021 HSK 3.0 standard". This is another 2021 list sold as "new HSK". — [App Store IT](https://apps.apple.com/it/app/vocabolario-hsk-1-9-11000/id6801332913) **[vendor]**
- **Chinesimple** (Khanji School, Spain):
  - One separate app per level, with Italian UI. v12.11.0 (2026-09-12): "All HSK1-HSK6 levels are ready for the new standard" (HSK 3.0, 2026). — [App Store IT](https://apps.apple.com/it/app/hsk1-impara-cinese-chinesimple/id1495963573) **[vendor]**
  - An Italian reviewer complains: "Costa troppo… bisogna acquistare per ogni singola app inerente a ciascun livello". A UK reviewer says "£99.99 I just can't afford it". — [IT feed](https://itunes.apple.com/it/rss/customerreviews/page=1/id=1495963573/sortby=mostrecent/json), [GB feed](https://itunes.apple.com/gb/rss/customerreviews/page=1/id=1495963573/sortby=mostrecent/json) **[anecdotal]**
- **Migaku**: subscription required just to try it; v2.68.0 (2026-10-17) redesigned Home around a "streak and known-words" display plus an activity heatmap. — [App Store IT](https://apps.apple.com/it/app/migaku-really-learn-languages/id1664096855) **[vendor]**
- **AnkiMobile**: €29.99 one-off purchase in the Italian store. — [App Store IT](https://apps.apple.com/it/app/ankimobile-flashcards/id373493387)
- Third-party information about the new HSK is often wrong:
  - [cnhsk.org](https://www.cnhsk.org/hsk) lists HSK 5 at 4,000 words and different question counts from the official 2025‑12 document (see §4).
  - Search-indexed sites list "Level 4: 1,200 words, Level 5: 2,500" (e.g. [mandarinbean](https://mandarinbean.com/new-hsk-vocabulary/), via search extract), versus the official cumulative 2,000 / 3,600 recorded in `PROPOSTA_APP.md`.
  - **[anecdotal]**

#### What users complain about (App Store reviews, anecdotal)
- **[my analysis]** Keyword classification of **266 low-star (≤3★) reviews** across 13 apps (US, GB and IT feeds; dates 2010-06 to 2026-10). A review can count in several themes:

  | Theme | Share of reviews | Most affected apps |
  |---|---|---|
  | Paywall, price, trial or refunds | 130 (49%) | Skritter, ChineseSkill, Laoshi, SuperTest |
  | Bugs, crashes, login | 36 (14%) | |
  | Content or answer errors | 25 (9%) | |
  | Level, placement, can't skip | 23 (9%) | HelloChinese, Du Chinese |
  | Speech recognition and pronunciation feedback | 19 (7%) | |
  | iPad landscape, desktop, font size, dark mode | 13 (5%) | |
  | AI quality, "AI slop" | 11 (4%) | |
  | Gamification and notification pressure | 8 (3%) | |
  | Outdated HSK version | 6 (2%) | |

  Feeds used: [HelloChinese](https://itunes.apple.com/us/rss/customerreviews/page=1/id=1001507516/sortby=mostrecent/json), [SuperTest](https://itunes.apple.com/us/rss/customerreviews/page=1/id=1335503360/sortby=mostrecent/json), [Skritter](https://itunes.apple.com/us/rss/customerreviews/page=1/id=1370892114/sortby=mostrecent/json), [Laoshi](https://itunes.apple.com/us/rss/customerreviews/page=1/id=1510215770/sortby=mostrecent/json), [ChineseSkill](https://itunes.apple.com/us/rss/customerreviews/page=1/id=777111034/sortby=mostrecent/json).
- **Paywalls without warning, and review locked behind payment:**
  - HelloChinese, 2026-10-15: "there is a paywall… After only 2 units, you cannot finish the course… there should be a warning".
  - HelloChinese, 2026-09-09: "you have to buy the membership just to review the words and characters you've already learned".
  - HelloChinese, Italy, 2026-04-12: "perché devo pagare 69,99€ al anno se voglio studiare dopo il 5 capitolo".
  - Source: [US feed](https://itunes.apple.com/us/rss/customerreviews/page=1/id=1001507516/sortby=mostrecent/json), [IT feed](https://itunes.apple.com/it/rss/customerreviews/page=1/id=1001507516/sortby=mostrecent/json)
- **No placement or test-out:**
  - HelloChinese, 2026-09-03: "Why can't I adjust my level at the beginning?"
  - HelloChinese, GB, 2026-09-13: "painful to start from 你好 and not be able to at least test out of some lessons. Over an hour on the app and I learned like one new word".
  - Source: [US feed](https://itunes.apple.com/us/rss/customerreviews/page=1/id=1001507516/sortby=mostrecent/json), [GB feed](https://itunes.apple.com/gb/rss/customerreviews/page=1/id=1001507516/sortby=mostrecent/json)
- **AI-generated content backlash:**
  - HelloChinese, 2026-10-10: "replace a lot of assets with AI including… actual human teachers".
  - HelloChinese, GB, 2026-08-30: "AI slop is all over the new course material… gamification is getting worse. I don't care about daily challenges or points".
  - Migaku, 2026-07-20: "AI stuck in all parts of this… settings to opt out… still more ways the AI was popping up".
  - Sources: [HelloChinese US](https://itunes.apple.com/us/rss/customerreviews/page=1/id=1001507516/sortby=mostrecent/json), [Migaku US](https://itunes.apple.com/us/rss/customerreviews/page=1/id=1664096855/sortby=mostrecent/json)
- **Weak speech and pronunciation feedback:**
  - SuperChinese, 2026-07-29: "when you mess up in pronunciation, it doesn't tell you why or how".
  - SuperChinese, GB, 2025-05-27: "the AI and voice recognition needs work".
  - ChineseSkill, 2026-07-18: "AI… often gets your ratings wrong".
  - Sources: [SuperChinese US](https://itunes.apple.com/us/rss/customerreviews/page=1/id=1462500984/sortby=mostrecent/json), [ChineseSkill US](https://itunes.apple.com/us/rss/customerreviews/page=1/id=777111034/sortby=mostrecent/json)
- **Mock-exam reliability and price:**
  - SuperTest, 2026-07-05: "I get the answer correct and they tell me it's wrong because I didn't put it in the correct order but it's the exact same order… $25 extra to ask AI a month… already paying $20 a month".
  - SuperTest, Italy, 2026-05-26: no iPad landscape, and "le foto nel listening sono tagliate".
  - SuperTest, US: grammar explanations are "written in chinese".
  - Sources: [US feed](https://itunes.apple.com/us/rss/customerreviews/page=1/id=1335503360/sortby=mostrecent/json), [IT feed](https://itunes.apple.com/it/rss/customerreviews/page=1/id=1335503360/sortby=mostrecent/json), [App Store US](https://apps.apple.com/us/app/-/id1335503360)
- **Billing practices:**
  - Skritter, 2026-02-10: "charged my credit card without alerting me that the trial period was nearing its end".
  - Laoshi, 2026-08-25: offered $55.99 during cancellation but "charged the full $79.99".
  - SuperTest, Italy, 2021: a "lifetime" membership was cancelled with an update.
  - Sources: [Skritter feed](https://itunes.apple.com/us/rss/customerreviews/page=1/id=1370892114/sortby=mostrecent/json), [Laoshi feed](https://itunes.apple.com/us/rss/customerreviews/page=1/id=1510215770/sortby=mostrecent/json), [SuperTest IT feed](https://itunes.apple.com/it/rss/customerreviews/page=1/id=1335503360/sortby=mostrecent/json)
- **Italian-specific wishes:** an Italian–Chinese dictionary in Pleco (2022) and character drawing — [Pleco IT feed](https://itunes.apple.com/it/rss/customerreviews/page=1/id=341922306/sortby=mostrecent/json) **[anecdotal]**

### Inferences
- **[my analysis]** Bùbù's defensible niche is a single combination nobody else offers: Italian explanations + the 2025 考试大纲 (not the 2021 lists) + 2025‑12 format mocks + honest readiness. The 2021-vs-2025 confusion seen at Laoshi, the Vocabolario HSK app and on cnhsk.org is a marketing and trust opportunity. The app should state its source and version on screen, e.g. "Programma: HSK 考试大纲 (CLEC, 2025‑11) · Formato: 样题 2025‑12". It should also publish a changelog whenever CTI publishes updates.
- **Business model:** since half of the negative reviews are about money, competitors' anti-patterns are a checklist:
  - Never lock reviewing of already-learned items behind payment.
  - Show the free/paid boundary before the user starts a unit.
  - Use one app for all levels, not one app per level.
  - Send an in-app reminder before a trial converts.
  - Avoid "lifetime" tiers that you might not honour.
  - Keep the AI tutor out of a separate expensive add-on.
- **Placement and test-out:** add a placement test plus a "salta l'unità con un quiz" option per unit. The prototype goes straight to unit 5 with no onboarding.
- **AI stance:** human-reviewed content and pictures, with AI features clearly labelled ("IA") and switchable off. This contrasts with the HelloChinese and Migaku backlash.
- **iPad layout and Dynamic Type:** support landscape on iPad and Dynamic Type from day one, given the SuperTest and Du Chinese complaints.
- **Mock answer checking:** robust answer-equivalence for ordering items, to avoid SuperTest-style false "wrong" verdicts.
- **Duolingo now teaches Mandarin from Italian**, but only at A1–A2 and without HSK exam focus. The proposal's "Perché non è come Duolingo" table remains valid. It should add that Duolingo's course is not built on the 2025 syllabus; the HSK claim could not be verified this session.

### Gaps
- Reddit (r/ChineseLanguage, r/HSK) could not be read (403), and Google Play reviews were not collected.
- Hack Chinese is a JS-rendered web app (fetch returned no content), so its HSK 3.0/2025 list support and price are unverified. Du Chinese and Pleco HSK‑2025 list support were also not verified.
- EUR prices in the Italian store were only seen for HelloChinese (€69.99/year, from a review) and AnkiMobile (€29.99); the other prices are US$.
- Not known: whether SuperTest's and HSK Mock's "real past papers" are licensed from CTI (only HSK Mock claims recognition), or how many mocks Chinesimple contains and in which format.
- Duolingo's claim that its Chinese course covers "HSK 1–3 plus half of HSK 4" appeared only in a search extract; the original blog URL returns 404, so it is unverified.
- The official CLEC "Chinese Plus"/global learning platform was not researched.

## 2. Adaptive learning design: knowledge tracing in production, mastery thresholds, adaptive difficulty, placement, and an honest exam-readiness estimate

### Takeaway
Production systems separate **memory** models from **ability/difficulty** models:
- Memory models: Duolingo's half-life regression; FSRS (≈10k-user benchmark); MaiMemo's SSP-MMC.
- Ability/difficulty models: Duolingo's Birdbrain, an IRT-style logistic model with Elo-like online updates; ALEKS's knowledge-space theory; BKT with a mastery threshold (e.g. 0.95).

Bùbù should keep FSRS for cards, add an item-difficulty/ability model for exam parts, and turn the single "38% pronto" ring into a calibrated **predicted-score range with stated uncertainty**. Mastery thresholds matter, and spacing should be scheduled against the exam date.

### Cited Findings
- **Half-life regression** (Settles & Meeder, ACL 2016): HLR cuts recall-prediction error by **45%+** versus baselines and "significantly improves daily student engagement" in operational use. — [ACL Anthology P16-1174](https://aclanthology.org/P16-1174/) **[measured]**
- **FSRS benchmark** (open-spaced-repetition srs-benchmark): ≈10,000 Anki users; **349,923,850 reviews** in the variant without same-day reviews. Scores (lower log loss and RMSE are better, higher AUC is better). — [GitHub srs-benchmark](https://github.com/open-spaced-repetition/srs-benchmark) **[measured]**

  | Model | Log loss | RMSE(bins) | AUC |
  |---|---|---|---|
  | FSRS-6 | 0.3460 | 0.0653 | 0.7034 |
  | FSRS-4.5 | 0.3625 | 0.0764 | 0.6891 |
  | HLR (Duolingo) | 0.4694 | 0.1275 | 0.6369 |
  | FSRS-7 "recency" | 0.3363 | 0.0576 | 0.7243 |
  | RWKV-Instant (neural) | **0.2773** | 0.0250 | **0.8329** |

- **ts-fsrs** (the library named in the proposal) implements FSRS v6. — [GitHub ts-fsrs](https://github.com/open-spaced-repetition/ts-fsrs) **[vendor]**
- **MaiMemo SSP-MMC** (Ye, Su & Cao, KDD 2022): a memory model built on **220 million** learners' logs, with a scheduler that minimises review cost via a stochastic shortest path. It reports a **12.6%** improvement over the previous state of the art and is deployed in MaiMemo; it is the academic origin of FSRS. — [DOI 10.1145/3534678.3539081](https://doi.org/10.1145/3534678.3539081) **[measured]**
- **Birdbrain** (Duolingo) — [IEEE Spectrum](https://spectrum.ieee.org/duolingo) **[vendor, technical]**:
  - "a flavor of logistic regression inspired by item response theory": P(correct) is a function of learner ability and exercise difficulty.
  - Difficulty is estimated "by summing up the difficulty of its component features like the type of exercise, its vocabulary words".
  - Updates are "one step of stochastic gradient descent… every time a learner completes an exercise… a generalization of the Elo rating system".
  - V1 updated once every 24 h; V2 processes exercises in real time.
  - V1 lost data because "roughly 20 percent of lessons started on Duolingo aren't completed".
- **Birdbrain blog** (Duolingo): A/B tests "consistently helped our learners learn more" when lessons were built at the right difficulty. — [Duolingo blog](https://blog.duolingo.com/learning-how-to-help-you-learn-introducing-birdbrain/) **[vendor]**
- **Mastery thresholds:**
  - Bayesian Knowledge Tracing comes from [Corbett & Anderson 1995, DOI 10.1007/bf01099821](https://doi.org/10.1007/bf01099821).
  - The BKT estimate "is often converted into a binary indicator… based on a predefined threshold (e.g. 0.95)", and "determining optimal thresholds is critical"; this EDM 2025 study links degree of mastery to performance on subsequent lessons. — [Zhang, Vanacore, Baker et al., EDM 2025 (ERIC ED675652)](https://eric.ed.gov/?id=ED675652) **[measured]**
  - Further reading on N-consecutive-correct vs model-based mastery criteria: [Pelánek & Řihák, UMAP 2017](https://doi.org/10.1145/3079628.3079667) and [Pelánek & Řihák 2018](https://doi.org/10.1080/13614568.2018.1476596) (abstracts not retrieved).
- **ALEKS / knowledge-space theory:** ALEKS is "an application of knowledge space theory". Knowledge states are subsets of questions; a stochastic version treats them as learning-history epochs. — [Falmagne 1999](https://doi.org/10.1016/s1571-0653(05)80004-6), [Falmagne 1989, Psychometrika](https://doi.org/10.1007/bf02294521) **[measured/theory]**
- **Spacing against a deadline** (Cepeda et al. 2008): more than 1,350 learners, gaps up to 3.5 months, tests up to 1 year later. "The optimal gap increased as test delay increased… as a proportion of test delay, the optimal gap declined from about 20 to 40% of a 1-week test delay to about 5 to 10% of a 1-year test delay." — [DOI 10.1111/j.1467-9280.2008.02209.x](https://doi.org/10.1111/j.1467-9280.2008.02209.x) **[measured]**
- **Testing effect** (Roediger & Karpicke 2006): at 5 minutes, restudying beat testing; on delayed tests (2 days, 1 week), prior testing produced greater retention. — [DOI 10.1111/j.1467-9280.2006.01693.x](https://doi.org/10.1111/j.1467-9280.2006.01693.x)
- **Dunlosky et al. 2013** rate practice testing and distributed practice as high-utility techniques. — [DOI 10.1177/1529100612453266](https://doi.org/10.1177/1529100612453266) **[measured/review]**
- **Placement as implemented by competitors:** HSK Mock ("short test free of charge" to choose a level), Migii (level test plus a 30/60/90-day plan), Pass HSK (placement assessment), Gushi (placement "settles reading and listening separately, because almost nobody is at the same level in both"). — [HSK Mock](https://apps.apple.com/it/app/hsk-mock/id1624661903), [Migii](https://apps.apple.com/it/app/chinese-hsk-learn-test-migii/id6444041413), [Pass HSK](https://apps.apple.com/it/app/pass-hsk-learn-chinese/id6757735304), [Gushi](https://apps.apple.com/it/app/gushi-learn-chinese-hsk-3-0/id6799015237) **[vendor]**
- **Adaptive-test item pools:** pools need "sufficient numbers of good quality items"; besides size, the distribution of item parameters, content balance and item exposure matter, and "there is little research on how to design" pools. — [ERIC EJ1026121 (Educ. Psych. Meas., 2014)](https://eric.ed.gov/?id=EJ1026121). Simulations compared pools of **200 vs 2,000** items and fixed vs error-based stopping rules. — [Doğan 2024, DOI 10.14687/jhs.v21i4.6513](https://doi.org/10.14687/jhs.v21i4.6513) **[measured]**
- **Score scale for readiness** (third-party, legacy-format description): an HSK 1 report gives listening, reading and total scores, "满分200分，总分120分为合格", plus a percentile norm table. — [cnhsk.org](https://www.cnhsk.org/hsk) **[anecdotal; see §4 conflict]**
- **Level-controlled content generation** (Malik, Mayhew, Piech & Bicknell, ACL Findings 2024): prompting showed a large GPT‑4 vs open-model gap. A "careful combination of finetuning and RL alignment" (CALM) "surpasses the performance of GPT-4… at only a fraction of the cost" for CEFR-level control. — [arXiv 2406.03030](https://arxiv.org/abs/2406.03030) **[measured]**

### Inferences
- **[my analysis] Architecture for Bùbù:**
  1. **Memory layer:** FSRS‑6 (ts-fsrs) per card type: word Chinese→Italian, Italian→Chinese, audio→meaning, character recognition, tone minimal pair.
  2. **Skill layer:** a Birdbrain-style Elo/IRT model per exam part (Ascolto 1–4, Lettura 1–4), with item difficulty learned from all users' answers. Log each answer immediately, not at lesson end (Birdbrain V1's 20% data loss).
  3. **Coverage layer:** words, characters, grammar points and the 15 tasks of the 考试大纲.
- **Replace "38% pronto" in `S.level`.** The ring currently merges coverage with readiness. Show two things instead:
  - **"Copertura del programma"**: deterministic counts. The prototype's four bars already do this.
  - **"Preparazione all'esame"**: a predicted-score distribution.
  - Compute it by Monte Carlo over the real blueprint (HSK 1: 4×5 listening + 4×5 reading items). For each sampled item, P(correct) combines the user's part ability, the item's difficulty, and FSRS retrievability *on the exam date* for the item's vocabulary.
  - Report the median and the 80% interval, plus P(score ≥ threshold), e.g. "Oggi supereresti l'HSK 1 con probabilità ~70% (intervallo 60–80%)". Add a reliability badge ("stima poco affidabile: fai ancora 1 simulazione completa") until enough data exist.
  - Calibrate continuously: log predicted vs. actual mock scores, check calibration, and update with each full mock (Bayesian).
- **`S.examres` ("78% stima") and `S.profile` ("finisci verso il 5 dicembre")** should show ranges, not points, and state the data source. For example: "31/40 = 78% (soglia provvisoria 60%)". Until CTI publishes the new-format scoring, avoid converting to the 200-point scale (see §4).
- **Mastery definitions to display and test** (thresholds are design hypotheses to validate, not established values):
  - A word is "Imparata" when predicted retrievability on the exam date is ≥0.9, with successful recall in at least 2 modalities.
  - A grammar point is "padroneggiato" when correct across ≥2 item formats, including one production or ordering task.
  - A task (unit) is "completato" when its unit mini-test score is ≥80%.
  - The 4-segment mastery bar in `S.words` should map to these explicit states.
- **Exam-date-aware scheduling** (Cepeda ridgeline): for an exam ~8 weeks away, cap intervals so each item gets several reviews spread up to the last ~1–2 weeks before the exam. Add a final "consolidamento" mode in the last 2–3 weeks: no new words, only reviews and mocks. The prototype shows a countdown (`S.home`), but scheduling ignores it.
- **Placement:**
  - A 10–15-minute adaptive check that estimates listening and reading separately (as Gushi does).
  - Vocabulary "sì/no" checks backed by spot-recall questions to catch over-claiming.
  - Then auto-place in the 15-unit path, with test-out quizzes per unit. This directly answers the HelloChinese complaints in §1.
- **Adaptive difficulty in practice:** pick drill items so expected success sits in a moderate band (hypothesis: ~70–85%) and A/B test it. No verified public target rate was found (see Gaps).
- **LLM-generated practice text:** use only after a deterministic level check (segmentation plus the 2025 word list). Malik et al. show prompting alone is unreliable for level control in open models.

### Gaps
- The "~70% success target" attributed to Duolingo in search summaries could not be traced to a primary source.
- Khan Academy's current mastery mechanics and ALEKS's current initial-assessment length were not retrieved.
- No published, validated method was found for predicting an HSK score from app data; the readiness model above is a design proposal.
- FSRS default desired-retention values and exam-date scheduling options in ts-fsrs were not verified.
- No source was found for minimum responses per item needed for stable Elo/IRT difficulty estimates in a small Italian user base.
- The official new-format scale and pass mark are not stated in the 2025‑12 document (see §4).

## 3. Engagement design with evidence: notifications, streaks, habit formation, sessions, dashboards, autonomy, dark patterns, accessibility (tone colours)

### Takeaway
- **Reminders work modestly.** Duolingo's best bandit system gained +0.5% DAU and +2% new-user retention, and gains fade with novelty, so vary content and stop nagging.
- **Streaks help when intact or repairable but hurt when broken**, especially when users blame themselves.
- **Habits form over weeks to months**, and missing a single day doesn't derail them.
- **Gamification effects are small to moderate**, and the motivational and behavioural effects are unstable.
- **Dashboards rarely support metacognition.**
- **Accessibility:** the prototype's tone palette fails WCAG contrast for orange (2.5:1 on the app background) and green (4.0:1). Under deuteranopia, red vs green tones become nearly indistinguishable (ΔE2000 ≈ 5.8). Colour must never be the only cue.

### Cited Findings
- **Notification bandit** (Yancey & Settles, KDD 2020) — [paper PDF](https://research.duolingo.com/papers/yancey.kdd20.pdf), [DOI 10.1145/3394486.3403351](https://doi.org/10.1145/3394486.3403351) **[measured; verified in the PDF]**:
  - The "Recovering Difference Softmax" algorithm optimised millions of daily reminders and led "to a **0.5%** increase in total daily active users… and a **2%** increase in new user retention over a strong baseline".
  - Reward = "the user completes a lesson within two hours of the reminder".
  - Prior A/B tests showed new templates boost conversion through a "novelty effect" even when they don't win long-term. Without variation, "the bandit will converge to using the same template… day after day, which will get repetitive, desensitize users".
  - Templates are also conditionally eligible ("sleeping" arms).
- **Duolingo streak** (Duolingo blog, 31 Jan 2022) — [Duolingo blog](https://blog.duolingo.com/how-duolingo-streak-builds-habit/) **[vendor]**:
  - Redesigned streak animations "increased the likelihood a brand new learner was still using Duolingo 7 days later by **+1.7%**".
  - Later the streak relies on "loss aversion".
  - The "Streak Freeze" gives "slack", citing UPenn/UCLA research that slack is "more motivating than having a rigid set of rules". Learners can equip up to two freezes.
- **Broken streaks** (Silverman & Barasch, *Journal of Consumer Research* 2023): across seven studies, highlighted **intact** streaks increase subsequent engagement relative to **broken** ones, independent of actual past behaviour. The effect "is amplified when consumers attribute a break… to themselves… and attenuated when consumers can 'repair' a broken streak". — [DOI 10.1093/jcr/ucac029](https://doi.org/10.1093/jcr/ucac029) **[measured]**
- **Habit formation** (Lally et al., *European Journal of Social Psychology*, online 2009/print 2010): 96 volunteers repeated a behaviour in a consistent context ("after breakfast"). Time to 95% of automaticity asymptote "ranged from **18 to 254 days**". "Missing one opportunity to perform the behaviour did not materially affect the habit formation process." — [DOI 10.1002/ejsp.674](https://doi.org/10.1002/ejsp.674) **[measured]**
- **Implementation intentions** ("if-then" plans) were meta-analysed by [Gollwitzer & Sheeran 2006, DOI 10.1016/s0065-2601(06)38002-1](https://doi.org/10.1016/s0065-2601(06)38002-1). The effect size was not retrieved this session.
- **Gamification meta-analysis** (Sailer & Homner, *Educational Psychology Review*, 2020; online 2019): small but significant effects. Cognitive effects held in high-rigour studies; motivational and behavioural effects "were less stable". Game fiction, social interaction, and competition combined with collaboration moderated behavioural outcomes. — [DOI 10.1007/s10648-019-09498-w](https://doi.org/10.1007/s10648-019-09498-w) **[measured]**

  | Outcome | Hedges' g | 95% CI | Studies (k) |
  |---|---|---|---|
  | Cognitive | **0.49** | [0.30, 0.69] | 19 |
  | Motivational | **0.36** | [0.18, 0.54] | 16 |
  | Behavioural | **0.25** | [0.04, 0.46] | 9 |

- **Learning-analytics dashboards** (Matcha et al., IEEE TLT 2020 systematic review): existing dashboards "are rarely grounded in learning theory, cannot be suggested to support metacognition, do not offer any information about effective learning tactics", and their evaluations are weak. — [DOI 10.1109/tlt.2019.2916802](https://doi.org/10.1109/tlt.2019.2916802) **[measured]**
  - A 2026 review of 69 papers finds that "adaptive" dashboards help "students decide what action to take after analyzing" their data. — [Journal of Learning Analytics 2026, DOI 10.18608/jla.2026.9303](https://doi.org/10.18608/jla.2026.9303) **[measured/review]**
- **Dark patterns:** the canonical taxonomy is [Gray et al., CHI 2018, DOI 10.1145/3173574.3174108](https://doi.org/10.1145/3173574.3174108): nagging, obstruction, sneaking, interface interference, forced action. Category list from the paper; the abstract was not retrieved this session.
- **Apple App Review Guidelines** — [Apple](https://developer.apple.com/app-store/review/guidelines/) **[official]**:
  - 4.5.4: push notifications "must not be required for the app to function" and "should not be used for promotions or direct marketing purposes unless customers have explicitly opted in".
  - 3.1.2 governs auto-renewable subscriptions.
- **Apple HIG, Color:** "Avoid relying solely on color to differentiate between objects… or communicate essential information… provide the same information in alternative ways so people with color blindness… can understand it". Supply light, dark and increased-contrast variants of custom colours. — [HIG Color](https://developer.apple.com/design/human-interface-guidelines/color) **[official]**
- **Apple HIG, Accessibility** — [HIG Accessibility](https://developer.apple.com/design/human-interface-guidelines/accessibility) **[official]**:
  - Minimum contrast **4.5:1** for text up to 17 pt, **3:1** at 18 pt or bold.
  - "people who are color blind may have particular difficulty with pairings such as **red-green and blue-orange**"; offer "distinct shapes or icons" and consider letting people customise colour schemes.
  - Default control size **44×44 pt** (minimum 28×28).
  - Support Dynamic Type; describe UI for VoiceOver.
- **Prototype tone colours, analysed** — **[my analysis]**; simulation method from [Machado, Oliveira & Fernandes 2009, IEEE TVCG, DOI 10.1109/TVCG.2009.113](https://doi.org/10.1109/TVCG.2009.113); thresholds from the [HIG](https://developer.apple.com/design/human-interface-guidelines/accessibility):
  - The CSS defines T1 #D1342F, T2 #E08A00, T3 #2E8B3A, T4 #2C62B8, T0 #8E8E8E on paper #FAF6F0 / card #FFFFFF.
  - WCAG contrast on #FAF6F0: T1 4.6:1, **T2 2.5:1**, **T3 4.0:1**, T4 5.5:1. On white: T2 2.69, T3 4.31, T0 3.28. Orange and green fail 4.5:1 for small pinyin; orange fails even the 3:1 large-text rule.
  - Simulated colour-vision deficiency (Machado 2009, severity 1.0), with CIEDE2000 distances:
    - Deuteranopia: T1–T3 **5.8** (nearly identical).
    - Protanopia: T2–T3 **9.4**, T1–T3 15.1.
    - Tritanopia: T3–T4 13.1.
  - A constrained search (contrast 4.5–8:1 on #FAF6F0, keeping the red/orange/green/blue roles) found **T1 #C43149, T2 #7A3D00, T3 #007A7A, T4 #313DC4**. It raises the worst-case CIEDE2000 across normal vision plus the three deficiencies from **5.8 to 14.0**, with contrasts 5.0 / 7.8 / 4.8 / 7.5:1. This is illustrative and needs visual review.
- **Anecdotal engagement complaints:**
  - SuperChinese notifications "saying i'm not busy and just lazy" (GB, 2026-05) — [feed](https://itunes.apple.com/gb/rss/customerreviews/page=1/id=1462500984/sortby=mostrecent/json)
  - HelloChinese: "I don't care about daily challenges or points. Let me opt…" (GB, 2026-08) — [feed](https://itunes.apple.com/gb/rss/customerreviews/page=1/id=1001507516/sortby=mostrecent/json)
  - Skritter: "no way to control the number of new cards… overwhelming" (US, 2026-05) — [feed](https://itunes.apple.com/us/rss/customerreviews/page=1/id=1370892114/sortby=mostrecent/json)
  - Du Chinese: "Font size for the small flashcard text cannot be adjusted" (US, 2026-10) — [feed](https://itunes.apple.com/us/rss/customerreviews/page=1/id=1052961520/sortby=mostrecent/json)
  - SuperChinese "pressures you to move forward quickly" (US, 2026-07) — [feed](https://itunes.apple.com/us/rss/customerreviews/page=1/id=1462500984/sortby=mostrecent/json) **[anecdotal]**
- **Competitor engagement patterns:**
  - SuperChinese "Smart Review: 3 minutes a day" and "Focused Review: choose your own…" — [App Store US](https://apps.apple.com/us/app/superchinese-learn-chinese/id1462500984)
  - Migaku Home with streak and activity heatmap — [App Store](https://apps.apple.com/it/app/migaku-really-learn-languages/id1664096855)
  - Skritter's optional reminders — [App Store](https://apps.apple.com/it/app/skritter-write-chinese/id1370892114) **[vendor]**

### Inferences
- **Notifications** (`S.profile` "Promemoria 19:30"):
  - One daily reminder at a time the user picks during onboarding, phrased as an if-then plan ("Dopo cena, 10 minuti di ripasso"), consistent with Lally's consistent-context finding.
  - Rotate a pool of neutral, informative templates, e.g. "24 carte pronte · 8 min" or "Mancano 55 giorni all'esame: oggi Ascolto parte 2". Never guilt.
  - Reduce frequency after several ignored reminders, and add an exam-date-aware nudge for mock exams.
  - Measure "lesson within 2 h" conversion as Duolingo does; no promotional pushes without explicit opt-in (Apple 4.5.4).
- **Streaks:** the proposal's "nessuna vita… le carte aspettano" stance is well supported. If any continuity indicator is shown, make it forgiving:
  - Count active days per week (e.g. "5 di 7 giorni") rather than an all-or-nothing chain.
  - Allow repair, since Silverman & Barasch find repair attenuates the broken-streak drop.
  - Never mark missed days in red. In the 15-week heatmap in `S.profile`, use neutral empty cells.
  - Copy based on Lally: "Saltare un giorno non rovina l'abitudine."
- **Sessions:**
  - Keep the "~15 minuti" daily plan: reviews first (retrieval practice), then new material.
  - Cap new cards per day, user-adjustable, to avoid Skritter-style overload.
  - Always show remaining time; make every session resumable mid-way.
  - Offer a 3–5-minute "mini" session for busy days.
- **Dashboard (`S.profile`):** replace "11 h di studio"-style vanity stats with actionable ones: coverage gaps, weakest exam part, readiness range, and a single "Prossimo passo consigliato" button. Matcha et al. found dashboards without action guidance don't help.
- **Gamification:** effects are modest and unstable. Skip leagues and points; if anything social is added, prefer cooperative features (study partner, class code for Italian Confucius Institute courses) over competition.
- **Autonomy:**
  - "Ripasso mirato" lets the user choose what to review (words, grammar, mistakes, a specific exam part).
  - Users can skip units via test-out.
  - The AI tutor is optional.
- **Dark-pattern checklist:**
  - No confirmshaming or guilt copy.
  - Clear free/paid boundary; trial-end reminder 48 h before conversion.
  - One-tap cancellation path via Apple subscriptions; no bait discount at cancellation.
  - No "lifetime" plan that could be revoked.
  - Never paywall review of learned material.
- **Accessibility fixes for the prototype:**
  1. **Tone colours:**
     - Ship the CVD-safe, ≥4.5:1 palette (or similar) as the default.
     - Offer "Colori dei toni: Standard / Alto contrasto / Daltonismo / Disattivati".
     - Always pair colour with a non-colour cue: tone diacritics in pinyin (already present), plus optional tone-contour glyphs (ˉ ˊ ˇ ˋ) or numbers next to hanzi when pinyin is hidden.
  2. **Dynamic Type** for hanzi, pinyin and Italian text, including flashcards and exam options.
  3. **VoiceOver:**
     - Label all controls (only the audio buttons have `aria-label` today).
     - Mark Chinese strings with the zh-CN language so VoiceOver uses a Mandarin voice, and Italian strings with it-IT.
     - Give the pitch chart a text description ("la tua curva sale troppo poco alla fine").
  4. **Touch targets** of at least 44×44 pt for tone buttons, chips and answer options.
  5. **Transcripts** for listening content: available in practice mode, hidden in exam mode until the review screen.

### Gaps
- EU and Italian rules on dark patterns and subscriptions (e.g. DSA Art. 25, consumer-protection guidance) were not fetched this session.
- The effect size of implementation intentions and the specific UPenn/UCLA "slack" study cited by Duolingo were not retrieved.
- No evidence was found specific to Italian adult learners' notification preferences.
- Not tested: how VoiceOver reads pinyin with tone diacritics and mixed hanzi/pinyin strings. This needs device testing.
- The suggested palette is computational. It needs visual checks on device in light and dark mode, and ideally with colour-blind users.

## 4. Exam-simulation UX: paper vs internet-based HSK, timers, double audio, review, explanations, item banks, and legal limits

### Takeaway
- **Format:** the official 2025‑12 document fixes the HSK 1 format at 40 items, ~40 min, including time to fill in personal data and the answer sheet. A third-party test-centre page says audio is played **twice for HSK 1–3 and once for HSK 4–6**, with HSK 1 scored out of 200 (pass 120). But that page describes a different, likely draft, structure, so the scoring and double play are **unconfirmed for the 2025‑12 format**.
- **Simulation modes:** Bùbù needs a strict *exam mode* (automatic playback, no feedback until the end, paper vs computer variants) distinct from *practice mode* (replays and instant explanations). The current `S.examq` mixes the two.
- **Content:** every item must be original, ideally a few hundred per level; competitors' "real past papers" are an IP risk unless licensed.
- **Branding:** use "HSK" only descriptively, with a non-affiliation disclaimer; CLEC holds the US trademark.

### Cited Findings
- **Official 2025‑12 structure** (汉考国际, "新版HSK（1-6级）考试结构与样题示例", published 2025‑12, effective 2026‑07; local copy [HSK_struttura_esempi_2025-12.pdf](https://confucio.unimc.it/it/certificazioni/HSK16.pdf)) **[official]**:

  | Level | Listening | Reading | Writing | Total items | Total time |
  |---|---|---|---|---|---|
  | HSK 1 | 4 parts × 5 = 20 items, ~12 min | 4 parts × 5 = 20 items, 20 min | — | 40 | ~40 min |
  | HSK 2 | 25 | 25 | 10 | 60 | ~60 min |
  | HSK 3 | 30 (~23 min) | 30 (30 min) | 10 (20 min) | 70 | ~83 min |

  - Note: "考试总时长含考生填写个人信息及填写答题卡时间" (total time includes filling in personal data and the answer sheet).
  - The HSK 1 sample items match the proposal: Part 1 "三个苹果" → choose A/B/C picture; Part 2 question → answer; Part 3 dialogues matched to pictures A–F; Part 4 sentence plus question with 3 options.
  - The document does not state how many times audio is played, nor the scoring scale.
- **cnhsk.org** (丝绸之路国际教育科技中心, a test-centre/agency page) — [cnhsk.org/hsk](https://www.cnhsk.org/hsk) **[anecdotal/third-party]**:
  - The new HSK is "依据《国际中文教育中文水平等级标准》（GF0025-2021）研发".
  - For HSK 1–3: "听力材料播放两遍" (audio played twice); for HSK 4–6: "听力材料仅播放一遍" (once).
  - HSK 1 report: "听力、阅读和总分三个分数。满分200分，总分120分为合格" plus percentile norms. Results on chinesetest.cn one month after the exam, valid two years.
  - HSK 1–6 "说" (speaking) "需通过单独的HSK口语考试进行考查". HSKK scores out of 100, with 60 to pass.
  - **But** it lists HSK 2 as 35 listening + 25 reading items, HSK 3 as 80 items, HSK 5 as 4,000 words, and an HSK 1 Part 1 true/false format. All of these **contradict** the official 2025‑12 document, so the page likely reflects an earlier draft.
- **Conflict on speaking:** several blogs claim speaking is mandatory from HSK 3 (search extract, e.g. [mandarinzone](https://www.mandarinzone.com/new-hsk-test/)). cnhsk says speaking for HSK 1–6 is a separate oral test. The official 2025‑12 HSK 3 structure lists only listening, reading and writing (70 items). **[conflicting]**
- **Official mocks exist** in paper-based and computer-based (internet) versions. — [Shanghai Education Commission](https://edu.sh.gov.cn/study_en_hsk/20260107/5292266eca744a959c1db43237fbc185.html) **[official]**
- **Competitor practices:**
  - "Work through a full paper… in the same order as the real exam… electronic score report the moment you submit", with an explicit disclaimer that reports don't equal official scores. — [NEW HSK Mock Test](https://apps.apple.com/it/app/hsk3-0-mock-test/id6785017655)
  - "Real past papers… developed with the exam board". — [HSK Mock](https://apps.apple.com/it/app/hsk-mock/id1624661903)
  - "previous real HSK tests". — [SuperTest](https://apps.apple.com/us/app/-/id1335503360)
  - **[vendor]**
- **Practitioner advice:** "Sit at least one mock in the format of your sitting, under real timing, before the exam." — [HSK University, 2026-10-02](https://hskuniversity.com/blog/free-hsk-mock-tests/) **[anecdotal]**
- **Item-bank design:** size alone isn't enough; parameter distribution, content coverage and exposure control matter. — [ERIC EJ1026121](https://eric.ed.gov/?id=EJ1026121), [Doğan 2024](https://doi.org/10.14687/jhs.v21i4.6513) **[measured]**
- **Trademark:** the US register lists HSK marks owned by the **Center for Language Education and Cooperation** (CLEC) — [Justia owner page](https://trademarks.justia.com/owners/center-for-language-education-and-cooperation-5837659), [TrademarkElite](https://www.trademarkelite.com/trademark/trademark-detail/79005627/HSK) (content via search extract; direct fetch returned 403):
  - Serial 79005627 (2004, "Educational examination"): registration cancelled 2024-06-04.
  - Serial 79392708: filed 2024-03-05 for "educational examination services; teaching…".
  - The 79xxxxxx serials indicate Madrid-system international registrations.
- **Apple rules on names and metadata** — [Apple](https://developer.apple.com/app-store/review/guidelines/) **[official]**:
  - 5.2.1: "Don't use protected third-party material such as trademarks… without permission, and don't include misleading, false, or copycat representations, names, or metadata".
  - 2.3.7: don't "pack any of your metadata with trademarked terms"; app names are limited to 30 characters.
- **EU legal background** (not fetched this session; for a lawyer to confirm):
  - EU trade-mark law allows referential use of a mark "for the purpose of identifying or referring to goods or services as those of the proprietor", in particular to indicate intended purpose, if "in accordance with honest practices". — [Regulation (EU) 2017/1001, Art. 14(1)(c)](https://eur-lex.europa.eu/eli/reg/2017/1001/oj)
  - Copyright protects works that are the "author's own intellectual creation", which typically covers test items and texts. — [CJEU C‑5/08 Infopaq](https://eur-lex.europa.eu/legal-content/EN/TXT/?uri=CELEX:62008CJ0005)
- **Anecdotal mock UX failures:**
  - Scoring of an ordering item rejected a correct answer. — [SuperTest US feed](https://itunes.apple.com/us/rss/customerreviews/page=1/id=1335503360/sortby=mostrecent/json)
  - Listening pictures were cut off and there was no iPad landscape mode. — [SuperTest IT feed](https://itunes.apple.com/it/rss/customerreviews/page=1/id=1335503360/sortby=mostrecent/json)
  - Explanations were paywalled (NEW HSK Mock Test release notes). — [App Store](https://apps.apple.com/it/app/hsk3-0-mock-test/id6785017655)

### Inferences
- **[my analysis] Two modes, clearly separated in `S.exam`:**
  - **"Simulazione d'esame"** (strict):
    - Section order and timers as in the 2025‑12 document; listening runs on the audio clock.
    - Each listening item plays automatically at the official pace (twice for HSK 1–3 *if confirmed*; make it a content-pack parameter, not hard code). No pause or replay.
    - No back-navigation into listening. Reading allows free navigation within its section, with "segna per dopo" flags and an unanswered-items overview before submit.
    - No feedback until the end.
    - A **paper variant** adds an answer-sheet transfer step and time (the official total includes it). A **computer (网考) variant** does not.
    - Show pinyin above characters where the official level does (HSK 1 sample).
  - **"Allenamento"**: per-part drills with unlimited replays, 0.8× audio, instant feedback, transcripts.
  - The current `S.examq` (user-controlled "Ascolti: 1/2" button plus immediate "✓ Giusto!" feedback during a 40-question run) belongs to Allenamento. It should not be labelled "Simulazione completa".
- **Results screen (`S.examres`):**
  - Show per-part raw scores (already done), time per section, and items flagged.
  - For each wrong item: audio replay, transcript (hanzi + pinyin + Italian), why the right option is right and why *each* distractor is wrong, and an error tag (parola sconosciuta / tono / grammatica / domanda fraintesa / tempo).
  - The prototype's "aggiunte al ripasso" auto-feeding into FSRS is good.
  - Add the NEW HSK Mock-style disclaimer: "Punteggio indicativo, non equivale a un risultato ufficiale HSK".
  - Explanations are free, not paywalled.
- **[my analysis] Item-bank sizing for HSK 1.** One form has 40 items (8 parts × 5).
  - ~8 non-overlapping full mocks = 320 items.
  - Per-part drill pools of ~60 items × 8 parts = 480 items.
  - Total ≈ **800 original items for HSK 1**, about 2–3× the blueprint per part type. Exposure control means users rarely see the same mock item twice.
  - HSK 2 and HSK 3 scale with their 60/70-item blueprints, plus writing tasks needing rubric-based scoring.
  - Calibrate item difficulty from early users' answers (Elo/IRT, §2) before relying on readiness predictions.
  - Every item must be original. Do not copy or paraphrase closely the official 样题 or 真题. The proposal already says so.
- **Naming and marketing:**
  - Keep "Bùbù 步步" as the name. Use "HSK" only descriptively in subtitle and metadata (e.g. "Preparazione al nuovo esame HSK in italiano"), consistent with Apple 2.3.7.
  - Add "Non affiliata né approvata da Chinese Testing International (CTI) o CLEC" in the App Store description and the About screen.
  - Before launch, check EUIPO/TMview for HSK marks in the EU and Italy.
  - Do not use CTI logos or the official answer-sheet design.

### Gaps
- Not verified: the official 2026 internet-based-test interface (navigation, replay rules, on-screen timer, typing method for writing).
- The official 2025‑12 document is silent on whether audio is played twice in the new format. cnhsk's "两遍" belongs to a conflicting structure, so double play is plausible (legacy convention) but **unconfirmed**.
- The new-format scoring scale and pass marks were not found in official sources.
- Exam-date consistency: the proposal says 13 Dec 2026, HSK University says 13 Dec 2026, and a UK centre listing seen in a search extract says 12 Dec 2026. Some sources say regular 2026 sessions remain HSK 2.0 until the formal launch. Other researchers should confirm.
- The HSK trademark's EU/Italian status, and whether CTI licenses past papers to third parties (and on what terms), are unknown.
- No source was found on the item counts competitors actually own.

## 5. Technology options for advanced features: pronunciation scoring, on-device ASR, pitch/tone feedback, handwriting, neural TTS, LLM tutors, offline-first sync, with costs (dated) and licensing

### Takeaway
- **Pronunciation:** Azure pronunciation assessment covers zh-CN at phoneme level, priced like speech-to-text ($1.00 per audio hour list price, West Europe, Oct 2026). Prosody and syllable-level scores are en-US only, and there is no dedicated tone score.
- **Tone feedback:** on-device pitch tracking (YIN/CREPE) gives free, private feedback, and research supports pitch-curve visualisation.
- **ASR:** Apple's iOS 26 SpeechTranscriber runs on-device and supports Chinese. ASR suits "did you say the word" checks, not pronunciation grading.
- **Handwriting:** Hanzi Writer (MIT) on Make Me a Hanzi data (Arphic PL for graphics, **LGPL for dictionary.txt**) covers stroke-order quizzes. Google ML Kit Digital Ink gives free on-device recognition.
- **Audio:** bundling all neural-TTS audio for HSK 1–3 costs a few dollars (Azure $15 per 1M chars; Google Chirp 3 HD $30 per 1M; Polly Neural $16 per 1M).
- **LLM tutor:** about $0.02–$0.60 per active user per month depending on model, under my assumptions. LLMs over-correct Chinese, so outputs need deterministic guardrails.
- **Sync:** CloudKit (private data in users' iCloud) or Supabase (Free; Pro $25/month).

### Cited Findings

#### Pronunciation assessment APIs
- **Azure pronunciation assessment** (doc updated 2026-07-03) — [Microsoft Learn](https://learn.microsoft.com/en-us/azure/ai-services/speech-service/how-to-pronunciation-assessment) **[official]**:
  - "Prosody assessment is only available in the en-US locale".
  - Syllable-level accuracy is "en-US only".
  - Phoneme names (SAPI alphabet) are supported for **en-US and zh-CN**.
  - Audio over 30 s needs continuous mode, where `EnableMiscue` (omission/insertion detection) is not supported.
  - Unscripted assessment uses a different STT model; Microsoft recommends calling STT first and then running a scripted assessment.
- **Azure pricing model** (tool page, ms.date 2026-03-31): pronunciation assessment "costs the same as speech to text". Accuracy, fluency, completeness and miscue are in the baseline price; prosody is an add-on. "Content and prosody assessments are only available in the en-US locale." — [Microsoft Learn](https://learn.microsoft.com/en-us/azure/ai-services/speech-service/pronunciation-assessment-tool) **[official]**
- **Azure list prices** (West Europe, USD, from the Azure Retail Prices API, 2026-10-19) — [prices.azure.com API](https://prices.azure.com/api/retail/prices?$filter=serviceFamily%20eq%20%27AI%20%2B%20Machine%20Learning%27%20and%20armRegionName%20eq%20%27westeurope%27%20and%20contains(meterName,%27Speech%27)) **[measured: API]**:

  | Meter | Price |
  |---|---|
  | S1 Speech to Text | **$1.00/hour** |
  | Fast Transcription | $0.36/hour |
  | Azure OpenAI Whisper batch (global) | $0.36/hour |
  | Neural TTS | **$15 per 1M chars** (since 2024-02) |
  | Neural HD TTS | **$22 per 1M chars** (since 2026-03-01) |
  | Personal Voice | $24 per 1M chars |

  - Free tier (F0): 5 audio hours of STT and 0.5M neural TTS characters per month. — [Azure pricing page](https://azure.microsoft.com/en-us/pricing/details/cognitive-services/speech-services/) (prices render as placeholders there)
  - Conflict: a volunteer moderator on Microsoft Q&A (2025-11-04) quotes **$1.32/h** for STT standard (likely another region or currency). He confirms PA "is not a separate add-on" and that short audio is prorated per second (e.g. 8 s ≈ $0.0029). — [Microsoft Q&A](https://learn.microsoft.com/en-us/answers/questions/5608069/pricing-and-usage-of-pronunciation-assessment-feat) **[anecdotal]**
- **SpeechSuper**: scripted Mandarin assessment at "Single Character", "Short Text" and "Long Text" levels. iOS/Android SDKs for "English & Mandarin Chinese" are "Offline-Ready". No public pricing (free trial). — [speechsuper.com](https://www.speechsuper.com/), [API samples](https://github.com/speechsuper/SpeechSuper-API-Samples) **[vendor]**
- **iFlytek:** its 语音评测 (speech evaluation) covers Mandarin and English. The "普通版" has been retired in favour of "流式版" (streaming). — [third-party API doc (apifox)](https://3lm2ecwxxs.apifox.cn/doc-3428919) (via search extract; weak source)
- **Tencent Cloud SOE:** the product page returned 404. — [tencentcloud.com](https://www.tencentcloud.com/products/soe-overview)
- **Competitor claims on tone scoring:**
  - Laoshi scores "pronunciation and tone… two scores… one for pronunciation, one for the tone" per character. — [App Store](https://apps.apple.com/it/app/laoshi-imparare-cinese-hsk/id1510215770)
  - SuperChinese claims tone correction; ChineseSkill says it "corrects… tones".
  - Users complain of opaque or wrong scores (§1). **[vendor/anecdotal]**

#### On-device speech recognition (iOS)
- **SFSpeechRecognizer:** `supportsOnDeviceRecognition` "indicates whether the speech recognizer can operate without network access". With `requiresOnDeviceRecognition`, "on-device requests won't be as accurate". — [Apple docs](https://developer.apple.com/documentation/speech/sfspeechrecognizer/supportsondevicerecognition), [Apple docs](https://developer.apple.com/documentation/speech/sfspeechrecognitionrequest/requiresondevicerecognition) **[official]**
- **SpeechAnalyzer / SpeechTranscriber** (iOS 26) — [Apple docs](https://developer.apple.com/documentation/speech/speechtranscriber), [Addpipe blog, 2026-08-17](https://blog.addpipe.com/apple-speechanalyzer-api/) **[official + vendor-adjacent]**:
  - Run "entirely on the device" using a system-managed downloadable model.
  - Languages at launch: "Cantonese, Chinese, English, French, German, Italian, Japanese, Korean, Portuguese and Spanish". Check `supportedLocales` at runtime.
  - DictationTranscriber is a fallback for unsupported languages or devices.
  - Reported to be ~2.2–3× faster than Whisper.
- **whisper.cpp:** MIT licence, iOS support, Core ML encoder on the Apple Neural Engine (">x3 faster compared with CPU-only"). — [GitHub](https://github.com/ggml-org/whisper.cpp) **[vendor]**
- **Whisper hallucinations** ("Careless Whisper", FAccT 2024): "roughly 1% of audio transcriptions contained entire hallucinated phrases", and 38% of those included explicit harms; hallucinations occur more with long non-vocal durations. — [DOI 10.1145/3630106.3658996](https://doi.org/10.1145/3630106.3658996) **[measured]**

#### Pitch and tone feedback
- **YIN** (de Cheveigné & Kawahara 2002): F0 error rates "about three times lower than the best competing methods", "may be implemented efficiently and with low latency". — [DOI 10.1121/1.1458024](https://doi.org/10.1121/1.1458024) **[measured]**
- **CREPE** (ICASSP 2018) is a convolutional neural pitch estimator. — [DOI 10.1109/icassp.2018.8461329](https://doi.org/10.1109/icassp.2018.8461329)
- **Pitch-curve training** (Chun, Jiang, Meyr & Yang 2015, *Journal of Second Language Pronunciation*): 35 learners compared their pitch curves with native ones, 20–25 min weekly for 9 weeks. Native raters judged tones improved pre→post, acoustic analysis showed some tones improved, and "two-thirds of the participants found viewing pitch curves helpful". — [DOI 10.1075/jslp.1.1.04chu](https://doi.org/10.1075/jslp.1.1.04chu) **[measured, small sample, no control group reported in the abstract]**

#### Handwriting and stroke order
- **Hanzi Writer** — [GitHub hanzi-writer](https://github.com/chanind/hanzi-writer) **[official repo]**:
  - "released under an MIT license".
  - Its data is "derived from the Make me a Hanzi project", which "extracted the data from fonts by Arphic Technology"; redistributable "under the terms of the Arphic Public License".
- **Make Me a Hanzi** — [README](https://github.com/skishore/makemeahanzi), [COPYING](https://raw.githubusercontent.com/skishore/makemeahanzi/master/COPYING) **[official repo]**:
  - "over 9000 of the most common simplified and traditional Chinese characters".
  - `graphics.txt` (stroke SVGs) is under the **Arphic Public License**; `dictionary.txt` (decomposition, radical, etymology, pinyin) is under the **GNU LGPL v3+**.
  - Stroke data follows **PRC** stroke order.
- **Google ML Kit Digital Ink Recognition:** on-device, works "without an internet connection", "Supports 300+ languages and 25+ writing systems", available on iOS and Android, free. — [Google developers](https://developers.google.com/ml-kit/vision/digital-ink-recognition), [Google blog 2020](https://developers.googleblog.com/2020/08/digital-ink-recognition-in-ml-kit.html) (≈20 MB model per language per search extract) **[official]**
- **PencilKit** captures finger or Apple Pencil input as drawings and provides a drawing environment; the docs describe no recognition API. — [Apple docs](https://developer.apple.com/documentation/pencilkit) **[official]**

#### Neural TTS (prices retrieved 2026-10-19)
- **Azure:** Neural $15 per 1M characters; Neural HD $22 per 1M; free tier 0.5M per month (see table above).
- **Google Cloud TTS** — [Google pricing](https://cloud.google.com/text-to-speech/pricing):
  - Chirp 3 HD: **$30 per 1M** characters, first 1M free per month.
  - Neural2 $16 per 1M; Studio $160 per 1M; Standard $4 per 1M.
  - Gemini TTS preview (e.g. "Gemini 3.8 Flash TTS"): $0.50 per 1M text input tokens and $9 per 1M audio output tokens through 31 Dec 2026, rising to $1 / $18 from 1 Jan 2027.
- **Amazon Polly:** Standard $4 per 1M, **Neural $16 per 1M**, Generative $30 per 1M, Long-Form $100 per 1M. Free tier: 1M Neural characters per month for 12 months. — [AWS pricing](https://aws.amazon.com/polly/pricing/)
- **Open-source TTS:**
  - CosyVoice (Alibaba FunAudioLLM) is under the **Apache-2.0** licence; its README disclaimer says demo content is "for academic purposes only". — [GitHub](https://github.com/FunAudioLLM/CosyVoice), [LICENSE](https://raw.githubusercontent.com/FunAudioLLM/CosyVoice/main/LICENSE)
  - Kokoro-82M has Apache-2.0 weights, but its model card lists `language: en` only. — [Hugging Face](https://huggingface.co/hexgrad/Kokoro-82M)
  - MeloTTS supports "Chinese (mix EN)", "Fast enough for CPU real-time inference". — [GitHub](https://github.com/myshell-ai/MeloTTS) **[vendor]**

#### LLM tutors
- **Claude API list prices** (Anthropic docs, table cached 2026-06-24), USD per 1M input / output tokens — [Anthropic pricing](https://platform.claude.com/docs/en/about-claude/pricing), [prompt caching](https://platform.claude.com/docs/en/build-with-claude/prompt-caching) **[official]**:

  | Model | Input | Output |
  |---|---|---|
  | Claude Haiku 4.5 | $1 | $5 |
  | Claude Sonnet 5 | $2 | $10 |
  | Claude Sonnet 4.6 | $3 | $15 |
  | Claude Opus 5.5 | $4 | $20 |
  | Claude Opus 5 | $5 | $25 |

  - Cache reads ≈0.1× the input price; cache writes 1.25× (5-minute TTL) or 2× (1-hour TTL).
  - The Batch API runs at 50% cost.
- **Gemini API** (page "last updated 2026-10-16") — [Google AI pricing](https://ai.google.dev/gemini-api/docs/pricing) **[official]**:
  - Gemini 2.5 Flash-Lite: $0.10 input (text) / $0.40 output per 1M tokens.
  - Gemini 3.5 Flash-Lite: $0.30 / $2.50.
  - Batch at 50%; context caching $0.01–$0.03 per 1M plus $1 per 1M tokens per hour of storage.
- **Correctness on Chinese:**
  - LLMs evaluated on four Chinese grammatical-error-correction datasets "fall short of the previous sota models because of the problem of over-correction", and performance varies across data distributions. — [Qu, Tang & Wu, arXiv 2307.03972 (rev. 2025-03)](https://arxiv.org/abs/2307.03972)
  - ChatGPT shows "over-correction tendencies and not adhering to the principle of minimal edits". — [Fang et al. 2023, arXiv 2304.01746](https://arxiv.org/abs/2304.01746) **[measured]**
- **Level control** (CEFR): prompting alone is weak for open models; fine-tuning plus RL can beat GPT‑4 at a fraction of the cost. — [Malik et al., ACL Findings 2024](https://arxiv.org/abs/2406.03030) **[measured]**

#### Offline-first storage and sync
- **Supabase** (2026-10-19) — [Supabase pricing](https://supabase.com/pricing) **[official]**:
  - Free $0: 50,000 MAU, 500 MB database; "Free projects are paused after 1 week of inactivity".
  - Pro **$25/month**: 100,000 MAU then $0.00325 per MAU, 8 GB disk, daily backups.
- **CloudKit:** "Store private data securely in your users' iCloud accounts for limitless scale… and get up to 1PB of storage for your app's public data". Fields can be encrypted. — [Apple CloudKit](https://developer.apple.com/icloud/cloudkit/) **[official]**

### Inferences
- **[my analysis] Tone/pronunciation roadmap for `S.tones`** (currently a simulated "Punteggio tono: 72/100"):
  - **v1, on-device and free:**
    - Track pitch with YIN/pYIN, convert to semitones, normalise to the speaker's range, and overlay on the native contour (as designed). Chun et al. support this.
    - Replace the pseudo-precise "72/100" with categorical feedback: tone recognised as T1/T2/T3/T4, plus a specific hint ("risali di più alla fine").
    - Classify with DTW/template matching or a small classifier trained on native recordings, for isolated syllables and 2-syllable words first. Handle neutral tone and 3rd-tone sandhi explicitly.
  - **v2, cloud, sentences:** Azure zh-CN scripted assessment for sentence reading and HSKK-style repetition, with phoneme-level accuracy. Combine with the app's own F0 analysis for tones, since Azure gives no tone or prosody score for zh-CN.
  - **Cost at list price:** 20 utterances × 4 s × 20 days ≈ 0.44 h/user/month ≈ **$0.44/user/month**, or ~$0.22 at 10 utterances per day.
  - Evaluate SpeechSuper (offline SDK) against Azure on Italian learners' recordings before committing.
- **ASR use:**
  - Use iOS 26 SpeechTranscriber (on-device, private) only for lenient recall checks ("dì la parola"), comparing recognised hanzi or pinyin to the target. Never use it as a pronunciation grade: ASR language models "repair" errors, and Whisper hallucinates.
  - Bundled Whisper (whisper.cpp) is only a fallback for older iOS versions.
- **Handwriting (`S.char`, HSK 2+):**
  - Keep Hanzi Writer's quiz (stroke-by-stroke matching) for 书写字. Optionally add ML Kit Digital Ink for free-form character recognition in "scrivi la parola" drills.
  - **Licence fix to the proposal:** it says "Make Me a Hanzi, licenza Arphic Public License: da citare". If Bùbù uses `dictionary.txt` data (decompositions, radicals, as in the "Come è fatto" box), **LGPL v3** obligations also apply. Keep that data in a separate replaceable file and include licence texts and attribution in "Crediti".
  - Stroke order follows PRC conventions, which is fine for the HSK.
- **[my analysis] Audio.** Replace the prototype's browser `speechSynthesis` (voice quality varies by device) with pre-generated, human-checked audio:
  - Rough HSK 1–3 volume: 1,000 words (~2k characters) + ~1,000 example sentences (~12k) + 45 dialogues (~7k) + 30 mocks × ~60 items × ~40 chars (~72k) + ~2,000 grammar examples (~24k) ≈ **117k characters**, ≈234k with two voices (male/female, like the exam).
  - Cost: Azure Neural ≈ **$3.5**; Chirp 3 HD ≈ $7, or $0 within the 1M free tier. This confirms the proposal's "pochi euro".
  - Budget human QA for polyphones (多音字), neutral tones and 一/不 sandhi; use SSML phoneme overrides where needed.
  - For mock-exam realism, consider recording two native speakers for a subset of listening items.
- **[my analysis] LLM tutor cost.** Assumptions: 20 active days, 8 turns/day, ~2,000-token cached system prompt (rules + HSK 1 list), ~600 uncached context tokens and ~150 output tokens per turn, one cache write per session.

  | Model | Cost per active user per month |
  |---|---|
  | Claude Haiku 4.5 | ≈ **$0.30** |
  | Claude Sonnet 5 | ≈ **$0.60** |
  | Gemini 2.5 Flash-Lite | ≈ **$0.02** (excluding cache storage) |

  Heavy users at 3× usage scale linearly. Chinese tokenisation rates were not measured (see Gaps).
- **LLM guardrails for correctness in Chinese:**
  1. Restrict the LLM to explaining in Italian *the learner's* mistakes, generating practice sentences, and role-playing the 15 official tasks. It never scores mocks.
  2. Deterministic post-checks: word segmentation (e.g. jieba) plus a whitelist of the 2025 syllabus words up to the user's level. Regenerate if out-of-level words exceed ~2–5% (the proposal's 95–98% comprehensible-input rule).
  3. Take pinyin from the app's dictionary, never from the LLM.
  4. Prefer minimal-edit prompts and show the diff to counter over-correction.
  5. Label output "IA", allow opt-out, and log reports of wrong answers.
- **Offline-first:**
  - Keep the content database bundled in SQLite (expo-sqlite or GRDB).
  - Store reviews and answers as append-only event logs, which merge well across devices.
  - iOS-only MVP: CloudKit private database (no server cost; data counts against users' iCloud quota).
  - If Android or web follow: Supabase (Free tier pauses inactive projects; Pro $25/month).
  - Never require network for reviews, mocks or audio.

### Gaps
- No public pricing was found for SpeechSuper, iFlytek international or Tencent SOE; iFlytek's international availability and data-residency terms were not checked.
- Whether Azure's zh-CN phoneme results encode tone errors explicitly, and how accurate they are on Italian speakers, is unknown.
- Each TTS provider's terms on redistributing generated audio inside a paid app were not fetched.
- Kokoro's Mandarin support (model card says `en`) and MeloTTS's licence were not verified.
- No public accuracy figures were found for an on-device Mandarin tone classifier on L2 speech.
- Not measured: Chinese and Italian token-per-character rates for each LLM, which affect the cost estimate.
- GDPR handling for voice recordings (EU-region processing, retention) needs separate review.
