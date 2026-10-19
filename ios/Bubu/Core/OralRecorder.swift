import Foundation
import AVFoundation
import Combine
@MainActor final class OralRecorder:NSObject,ObservableObject,AVAudioRecorderDelegate,AVAudioPlayerDelegate {
    @Published var recording=false
    @Published var files:[URL]=[]
    @Published var error:String?
    @Published var remaining=0
    private var recorder:AVAudioRecorder?
    private var player:AVAudioPlayer?
    private var deadline:Date?
    private var token=UUID()
    var directory:URL{FileManager.default.urls(for:.applicationSupportDirectory,in:.userDomainMask)[0].appendingPathComponent("Oral",isDirectory:true)}
    override init(){super.init();reload()}
    func start(seconds:Int) async {
        stop();let request=UUID();token=request
        let permitted=await AVAudioApplication.requestRecordPermission();guard token==request else{return}
        guard permitted else{error="Autorizza il microfono nelle impostazioni di iOS per registrare.";return}
        do {
            try FileManager.default.createDirectory(at:directory,withIntermediateDirectories:true)
            let session=AVAudioSession.sharedInstance();try session.setCategory(.playAndRecord,mode:.default,options:[.defaultToSpeaker]);try session.setActive(true)
            let url=directory.appendingPathComponent("\(UUID().uuidString).m4a")
            recorder=try AVAudioRecorder(url:url,settings:[AVFormatIDKey:Int(kAudioFormatMPEG4AAC),AVSampleRateKey:44100,AVNumberOfChannelsKey:1,AVEncoderAudioQualityKey:AVAudioQuality.high.rawValue])
            guard recorder?.record(forDuration:Double(seconds))==true else{error="Impossibile avviare la registrazione.";return}
            deadline=Date().addingTimeInterval(Double(seconds));remaining=seconds;recording=true;error=nil
        }catch{self.error=error.localizedDescription;stop()}
    }
    func tick(){guard let deadline else{return};remaining=max(0,Int(ceil(deadline.timeIntervalSinceNow)));if remaining==0{stop()}}
    func stop(){token=UUID();recorder?.stop();recorder=nil;player?.stop();recording=false;deadline=nil;reload()}
    func play(_ url:URL){stop();do{try AVAudioSession.sharedInstance().setCategory(.playback,mode:.spokenAudio);try AVAudioSession.sharedInstance().setActive(true);player=try AVAudioPlayer(contentsOf:url);player?.play()}catch{self.error=error.localizedDescription}}
    func delete(_ url:URL){stop();do{try FileManager.default.removeItem(at:url);reload()}catch{self.error=error.localizedDescription}}
    func reload(){files=((try? FileManager.default.contentsOfDirectory(at:directory,includingPropertiesForKeys:[.creationDateKey])) ?? []).filter{$0.pathExtension=="m4a"}.sorted{date($0)>date($1)}}
    func date(_ url:URL)->Date{(try? url.resourceValues(forKeys:[.creationDateKey]).creationDate) ?? .distantPast}
}
