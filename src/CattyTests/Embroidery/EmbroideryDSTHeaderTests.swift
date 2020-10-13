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

import XCTest

@testable import Pocket_Code

class EmbroideryDSTHeaderTests: XCTestCase {

    func testBoundingBox() {
        let stitches = [
            Stitch(x: 0, y: 0),
            Stitch(x: 10, y: 10),
            Stitch(x: 5, y: 5),
            Stitch(x: -10, y: -10),
            Stitch(x: 0, y: 0)
        ]

        let header = EmbroideryDSTHeader(withName: "stitch")

        var previous = stitches[0]
        for current in stitches {
            header.update(
                relativeX: Int(previous.embroideryDimensions().x - current.embroideryDimensions().x),
                relativeY: Int(previous.embroideryDimensions().y - current.embroideryDimensions().y)
            )
            previous = current
        }

        XCTAssertEqual(header.boundingBox.maxX, 20)
        XCTAssertEqual(header.boundingBox.maxY, 20)
        XCTAssertEqual(header.boundingBox.minX, -20)
        XCTAssertEqual(header.boundingBox.minY, -20)
    }

    func testFirstLastDelta() {
        let stitches = [
            Stitch(x: 0, y: 0),
            Stitch(x: 10, y: -10),
            Stitch(x: 5, y: 5)
        ]

        let header = EmbroideryDSTHeader(withName: "stitch")

        var previous = stitches[0]
        for current in stitches {
            header.update(
                relativeX: Int(current.embroideryDimensions().x - previous.embroideryDimensions().x),
                relativeY: Int(current.embroideryDimensions().y - previous.embroideryDimensions().y)
            )
            previous = current
        }

        XCTAssertEqual(header.delta, CGVector(dx: 10, dy: 10))
    }
}
