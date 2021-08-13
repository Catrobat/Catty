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

final class ClearGraphicEffectBrickTests: AbstractBrickTest {

    var brick: SetTransparencyBrick!
    var spriteNode: CBSpriteNode!
    var project: Project!
    var object: SpriteObject!
    var script: WhenScript!

    override func setUp() {
        super.setUp()
        object = SpriteObject()
        project = ProjectManager.shared.createProject(name: "a", projectId: "1")
        object.scene = project.scene
        spriteNode = CBSpriteNode.init(spriteObject: object)
        object.spriteNode = spriteNode
        self.stage.addChild(spriteNode)
        spriteNode.catrobatPosition = CBPosition(x: 0.0, y: 0.0)

        let bundle = Bundle(for: type(of: self))
        let filePath = bundle.path(forResource: "test.png", ofType: nil)
        let imageData = UIImage(contentsOfFile: filePath!)!.pngData()
        let look = Look(name: "test", filePath: "test.png")

        do {
            try imageData?.write(to: URL(fileURLWithPath: object.scene.imagesPath()! + "/test.png"))
        } catch {
            XCTFail("Error when writing image data")
        }

        script = WhenScript()
        script.object = object

        brick = SetTransparencyBrick()
        brick.script = script

        object.lookList.add(look)
        object.lookList.add(look)
        object.spriteNode.currentLook = look
        object.spriteNode.currentUIImageLook = UIImage(contentsOfFile: filePath!)

        object.spriteNode.catrobatBrightness = 10
        object.spriteNode.catrobatTransparency = 10
    }

    override func tearDown() {
        super.tearDown()
        Project.removeProjectFromDisk(withProjectName: project.header.programName, projectID: project.header.programID)
    }

    func testClearGraphicEffectBrick() {
        brick.transparency = Formula(integer: 20)

        XCTAssertNotEqual(Double(spriteNode.ciBrightness), BrightnessSensor.defaultRawValue, accuracy: 0.0001)
        XCTAssertNotEqual(Double(spriteNode.alpha), TransparencySensor.defaultRawValue, accuracy: 0.0001)

        var action = brick.actionBlock(self.formulaInterpreter)
        action()

        let clearBrick = ClearGraphicEffectBrick()
        clearBrick.script = script

        action = clearBrick.actionBlock()
        action()

        XCTAssertEqual(Double(spriteNode.alpha), TransparencySensor.defaultRawValue, accuracy: 0.0001, "ClearGraphic alpha is not correctly calculated")
        XCTAssertEqual(Double(spriteNode.ciBrightness), BrightnessSensor.defaultRawValue, accuracy: 0.0001, "ClearGraphic brightness is not correctly calculated")
    }

    func testClearGraphicEffectBrick2() {
        brick.transparency = Formula(integer: -20)

        XCTAssertNotEqual(Double(spriteNode.alpha), TransparencySensor.defaultRawValue, accuracy: 0.001)
        XCTAssertNotEqual(Double(spriteNode.ciBrightness), BrightnessSensor.defaultRawValue, accuracy: 0.001)

        var action = brick.actionBlock(self.formulaInterpreter)
        action()

        let clearBrick = ClearGraphicEffectBrick()
        clearBrick.script = script

        action = clearBrick.actionBlock()
        action()

        XCTAssertEqual(Double(spriteNode.alpha), TransparencySensor.defaultRawValue, accuracy: 0.0001, "ClearGraphic is not correctly calculated")
        XCTAssertEqual(Double(spriteNode.ciBrightness), BrightnessSensor.defaultRawValue, accuracy: 0.0001, "ClearGraphic brightness is not correctly calculated")
    }

    func testMutableCopy() {
        let clearBrick = ClearGraphicEffectBrick()

        let copiedClearBrick: ClearGraphicEffectBrick = clearBrick.mutableCopy(with: CBMutableCopyContext()) as! ClearGraphicEffectBrick

        XCTAssertTrue(clearBrick.isEqual(to: copiedClearBrick))
        XCTAssertFalse(clearBrick === copiedClearBrick)
    }
}
