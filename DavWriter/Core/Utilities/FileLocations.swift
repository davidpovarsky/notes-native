import Foundation

enum FileLocations {
    static var applicationSupportDirectory: URL {
        FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("DavWriter", isDirectory: true)
    }

    static var librarySnapshotURL: URL {
        applicationSupportDirectory.appendingPathComponent("library.json")
    }

    static var toolPacksDirectory: URL {
        applicationSupportDirectory.appendingPathComponent("ToolPacks", isDirectory: true)
    }

    static func prepareDirectories() throws {
        try FileManager.default.createDirectory(
            at: applicationSupportDirectory,
            withIntermediateDirectories: true
        )
        try FileManager.default.createDirectory(
            at: toolPacksDirectory,
            withIntermediateDirectories: true
        )
    }
}
