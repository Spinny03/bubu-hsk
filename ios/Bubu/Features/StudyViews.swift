import SwiftUI
import SwiftData

struct StudySessionView: View {
    let content: Curriculum
    let initialQueue: [ReviewItem]
    var unitAssessment: Int? = nil
    @State private var correctCount = 0
    @State private var assessmentSaved = false
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @AppStorage("tonePalette") private var palette = "Standard"
    @StateObject private var speech = SpeechPlayer()
    @State private var queue: [ReviewItem] = []
    @State private var loaded = false
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
    var word: Word? {
        guard let item, ["meaning", "audio", "pinyin"].contains(item.kind) else { return nil }
        return content.words.first { String($0.id) == item.contentID }
    }
    var character: Hanzi? { content.characters.first { $0.id == item?.contentID } }
    var body: some View {
        ScrollViewReader { proxy in
            Page(spacing: 16) {
                if let item {
                    header(item)
                    if let word { wordExercise(item, word) }
                    else if let character, item.kind == "character" { characterExercise(character) }
                    else if item.kind == "grammar", let lesson = GrammarCatalog.shared?.lessons.first(where: { String($0.id) == item.contentID }) {
                        GrammarExercise(lesson: lesson) { result, response in answer(result, response: response) }.id(item.id)
                    } else if item.kind == "tone", let exercise = ToneExercise.all.first(where: { $0.id == item.contentID }) {
                        ToneQuiz(exercise: exercise, answered: answered) { result, response in answer(result, response: response) }.id(item.id)
                    } else {
                        Text("Contenuto non disponibile per questa carta.")
                        Button("Prosegui") { next() }.buttonStyle(.secondary)
                    }
                    if !answered { Toggle("Non sono sicuro", isOn: $uncertain).toggleStyle(.chip) }
                    if answered { feedback(item) }
                    if let error {
                        Text(error).font(.footnote).foregroundStyle(Palette.red)
                        Button("Riprova a salvare") { answer(correct, response: response) }.buttonStyle(.secondary)
                    }
                    if let error = speech.error { Text(error).font(.footnote).foregroundStyle(Palette.red) }
                } else if loaded {
                    completion
                }
            }
            .animation(.easeOut(duration: 0.2), value: answered)
            .onChange(of: answered) { _, value in
                // Attende il layout della correzione, poi porta «Continua» nello schermo.
                if value { DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) { withAnimation(.easeOut(duration: 0.3)) { proxy.scrollTo("continue", anchor: .bottom) } } }
            }
            .onChange(of: index) { _, _ in proxy.scrollTo("top", anchor: .top) }
        }
        .navigationTitle(unitAssessment.map { "Mini-test · unità \($0)" } ?? "Ripasso").navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .tabBar)
        .onAppear { if !loaded { queue = initialQueue; loaded = true; prepare() } }
        .onDisappear { speech.stop() }
    }
    func header(_ item: ReviewItem) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Tag(text: label(item.kind))
                Spacer()
                Text("\(index+1) di \(queue.count)").font(.footnote.weight(.semibold)).monospacedDigit().foregroundStyle(Palette.inkSoft)
            }
            Meter(value: Double(index) / Double(max(1, queue.count)), tint: Palette.ink, height: 4)
        }.id("top")
    }
    @ViewBuilder func wordExercise(_ item: ReviewItem, _ word: Word) -> some View {
        Panel(padding: 20, spacing: 18) {
            Text(prompt(item.kind)).font(.subheadline.weight(.medium)).foregroundStyle(Palette.inkSoft).frame(maxWidth: .infinity)
            if !answered && item.kind == "audio" {
                AudioButton(speaking: speech.isSpeaking) { speech.speak(word.hanzi) }.frame(maxWidth: .infinity)
            } else if !answered && item.kind == "pinyin" {
                Text(word.italian).font(.title2.weight(.semibold)).multilineTextAlignment(.center).frame(maxWidth: .infinity)
            } else {
                HanziHero(hanzi: word.hanzi, pinyin: word.pinyin)
            }
            if answered {
                Rectangle().fill(Palette.line).frame(height: 0.5)
                HStack(spacing: 12) {
                    Text("\(word.emoji) \(word.italian)").font(.title3.weight(.semibold)).accessibilityIdentifier("card-back")
                    Spacer(minLength: 8)
                    Button { speech.speak(word.hanzi) } label: { Image(systemName: "speaker.wave.2.fill") }
                        .buttonStyle(.secondaryCompact).accessibilityLabel("Ascolta la parola")
                }
            }
        }
        if item.kind == "pinyin" {
            if !answered { pinyinInput }
        } else {
            VStack(spacing: 10) {
                ForEach(options) { option in
                    ChoiceButton(state: state(option.id == word.id, chosen: option.italian == response)) { answer(option.id == word.id, response: option.italian) } label: {
                        Text(option.italian)
                    }
                    .disabled(answered).accessibilityIdentifier("answer-\(option.id)")
                }
            }
        }
    }
    @ViewBuilder func characterExercise(_ character: Hanzi) -> some View {
        Panel(padding: 20, spacing: 16) {
            Text("Quale carattere senti?").font(.subheadline.weight(.medium)).foregroundStyle(Palette.inkSoft).frame(maxWidth: .infinity)
            AudioButton(speaking: speech.isSpeaking) { speech.speak(character.hanzi) }.frame(maxWidth: .infinity)
        }
        LazyVGrid(columns: [GridItem(.flexible(), spacing: 10), GridItem(.flexible())], spacing: 10) {
            ForEach(characterOptions) { option in
                ChoiceButton(state: state(option.id == character.id, chosen: option.hanzi == response), alignment: .center) { answer(option.id == character.id, response: option.hanzi) } label: {
                    ChineseText(hanzi: option.hanzi, pinyin: option.pinyin, size: .card, alignment: .center)
                }.disabled(answered)
            }
        }
    }
    var pinyinInput: some View {
        VStack(spacing: 12) {
            TextField("Es. nǐ hǎo", text: $response)
                .font(.title3).textInputAutocapitalization(.never).autocorrectionDisabled().focused($typing)
                .padding(.horizontal, 16).frame(minHeight: 54)
                .background(Palette.surface, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous).strokeBorder(typing ? Palette.ink : Palette.line, lineWidth: typing ? 2 : 1))
                .onSubmit { verifyPinyin() }
                .accessibilityIdentifier("pinyin-input")
            Grid(horizontalSpacing: 6, verticalSpacing: 6) {
                ForEach(Array(["āēīōūǖ", "áéíóúǘ", "ǎěǐǒǔǚ", "àèìòùǜ"].enumerated()), id: \.offset) { tone, row in
                    GridRow {
                        ForEach(Array(row), id: \.self) { mark in
                            Button { response += String(mark) } label: {
                                Text(String(mark)).font(.title3).foregroundStyle(Palette.tone(tone+1, mode: palette))
                                    .frame(maxWidth: .infinity, minHeight: 44)
                                    .background(Palette.surface, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
                                    .contentShape(Rectangle())
                            }
                            .buttonStyle(.plain).accessibilityLabel("\(mark), \(tone+1)° tono")
                        }
                    }
                }
            }
            Button("Verifica") { verifyPinyin() }.buttonStyle(.primary).disabled(response.trimmingCharacters(in: .whitespaces).isEmpty)
        }
    }
    @ViewBuilder func feedback(_ item: ReviewItem) -> some View {
        FeedbackBanner(correct: correct, title: correct ? "Risposta corretta" : "Da rivedere") {
            Text(correct ? (uncertain ? "Segnata come incerta: tornerà un po’ prima." : "Il prossimo ripasso è stato programmato.") : "Confronta la risposta con la tua. La carta tornerà nei ripassi.")
            if item.kind == "pinyin", let word {
                Grid(alignment: .leading, horizontalSpacing: 12, verticalSpacing: 4) {
                    GridRow { Text("Hai scritto").foregroundStyle(Palette.inkSoft); Text(response).font(.body.weight(.semibold)) }
                    GridRow { Text("Pinyin atteso").foregroundStyle(Palette.inkSoft); Text(word.pinyin).font(.body.weight(.semibold)) }
                }
            }
        }
        Button("Continua") { next() }.buttonStyle(.primary).accessibilityIdentifier("continue-review").id("continue")
    }
    @ViewBuilder var completion: some View {
        VStack(spacing: 12) {
            Image(systemName: queue.isEmpty ? "tray" : "checkmark.seal.fill").font(.system(size: 48)).foregroundStyle(queue.isEmpty ? Palette.inkSoft : Palette.jade).accessibilityHidden(true)
            Text(queue.isEmpty ? "Niente da ripassare adesso" : "Ripasso completato").font(.screenTitle).multilineTextAlignment(.center)
            Text(queue.isEmpty ? "Le carte torneranno quando sarà utile riprenderle." : "Le risposte sono salvate. Le carte torneranno quando sarà utile riprenderle.")
                .font(.subheadline).foregroundStyle(Palette.inkSoft).multilineTextAlignment(.center)
        }.frame(maxWidth: .infinity).padding(.top, 32).padding(.bottom, 8)
        if unitAssessment != nil && !queue.isEmpty {
            Panel(spacing: 8) {
                HStack(alignment: .firstTextBaseline) {
                    Text("Mini-test").font(.headline)
                    Spacer()
                    Text("\(correctCount)/\(queue.count)").font(.title3.weight(.semibold)).monospacedDigit()
                }
                Text(correctCount * 10 >= queue.count * 8 ? "Puoi passare alla prossima unità. Continua comunque i ripassi." : "Riprendi le parole che ti hanno fermato, poi riprova.")
                Text("Criterio didattico: almeno 8 risposte su 10. Non è una soglia d’esame.").font(.footnote).foregroundStyle(Palette.inkSoft)
            }
        }
        if let error {
            Text(error).font(.footnote).foregroundStyle(Palette.red)
            Button("Salva il mini-test") { saveAssessment() }.buttonStyle(.secondary)
        }
        Button("Fine") { dismiss() }.buttonStyle(.primary)
    }
    func prompt(_ kind: String) -> String {
        switch kind { case "audio": return "Ascolta e scegli il significato."; case "pinyin": return "Scrivi il pinyin con i toni"; default: return "Che cosa significa?" }
    }
    func label(_ kind: String) -> String {
        switch kind { case "audio": return "Ascolto → significato"; case "pinyin": return "Richiamo del pinyin"; case "grammar": return "Grammatica"; case "character": return "Riconoscimento"; case "tone": return "Toni nelle parole"; default: return "Cinese → significato" }
    }
    func state(_ isAnswer: Bool, chosen: Bool) -> ChoiceState {
        guard answered else { return .idle }
        if isAnswer { return .correct }
        return chosen ? .wrong : .dimmed
    }
    func verifyPinyin() {
        guard let word, !response.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        answer(StudyEngine.acceptsPinyin(response, expected: word.pinyin), response: response)
    }
    func answer(_ result: Bool, response: String) {
        guard !answered, let item else { return }
        correct = result; self.response = response; typing = false
        do {
            try StudyEngine.record(item, correct: result, uncertain: uncertain, response: response, duration: Date().timeIntervalSince(started), context: context)
            answered = true; error = nil
            if result { correctCount += 1 }
            AccessibilityNotification.Announcement(result ? "Risposta corretta" : "Da rivedere").post()
        } catch { self.error = "Risposta non salvata: \(error.localizedDescription)" }
    }
    func saveAssessment() {
        if let unitAssessment, !assessmentSaved {
            context.insert(StudyEvent(key: "unit-\(unitAssessment)", correct: correctCount * 10 >= queue.count * 8, mode: "unit-assessment", response: "\(correctCount)/\(queue.count)"))
            do { try context.save(); assessmentSaved = true; error = nil } catch { context.rollback(); self.error = "Mini-test non salvato: \(error.localizedDescription)" }
        }
    }
    func next() {
        speech.stop(); index += 1
        answered = false; response = ""; uncertain = false; error = nil
        if index >= queue.count { saveAssessment() }
        prepare()
    }
    func prepare() {
        started = .now
        if let word { options = StudyEngine.distractors(for: word, in: content.words) }
        if let character { characterOptions = (Array(content.characters.filter { $0.id != character.id }.shuffled().prefix(3))+[character]).shuffled() }
    }
}
