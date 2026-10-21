import SwiftUI
import Combine
struct OralPracticeView:View {
    @StateObject private var recorder=OralRecorder()
    @StateObject private var speech=SpeechPlayer()
    @State private var mode=0
    @State private var preparation:Date?
    @State private var preparationLeft=0
    @State private var pendingDelete:URL?
    @Environment(\.scenePhase) private var scenePhase
    let timer=Timer.publish(every:1,on:.main,in:.common).autoconnect()
    var line:ExamSentence?{Dialogue.all.first?.lines.last}
    var body:some View {
        Page(spacing:20) {
            Text("L’HSK 1 non prevede una prova orale. Qui costruisci l’abilità per i livelli successivi, senza valutazioni automatiche.").font(.subheadline).foregroundStyle(Palette.inkSoft)
            Picker("Attività",selection:$mode){Text("Ripeti").tag(0);Text("Descrivi").tag(1);Text("Rispondi").tag(2)}.pickerStyle(.segmented).disabled(recorder.recording || preparation != nil)
            Panel(padding:20,spacing:16) {
                if mode==0,let line {
                    Text("Ascolta e poi ripeti").font(.subheadline.weight(.medium)).foregroundStyle(Palette.inkSoft)
                    RubySentenceView(sentence:line)
                    Button{speech.speak(line.hanzi)} label:{Label("Ascolta la frase",systemImage:"speaker.wave.2.fill")}.buttonStyle(.secondary)
                    Text("Hai 10 secondi per ripetere.").font(.footnote).foregroundStyle(Palette.inkSoft)
                } else if mode==1 {
                    HStack(spacing:24) {Image(systemName:"person.2.fill").font(.system(size:52));Image(systemName:"book.closed.fill").font(.system(size:38))}
                        .foregroundStyle(Palette.ink).frame(maxWidth:.infinity,minHeight:120)
                        .background(Palette.sunken,in:RoundedRectangle(cornerRadius:12,style:.continuous))
                        .accessibilityElement(children:.ignore).accessibilityLabel("Immagine: due persone e un libro")
                    Text("Descrivi due persone che studiano. Hai 15 secondi.").font(.headline)
                } else {
                    Text("Parla della tua famiglia: chi sono le persone, dove vivono e che cosa fanno.").font(.headline)
                    Text("3 minuti per prepararti, poi 1 minuto e mezzo di risposta. Sono tempi di pratica ispirati alla prova orale HSK 3; questa attività non ne riproduce l’intera struttura.").font(.footnote).foregroundStyle(Palette.inkSoft)
                }
                Rectangle().fill(Palette.line).frame(height:0.5)
                if preparation != nil {
                    VStack(spacing:10) {
                        Text("Preparazione").font(.subheadline).foregroundStyle(Palette.inkSoft)
                        Text(clock(preparationLeft)).font(.system(.largeTitle,design:.rounded).weight(.semibold)).monospacedDigit()
                        Button("Annulla"){preparation=nil}.buttonStyle(.secondaryCompact)
                    }.frame(maxWidth:.infinity)
                } else {
                    VStack(spacing:8) {
                        if recorder.recording {Text(clock(recorder.remaining)).font(.title2.weight(.semibold)).monospacedDigit().foregroundStyle(Palette.red)}
                        RecordButton(recording:recorder.recording,title:recorder.recording ? "Termina e salva" : (mode==2 ? "Inizia la preparazione" : "Registra la risposta")) {
                            if recorder.recording {recorder.stop()}
                            else {speech.stop();if mode==2{preparation=Date().addingTimeInterval(180);preparationLeft=180}else{Task{await recorder.start(seconds:mode==0 ? 10 : 15)}}}
                        }
                    }.frame(maxWidth:.infinity)
                }
            }
            VStack(alignment:.leading,spacing:10) {
                SectionTitle(title:"Le tue registrazioni",detail:"Solo sul dispositivo")
                if recorder.files.isEmpty {
                    Text("Le registrazioni appariranno qui dopo la prima prova.").font(.subheadline).foregroundStyle(Palette.inkSoft).padding(.horizontal,4)
                } else {
                    RowGroup {
                        ForEach(Array(recorder.files.enumerated()),id:\.element){i,url in
                            if i>0 {RowDivider(inset:16)}
                            HStack(spacing:12) {
                                Text(recorder.date(url),format:.dateTime.day().month().hour().minute()).font(.subheadline)
                                Spacer()
                                Button{speech.stop();recorder.play(url)} label:{Image(systemName:"play.fill").frame(width:44,height:44)}.buttonStyle(.plain).foregroundStyle(Palette.ink).accessibilityLabel("Riascolta")
                                Button(role:.destructive){pendingDelete=url} label:{Image(systemName:"trash").frame(width:44,height:44)}.buttonStyle(.plain).foregroundStyle(Palette.red).accessibilityLabel("Elimina")
                            }.padding(.leading,16).padding(.trailing,4)
                        }
                    }
                }
            }
            Text("Riascoltati cercando un dettaglio alla volta: parole comprensibili, tono basso, cambio 3–3. Una persona madrelingua può darti un riscontro più affidabile di un voto automatico.").font(.footnote).foregroundStyle(Palette.inkSoft)
            if let error=recorder.error ?? speech.error{Text(error).font(.footnote).foregroundStyle(Palette.red)}
        }.navigationTitle("Pratica orale").navigationBarTitleDisplayMode(.inline)
            .onReceive(timer){_ in recorder.tick();if let date=preparation{preparationLeft=max(0,Int(ceil(date.timeIntervalSinceNow)));if preparationLeft==0{preparation=nil;Task{await recorder.start(seconds:90)}}}}
            .onDisappear{preparation=nil;recorder.stop();speech.stop()}
            .onChange(of:scenePhase){_,phase in if phase == .background{preparation=nil;recorder.stop();speech.stop()}}
            .alert("Eliminare questa registrazione?",isPresented:Binding(get:{pendingDelete != nil},set:{if !$0{pendingDelete=nil}})){Button("Annulla",role:.cancel){pendingDelete=nil};Button("Elimina",role:.destructive){if let url=pendingDelete{recorder.delete(url)};pendingDelete=nil}}
    }
    func clock(_ seconds:Int)->String {String(format:"%d:%02d",seconds/60,seconds%60)}
}
