/**
 *  Copyright (C) 2010-2024 The Catrobat Team
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

final class StartPlotBrickTest: XCTestCase {

    func testStartPlotBrick() {
        let object = SpriteObject()
        let scene = Scene(name: "testScene")
        object.scene = scene
        let spriteNode = CBSpriteNode(spriteObject: object)
        spriteNode.penConfiguration.isCut = false
        object.spriteNode = spriteNode

        let script = Script()
        script.object = object

        let brick = StartPlotBrick()
        brick.script = script

        let action = brick.actionBlock()
        XCTAssertFalse(spriteNode.penConfiguration.isCut)
        action()
        XCTAssertTrue(spriteNode.penConfiguration.isCut)
        XCTAssertEqual(spriteNode.penConfiguration.previousCutPositions.last, spriteNode.position)
    }
}
