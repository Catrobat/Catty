/**
 *  Copyright (C) 2010-2021 The Catrobat Team
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

final class RotationStyleTests: XCTestCase {

    override func setUp() {
        super.setUp()
    }

    func testEnumSize() {
        XCTAssertEqual(RotationStyle.allCases.count, 3, "Wrong Length!")
    }

    func testEnumStrings() {
        let strings = [kLocalizedLeftRight, kLocalizedAllAround, kLocalizedDoNotRotate]
        for choice in 0 ..< RotationStyle.allCases.count {
            if let style = RotationStyle.from(rawValue: choice) {
                XCTAssertEqual(strings[choice], style.localizedString())
            } else {
                XCTAssertTrue(false, "Invalid raw value!")
            }
        }
    }

    func testEnumValues() {
        let enums = [RotationStyle.leftRight, RotationStyle.allAround, RotationStyle.notRotate]
        for choice in 0 ..< RotationStyle.allCases.count {
            if let style = RotationStyle.from(rawValue: choice) {
                XCTAssertEqual(enums[choice], style)
            } else {
                XCTAssertTrue(false, "Invalid raw value!")
            }
        }
    }

    func testFromString() {
        let strings = [kLocalizedLeftRight, kLocalizedAllAround, kLocalizedDoNotRotate]
        let enums = [RotationStyle.leftRight, RotationStyle.allAround, RotationStyle.notRotate]
        for choice in 0 ..< RotationStyle.allCases.count {
            if let style = RotationStyle.from(localizedString: strings[choice]) {
                XCTAssertEqual(enums[choice], style)
            } else {
                XCTAssertTrue(false, "Invalid localized string!")
            }
        }
    }

    func testInvalidRawValue() {
        XCTAssertTrue(RotationStyle.from(rawValue: 666) == nil, "Invalid raw Value doesn't return nil!")
    }

    func testInvalidLocalizedString() {
        XCTAssertTrue(RotationStyle.from(localizedString: "invalid") == nil, "Invalid localized string doesn't return nil!")
    }
}
