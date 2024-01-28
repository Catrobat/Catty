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

import XCTest

@testable import Pocket_Code

final class StitchTests: XCTestCase {

    func testStitchEmbroderyCorridnatesfromInt() {
        let testPointsInt = [
            (0, 0, CGPoint(x: 0, y: 0)),
            (250, 0, CGPoint(x: 500, y: 0)),
            (250, -250, CGPoint(x: 500, y: -500))
        ]
        for point in testPointsInt {
            let stitch = Stitch(x: point.0, y: point.1)
            XCTAssertEqual(stitch.embroideryDimensions(), point.2)
        }
    }

    func testStitchEmbroderyCorridnatesfromDouble() {
        let testPointsDouble = [
            (0.1, 0.1, CGPoint(x: 0, y: 0)),
            (1.2, 0, CGPoint(x: 2, y: 0)),
            (0, -2.9, CGPoint(x: 0, y: -6))
        ]
        for point in testPointsDouble {
            let stitch = Stitch(x: point.0, y: point.1)
            XCTAssertEqual(stitch.embroideryDimensions(), point.2)
        }
    }

    func testStitchEmbroderyCorridnatesfromCGPoint() {
        let testPointsCGPoint = [
            (CGPoint(x: 100, y: 0), CGPoint(x: 200, y: 0))
        ]
        for point in testPointsCGPoint {
            let stitch = Stitch(atPosition: point.0)
            XCTAssertEqual(stitch.embroideryDimensions(), point.1)
        }
    }

    func testMaxDistanceInEmbroideryDimensions() {
        let first = Stitch(atPosition: CGPoint(x: 0, y: 0))
        let second = Stitch(atPosition: CGPoint(x: 250, y: 0))

        XCTAssertEqual(first.maxDistanceInEmbroideryDimensions(stitch: second), 500)
    }

    func testGetPosition() {
        let first = Stitch(atPosition: CGPoint(x: -100, y: -100))
        let second = Stitch(atPosition: CGPoint(x: 200, y: 200))

        XCTAssertEqual(first.getPosition(), CGPoint(x: -100, y: -100))
        XCTAssertEqual(second.getPosition(), CGPoint(x: 200, y: 200))
    }
}
