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

final class RunningStitchPatternTests: XCTestCase {
    var embroideryStream: EmbroideryStream?

    override func setUp() {
        super.setUp()
        embroideryStream = EmbroideryStream()
    }

    func testSimpleLine() {
        let reference = EmbroideryStream()
        reference.add(Stitch(x: 0, y: 0))
        reference.add(Stitch(x: 0, y: 20))
        reference.add(Stitch(x: 0, y: 40))
        reference.add(Stitch(x: 0, y: 60))
        reference.add(Stitch(x: 0, y: 80))

        embroideryStream!.activePattern = RunningStitchPattern(for: embroideryStream!,
                                                               at: .zero,
                                                               with: 20)
        embroideryStream!.activePattern!.spriteDidMove(to: CGPoint(x: 0, y: 80), rotation: 0)

        XCTAssertEqual(embroideryStream!.count, reference.count)
        for i in 0..<reference.count {
            XCTAssertEqual(reference[i].getPosition(), embroideryStream![i].getPosition())
        }
    }

    func testSquare() {
        let reference = EmbroideryStream()
        reference.add(Stitch(x: 0, y: 0))
        reference.add(Stitch(x: 0, y: 20))
        reference.add(Stitch(x: 0, y: 40))
        reference.add(Stitch(x: 0, y: 60))
        reference.add(Stitch(x: 0, y: 80))
        reference.add(Stitch(x: 20, y: 80))
        reference.add(Stitch(x: 40, y: 80))
        reference.add(Stitch(x: 60, y: 80))
        reference.add(Stitch(x: 80, y: 80))
        reference.add(Stitch(x: 60, y: 80))
        reference.add(Stitch(x: 40, y: 80))
        reference.add(Stitch(x: 20, y: 80))
        reference.add(Stitch(x: 0, y: 80))
        reference.add(Stitch(x: 0, y: 60))
        reference.add(Stitch(x: 0, y: 40))
        reference.add(Stitch(x: 0, y: 20))
        reference.add(Stitch(x: 0, y: 0))

        embroideryStream!.activePattern = RunningStitchPattern(for: embroideryStream!,
                                                               at: .zero,
                                                               with: 20)
        embroideryStream!.activePattern!.spriteDidMove(to: CGPoint(x: 0, y: 80), rotation: 0)
        embroideryStream!.activePattern!.spriteDidMove(to: CGPoint(x: 80, y: 80), rotation: 0)
        embroideryStream!.activePattern!.spriteDidMove(to: CGPoint(x: 0, y: 80), rotation: 0)
        embroideryStream!.activePattern!.spriteDidMove(to: CGPoint(x: 0, y: 0), rotation: 0)

        XCTAssertEqual(embroideryStream!.count, reference.count)
        for i in 0..<reference.count {
            XCTAssertEqual(reference[i].getPosition(), embroideryStream![i].getPosition())
        }
    }

    func testSquareNonDivisibleLength() {
        let reference = EmbroideryStream()
        reference.add(Stitch(x: 0, y: 0))
        reference.add(Stitch(x: 0, y: 10))
        reference.add(Stitch(x: 9, y: 14))
        reference.add(Stitch(x: 18, y: 19))
        reference.add(Stitch(x: 19, y: 9))
        reference.add(Stitch(x: 9, y: 4))
        reference.add(Stitch(x: 0, y: 0))

        embroideryStream!.activePattern = RunningStitchPattern(for: embroideryStream!,
                                                               at: .zero,
                                                               with: 10)
        embroideryStream!.activePattern!.spriteDidMove(to: CGPoint(x: 0, y: 19), rotation: 0)
        embroideryStream!.activePattern!.spriteDidMove(to: CGPoint(x: 19, y: 19), rotation: 0)
        embroideryStream!.activePattern!.spriteDidMove(to: CGPoint(x: 19, y: 0), rotation: 0)
        embroideryStream!.activePattern!.spriteDidMove(to: CGPoint(x: 0, y: 0), rotation: 0)

        XCTAssertEqual(embroideryStream!.count, reference.count)
        for i in 0..<reference.count {
            XCTAssertEqual(reference[i].getPosition(), embroideryStream![i].getPosition())
        }
    }
}
