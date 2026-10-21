import Foundation
import SwiftData

@Model final class StudyCard {
    @Attribute(.unique) var key: String
    var contentID: String
    var kind: String
    var due: Date
    var schedulerData: Data?
    var successes: Int
    var lastCorrect: Bool
    init(key: String, contentID: String, kind: String, due: Date = .now) {
        self.key = key; self.contentID = contentID; self.kind = kind; self.due = due
        successes = 0; lastCorrect = false
    }
}
@Model final class StudyEvent {
    var id: UUID
    var key: String
    var date: Date
    var correct: Bool
    var mode: String
    var response: String
    var duration: Double
    init(key: String, correct: Bool, mode: String, response: String, duration: Double = 0) {
        id = UUID(); self.key = key; date = .now; self.correct = correct
        self.mode = mode; self.response = response; self.duration = duration
    }
}
@Model final class ExamAttempt {
    @Attribute(.unique) var id: UUID
    var started: Date
    var completed: Date?
    var mode: String
    var variant: String
    var answers: Data
    var score: Int
    var valid: Bool
    init(mode: String, variant: String) {
        id = UUID(); started = .now; self.mode = mode; self.variant = variant
        answers = Data(); score = 0; valid = true
    }
}
