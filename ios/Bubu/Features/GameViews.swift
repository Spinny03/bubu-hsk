import SwiftUI

struct GameView: View {
    @AppStorage("game.level") private var level = 1
    @AppStorage("game.mode") private var modeRaw = GameMode.meaning.rawValue
    @State private var round: GameRound?
    @State private var streak = 0
    @State private var best = 0
    @State private var chosen: Int?
    @State private var recent: [String] = []
    @State private var record = false
    @State private var advance: Task<Void, Never>?
    @State private var successes = 0
    @State private var errors = 0
    var mode: GameMode { GameMode(rawValue: modeRaw) ?? .meaning }
    var body: some View {
        Page(spacing: 18) {
            VStack(spacing: 10) {
                Picker("Livello", selection: $level) { ForEach(GameEngine.levels, id: \.self) { Text(GameEngine.label(level: $0)).tag($0) } }
                    .pickerStyle(.segmented)
                Picker("Rispondi con", selection: $modeRaw) { ForEach(GameMode.allCases) { Text($0.label).tag($0.rawValue) } }
                    .pickerStyle(.segmented)
            }
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: 0) {
                    Text("Serie").font(.footnote.weight(.semibold)).foregroundStyle(Palette.inkSoft)
                    Text("\(streak)").font(.system(.largeTitle, design: .rounded).weight(.bold)).monospacedDigit()
                        .contentTransition(.numericText()).accessibilityIdentifier("game-streak")
                }
                Spacer()
                if record { Tag(text: "Nuovo record", tint: Palette.jade) }
                VStack(alignment: .trailing, spacing: 0) {
                    Text("Record").font(.footnote.weight(.semibold)).foregroundStyle(Palette.inkSoft)
                    Text("\(best)").font(.system(.title, design: .rounded).weight(.semibold)).monospacedDigit().foregroundStyle(Palette.inkSoft)
                        .contentTransition(.numericText())
                }
            }
            .accessibilityElement(children: .combine)
            if let round {
                Panel(padding: 22, spacing: 10) {
                    Text(round.word.hanzi).font(.hanzi(64, relativeTo: .largeTitle)).lineLimit(1).minimumScaleFactor(0.5)
                        .frame(maxWidth: .infinity, minHeight: 96).accessibilityIdentifier("game-hanzi")
                    // Il pinyin accompagna sempre il carattere: compare appena si risponde.
                    if chosen != nil {
                        VStack(spacing: 2) {
                            Text(round.word.pinyin).font(.title3).foregroundStyle(Palette.inkSoft)
                            Text(round.word.italian).font(.subheadline).multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity).transition(.opacity)
                    }
                }
                VStack(spacing: 10) {
                    ForEach(Array(round.options.enumerated()), id: \.offset) { i, option in
                        ChoiceButton(state: state(i, round), alignment: mode == .pinyin ? .center : .leading) { pick(i) } label: {
                            Text(option).font(mode == .pinyin ? .title3 : .body)
                        }
                        .disabled(chosen != nil).accessibilityIdentifier("game-option")
                    }
                }
                if let chosen, chosen != round.answer {
                    Button { next() } label: { Label("Avanti", systemImage: "arrow.right") }.buttonStyle(.primary).accessibilityIdentifier("game-next")
                }
            } else {
                Text("Nessuna parola disponibile per questo livello.").font(.subheadline).foregroundStyle(Palette.inkSoft)
            }
            Text("Risposte casuali tra le parole del livello. La Sfida non cambia ripasso e copertura; resta solo il record.")
                .font(.footnote).foregroundStyle(Palette.inkSoft)
        }
        .navigationTitle("Sfida").navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .tabBar)
        .sensoryFeedback(.success, trigger: successes)
        .sensoryFeedback(.error, trigger: errors)
        .onAppear { restart() }
        .onChange(of: level) { _, _ in restart() }
        .onChange(of: modeRaw) { _, _ in restart() }
        .onDisappear { advance?.cancel() }
    }
    func state(_ i: Int, _ round: GameRound) -> ChoiceState {
        guard let chosen else { return .idle }
        if i == round.answer { return .correct }
        return i == chosen ? .wrong : .dimmed
    }
    func pick(_ i: Int) {
        guard chosen == nil, let round else { return }
        withAnimation(.easeOut(duration: 0.2)) { chosen = i }
        if i == round.answer {
            successes += 1
            withAnimation { streak += 1 }
            if streak > best {
                withAnimation { best = streak; record = true }
                UserDefaults.standard.set(best, forKey: GameEngine.bestKey(level: level, mode: mode))
            }
            advance?.cancel()
            advance = Task { try? await Task.sleep(nanoseconds: 700_000_000); if !Task.isCancelled { next() } }
        } else {
            errors += 1
            withAnimation { streak = 0; record = false }
            advance?.cancel()
            advance = Task { try? await Task.sleep(nanoseconds: 2_600_000_000); if !Task.isCancelled { next() } }
        }
    }
    func next() {
        advance?.cancel()
        var generator = SystemRandomNumberGenerator()
        let upcoming = GameEngine.round(level: level, mode: mode, recent: recent, using: &generator)
        if let upcoming { recent = Array((recent + [upcoming.word.hanzi]).suffix(12)) }
        withAnimation(.easeOut(duration: 0.15)) { round = upcoming; chosen = nil }
    }
    func restart() {
        advance?.cancel()
        streak = 0; record = false; recent = []
        best = UserDefaults.standard.integer(forKey: GameEngine.bestKey(level: level, mode: mode))
        next()
    }
}
