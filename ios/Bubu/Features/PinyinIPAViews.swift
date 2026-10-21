import SwiftUI

/// Suoni che un italiano tende a leggere come nella propria lingua.
private let italianTraps: Set<String> = ["b", "p", "d", "t", "g", "k", "h", "j", "q", "x", "zh", "ch", "sh", "r", "z", "c",
                                         "e", "er", "ao", "ong", "iu", "ian", "ui", "un", "ü", "üe", "üan", "ün", "-i₁", "-i₂"]

struct PinyinIPAView: View {
    let content: Curriculum
    @State private var input = ""
    @ScaledMetric(relativeTo: .title3) private var cell: CGFloat = 76
    var body: some View {
        Page(spacing: 24) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Il pinyin è un modo di scrivere, non una pronuncia: molte lettere hanno un valore diverso dall’italiano. L’IPA, l’alfabeto fonetico internazionale, indica il suono reale.")
                    .font(.subheadline).foregroundStyle(Palette.inkSoft)
                Label("Diverso dall’italiano", systemImage: "circle.fill").font(.footnote).foregroundStyle(Palette.inkSoft)
                    .labelStyle(TrapLegendStyle())
            }
            converter
            VStack(alignment: .leading, spacing: 10) {
                SectionTitle(title: "Toni", detail: "Lettere di Chao, 5 = alto")
                RowGroup {
                    ForEach(Array(PinyinIPA.tones.enumerated()), id: \.element.id) { i, tone in
                        if i > 0 { RowDivider(inset: 76) }
                        ToneRow(tone: tone)
                    }
                }
            }
            soundSection("Iniziali", sounds: PinyinIPA.initials)
            soundSection("Finali", sounds: PinyinIPA.finals)
            Text("Trascrizione larga del cinese standard secondo le tabelle di Wikipedia «Pinyin», «Standard Chinese phonology» ed «Erhua», basate su Lee & Zee (2003), Duanmu (2007) e Lin (2007); toni secondo Chao (1968). Le varianti regionali sono escluse.")
                .font(.footnote).foregroundStyle(Palette.inkSoft)
        }
        .navigationTitle("Pinyin e IPA").navigationBarTitleDisplayMode(.inline)
    }
    var converter: some View {
        let syllables = input.isEmpty ? nil : PinyinIPA.segment(PinyinIPA.markTones(input))
        let marked = PinyinIPA.markTones(input)
        let match = content.words.first { word in word.pinyin.split(separator: "/").contains { PinyinIPA.normalized(String($0)) == PinyinIPA.normalized(marked) } }
        return VStack(alignment: .leading, spacing: 10) {
            SectionTitle(title: "Dal pinyin all’IPA")
            Panel(spacing: 12) {
                TextField("Es. xièxie oppure xie4 xie5", text: $input)
                    .font(.title3).textInputAutocapitalization(.never).autocorrectionDisabled()
                    .padding(.horizontal, 14).frame(minHeight: 50)
                    .background(Palette.paper, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                    .accessibilityIdentifier("ipa-input")
                if input.isEmpty {
                    Text("Scrivi una sillaba o una parola. Puoi indicare i toni con i numeri da 1 a 4 (5 per il tono neutro).")
                        .font(.footnote).foregroundStyle(Palette.inkSoft)
                } else if let syllables, let ipa = PinyinIPA.transcribe(marked) {
                    Text(ipa).font(.title2.weight(.semibold)).textSelection(.enabled).accessibilityIdentifier("ipa-result")
                    SyllableBreakdown(syllables: syllables, content: content)
                    if let match {
                        Rectangle().fill(Palette.line).frame(height: 0.5)
                        NavigationLink { WordDetail(content: content, word: match) } label: {
                            HStack(spacing: 12) {
                                ChineseText(hanzi: match.hanzi, pinyin: match.pinyin)
                                Text(match.italian).font(.subheadline).foregroundStyle(Palette.inkSoft).frame(maxWidth: .infinity, alignment: .leading)
                                Image(systemName: "chevron.right").font(.footnote.weight(.semibold)).foregroundStyle(Palette.inkSoft)
                            }.contentShape(Rectangle())
                        }.buttonStyle(.plain)
                    }
                } else {
                    Label("Non riconosco questa grafia. Controlla i toni e usa l’apostrofo prima delle sillabe che iniziano per a, o, e (xī’ān).", systemImage: "exclamationmark.circle")
                        .font(.footnote).foregroundStyle(Palette.red)
                }
            }
        }
    }
    func soundSection(_ title: String, sounds: [PinyinIPA.Sound]) -> some View {
        let groups = sounds.reduce(into: [String]()) { if !$0.contains($1.group) { $0.append($1.group) } }
        return VStack(alignment: .leading, spacing: 14) {
            SectionTitle(title: title, detail: "\(sounds.count) suoni")
            ForEach(groups, id: \.self) { group in
                VStack(alignment: .leading, spacing: 8) {
                    Text(group).font(.footnote.weight(.semibold)).foregroundStyle(Palette.inkSoft).padding(.horizontal, 4)
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: cell), spacing: 8)], spacing: 8) {
                        ForEach(sounds.filter { $0.group == group }) { sound in
                            NavigationLink { SoundDetailView(content: content, sound: sound) } label: { SoundCell(sound: sound) }
                                .buttonStyle(.plain).accessibilityIdentifier("sound-\(sound.id)")
                        }
                    }
                }
            }
        }
    }
}
private struct TrapLegendStyle: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: 6) {
            configuration.icon.font(.system(size: 7)).foregroundStyle(Palette.red)
            configuration.title
        }
    }
}
struct SoundCell: View {
    let sound: PinyinIPA.Sound
    var title: String {
        if sound.id.hasPrefix("-i") { return String(sound.pinyin.dropFirst(4).dropLast()) }
        return sound.pinyin.components(separatedBy: " (").first ?? sound.pinyin
    }
    var body: some View {
        VStack(spacing: 2) {
            Text(title).font(.title3.weight(.semibold)).lineLimit(2).minimumScaleFactor(0.7).multilineTextAlignment(.center)
            Text("[\(sound.ipa)]").font(.subheadline).foregroundStyle(Palette.inkSoft)
        }
        .padding(.vertical, 10).padding(.horizontal, 4).frame(maxWidth: .infinity, minHeight: 66)
        .background(Palette.surface, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay(alignment: .topTrailing) {
            if italianTraps.contains(sound.id) { Circle().fill(Palette.red).frame(width: 6, height: 6).padding(7) }
        }
        .contentShape(Rectangle())
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(sound.pinyin), IPA \(sound.ipa)\(italianTraps.contains(sound.id) ? ", diverso dall’italiano" : "")")
    }
}
/// Andamento del tono sui cinque livelli di Chao, nel colore scelto per i toni.
struct ToneContour: View {
    let tone: PinyinIPA.Tone
    @AppStorage("tonePalette") private var palette = "Standard"
    var body: some View {
        Canvas { context, size in
            func y(_ level: Int) -> CGFloat { size.height * (1 - CGFloat(level - 1) / 4) }
            var grid = Path()
            for level in 1...5 { grid.move(to: CGPoint(x: 0, y: y(level))); grid.addLine(to: CGPoint(x: size.width, y: y(level))) }
            context.stroke(grid, with: .color(Palette.ink.opacity(0.1)), lineWidth: 1)
            let color = Palette.tone(tone.id, mode: palette)
            if tone.id == 0 {
                context.fill(Path(ellipseIn: CGRect(x: size.width/2 - 4, y: y(3) - 4, width: 8, height: 8)), with: .color(color))
                return
            }
            var line = Path()
            for (i, level) in tone.levels.enumerated() {
                let point = CGPoint(x: size.width * CGFloat(i) / CGFloat(tone.levels.count - 1), y: y(level))
                if i == 0 { line.move(to: point) } else { line.addLine(to: point) }
            }
            context.stroke(line, with: .color(color), style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))
        }
        .padding(4)
        .accessibilityHidden(true)
    }
}
struct ToneRow: View {
    let tone: PinyinIPA.Tone
    @AppStorage("tonePalette") private var palette = "Standard"
    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            ToneContour(tone: tone).frame(width: 46, height: 40)
                .background(Palette.paper, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
            VStack(alignment: .leading, spacing: 3) {
                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    Text(tone.id == 0 ? "Tono neutro" : "\(tone.id)° tono").font(.headline)
                    Text(tone.example).font(.headline).foregroundStyle(Palette.tone(tone.id, mode: palette))
                    Spacer()
                    Text("[\(tone.letters)]").font(.subheadline).foregroundStyle(Palette.inkSoft)
                    if tone.chao != "—" { Text(tone.chao).font(.subheadline).monospacedDigit().foregroundStyle(Palette.inkSoft) }
                }
                Text(tone.hint).font(.footnote).foregroundStyle(Palette.inkSoft)
            }
        }
        .padding(.horizontal, 16).padding(.vertical, 12)
        .accessibilityElement(children: .combine)
    }
}
/// Ogni sillaba scomposta in iniziale, finale e tono, collegati alle schede dei suoni.
struct SyllableBreakdown: View {
    let syllables: [PinyinIPA.Syllable]
    var content: Curriculum? = nil
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            ForEach(Array(syllables.enumerated()), id: \.offset) { i, syllable in
                VStack(alignment: .leading, spacing: 6) {
                    Text(syllable.text).font(.headline)
                    RubyFlow(spacing: 6, lineSpacing: 6) {
                        if let initial = PinyinIPA.initialSound(for: syllable) { chip(initial) }
                        if let final = PinyinIPA.finalSound(for: syllable) { chip(final) }
                        if syllable.erhua { Tag(text: "erhua [ʵ]") }
                        Tag(text: syllable.tone == 0 ? "neutro [\(PinyinIPA.toneLetters(syllables, at: i))]" : "\(syllable.tone)° [\(PinyinIPA.toneLetters(syllables, at: i))]")
                    }
                }
            }
        }
    }
    @ViewBuilder func chip(_ sound: PinyinIPA.Sound) -> some View {
        let label = Text("\(SoundCell(sound: sound).title) [\(sound.ipa)]").font(.subheadline.weight(.semibold))
            .padding(.horizontal, 10).frame(minHeight: 32)
            .background(Palette.sunken, in: Capsule())
        if let content {
            NavigationLink { SoundDetailView(content: content, sound: sound) } label: { label }.buttonStyle(.plain)
        } else { label }
    }
}
struct SoundDetailView: View {
    let content: Curriculum
    let sound: PinyinIPA.Sound
    @StateObject private var speech = SpeechPlayer()
    var body: some View {
        let examples = PinyinIPA.examples(for: sound, in: content.words)
        Page(spacing: 22) {
            HStack(alignment: .firstTextBaseline, spacing: 14) {
                Text(SoundCell(sound: sound).title).font(.system(.largeTitle, design: .serif).weight(.bold))
                Text("[\(sound.ipa)]").font(.title).foregroundStyle(Palette.red).accessibilityIdentifier("sound-ipa")
            }
            .accessibilityElement(children: .combine)
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 6) {
                    Tag(text: PinyinIPA.initials.contains(sound) ? "Iniziale" : "Finale")
                    Tag(text: sound.group)
                    if italianTraps.contains(sound.id) { Tag(text: "Diverso dall’italiano", tint: Palette.red) }
                }
                Text(sound.hint).font(.body).fixedSize(horizontal: false, vertical: true)
                if sound.pinyin.contains("(") && !sound.id.hasPrefix("-i") {
                    Text("Senza iniziale si scrive \(sound.pinyin.components(separatedBy: "(").last?.dropLast() ?? "").").font(.subheadline).foregroundStyle(Palette.inkSoft)
                }
            }
            VStack(alignment: .leading, spacing: 10) {
                SectionTitle(title: "Nelle parole dell’HSK 1", detail: examples.isEmpty ? "" : "Tocca per ascoltare")
                if examples.isEmpty {
                    Text("Nessuna delle 300 parole contiene questo suono.").font(.subheadline).foregroundStyle(Palette.inkSoft).padding(.horizontal, 4)
                } else {
                    RowGroup {
                        ForEach(Array(examples.enumerated()), id: \.element.id) { i, word in
                            if i > 0 { RowDivider(inset: 16) }
                            Button { speech.speak(word.hanzi) } label: {
                                HStack(spacing: 12) {
                                    ChineseText(hanzi: word.hanzi, pinyin: word.pinyin).frame(minWidth: 84, alignment: .leading)
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(PinyinIPA.transcribe(word.pinyin) ?? "").font(.subheadline.weight(.medium))
                                        Text(word.italian).font(.footnote).foregroundStyle(Palette.inkSoft)
                                    }.frame(maxWidth: .infinity, alignment: .leading)
                                    Image(systemName: "speaker.wave.2.fill").foregroundStyle(Palette.ink).accessibilityHidden(true)
                                }
                                .padding(.horizontal, 16).padding(.vertical, 10).contentShape(Rectangle())
                            }
                            .buttonStyle(.plain)
                            .accessibilityHint("Ascolta la parola")
                        }
                    }
                }
            }
            if let error = speech.error { Text(error).font(.footnote).foregroundStyle(Palette.red) }
            Text("Voce Apple provvisoria: confronta l’ascolto con la descrizione, non il contrario.").font(.footnote).foregroundStyle(Palette.inkSoft)
        }
        .navigationTitle("Suono").navigationBarTitleDisplayMode(.inline)
        .onDisappear { speech.stop() }
    }
}
/// Sezione di pronuncia nel dettaglio di una parola.
struct WordIPASection: View {
    let content: Curriculum
    let word: Word
    var body: some View {
        if let ipa = PinyinIPA.transcribe(word.pinyin) {
            VStack(alignment: .leading, spacing: 10) {
                SectionTitle(title: "Pronuncia", detail: "IPA")
                Panel(spacing: 12) {
                    Text(ipa).font(.title3.weight(.semibold)).textSelection(.enabled).accessibilityIdentifier("word-ipa")
                    SyllableBreakdown(syllables: PinyinIPA.syllables(word.pinyin), content: content)
                    Text("Nelle parole il 3° tono resta basso e due 3° di fila diventano 2° + 3°. Alcune parole fanno eccezione.")
                        .font(.footnote).foregroundStyle(Palette.inkSoft)
                    NavigationLink { PinyinIPAView(content: content) } label: {
                        Label("Tutti i suoni del pinyin", systemImage: "mouth")
                    }.buttonStyle(.secondary)
                }
            }
        }
    }
}
