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

class XMLParserTests09993: XMLAbstractTest {
    var formulaManager: FormulaManager!

    override func setUp() {
        super.setUp()
        formulaManager = FormulaManager(stageSize: Util.screenSize(true), landscapeMode: false)
    }

    func testAllBricks() {
        let project = self.getProjectForXML(xmlFile: "ValidProjectAllBricks09993")
        XCTAssertEqual(0, project.unsupportedElements.count)
    }

    func testAllFunctions() {
        let project = self.getProjectForXML(xmlFile: "Functions_09993")
        XCTAssertEqual(0, project.unsupportedElements.count)
    }

    func testAllSensors() {
        let project = self.getProjectForXML(xmlFile: "Sensors_09993")
        XCTAssertEqual(0, project.unsupportedElements.count)
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

    func testParseLocalLists() {
        let project = self.getProjectForXML(xmlFile: "UserLists_09993")
        let objects = project.scene.objects()
        XCTAssertEqual(3, objects.count)

        let backgroundObject = project.scene.object(at: 0)
        XCTAssertEqual("Background", backgroundObject?.name)

        let localLists = backgroundObject?.userData.lists()
        XCTAssertEqual(1, localLists?.count)
        XCTAssertEqual("localListBackground", localLists?[0].name)

        let object = project.scene.object(at: 1)
        XCTAssertEqual("Object1", object?.name)

        let localListsObject = object?.userData.lists()
        XCTAssertEqual(1, localListsObject?.count)
        XCTAssertEqual("localListObject1", localListsObject?[0].name)
    }

    func testParseGlobalLists() {
        let project = self.getProjectForXML(xmlFile: "UserLists_09993")
        let list = project.userData.lists()
        XCTAssertEqual(1, list.count)
        XCTAssertEqual("globalList", list.first?.name)
    }

    func testParseLocalVariables() {
        let project = self.getProjectForXML(xmlFile: "UserVariables_09993")
        let objects = project.scene.objects()
        XCTAssertEqual(3, objects.count)

        let backgroundObject = project.scene.object(at: 0)
        XCTAssertEqual("Background", backgroundObject?.name)

        let localVariables = backgroundObject?.userData.variables()
        XCTAssertEqual(2, localVariables?.count)
        XCTAssertEqual("localBackground", localVariables?[0].name)
        XCTAssertEqual("localBackground2", localVariables?[1].name)

        let object = project.scene.object(at: 1)
        XCTAssertEqual("A", object?.name)

        let localVariablesObject = object?.userData.variables()
        XCTAssertEqual(1, localVariablesObject?.count)
        XCTAssertEqual("localB", localVariablesObject?[0].name)
    }

    func testParseGlobalVariables() {
        let project = self.getProjectForXML(xmlFile: "UserVariables_09993")
        let variables = project.userData.variables()
        XCTAssertEqual(3, variables.count)
        XCTAssertEqual("global1", variables[0].name)
        XCTAssertEqual("global2", variables[1].name)
        XCTAssertEqual("global3", variables[2].name)
    }
}
