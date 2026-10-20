import SwiftUI
struct TonePracticeView:View {
    let content:Curriculum
    @StateObject private var recorder=PitchRecorder()
    @StateObject private var speech=SpeechPlayer()
    @State private var selected="hao"
    @State private var voice=0
    var exercise:ToneExercise {ToneExercise.all.first{$0.id==selected} ?? ToneExercise.all[0]}
    var body:some View {
        Page(spacing:20) {
            Text("Prima ascolta il modello, poi guarda la curva della tua voce.").font(.subheadline).foregroundStyle(Palette.inkSoft)
            ScrollView(.horizontal,showsIndicators:false) {
                HStack(spacing:8) {
                    ForEach(ToneExercise.all) {item in
                        let active=item.id==selected
                        Button {selected=item.id} label:{
                            VStack(spacing:0) {Text(item.pinyin).font(.caption);Text(item.hanzi).font(.hanzi(22,relativeTo:.title2))}
                                .foregroundStyle(active ? Palette.paper : Palette.ink)
                                .padding(.horizontal,16).padding(.vertical,8).frame(minHeight:44)
                                .background(active ? Palette.ink : Palette.surface,in:RoundedRectangle(cornerRadius:12,style:.continuous))
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("\(item.hanzi), \(item.pinyin)").accessibilityAddTraits(active ? .isSelected : [])
                    }
                }.padding(.horizontal,16)
            }.padding(.horizontal,-16)
            Panel(padding:20,spacing:16) {
                HanziHero(hanzi:exercise.hanzi,pinyin:exercise.pinyin)
                Text(exercise.advice).font(.subheadline)
                Button {recorder.stop();speech.speak(exercise.hanzi,voiceIndex:voice)} label:{Label("Ascolta il modello",systemImage:"speaker.wave.2.fill")}.buttonStyle(.secondary)
                if speech.voices.count>1 {
                    HStack {Text("Voce Apple").font(.subheadline);Spacer();Picker("Voce Apple",selection:$voice){ForEach(speech.voices.indices,id:\.self){Text(speech.voices[$0].name).tag($0)}}.labelsHidden()}
                } else {Text("Su questo dispositivo è disponibile una sola voce cinese.").font(.footnote).foregroundStyle(Palette.inkSoft)}
            }
            VStack(alignment:.leading,spacing:10) {
                SectionTitle(title:"La tua voce",detail:recorder.baseline == nil ? "Voce non calibrata" : "Voce calibrata")
                Panel(padding:20,spacing:16) {
                    PitchChart(frames:recorder.frames,baseline:recorder.baseline).frame(height:140)
                    if !recorder.frames.isEmpty && !recorder.recording {
                        VStack(alignment:.leading,spacing:4) {
                            if exercise.pattern.count==1 {
                                let feedback=ToneFeedback.analyze(recorder.frames,baseline:recorder.baseline)
                                Text(feedback.recognized).font(.headline);Text(feedback.advice).font(.subheadline)
                            } else {
                                Text("Confronta le due sillabe").font(.headline)
                                Text(exercise.advice).font(.subheadline)
                                Text("La curva non separa automaticamente le sillabe: non attribuiamo un tono unico all’intera parola.").font(.footnote).foregroundStyle(Palette.inkSoft)
                            }
                        }
                    }
                    RecordButton(recording:recorder.recording,title:recorder.recording ? "Ferma" : "Registra fino a 5 secondi") {speech.stop();if recorder.recording{recorder.stop()}else{Task{await recorder.start()}}}
                        .frame(maxWidth:.infinity)
                    Button(recorder.baseline == nil ? "Calibra la voce: una ‘a’ naturale" : "Ricalibra la voce") {speech.stop();Task{await recorder.start(calibration:true)}}
                        .buttonStyle(.secondary).disabled(recorder.recording)
                    Text("Indicazione orientativa, senza voto. La curva mostra l’altezza rilevata sul dispositivo; non sostituisce l’ascolto di un insegnante.").font(.footnote).foregroundStyle(Palette.inkSoft)
                    if let error=recorder.error ?? speech.error {Text(error).font(.footnote).foregroundStyle(Palette.red)}
                }
            }
            NavigationLink {StudySessionView(content:content,initialQueue:ToneExercise.all.map{ReviewItem(contentID:$0.id,kind:"tone")})} label:{Label("Allena l’orecchio nel ripasso",systemImage:"ear")}.buttonStyle(.primary)
        }.navigationTitle("Pronuncia e toni").navigationBarTitleDisplayMode(.inline)
            .onChange(of:selected){_,_ in recorder.stop();recorder.frames=[];speech.stop()}
            .onDisappear{recorder.stop();speech.stop()}
    }
}
struct PitchChart:View {
    let frames:[PitchFrame]
    let baseline:Double?
    var body:some View {
        Canvas {context,size in
            var grid=Path();for i in 1...3{let y=size.height*CGFloat(i)/4;grid.move(to:CGPoint(x:0,y:y));grid.addLine(to:CGPoint(x:size.width,y:y))};context.stroke(grid,with:.color(Palette.ink.opacity(0.1)),style:StrokeStyle(lineWidth:1,dash:[4,4]))
            guard frames.count>1,let first=frames.first,let last=frames.last else{return}
            let values=frames.map{12*log2($0.hertz/(baseline ?? 180))};let low=(values.min() ?? -5)-1,high=(values.max() ?? 5)+1
            var path=Path()
            for (i,f) in frames.enumerated(){let p=CGPoint(x:(f.time-first.time)/max(0.1,last.time-first.time)*size.width,y:(1-(values[i]-low)/(high-low))*size.height);if i==0 || f.time-frames[i-1].time>0.2{path.move(to:p)}else{path.addLine(to:p)}}
            context.stroke(path,with:.color(Palette.jade),style:StrokeStyle(lineWidth:3,lineCap:.round,lineJoin:.round))
        }
        .padding(.vertical,8)
        .background(Palette.sunken,in:RoundedRectangle(cornerRadius:12,style:.continuous))
        .overlay {if frames.isEmpty {Text("Registra per vedere la curva").font(.footnote).foregroundStyle(Palette.inkSoft)}}
        .accessibilityElement(children:.ignore)
        .accessibilityLabel(frames.isEmpty ? "Curva vuota: registra la voce" : ToneFeedback.analyze(frames,baseline:baseline).recognized)
    }
}
struct ToneQuiz:View {
    let exercise:ToneExercise
    let answered:Bool
    let complete:(Bool,String)->Void
    @StateObject private var speech=SpeechPlayer()
    @State private var chosen:String?
    var choices:[String] {exercise.pattern.count==1 ? ["1","2","3","4"] : ["2–3","3–1","3–3","4–3"]}
    var body:some View {
        Panel(padding:20,spacing:14) {
            Text("Quale andamento senti?").font(.subheadline.weight(.medium)).foregroundStyle(Palette.inkSoft).frame(maxWidth:.infinity)
            AudioButton(speaking:speech.isSpeaking){speech.speak(exercise.hanzi)}.frame(maxWidth:.infinity)
            Text("Voce Apple provvisoria. Le coppie descrivono i toni pronunciati, dopo il cambio tonale.").font(.footnote).foregroundStyle(Palette.inkSoft).multilineTextAlignment(.center).frame(maxWidth:.infinity)
        }
        .onDisappear{speech.stop()}
        LazyVGrid(columns:[GridItem(.flexible(),spacing:10),GridItem(.flexible())],spacing:10) {
            ForEach(choices,id:\.self){choice in
                ChoiceButton(state:state(choice),alignment:.center){chosen=choice;complete(choice==exercise.pattern,choice)} label:{
                    VStack(spacing:0){Text("Tono \(choice)").font(.body.weight(.semibold));Text(marks(choice)).font(.title2).foregroundStyle(Palette.inkSoft)}
                }
                .disabled(answered).accessibilityLabel("Tono \(choice)")
            }
        }
        if answered {Panel {ChineseText(hanzi:exercise.hanzi,pinyin:exercise.pinyin,size:.card);Text("Andamento: \(exercise.pattern)").font(.headline);Text(exercise.advice).font(.subheadline)}}
    }
    func state(_ choice:String)->ChoiceState {
        guard answered else {return .idle}
        if choice==exercise.pattern {return .correct}
        return choice==chosen ? .wrong : .dimmed
    }
    /// Segni di tono come promemoria visivo dell'andamento: ˉ alto, ˊ sale, ˇ scende e risale, ˋ scende.
    func marks(_ choice:String)->String {choice.split(separator:"–").map{["1":"ˉ","2":"ˊ","3":"ˇ","4":"ˋ"][String($0)] ?? ""}.joined(separator:" ")}
}
