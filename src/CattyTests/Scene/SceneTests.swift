/**
 *  Copyright (C) 2010-2018 The Catrobat Team
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

class SceneTests: XCTestCase {
    var screenSize = CGSize.zero
    private var pocketCodeCenter = CGPoint.zero
    private var pocketCodeBottomLeft = CGPoint.zero
    private var pocketCodeBottomRight = CGPoint.zero
    private var pocketCodeTopLeft = CGPoint.zero
    private var pocketCodeTopRight = CGPoint.zero
    private var sceneCenter = CGPoint.zero
    private var sceneBottomLeft = CGPoint.zero
    private var sceneBottomRight = CGPoint.zero
    private var sceneTopLeft = CGPoint.zero
    private var sceneTopRight = CGPoint.zero

    override func setUp() {
        super.setUp()
        screenSize = Util.screenSize(false)

        pocketCodeCenter = CGPoint(x: 0, y: 0)
        pocketCodeBottomLeft = CGPoint(x: -240, y: -400)
        pocketCodeBottomRight = CGPoint(x: 240, y: -400)
        pocketCodeTopLeft = CGPoint(x: -240, y: 400)
        pocketCodeTopRight = CGPoint(x: 240, y: 400)

        sceneCenter = CGPoint(x: 240, y: 400)
        sceneBottomLeft = CGPoint(x: 0, y: 0)
        sceneBottomRight = CGPoint(x: 480, y: 0)
        sceneTopLeft = CGPoint(x: 0, y: 800)
        sceneTopRight = CGPoint(x: 480, y: 800)
    }

    override class func tearDown() {
        super.tearDown()
    }

    // MARK: Touch to Pocked Code

    func testTouchConversionCenter() {
        let scaledScene: CBScene? = (SceneBuilder(program: ProgramMock(width: screenSize.width * 2, andHeight: screenSize.height * 2))).build()
        let scaledSceneCenter = CGPoint(x: screenSize.width / 2, y: screenSize.height / 2)
        let convertedCenter: CGPoint = CBSceneHelper.convertTouchCoordinateToPoint(coordinate: scaledSceneCenter, sceneSize: (scaledScene?.size)!)

        XCTAssertTrue(convertedCenter.equalTo(pocketCodeCenter), "The Scene Center is not correctly calculated")
    }

    func testTouchConversionCenterNoScale() {
        let scaledScene: CBScene? = SceneBuilder(program: ProgramMock(width: screenSize.width, andHeight: screenSize.height)).build()
        let scaledSceneCenter = CGPoint(x: screenSize.width / 2, y: screenSize.height / 2)
        let convertedCenter: CGPoint = CBSceneHelper.convertTouchCoordinateToPoint(coordinate: scaledSceneCenter, sceneSize: (scaledScene?.size)!)

        XCTAssertTrue(convertedCenter.equalTo(pocketCodeCenter), "The Scene Center is not correctly calculated")
    }

    func testTouchConversionBottomLeft() {
        let scaledScene: CBScene? = (SceneBuilder(program: ProgramMock(width: screenSize.width * 2, andHeight: screenSize.height * 2))).build()
        let scaledSceneBottomLeft = CGPoint(x: 0, y: screenSize.height)
        let pocketCodeBottomLeft = CGPoint(x: (scaledScene?.size.width)! / 2 * -1, y: (scaledScene?.size.height)! / 2 * -1)
        let convertedBottomLeft: CGPoint = CBSceneHelper.convertTouchCoordinateToPoint(coordinate: scaledSceneBottomLeft, sceneSize: (scaledScene?.size)!)
        XCTAssertEqual(convertedBottomLeft, pocketCodeBottomLeft, "The Bottom Left is not correctly calculated")
    }

    func testTouchConversionBottomRight() {
        let scaledScene: CBScene? = (SceneBuilder(program: ProgramMock(width: screenSize.width * 2, andHeight: screenSize.height * 2))).build()
        let scaledSceneBottomRight = CGPoint(x: screenSize.width, y: screenSize.height)
        let pocketCodeBottomRight = CGPoint(x: (scaledScene?.size.width)! / 2, y: (scaledScene?.size.height)! / 2 * -1)
        let convertedBottomRight: CGPoint = CBSceneHelper.convertTouchCoordinateToPoint(coordinate: scaledSceneBottomRight, sceneSize: (scaledScene?.size)!)
        XCTAssertEqual(convertedBottomRight, pocketCodeBottomRight, "The Bottom Right is not correctly calculated")
    }

    func testTouchConversionTopLeft() {
        let scaledScene: CBScene? = (SceneBuilder(program: ProgramMock(width: screenSize.width * 2, andHeight: screenSize.height * 2))).build()
        let scaledSceneTopLeft = CGPoint(x: 0, y: 0)
        let pocketCodeTopLeft = CGPoint(x: (scaledScene?.size.width)! / 2 * -1, y: (scaledScene?.size.height)! / 2)
        let convertedTopLeft: CGPoint = CBSceneHelper.convertTouchCoordinateToPoint(coordinate: scaledSceneTopLeft, sceneSize: (scaledScene?.size)!)
        XCTAssertEqual(convertedTopLeft, pocketCodeTopLeft, "The Top Left is not correctly calculated")
    }

    func testTouchConversionTopRight() {
        let scaledScene: CBScene? = (SceneBuilder(program: ProgramMock(width: screenSize.width * 2, andHeight: screenSize.height * 2))).build()
        let scaledSceneTopRight = CGPoint(x: screenSize.width, y: 0)
        let pocketCodeTopRight = CGPoint(x: (scaledScene?.size.width)! / 2, y: (scaledScene?.size.height)! / 2)
        let convertedTopRight: CGPoint = CBSceneHelper.convertTouchCoordinateToPoint(coordinate: scaledSceneTopRight, sceneSize: (scaledScene?.size)!)
        XCTAssertEqual(convertedTopRight, pocketCodeTopRight, "The Top Right is not correctly calculated")
    }
}
