import Foundation
import UniformTypeIdentifiers
import UIKit

@MainActor
enum ImportService {
    static let supportedTypes: [UTType] = [
        .plainText,
        .rtf,
        .rtfd,
        .html,
        .davWordDocument
    ]

    static func loadDocument(from url: URL) throws -> (title: String, content: NSAttributedString) {
        let accessed = url.startAccessingSecurityScopedResource()
        defer {
            if accessed { url.stopAccessingSecurityScopedResource() }
        }

        let data = try Data(contentsOf: url)
        let ext = url.pathExtension.lowercased()
        let attributed: NSAttributedString

        if ext == "txt" || ext == "md" {
            let text = String(data: data, encoding: .utf8) ?? ""
            attributed = attributedString(for: text)
        } else {
            let type: NSAttributedString.DocumentType
            switch ext {
            case "rtf": type = .rtf
            case "rtfd": type = .rtfd
            case "html", "htm": type = .html
            case "docx": type = .officeOpenXML
            default: type = .plain
            }
            attributed = try NSAttributedString(
                data: data,
                options: [.documentType: type],
                documentAttributes: nil
            )
        }

        return (url.deletingPathExtension().lastPathComponent, attributed)
    }

    private static func attributedString(for text: String) -> NSAttributedString {
        let paragraph = NSMutableParagraphStyle()
        paragraph.baseWritingDirection = .rightToLeft
        paragraph.alignment = .right
        paragraph.lineSpacing = 4
        return NSAttributedString(
            string: text,
            attributes: [
                .font: UIFont.systemFont(ofSize: AppConstants.defaultFontSize),
                .paragraphStyle: paragraph,
                .foregroundColor: UIColor.label
            ]
        )
    }
}
