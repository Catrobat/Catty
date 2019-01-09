/**
 *  Copyright (C) 2010-2019 The Catrobat Team
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

final class XMLParserUserVariableTests095: XMLAbstractTest {

    var parserContext: CBXMLParserContext!

    override func setUp( ) {
        super.setUp()
        parserContext = CBXMLParserContext(languageVersion: CGFloat(Float32(0.95)))
    }

    func testValidVariables() {
        let xmlRoot = self.getXMLDocumentForPath(xmlPath: self.getPathForXML(xmlFile: "Airplane_with_shadow_095"))
        XCTAssertNotNil(xmlRoot.rootElement, "rootElement is nil")

        let variablesContainer = self.parserContext?.parse(from: xmlRoot.rootElement(), withClass: VariablesContainer.self as? CBXMLNodeProtocol.Type) as! VariablesContainer
        XCTAssertNotNil(variablesContainer, "VariablesContainer is nil")
        XCTAssertEqual(8, variablesContainer.objectVariableList.count(), "Invalid number of object variables")

        var spriteObject = variablesContainer.objectVariableList.key(at: 0) as! SpriteObject
        XCTAssertEqual(spriteObject.name, "Lower right tile", "Invalid SpriteObject name for object variable 1")
        var variables = variablesContainer.objectVariables(for: spriteObject)
        XCTAssertEqual(0, variables!.count, "Invalid number of object variables for object 1")

        spriteObject = variablesContainer.objectVariableList.key(at: 1) as! SpriteObject
        XCTAssertEqual(spriteObject.name, "Lower left tile", "Invalid SpriteObject name for object variable 2")
        variables = variablesContainer.objectVariables(for: spriteObject)
        XCTAssertEqual(0, variables!.count, "Invalid number of object variables for object 2")

        spriteObject = variablesContainer.objectVariableList.key(at: 2) as! SpriteObject
        XCTAssertEqual(spriteObject.name, "Upper left tile", "Invalid SpriteObject name for object variable 3")
        variables = variablesContainer.objectVariables(for: spriteObject)
        XCTAssertEqual(0, variables!.count, "Invalid number of object variables for object 3")

        spriteObject = variablesContainer.objectVariableList.key(at: 3) as! SpriteObject
        XCTAssertEqual(spriteObject.name, "Airplane", "Invalid SpriteObject name for object variable 4")
        variables = variablesContainer.objectVariables(for: spriteObject)
        XCTAssertEqual(0, variables!.count, "Invalid number of object variables for object 5")

        spriteObject = variablesContainer.objectVariableList.key(at: 4) as! SpriteObject
        XCTAssertEqual(spriteObject.name, "Upper right tile", "Invalid SpriteObject name for object variable 5")
        variables = variablesContainer.objectVariables(for: spriteObject)
        XCTAssertEqual(0, variables!.count, "Invalid number of object variables for object 5")

        spriteObject = variablesContainer.objectVariableList.key(at: 5) as! SpriteObject
        XCTAssertEqual(spriteObject.name, "Shadow", "Invalid SpriteObject name for object variable 6")
        variables = variablesContainer.objectVariables(for: spriteObject)
        XCTAssertEqual(0, variables!.count, "Invalid number of object variables for object 6")

        spriteObject = variablesContainer.objectVariableList.key(at: 6) as! SpriteObject
        XCTAssertEqual(spriteObject.name, "Background", "Invalid SpriteObject name for object variable 7")
        variables = variablesContainer.objectVariables(for: spriteObject)
        XCTAssertEqual(0, variables!.count, "Invalid number of object variables for object 7")

        spriteObject = variablesContainer.objectVariableList.key(at: 7) as! SpriteObject
        XCTAssertEqual(spriteObject.name, "Pointer", "Invalid SpriteObject name for object variable 8")
        variables = variablesContainer.objectVariables(for: spriteObject)
        XCTAssertEqual(0, variables!.count, "Invalid number of object variables for object 8")

        XCTAssertEqual(5, variablesContainer.programVariableList.count, "Invalid number of program variables")
    }

}
