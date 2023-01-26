/**
 *  Copyright (C) 2010-2023 The Catrobat Team
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

class TouchManagerTests: XCTestCase {

    var touchManager: TouchManager!
    var stage: Stage!

    override func setUp() {
        stage = StageBuilder(project: ProjectMock(width: 500, andHeight: 500)).build()
        touchManager = TouchManager()
        touchManager.startTrackingTouches(for: stage)
    }

    override func tearDown() {
        touchManager = nil
        stage = nil
        super.tearDown()
    }

    func testScreenTouched() {
        let touchA = MockTouch(point: CGPoint.zero)
        let touchB = MockTouch(point: CGPoint.zero)

        XCTAssertFalse(touchManager.screenTouched())

        touchManager.handle(touch: touchA, for: .began)
        XCTAssertTrue(touchManager.screenTouched())

        touchManager.handle(touch: touchB, for: .began)
        XCTAssertTrue(touchManager.screenTouched())

        touchManager.handle(touch: touchA, for: .ended)
        XCTAssertTrue(touchManager.screenTouched())

        touchManager.handle(touch: touchB, for: .cancelled)
        XCTAssertFalse(touchManager.screenTouched())
    }

    func testScreenTouchedForTouchNumber() {
        let touchA = MockTouch(point: CGPoint.zero)
        let touchB = MockTouch(point: CGPoint.zero)

        XCTAssertFalse(touchManager.screenTouched(for: -1))
        XCTAssertFalse(touchManager.screenTouched(for: 0))
        XCTAssertFalse(touchManager.screenTouched(for: 1))

        touchManager.handle(touch: touchA, for: .began)
        XCTAssertTrue(touchManager.screenTouched(for: 1))
        XCTAssertFalse(touchManager.screenTouched(for: 0))
        XCTAssertFalse(touchManager.screenTouched(for: 2))

        touchManager.handle(touch: touchB, for: .began)
        XCTAssertTrue(touchManager.screenTouched(for: 1))
        XCTAssertTrue(touchManager.screenTouched(for: 2))
        XCTAssertFalse(touchManager.screenTouched(for: 0))
        XCTAssertFalse(touchManager.screenTouched(for: 3))

        touchManager.handle(touch: touchA, for: .ended)
        XCTAssertFalse(touchManager.screenTouched(for: 1))
        XCTAssertTrue(touchManager.screenTouched(for: 2))

        touchManager.handle(touch: touchB, for: .cancelled)
        XCTAssertFalse(touchManager.screenTouched(for: 1))
        XCTAssertFalse(touchManager.screenTouched(for: 2))
    }

    func testLastPosition() {
        let touchA = MockTouch(point: CGPoint(x: 10, y: 20))
        let touchB = MockTouch(point: CGPoint(x: 20, y: 30))

        XCTAssertNil(touchManager.lastPositionInScene())

        touchManager.handle(touch: touchA, for: .began)
        XCTAssertEqual(touchA.point, touchManager.lastPositionInScene())

        touchManager.handle(touch: touchB, for: .ended)
        XCTAssertEqual(touchA.point, touchManager.lastPositionInScene())

        touchManager.handle(touch: touchB, for: .began)
        XCTAssertEqual(touchB.point, touchManager.lastPositionInScene())
    }

    func testNumberOfTouches() {
        let touchA = MockTouch(point: CGPoint.zero)
        let touchB = MockTouch(point: CGPoint.zero)

        XCTAssertEqual(0, touchManager.numberOfTouches())

        touchManager.handle(touch: touchA, for: .began)
        XCTAssertEqual(1, touchManager.numberOfTouches())

        touchManager.handle(touch: touchA, for: .changed)
        XCTAssertEqual(1, touchManager.numberOfTouches())

        touchManager.handle(touch: touchB, for: .ended)
        XCTAssertEqual(1, touchManager.numberOfTouches())

        touchManager.handle(touch: touchB, for: .began)
        XCTAssertEqual(2, touchManager.numberOfTouches())
    }

    func testPositionInScene() {
        let touchA = MockTouch(point: CGPoint(x: 15, y: 25))
        let touchB = MockTouch(point: CGPoint(x: 35, y: 45))
        let newPositionA = CGPoint(x: 100, y: 200)

        XCTAssertNil(touchManager.getPositionInScene(for: 0))
        XCTAssertNil(touchManager.getPositionInScene(for: 1))
        XCTAssertNil(touchManager.getPositionInScene(for: -1))

        touchManager.handle(touch: touchA, for: .began)
        XCTAssertEqual(touchA.point, touchManager.getPositionInScene(for: 1))

        touchA.point = newPositionA

        touchManager.handle(touch: touchA, for: .changed)
        XCTAssertEqual(newPositionA, touchManager.getPositionInScene(for: 1))

        touchManager.handle(touch: touchB, for: .began)
        XCTAssertEqual(touchB.point, touchManager.getPositionInScene(for: 2))
        XCTAssertEqual(newPositionA, touchManager.getPositionInScene(for: 1))
    }

    func testReset() {
        let touch = MockTouch(point: CGPoint(x: 15, y: 25))

        touchManager.handle(touch: touch, for: .began)
        XCTAssertTrue(touchManager.screenTouched())
        XCTAssertEqual(1, touchManager.numberOfTouches())
        XCTAssertEqual(touch.point, touchManager.lastPositionInScene())

        touchManager.reset()

        XCTAssertFalse(touchManager.screenTouched())
        XCTAssertEqual(0, touchManager.numberOfTouches())
        XCTAssertNil(touchManager.lastPositionInScene())
    }
}
