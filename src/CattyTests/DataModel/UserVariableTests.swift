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

final class UserVariableTests: XCTestCase {

    override func setUp() {
        super.setUp()
    }

    func testSizeForSKLabel() {
        let userVariable = UserVariable()
        let defaultSize = CGFloat(42)

        XCTAssertEqual(defaultSize, userVariable.sizeForSKLabel(sceneSize: CGSize(width: 1080, height: 1920))) // iPhone 6/6s/7/8 Plus
        XCTAssertEqual(defaultSize / 1920 * 2436, userVariable.sizeForSKLabel(sceneSize: CGSize(width: 1125, height: 2436))) // iPhone X
        XCTAssertEqual(defaultSize / 1920 * 1334, userVariable.sizeForSKLabel(sceneSize: CGSize(width: 750, height: 1334))) // iPhone 6, 6s, 7, 8
        XCTAssertEqual(defaultSize / 1920 * 1136, userVariable.sizeForSKLabel(sceneSize: CGSize(width: 640, height: 1136))) // iPhone 5, 5s, 5c, SE
    }

    func testMutableCopyWithContext() {
        let userVariable = UserVariable()
        userVariable.name = "userVar"

        let userVariableCopy = userVariable.mutableCopy(with: CBMutableCopyContext()) as! UserVariable

        XCTAssertEqual(userVariable.name, userVariableCopy.name, "mutableCopyWithContext not working")
        XCTAssertTrue(userVariable === userVariableCopy, "mutableCopyWithContext not working")
    }
}
