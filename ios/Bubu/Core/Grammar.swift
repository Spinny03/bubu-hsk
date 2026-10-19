import Foundation
struct ExampleSentence: Codable, Hashable {
    let hanzi, pinyin, italian: String
}
struct GrammarLesson: Codable, Identifiable, Hashable {
    let id, unit, syllabusPage: Int
    let title, source, sourceHeading, body: String
    let examples: [ExampleSentence]
}
struct GrammarCatalog: Codable {
    let lessons: [GrammarLesson]
    static let shared: GrammarCatalog? = {
        guard let url = Bundle.main.url(forResource: "grammar", withExtension: "json"), let data = try? Data(contentsOf: url) else { return nil }
        return try? JSONDecoder().decode(GrammarCatalog.self, from: data)
    }()
}
