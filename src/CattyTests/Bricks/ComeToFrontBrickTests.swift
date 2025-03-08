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

final class ComeToFrontBrickTests: AbstractBrickTest {

    func testComeToFrontBrick() {
        let project = Project()
        let scene = Scene(name: "testScene")
        scene.project = project
        project.scene = scene

        let background = SpriteObject()
        background.scene = scene
        let spriteNodeBG = CBSpriteNode(spriteObject: background)
        background.spriteNode = spriteNodeBG

        let object1 = SpriteObject()
        object1.scene = scene
        let spriteNode1 = CBSpriteNode(spriteObject: object1)
        object1.spriteNode = spriteNode1
        spriteNode1.zPosition = 1

        let object2 = SpriteObject()
        object2.scene = scene
        let spriteNode2 = CBSpriteNode(spriteObject: object2)
        object2.spriteNode = spriteNode2
        spriteNode2.zPosition = 2

        project.scene.add(object: background)
        project.scene.add(object: object1)
        project.scene.add(object: object2)

        let script = WhenScript()
        script.object = object1
        let brick = ComeToFrontBrick()
        brick.script = script
        let action = brick.actionBlock()
        action()

        XCTAssertEqual(spriteNode1.zPosition, CGFloat(2.0), "ComeToFront is not correctly calculated")
        XCTAssertEqual(spriteNode2.zPosition, CGFloat(1.0), "ComeToFront is not correctly calculated")
    }

    func testMutableCopy() {
        let brick = ComeToFrontBrick()

        let copiedBrick: ComeToFrontBrick = brick.mutableCopy(with: CBMutableCopyContext()) as! ComeToFrontBrick

        XCTAssertTrue(brick.isEqual(to: copiedBrick))
        XCTAssertFalse(brick === copiedBrick)
    }
}
