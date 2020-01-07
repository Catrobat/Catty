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

class XMLParserObjectTests093: XMLAbstractTest {

    var parserContext: CBXMLParserContext!

    override func setUp( ) {
        super.setUp()
        parserContext = CBXMLParserContext(languageVersion: CGFloat(Float32(0.93)))
    }

    func testValidObjectList() {
        let document = self.getXMLDocumentForPath(xmlPath: self.getPathForXML(xmlFile: "ValidProject"))
        let xmlElement = document.rootElement()

        let objectListElements = xmlElement?.elements(forName: "objectList")
        XCTAssertEqual(objectListElements!.count, 1)

        let objectElements = (objectListElements?.first as! GDataXMLElement).children() as! [GDataXMLElement]
        let objectList = NSMutableArray(capacity: objectElements.count)

        let context = CBXMLParserContext()
        var userVariable = UserVariable()
        userVariable.name = "random from"
        context.programVariableList.add(userVariable)
        userVariable = UserVariable()
        userVariable.name = "random to"
        context.programVariableList.add(userVariable)
        for objectElement in objectElements {
            let spriteObject = self.parserContext?.parse(from: objectElement, withClass: SpriteObject.self) as! SpriteObject
            objectList.add(spriteObject)

        }

        XCTAssertEqual(objectList.count, 5)

        let background = objectList.object(at: 0) as! SpriteObject
        XCTAssertEqual(background.name, "Background", "SpriteObject[0]: Name not correctly parsed")
        XCTAssertEqual(background.lookList.count, 1, "SpriteObject[0]: lookList not correctly parsed")

        var look = background.lookList.object(at: 0) as! Look
        XCTAssertEqual(look.name, "Background", "SpriteObject[0]: Look name not correctly parsed")
        XCTAssertEqual(look.fileName, "1f363a1435a9497852285dbfa82b74e4_Background.png", "SpriteObject[0]: Look fileName not correctly parsed")

        XCTAssertEqual(background.soundList.count, 0, "SpriteObject[0]: soundList not correctly parsed")
        XCTAssertEqual(background.scriptList.count, 1, "SpriteObject[0]: scriptList not correctly parsed")

        let mole = objectList.object(at: 1) as! SpriteObject
        XCTAssertEqual(mole.name, "Mole 1", "SpriteObject[1]: Name not correctly parsed")
        XCTAssertEqual(mole.lookList.count, 3, "SpriteObject[1]: lookList not correctly parsed")
        look = mole.lookList.object(at: 1) as! Look
        XCTAssertEqual(look.name, "Mole", "SpriteObject[1]: Look name not correctly parsed")
        XCTAssertEqual(look.fileName, "dfcefc77af918afcbb71009c12ca5378_Mole.png", "SpriteObject[1]: Look fileName not correctly parsed")

        XCTAssertEqual(mole.soundList.count, 1, "SpriteObject[1]: soundList not correctly parsed")
        let sound = mole.soundList.object(at: 0) as! Sound
        XCTAssertEqual(sound.name, "Hit", "SpriteObject[1]: Sound name not correctly parsed")
        XCTAssertEqual(sound.fileName, "6f231e6406d3554d691f3c9ffb37c043_Hit1.m4a", "SpriteObject[1]: Sound fileName not correctly parsed")
    }

    func testValidObjectListForAllBricks() {
        let document = self.getXMLDocumentForPath(xmlPath: self.getPathForXML(xmlFile: "ValidProjectAllBricks093"))

        let xmlElement = document.rootElement()

        let objectListElements = xmlElement?.elements(forName: "objectList")
        XCTAssertEqual(objectListElements!.count, 1)

        let objectElements = (objectListElements?.first as! GDataXMLElement).children() as! [GDataXMLElement]
        let objectList = NSMutableArray(capacity: objectElements.count)

        let context = CBXMLParserContext()
        var userVariable = UserVariable()
        userVariable.name = "global"
        context.programVariableList.add(userVariable)
        userVariable = UserVariable()
        userVariable.name = "lokal"
        context.programVariableList.add(userVariable)

        for objectElement in objectElements {
            let spriteObject = self.parserContext?.parse(from: objectElement, withClass: SpriteObject.self as CBXMLNodeProtocol.Type) as! SpriteObject
            objectList.add(spriteObject)
        }

        XCTAssertEqual(objectList.count, 2)
        let background = objectList.object(at: 0) as! SpriteObject
        XCTAssertEqual(background.name, "Hintergrund", "SpriteObject[0]: Name not correctly parsed")
    }

}
