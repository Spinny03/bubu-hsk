import SwiftUI
import PencilKit
struct WritingListView:View {
    let content:Curriculum
    var body:some View {
        List {
            Section {Text("100 caratteri della lista comune HSK 1–2. La scrittura non è esaminata all’HSK 1: qui prepari il passo successivo.").font(.subheadline)}
            ForEach(content.writingCharacters){character in NavigationLink{WritingView(character:character)}label:{ChineseText(hanzi:character.hanzi,pinyin:character.pinyin)}}
        }.navigationTitle("Scrittura · 100 caratteri")
    }
}
struct WritingView:View {
    let character:Hanzi
    @State private var drawing=PKDrawing()
    @State private var guide=true
    @State private var shown=0
    @State private var animation:Task<Void,Never>?
    @State private var saved=false
    @State private var error:String?
    @State private var typed=""
    @State private var typedResult:String?
    @State private var story=""
    var strokeCount:Int{StrokeCatalog.all[character.hanzi]?.strokes.count ?? 0}
    var storage:URL {FileManager.default.urls(for:.applicationSupportDirectory,in:.userDomainMask)[0].appendingPathComponent("Writing",isDirectory:true)}
    var body:some View {
        Page {
            ChineseText(hanzi:character.hanzi,pinyin:character.pinyin,large:true)
            Panel {
                HStack {Text("Ordine dei tratti").font(.headline);Spacer();Text("\(shown)/\(strokeCount)").monospacedDigit()}
                StrokeDiagram(hanzi:character.hanzi,count:shown).frame(height:180)
                HStack {Button("Anima"){animate()};Spacer();Button("Tratto successivo"){animation?.cancel();shown=min(strokeCount,shown+1)}}
            }
            Panel {
                Toggle("Guida visiva",isOn:$guide)
                ZStack {
                    Canvas {context,size in var p=Path();p.move(to:CGPoint(x:size.width/2,y:0));p.addLine(to:CGPoint(x:size.width/2,y:size.height));p.move(to:CGPoint(x:0,y:size.height/2));p.addLine(to:CGPoint(x:size.width,y:size.height/2));context.stroke(p,with:.color(.gray.opacity(0.3)),style:StrokeStyle(lineWidth:1,dash:[5]))}
                    if guide {StrokeDiagram(hanzi:character.hanzi,count:strokeCount,faint:true)}
                    PencilCanvas(drawing:$drawing).accessibilityLabel("Area di scrittura con dito o Apple Pencil")
                }.frame(height:250).background(Palette.paper,in:RoundedRectangle(cornerRadius:12)).overlay(RoundedRectangle(cornerRadius:12).stroke(.gray.opacity(0.2)))
                HStack {Button("Cancella"){drawing=PKDrawing();saved=false};Spacer();Button("Salva sul dispositivo"){saveDrawing()}.disabled(drawing.strokes.isEmpty)}
                if saved {Text("Disegno salvato.").font(.caption).foregroundStyle(Palette.jade)}
                Text("Confronta forma e ordine dei tratti. Il disegno non riceve un voto automatico e non aumenta la copertura.").font(.caption).foregroundStyle(.secondary)
            }
            Panel {
                Text("Per l’esame al computer").font(.headline)
                Text("Con la tastiera cinese, digita il pinyin senza toni e scegli il carattere. Per questa lettura: \(character.pinyin.folding(options:.diacriticInsensitive,locale:.current)).").font(.subheadline)
                TextField("Inserisci il carattere",text:$typed).textFieldStyle(.roundedBorder)
                Button("Controlla il carattere"){typedResult=typed.trimmingCharacters(in:.whitespacesAndNewlines)==character.hanzi ? "Carattere corretto." : "Confronta con \(character.hanzi) \(character.pinyin) e controlla l’omofono scelto."}
                if let typedResult {Text(typedResult).font(.subheadline)}
            }
            Panel {Text("La tua storia per ricordarlo").font(.headline);TextField("Scrivi un’associazione personale",text:$story,axis:.vertical).onChange(of:story){_,value in UserDefaults.standard.set(value,forKey:"story-\(character.id)")}}
            if let error{Text(error).foregroundStyle(Palette.red)}
        }.navigationTitle("Scrittura").navigationBarTitleDisplayMode(.inline).onAppear{loadDrawing()}.onDisappear{animation?.cancel()}
    }
    func animate(){animation?.cancel();shown=0;animation=Task{for i in 1...max(1,strokeCount){guard !Task.isCancelled else{return};shown=i;try? await Task.sleep(nanoseconds:500_000_000)}}}
    func saveDrawing(){do{try FileManager.default.createDirectory(at:storage,withIntermediateDirectories:true);try drawing.dataRepresentation().write(to:storage.appendingPathComponent("\(character.id).drawing"),options:.atomic);saved=true}catch{self.error=error.localizedDescription}}
    func loadDrawing(){story=UserDefaults.standard.string(forKey:"story-\(character.id)") ?? "";if let data=try? Data(contentsOf:storage.appendingPathComponent("\(character.id).drawing")),let restored=try? PKDrawing(data:data){drawing=restored}}
}
struct LicensesView:View {
    var body:some View {
        List {
            Section("Ripasso") {Text("FSRS Swift · MIT · revisione 4fbaf20184d62f82a9f44f343337c61a2c5483e9");NavigationLink("Licenza MIT completa"){LicenseTextView(name:"LICENSE-FSRS")}}
            Section("Grafica dei tratti") {Text("Make Me a Hanzi / hanzi-writer-data 2.0.1 · Arphic Public License. Sono inclusi tratti e mediane di 100 caratteri.");NavigationLink("Arphic Public License completa"){LicenseTextView(name:"ARPHICPL")};Text("Le scomposizioni e i radicali di Make Me a Hanzi sono LGPL v3. Questo modulo non li include e non li usa.").font(.caption)}
            Section("Voce e analisi") {Text("Voci Apple locali, provvisorie e non revisionate. YIN: de Cheveigné e Kawahara, 2002, DOI 10.1121/1.1458024. La classificazione orientativa dei toni non è validata.")}
        }.navigationTitle("Licenze")
    }
}
struct LicenseTextView:View {
    let name:String
    var body:some View {ScrollView{Text(Bundle.main.url(forResource:name,withExtension:"txt").flatMap{try? String(contentsOf:$0,encoding:.utf8)} ?? "Licenza non disponibile").font(.caption.monospaced()).padding()}.navigationTitle(name)}
}
