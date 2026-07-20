import Foundation

enum LibraryScope: Hashable {
    case all
    case favorites
    case folder(UUID)
}
