import Combine
import Foundation
import UIKit

@MainActor
final class EditorViewModel: ObservableObject {
    @Published var title: String
    @Published var attributedText: NSAttributedString
    @Published var exportURL: URL?
    @Published var errorMessage: String?

    let documentID: UUID
    private let onSave: (String, NSAttributedString) -> Void
    private var pendingSaveTask: Task<Void, Never>?

    init(document: DocumentRecord, onSave: @escaping (String, NSAttributedString) -> Void) {
        self.documentID = document.id
        self.title = document.title
        self.attributedText = EditorArchive.attributedString(from: document.attributedContentData)
        self.onSave = onSave
    }

    deinit {
        pendingSaveTask?.cancel()
    }

    func contentChanged(_ content: NSAttributedString) {
        attributedText = content
        scheduleSave()
    }

    func titleChanged() {
        scheduleSave()
    }

    func flushSave() {
        pendingSaveTask?.cancel()
        onSave(title, attributedText)
    }

    func export(_ format: ExportService.Format) {
        do {
            exportURL = try ExportService.export(title: title, attributedText: attributedText, format: format)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func scheduleSave() {
        pendingSaveTask?.cancel()
        pendingSaveTask = Task { [weak self] in
            try? await Task.sleep(nanoseconds: AppConstants.autosaveDelayNanoseconds)
            guard !Task.isCancelled, let self else { return }
            self.onSave(self.title, self.attributedText)
        }
    }
}
