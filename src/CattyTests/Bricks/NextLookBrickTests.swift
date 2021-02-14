/**
 *  Copyright (C) 2010-2021 The Catrobat Team
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

final class NextLookBrickTests: AbstractBrickTest {

    func testNextLookBrick() {
        let object = SpriteObject()
        let project = ProjectManager.shared.createProject(name: "a", projectId: "1")
        object.scene = project.scene
        let spriteNode = CBSpriteNode(spriteObject: object)
        object.spriteNode = spriteNode

        let bundle = Bundle(for: type(of: self))
        let filePath = bundle.path(forResource: "test.png", ofType: nil)
        let imageData = UIImage(contentsOfFile: filePath!)!.pngData()

        var look: Look!
        var look2: Look!
        do {
            look = Look(name: "test", filePath: "test.png")
            try imageData?.write(to: URL(fileURLWithPath: object.scene.imagesPath()! + "/test.png"))
            look2 = Look(name: "test2", filePath: "test2.png")
            try imageData?.write(to: URL(fileURLWithPath: object.scene.imagesPath()! + "/test2.png"))
        } catch {
            XCTFail("Error when writing image data")
        }

        let script = WhenScript()
        script.object = object
        let brick = NextLookBrick()
        brick.script = script

        object.lookList.add(look!)
        object.lookList.add(look2!)
        object.spriteNode.currentLook = look
        object.spriteNode.currentUIImageLook = UIImage(contentsOfFile: filePath!)

        let action = brick.actionBlock()
        action()

        XCTAssertEqual(spriteNode.currentLook, look2, "NextLookBrick not correct")
        Project.removeProjectFromDisk(withProjectName: project.header.programName, projectID: project.header.programID)
    }

    func testMutableCopy() {
        let brick = NextLookBrick()

        let copiedBrick: NextLookBrick = brick.mutableCopy(with: CBMutableCopyContext(), andErrorReporting: true) as! NextLookBrick

        XCTAssertTrue(brick.isEqual(to: copiedBrick))
        XCTAssertFalse(brick === copiedBrick)
    }
}
