import SwiftUI

/// Tessera di un carattere: pinyin sopra, tratti con il radicale nel rosso del sigillo.
struct CharacterTile: View {
    let character: Hanzi
    var size: CGFloat = 70
    var body: some View {
        VStack(spacing: 2) {
            Text(character.pinyin).font(.caption).foregroundStyle(Palette.inkSoft).lineLimit(1).minimumScaleFactor(0.7)
            RadicalGlyph(hanzi: character.hanzi).frame(width: size * 0.56, height: size * 0.56)
        }
        .padding(.vertical, 8).frame(maxWidth: .infinity, minHeight: size)
        .background(Palette.surface, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay(alignment: .topTrailing) {
            if character.writing { Image(systemName: "pencil").font(.caption2.weight(.semibold)).foregroundStyle(Palette.inkSoft).padding(6) }
        }
        .contentShape(Rectangle())
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(CharacterTile.spoken(character))
    }
    static func spoken(_ character: Hanzi) -> String {
        var text = "\(character.hanzi), \(character.pinyin)"
        if let match = RadicalCatalog.shared?.entry(for: character.hanzi) {
            text += match.whole ? ", è un radicale: \(match.form.meaning)" : ", radicale \(match.form.canonical) \(match.form.pinyin), \(match.form.meaning)"
        }
        return text + (character.writing ? ", anche da scrivere" : "")
    }
}
struct RadicalLegend: View {
    var body: some View {
        HStack(spacing: 6) {
            RoundedRectangle(cornerRadius: 2).fill(Palette.red).frame(width: 10, height: 10)
            Text("Radicale").font(.footnote).foregroundStyle(Palette.inkSoft)
        }
        .accessibilityElement(children: .ignore).accessibilityLabel("In rosso il radicale")
    }
}
/// Riquadro del radicale: forma, carattere di riferimento con pinyin, significato.
struct RadicalPanel: View {
    let match: RadicalCatalog.Match
    var number: String {
        let raw = match.key.components(separatedBy: "|").first ?? ""
        return raw.hasSuffix("'") ? "\(raw.dropLast()), forma semplificata" : raw
    }
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionTitle(title: "Radicale", detail: match.whole ? "È esso stesso un radicale" : "In rosso nel carattere")
            Panel(spacing: 10) {
                HStack(alignment: .center, spacing: 14) {
                    Text(match.form.form).font(.hanzi(40, relativeTo: .largeTitle)).foregroundStyle(Palette.red)
                        .frame(minWidth: 56).accessibilityHidden(true)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(match.form.label).font(.headline)
                        Text(match.form.meaning.prefix(1).uppercased() + match.form.meaning.dropFirst()).font(.subheadline).foregroundStyle(Palette.inkSoft)
                    }
                }
                .accessibilityElement(children: .combine)
                Text("Radicale \(number) secondo Unihan, sistema Kangxi. Tratti annotati in Bùbù, da rivedere con un insegnante.")
                    .font(.footnote).foregroundStyle(Palette.inkSoft)
            }
        }
    }
}
struct CharacterDetailView: View {
    let content: Curriculum
    let character: Hanzi
    @StateObject private var speech = SpeechPlayer()
    @ScaledMetric(relativeTo: .title) private var tile: CGFloat = 70
    var body: some View {
        let match = RadicalCatalog.shared?.entry(for: character.hanzi)
        let siblings = RadicalCatalog.shared?.siblings(of: character.hanzi, in: content.characters) ?? []
        let words = content.words.filter { $0.hanzi.contains(character.hanzi) }
        Page(spacing: 22) {
            Panel(padding: 20, spacing: 14) {
                VStack(spacing: 10) {
                    Text(character.pinyin).font(.title3).foregroundStyle(Palette.inkSoft)
                    ZStack { TianGrid(); RadicalGlyph(hanzi: character.hanzi).padding(14) }.frame(width: 176, height: 176)
                }
                .frame(maxWidth: .infinity)
                .accessibilityElement(children: .ignore).accessibilityLabel("\(character.hanzi), \(character.pinyin)")
                AudioButton(title: "Ascolta", speaking: speech.isSpeaking, size: 52) { speech.speak(character.hanzi) }.frame(maxWidth: .infinity)
            }
            if let match { RadicalPanel(match: match) }
            if !siblings.isEmpty {
                VStack(alignment: .leading, spacing: 10) {
                    SectionTitle(title: "Stesso radicale", detail: siblings.count == 1 ? "1 carattere" : "\(siblings.count) caratteri")
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: tile), spacing: 8)], spacing: 8) {
                        ForEach(siblings) { other in
                            NavigationLink { CharacterDetailView(content: content, character: other) } label: { CharacterTile(character: other, size: tile) }
                                .buttonStyle(.plain).accessibilityLabel(CharacterTile.spoken(other))
                        }
                    }
                }
            }
            if !words.isEmpty {
                VStack(alignment: .leading, spacing: 10) {
                    SectionTitle(title: "Nelle parole", detail: words.count == 1 ? "1 parola" : "\(words.count) parole")
                    RowGroup {
                        ForEach(Array(words.prefix(8).enumerated()), id: \.element.id) { i, word in
                            if i > 0 { RowDivider(inset: 16) }
                            NavigationLink { WordDetail(content: content, word: word) } label: {
                                HStack(spacing: 12) {
                                    ChineseText(hanzi: word.hanzi, pinyin: word.pinyin).frame(minWidth: 84, alignment: .leading)
                                    Text(word.italian).font(.subheadline).foregroundStyle(Palette.inkSoft).frame(maxWidth: .infinity, alignment: .leading)
                                    Image(systemName: "chevron.right").font(.footnote.weight(.semibold)).foregroundStyle(Palette.inkSoft)
                                }
                                .padding(.horizontal, 16).padding(.vertical, 10).contentShape(Rectangle())
                            }.buttonStyle(.plain)
                        }
                    }
                }
            }
            if let writable = content.writingCharacters.first(where: { $0.hanzi == character.hanzi }) {
                NavigationLink { WritingView(character: writable) } label: { Label("Esercitati a scriverlo", systemImage: "pencil.and.outline") }.buttonStyle(.secondary)
            }
            if let error = speech.error { Text(error).font(.footnote).foregroundStyle(Palette.red) }
        }
        .navigationTitle("Carattere").navigationBarTitleDisplayMode(.inline)
        .onDisappear { speech.stop() }
    }
}
/// Caratteri di una parola con il loro radicale, nel dettaglio parola.
struct WordCharactersSection: View {
    let content: Curriculum
    let word: Word
    var characters: [Hanzi] {
        let han = word.hanzi.filter { $0.unicodeScalars.allSatisfy { $0.properties.isIdeographic } }.map(String.init)
        let syllables = PinyinIPA.syllables(word.pinyin)
        var seen = Set<String>()
        return han.enumerated().compactMap { i, hanzi in
            guard seen.insert(hanzi).inserted else { return nil }
            if let known = content.characters.first(where: { $0.hanzi == hanzi }) ?? content.writingCharacters.first(where: { $0.hanzi == hanzi }) {
                // Nella parola vale la lettura della parola (per esempio 了 le, non liǎo).
                let reading = syllables.count == han.count ? syllables[i].text : known.pinyin
                return Hanzi(id: known.id, hanzi: hanzi, pinyin: reading.lowercased(), writing: known.writing)
            }
            return syllables.count == han.count ? Hanzi(id: hanzi, hanzi: hanzi, pinyin: syllables[i].text.lowercased(), writing: false) : nil
        }
    }
    var body: some View {
        let list = characters
        if !list.isEmpty && RadicalCatalog.shared != nil {
            VStack(alignment: .leading, spacing: 10) {
                HStack { SectionTitle(title: list.count == 1 ? "Carattere" : "Caratteri"); RadicalLegend() }
                RowGroup {
                    ForEach(Array(list.enumerated()), id: \.element.hanzi) { i, character in
                        if i > 0 { RowDivider(inset: 74) }
                        NavigationLink { CharacterDetailView(content: content, character: character) } label: {
                            HStack(spacing: 14) {
                                ZStack { TianGrid(); RadicalGlyph(hanzi: character.hanzi).padding(5) }.frame(width: 46, height: 46).accessibilityHidden(true)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("\(character.hanzi) \(character.pinyin)").font(.headline)
                                    if let match = RadicalCatalog.shared?.entry(for: character.hanzi) {
                                        Text(match.whole ? "È un radicale: \(match.form.meaning)" : "Radicale \(match.form.label), \(match.form.meaning)")
                                            .font(.footnote).foregroundStyle(Palette.inkSoft)
                                    }
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                Image(systemName: "chevron.right").font(.footnote.weight(.semibold)).foregroundStyle(Palette.inkSoft)
                            }
                            .padding(.horizontal, 14).padding(.vertical, 10).contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel(CharacterTile.spoken(character))
                    }
                }
            }
        }
    }
}
