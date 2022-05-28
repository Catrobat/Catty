/**
 *  Copyright (C) 2010-2022 The Catrobat Team
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

final class StitchBrickTests: XCTestCase {

    func testStitchBrick() {
        let object = SpriteObject()
        let scene = Scene(name: "testScene")
        object.scene = scene
        let spriteNode = CBSpriteNode(spriteObject: object)
        object.spriteNode = spriteNode
        spriteNode.position = CGPoint(x: 0, y: 0)
        let script = Script()
        script.object = object

        let brick = StitchBrick()
        brick.script = script

        let action = brick.actionBlock()
        XCTAssertEqual(spriteNode.embroideryStream.count, 0)
        action()
        XCTAssertEqual(spriteNode.embroideryStream.count, 1)
        XCTAssertEqual(spriteNode.embroideryStream[0].getPosition(), spriteNode.position)
    }
}
