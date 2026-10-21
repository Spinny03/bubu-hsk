import Foundation

/// Sfida: un carattere, quattro risposte casuali, una serie senza fine. Non tocca ripasso né copertura.
struct GameWord: Codable, Hashable {
    let hanzi, pinyin, italian: String
    let level: Int
}
enum GameMode: String, CaseIterable, Identifiable {
    case meaning, pinyin
    var id: String { rawValue }
    var label: String { self == .meaning ? "Significato" : "Pinyin" }
}
struct GameRound: Equatable {
    let word: GameWord
    let options: [String]
    let answer: Int
}
enum GameEngine {
    /// 1000 parole HSK 1–3 della lista ufficiale 2025, con le traduzioni del progetto (Scripts/import_game.py).
    static let words: [GameWord] = {
        guard let url = Bundle.main.url(forResource: "game-words", withExtension: "json"), let data = try? Data(contentsOf: url) else { return [] }
        return (try? JSONDecoder().decode([GameWord].self, from: data)) ?? []
    }()
    static let levels = [1, 2, 3, 0]
    static func label(level: Int) -> String { level == 0 ? "Tutti" : "HSK \(level)" }
    static func pool(level: Int) -> [GameWord] { level == 0 ? words : words.filter { $0.level == level } }
    static func text(_ word: GameWord, _ mode: GameMode) -> String { mode == .meaning ? word.italian : word.pinyin }
    /// Parola casuale non vista di recente e tre distrattori casuali dello stesso livello, tutti diversi tra loro.
    static func round<G: RandomNumberGenerator>(level: Int, mode: GameMode, recent: [String], using generator: inout G) -> GameRound? {
        let pool = pool(level: level)
        guard pool.count >= 4 else { return nil }
        let fresh = pool.filter { !recent.contains($0.hanzi) }
        guard let word = (fresh.isEmpty ? pool : fresh).randomElement(using: &generator) else { return nil }
        let correct = text(word, mode)
        var options = [correct]
        for other in pool.shuffled(using: &generator) where options.count < 4 {
            let candidate = text(other, mode)
            if !options.contains(candidate) { options.append(candidate) }
        }
        guard options.count == 4 else { return nil }
        options.shuffle(using: &generator)
        return GameRound(word: word, options: options, answer: options.firstIndex(of: correct)!)
    }
    static func bestKey(level: Int, mode: GameMode) -> String { "game.best.\(level).\(mode.rawValue)" }
}
