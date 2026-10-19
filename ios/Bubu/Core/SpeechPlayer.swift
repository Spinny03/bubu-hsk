import Foundation
import AVFoundation
import CryptoKit
import Combine

/// Serializza i buffer della sintesi su un file locale. Nessun servizio remoto.
private final class SpeechFileWriter: @unchecked Sendable {
    private let lock=NSLock()
    private var file:AVAudioFile?
    private var failure:Error?
    private var completed=false
    let url:URL
    init(url:URL){self.url=url}
    func append(_ buffer:AVAudioPCMBuffer)->(finished:Bool,error:Error?) {
        lock.lock();defer{lock.unlock()}
        guard !completed else { return (false,nil) }
        if buffer.frameLength==0 {completed=true;file=nil;return (true,failure)}
        do {
            if file==nil && failure==nil {file=try AVAudioFile(forWriting:url,settings:buffer.format.settings)}
            try file?.write(from:buffer)
        }catch{failure=error}
        return (false,failure)
    }
}
@MainActor final class SpeechPlayer:NSObject,ObservableObject,AVAudioPlayerDelegate {
    @Published var isSpeaking=false
    @Published var error:String?
    private let synthesizer=AVSpeechSynthesizer()
    private var player:AVAudioPlayer?
    private var continuation:CheckedContinuation<Void,Never>?
    private var generation=UUID()
    var voices:[AVSpeechSynthesisVoice]{AVSpeechSynthesisVoice.speechVoices().filter{$0.language=="zh-CN"}.sorted{$0.identifier<$1.identifier}}
    func speak(_ text:String,slow:Bool=false,voiceIndex:Int=0) {
        stop();let request=UUID();generation=request
        do {try AVAudioSession.sharedInstance().setCategory(.playback,mode:.spokenAudio);try AVAudioSession.sharedInstance().setActive(true)}
        catch{self.error="Audio non disponibile: \(error.localizedDescription)";return}
        guard let voice=voices.isEmpty ? AVSpeechSynthesisVoice(language:"zh-CN") : voices[voiceIndex%voices.count] else{error="Voce cinese non disponibile. Scaricala nelle impostazioni di accessibilità di iOS.";return}
        error=nil;isSpeaking=true
        let folder=FileManager.default.urls(for:.cachesDirectory,in:.userDomainMask)[0].appendingPathComponent("Speech",isDirectory:true)
        let key=SHA256.hash(data:Data((voice.identifier+"|"+text).utf8)).map{String(format:"%02x",$0)}.joined()
        let url=folder.appendingPathComponent(key+".caf")
        do {try FileManager.default.createDirectory(at:folder,withIntermediateDirectories:true)}catch{failed(error);return}
        if FileManager.default.fileExists(atPath:url.path),let file=try? AVAudioFile(forReading:url),file.length>0 {play(url,slow:slow);return}
        let temporary=folder.appendingPathComponent(request.uuidString+".caf")
        let writer=SpeechFileWriter(url:temporary)
        let utterance=AVSpeechUtterance(string:text);utterance.voice=voice;utterance.rate=AVSpeechUtteranceDefaultSpeechRate
        synthesizer.write(utterance){[weak self] buffer in
            guard let pcm=buffer as? AVAudioPCMBuffer else{return}
            let result=writer.append(pcm)
            if result.finished {
                Task{@MainActor in
                    guard let self,self.generation==request else{try? FileManager.default.removeItem(at:temporary);return}
                    if let error=result.error{self.failed(error);return}
                    do {
                        if FileManager.default.fileExists(atPath:url.path){try FileManager.default.removeItem(at:url)}
                        try FileManager.default.moveItem(at:temporary,to:url)
                        self.play(url,slow:slow)
                    }catch{self.failed(error)}
                }
            }
        }
    }
    private func play(_ url:URL,slow:Bool) {
        do {player=try AVAudioPlayer(contentsOf:url);player?.delegate=self;player?.enableRate=true;player?.rate=slow ? 0.8 : 1
            guard player?.play()==true else{failed(CocoaError(.fileReadCorruptFile));return}
        }catch{failed(error)}
    }
    private func failed(_ error:Error){self.error="Riproduzione non riuscita: \(error.localizedDescription)";isSpeaking=false;continuation?.resume();continuation=nil}
    func speakAndWait(_ text:String,voiceIndex:Int=0) async {
        guard !Task.isCancelled else{return}
        speak(text,voiceIndex:voiceIndex);guard isSpeaking else{return}
        await withTaskCancellationHandler {
            await withCheckedContinuation{continuation=$0}
        } onCancel:{Task{@MainActor in self.stop()}}
    }
    func stop(){generation=UUID();synthesizer.stopSpeaking(at:.immediate);player?.stop();player=nil;isSpeaking=false;continuation?.resume();continuation=nil}
    nonisolated func audioPlayerDidFinishPlaying(_ player:AVAudioPlayer,successfully flag:Bool){Task{@MainActor in guard self.player===player else{return};self.isSpeaking=false;if !flag{self.error="La riproduzione audio si è interrotta."};self.continuation?.resume();self.continuation=nil}}
    nonisolated func audioPlayerDecodeErrorDidOccur(_ player:AVAudioPlayer,error:Error?){Task{@MainActor in guard self.player===player else{return};self.failed(error ?? CocoaError(.fileReadCorruptFile))}}
}
struct PinyinTone {
    static func number(_ syllable:String)->Int {
        for(i,chars)in ["āēīōūǖ","áéíóúǘ","ǎěǐǒǔǚ","àèìòùǜ"].enumerated(){if syllable.lowercased().contains(where:{chars.contains($0)}){return i+1}}
        return 0
    }
}
