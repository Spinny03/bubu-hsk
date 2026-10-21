import SwiftUI
import PencilKit
struct WritingListView:View {
    let content:Curriculum
    var body:some View {
        List {
            Section {Text("100 caratteri della lista comune HSK 1–2. La scrittura non è esaminata all’HSK 1: qui prepari il passo successivo.").font(.subheadline).foregroundStyle(Palette.inkSoft)}
            Section {
                ForEach(content.writingCharacters){character in
                    NavigationLink{WritingView(character:character)} label:{
                        HStack(spacing:14) {
                            ZStack {TianGrid();RadicalGlyph(hanzi:character.hanzi).padding(5)}.frame(width:44,height:44).accessibilityHidden(true)
                            Text(character.pinyin).font(.body)
                            Spacer()
                            if let count=StrokeCatalog.all[character.hanzi]?.strokes.count {Text(count == 1 ? "1 tratto" : "\(count) tratti").font(.footnote).monospacedDigit().foregroundStyle(Palette.inkSoft)}
                        }
                        .accessibilityElement(children:.combine).accessibilityLabel("\(character.hanzi), \(character.pinyin)")
                    }
                }
            }
        }
        .paperList()
        .navigationTitle("Scrittura · 100 caratteri").navigationBarTitleDisplayMode(.inline)
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
    var radical:RadicalCatalog.Match?{RadicalCatalog.shared?.entry(for:character.hanzi)}
    var storage:URL {FileManager.default.urls(for:.applicationSupportDirectory,in:.userDomainMask)[0].appendingPathComponent("Writing",isDirectory:true)}
    var body:some View {
        Page(spacing:22) {
            HStack(spacing:16) {
                ZStack {TianGrid();RadicalGlyph(hanzi:character.hanzi).padding(8)}.frame(width:76,height:76).background(Palette.surface)
                VStack(alignment:.leading,spacing:2) {
                    Text(character.pinyin).font(.title2.weight(.semibold))
                    if let meaning=CharacterMeaning.all[character.hanzi] {
                        HStack(spacing:6) {CharacterImage(meaning:meaning,size:18);Text(meaning.meaning).font(.subheadline)}
                    }
                    Text(strokeCount == 1 ? "1 tratto" : "\(strokeCount) tratti").font(.subheadline).foregroundStyle(Palette.inkSoft)
                    if let radical {
                        Text(radical.whole ? "È un radicale: \(radical.form.meaning)" : "Radicale \(radical.form.label), \(radical.form.meaning)").font(.footnote).foregroundStyle(Palette.red)
                    }
                }
            }.accessibilityElement(children:.ignore).accessibilityLabel("\(character.hanzi), \(character.pinyin)\(CharacterMeaning.all[character.hanzi].map { ", \($0.meaning)" } ?? ""), \(strokeCount) tratti\(radical.map { ", radicale \($0.form.canonical) \($0.form.pinyin)" } ?? "")")
            VStack(alignment:.leading,spacing:10) {
                SectionTitle(title:"Ordine dei tratti",detail:"\(shown)/\(strokeCount)")
                Panel(spacing:14) {
                    ZStack {TianGrid();StrokeDiagram(hanzi:character.hanzi,count:shown,radical:radical?.strokes ?? []).padding(8)}
                        .frame(width:200,height:200).frame(maxWidth:.infinity)
                    HStack(spacing:10) {
                        Button{animate()} label:{Label("Anima",systemImage:"play.fill")}.buttonStyle(.secondary)
                        Button{animation?.cancel();shown=min(strokeCount,shown+1)} label:{Label("Successivo",systemImage:"forward.frame.fill")}.buttonStyle(.secondary).accessibilityLabel("Tratto successivo")
                    }
                }
            }
            VStack(alignment:.leading,spacing:10) {
                SectionTitle(title:"Prova a scrivere")
                Panel(spacing:14) {
                    Toggle("Guida visiva",isOn:$guide).tint(Palette.jade)
                    ZStack {
                        TianGrid()
                        if guide {StrokeDiagram(hanzi:character.hanzi,count:strokeCount,faint:true,radical:radical?.strokes ?? []).padding(12)}
                        PencilCanvas(drawing:$drawing).accessibilityLabel("Area di scrittura con dito o Apple Pencil")
                    }
                    .aspectRatio(1,contentMode:.fit).frame(maxWidth:340).frame(maxWidth:.infinity)
                    .background(Palette.paper)
                    HStack(spacing:10) {
                        Button{drawing=PKDrawing();saved=false} label:{Label("Cancella",systemImage:"eraser")}.buttonStyle(.secondary)
                        Button{saveDrawing()} label:{Label("Salva",systemImage:"square.and.arrow.down")}.buttonStyle(.secondary).disabled(drawing.strokes.isEmpty).accessibilityLabel("Salva sul dispositivo")
                    }
                    if saved {Label("Disegno salvato.",systemImage:"checkmark.circle.fill").font(.footnote).foregroundStyle(Palette.jade)}
                    Text("Confronta forma e ordine dei tratti. Il disegno non riceve un voto automatico e non aumenta la copertura.").font(.footnote).foregroundStyle(Palette.inkSoft)
                }
            }
            VStack(alignment:.leading,spacing:10) {
                SectionTitle(title:"Per l’esame al computer")
                Panel(spacing:12) {
                    Text("Con la tastiera cinese, digita il pinyin senza toni e scegli il carattere. Per questa lettura: \(character.pinyin.folding(options:.diacriticInsensitive,locale:.current)).").font(.subheadline)
                    HStack(spacing:10) {
                        TextField("Inserisci il carattere",text:$typed)
                            .padding(.horizontal,14).frame(minHeight:48)
                            .background(Palette.paper,in:RoundedRectangle(cornerRadius:12,style:.continuous))
                        Button("Controlla"){typedResult=typed.trimmingCharacters(in:.whitespacesAndNewlines)==character.hanzi ? "Carattere corretto." : "Confronta con \(character.hanzi) \(character.pinyin) e controlla l’omofono scelto."}
                            .buttonStyle(.primaryCompact).disabled(typed.trimmingCharacters(in:.whitespacesAndNewlines).isEmpty)
                    }
                    if let typedResult {
                        Label(typedResult,systemImage:typedResult == "Carattere corretto." ? "checkmark.circle.fill" : "arrow.uturn.backward.circle.fill")
                            .font(.subheadline).foregroundStyle(typedResult == "Carattere corretto." ? Palette.jade : Palette.red)
                    }
                }
            }
            VStack(alignment:.leading,spacing:10) {
                SectionTitle(title:"La tua storia per ricordarlo")
                TextField("Scrivi un’associazione personale",text:$story,axis:.vertical)
                    .lineLimit(2...6).padding(14)
                    .background(Palette.surface,in:RoundedRectangle(cornerRadius:Metrics.radius,style:.continuous))
                    .onChange(of:story){_,value in UserDefaults.standard.set(value,forKey:"story-\(character.id)")}
            }
            if let error{Text(error).font(.footnote).foregroundStyle(Palette.red)}
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
            Section {Text("Make Me a Hanzi / hanzi-writer-data 2.0.1 · Arphic Public License. Sono inclusi tratti e mediane di 253 caratteri.");NavigationLink("Arphic Public License completa"){LicenseTextView(name:"ARPHICPL")}} header:{Text("Grafica dei tratti")} footer:{Text("Le scomposizioni e i radicali di Make Me a Hanzi sono LGPL v3. Questo modulo non li include e non li usa.")}
            Section {Text("Numero e forma del radicale: Unicode Unihan 18.0 e CJKRadicals.txt (Unicode License v3). I tratti che formano il radicale sono annotati in Bùbù secondo l’ordine dei tratti dello standard cinese.");NavigationLink("Unicode License completa"){LicenseTextView(name:"LICENSE-UNICODE")}} header:{Text("Radicali")} footer:{Text("Non sono usati le scomposizioni né i radicali di Make Me a Hanzi (LGPL v3).")}
            Section("Voce e analisi") {Text("Voci Apple locali, provvisorie e non revisionate. YIN: de Cheveigné e Kawahara, 2002, DOI 10.1121/1.1458024. La classificazione orientativa dei toni non è validata.")}
            Section("Trascrizione IPA") {Text("Tabelle di Wikipedia «Pinyin», «Standard Chinese phonology» ed «Erhua» (CC BY-SA 4.0), basate su Lee & Zee 2003, «Standard Chinese (Beijing)», JIPA 33(1); Duanmu 2007, The Phonology of Standard Chinese; Lin 2007, The Sounds of Chinese. Toni: Chao 1968; il 3° tono a metà parola [˨˩] è una convenzione didattica. Versioni consultate il 20/10/2026. Trascrizione larga, senza varianti regionali.")}
        }.paperList().navigationTitle("Licenze").navigationBarTitleDisplayMode(.inline)
    }
}
struct LicenseTextView:View {
    let name:String
    var body:some View {
        ScrollView{Text(Bundle.main.url(forResource:name,withExtension:"txt").flatMap{try? String(contentsOf:$0,encoding:.utf8)} ?? "Licenza non disponibile").font(.caption.monospaced()).padding()}
            .background(Palette.paper.ignoresSafeArea()).navigationTitle(name).navigationBarTitleDisplayMode(.inline)
    }
}
