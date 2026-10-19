import Foundation
struct RubyToken: Codable, Hashable { let hanzi, pinyin: String }
struct ExamSentence: Codable, Hashable {
    let hanzi, pinyin, italian: String
    let tokens: [RubyToken]
    let wordIDs: [Int]
}
struct ExamOption: Codable, Identifiable, Hashable {
    let id: String
    let text: ExamSentence?
    let symbol: String?
    let count: Int
    let label: String
}
struct ExamQuestion: Codable, Identifiable, Hashable {
    let id: String
    let part: Int
    let prompt: ExamSentence?
    let stimulus: [ExamSentence]
    let options: [ExamOption]
    let answer, explanation: String
    let example: ExamSentence?
    let exampleAnswer: String?
    let wordIDs: [Int]
    var listening: Bool { part <= 4 }
    var title: String { "\(listening ? "Ascolto" : "Lettura") · parte \(listening ? part : part-4)" }
    var audio: [ExamSentence] { stimulus + (prompt.map { [$0] } ?? []) }
}
struct ExamForm: Codable, Identifiable {
    let id: Int
    let reserved: Bool
    let questions: [ExamQuestion]
}
struct ExamConfig: Codable {
    let readings, firstPauseSeconds, otherPauseSeconds, personalDataSeconds, paperTransferSeconds, readingSeconds: Int
    let questionSlotSeconds: [Int]
}
struct ExamBank: Codable {
    let config: ExamConfig
    let forms: [ExamForm]
    static let shared: ExamBank? = {
        guard let url=Bundle.main.url(forResource: "exam-bank", withExtension: "json"), let data=try? Data(contentsOf: url) else { return nil }
        return try? JSONDecoder().decode(Self.self, from: data)
    }()
}
enum ExamMode: String, CaseIterable { case simulation = "Simulazione", training = "Allenamento", placement = "Piazzamento" }
enum ExamPhase: String, Codable { case ready, personalData, listening, transfer, reading, finished, interrupted }
struct ExamSnapshot: Codable {
    var formID: Int
    var questionIDs: [String]
    var choices: [String: String] = [:]
    var bookmarks: Set<String> = []
    var phase: ExamPhase = .ready
    var index: Int = 0
    var deadline: Date?
}
struct ScoreInterval {
    let lower, upper: Int
    let provisionalProbability: Double
    // Distribuzione predittiva beta-binomiale per ciascuna delle otto parti, poi convoluzione.
    // È una stima esplorativa, senza taratura esterna e senza punteggio ufficiale.
    static func predict(partScores: [(correct: Int, total: Int)]) -> Self {
        var distribution=[1.0]
        for score in partScores {
            let a=Double(score.correct+1), b=Double(score.total-score.correct+1), n=5
            func logBeta(_ x: Double, _ y: Double) -> Double { lgamma(x)+lgamma(y)-lgamma(x+y) }
            let p=(0...n).map { k in exp(lgamma(Double(n+1))-lgamma(Double(k+1))-lgamma(Double(n-k+1))+logBeta(Double(k)+a,Double(n-k)+b)-logBeta(a,b)) }
            var next=Array(repeating: 0.0, count: distribution.count+n)
            for i in distribution.indices { for k in p.indices { next[i+k] += distribution[i]*p[k] } }
            distribution=next
        }
        func quantile(_ limit: Double) -> Int { var sum=0.0; for (i,p) in distribution.enumerated() { sum+=p; if sum>=limit { return i } }; return distribution.count-1 }
        return Self(lower: quantile(0.1), upper: quantile(0.9), provisionalProbability: distribution.enumerated().filter { $0.offset>=24 }.reduce(0) { $0+$1.element })
    }
}
