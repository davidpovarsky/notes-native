import Foundation
import UIKit

struct DocumentToolContext {
    let documentTitle: String
    let fullText: String
    let selectedText: String
    let selectionRange: NSRange
}

enum DocumentToolOutput {
    case replaceSelection(NSAttributedString)
    case insertAtCaret(NSAttributedString)
    case showResult(title: String, body: String)
    case none
}

@MainActor
protocol DocumentTool: Identifiable {
    var id: String { get }
    var title: String { get }
    var systemImage: String { get }
    var requiresSelection: Bool { get }

    func run(context: DocumentToolContext) async throws -> DocumentToolOutput
}

@MainActor
struct AnyDocumentTool: Identifiable {
    let id: String
    let title: String
    let systemImage: String
    let requiresSelection: Bool
    private let runner: (DocumentToolContext) async throws -> DocumentToolOutput

    init<T: DocumentTool>(_ tool: T) {
        id = tool.id
        title = tool.title
        systemImage = tool.systemImage
        requiresSelection = tool.requiresSelection
        runner = tool.run
    }

    func run(context: DocumentToolContext) async throws -> DocumentToolOutput {
        try await runner(context)
    }
}
