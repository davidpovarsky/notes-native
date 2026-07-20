import Foundation
import SwiftUI

@MainActor
final class DocumentToolRegistry: ObservableObject {
    @Published private(set) var tools: [AnyDocumentTool] = []

    init(bundle: Bundle = .main) {
        var initial: [AnyDocumentTool] = [
            AnyDocumentTool(FindSourceTool()),
            AnyDocumentTool(InsertCitationTool())
        ]
        if let pack = try? ToolPackLoader.loadBundledPack(named: "default-tools", bundle: bundle) {
            initial.append(contentsOf: pack.tools.map { AnyDocumentTool(DeclarativeDocumentTool($0)) })
        }
        tools = initial
    }
}
