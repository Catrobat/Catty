/**
 *  Copyright (C) 2010-2022 The Catrobat Team
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

final class PreviousLookBrickTests: AbstractBrickTest {

    var lookA: Look!
    var lookB: Look!
    var lookC: Look!
    var image: UIImage!

    var scene: Scene!
    var spriteNode: CBSpriteNode!
    var script: Script!

    override func setUp() {
        super.setUp()

        let filePath = Bundle(for: type(of: self)).path(forResource: "test.png", ofType: nil)!
        image = UIImage(contentsOfFile: filePath)

        lookA = LookMock(name: "LookA", absolutePath: filePath)
        lookB = LookMock(name: "LookB", absolutePath: filePath)
        lookC = LookMock(name: "LookC", absolutePath: filePath)
        scene = Scene(name: "scene")

        scene.project = Project()

        let backgroundObject = SpriteObject()
        scene.add(object: backgroundObject)

        spriteNode = CBSpriteNode(spriteObject: backgroundObject)
        backgroundObject.spriteNode = spriteNode

        script = Script()
        script.object = backgroundObject
    }

    func testPreviousLookBrickWithCache() {
        let imageCacheMock = RuntimeImageCacheMock(imagesOnDisk: [:],
                                                   cachedImages: [CachedImage(path: lookB.path(for: scene)!, image: image)])

        script.object.lookList.add(lookA!)
        script.object.lookList.add(lookB!)
        script.object.lookList.add(lookC!)

        let brick = PreviousLookBrick()
        brick.script = script
        spriteNode.currentLook = lookA

        XCTAssertEqual(spriteNode.currentLook, lookA, "Current look should be lookA")

        let action = brick.actionBlock(imageCache: imageCacheMock)
        action()

        XCTAssertEqual(spriteNode.currentLook, lookC, "PreviousLookBrick not correct")
        XCTAssertEqual(0, imageCacheMock.loadImageFromDiskCalledPaths.count)
    }

    func testPreviousLookBrickWithoutCache() {
        let imageCacheMock = RuntimeImageCacheMock(imagesOnDisk: [lookB.path(for: scene)!: image],
                                                   cachedImages: [])

        script.object.lookList.add(lookA!)
        script.object.lookList.add(lookB!)
        script.object.lookList.add(lookC!)

        let brick = PreviousLookBrick()
        brick.script = script
        spriteNode.currentLook = lookA

        XCTAssertEqual(spriteNode.currentLook, lookA, "Current look should be lookA")

        let action = brick.actionBlock(imageCache: imageCacheMock)
        action()

        XCTAssertEqual(spriteNode.currentLook, lookC, "PreviousLookBrick not correct")
        XCTAssertEqual(1, imageCacheMock.loadImageFromDiskCalledPaths.count)
        XCTAssertEqual(lookB.path(for: scene), imageCacheMock.loadImageFromDiskCalledPaths.first!)
    }

    func testPreviousLookBrickWithOneLook() {
        let imageCacheMock = RuntimeImageCacheMock(imagesOnDisk: [lookB.path(for: scene)!: image],
                                                   cachedImages: [])

        script.object.lookList.add(lookA!)

        let brick = PreviousLookBrick()
        brick.script = script
        spriteNode.currentLook = lookA

        XCTAssertEqual(spriteNode.currentLook, lookA, "Current look should be lookA")

        let action = brick.actionBlock(imageCache: imageCacheMock)
        action()

        XCTAssertEqual(spriteNode.currentLook, lookA, "Current look should be lookA")
    }

    func testPreviousLookBrickWithNoLook() {
        let imageCacheMock = RuntimeImageCacheMock(imagesOnDisk: [lookB.path(for: scene)!: image],
                                                   cachedImages: [])

        let brick = PreviousLookBrick()
        brick.script = script

        XCTAssertNil(spriteNode.currentLook)

        let action = brick.actionBlock(imageCache: imageCacheMock)
        action()

        XCTAssertNil(spriteNode.currentLook)
    }

    func testMutableCopy() {
          let brick = PreviousLookBrick()
          let script = Script()
          let object = SpriteObject()
          let scene = Scene(name: "testScene")
          object.scene = scene

          script.object = object
          brick.script = script

          let copiedBrick: PreviousLookBrick = brick.mutableCopy(with: CBMutableCopyContext(), andErrorReporting: true) as! PreviousLookBrick

          XCTAssertTrue(brick.isEqual(to: copiedBrick))
          XCTAssertFalse(brick === copiedBrick)
      }
}
