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

final class SetBackgroundBrickTests: AbstractBrickTest {

    var object: SpriteObject!
    var project: Project!
    var spriteNode: CBSpriteNode!
    var script: Script!

    override func setUp() {
        object = SpriteObject()
        project = ProjectManager.createProject(name: "a", projectId: "1")
        object.scene = project.scene
        spriteNode = CBSpriteNode(spriteObject: object)
        object.spriteNode = spriteNode

        script = WhenScript()
        script.object = object

    }

    func testSetBackgroundBrick() {

        let backgroundObject = project.scene.objects().first!
        XCTAssertNotNil(backgroundObject)

        let bgSpriteNode = CBSpriteNode(spriteObject: object)
        backgroundObject.spriteNode = bgSpriteNode

        let bundle = Bundle(for: type(of: self))
        let filePath = bundle.path(forResource: "test.png", ofType: nil)
        let imageData = UIImage(contentsOfFile: filePath!)!.pngData()

        var look: Look!
        var look1: Look!
        do {
            look = Look(name: "test", filePath: "test.png")
            try imageData?.write(to: URL(fileURLWithPath: object.scene.imagesPath()! + "/test.png"))
            look1 = Look(name: "test2", filePath: "test2.png")
            try imageData?.write(to: URL(fileURLWithPath: object.scene.imagesPath()! + "/test2.png"))
        } catch {
            XCTFail("Error when writing image data")
        }

        let brick = SetBackgroundBrick()
        brick.script = script
        brick.look = look1

        object.lookList.add(look!)
        object.lookList.add(look1!)

        let action = brick.actionBlock()
        action()

        XCTAssertEqual(backgroundObject.spriteNode.currentLook, look1, "SetBackgroundBrick not correct")
        Project.removeProjectFromDisk(withProjectName: project.header.programName, projectID: project.header.programID)
    }

    func testMutableCopy() {

        let brick = SetBackgroundBrick()
        let look = Look(name: "backgroundToCopy", filePath: "background")
        brick.look = look

        let copiedBrick: SetBackgroundBrick = brick.mutableCopy(with: CBMutableCopyContext()) as! SetBackgroundBrick

        XCTAssertTrue(brick.isEqual(to: copiedBrick))
        XCTAssertFalse(brick === copiedBrick)
        XCTAssertTrue(brick.look.isEqual(copiedBrick.look))
        XCTAssertTrue(copiedBrick.look.isEqual(look))
        XCTAssertTrue(copiedBrick.look === brick.look)
    }

}
