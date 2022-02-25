/**
 *  Copyright (C) 2010-2022 The Catrobat Team
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

final class SewUpTests: XCTestCase {
    var testStream: EmbroideryStream?

    override func setUp() {
        super.setUp()
        testStream = EmbroideryStream()
    }

    func testSewUpOnlyRight() {
        let rightInRadians = CGFloat.zero
        let referenceStream = EmbroideryStream(fromArray: [
            Stitch(x: EmbroideryDefines.sewUpSteps, y: 0),
            Stitch(x: 0, y: 0),
            Stitch(x: -EmbroideryDefines.sewUpSteps, y: 0),
            Stitch(x: 0, y: 0)
        ])

        testStream!.sewUp(at: CGPoint(x: 0, y: 0), inDirectionInRadians: rightInRadians)

        for i in 0..<referenceStream.count {
            XCTAssertEqual(testStream![i].getPosition(), referenceStream[i].getPosition())
        }
    }

    func testSewUpOnlyUp() {
        let negSteps = -EmbroideryDefines.sewUpSteps
        XCTAssertEqual(negSteps, -3)
        let upInRadians = CGFloat.pi / 2
        let referenceStream = EmbroideryStream(fromArray: [
            Stitch(x: 0, y: EmbroideryDefines.sewUpSteps),
            Stitch(x: 0, y: 0),
            Stitch(x: 0, y: -EmbroideryDefines.sewUpSteps),
            Stitch(x: 0, y: 0)
        ])

        testStream!.sewUp(at: CGPoint(x: 0, y: 0), inDirectionInRadians: upInRadians)

        for i in 0..<referenceStream.count {
            XCTAssertEqual(testStream![i].embroideryDimensions(),
                           referenceStream[i].embroideryDimensions())
        }
    }

    func testSewUpOnlyLeft() {
        let leftInRadians = CGFloat.pi
        let referenceStream = EmbroideryStream(fromArray: [
            Stitch(x: -EmbroideryDefines.sewUpSteps, y: 0),
            Stitch(x: 0, y: 0),
            Stitch(x: EmbroideryDefines.sewUpSteps, y: 0),
            Stitch(x: 0, y: 0)
        ])

        testStream!.sewUp(at: CGPoint(x: 0, y: 0), inDirectionInRadians: leftInRadians)

        for i in 0..<referenceStream.count {
            XCTAssertEqual(testStream![i].embroideryDimensions(),
                           referenceStream[i].embroideryDimensions())
        }
    }

    func testSewUpOnlyDown() {
        let downInRadians = CGFloat.pi * (3 / 2)
        let referenceStream = EmbroideryStream(fromArray: [
            Stitch(x: 0, y: -EmbroideryDefines.sewUpSteps),
            Stitch(x: 0, y: 0),
            Stitch(x: 0, y: EmbroideryDefines.sewUpSteps),
            Stitch(x: 0, y: 0)
        ])

        testStream!.sewUp(at: CGPoint(x: 0, y: 0), inDirectionInRadians: downInRadians)

        for i in 0..<referenceStream.count {
            XCTAssertEqual(testStream![i].embroideryDimensions(),
                           referenceStream[i].embroideryDimensions())
        }
    }
}
