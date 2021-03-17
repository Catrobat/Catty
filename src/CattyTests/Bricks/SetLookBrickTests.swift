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

final class SetLookBrickTests: AbstractBrickTest {

    var lookA: Look!
    var lookB: Look!
    var image: UIImage!

    var scene: Scene!
    var object: SpriteObject!
    var spriteNode: CBSpriteNode!
    var script: Script!
    var context: CBScriptContextProtocol!

    override func setUp() {
        super.setUp()

        let filePath = Bundle(for: type(of: self)).path(forResource: "test.png", ofType: nil)!
        image = UIImage(contentsOfFile: filePath)

        lookA = LookMock(name: "LookA", absolutePath: filePath)
        lookB = LookMock(name: "LookB", absolutePath: filePath)
        scene = Scene(name: "scene")

        scene.project = Project()

        object = SpriteObject()
        scene.add(object: object)

        object.lookList.add(lookA!)
        object.lookList.add(lookB!)

        spriteNode = CBSpriteNode(spriteObject: object)
        object.spriteNode = spriteNode

        script = Script()
        script.object = object

        context = CBScriptContext(script: script, spriteNode: spriteNode, formulaInterpreter: formulaInterpreter, touchManager: formulaInterpreter.touchManager)
    }

    func testMutableCopy() {
        let brick = SetLookBrick()
        let look = Look(name: "lookToCopy", filePath: "look")
        brick.look = look

        let copiedBrick: SetLookBrick = brick.mutableCopy(with: CBMutableCopyContext()) as! SetLookBrick

        XCTAssertTrue(brick.isEqual(to: copiedBrick))
        XCTAssertFalse(brick === copiedBrick)
        XCTAssertTrue(brick.look!.isEqual(copiedBrick.look))
        XCTAssertTrue(copiedBrick.look === brick.look)
    }

    func testInstructionWithCache() {
        let imageCacheMock = RuntimeImageCacheMock(imagesOnDisk: [:],
                                                   cachedImages: [CachedImage(path: lookB.path(for: scene)!, image: image)])

        let brick = SetLookBrick()
        brick.script = script
        brick.look = lookB

        spriteNode.currentLook = lookA

        let instruction = brick.actionBlock(imageCache: imageCacheMock)
        instruction()

        XCTAssertEqual(lookB, spriteNode.currentLook)
        XCTAssertEqual(0, imageCacheMock.loadImageFromDiskCalledPaths.count)
    }

    func testInstructionWithoutCache() {
        let imageCacheMock = RuntimeImageCacheMock(imagesOnDisk: [lookB.path(for: scene)!: image],
                                                   cachedImages: [])

        let brick = SetLookBrick()
        brick.script = script
        brick.look = lookB

        spriteNode.currentLook = lookA

        let instruction = brick.actionBlock(imageCache: imageCacheMock)
        instruction()

        XCTAssertEqual(lookB, spriteNode.currentLook)
        XCTAssertEqual(1, imageCacheMock.loadImageFromDiskCalledPaths.count)
        XCTAssertEqual(lookB.path(for: scene), imageCacheMock.loadImageFromDiskCalledPaths.first!)
    }

    func testInstructionWithoutLook() {
        let imageCacheMock = RuntimeImageCacheMock(imagesOnDisk: [lookB.path(for: scene)!: image],
                                                   cachedImages: [])

        let brick = SetLookBrick()
        brick.script = script
        brick.look = nil

        spriteNode.currentLook = lookA

        let instruction = brick.actionBlock(imageCache: imageCacheMock)
        instruction()

        XCTAssertEqual(lookA, spriteNode.currentLook)
        XCTAssertEqual(0, imageCacheMock.loadImageFromDiskCalledPaths.count)
    }

    func testInstructionInvalidImage() {
        let imageCacheMock = RuntimeImageCacheMock(imagesOnDisk: [:], cachedImages: [])
        let lookWithInvalidPath = LookMock(name: "LookWithInvalidPath", absolutePath: "invalidPath")

        let brick = SetLookBrick()
        brick.script = script
        brick.look = lookWithInvalidPath

        spriteNode.currentLook = lookA

        let instruction = brick.actionBlock(imageCache: imageCacheMock)
        instruction()

        XCTAssertEqual(lookA, spriteNode.currentLook)
        XCTAssertEqual(1, imageCacheMock.loadImageFromDiskCalledPaths.count)
        XCTAssertEqual(lookWithInvalidPath.path(for: scene), imageCacheMock.loadImageFromDiskCalledPaths.first!)
    }

    func testIsEqualReturnTrue() {
        let brick1 = SetLookBrick()
        brick1.look = lookA

        let brick2 = SetLookBrick()
        brick2.look = lookA

        XCTAssertTrue(brick1.isEqual(to: brick2))
    }

    func testIsEqualReturnFalse() {
        let brick1 = SetLookBrick()
        brick1.look = lookA

        let brick2 = SetBackgroundBrick()
        brick2.look = lookA

        XCTAssertFalse(brick1.isEqual(to: brick2))
    }
}
