import Foundation

enum SearchService {
    static func filter(
        documents: [DocumentRecord],
        query: String,
        scope: LibraryScope
    ) -> [DocumentRecord] {
        let scoped: [DocumentRecord]
        switch scope {
        case .all:
            scoped = documents
        case .favorites:
            scoped = documents.filter(\.isFavorite)
        case .folder(let folderID):
            scoped = documents.filter { $0.folderID == folderID }
        }

        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            return scoped.sorted { $0.updatedAt > $1.updatedAt }
        }

        return scoped
            .filter {
                $0.title.localizedCaseInsensitiveContains(trimmed)
                    || $0.plainText.localizedCaseInsensitiveContains(trimmed)
            }
            .sorted { $0.updatedAt > $1.updatedAt }
    }
}
