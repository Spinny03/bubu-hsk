import Foundation

/// Radicale di ogni carattere: numero e forma da Unihan (sistema Kangxi, con le forme semplificate),
/// tratti annotati in questo progetto (Content/radicals.tsv). Nessun dato di Make Me a Hanzi.
struct RadicalForm: Codable, Hashable {
    let form, canonical, pinyin, meaning: String
    /// «氵 · 水 shuǐ» oppure «口 kǒu»: ogni forma accompagnata dal pinyin del carattere di riferimento.
    var label: String { form == canonical ? "\(form) \(pinyin)" : "\(form) · \(canonical) \(pinyin)" }
}
struct RadicalCatalog: Codable {
    struct Entry: Codable, Hashable {
        let radical: String
        let strokes: [Int]
    }
    struct Match {
        let key: String
        let form: RadicalForm
        let strokes: Set<Int>
        let whole: Bool
    }
    let forms: [String: RadicalForm]
    let characters: [String: Entry]
    static let shared: RadicalCatalog? = {
        guard let url = Bundle.main.url(forResource: "radicals", withExtension: "json"), let data = try? Data(contentsOf: url) else { return nil }
        return try? JSONDecoder().decode(RadicalCatalog.self, from: data)
    }()
    func entry(for hanzi: String) -> Match? {
        guard let entry = characters[hanzi], let form = forms[entry.radical] else { return nil }
        let total = StrokeCatalog.all[hanzi]?.strokes.count ?? 0
        return Match(key: entry.radical, form: form, strokes: Set(entry.strokes), whole: entry.strokes.count == total)
    }
    /// Altri caratteri con la stessa forma di radicale, nell'ordine del catalogo.
    func siblings(of hanzi: String, in list: [Hanzi]) -> [Hanzi] {
        guard let key = characters[hanzi]?.radical else { return [] }
        return list.filter { $0.hanzi != hanzi && characters[$0.hanzi]?.radical == key }
    }
}
