# Scienza dell'apprendimento per un'app HSK: tecniche di studio con le prove più solide (retrieval, spacing, SRS, interleaving, feedback, metacognizione, parametri pratici)

Notes language: English (for precision of quoted statistics); final report will be in Italian.
Legend for study types: **[MA]** meta-analysis, **[SR]** systematic/narrative review, **[EXP]** controlled experiment(s), **[FIELD]** classroom/field experiment, **[SIM]** simulation/modelling, **[IND]** industry paper / production A/B test, **[BENCH]** open benchmark (not peer-reviewed), **[DOC]** practitioner documentation. "Single study" flags are explicit. Numbers marked *(secondary)* come from a summary/search snippet or a citing paper, not from the primary text I read.

---

## 1. Retrieval practice / testing effect: size, transfer, recall vs recognition, feedback, L2 vocabulary

### Takeaway
Retrieval practice is the best-replicated technique: about g ≈ 0.50 over restudy/other conditions in lab meta-analyses and g ≈ 0.50 in real classrooms (≈0.33 over restudy specifically). Effects are larger with feedback, with recall-type initial tests (in Rowland), with retention intervals of 1 day or more, and with more repetitions. It transfers moderately (d ≈ 0.40), but transfer is weakest when the cue and the answer are swapped (e.g. learning 汉字→meaning and then being tested meaning→汉字). For an L2 app, this means recall-first cards in several directions, corrective feedback every time, at least 3–4 successful retrievals spread over sessions, and some practice in the exam's own format.

### Cited Findings
**Lab meta-analyses**
- [MA] Rowland 2014 (Psychological Bulletin 140(6):1432–1463): 159 effect sizes from 61 studies (1975–2013); random-effects overall g = 0.50, 95% CI [0.42, 0.58], testing vs restudy — [Rowland 2014, DOI](https://doi.org/10.1037/a0037559); [open PDF](https://courseware.epfl.ch/assets/courseware/v1/fdde2f0aa590bf3b1324077a6bf1540c/asset-v1%3AEPFL%2BDEMO%2B2020%2Btype%40asset%2Bblock/Rowland2014-meta-analysis.pdf)
- Rowland moderators (full data set): published g = 0.58 (k = 122) vs unpublished g = 0.25 (k = 37), a sign of publication bias; between-subjects 0.69 vs within-subjects 0.43; stimuli: paired associates 0.59 (k = 71), prose 0.58, single words 0.39 — [Rowland 2014 PDF, Table 2](https://courseware.epfl.ch/assets/courseware/v1/fdde2f0aa590bf3b1324077a6bf1540c/asset-v1%3AEPFL%2BDEMO%2B2020%2Btype%40asset%2Bblock/Rowland2014-meta-analysis.pdf)
- Rowland, initial test type: cued recall g = 0.61 (k = 104), free recall 0.29 (k = 36), recognition 0.29 (k = 19). In the "high-exposure" subset (feedback given, or >75% initial success): cued recall 0.72, free recall 0.81, recognition 0.36. Rowland reads this as support for "retrieval effort" accounts — [Rowland 2014 PDF](https://courseware.epfl.ch/assets/courseware/v1/fdde2f0aa590bf3b1324077a6bf1540c/asset-v1%3AEPFL%2BDEMO%2B2020%2Btype%40asset%2Bblock/Rowland2014-meta-analysis.pdf)
- Rowland, retention interval: <1 day g = 0.41 (k = 103) vs ≥1 day g = 0.69 (k = 56). Final test type: cued recall 0.57, free recall 0.49, recognition 0.31. Matching vs mismatching initial and final test formats: not significant (different 0.58 vs same 0.46) — [Rowland 2014 PDF](https://courseware.epfl.ch/assets/courseware/v1/fdde2f0aa590bf3b1324077a6bf1540c/asset-v1%3AEPFL%2BDEMO%2B2020%2Btype%40asset%2Bblock/Rowland2014-meta-analysis.pdf)
- Rowland, feedback: with feedback g = 0.73 (k = 52) vs without g = 0.39 (k = 107). Without feedback the effect depends on initial success: ≤50% correct g = 0.03 (n.s.); 51–75% g = 0.29; >75% g = 0.56. Delayed feedback g = 1.38 (k = 6) vs immediate g = 0.66 (k = 46); the author warns this rests on very few studies — [Rowland 2014 PDF](https://courseware.epfl.ch/assets/courseware/v1/fdde2f0aa590bf3b1324077a6bf1540c/asset-v1%3AEPFL%2BDEMO%2B2020%2Btype%40asset%2Bblock/Rowland2014-meta-analysis.pdf)
- [MA] Adesope, Trevisan & Sundararajan 2017 (Review of Educational Research): 118 articles, 272 independent effect sizes, 15,472 participants. Practice tests beat restudying and every other comparison condition — [ERIC record](https://eric.ed.gov/?id=EJ1141817); [DOI](https://doi.org/10.3102/0034654316689306); [WSU news, sample sizes](https://news.wsu.edu/news/2018/01/09/educational-psychology-article-among-nations-most-read/). Overall g = 0.61 *(secondary)* — [Learning Scientists summary](https://www.learningscientists.org/blog/2017/2/9-1)
- Adesope's format and feedback results, as reported by Yang et al. 2021 *(secondary)*: multiple choice g = 0.70 > free recall 0.62 > cued recall 0.58 > short answer 0.48, which conflicts with Rowland's recall > recognition; and no moderating effect of feedback (with feedback 0.63, without 0.60), which conflicts with Rowland's 0.73 vs 0.39 — [Yang et al. 2021 PDF](https://gwern.net/doc/spaced-repetition/2021-yang.pdf)

**Classroom meta-analysis**
- [MA] Yang, Luo, Vadillo, Yu & Shanks 2021 (Psychological Bulletin 147(4):399–435): 222 independent studies, 48,478 students. Overall g = 0.499. P-curve gives strong evidence for the effect; publication-bias risk judged small — [PubMed](https://pubmed.ncbi.nlm.nih.gov/33683913/); [DOI](https://doi.org/10.1037/bul0000309)
- Yang by comparison condition: vs no activity/filler g = 0.610; vs testing with fewer questions 0.465; vs restudying 0.330; vs other elaborative strategies 0.095 — [Yang 2021 PDF, Table 1](https://gwern.net/doc/spaced-repetition/2021-yang.pdf)
- Yang by quiz format (format was **not** a significant moderator): matching 0.913, fill-in-the-blank 0.773, short answer 0.638, multiple choice 0.567, cued recall 0.316, free recall 0.238, mixed 0.336 — [Yang 2021 PDF](https://gwern.net/doc/spaced-repetition/2021-yang.pdf)
- Yang on transfer and format match: quiz and exam in the same format g = 0.531 vs different formats 0.399 (both > 0). Untested but related knowledge also benefits (g = 0.321 vs 0.512 for tested knowledge) — [Yang 2021 PDF](https://gwern.net/doc/spaced-repetition/2021-yang.pdf)
- Yang on feedback and dose: corrective feedback 0.537 vs none 0.374. The effect grows with the number of test repetitions and with treatment duration (single class 0.385; less than a semester 0.521; one semester 0.547; more than a semester 0.624). Post-class quizzes 0.536 vs pre-class quizzes 0.186. University students 0.486. Continuing/adult education: only k = 6, n.s. (0.314) — [Yang 2021 PDF](https://gwern.net/doc/spaced-repetition/2021-yang.pdf)

**Transfer**
- [MA] Pan & Rickard 2018 (Psychological Bulletin 144(7):710–756): 192 transfer effect sizes, 122 experiments, 67 articles, N = 10,382. Testing gives transferable learning vs a non-testing re-exposure control, d = 0.40 [0.31, 0.50]. Transfer is greatest across test formats, to application/inference questions and to mediator/related-word cues. It is weakest to **rearranged stimulus–response items**, to untested material seen during study, and to worked-example problems. Response congruency, elaborated retrieval practice and initial test performance strongly moderate transfer. After PET-PEESE bias correction, the predicted transfer is often zero when none of these moderators is present — [Pan & Rickard 2018](https://doi.org/10.1037/bul0000151)
- Pan & Rickard *(secondary)*: without response congruency d ≈ 0.28; with congruency about +0.30 more (≈0.58) — [Matuschak notes](https://notes.andymatuschak.org/zC1oBp6yE72b7YHzaJZmjXf)

**L2 vocabulary specifically**
- [EXP] Karpicke & Roediger 2008 (Science): foreign-language (Swahili) vocabulary. Repeated studying after an item was learned had no effect on delayed recall; repeated testing had a large positive effect. Students' predictions of their own performance were uncorrelated with actual performance — [Karpicke & Roediger 2008](https://doi.org/10.1126/science.1152408)
- [EXP] Soderstrom, Kerr & Bjork 2016: replicated Karpicke & Roediger. When spacing differences were controlled within subjects, **both** repeated testing and restudying improved learning, so part of the 2008 "restudy does nothing" result reflected a spacing confound — [PubMed](https://pubmed.ncbi.nlm.nih.gov/26674128/)
- [EXP] Huang et al. 2025: 108 Chinese–English bilinguals, 60 Swahili–Chinese word pairs. The retrieval-practice effect grew with more learning rounds (4 vs 3) and held for both paper and computer tests, but the test came only 30 min after learning — [Huang et al. 2025](https://doi.org/10.3390/bs15111540)
- [EXP] Miyatsu & McDaniel 2019: with only 2 retrievals per item there was **no** testing effect for foreign vocabulary at 48 h or 1 week; 4 rounds gave a marginal effect. Keyword mnemonic + retrieval beat keyword alone at 1 week — [PubMed](https://pubmed.ncbi.nlm.nih.gov/31077068/); [DOI](https://doi.org/10.3758/s13421-019-00936-2)
- [EXP, single study] Nakata 2017 (SSLA): 98 Japanese learners, 16 English–Japanese pairs, 1/3/5/7 retrievals within a session. 5 and 7 retrievals scored significantly higher than 1 and 3 at every posttest (delay >2 weeks). Per unit of time-on-task, 1 retrieval gave the largest gain — [Nakata 2017](https://doi.org/10.1017/S0272263116000280)
- [MA] Webb, Yanagisawa & Uchihara 2020 (Modern Language Journal): 100 effect sizes from 22 studies on flashcards, word lists, writing and fill-in-the-blank. Mean gains were 60.1% (meaning recall) and 58.5% (form recall) on immediate posttests, dropping to 39.4% and 25.1% on delayed tests. Activities ranged from 18.4% to 77.0% (immediate). Learning **direction** and place of study moderated gains — [Webb et al. 2020](https://doi.org/10.1111/modl.12671). Flashcards and word lists gave "relatively large gains"; writing and fill-in-the-blank "relatively small" *(secondary)* — [Semantic Scholar record](https://www.semanticscholar.org/paper/How-Effective-Are-Intentional-Vocabulary%E2%80%90Learning-A-Webb-Yanagisawa/7ed303720cba3acd650b0300e1f7257a60d5e725)
- [FIELD, single study] Maie et al. 2025: 88 Japanese university students, 100 words over a semester, online flashcards. Cumulative quizzes (new + old words) beat non-cumulative ones, but only with more practice and mainly for lower-proficiency learners. Total study time did not differ — [Maie et al. 2025](https://doi.org/10.1002/tesq.3391)
- [EXP] Pashler, Cepeda, Wixted & Rohrer 2005: 258 subjects, Luganda–English pairs. Giving the correct answer after an incorrect response raised retention at 1 week by **494%**; feedback after correct responses made little difference, even when confidence was low — [PubMed](https://pubmed.ncbi.nlm.nih.gov/15641900/)
- [EXP] Butler, Karpicke & Roediger 2008: feedback **doubled** retention of correct-but-low-confidence answers (general-knowledge MC). This partly conflicts with Pashler 2005 on low-confidence correct answers — [Butler et al. 2008](https://doi.org/10.1037/0278-7393.34.4.918)

### Inferences
- The default exercise should be **recall-first** (produce the meaning, pinyin/tone or character from a cue), always followed by the correct answer. Rowland's recall > recognition result and the very large benefit of feedback after errors (Pashler) both point this way.
- Recognition/MC items still have two uses:
  - early in learning, when unaided recall success would be ≤50% (without feedback that case gives g ≈ 0.03);
  - **exam-format practice**, because HSK 1 tests recognition in listening and reading (Yang: matched format 0.531 vs mismatched 0.399).
- Rowland and Adesope disagree on format. The safe design is a mix: recall for durability plus HSK-like MC for transfer.
- Each direction needs its own card, because transfer to rearranged items is weakest (Pan & Rickard) and direction moderated gains (Webb 2020). Suggested directions: 汉字→meaning, audio→meaning/汉字, meaning→汉字/pinyin, and tone recall.
- Plan for **≥3–4 successful retrievals per item spread across sessions/days**. Two retrievals can produce no testing effect (Miyatsu & McDaniel), and effects grow with repetitions (Yang; Huang; Nakata 2017).
- Realistic expectation over restudy is about +0.3–0.5 SD. Against other active strategies the classroom gain is small (0.095), so the app's advantage will come mostly from scheduling and dosage, not from quizzing alone.

### Gaps
- I found no meta-analysis of the testing effect specifically for Chinese (characters, tones). L2 evidence is mostly alphabetic or paired-associate (Swahili, Luganda, English–Japanese).
- Adesope 2017's full moderator table (e.g. the restudy-only comparison) was not accessible. The format and feedback numbers come from Yang 2021's citation.
- Yang 2021 has very little evidence for adult/continuing education (k = 6, n.s.).

---

## 2. Spacing and spaced repetition: optimal gaps, L2 meta-analysis, expanding vs uniform, algorithms (SM-2, HLR, DHP/FSRS), desired retention, fixed exam date

### Takeaway
Spacing has large effects. The optimal gap depends on how long you need to remember: about 20–40% of the retention interval for a 1-week horizon, falling to 5–10% for a 1-year horizon. A gap that is too short costs far more than one that is too long. Expanding and uniform schedules give the same long-term retention (Latimier g = 0.034; Kim & Webb "statistically equivalent"), though expanding keeps performance higher during training. Among deployable algorithms, FSRS (DSR model; FSRS-6/7) predicts recall clearly better than HLR and is better than SM-2 for about 99.6% of users in an open (FSRS-team) benchmark. A desired retention of about 0.90 is the documented default; workload climbs steeply above 0.90–0.95.

### Cited Findings
**Spacing meta-analyses and benchmark studies**
- [MA] Cepeda, Pashler, Vul, Wixted & Rohrer 2006 (Psychological Bulletin): 839 assessments of distributed practice in 317 experiments from 184 articles. The gap (ISI) that maximizes retention grows as the retention interval grows — [DOI](https://doi.org/10.1037/0033-2909.132.3.354); [open PDF](https://escholarship.org/content/qt3rr6q10c/qt3rr6q10c.pdf)
- [EXP, large online] Cepeda, Vul, Rohrer, Wixted & Pashler 2008 (Psychological Science 19(11):1095–1102): 1,354 participants (mean age 34; 32 obscure facts). Study gaps went up to 3.5 months and final test delays up to 1 year. With study time held fixed, the optimal gap vs a zero-day gap raised final recall by 64% (d = 1.1) and recognition by 26% (d = 1.5) — [PDF](https://www.evullab.org/pdf/CepedaVulRohrerWixtedPashler-PS-2008.pdf); [DOI](https://doi.org/10.1111/j.1467-9280.2008.02209.x)
- Cepeda 2008 optimal gaps. For retention intervals of 7/35/70/350 days, the best tested gaps for recall were 1/11/21/21 days. Interpolated optima were ≈3/8/12/27 days, i.e. 43%/23%/17%/8% of the retention interval. In the abstract, the optimal gap falls "from about 20 to 40% of a 1-week test delay to about 5 to 10% of a 1-year test delay." Too long a gap costs "much smaller" than too short a gap — [Cepeda 2008 PDF](https://www.evullab.org/pdf/CepedaVulRohrerWixtedPashler-PS-2008.pdf)
- [MA] Kim & Webb 2022 (Language Learning 72(1):269–319): 98 effect sizes, 48 experiments, N = 3,411 L2 learners. Findings:
  - spacing had a **medium-to-large** effect on L2 learning;
  - shorter spacing equalled longer spacing on immediate tests but was **less effective on delayed tests**;
  - equal and expanding spacing were **statistically equivalent**;
  - variability was explained by learning target, number of sessions, type of practice, activity type, feedback timing and retention interval.
  — [Kim & Webb 2022](https://doi.org/10.1111/lang.12479)
- [MA] Latimier, Peyre & Ramus 2021 (Educational Psychology Review 33:959–987): 29 studies. Spaced vs massed retrieval practice g = 0.74 (39 effect sizes). Expanding vs uniform g = 0.034, n.s. (54 effect sizes). The more often an item is tested, the more expanding beats uniform. Their conclusion: the data "do not support the widely held belief that inter-retrieval intervals should be progressively increased" — [ERIC](https://eric.ed.gov/?id=EJ1310148); [DOI](https://doi.org/10.1007/s10648-020-09572-8); [OSF preprint](https://osf.io/kzy7u)

**Expanding vs uniform schedules (L2)**
- [EXP] Nakata 2015 (SSLA): 128 Japanese college students, 20 English–Japanese pairs. Expanding beat equal spacing by a "limited, yet statistically significant" margin, the first L2 study to find this. The **amount** of spacing had large effects; "introducing spacing may have a larger effect" — [Nakata 2015](https://doi.org/10.1017/S0272263114000825)
- [EXP] Kang, Lindsey, Mozer & Pashler 2014: foreign vocabulary over 4 weeks. Expanding and equal-interval schedules gave equal recall on a final test 8 weeks later, but expanding gave "much higher average recallability over the whole training period" — [PubMed](https://pubmed.ncbi.nlm.nih.gov/24744260/)
- [EXP] Karpicke & Roediger 2007: expanding retrieval helped at 10 min, but equal spacing gave better retention after 2 days. What mattered was **delaying the first test**, to make the first retrieval harder — [Karpicke & Roediger 2007](https://doi.org/10.1037/0278-7393.33.4.704)

**Long-term and practical spacing studies**
- [EXP, longitudinal, n = 4] Bahrick et al. 1993: 300 English–foreign word pairs over 9 years. 13 relearning sessions at 56-day intervals gave retention comparable to 26 sessions at 14-day intervals. Number of sessions and spacing had independent benefits — [Bahrick et al. 1993](https://doi.org/10.1111/j.1467-9280.1993.tb00571.x)
- [EXP] Kornell 2009 (GRE word pairs, web flashcards): one large stack (spacing) beat four small stacks (massing), and spacing beat cramming on the last day. Spacing was better for 90% of participants, yet 72% believed massing had worked better — [Kornell 2009](https://doi.org/10.1002/acp.1537)
- [EXP] Nakata & Webb 2016 (SSLA): once spacing is equated, set size (4, 10 or 20 items) "has little effect"; spacing matters more than the part/whole distinction — [Nakata & Webb 2016](https://doi.org/10.1017/S0272263115000236)
- [EXP] Nakata & Elgort 2020: in contextual (reading) word learning, spacing helped explicit knowledge (meaning recall, form–meaning matching) but not tacit knowledge (semantic priming) — [Nakata & Elgort 2020](https://doi.org/10.1177/0267658320927764)

**Algorithms**
- [IND] Settles & Meeder 2016 (ACL), Duolingo half-life regression (HLR):
  - Data: 12.9 million student–word traces from two weeks of logs.
  - Mean absolute error: HLR 0.128 vs Leitner 0.235 vs Pimsleur 0.445; a constant baseline (p̄ = 0.859) gave 0.175. AUC barely differed (HLR 0.538 vs Leitner 0.542).
  - A/B test I (≈1 million students, 6 weeks), HLR vs Leitner: daily *engagement* +0.3% any activity, +0.3% lessons, −7.3% practice sessions.
  - A/B test II (3.3 million students, 2 weeks), HLR without lexeme features vs HLR: +12.0% any activity, +1.7% lessons, +9.5% practice.
  - So the often-quoted "+12%" is HLR-lex vs HLR, and it measures user return rates, not memory.
  — [ACL Anthology](https://aclanthology.org/P16-1174/); [PDF](https://aclanthology.org/P16-1174.pdf); [code & data](https://github.com/duolingo/halflife-regression)
- [IND] Ye, Su & Cao 2022 (KDD): 220 million memory-behaviour logs from MaiMemo, a Chinese vocabulary app. The memory model has the Markov property; the scheduler (SSP-MMC) minimizes review cost via a stochastic-shortest-path algorithm. Reported 12.6% improvement over prior state of the art; deployed in MaiMemo — [DOI](https://doi.org/10.1145/3534678.3539081); [dblp](https://dblp1.uni-trier.de/rec/conf/kdd/YeSC22.html)
- [IND] Su, Ye, Nie, Cao & Chen 2023 (IEEE TKDE): reports 64% lower error in predicting recall and 17% lower schedule cost vs baselines; released a 220-million-row dataset — [DOI](https://doi.org/10.1109/TKDE.2023.3251721); [SSP-MMC-Plus](https://github.com/maimemo/SSP-MMC-Plus)
- [DOC] FSRS model:
  - It originates in MaiMemo's DHP model, a variant of the DSR (Difficulty, Stability, Retrievability) model.
  - Stability S is the interval at which R = 90%.
  - FSRS-6 has 21 parameters and a forgetting curve R(t,S) = (1 + factor·t/S)^(−w20) with a trainable decay.
  - Stability grows less for difficult items and for already-stable items, and grows **more when R is lower** (a formal version of the spacing effect).
  — [FSRS wiki: The Algorithm](https://github.com/open-spaced-repetition/awesome-fsrs/wiki/The-Algorithm)
- [BENCH] open-spaced-repetition srs-benchmark, setup: 9,999 Anki collections, 349,923,850 evaluated reviews (dataset of about 727 million reviews from 10k users). Metrics: log loss and RMSE(bins) for calibration, AUC for discrimination — [srs-benchmark](https://github.com/open-spaced-repetition/srs-benchmark)
- srs-benchmark results without same-day reviews (log loss / RMSE(bins) / AUC):

  | Model | Log loss | RMSE(bins) | AUC |
  |---|---|---|---|
  | FSRS-7 (34 params) | 0.3401 | 0.0634 | 0.7167 |
  | FSRS-7 with recency weighting | 0.3370 | — | — |
  | FSRS-6 (21 params) | 0.3460 | 0.0653 | 0.7034 |
  | FSRS-5 | 0.3561 | — | — |
  | FSRS-7, default parameters (no per-user fit) | 0.3620 | — | — |
  | DASH | 0.3682 | — | — |
  | AVG (constant baseline) | 0.3945 | — | — |
  | ACT-R | 0.4033 | — | — |
  | HLR | 0.4694 | 0.1275 | 0.6369 |
  | Ebisu v2 | 0.4989 | — | — |

  The best model is RWKV-Instant (log loss 0.2773, AUC 0.8329), but it has 2.76 million parameters, is trained across users rather than per user, and can give "unintuitive predictions" — [srs-benchmark README](https://github.com/open-spaced-repetition/srs-benchmark)
- [BENCH] SM-2 is not in the current README tables. The Expertium benchmark write-up says FSRS-6 with recency weighting has a lower log loss than Anki SM-2 for **99.6% of users**, with the caveat that SM-2 was never designed to output probabilities (an interval-to-probability converter was added) — [Expertium benchmark](https://expertium.github.io/Benchmark.html)
- [DOC] Anki manual on FSRS desired retention:
  - Default 90%, "a good balance of retention and workload"; "Above 90% the workload increases very quickly, and above 97% the workload can be overwhelming"; keep it below 97%.
  - "Compute minimum recommended retention" was removed in Anki 25.07.
  - In the legacy SM-2 section, an example says raising retention from 85% to 90% requires studying about 35% more frequently.
  — [Anki manual, deck options](https://docs.ankiweb.net/deck-options.html)

**Personalized review and fixed exam dates**
- [SIM+IND] Tabibian et al. 2019 (PNAS), MEMORIZE: if the goal is to maximize recall subject to a cost on review frequency, the optimal reviewing schedule "is given by the recall probability itself." A natural experiment on Duolingo data favoured it over heuristic schedules — [Tabibian et al. 2019](https://doi.org/10.1073/pnas.1815156116)
- [FIELD] Lindsey, Shroyer, Pashler & Mozer 2014 (Psychological Science): 179 8th-grade Spanish students, one semester, cumulative exam after the semester. Personalized model-based review gave +16.5% retention vs massed study and +10.0% vs a one-size-fits-all spaced schedule, at equal time — [DOI](https://doi.org/10.1177/0956797613504302); [PDF](https://home.cs.colorado.edu/~mozer/Research/Selected%20Publications/reprints/LindseyShroyerPashlerMozer2014Published.pdf)
- [SIM] Khajah, Lindsey & Mozer 2014 (ACT-R and MCM memory models): with a fixed weekly review budget, optimal schedules clearly beat haphazard ones. Two near-optimal heuristics: (a) review material from μ weeks back; (b) review items whose predicted memory strength is closest to a threshold, the latter recommended for digital tutors — [PubMed](https://pubmed.ncbi.nlm.nih.gov/24482341/)
- [EXP/FIELD] Rawson & Dunlosky 2011: 533 students, more than 100,000 recall responses. Initial criterion (1–4 correct recalls) and later relearning sessions were subadditive; relearning had large effects on retention 1–4 months later at small extra cost. Prescription: **3 correct recalls initially, then relearn 3 times at widely spaced intervals** — [Rawson & Dunlosky 2011](https://doi.org/10.1037/a0023956)
- [FIELD] Rawson, Dunlosky & Sciartelli 2013: successive relearning improved real course-exam performance and long-term retention — [ERIC](https://eric.ed.gov/?id=EJ1036741)

### Inferences
- **Algorithm:** implement FSRS (open source, Rust/JS/Python ports; FSRS-6 or newer) rather than SM-2 or Leitner. With no user data yet, FSRS default parameters already beat a constant baseline and HLR in the benchmark; refit per user once they have enough reviews.
- **Caution on the benchmark:** it is run by the FSRS developers, uses Anki data (mixed content, not specific to Chinese), and its HLR lacks Duolingo's lexeme features. Treat it as strong but not independent evidence. MaiMemo's DHP/SSP-MMC (also by Ye) is the vocabulary-specific peer-reviewed evidence behind FSRS.
- **Desired retention:** use 0.90 by default and allow roughly 0.85–0.92 for long-term maintenance; don't go above about 0.95–0.97.
- **Fixed exam date (inference):**
  1. Front-load the introduction of all ~300 HSK 1 words and 246 characters, so each item gets ≥3 spaced successful retrievals before the exam (Rawson & Dunlosky).
  2. Keep the last inter-review gap at roughly 10–25% of the remaining time (Cepeda); with 6–10 weeks left that means about 5–14 days.
  3. In the last 1–2 weeks, raise target retention or schedule "exam-date-aware" reviews, so each item's predicted retrievability on the exam day (from R(t,S)) is high.
  4. Don't add new items in the final days and don't cram (Kornell 2009).
  5. Prioritizing items whose predicted recall is near a threshold is a validated simulation heuristic (Khajah 2014).
- **Expanding vs uniform:** schedule shape matters little long term. FSRS is naturally expanding, which also keeps in-training success high (Kang 2014), and that probably helps motivation.

### Gaps
- Kim & Webb 2022's numerical effect sizes (overall d, vocabulary vs grammar) could not be retrieved (paywalled; Wiley blocked); only the abstract-level conclusions are reported.
- I found no peer-reviewed independent replication of the srs-benchmark rankings, and no head-to-head RCT of FSRS vs SM-2/HLR measuring learning outcomes (as opposed to prediction accuracy).
- I found no empirical study of the optimal *desired-retention* value for a fixed exam date; the Anki guidance is practitioner documentation.
- Cepeda 2008 used trivia facts, not L2 words or characters; transferring the gap/retention-interval ratios to Chinese vocabulary is an extrapolation.

---

## 3. Interleaving vs blocking: when it helps or hurts (similar characters, tones, confusable grammar)

### Takeaway
Interleaving helps inductive discrimination of categories that are hard to tell apart (overall g = 0.42; paintings g = 0.67). For "words" as material, blocking was better (g = −0.39), and the meta-analysts are "reluctant to recommend" interleaving for grammar rules, foreign languages or words. In L2 research, blocking beat interleaving for learning French pronunciation rules. Interleaving beat blocking for Spanish verb tenses and English grammar structures, but only across multiple sessions or at a 1-week delay. For Chinese, introduce new material in blocks and interleave confusable sets once they have been acquired.

### Cited Findings
- [MA] Brunmair & Richter 2019 (Psychological Bulletin, DOI 10.1037/bul0000209): 59 studies, 238 effect sizes, 158 samples.
  - Overall interleaving effect g = 0.42.
  - By material: paintings g = 0.67 [0.57, 0.77]; naturalistic photos 0.35; mathematical tasks 0.34 [0.11, 0.57]; expository texts n.s.; **words g = −0.39 [−0.64, −0.14]** (blocking better).
  - Interleaving effects are stronger when categories are more similar *between* each other, weaker when items are similar *within* a category, and stronger for more complex material.
  — [Accepted manuscript PDF](https://www.psychologie.uni-wuerzburg.de/fileadmin/06020400/2019/Brunmair_Richter_in_press__2019_META-ANALYSIS_OF_INTERLEAVED_LEARNING.pdf); [DOI](https://doi.org/10.1037/bul0000209)
- Brunmair & Richter's "words" category covered names belonging to conceptual categories, pronunciation rules, and translations in different languages (e.g. Carpenter & Mueller 2013; Hausman & Kornell 2014; Sorensen & Woltz 2016), i.e. inductive category learning rather than standard flashcard pairs. They conclude: "We are reluctant to recommend interleaving for learning materials such as mathematical tasks, expository texts, grammar rules, foreign languages or words… it could even impede learning" — [Brunmair & Richter PDF](https://www.psychologie.uni-wuerzburg.de/fileadmin/06020400/2019/Brunmair_Richter_in_press__2019_META-ANALYSIS_OF_INTERLEAVED_LEARNING.pdf)
- [EXP] Carpenter & Mueller 2013 (Memory & Cognition): English speakers learned French spelling-to-sound rules (e.g. "eau" in *bateau*). **Blocking beat interleaving in all 4 experiments**, both with 4 words per rule and with 15 — [PubMed](https://pubmed.ncbi.nlm.nih.gov/23322358/)
- [EXP] Pan, Tajran, Lovelett, Osuna & Rickard 2019 (Journal of Educational Psychology): adults learning Spanish preterite vs imperfect conjugation. Single-session interleaving gave no advantage (numerically worse or equal at 2 days). Interleaving across 2 weekly sessions gave "substantially better performance" at 1 week, described as the first interleaving effect shown for foreign-language learning — [Pan et al. 2019](https://doi.org/10.1037/edu0000336)
- [EXP] Nakata & Suzuki 2019 (Modern Language Journal): 115 Japanese learners, 5 English grammatical structures, conditions blocking / interleaving / "increasing" (blocked then interleaved). Interleaving produced the most errors during training but was better than blocking on a 1-week delayed grammaticality-judgment test. Learners with lower prior knowledge benefited more — [Nakata & Suzuki 2019](https://doi.org/10.1111/modl.12581)
- [EXP] Kornell & Bjork 2008: interleaving improved learning to recognize artists' styles (induction), yet participants rated massing as more effective even after their own test results showed the opposite — [PubMed](https://pubmed.ncbi.nlm.nih.gov/18578849/)
- [EXP, single study, Chinese] Chang, Tang, Lee & Chen 2022 (Frontiers in Psychology): 66 non-beginning learners of Chinese studied visually similar characters (e.g. 理/埋) presented in similar vs dissimilar pairs. Form+meaning strategies ("Key-images"; "Pithy formulas + key-images") gave higher writing accuracy than a stroke-sequence strategy immediately after learning. The advantage of verbal+visual over visual-only was specific to learners who studied **visually similar pairs**. All strategies were effective for reading — [Chang et al. 2022](https://doi.org/10.3389/fpsyg.2022.783898)

### Inferences
- **New items:** introduce in small coherent blocks (e.g. a theme of 5–10 words, or one rule such as the third-tone sandhi or a pinyin spelling rule). This fits the blocking advantage for words and rules (Brunmair & Richter; Carpenter & Mueller). The SRS will interleave items naturally afterwards.
- **Confusable sets:** after initial acquisition, add deliberate *contrastive* discrimination drills. Examples: 人/入/八, 大/太/犬, 己/已, tone 2 vs tone 3, 的/得, 二/两, 不/没. High between-category similarity is exactly where interleaving pays off (Brunmair & Richter moderator). Show the pair side by side with a form+meaning cue (Chang 2022) and elaborated feedback (see section 5).
- **Grammar patterns:** interleave across days/sessions, not inside the first lesson (Pan 2019; Nakata & Suzuki 2019). Expect more errors during practice, and tell learners this is normal.

### Gaps
- I found no experiment on interleaving vs blocking for Mandarin **tone** learning or for confusable **characters** with adult L2 learners; the search returned only tone-perception and high-variability phonetic-training work.
- Nakata & Suzuki's "increasing" (blocked → interleaved) condition: its exact result relative to pure interleaving was not in the abstract.

---

## 4. Desirable difficulties, generation, pretesting / errorful learning, elaborative interrogation, self-explanation, keyword and character mnemonics, pictures / emoji, multimedia principles

### Takeaway
Making learning effortful but successful (generation, pre-testing followed by feedback, self-explanation) helps, with typical effects of d ≈ 0.40–0.55. Learners consistently misjudge these benefits. The keyword mnemonic is rated "low utility" in general: its benefits are short-lived unless combined with retrieval. For characters, component/radical-based image and verbal mnemonics show promise, but the evidence is small. Pictures do not automatically beat L1 translations, partly because pictures cause overconfidence. Picture + L1 translation beats either alone at immediate tests (g ≈ 0.33–0.35), with the advantage shrinking at delay. Emoji have only short-term recognition evidence. Mayer's multimedia principles (e.g. coherence d = 0.70, modality d = 0.72) argue for relevant, non-decorative visuals.

### Cited Findings
**Desirable difficulties, generation and pretesting**
- [SR] Soderstrom & Bjork 2015 (Perspectives on Psychological Science): performance during acquisition is an unreliable guide to long-term learning; people often mistake current performance for learning — [Soderstrom & Bjork 2015](https://doi.org/10.1177/1745691615569000)
- [SR] Dunlosky, Rawson, Marsh, Nathan & Willingham 2013 (PSPI 14(1):4–58) rated 10 techniques:
  - **high** utility: practice testing, distributed practice;
  - **moderate**: elaborative interrogation, self-explanation, interleaved practice (evidence "limited", e.g. not adequately evaluated in educational contexts);
  - **low**: summarization, highlighting, the **keyword mnemonic**, imagery use for text learning, rereading. The keyword mnemonic "is difficult to implement in some contexts, and it appears to benefit students for a limited number of materials and for short retention intervals."
  — [PubMed](https://pubmed.ncbi.nlm.nih.gov/26173288/); [DOI](https://doi.org/10.1177/1529100612453266)
- [MA] Bertsch, Pesta, Wiscott & McDaniel 2007 (Memory & Cognition): 445 effect sizes in 86 studies. Generating beats reading by d = 0.40. The effect is larger in older adults, within-subject designs and incidental learning — [PubMed](https://pubmed.ncbi.nlm.nih.gov/17645161/); [DOI](https://doi.org/10.3758/BF03193441)
- [SR] Pan & Carpenter 2023 (Educational Psychology Review): prequestioning/pretesting improves learning across many materials *if the correct answers are studied afterwards*, despite many errors on the pretest. The size of the benefit varies with procedure and with how learning is assessed — [Pan & Carpenter 2023](https://doi.org/10.1007/s10648-023-09814-5); [OA PDF](https://link.springer.com/content/pdf/10.1007/s10648-023-09814-5.pdf)
- [EXP] Kornell, Hays & Bjork 2009: unsuccessful retrieval attempts (questions guaranteed to be failed) still enhanced later learning of the answer vs reading the question and answer together — [Kornell et al. 2009](https://doi.org/10.1037/a0015729)
- [EXP] Potts & Shanks 2014 (JEP: General): for unfamiliar English words and **foreign vocabulary translations**, generating (mostly wrong) answers followed by corrective feedback beat reading and beat picking a wrong option from a choice. Participants judged errorful generation *less* effective — [Potts & Shanks](https://doi.org/10.1037/a0033194); [OA PDF](https://discovery.ucl.ac.uk/1399515/1/RPottsLastRevision.pdf)
- [SR] Metcalfe 2017 (Annual Review of Psychology): errorful learning followed by corrective feedback is beneficial, especially when learners strongly believed their error was correct (the hypercorrection effect) — [Metcalfe 2017](https://doi.org/10.1146/annurev-psych-010416-044022)
- In classrooms, pre-class quizzes give smaller benefits than post-class quizzes (g = 0.186 vs 0.536) — [Yang et al. 2021 PDF](https://gwern.net/doc/spaced-repetition/2021-yang.pdf)

**Self-explanation**
- [MA] Bisra, Liu, Nesbit, Salimi & Winne 2018: 69 effect sizes from 64 reports. Self-explanation prompts g = 0.55 across tasks (problem solving, worked examples, texts). The authors suggest computer-generated prompts — [ERIC](https://eric.ed.gov/?id=EJ1186664); [DOI](https://doi.org/10.1007/s10648-018-9434-x)

**Keyword and character mnemonics**
- [EXP] Wang & Thomas 1995, "Effects of keyword on long-term retention: Help or hindrance?" — [DOI](https://doi.org/10.1037/0022-0663.87.3.468). Related work by Wang, Thomas & Ouellette found long-term forgetting greater after keyword instruction than after rote rehearsal *(secondary, from the record's description)* — [UCF STARS record](https://stars.library.ucf.edu/facultybib1990/601)
- [EXP] Miyatsu & McDaniel 2019: keyword encoding followed by retrieval practice was better than keyword alone at 1 week; retrieval alone, limited to 2 rounds, gave no testing effect — [PubMed](https://pubmed.ncbi.nlm.nih.gov/31077068/)
- [EXP, single preliminary study, children] Lee & Tse 2026 (Reading and Writing): 95 non-Chinese-speaking 5–8-year-olds in Hong Kong learned 21 characters. A "radical-with-dual-coding" approach (simple pictographs + concise English prompts) gave the highest immediate performance: significantly better than copying (stroke order), not significantly different from phonological instruction. Its advantage over the average of the other two approaches persisted about 9.5 days later, with similar forgetting rates — [Lee & Tse 2026](https://doi.org/10.1007/s11145-026-10851-z)
- [EXP, CSL adults] Chang et al. 2022: form+meaning mnemonics ("key-images", "pithy formulas") outperformed stroke-sequence practice for writing similar characters — [Chang et al. 2022](https://doi.org/10.3389/fpsyg.2022.783898)

**Pictures, glosses and emoji**
- [EXP] Carpenter & Olson 2012 (JEP: LMC): Swahili words were **not** learned better from pictures than from English translations in 3 experiments. Learners were *more overconfident* with pictures and found picture pairs easier to process. When overconfidence was removed through retrieval practice or explicit warnings, pictures did beat translations — [Carpenter & Olson](https://doi.org/10.1037/a0024828)
- [MA] Zhang, Sala & Gobet 2025 (Educational Research Review): 2,056 participants in total.
  - Comparisons: L1 vs picture (20 studies, 51 effect sizes); L1 vs L1+picture (21 studies, 55); picture vs L1+picture (9 studies, 27).
  - Immediate tests: L1+picture > L1 only (g = 0.334) and > picture only (g = 0.350).
  - Delayed tests: L1+picture vs picture only g = 0.271 (p = .067, marginal); no difference between L1 only and picture only. No significant moderators.
  — [LSE Research Online](https://researchonline.lse.ac.uk/id/eprint/127744); [DOI](https://doi.org/10.1016/j.edurev.2025.100681)
- [MA] Ramezanali, Uchihara & Faez 2020 (TESOL Quarterly): 22 studies. Adding one more gloss mode gave g = 0.46 immediate and g = 0.28 delayed. Adding a mode to a single *textual* gloss helps; adding a third mode to a dual gloss does not — [Ramezanali et al. 2020](https://doi.org/10.1002/tesq.579)
- [second-order MA] Mahdi, Mohsen & Almanea 2024 (Acta Psychologica): 7 meta-analyses, 136 primary studies. Overall gloss effect g = 0.63 (fixed) / 0.76 (random). Beginners benefited most. They report single-mode glosses as *more* effective than multi-mode, which conflicts with Ramezanali 2020 and Zhang 2025 — [Mahdi et al. 2024](https://doi.org/10.1016/j.actpsy.2024.104341)
- [EXP, single small study, Chinese] Li & Zhong 2025 (Frontiers in Psychology): 30 English-speaking learners of Chinese, semantic matching task. Emoji–Chinese pairs gave faster and more accurate responses than English–Chinese pairs when meanings matched; the advantage shrank in mismatch trials. The authors note this shows easier *matching*, not long-term acquisition, and call for delayed retention tests — [PMC full text](https://pmc.ncbi.nlm.nih.gov/articles/PMC12605125/); [DOI](https://doi.org/10.3389/fpsyg.2025.1629078)

**Multimedia principles**
- [SR] Mayer 2017 (Journal of Computer Assisted Learning), median effect sizes:
  - multimedia principle (words + graphics > words alone) d = 1.67, based on only 5 comparisons;
  - coherence d = 0.70, signalling 0.46, redundancy 0.87, spatial contiguity 0.79, temporal contiguity 1.30;
  - segmenting 0.70, pre-training 0.46, modality 0.72;
  - personalization 0.79, voice 0.74, embodiment 0.36;
  - some principles are stronger for low-knowledge learners.
  — [ERIC](https://eric.ed.gov/?id=EJ1153516); [DOI](https://doi.org/10.1111/jcal.12197)
- [SR] Mayer 2024 (Educational Psychology Review) restates the theory (dual channels, limited capacity, active processing) and lists 15 evidence-based design principles — [ERIC](https://eric.ed.gov/?id=EJ1407410); [DOI](https://doi.org/10.1007/s10648-023-09842-1)
- [SR] Earlier handbook figures *(secondary, chapter abstract)*: coherence 23/23 tests, median d = 0.86; signalling 24/28, d = 0.41; redundancy 16/16, d = 0.86 — [Mayer & Fiorella chapter, Cambridge Handbook of Multimedia Learning](https://www.cambridge.org/core/books/abs/cambridge-handbook-of-multimedia-learning/principles-for-reducing-extraneous-processing-in-multimedia-learning-coherence-signaling-redundancy-spatial-contiguity-and-temporal-contiguity-principles/C98AB3A6CE760DD63C048936EA0B3B44)
- [MA] Sundararajan & Adesope 2020: interesting but irrelevant "seductive details" hinder learning; moderated by image type, delivery format, pacing and other factors — [ERIC](https://eric.ed.gov/?id=EJ1263249); [DOI](https://doi.org/10.1007/s10648-020-09522-4). Overall g = −0.33 *(secondary)* — [WSU news](https://news.wsu.edu/press-release/2020/03/19/seductive-details-inhibit-learning); [ACU summary](https://inspire.acu.edu.au/articles/seductive-details)

### Inferences
- **Emoji:** use an emoji as a meaning cue *together with* the Italian gloss, not instead of it. Picture+L1 beats either alone at least at immediate test (Zhang 2025). Every exposure must end in a retrieval attempt, because pictures cause overconfidence and retrieval removes it (Carpenter & Olson).
- Keep emoji strictly relevant to the meaning. Decorative emoji and animations count as seductive details (coherence principle); any emoji-only card (no gloss) is an untested design.
- For abstract HSK 1 words (e.g. 的, 了, 很, 是, 吗) emoji are likely weak cues. This is an inference: I found no data.
- **Character mnemonics:** for each character, give a component/radical-based "key image" plus a short verbal formula. This is most worthwhile for visually similar pairs (Chang 2022). Always follow it with spaced retrieval (Miyatsu & McDaniel), since mnemonics alone fade (Dunlosky).
- **Errorful generation:** for new items, let the learner guess first (e.g. meaning from the radicals, or the tone) before revealing the answer with feedback (Potts & Shanks; Kornell 2009). Tell learners that being wrong first is beneficial.
- **Grammar explanations:** use brief self-explanation prompts (g = 0.55), e.g. "why 了 here?" with tap-to-choose options. Follow Mayer's principles: narration rather than on-screen text for explanations (modality), short segments, highlighted key components (signalling), pre-training of radical names, nothing extraneous.

### Gaps
- I found no meta-analysis of the keyword method for L2. The one hit (Aydoğdu & Zengin 2023, conference) is not informative.
- I found no study of emoji-based vocabulary learning with delayed retention, and no study on adults learning Chinese characters with mnemonics + SRS at scale.
- The overall effect size for seductive details was not verified in the primary text.

---

## 5. Feedback: immediate vs delayed, elaborated vs correct-answer

### Takeaway
Feedback is important: d = 0.48 overall, with high-information feedback d = 0.99. In computer-based environments, elaborated feedback (explanations) beats showing the correct answer (0.49 vs 0.32), which beats right/wrong only (0.05). Correct-answer feedback after errors is the essential minimum; one study found +494% retention. Timing evidence is mixed. Lab list-learning tends to favour delay, applied/classroom settings favour immediate feedback, and for adults the delayed advantage disappeared when lag to test was controlled. For an app, the sensible default is immediate feedback plus a delayed re-exposure of missed items.

### Cited Findings
- [MA] Wisniewski, Zierer & Hattie 2020 (Frontiers in Psychology):
  - 435 studies, k = 994, N > 61,000; d = 0.48 (0.55 before outlier removal); I² = 83.4%.
  - By information content: reinforcement/punishment d = 0.24 (k = 39); corrective feedback d = 0.46 (k = 238); **high-information feedback d = 0.99** (k = 42).
  - By outcome: cognitive 0.51; motivational 0.33.
  - Egger's test shows funnel asymmetry in journal articles. Timing was not analysed because prior results were inconsistent.
  — [Frontiers full text](https://www.frontiersin.org/journals/psychology/articles/10.3389/fpsyg.2019.03087/full); [DOI](https://doi.org/10.3389/fpsyg.2019.03087)
- [MA] Van der Kleij, Feskens & Eggen 2015 (Review of Educational Research):
  - 40 studies, 70 effect sizes on item-based feedback in **computer-based** learning.
  - Elaborated feedback (EF) 0.49 > knowledge of correct response (KCR) 0.32 > knowledge of result (KR) 0.05. EF was especially better for higher-order outcomes.
  - Effects were larger in mathematics than in languages, and smaller with delayed feedback.
  - Immediate feedback looked better for lower-order learning and delayed for higher-order, but the interaction was not significant.
  — [ERIC](https://eric.ed.gov/?id=EJ1081708); [DOI](https://doi.org/10.3102/0034654314564881)
- [MA] Kulik & Kulik 1988 (Review of Educational Research), 53 studies:
  - applied studies with real classroom quizzes found **immediate** feedback more effective;
  - experiments on acquisition of the test content itself showed the opposite;
  - lab list-learning results varied.
  — [ERIC](https://eric.ed.gov/?id=EJ375720); [DOI](https://doi.org/10.3102/00346543058001079)
- [MA] Rowland 2014, within studies that gave feedback: delayed g = 1.38 (k = 6) vs immediate g = 0.66 (k = 46), "to be considered with caution" — [Rowland 2014 PDF](https://courseware.epfl.ch/assets/courseware/v1/fdde2f0aa590bf3b1324077a6bf1540c/asset-v1%3AEPFL%2BDEMO%2B2020%2Btype%40asset%2Bblock/Rowland2014-meta-analysis.pdf)
- [EXP] Metcalfe, Kornell & Finn 2009 (vocabulary): for 6th-graders, delayed feedback beat immediate, which beat none, whether or not lag to test was controlled. For **college students** (GRE words), delayed beat immediate only when lag to test was uncontrolled; with lag controlled there was **no difference** — [PubMed](https://pubmed.ncbi.nlm.nih.gov/19933453/)
- [FIELD] Mullet, Butler, Verdin, von Borries & Marsh 2014: in an engineering course, feedback delayed by 1 week improved transfer on later exams, yet students reported they benefited most from immediate feedback — [Mullet et al. 2014](https://doi.org/10.1016/j.jarmac.2014.05.001)
- [EXP] Pashler et al. 2005: feedback after errors increased 1-week retention by 494%; after correct answers it made little difference — [PubMed](https://pubmed.ncbi.nlm.nih.gov/15641900/)
- [EXP] Butler, Karpicke & Roediger 2008: feedback doubled retention of low-confidence correct responses — [Butler et al. 2008](https://doi.org/10.1037/0278-7393.34.4.918)
- [SR] Metcalfe 2017: corrective feedback is most powerful for errors made with high confidence (hypercorrection) — [Metcalfe 2017](https://doi.org/10.1146/annurev-psych-010416-044022)
- In testing-effect meta-analyses, Rowland found feedback nearly doubled the effect (0.73 vs 0.39), Adesope found no moderation (0.63 vs 0.60), and Yang found 0.537 vs 0.374 — [Yang et al. 2021 PDF](https://gwern.net/doc/spaced-repetition/2021-yang.pdf)

### Inferences
- **Never give right/wrong-only feedback** (KR ≈ 0.05); always show the correct answer, with audio and tone marks.
- For confusable characters, tones and grammar, add one line of elaboration, e.g. "入 ≠ 人: the left stroke is shorter / it means enter," or "了 here marks completion." This is where EF beats KCR.
- Give **immediate** feedback by default: adult lab data show no cost when lag is controlled, and applied and computer-based data favour immediate feedback.
- Add a delayed second exposure of missed items, either at the end of the session or the next day. This captures the possible benefit of delay and spacing (Rowland k = 6; Mullet).
- Use the learner's confidence or the time they took to answer to spot correct-but-uncertain answers, and give these extra feedback or bring them back sooner (Butler 2008). Pashler 2005 found little benefit of feedback for correct answers, so this is optional.

### Gaps
- Most feedback-timing studies are not L2 vocabulary on a mobile phone.
- Van der Kleij found smaller effects for language subjects but gave no language-specific breakdown in the abstract.
- I found no study on the optimal amount of elaboration for character or tone errors.

---

## 6. Metacognition: judgments of learning, illusions of competence, showing calibrated progress, mastery learning

### Takeaway
Learners systematically misjudge what works:
- they prefer massing, pictures, rereading and immediate feedback;
- they underrate spacing, interleaving and errorful generation;
- their predictions can be uncorrelated with real recall.

Judgments made after a delay are far more accurate (g = 0.93), and warnings or retrieval practice reduce overconfidence. Mastery-learning programs raise achievement (ES = 0.52 *(secondary)*). Dashboards rarely support metacognition unless grounded in learning theory. So the app should base progress displays on model-predicted retention, not on felt fluency.

### Cited Findings
**Illusions of competence**
- [EXP] Karpicke & Roediger 2008: students' predictions of their performance were uncorrelated with actual performance — [Karpicke & Roediger 2008](https://doi.org/10.1126/science.1152408)
- [EXP] Kornell 2009: spacing was more effective for 90% of participants, but 72% believed massing was better — [Kornell 2009](https://doi.org/10.1002/acp.1537)
- [EXP] Kornell & Bjork 2008: participants rated massing as more effective even after their own test showed the opposite — [PubMed](https://pubmed.ncbi.nlm.nih.gov/18578849/)
- [EXP] Carpenter & Olson 2012: overconfidence with picture cues; retrieval practice or explicit warnings removed it — [Carpenter & Olson](https://doi.org/10.1037/a0024828)
- [EXP] Rhodes & Castel 2008: larger font size raised judgments of learning without affecting recall. The illusion persisted across study–test cycles and despite explicit warnings, and disappeared when large fonts were made less fluent — [Rhodes & Castel 2008](https://doi.org/10.1037/a0013684)
- [EXP] Potts & Shanks 2014: learners judged errorful generation less effective than reading, although it was better — [Potts & Shanks](https://doi.org/10.1037/a0033194)
- [EXP, conference/repository record] Learners are generally unaware of the pretesting benefit, but awareness improves with self-regulation support — [TCU repository record](https://repository.tcu.edu/handle/116099117/61277)
- [FIELD] Mullet et al. 2014: students preferred immediate feedback although delayed feedback produced better transfer — [Mullet et al. 2014](https://doi.org/10.1016/j.jarmac.2014.05.001)
- Survey data cited by Yang et al.: in Kornell & Bjork 2007, 68% of students self-test to check how well they know the material, and only 18% because testing itself improves learning — [Yang et al. 2021 PDF](https://gwern.net/doc/spaced-repetition/2021-yang.pdf)

**Judgments of learning**
- [MA] Rhodes & Tauber 2011 (Psychological Bulletin):
  - delayed vs immediate JOLs: 112 effect sizes, 4,554 participants; delaying gives much better relative accuracy (g = 0.93);
  - effect on memory itself: 98 effect sizes, 3,807 participants; small benefit (g = 0.08).
  — [PubMed](https://pubmed.ncbi.nlm.nih.gov/21219059/)
- [MA] Double, Birney & Walker 2018 (Memory): making JOLs had no overall effect on memory (g = 0.054, n.s.). Positive reactivity appeared for related word pairs (g = 0.323) and word lists (g = 0.384), none for unrelated pairs — [Double et al.](https://doi.org/10.1080/09658211.2017.1404111)
- [SR] Soderstrom & Bjork 2015: performance during learning is a poor index of long-term learning — [Soderstrom & Bjork](https://doi.org/10.1177/1745691615569000)

**Dashboards and mastery**
- [SR] Matcha, Uzir, Gašević & Pardo 2020 (IEEE Transactions on Learning Technologies): existing learning-analytics dashboards are "rarely grounded in learning theory, cannot be suggested to support metacognition, do not offer any information about effective learning tactics," and their evaluations have significant limitations — [ERIC](https://eric.ed.gov/?id=EJ1279917)
- [MA] Kulik, Kulik & Bangert-Drowns 1990 (Review of Educational Research): 108 controlled evaluations; mastery-learning programs improve exam performance — [ERIC](https://eric.ed.gov/?id=EJ415887); [DOI](https://doi.org/10.3102/00346543060002265). Average ES = 0.52; stronger for weaker students; may increase time on task; group-based > self-paced *(secondary)* — [academia.edu copy](https://www.academia.edu/81783373/Effectiveness_of_Mastery_Learning_Programs_A_Meta_Analysis)
- [EXP/FIELD] Rawson & Dunlosky 2011 give a concrete mastery criterion: 3 correct recalls initially, then relearn 3 times widely spaced — [Rawson & Dunlosky 2011](https://doi.org/10.1037/a0023956)

### Inferences
- **Progress indicators** should be model-based, e.g. "% of HSK 1 words/characters with predicted recall ≥ 90% on your exam date," computed from FSRS retrievability. Avoid "words seen," and do not rely on streaks alone. Note that the 90% target is an inference, not a tested threshold.
- Define "learned / mastered" as successful recall in at least 2–3 separate sessions, or FSRS stability above a threshold, never as a single correct answer.
- Do not let self-grading ("I knew it") be the only signal. Mix in objective checks (typed pinyin/tone, MC with distractors, audio recognition). Optionally ask a quick confidence rating before revealing the answer, then use the gap between confidence and accuracy to give calibration feedback.
- Explain desirable difficulties briefly inside the app ("errors and effortful recall mean you're learning"). Warnings and support improved calibration in Carpenter & Olson and in the pretesting study.

### Gaps
- I found no controlled study of the effect of "calibrated progress displays" or exam-readiness predictions on learning or adherence in language apps.
- The mastery-learning effect size (0.52) comes from a secondary summary, and the studies are mostly 1970s–80s classroom programs.

---

## 7. Practical parameters: session length, daily practice, sleep and consolidation, overlearning, new items per day

### Takeaway
The strongest practical levers are distributing practice over many days and adding more sessions; classroom effects grow roughly linearly with duration. Repeated same-day drilling (overlearning) gives little long-term return. Sleep between learning and relearning consolidates memory (g = 0.44, about 0.28 after bias correction). In one study, sleeping between two sessions halved the relearning needed. No good evidence fixes an optimal session length or number of new items per day. Practitioner heuristics (about 10 reviews/day for each new card/day introduced at steady state) and the exam horizon should set these.

### Cited Findings
**Overlearning and same-day repetition**
- [EXP] Rohrer, Taylor, Pashler, Wixted & Cepeda 2005: 218 students learning geography facts or word definitions. Overlearners recalled far more at 1 week, but the difference "decreased dramatically thereafter" (tests up to 9 weeks), so within-session overlearning is "an inefficient strategy" — [DOI](https://doi.org/10.1002/acp.1083); [OA PDF](https://escholarship.org/content/qt0279q9m1/qt0279q9m1.pdf)
- [EXP] Nakata 2017: more within-session retrievals help (5–7 > 1–3), but per minute one retrieval is most efficient — [Nakata 2017](https://doi.org/10.1017/S0272263116000280)
- [DOC] Anki manual: "(Re)learning steps of 1 day or greater are not recommended when using FSRS"; keep learning steps few, because "repeating a card multiple times in a single day does not significantly contribute to long-term memory" (practitioner claim) — [Anki manual](https://docs.ankiweb.net/deck-options.html)

**Daily load and new items**
- [DOC] Anki manual: "If you are consistently learning 20 new cards a day, you can expect your daily reviews to be roughly about 200 cards/day" — [Anki manual](https://docs.ankiweb.net/deck-options.html)
- [MA] Yang 2021: test benefits rise from a single class (g = 0.385) to more than a semester (0.624); more test repetitions give larger effects — [Yang et al. 2021 PDF](https://gwern.net/doc/spaced-repetition/2021-yang.pdf)
- [EXP] Bahrick et al. 1993: number of relearning sessions and spacing each improved multi-year retention of foreign vocabulary — [Bahrick et al. 1993](https://doi.org/10.1111/j.1467-9280.1993.tb00571.x)
- [EXP] Kornell 2009 and Nakata & Webb 2016: within a session, a larger interleaved stack (more spacing between repetitions) beats small stacks, and set size matters little once spacing is equated — [Kornell 2009](https://doi.org/10.1002/acp.1537); [Nakata & Webb 2016](https://doi.org/10.1017/S0272263115000236)
- [EXP, single study] Chukharev-Hudilainen & Klepikova 2016 (CALICO Journal): EFL students spending on average about **3 minutes a day** on automatically generated spaced-repetition activities tripled their long-term vocabulary retention rate (double-blind design) — [ERIC](https://eric.ed.gov/?id=EJ1143520)
- [IND] In the Duolingo practice logs the mean recall rate was p̄ = 0.859 — [Settles & Meeder 2016 PDF](https://aclanthology.org/P16-1174.pdf)

**Sleep**
- [MA] Berres & Erdfelder 2021 (Psychological Bulletin): 823 effect sizes, 271 samples, 177 articles (1967–2019). Sleep vs wake benefit for episodic memory g = 0.44, reduced to g = 0.28 after correcting for selective reporting. The benefit is larger when material is studied multiple times, and for words largest in free recall, then cued recall, then recognition — [DOI](https://doi.org/10.1037/bul0000350); [preprint](https://psyarxiv.com/r2an6)
- [EXP] Gais, Lucas & Born 2006: high-school students' vocabulary retention improved when sleep followed within a few hours of learning; sleep deprivation hurt memory — [Gais et al. 2006](https://doi.org/10.1101/lm.132106)
- [EXP, single small study] Mazza et al. 2016 (Psychological Science): 40 participants learned foreign vocabulary to perfect performance in two sessions 12 h apart. With sleep between the sessions, relearning took about **half** the practice, and retention was better at 1 week and at 6 months — [Mazza et al. 2016](https://doi.org/10.1177/0956797616659930)
- [EXP] Schimke et al. 2023: 74 young adults showed no sleep benefit for learning word meanings from reading context, so not every form of word learning benefits — [Schimke et al. 2023](https://doi.org/10.1177/17470218231179459)

**Technology-assisted vocabulary learning**
- [MA] Hao, Wang & Ardasheva 2021: 45 studies, 2,374 EFL learners; technology-assisted vocabulary learning vs traditional instruction g = 0.845. Device type, game condition, setting and test format moderated the effect — [ERIC](https://eric.ed.gov/?id=EJ1310397)
- [MA] Yu & Trainin 2021 (ReCALL): 34 studies, 2,511 participants, d = 0.64 — [ERIC](https://eric.ed.gov/?id=EJ1333441)
- Other meta-analyses of mobile-assisted vocabulary learning — [Lin & Lin 2019 (CALL)](https://eric.ed.gov/?id=EJ1235365); [Mahdi 2018 (JECR), 16 studies, 986 participants](https://eric.ed.gov/?id=EJ1168914)

### Inferences
- **Daily, short sessions:**
  - Aim for 10–20 minutes, possibly split into 2 micro-sessions. The evidence is indirect (Yang dose–response; the 3 min/day study; Bahrick); I found no RCT on minutes per session.
  - Put reviews due today before new items, and cap reviews so a session stays short.
- **New items per day, worked example:** with ~300 words + 246 characters (many shared) and an exam 8–12 weeks away, about 8–12 new words/day for the first 4–6 weeks puts all items in the queue early. That leaves 3–6 weeks of spaced consolidation and keeps steady-state reviews around 80–120/day by the Anki ratio of about 10:1. This is an inference from practitioner heuristics; set the cap adaptively from the FSRS simulator's projected workload.
- **Sleep-aware scheduling:** introduce new items so the first relearning comes after a night's sleep (the next morning or day). An optional evening "learn" and morning "relearn" pattern follows Mazza 2016, but that is a single study.
- **Same-day repetition:** use 1–2 short learning steps (minutes), then move to a one-day interval. Avoid long same-day drilling; spread the repetitions out instead.

### Gaps
- I found no experimental evidence on optimal session length, ideal number of new items per day, or notification and streak mechanics for L2 apps. These are practitioner heuristics.
- The overlearning meta-analysis (Driskell, Willis & Copper 1992, [DOI](https://doi.org/10.1037/0021-9010.77.5.615)) was identified, but its effect sizes could not be verified.
- The sleep–vocabulary evidence for adults learning Chinese characters or tones is extrapolated. The direct L2 studies are small (Mazza n = 40) or involve adolescents (Gais).
