import XCTest
@testable import Bubu
final class ContentTests: XCTestCase {
    func testOfficialInventoryAndUnitCoverage() throws {
        let c = try Curriculum.load()
        XCTAssertEqual(c.words.count, 300)
        XCTAssertEqual(Set(c.words.map(\.id)).count, 300)
        XCTAssertEqual(Set(c.words.map(\.unit)), Set(1...15))
        XCTAssertEqual(c.characters.count, 246)
        XCTAssertEqual(c.writingCharacters.count, 100)
        XCTAssertTrue(c.words.allSatisfy { !$0.pinyin.isEmpty && !$0.italian.isEmpty })
        XCTAssertEqual(c.words.first { $0.hanzi == "谁" }?.pinyin, "shéi/shuí")
    }
}
