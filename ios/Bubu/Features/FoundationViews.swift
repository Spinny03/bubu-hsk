import SwiftUI
import SwiftData

struct RootView: View {
    let content: Curriculum
    @State private var selected = 0
    var body: some View {
        VStack(spacing: 0) {
        TabView(selection: $selected) {
            NavigationStack { HomeView(content: content) }.tabItem { Label("Livelli", systemImage: "square.stack.3d.up") }.tag(0)
            NavigationStack { ReviewLanding(content: content) }.tabItem { Label("Ripasso", systemImage: "arrow.triangle.2.circlepath") }.tag(1)
            NavigationStack { PlanView() }.tabItem { Label("Il mio piano", systemImage: "calendar") }.tag(2)
        }
        SourceFooter()
        }.background(Palette.paper)
    }
}
struct HomeView: View {
    let content: Curriculum
    @Query private var cards: [StudyCard]
    @AppStorage("placementDone") private var placementDone = false
    var body: some View {
        Page {
            HStack(alignment: .firstTextBaseline) {
                Text("Bùbù").font(.system(size: 38, weight: .bold, design: .serif))
                Text("步步 bùbù").font(.title3).foregroundStyle(Palette.red)
                Spacer()
                Image(systemName: "sun.max").foregroundStyle(Palette.red)
            }
            Text("Il cinese, un passo alla volta.").foregroundStyle(.secondary)
            NavigationLink { ReviewLanding(content: content) } label: {
                VStack(alignment: .leading, spacing: 10) {
                    Label("IL RIPASSO DI OGGI", systemImage: "arrow.clockwise").font(.caption.bold())
                    HStack {
                        Text(cards.filter { $0.due <= .now }.isEmpty ? "Comincia da qui" : "\(cards.filter { $0.due <= .now }.count) carte pronte").font(.title2.bold())
                        Spacer(); Image(systemName: "arrow.right.circle.fill").font(.title)
                    }
                    Text("Un solo ripasso per parole e abilità.").font(.subheadline)
                }.foregroundStyle(.white).padding(18).background(Palette.jade, in: RoundedRectangle(cornerRadius: 20))
            }.buttonStyle(.plain)
            SectionTitle(title: "Scegli il tuo livello", detail: "Programma 2025")
            ForEach(Array([300, 500, 1000, 2000, 3600, 5400, 11000].enumerated()), id: \.offset) { i, count in
                NavigationLink { if i == 0 { LevelView(content: content) } else { FutureLevelView(level: i == 6 ? "7–9" : "\(i+1)", count: count) } } label: {
                    Panel {
                        HStack(spacing: 14) {
                            Text(i == 6 ? "7–9" : "0\(i+1)").font(.system(.title2, design: .serif).bold()).foregroundStyle(i == 0 ? Palette.red : .secondary).frame(width: 44)
                            VStack(alignment: .leading, spacing: 4) {
                                Text("HSK \(i == 6 ? "7–9" : "\(i+1)")").font(.headline)
                                Text("\(count) parole cumulative" + (i == 0 ? " · 15 unità" : "")).font(.caption).foregroundStyle(.secondary)
                            }
                            Spacer(); Image(systemName: i == 0 ? "arrow.up.right" : "lock").foregroundStyle(.secondary)
                        }
                    }
                }.buttonStyle(.plain).accessibilityIdentifier("level-\(i+1)")
            }
        }.toolbar(.hidden, for: .navigationBar)
    }
}
struct LevelView: View {
    let content: Curriculum
    @Query private var cards: [StudyCard]
    var learned: Int { content.words.filter { word in ["meaning", "audio", "pinyin"].allSatisfy { kind in cards.contains { $0.contentID == String(word.id) && $0.kind == kind && $0.successes >= 2 && $0.lastCorrect } } }.count }
    var body: some View {
        Page {
            Text("Le basi per capire\ne farti capire.").font(.system(.largeTitle, design: .serif).bold())
            Text("HSK 1 · 一级 yī jí · 40 domande, circa 40 minuti").font(.subheadline).foregroundStyle(.secondary)
            Panel {
                SectionTitle(title: "Copertura del programma")
                coverage("Parole verificate", count: learned, total: 300)
                coverage("Caratteri verificati", count: cards.filter { $0.kind == "character" && $0.successes >= 2 && $0.lastCorrect }.count, total: 246)
                coverage("Righe di grammatica", count: cards.filter { $0.kind == "grammar" && $0.successes >= 2 && $0.lastCorrect }.count, total: 70)
                Text("Le verifiche contano. Aprire una lezione non basta.").font(.caption).foregroundStyle(.secondary)
            }
            ReadinessView()
            NavigationLink { UnitsView(content: content) } label: { Panel { ActionRow(title: "Il percorso", detail: "15 compiti, dalle presentazioni alla cucina", icon: "point.topleft.down.to.point.bottomright.curvepath") } }.buttonStyle(.plain)
            Panel {
                NavigationLink { WordsView(content: content) } label: { ActionRow(title: "Parole", detail: "300 parole · pinyin e significato", icon: "character.book.closed") }
                Divider()
                NavigationLink { GrammarListView(content: content) } label: { ActionRow(title: "Grammatica", detail: "70 righe collegate ai testi del libro", icon: "text.book.closed") }
                Divider()
                NavigationLink { CharactersView(content: content) } label: { ActionRow(title: "Caratteri", detail: "246 da riconoscere · 100 da scrivere", icon: "pencil.tip") }
            }.buttonStyle(.plain)
        }.navigationTitle("HSK 1").navigationBarTitleDisplayMode(.inline)
    }
    func coverage(_ label: String, count: Int, total: Int) -> some View {
        VStack(spacing: 4) {
            HStack { Text(label); Spacer(); Text("\(count)/\(total)").monospacedDigit().bold() }.font(.subheadline)
            ProgressView(value: Double(count), total: Double(total)).tint(Palette.jade)
        }
    }
}
struct ReadinessView: View {
    @Query private var attempts: [ExamAttempt]
    var body: some View {
        Panel {
            Label("Preparazione all’esame", systemImage: "chart.bar.xaxis").font(.headline)
            Text("Ancora da stimare").font(.title2.bold()).foregroundStyle(Palette.red)
            Text("Completa una simulazione per ottenere un intervallo di risposte corrette su 40. Nessuna scala o soglia ufficiale disponibile al 19/10/2026.").font(.caption).foregroundStyle(.secondary)
        }
    }
}
struct UnitsView: View {
    let content: Curriculum
    var body: some View {
        Page {
            Text("15 modi di usare il cinese").font(.system(.title, design: .serif).bold())
            ForEach(content.units) { unit in
                NavigationLink { UnitView(content: content, unit: unit) } label: {
                    Panel {
                        HStack(alignment: .top) {
                            Text(String(format: "%02d", unit.id)).font(.title3.bold()).foregroundStyle(Palette.red).frame(width: 30)
                            VStack(alignment: .leading, spacing: 5) {
                                Text(unit.title).font(.headline)
                                Text("\(unit.hanzi) \(unit.pinyin)").font(.caption).foregroundStyle(.secondary)
                                Text("\(content.words.filter { $0.unit == unit.id }.count) parole").font(.caption.bold()).foregroundStyle(Palette.jade)
                            }
                            Spacer(); Image(systemName: "chevron.right").font(.caption)
                        }
                    }
                }.buttonStyle(.plain)
            }
        }.navigationTitle("Percorso").navigationBarTitleDisplayMode(.inline)
    }
}
struct UnitView: View {
    let content: Curriculum
    let unit: LearningUnit
    var body: some View {
        Page {
            Text(unit.title).font(.system(.largeTitle, design: .serif).bold())
            Text("\(unit.hanzi) \(unit.pinyin)").foregroundStyle(.secondary)
            Panel { Text("Alla fine saprai").font(.headline); ForEach(unit.goals, id: \.self) { Label($0, systemImage: "circle") } }
            NavigationLink { WordsView(content: content, unit: unit.id) } label: {
                Panel { ActionRow(title: "Le parole dell’unità", detail: "Studia e verifica quello che ricordi", icon: "rectangle.on.rectangle") }
            }.buttonStyle(.plain)
            NavigationLink { GrammarListView(content: content, unit: unit.id) } label: { Panel { ActionRow(title: "Grammatica dell’unità", detail: "Spiegazione, esempi e verifica", icon: "text.book.closed") } }.buttonStyle(.plain)
        }.navigationTitle("Unità \(unit.id)").navigationBarTitleDisplayMode(.inline)
    }
}
struct WordsView: View {
    let content: Curriculum
    var unit: Int? = nil
    @State private var search = ""
    @Query private var cards: [StudyCard]
    var words: [Word] { content.words.filter { (unit == nil || $0.unit == unit) && (search.isEmpty || "\($0.hanzi) \($0.pinyin) \($0.italian)".folding(options: [.diacriticInsensitive, .caseInsensitive], locale: .current).contains(search.folding(options: [.diacriticInsensitive, .caseInsensitive], locale: .current))) } }
    var body: some View {
        List {
            NavigationLink { StudySessionView(content: content, initialQueue: StudyEngine.queue(cards: cards, words: content.words, unit: unit)) } label: { Label("Studia queste parole", systemImage: "play.fill") }.accessibilityIdentifier("study-words")
            ForEach(words) { word in
            NavigationLink { WordDetail(content: content, word: word) } label: {
                HStack { ChineseText(hanzi: word.hanzi, pinyin: word.pinyin).frame(width: 125, alignment: .leading); Text(word.italian).font(.subheadline) }.padding(.vertical, 4)
            }
        }
        }.searchable(text: $search, prompt: "Cinese, pinyin o italiano").navigationTitle(unit.map { "Parole · unità \($0)" } ?? "300 parole")
    }
}
struct WordDetail: View {
    let content: Curriculum
    let word: Word
    @StateObject private var speech = SpeechPlayer()
    var body: some View {
        Page {
            Panel { ChineseText(hanzi: word.hanzi, pinyin: word.pinyin, large: true); Text("\(word.emoji) \(word.italian)").font(.title2); Text("Unità \(word.unit)").foregroundStyle(.secondary); Button { speech.speak(word.hanzi) } label: { Label("Ascolta", systemImage: "speaker.wave.2") } }
            NavigationLink("Verifica questa parola") { StudySessionView(content: content, initialQueue: ["meaning", "audio", "pinyin"].map { ReviewItem(contentID: String(word.id), kind: $0) }) }.buttonStyle(.borderedProminent)
            if let error = speech.error { Text(error).foregroundStyle(Palette.red) }
        }.navigationTitle("Parola").navigationBarTitleDisplayMode(.inline).onDisappear { speech.stop() }
    }
}
struct CharactersView: View {
    let content: Curriculum
    var body: some View {
        List {
            NavigationLink { StudySessionView(content: content, initialQueue: Array(content.characters.prefix(10)).map { ReviewItem(contentID: $0.id, kind: "character") }) } label: { Label("Verifica il riconoscimento", systemImage: "play.fill") }
            ForEach(content.characters) { character in
                HStack { ChineseText(hanzi: character.hanzi, pinyin: character.pinyin); Spacer(); if character.writing { Text("Anche da scrivere").font(.caption).foregroundStyle(.secondary) } }
            }
        }.navigationTitle("246 caratteri")
    }
}
struct ReviewLanding: View {
    let content: Curriculum
    @Query private var cards: [StudyCard]
    var due: [StudyCard] { cards.filter { $0.due <= .now } }
    var body: some View {
        Page {
            Text("Un ripasso,\ntutte le tue abilità.").font(.system(.largeTitle, design: .serif).bold())
            Panel {
                Text(due.isEmpty ? "Puoi imparare qualcosa di nuovo" : "\(due.count) carte da riprendere").font(.title2.bold())
                Text("Parole, ascolto, pinyin, caratteri e grammatica. Le scadenze seguono quello che ricordi davvero.").foregroundStyle(.secondary)
                NavigationLink { StudySessionView(content: content, initialQueue: StudyEngine.queue(cards: cards, words: content.words)) } label: { Label(due.isEmpty ? "Inizia a studiare" : "Inizia il ripasso", systemImage: "play.fill") }.buttonStyle(.borderedProminent).accessibilityIdentifier("start-review")
            }
            Panel { Text("Come funziona").font(.headline); Text("Rispondi prima di vedere la soluzione. Se sbagli, la carta torna presto; se ricordi, l’intervallo cresce. Non perdi nulla se salti un giorno."); Text("FSRS 6 · ricordo desiderato 90%. La copertura richiede risposte corrette in almeno due giorni distinti.").font(.caption).foregroundStyle(.secondary) }
        }.navigationTitle("Ripasso").navigationBarTitleDisplayMode(.inline)
    }
}
struct PlanView: View {
    @AppStorage("examCenter") private var center = ""
    @AppStorage("examVariant") private var variant = "Computer"
    @AppStorage("hasExamDate") private var hasDate = false
    @AppStorage("examTimestamp") private var timestamp = Date().addingTimeInterval(90*86400).timeIntervalSince1970
    @AppStorage("tonePalette") private var palette = "Standard"
    var body: some View {
        Form {
            Section("Il tuo esame") {
                TextField("Centro d’esame", text: $center)
                Picker("Modalità", selection: $variant) { Text("Computer").tag("Computer"); Text("Carta").tag("Carta") }
                Toggle("Ho scelto una data", isOn: $hasDate)
                if hasDate { DatePicker("Data", selection: Binding(get: { Date(timeIntervalSince1970: timestamp) }, set: { timestamp = $0.timeIntervalSince1970 }), displayedComponents: .date) }
                Text("Questa è una preferenza personale, non una prenotazione.").font(.caption)
            }
            Section("Toni e accessibilità") {
                Picker("Colori dei toni", selection: $palette) { ForEach(["Standard", "Alto contrasto", "Daltonismo", "Disattivati"], id: \.self) { Text($0) } }
                HStack { ForEach(Array(["mā 1°", "má 2°", "mǎ 3°", "mà 4°"].enumerated()), id: \.offset) { i, s in Text(s).foregroundStyle(Palette.tone(i+1, mode: palette)); Spacer() } }
                Text("I segni di tono restano sempre visibili.").font(.caption)
            }
            Section("I tuoi dati") { Text("Contenuti e progressi sono salvati sul dispositivo. Nessun account richiesto."); Text("Voce di sistema provvisoria: non ancora revisionata da un parlante madrelingua.").font(.caption) }
        }.navigationTitle("Il mio piano")
    }
}
struct FutureLevelView: View {
    let level: String
    let count: Int
    var body: some View { ContentUnavailableView("HSK \(level)", systemImage: "books.vertical", description: Text("\(count) parole cumulative. Questo livello non è ancora disponibile; puoi iniziare dall’HSK 1.")) }
}
