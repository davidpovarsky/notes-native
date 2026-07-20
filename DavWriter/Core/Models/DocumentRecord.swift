import Foundation

struct DocumentRecord: Identifiable, Codable, Hashable, Sendable {
    var id: UUID
    var folderID: UUID?
    var title: String
    var attributedContentData: Data
    var plainText: String
    var createdAt: Date
    var updatedAt: Date
    var isFavorite: Bool

    init(
        id: UUID = UUID(),
        folderID: UUID? = nil,
        title: String,
        attributedContentData: Data,
        plainText: String = "",
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        isFavorite: Bool = false
    ) {
        self.id = id
        self.folderID = folderID
        self.title = title
        self.attributedContentData = attributedContentData
        self.plainText = plainText
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.isFavorite = isFavorite
    }
}
