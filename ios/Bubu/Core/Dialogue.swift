import Foundation
struct Dialogue:Codable,Identifiable {
    let id:Int
    let title:String
    let lines:[ExamSentence]
    let question:String
    let choices:[String]
    let answer:Int
    let wordIDs:[Int]
    static let all:[Self] = {
        guard let url=Bundle.main.url(forResource:"dialogues",withExtension:"json"),let data=try? Data(contentsOf:url)else{return []}
        return (try? JSONDecoder().decode([Self].self,from:data)) ?? []
    }()
}
