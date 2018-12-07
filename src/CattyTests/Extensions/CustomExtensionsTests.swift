/**
 *  Copyright (C) 2010-2018 The Catrobat Team
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

final class CustomExtensionsTests: XCTestCase {

    func testEscapingHTMLEntities() {
        var testString = "entities: &amp; , &quot; , &#x27; , &#x39; , &#x92; , &#x96; , &gt; and &lt; "

        var range = NSRange(location: 0, length: testString.count)

        let compareString = "entities: & , \" , ' , ' , ' , ' , > and < "

        let stringsToReplace = ["&amp;", "&quot;", "&#x27;", "&#x39;", "&#x92;", "&#x96;", "&gt;", "&lt;"]

        let stringsReplaceBy = ["&", "\"", "'", "'", "'", "'", ">", "<"]

        for i in 0..<stringsReplaceBy.count {
            if let subRange = Range<String.Index>(range, in: testString) {
                testString = testString.replacingOccurrences(of: stringsToReplace[i],
                                                             with: stringsReplaceBy[i],
                                                             options: .literal,
                                                             range: subRange)

            }
            range = NSRange(location: 0, length: testString.count)
        }

        var check = false
        if testString == compareString {
        } else {
            check = true
        }

        XCTAssertFalse(check, "stringByEscapingHTMLEntities is not correctly replaced")
    }
}
