import SwiftUI

struct DocumentInspectorView: View {
    @Environment(\.dismiss) private var dismiss
    let title: String
    let plainText: String

    var body: some View {
        NavigationStack {
            Form {
                Section("מסמך") {
                    LabeledContent("כותרת", value: title)
                    LabeledContent("מילים", value: "\(wordCount)")
                    LabeledContent("תווים", value: "\(plainText.count)")
                    LabeledContent("פסקאות", value: "\(paragraphCount)")
                }
            }
            .navigationTitle("פרטי מסמך")
            .toolbar {
                Button("סגירה") { dismiss() }
            }
        }
    }

    private var wordCount: Int {
        plainText.split { $0.isWhitespace || $0.isNewline }.count
    }

    private var paragraphCount: Int {
        max(plainText.components(separatedBy: "\n").filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }.count, plainText.isEmpty ? 0 : 1)
    }
}
