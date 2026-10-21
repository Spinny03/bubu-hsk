import Foundation
import AVFoundation
import Combine

/// YIN: differenza quadratica, media cumulativa normalizzata, soglia e interpolazione.
/// de Cheveigné & Kawahara (2002), doi:10.1121/1.1458024. Implementazione locale.
enum YIN {
    static func frequency(samples: [Float], sampleRate: Double, threshold: Double = 0.15) -> Double? {
        guard samples.count >= 256, sampleRate > 0 else { return nil }
        let rms=sqrt(samples.reduce(0.0){$0+Double($1*$1)}/Double(samples.count))
        guard rms>0.005 else { return nil }
        let minTau=max(2,Int(sampleRate/500)),maxTau=min(samples.count/2-1,Int(sampleRate/60))
        guard maxTau>minTau else {return nil}
        let window=samples.count-maxTau
        var difference=Array(repeating:0.0,count:maxTau+1), normalized=Array(repeating:1.0,count:maxTau+1)
        for tau in 1...maxTau {
            var sum=0.0
            for i in 0..<window {let d=Double(samples[i]-samples[i+tau]);sum+=d*d}
            difference[tau]=sum
        }
        var running=0.0
        for tau in 1...maxTau {running+=difference[tau];normalized[tau]=running>0 ? difference[tau]*Double(tau)/running : 1}
        var tau=minTau
        while tau<maxTau {
            if normalized[tau]<threshold {
                while tau+1<=maxTau && normalized[tau+1]<normalized[tau] {tau+=1}
                let left=max(1,tau-1),right=min(maxTau,tau+1)
                let denominator=normalized[left]-2*normalized[tau]+normalized[right]
                let shift=abs(denominator)>1e-12 ? 0.5*(normalized[left]-normalized[right])/denominator : 0
                let f=sampleRate/(Double(tau)+max(-1,min(1,shift)))
                return (60...500).contains(f) ? f : nil
            }
            tau+=1
        }
        return nil
    }
}
struct PitchFrame: Identifiable { let id=UUID();let time,hertz:Double }
struct ToneFeedback {
    let recognized,advice:String
    static func analyze(_ frames:[PitchFrame],baseline:Double?) -> Self {
        guard frames.count>=8,let first=frames.first,let last=frames.last,last.time-first.time>0.2 else {
            return Self(recognized:"Tono non riconosciuto",advice:"Prova in un posto silenzioso, avvicina il telefono e pronuncia una sillaba senza sussurrare.")
        }
        let f=frames.map{12*log2($0.hertz/(baseline ?? 180))}
        let k=max(2,f.count/4),start=f.prefix(k).reduce(0,+)/Double(k),end=f.suffix(k).reduce(0,+)/Double(k)
        let middle=Array(f.dropFirst(k).dropLast(k));let low=middle.min() ?? min(start,end)
        if low<start-1.5 && end>low+1.5 {return Self(recognized:"Compatibile con il 3° tono · ˇ",advice:"La curva scende e risale. Nelle parole, mantieni la parte bassa: la risalita completa spesso non serve.")}
        if end-start>2 {return Self(recognized:"Compatibile con il 2° tono · ˊ",advice:"La curva sale. Se cercavi il 3° tono, comincia più in basso e non trasformarlo subito in una salita.")}
        if start-end>2 {return Self(recognized:"Compatibile con il 4° tono · ˋ",advice:"La curva scende. Parti deciso e lascia cadere la voce senza aggiungere una risalita finale.")}
        if baseline != nil && f.reduce(0,+)/Double(f.count)<(-2) {return Self(recognized:"Compatibile con il 3° tono basso · ˇ",advice:"La voce rimane bassa: è utile nel parlato continuo. Prova ora una parola di due sillabe.")}
        return Self(recognized:baseline == nil ? "Curva quasi piatta · tono incerto" : "Compatibile con il 1° tono · ˉ",advice:baseline == nil ? "Calibra prima la voce: una curva piatta può essere alta oppure bassa." : "Mantieni la voce stabile. Per il 3° tono devi scendere sotto il tuo livello abituale.")
    }
}
@MainActor final class PitchRecorder: ObservableObject {
    @Published var frames:[PitchFrame]=[]
    @Published var recording=false
    @Published var error:String?
    @Published var baseline:Double?
    private let engine=AVAudioEngine()
    private var tapInstalled=false
    private var started=0.0
    private var calibrating=false
    private var generation=UUID()
    private var limitTask:Task<Void,Never>?
    func start(calibration:Bool=false) async {
        stop();let request=UUID();generation=request
        let granted=await AVAudioApplication.requestRecordPermission()
        guard generation==request else{return}
        guard granted else {error="Microfono non autorizzato. Puoi abilitarlo nelle impostazioni di iOS.";return}
        do {
            let session=AVAudioSession.sharedInstance();try session.setCategory(.playAndRecord,mode:.measurement,options:[.defaultToSpeaker]);try session.setActive(true)
            let input=engine.inputNode,format=input.outputFormat(forBus:0)
            guard format.sampleRate>0,format.channelCount>0 else {error="Nessun ingresso audio disponibile.";return}
            frames=[];error=nil;calibrating=calibration;started=ProcessInfo.processInfo.systemUptime
            let origin=started
            input.installTap(onBus:0,bufferSize:4096,format:format) { [weak self] buffer,_ in
                guard let channel=buffer.floatChannelData?[0] else{return}
                let factor=max(1,Int(buffer.format.sampleRate/12000)),count=Int(buffer.frameLength)
                var samples:[Float]=[];samples.reserveCapacity(count/factor)
                for i in stride(from:0,to:count-factor+1,by:factor) {var sum:Float=0;for j in 0..<factor{sum+=channel[i+j]};samples.append(sum/Float(factor))}
                guard let frequency=YIN.frequency(samples:samples,sampleRate:buffer.format.sampleRate/Double(factor)) else{return}
                let time=ProcessInfo.processInfo.systemUptime-origin
                Task { @MainActor in guard let self,self.recording,self.generation==request else{return};self.frames.append(PitchFrame(time:time,hertz:frequency));if time>=5 {self.stop()} }
            }
            tapInstalled=true;engine.prepare();try engine.start();recording=true
            limitTask=Task { try? await Task.sleep(nanoseconds:5_000_000_000); guard !Task.isCancelled else{return}; self.stop() }
        } catch {self.error="Registrazione non disponibile: \(error.localizedDescription)";stop()}
    }
    func stop() {
        generation=UUID();limitTask?.cancel();limitTask=nil
        engine.stop();if tapInstalled {engine.inputNode.removeTap(onBus:0);tapInstalled=false}
        if calibrating && frames.count>=8 {let f=frames.map(\.hertz).sorted();baseline=f[f.count/2]}
        calibrating=false;recording=false
    }
}
struct ToneExercise:Identifiable {
    let id,hanzi,pinyin,pattern,advice:String
    static let all:[Self]=[
        .init(id:"hao",hanzi:"好",pinyin:"hǎo",pattern:"3",advice:"Parti basso. In una frase il terzo tono spesso resta basso, senza risalire del tutto."),
        .init(id:"nihao",hanzi:"你好",pinyin:"nǐ hǎo",pattern:"2–3",advice:"Due terzi toni: il primo si pronuncia come un secondo. La grafia di dizionario conserva nǐ hǎo."),
        .init(id:"henhao",hanzi:"很好",pinyin:"hěn hǎo",pattern:"2–3",advice:"Prima sillaba in salita, seconda bassa. Non pronunciare due curve complete e separate."),
        .init(id:"shuiguo",hanzi:"水果",pinyin:"shuǐguǒ",pattern:"2–3",advice:"Il primo terzo tono cambia in secondo: tieni unite le due sillabe."),
        .init(id:"laoshi",hanzi:"老师",pinyin:"lǎoshī",pattern:"3–1",advice:"La prima sillaba resta bassa; la seconda è alta e stabile.")
    ]
}
