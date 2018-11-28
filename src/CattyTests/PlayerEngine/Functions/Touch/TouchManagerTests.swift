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

class TouchedManagerTests: XCTestCase {

    var touchManager: TouchManager!
    var scene: CBScene!

    override func setUp() {
        scene = SceneBuilder(program: ProgramMock(width: 500, andHeight: 500)).build()
        touchManager = TouchManager()
        touchManager.startTrackingTouches(for: scene)
    }

    override func tearDown() {
        touchManager = nil
        scene = nil
        super.tearDown()
    }

    func testScreenTouched() {
        XCTAssertFalse(touchManager.screenTouched())

        touchManager.handleTouch(gestureRecognizer: UIGestureRecognizerMock(location: CGPoint.zero, state: .began))
        XCTAssertTrue(touchManager.screenTouched())

        touchManager.handleTouch(gestureRecognizer: UIGestureRecognizerMock(location: CGPoint.zero, state: .ended))
        XCTAssertFalse(touchManager.screenTouched())
    }

    func testLastPosition() {
        let positionA = CGPoint(x: 10, y: 20)
        let positionB = CGPoint(x: 20, y: 30)

        XCTAssertNil(touchManager.lastPositionInScene())

        touchManager.handleTouch(gestureRecognizer: UIGestureRecognizerMock(location: positionA, state: .began))
        XCTAssertEqual(positionA, touchManager.lastPositionInScene())

        touchManager.handleTouch(gestureRecognizer: UIGestureRecognizerMock(location: positionB, state: .began))
        XCTAssertEqual(positionB, touchManager.lastPositionInScene())
    }

    func testNumberOfTouches() {
        XCTAssertEqual(0, touchManager.numberOfTouches())

        touchManager.handleTouch(gestureRecognizer: UIGestureRecognizerMock(location: CGPoint.zero, state: .began))
        XCTAssertEqual(1, touchManager.numberOfTouches())

        touchManager.handleTouch(gestureRecognizer: UIGestureRecognizerMock(location: CGPoint.zero, state: .began))
        XCTAssertEqual(2, touchManager.numberOfTouches())
    }

    func testPositionInScene() {
        let positionA = CGPoint(x: 10, y: 20)
        let positionB = CGPoint(x: 20, y: 30)

        XCTAssertNil(touchManager.getPositionInScene(for: 0))
        XCTAssertNil(touchManager.getPositionInScene(for: 1))
        XCTAssertNil(touchManager.getPositionInScene(for: -1))

        touchManager.handleTouch(gestureRecognizer: UIGestureRecognizerMock(location: positionA, state: .began))
        XCTAssertEqual(positionA, touchManager.getPositionInScene(for: 1))

        touchManager.handleTouch(gestureRecognizer: UIGestureRecognizerMock(location: positionB, state: .began))
        XCTAssertEqual(positionA, touchManager.getPositionInScene(for: 1))
        XCTAssertEqual(positionB, touchManager.getPositionInScene(for: 2))
    }

    func testReset() {
        let position = CGPoint(x: 10, y: 20)

        touchManager.handleTouch(gestureRecognizer: UIGestureRecognizerMock(location: position, state: .began))
        XCTAssertTrue(touchManager.screenTouched())
        XCTAssertEqual(1, touchManager.numberOfTouches())
        XCTAssertEqual(position, touchManager.lastPositionInScene())

        touchManager.reset()

        XCTAssertFalse(touchManager.screenTouched())
        XCTAssertEqual(0, touchManager.numberOfTouches())
        XCTAssertNil(touchManager.lastPositionInScene())
    }
}
