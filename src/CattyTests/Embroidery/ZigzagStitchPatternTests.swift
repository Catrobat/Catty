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

final class ZigzagStitchPatternTests: XCTestCase {
    var embroideryStream: EmbroideryStream?

    override func setUp() {
        super.setUp()
        embroideryStream = EmbroideryStream()
    }

    func testSquare() {
        let length = CGFloat(20)
        let width = CGFloat(30)
        let halfWidth = width / 2
        let firstPoint = CGPoint(x: 0, y: 80)
        let secondPoint = CGPoint(x: 80, y: 80)
        let thirdPoint = CGPoint(x: 80, y: 0)
        let fourthPoint = CGPoint(x: 0, y: 0)
        let reference = EmbroideryStream()

        reference.add(Stitch(x: firstPoint.x - halfWidth, y: length * 0))
        reference.add(Stitch(x: firstPoint.x + halfWidth, y: length * 1))
        reference.add(Stitch(x: firstPoint.x - halfWidth, y: length * 2))
        reference.add(Stitch(x: firstPoint.x + halfWidth, y: length * 3))
        reference.add(Stitch(x: firstPoint.x - halfWidth, y: length * 4))

        reference.add(Stitch(x: length * 1, y: secondPoint.y - halfWidth))
        reference.add(Stitch(x: length * 2, y: secondPoint.y + halfWidth))
        reference.add(Stitch(x: length * 3, y: secondPoint.y - halfWidth))
        reference.add(Stitch(x: length * 4, y: secondPoint.y + halfWidth))

        reference.add(Stitch(x: thirdPoint.x - width / 2, y: length * 3))
        reference.add(Stitch(x: thirdPoint.x + width / 2, y: length * 2))
        reference.add(Stitch(x: thirdPoint.x - width / 2, y: length * 1))
        reference.add(Stitch(x: thirdPoint.x + width / 2, y: length * 0))

        reference.add(Stitch(x: length * 3, y: fourthPoint.y + halfWidth))
        reference.add(Stitch(x: length * 2, y: fourthPoint.y - halfWidth))
        reference.add(Stitch(x: length * 1, y: fourthPoint.y + halfWidth))
        reference.add(Stitch(x: length * 0, y: fourthPoint.y - halfWidth))

        embroideryStream!.activePattern = ZigzagStitchPattern(for: embroideryStream!,
                                                              at: .zero,
                                                              withLength: length,
                                                              andWidth: width)
        embroideryStream!.activePattern!.spriteDidMove(to: firstPoint, rotation: 0)
        embroideryStream!.activePattern!.spriteDidMove(to: secondPoint, rotation: 90)
        embroideryStream!.activePattern!.spriteDidMove(to: thirdPoint, rotation: 180)
        embroideryStream!.activePattern!.spriteDidMove(to: fourthPoint, rotation: 270)

        XCTAssertEqual(embroideryStream!.count, reference.count)
        for i in 0..<reference.count {
            XCTAssertEqual(reference[i].getPosition().x, embroideryStream![i].getPosition().x, accuracy: 0.01)
            XCTAssertEqual(reference[i].getPosition().y, embroideryStream![i].getPosition().y, accuracy: 0.01)
        }
    }
}
