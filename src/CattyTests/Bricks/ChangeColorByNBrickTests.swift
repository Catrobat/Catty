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

final class ChangeColorByNBrickTests: AbstractBrickTests {

    func testChangeColorByNBrickPositive() {
        let object = SpriteObject()
        let program = Program.defaultProgram(withName: "a", programID: nil)
        let spriteNode = CBSpriteNode(spriteObject: object)
        object.spriteNode = spriteNode
        object.program = program

        let bundle = Bundle(for: ChangeColorByNBrickTests.self)
        let filePath = bundle.path(forResource: "test.png", ofType: nil)
        let imageData: Data? = UIImage(contentsOfFile: filePath ?? "")!.pngData()
        let look = Look(name: "test", andPath: "test.png")
        try? imageData?.write(to: URL(fileURLWithPath: "\(object.projectPath()!)images/\("test.png")"), options: [.atomic])

        let script = WhenScript()
        script.object = object

        let brick = ChangeColorByNBrick()
        brick.script = script
        object.lookList.add(look as Any)
        object.lookList.add(look as Any)
        object.spriteNode.currentLook = look
        object.spriteNode.currentUIImageLook = UIImage(contentsOfFile: filePath ?? "")
        object.spriteNode.catrobatColor = 0.0

        brick.changeColor = Formula(integer: 70)

        let action: () -> Void = brick.actionBlock(formulaInterpreter!)
        action()

        XCTAssertEqual(70.0, spriteNode.catrobatColor, accuracy: 0.1, "ChangeColorBrick - Color not correct")

        //TODO: Program.removeProgramFromDisk(withProgramName: program.header.programName, programID: program.header.programID)
    }

    func testChangeColorByNBrickWrongInput() {
        let object = SpriteObject()
        let program = Program.defaultProgram(withName: "a", programID: nil)
        let spriteNode = CBSpriteNode(spriteObject: object)
        object.spriteNode = spriteNode
        object.program = program

        let bundle = Bundle(for: ChangeColorByNBrickTests.self)
        let filePath = bundle.path(forResource: "test.png", ofType: nil)
        let imageData: Data? = UIImage(contentsOfFile: filePath ?? "")!.pngData()
        let look = Look(name: "test", andPath: "test.png")
        try? imageData?.write(to: URL(fileURLWithPath: "\(object.projectPath()!)images/\("test.png")"), options: [.atomic])

        let script = WhenScript()
        script.object = object

        let brick = ChangeColorByNBrick()
        brick.script = script
        object.lookList.add(look as Any)
        object.lookList.add(look as Any)
        object.spriteNode.currentLook = look
        object.spriteNode.currentUIImageLook = UIImage(contentsOfFile: filePath ?? "")
        object.spriteNode.catrobatColor = 10.0

        brick.changeColor = Formula(string: "a")

        let action: () -> Void = brick.actionBlock(formulaInterpreter!)
        action()

        XCTAssertEqual(10.0, spriteNode.catrobatColor, accuracy: 0.1, "ChangeColorBrick - Color not correct")

        //TODO: Program.removeProgramFromDisk(withProgramName: program.header.programName, programID: program.header.programID)
    }

    func testChangeColorByNBrickNegative() {
        let object = SpriteObject()
        let program = Program.defaultProgram(withName: "a", programID: nil)
        let spriteNode = CBSpriteNode(spriteObject: object)
        object.spriteNode = spriteNode
        object.program = program

        let bundle = Bundle(for: ChangeColorByNBrickTests.self)
        let filePath = bundle.path(forResource: "test.png", ofType: nil)
        let imageData: Data? = UIImage(contentsOfFile: filePath ?? "")!.pngData()
        let look = Look(name: "test", andPath: "test.png")
        try? imageData?.write(to: URL(fileURLWithPath: "\(object.projectPath()!)images/\("test.png")"), options: [.atomic])

        let script = WhenScript()
        script.object = object

        let brick = ChangeColorByNBrick()
        brick.script = script
        object.lookList.add(look as Any)
        object.lookList.add(look as Any)
        object.spriteNode.currentLook = look
        object.spriteNode.currentUIImageLook = UIImage(contentsOfFile: filePath ?? "")
        object.spriteNode.catrobatColor = 20.0

        brick.changeColor = Formula(integer: -10)

        let action: () -> Void = brick.actionBlock(formulaInterpreter!)
        action()

        XCTAssertEqual(10.0, spriteNode.catrobatColor, accuracy: 0.1, "ChangeColorBrick - Color not correct")

        //TODO: Program.removeProgramFromDisk(withProgramName: program.header.programName, programID: program.header.programID)
    }

    func testChangeColorByNBrickMoreThan2Pi() {
        let object = SpriteObject()
        let program = Program.defaultProgram(withName: "a", programID: nil)
        let spriteNode = CBSpriteNode(spriteObject: object)
        object.spriteNode = spriteNode
        object.program = program

        let bundle = Bundle(for: ChangeColorByNBrickTests.self)
        let filePath = bundle.path(forResource: "test.png", ofType: nil)
        let imageData: Data? = UIImage(contentsOfFile: filePath ?? "")!.pngData()
        let look = Look(name: "test", andPath: "test.png")
        try? imageData?.write(to: URL(fileURLWithPath: "\(object.projectPath()!)images/\("test.png")"), options: [.atomic])

        let script = WhenScript()
        script.object = object

        let brick = ChangeColorByNBrick()
        brick.script = script
        object.lookList.add(look as Any)
        object.lookList.add(look as Any)
        object.spriteNode.currentLook = look
        object.spriteNode.currentUIImageLook = UIImage(contentsOfFile: filePath ?? "")
        object.spriteNode.ciHueAdjust = CGFloat(ColorSensor.defaultRawValue)

        brick.changeColor = Formula(integer: -730)

        let action: () -> Void = brick.actionBlock(formulaInterpreter!)
        action()

        XCTAssertEqual(200 - 130.0, spriteNode.catrobatColor, accuracy: 0.1, "ChangeColorBrick - Color not correct")

        //TODO: Program.removeProgramFromDisk(withProgramName: program.header.programName, programID: program.header.programID)
    }
}
