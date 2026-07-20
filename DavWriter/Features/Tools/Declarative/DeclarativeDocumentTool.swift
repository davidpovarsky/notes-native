import Foundation
import UIKit

struct DeclarativeDocumentTool: DocumentTool {
    let definition: DeclarativeToolDefinition

    init(_ definition: DeclarativeToolDefinition) {
        self.definition = definition
    }

    var id: String { "declarative.\(definition.id)" }
    var title: String { definition.title }
    var systemImage: String { definition.systemImage }
    var requiresSelection: Bool { definition.requiresSelection }

    func run(context: DocumentToolContext) async throws -> DocumentToolOutput {
        let output: String
        switch definition.action {
        case .uppercase:
            output = context.selectedText.uppercased()
        case .lowercase:
            output = context.selectedText.lowercased()
        case .wrapSelection:
            output = (definition.prefix ?? "") + context.selectedText + (definition.suffix ?? "")
        case .insertTemplate:
            output = (definition.template ?? "")
                .replacingOccurrences(of: "{{title}}", with: context.documentTitle)
                .replacingOccurrences(of: "{{selection}}", with: context.selectedText)
        case .replaceLiteral:
            output = context.selectedText.replacingOccurrences(
                of: definition.search ?? "",
                with: definition.replacement ?? ""
            )
        }

        let paragraph = NSMutableParagraphStyle()
        paragraph.baseWritingDirection = .rightToLeft
        paragraph.alignment = .right
        let attributed = NSAttributedString(
            string: output,
            attributes: [
                .font: UIFont.systemFont(ofSize: AppConstants.defaultFontSize),
                .paragraphStyle: paragraph,
                .foregroundColor: UIColor.label
            ]
        )
        return definition.action == .insertTemplate ? .insertAtCaret(attributed) : .replaceSelection(attributed)
    }
}
