import UniformTypeIdentifiers

extension UTType {
    static let davWordDocument = UTType(filenameExtension: "docx") ?? .data
}
