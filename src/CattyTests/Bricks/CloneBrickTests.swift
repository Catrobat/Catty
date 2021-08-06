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

final class CloneBrickTests: AbstractBrickTest {

    var firstSpriteNode: CBSpriteNode!
    var script: Script!
    var brick: CloneBrick!
    var scene: Scene!

    override func setUp() {
        super.setUp()
        self.stage = StageBuilder(project: ProjectMock()).build()

        let firstObject = SpriteObject()
        scene = Scene(name: "testScene")
        firstObject.scene = scene
        firstSpriteNode = CBSpriteNode(spriteObject: firstObject)
        firstObject.spriteNode = firstSpriteNode

        self.stage.addChild(firstSpriteNode)
        scene.add(object: firstObject)

        script = WhenScript()
        script.object = firstObject

        brick = CloneBrick()
        brick.script = script
        brick.objectToClone = firstObject
    }

    func testCreateClone() {
        XCTAssertEqual(brick.objectToClone!.scene.objects().count, 1)
        let name = "test"
        brick.objectToClone?.name = name
        let userData = UserDataContainer()
        brick.objectToClone?.userData = userData
        let scriptList: NSMutableArray = [Script()]
        brick.objectToClone?.scriptList = scriptList
        let soundList: NSMutableArray = [Sound(name: "test", fileName: "testName")]
        brick.objectToClone?.soundList = soundList
        let lookList: NSMutableArray = [Look(name: "test", filePath: "testPath")]
        brick.objectToClone?.lookList = lookList

        let action = brick.actionBlock(self.formulaInterpreter)
        action()

        XCTAssertEqual(brick.objectToClone!.scene.objects().count, 2)

        let firstObject = brick.objectToClone!.scene.object(at: 0)
        let secondObject = brick.objectToClone!.scene.object(at: 1)

        XCTAssertEqual(firstObject?.userData, userData)
        XCTAssertEqual(secondObject?.userData, userData)
        XCTAssertEqual(firstObject?.lookList, lookList)
        XCTAssertEqual(secondObject?.lookList, lookList)
        XCTAssertEqual(firstObject?.soundList, soundList)
        XCTAssertEqual(secondObject?.soundList, soundList)
    }

    func testMutableCopy() {
        let brick = CloneBrick()
        let script = Script()
        let object = SpriteObject()
        let scene = Scene(name: "testScene")
        object.scene = scene

        script.object = object
        brick.script = script
        let clonedObject = SpriteObject()
        clonedObject.name = "clonedObject"
        brick.objectToClone = clonedObject

        let copiedBrick: CloneBrick = brick.mutableCopy(with: CBMutableCopyContext()) as! CloneBrick

        XCTAssertTrue(brick.isEqual(to: copiedBrick))
        XCTAssertFalse(brick === copiedBrick)
        XCTAssertTrue(brick.objectToClone!.isEqual(to: copiedBrick.objectToClone))
        XCTAssertTrue(brick.objectToClone === copiedBrick.objectToClone)
    }
}
