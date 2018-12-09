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

final class FormulaTest: XCTestCase {
    var formulaManager: FormulaManager?

    override func setUp() {
        super.setUp()
        formulaManager = FormulaManager(sceneSize: Util.screenSize(true))
    }

    func testIsSingularNumberFormula() {
        var formula = Formula(integer: 1)
        XCTAssertTrue((formula?.isSingularNumber())!)

        formula = Formula(double: 1.0)
        XCTAssertTrue((formula?.isSingularNumber())!)

        formula = Formula(float: 1.0)
        XCTAssertTrue((formula?.isSingularNumber())!)

        formula = Formula(string: "1")
        XCTAssertTrue((formula?.isSingularNumber())!)

        formula = Formula(string: "1.0")
        XCTAssertTrue((formula?.isSingularNumber())!)

        formula = Formula(double: 1.1)
        XCTAssertFalse((formula?.isSingularNumber())!)

        let internTokenList = NSMutableArray()
        internTokenList.add(InternToken(type: TOKEN_TYPE_OPERATOR, andValue: Operators.getName(Operator.MINUS)))
        internTokenList.add(InternToken(type: TOKEN_TYPE_NUMBER, andValue: "1"))

        var internParser = InternFormulaParser(tokens: (internTokenList as! [InternToken]), andFormulaManager: formulaManager)
        var parseTree: FormulaElement? = internParser!.parseFormula(for: nil)
        formula = Formula(formulaElement: parseTree)

        XCTAssertNotNil(parseTree, "Formula is not parsed correctly: - 1")
        XCTAssertEqual(-1, formulaManager?.interpretDouble(formula!, for: SpriteObject()), "Formula interpretation is not as expected")
        internTokenList.removeAllObjects()

        formula = Formula(formulaElement: parseTree)
        XCTAssertFalse((formula?.isSingularNumber())!, "Formula should be single number formula")

        internTokenList.add(InternToken(type: TOKEN_TYPE_OPERATOR, andValue: Operators.getName(Operator.MINUS)))
        internTokenList.add(InternToken(type: TOKEN_TYPE_NUMBER, andValue: "1.0"))

        internParser = InternFormulaParser(tokens: (internTokenList as! [InternToken]), andFormulaManager: formulaManager)
        parseTree = internParser!.parseFormula(for: nil)

        XCTAssertNotNil(parseTree, "Formula is not parsed correctly: - 1")
        XCTAssertEqual(-1, formulaManager?.interpretDouble(formula!, for: SpriteObject()), "Formula interpretation is not as expected")
        internTokenList.removeAllObjects()

        formula = Formula(formulaElement: parseTree)
        XCTAssertFalse((formula?.isSingularNumber())!, "Formula should be single number formula")

        internTokenList.add(InternToken(type: TOKEN_TYPE_OPERATOR, andValue: Operators.getName(Operator.MINUS)))
        internTokenList.add(InternToken(type: TOKEN_TYPE_NUMBER, andValue: "1.0"))
        internTokenList.add(InternToken(type: TOKEN_TYPE_OPERATOR, andValue: Operators.getName(Operator.MINUS)))
        internTokenList.add(InternToken(type: TOKEN_TYPE_NUMBER, andValue: "1.0"))

        internParser = InternFormulaParser(tokens: (internTokenList as! [InternToken]), andFormulaManager: formulaManager)
        parseTree = internParser!.parseFormula(for: nil)
        XCTAssertNotNil(parseTree, "Formula is not parsed correctly: - 1 - 1")

        formula = Formula(formulaElement: parseTree)
        XCTAssertEqual(-2, formulaManager?.interpretDouble(formula!, for: SpriteObject()), "Formula interpretation is not as expected")

        formula = Formula(formulaElement: parseTree)
        XCTAssertFalse((formula?.isSingularNumber())!, "Should NOT be a single number formula")

        internTokenList.removeAllObjects()
        internTokenList.add(InternToken(type: TOKEN_TYPE_FUNCTION_NAME, andValue: "ROUND"))
        internTokenList.add(InternToken(type: TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_OPEN))
        internTokenList.add(InternToken(type: TOKEN_TYPE_NUMBER, andValue: "1.1111"))
        internTokenList.add(InternToken(type: TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_CLOSE))

        internParser = InternFormulaParser(tokens: (internTokenList as! [InternToken]), andFormulaManager: formulaManager)
        parseTree = internParser!.parseFormula(for: nil)
        XCTAssertNotNil(parseTree, "Formula is not parsed correctly: round(1.1111)")

        formula = Formula(formulaElement: parseTree)
        XCTAssertEqual(1, formulaManager?.interpretDouble(formula!, for: SpriteObject()), "Formula interpretation is not as expected")
        internTokenList.removeAllObjects()

        formula = Formula(formulaElement: parseTree)
        XCTAssertFalse((formula?.isSingularNumber())!, "Should NOT be a single number formula")
    }
}
