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

final class XMLSerializerTests: XMLAbstractTest {

    func testHeader() {
        let project = self.getProjectForXML(xmlFile: "ValidHeader0991")
        let header = project.header
        let equal = self.isXMLElement(xmlElement: header.xmlElement(with: nil), equalToXMLElementForXPath: "//program/header", inProjectForXML: "ValidHeader0991")
        XCTAssertTrue(equal, "XMLElement invalid!")
    }

    func testInvalidHeader() {
        let project = self.getProjectForXML(xmlFile: "ValidHeader0991")
        let header = project.header
        header.programDescription = "Invalid"
        let equal = self.isXMLElement(xmlElement: header.xmlElement(with: nil), equalToXMLElementForXPath: "//program/header", inProjectForXML: "ValidHeader0991")
        XCTAssertFalse(equal, "GDataXMLElement::isEqualToElement not working correctly!")
    }

    func testFormulaAndMoveNStepsBrick() {
        let project = self.getProjectForXML(xmlFile: "ValidProjectAllBricks0991")
        let brick = ((project.objectList.object(at: 0) as! SpriteObject).scriptList.object(at: 0) as! Script).brickList.object(at: 5) as! MoveNStepsBrick
        let xmlElementPath = "//program/objectList/object[1]/scriptList/script[1]/brickList/brick[6]"
        let equal = self.isXMLElement(xmlElement: brick.xmlElement(with: nil), equalToXMLElementForXPath: xmlElementPath, inProjectForXML: "ValidProjectAllBricks0991")
        XCTAssertTrue(equal, "XMLElement invalid!")
    }

    func testRemoveObjectAndSerializeProject() {
        let projectName = "ValidProject0991"
        let referenceProject = self.getProjectForXML(xmlFile: projectName)
        let project = self.getProjectForXML(xmlFile: projectName)

        let moleOne = project.objectList.object(at: 1) as! SpriteObject
        project.remove(moleOne)

        let serializerContext = CBXMLSerializerContext(project: project)

        let xmlElement = project.xmlElement(with: serializerContext)
        XCTAssertNotNil(xmlElement, "Error during serialization of removed object")
        XCTAssertEqual(project.objectList.count + 1, referenceProject.objectList.count, "Object not properly removed")
        XCTAssertFalse((referenceProject.xmlElement(with: CBXMLSerializerContext(project: Project())).isEqual(to: xmlElement)), "Object not properly removed")

        let parserContext = CBXMLParserContext(languageVersion: CGFloat(Float32(0.98)), andRootElement: xmlElement)

        let parsedProject = parserContext?.parse(from: xmlElement, withClass: Project.self) as! Project
        XCTAssertTrue(parsedProject.isEqual(to: project), "Projects are not equal")
    }

    func testPointedToBrickWithoutSpriteObject() {
        let project = self.getProjectForXML(xmlFile: "PointToBrickWithoutSpriteObject")
        XCTAssertNotNil(project, "Project must not be nil!")

        let moleTwo = project.objectList.object(at: 1) as! SpriteObject
        XCTAssertNotNil(moleTwo, "SpriteObject must not be nil!")
        XCTAssertEqual(moleTwo.name, "Mole 2", "Invalid object name!")

        let script = moleTwo.scriptList.object(at: 0) as! Script
        XCTAssertNotNil(script, "Script must not be nil!")

        let pointToBrick = script.brickList.object(at: 7) as! PointToBrick
        XCTAssertNotNil(pointToBrick, "PointToBrick must not be nil!")

        let context = CBXMLSerializerContext(project: project)
        context?.spriteObjectList = project.objectList

        let xmlElementPath = "//program/objectList/object[2]/scriptList/script[1]/brickList/brick[8]"
        let equal = self.isXMLElement(xmlElement: pointToBrick.xmlElement(with: context), equalToXMLElementForXPath: xmlElementPath, inProjectForXML: "PointToBrickWithoutSpriteObject")

        XCTAssertTrue(equal, "XMLElement invalid!")
    }

    func testPenDownBrick() {
        let project = self.getProjectForXML(xmlFile: "ValidProjectAllBricks0991")

        let brick = ((project.objectList.object(at: 0) as! SpriteObject).scriptList.object(at: 0) as! Script).brickList.object(at: 41) as! PenDownBrick
        let xmlElementPath = "//program/objectList/object[1]/scriptList/script[1]/brickList/brick[42]"

        guard let xmlElement = brick.xmlElement(with: CBXMLSerializerContext(project: Project())) else {
            XCTFail("xmlElement is nil")
            return
        }
        let equal = self.isXMLElement(xmlElement: xmlElement, equalToXMLElementForXPath: xmlElementPath, inProjectForXML: "ValidProjectAllBricks0991")
        XCTAssertTrue(equal, "XMLElement invalid!")
    }

    func testPenUpBrick() {
        let project = self.getProjectForXML(xmlFile: "ValidProjectAllBricks0991")

        let brick = ((project.objectList.object(at: 0) as! SpriteObject).scriptList.object(at: 0) as! Script).brickList.object(at: 42) as! PenUpBrick
        let xmlElementPath = "//program/objectList/object[1]/scriptList/script[1]/brickList/brick[43]"

        guard let xmlElement = brick.xmlElement(with: CBXMLSerializerContext(project: Project())) else {
            XCTFail("xmlElement is nil")
            return
        }
        let equal = self.isXMLElement(xmlElement: xmlElement, equalToXMLElementForXPath: xmlElementPath, inProjectForXML: "ValidProjectAllBricks0991")
        XCTAssertTrue(equal, "XMLElement invalid!")
    }

    func testPenClearBrick() {
        let project = self.getProjectForXML(xmlFile: "ValidProjectAllBricks0991")

        let brick = ((project.objectList.object(at: 0) as! SpriteObject).scriptList.object(at: 0) as! Script).brickList.object(at: 43) as! PenClearBrick
        let xmlElementPath = "//program/objectList/object[1]/scriptList/script[1]/brickList/brick[44]"

        guard let xmlElement = brick.xmlElement(with: CBXMLSerializerContext(project: Project())) else {
            XCTFail("xmlElement is nil")
            return
        }
        let equal = self.isXMLElement(xmlElement: xmlElement, equalToXMLElementForXPath: xmlElementPath, inProjectForXML: "ValidProjectAllBricks0991")
        XCTAssertTrue(equal, "XMLElement invalid!")
    }

    func testSetPenSizeBrick() {
        let project = self.getProjectForXML(xmlFile: "ValidProjectAllBricks0991")

        let brick = ((project.objectList.object(at: 0) as! SpriteObject).scriptList.object(at: 0) as! Script).brickList.object(at: 44) as! SetPenSizeBrick
        let xmlElementPath = "//program/objectList/object[1]/scriptList/script[1]/brickList/brick[45]"

        guard let xmlElement = brick.xmlElement(with: CBXMLSerializerContext(project: Project())) else {
            XCTFail("xmlElement is nil")
            return
        }
        print("XML Element: \(xmlElement)")
        let equal = self.isXMLElement(xmlElement: xmlElement, equalToXMLElementForXPath: xmlElementPath, inProjectForXML: "ValidProjectAllBricks0991")
        XCTAssertTrue(equal, "XMLElement invalid!")
    }

    func testSetPenColorBrick() {
        let project = self.getProjectForXML(xmlFile: "ValidProjectAllBricks0991")

        let brick = ((project.objectList.object(at: 0) as! SpriteObject).scriptList.object(at: 0) as! Script).brickList.object(at: 45) as! SetPenColorBrick
        let xmlElementPath = "//program/objectList/object[1]/scriptList/script[1]/brickList/brick[46]"

        guard let xmlElement = brick.xmlElement(with: CBXMLSerializerContext(project: project)) else {
            XCTFail("xmlElement is nil")
            return
        }
        print("XML Element: \(xmlElement)")
        let equal = self.isXMLElement(xmlElement: xmlElement, equalToXMLElementForXPath: xmlElementPath, inProjectForXML: "ValidProjectAllBricks0991")
        XCTAssertTrue(equal, "XMLElement invalid!")
    }
}
