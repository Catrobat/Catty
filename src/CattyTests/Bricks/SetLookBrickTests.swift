/**
 *  Copyright (C) 2010-2020 The Catrobat Team
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

final class SetLookBrickTests: XCTestCase {

    var object: SpriteObject!
    var project: Project!
    var spriteNode: CBSpriteNode!

    override func setUp() {
        let scene = Scene(name: "testScene")
        scene.project = project
        object = SpriteObject()
        object.scene = scene

        project = ProjectManager.createProject(name: "a", projectId: "1")

        spriteNode = CBSpriteNode(spriteObject: object)
        object.spriteNode = spriteNode

    }

    func testMutableCopy() {
        let brick = SetLookBrick()
        let look = Look(name: "lookToCopy", andPath: "look")
        brick.look = look

        let copiedBrick: SetLookBrick = brick.mutableCopy(with: CBMutableCopyContext()) as! SetLookBrick

        XCTAssertTrue(brick.isEqual(to: copiedBrick))
        XCTAssertFalse(brick === copiedBrick)
        XCTAssertTrue(brick.look.isEqual(to: copiedBrick.look))
        XCTAssertTrue(copiedBrick.look === brick.look)
    }

}
