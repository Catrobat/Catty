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

final class XMLParserUserVariableTests095: XMLAbstractTest {

    var parserContext: CBXMLParserContext!

    override func setUp( ) {
        super.setUp()
    }

    override func getXMLDocumentForPath(xmlPath: String) -> GDataXMLDocument {
        let document = super.getXMLDocumentForPath(xmlPath: xmlPath)

        parserContext = CBXMLParserContext(languageVersion: CGFloat(Float32(0.95)), andRootElement: document.rootElement())

        return document
    }

    func testValidVariables() {
        let xmlRoot = self.getXMLDocumentForPath(xmlPath: self.getPathForXML(xmlFile: "Airplane_with_shadow_095"))
        XCTAssertNotNil(xmlRoot.rootElement, "rootElement is nil")

        let project = self.parserContext?.parse(from: xmlRoot.rootElement(), withClass: Project.self) as! Project
        XCTAssertNotNil(project, "project is nil")
        XCTAssertEqual(8, project.allObjects().count, "Invalid number of object variables")

        var spriteObject = project.allObjects()[0]
        XCTAssertEqual(spriteObject.name, "Background", "Invalid SpriteObject name for object variable 1")
        var variables = UserDataContainer.objectVariables(for: spriteObject)
        XCTAssertEqual(0, variables.count, "Invalid number of object variables for object 1")

        spriteObject = project.allObjects()[1]
        XCTAssertEqual(spriteObject.name, "Airplane", "Invalid SpriteObject name for object variable 2")
        variables = UserDataContainer.objectVariables(for: spriteObject)
        XCTAssertEqual(0, variables.count, "Invalid number of object variables for object 2")

        spriteObject = project.allObjects()[2]
        XCTAssertEqual(spriteObject.name, "Pointer", "Invalid SpriteObject name for object variable 3")
        variables = UserDataContainer.objectVariables(for: spriteObject)
        XCTAssertEqual(0, variables.count, "Invalid number of object variables for object 3")

        spriteObject = project.allObjects()[3]
        XCTAssertEqual(spriteObject.name, "Shadow", "Invalid SpriteObject name for object variable 4")
        variables = UserDataContainer.objectVariables(for: spriteObject)
        XCTAssertEqual(0, variables.count, "Invalid number of object variables for object 4")

        spriteObject = project.allObjects()[4]
        XCTAssertEqual(spriteObject.name, "Lower left tile", "Invalid SpriteObject name for object variable 5")
        variables = UserDataContainer.objectVariables(for: spriteObject)
        XCTAssertEqual(0, variables.count, "Invalid number of object variables for object 5")

        spriteObject = project.allObjects()[5]
        XCTAssertEqual(spriteObject.name, "Lower right tile", "Invalid SpriteObject name for object variable 6")
        variables = UserDataContainer.objectVariables(for: spriteObject)
        XCTAssertEqual(0, variables.count, "Invalid number of object variables for object 6")

        spriteObject = project.allObjects()[6]
        XCTAssertEqual(spriteObject.name, "Upper left tile", "Invalid SpriteObject name for object variable 7")
        variables = UserDataContainer.objectVariables(for: spriteObject)
        XCTAssertEqual(0, variables.count, "Invalid number of object variables for object 7")

        spriteObject = project.allObjects()[7]
        XCTAssertEqual(spriteObject.name, "Upper right tile", "Invalid SpriteObject name for object variable 8")
        variables = UserDataContainer.objectVariables(for: spriteObject)
        XCTAssertEqual(0, variables.count, "Invalid number of object variables for object 8")

        XCTAssertEqual(5, project.userData.variables().count, "Invalid number of project variables")
    }

}
