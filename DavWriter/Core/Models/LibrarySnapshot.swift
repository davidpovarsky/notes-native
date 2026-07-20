import Foundation

struct LibrarySnapshot: Codable, Equatable, Sendable {
    static let currentSchemaVersion = 1

    var schemaVersion: Int
    var folders: [FolderRecord]
    var documents: [DocumentRecord]

    init(
        schemaVersion: Int = LibrarySnapshot.currentSchemaVersion,
        folders: [FolderRecord] = [],
        documents: [DocumentRecord] = []
    ) {
        self.schemaVersion = schemaVersion
        self.folders = folders
        self.documents = documents
    }
}
