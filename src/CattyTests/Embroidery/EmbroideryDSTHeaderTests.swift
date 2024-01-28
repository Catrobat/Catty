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

class EmbroideryDSTHeaderTests: XCTestCase {

    func testBoundingBox() {
        let startPoint = CGPoint(x: 0, y: 0)
        let stitches = [
            Stitch(atPosition: startPoint),
            Stitch(x: 10, y: 10),
            Stitch(x: 5, y: 5),
            Stitch(x: -10, y: -10),
            Stitch(atPosition: startPoint)
        ]
        let header = EmbroideryDSTHeader(withName: "stitch")

        var previous = stitches[0]
        for current in stitches {
            let delta = CGVector(dx: previous.embroideryDimensions().x - current.embroideryDimensions().x,
                                 dy: previous.embroideryDimensions().y - current.embroideryDimensions().y)
            header.update(
                relativeX: Float(current.x - startPoint.x),
                relativeY: Float(current.y - startPoint.y),
                delta: delta
            )
            previous = current
        }

        XCTAssertEqual(header.maxX, 20)
        XCTAssertEqual(header.maxY, 20)
        XCTAssertEqual(header.minX, -20)
        XCTAssertEqual(header.minY, -20)
        XCTAssertEqual(header.mx, 0)
        XCTAssertEqual(header.my, 0)
    }

    func testFirstLastDelta() {
        let startPoint = CGPoint(x: 0, y: 0)
        let stitches = [
            Stitch(atPosition: startPoint),
            Stitch(x: 10, y: -10),
            Stitch(x: 5, y: 5)
        ]
        let header = EmbroideryDSTHeader(withName: "stitch")

        var previous = stitches[0]
        for current in stitches {
            let delta = CGVector(dx: previous.embroideryDimensions().x - current.embroideryDimensions().x,
                                 dy: previous.embroideryDimensions().y - current.embroideryDimensions().y)
            header.update(
                relativeX: Float(current.x - startPoint.x),
                relativeY: Float(current.y - startPoint.y),
                delta: delta
            )
            previous = current
        }
        XCTAssertEqual(header.delta, CGVector(dx: -10, dy: -10))
    }
}
