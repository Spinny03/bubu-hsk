import SwiftUI

// Bùbù · «quaderno e sigillo».
// Carta calda e inchiostro per lo studio quotidiano; il rosso del sigillo resta all'identità,
// alla selezione e agli errori, il giada alle risposte corrette e all'avanzamento.
// Contrasti verificati: inchiostro tenue ≥ 5:1 su carta e bianco, rosso e giada ≥ 6:1 sul bianco.
enum Palette {
    static let ink = Color(hex: 0x1E2422)
    static let inkSoft = Color(hex: 0x5C6360)
    static let paper = Color(hex: 0xF4F1EA)
    static let surface = Color.white
    static let sunken = Color(hex: 0xEDE9E0)
    static let line = Color(hex: 0x1E2422).opacity(0.1)
    static let red = Color(hex: 0xA6303C)
    static let jade = Color(hex: 0x1F6B57)
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
extension Font {
    /// PingFang SC esplicito: forme semplificate garantite e scala con Dynamic Type.
    static func hanzi(_ size: CGFloat, relativeTo style: Font.TextStyle = .title) -> Font {
        .custom("PingFangSC-Regular", size: size, relativeTo: style)
    }
    static let screenTitle = Font.system(.title2, design: .serif).weight(.bold)
}
enum Metrics {
    static let radius: CGFloat = 16
    static let maxWidth: CGFloat = 640
}

// MARK: - Struttura delle pagine

struct Page<Content: View>: View {
    var spacing: CGFloat = 20
    @ViewBuilder var content: Content
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: spacing) { content }
                .padding(.horizontal, 16).padding(.top, 8).padding(.bottom, 28)
                .frame(maxWidth: Metrics.maxWidth, alignment: .leading).frame(maxWidth: .infinity)
        }
        .scrollDismissesKeyboard(.interactively)
        .background(Palette.paper.ignoresSafeArea()).foregroundStyle(Palette.ink)
    }
}
/// Intestazione compatta: il titolo di navigazione resta in alto, qui solo ciò che aggiunge informazione.
struct ScreenHeader: View {
    var eyebrow: String? = nil
    let title: String
    var subtitle: String? = nil
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            if let eyebrow { Text(eyebrow).font(.footnote.weight(.semibold)).foregroundStyle(Palette.red) }
            Text(title).font(.screenTitle).accessibilityAddTraits(.isHeader)
            if let subtitle { Text(subtitle).font(.subheadline).foregroundStyle(Palette.inkSoft) }
        }.frame(maxWidth: .infinity, alignment: .leading)
    }
}
struct Panel<Content: View>: View {
    var padding: CGFloat = 16
    var spacing: CGFloat = 12
    @ViewBuilder var content: Content
    var body: some View {
        VStack(alignment: .leading, spacing: spacing) { content }
            .frame(maxWidth: .infinity, alignment: .leading).padding(padding)
            .background(Palette.surface, in: RoundedRectangle(cornerRadius: Metrics.radius, style: .continuous))
    }
}
/// Righe collegate in un'unica superficie: sostituisce una scheda per ogni riga.
struct RowGroup<Content: View>: View {
    @ViewBuilder var content: Content
    var body: some View {
        VStack(spacing: 0) { content }
            .background(Palette.surface, in: RoundedRectangle(cornerRadius: Metrics.radius, style: .continuous))
            .clipShape(RoundedRectangle(cornerRadius: Metrics.radius, style: .continuous))
    }
}
struct RowDivider: View {
    var inset: CGFloat = 62
    var body: some View { Rectangle().fill(Palette.line).frame(height: 0.5).padding(.leading, inset) }
}
struct SectionTitle: View {
    let title: String
    var detail = ""
    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(title).font(.headline).accessibilityAddTraits(.isHeader)
            Spacer(minLength: 8)
            if !detail.isEmpty { Text(detail).font(.footnote).foregroundStyle(Palette.inkSoft) }
        }.padding(.horizontal, 4)
    }
}
struct ActionRow: View {
    let title, detail, icon: String
    var trailing: String? = nil
    var body: some View {
        HStack(spacing: 14) {
            IconBadge(icon: icon)
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.body.weight(.semibold))
                if !detail.isEmpty { Text(detail).font(.footnote).foregroundStyle(Palette.inkSoft) }
            }
            Spacer(minLength: 8)
            if let trailing { Text(trailing).font(.subheadline).monospacedDigit().foregroundStyle(Palette.inkSoft) }
            Image(systemName: "chevron.right").font(.footnote.weight(.semibold)).foregroundStyle(Palette.inkSoft).accessibilityHidden(true)
        }
        .padding(.horizontal, 14).padding(.vertical, 10).frame(minHeight: 58)
        .contentShape(Rectangle())
    }
}
struct IconBadge: View {
    let icon: String
    var tint: Color = Palette.ink
    @ScaledMetric(relativeTo: .body) private var side: CGFloat = 34
    var body: some View {
        Image(systemName: icon).font(.body.weight(.medium)).foregroundStyle(tint)
            .frame(width: side, height: side)
            .background(Palette.sunken, in: RoundedRectangle(cornerRadius: 9, style: .continuous))
            .accessibilityHidden(true)
    }
}
struct FactRow: View {
    let icon: String
    let text: String
    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 12) {
            Image(systemName: icon).font(.subheadline.weight(.medium)).foregroundStyle(Palette.inkSoft).frame(width: 22).accessibilityHidden(true)
            Text(text).font(.subheadline).fixedSize(horizontal: false, vertical: true)
        }
    }
}
struct Tag: View {
    let text: String
    var tint: Color = Palette.inkSoft
    var body: some View {
        Text(text).font(.caption.weight(.semibold)).foregroundStyle(tint)
            .padding(.horizontal, 8).padding(.vertical, 4)
            .background(tint.opacity(0.1), in: Capsule())
    }
}
struct Meter: View {
    let value: Double
    var tint: Color = Palette.jade
    var height: CGFloat = 6
    var body: some View {
        GeometryReader { g in
            ZStack(alignment: .leading) {
                Capsule().fill(Palette.sunken)
                Capsule().fill(tint).frame(width: value > 0 ? max(height, g.size.width * min(1, value)) : 0)
            }
        }.frame(height: height).accessibilityHidden(true)
    }
}

// MARK: - Cinese

/// Pinyin sopra, carattere sotto. Le proporzioni seguono la gerarchia: il carattere guida, il pinyin lo sostiene.
struct ChineseText: View {
    enum Size { case row, card, hero }
    let hanzi: String
    let pinyin: String
    var size: Size = .row
    var alignment: HorizontalAlignment = .leading
    init(hanzi: String, pinyin: String, large: Bool = false, size: Size? = nil, alignment: HorizontalAlignment = .leading) {
        self.hanzi = hanzi; self.pinyin = pinyin; self.alignment = alignment
        self.size = size ?? (large ? .hero : .row)
    }
    var body: some View {
        VStack(alignment: alignment, spacing: size == .row ? 1 : 4) {
            Text(pinyin).font(size == .row ? .footnote : (size == .card ? .body : .title3)).foregroundStyle(Palette.inkSoft)
            Text(hanzi).font(size == .row ? .hanzi(22, relativeTo: .title2) : (size == .card ? .hanzi(30, relativeTo: .title) : .hanzi(52, relativeTo: .largeTitle)))
        }
        .multilineTextAlignment(alignment == .center ? .center : .leading)
        .accessibilityElement(children: .ignore).accessibilityLabel("\(hanzi), \(pinyin)")
    }
}
/// Griglia 田字格 dei quaderni cinesi: mostra proporzioni e centro del carattere.
struct TianGrid: View {
    var tint: Color = Palette.red
    var body: some View {
        Canvas { context, size in
            let frame = CGRect(origin: .zero, size: size).insetBy(dx: 0.5, dy: 0.5)
            context.stroke(Path(frame), with: .color(tint.opacity(0.4)), lineWidth: 1)
            var cross = Path()
            cross.move(to: CGPoint(x: size.width/2, y: 0)); cross.addLine(to: CGPoint(x: size.width/2, y: size.height))
            cross.move(to: CGPoint(x: 0, y: size.height/2)); cross.addLine(to: CGPoint(x: size.width, y: size.height/2))
            context.stroke(cross, with: .color(tint.opacity(0.3)), style: StrokeStyle(lineWidth: 1, dash: [4, 4]))
        }.accessibilityHidden(true)
    }
}
/// Parola grande in griglia, con pinyin sopra: fronte e retro delle carte, dettaglio della parola.
struct HanziHero: View {
    let hanzi: String
    let pinyin: String
    @ScaledMetric(relativeTo: .largeTitle) private var cell: CGFloat = 96
    var body: some View {
        let characters = Array(hanzi)
        let side = min(cell, 300 / CGFloat(max(1, characters.count)), 150)
        VStack(spacing: 10) {
            Text(pinyin).font(.title3).foregroundStyle(Palette.inkSoft)
            HStack(spacing: -1) {
                ForEach(Array(characters.enumerated()), id: \.offset) { _, character in
                    ZStack {
                        TianGrid()
                        Text(String(character)).font(.custom("PingFangSC-Regular", fixedSize: side * 0.66))
                    }.frame(width: side, height: side)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .ignore).accessibilityLabel("\(hanzi), \(pinyin)")
    }
}
/// Sigillo dell'app: 步步 in verticale, come un timbro. Il nome Bùbù accanto ne è il pinyin.
struct SealMark: View {
    var size: CGFloat = 44
    var body: some View {
        VStack(spacing: -size * 0.08) {
            Text("步"); Text("步")
        }
        .font(.custom("PingFangSC-Semibold", fixedSize: size * 0.36))
        .foregroundStyle(.white)
        .frame(width: size, height: size)
        .background(Palette.red, in: RoundedRectangle(cornerRadius: size * 0.2, style: .continuous))
        .accessibilityHidden(true)
    }
}

// MARK: - Pulsanti

struct PrimaryButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled
    var fullWidth = true
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.body.weight(.semibold)).multilineTextAlignment(.center)
            .foregroundStyle(isEnabled ? Palette.paper : Palette.inkSoft)
            .padding(.horizontal, 20).padding(.vertical, 12)
            .frame(maxWidth: fullWidth ? .infinity : nil, minHeight: 52)
            .background(isEnabled ? Palette.ink : Palette.sunken, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
            .opacity(configuration.isPressed ? 0.82 : 1)
            .contentShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}
struct SecondaryButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled
    var fullWidth = true
    var tint: Color = Palette.ink
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.body.weight(.semibold)).multilineTextAlignment(.center)
            .foregroundStyle(isEnabled ? tint : Palette.inkSoft.opacity(0.7))
            .padding(.horizontal, 16).padding(.vertical, 10)
            .frame(maxWidth: fullWidth ? .infinity : nil, minHeight: 48)
            .background(configuration.isPressed ? Palette.sunken : Palette.surface, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous).strokeBorder(Palette.line))
            .contentShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}
/// Azione su fondo inchiostro (scheda del ripasso di oggi).
struct InverseButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.body.weight(.semibold)).foregroundStyle(Palette.ink)
            .padding(.horizontal, 20).frame(maxWidth: .infinity, minHeight: 50)
            .background(Palette.paper.opacity(configuration.isPressed ? 0.85 : 1), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
            .contentShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}
extension ButtonStyle where Self == PrimaryButtonStyle {
    static var primary: PrimaryButtonStyle { .init() }
    static var primaryCompact: PrimaryButtonStyle { .init(fullWidth: false) }
}
extension ButtonStyle where Self == SecondaryButtonStyle {
    static var secondary: SecondaryButtonStyle { .init() }
    static var secondaryCompact: SecondaryButtonStyle { .init(fullWidth: false) }
}
/// Pulsante tondo per l'ascolto: il bersaglio principale degli esercizi audio.
struct AudioButton: View {
    var title = "Ascolta"
    var speaking = false
    var size: CGFloat = 76
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: "speaker.wave.2.fill")
                    .font(.system(size: size * 0.34, weight: .semibold))
                    .symbolEffect(.variableColor.iterative, isActive: speaking)
                    .foregroundStyle(Palette.paper)
                    .frame(width: size, height: size)
                    .background(Palette.ink, in: Circle())
                Text(title).font(.subheadline.weight(.semibold)).foregroundStyle(Palette.ink)
            }.contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(title)
    }
}
struct RecordButton: View {
    let recording: Bool
    let title: String
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                ZStack {
                    Circle().fill(Palette.red)
                    if recording { RoundedRectangle(cornerRadius: 5).fill(.white).frame(width: 24, height: 24) }
                    else { Image(systemName: "mic.fill").font(.system(size: 26, weight: .semibold)).foregroundStyle(.white) }
                }.frame(width: 72, height: 72)
                Text(title).font(.subheadline.weight(.semibold)).foregroundStyle(Palette.ink).multilineTextAlignment(.center)
            }.contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(title)
    }
}

// MARK: - Risposte

enum ChoiceState {
    case idle, selected, correct, wrong, dimmed
    var spoken: String {
        switch self {
        case .selected: return "Selezionata"
        case .correct: return "Risposta corretta"
        case .wrong: return "La tua risposta, errata"
        default: return ""
        }
    }
}
/// Unico stile per le opzioni di ripasso, prove, grammatica, toni e dialoghi.
struct ChoiceStyle: ButtonStyle {
    var state: ChoiceState = .idle
    var alignment: Alignment = .leading
    func makeBody(configuration: Configuration) -> some View {
        let shape = RoundedRectangle(cornerRadius: 14, style: .continuous)
        return HStack(spacing: 10) {
            configuration.label.frame(maxWidth: .infinity, alignment: alignment)
            if let icon { Image(systemName: icon).font(.title3).foregroundStyle(tint).accessibilityHidden(true) }
        }
        .font(.body).foregroundStyle(state == .dimmed ? Palette.inkSoft : Palette.ink)
        .padding(.horizontal, 16).padding(.vertical, 12).frame(minHeight: 54)
        .background(fill(pressed: configuration.isPressed), in: shape)
        .overlay(shape.strokeBorder(tint, lineWidth: state == .idle || state == .dimmed ? 0 : 2))
        .contentShape(shape)
    }
    private var tint: Color {
        switch self.state {
        case .correct: return Palette.jade
        case .wrong: return Palette.red
        default: return Palette.ink
        }
    }
    private var icon: String? {
        switch state {
        case .selected: return "largecircle.fill.circle"
        case .correct: return "checkmark.circle.fill"
        case .wrong: return "xmark.circle.fill"
        default: return nil
        }
    }
    private func fill(pressed: Bool) -> Color {
        switch state {
        case .correct: return Color(hex: 0xE6F0EC)
        case .wrong: return Color(hex: 0xF7E8EA)
        case .selected: return Palette.sunken
        case .dimmed: return Palette.surface.opacity(0.6)
        case .idle: return pressed ? Palette.sunken : Palette.surface
        }
    }
}
struct ChoiceButton<Label: View>: View {
    var state: ChoiceState = .idle
    var alignment: Alignment = .leading
    let action: () -> Void
    @ViewBuilder var label: Label
    var body: some View {
        Button(action: action) { label }
            .buttonStyle(ChoiceStyle(state: state, alignment: alignment))
            .accessibilityValue(state.spoken)
            .accessibilityAddTraits(state == .selected ? .isSelected : [])
    }
}
struct FeedbackBanner<Content: View>: View {
    let correct: Bool
    let title: String
    @ViewBuilder var content: Content
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(title, systemImage: correct ? "checkmark.circle.fill" : "arrow.uturn.backward.circle.fill")
                .font(.headline).foregroundStyle(correct ? Palette.jade : Palette.red)
            content.font(.subheadline).foregroundStyle(Palette.ink)
        }
        .frame(maxWidth: .infinity, alignment: .leading).padding(16)
        .background(correct ? Color(hex: 0xE6F0EC) : Color(hex: 0xF7E8EA), in: RoundedRectangle(cornerRadius: Metrics.radius, style: .continuous))
    }
}
/// Interruttore a pastiglia per opzioni brevi dentro gli esercizi («Non sono sicuro», «0,8×»).
struct ChipToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        Button { configuration.isOn.toggle() } label: {
            HStack(spacing: 6) {
                Image(systemName: configuration.isOn ? "checkmark.circle.fill" : "circle").accessibilityHidden(true)
                configuration.label
            }
            .font(.subheadline.weight(.medium))
            .foregroundStyle(configuration.isOn ? Palette.paper : Palette.ink)
            .padding(.horizontal, 14).frame(minHeight: 44)
            .background(configuration.isOn ? Palette.ink : Palette.surface, in: Capsule())
            .overlay(Capsule().strokeBorder(configuration.isOn ? .clear : Palette.line))
            .contentShape(Capsule())
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(.isToggle)
        .accessibilityValue(configuration.isOn ? "Attivo" : "Non attivo")
    }
}
extension ToggleStyle where Self == ChipToggleStyle {
    static var chip: ChipToggleStyle { .init() }
}
extension View {
    /// Liste native sullo sfondo carta: stesso tono delle pagine, righe bianche.
    func paperList() -> some View {
        scrollContentBackground(.hidden).background(Palette.paper.ignoresSafeArea())
    }
}
