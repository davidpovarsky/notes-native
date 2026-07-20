import Foundation
import UIKit

struct EditorArchive {
    static func emptyRTL(fontSize: CGFloat = AppConstants.defaultFontSize) -> NSAttributedString {
        let paragraph = NSMutableParagraphStyle()
        paragraph.baseWritingDirection = .rightToLeft
        paragraph.alignment = .right
        paragraph.lineSpacing = 4

        return NSAttributedString(
            string: "",
            attributes: [
                .font: UIFont.systemFont(ofSize: fontSize),
                .paragraphStyle: paragraph,
                .foregroundColor: UIColor.label
            ]
        )
    }

    static func data(for string: NSAttributedString) -> Data {
        (try? string.secureArchiveData()) ?? Data()
    }

    static func attributedString(from data: Data) -> NSAttributedString {
        guard !data.isEmpty else { return emptyRTL() }
        return (try? NSAttributedString.fromSecureArchive(data)) ?? emptyRTL()
    }
}
