/**
 *  Copyright (C) 2010-2023 The Catrobat Team
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

import XCTest

@testable import Pocket_Code

final class NSStringExtensionTests: XCTestCase {

    func testSHA1() {
        let testString1 = NSString(string: "")
        let correctOutput1 = "da39a3ee5e6b4b0d3255bfef95601890afd80709"

        let testString2 = NSString(string: "abc")
        let correctOutput2 = "a9993e364706816aba3e25717850c26c9cd0d89d"

        let testString3 = NSString(string: "abcdbcdecdefdefgefghfghighijhijkijkljklmklmnlmnomnopnopq")
        let correctOutput3 = "84983e441c3bd26ebaae4aa1f95129e5e54670f1"

        let testString4 = NSString(string: "abcdefghbcdefghicdefghijdefghijkefghijklfghijklmghijklmnhijklmnoijklmnopjklmnopqklmnopqrlmnopqrsmnopqrstnopqrstu")
        let correctOutput4 = "a49b2446a02c645bf419f995b67091253a04a259"

        let testString5 = NSString(string: "hello world")
        let correctOutput5 = "2aae6c35c94fcfb415dbe95f408b9ce91ee846ed"

        XCTAssertEqual(testString1.sha1(), correctOutput1)
        XCTAssertEqual(testString2.sha1(), correctOutput2)
        XCTAssertEqual(testString3.sha1(), correctOutput3)
        XCTAssertEqual(testString4.sha1(), correctOutput4)
        XCTAssertEqual(testString5.sha1(), correctOutput5)
    }

    func testStringByEscapingHTMLEntities() {

        let testString1 = NSString(string: "&amp;")
        let correctOutput1 = "&"

        let testString2 = NSString(string: "&quot;")
        let correctOutput2 = "\""

        let testString3 = NSString(string: "&#x27;")
        let correctOutput3 = "'"

        let testString4 = NSString(string: "&#x39;")
        let correctOutput4 = "'"

        let testString5 = NSString(string: "&#x92;")
        let correctOutput5 = "'"

        let testString6 = NSString(string: "&#x96;")
        let correctOutput6 = "'"

        let testString7 = NSString(string: "&gt;")
        let correctOutput7 = ">"

        let testString8 = NSString(string: "&lt;")
        let correctOutput8 = "<"

        let testString9 = NSString(string: "")
        let correctOutput9 = ""

        let testString10 = NSString(string: "abcxyz.abc/xy=&amp;qbc&quot;&#x27;&lt;")
        let correctOutput10 = "abcxyz.abc/xy=&qbc\"'<"

        XCTAssertEqual(testString1.stringByEscapingHTMLEntities(), correctOutput1)
        XCTAssertEqual(testString2.stringByEscapingHTMLEntities(), correctOutput2)
        XCTAssertEqual(testString3.stringByEscapingHTMLEntities(), correctOutput3)
        XCTAssertEqual(testString4.stringByEscapingHTMLEntities(), correctOutput4)
        XCTAssertEqual(testString5.stringByEscapingHTMLEntities(), correctOutput5)
        XCTAssertEqual(testString6.stringByEscapingHTMLEntities(), correctOutput6)
        XCTAssertEqual(testString7.stringByEscapingHTMLEntities(), correctOutput7)
        XCTAssertEqual(testString8.stringByEscapingHTMLEntities(), correctOutput8)
        XCTAssertEqual(testString9.stringByEscapingHTMLEntities(), correctOutput9)
        XCTAssertEqual(testString10.stringByEscapingHTMLEntities(), correctOutput10)

    }

    func testStringByEscapingForXMLValues() {

        let testString1 = NSString(string: "<")
        let correctOutput1 = "&lt;"

        let testString2 = NSString(string: ">")
        let correctOutput2 = "&gt;"

        let testString3 = NSString(string: "&")
        let correctOutput3 = "&amp;"

        let testString4 = NSString(string: "\"")
        let correctOutput4 = "&quot;"

        let testString5 = NSString(string: "'")
        let correctOutput5 = "&apos;"

        let testString6 = NSString(string: "<xyz&><'abc\"")
        let correctOutput6 = "&lt;xyz&amp;&gt;&lt;&apos;abc&quot;"

        XCTAssertEqual(testString1.stringByEscapingForXMLValues(), correctOutput1)
        XCTAssertEqual(testString2.stringByEscapingForXMLValues(), correctOutput2)
        XCTAssertEqual(testString3.stringByEscapingForXMLValues(), correctOutput3)
        XCTAssertEqual(testString4.stringByEscapingForXMLValues(), correctOutput4)
        XCTAssertEqual(testString5.stringByEscapingForXMLValues(), correctOutput5)
        XCTAssertEqual(testString6.stringByEscapingForXMLValues(), correctOutput6)

    }

    func testFirstCharacterUppercaseString() {
        let testString1 = NSString(string: "abc")
        let correctOutput1 = "Abc"

        let testString2 = NSString(string: "Abc")
        let correctOutput2 = "Abc"

        let testString3 = NSString(string: "")
        let correctOutput3 = ""

        let testString4 = NSString(string: "a")
        let correctOutput4 = "A"

        let testString5 = NSString(string: "1abc")
        let correctOutput5 = "1abc"

        let testString6 = NSString(string: "#abc")
        let correctOutput6 = "#abc"

        XCTAssertEqual(testString1.firstCharacterUppercaseString(), correctOutput1)
        XCTAssertEqual(testString2.firstCharacterUppercaseString(), correctOutput2)
        XCTAssertEqual(testString3.firstCharacterUppercaseString(), correctOutput3)
        XCTAssertEqual(testString4.firstCharacterUppercaseString(), correctOutput4)
        XCTAssertEqual(testString5.firstCharacterUppercaseString(), correctOutput5)
        XCTAssertEqual(testString6.firstCharacterUppercaseString(), correctOutput6)

    }

    func testStringBetweenStringAndString() {

        let testString1 = NSString(string: "abcdefg")
        let fromString1 = "ab"
        let toString1 = "ef"
        let correctOutput1 = "cd"

        let testString2 = NSString(string: "abcd")
        let fromString2 = "ab"
        let toString2 = "cd"
        let correctOutput2: String? = ""

        let testString3 = NSString(string: "a")
        let fromString3 = "a"
        let toString3 = "a"
        let correctOutput3: String? = nil

        let testString4 = NSString(string: "")
        let fromString4 = ""
        let toString4 = ""
        let correctOutput4: String? = nil

        let testString5 = NSString(string: "abcdefg")
        let fromString5 = "xy"
        let toString5 = "pq"
        let correctOutput5: String? = nil

        let testString6 = NSString(string: "abcdefg")
        let fromString6 = "ef"
        let toString6 = "ab"
        let correctOutput6: String? = nil

        let testString7 = NSString(string: "abcdefabxyef")
        let fromString7 = "ab"
        let toString7 = "ef"
        let correctOutput7 = "cd"

        let testString8 = NSString(string: "<abcxyzabc")
        let fromString8 = "abc"
        let toString8 = "abc"
        let correctOutput8 = "xyz"

        XCTAssertEqual(testString1.stringBetweenString(fromString1, andString: toString1, withOptions: .caseInsensitive), correctOutput1)
        XCTAssertEqual(testString2.stringBetweenString(fromString2, andString: toString2, withOptions: .caseInsensitive), correctOutput2)
        XCTAssertEqual(testString3.stringBetweenString(fromString3, andString: toString3, withOptions: .caseInsensitive), correctOutput3)
        XCTAssertEqual(testString4.stringBetweenString(fromString4, andString: toString4, withOptions: .caseInsensitive), correctOutput4)
        XCTAssertEqual(testString5.stringBetweenString(fromString5, andString: toString5, withOptions: .caseInsensitive), correctOutput5)
        XCTAssertEqual(testString6.stringBetweenString(fromString6, andString: toString6, withOptions: .caseInsensitive), correctOutput6)
        XCTAssertEqual(testString7.stringBetweenString(fromString7, andString: toString7, withOptions: .caseInsensitive), correctOutput7)
        XCTAssertEqual(testString8.stringBetweenString(fromString8, andString: toString8, withOptions: .caseInsensitive), correctOutput8)

    }

    func testIsValidNumber() {

        let testString1 = NSString(string: "1")
        let testString2 = NSString(string: "1.2")
        let testString3 = NSString(string: "11.22")
        let testString4 = NSString(string: "11.12.14")
        let testString5 = NSString(string: "1,2")
        let testString6 = NSString(string: "a")
        let testString7 = NSString(string: "1a")
        let testString8 = NSString(string: "1.a")

        XCTAssertTrue(testString1.isValidNumber())
        XCTAssertTrue(testString2.isValidNumber())
        XCTAssertTrue(testString3.isValidNumber())
        XCTAssertFalse(testString4.isValidNumber())
        XCTAssertFalse(testString5.isValidNumber())
        XCTAssertFalse(testString6.isValidNumber())
        XCTAssertFalse(testString7.isValidNumber())
        XCTAssertFalse(testString8.isValidNumber())

    }

    func testUUID() {
        let testString1 = NSString.uuid()
        let testString2 = NSString.uuid()
        let testString3 = NSString.uuid()

        XCTAssertNotEqual(testString1, testString2)
        XCTAssertNotEqual(testString2, testString3)
        XCTAssertNotEqual(testString1, testString3)
    }

}
