import Foundation
import SwiftData

@MainActor final class ExamSession: ObservableObject {
    let mode: ExamMode
    let variant: String
    let questions: [ExamQuestion]
    let config: ExamConfig
    let formID: Int
    let speech=SpeechPlayer()
    @Published var snapshot: ExamSnapshot
    @Published var phase: ExamPhase = .ready
    @Published var status = ""
    @Published var error: String?
    @Published var answerConfirmed = false
    @Published var now = Date()
    private var runner: Task<Void,Never>?
    private var attempt: ExamAttempt?
    private var context: ModelContext?
    private var accelerated = false
    var current: ExamQuestion { questions[min(snapshot.index,questions.count-1)] }
    var secondsLeft: Int { max(0,Int(ceil((snapshot.deadline ?? now).timeIntervalSince(now)))) }
    var score: Int { questions.filter { snapshot.choices[$0.id] == $0.answer }.count }
    var missing: Int { questions.filter { snapshot.choices[$0.id] == nil }.count }
    var canMoveFreely: Bool { mode == .simulation && phase == .reading }
    init(form: ExamForm, mode: ExamMode, variant: String, config: ExamConfig, unit: Int? = nil, accelerated: Bool = false) {
        self.mode=mode;self.variant=variant;self.config=config;self.formID=form.id
        if mode == .placement { questions=form.questions.enumerated().filter { $0.offset%5<2 || [4,9,24,29].contains($0.offset) }.map(\.element) }
        else { questions=form.questions }
        snapshot=ExamSnapshot(formID: form.id,questionIDs: questions.map(\.id))
        #if DEBUG
        self.accelerated=accelerated
        #endif
    }
    func start(context: ModelContext) {
        guard phase == .ready else { return }
        self.context=context
        let new=ExamAttempt(mode: mode.rawValue,variant: variant); context.insert(new);attempt=new
        if mode != .simulation {
            phase = .listening; snapshot.phase=phase
            if mode == .placement { snapshot.deadline = Date().addingTimeInterval(15*60) }
            save(); return
        }
        runner=Task {
            phase = .personalData; status="Preparazione e dati personali"; await wait(config.personalDataSeconds)
            guard !Task.isCancelled else { return }
            phase = .listening
            for i in questions.indices where questions[i].listening {
                guard !Task.isCancelled else { return }
                snapshot.index=i; answerConfirmed=false; let q=questions[i]
                let start=Date();snapshot.deadline=nil;save()
                if i%5==0 {
                    status="Introduzione · \(q.title)"
                    if !accelerated {
                        await speech.speakAndWait("现在开始。",voiceIndex: 0)
                        if let example=q.example {
                            for _ in 0..<config.readings { await speech.speakAndWait(example.hanzi) }
                        }
                    }
                }
                for repetition in 1...config.readings {
                    guard !Task.isCancelled else { return }
                    status="Ascolto automatico · lettura \(repetition)/\(config.readings)"
                    if !accelerated { for (j,line) in q.audio.enumerated() { await speech.speakAndWait(line.hanzi,voiceIndex: j%2) } }
                    if speech.error != nil { interrupt(reason: speech.error!); return }
                    if repetition<config.readings { await pause(1) }
                }
                status="Scegli la risposta"
                let pauseSeconds=q.part==1 ? config.firstPauseSeconds : config.otherPauseSeconds
                let target=config.questionSlotSeconds[q.part-1]
                await wait(accelerated ? 1 : max(pauseSeconds,target-Int(Date().timeIntervalSince(start))))
            }
            guard !Task.isCancelled else { return }
            if variant == "Carta" { phase = .transfer;status="Riporta le risposte sul foglio";await wait(config.paperTransferSeconds) }
            guard !Task.isCancelled else { return }
            snapshot.index=questions.firstIndex { !$0.listening } ?? 20
            phase = .reading;status="Lettura · puoi muoverti tra le domande"; await wait(config.readingSeconds)
            guard !Task.isCancelled else { return };finish()
        }
    }
    private func pause(_ seconds: Int) async { try? await Task.sleep(nanoseconds: UInt64(accelerated ? 1 : max(1,seconds))*1_000_000_000) }
    private func wait(_ seconds: Int) async {
        let duration=accelerated ? (phase == .reading ? 60 : 1) : seconds
        let end=Date().addingTimeInterval(Double(duration));snapshot.deadline=end;save()
        while Date()<end && !Task.isCancelled { now = .now;try? await Task.sleep(nanoseconds: 200_000_000) }
        now = .now
    }
    func tick() {
        now = .now
        if mode == .placement, let deadline=snapshot.deadline,now>=deadline,phase != .finished { finish() }
    }
    func choose(_ option: String) {
        guard phase == .listening || phase == .reading || phase == .transfer else { return }
        guard option != current.exampleAnswer else { return }
        guard !answerConfirmed || mode == .simulation else { return }
        snapshot.choices[current.id]=option
        if mode == .training { answerConfirmed=true }
        save()
    }
    func next() {
        guard mode != .simulation else { return }
        speech.stop()
        if snapshot.index+1>=questions.count { finish();return }
        snapshot.index+=1;phase=current.listening ? .listening : .reading;answerConfirmed=false;save()
    }
    func go(to index: Int) {
        guard questions.indices.contains(index) else { return }
        if canMoveFreely && !questions[index].listening { snapshot.index=index;save() }
        else if phase == .transfer && questions[index].listening { snapshot.index=index;save() }
    }
    func bookmark() { if snapshot.bookmarks.contains(current.id) { snapshot.bookmarks.remove(current.id) } else { snapshot.bookmarks.insert(current.id) };save() }
    func finish() {
        guard phase != .finished, phase != .interrupted else { return }
        runner?.cancel();speech.stop();phase = .finished;snapshot.phase=phase;snapshot.deadline=nil
        attempt?.score=score;attempt?.completed = .now
        if mode == .placement { UserDefaults.standard.set(true,forKey:"placementDone") }
        save()
        guard let context else { return }
        // Le parole presenti nei quesiti sbagliati entrano nel ripasso come nuove carte,
        // senza inferire che ogni parola sia stata dimenticata.
        let ids=Set(questions.filter { snapshot.choices[$0.id] != $0.answer }.flatMap(\.wordIDs))
        do {
            let existing=Set(try context.fetch(FetchDescriptor<StudyCard>()).map(\.key))
            for id in ids { let key="meaning:\(id)";if !existing.contains(key) { context.insert(StudyCard(key:key,contentID:String(id),kind:"meaning")) } }
            try context.save()
        } catch { self.error="Risultato salvato; alcune carte non sono state aggiunte: \(error.localizedDescription)" }
    }
    func interrupt(reason: String) {
        guard phase != .ready && phase != .finished && phase != .interrupted else { return }
        runner?.cancel();speech.stop();attempt?.valid=false;phase = .interrupted;status=reason;save()
    }
    func stop() { runner?.cancel();speech.stop() }
    private func save() {
        snapshot.phase=phase
        do { attempt?.answers=try JSONEncoder().encode(snapshot);try context?.save() }
        catch { self.error="Salvataggio non riuscito: \(error.localizedDescription)";attempt?.valid=false }
    }
}
