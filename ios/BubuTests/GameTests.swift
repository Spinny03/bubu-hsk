import XCTest
@testable import Bubu

final class GameTests: XCTestCase {
    func testOfficialPoolsPerLevel() {
        XCTAssertEqual(GameEngine.pool(level: 1).count, 300)
        XCTAssertEqual(GameEngine.pool(level: 2).count, 200)
        XCTAssertEqual(GameEngine.pool(level: 3).count, 500)
        XCTAssertEqual(GameEngine.pool(level: 0).count, 1000)
        // Ogni testo cinese nelle traduzioni ha il pinyin accanto.
        for word in GameEngine.words {
            let han = word.italian.unicodeScalars.filter { $0.properties.isIdeographic }
            if !han.isEmpty { XCTAssertTrue(word.italian.contains { "āáǎàēéěèīíǐìōóǒòūúǔùǖǘǚǜ".contains($0) }, word.hanzi) }
        }
    }
    func testEveryRoundHasFourDistinctOptionsAndOneAnswer() throws {
        var generator = SystemRandomNumberGenerator()
        for level in GameEngine.levels {
            for mode in GameMode.allCases {
                for _ in 0..<300 {
                    let round = try XCTUnwrap(GameEngine.round(level: level, mode: mode, recent: [], using: &generator))
                    XCTAssertEqual(round.options.count, 4)
                    XCTAssertEqual(Set(round.options).count, 4)
                    XCTAssertEqual(round.options[round.answer], GameEngine.text(round.word, mode))
                    if level != 0 { XCTAssertEqual(round.word.level, level) }
                }
            }
        }
    }
    func testRecentWordsAreNotRepeatedAndBestIsPerLevelAndMode() throws {
        var generator = SystemRandomNumberGenerator()
        var recent: [String] = []
        for _ in 0..<100 {
            let round = try XCTUnwrap(GameEngine.round(level: 1, mode: .meaning, recent: recent, using: &generator))
            XCTAssertFalse(recent.contains(round.word.hanzi))
            recent = Array((recent + [round.word.hanzi]).suffix(12))
        }
        XCTAssertNotEqual(GameEngine.bestKey(level: 1, mode: .pinyin), GameEngine.bestKey(level: 1, mode: .meaning))
        XCTAssertNotEqual(GameEngine.bestKey(level: 1, mode: .pinyin), GameEngine.bestKey(level: 2, mode: .pinyin))
    }
}
