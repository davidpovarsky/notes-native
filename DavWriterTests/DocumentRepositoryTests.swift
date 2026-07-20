import XCTest
@testable import DavWriter

final class DocumentRepositoryTests: XCTestCase {
    func testRoundTripSnapshot() async throws {
        let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString, isDirectory: true)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        let url = directory.appendingPathComponent("library.json")
        let repository = DocumentRepository(snapshotURL: url)
        let original = SampleLibrarySeeder.makeSnapshot()

        try await repository.save(original)
        let loaded = try await repository.load()

        XCTAssertEqual(original, loaded)
    }
}
