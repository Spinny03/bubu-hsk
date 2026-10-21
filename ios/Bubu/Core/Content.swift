import Foundation

struct Word: Codable, Identifiable, Hashable {
    let id: Int
    let hanzi, pinyin, category, italian, emoji: String
    let unit: Int
}
struct LearningUnit: Codable, Identifiable, Hashable {
    let id: Int
    let title, hanzi, pinyin: String
    let goals: [String]
}
struct Hanzi: Codable, Identifiable, Hashable {
    let id, hanzi, pinyin: String
    let writing: Bool
}
struct Curriculum: Codable {
    let version: String
    let words: [Word]
    let units: [LearningUnit]
    let characters, writingCharacters: [Hanzi]
    static func load(bundle: Bundle = .main) throws -> Self {
        guard let url = bundle.url(forResource: "curriculum", withExtension: "json") else { throw CocoaError(.fileNoSuchFile) }
        let content = try JSONDecoder().decode(Self.self, from: Data(contentsOf: url))
        guard content.words.count == 300, content.units.count == 15, content.characters.count == 246,
              content.writingCharacters.count == 100 else { throw CocoaError(.fileReadCorruptFile) }
        return content
    }
}
