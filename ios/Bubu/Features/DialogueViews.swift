import SwiftUI
import SwiftData
struct DialogueListView:View {
    let content:Curriculum
    let listening:Bool
    @AppStorage("allowGeneratedContent") private var allowGenerated = true
    @Query private var cards:[StudyCard]
    var known:Set<Int>{Set(cards.filter{$0.successes>=2 && $0.lastCorrect && $0.kind == (listening ? "audio" : "meaning")}.compactMap{Int($0.contentID)})}
    var body:some View {
        List {
            Section {Text(listening ? "Ascolta, prova a capire, poi apri la trascrizione. La disponibilità di più voci dipende da iOS." : "Testi brevi delle 15 unità. La difficoltà mostrata dipende dalle parole che hai già verificato.").font(.subheadline)}
            if !allowGenerated { Text("I dialoghi IA sono disattivati nel tuo piano. I contenuti revisionati non sono ancora disponibili.") }
            ForEach(allowGenerated ? Dialogue.all.sorted{ coverage($0)>coverage($1) } : []){dialogue in
                NavigationLink{DialogueView(content:content,dialogue:dialogue,listening:listening)}label:{VStack(alignment:.leading,spacing:5){Text("\(dialogue.id). \(dialogue.title)").font(.headline);Text("\(dialogue.wordIDs.filter{known.contains($0)}.count)/\(dialogue.wordIDs.count) parole già verificate").font(.caption);Text(coverage(dialogue)>=(listening ? 0.9 : 0.95) ? "Adatto alla pratica fluida" : "Da affrontare con gli aiuti").font(.caption).foregroundStyle(Palette.jade)}}
            }
        }.navigationTitle(listening ? "Ascolto graduato" : "Lettura graduata")
    }
    func coverage(_ d:Dialogue)->Double{Double(d.wordIDs.filter{known.contains($0)}.count)/Double(max(1,d.wordIDs.count))}
}
struct DialogueView:View {
    let content:Curriculum
    let dialogue:Dialogue
    let listening:Bool
    @Environment(\.modelContext) private var context
    @Query private var cards:[StudyCard]
    @StateObject private var speech=SpeechPlayer()
    @State private var transcript=false
    @State private var translation=false
    @State private var answer:Int?
    @State private var saved=false
    @State private var error:String?
    @State private var playback:Task<Void,Never>?
    var body:some View {
        Page {
            Text(dialogue.title).font(.system(.title,design:.serif).bold())
            HStack {Button{play()}label:{Label("Ascolta il dialogo",systemImage:"speaker.wave.2.fill")}.buttonStyle(.borderedProminent).foregroundStyle(.white);Button("Ferma"){playback?.cancel();speech.stop()}}
            if listening {Toggle("Mostra la trascrizione",isOn:$transcript)}
            if !listening || transcript {
                Toggle("Traduzione italiana",isOn:$translation)
                ForEach(Array(dialogue.lines.enumerated()),id:\.offset){i,line in Panel{Text("Voce \(i%2+1)").font(.caption).foregroundStyle(Palette.jade);RubySentenceView(sentence:line);if translation{Text(line.italian).font(.subheadline)}}}
            }
            Panel {
                Text(dialogue.question).font(.headline)
                ForEach(dialogue.choices.indices,id:\.self){i in Button{submit(i)}label:{HStack{Text(dialogue.choices[i]);Spacer();if answer==i{Image(systemName:"checkmark.circle")}}.frame(minHeight:44)}.disabled(answer != nil)}
                if let answer {Text(answer==dialogue.answer ? "Corretto: \(dialogue.choices[dialogue.answer])." : "La risposta è: \(dialogue.choices[dialogue.answer]). Rileggi il dettaglio nel dialogo.").foregroundStyle(answer==dialogue.answer ? Palette.jade : Palette.red)}
            }
            SectionTitle(title:"Parole da riprendere")
            ForEach(content.words.filter{dialogue.wordIDs.contains($0.id)}){word in NavigationLink{WordDetail(content:content,word:word)}label:{HStack{ChineseText(hanzi:word.hanzi,pinyin:word.pinyin);Spacer();Text(word.italian).font(.caption)}}.buttonStyle(.plain)}
            Button(saved ? "Parole aggiunte" : "Aggiungi le parole nuove al ripasso"){addWords()}.disabled(saved)
            if let error=error ?? speech.error{Text(error).foregroundStyle(Palette.red)}
            Text("Dialogo originale IA, lessico confrontato con il programma HSK 1. Revisione umana ancora da fare.").font(.caption).foregroundStyle(.secondary)
        }.navigationTitle("Unità \(dialogue.id)").navigationBarTitleDisplayMode(.inline).onDisappear{playback?.cancel();speech.stop()}
    }
    func play(){playback?.cancel();playback=Task{for(i,line)in dialogue.lines.enumerated(){guard !Task.isCancelled else{return};await speech.speakAndWait(line.hanzi,voiceIndex:i%2)}}}
    func submit(_ index:Int){answer=index;context.insert(StudyEvent(key:"dialogue-\(dialogue.id)",correct:index==dialogue.answer,mode:listening ? "dialogue-listening" : "dialogue-reading",response:dialogue.choices[index]));do{try context.save()}catch{self.error=error.localizedDescription}}
    func addWords(){let existing=Set(cards.map(\.key));for id in dialogue.wordIDs{let key="meaning:\(id)";if !existing.contains(key){context.insert(StudyCard(key:key,contentID:String(id),kind:"meaning"))}};do{try context.save();saved=true}catch{self.error=error.localizedDescription}}
}
