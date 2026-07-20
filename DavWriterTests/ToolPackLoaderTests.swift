import XCTest
@testable import DavWriter

final class ToolPackLoaderTests: XCTestCase {
    func testDecodesToolPack() throws {
        let json = #"""
        {
          "id": "test",
          "name": "Test",
          "version": 1,
          "tools": [
            {
              "id": "wrap",
              "title": "Wrap",
              "systemImage": "parentheses",
              "action": "wrapSelection",
              "prefix": "(",
              "suffix": ")",
              "template": null,
              "search": null,
              "replacement": null
            }
          ]
        }
        """#
        let pack = try JSONDecoder().decode(ToolPack.self, from: Data(json.utf8))
        XCTAssertEqual(pack.tools.count, 1)
        XCTAssertEqual(pack.tools[0].action, .wrapSelection)
    }
}
