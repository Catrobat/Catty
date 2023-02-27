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

final class TouchesFingerSensorTest: XCTestCase {

    var spriteObjectA: SpriteObject!
    var spriteObjectB: SpriteObject!
    var spriteNodeA: CBSpriteNode!
    var spriteNodeB: CBSpriteNode!
    var sensor: TouchesFingerSensor!
    var touchManager: TouchManagerMock!
    var scene: Scene!
    var lookA: Look!
    var stage: Stage!

    override func setUp() {
        stage = StageBuilder(project: ProjectMock(width: 400, andHeight: 800)).build()
        stage.scheduler.running = true

        let look = Look(name: "Look", filePath: "Look")

        let scene = Scene(name: "testScene")
        spriteObjectA = SpriteObject()
        spriteObjectA.scene = scene
        spriteObjectA.name = "SpriteObjectA"
        spriteObjectA.add(look, andSaveToDisk: false)
        spriteNodeA = CBSpriteNode(spriteObject: spriteObjectA)
        spriteNodeA.currentUIImageLook = MockImage(size: CGSize(width: 100, height: 100))

        spriteObjectB = SpriteObject()
        spriteObjectB.scene = scene
        spriteObjectB.name = "SpriteObjectB"
        spriteObjectB.add(look, andSaveToDisk: false)
        spriteNodeB = CBSpriteNode(spriteObject: spriteObjectB)
        spriteNodeB.currentUIImageLook = MockImage(size: CGSize(width: 100, height: 100))

        touchManager = TouchManagerMock()
        touchManager.isScreenTouched = true

        sensor = TouchesFingerSensor(touchManagerGetter: { self.touchManager })
    }

    override func tearDown() {
        spriteObjectA = nil
        spriteObjectB = nil
        touchManager = nil
        super.tearDown()
    }

    func testDefaultRawValue() {
        let sensor = TouchesFingerSensor { nil }
        XCTAssertEqual(TouchesFingerSensor.defaultRawValue, sensor.rawValue(for: spriteObjectA), accuracy: Double.epsilon)
    }

    func testRawValueNotTouched() {
        spriteNodeA.size = CGSize(width: 10, height: 10)
        spriteNodeA.position = CGPoint(x: 10, y: 10)
        stage.addChild(spriteNodeA)

        touchManager.isScreenTouched = false
        touchManager.lastTouchMock = MockTouch(point: CGPoint(x: 10, y: 10))

        XCTAssertEqual(0, self.sensor.rawValue(for: spriteObjectA))
    }

    func testRawValue() {
        let distanceToBorder = 0.00001

        spriteNodeA.size = CGSize(width: 10, height: 10)
        spriteNodeA.position = CGPoint(x: 10, y: 10)
        stage.addChild(spriteNodeA)

        //exactly touch
        touchManager.lastTouchMock = MockTouch(point: CGPoint(x: 10, y: 10))
        XCTAssertEqual(1, sensor.rawValue(for: spriteObjectA))

        //lower limit x axis
        touchManager.lastTouchMock = MockTouch(point: CGPoint(x: 5 + distanceToBorder, y: 10))
        XCTAssertEqual(1, sensor.rawValue(for: spriteObjectA))

        //upper limit x axis
        touchManager.lastTouchMock = MockTouch(point: CGPoint(x: 15 - distanceToBorder, y: 10))
        XCTAssertEqual(1, sensor.rawValue(for: spriteObjectA))

        //lower limit y axis
        touchManager.lastTouchMock = MockTouch(point: CGPoint(x: 10, y: 5 + distanceToBorder))
        XCTAssertEqual(1, sensor.rawValue(for: spriteObjectA))

        //upper limit y axis
        touchManager.lastTouchMock = MockTouch(point: CGPoint(x: 10, y: 15 - distanceToBorder))
        XCTAssertEqual(1, sensor.rawValue(for: spriteObjectA))

        //upper limit both axis
        touchManager.lastTouchMock = MockTouch(point: CGPoint(x: 15 - distanceToBorder, y: 15 - distanceToBorder))
        XCTAssertEqual(1, sensor.rawValue(for: spriteObjectA))

        //lower limit both axis
        touchManager.lastTouchMock = MockTouch(point: CGPoint(x: 5 + distanceToBorder, y: 5 + distanceToBorder))
        XCTAssertEqual(1, sensor.rawValue(for: spriteObjectA))

        touchManager.lastTouchMock = MockTouch(point: CGPoint(x: 16, y: 10))
        XCTAssertEqual(0, sensor.rawValue(for: spriteObjectA))

        touchManager.lastTouchMock = MockTouch(point: CGPoint(x: 4, y: 10))
        XCTAssertEqual(0, sensor.rawValue(for: spriteObjectA))

        touchManager.lastTouchMock = MockTouch(point: CGPoint(x: 10, y: 16))
        XCTAssertEqual(0, sensor.rawValue(for: spriteObjectA))

        touchManager.lastTouchMock = MockTouch(point: CGPoint(x: 10, y: 4))
        XCTAssertEqual(0, sensor.rawValue(for: spriteObjectA))

    }

    func testWhenHidden() {
        spriteNodeA.isHidden = true
        spriteNodeA.size = CGSize(width: 10, height: 10)
        spriteNodeA.position = CGPoint(x: 10, y: 10)
        stage.addChild(spriteNodeA)

        //exactly touch
        touchManager.lastTouchMock = MockTouch(point: CGPoint(x: 10, y: 10))
        XCTAssertEqual(1, sensor.rawValue(for: spriteObjectA))
    }

    func testBehindObject() {
        spriteNodeA.size = CGSize(width: 10, height: 10)
        spriteNodeA.position = CGPoint(x: 10, y: 10)
        spriteNodeA.zPosition = 1
        stage.addChild(spriteNodeA)

        spriteNodeB.size = CGSize(width: 10, height: 10)
        spriteNodeB.position = CGPoint(x: 10, y: 10)
        spriteNodeB.zPosition = 2
        stage.addChild(spriteNodeB)

        touchManager.lastTouchMock = MockTouch(point: CGPoint(x: 10, y: 10))
        XCTAssertEqual(1, sensor.rawValue(for: spriteObjectA))
        XCTAssertEqual(1, sensor.rawValue(for: spriteObjectB))
    }

    func testConvertToStandarized() {
        XCTAssertEqual(1, sensor.convertToStandardized(rawValue: 1, for: spriteObjectA))
        XCTAssertEqual(0, sensor.convertToStandardized(rawValue: 0, for: spriteObjectA))
    }

    func testTag() {
        XCTAssertEqual("COLLIDES_WITH_FINGER", sensor.tag())
    }

    func testRequiredResources() {
        XCTAssertEqual(ResourceType.touchHandler, type(of: sensor).requiredResource)
    }

    func testFormulaEditorSections() {
        let sections = sensor.formulaEditorSections(for: SpriteObject())
        XCTAssertEqual(1, sections.count)
        XCTAssertEqual(.object(position: type(of: sensor).position, subsection: .motion), sections.first)
    }
}
