import SwiftUI

enum Palette {
    static let ink = Color(hex: 0x262D2B)
    static let paper = Color(hex: 0xF7F4EE)
    static let red = Color(hex: 0xA73541)
    static let jade = Color(hex: 0x246957)
    static func tone(_ number: Int, mode: String) -> Color {
        if mode == "Disattivati" { return ink }
        let standard = [0x595959, 0xC43149, 0x7A3D00, 0x007A7A, 0x313DC4]
        if mode == "Alto contrasto" { return Color(hex: [0x2C2C2C, 0x850021, 0x582B00, 0x005454, 0x152090][min(max(number, 0), 4)]) }
        let accessible = [0x595959, 0x934B00, 0x004D80, 0x5E3C99, 0x202020]
        return Color(hex: (mode == "Daltonismo" ? accessible : standard)[min(max(number, 0), 4)])
    }
}
extension Color {
    init(hex: Int) { self.init(red: Double((hex >> 16) & 255)/255, green: Double((hex >> 8) & 255)/255, blue: Double(hex & 255)/255) }
}
struct ChineseText: View {
    let hanzi: String
    let pinyin: String
    var large = false
    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(pinyin).font(large ? .title3 : .subheadline).foregroundStyle(.secondary)
            Text(hanzi).font(large ? .system(.largeTitle, design: .serif) : .title3)
        }.accessibilityElement(children: .ignore).accessibilityLabel("\(hanzi), \(pinyin)")
    }
}
struct Page<Content: View>: View {
    @ViewBuilder var content: Content
    var body: some View {
        ScrollView { VStack(alignment: .leading, spacing: 14) { content }.padding(18) }
            .background(Palette.paper).foregroundStyle(Palette.ink)
    }
}
struct Panel<Content: View>: View {
    @ViewBuilder var content: Content
    var body: some View {
        VStack(alignment: .leading, spacing: 10) { content }
            .frame(maxWidth: .infinity, alignment: .leading).padding(16)
            .background(.white, in: RoundedRectangle(cornerRadius: 18))
            .overlay(RoundedRectangle(cornerRadius: 18).stroke(Palette.ink.opacity(0.08)))
    }
}
struct SectionTitle: View {
    let title: String
    var detail = ""
    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(title).font(.title3.bold()); Spacer()
            if !detail.isEmpty { Text(detail).font(.caption).foregroundStyle(.secondary) }
        }
    }
}
struct ActionRow: View {
    let title, detail, icon: String
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon).font(.title3).foregroundStyle(Palette.red).frame(width: 28)
            VStack(alignment: .leading, spacing: 3) { Text(title).font(.headline); Text(detail).font(.caption).foregroundStyle(.secondary) }
            Spacer(); Image(systemName: "chevron.right").font(.caption.bold()).foregroundStyle(.secondary)
        }.padding(.vertical, 6).frame(minHeight: 44).contentShape(Rectangle())
    }
}
