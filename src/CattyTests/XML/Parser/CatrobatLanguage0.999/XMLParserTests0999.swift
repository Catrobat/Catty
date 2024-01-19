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

class XMLParserTests0999: XMLAbstractTest {
    var formulaManager: FormulaManager!

    override func setUp() {
        super.setUp()
        formulaManager = FormulaManager(stageSize: Util.screenSize(true), landscapeMode: false)
    }

    func testAllBricks() {
        let project = self.getProjectForXML(xmlFile: "ValidProjectAllBricks0999")
        XCTAssertEqual(0, project.unsupportedElements.count)
    }

    func testAllFunctions() {
        let project = self.getProjectForXML(xmlFile: "Functions_0999")
        XCTAssertEqual(0, project.unsupportedElements.count)
    }

    func testAllSensors() {
        let project = self.getProjectForXML(xmlFile: "Sensors_0999")
        XCTAssertEqual(0, project.unsupportedElements.count)
    }

    func testSetPenColorBrick() {
        let project = self.getProjectForXML(xmlFile: "ValidProjectAllBricks0999")
        let setPenColorBrick = (project.scene.object(at: 0)!.scriptList.object(at: 0) as! Script).brickList.object(at: 46) as! Brick

        XCTAssertEqual(0, project.unsupportedElements.count)
        XCTAssertTrue(setPenColorBrick.isKind(of: SetPenColorBrick.self), "Invalid brick type")

        let castedBrick = setPenColorBrick as! SetPenColorBrick
        XCTAssertTrue(castedBrick.red!.isEqual(to: Formula(integer: 0)))
        XCTAssertTrue(castedBrick.blue!.isEqual(to: Formula(integer: 255)))
        XCTAssertTrue(castedBrick.green!.isEqual(to: Formula(integer: 0)))
    }

    func testGlideToBrick() {
        let project = self.getProjectForXML(xmlFile: "ValidProjectAllBricks0998")
        let glideToBrick = (project.scene.object(at: 0)!.scriptList.object(at: 0) as! Script).brickList.object(at: 10) as! Brick

        XCTAssertEqual(0, project.unsupportedElements.count)
        XCTAssertTrue(glideToBrick.isKind(of: GlideToBrick.self), "Invalid brick type")

        let castedBrick = glideToBrick as! GlideToBrick
        XCTAssertTrue(castedBrick.xDestination.isEqual(to: Formula(integer: 100)), "Invalid formula")
        XCTAssertTrue(castedBrick.yDestination.isEqual(to: Formula(integer: 200)), "Invalid formula")
        XCTAssertEqual("1.0", castedBrick.durationInSeconds.formulaTree.value, "Invalid formula")
    }

    func testThinkForBubbleBrick() {
        let project = self.getProjectForXML(xmlFile: "ValidProjectAllBricks0998")
        let thinkForBubbleBrick = (project.scene.object(at: 0)!.scriptList.object(at: 0) as! Script).brickList.object(at: 37) as! Brick

        XCTAssertEqual(0, project.unsupportedElements.count)
        XCTAssertTrue(thinkForBubbleBrick.isKind(of: ThinkForBubbleBrick.self), "Invalid brick type")

        let castedBrick = thinkForBubbleBrick as! ThinkForBubbleBrick
        XCTAssertTrue(castedBrick.stringFormula.isEqual(to: Formula(string: kLocalizedHmmmm)), "Invalid formula")
        XCTAssertEqual("1.0", castedBrick.intFormula.formulaTree.value, "Invalid formula")
    }

    func testInsertItemIntoUserListBrick() {
        let project = self.getProjectForXML(xmlFile: "ValidProjectAllBricks0998")
        let insertItemIntoUserListBrick = (project.scene.object(at: 0)!.scriptList.object(at: 0) as! Script).brickList.object(at: 49) as! Brick

        let castedBrick = insertItemIntoUserListBrick as! InsertItemIntoUserListBrick
        XCTAssertTrue(castedBrick.index.isEqual(to: Formula(integer: 2)), "Invalid formula")
        XCTAssertTrue(castedBrick.elementFormula.isEqual(to: Formula(string: "hello")), "Invalid formula")
    }
}
