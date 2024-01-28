/**
 *  Copyright (C) 2010-2024 The Catrobat Team
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
        project.scenes[0] = scene
        scene.project = project
        let look = Look(name: "testLook", filePath: "testLookFile")
        let expectedPath = project.projectPath() + "testScene/images/testLookFile"
        XCTAssertEqual(expectedPath, look.path(for: scene))
    }

    func testPathForTwoScenes() {
        let project = Project()
        let scene = Scene(name: "testScene")
        project.scenes[0] = scene
        scene.project = project
        let look = Look(name: "testLook", filePath: "testLookFile")
        let expectedPath = project.projectPath() + "testScene/images/testLookFile"
        XCTAssertEqual(expectedPath, look.path(for: scene))

        let scene2 = Scene(name: "testScene2")
        project.scenes[1] = scene2
        scene2.project = project
        let look2 = Look(name: "testLook2", filePath: "testLookFile2")
        let expectedPath2 = project.projectPath() + "testScene2/images/testLookFile2"
        XCTAssertEqual(expectedPath2, look2.path(for: scene2))
    }

    func testIsEqual() {
        let project = Project()
        let scene = Scene(name: "testScene")
        project.scenes[0] = scene
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
        let project = ProjectManager.shared.createProject(name: "a", projectId: "1")
        object.scene = (project.scenes[0] as! Scene)
        let spriteNode = CBSpriteNode.init(spriteObject: object)
        object.spriteNode = spriteNode

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
        let project = ProjectManager.shared.createProject(name: "a", projectId: "1")
        object.scene = (project.scenes[0] as! Scene)
        let spriteNode = CBSpriteNode.init(spriteObject: object)
        object.spriteNode = spriteNode

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
