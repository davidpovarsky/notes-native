import Foundation

enum RepositoryError: LocalizedError {
    case unsupportedSchema(Int)
    case invalidSnapshot

    var errorDescription: String? {
        switch self {
        case .unsupportedSchema(let version):
            return "גרסת ספרייה לא נתמכת: \(version)"
        case .invalidSnapshot:
            return "קובץ הספרייה אינו תקין."
        }
    }
}
