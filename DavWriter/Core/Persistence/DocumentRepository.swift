import Foundation

actor DocumentRepository {
    private let snapshotURL: URL
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder

    init(snapshotURL: URL = FileLocations.librarySnapshotURL) {
        self.snapshotURL = snapshotURL
        self.encoder = JSONEncoder()
        self.decoder = JSONDecoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
    }

    func load() throws -> LibrarySnapshot {
        try FileLocations.prepareDirectories()
        guard FileManager.default.fileExists(atPath: snapshotURL.path) else {
            let seeded = SampleLibrarySeeder.makeSnapshot()
            try save(seeded)
            return seeded
        }

        let data = try Data(contentsOf: snapshotURL)
        let snapshot = try decoder.decode(LibrarySnapshot.self, from: data)
        guard snapshot.schemaVersion <= LibrarySnapshot.currentSchemaVersion else {
            throw RepositoryError.unsupportedSchema(snapshot.schemaVersion)
        }
        return snapshot
    }

    func save(_ snapshot: LibrarySnapshot) throws {
        try FileLocations.prepareDirectories()
        var normalized = snapshot
        normalized.schemaVersion = LibrarySnapshot.currentSchemaVersion
        let data = try encoder.encode(normalized)
        try data.write(to: snapshotURL, options: [.atomic])
    }

    func resetWithSampleData() throws -> LibrarySnapshot {
        let snapshot = SampleLibrarySeeder.makeSnapshot()
        try save(snapshot)
        return snapshot
    }
}
