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

class XMLParserTests092: XMLAbstractTest {

    func testWhackAMole() {
        let project = getProjectForXML(xmlFile: "Whack_A_Mole_092")
        XCTAssertNotNil(project, "Project should not be nil")
        XCTAssertEqual(5, project.scene.objects().count)

        let object = project.scene.object(at: 1)!
        XCTAssertEqual(3, object.lookList.count)
        XCTAssertEqual(1, object.soundList.count)

        let firstLook = object.lookList.object(at: 0) as! Look
        XCTAssertEqual("Moving Mole", firstLook.name)
        XCTAssertEqual("06e01b636e184f82c05532292ace0de4_Moving Mole.png", firstLook.fileName)

        let secondLook = object.lookList.object(at: 1) as! Look
        XCTAssertEqual("Mole", secondLook.name)
        XCTAssertEqual("c1a4cf63f691c3e5db6239c2dff29ab3_Mole.png", secondLook.fileName)

        let sound = object.soundList.object(at: 0) as! Sound
        XCTAssertEqual("Hit", sound.name)
        XCTAssertEqual("6f231e6406d3554d691f3c9ffb37c043_Hit1.m4a", sound.fileName)

        XCTAssertEqual(2, object.scriptList.count)

        let startScript = object.scriptList[0] as! StartScript
        XCTAssertEqual(12, startScript.brickList.count)
    }
}
