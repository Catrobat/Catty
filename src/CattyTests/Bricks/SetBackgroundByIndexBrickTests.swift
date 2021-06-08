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

final class SetBackgroundByIndexBrickTest: XCTestCase {

    var project: Project!
    var spriteObject: SpriteObject!
    var spriteNode: CBSpriteNode!
    var script: Script!
    var brick: SetBackgroundByIndexBrick!
    var formulaInterpreter: FormulaInterpreterProtocol!

    var look: Look!
    var look2: Look!
    var look3: Look!
    var look4: Look!

    override func setUp() {
        project = ProjectManager.createProject(name: "setBackgroundByIndexTest", projectId: "1")
        spriteObject = project.scene.object(at: 0)
        spriteObject.scene = project.scene
        spriteObject.name = "SpriteObjectName"

        spriteNode = CBSpriteNode(spriteObject: spriteObject)
        spriteObject.spriteNode = spriteNode

        script = Script()
        script.object = spriteObject

        formulaInterpreter = FormulaManager(stageSize: Util.screenSize(true), landscapeMode: false)

        let bundle = Bundle(for: type(of: self))
        let filePath = bundle.path(forResource: "test.png", ofType: nil)
        let imageData = UIImage(contentsOfFile: filePath!)!.pngData()

        do {
            look = Look(name: "test", filePath: "test.png")
            try imageData?.write(to: URL(fileURLWithPath: spriteObject.scene.imagesPath()! + "/test.png"))
            look2 = Look(name: "test2", filePath: "test2.png")
            try imageData?.write(to: URL(fileURLWithPath: spriteObject.scene.imagesPath()! + "/test2.png"))
            look3 = Look(name: "test3", filePath: "test3.png")
            try imageData?.write(to: URL(fileURLWithPath: spriteObject.scene.imagesPath()! + "/test3.png"))
            look4 = Look(name: "test4", filePath: "invalid.png")
        } catch {
            XCTFail("Error when writing image data")
        }

        brick = SetBackgroundByIndexBrick()
        brick.script = script

        spriteObject.lookList.add(look!)
        spriteObject.lookList.add(look2!)
        spriteObject.lookList.add(look3!)
        spriteObject.spriteNode.currentLook = look
        spriteObject.spriteNode.currentUIImageLook = UIImage(contentsOfFile: filePath!)
    }

    func testSetLookByValidIndex() {
        let imageCacheMock = RuntimeImageCacheMock(imagesOnDisk: [:], cachedImages: [])
        brick.backgroundIndex = Formula(integer: 3)

        var action = brick.actionBlock(formulaInterpreter: formulaInterpreter, imageCache: imageCacheMock)
        action()
        XCTAssertEqual(spriteNode.currentLook, look3, "setBackgroundByIndex look was not set correctly")

        brick.backgroundIndex = Formula(integer: 2)
        action = brick.actionBlock(formulaInterpreter: formulaInterpreter, imageCache: imageCacheMock)
        action()
        XCTAssertEqual(spriteNode.currentLook, look2, "setBackgroundByIndex look was not set correctly")

        brick.backgroundIndex = Formula(integer: 1)
        action = brick.actionBlock(formulaInterpreter: formulaInterpreter, imageCache: imageCacheMock)
        action()
        XCTAssertEqual(spriteNode.currentLook, look, "setBackgroundByIndex look was not set correctly")
    }

    func testSetLookByInvalidIndex() {
        let imageCacheMock = RuntimeImageCacheMock(imagesOnDisk: [:], cachedImages: [])
        brick.backgroundIndex = Formula(integer: 3)

        var action = brick.actionBlock(formulaInterpreter: formulaInterpreter, imageCache: imageCacheMock)
        action()
        XCTAssertEqual(spriteNode.currentLook, look3, "setBackgroundByIndex look was not set correctly")

        brick.backgroundIndex = Formula(integer: 0)
        action = brick.actionBlock(formulaInterpreter: formulaInterpreter, imageCache: imageCacheMock)
        action()
        XCTAssertEqual(spriteNode.currentLook, look3, "setBackgroundByIndex look was not set correctly")

        brick.backgroundIndex = Formula(integer: 5)
        action = brick.actionBlock(formulaInterpreter: formulaInterpreter, imageCache: imageCacheMock)
        action()
        XCTAssertEqual(spriteNode.currentLook, look3, "setBackgroundByIndex look was not set correctly")
    }

    func testSetLookByInvalidImagePath() {
        let imageCacheMock = RuntimeImageCacheMock(imagesOnDisk: [:], cachedImages: [])
        brick.backgroundIndex = Formula(integer: 3)

        var action = brick.actionBlock(formulaInterpreter: formulaInterpreter, imageCache: imageCacheMock)
        action()
        XCTAssertEqual(spriteNode.currentLook, look3, "setBackgroundByIndex look was not set correctly")

        brick.backgroundIndex = Formula(integer: 4)
        action = brick.actionBlock(formulaInterpreter: formulaInterpreter, imageCache: imageCacheMock)
        action()
        XCTAssertEqual(spriteNode.currentLook, look3, "setBackgroundByIndex look was not set correctly")
    }

    func testMutableCopy() {
        let brick = SetBackgroundByIndexBrick()

        let copiedBrick: SetBackgroundByIndexBrick = brick.mutableCopy(with: CBMutableCopyContext(), andErrorReporting: true) as! SetBackgroundByIndexBrick

        XCTAssertTrue(brick.isEqual(to: copiedBrick))
        XCTAssertFalse(brick === copiedBrick)
    }
}
