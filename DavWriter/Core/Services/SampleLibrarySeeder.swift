import Foundation
import UIKit

enum SampleLibrarySeeder {
    static func makeSnapshot() -> LibrarySnapshot {
        let folder = FolderRecord(name: "לימוד", sortOrder: 0)

        let paragraph = NSMutableParagraphStyle()
        paragraph.baseWritingDirection = .rightToLeft
        paragraph.alignment = .right
        paragraph.lineSpacing = 5

        let content = NSMutableAttributedString(
            string: "ברוכים הבאים ל־Dav Writer\n\n",
            attributes: [
                .font: UIFont.boldSystemFont(ofSize: 28),
                .paragraphStyle: paragraph,
                .foregroundColor: UIColor.label
            ]
        )
        content.append(NSAttributedString(
            string: "זהו עורך מסמכים נייטיבי לאייפד, שנבנה במיוחד לעבודה בעברית. אפשר ליצור תיקיות, לעצב טקסט, להוסיף תמונות ולהפעיל כלים מן החלונית הצדדית.",
            attributes: [
                .font: UIFont.systemFont(ofSize: AppConstants.defaultFontSize),
                .paragraphStyle: paragraph,
                .foregroundColor: UIColor.label
            ]
        ))

        let document = DocumentRecord(
            folderID: folder.id,
            title: "מסמך ראשון",
            attributedContentData: EditorArchive.data(for: content),
            plainText: content.string
        )

        return LibrarySnapshot(folders: [folder], documents: [document])
    }
}
