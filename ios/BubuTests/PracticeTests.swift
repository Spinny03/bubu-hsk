import XCTest
@testable import Bubu
@MainActor final class PracticeTests:XCTestCase {
    func testYINFindsPitchAndRejectsSilence() throws {
        let rate=12000.0
        for frequency in [80.0,150,220,350,480] {
            let samples=(0..<2048).map{Float(0.3*sin(2*Double.pi*frequency*Double($0)/rate))}
            let detected=try XCTUnwrap(YIN.frequency(samples:samples,sampleRate:rate))
            XCTAssertEqual(detected,frequency,accuracy:2)
        }
        XCTAssertNil(YIN.frequency(samples:Array(repeating:0,count:2048),sampleRate:rate))
        XCTAssertEqual(ToneFeedback.analyze([],baseline:nil).recognized,"Tono non riconosciuto")
    }
    func testOneHundredStrokeGraphicsAndFifteenDialogues() throws {
        let c=try Curriculum.load()
        XCTAssertEqual(StrokeCatalog.all.count,100)
        for ch in c.writingCharacters {
            let graphics=try XCTUnwrap(StrokeCatalog.all[ch.hanzi])
            XCTAssertFalse(graphics.strokes.isEmpty)
            XCTAssertEqual(graphics.strokes.count,graphics.medians.count)
            for stroke in graphics.strokes {XCTAssertFalse(StrokeCatalog.path(stroke).isEmpty)}
        }
        XCTAssertEqual(Dialogue.all.count,15)
        let ids=Set(c.words.map(\.id))
        for d in Dialogue.all {XCTAssertTrue(Set(d.wordIDs).isSubset(of:ids));XCTAssertTrue(d.choices.indices.contains(d.answer));XCTAssertGreaterThanOrEqual(d.lines.count,2)}
    }
    func testAppleVoiceProducesPlayableCachedAudio() async throws {
        let speech=SpeechPlayer()
        XCTAssertFalse(speech.voices.isEmpty,"Il simulatore deve avere almeno una voce cinese per verificare l’audio")
        speech.speak("你好",slow:true)
        let deadline=Date().addingTimeInterval(25)
        while speech.isSpeaking && Date()<deadline {try await Task.sleep(nanoseconds:100_000_000)}
        XCTAssertFalse(speech.isSpeaking,"La sintesi/riproduzione deve concludersi")
        XCTAssertNil(speech.error)
        let folder=FileManager.default.urls(for:.cachesDirectory,in:.userDomainMask)[0].appendingPathComponent("Speech")
        let files=try FileManager.default.contentsOfDirectory(at:folder,includingPropertiesForKeys:nil)
        XCTAssertTrue(files.contains{$0.pathExtension=="caf"})
        speech.stop()
    }
}
