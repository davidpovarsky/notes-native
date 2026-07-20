import Foundation
import UIKit

extension NSAttributedString {
    func secureArchiveData() throws -> Data {
        try NSKeyedArchiver.archivedData(withRootObject: self, requiringSecureCoding: true)
    }

    static func fromSecureArchive(_ data: Data) throws -> NSAttributedString {
        let allowed: [AnyClass] = [
            NSAttributedString.self,
            NSMutableAttributedString.self,
            NSString.self,
            NSNumber.self,
            NSDictionary.self,
            NSArray.self,
            NSData.self,
            NSURL.self,
            UIFont.self,
            UIColor.self,
            NSParagraphStyle.self,
            NSMutableParagraphStyle.self,
            NSTextAttachment.self,
            UIImage.self,
            NSFileWrapper.self
        ]
        guard let value = try NSKeyedUnarchiver.unarchivedObject(ofClasses: allowed, from: data) as? NSAttributedString else {
            throw RepositoryError.invalidSnapshot
        }
        return value
    }
}
