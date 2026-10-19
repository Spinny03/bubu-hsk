import SwiftUI
import Combine
import SwiftData

struct RubyFlow: Layout {
    var spacing: CGFloat = 4
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        arrange(width: proposal.width ?? 330, subviews: subviews).size
    }
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result=arrange(width:bounds.width,subviews:subviews)
        for (i,p) in result.points.enumerated() { subviews[i].place(at: CGPoint(x: bounds.minX+p.x,y:bounds.minY+p.y),proposal:.unspecified) }
    }
    private func arrange(width: CGFloat, subviews: Subviews) -> (size: CGSize,points:[CGPoint]) {
        var x:CGFloat=0,y:CGFloat=0,rowHeight:CGFloat=0,points:[CGPoint]=[]
        for view in subviews {
            let s=view.sizeThatFits(.unspecified)
            if x+s.width>width && x>0 { x=0;y+=rowHeight+8;rowHeight=0 }
            points.append(CGPoint(x:x,y:y));x+=s.width+spacing;rowHeight=max(rowHeight,s.height)
        }
        return (CGSize(width:width,height:y+rowHeight),points)
    }
}
struct RubySentenceView: View {
    let sentence: ExamSentence
    @AppStorage("tonePalette") private var palette="Standard"
    var body: some View {
        RubyFlow {
            ForEach(Array(sentence.tokens.enumerated()), id: \.offset) { _,token in
                VStack(spacing: 1) {
                    Text(token.pinyin.isEmpty ? " " : token.pinyin).font(.caption).foregroundStyle(Palette.tone(PinyinTone.number(token.pinyin),mode:palette))
                    Text(token.hanzi).font(.title3)
                }.fixedSize()
            }
        }.accessibilityElement(children:.ignore).accessibilityLabel("\(sentence.hanzi), \(sentence.pinyin)")
    }
}
struct PictureOptionView: View {
    let option: ExamOption
    var body: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()),count: min(3,max(1,option.count))),spacing:8) {
            ForEach(0..<option.count,id:\.self) { _ in Image(systemName:option.symbol ?? "questionmark").font(.system(size:28)).foregroundStyle(Palette.ink) }
        }.frame(maxWidth:.infinity,minHeight:65).padding(6).background(Palette.paper,in:RoundedRectangle(cornerRadius:10)).accessibilityLabel(option.label)
    }
}
struct ExamLandingView: View {
    let content: Curriculum
    var initialMode: ExamMode = .simulation
    @AppStorage("examVariant") private var variant="Computer"
    @AppStorage("allowGeneratedContent") private var allowGenerated=true
    @State private var mode: ExamMode = .simulation
    @State private var formNumber=1
    @Query private var attempts: [ExamAttempt]
    var body: some View {
        Page {
            Text("Metti insieme\nquello che sai.").font(.system(.largeTitle,design:.serif).bold())
            Text("HSK 1 · 4 parti di ascolto + 4 di lettura").foregroundStyle(.secondary)
            Picker("Modalità di pratica",selection:$mode) { ForEach(ExamMode.allCases,id:\.self) { Text($0.rawValue) } }.pickerStyle(.segmented)
            Panel {
                if mode == .simulation {
                    Text("40 domande · circa 40 minuti").font(.headline)
                    Text("Audio automatico, due letture. Nessun riascolto, nessun aiuto e nessuna correzione prima della fine.")
                    Text("5 minuti per prepararti · ascolto circa 12 minuti · lettura 20 minuti. Su carta: altri 3 minuti per il foglio risposte.").font(.caption).foregroundStyle(.secondary)
                    Picker("Variante",selection:$variant) { Text("Computer").tag("Computer");Text("Carta").tag("Carta") }.pickerStyle(.segmented)
                    Picker("Prova",selection:$formNumber) { ForEach(1...8,id:\.self) { Text("Prova \($0)").tag($0) } }
                    if attempts.contains(where:{ (try? JSONDecoder().decode(ExamSnapshot.self,from:$0.answers).formID) == formNumber && $0.completed != nil }) {
                        Text("Hai già visto questa prova. Ripeterla aiuta a esercitarti, ma non aggiunge evidenza alla stima.").font(.caption).foregroundStyle(Palette.red)
                    }
                    if variant == "Carta" { Text("Prepara un foglio con i numeri da 1 a 40. Segna lì le risposte; riportale nell’app nella fase dedicata. La grafica non riproduce il foglio ufficiale.").font(.caption) }
                } else if mode == .training {
                    Text("Allenati con calma").font(.headline)
                    Text("Riascolto libero, velocità 0,8× e spiegazione dopo ogni risposta. Questi risultati non modificano la stima di preparazione.")
                    Picker("Serie",selection:$formNumber) { ForEach(9...20,id:\.self) { Text("Serie \($0-8)").tag($0) } }
                } else {
                    Text("Da dove cominciare?").font(.headline)
                    Text("20 domande, circa 10–15 minuti. Ascolto e lettura vengono descritti separatamente. È un orientamento: puoi comunque aprire qualsiasi unità.")
                }
            }
            if allowGenerated, let bank=ExamBank.shared, let form=bank.forms.first(where:{$0.id == (mode == .placement ? 20 : formNumber)}) {
                NavigationLink { ExamSessionView(content:content,session:ExamSession(form:form,mode:mode,variant:variant,config:bank.config)) } label: { Label(mode == .placement ? "Inizia il piazzamento" : "Inizia \(mode.rawValue.lowercased())",systemImage:"play.fill").frame(maxWidth:.infinity).padding(8) }.buttonStyle(.borderedProminent).foregroundStyle(.white).accessibilityIdentifier("start-exam")
            } else { Text("Le domande IA sono disattivate nel tuo piano. I contenuti revisionati non sono ancora disponibili.") }
            Panel {
                Label("Contenuti originali · IA",systemImage:"doc.text").font(.headline)
                Text("800 varianti costruite da schemi: 320 riservate alle prove, 480 per allenarti. Controlli automatici su lessico e pinyin; revisione linguistica umana ancora da fare.").font(.caption)
                Text("Voci Apple provvisorie. Nessuna scala né soglia ufficiale di superamento disponibile al 19/10/2026.").font(.caption).foregroundStyle(.secondary)
            }
        }.navigationTitle("Esame").navigationBarTitleDisplayMode(.inline)
            .onAppear { mode=initialMode; formNumber=initialMode == .training ? 9 : 1 }
            .onChange(of:mode) { _,new in formNumber=new == .training ? 9 : 1 }
    }
}
struct ExamSessionView: View {
    let content: Curriculum
    @StateObject var session: ExamSession
    @Environment(\.modelContext) private var context
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.dismiss) private var dismiss
    @State private var slow=false
    @State private var confirmExit=false
    @State private var confirmFinish=false
    let timer=Timer.publish(every:1,on:.main,in:.common).autoconnect()
    var body: some View {
        Page {
            if session.phase == .finished { ExamResultsView(content:content,session:session) }
            else if session.phase == .interrupted {
                Panel { Text("Prova interrotta").font(.title2.bold());Text(session.status);Text("Le risposte sono salvate, ma questa prova non entra nella stima di preparazione.");Button("Torna alle prove") { dismiss() } }
            } else if session.phase == .personalData {
                Panel { Text("Preparati alla prova").font(.title2.bold());Text("Sistema il volume, tieni pronti il documento e il materiale. L’ascolto inizierà automaticamente alla fine dei cinque minuti.");Text(time(session.secondsLeft)).font(.system(.largeTitle,design:.monospaced)).accessibilityIdentifier("exam-countdown");Text("\(session.variant) · 40 domande").foregroundStyle(.secondary) }
            } else {
                questionView
            }
            if let error=session.error { Text(error).foregroundStyle(Palette.red) }
        }.navigationTitle(session.mode.rawValue).navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(session.phase != .finished)
            .toolbar(.hidden,for:.tabBar)
            .toolbar { if session.phase != .finished { ToolbarItem(placement:.topBarTrailing) { Button("Esci") { confirmExit=true } } } }
            .alert("Interrompere la prova?",isPresented:$confirmExit) { Button("Continua",role:.cancel){};Button("Interrompi",role:.destructive){session.interrupt(reason:"Hai interrotto la sessione.");dismiss()} } message: { Text("Le risposte restano salvate. Una simulazione interrotta non entra nella stima.") }
            .alert("Consegna le risposte",isPresented:$confirmFinish) { Button("Torna alla prova",role:.cancel){};Button("Consegna"){session.finish()} } message: { Text("Domande senza risposta: \(session.missing). Dopo la consegna vedrai le spiegazioni.") }
            .onAppear { session.start(context:context) }
            .onDisappear { if session.phase != .finished { session.interrupt(reason:"La schermata della prova è stata chiusa.") };session.stop() }
            .onReceive(timer) { _ in session.tick() }
            .onChange(of:scenePhase) { _,phase in if phase == .background && session.mode == .simulation { session.interrupt(reason:"L’app è passata in secondo piano. La prova rigorosa non può essere sospesa.") } }
    }
    var questionView: some View {
        VStack(alignment:.leading,spacing:14) {
            HStack { Text(session.current.title).font(.headline);Spacer();Text("\(session.snapshot.index+1)/\(session.questions.count)").monospacedDigit() }
            if session.mode == .simulation || session.mode == .placement { HStack { Text(session.status).font(.caption);Spacer();Text(time(session.secondsLeft)).font(.callout.monospacedDigit()) } }
            if session.phase == .transfer {
                Panel { Text("Riporta le 20 risposte di ascolto").font(.headline);Text("Seleziona il numero e trascrivi la lettera dal tuo foglio. Non è possibile riascoltare.");numberGrid(listening:true) }
            }
            if let example=session.current.example {
                Panel {
                    Text("Esempio → \(session.current.exampleAnswer ?? "F") · opzione già usata").font(.caption.bold())
                    if !session.current.listening || session.mode != .simulation { RubySentenceView(sentence:example) }
                }
            }
            if session.current.listening {
                if session.mode != .simulation {
                    Button { playQuestion() } label: { Label("Ascolta",systemImage:"speaker.wave.2.fill").frame(maxWidth:.infinity,minHeight:44) }.buttonStyle(.borderedProminent).foregroundStyle(.white).accessibilityIdentifier("replay-audio")
                    if session.mode == .training { Toggle("Audio a 0,8×",isOn:$slow) }
                } else { Label("Ascolto automatico · 2 letture",systemImage:"waveform").font(.subheadline).foregroundStyle(Palette.jade) }
            } else {
                ForEach(session.current.stimulus,id:\.self) { line in Panel { RubySentenceView(sentence:line) } }
                if let prompt=session.current.prompt { Panel { RubySentenceView(sentence:prompt) } }
            }
            if session.current.options.first?.symbol != nil {
                LazyVGrid(columns:[GridItem(.flexible()),GridItem(.flexible())],spacing:10) { ForEach(session.current.options) { option in optionButton(option) } }
            } else { ForEach(session.current.options) { option in optionButton(option) } }
            if session.mode == .training && session.answerConfirmed {
                ExamExplanation(question:session.current,choice:session.snapshot.choices[session.current.id],speech:session.speech)
            }
            if session.mode != .simulation {
                Button(session.snapshot.index+1 == session.questions.count ? "Concludi" : "Prossima domanda") { session.next() }.buttonStyle(.borderedProminent).foregroundStyle(.white).disabled(session.snapshot.choices[session.current.id]==nil).accessibilityIdentifier("next-exam")
            } else if session.phase == .reading {
                HStack { Button("Precedente"){session.go(to:session.snapshot.index-1)}.disabled(session.snapshot.index<=20);Spacer();Button("Successiva"){session.go(to:session.snapshot.index+1)}.disabled(session.snapshot.index==39) }
                Button { session.bookmark() } label: { Label(session.snapshot.bookmarks.contains(session.current.id) ? "Rimuovi segnalibro" : "Segna da rivedere",systemImage:"bookmark") }
                numberGrid(listening:false)
                Text("\(session.missing) risposte mancanti in tutta la prova").font(.caption)
                Button("Consegna la prova"){confirmFinish=true}.buttonStyle(.borderedProminent).foregroundStyle(.white)
            }
        }
    }
    func optionButton(_ option: ExamOption) -> some View {
        Button { session.choose(option.id) } label: {
            HStack(alignment:.center,spacing:10) {
                Text(option.id).font(.headline).frame(width:20)
                if option.symbol != nil { PictureOptionView(option:option) }
                else if let text=option.text { RubySentenceView(sentence:text) }
                if session.snapshot.choices[session.current.id] == option.id { Image(systemName:"checkmark.circle.fill").foregroundStyle(Palette.jade) }
            }.frame(maxWidth:.infinity,minHeight:44,alignment:.leading).padding(12)
                .background(session.snapshot.choices[session.current.id] == option.id ? Palette.jade.opacity(0.12) : .white,in:RoundedRectangle(cornerRadius:14))
        }.buttonStyle(.plain).disabled(option.id == session.current.exampleAnswer || (session.mode != .simulation && session.answerConfirmed)).opacity(option.id == session.current.exampleAnswer ? 0.45 : 1).accessibilityIdentifier("exam-option-\(option.id)")
    }
    func numberGrid(listening:Bool) -> some View {
        LazyVGrid(columns:Array(repeating:GridItem(.flexible()),count:5),spacing:6) {
            ForEach(session.questions.indices.filter { session.questions[$0].listening == listening },id:\.self) { i in
                let q=session.questions[i]
                Button { session.go(to:i) } label: {
                    VStack(spacing:2) { Text("\(i+1)");Text(session.snapshot.choices[q.id] ?? "—").font(.caption);if session.snapshot.bookmarks.contains(q.id){Image(systemName:"bookmark.fill").font(.caption2)} }.frame(maxWidth:.infinity,minHeight:44).background(i==session.snapshot.index ? Palette.jade.opacity(0.2) : .white,in:RoundedRectangle(cornerRadius:8))
                }.buttonStyle(.plain)
            }
        }
    }
    func playQuestion() { session.speech.speak(session.current.audio.map(\.hanzi).joined(separator:" "),slow:slow && session.mode == .training) }
    func time(_ value:Int)->String { String(format:"%02d:%02d",value/60,value%60) }
}
struct ExamExplanation: View {
    let question: ExamQuestion
    let choice: String?
    @ObservedObject var speech: SpeechPlayer
    var body: some View {
        Panel {
            Label(choice == question.answer ? "Risposta corretta" : "Risposta: \(question.answer)",systemImage:choice == question.answer ? "checkmark.circle" : "arrow.uturn.backward").font(.headline).foregroundStyle(choice == question.answer ? Palette.jade : Palette.red)
            ForEach(question.audio,id:\.self) { line in RubySentenceView(sentence:line);Text(line.italian).font(.subheadline) }
            Text(question.explanation).font(.subheadline)
            ForEach(question.options) { option in Text("\(option.id): \(option.label)\(option.id == question.answer ? " · risposta corretta" : "")").font(.caption) }
            if question.listening { Button("Riascolta con la trascrizione") { speech.speak(question.audio.map(\.hanzi).joined(separator:" ")) } }
        }.accessibilityIdentifier("exam-feedback")
    }
}
struct ExamResultsView: View {
    let content: Curriculum
    @ObservedObject var session: ExamSession
    @Environment(\.modelContext) private var context
    @State private var cause="Parola sconosciuta"
    var body: some View {
        VStack(alignment:.leading,spacing:14) {
            Text(session.mode == .placement ? "Il tuo punto di partenza" : "La prova è conclusa").font(.system(.title,design:.serif).bold())
            Panel {
                Text("\(session.score)/\(session.questions.count) risposte corrette").font(.title.bold()).foregroundStyle(Palette.jade)
                Text("Conteggio grezzo, non un punteggio ufficiale. Non è disponibile una soglia ufficiale di superamento.").font(.caption)
                if session.mode == .placement {
                    ForEach([true,false],id:\.self) { listen in
                        let subset=session.questions.filter { $0.listening == listen };let correct=subset.filter { session.snapshot.choices[$0.id] == $0.answer }.count
                        Text("\(listen ? "Ascolto" : "Lettura"): \(correct)/\(subset.count)")
                    }
                    Text("Riparti dalle unità con parole sconosciute. Puoi saltare liberamente quelle già note; questo test non certifica un livello.").font(.subheadline)
                }
            }
            ForEach(1...8,id:\.self) { part in
                let qs=session.questions.filter{$0.part==part}
                HStack { Text("\(part<=4 ? "Ascolto" : "Lettura") \(part<=4 ? part : part-4)");Spacer();Text("\(qs.filter{session.snapshot.choices[$0.id]==$0.answer}.count)/\(qs.count)").bold() }.font(.subheadline)
            }
            Text("Le parole dei quesiti sbagliati sono disponibili nel ripasso, senza attribuire automaticamente un errore a ciascuna parola.").font(.caption).foregroundStyle(.secondary)
            SectionTitle(title:"Correzione completa")
            ForEach(session.questions) { question in
                DisclosureGroup("\(question.title) · \(question.id) · \(session.snapshot.choices[question.id] ?? "—")") {
                    ExamExplanation(question:question,choice:session.snapshot.choices[question.id],speech:session.speech)
                    if session.snapshot.choices[question.id] != question.answer {
                        Picker("Causa da riprendere",selection:$cause) { ForEach(["Parola sconosciuta","Tono","Grammatica","Domanda fraintesa","Tempo"],id:\.self){Text($0)} }
                        Button("Salva la causa") { context.insert(StudyEvent(key:question.id,correct:false,mode:"exam-cause",response:cause));do{try context.save()}catch{session.error=error.localizedDescription} }
                    }
                }
            }
        }
    }
}
