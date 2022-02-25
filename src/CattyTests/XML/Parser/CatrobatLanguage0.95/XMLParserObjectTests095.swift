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

final class XMLParserObjectTests095: XMLAbstractTest {

    var parserContext: CBXMLParserContext!

    override func setUp( ) {
        super.setUp()
    }

    override func getXMLDocumentForPath(xmlPath: String) -> GDataXMLDocument {
        let document = super.getXMLDocumentForPath(xmlPath: xmlPath)

        parserContext = CBXMLParserContext(languageVersion: CGFloat(Float32(0.95)), andRootElement: document.rootElement())

        return document
    }

    func testValidObjectListForAllBricks() {
        let document = self.getXMLDocumentForPath(xmlPath: self.getPathForXML(xmlFile: "ValidProjectAllBricks095"))

        let xmlElement = document.rootElement()

        let objectListElements = xmlElement?.elements(forName: "objectList")
        XCTAssertEqual(objectListElements!.count, 1)

        let objectElements = (objectListElements?.first as! GDataXMLElement).children() as! [GDataXMLElement]
        let objectList = NSMutableArray(capacity: objectElements.count)

        for objectElement in objectElements {
            let spriteObject = self.parserContext?.parse(from: objectElement, withClass: SpriteObject.self as CBXMLNodeProtocol.Type) as! SpriteObject
            objectList.add(spriteObject)
        }

        XCTAssertEqual(objectList.count, 2)
        let background = objectList.object(at: 0) as! SpriteObject
        XCTAssertEqual(background.name, "Hintergrund", "SpriteObject[0]: Name not correctly parsed")
    }
}
