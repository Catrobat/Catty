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

final class SceneTest: XCTestCase {

    var scene: Scene!

    override func setUp() {
        super.setUp()
        scene = Scene(name: "testScene")
    }

    func testName() {
        XCTAssertEqual("testScene", scene.name)
    }

    func testCount() {
        XCTAssertEqual(0, scene.count)

        let object = SpriteObject()
        scene.add(object: object)

        XCTAssertEqual(1, scene.count)
    }

    func testNumberOfBackgroundObjects() {
        XCTAssertEqual(0, scene.numberOfBackgroundObjects())

        let object1 = SpriteObject()
        scene.add(object: object1)
        XCTAssertEqual(1, scene.numberOfBackgroundObjects())

        let object2 = SpriteObject()
        scene.add(object: object2)
        XCTAssertEqual(1, scene.numberOfBackgroundObjects())
    }

    func testNumberOfNormalObjects() {
        XCTAssertEqual(0, scene.numberOfNormalObjects())

        let object1 = SpriteObject()
        scene.add(object: object1)
        XCTAssertEqual(0, scene.numberOfNormalObjects())

        let object2 = SpriteObject()
        scene.add(object: object2)
        XCTAssertEqual(1, scene.numberOfNormalObjects())
    }

    func testAddObject() {
        let object = SpriteObject()
        object.name = "testObject"

        XCTAssertEqual(0, scene.objects().count)

        scene.add(object: object)

        XCTAssertEqual(1, scene.objects().count)
        XCTAssertEqual("testObject", scene.objects()[0].name)
    }

    func testInsertObject() {
        let object1 = SpriteObject()
        object1.name = "testObject1"

        let object2 = SpriteObject()
        object2.name = "testObject2"

        XCTAssertEqual(0, scene.objects().count)

        scene.add(object: object1)
        XCTAssertEqual(1, scene.objects().count)

        scene.insert(object: object2, at: 5)
        XCTAssertEqual(1, scene.objects().count)

        scene.insert(object: object2, at: 1)
        XCTAssertEqual(2, scene.objects().count)
    }

    func testRemoveObjectAtIndex() {
        let object1 = SpriteObject()
        object1.name = "testObject1"

        let object2 = SpriteObject()
        object2.name = "testObject2"

        XCTAssertEqual(0, scene.objects().count)

        scene.add(object: object1)
        scene.add(object: object2)
        XCTAssertEqual(2, scene.objects().count)

        scene.removeObject(at: 5)
        XCTAssertEqual(2, scene.objects().count)

        scene.removeObject(at: 0)
        XCTAssertEqual(1, scene.objects().count)
        XCTAssertEqual("testObject2", scene.objects()[0].name)
    }

    func testRemoveObject() {
        let object1 = SpriteObject()
        object1.name = "testObject1"
        scene.add(object: object1)

        let object2 = SpriteObject()
        object2.name = "testObject2"
        scene.add(object: object2)

        let object3 = SpriteObject()
        object3.name = "testObject3"
        scene.add(object: object3)

        XCTAssertEqual(3, scene.objects().count)

        scene.removeObject(object2)
        XCTAssertEqual(2, scene.objects().count)
        XCTAssertEqual(object1, scene.objects()[0])
        XCTAssertEqual(object3, scene.objects()[1])
    }

    func testObjectExists() {
        let object1 = SpriteObject()
        object1.name = "testObject1"

        let object2 = SpriteObject()
        object2.name = "testObject2"

        XCTAssertFalse(scene.objectExists(withName: "testObject1"))
        XCTAssertFalse(scene.objectExists(withName: "testObject2"))

        scene.add(object: object1)
        XCTAssertTrue(scene.objectExists(withName: "testObject1"))
        XCTAssertFalse(scene.objectExists(withName: "testObject2"))

        scene.add(object: object2)
        XCTAssertTrue(scene.objectExists(withName: "testObject1"))
        XCTAssertTrue(scene.objectExists(withName: "testObject2"))
    }

    func testhasObject() {
        let object1 = SpriteObject()
        object1.name = "testObject1"

        let object2 = SpriteObject()
        object2.name = "testObject2"

        XCTAssertFalse(scene.hasObject(object1))
        XCTAssertFalse(scene.hasObject(object2))

        scene.add(object: object1)
        XCTAssertTrue(scene.hasObject(object1))
        XCTAssertFalse(scene.hasObject(object2))

        scene.add(object: object2)
        XCTAssertTrue(scene.hasObject(object1))
        XCTAssertTrue(scene.hasObject(object2))
    }

    func testRenameObject() {
        let object1 = SpriteObject()
        object1.name = "testObject1"

        let object2 = SpriteObject()
        object2.name = "testObject2"

        scene.add(object: object1)

        scene.renameObject(object1, toName: "testObject")
        XCTAssertEqual("testObject", object1.name)

        scene.renameObject(object2, toName: "testObject1")
        XCTAssertEqual("testObject2", object2.name)
    }

    func testCopyObject() {
        let object1 = SpriteObject()
        object1.name = "testObject1"

        var copyObject = scene.copy(object1, withNameForCopiedObject: "testObject")

        XCTAssertEqual(0, scene.count)
        XCTAssertNil(copyObject)

        scene.add(object: object1)
        XCTAssertEqual(1, scene.count)

        copyObject = scene.copy(object1, withNameForCopiedObject: "testObject")

        XCTAssertEqual(2, scene.count)
        XCTAssertEqual(object1, scene.objects()[0])
        XCTAssertEqual(copyObject, scene.objects()[1])
        XCTAssertEqual(copyObject?.name, "testObject")
    }

    func testImagesPath() {
        let project = Project()
        let expectedPath = project.projectPath() + scene.name + "/\(kProjectImagesDirName)"

        XCTAssertNil(scene.imagesPath())

        scene.project = project
        XCTAssertEqual(expectedPath, scene.imagesPath())
    }

    func testSoundsPath() {
        let project = Project()
        let expectedPath = project.projectPath() + scene.name + "/\(kProjectSoundsDirName)"

        XCTAssertNil(scene.soundsPath())

        scene.project = project
        XCTAssertEqual(expectedPath, scene.soundsPath())
    }

    func testIsEqual() {
        let newScene = Scene(name: "newTestScene")

        XCTAssertFalse(scene.isEqual(newScene))

        let object = SpriteObject()
        object.name = "testObject"

        newScene.name = "testScene"
        newScene.add(object: object)
        XCTAssertFalse(scene.isEqual(newScene))

        scene.add(object: object)
        XCTAssertTrue(scene.isEqual(newScene))
    }

    func testMutableCopy() {
        let object = SpriteObject()
        object.name = "testObject"

        scene.add(object: object)
        let copyScene = scene.mutableCopy(with: CBMutableCopyContext()) as! Scene

        XCTAssertTrue(scene.isEqual(copyScene))
        XCTAssertFalse(copyScene === scene)
    }

    func testCopyObjects() {
        let object1 = SpriteObject()
        object1.name = "testObject1"
        scene.add(object: object1)

        let object2 = SpriteObject()
        object2.name = "testObject2"
        scene.add(object: object2)

        let objectsBefore = scene.count
        let objectsList = scene.copyObjects([object1, object2])
        XCTAssertEqual(objectsBefore * 2, scene.count)
        XCTAssertEqual("testObject1 (1)", objectsList[0].name)
        XCTAssertEqual("testObject2 (1)", objectsList[1].name)
    }
}
