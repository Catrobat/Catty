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

final class LayerSensorTest: XCTestCase {

    var spriteObject: SpriteObject!
    var spriteNode: CBSpriteNodeMock!
    var sensor: LayerSensor!
    var scene: Scene!

    override func setUp() {
        super.setUp()
        scene = Scene(name: "testScene")
        spriteObject = SpriteObject()
        spriteObject.scene = scene
        spriteNode = CBSpriteNodeMock(spriteObject: spriteObject)
        sensor = LayerSensor()
    }

    override func tearDown() {
        spriteObject = nil
        super.tearDown()
    }

    func testDefaultRawValue() {
        let project = Project()
        scene.project = project
        project.scenes[0] = scene!

        let spriteObjectA = SpriteObjectMock()
        (project.scenes[0] as! Scene).add(object: spriteObjectA)

        let spriteObjectB = SpriteObjectMock()
        (project.scenes[0] as! Scene).add(object: spriteObjectB)

        let spriteObjectC = SpriteObjectMock()
        (project.scenes[0] as! Scene).add(object: spriteObjectC)

        XCTAssertEqual(type(of: sensor).defaultRawValue, type(of: sensor).defaultRawValue(for: spriteObjectA), accuracy: Double.epsilon)
        XCTAssertEqual(type(of: sensor).defaultRawValue, type(of: sensor).rawValue(for: spriteObjectA), accuracy: Double.epsilon)

        XCTAssertEqual(type(of: sensor).defaultRawValue + 1, type(of: sensor).defaultRawValue(for: spriteObjectB), accuracy: Double.epsilon)
        XCTAssertEqual(type(of: sensor).defaultRawValue + 1, type(of: sensor).rawValue(for: spriteObjectB), accuracy: Double.epsilon)

        XCTAssertEqual(type(of: sensor).defaultRawValue + 2, type(of: sensor).defaultRawValue(for: spriteObjectC), accuracy: Double.epsilon)
        XCTAssertEqual(type(of: sensor).defaultRawValue + 2, type(of: sensor).rawValue(for: spriteObjectC), accuracy: Double.epsilon)
    }

    func testRawValue() {
        // background like on Android
        spriteNode.zPosition = -1
        XCTAssertEqual(-1, type(of: sensor).rawValue(for: spriteObject), accuracy: Double.epsilon)

        // background raw on iOS
        spriteNode.zPosition = 0
        XCTAssertEqual(0, type(of: sensor).rawValue(for: spriteObject), accuracy: Double.epsilon)

        // third layer
        spriteNode.zPosition = 3
        XCTAssertEqual(3, type(of: sensor).rawValue(for: spriteObject), accuracy: Double.epsilon)
    }

    func testSetRawValue() {
        let expectedRawValue = type(of: sensor).convertToRaw(userInput: 2, for: spriteObject)
        type(of: sensor).setRawValue(userInput: 2, for: spriteObject)
        XCTAssertEqual(expectedRawValue, Double(spriteNode.zPosition), accuracy: Double.epsilon)
    }

    func testConvertToStandarized() {
        // background
        XCTAssertEqual(-1, type(of: sensor).convertToStandardized(rawValue: 0, for: spriteObject), accuracy: Double.epsilon)

        // objects
        XCTAssertEqual(1, type(of: sensor).convertToStandardized(rawValue: 1, for: spriteObject), accuracy: Double.epsilon)
        XCTAssertEqual(2, type(of: sensor).convertToStandardized(rawValue: 2, for: spriteObject), accuracy: Double.epsilon)
    }

    func testConvertToRaw() {
        // can not be set for background
        XCTAssertEqual(1, type(of: sensor).convertToRaw(userInput: -1, for: spriteObject), accuracy: Double.epsilon)
        XCTAssertEqual(1, type(of: sensor).convertToRaw(userInput: 0, for: spriteObject), accuracy: Double.epsilon)

        // objects
        XCTAssertEqual(3, type(of: sensor).convertToRaw(userInput: 3, for: spriteObject), accuracy: Double.epsilon)
        XCTAssertEqual(4, type(of: sensor).convertToRaw(userInput: 4, for: spriteObject), accuracy: Double.epsilon)
    }

    func testTag() {
        XCTAssertEqual("OBJECT_LAYER", sensor.tag())
    }

    func testRequiredResources() {
        XCTAssertEqual(ResourceType.noResources, type(of: sensor).requiredResource)
    }

    func testFormulaEditorSections() {
        let sections = sensor.formulaEditorSections(for: SpriteObject())
        XCTAssertEqual(1, sections.count)
        XCTAssertEqual(.object(position: type(of: sensor).position, subsection: .motion), sections.first)
    }
}
