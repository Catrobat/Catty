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

final class ChangeColorByNBrickTests: AbstractBrickTest {

    var brick: ChangeColorByNBrick!
    var spriteNode: CBSpriteNode!
    var project: Project!
    var object: SpriteObject!
    var script: WhenScript!

    override func setUp() {
        super.setUp()
        brick = ChangeColorByNBrick()
        script = WhenScript()
        object = SpriteObject()
        project = ProjectManager.shared.createProject(name: "a", projectId: "1")
        object.scene = project.scene
        spriteNode = CBSpriteNode(spriteObject: object)
        object.spriteNode = spriteNode
        object.scene.project = project

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

    func testChangeColorByNBrickPositive() {
        object.spriteNode.catrobatColor = 0.0
        brick.changeColor = Formula(integer: 70)

        let action = brick.actionBlock(self.formulaInterpreter)
        action()

        XCTAssertEqual(70.0, spriteNode.catrobatColor, accuracy: 0.1, "ChangeColorBrick - Color not correct")
    }

    func testChangeColorByNBrickWrongInput() {
        object.spriteNode.catrobatColor = 10.0
        brick.changeColor = Formula(string: "a")

        let action = brick.actionBlock(self.formulaInterpreter)
        action()

        XCTAssertEqual(10.0, spriteNode.catrobatColor, accuracy: 0.1, "ChangeColorBrick - Color not correct")
    }

    func testChangeColorByNBrickNegative() {
        object.spriteNode.catrobatColor = 20.0
        brick.changeColor = Formula(integer: -10)

        let action = brick.actionBlock(self.formulaInterpreter)
        action()

        XCTAssertEqual(10.0, spriteNode.catrobatColor, accuracy: 0.1, "ChangeColorBrick - Color not correct")
    }

    func testChangeColorByNBrickMoreThan2Pi() {
        object.spriteNode.ciHueAdjust = CGFloat(ColorSensor.defaultRawValue)
        brick.changeColor = Formula(integer: -730)

        let action = brick.actionBlock(self.formulaInterpreter)
        action()

        XCTAssertEqual(200.0 - 130.0, spriteNode.catrobatColor, accuracy: 0.1, "ChangeColorBrick - Color not correct")
    }

    func testMutableCopy() {
        brick.changeColor = Formula(integer: 70)

        var copiedBrick: ChangeColorByNBrick = brick.mutableCopy(with: CBMutableCopyContext(), andErrorReporting: true) as! ChangeColorByNBrick

        XCTAssertTrue(brick.isEqual(to: copiedBrick))
        XCTAssertFalse(brick === copiedBrick)

        XCTAssertTrue(brick.changeColor.isEqual(to: copiedBrick.changeColor))
        XCTAssertFalse(brick.changeColor === copiedBrick.changeColor)

        brick.changeColor = Formula(integer: -10)

        copiedBrick = brick.mutableCopy(with: CBMutableCopyContext(), andErrorReporting: true) as! ChangeColorByNBrick

        XCTAssertTrue(brick.changeColor.isEqual(to: copiedBrick.changeColor))
        XCTAssertFalse(brick.changeColor === copiedBrick.changeColor)
    }

    func testGetFormulas() {
        brick.changeColor = Formula(integer: 1)
        var formulas = brick.getFormulas()

        XCTAssertTrue(brick.changeColor.isEqual(to: formulas?[0]))
        XCTAssertTrue(brick.changeColor.isEqual(to: Formula(integer: 1)))
        XCTAssertFalse(brick.changeColor.isEqual(to: Formula(integer: -22)))

        brick.changeColor = Formula(integer: -22)
        formulas = brick.getFormulas()

        XCTAssertTrue(brick.changeColor.isEqual(to: formulas?[0]))
        XCTAssertTrue(brick.changeColor.isEqual(to: Formula(integer: -22)))
        XCTAssertFalse(brick.changeColor.isEqual(to: Formula(integer: 1)))
    }
}
