import XCTest
@testable import Bubu

final class PinyinIPATests: XCTestCase {
    func testKnownTranscriptionsFollowTheReferenceTables() {
        let cases = [
            "hǎo": "[xau̯˨˩˦]", "nǐ hǎo": "[ni˧˥.xau̯˨˩˦]", "lǎoshī": "[lau̯˨˩.ʂɻ̩˥]", "zì": "[tsɹ̩˥˩]",
            "xué": "[ɕɥe˧˥]", "qù": "[tɕʰy˥˩]", "nǚ’ér": "[ny˨˩.aɚ̯˧˥]", "bàba": "[pa˥˩.pa˩]",
            "duì": "[twei̯˥˩]", "yǒu": "[jou̯˨˩˦]", "wǒ": "[wo˨˩˦]", "èr": "[aɚ̯˥˩]", "Zhōngguó": "[ʈʂʊŋ˥.kwo˧˥]",
            "xièxie": "[ɕje˥˩.ɕje˩]", "shéi/shuí": "[ʂei̯˧˥] / [ʂwei̯˧˥]", "zhèr": "[ʈʂɤʵ˥˩]",
            "yǒudiǎnr": "[jou̯˧˥.tjɐʵ˨˩˦]", "miàntiáor": "[mjɛn˥˩.tʰjɑu̯˞˧˥]", "xī’ān": "[ɕi˥.an˥]",
        ]
        for (pinyin, ipa) in cases { XCTAssertEqual(PinyinIPA.transcribe(pinyin), ipa, pinyin) }
    }
    func testEveryHSK1WordSegmentsIntoOneSyllablePerCharacter() throws {
        let content = try Curriculum.load()
        for word in content.words {
            let han = word.hanzi.filter { $0.unicodeScalars.allSatisfy { $0.properties.isIdeographic } }.count
            for form in word.pinyin.split(separator: "/") {
                let syllables = try XCTUnwrap(PinyinIPA.segment(String(form)), "\(word.hanzi) \(form)")
                // L'erhua unisce 儿 alla sillaba precedente.
                XCTAssertEqual(syllables.count, han - syllables.filter(\.erhua).count, "\(word.hanzi) \(form)")
            }
            XCTAssertNotNil(PinyinIPA.transcribe(word.pinyin), word.hanzi)
        }
        for character in content.characters {
            for form in character.pinyin.split(separator: "/") {
                XCTAssertEqual(PinyinIPA.segment(String(form))?.count, 1, "\(character.hanzi) \(form)")
            }
        }
    }
    func testInvalidSpellingsAreRejectedAndNumbersBecomeToneMarks() {
        for invalid in ["gi", "zhü", "bua", "xa", "hǎǒ"] { XCTAssertNil(PinyinIPA.parse(invalid), invalid) }
        XCTAssertEqual(PinyinIPA.segment("xiān")?.count, 1, "Senza apostrofo una sillaba interna non comincia per vocale")
        XCTAssertEqual(PinyinIPA.markTones("ni3 hao3"), "nǐ hǎo")
        XCTAssertEqual(PinyinIPA.markTones("xie4xie5"), "xièxie")
        XCTAssertEqual(PinyinIPA.markTones("liu2 gui4 lv4"), "liú guì lǜ")
        XCTAssertEqual(Set(PinyinIPA.initials.map(\.id)).count, PinyinIPA.initials.count)
        XCTAssertEqual(Set(PinyinIPA.finals.map(\.id)).count, PinyinIPA.finals.count)
    }
}
