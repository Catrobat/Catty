/**
 *  Copyright (C) 2010-2018 The Catrobat Team
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

final class ClearGrafficEffectBrickTests: AbstractBrickTests {

    func testClearGraphicEffectBrick() {
        let object = SpriteObject()
        let program = Program.defaultProgram(withName: "a", programID: nil)
        object.program = program
        let spriteNode = CBSpriteNode(spriteObject: object)
        object.spriteNode = spriteNode

        scene!.addChild(spriteNode)
        spriteNode.catrobatPosition = CGPoint(x: 0.0, y: 0.0)

        let bundle = Bundle(for: ClearGrafficEffectBrickTests.self)
        let filePath = bundle.path(forResource: "test.png", ofType: nil)
        let imageData: Data? = UIImage(contentsOfFile: filePath ?? "")!.pngData()
        let look = Look(name: "test", andPath: "test.png")
        try? imageData?.write(to: URL(fileURLWithPath: "\(object.projectPath()!)images/\("test.png")"), options: [.atomic])

        let script = WhenScript()
        script.object = object

        let brick = SetTransparencyBrick()
        brick.script = script
        object.lookList.add(look as Any)
        object.lookList.add(look as Any)
        object.spriteNode.currentLook = look
        object.spriteNode.currentUIImageLook = UIImage(contentsOfFile: filePath ?? "")
        object.spriteNode.catrobatBrightness = 10
        object.spriteNode.catrobatTransparency = 10
        brick.script = script
        brick.transparency = Formula(integer: 20)

        XCTAssertNotEqual(Double(spriteNode.ciBrightness), BrightnessSensor.defaultRawValue, accuracy: 0.0001)
        XCTAssertNotEqual(Double(spriteNode.alpha), TransparencySensor.defaultRawValue, accuracy: 0.0001)

        var action: () -> Void = brick.actionBlock(formulaInterpreter!)
        action()

        let clearBrick = ClearGraphicEffectBrick()
        clearBrick.script = script
        action = clearBrick.actionBlock()
        action()

        XCTAssertEqual(Double(spriteNode.alpha), TransparencySensor.defaultRawValue, accuracy: 0.0001, "ClearGraphic alpha is not correctly calculated")
        XCTAssertEqual(Double(spriteNode.ciBrightness), BrightnessSensor.defaultRawValue, accuracy: 0.0001, "ClearGraphic brightness is not correctly calculated")
        //TODO: Program.removeProgramFromDisk(withProgramName: program.header.programName, programID: program.header.programID)
    }

    func testClearGraphicEffectBrick2() {
        let object = SpriteObject()
        let program = Program.defaultProgram(withName: "a", programID: nil)
        object.program = program
        let spriteNode = CBSpriteNode(spriteObject: object)
        object.spriteNode = spriteNode

        scene!.addChild(spriteNode)
        spriteNode.catrobatPosition = CGPoint(x: 0.0, y: 0.0)

        let bundle = Bundle(for: ClearGrafficEffectBrickTests.self)
        let filePath = bundle.path(forResource: "test.png", ofType: nil)
        let imageData: Data? = UIImage(contentsOfFile: filePath ?? "")!.pngData()
        let look = Look(name: "test", andPath: "test.png")
        try? imageData?.write(to: URL(fileURLWithPath: "\(object.projectPath()!)images/\("test.png")"), options: [.atomic])

        let transparency = Formula()
        let formulaTree = FormulaElement()
        formulaTree.type = ElementType.NUMBER
        formulaTree.value = "-20"
        transparency.formulaTree = formulaTree

        let script = WhenScript()
        script.object = object

        let brick = SetTransparencyBrick()
        brick.script = script
        object.lookList.add(look as Any)
        object.lookList.add(look as Any)
        object.spriteNode.currentLook = look
        object.spriteNode.currentUIImageLook = UIImage(contentsOfFile: filePath ?? "")
        object.spriteNode.catrobatTransparency = 10
        object.spriteNode.catrobatBrightness = 10
        brick.script = script
        brick.transparency = transparency

        XCTAssertNotEqual(Double(spriteNode.alpha), TransparencySensor.defaultRawValue, accuracy: 0.001)
        XCTAssertNotEqual(Double(spriteNode.ciBrightness), BrightnessSensor.defaultRawValue, accuracy: 0.001)

        var action: () -> Void = brick.actionBlock(formulaInterpreter!)
        action()

        let clearBrick = ClearGraphicEffectBrick()
        clearBrick.script = script

        action = clearBrick.actionBlock()
        action()

        XCTAssertEqual(Double(spriteNode.alpha), TransparencySensor.defaultRawValue, accuracy: 0.0001, "ClearGraphic is not correctly calculated")
        XCTAssertEqual(Double(spriteNode.ciBrightness), BrightnessSensor.defaultRawValue, accuracy: 0.0001, "ClearGraphic brightness is not correctly calculated")
        //TODO: Program.removeProgramFromDisk(withProgramName: program.header.programName, programID: program.header.programID)
    }
}
