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

extension SetPenColorBrick: CBXMLNodeProtocol {

    static func parse(from xmlElement: GDataXMLElement, with context: CBXMLParserContext) -> Self {
        CBXMLParserHelper.validate(xmlElement, forNumberOfChildNodes: 1, andFormulaListWithTotalNumberOfFormulas: 3)
        let brick = self.init()

        let greenFormula = CBXMLParserHelper.formula(in: xmlElement, forCategoryName: "PEN_COLOR_GREEN", with: context)
        brick.green = greenFormula

        let blueFormula = CBXMLParserHelper.formula(in: xmlElement, forCategoryName: "PEN_COLOR_BLUE", with: context)
        brick.blue = blueFormula

        let redFormula = CBXMLParserHelper.formula(in: xmlElement, forCategoryName: "PEN_COLOR_RED", with: context)
        brick.red = redFormula

        return brick
    }

    func xmlElement(with context: CBXMLSerializerContext) -> GDataXMLElement? {
        let brick = super.xmlElement(for: "SetPenColorBrick", with: context)
        let formulaList = GDataXMLElement(name: "formulaList", context: context)

        let greenFormula = self.green?.xmlElement(with: context)
        greenFormula?.addAttribute(GDataXMLElement(name: "category", stringValue: "PEN_COLOR_GREEN", context: nil))
        formulaList?.addChild(greenFormula, context: context)

        let blueFormula = self.blue?.xmlElement(with: context)
        blueFormula?.addAttribute(GDataXMLElement(name: "category", stringValue: "PEN_COLOR_BLUE", context: nil))
        formulaList?.addChild(blueFormula, context: context)

        let redFormula = self.red?.xmlElement(with: context)
        redFormula?.addAttribute(GDataXMLElement(name: "category", stringValue: "PEN_COLOR_RED", context: nil))
        formulaList?.addChild(redFormula, context: context)

        brick?.addChild(formulaList, context: context)
        return brick
    }

}
