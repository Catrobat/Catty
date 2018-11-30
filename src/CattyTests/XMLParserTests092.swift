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

class XMLParserTests092: XMLAbstractTest {

    func testConvertUnsupportedBrickToNoteBrick() {
        let program = getProgramForXML(xmlFile: "LegoNxtMotorActionBrick")
        XCTAssertNotNil(program, "Program should not be nil")

        for spriteObject in program.objectList {
            XCTAssertNotNil(spriteObject, "SpriteObject should not be nil")
            for script in (spriteObject as! SpriteObject).scriptList {
                for brick in (script as! Script).brickList {
                    XCTAssertNotNil(brick, "Brick should not be nil")
                }
            }
        }

        XCTAssertEqual(6, program.objectList.count, "Invalid number of SpriteObjects")
        let spriteObject = program.objectList.object(at: 1) as! SpriteObject
        XCTAssertEqual(1, spriteObject.scriptList.count, "Invalid number of Scripts")
        let script = spriteObject.scriptList.object(at: 0) as! Script
        XCTAssertEqual(1, script.brickList.count, "Invalid number of Bricks")
        let brick = script.brickList.object(at: 0) as! Brick
        XCTAssertTrue(brick.isKind(of: NoteBrick.self), "Invalid Brick type: Brick should be of type NoteBrick")
    }
}
