/**
 *  Copyright (C) 2010-2018 The Catrobat Team
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
        let program = self.getProgramForXML(xmlFile: "ValidHeader0991")
        let header = program.header
        let equal = self.isXMLElement(xmlElement: header.xmlElement(with: nil), equalToXMLElementForXPath: "//program/header", inProgramForXML: "ValidHeader0991")
        XCTAssertTrue(equal, "XMLElement invalid!");
    }
    
    func testInvalidHeader() {
        let program = self.getProgramForXML(xmlFile: "ValidHeader0991")
        let header = program.header
        header.programDescription = "Invalid"
        let equal = self.isXMLElement(xmlElement: header.xmlElement(with: nil), equalToXMLElementForXPath: "//program/header", inProgramForXML: "ValidHeader0991")
        XCTAssertFalse(equal, "GDataXMLElement::isEqualToElement not working correctly!");
    }
    
    func testFormulaAndMoveNStepsBrick() {
        let program = self.getProgramForXML(xmlFile: "ValidProgramAllBricks0991")
        let brick = ((program.objectList.object(at: 0) as! SpriteObject).scriptList.object(at: 0) as! Script).brickList.object(at: 5) as! MoveNStepsBrick
        let equal = self.isXMLElement(xmlElement: brick.xmlElement(with: nil), equalToXMLElementForXPath: "//program/objectList/object[1]/scriptList/script[1]/brickList/brick[6]", inProgramForXML: "ValidProgramAllBricks0991")
        XCTAssertTrue(equal, "XMLElement invalid!")
    }
    
    func testRemoveObjectAndSerializeProgram() {
        let parserContext = CBXMLParserContext(languageVersion: 0.98)
    
        let referenceProgram = self.getProgramForXML(xmlFile: "ValidProgram0991")
        let program = self.getProgramForXML(xmlFile: "ValidProgram0991")
        let moleOne = program.objectList.object(at: 1) as! SpriteObject
        program.remove(moleOne)
        
        let xmlElement = program.xmlElement(with: CBXMLSerializerContext())
        XCTAssertNotNil(xmlElement, "Error during serialization of removed object")
        XCTAssertEqual(program.objectList.count + 1, referenceProgram.objectList.count, "Object not properly removed")
        XCTAssertFalse((referenceProgram.xmlElement(with: CBXMLSerializerContext()).isEqual(to: xmlElement)), "Object not properly removed")
    
        let parsedProgram = parserContext?.parse(from: xmlElement, withClass: Program.self) as! Program
        XCTAssertTrue(parsedProgram.isEqual(to: program), "Programs are not equal")
    }
    
    func testPointedToBrickWithoutSpriteObject() {
        let program = self.getProgramForXML(xmlFile: "PointToBrickWithoutSpriteObject")
        XCTAssertNotNil(program, "Program must not be nil!");
    
        let moleTwo = program.objectList.object(at: 1) as! SpriteObject
        XCTAssertNotNil(moleTwo, "SpriteObject must not be nil!")
        XCTAssertTrue(moleTwo.name == "Mole 2", "Invalid object name!")
    
        let script = moleTwo.scriptList.object(at: 0) as! Script
        XCTAssertNotNil(script, "Script must not be nil!")
    
        let pointToBrick = script.brickList.object(at: 7) as! PointToBrick
        XCTAssertNotNil(pointToBrick, "PointToBrick must not be nil!");
    
        let context = CBXMLSerializerContext()
        context.spriteObjectList = program.objectList
    
        let equal = self.isXMLElement(xmlElement: pointToBrick.xmlElement(with: context), equalToXMLElementForXPath: "//program/objectList/object[2]/scriptList/script[1]/brickList/brick[8]", inProgramForXML: "PointToBrickWithoutSpriteObject")

        XCTAssertTrue(equal, "XMLElement invalid!")
    }
}
