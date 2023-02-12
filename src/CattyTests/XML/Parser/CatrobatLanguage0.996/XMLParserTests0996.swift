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

class XMLParserTests0996: XMLAbstractTest {
    var formulaManager: FormulaManager!

    override func setUp() {
        super.setUp()
        formulaManager = FormulaManager(stageSize: Util.screenSize(true), landscapeMode: false)
    }

    func testAllBricks() {
        let project = self.getProjectForXML(xmlFile: "ValidProjectAllBricks0996")
        XCTAssertEqual(0, project.unsupportedElements.count)
    }

    func testAllFunctions() {
        let project = self.getProjectForXML(xmlFile: "Functions_0996")
        XCTAssertEqual(0, project.unsupportedElements.count)
    }

    func testAllSensors() {
        let project = self.getProjectForXML(xmlFile: "Sensors_0996")
        XCTAssertEqual(0, project.unsupportedElements.count)
    }

    func testSetPenColorBrick() {
        let project = self.getProjectForXML(xmlFile: "ValidProjectAllBricks0996")
        let setPenColorBrick = (project.scene.object(at: 0)!.scriptList.object(at: 0) as! Script).brickList.object(at: 46) as! Brick

        XCTAssertEqual(0, project.unsupportedElements.count)
        XCTAssertTrue(setPenColorBrick.isKind(of: SetPenColorBrick.self), "Invalid brick type")

        let castedBrick = setPenColorBrick as! SetPenColorBrick
        XCTAssertTrue(castedBrick.red!.isEqual(to: Formula(integer: 0)))
        XCTAssertTrue(castedBrick.blue!.isEqual(to: Formula(integer: 255)))
        XCTAssertTrue(castedBrick.green!.isEqual(to: Formula(integer: 0)))
    }

    func testGlideToBrick() {
        let project = self.getProjectForXML(xmlFile: "ValidProjectAllBricks0996")
        let glideToBrick = (project.scene.object(at: 0)!.scriptList.object(at: 0) as! Script).brickList.object(at: 10) as! Brick

        XCTAssertEqual(0, project.unsupportedElements.count)
        XCTAssertTrue(glideToBrick.isKind(of: GlideToBrick.self), "Invalid brick type")

        let castedBrick = glideToBrick as! GlideToBrick
        XCTAssertTrue(castedBrick.xPosition.isEqual(to: Formula(integer: 100)), "Invalid formula")
        XCTAssertTrue(castedBrick.yPosition.isEqual(to: Formula(integer: 200)), "Invalid formula")
        XCTAssertEqual("1.0", castedBrick.durationInSeconds.formulaTree.value, "Invalid formula")
    }

    func testParseLookAndLooklist() {
        let project = self.getProjectForXML(xmlFile: "ValidProjectAllBricks0996")
        let looklist = project.scene.object(at: 0)!.lookList
        XCTAssertEqual(1, looklist!.count)

        let look = (looklist?.object(at: 0)) as! Look
        XCTAssertEqual(look.name, "testLook")
        XCTAssertEqual(look.fileName, "d842e119ceee69833b8db40d96d42a26_IMG_20141005_171500.jpg")
    }

    func testParseSoundAndSoundlist() {
        let project = self.getProjectForXML(xmlFile: "ValidProjectAllBricks0996")
        let soundlist = ((project.scene.object(at: 0)!.scriptList.object(at: 0) as! Script).brickList.object(at: 9) as! PointToBrick).pointedObject.soundList
        XCTAssertEqual(1, soundlist!.count)

        let sound = (soundlist?.object(at: 0)) as! Sound
        XCTAssertEqual(sound.name, "Aufnahme")
        XCTAssertEqual(sound.fileName, "6fa66a339e846455f1061d76e1c079df_Aufnahme.m4a")
    }

    func testParseLocalLists() {
        let project = self.getProjectForXML(xmlFile: "UserLists_0996")
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
}
