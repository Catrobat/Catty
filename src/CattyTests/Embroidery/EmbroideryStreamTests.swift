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

    private let width: CGFloat = 100
    private let height: CGFloat = 200
    private var deviceDiagonalPixel: CGFloat = 0
    private var defaultSize: CGFloat = 0.0

    override func setUp() {
        let deviceScreenRect = UIScreen.main.nativeBounds
        self.deviceDiagonalPixel = CGFloat(sqrt(pow(deviceScreenRect.width, 2) + pow(deviceScreenRect.height, 2)))
        self.defaultSize = SpriteKitDefines.defaultCatrobatStitchingSize * EmbroideryDefines.sizeConversionFactor
    }

    func testAddSimpleStitches() {
        let input = [
            Stitch(atPosition: CGPoint(x: 1, y: 1)),
            Stitch(atPosition: CGPoint(x: 2, y: 2)),
            Stitch(atPosition: CGPoint(x: 3, y: 3))
        ]

        let stream = EmbroideryStream(projectWidth: width, projectHeight: height)

        for stitch in input {
            stream.add(stitch)
        }

        XCTAssertEqual(stream.count, input.count)

        for i in 0..<input.count {
            let stitch = stream[i]

            XCTAssertEqual(stitch.embroideryDimensions().x, input[i].embroideryDimensions().x)
            XCTAssertEqual(stitch.embroideryDimensions().y, input[i].embroideryDimensions().y)
            XCTAssertFalse(stitch.isJump)
            XCTAssertFalse(stitch.isDrawn)
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

        let stream = EmbroideryStream(projectWidth: width, projectHeight: height)
        for stitch in input {
            stream.add(stitch)
        }

        XCTAssertEqual(stream.count, output.count)
        for i in 0..<stream.count {
            XCTAssertEqual(stream[i].embroideryDimensions().x,
                           output[i].embroideryDimensions().x)
            XCTAssertEqual(stream[i].embroideryDimensions().y,
                           output[i].embroideryDimensions().y)
        }

        let interpolatedStitches = stream.filter { $0.isInterpolated }
        XCTAssertFalse(interpolatedStitches.isEmpty)
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

        let stream = EmbroideryStream(projectWidth: width, projectHeight: height)
        for stitch in input {
            stream.add(stitch)
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

        let stream = EmbroideryStream(projectWidth: width, projectHeight: height)
        stream.add(Stitch(atPosition: CGPoint(x: 0, y: 0)))
        stream.add(Stitch(atPosition: CGPoint(x: 10, y: 0)))
        stream.addColorChange()
        stream.add(Stitch(atPosition: CGPoint(x: 0, y: 0)))
        stream.add(Stitch(atPosition: CGPoint(x: 10, y: 0)))

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

        let stream = EmbroideryStream(projectWidth: width, projectHeight: height)
        stream.add(Stitch(atPosition: CGPoint(x: 0, y: 0)))
        stream.add(Stitch(atPosition: CGPoint(x: 250, y: 0)))
        stream.addColorChange()
        stream.add(Stitch(atPosition: CGPoint(x: 0, y: 0)))
        stream.add(Stitch(atPosition: CGPoint(x: 250, y: 0)))

        XCTAssertEqual(stream.count, output.count)
        for i in 0..<stream.count {
            XCTAssertEqual(stream[i].embroideryDimensions().x,
                           output[i].embroideryDimensions().x)
            XCTAssertEqual(stream[i].embroideryDimensions().y,
                           output[i].embroideryDimensions().y)
        }
    }

    func testDrawEmbroideryQueue() {
        let stream = EmbroideryStream(projectWidth: width, projectHeight: height)
        let stitch = Stitch(atPosition: CGPoint(x: 0, y: 0))

        XCTAssertEqual(0, stream.drawEmbroideryQueue.count)

        stream.add(stitch)

        XCTAssertEqual(1, stream.drawEmbroideryQueue.count)
        XCTAssertEqual(stitch.getPosition(), stream.drawEmbroideryQueue.first!.getPosition())
    }

    func testEmbroideryStreameInitParametersNil() {
        let embroideryStream = EmbroideryStream(projectWidth: nil, projectHeight: nil)
        XCTAssertEqual(embroideryStream.size, self.defaultSize, accuracy: 0.01)
    }

    func testEmbroideryStreameInitParametersNot() {
        let embroideryStream = EmbroideryStream(projectWidth: width, projectHeight: height)
        let defaultCreatorDiagonalPixel = CGFloat(sqrt(pow(width, 2) + pow(height, 2)))
        let creatorDiagonalPixel = deviceDiagonalPixel * embroideryStream.size / self.defaultSize
        XCTAssertEqual(creatorDiagonalPixel, defaultCreatorDiagonalPixel, accuracy: 0.01)
    }

    func testInitWithStreams() {
        let stream = EmbroideryStream(projectWidth: width, projectHeight: height)
        stream.add(Stitch(atPosition: CGPoint(x: 0, y: 0)))
        stream.add(Stitch(atPosition: CGPoint(x: 10, y: 0)))
        stream.add(Stitch(atPosition: CGPoint(x: 0, y: 0)))
        stream.add(Stitch(atPosition: CGPoint(x: 10, y: 0)))

        let streamTwo = EmbroideryStream(projectWidth: width, projectHeight: height)
        streamTwo.add(Stitch(atPosition: CGPoint(x: 0, y: 0)))
        streamTwo.add(Stitch(atPosition: CGPoint(x: 5, y: 0)))
        streamTwo.add(Stitch(atPosition: CGPoint(x: 0, y: 0)))
        streamTwo.add(Stitch(atPosition: CGPoint(x: 5, y: 0)))

        let streamArray = [stream, streamTwo]
        let mergedStream = EmbroideryStream(streams: streamArray)
        XCTAssertEqual(mergedStream.stitches.count, 8)
        XCTAssertEqual(mergedStream.size, stream.size)
        XCTAssertFalse(mergedStream.stitches[0]!.isColorChange)
        XCTAssertFalse(mergedStream.stitches[1]!.isColorChange)
        XCTAssertFalse(mergedStream.stitches[2]!.isColorChange)
        XCTAssertFalse(mergedStream.stitches[3]!.isColorChange)
        XCTAssertTrue(mergedStream.stitches[4]!.isColorChange)
        XCTAssertFalse(mergedStream.stitches[5]!.isColorChange)
        XCTAssertFalse(mergedStream.stitches[6]!.isColorChange)
        XCTAssertFalse(mergedStream.stitches[7]!.isColorChange)
    }

    func testGenerateInitWithEmptyStreamsArray() {
        let empty: [EmbroideryStream] = []
        let stream = EmbroideryStream(streams: empty, withName: "Empty")
        XCTAssertEqual(0, stream.count)
    }
}
