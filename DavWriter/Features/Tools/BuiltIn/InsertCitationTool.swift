import Foundation
import UIKit

struct InsertCitationTool: DocumentTool {
    let id = "builtin.insert-citation"
    let title = "הכנס ציטוט ומראה מקום"
    let systemImage = "quote.bubble"
    let requiresSelection = true

    func run(context: DocumentToolContext) async throws -> DocumentToolOutput {
        guard let match = SampleTorahCorpus.bestMatch(for: context.selectedText) else {
            return .showResult(title: "לא נמצא מקור", body: "בחר טקסט שמופיע במאגר המקורות.")
        }

        let paragraph = NSMutableParagraphStyle()
        paragraph.baseWritingDirection = .rightToLeft
        paragraph.alignment = .right
        paragraph.headIndent = 18
        paragraph.firstLineHeadIndent = 18

        let result = NSAttributedString(
            string: "״\(match.text)״ (\(match.reference))",
            attributes: [
                .font: UIFont.italicSystemFont(ofSize: AppConstants.defaultFontSize),
                .paragraphStyle: paragraph,
                .foregroundColor: UIColor.secondaryLabel
            ]
        )
        return .replaceSelection(result)
    }
}
