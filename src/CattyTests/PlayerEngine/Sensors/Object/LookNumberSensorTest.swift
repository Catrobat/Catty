/**
 *  Copyright (C) 2010-2019 The Catrobat Team
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

final class LookNumberSensorTest: XCTestCase {

    var spriteObject: SpriteObjectMock!
    var spriteNode: CBSpriteNodeMock!
    var sensor: LookNumberSensor!

    override func setUp() {
        super.setUp()
        spriteObject = SpriteObjectMock()
        spriteNode = CBSpriteNodeMock(spriteObject: spriteObject)
        sensor = LookNumberSensor()
    }

    override func tearDown() {
        spriteObject = nil
        super.tearDown()
    }

    func testDefaultRawValue() {
        spriteNode.currentLook = nil
        XCTAssertEqual(type(of: sensor).defaultRawValue, type(of: sensor).rawValue(for: spriteObject))

        spriteNode = nil
        XCTAssertEqual(type(of: sensor).defaultRawValue, type(of: sensor).rawValue(for: spriteObject))

    }

    func testRawValue() {
        spriteObject.lookList = [Look(name: "first", andPath: "test1.png")!,
                                 Look(name: "second", andPath: "test2.png")!,
                                 Look(name: "third", andPath: "test3.png")!]

        spriteNode.currentLook = (spriteObject.lookList[0] as! Look)
        XCTAssertEqual(0, type(of: sensor).rawValue(for: spriteObject))

        spriteNode.currentLook = (spriteObject.lookList[1] as! Look)
        XCTAssertEqual(1, type(of: sensor).rawValue(for: spriteObject))

        spriteNode.currentLook = (spriteObject.lookList[2] as! Look)
        XCTAssertEqual(2, type(of: sensor).rawValue(for: spriteObject))
    }

    func testConvertToStandardized() {
        XCTAssertEqual(1, type(of: sensor).convertToStandardized(rawValue: 0, for: spriteObject))
        XCTAssertEqual(2, type(of: sensor).convertToStandardized(rawValue: 1, for: spriteObject))
        XCTAssertEqual(3, type(of: sensor).convertToStandardized(rawValue: 2, for: spriteObject))
    }

    func testTag() {
        XCTAssertEqual("OBJECT_LOOK_NUMBER", sensor.tag())
    }

    func testRequiredResources() {
        XCTAssertEqual(ResourceType.noResources, type(of: sensor).requiredResource)
    }

    func testFormulaEditorSection() {
        spriteObject.background = true
        XCTAssertEqual(0, sensor.formulaEditorSections(for: spriteObject).count)

        spriteObject.background = false

        let sections = sensor.formulaEditorSections(for: spriteObject)
        XCTAssertEqual(1, sections.count)
        XCTAssertEqual(.object(position: type(of: sensor).position), sections.first)
    }
}
