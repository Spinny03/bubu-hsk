import SwiftUI
import SwiftData

@main struct BubuApp: App {
    private let container: ModelContainer?
    private let curriculum: Curriculum?
    private let startupError: String?
    init() {
        do {
            let loaded = try Curriculum.load()
            let database = try ModelContainer(for: StudyCard.self, StudyEvent.self, ExamAttempt.self,
                configurations: ModelConfiguration(isStoredInMemoryOnly: ProcessInfo.processInfo.arguments.contains("--uitesting")))
            curriculum = loaded; container = database; startupError = nil
        } catch {
            curriculum = nil; container = nil; startupError = error.localizedDescription
        }
    }
    var body: some Scene {
        WindowGroup {
            if let container, let curriculum {
                RootView(content: curriculum).modelContainer(container)
                    .tint(Palette.red).preferredColorScheme(.light)
            } else {
                ContentUnavailableView("Impossibile aprire i dati", systemImage: "exclamationmark.triangle",
                    description: Text(startupError ?? "Riapri l’app. I tuoi dati non sono stati cancellati."))
            }
        }
    }
}
