import Foundation
import AVFoundation

@MainActor final class SpeechPlayer: NSObject, ObservableObject, AVSpeechSynthesizerDelegate {
    @Published var isSpeaking = false
    @Published var error: String?
    let synthesizer = AVSpeechSynthesizer()
    private var continuation: CheckedContinuation<Void, Never>?
    var voices: [AVSpeechSynthesisVoice] { AVSpeechSynthesisVoice.speechVoices().filter { $0.language == "zh-CN" }.sorted { $0.identifier < $1.identifier } }
    override init() { super.init(); synthesizer.delegate = self }
    func speak(_ text: String, slow: Bool = false, voiceIndex: Int = 0) {
        stop()
        do { try AVAudioSession.sharedInstance().setCategory(.playback, mode: .spokenAudio); try AVAudioSession.sharedInstance().setActive(true) }
        catch { self.error = "Audio non disponibile: \(error.localizedDescription)"; return }
        guard let voice = voices.isEmpty ? AVSpeechSynthesisVoice(language: "zh-CN") : voices[voiceIndex % voices.count] else {
            error = "Voce cinese non disponibile. Scarica una voce cinese nelle impostazioni di accessibilità di iOS."; return
        }
        error = nil
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = voice; utterance.rate = AVSpeechUtteranceDefaultSpeechRate * (slow ? 0.8 : 1)
        isSpeaking = true; synthesizer.speak(utterance)
    }
    func speakAndWait(_ text: String, voiceIndex: Int = 0) async {
        guard !Task.isCancelled else { return }
        speak(text, voiceIndex: voiceIndex)
        guard isSpeaking else { return }
        await withTaskCancellationHandler {
            await withCheckedContinuation { continuation = $0 }
        } onCancel: { Task { @MainActor in self.stop() } }
    }
    func stop() {
        synthesizer.stopSpeaking(at: .immediate); isSpeaking = false
        continuation?.resume(); continuation = nil
    }
    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        Task { @MainActor in self.isSpeaking = false; self.continuation?.resume(); self.continuation = nil }
    }
    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        // stop() riprende la continuation sincronicamente; un callback vecchio non deve terminare un nuovo audio.
    }
}
struct PinyinTone {
    static func number(_ syllable: String) -> Int {
        for (i, chars) in ["āēīōūǖ", "áéíóúǘ", "ǎěǐǒǔǚ", "àèìòùǜ"].enumerated() {
            if syllable.lowercased().contains(where: { chars.contains($0) }) { return i+1 }
        }
        return 0
    }
}
