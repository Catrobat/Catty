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

final class XMLParserBrickTests095: XMLAbstractTest {
    var serializerContext = CBXMLSerializerContext()
    var parserContext = CBXMLParserContext(languageVersion: 0.95)
    
    func testInvalidSetVariableBrickWithoutFormula() {
        let setVariableBrick = SetVariableBrick()
        let xmlElement = setVariableBrick.xmlElement(with: self.serializerContext)

        XCTAssertThrowsError(try ConvertExceptionToError.catchException {
            SetVariableBrick.parse(from: xmlElement, with: self.parserContext)})
        { error in
            XCTAssertTrue(error.localizedDescription.contains(NSStringFromClass(CBXMLParserHelper.self)))
            error.localizedDescription.contains(NSStringFromClass(CBXMLParserHelper.self))
        }
    }
    
    func testSetVariableBrickWithoutUserVariableAndWithoutInUserBrickElement() {
        let setVariableBrick = SetVariableBrick()
        setVariableBrick.setDefaultValuesFor(nil)
        let xmlElement = setVariableBrick.xmlElement(with: self.serializerContext)
        XCTAssertNotNil(xmlElement, "GDataXMLElement must not be nil")
        XCTAssertNil(xmlElement?.child(withElementName: "inUserBrick"), "inUserBrickElement element not removed");
        let parsedSetVariableBrick = SetVariableBrick.parse(from: xmlElement, with: self.parserContext)
        XCTAssertNotNil(parsedSetVariableBrick, "Could not parse SetVariableBrick")
        XCTAssertNotNil(parsedSetVariableBrick!.variableFormula, "Formula not correctly parsed")
    }
    
    func testCompleteSetVariableBrick() {
        let userVariable = UserVariable()
        userVariable.name = "test"
        self.serializerContext.variables.programVariableList.add(userVariable)
    
        let setVariableBrick = SetVariableBrick()
        setVariableBrick.setDefaultValuesFor(nil)
        setVariableBrick.userVariable = userVariable
    
        let xmlElement = setVariableBrick.xmlElement(with: self.serializerContext)
    
        XCTAssertNotNil(xmlElement, "GDataXMLElement must not be nil")
    
        let parsedSetVariableBrick = SetVariableBrick.parse(from: xmlElement, with: self.parserContext)
    
        XCTAssertNotNil(parsedSetVariableBrick, "Could not parse SetVariableBrick")
        XCTAssertNotNil(parsedSetVariableBrick!.variableFormula, "Formula not correctly parsed")
        XCTAssertNotNil(parsedSetVariableBrick!.userVariable, "UserVariable not correctly parsed")
    }
    
    func testInvalidChangeVariableBrickWithoutFormula() {
        let changeVariableBrick = ChangeVariableBrick()
        let xmlElement = changeVariableBrick.xmlElement(with: self.serializerContext)
        
        XCTAssertThrowsError(try ConvertExceptionToError.catchException {
            ChangeVariableBrick.parse(from: xmlElement, with: self.parserContext)})
        { error in
            XCTAssertTrue(error.localizedDescription.contains(NSStringFromClass(CBXMLParserHelper.self)))
            error.localizedDescription.contains(NSStringFromClass(CBXMLParserHelper.self))
        }
    }
    
    func testChangeVariableBrickWithoutUserVariableAndWithoutInUserBrickElement() {
        let changeVariableBrick = ChangeVariableBrick()
        changeVariableBrick.setDefaultValuesFor(nil)
        let xmlElement = changeVariableBrick.xmlElement(with: self.serializerContext)
    
        XCTAssertNotNil(xmlElement, "GDataXMLElement must not be nil");
    
        XCTAssertNil(xmlElement?.child(withElementName: "inUserBrick"), "inUserBrickElement element not removed");
    
        let parsedChangeVariableBrick = ChangeVariableBrick.parse(from: xmlElement, with: self.parserContext)
    
        XCTAssertNotNil(parsedChangeVariableBrick, "Could not parse ChangeVariableBrick");
        XCTAssertNotNil(parsedChangeVariableBrick!.variableFormula, "Formula not correctly parsed");
    }
    
    func testCompleteChangeVariableBrick() {
        let userVariable = UserVariable()
        userVariable.name = "test"
        self.serializerContext.variables.programVariableList.add(userVariable)
        
        let changeVariableBrick = ChangeVariableBrick()
        changeVariableBrick.setDefaultValuesFor(nil)
        changeVariableBrick.userVariable = userVariable
        
        let xmlElement = changeVariableBrick.xmlElement(with: self.serializerContext)
        
        XCTAssertNotNil(xmlElement, "GDataXMLElement must not be nil")
        
        let parsedChangeVariableBrick = ChangeVariableBrick.parse(from: xmlElement, with: self.parserContext)
        
        XCTAssertNotNil(parsedChangeVariableBrick, "Could not parse ChangeVariableBrick")
        XCTAssertNotNil(parsedChangeVariableBrick!.variableFormula, "Formula not correctly parsed")
        XCTAssertNotNil(parsedChangeVariableBrick!.userVariable, "UserVariable not correctly parsed")
    }

    
}
