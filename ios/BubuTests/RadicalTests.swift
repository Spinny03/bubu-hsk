import XCTest
@testable import Bubu

final class RadicalTests: XCTestCase {
    func testEveryCharacterHasARadicalInsideItsStrokes() throws {
        let catalog = try XCTUnwrap(RadicalCatalog.shared)
        let content = try Curriculum.load()
        XCTAssertEqual(catalog.characters.count, StrokeCatalog.all.count)
        for character in content.characters + content.writingCharacters {
            let match = try XCTUnwrap(catalog.entry(for: character.hanzi), character.hanzi)
            let total = try XCTUnwrap(StrokeCatalog.all[character.hanzi]).strokes.count
            XCTAssertFalse(match.strokes.isEmpty, character.hanzi)
            XCTAssertTrue(match.strokes.allSatisfy { (0..<total).contains($0) }, character.hanzi)
            XCTAssertFalse(match.form.pinyin.isEmpty, character.hanzi)
            XCTAssertFalse(match.form.meaning.isEmpty, character.hanzi)
        }
    }
    func testAnnotatedRadicalsFollowStrokeOrder() throws {
        let catalog = try XCTUnwrap(RadicalCatalog.shared)
        let expected: [String: (String, Set<Int>)] = [
            "好": ("女", [0, 1, 2]), "汉": ("氵", [0, 1, 2]), "这": ("辶", [4, 5, 6]), "国": ("囗", [0, 1, 7]),
            "我": ("戈", [1, 4, 5, 6]), "起": ("走", [0, 1, 2, 3, 4, 5, 9]), "能": ("月", [2, 3, 4, 5]), "想": ("心", [9, 10, 11, 12]),
        ]
        for (hanzi, (form, strokes)) in expected {
            let match = try XCTUnwrap(catalog.entry(for: hanzi))
            XCTAssertEqual(match.form.form, form, hanzi)
            XCTAssertEqual(match.strokes, strokes, hanzi)
        }
        XCTAssertTrue(try XCTUnwrap(catalog.entry(for: "口")).whole)
        XCTAssertEqual(try XCTUnwrap(catalog.entry(for: "脑")).form.canonical, "肉", "Il 月 di 脑 è il radicale carne, non luna")
        XCTAssertEqual(try XCTUnwrap(catalog.entry(for: "朋")).form.canonical, "月")
    }
}
