import Foundation

struct FindSourceTool: DocumentTool {
    let id = "builtin.find-source"
    let title = "מצא מקור"
    let systemImage = "books.vertical"
    let requiresSelection = true

    func run(context: DocumentToolContext) async throws -> DocumentToolOutput {
        guard let match = SampleTorahCorpus.bestMatch(for: context.selectedText) else {
            return .showResult(title: "לא נמצא מקור", body: "לא נמצאה התאמה במאגר ההדגמה המקומי.")
        }
        return .showResult(title: match.reference, body: match.text)
    }
}
