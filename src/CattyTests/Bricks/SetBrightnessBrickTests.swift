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

final class SetBrightnessBrickTests: AbstractBrickTest {

    var brick: SetBrightnessBrick!
    var spriteNode: CBSpriteNode!
    var project: Project!
    var object: SpriteObject!
    var script: WhenScript!

    override func setUp() {
        super.setUp()
        brick = SetBrightnessBrick()
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

    func testSetBrightnessBrick() {
        brick.brightness = Formula(integer: 180)

        let action = brick.actionBlock(self.formulaInterpreter)
        action()

        XCTAssertEqual(180.0, spriteNode.catrobatBrightness, accuracy: 0.1, "SetBrightnessBrick - Brightness not correct")
    }

    func testSetBrightnessBrickNegative() {
        brick.brightness = Formula(integer: -10)

        let action = brick.actionBlock(self.formulaInterpreter)
        action()

        XCTAssertEqual(0.0, spriteNode.catrobatBrightness, accuracy: 0.1, "SetBrightnessBrick - Brightness not correct")
    }

    func testSetBrightnessBrickTooBright() {
        brick.brightness = Formula(integer: 210)

        let action = brick.actionBlock(self.formulaInterpreter)
        action()

        XCTAssertEqual(200.0, spriteNode.catrobatBrightness, accuracy: 0.1, "SetBrightnessBrick - Brightness not correct")
    }

    func testSetBrightnessBrickWrongInput() {
        brick.brightness = Formula(string: "a")

        let action = brick.actionBlock(self.formulaInterpreter)
        action()

        XCTAssertEqual(0.0, spriteNode.catrobatBrightness, accuracy: 0.1, "SetBrightnessBrick - Brightness not correct")
    }

    func testMutableCopy() {
        let brick = SetBrightnessBrick()
        let script = Script()
        let object = SpriteObject()
        let scene = Scene(name: "testScene")
        object.scene = scene

        script.object = object
        brick.script = script
        brick.brightness = Formula(integer: 0)

        let copiedBrick: SetBrightnessBrick = brick.mutableCopy(with: CBMutableCopyContext()) as! SetBrightnessBrick

        XCTAssertTrue(brick.isEqual(to: copiedBrick))
        XCTAssertFalse(brick === copiedBrick)
    }

    func testGetFormulas() {
        brick.brightness = Formula(integer: 1)
        var formulas = brick.getFormulas()

        XCTAssertEqual(formulas?.count, 1)
        XCTAssertEqual(brick.brightness, formulas?[0])

        brick.brightness = Formula(integer: 22)
        formulas = brick.getFormulas()

        XCTAssertEqual(brick.brightness, formulas?[0])
     }
}
