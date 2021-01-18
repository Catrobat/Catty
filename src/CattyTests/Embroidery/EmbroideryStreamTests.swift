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

final class EmbroideryStreamTests: XCTestCase {

    func testAddSimpleStitches() {
        let input = [
            Stitch(atPosition: CGPoint(x: 1, y: 1)),
            Stitch(atPosition: CGPoint(x: 2, y: 2)),
            Stitch(atPosition: CGPoint(x: 3, y: 3))
        ]

        let stream = EmbroideryStream()

        for stitch in input {
            stream.addStich(stitch: stitch)
        }

        XCTAssertEqual(stream.count, input.count)
        for i in 0..<input.count {
            XCTAssertEqual(stream[i].embroideryDimensions().x,
                           input[i].embroideryDimensions().x)
            XCTAssertEqual(stream[i].embroideryDimensions().y,
                           input[i].embroideryDimensions().y)
            XCTAssertFalse(stream[i].isJump)
        }
    }

    func testInterpolation() {
        let input = [
            Stitch(atPosition: CGPoint(x: 0, y: 0)),
            Stitch(atPosition: CGPoint(x: 250, y: 0))
        ]

        let output = [
            Stitch(atPosition: CGPoint(x: 0, y: 0), asJump: false),
            Stitch(atPosition: CGPoint(x: 0, y: 0), asJump: true),
            Stitch(atPosition: CGPoint(x: 50, y: 0), asJump: true),
            Stitch(atPosition: CGPoint(x: 100, y: 0), asJump: true),
            Stitch(atPosition: CGPoint(x: 150, y: 0), asJump: true),
            Stitch(atPosition: CGPoint(x: 200, y: 0), asJump: true),
            Stitch(atPosition: CGPoint(x: 250, y: 0), asJump: true),
            Stitch(atPosition: CGPoint(x: 250, y: 0), asJump: false)
        ]

        let stream = EmbroideryStream()
        for stitch in input {
            stream.addStich(stitch: stitch)
        }

        XCTAssertEqual(stream.count, output.count)
        for i in 0..<stream.count {
            XCTAssertEqual(stream[i].embroideryDimensions().x,
                           output[i].embroideryDimensions().x)
            XCTAssertEqual(stream[i].embroideryDimensions().y,
                           output[i].embroideryDimensions().y)
        }
    }

    func testInterpolationNegDirection() {
        let input = [
            Stitch(atPosition: CGPoint(x: 250, y: 0)),
            Stitch(atPosition: CGPoint(x: 0, y: 0))
        ]

        let output = [
            Stitch(atPosition: CGPoint(x: 250, y: 0), asJump: false),
            Stitch(atPosition: CGPoint(x: 250, y: 0), asJump: true),
            Stitch(atPosition: CGPoint(x: 200, y: 0), asJump: true),
            Stitch(atPosition: CGPoint(x: 150, y: 0), asJump: true),
            Stitch(atPosition: CGPoint(x: 100, y: 0), asJump: true),
            Stitch(atPosition: CGPoint(x: 50, y: 0), asJump: true),
            Stitch(atPosition: CGPoint(x: 0, y: 0), asJump: true),
            Stitch(atPosition: CGPoint(x: 0, y: 0), asJump: false)
        ]

        let stream = EmbroideryStream()
        for stitch in input {
            stream.addStich(stitch: stitch)
        }

        XCTAssertEqual(stream.count, output.count)
        for i in 0..<stream.count {
            XCTAssertEqual(stream[i].embroideryDimensions().x,
                           output[i].embroideryDimensions().x)
            XCTAssertEqual(stream[i].embroideryDimensions().y,
                           output[i].embroideryDimensions().y)
        }
    }

    func testColorChange() {
        let output = [
            Stitch(atPosition: CGPoint(x: 0, y: 0)),
            Stitch(atPosition: CGPoint(x: 10, y: 0)),
            Stitch(atPosition: CGPoint(x: 0, y: 0)),
            Stitch(atPosition: CGPoint(x: 10, y: 0))
        ]
        output[2].isColorChange = true

        let stream = EmbroideryStream()
        stream.addStich(stitch: Stitch(atPosition: CGPoint(x: 0, y: 0)))
        stream.addStich(stitch: Stitch(atPosition: CGPoint(x: 10, y: 0)))
        stream.addColorChange()
        stream.addStich(stitch: Stitch(atPosition: CGPoint(x: 0, y: 0)))
        stream.addStich(stitch: Stitch(atPosition: CGPoint(x: 10, y: 0)))

        XCTAssertEqual(stream.count, output.count)
        for i in 0..<stream.count {
            XCTAssertEqual(stream[i].embroideryDimensions().x,
                           output[i].embroideryDimensions().x)
            XCTAssertEqual(stream[i].embroideryDimensions().y,
                           output[i].embroideryDimensions().y)
        }
    }

    func testCombined() {
        let output = [
            Stitch(atPosition: CGPoint(x: 0, y: 0), asJump: false),
            Stitch(atPosition: CGPoint(x: 0, y: 0), asJump: true),
            Stitch(atPosition: CGPoint(x: 50, y: 0), asJump: true),
            Stitch(atPosition: CGPoint(x: 100, y: 0), asJump: true),
            Stitch(atPosition: CGPoint(x: 150, y: 0), asJump: true),
            Stitch(atPosition: CGPoint(x: 200, y: 0), asJump: true),
            Stitch(atPosition: CGPoint(x: 250, y: 0), asJump: true),
            Stitch(atPosition: CGPoint(x: 250, y: 0), asJump: false),
            Stitch(atPosition: CGPoint(x: 250, y: 0), asJump: true),
            Stitch(atPosition: CGPoint(x: 200, y: 0), asJump: true),
            Stitch(atPosition: CGPoint(x: 150, y: 0), asJump: true),
            Stitch(atPosition: CGPoint(x: 100, y: 0), asJump: true),
            Stitch(atPosition: CGPoint(x: 50, y: 0), asJump: true),
            Stitch(atPosition: CGPoint(x: 0, y: 0), asJump: true),
            Stitch(atPosition: CGPoint(x: 0, y: 0), asJump: false), // <- ColorChange
            Stitch(atPosition: CGPoint(x: 0, y: 0), asJump: true),
            Stitch(atPosition: CGPoint(x: 50, y: 0), asJump: true),
            Stitch(atPosition: CGPoint(x: 100, y: 0), asJump: true),
            Stitch(atPosition: CGPoint(x: 150, y: 0), asJump: true),
            Stitch(atPosition: CGPoint(x: 200, y: 0), asJump: true),
            Stitch(atPosition: CGPoint(x: 250, y: 0), asJump: true),
            Stitch(atPosition: CGPoint(x: 250, y: 0), asJump: false)
        ]
        output[14].isColorChange = true

        let stream = EmbroideryStream()
        stream.addStich(stitch: Stitch(atPosition: CGPoint(x: 0, y: 0)))
        stream.addStich(stitch: Stitch(atPosition: CGPoint(x: 250, y: 0)))
        stream.addColorChange()
        stream.addStich(stitch: Stitch(atPosition: CGPoint(x: 0, y: 0)))
        stream.addStich(stitch: Stitch(atPosition: CGPoint(x: 250, y: 0)))

        XCTAssertEqual(stream.count, output.count)
        for i in 0..<stream.count {
            XCTAssertEqual(stream[i].embroideryDimensions().x,
                           output[i].embroideryDimensions().x)
            XCTAssertEqual(stream[i].embroideryDimensions().y,
                           output[i].embroideryDimensions().y)
        }
    }
}
