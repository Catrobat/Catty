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

final class FormulaTest: XCTestCase {
    var formulaManager: FormulaManagerProtocol!
    var interpreter: FormulaInterpreterProtocol!

    override func setUp() {
        let screenSize = Util.screenSize(true)
        formulaManager = FormulaManager(sceneSize: screenSize, landscapeMode: false)
        interpreter = formulaManager
    }

    func testIsSingularNumberFormulaForInteger() {
        let formula = Formula(integer: 1)!
        XCTAssertTrue(formula.isSingularNumber())
    }

    func testIsSingularNumberFormulaForDouble() {
        let formula = Formula(double: 1.0)!
        XCTAssertTrue(formula.isSingularNumber())
    }

    func testIsSingularNumberFormulaForDouble2() {
        let formula = Formula(double: 1.1)!
        XCTAssertFalse(formula.isSingularNumber())
    }

    func testIsSingularNumberFormulaForFloat() {
        let formula = Formula(float: 1.0)!
        XCTAssertTrue(formula.isSingularNumber())
    }

    func testIsSingularNumberFormulaForString() {
        let formula = Formula(string: "1")!
        XCTAssertTrue(formula.isSingularNumber())
    }
    func testIsSingularNumberFormulaForString2() {
        let formula = Formula(string: "1.0")!
        XCTAssertTrue(formula.isSingularNumber())
    }

    func testIsSingularNumberFormulaForIntegerToken() {
        let internTokenList = NSMutableArray()
        let token = InternToken(type: TOKEN_TYPE_OPERATOR, andValue: MinusOperator.tag)!
        let tokenNumber = InternToken(type: TOKEN_TYPE_NUMBER, andValue: "1")!

        internTokenList.add(token)
        internTokenList.add(tokenNumber)

        var tokenList = [InternToken]()
        for tokenElement in internTokenList {
            if let internToken = tokenElement as? InternToken {
                tokenList.append(internToken)
            }
        }

        let internParser = InternFormulaParser(tokens: tokenList, andFormulaManager: formulaManager)!
        let parseTree = internParser.parseFormula(for: nil)
        XCTAssertNotNil(parseTree)

        var formula = Formula(formulaElement: parseTree)!
        XCTAssertEqual(-1, interpreter.interpretDouble(formula, for: SpriteObject()))

        internTokenList.removeAllObjects()

        formula = Formula(formulaElement: parseTree)!
        XCTAssertFalse(formula.isSingularNumber())
    }

    func testIsSingularNumberFormulaForDoubleToken() {
        let internTokenList = NSMutableArray()
        let token = InternToken(type: TOKEN_TYPE_OPERATOR, andValue: MinusOperator.tag)!
        let tokenNumber = InternToken(type: TOKEN_TYPE_NUMBER, andValue: "1.0")!

        internTokenList.add(token)
        internTokenList.add(tokenNumber)

        var tokenList = [InternToken]()
        for tokenElement in internTokenList {
            if let internToken = tokenElement as? InternToken {
                tokenList.append(internToken)
            }
        }

        let internParser = InternFormulaParser(tokens: tokenList, andFormulaManager: formulaManager)!
        let parseTree = internParser.parseFormula(for: nil)
        XCTAssertNotNil(parseTree)

        var formula = Formula(formulaElement: parseTree)!
        XCTAssertEqual(-1, interpreter.interpretDouble(formula, for: SpriteObject()))
        internTokenList.removeAllObjects()

        formula = Formula(formulaElement: parseTree)!
        XCTAssertFalse(formula.isSingularNumber())
    }

    func testIsSingularNumberFormulaForTwoTokens() {
        let internTokenList = NSMutableArray()
        let token = InternToken(type: TOKEN_TYPE_OPERATOR, andValue: MinusOperator.tag)!
        let tokenNumber = InternToken(type: TOKEN_TYPE_NUMBER, andValue: "1.0")!
        let secondToken = InternToken(type: TOKEN_TYPE_OPERATOR, andValue: MinusOperator.tag)!
        let secondNumber = InternToken(type: TOKEN_TYPE_NUMBER, andValue: "1.0")!

        internTokenList.add(token)
        internTokenList.add(tokenNumber)
        internTokenList.add(secondToken)
        internTokenList.add(secondNumber)

        var tokenList = [InternToken]()
        for tokenElement in internTokenList {
            if let internToken = tokenElement as? InternToken {
                tokenList.append(internToken)
            }
        }

        let internParser = InternFormulaParser(tokens: tokenList, andFormulaManager: formulaManager)!
        let parseTree = internParser.parseFormula(for: nil)
        XCTAssertNotNil(parseTree)

        var formula = Formula(formulaElement: parseTree)!
        XCTAssertEqual(-2, interpreter.interpretDouble(formula, for: SpriteObject()))
        formula = Formula(formulaElement: parseTree)!
        XCTAssertFalse(formula.isSingularNumber())

        internTokenList.removeAllObjects()
        formula = Formula(formulaElement: parseTree)!
        XCTAssertFalse(formula.isSingularNumber())
    }

    func testIsSingularNumberFormulaForMultipleMixedTokens() {
        let internTokenList = NSMutableArray()
        let token1 = InternToken(type: TOKEN_TYPE_FUNCTION_NAME, andValue: "ROUND")!
        let token2 = InternToken(type: TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_OPEN)!
        let token3 = InternToken(type: TOKEN_TYPE_NUMBER, andValue: "1.1111")!
        let token4 = InternToken(type: TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_CLOSE)!
        internTokenList.add(token1)
        internTokenList.add(token2)
        internTokenList.add(token3)
        internTokenList.add(token4)

        var tokenList = [InternToken]()
        for tokenElement in internTokenList {
            if let internToken = tokenElement as? InternToken {
                tokenList.append(internToken)
            }
        }

        let internParser = InternFormulaParser(tokens: tokenList, andFormulaManager: formulaManager)!
        let parseTree = internParser.parseFormula(for: nil)
        XCTAssertNotNil(parseTree)

        var formula = Formula(formulaElement: parseTree)!
        XCTAssertEqual(1, interpreter.interpretDouble(formula, for: SpriteObject()))
        internTokenList.removeAllObjects()

        formula = Formula(formulaElement: parseTree)!
        XCTAssertFalse(formula.isSingularNumber())
    }
}
