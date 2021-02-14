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

final class SetColorBrickTests: AbstractBrickTest {

    var brick: SetColorBrick!
    var spriteNode: CBSpriteNode!
    var project: Project!
    var object: SpriteObject!
    var script: WhenScript!

    override func setUp() {
        super.setUp()
        brick = SetColorBrick()
        script = WhenScript()

        object = SpriteObject()
        project = ProjectManager.shared.createProject(name: "a", projectId: "1")
        object.scene = project.scene
        spriteNode = CBSpriteNode.init(spriteObject: object)
        object.spriteNode = spriteNode

        let bundle = Bundle(for: type(of: self))
        let filePath = bundle.path(forResource: "test.png", ofType: nil)
        let imageData = UIImage(contentsOfFile: filePath!)!.pngData()
        let look = Look(name: "test", filePath: "test.png")

        do {
            try imageData?.write(to: URL(fileURLWithPath: object.scene.imagesPath()! + "/test.png"))
        } catch {
            XCTFail("Error when writing image data")
        }

        object.lookList.add(look)
        object.lookList.add(look)
        object.spriteNode.currentLook = look
        object.spriteNode.currentUIImageLook = UIImage(contentsOfFile: filePath!)

        script.object = object
        brick.script = script
    }

    override func tearDown() {
        super.tearDown()
        Project.removeProjectFromDisk(withProjectName: project.header.programName, projectID: project.header.programID)
    }

    func testSetColorBrickLower() {
        object.spriteNode.catrobatColor = 0.0
        brick.color = Formula(integer: -60)

        let action = brick.actionBlock(self.formulaInterpreter)
        action()

        XCTAssertEqual(140, spriteNode.catrobatColor, accuracy: 0.1, "SetColorBrick - Color not correct")
    }

    func testSetColorBrickHigher() {
        object.spriteNode.catrobatColor = 0.0
        brick.color = Formula(integer: 140)

        let action = brick.actionBlock(self.formulaInterpreter)
        action()

        XCTAssertEqual(140.0, spriteNode.catrobatColor, accuracy: 0.1, "SetColorBrick - Color not correct")
    }

    func testSetColorBrickMoreThan2Pi() {
        object.spriteNode.catrobatColor = 0.0
        brick.color = Formula(integer: 230)

        let action = brick.actionBlock(self.formulaInterpreter)
        action()

        XCTAssertEqual(30.0, spriteNode.catrobatColor, accuracy: 0.1, "SetColorBrick - Color not correct")
    }

    func testSetColorBrickWrongInput() {
        brick.color = Formula(string: "a")

        let action = brick.actionBlock(self.formulaInterpreter)
        action()

        XCTAssertEqual(0.0, spriteNode.catrobatColor, accuracy: 0.1, "SetColorBrick - Color not correct")
    }
    func testMutableCopy() {
             let brick = SetColorBrick()
             let script = Script()
             let object = SpriteObject()
             let scene = Scene(name: "testScene")
             object.scene = scene

             script.object = object
             brick.script = script
             brick.color = Formula(integer: 100)

             let copiedBrick: SetColorBrick = brick.mutableCopy(with: CBMutableCopyContext()) as! SetColorBrick

             XCTAssertTrue(brick.isEqual(to: copiedBrick))
             XCTAssertFalse(brick === copiedBrick)
      }
    func testGetFormulas() {
        brick.color = Formula(integer: 1)
        var formulas = brick.getFormulas()

        XCTAssertEqual(formulas?.count, 1)
        XCTAssertEqual(brick.color, formulas?[0])

        brick.color = Formula(integer: 22)
        formulas = brick.getFormulas()

        XCTAssertEqual(brick.color, formulas?[0])
     }
}
