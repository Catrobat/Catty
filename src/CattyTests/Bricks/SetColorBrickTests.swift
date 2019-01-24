/**
 *  Copyright (C) 2010-2019 The Catrobat Team
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

final class SetColorBrickTests: AbstractBrickTests {

    func testSetColorBrickLower() {
        let object = SpriteObject()
        let project = Project.defaultProject(withName: "a", projectID: "")
        let spriteNode = CBSpriteNode(spriteObject: object)
        object.spriteNode = spriteNode
        object.project = project

        let bundle = Bundle(for: SetColorBrickTests.self)
        let filePath = bundle.path(forResource: "test.png", ofType: nil)
        let imageData: Data? = UIImage(contentsOfFile: filePath ?? "")!.pngData()
        let look = Look(name: "test", andPath: "test.png")
        try? imageData?.write(to: URL(fileURLWithPath: "\(object.projectPath()!)images/\("test.png")"), options: [.atomic])

        let script = WhenScript()
        script.object = object
        let brick = SetColorBrick()
        brick.script = script
        object.lookList.add(look as Any)
        object.lookList.add(look as Any)
        object.spriteNode.currentLook = look
        object.spriteNode.currentUIImageLook = UIImage(contentsOfFile: filePath ?? "")
        object.spriteNode.catrobatColor = 0.0

        brick.color = Formula(integer: -60)

        let action: () -> Void = brick.actionBlock(formulaInterpreter!)
        action()

        XCTAssertEqual(200.0 - 60.0, spriteNode.catrobatColor, accuracy: 0.1, "SetColorBrick - Color not correct")
        Project.removeProjectFromDisk(withProjectName: project.header.programName, projectID: project.header.programID)
    }

    func testSetColorBrickHigher() {
        let object = SpriteObject()
        let project = Project.defaultProject(withName: "a", projectID: "")
        let spriteNode = CBSpriteNode(spriteObject: object)
        object.spriteNode = spriteNode
        object.project = project

        let bundle = Bundle(for: SetColorBrickTests.self)
        let filePath = bundle.path(forResource: "test.png", ofType: nil)
        let imageData: Data? = UIImage(contentsOfFile: filePath ?? "")!.pngData()
        let look = Look(name: "test", andPath: "test.png")
        try? imageData?.write(to: URL(fileURLWithPath: "\(object.projectPath()!)images/\("test.png")"), options: [.atomic])

        let script = WhenScript()
        script.object = object
        let brick = SetColorBrick()
        brick.script = script
        object.lookList.add(look as Any)
        object.lookList.add(look as Any)
        object.spriteNode.currentLook = look
        object.spriteNode.currentUIImageLook = UIImage(contentsOfFile: filePath ?? "")
        object.spriteNode.catrobatColor = 0.0

        brick.color = Formula(integer: 140)

        let action: () -> Void = brick.actionBlock(formulaInterpreter!)
        action()

        XCTAssertEqual(140.0, spriteNode.catrobatColor, accuracy: 0.1, "SetColorBrick - Color not correct")
        Project.removeProjectFromDisk(withProjectName: project.header.programName, projectID: project.header.programID)
    }

    func testSetColorBrickMoreThan2Pi() {
        let object = SpriteObject()
        let project = Project.defaultProject(withName: "a", projectID: "")
        let spriteNode = CBSpriteNode(spriteObject: object)
        object.spriteNode = spriteNode
        object.project = project

        let bundle = Bundle(for: SetColorBrickTests.self)
        let filePath = bundle.path(forResource: "test.png", ofType: nil)
        let imageData: Data? = UIImage(contentsOfFile: filePath ?? "")!.pngData()
        let look = Look(name: "test", andPath: "test.png")
        try? imageData?.write(to: URL(fileURLWithPath: "\(object.projectPath()!)images/\("test.png")"), options: [.atomic])

        let script = WhenScript()
        script.object = object
        let brick = SetColorBrick()
        brick.script = script
        object.lookList.add(look as Any)
        object.lookList.add(look as Any)
        object.spriteNode.currentLook = look
        object.spriteNode.currentUIImageLook = UIImage(contentsOfFile: filePath ?? "")
        object.spriteNode.catrobatColor = 0.0

        brick.color = Formula(integer: 230)

        let action: () -> Void = brick.actionBlock(formulaInterpreter!)
        action()

        XCTAssertEqual(30.0, spriteNode.catrobatColor, accuracy: 0.1, "SetColorBrick - Color not correct")
        Project.removeProjectFromDisk(withProjectName: project.header.programName, projectID: project.header.programID)
    }

    func testSetColorBrickWrongInput() {
        let object = SpriteObject()
        let project = Project.defaultProject(withName: "a", projectID: "")
        let spriteNode = CBSpriteNode(spriteObject: object)
        object.spriteNode = spriteNode
        object.project = project

        let bundle = Bundle(for: SetColorBrickTests.self)
        let filePath = bundle.path(forResource: "test.png", ofType: nil)
        let imageData: Data? = UIImage(contentsOfFile: filePath ?? "")!.pngData()
        let look = Look(name: "test", andPath: "test.png")
        try? imageData?.write(to: URL(fileURLWithPath: "\(object.projectPath()!)images/\("test.png")"), options: [.atomic])

        let script = WhenScript()
        script.object = object

        let brick = SetColorBrick()
        brick.script = script
        object.lookList.add(look as Any)
        object.lookList.add(look as Any)
        object.spriteNode.currentLook = look
        object.spriteNode.currentUIImageLook = UIImage(contentsOfFile: filePath ?? "")

        brick.color = Formula(string: "a")

        let action: () -> Void = brick.actionBlock(formulaInterpreter!)
        action()

        XCTAssertEqual(0.0, spriteNode.catrobatColor, accuracy: 0.1, "SetColorBrick - Color not correct")
        Project.removeProjectFromDisk(withProjectName: project.header.programName, projectID: project.header.programID)
    }
}
