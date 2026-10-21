import SwiftUI
import SwiftData
struct GrammarListView: View {
    let content: Curriculum
    var unit: Int? = nil
    var body: some View {
        List {
            Section { Text("70 righe del programma, collegate al libro. Gli estratti possono includere parole di approfondimento oltre il livello 1.").font(.subheadline) }
            if let catalog = GrammarCatalog.shared {
                ForEach(catalog.lessons.filter { unit == nil || $0.unit == unit }) { lesson in
                    NavigationLink { GrammarDetailView(content: content, lesson: lesson) } label: {
                        HStack { Text(String(format: "%02d", lesson.id)).foregroundStyle(Palette.red).monospacedDigit(); VStack(alignment: .leading) { Text(lesson.title); Text("Unità \(lesson.unit) · riga \(lesson.id)/70").font(.caption).foregroundStyle(.secondary) } }
                    }
                }
            } else { Text("Impossibile caricare la grammatica.") }
        }.navigationTitle("Grammatica")
    }
}
struct GrammarDetailView: View {
    let content: Curriculum
    let lesson: GrammarLesson
    @StateObject private var speech = SpeechPlayer()
    var body: some View {
        Page {
            Text(lesson.title).font(.system(.title, design: .serif).bold())
            Text("Riga \(lesson.id) del programma · unità \(lesson.unit)").font(.caption).foregroundStyle(Palette.jade)
            Panel { Text(lesson.body).font(.body) }
            SectionTitle(title: "Esempi dal libro")
            ForEach(lesson.examples, id: \.self) { example in
                Panel { ChineseText(hanzi: example.hanzi, pinyin: example.pinyin); Text(example.italian); Button { speech.speak(example.hanzi) } label: { Label("Ascolta", systemImage: "speaker.wave.2") } }
            }
            NavigationLink { StudySessionView(content: content, initialQueue: [.init(contentID: String(lesson.id), kind: "grammar")]) } label: { Label("Verifica la comprensione", systemImage: "checkmark.circle").frame(maxWidth: .infinity).padding(10) }.buttonStyle(.borderedProminent).foregroundStyle(.white)
            Text("Fonte: \(lesson.source)\nSezione: \(lesson.sourceHeading)\nProgramma, pagina PDF \(lesson.syllabusPage). Il quiz verifica la comprensione dell’esempio, non certifica tutta la struttura.").font(.caption).foregroundStyle(.secondary)
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
            Panel { Text(lesson.title).font(.headline); ChineseText(hanzi: example.hanzi, pinyin: example.pinyin); Text("Quale significato esprime questa frase?").font(.subheadline) }
            ForEach(options, id: \.self) { option in
                Button { selected = option; completed(option == example.italian, option) } label: { Text(option).frame(maxWidth: .infinity, alignment: .leading).padding(14).background(.white, in: RoundedRectangle(cornerRadius: 12)) }.buttonStyle(.plain).disabled(selected != nil)
            }
            if selected != nil { Panel { Text(example.italian).font(.headline); Text(lesson.body).font(.subheadline) } }
            Color.clear.frame(height: 0).onAppear {
                let others=Array(Set((GrammarCatalog.shared?.lessons.flatMap(\.examples).map(\.italian) ?? []).filter { $0 != example.italian })).sorted()
                options=(Array(others.shuffled().prefix(2))+[example.italian]).shuffled()
            }
        }
    }
}
