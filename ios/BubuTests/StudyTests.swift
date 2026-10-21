import XCTest
import SwiftData
import FSRS
@testable import Bubu
@MainActor final class StudyTests: XCTestCase {
    func testPinyinRequiresToneAndAcceptsOfficialAlternatives() {
        XCTAssertTrue(StudyEngine.acceptsPinyin("Nǐ Hǎo", expected: "nǐhǎo"))
        XCTAssertFalse(StudyEngine.acceptsPinyin("ni hao", expected: "nǐhǎo"))
        XCTAssertFalse(StudyEngine.acceptsPinyin("nǐháo", expected: "nǐhǎo"))
        XCTAssertTrue(StudyEngine.acceptsPinyin("shuí", expected: "shéi/shuí"))
        XCTAssertFalse(StudyEngine.acceptsPinyin("lu", expected: "lǜ"))
    }
    func testReviewIsPersistedAndImmediateRepeatDoesNotInflateCoverage() throws {
        let c = try ModelContainer(for: StudyCard.self, StudyEvent.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
        let context = c.mainContext, item = ReviewItem(contentID: "1", kind: "meaning")
        let now = Date(timeIntervalSince1970: 1_700_000_000)
        try StudyEngine.record(item, correct: false, uncertain: false, response: "errore", duration: 2, context: context, now: now)
        var card = try XCTUnwrap(context.fetch(FetchDescriptor<StudyCard>()).first)
        XCTAssertEqual(card.successes, 0)
        XCTAssertTrue(card.due > now)
        try StudyEngine.record(item, correct: true, uncertain: false, response: "amare", duration: 2, context: context, now: now.addingTimeInterval(60))
        XCTAssertEqual(card.successes, 0)
        try StudyEngine.record(item, correct: true, uncertain: false, response: "amare", duration: 2, context: context, now: now.addingTimeInterval(86400))
        card = try XCTUnwrap(context.fetch(FetchDescriptor<StudyCard>()).first)
        XCTAssertEqual(card.successes, 1)
        XCTAssertEqual(try context.fetchCount(FetchDescriptor<StudyEvent>()), 3)
        let state = try JSONDecoder().decode(Card.self, from: XCTUnwrap(card.schedulerData))
        XCTAssertEqual(state.reps, 3)
        XCTAssertTrue(state.stability > 0)
    }
    func testGrammarHasSeventySourceLinkedRows() throws {
        let lessons = try XCTUnwrap(GrammarCatalog.shared?.lessons)
        XCTAssertEqual(lessons.count, 70)
        XCTAssertEqual(Set(lessons.map(\.id)), Set(1...70))
        XCTAssertTrue(lessons.allSatisfy { $0.source.hasPrefix("content/") && !$0.examples.isEmpty && !$0.body.isEmpty })
    }
}
