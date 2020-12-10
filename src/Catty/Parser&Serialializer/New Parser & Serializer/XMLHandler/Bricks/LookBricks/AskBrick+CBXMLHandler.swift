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

extension AskBrick: CBXMLNodeProtocol {
    static func parse(from xmlElement: GDataXMLElement, with context: CBXMLParserContext) -> Self {
        CBXMLParserHelper.validate(xmlElement, forNumberOfChildNodes: 2, andFormulaListWithTotalNumberOfFormulas: 1)
        let formula = CBXMLParserHelper.formula(in: xmlElement, forCategoryName: "ASK_QUESTION", with: context)
        let xmlVariable = xmlElement.child(withElementName: "userVariable")
        let userVariable = context.parse(from: xmlVariable, withClass: UserVariable.self)

        let brick = self.init()
        brick.question = formula
        brick.userVariable = userVariable as? UserVariable

        return brick
    }

    func xmlElement(with context: CBXMLSerializerContext) -> GDataXMLElement? {
        let brick = super.xmlElement(for: "AskBrick", with: context)
        let formulaList = GDataXMLElement(name: "formulaList", context: context)
        let formula = self.question?.xmlElement(with: context)
        formula?.addAttribute(GDataXMLElement(name: "category", stringValue: "ASK_QUESTION", context: nil))
        formulaList?.addChild(formula, context: context)
        brick?.addChild(formulaList, context: context)

        guard let variable = self.userVariable else {
            return brick
        }

        let finalVariable = GDataXMLElement.element(withName: "userVariable", stringValue: variable.name)
        brick?.addChild(finalVariable)

        return brick
    }
}
