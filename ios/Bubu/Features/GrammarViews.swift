import SwiftUI
import SwiftData
struct GrammarListView: View {
    let content: Curriculum
    var unit: Int? = nil
    var body: some View {
        List {
            Section { Text("70 righe del programma, collegate al libro. Gli estratti possono includere parole di approfondimento oltre il livello 1.").font(.subheadline).foregroundStyle(Palette.inkSoft) }
            if let catalog = GrammarCatalog.shared {
                Section {
                    ForEach(catalog.lessons.filter { unit == nil || $0.unit == unit }) { lesson in
                        NavigationLink { GrammarDetailView(content: content, lesson: lesson) } label: {
                            HStack(alignment: .firstTextBaseline, spacing: 14) {
                                Text(String(format: "%02d", lesson.id)).font(.subheadline.weight(.semibold)).monospacedDigit().foregroundStyle(Palette.red)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(lesson.title).font(.body.weight(.medium))
                                    Text("Unità \(lesson.unit) · riga \(lesson.id)/70").font(.footnote).foregroundStyle(Palette.inkSoft)
                                }
                            }.padding(.vertical, 2)
                        }
                    }
                }
            } else { Text("Impossibile caricare la grammatica.") }
        }
        .paperList()
        .navigationTitle("Grammatica").navigationBarTitleDisplayMode(.inline)
    }
}
struct GrammarDetailView: View {
    let content: Curriculum
    let lesson: GrammarLesson
    @StateObject private var speech = SpeechPlayer()
    var body: some View {
        Page(spacing: 22) {
            ScreenHeader(eyebrow: "Riga \(lesson.id) di 70 · unità \(lesson.unit)", title: lesson.title)
            Text(lesson.body).font(.body).lineSpacing(3).fixedSize(horizontal: false, vertical: true)
            VStack(alignment: .leading, spacing: 10) {
                SectionTitle(title: "Esempi dal libro")
                RowGroup {
                    ForEach(Array(lesson.examples.enumerated()), id: \.offset) { i, example in
                        if i > 0 { RowDivider(inset: 16) }
                        HStack(alignment: .top, spacing: 12) {
                            VStack(alignment: .leading, spacing: 6) {
                                ChineseText(hanzi: example.hanzi, pinyin: example.pinyin)
                                Text(example.italian).font(.subheadline).foregroundStyle(Palette.inkSoft)
                            }.frame(maxWidth: .infinity, alignment: .leading)
                            Button { speech.speak(example.hanzi) } label: {
                                Image(systemName: "speaker.wave.2.fill").font(.body).foregroundStyle(Palette.ink)
                                    .frame(width: 44, height: 44).background(Palette.sunken, in: Circle())
                            }.buttonStyle(.plain).accessibilityLabel("Ascolta l’esempio")
                        }.padding(16)
                    }
                }
            }
            NavigationLink { StudySessionView(content: content, initialQueue: [.init(contentID: String(lesson.id), kind: "grammar")]) } label: {
                Label("Verifica la comprensione", systemImage: "checkmark.circle")
            }.buttonStyle(.primary).accessibilityIdentifier("grammar-quiz")
            Text("Fonte: \(lesson.source)\nSezione: \(lesson.sourceHeading)\nProgramma, pagina PDF \(lesson.syllabusPage). Il quiz verifica la comprensione dell’esempio, non certifica tutta la struttura.")
                .font(.footnote).foregroundStyle(Palette.inkSoft)
            if let error = speech.error { Text(error).font(.footnote).foregroundStyle(Palette.red) }
        }.navigationTitle("Grammatica").navigationBarTitleDisplayMode(.inline).onDisappear { speech.stop() }
    }
}
struct GrammarExercise: View {
    let lesson: GrammarLesson
    var completed: (Bool, String) -> Void
    @State private var options: [String] = []
    @State private var selected: String?
    var body: some View {
        if let example = lesson.examples.first {
            Panel(padding: 20, spacing: 14) {
                Text(lesson.title).font(.subheadline.weight(.medium)).foregroundStyle(Palette.inkSoft)
                ChineseText(hanzi: example.hanzi, pinyin: example.pinyin, size: .card)
                Text("Quale significato esprime questa frase?").font(.headline)
            }
            .onAppear {
                guard options.isEmpty else { return }
                let others=Array(Set((GrammarCatalog.shared?.lessons.flatMap(\.examples).map(\.italian) ?? []).filter { $0 != example.italian })).sorted()
                options=(Array(others.shuffled().prefix(2))+[example.italian]).shuffled()
            }
            VStack(spacing: 10) {
                ForEach(options, id: \.self) { option in
                    ChoiceButton(state: state(option, answer: example.italian)) { selected = option; completed(option == example.italian, option) } label: { Text(option) }
                        .disabled(selected != nil)
                }
            }
            if selected != nil {
                Panel(spacing: 8) {
                    Text("Spiegazione").font(.subheadline.weight(.semibold)).foregroundStyle(Palette.inkSoft)
                    Text(example.italian).font(.headline)
                    Text(lesson.body).font(.subheadline)
                }
            }
        }
    }
    func state(_ option: String, answer: String) -> ChoiceState {
        guard let selected else { return .idle }
        if option == answer { return .correct }
        return option == selected ? .wrong : .dimmed
    }
}
