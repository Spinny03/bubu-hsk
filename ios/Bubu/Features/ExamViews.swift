import SwiftUI
import Combine
import SwiftData

/// Regole di a capo cinesi: la punteggiatura di chiusura non apre una riga (避头 bìtóu),
/// quella di apertura non la chiude (避尾 bìwěi). Lo spazio del quesito resta tra le sue parentesi.
struct NoLineStart: LayoutValueKey { static let defaultValue = false }
struct NoLineEnd: LayoutValueKey { static let defaultValue = false }
struct RubyFlow: Layout {
    var spacing: CGFloat = 4
    var lineSpacing: CGFloat = 10
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        arrange(width: proposal.width ?? 330, subviews: subviews).size
    }
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result=arrange(width:bounds.width,subviews:subviews)
        for (i,p) in result.points.enumerated() { subviews[i].place(at: CGPoint(x: bounds.minX+p.x,y:bounds.minY+p.y),proposal:.unspecified) }
    }
    private func arrange(width: CGFloat, subviews: Subviews) -> (size: CGSize,points:[CGPoint]) {
        var x:CGFloat=0,y:CGFloat=0,rowHeight:CGFloat=0,rowStart=0,points:[CGPoint]=[]
        let sizes=subviews.map { $0.sizeThatFits(.unspecified) }
        for i in subviews.indices {
            let s=sizes[i]
            if x+s.width>width && x>0 {
                // Arretra finché la nuova riga può cominciare qui; se l'intera riga è legata, va a capo senza spostare nulla.
                var start=i
                while start>rowStart && (subviews[start][NoLineStart.self] || subviews[start-1][NoLineEnd.self]) { start-=1 }
                if start==rowStart { start=i }
                y+=rowHeight+lineSpacing;x=0;rowHeight=0
                for k in start..<i { points[k]=CGPoint(x:x,y:y);x+=sizes[k].width+spacing;rowHeight=max(rowHeight,sizes[k].height) }
                rowStart=start
            }
            points.append(CGPoint(x:x,y:y));x+=s.width+spacing;rowHeight=max(rowHeight,s.height)
        }
        return (CGSize(width:width,height:y+rowHeight),points)
    }
}
/// Pinyin sempre sopra ogni carattere, colorato secondo la scelta dei toni nel piano.
struct RubySentenceView: View {
    private static let closing: Set<String> = ["。","？","，","）","：","！","、","；","”"," "]
    private static let opening: Set<String> = ["（","“"," "]
    let sentence: ExamSentence
    var large = false
    @AppStorage("tonePalette") private var palette="Standard"
    var body: some View {
        RubyFlow {
            ForEach(Array(sentence.tokens.enumerated()), id: \.offset) { _,token in
                VStack(spacing: 0) {
                    Text(token.pinyin.isEmpty ? " " : token.pinyin).font(large ? .footnote : .caption).foregroundStyle(Palette.tone(PinyinTone.number(token.pinyin),mode:palette))
                    Text(token.hanzi).font(.hanzi(large ? 26 : 22, relativeTo: .title2))
                }.fixedSize()
                    .layoutValue(key: NoLineStart.self, value: Self.closing.contains(token.hanzi))
                    .layoutValue(key: NoLineEnd.self, value: Self.opening.contains(token.hanzi))
            }
        }.accessibilityElement(children:.ignore).accessibilityLabel("\(sentence.hanzi), \(sentence.pinyin)")
    }
}
struct PictureOptionView: View {
    let option: ExamOption
    var body: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 4),count: min(3,max(1,option.count))),spacing:6) {
            ForEach(0..<option.count,id:\.self) { _ in Image(systemName:option.symbol ?? "questionmark").font(.system(size:24)).foregroundStyle(Palette.ink) }
        }.frame(maxWidth:.infinity,minHeight:56).accessibilityElement(children:.ignore).accessibilityLabel(option.label)
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
        Page(spacing: 18) {
            Text("HSK 1 · 4 parti di ascolto + 4 di lettura").font(.subheadline).foregroundStyle(Palette.inkSoft)
            Picker("Modalità di pratica",selection:$mode) { ForEach(ExamMode.allCases,id:\.self) { Text($0.rawValue) } }.pickerStyle(.segmented)
            Panel(padding: 18, spacing: 14) {
                if mode == .simulation {
                    Text("40 domande · circa 40 minuti").font(.title3.weight(.semibold))
                    FactRow(icon: "speaker.wave.2", text: "Audio automatico, due letture. Nessun riascolto, nessun aiuto e nessuna correzione prima della fine.")
                    FactRow(icon: "clock", text: "5 minuti per prepararti · ascolto circa 12 minuti · lettura 20 minuti. Su carta: altri 3 minuti per il foglio risposte.")
                    Rectangle().fill(Palette.line).frame(height: 0.5)
                    Picker("Variante",selection:$variant) { Text("Computer").tag("Computer");Text("Carta").tag("Carta") }.pickerStyle(.segmented)
                    HStack { Text("Prova").font(.subheadline.weight(.medium)); Spacer(); Picker("Prova",selection:$formNumber) { ForEach(1...8,id:\.self) { Text("Prova \($0)").tag($0) } }.labelsHidden() }
                    if attempts.contains(where:{ (try? JSONDecoder().decode(ExamSnapshot.self,from:$0.answers).formID) == formNumber && $0.completed != nil }) {
                        Label("Hai già visto questa prova. Ripeterla aiuta a esercitarti, ma non aggiunge evidenza alla stima.", systemImage: "info.circle").font(.footnote).foregroundStyle(Palette.red)
                    }
                    if variant == "Carta" { Label("Prepara un foglio con i numeri da 1 a 40. Segna lì le risposte; riportale nell’app nella fase dedicata. La grafica non riproduce il foglio ufficiale.", systemImage: "doc.plaintext").font(.footnote) }
                } else if mode == .training {
                    Text("Allenati con calma").font(.title3.weight(.semibold))
                    FactRow(icon: "arrow.counterclockwise", text: "Riascolto libero e velocità 0,8×.")
                    FactRow(icon: "text.bubble", text: "Spiegazione dopo ogni risposta.")
                    FactRow(icon: "chart.bar.xaxis", text: "Questi risultati non modificano la stima di preparazione.")
                    Rectangle().fill(Palette.line).frame(height: 0.5)
                    HStack { Text("Serie").font(.subheadline.weight(.medium)); Spacer(); Picker("Serie",selection:$formNumber) { ForEach(9...20,id:\.self) { Text("Serie \($0-8)").tag($0) } }.labelsHidden() }
                } else {
                    Text("Da dove cominciare?").font(.title3.weight(.semibold))
                    FactRow(icon: "clock", text: "20 domande, circa 10–15 minuti.")
                    FactRow(icon: "square.split.2x1", text: "Ascolto e lettura vengono descritti separatamente.")
                    FactRow(icon: "map", text: "È un orientamento: puoi comunque aprire qualsiasi unità.")
                }
            }
            if allowGenerated, let bank=ExamBank.shared, let form=bank.forms.first(where:{$0.id == (mode == .placement ? 20 : formNumber)}) {
                NavigationLink { ExamSessionView(content:content,session:ExamSession(form:form,mode:mode,variant:variant,config:bank.config)) } label: {
                    Label(mode == .placement ? "Inizia il piazzamento" : "Inizia \(mode.rawValue.lowercased())",systemImage:"play.fill")
                }.buttonStyle(.primary).accessibilityIdentifier("start-exam")
            } else {
                Label("Le domande IA sono disattivate nel tuo piano. I contenuti revisionati non sono ancora disponibili.", systemImage: "eye.slash").font(.subheadline).foregroundStyle(Palette.inkSoft)
            }
            VStack(alignment: .leading, spacing: 6) {
                Label("Contenuti originali · IA",systemImage:"doc.text").font(.footnote.weight(.semibold))
                Text("800 varianti costruite da schemi: 320 riservate alle prove, 480 per allenarti. Controlli automatici su lessico e pinyin; revisione linguistica umana ancora da fare.")
                Text("Voci Apple provvisorie. Nessuna scala né soglia ufficiale di superamento disponibile al 19/10/2026.")
            }.font(.footnote).foregroundStyle(Palette.inkSoft).padding(.horizontal, 4)
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
        ScrollViewReader { proxy in
            Page(spacing: 16) {
                if session.phase == .finished { ExamResultsView(content:content,session:session) }
                else if session.phase == .interrupted {
                    VStack(spacing: 12) {
                        Image(systemName: "pause.circle").font(.system(size: 48)).foregroundStyle(Palette.inkSoft).accessibilityHidden(true)
                        Text("Prova interrotta").font(.screenTitle)
                        Text(session.status).font(.subheadline)
                        Text("Le risposte sono salvate, ma questa prova non entra nella stima di preparazione.").font(.footnote).foregroundStyle(Palette.inkSoft)
                    }.multilineTextAlignment(.center).frame(maxWidth: .infinity).padding(.top, 32).padding(.bottom, 8)
                    Button("Torna alle prove") { dismiss() }.buttonStyle(.primary)
                } else if session.phase == .personalData {
                    VStack(spacing: 14) {
                        Text("Preparati alla prova").font(.screenTitle)
                        Text("Sistema il volume, tieni pronti il documento e il materiale. L’ascolto inizierà automaticamente alla fine dei cinque minuti.").font(.subheadline)
                        Text(time(session.secondsLeft)).font(.system(.largeTitle, design: .rounded).weight(.semibold)).monospacedDigit().accessibilityIdentifier("exam-countdown")
                        Text("\(session.variant) · 40 domande").font(.footnote).foregroundStyle(Palette.inkSoft)
                    }
                    .multilineTextAlignment(.center).frame(maxWidth: .infinity).padding(24)
                    .background(Palette.surface, in: RoundedRectangle(cornerRadius: Metrics.radius, style: .continuous))
                } else {
                    questionView
                }
                if let error=session.error { Text(error).font(.footnote).foregroundStyle(Palette.red) }
            }
            .onChange(of: session.snapshot.index) { _, _ in proxy.scrollTo("question-top", anchor: .top) }
            .onChange(of: session.answerConfirmed) { _, confirmed in
                if confirmed && session.mode == .training { DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) { withAnimation(.easeOut(duration: 0.3)) { proxy.scrollTo("next-question", anchor: .bottom) } } }
            }
        }
        .navigationTitle(session.mode.rawValue).navigationBarTitleDisplayMode(.inline)
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
        let chosen=session.snapshot.choices[session.current.id]
        return VStack(alignment:.leading,spacing:16) {
            VStack(alignment:.leading,spacing:8) {
                HStack(alignment:.firstTextBaseline) {
                    Text(session.current.title).font(.headline)
                    Spacer()
                    Text("\(session.snapshot.index+1)/\(session.questions.count)").font(.subheadline.weight(.semibold)).monospacedDigit().foregroundStyle(Palette.inkSoft)
                }
                Meter(value:Double(session.snapshot.index+1)/Double(max(1,session.questions.count)),tint:Palette.ink,height:4)
                if session.mode == .simulation || session.mode == .placement {
                    HStack(alignment:.firstTextBaseline) {
                        Text(session.status).font(.footnote).foregroundStyle(Palette.inkSoft)
                        Spacer()
                        Label(time(session.secondsLeft),systemImage:"timer").font(.subheadline.weight(.semibold)).monospacedDigit()
                    }
                }
            }.id("question-top")
            if session.phase == .transfer {
                Panel { Text("Riporta le 20 risposte di ascolto").font(.headline);Text("Seleziona il numero e trascrivi la lettera dal tuo foglio. Non è possibile riascoltare.").font(.subheadline);answerSheet(listening:true) }
            }
            if let example=session.current.example {
                VStack(alignment:.leading,spacing:8) {
                    Label("Esempio · risposta \(session.current.exampleAnswer ?? "F") · opzione già usata",systemImage:"lightbulb").font(.footnote.weight(.semibold)).foregroundStyle(Palette.inkSoft)
                    if !session.current.listening || session.mode != .simulation { RubySentenceView(sentence:example) }
                }
                .padding(14).frame(maxWidth:.infinity,alignment:.leading)
                .background(Palette.sunken,in:RoundedRectangle(cornerRadius:14,style:.continuous))
            }
            if session.current.listening {
                if session.mode != .simulation {
                    HStack(spacing:10) {
                        Button { playQuestion() } label: { Label("Ascolta",systemImage:"speaker.wave.2.fill") }.buttonStyle(.primary).accessibilityIdentifier("replay-audio")
                        if session.mode == .training { Toggle("0,8×",isOn:$slow).toggleStyle(.chip).accessibilityLabel("Audio a 0,8×") }
                    }
                } else {
                    Label("Ascolto automatico · 2 letture",systemImage:"waveform").font(.subheadline.weight(.medium)).foregroundStyle(Palette.jade)
                        .padding(.horizontal,14).frame(maxWidth:.infinity,minHeight:48,alignment:.leading)
                        .background(Color(hex:0xE6F0EC),in:RoundedRectangle(cornerRadius:14,style:.continuous))
                }
            } else if !session.current.stimulus.isEmpty || session.current.prompt != nil {
                Panel(padding:18,spacing:14) {
                    ForEach(session.current.stimulus,id:\.self) { line in RubySentenceView(sentence:line,large:true) }
                    if let prompt=session.current.prompt {
                        if !session.current.stimulus.isEmpty { Rectangle().fill(Palette.line).frame(height:0.5) }
                        RubySentenceView(sentence:prompt,large:true)
                    }
                }
            }
            if session.current.options.first?.symbol != nil {
                LazyVGrid(columns:[GridItem(.flexible(),spacing:10),GridItem(.flexible())],spacing:10) { ForEach(session.current.options) { option in optionButton(option) } }
            } else { VStack(spacing:10) { ForEach(session.current.options) { option in optionButton(option) } } }
            if session.mode == .training && session.answerConfirmed {
                ExamExplanation(question:session.current,choice:chosen,speech:session.speech)
            }
            if session.mode != .simulation {
                Button(session.snapshot.index+1 == session.questions.count ? "Concludi" : "Prossima domanda") { session.next() }
                    .buttonStyle(.primary).disabled(chosen==nil).accessibilityIdentifier("next-exam").id("next-question")
            } else if session.phase == .reading {
                HStack(spacing:10) {
                    Button{session.go(to:session.snapshot.index-1)} label:{ HStack(spacing:6) { Image(systemName:"chevron.left"); Text("Precedente") } }.buttonStyle(.secondary).disabled(session.snapshot.index<=20)
                    Button{session.go(to:session.snapshot.index+1)} label:{ HStack(spacing:6) { Text("Successiva"); Image(systemName:"chevron.right") } }.buttonStyle(.secondary).disabled(session.snapshot.index==39)
                }
                let marked=session.snapshot.bookmarks.contains(session.current.id)
                Button { session.bookmark() } label: { Label(marked ? "Rimuovi segnalibro" : "Segna da rivedere",systemImage:marked ? "bookmark.fill" : "bookmark") }.buttonStyle(.secondary)
                VStack(alignment:.leading,spacing:10) {
                    SectionTitle(title:"Foglio risposte · lettura")
                    answerSheet(listening:false)
                    Text("\(session.missing) risposte mancanti in tutta la prova").font(.footnote).foregroundStyle(Palette.inkSoft).padding(.horizontal,4)
                }
                Button("Consegna la prova"){confirmFinish=true}.buttonStyle(.primary)
            }
        }
    }
    func optionButton(_ option: ExamOption) -> some View {
        let isExample=option.id == session.current.exampleAnswer
        return ChoiceButton(state:optionState(option)) { session.choose(option.id) } label: {
            if option.symbol != nil {
                VStack(alignment:.leading,spacing:6) { letter(option.id); PictureOptionView(option:option) }
            } else {
                HStack(alignment:.center,spacing:12) {
                    letter(option.id)
                    if let text=option.text { RubySentenceView(sentence:text) }
                }
            }
        }
        .disabled(isExample || (session.mode != .simulation && session.answerConfirmed))
        .opacity(isExample ? 0.45 : 1)
        .accessibilityHint(isExample ? "Usata nell’esempio" : "")
        .accessibilityIdentifier("exam-option-\(option.id)")
    }
    /// Simulazione e piazzamento mostrano solo la selezione; la correzione compare subito solo in allenamento.
    func optionState(_ option: ExamOption) -> ChoiceState {
        let chosen=session.snapshot.choices[session.current.id]
        if option.id == session.current.exampleAnswer { return .dimmed }
        if session.mode == .training && session.answerConfirmed {
            if option.id == session.current.answer { return .correct }
            return option.id == chosen ? .wrong : .dimmed
        }
        return option.id == chosen ? .selected : .idle
    }
    func letter(_ id: String) -> some View {
        Text(id).font(.subheadline.weight(.bold)).frame(width:30,height:30).overlay(Circle().strokeBorder(Palette.ink.opacity(0.25)))
    }
    /// Foglio risposte: numero, lettera scelta, domanda corrente e segnalibri.
    func answerSheet(listening:Bool) -> some View {
        LazyVGrid(columns:Array(repeating:GridItem(.flexible(),spacing:6),count:5),spacing:6) {
            ForEach(session.questions.indices.filter { session.questions[$0].listening == listening },id:\.self) { i in
                let q=session.questions[i]
                let choice=session.snapshot.choices[q.id]
                let current=i==session.snapshot.index
                let marked=session.snapshot.bookmarks.contains(q.id)
                Button { session.go(to:i) } label: {
                    VStack(spacing:1) {
                        Text("\(i+1)").font(.caption2).monospacedDigit().foregroundStyle(Palette.inkSoft)
                        Text(choice ?? "—").font(.headline)
                    }
                    .frame(maxWidth:.infinity,minHeight:48)
                    .background(choice == nil ? Palette.sunken : Palette.surface,in:RoundedRectangle(cornerRadius:10,style:.continuous))
                    .overlay(RoundedRectangle(cornerRadius:10,style:.continuous).strokeBorder(current ? Palette.ink : .clear,lineWidth:2))
                    .overlay(alignment:.topTrailing) { if marked { Image(systemName:"bookmark.fill").font(.caption2).foregroundStyle(Palette.red).padding(4) } }
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Domanda \(i+1), \(choice.map { "risposta \($0)" } ?? "senza risposta")\(marked ? ", segnata" : "")")
                .accessibilityAddTraits(current ? .isSelected : [])
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
        let right=choice == question.answer
        FeedbackBanner(correct:right,title:right ? "Risposta corretta" : "Risposta: \(question.answer)") {
            VStack(alignment:.leading,spacing:12) {
                ForEach(question.audio,id:\.self) { line in
                    VStack(alignment:.leading,spacing:4) { RubySentenceView(sentence:line);Text(line.italian).foregroundStyle(Palette.inkSoft) }
                }
                Text(question.explanation)
                VStack(alignment:.leading,spacing:3) {
                    ForEach(question.options) { option in
                        Text("\(option.id): \(option.label)\(option.id == question.answer ? " · risposta corretta" : "")")
                            .font(.footnote.weight(option.id == question.answer ? .semibold : .regular))
                            .foregroundStyle(option.id == question.answer ? Palette.jade : Palette.inkSoft)
                    }
                }
                if question.listening {
                    Button { speech.speak(question.audio.map(\.hanzi).joined(separator:" ")) } label: { Label("Riascolta con la trascrizione",systemImage:"speaker.wave.2.fill") }.buttonStyle(.secondary)
                }
            }
        }.accessibilityIdentifier("exam-feedback")
    }
}
struct ExamResultsView: View {
    let content: Curriculum
    @ObservedObject var session: ExamSession
    @Environment(\.modelContext) private var context
    @State private var cause="Parola sconosciuta"
    @State private var savedCauses=Set<String>()
    var body: some View {
        VStack(alignment:.leading,spacing:22) {
            ScreenHeader(title:session.mode == .placement ? "Il tuo punto di partenza" : "La prova è conclusa")
            Panel(spacing:10) {
                HStack(alignment:.firstTextBaseline,spacing:8) {
                    Text("\(session.score)").font(.system(.largeTitle,design:.serif).weight(.bold)).monospacedDigit()
                    Text("/\(session.questions.count) risposte corrette").font(.headline).foregroundStyle(Palette.inkSoft)
                }.accessibilityElement(children:.combine)
                Text("Conteggio grezzo, non un punteggio ufficiale. Non è disponibile una soglia ufficiale di superamento.").font(.footnote).foregroundStyle(Palette.inkSoft)
                if session.mode == .placement {
                    Rectangle().fill(Palette.line).frame(height:0.5)
                    HStack(spacing:28) {
                        ForEach([true,false],id:\.self) { listen in
                            let subset=session.questions.filter { $0.listening == listen }
                            let correct=subset.filter { session.snapshot.choices[$0.id] == $0.answer }.count
                            VStack(alignment:.leading,spacing:2) {
                                Text(listen ? "Ascolto" : "Lettura").font(.footnote).foregroundStyle(Palette.inkSoft)
                                Text("\(correct)/\(subset.count)").font(.title3.weight(.semibold)).monospacedDigit()
                            }.accessibilityElement(children:.combine)
                        }
                    }
                    Text("Riparti dalle unità con parole sconosciute. Puoi saltare liberamente quelle già note; questo test non certifica un livello.").font(.subheadline)
                }
            }
            VStack(alignment:.leading,spacing:10) {
                SectionTitle(title:"Per parte")
                RowGroup {
                    ForEach(1...8,id:\.self) { part in
                        let qs=session.questions.filter{$0.part==part}
                        let correct=qs.filter{session.snapshot.choices[$0.id]==$0.answer}.count
                        if part>1 { RowDivider(inset:16) }
                        HStack(spacing:12) {
                            Text("\(part<=4 ? "Ascolto" : "Lettura") \(part<=4 ? part : part-4)").font(.subheadline)
                            Spacer()
                            Meter(value:qs.isEmpty ? 0 : Double(correct)/Double(qs.count),height:4).frame(width:72)
                            Text("\(correct)/\(qs.count)").font(.subheadline.weight(.semibold)).monospacedDigit().frame(minWidth:34,alignment:.trailing)
                        }
                        .padding(.horizontal,16).frame(minHeight:44)
                        .accessibilityElement(children:.combine)
                    }
                }
                Text("Le parole dei quesiti sbagliati sono disponibili nel ripasso, senza attribuire automaticamente un errore a ciascuna parola.").font(.footnote).foregroundStyle(Palette.inkSoft).padding(.horizontal,4)
            }
            VStack(alignment:.leading,spacing:10) {
                SectionTitle(title:"Correzione completa")
                RowGroup {
                    ForEach(Array(session.questions.enumerated()),id:\.element.id) { i,question in
                        let choice=session.snapshot.choices[question.id]
                        let right=choice == question.answer
                        if i>0 { RowDivider(inset:16) }
                        DisclosureGroup {
                            VStack(alignment:.leading,spacing:12) {
                                ExamExplanation(question:question,choice:choice,speech:session.speech)
                                if !right {
                                    HStack {
                                        Text("Causa").font(.subheadline)
                                        Spacer()
                                        Picker("Causa da riprendere",selection:$cause) { ForEach(["Parola sconosciuta","Tono","Grammatica","Domanda fraintesa","Tempo"],id:\.self){Text($0)} }.labelsHidden()
                                    }
                                    Button(savedCauses.contains(question.id) ? "Causa salvata" : "Salva la causa") {
                                        context.insert(StudyEvent(key:question.id,correct:false,mode:"exam-cause",response:cause))
                                        do { try context.save(); savedCauses.insert(question.id) } catch { context.rollback(); session.error=error.localizedDescription }
                                    }.buttonStyle(.secondary).disabled(savedCauses.contains(question.id))
                                }
                            }.padding(.top,10)
                        } label: {
                            HStack(spacing:10) {
                                Image(systemName:right ? "checkmark.circle.fill" : "xmark.circle.fill").foregroundStyle(right ? Palette.jade : Palette.red).accessibilityHidden(true)
                                VStack(alignment:.leading,spacing:1) {
                                    Text("\(i+1). \(question.title)").font(.subheadline.weight(.medium)).foregroundStyle(Palette.ink)
                                    Text("Tua risposta: \(choice ?? "—")\(right ? "" : " · corretta: \(question.answer)")").font(.footnote).foregroundStyle(Palette.inkSoft)
                                }
                            }
                            .accessibilityElement(children:.combine)
                            .accessibilityValue(right ? "Corretta" : "Errata")
                        }
                        .tint(Palette.inkSoft)
                        .padding(.horizontal,16).padding(.vertical,10)
                    }
                }
            }
        }
    }
}
