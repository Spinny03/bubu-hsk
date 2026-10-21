import SwiftUI
import SwiftData

struct RootView: View {
    let content: Curriculum
    @State private var selected = 0
    var body: some View {
        TabView(selection: $selected) {
            NavigationStack { HomeView(content: content) }.tabItem { Label("Livelli", systemImage: "square.stack.3d.up") }.tag(0)
            NavigationStack { ReviewLanding(content: content) }.tabItem { Label("Ripasso", systemImage: "arrow.triangle.2.circlepath") }.tag(1)
            NavigationStack { PlanView(content: content) }.tabItem { Label("Il mio piano", systemImage: "calendar") }.tag(2)
        }
    }
}
enum Coverage {
    /// Una parola è coperta quando significato, ascolto e pinyin hanno almeno due successi distanziati e l'ultima risposta è corretta.
    static func verifiedWords(_ content: Curriculum, cards: [StudyCard]) -> Set<Int> {
        let done = Set(cards.filter { ["meaning", "audio", "pinyin"].contains($0.kind) && $0.successes >= 2 && $0.lastCorrect }.map { "\($0.kind):\($0.contentID)" })
        return Set(content.words.filter { word in ["meaning", "audio", "pinyin"].allSatisfy { done.contains("\($0):\(word.id)") } }.map(\.id))
    }
}
struct HomeView: View {
    let content: Curriculum
    @Query private var cards: [StudyCard]
    @AppStorage("placementDone") private var placementDone = false
    /// Miglior serie della Sfida su tutti i livelli e modi.
    var bestGame: Int { GameEngine.levels.flatMap { level in GameMode.allCases.map { UserDefaults.standard.integer(forKey: GameEngine.bestKey(level: level, mode: $0)) } }.max() ?? 0 }
    private let nextLevels: [(name: String, words: Int)] = [("2", 500), ("3", 1000), ("4", 2000), ("5", 3600), ("6", 5400), ("7–9", 11000)]
    var body: some View {
        Page(spacing: 24) {
            HStack(spacing: 12) {
                SealMark(size: 46)
                VStack(alignment: .leading, spacing: 0) {
                    Text("Bùbù").font(.system(.title, design: .serif).weight(.bold))
                    Text("Il cinese, un passo alla volta.").font(.subheadline).foregroundStyle(Palette.inkSoft)
                }
            }
            .padding(.top, 12).accessibilityElement(children: .combine).accessibilityAddTraits(.isHeader)
            TodayCard(content: content, cards: cards, buttonID: "home-start-review")
            if !placementDone {
                NavigationLink { ExamLandingView(content: content, initialMode: .placement) } label: {
                    RowGroup { ActionRow(title: "Sai già un po’ di cinese?", detail: "Ascolto e lettura · 10–15\u{00A0}min", icon: "location.magnifyingglass") }
                }.buttonStyle(.plain).accessibilityIdentifier("placement")
            }
            NavigationLink { GameView() } label: {
                RowGroup { ActionRow(title: "Sfida", detail: "Un carattere, quattro risposte: serie senza fine", icon: "bolt.fill", trailing: bestGame > 0 ? "Record \(bestGame)" : nil) }
            }.buttonStyle(.plain).accessibilityIdentifier("game")
            VStack(alignment: .leading, spacing: 10) {
                SectionTitle(title: "Il tuo livello", detail: "Programma 2025")
                NavigationLink { LevelView(content: content) } label: { currentLevel }
                    .buttonStyle(.plain).accessibilityIdentifier("level-1")
            }
            VStack(alignment: .leading, spacing: 10) {
                SectionTitle(title: "Livelli successivi", detail: "Parole cumulative")
                RowGroup {
                    ForEach(Array(nextLevels.enumerated()), id: \.offset) { i, level in
                        if i > 0 { RowDivider(inset: 16) }
                        NavigationLink { FutureLevelView(level: level.name, count: level.words) } label: {
                            HStack(spacing: 12) {
                                Text("HSK \(level.name)").font(.body.weight(.medium))
                                Spacer()
                                Text("\(level.words)").font(.subheadline).monospacedDigit().foregroundStyle(Palette.inkSoft)
                                Image(systemName: "lock.fill").font(.footnote).foregroundStyle(Palette.inkSoft)
                            }
                            .padding(.horizontal, 16).frame(minHeight: 50).contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("HSK \(level.name), \(level.words) parole cumulative, non ancora disponibile")
                        .accessibilityIdentifier("level-\(i+2)")
                    }
                }
            }
        }
        .overlay(alignment: .top) {
            // Senza barra di navigazione, una sfumatura carta separa il contenuto dalla barra di stato.
            Color.clear.frame(height: 12)
                .background(alignment: .bottom) {
                    LinearGradient(stops: [.init(color: Palette.paper, location: 0), .init(color: Palette.paper, location: 0.7), .init(color: Palette.paper.opacity(0), location: 1)], startPoint: .top, endPoint: .bottom)
                        .frame(height: 90)
                }
                .allowsHitTesting(false).accessibilityHidden(true)
        }
        .toolbar(.hidden, for: .navigationBar)
    }
    var currentLevel: some View {
        let verified = Coverage.verifiedWords(content, cards: cards).count
        return VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .firstTextBaseline, spacing: 10) {
                Text("HSK 1").font(.system(.title2, design: .serif).weight(.bold))
                Text("一级 yī jí").font(.subheadline).foregroundStyle(Palette.inkSoft)
                Spacer()
                Image(systemName: "chevron.right").font(.footnote.weight(.semibold)).foregroundStyle(Palette.inkSoft)
            }
            Text("15 unità · 300 parole · 70 righe di grammatica").font(.subheadline)
            VStack(alignment: .leading, spacing: 6) {
                Meter(value: Double(verified) / 300)
                Text("\(verified)/300 parole verificate").font(.footnote).monospacedDigit().foregroundStyle(Palette.inkSoft)
            }
        }
        .padding(18).frame(maxWidth: .infinity, alignment: .leading)
        .background(Palette.surface, in: RoundedRectangle(cornerRadius: Metrics.radius, style: .continuous))
        .contentShape(Rectangle())
    }
}
/// Scheda del ripasso di oggi: l'unica superficie scura dell'app, perché è l'azione quotidiana.
struct TodayCard: View {
    let content: Curriculum
    let cards: [StudyCard]
    let buttonID: String
    var due: Int { cards.filter { $0.due <= .now }.count }
    var headline: String {
        if due == 1 { return "1 carta pronta" }
        if due > 1 { return "\(due) carte pronte" }
        return cards.isEmpty ? "Comincia da qui" : "Sei in pari"
    }
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Ripasso di oggi").font(.subheadline.weight(.semibold)).foregroundStyle(Palette.paper.opacity(0.75))
                Text(headline).font(.system(.title, design: .serif).weight(.bold))
                Text(due == 0 ? "Nessuna carta in scadenza: puoi iniziare parole nuove." : "Parole, ascolto, pinyin, caratteri e grammatica in un solo ripasso.")
                    .font(.subheadline).foregroundStyle(Palette.paper.opacity(0.8))
            }
            NavigationLink { StudySessionView(content: content, initialQueue: StudyEngine.queue(cards: cards, words: content.words)) } label: {
                Label(due == 0 ? "Inizia a studiare" : "Inizia il ripasso", systemImage: "play.fill")
            }
            .buttonStyle(InverseButtonStyle()).accessibilityIdentifier(buttonID)
        }
        .foregroundStyle(Palette.paper).padding(20).frame(maxWidth: .infinity, alignment: .leading)
        .background(Palette.ink, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
}
struct LevelView: View {
    let content: Curriculum
    @Query private var cards: [StudyCard]
    @Query private var events: [StudyEvent]
    @Environment(\.dynamicTypeSize) private var typeSize
    var passedUnits: Set<String> { Set(events.filter { $0.mode == "unit-assessment" && $0.correct }.map(\.key)) }
    var body: some View {
        let nextUnit = content.units.first { !passedUnits.contains("unit-\($0.id)") }
        Page(spacing: 24) {
            ScreenHeader(eyebrow: "一级 yī jí · Programma 2025", title: "Le basi per capire e farti capire",
                         subtitle: "15 unità · 300 parole · esame di 40 domande, circa 40 minuti")
            VStack(alignment: .leading, spacing: 10) {
                SectionTitle(title: "Copertura del programma")
                Panel(spacing: 14) {
                    LazyVGrid(columns: typeSize.isAccessibilitySize ? [GridItem(.flexible())] : [GridItem(.flexible(), spacing: 18), GridItem(.flexible())], alignment: .leading, spacing: 16) {
                        stat(Coverage.verifiedWords(content, cards: cards).count, of: 300, "parole verificate")
                        stat(cards.filter { $0.kind == "character" && $0.successes >= 2 && $0.lastCorrect }.count, of: 246, "caratteri verificati")
                        stat(cards.filter { $0.kind == "grammar" && $0.successes >= 2 && $0.lastCorrect }.count, of: 70, "righe di grammatica")
                        stat(passedUnits.count, of: 15, "unità con mini\u{2011}test superato")
                    }
                    Text("Le verifiche contano. Aprire una lezione non basta.").font(.footnote).foregroundStyle(Palette.inkSoft)
                }
            }
            ReadinessView()
            RowGroup {
                NavigationLink { UnitsView(content: content) } label: {
                    ActionRow(title: "Il percorso", detail: nextUnit.map { "15 unità · prossima: \($0.title)" } ?? "15 unità · tutti i mini-test superati", icon: "point.topleft.down.to.point.bottomright.curvepath")
                }
                RowDivider()
                NavigationLink { ExamLandingView(content: content) } label: { ActionRow(title: "Esame simulato", detail: "Simulazione rigorosa o allenamento", icon: "checklist") }
                    .accessibilityIdentifier("exam-landing")
            }.buttonStyle(.plain)
            VStack(alignment: .leading, spacing: 10) {
                SectionTitle(title: "Studia")
                RowGroup {
                    NavigationLink { WordsView(content: content) } label: { ActionRow(title: "Parole", detail: "300 parole · pinyin e significato", icon: "character.book.closed") }
                    RowDivider()
                    NavigationLink { PinyinIPAView(content: content) } label: { ActionRow(title: "Pinyin e IPA", detail: "Come suonano lettere e toni", icon: "mouth") }.accessibilityIdentifier("pinyin-ipa")
                    RowDivider()
                    NavigationLink { GrammarListView(content: content) } label: { ActionRow(title: "Grammatica", detail: "70 righe collegate ai testi del libro", icon: "text.book.closed") }
                    RowDivider()
                    NavigationLink { CharactersView(content: content) } label: { ActionRow(title: "Caratteri", detail: "246 da riconoscere · 100 da scrivere", icon: "square.grid.2x2") }
                }.buttonStyle(.plain)
            }
            VStack(alignment: .leading, spacing: 10) {
                SectionTitle(title: "Esercita")
                RowGroup {
                    NavigationLink { TonePracticeView(content: content) } label: { ActionRow(title: "Pronuncia e toni", detail: "Terzo tono, cambio 3–3 e parole", icon: "waveform") }.accessibilityIdentifier("tone-practice")
                    RowDivider()
                    NavigationLink { WritingListView(content: content) } label: { ActionRow(title: "Scrittura", detail: "100 caratteri · dito o Apple Pencil", icon: "pencil.and.outline") }.accessibilityIdentifier("writing-practice")
                    RowDivider()
                    NavigationLink { DialogueListView(content: content, listening: true) } label: { ActionRow(title: "Ascolto", detail: "15 dialoghi con trascrizione", icon: "headphones") }.accessibilityIdentifier("listening-practice")
                    RowDivider()
                    NavigationLink { DialogueListView(content: content, listening: false) } label: { ActionRow(title: "Lettura", detail: "Testi graduati sulle parole verificate", icon: "text.alignleft") }.accessibilityIdentifier("reading-practice")
                    RowDivider()
                    NavigationLink { OralPracticeView() } label: { ActionRow(title: "Pratica orale", detail: "Registra e riascoltati, senza voti", icon: "mic") }.accessibilityIdentifier("oral-practice")
                }.buttonStyle(.plain)
            }
        }.navigationTitle("HSK 1").navigationBarTitleDisplayMode(.inline)
    }
    func stat(_ count: Int, of total: Int, _ label: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(alignment: .firstTextBaseline, spacing: 1) {
                Text("\(count)").font(.title3.weight(.semibold))
                Text("/\(total)").font(.footnote).foregroundStyle(Palette.inkSoft)
            }.monospacedDigit()
            Text(label).font(.footnote).foregroundStyle(Palette.inkSoft).lineLimit(2, reservesSpace: !typeSize.isAccessibilitySize)
            Meter(value: Double(count) / Double(total))
        }
        .accessibilityElement(children: .ignore).accessibilityLabel("\(label): \(count) su \(total)")
    }
}
struct ReadinessView: View {
    @Query private var attempts: [ExamAttempt]
    var scores: [(correct: Int,total: Int)]? {
        guard let bank=ExamBank.shared else { return nil }
        var seen=Set<Int>(), results=Array(repeating:(correct:0,total:0),count:8)
        for attempt in attempts.filter({$0.mode==ExamMode.simulation.rawValue && $0.completed != nil && $0.valid}).sorted(by:{$0.started<$1.started}) {
            guard let snapshot=try? JSONDecoder().decode(ExamSnapshot.self,from:attempt.answers),!seen.contains(snapshot.formID),let form=bank.forms.first(where:{$0.id==snapshot.formID}) else {continue}
            seen.insert(snapshot.formID)
            for q in form.questions { results[q.part-1].total += 1;if snapshot.choices[q.id]==q.answer{results[q.part-1].correct += 1} }
        }
        return seen.isEmpty ? nil : results
    }
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionTitle(title: "Preparazione all’esame", detail: "Sperimentale")
            Panel(spacing: 10) {
                if let scores {
                    let interval=ScoreInterval.predict(partScores:scores)
                    HStack(alignment: .firstTextBaseline, spacing: 8) {
                        Text("\(interval.lower)–\(interval.upper)").font(.system(.title, design: .serif).weight(.bold)).monospacedDigit()
                        Text("risposte corrette su 40").font(.subheadline).foregroundStyle(Palette.inkSoft)
                    }
                    .accessibilityElement(children: .combine)
                    IntervalBar(lower: interval.lower, upper: interval.upper)
                    Text("Intervallo predittivo all’80%, sperimentale. Banca non calibrata: stima poco affidabile, non un risultato ufficiale.").font(.footnote)
                    Text("Probabilità stimata di almeno 24/40: \(Int(interval.provisionalProbability*100))%. Il 60% è solo una soglia provvisoria, non ufficiale.").font(.footnote).foregroundStyle(Palette.inkSoft)
                } else {
                    Text("Ancora da stimare").font(.title3.weight(.semibold))
                    IntervalBar(lower: nil, upper: nil)
                    Text("Completa una simulazione per ottenere un intervallo di risposte corrette su 40. Nessuna scala o soglia ufficiale disponibile al 19/10/2026.").font(.footnote).foregroundStyle(Palette.inkSoft)
                }
            }
        }
    }
}
/// Intervallo su una scala 0–40: la stima resta un intervallo, non diventa un numero unico.
struct IntervalBar: View {
    let lower: Int?
    let upper: Int?
    var total = 40
    var body: some View {
        VStack(spacing: 4) {
            GeometryReader { g in
                ZStack(alignment: .leading) {
                    Capsule().fill(Palette.sunken)
                    if let lower, let upper {
                        let width = max(10, g.size.width * CGFloat(upper - lower) / CGFloat(total))
                        Capsule().fill(Palette.ink).frame(width: width)
                            .offset(x: min(g.size.width - width, g.size.width * CGFloat(lower) / CGFloat(total)))
                    } else {
                        Capsule().strokeBorder(Palette.inkSoft.opacity(0.5), style: StrokeStyle(lineWidth: 1, dash: [3, 3]))
                    }
                }
            }.frame(height: 10)
            HStack { Text("0"); Spacer(); Text("20"); Spacer(); Text("40") }.font(.caption2).monospacedDigit().foregroundStyle(Palette.inkSoft)
        }.accessibilityHidden(true)
    }
}
struct UnitsView: View {
    let content: Curriculum
    @Query private var cards: [StudyCard]
    @Query private var events: [StudyEvent]
    var body: some View {
        let passed = Set(events.filter { $0.mode == "unit-assessment" && $0.correct }.map(\.key))
        let verified = Coverage.verifiedWords(content, cards: cards)
        Page(spacing: 18) {
            ScreenHeader(title: "15 modi di usare il cinese", subtitle: "Ogni unità è un compito concreto. Puoi aprirle in qualsiasi ordine.")
            VStack(spacing: 0) {
                ForEach(content.units) { unit in
                    let words = content.words.filter { $0.unit == unit.id }
                    NavigationLink { UnitView(content: content, unit: unit) } label: {
                        PathStep(unit: unit, last: unit.id == content.units.last?.id, passed: passed.contains("unit-\(unit.id)"),
                                 verified: words.filter { verified.contains($0.id) }.count, total: words.count)
                    }.buttonStyle(.plain)
                }
            }
        }.navigationTitle("Percorso").navigationBarTitleDisplayMode(.inline)
    }
}
/// Un passo del percorso (步步): nodo, filo che collega le unità, compito e avanzamento reale.
struct PathStep: View {
    let unit: LearningUnit
    let last: Bool
    let passed: Bool
    let verified: Int
    let total: Int
    @ScaledMetric(relativeTo: .subheadline) private var node: CGFloat = 34
    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            VStack(spacing: 0) {
                ZStack {
                    Circle().fill(passed ? Palette.jade : Palette.surface)
                    if passed { Image(systemName: "checkmark").font(.footnote.weight(.bold)).foregroundStyle(.white) }
                    else { Text("\(unit.id)").font(.subheadline.weight(.semibold)).monospacedDigit() }
                }.frame(width: node, height: node)
                if !last { Rectangle().fill(Palette.ink.opacity(0.14)).frame(width: 2).frame(maxHeight: .infinity) }
            }
            VStack(alignment: .leading, spacing: 3) {
                HStack(alignment: .firstTextBaseline) {
                    Text(unit.title).font(.headline)
                    Spacer(minLength: 8)
                    Image(systemName: "chevron.right").font(.footnote.weight(.semibold)).foregroundStyle(Palette.inkSoft)
                }
                Text("\(unit.hanzi) \(unit.pinyin)").font(.footnote).foregroundStyle(Palette.inkSoft)
                Text(verified == 0 ? "\(total) parole" : "\(verified)/\(total) parole verificate")
                    .font(.footnote.weight(.medium)).monospacedDigit().foregroundStyle(verified == 0 ? Palette.inkSoft : Palette.jade)
            }
            .padding(.top, (node - 20) / 2).padding(.bottom, last ? 4 : 24)
        }
        .contentShape(Rectangle())
        .accessibilityElement(children: .combine)
        .accessibilityValue(passed ? "Mini-test superato" : "")
    }
}
struct UnitView: View {
    let content: Curriculum
    let unit: LearningUnit
    @AppStorage("allowGeneratedContent") private var allowGenerated = true
    var body: some View {
        let words = content.words.filter { $0.unit == unit.id }
        let grammar = GrammarCatalog.shared?.lessons.filter { $0.unit == unit.id }.count ?? 0
        Page(spacing: 24) {
            VStack(alignment: .leading, spacing: 6) {
                ScreenHeader(eyebrow: "\(words.count) parole · \(grammar == 1 ? "1 riga" : "\(grammar) righe") di grammatica", title: unit.title)
                Text("\(unit.hanzi) \(unit.pinyin)").font(.subheadline).foregroundStyle(Palette.inkSoft)
            }
            VStack(alignment: .leading, spacing: 10) {
                SectionTitle(title: "Alla fine saprai")
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(unit.goals, id: \.self) { goal in
                        HStack(alignment: .firstTextBaseline, spacing: 10) {
                            Text("•").font(.body.weight(.bold)).foregroundStyle(Palette.red).accessibilityHidden(true)
                            Text(goal)
                        }
                    }
                }.padding(.horizontal, 4)
            }
            RowGroup {
                NavigationLink { WordsView(content: content, unit: unit.id) } label: {
                    ActionRow(title: "Le parole dell’unità", detail: "Studia e verifica quello che ricordi", icon: "rectangle.on.rectangle", trailing: "\(words.count)")
                }
                RowDivider()
                NavigationLink { GrammarListView(content: content, unit: unit.id) } label: {
                    ActionRow(title: "Grammatica dell’unità", detail: "Spiegazione, esempi e verifica", icon: "text.book.closed", trailing: "\(grammar)")
                }
                if allowGenerated, let dialogue = Dialogue.all.first(where: { $0.id == unit.id }) {
                    RowDivider()
                    NavigationLink { DialogueView(content: content, dialogue: dialogue, listening: true) } label: { ActionRow(title: "Dialogo e comprensione", detail: "Ascolta, leggi e rispondi", icon: "headphones") }
                }
                RowDivider()
                NavigationLink { TonePracticeView(content: content) } label: { ActionRow(title: "Pronuncia", detail: "Ascolta il modello e prova con la voce", icon: "waveform") }
            }.buttonStyle(.plain)
            VStack(spacing: 8) {
                NavigationLink { StudySessionView(content: content, initialQueue: Array(content.words.filter { $0.unit == unit.id }.flatMap { w in ["meaning", "audio", "pinyin"].map { ReviewItem(contentID: String(w.id), kind: $0) } }.shuffled().prefix(10)), unitAssessment: unit.id) } label: {
                    Label("Mini-test dell’unità", systemImage: "checkmark.seal")
                }.buttonStyle(.primary)
                Text("10 verifiche per decidere se proseguire.").font(.footnote).foregroundStyle(Palette.inkSoft)
            }
        }.navigationTitle("Unità \(unit.id)").navigationBarTitleDisplayMode(.inline)
    }
}
struct WordsView: View {
    let content: Curriculum
    var unit: Int? = nil
    @State private var search = ""
    @Query private var cards: [StudyCard]
    @ScaledMetric(relativeTo: .title2) private var column: CGFloat = 96
    var words: [Word] { content.words.filter { (unit == nil || $0.unit == unit) && (search.isEmpty || "\($0.hanzi) \($0.pinyin) \($0.italian)".folding(options: [.diacriticInsensitive, .caseInsensitive], locale: .current).contains(search.folding(options: [.diacriticInsensitive, .caseInsensitive], locale: .current))) } }
    var body: some View {
        let verified = Coverage.verifiedWords(content, cards: cards)
        List {
            NavigationLink { StudySessionView(content: content, initialQueue: StudyEngine.queue(cards: cards, words: content.words, unit: unit)) } label: {
                HStack(spacing: 14) {
                    IconBadge(icon: "play.fill", tint: Palette.red)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Studia queste parole").font(.body.weight(.semibold))
                        Text("Ripasso in scadenza e parole nuove").font(.footnote).foregroundStyle(Palette.inkSoft)
                    }
                }.padding(.vertical, 4)
            }.accessibilityIdentifier("study-words")
            Section {
                ForEach(words) { word in
                    NavigationLink { WordDetail(content: content, word: word) } label: {
                        HStack(spacing: 12) {
                            ChineseText(hanzi: word.hanzi, pinyin: word.pinyin).frame(width: column, alignment: .leading)
                            Text(word.italian).font(.subheadline).frame(maxWidth: .infinity, alignment: .leading)
                            if verified.contains(word.id) {
                                Image(systemName: "checkmark.seal.fill").foregroundStyle(Palette.jade).accessibilityLabel("Verificata")
                            }
                        }
                    }
                }
            } header: {
                Text(words.count == 1 ? "1 parola" : "\(words.count) parole")
            }
        }
        .paperList()
        .searchable(text: $search, prompt: "Cinese, pinyin o italiano")
        .navigationTitle(unit.map { "Parole · unità \($0)" } ?? "300 parole").navigationBarTitleDisplayMode(.inline)
    }
}
enum WordClass {
    private static let names = ["名": "nome", "动": "verbo", "代": "pronome", "形": "aggettivo", "数": "numerale", "副": "avverbio",
                                "量": "classificatore", "助": "particella", "介": "preposizione", "数量": "numerale e classificatore",
                                "前缀": "prefisso", "后缀": "suffisso"]
    /// Le classi del programma sono abbreviate in cinese; nell'interfaccia le mostriamo in italiano. Le parentesi indicano usi secondari.
    static func italian(_ category: String) -> String {
        var optional = false
        return category.split(separator: "、").compactMap { part -> String? in
            if part.contains("（") { optional = true }
            let key = part.trimmingCharacters(in: CharacterSet(charactersIn: "（）"))
            defer { if part.contains("）") { optional = false } }
            guard let name = names[key] else { return nil }
            return optional ? "(\(name))" : name
        }.joined(separator: ", ")
    }
}
struct WordDetail: View {
    let content: Curriculum
    let word: Word
    @StateObject private var speech = SpeechPlayer()
    var body: some View {
        Page {
            Panel(padding: 20, spacing: 18) {
                HanziHero(hanzi: word.hanzi, pinyin: word.pinyin, showsRadicals: true)
                AudioButton(title: "Ascolta", speaking: speech.isSpeaking, size: 56) { speech.speak(word.hanzi) }.frame(maxWidth: .infinity)
            }
            VStack(alignment: .leading, spacing: 10) {
                Text("\(word.emoji) \(word.italian)").font(.title2.weight(.semibold))
                HStack(spacing: 6) {
                    Tag(text: "Unità \(word.unit)")
                    let wordClass = WordClass.italian(word.category)
                    if !wordClass.isEmpty { Tag(text: wordClass) }
                }
            }.padding(.horizontal, 4)
            WordCharactersSection(content: content, word: word)
            WordIPASection(content: content, word: word)
            NavigationLink { StudySessionView(content: content, initialQueue: ["meaning", "audio", "pinyin"].map { ReviewItem(contentID: String(word.id), kind: $0) }) } label: {
                Label("Verifica questa parola", systemImage: "checkmark.circle")
            }.buttonStyle(.primary)
            if let error = speech.error { Text(error).font(.footnote).foregroundStyle(Palette.red) }
        }.navigationTitle("Parola").navigationBarTitleDisplayMode(.inline).onDisappear { speech.stop() }
    }
}
struct CharactersView: View {
    let content: Curriculum
    @Query private var cards: [StudyCard]
    @ScaledMetric(relativeTo: .title) private var tile: CGFloat = 70
    var practice: [ReviewItem] {
        let due = cards.filter { $0.kind == "character" && $0.due <= .now }.sorted { $0.due < $1.due }.map { ReviewItem(contentID: $0.contentID, kind: "character") }
        let seen = Set(cards.filter { $0.kind == "character" }.map(\.contentID))
        let fresh = content.characters.filter { !seen.contains($0.id) }.map { ReviewItem(contentID: $0.id, kind: "character") }
        return Array((due + fresh).prefix(10))
    }
    var body: some View {
        Page(spacing: 18) {
            NavigationLink { StudySessionView(content: content, initialQueue: practice) } label: { Label("Verifica il riconoscimento", systemImage: "play.fill") }
                .buttonStyle(.primary).disabled(practice.isEmpty)
            NavigationLink { WritingListView(content: content) } label: {
                RowGroup { ActionRow(title: "Scrittura dei 100 caratteri", detail: "Ordine dei tratti e pratica a mano", icon: "pencil.and.outline") }
            }.buttonStyle(.plain)
            HStack(alignment: .firstTextBaseline, spacing: 12) {
                Text("Da riconoscere").font(.headline).accessibilityAddTraits(.isHeader)
                Spacer()
                RadicalLegend()
                Label("da scrivere", systemImage: "pencil").font(.footnote).foregroundStyle(Palette.inkSoft)
            }.padding(.horizontal, 4)
            LazyVGrid(columns: [GridItem(.adaptive(minimum: tile), spacing: 8)], spacing: 8) {
                ForEach(content.characters) { character in
                    NavigationLink { CharacterDetailView(content: content, character: character) } label: { CharacterTile(character: character, size: tile) }
                        .buttonStyle(.plain).accessibilityLabel(CharacterTile.spoken(character)).accessibilityIdentifier("char-\(character.hanzi)")
                }
            }
        }.navigationTitle("246 caratteri").navigationBarTitleDisplayMode(.inline)
    }
}
struct ReviewLanding: View {
    let content: Curriculum
    @Query private var cards: [StudyCard]
    var upcoming: Int { cards.filter { $0.due > .now && $0.due <= Date().addingTimeInterval(86400) }.count }
    var body: some View {
        Page(spacing: 24) {
            VStack(alignment: .leading, spacing: 12) {
                TodayCard(content: content, cards: cards, buttonID: "start-review")
                if !cards.isEmpty {
                    FactRow(icon: "clock", text: upcoming == 0 ? "Nessuna carta in arrivo nelle prossime 24 ore." : (upcoming == 1 ? "1 carta in arrivo nelle prossime 24 ore." : "\(upcoming) carte in arrivo nelle prossime 24 ore."))
                        .foregroundStyle(Palette.inkSoft).padding(.horizontal, 4)
                }
            }
            VStack(alignment: .leading, spacing: 10) {
                SectionTitle(title: "Come funziona")
                RowGroup {
                    step(1, "Rispondi prima di vedere la soluzione.")
                    RowDivider(inset: 54)
                    step(2, "Se sbagli, la carta torna presto; se ricordi, l’intervallo cresce.")
                    RowDivider(inset: 54)
                    step(3, "Non perdi nulla se salti un giorno.")
                }
                Text("FSRS 6 · ricordo desiderato 90%. La copertura richiede risposte corrette in almeno due giorni distinti.")
                    .font(.footnote).foregroundStyle(Palette.inkSoft).padding(.horizontal, 4)
            }
        }.navigationTitle("Ripasso").navigationBarTitleDisplayMode(.inline)
    }
    func step(_ number: Int, _ text: String) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 14) {
            Text("\(number)").font(.subheadline.weight(.semibold)).foregroundStyle(Palette.red).frame(width: 24).accessibilityHidden(true)
            Text(text).font(.subheadline).frame(maxWidth: .infinity, alignment: .leading)
        }.padding(.horizontal, 16).padding(.vertical, 14)
    }
}
struct PlanView: View {
    let content: Curriculum
    @AppStorage("examCenter") private var center = ""
    @AppStorage("examVariant") private var variant = "Computer"
    @AppStorage("hasExamDate") private var hasDate = false
    @AppStorage("examTimestamp") private var timestamp = Date().addingTimeInterval(90*86400).timeIntervalSince1970
    @AppStorage("tonePalette") private var palette = "Standard"
    @AppStorage("allowGeneratedContent") private var allowGenerated = true
    var appVersion: String {
        let info = Bundle.main.infoDictionary
        return "\(info?["CFBundleShortVersionString"] as? String ?? "—") (\(info?["CFBundleVersion"] as? String ?? "—"))"
    }
    var body: some View {
        Form {
            Section("Da dove partire") { NavigationLink("Ripeti il test di piazzamento") { ExamLandingView(content: content, initialMode: .placement) } }
            Section {
                TextField("Centro d’esame", text: $center)
                Picker("Modalità", selection: $variant) { Text("Computer").tag("Computer"); Text("Carta").tag("Carta") }
                Toggle("Ho scelto una data", isOn: $hasDate).tint(Palette.jade)
                if hasDate { DatePicker("Data", selection: Binding(get: { Date(timeIntervalSince1970: timestamp) }, set: { timestamp = $0.timeIntervalSince1970 }), displayedComponents: .date) }
            } header: { Text("Il tuo esame") } footer: { Text("Questa è una preferenza personale, non una prenotazione.") }
            Section {
                Picker("Colori dei toni", selection: $palette) { ForEach(["Standard", "Alto contrasto", "Daltonismo", "Disattivati"], id: \.self) { Text($0) } }
                HStack(spacing: 0) {
                    ForEach(Array(["mā", "má", "mǎ", "mà"].enumerated()), id: \.offset) { i, syllable in
                        VStack(spacing: 2) {
                            Text(syllable).font(.title2.weight(.medium)).foregroundStyle(Palette.tone(i+1, mode: palette))
                            Text("\(i+1)° tono").font(.caption).foregroundStyle(Palette.inkSoft)
                        }.frame(maxWidth: .infinity)
                    }
                }.padding(.vertical, 4).accessibilityElement(children: .combine)
            } header: { Text("Toni e accessibilità") } footer: { Text("I segni di tono restano sempre visibili.") }
            Section {
                Toggle("Mostra domande e dialoghi IA", isOn: $allowGenerated).tint(Palette.jade)
            } header: { Text("Contenuti di pratica") } footer: { Text("La banca d’esame e i dialoghi richiedono ancora revisione linguistica umana.") }
            Section("Fonti e progetto") {
                Text("Programma: 考试大纲 kǎoshì dàgāng 2025-11 · Formato: 样题 yàngtí 2025-12")
                LabeledContent("Versione", value: "Bùbù \(appVersion)")
                Text("Non affiliata né approvata da CTI o CLEC").font(.footnote)
                NavigationLink("Licenze e componenti") { LicensesView() }
            }
            Section {
                Text("Contenuti e progressi sono salvati sul dispositivo. Nessun account richiesto.")
            } header: { Text("I tuoi dati") } footer: { Text("Voce di sistema provvisoria: non ancora revisionata da un parlante madrelingua.") }
        }
        .paperList()
        .navigationTitle("Il mio piano").navigationBarTitleDisplayMode(.inline)
    }
}
struct FutureLevelView: View {
    let level: String
    let count: Int
    var body: some View {
        ContentUnavailableView("HSK \(level)", systemImage: "lock", description: Text("\(count) parole cumulative. Questo livello non è ancora disponibile; puoi iniziare dall’HSK 1."))
            .background(Palette.paper.ignoresSafeArea()).navigationBarTitleDisplayMode(.inline)
    }
}
