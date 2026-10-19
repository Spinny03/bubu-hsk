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
        Page {
            Text("Ascolta, parla, riascoltati.").font(.system(.title,design:.serif).bold())
            Text("L’HSK 1 non prevede una prova orale. Qui costruisci l’abilità per i livelli successivi, senza valutazioni automatiche.").font(.subheadline).foregroundStyle(.secondary)
            Picker("Attività",selection:$mode){Text("Ripeti").tag(0);Text("Descrivi").tag(1);Text("Rispondi").tag(2)}.pickerStyle(.segmented).disabled(recorder.recording || preparation != nil)
            Panel {
                if mode==0,let line{RubySentenceView(sentence:line);Button("Ascolta e poi ripeti"){speech.speak(line.hanzi)};Text("Hai 10 secondi per ripetere.").font(.caption)}
                else if mode==1 {Image(systemName:"person.2.fill").font(.system(size:60)).frame(maxWidth:.infinity);Image(systemName:"book.closed.fill").font(.system(size:40)).frame(maxWidth:.infinity);Text("Descrivi due persone che studiano. Hai 15 secondi.")}
                else {Text("Parla della tua famiglia: chi sono le persone, dove vivono e che cosa fanno.").font(.headline);Text("3 minuti per prepararti, poi 1 minuto e mezzo di risposta. Sono tempi di pratica ispirati alla prova orale HSK 3; questa attività non ne riproduce l’intera struttura.").font(.caption)}
                if preparation != nil{Text("Preparazione: \(preparationLeft) s").font(.title2.monospacedDigit());Button("Annulla"){preparation=nil}}
                else if recorder.recording{Text("Registrazione: \(recorder.remaining) s").font(.title2.monospacedDigit());Button("Termina e salva"){recorder.stop()}.buttonStyle(.borderedProminent).foregroundStyle(.white)}
                else {Button(mode==2 ? "Inizia la preparazione" : "Registra la risposta"){speech.stop();if mode==2{preparation=Date().addingTimeInterval(180);preparationLeft=180}else{Task{await recorder.start(seconds:mode==0 ? 10 : 15)}}}.buttonStyle(.borderedProminent).foregroundStyle(.white)}
            }
            SectionTitle(title:"Le tue registrazioni",detail:"Solo sul dispositivo")
            if recorder.files.isEmpty{Text("Le registrazioni appariranno qui dopo la prima prova.").font(.subheadline).foregroundStyle(.secondary)}
            ForEach(recorder.files,id:\.self){url in Panel{Text(recorder.date(url),format:.dateTime.day().month().hour().minute());HStack{Button("Riascolta"){speech.stop();recorder.play(url)};Spacer();Button("Elimina",role:.destructive){pendingDelete=url}}}}
            Text("Riascoltati cercando un dettaglio alla volta: parole comprensibili, tono basso, cambio 3–3. Una persona madrelingua può darti un riscontro più affidabile di un voto automatico.").font(.caption)
            if let error=recorder.error ?? speech.error{Text(error).foregroundStyle(Palette.red)}
        }.navigationTitle("Pratica orale").navigationBarTitleDisplayMode(.inline)
            .onReceive(timer){_ in recorder.tick();if let date=preparation{preparationLeft=max(0,Int(ceil(date.timeIntervalSinceNow)));if preparationLeft==0{preparation=nil;Task{await recorder.start(seconds:90)}}}}
            .onDisappear{preparation=nil;recorder.stop();speech.stop()}
            .onChange(of:scenePhase){_,phase in if phase == .background{preparation=nil;recorder.stop();speech.stop()}}
            .alert("Eliminare questa registrazione?",isPresented:Binding(get:{pendingDelete != nil},set:{if !$0{pendingDelete=nil}})){Button("Annulla",role:.cancel){pendingDelete=nil};Button("Elimina",role:.destructive){if let url=pendingDelete{recorder.delete(url)};pendingDelete=nil}}
    }
}
