import Foundation

enum ToolPackLoader {
    static func loadBundledPack(named name: String, bundle: Bundle = .main) throws -> ToolPack {
        let url = bundle.url(forResource: name, withExtension: "json", subdirectory: "ToolPacks")
            ?? bundle.url(forResource: name, withExtension: "json")
        guard let url else { throw CocoaError(.fileNoSuchFile) }
        return try load(from: url)
    }

    static func load(from url: URL) throws -> ToolPack {
        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode(ToolPack.self, from: data)
    }
}
