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

final class EmbroideryDSTServiceTests: XCTestCase {

    private let width: CGFloat = 100
    private let height: CGFloat = 200

    func testGenerateOutputInterpolation() {
        let bundlePath = Bundle(for: type(of: self)).path(forResource: "stitch", ofType: "dst")
        let reference = try? Data(contentsOf: URL(fileURLWithPath: bundlePath!))

        let DSTService = EmbroideryDSTService()
        let stream = EmbroideryStream(projectWidth: width, projectHeight: height, withName: "stitch")
        stream.add(Stitch(atPosition: CGPoint(x: 0, y: 0)))
        stream.add(Stitch(atPosition: CGPoint(x: 250, y: 0)))

        let out = DSTService.generateOutput(embroideryStream: stream)
        XCTAssertEqual(out, reference)
    }

    func testGenerateOutputColorChange() {
        let bundlePath = Bundle(for: type(of: self)).path(forResource: "color_change", ofType: "dst")
        let reference = try? Data(contentsOf: URL(fileURLWithPath: bundlePath!))

        let DSTService = EmbroideryDSTService()
        let stream = EmbroideryStream(projectWidth: width, projectHeight: height, withName: "EmbroideryStitc")

        stream.add(Stitch(atPosition: CGPoint(x: 0, y: 0)))
        stream.add(Stitch(atPosition: CGPoint(x: 250, y: 0)))
        stream.addColorChange()
        stream.add(Stitch(atPosition: CGPoint(x: 0, y: 0)))
        stream.add(Stitch(atPosition: CGPoint(x: 0, y: 250)))

        let out = DSTService.generateOutput(embroideryStream: stream)
        XCTAssertEqual(out, reference)
    }

    func testGenerateInitWithStreams() {
        let bundlePath = Bundle(for: type(of: self)).path(forResource: "color_change", ofType: "dst")
        let reference = try? Data(contentsOf: URL(fileURLWithPath: bundlePath!))

        let DSTService = EmbroideryDSTService()

        let stream = EmbroideryStream(projectWidth: width, projectHeight: height)
        stream.add(Stitch(atPosition: CGPoint(x: 0, y: 0)))
        stream.add(Stitch(atPosition: CGPoint(x: 250, y: 0)))

        let streamTwo = EmbroideryStream(projectWidth: width, projectHeight: height)
        streamTwo.add(Stitch(atPosition: CGPoint(x: 0, y: 0)))
        streamTwo.add(Stitch(atPosition: CGPoint(x: 0, y: 250)))

        let streamArray = [stream, streamTwo]
        let mergedStream = EmbroideryStream(streams: streamArray, withName: "EmbroideryStitc")

        let out = DSTService.generateOutput(embroideryStream: mergedStream)
        XCTAssertEqual(out, reference)
    }
}
