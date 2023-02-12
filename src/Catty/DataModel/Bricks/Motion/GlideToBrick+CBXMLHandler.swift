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

extension GlideToBrick: CBXMLNodeProtocol {
    static func parse(from xmlElement: GDataXMLElement!, with context: CBXMLParserContext!) -> Self! {
        CBXMLParserHelper.validate(xmlElement, forNumberOfChildNodes: 1, andFormulaListWithTotalNumberOfFormulas: 3)

        let glideToBrick = self.init()
        if let formulaDuration = CBXMLParserHelper.formula(in: xmlElement, forCategoryName: "DURATION_IN_SECONDS", with: context) {
            glideToBrick.durationInSeconds = formulaDuration
        }
        if let formulaXDestination = CBXMLParserHelper.formula(in: xmlElement, forCategoryName: "X_DESTINATION", with: context) {
            glideToBrick.xPosition = formulaXDestination
        }
        if let formulaYDestination = CBXMLParserHelper.formula(in: xmlElement, forCategoryName: "Y_DESTINATION", with: context) {
            glideToBrick.yPosition = formulaYDestination
        }

        return glideToBrick
    }

    func xmlElement(with context: CBXMLSerializerContext!) -> GDataXMLElement! {
        let brick = super.xmlElement(for: "GlideToBrick", with: context)
        let formulaList = GDataXMLElement(name: "formulaList", context: context)

        var formula = self.durationInSeconds.xmlElement(with: context)
        formula?.addAttribute(GDataXMLElement.attribute(withName: "category", escapedStringValue: "DURATION_IN_SECONDS") as? GDataXMLNode)
        formulaList?.addChild(formula, context: context)

        formula = self.yPosition.xmlElement(with: context)
        formula?.addAttribute(GDataXMLElement.attribute(withName: "category", escapedStringValue: "Y_DESTINATION") as? GDataXMLNode)
        formulaList?.addChild(formula, context: context)

        formula = self.xPosition.xmlElement(with: context)
        formula?.addAttribute(GDataXMLElement.attribute(withName: "category", escapedStringValue: "X_DESTINATION") as? GDataXMLNode)
        formulaList?.addChild(formula, context: context)

        brick?.addChild(formulaList, context: context)
        return brick
    }
}
