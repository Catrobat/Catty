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

class XMLParserTests092: XMLAbstractTest {

    func testConvertUnsupportedBrickToNoteBrick() {
        let project = getProjectForXML(xmlFile: "InvalidBricksAndScripts")
        XCTAssertNotNil(project, "Project should not be nil")
        XCTAssertEqual(1, project.objectList.count)

        let object = project.objectList[0] as! SpriteObject
        XCTAssertEqual(3, object.scriptList.count)

        let startScript = object.scriptList[0] as! StartScript
        XCTAssertEqual(3, startScript.brickList.count)

        let waitBrick = startScript.brickList[0] as AnyObject
        XCTAssertTrue(waitBrick.isKind(of: WaitBrick.self))

        let unknownBrick = startScript.brickList[1] as AnyObject
        XCTAssertTrue(unknownBrick.isKind(of: NoteBrick.self))

        let noteBrick = unknownBrick as! NoteBrick
        XCTAssertTrue(noteBrick.note.starts(with: kLocalizedUnsupportedBrick))
    }

    func testConvertUnsupportedScriptToBroadcastBrick() {
        let project = getProjectForXML(xmlFile: "InvalidBricksAndScripts")
        XCTAssertNotNil(project, "Project should not be nil")
        XCTAssertEqual(1, project.objectList.count)

        let object = project.objectList[0] as! SpriteObject
        XCTAssertEqual(3, object.scriptList.count)

        let unknownScript = object.scriptList[1] as AnyObject
        XCTAssertTrue(unknownScript.isKind(of: BroadcastScript.self))

        let broadcastScript = unknownScript as! BroadcastScript
        XCTAssertEqual(1, broadcastScript.brickList.count)
        XCTAssertTrue(broadcastScript.receivedMessage.starts(with: kLocalizedUnsupportedScript))

        let secondWaitBrick = broadcastScript.brickList[0] as AnyObject
        XCTAssertTrue(secondWaitBrick.isKind(of: WaitBrick.self))
    }

    func testUnsupportedElements() {
        let project = self.getProjectForXML(xmlFile: "InvalidBricksAndScripts")

        XCTAssertEqual(2, project.unsupportedElements.count)
        XCTAssertTrue(project.unsupportedElements.contains("InvalidScript"))
        XCTAssertTrue(project.unsupportedElements.contains("InvalidBrick"))
    }
}
