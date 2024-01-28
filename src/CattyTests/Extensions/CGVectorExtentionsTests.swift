/**
 *  Copyright (C) 2010-2024 The Catrobat Team
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

import Foundation
import XCTest

@testable import Pocket_Code

final class CGVectorExtentionsTests: XCTestCase {
    let a = CGVector(dx: 2, dy: 0)
    let b = CGVector(dx: 0, dy: 3)
    let c = CGVector(dx: -2, dy: 0)
    let d = CGVector(dx: 0, dy: -3)

    let e = CGVector(dx: 2, dy: 3)
    let f = CGVector(dx: -2, dy: -3)

    func testAdd() {
        XCTAssertEqual(a + b, e)
        XCTAssertEqual(c + d, f)
    }

    func testAddAssigment() {
        var t = a
        t += b
        XCTAssertEqual(t, e)

        t += c
        XCTAssertEqual(t, b)
    }

    func testSub () {
        XCTAssertEqual(e - b, a)
        XCTAssertEqual(e - a, b)
    }

    func testSubAssigment() {
        var t = e
        t -= b
        XCTAssertEqual(t, a)

        t -= a
        XCTAssertEqual(t, CGVector.zero)
    }

    func testToCGPoint() {
        let p = CGPoint(x: 2, y: 2)
        let t = CGVector(fromPoint: p)

        XCTAssertEqual(t.toCGPoint(), p)
    }
}
