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

final class LookTest: XCTestCase {

    func testPathForScene() {
        let project = Project()
        let scene = Scene(name: "testScene")
        project.scene = scene
        scene.project = project

        let look = Look(name: "testLook", filePath: "testLookFile")

        let expectedPath = project.projectPath() + "testScene/images/testLookFile"
        XCTAssertEqual(expectedPath, look.path(for: scene))
    }

    func testIsEqual() {
        let project = Project()
        let scene = Scene(name: "testScene")
        project.scene = scene
        scene.project = project

        let look = Look(name: "testLook", filePath: "testLookFile")
        let equalLook = Look(name: "testLook", filePath: "testLookFile")

        XCTAssertTrue(look.isEqual(equalLook))
    }

    func testMutableCopyWithContext() {
        let look = Look(name: "testLook", filePath: "testLookFile")
        let context = CBMutableCopyContext()

        let lookCopy = look.mutableCopy(with: context) as! Look

        XCTAssertEqual(look.name, lookCopy.name)
        XCTAssertFalse(look === lookCopy)
        XCTAssertEqual(look.fileName, lookCopy.fileName)
    }

    func testInitWithPath() {
        let object = SpriteObject()
        let project = ProjectManager.createProject(name: "a", projectId: "1")
        object.scene = project.scene
        let spriteNode = CBSpriteNode.init(spriteObject: object)
        object.spriteNode = spriteNode
        object.scene.project = project

        let bundle = Bundle(for: type(of: self))
        let param = "test.png"
        let filePath = bundle.path(forResource: param, ofType: nil)
        let look = Look.init(name: "", filePath: filePath!)

        XCTAssertNotNil(look)
        XCTAssertFalse(look.fileName.isEmpty)
        XCTAssertEqual(look.fileName, filePath)
        XCTAssertEqual(String(look.fileName.split(separator: "/").last!), param)
    }

    func testInitWithName() {
        let object = SpriteObject()
        let project = ProjectManager.createProject(name: "a", projectId: "1")
        object.scene = project.scene
        let spriteNode = CBSpriteNode.init(spriteObject: object)
        object.spriteNode = spriteNode
        object.scene.project = project

        let bundle = Bundle(for: type(of: self))
        let param1 = "test.png"
        let filePath = bundle.path(forResource: param1, ofType: nil)
        let param2 = "testLook"
        let look = Look.init(name: param2, filePath: filePath!)

        XCTAssertNotNil(look)
        XCTAssertFalse(look.fileName.isEmpty)
        XCTAssertEqual(look.fileName, filePath)
        XCTAssertEqual(String(look.fileName.split(separator: "/").last!), param1)
        XCTAssertFalse(look.name.isEmpty)
        XCTAssertEqual(look.name, param2)

    }

}
