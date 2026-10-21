import SwiftUI
import SwiftData

struct StudySessionView: View {
    let content: Curriculum
    let initialQueue: [ReviewItem]
    @Environment(\.modelContext) private var context
    @StateObject private var speech = SpeechPlayer()
    @State private var queue: [ReviewItem] = []
    @State private var index = 0
    @State private var response = ""
    @State private var answered = false
    @State private var correct = false
    @State private var uncertain = false
    @State private var error: String?
    @State private var started = Date()
    @State private var options: [Word] = []
    @State private var characterOptions: [Hanzi] = []
    @FocusState private var typing: Bool
    var item: ReviewItem? { index < queue.count ? queue[index] : nil }
    var word: Word? { content.words.first { String($0.id) == item?.contentID } }
    var character: Hanzi? { content.characters.first { $0.id == item?.contentID } }
    var body: some View {
        Page {
            if let item {
                HStack { Text("\(index+1) di \(queue.count)").font(.caption.bold()); Spacer(); Text(label(item.kind)).font(.caption).foregroundStyle(Palette.jade) }
                ProgressView(value: Double(index), total: Double(max(1,queue.count))).tint(Palette.jade)
                if let word {
                    Panel {
                        if !answered && item.kind == "audio" {
                            Text("Ascolta e scegli il significato.").font(.title2.bold())
                            Button { speech.speak(word.hanzi) } label: { Label("Ascolta", systemImage: "speaker.wave.2.fill").frame(maxWidth: .infinity, minHeight: 70) }.buttonStyle(.borderedProminent).foregroundStyle(.white)
                        } else if !answered && item.kind == "pinyin" {
                            Text("Scrivi il pinyin con i toni").font(.headline)
                            Text(word.italian).font(.title2.bold())
                        } else {
                            ChineseText(hanzi: word.hanzi, pinyin: word.pinyin, large: true)
                        }
                        if answered {
                            Text("\(word.emoji) \(word.italian)").font(.title2).accessibilityIdentifier("card-back")
                            Button { speech.speak(word.hanzi) } label: { Label("Ascolta la parola", systemImage: "speaker.wave.2") }
                        }
                    }
                    if !answered {
                        if item.kind == "pinyin" { pinyinInput }
                        else {
                            ForEach(options) { option in
                                Button { answer(option.id == word.id, response: option.italian) } label: {
                                    Text(option.italian).frame(maxWidth: .infinity, alignment: .leading).padding(14)
                                        .background(.white, in: RoundedRectangle(cornerRadius: 12))
                                }.buttonStyle(.plain).accessibilityIdentifier("answer-\(option.id)")
                            }
                        }
                    }
                } else if let character, item.kind == "character" {
                    Panel { Text("Quale carattere senti?").font(.headline); Button("Ascolta") { speech.speak(character.hanzi) }.buttonStyle(.borderedProminent).foregroundStyle(.white) }
                    ForEach(characterOptions) { c in Button { answer(c.id == character.id, response: c.hanzi) } label: { ChineseText(hanzi: c.hanzi, pinyin: c.pinyin).frame(maxWidth: .infinity, alignment: .leading).padding(12).background(.white, in: RoundedRectangle(cornerRadius: 12)) }.buttonStyle(.plain).disabled(answered) }
                    if answered { ChineseText(hanzi: character.hanzi, pinyin: character.pinyin) }
                } else if item.kind == "grammar", let lesson = GrammarCatalog.shared?.lessons.first(where: { String($0.id) == item.contentID }) {
                    GrammarExercise(lesson: lesson) { result, response in answer(result, response: response) }.id(item.id)
                } else {
                    Text("Contenuto non disponibile per questa carta.")
                    Button("Prosegui") { next() }
                }
                if !answered { Toggle("Non sono sicuro", isOn: $uncertain).font(.subheadline) }
                if answered {
                    Panel {
                        Label(correct ? "Risposta corretta" : "Da rivedere", systemImage: correct ? "checkmark.circle" : "arrow.uturn.backward").foregroundStyle(correct ? Palette.jade : Palette.red).font(.headline)
                        Text(correct ? "Il prossimo ripasso è stato programmato." : "Confronta la risposta con la tua. La carta tornerà nei ripassi.").font(.subheadline)
                        if item.kind == "pinyin", let word { Text("Hai scritto: \(response)\nPinyin atteso: \(word.pinyin)").font(.subheadline) }
                    }
                    Button("Continua") { next() }.buttonStyle(.borderedProminent).foregroundStyle(.white).frame(maxWidth: .infinity).accessibilityIdentifier("continue-review")
                }
                if let error { Text(error).foregroundStyle(Palette.red); Button("Riprova a salvare") { answer(correct, response: response) } }
                if let error = speech.error { Text(error).foregroundStyle(Palette.red) }
            } else {
                Panel { Image(systemName: "checkmark.circle").font(.largeTitle).foregroundStyle(Palette.jade); Text("Ripasso completato").font(.title2.bold()); Text("Le risposte sono salvate. Le carte torneranno quando sarà utile riprenderle.") }
            }
        }.navigationTitle("Ripasso").navigationBarTitleDisplayMode(.inline)
            .onAppear { if queue.isEmpty { queue = initialQueue; prepare() } }
            .onDisappear { speech.stop() }
    }
    var pinyinInput: some View {
        VStack(alignment: .leading, spacing: 10) {
            TextField("Es. nǐ hǎo", text: $response).textFieldStyle(.roundedBorder).textInputAutocapitalization(.never).autocorrectionDisabled().focused($typing).accessibilityIdentifier("pinyin-input")
            ForEach(["ā á ǎ à", "ē é ě è", "ī í ǐ ì", "ō ó ǒ ò", "ū ú ǔ ù", "ǖ ǘ ǚ ǜ"], id: \.self) { row in
                HStack { ForEach(row.split(separator: " "), id: \.self) { tone in Button(String(tone)) { response += tone }.frame(maxWidth: .infinity, minHeight: 44).background(.white, in: RoundedRectangle(cornerRadius: 8)) } }
            }
            Button("Verifica") { if let word { answer(StudyEngine.acceptsPinyin(response, expected: word.pinyin), response: response) } }.buttonStyle(.borderedProminent).foregroundStyle(.white).disabled(response.trimmingCharacters(in: .whitespaces).isEmpty)
        }
    }
    func label(_ kind: String) -> String {
        switch kind { case "audio": return "ASCOLTO → SIGNIFICATO"; case "pinyin": return "RICHIAMO DEL PINYIN"; case "grammar": return "GRAMMATICA"; case "character": return "RICONOSCIMENTO"; default: return "CINESE → SIGNIFICATO" }
    }
    func answer(_ result: Bool, response: String) {
        guard !answered, let item else { return }
        correct = result; self.response = response; typing = false
        do {
            try StudyEngine.record(item, correct: result, uncertain: uncertain, response: response, duration: Date().timeIntervalSince(started), context: context)
            answered = true; error = nil
        } catch { self.error = "Risposta non salvata: \(error.localizedDescription)" }
    }
    func next() { speech.stop(); index += 1; answered = false; response = ""; uncertain = false; error = nil; prepare() }
    func prepare() {
        started = .now
        if let word { options = StudyEngine.distractors(for: word, in: content.words) }
        if let character { characterOptions = (Array(content.characters.filter { $0.id != character.id }.shuffled().prefix(3))+[character]).shuffled() }
    }
}
