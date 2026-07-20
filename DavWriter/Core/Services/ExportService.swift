import CoreText
import Foundation
import UIKit

@MainActor
enum ExportService {
    enum Format: String, CaseIterable, Identifiable {
        case pdf
        case rtf
        case html
        case plainText

        var id: String { rawValue }

        var title: String {
            switch self {
            case .pdf: return "PDF"
            case .rtf: return "RTF"
            case .html: return "HTML"
            case .plainText: return "טקסט"
            }
        }

        var fileExtension: String {
            switch self {
            case .pdf: return "pdf"
            case .rtf: return "rtf"
            case .html: return "html"
            case .plainText: return "txt"
            }
        }
    }

    static func export(
        title: String,
        attributedText: NSAttributedString,
        format: Format
    ) throws -> URL {
        let safeTitle = sanitizedFileName(title.isEmpty ? "מסמך" : title)
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent(safeTitle)
            .appendingPathExtension(format.fileExtension)

        switch format {
        case .pdf:
            try pdfData(from: attributedText).write(to: url, options: .atomic)
        case .rtf:
            let data = try attributedText.data(
                from: NSRange(location: 0, length: attributedText.length),
                documentAttributes: [.documentType: NSAttributedString.DocumentType.rtf]
            )
            try data.write(to: url, options: .atomic)
        case .html:
            let data = try attributedText.data(
                from: NSRange(location: 0, length: attributedText.length),
                documentAttributes: [.documentType: NSAttributedString.DocumentType.html]
            )
            try data.write(to: url, options: .atomic)
        case .plainText:
            try attributedText.string.data(using: .utf8)?.write(to: url, options: .atomic)
        }
        return url
    }

    private static func pdfData(from attributedText: NSAttributedString) throws -> Data {
        let pageBounds = CGRect(x: 0, y: 0, width: 612, height: 792)
        let contentBounds = pageBounds.insetBy(dx: 54, dy: 54)
        let renderer = UIGraphicsPDFRenderer(bounds: pageBounds)

        return renderer.pdfData { context in
            let framesetter = CTFramesetterCreateWithAttributedString(attributedText as CFAttributedString)
            var currentLocation = 0

            repeat {
                context.beginPage()
                let path = CGPath(rect: contentBounds, transform: nil)
                let frame = CTFramesetterCreateFrame(
                    framesetter,
                    CFRange(location: currentLocation, length: 0),
                    path,
                    nil
                )

                let cg = context.cgContext
                cg.saveGState()
                cg.translateBy(x: 0, y: pageBounds.height)
                cg.scaleBy(x: 1, y: -1)
                CTFrameDraw(frame, cg)
                cg.restoreGState()

                let visible = CTFrameGetVisibleStringRange(frame)
                guard visible.length > 0 else { break }
                currentLocation += visible.length
            } while currentLocation < attributedText.length
        }
    }

    private static func sanitizedFileName(_ value: String) -> String {
        let invalid = CharacterSet(charactersIn: "/:\\?%*|\"<>")
        return value.components(separatedBy: invalid).joined(separator: "-")
    }
}
