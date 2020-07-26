/**
 *  Copyright (C) 2010-2020 The Catrobat Team
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

class SpriteObjectTest: XCTestCase {

    var objectA: SpriteObject!
    var objectB: SpriteObject!

    override func setUp() {
        self.objectA = SpriteObject()
        objectA.name = "object"

        self.objectB = SpriteObject()
        objectB.name = "object"
    }

    func testIsEqualForDifferentName() {
        objectB.name = "objectB"

        XCTAssertFalse(objectA.isEqual(to: objectB))
    }

    func testIsEqualForDifferentNumberOfLooks() {
        let look1 = Look(name: "testLook1", andPath: "testPath1")!
        objectB.lookList.add(look1)
        XCTAssertFalse(objectA.isEqual(to: objectB))

        let look2 = Look(name: "testLook2", andPath: "testPath2")!
        objectA.lookList.add(look2)
        XCTAssertFalse(objectA.isEqual(to: objectB))

        objectA.lookList.add(look1)
        objectB.lookList.add(look2)
        XCTAssertFalse(objectA.isEqual(to: objectB))

        objectB.lookList.removeAllObjects()
        objectA.lookList.removeAllObjects()
        objectA.lookList.add(look1)
        objectB.lookList.add(look1)
        XCTAssertTrue(objectA.isEqual(to: objectB))
    }

    func testIsEqualForSound() {
        let sound1 = Sound(name: "testSound1", fileName: "testPath1")
        objectB.soundList.add(sound1)
        XCTAssertFalse(objectA.isEqual(to: objectB))

        let sound2 = Sound(name: "testSound2", fileName: "testPath2")
        objectA.soundList.add(sound2)
        XCTAssertFalse(objectA.isEqual(to: objectB))

        objectA.soundList.add(sound1)
        objectB.soundList.add(sound2)
        XCTAssertFalse(objectA.isEqual(to: objectB))

        objectB.soundList.removeAllObjects()
        objectA.soundList.removeAllObjects()
        objectA.soundList.add(sound1)
        objectB.soundList.add(sound1)
        XCTAssertTrue(objectA.isEqual(to: objectB))
    }

    func testIsEqualForScript() {
        let script1 = Script()
        objectB.scriptList.add(script1)
        XCTAssertFalse(objectA.isEqual(to: objectB))

        let object = SpriteObject()
        object.name = "object"

        let script2 = Script()
        script2.object = object
        objectA.scriptList.add(script2)
        XCTAssertFalse(objectA.isEqual(to: objectB))

        objectB.scriptList.add(script2)
        objectA.scriptList.add(script1)
        XCTAssertFalse(objectA.isEqual(to: objectB))

        objectB.scriptList.removeAllObjects()
        objectA.scriptList.removeAllObjects()
        objectA.scriptList.add(script2)
        objectB.scriptList.add(script2)
        XCTAssertTrue(objectA.isEqual(to: objectB))
    }

    func testIsEqualForUserDataContainer() {
        let list = UserList(name: "testList")
        let variable = UserVariable(name: "testvariable")

        let container1 = UserDataContainer()
        container1.addList(list)

        let container2 = UserDataContainer()
        container2.addVariable(variable)

        objectB.userData = container1
        objectA.userData = container2
        XCTAssertFalse(objectA.isEqual(to: objectB))

        container1.addVariable(variable)
        container2.addList(list)
        XCTAssertTrue(objectA.isEqual(to: objectB))
    }

}
