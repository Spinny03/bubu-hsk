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
            Section {Text(listening ? "Ascolta, prova a capire, poi apri la trascrizione. La disponibilità di più voci dipende da iOS." : "Testi brevi delle 15 unità. La difficoltà mostrata dipende dalle parole che hai già verificato.").font(.subheadline).foregroundStyle(Palette.inkSoft)}
            if !allowGenerated { Text("I dialoghi IA sono disattivati nel tuo piano. I contenuti revisionati non sono ancora disponibili.") }
            Section {
                ForEach(allowGenerated ? Dialogue.all.sorted{ coverage($0)>coverage($1) } : []){dialogue in
                    let fluent=coverage(dialogue)>=(listening ? 0.9 : 0.95)
                    NavigationLink{DialogueView(content:content,dialogue:dialogue,listening:listening)}label:{
                        HStack(alignment:.top,spacing:14) {
                            Text("\(dialogue.id)").font(.subheadline.weight(.semibold)).monospacedDigit().foregroundStyle(Palette.red).frame(minWidth:22,alignment:.leading)
                            VStack(alignment:.leading,spacing:6) {
                                Text(dialogue.title).font(.body.weight(.semibold))
                                Text("\(dialogue.wordIDs.filter{known.contains($0)}.count)/\(dialogue.wordIDs.count) parole già verificate").font(.footnote).monospacedDigit().foregroundStyle(Palette.inkSoft)
                                Tag(text:fluent ? "Adatto alla pratica fluida" : "Da affrontare con gli aiuti",tint:fluent ? Palette.jade : Palette.inkSoft)
                            }
                        }.padding(.vertical,4)
                    }
                }
            }
        }
        .paperList()
        .navigationTitle(listening ? "Ascolto graduato" : "Lettura graduata").navigationBarTitleDisplayMode(.inline)
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
        Page(spacing:20) {
            ScreenHeader(eyebrow:listening ? "Ascolto" : "Lettura",title:dialogue.title)
            HStack(spacing:10) {
                Button{play()}label:{Label("Ascolta il dialogo",systemImage:"speaker.wave.2.fill")}.buttonStyle(.primary)
                Button{playback?.cancel();speech.stop()}label:{Image(systemName:"stop.fill")}.buttonStyle(.secondaryCompact).accessibilityLabel("Ferma")
            }
            HStack(spacing:8) {
                if listening {Toggle("Trascrizione",isOn:$transcript).toggleStyle(.chip)}
                if !listening || transcript {Toggle("Traduzione italiana",isOn:$translation).toggleStyle(.chip)}
            }
            if !listening || transcript {
                VStack(spacing:10) {
                    ForEach(Array(dialogue.lines.enumerated()),id:\.offset){i,line in bubble(line,speaker:i%2)}
                }
            } else {
                Label("Ascolta prima di leggere: la trascrizione è nascosta.",systemImage:"eye.slash")
                    .font(.subheadline).foregroundStyle(Palette.inkSoft)
                    .frame(maxWidth:.infinity,minHeight:72).padding(.horizontal,16)
                    .background(RoundedRectangle(cornerRadius:Metrics.radius,style:.continuous).strokeBorder(Palette.ink.opacity(0.2),style:StrokeStyle(lineWidth:1,dash:[5,4])))
            }
            VStack(alignment:.leading,spacing:10) {
                Text(dialogue.question).font(.headline).padding(.horizontal,4).accessibilityAddTraits(.isHeader)
                ForEach(dialogue.choices.indices,id:\.self){i in
                    ChoiceButton(state:state(i)){submit(i)} label:{Text(dialogue.choices[i])}.disabled(answer != nil)
                }
                if let answer {
                    FeedbackBanner(correct:answer==dialogue.answer,title:answer==dialogue.answer ? "Risposta corretta" : "Da rivedere") {
                        Text(answer==dialogue.answer ? "Corretto: \(dialogue.choices[dialogue.answer])." : "La risposta è: \(dialogue.choices[dialogue.answer]). Rileggi il dettaglio nel dialogo.")
                    }
                }
            }
            VStack(alignment:.leading,spacing:10) {
                SectionTitle(title:"Parole da riprendere")
                RowGroup {
                    ForEach(Array(content.words.filter{dialogue.wordIDs.contains($0.id)}.enumerated()),id:\.element.id){i,word in
                        if i>0 {RowDivider(inset:16)}
                        NavigationLink{WordDetail(content:content,word:word)}label:{
                            HStack(spacing:12) {
                                ChineseText(hanzi:word.hanzi,pinyin:word.pinyin).frame(minWidth:80,alignment:.leading)
                                Text(word.italian).font(.subheadline).foregroundStyle(Palette.inkSoft).frame(maxWidth:.infinity,alignment:.leading)
                                Image(systemName:"chevron.right").font(.footnote.weight(.semibold)).foregroundStyle(Palette.inkSoft)
                            }.padding(.horizontal,16).padding(.vertical,10).contentShape(Rectangle())
                        }.buttonStyle(.plain)
                    }
                }
                Button{addWords()}label:{Label(saved ? "Parole aggiunte" : "Aggiungi le parole nuove al ripasso",systemImage:saved ? "checkmark" : "plus")}.buttonStyle(.secondary).disabled(saved)
            }
            if let error=error ?? speech.error{Text(error).font(.footnote).foregroundStyle(Palette.red)}
            Text("Dialogo originale IA, lessico confrontato con il programma HSK 1. Revisione umana ancora da fare.").font(.footnote).foregroundStyle(Palette.inkSoft)
        }.navigationTitle("Unità \(dialogue.id)").navigationBarTitleDisplayMode(.inline).onDisappear{playback?.cancel();speech.stop()}
    }
    /// Due voci alternate come in una conversazione: la prima a sinistra, la seconda a destra.
    func bubble(_ line:ExamSentence,speaker:Int)->some View {
        VStack(alignment:.leading,spacing:6) {
            Text("Voce \(speaker+1)").font(.caption.weight(.semibold)).foregroundStyle(speaker == 0 ? Palette.jade : Palette.red)
            RubySentenceView(sentence:line)
            if translation {Text(line.italian).font(.subheadline).foregroundStyle(Palette.inkSoft)}
        }
        .padding(14)
        .background(speaker == 0 ? Palette.surface : Color(hex:0xFBF8F2),in:RoundedRectangle(cornerRadius:Metrics.radius,style:.continuous))
        .overlay(RoundedRectangle(cornerRadius:Metrics.radius,style:.continuous).strokeBorder(speaker == 0 ? .clear : Palette.line))
        .padding(speaker == 0 ? .trailing : .leading,28)
        .frame(maxWidth:.infinity,alignment:speaker == 0 ? .leading : .trailing)
    }
    func state(_ i:Int)->ChoiceState {
        guard let answer else {return .idle}
        if i==dialogue.answer {return .correct}
        return i==answer ? .wrong : .dimmed
    }
    func play(){playback?.cancel();playback=Task{for(i,line)in dialogue.lines.enumerated(){guard !Task.isCancelled else{return};await speech.speakAndWait(line.hanzi,voiceIndex:i%2)}}}
    func submit(_ index:Int){answer=index;context.insert(StudyEvent(key:"dialogue-\(dialogue.id)",correct:index==dialogue.answer,mode:listening ? "dialogue-listening" : "dialogue-reading",response:dialogue.choices[index]));do{try context.save()}catch{self.error=error.localizedDescription}}
    func addWords(){let existing=Set(cards.map(\.key));for id in dialogue.wordIDs{let key="meaning:\(id)";if !existing.contains(key){context.insert(StudyCard(key:key,contentID:String(id),kind:"meaning"))}};do{try context.save();saved=true}catch{self.error=error.localizedDescription}}
}
