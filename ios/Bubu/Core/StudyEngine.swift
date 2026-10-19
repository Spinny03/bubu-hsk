import Foundation
import SwiftData
import FSRS

struct ReviewItem: Identifiable, Hashable {
    let contentID, kind: String
    var id: String { "\(kind):\(contentID)" }
}
enum StudyEngine {
    static let scheduler = FSRS(parameters: .init(requestRetention: 0.9, w: FSRSDefaults.defaultWv6, enableFuzz: false))
    @MainActor static func record(_ item: ReviewItem, correct: Bool, uncertain: Bool, response: String,
                       duration: Double, context: ModelContext, now: Date = .now) throws {
        let key = item.id
        let existing = try context.fetch(FetchDescriptor<StudyCard>(predicate: #Predicate { $0.key == key })).first
        let entry = existing ?? StudyCard(key: key, contentID: item.contentID, kind: item.kind)
        let previous = try entry.schedulerData.map { try JSONDecoder().decode(Card.self, from: $0) } ?? Card(due: now)
        let rating: Rating = correct ? (uncertain ? .hard : .good) : .again
        let next = try scheduler.next(card: previous, now: now, grade: rating).card
        entry.schedulerData = try JSONEncoder().encode(next)
        entry.due = next.due
        // Le ripetizioni immediate aiutano a imparare, ma non dimostrano ricordo a distanza.
        if correct && (previous.lastReview == nil || now.timeIntervalSince(previous.lastReview!) >= 20*3600) {
            entry.successes += 1
        }
        entry.lastCorrect = correct
        if existing == nil { context.insert(entry) }
        context.insert(StudyEvent(key: key, correct: correct, mode: item.kind, response: response, duration: duration))
        do { try context.save() } catch { context.rollback(); throw error }
    }
    static func queue(cards: [StudyCard], words: [Word], unit: Int? = nil, now: Date = .now) -> [ReviewItem] {
        let ids = Set(words.filter { unit == nil || $0.unit == unit }.map { String($0.id) })
        let due = cards.filter { $0.due <= now && (unit == nil || ids.contains($0.contentID)) }
            .sorted { $0.due < $1.due }.map { ReviewItem(contentID: $0.contentID, kind: $0.kind) }
        let existing = Set(cards.map(\.key))
        let fresh = words.filter { ids.contains(String($0.id)) }.flatMap { w in
            ["meaning", "audio", "pinyin"].map { ReviewItem(contentID: String(w.id), kind: $0) }
        }.filter { !existing.contains($0.id) }
        return Array(due.prefix(50)) + Array(fresh.prefix(9))
    }
    static func acceptsPinyin(_ input: String, expected: String) -> Bool {
        // Diacritici obbligatori: spazi, apostrofi e maiuscole non cambiano la risposta.
        func clean(_ s: String) -> String {
            s.precomposedStringWithCanonicalMapping.lowercased().filter { $0.isLetter }
        }
        return expected.split(separator: "/").contains { clean(String($0)) == clean(input) && !clean(input).isEmpty }
    }
    static func distractors(for word: Word, in words: [Word]) -> [Word] {
        let target = word.pinyin.folding(options: .diacriticInsensitive, locale: .current)
        func distance(_ a: String, _ b: String) -> Int {
            let x=Array(a), y=Array(b); var row=Array(0...y.count)
            for (i,c) in x.enumerated() {
                var next=[i+1]
                for (j,d) in y.enumerated() { next.append(min(next[j]+1,row[j+1]+1,row[j]+(c == d ? 0 : 1))) }
                row=next
            }
            return row.last ?? 0
        }
        let others = words.filter { $0.id != word.id && $0.italian != word.italian }
            .sorted { a,b in
                func score(_ w: Word) -> Int { (w.category == word.category ? 0 : 5) + (w.unit == word.unit ? 0 : 2) + distance(target, w.pinyin.folding(options: .diacriticInsensitive, locale: .current)) }
                return score(a) == score(b) ? a.id < b.id : score(a) < score(b)
            }
        return (Array(others.prefix(3)) + [word]).shuffled()
    }
}
