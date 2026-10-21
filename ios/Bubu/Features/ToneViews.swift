import SwiftUI
struct TonePracticeView:View {
    let content:Curriculum
    @StateObject private var recorder=PitchRecorder()
    @StateObject private var speech=SpeechPlayer()
    @State private var selected="hao"
    @State private var voice=0
    var exercise:ToneExercise {ToneExercise.all.first{$0.id==selected} ?? ToneExercise.all[0]}
    var body:some View {
        Page {
            Text("Prima ascolta.\nPoi guarda la tua voce.").font(.system(.title,design:.serif).bold())
            Picker("Esercizio",selection:$selected) {ForEach(ToneExercise.all){Text("\($0.hanzi) \($0.pinyin)").tag($0.id)}}
            Panel {
                ChineseText(hanzi:exercise.hanzi,pinyin:exercise.pinyin,large:true)
                Text(exercise.advice)
                Button {recorder.stop();speech.speak(exercise.hanzi,voiceIndex:voice)} label:{Label("Ascolta il modello",systemImage:"speaker.wave.2")}
                if speech.voices.count>1 {Picker("Voce Apple",selection:$voice){ForEach(speech.voices.indices,id:\.self){Text(speech.voices[$0].name).tag($0)}}}
                else {Text("Su questo dispositivo è disponibile una sola voce cinese.").font(.caption).foregroundStyle(.secondary)}
            }
            Panel {
                HStack {
                    Button(recorder.recording ? "Ferma" : "Registra fino a 5 secondi") {speech.stop();if recorder.recording{recorder.stop()}else{Task{await recorder.start()}}}.buttonStyle(.borderedProminent).foregroundStyle(.white)
                }
                Button(recorder.baseline == nil ? "Calibra la voce: una ‘a’ naturale" : "Ricalibra la voce") {speech.stop();Task{await recorder.start(calibration:true)}}.disabled(recorder.recording)
                PitchChart(frames:recorder.frames,baseline:recorder.baseline).frame(height:140)
                if !recorder.frames.isEmpty && !recorder.recording {
                    if exercise.pattern.count==1 {
                        let feedback=ToneFeedback.analyze(recorder.frames,baseline:recorder.baseline)
                        Text(feedback.recognized).font(.headline);Text(feedback.advice).font(.subheadline)
                    } else {
                        Text("Confronta le due sillabe").font(.headline)
                        Text(exercise.advice).font(.subheadline)
                        Text("La curva non separa automaticamente le sillabe: non attribuiamo un tono unico all’intera parola.").font(.caption)
                    }
                }
                Text("Indicazione orientativa, senza voto. La curva mostra l’altezza rilevata sul dispositivo; non sostituisce l’ascolto di un insegnante.").font(.caption).foregroundStyle(.secondary)
                if let error=recorder.error ?? speech.error {Text(error).foregroundStyle(Palette.red)}
            }
            NavigationLink {StudySessionView(content:content,initialQueue:ToneExercise.all.map{ReviewItem(contentID:$0.id,kind:"tone")})} label:{Label("Allena l’orecchio nel ripasso",systemImage:"ear")}.buttonStyle(.borderedProminent).foregroundStyle(.white)
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
            var grid=Path();for i in 1...3{let y=size.height*CGFloat(i)/4;grid.move(to:CGPoint(x:0,y:y));grid.addLine(to:CGPoint(x:size.width,y:y))};context.stroke(grid,with:.color(.gray.opacity(0.2)),lineWidth:1)
            guard frames.count>1,let first=frames.first,let last=frames.last else{return}
            let values=frames.map{12*log2($0.hertz/(baseline ?? 180))};let low=(values.min() ?? -5)-1,high=(values.max() ?? 5)+1
            var path=Path()
            for (i,f) in frames.enumerated(){let p=CGPoint(x:(f.time-first.time)/max(0.1,last.time-first.time)*size.width,y:(1-(values[i]-low)/(high-low))*size.height);if i==0 || f.time-frames[i-1].time>0.2{path.move(to:p)}else{path.addLine(to:p)}}
            context.stroke(path,with:.color(Palette.jade),style:StrokeStyle(lineWidth:3,lineCap:.round))
        }.background(Palette.paper,in:RoundedRectangle(cornerRadius:12)).accessibilityLabel(frames.isEmpty ? "Curva vuota: registra la voce" : ToneFeedback.analyze(frames,baseline:baseline).recognized)
    }
}
struct ToneQuiz:View {
    let exercise:ToneExercise
    let answered:Bool
    let complete:(Bool,String)->Void
    @StateObject private var speech=SpeechPlayer()
    var choices:[String] {exercise.pattern.count==1 ? ["1","2","3","4"] : ["2–3","3–1","3–3","4–3"]}
    var body:some View {
        Panel {Text("Quale andamento senti?").font(.headline);Button("Ascolta"){speech.speak(exercise.hanzi)}.buttonStyle(.borderedProminent).foregroundStyle(.white);Text("Voce Apple provvisoria. Le coppie descrivono i toni pronunciati, dopo il cambio tonale.").font(.caption)}
        ForEach(choices,id:\.self){choice in Button("Tono \(choice)"){complete(choice==exercise.pattern,choice)}.buttonStyle(.bordered).disabled(answered)}
        if answered {Panel {ChineseText(hanzi:exercise.hanzi,pinyin:exercise.pinyin);Text("Andamento: \(exercise.pattern)").font(.headline);Text(exercise.advice)}}
        Color.clear.frame(height:0).onDisappear{speech.stop()}
    }
}
