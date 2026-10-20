import Foundation

/// Collegamento tra pinyin e Alfabeto fonetico internazionale.
/// Trascrizione larga del cinese standard (Putonghua) secondo le tabelle di Wikipedia «Pinyin» e
/// «Standard Chinese phonology» (basate su Lee & Zee 2003, JIPA 33(1); Duanmu 2007; Lin 2007),
/// erhua secondo «Erhua» (Duanmu 2007; Lin 2007), toni con le lettere di Chao (1968).
/// Le varianti regionali e individuali sono escluse: è un riferimento per lo studio, non un'analisi fonetica.
enum PinyinIPA {
    struct Sound: Identifiable, Hashable {
        let id: String
        /// Grafia mostrata, per esempio «iu (you)».
        let pinyin: String
        let ipa: String
        let group: String
        let hint: String
    }
    struct Syllable: Hashable {
        let text: String
        let initial: String
        let final: String
        let tone: Int
        let erhua: Bool
    }
    struct Tone: Identifiable, Hashable {
        let id: Int
        let example: String
        let letters: String
        let chao: String
        let levels: [Int]
        let hint: String
    }

    static let initials: [Sound] = [
        .init(id: "b", pinyin: "b", ipa: "p", group: "Labiali", hint: "Come la p di «pane»: senza soffio. Non è la b sonora italiana."),
        .init(id: "p", pinyin: "p", ipa: "pʰ", group: "Labiali", hint: "La stessa p con un soffio d’aria udibile, come in inglese «pen»."),
        .init(id: "m", pinyin: "m", ipa: "m", group: "Labiali", hint: "Come in italiano."),
        .init(id: "f", pinyin: "f", ipa: "f", group: "Labiali", hint: "Come in italiano."),
        .init(id: "d", pinyin: "d", ipa: "t", group: "Alveolari", hint: "Come la t di «tavolo»: senza soffio. Non è la d sonora italiana."),
        .init(id: "t", pinyin: "t", ipa: "tʰ", group: "Alveolari", hint: "La stessa t con un soffio d’aria udibile."),
        .init(id: "n", pinyin: "n", ipa: "n", group: "Alveolari", hint: "Come in italiano."),
        .init(id: "l", pinyin: "l", ipa: "l", group: "Alveolari", hint: "Come in italiano."),
        .init(id: "g", pinyin: "g", ipa: "k", group: "Velari", hint: "Come la c di «casa»: senza soffio. Non è la g sonora italiana."),
        .init(id: "k", pinyin: "k", ipa: "kʰ", group: "Velari", hint: "La c di «casa» con un soffio d’aria udibile."),
        .init(id: "h", pinyin: "h", ipa: "x", group: "Velari", hint: "Fricativa in fondo alla bocca, come la j spagnola di «jamón», ma più morbida."),
        .init(id: "j", pinyin: "j", ipa: "tɕ", group: "Palatali", hint: "Vicina alla c di «cena», con la lingua piatta contro il palato e la punta dietro i denti inferiori. Senza soffio."),
        .init(id: "q", pinyin: "q", ipa: "tɕʰ", group: "Palatali", hint: "Come j, con un soffio d’aria. Non è la q italiana."),
        .init(id: "x", pinyin: "x", ipa: "ɕ", group: "Palatali", hint: "Tra la s di «sole» e la sc di «scena», con la lingua piatta in avanti. Non è la x italiana."),
        .init(id: "zh", pinyin: "zh", ipa: "ʈʂ", group: "Retroflesse", hint: "Vicina alla c di «cena», con la punta della lingua sollevata verso il palato. Senza soffio."),
        .init(id: "ch", pinyin: "ch", ipa: "ʈʂʰ", group: "Retroflesse", hint: "Come zh, con un soffio d’aria."),
        .init(id: "sh", pinyin: "sh", ipa: "ʂ", group: "Retroflesse", hint: "Vicina alla sc di «scena», con la punta della lingua sollevata e arretrata."),
        .init(id: "r", pinyin: "r", ipa: "ʐ", group: "Retroflesse", hint: "Come sh, ma con la voce. Alcuni autori la trascrivono [ɻ], simile alla r inglese di «red»."),
        .init(id: "z", pinyin: "z", ipa: "ts", group: "Dentali", hint: "Come la z sorda di «pizza», senza soffio."),
        .init(id: "c", pinyin: "c", ipa: "tsʰ", group: "Dentali", hint: "Come z, con un soffio d’aria. Non è la c italiana."),
        .init(id: "s", pinyin: "s", ipa: "s", group: "Dentali", hint: "Come la s di «sole»."),
        .init(id: "y", pinyin: "y", ipa: "j", group: "Semivocali", hint: "Come la i di «ieri». Davanti a u (yu, yue, yuan, yun) indica la ü."),
        .init(id: "w", pinyin: "w", ipa: "w", group: "Semivocali", hint: "Come la u di «uovo»."),
    ]
    static let finals: [Sound] = [
        .init(id: "a", pinyin: "a", ipa: "a", group: "Semplici", hint: "Come la a di «casa»."),
        .init(id: "o", pinyin: "o", ipa: "o", group: "Semplici", hint: "O chiusa. Dopo b, p, m, f molti parlanti inseriscono una breve [w]: bō [pwo]."),
        .init(id: "e", pinyin: "e", ipa: "ɤ", group: "Semplici", hint: "Come una o pronunciata senza arrotondare le labbra. Non è la e italiana."),
        .init(id: "ê", pinyin: "ê", ipa: "ɛ", group: "Semplici", hint: "E aperta di «bello». Si usa quasi solo nelle interiezioni."),
        .init(id: "er", pinyin: "er", ipa: "aɚ̯", group: "Semplici", hint: "Vocale centrale con la lingua che si arrotola indietro. Nel sud e a Taiwan si sente [ɚ]."),
        .init(id: "-i₁", pinyin: "-i (zi ci si)", ipa: "ɹ̩", group: "Semplici", hint: "Non è una i: la lingua resta nella posizione di z, c, s e la voce continua, come un ronzio."),
        .init(id: "-i₂", pinyin: "-i (zhi chi shi ri)", ipa: "ɻ̩", group: "Semplici", hint: "Non è una i: la lingua resta sollevata come per zh, ch, sh, r e la voce continua."),
        .init(id: "ai", pinyin: "ai", ipa: "ai̯", group: "Dittonghi", hint: "Come «ai» in «mai»."),
        .init(id: "ei", pinyin: "ei", ipa: "ei̯", group: "Dittonghi", hint: "Come «ei» in «lei»."),
        .init(id: "ao", pinyin: "ao", ipa: "au̯", group: "Dittonghi", hint: "Come «au» in «auto», non «ao»."),
        .init(id: "ou", pinyin: "ou", ipa: "ou̯", group: "Dittonghi", hint: "O chiusa seguita da una breve u."),
        .init(id: "an", pinyin: "an", ipa: "an", group: "Nasali", hint: "Come «an» in «canto»."),
        .init(id: "en", pinyin: "en", ipa: "ən", group: "Nasali", hint: "Vocale indistinta [ə], poi n."),
        .init(id: "ang", pinyin: "ang", ipa: "aŋ", group: "Nasali", hint: "A seguita dal suono [ŋ] di «banca», senza pronunciare la g."),
        .init(id: "eng", pinyin: "eng", ipa: "əŋ", group: "Nasali", hint: "[ə] seguita da [ŋ], come in «fungo» senza la g."),
        .init(id: "ong", pinyin: "ong", ipa: "ʊŋ", group: "Nasali", hint: "Una u aperta seguita da [ŋ]. Non è la o italiana."),
        .init(id: "i", pinyin: "i (yi)", ipa: "i", group: "Con i-", hint: "Come la i di «vino»."),
        .init(id: "ia", pinyin: "ia (ya)", ipa: "ja", group: "Con i-", hint: "Come «ia» in «piano»."),
        .init(id: "ie", pinyin: "ie (ye)", ipa: "je", group: "Con i-", hint: "Come «ie» in «ieri», con e chiusa."),
        .init(id: "iao", pinyin: "iao (yao)", ipa: "jau̯", group: "Con i-", hint: "Come «iao» in «miao»."),
        .init(id: "iu", pinyin: "iu (you)", ipa: "jou̯", group: "Con i-", hint: "Si scrive iu, ma si pronuncia «iou»: la o è breve, però c’è."),
        .init(id: "ian", pinyin: "ian (yan)", ipa: "jɛn", group: "Con i-", hint: "La a diventa una e aperta: si sente «ien»."),
        .init(id: "in", pinyin: "in (yin)", ipa: "in", group: "Con i-", hint: "I seguita da n."),
        .init(id: "iang", pinyin: "iang (yang)", ipa: "jaŋ", group: "Con i-", hint: "«Ia» seguita da [ŋ]."),
        .init(id: "ing", pinyin: "ing (ying)", ipa: "iŋ", group: "Con i-", hint: "I seguita da [ŋ], come in «vinco» senza la c."),
        .init(id: "iong", pinyin: "iong (yong)", ipa: "jʊŋ", group: "Con i-", hint: "I breve seguita da ong."),
        .init(id: "u", pinyin: "u (wu)", ipa: "u", group: "Con u-", hint: "Come la u di «luna»."),
        .init(id: "ua", pinyin: "ua (wa)", ipa: "wa", group: "Con u-", hint: "Come «ua» in «guado»."),
        .init(id: "uo", pinyin: "uo (wo)", ipa: "wo", group: "Con u-", hint: "Come «uo» in «uomo», con o chiusa."),
        .init(id: "uai", pinyin: "uai (wai)", ipa: "wai̯", group: "Con u-", hint: "Come «uai» in «guai»."),
        .init(id: "ui", pinyin: "ui (wei)", ipa: "wei̯", group: "Con u-", hint: "Si scrive ui, ma si pronuncia «uei», come in «quei»."),
        .init(id: "uan", pinyin: "uan (wan)", ipa: "wan", group: "Con u-", hint: "Come «uan» in «quando»."),
        .init(id: "un", pinyin: "un (wen)", ipa: "wən", group: "Con u-", hint: "Si scrive un, ma si pronuncia «uen» con vocale indistinta."),
        .init(id: "uang", pinyin: "uang (wang)", ipa: "waŋ", group: "Con u-", hint: "«Ua» seguita da [ŋ]."),
        .init(id: "ueng", pinyin: "weng", ipa: "wəŋ", group: "Con u-", hint: "Esiste solo come sillaba weng."),
        .init(id: "ü", pinyin: "ü (yu)", ipa: "y", group: "Con ü-", hint: "Di’ «i» arrotondando le labbra come per «u»: la u francese di «tu». Dopo j, q, x e y si scrive u."),
        .init(id: "üe", pinyin: "üe (yue)", ipa: "ɥe", group: "Con ü-", hint: "Ü che scivola su una e chiusa. Dopo j, q, x e y si scrive ue."),
        .init(id: "üan", pinyin: "üan (yuan)", ipa: "ɥɛn", group: "Con ü-", hint: "Ü seguita da «en» aperta. Dopo j, q, x e y si scrive uan."),
        .init(id: "ün", pinyin: "ün (yun)", ipa: "yn", group: "Con ü-", hint: "Ü seguita da n. Dopo j, q, x e y si scrive un."),
    ]
    /// Livelli di Chao: 5 alto, 1 basso.
    static let tones: [Tone] = [
        .init(id: 1, example: "mā", letters: "˥", chao: "55", levels: [5, 5], hint: "Alto e piatto, tenuto fino alla fine."),
        .init(id: 2, example: "má", letters: "˧˥", chao: "35", levels: [3, 5], hint: "Sale da medio ad alto, come una domanda sorpresa."),
        .init(id: 3, example: "mǎ", letters: "˨˩˦", chao: "214", levels: [2, 1, 4], hint: "Scende in basso e risale. Dentro la parola resta basso [˨˩]; prima di un altro 3° tono diventa [˧˥]."),
        .init(id: 4, example: "mà", letters: "˥˩", chao: "51", levels: [5, 1], hint: "Cade deciso da alto a basso."),
        .init(id: 0, example: "ma", letters: "˨ ˧ ˦ ˩", chao: "—", levels: [3, 3], hint: "Breve e leggero. L’altezza dipende dal tono precedente: [˨] dopo il 1°, [˧] dopo il 2°, [˦] dopo il 3°, [˩] dopo il 4°."),
    ]
    static func sound(_ id: String) -> Sound? { (initials + finals).first { $0.id == id } }
    static func finalSound(for syllable: Syllable) -> Sound? { finals.first { $0.id == syllable.final } }
    static func initialSound(for syllable: Syllable) -> Sound? {
        if !syllable.initial.isEmpty { return initials.first { $0.id == syllable.initial } }
        // Le sillabe senza iniziale si scrivono con y e w: mostriamo la semivocale come porta d'ingresso.
        if syllable.text.lowercased().hasPrefix("y") { return initials.first { $0.id == "y" } }
        if syllable.text.lowercased().hasPrefix("w") { return initials.first { $0.id == "w" } }
        return nil
    }

    private static let finalIPA = Dictionary(uniqueKeysWithValues: finals.map { ($0.id, $0.ipa) })
    private static let initialIPA = Dictionary(uniqueKeysWithValues: initials.filter { $0.group != "Semivocali" }.map { ($0.id, $0.ipa) })
    /// Finali rotacizzate presenti nel lessico HSK 1 (tabella della voce «Erhua»).
    private static let erhuaIPA = ["a": "ɐʵ", "ai": "ɐʵ", "an": "ɐʵ", "e": "ɤʵ", "ia": "jɐʵ", "ian": "jɐʵ", "ua": "wɐʵ", "uan": "wɐʵ",
                                   "üan": "ɥɐʵ", "ao": "ɑu̯˞", "iao": "jɑu̯˞", "ou": "ou̯˞", "u": "u˞"]
    private static let toneMarks: [Character: (Character, Int)] = [
        "ā": ("a", 1), "á": ("a", 2), "ǎ": ("a", 3), "à": ("a", 4), "ē": ("e", 1), "é": ("e", 2), "ě": ("e", 3), "è": ("e", 4),
        "ī": ("i", 1), "í": ("i", 2), "ǐ": ("i", 3), "ì": ("i", 4), "ō": ("o", 1), "ó": ("o", 2), "ǒ": ("o", 3), "ò": ("o", 4),
        "ū": ("u", 1), "ú": ("u", 2), "ǔ": ("u", 3), "ù": ("u", 4), "ǖ": ("ü", 1), "ǘ": ("ü", 2), "ǚ": ("ü", 3), "ǜ": ("ü", 4),
    ]
    private static let zeroInitial = ["yi": "i", "ya": "ia", "ye": "ie", "yao": "iao", "you": "iu", "yan": "ian", "yin": "in", "yang": "iang",
                                      "ying": "ing", "yong": "iong", "yu": "ü", "yue": "üe", "yuan": "üan", "yun": "ün", "wu": "u", "wa": "ua",
                                      "wo": "uo", "wai": "uai", "wei": "ui", "wan": "uan", "wen": "un", "wang": "uang", "weng": "ueng",
                                      "a": "a", "o": "o", "e": "e", "ê": "ê", "ai": "ai", "ei": "ei", "ao": "ao", "ou": "ou", "an": "an",
                                      "en": "en", "ang": "ang", "eng": "eng", "er": "er"]
    private static let initialOrder = ["zh", "ch", "sh", "b", "p", "m", "f", "d", "t", "n", "l", "g", "k", "h", "j", "q", "x", "r", "z", "c", "s"]
    private static let iSeries: Set<String> = ["i", "ia", "ie", "iao", "iu", "ian", "in", "iang", "ing", "iong"]
    private static let uSeries: Set<String> = ["ua", "uo", "uai", "ui", "uan", "un", "uang"]
    private static let üSeries: Set<String> = ["ü", "üe", "üan", "ün"]

    /// Una sillaba con al più un segno di tono; restituisce nil se la combinazione non esiste in pinyin.
    static func parse(_ raw: String) -> Syllable? {
        var plain = "", tone = 0, marks = 0
        for character in raw.lowercased() {
            if let (base, value) = toneMarks[character] { plain.append(base); tone = value; marks += 1 }
            else if character == "ü" || character == "ê" || ("a"..."z").contains(character) { plain.append(character) }
            else { return nil }
        }
        guard marks <= 1, !plain.isEmpty else { return nil }
        if let (initial, final) = structure(plain) { return Syllable(text: raw, initial: initial, final: final, tone: tone, erhua: false) }
        if plain.count > 1, plain.hasSuffix("r"), let (initial, final) = structure(String(plain.dropLast())), final != "er", erhuaIPA[final] != nil {
            return Syllable(text: raw, initial: initial, final: final, tone: tone, erhua: true)
        }
        return nil
    }
    private static func structure(_ plain: String) -> (String, String)? {
        if let final = zeroInitial[plain] { return ("", final) }
        for initial in initialOrder where plain.hasPrefix(initial) {
            var final = String(plain.dropFirst(initial.count))
            if ["j", "q", "x"].contains(initial) { final = ["u": "ü", "ue": "üe", "uan": "üan", "un": "ün"][final] ?? final }
            if final == "i" && ["z", "c", "s"].contains(initial) { final = "-i₁" }
            if final == "i" && ["zh", "ch", "sh", "r"].contains(initial) { final = "-i₂" }
            guard finalIPA[final] != nil, valid(initial, final) else { continue }
            return (initial, final)
        }
        return nil
    }
    private static func valid(_ initial: String, _ final: String) -> Bool {
        if ["er", "ê", "ueng"].contains(final) { return false }
        if final == "-i₁" { return ["z", "c", "s"].contains(initial) }
        if final == "-i₂" { return ["zh", "ch", "sh", "r"].contains(initial) }
        switch initial {
        case "j", "q", "x": return iSeries.contains(final) || üSeries.contains(final)
        case "zh", "ch", "sh", "r", "z", "c", "s", "g", "k", "h": return !iSeries.contains(final) && !üSeries.contains(final) && final != "o"
        case "b", "p", "m", "f": return !uSeries.contains(final) && !üSeries.contains(final) && final != "ong"
        case "d", "t": return !üSeries.contains(final)
        default: return true
        }
    }
    /// Divide un pinyin in sillabe. Spazi e apostrofi separano; senza apostrofo una sillaba interna non comincia per a, o, e.
    static func segment(_ pinyin: String) -> [Syllable]? {
        var result: [Syllable] = []
        for run in pinyin.split(whereSeparator: { " -'’".contains($0) }) {
            let characters = Array(run)
            var memo: [Int: [Syllable]?] = [:]
            func split(_ start: Int) -> [Syllable]? {
                if start == characters.count { return [] }
                if let known = memo[start] { return known }
                var found: [Syllable]? = nil
                for length in stride(from: min(7, characters.count - start), through: 1, by: -1) {
                    let piece = String(characters[start..<start+length])
                    if start > 0, let first = piece.lowercased().first, "aāáǎàoōóǒòeēéěè".contains(first) { continue }
                    if let syllable = parse(piece), let rest = split(start + length) { found = [syllable] + rest; break }
                }
                memo[start] = found
                return found
            }
            guard let syllables = split(0) else { return nil }
            result += syllables
        }
        return result.isEmpty ? nil : result
    }
    /// Suono della sillaba senza tono.
    static func segmental(_ syllable: Syllable) -> String {
        let onset = initialIPA[syllable.initial] ?? ""
        if syllable.erhua, let rhotic = erhuaIPA[syllable.final] { return onset + rhotic }
        return onset + (finalIPA[syllable.final] ?? "")
    }
    /// Lettere di Chao con le regole regolari: 3° basso dentro la parola, 3°+3° → 2°+3°, tono neutro secondo il precedente.
    static func toneLetters(_ syllables: [Syllable], at index: Int) -> String {
        let tone = syllables[index].tone
        let next = index + 1 < syllables.count ? syllables[index + 1].tone : nil
        switch tone {
        case 1: return "˥"
        case 2: return "˧˥"
        case 3:
            guard let next else { return "˨˩˦" }
            return next == 3 ? "˧˥" : "˨˩"
        case 4: return "˥˩"
        default:
            guard index > 0 else { return "" }
            return ["˧", "˨", "˧", "˦", "˩"][syllables[index - 1].tone]
        }
    }
    /// Trascrizione completa tra parentesi quadre; per le grafie alternative («shéi/shuí») trascrive ciascuna.
    static func transcribe(_ pinyin: String) -> String? {
        let forms = pinyin.split(separator: "/").map { String($0).trimmingCharacters(in: .whitespaces) }
        let transcribed = forms.compactMap { form -> String? in
            guard let syllables = segment(form) else { return nil }
            return "[" + syllables.indices.map { segmental(syllables[$0]) + toneLetters(syllables, at: $0) }.joined(separator: ".") + "]"
        }
        return transcribed.count == forms.count ? transcribed.joined(separator: " / ") : nil
    }
    /// Sillabe della prima grafia, per collegare ogni parte ai suoni della tabella.
    static func syllables(_ pinyin: String) -> [Syllable] {
        pinyin.split(separator: "/").first.flatMap { segment(String($0)) } ?? []
    }
    /// «ni3 hao3» → «nǐ hǎo»: i numeri 1–4 diventano segni di tono, 5 o 0 indicano il tono neutro; v e u: valgono ü.
    static func markTones(_ input: String) -> String {
        let text = input.lowercased().replacingOccurrences(of: "u:", with: "ü").replacingOccurrences(of: "v", with: "ü")
        guard text.contains(where: \.isNumber) else { return text }
        let marks: [Character: [Character]] = ["a": ["ā", "á", "ǎ", "à"], "e": ["ē", "é", "ě", "è"], "i": ["ī", "í", "ǐ", "ì"],
                                               "o": ["ō", "ó", "ǒ", "ò"], "u": ["ū", "ú", "ǔ", "ù"], "ü": ["ǖ", "ǘ", "ǚ", "ǜ"]]
        var result = "", syllable = ""
        for character in text {
            if let tone = character.wholeNumberValue {
                // Regola della grafia: a ed e prendono il segno; in «ou» lo prende la o; altrimenti l'ultima vocale.
                var letters = Array(syllable)
                let target = letters.firstIndex(of: "a") ?? letters.firstIndex(of: "e")
                    ?? (syllable.contains("ou") ? letters.firstIndex(of: "o") : letters.lastIndex { "iouü".contains($0) })
                if (1...4).contains(tone), let target, let options = marks[letters[target]] { letters[target] = options[tone - 1] }
                result += String(letters); syllable = ""
            } else if character.isLetter { syllable.append(character) }
            else { result += syllable + String(character); syllable = "" }
        }
        return result + syllable
    }
    /// Confronto tra grafie: minuscole, senza spazi né apostrofi.
    static func normalized(_ pinyin: String) -> String { pinyin.lowercased().filter(\.isLetter) }
    /// Parole del lessico che contengono un'iniziale o una finale.
    static func examples(for sound: Sound, in words: [Word], limit: Int = 8) -> [Word] {
        let isInitial = initials.contains(sound)
        return Array(words.filter { word in
            syllables(word.pinyin).contains { syllable in
                if isInitial { return initialSound(for: syllable)?.id == sound.id }
                return syllable.final == sound.id
            }
        }.prefix(limit))
    }
}
