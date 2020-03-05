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

class XMLParserFormulaTests093: XMLAbstractTest {
    var parserContext: CBXMLParserContext!
    var formulaManager: FormulaManager!

    override func setUp() {
        super.setUp()
        parserContext = CBXMLParserContext(languageVersion: CGFloat(Float32(0.93)))
        formulaManager = FormulaManager(sceneSize: Util.screenSize(true))
    }

    func testValidFormulaList() {
        let document = self.getXMLDocumentForPath(xmlPath: self.getPathForXML(xmlFile: "ValidFormulaList"))

        let brickElement = self.getXMLElementsForXPath(document, xPath: "//program/objectList/object[1]/scriptList/script[1]/brickList/brick[2]")
        XCTAssertEqual(brickElement!.count, 1)

        let brickXMLElement = brickElement!.first
        let brick = self.parserContext!.parse(from: brickXMLElement, withClass: SetVariableBrick.self) as! Brick

        XCTAssertTrue(brick.isKind(of: SetVariableBrick.self), "Invalid brick class")

        let setVariableBrick = brick as! SetVariableBrick

        XCTAssertEqual(setVariableBrick.userVariable.name, "random from", "Invalid user variable name")

        let formula = setVariableBrick.variableFormula
        // formula value should be: (1 * (-2)) + (3 / 4) = -1,25
        XCTAssertEqual(self.formulaManager.interpretDouble(formula!, for: SpriteObject()), -1.25, accuracy: 0.00001, "Formula not correctly parsed")
    }
}
