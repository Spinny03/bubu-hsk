import XCTest
import SwiftData
@testable import Bubu
@MainActor final class ExamTests: XCTestCase {
    func testBankStructureAndReservedSeparation() throws {
        let bank=try XCTUnwrap(ExamBank.shared)
        XCTAssertEqual(bank.forms.count,20)
        XCTAssertEqual(bank.forms.filter(\.reserved).flatMap(\.questions).count,320)
        XCTAssertEqual(bank.forms.filter{!$0.reserved}.flatMap(\.questions).count,480)
        XCTAssertEqual(Set(bank.forms.flatMap(\.questions).map(\.id)).count,800)
        for form in bank.forms {
            for part in 1...8 {
                let questions=form.questions.filter{$0.part==part}
                XCTAssertEqual(questions.count,5)
                for q in questions {
                    XCTAssertTrue(q.options.contains{$0.id==q.answer})
                    if [3,5,6,7].contains(part) {
                        XCTAssertEqual(q.options.count,6)
                        XCTAssertEqual(q.exampleAnswer,"F")
                        XCTAssertNotNil(q.example)
                        XCTAssertEqual(q.options,questions[0].options)
                        XCTAssertNotEqual(q.answer,q.exampleAnswer)
                    } else {XCTAssertEqual(q.options.count,3)}
                }
            }
        }
        XCTAssertEqual(bank.config.readings,2)
        XCTAssertEqual(bank.config.firstPauseSeconds,10)
        XCTAssertEqual(bank.config.otherPauseSeconds,15)
        XCTAssertEqual(bank.config.readingSeconds,1200)
    }
    func testTrainingFeedbackAndImmediatePersistence() throws {
        let bank=try XCTUnwrap(ExamBank.shared),form=bank.forms[8]
        let c=try ModelContainer(for:ExamAttempt.self,StudyCard.self,configurations:ModelConfiguration(isStoredInMemoryOnly:true))
        let session=ExamSession(form:form,mode:.training,variant:"Computer",config:bank.config)
        session.start(context:c.mainContext);session.choose("A")
        XCTAssertTrue(session.answerConfirmed)
        let first=try XCTUnwrap(c.mainContext.fetch(FetchDescriptor<ExamAttempt>()).first)
        let saved=try JSONDecoder().decode(ExamSnapshot.self,from:first.answers)
        XCTAssertEqual(saved.choices[form.questions[0].id],"A")
        session.next();XCTAssertFalse(session.answerConfirmed)
        session.interrupt(reason:"test");XCTAssertFalse(first.valid)
    }
    func testSimulationAndTrainingPolicies() async throws {
        let bank=try XCTUnwrap(ExamBank.shared)
        let c=try ModelContainer(for:ExamAttempt.self,StudyCard.self,configurations:ModelConfiguration(isStoredInMemoryOnly:true))
        let session=ExamSession(form:bank.forms[0],mode:.simulation,variant:"Computer",config:bank.config,accelerated:true)
        session.start(context:c.mainContext)
        try await Task.sleep(nanoseconds:1_500_000_000)
        XCTAssertEqual(session.phase,.listening)
        session.choose("B");XCTAssertFalse(session.answerConfirmed)
        let i=session.snapshot.index;session.next();XCTAssertEqual(session.snapshot.index,i)
        session.go(to:25);XCTAssertEqual(session.snapshot.index,i)
        session.interrupt(reason:"app in background")
        XCTAssertEqual(session.phase,.interrupted)
        XCTAssertFalse(try XCTUnwrap(c.mainContext.fetch(FetchDescriptor<ExamAttempt>()).first).valid)
    }
    func testAcceleratedPaperFlowAndReadingNavigation() async throws {
        let bank=try XCTUnwrap(ExamBank.shared)
        let c=try ModelContainer(for:ExamAttempt.self,StudyCard.self,configurations:ModelConfiguration(isStoredInMemoryOnly:true))
        let s=ExamSession(form:bank.forms[0],mode:.simulation,variant:"Carta",config:bank.config,accelerated:true)
        s.start(context:c.mainContext)
        let deadline=Date().addingTimeInterval(55);var sawTransfer=false;var seen=Set<String>()
        while Date()<deadline && s.phase != .reading {
            if s.phase == .listening {seen.insert(s.current.id);s.choose(s.current.answer);XCTAssertFalse(s.answerConfirmed)}
            if s.phase == .transfer {sawTransfer=true}
            try await Task.sleep(nanoseconds:100_000_000)
        }
        XCTAssertEqual(seen.count,20);XCTAssertTrue(sawTransfer);XCTAssertEqual(s.phase,.reading)
        s.go(to:4);XCTAssertEqual(s.snapshot.index,20)
        s.go(to:39);XCTAssertEqual(s.snapshot.index,39)
        s.bookmark();XCTAssertTrue(s.snapshot.bookmarks.contains(s.current.id))
        for i in 20..<40 {s.go(to:i);s.choose(s.current.answer)}
        s.finish();XCTAssertEqual(s.score,40);XCTAssertEqual(s.phase,.finished)
        let attempt=try XCTUnwrap(c.mainContext.fetch(FetchDescriptor<ExamAttempt>()).first)
        XCTAssertEqual(attempt.score,40);XCTAssertNotNil(attempt.completed);XCTAssertTrue(attempt.valid)
    }
    func testPredictionIsAnIntervalAndRewardsConsistentEvidence() {
        let low=ScoreInterval.predict(partScores:Array(repeating:(correct:1,total:5),count:8))
        let high=ScoreInterval.predict(partScores:Array(repeating:(correct:4,total:5),count:8))
        XCTAssertLessThan(low.lower,low.upper)
        XCTAssertGreaterThan(high.lower,low.lower)
        XCTAssertGreaterThan(high.provisionalProbability,low.provisionalProbability)
        XCTAssertLessThanOrEqual(high.upper,40)
    }
    func testPlacementSeparatesTenListeningAndTenReading() throws {
        let b=try XCTUnwrap(ExamBank.shared)
        let s=ExamSession(form:b.forms[19],mode:.placement,variant:"Computer",config:b.config)
        XCTAssertEqual(s.questions.filter(\.listening).count,10)
        XCTAssertEqual(s.questions.filter{!$0.listening}.count,10)
    }
}
