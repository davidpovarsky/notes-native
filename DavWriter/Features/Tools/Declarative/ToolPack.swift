import Foundation

struct ToolPack: Codable, Sendable {
    let id: String
    let name: String
    let version: Int
    let tools: [DeclarativeToolDefinition]
}

enum DeclarativeAction: String, Codable, Sendable {
    case uppercase
    case lowercase
    case wrapSelection
    case insertTemplate
    case replaceLiteral
}

struct DeclarativeToolDefinition: Codable, Sendable {
    let id: String
    let title: String
    let systemImage: String
    let action: DeclarativeAction
    let prefix: String?
    let suffix: String?
    let template: String?
    let search: String?
    let replacement: String?

    var requiresSelection: Bool {
        switch action {
        case .insertTemplate: return false
        default: return true
        }
    }
}
