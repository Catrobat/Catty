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

final class EmbroideryDSTServiceTests: XCTestCase {

    func testGenerateOutputInterpolation() {
        let bundlePath = Bundle(for: type(of: self)).path(forResource: "stitch", ofType: "dst")
        let reference = try? Data(contentsOf: URL(fileURLWithPath: bundlePath!))

        let DSTService = EmbroideryDSTService()
        let stream = EmbroideryStream(withName: "stitch")
        stream.addStich(stitch: Stitch(atPosition: CGPoint(x: 0, y: 0)))
        stream.addStich(stitch: Stitch(atPosition: CGPoint(x: 250, y: 0)))

        let out = DSTService.generateOutput(embroideryStream: stream)
        XCTAssertEqual(out, reference)
    }

    func testGenerateOutputColorChange() {
        let bundlePath = Bundle(for: type(of: self)).path(forResource: "color_change", ofType: "dst")
        let reference = try? Data(contentsOf: URL(fileURLWithPath: bundlePath!))

        let DSTService = EmbroideryDSTService()
        let stream = EmbroideryStream(withName: "EmbroideryStitc")

        stream.addStich(stitch: Stitch(atPosition: CGPoint(x: 0, y: 0)))
        stream.addStich(stitch: Stitch(atPosition: CGPoint(x: 250, y: 0)))
        stream.addColorChange()
        stream.addStich(stitch: Stitch(atPosition: CGPoint(x: 0, y: 0)))
        stream.addStich(stitch: Stitch(atPosition: CGPoint(x: 0, y: 250)))

        let out = DSTService.generateOutput(embroideryStream: stream)
        XCTAssertEqual(out, reference)
    }
}
