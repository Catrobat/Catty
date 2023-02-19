/**
 *  Copyright (C) 2010-2023 The Catrobat Team
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

class FormulaParserFunctionsTest: XCTestCase {

    var formulaTestHelper: FormulaTestHelper!
    let EPSILON = 0.01

    override func setUp() {
        super.setUp()
        formulaTestHelper = FormulaTestHelper()
        }

    func testSin() {
        let internTokenList = addOpeningAndClosingBrackets(withTag: "SIN", andValue: "90")
        formulaTestHelper.interpretValidFormula(with: internTokenList, description: "sin(90)", andExpectedResult: 1)
    }

    func testCos() {
        let internTokenList = addOpeningAndClosingBrackets(withTag: "COS", andValue: "180")
        formulaTestHelper.interpretValidFormula(with: internTokenList, description: "cos(90)", andExpectedResult: -1)
    }

    func testTan() {
        let internTokenList = addOpeningAndClosingBrackets(withTag: "TAN", andValue: "180")
        formulaTestHelper.interpretValidFormula(with: internTokenList, description: "tan(90)", andExpectedResult: 0.0, withAccuracy: EPSILON)
    }

    func testLn() {
        let internTokenList = addOpeningAndClosingBrackets(withTag: "LN", andValue: "2.7182818")
        formulaTestHelper.interpretValidFormula(with: internTokenList, description: "ln(2.7182818)", andExpectedResult: 1.0, withAccuracy: EPSILON)
    }

    func testLog() {
        let internTokenList = addOpeningAndClosingBrackets(withTag: "LOG", andValue: "10")
        formulaTestHelper.interpretValidFormula(with: internTokenList, description: "log(10)", andExpectedResult: 1)
    }

    func testPi() {
        let internTokenList = [InternToken(type: TOKEN_TYPE_FUNCTION_NAME, andValue: "PI")!]
        formulaTestHelper.interpretValidFormula(with: internTokenList, description: "PI", andExpectedResult: Double.pi)
    }

    func testSqrt() {
        let internTokenList = addOpeningAndClosingBrackets(withTag: "SQRT", andValue: "100")
        formulaTestHelper.interpretValidFormula(with: internTokenList, description: "sqrt(100)", andExpectedResult: 10)
    }

    func testExp() {
        let internTokenList = addOpeningAndClosingBrackets(withTag: "EXP", andValue: "3")
        formulaTestHelper.interpretValidFormula(with: internTokenList, description: "exp(3)", andExpectedResult: 20.08, withAccuracy: 0.1)
    }

    func testRandomNaturalNumbers() {
        let internTokenList = [InternToken(type: TOKEN_TYPE_FUNCTION_NAME, andValue: "RAND")!,
                               InternToken(type: TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_OPEN)!,
                               InternToken(type: TOKEN_TYPE_NUMBER, andValue: "0")!,
                               InternToken(type: TOKEN_TYPE_FUNCTION_PARAMETER_DELIMITER)!,
                               InternToken(type: TOKEN_TYPE_NUMBER, andValue: "1")!,
                               InternToken(type: TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_CLOSE)!]
        let parser = InternFormulaParser(tokens: internTokenList, andFormulaManager: formulaTestHelper.formulaManager)
        let parseTree = parser?.parseFormula(for: nil)
        XCTAssertNotNil(parseTree, "Formula is not parsed correctly!")

        let formula = Formula(formulaElement: parseTree)!
        let result = formulaTestHelper.interpreter.interpretDouble(formula, for: formulaTestHelper.spriteObject)
        XCTAssertTrue(result == 1 || result == 0, "Formula interpretation is not as expected!")
    }

    func testRound() {
        let internTokenList = addOpeningAndClosingBrackets(withTag: "ROUND", andValue: "1.33333")
        formulaTestHelper.interpretValidFormula(with: internTokenList, description: "round(1.33333)", andExpectedResult: 1.0)
    }

    func testMod() {
        for offset in 0...9 {
            let dividend = 1 + offset
            let divisor = 1 + offset
            let internTokenList = [InternToken(type: TOKEN_TYPE_FUNCTION_NAME, andValue: "MOD")!,
                                   InternToken(type: TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_OPEN)!,
                                   InternToken(type: TOKEN_TYPE_NUMBER, andValue: String(dividend))!,
                                   InternToken(type: TOKEN_TYPE_FUNCTION_PARAMETER_DELIMITER)!,
                                   InternToken(type: TOKEN_TYPE_NUMBER, andValue: String(divisor))!,
                                   InternToken(type: TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_CLOSE)!]
            formulaTestHelper.interpretValidFormula(with: internTokenList, description: "mod(\(dividend), \(divisor))", andExpectedResult: 0.0, withAccuracy: EPSILON)
        }

        for offset in stride(from: 0, to: 100, by: 2) {
            let dividend = 3 + offset
            let divisor = 2 + offset
            let internTokenList = [InternToken(type: TOKEN_TYPE_FUNCTION_NAME, andValue: "MOD")!,
                                   InternToken(type: TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_OPEN)!,
                                   InternToken(type: TOKEN_TYPE_NUMBER, andValue: String(dividend))!,
                                   InternToken(type: TOKEN_TYPE_FUNCTION_PARAMETER_DELIMITER)!,
                                   InternToken(type: TOKEN_TYPE_NUMBER, andValue: String(divisor))!,
                                   InternToken(type: TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_CLOSE)!]
            formulaTestHelper.interpretValidFormula(with: internTokenList, description: "mod(\(dividend), \(divisor))", andExpectedResult: 1.0, withAccuracy: EPSILON)
        }

        for offset in 0...9 {
            let dividend = 3 + offset
            let divisor = 5 + offset
            let internTokenList = [InternToken(type: TOKEN_TYPE_FUNCTION_NAME, andValue: "MOD")!,
                                   InternToken(type: TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_OPEN)!,
                                   InternToken(type: TOKEN_TYPE_NUMBER, andValue: String(dividend))!,
                                   InternToken(type: TOKEN_TYPE_FUNCTION_PARAMETER_DELIMITER)!,
                                   InternToken(type: TOKEN_TYPE_NUMBER, andValue: String(divisor))!,
                                   InternToken(type: TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_CLOSE)!]
            formulaTestHelper.interpretValidFormula(with: internTokenList, description: "mod(\(dividend), \(divisor))", andExpectedResult: Double(dividend), withAccuracy: EPSILON)
        }

        for offset in 0...9 {
            let dividend = -3 - offset
            let divisor = 2 + offset
            let internTokenList = [InternToken(type: TOKEN_TYPE_FUNCTION_NAME, andValue: "MOD")!,
                                   InternToken(type: TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_OPEN)!,
                                   InternToken(type: TOKEN_TYPE_OPERATOR, andValue: MinusOperator.tag)!,
                                   InternToken(type: TOKEN_TYPE_NUMBER, andValue: String(abs(dividend)))!,
                                   InternToken(type: TOKEN_TYPE_FUNCTION_PARAMETER_DELIMITER)!,
                                   InternToken(type: TOKEN_TYPE_NUMBER, andValue: String(divisor))!,
                                   InternToken(type: TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_CLOSE)!]
            formulaTestHelper.interpretValidFormula(with: internTokenList, description: "mod(-\(abs(dividend)), \(divisor))", andExpectedResult: Double(1 + offset), withAccuracy: EPSILON)
        }
    }

    func testAbs() {
        let internTokenList = [InternToken(type: TOKEN_TYPE_FUNCTION_NAME, andValue: "ABS")!,
                               InternToken(type: TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_OPEN)!,
                               InternToken(type: TOKEN_TYPE_OPERATOR, andValue: MinusOperator.tag)!,
                               InternToken(type: TOKEN_TYPE_NUMBER, andValue: "1")!,
                               InternToken(type: TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_CLOSE)!]
        formulaTestHelper.interpretValidFormula(with: internTokenList, description: "abs(1)", andExpectedResult: 1)
    }

    func testInvalidFunction() {
        let internTokenList = [InternToken(type: TOKEN_TYPE_FUNCTION_NAME, andValue: "INVALID_FUNCTION")!,
                               InternToken(type: TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_OPEN)!,
                               InternToken(type: TOKEN_TYPE_NUMBER, andValue: "1")!,
                               InternToken(type: TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_CLOSE)!]
        formulaTestHelper.interpretInvalidFormula(with: internTokenList, description: "Formula parsed but should not: INVALID_FUNCTION(1)", andExpectedErrorCode: 0)
    }

    func testTrue() {
        let internTokenList = [InternToken(type: TOKEN_TYPE_FUNCTION_NAME, andValue: "TRUE")!]
        formulaTestHelper.interpretValidFormula(with: internTokenList, description: "TRUE", andExpectedResult: 1.0)
    }

    func testFalse() {
        let internTokenList = [InternToken(type: TOKEN_TYPE_FUNCTION_NAME, andValue: "FALSE")!]
        formulaTestHelper.interpretValidFormula(with: internTokenList, description: "FALSE", andExpectedResult: 0.0)
    }

    func testArcsin() {
        let internTokenList = addOpeningAndClosingBrackets(withTag: "ARCSIN", andValue: "1")
        formulaTestHelper.interpretValidFormula(with: internTokenList, description: "arcsin(1)", andExpectedResult: 90.0)
    }

    func testArccos() {
        let internTokenList = addOpeningAndClosingBrackets(withTag: "ARCCOS", andValue: "0")
        formulaTestHelper.interpretValidFormula(with: internTokenList, description: "arccos(0)", andExpectedResult: 90.0)
    }

    func testArctan() {
        let internTokenList = addOpeningAndClosingBrackets(withTag: "ARCTAN", andValue: "1")
        formulaTestHelper.interpretValidFormula(with: internTokenList, description: "arctan(1)", andExpectedResult: 45.0)
    }

    func testMax() {
        let internTokenList = [InternToken(type: TOKEN_TYPE_FUNCTION_NAME, andValue: "MAX")!,
                               InternToken(type: TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_OPEN)!,
                               InternToken(type: TOKEN_TYPE_NUMBER, andValue: "3")!,
                               InternToken(type: TOKEN_TYPE_FUNCTION_PARAMETER_DELIMITER)!,
                               InternToken(type: TOKEN_TYPE_NUMBER, andValue: "4")!,
                               InternToken(type: TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_CLOSE)!]
        formulaTestHelper.interpretValidFormula(with: internTokenList, description: "max(3,4)", andExpectedResult: 4.0)
    }

    func testMin() {
        let internTokenList = [InternToken(type: TOKEN_TYPE_FUNCTION_NAME, andValue: "MIN")!,
                               InternToken(type: TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_OPEN)!,
                               InternToken(type: TOKEN_TYPE_NUMBER, andValue: "3")!,
                               InternToken(type: TOKEN_TYPE_FUNCTION_PARAMETER_DELIMITER)!,
                               InternToken(type: TOKEN_TYPE_NUMBER, andValue: "4")!,
                               InternToken(type: TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_CLOSE)!]
        formulaTestHelper.interpretValidFormula(with: internTokenList, description: "min(3,4)", andExpectedResult: 3.0)
    }

    func addOpeningAndClosingBrackets(withTag tag: String, andValue value: String) -> [InternToken] {
        var internTokenList = [InternToken]()
        internTokenList.append(InternToken(type: TOKEN_TYPE_FUNCTION_NAME, andValue: tag))
        internTokenList.append(InternToken(type: TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_OPEN))
        internTokenList.append(InternToken(type: TOKEN_TYPE_NUMBER, andValue: value))
        internTokenList.append(InternToken(type: TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_CLOSE))
        return internTokenList
    }
}
