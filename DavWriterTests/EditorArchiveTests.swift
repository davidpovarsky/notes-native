import XCTest
import UIKit
@testable import DavWriter

final class EditorArchiveTests: XCTestCase {
    func testAttributedStringArchiveRoundTrip() throws {
        let source = NSAttributedString(
            string: "שלום עולם",
            attributes: [.font: UIFont.boldSystemFont(ofSize: 20)]
        )
        let data = try source.secureArchiveData()
        let restored = try NSAttributedString.fromSecureArchive(data)
        XCTAssertEqual(restored.string, source.string)
        XCTAssertEqual(restored.length, source.length)
    }
}
