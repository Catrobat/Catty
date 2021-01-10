/**
 *  Copyright (C) 2010-2020 The Catrobat Team
 *  (http://developer.catrobat.org/credits)
 *
 *  This program is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU Affero General Public License as
 *  published by the Free Software Foundation, either version 3 of the
 *  License, or (at your option) any later version.
 *
 *  An additional term exception under section 7 of the GNU Affero
 *  General Public License, version 3, is available at
 *  (http://developer.catrobat.org/license_additional_term)
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 *  GNU Affero General Public License for more details.
 *
 *  You should have received a copy of the GNU Affero General Public License
 *  along with this program.  If not, see http://www.gnu.org/licenses/.
 */

@objc extension NSString {

    func sha1() -> String {
        let string = self.utf8String
        var digest = [UInt8](repeating: 0, count: Int(CC_SHA1_DIGEST_LENGTH))
        CC_SHA1(string, CC_LONG(self.length), &digest)
        var digestHex = ""
        for index in 0..<Int(CC_SHA1_DIGEST_LENGTH) {
            digestHex += String(format: "%02x", digest[index])
        }
        return digestHex
    }

    func stringByEscapingHTMLEntities() -> String {
        var string = self

        let stringsToReplace = ["&amp;", "&quot;", "&#x27;", "&#x39;", "&#x92;", "&#x96;", "&gt;", "&lt;"]

        let stringReplacements = ["&", "\"", "'", "'", "'", "'", ">", "<"]

        for (fromString, toString) in zip(stringsToReplace, stringReplacements) {
            string = string.replacingOccurrences(of: fromString, with: toString) as NSString
        }
        return string as String
    }

    func stringByEscapingForXMLValues() -> String {
        var string = self

        let stringsToReplace = ["&", "<", ">", "\"", "'"]

        let stringReplacements = ["&amp;", "&lt;", "&gt;", "&quot;", "&apos;"]

        for (fromString, toString) in zip(stringsToReplace, stringReplacements) {
            string = string.replacingOccurrences(of: fromString, with: toString) as NSString
        }
        return string as String
    }

    func firstCharacterUppercaseString() -> String {
        if self.length > 0 {
            var string = self.substring(to: 1).uppercased()
            string.append(self.substring(from: 1))
            return string
        } else {
            return ""
        }
    }

    func stringBetweenString(_ start: String, andString end: String, withOptions mask: NSString.CompareOptions) -> String? {

        let startRange = self.range(of: start, options: mask)

        if startRange.location != NSNotFound {
            var targetRange = NSRange()
            targetRange.location = startRange.location + startRange.length
            targetRange.length = self.length - targetRange.location

            let endRange = self.range(of: end, options: mask, range: targetRange)

            if endRange.location != NSNotFound {
                targetRange.length = endRange.location - targetRange.location
                return self.substring(with: targetRange)
            }

        }

        return nil

    }

    func isValidNumber() -> Bool {
        let decimalRegEx = "^(?:|-)(?:|0|[1-9]\\d*)(?:\\.\\d*)?$"
        let predicate = NSPredicate(format: "SELF MATCHES %@", decimalRegEx)

        if predicate.evaluate(with: self) {
            return true
        }

        return false
    }

    static func uuid() -> String {
        let uuid = CFUUIDCreate(kCFAllocatorDefault)
        let uuidString = String(CFUUIDCreateString(kCFAllocatorDefault, uuid))
        return uuidString
    }

}
