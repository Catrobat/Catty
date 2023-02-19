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

final class FormulaParserOperatorsTest: XCTestCase {

    var formulaTestHelper: FormulaTestHelper!

    override func setUp() {
        super.setUp()
        formulaTestHelper = FormulaTestHelper()
    }

    func testOperatorChain() {
        var firstTerm = [InternToken(type: TOKEN_TYPE_NUMBER, andValue: "1")!,
                               InternToken(type: TOKEN_TYPE_OPERATOR, andValue: PlusOperator.tag)!,
                               InternToken(type: TOKEN_TYPE_NUMBER, andValue: "2")!]
        var secondTerm = [InternToken(type: TOKEN_TYPE_NUMBER, andValue: "2")!,
                                InternToken(type: TOKEN_TYPE_OPERATOR, andValue: PlusOperator.tag)!,
                                InternToken(type: TOKEN_TYPE_NUMBER, andValue: "1")!]

        firstTerm = FormulaTestHelper.appendOperationToList(internTokenList: firstTerm, withOperator: MultOperator.tag, andTokenType: TOKEN_TYPE_NUMBER, withValue: "3")
        firstTerm = FormulaTestHelper.mergeOperatorLists(firstList: firstTerm, withOperator: MultOperator.tag, andSecondList: secondTerm)
        formulaTestHelper.interpretValidFormula(with: firstTerm, description: "1 + 2 * 3 * 2 + 1", andExpectedResult: 14)

        firstTerm = [InternToken(type: TOKEN_TYPE_NUMBER, andValue: "1")!,
                               InternToken(type: TOKEN_TYPE_OPERATOR, andValue: PlusOperator.tag)!,
                               InternToken(type: TOKEN_TYPE_NUMBER, andValue: "2")!]
        secondTerm = [InternToken(type: TOKEN_TYPE_NUMBER, andValue: "3")!,
                                InternToken(type: TOKEN_TYPE_OPERATOR, andValue: MultOperator.tag)!,
                                InternToken(type: TOKEN_TYPE_NUMBER, andValue: "2")!]
        firstTerm = FormulaTestHelper.mergeOperatorLists(firstList: firstTerm, withOperator: MultOperator.tag, andSecondList: secondTerm)
        formulaTestHelper.interpretValidFormula(with: firstTerm, description: "1 + 2 * 3 * 2", andExpectedResult: 13)
    }

    func testOperatorLeftBinding() {
        var firstTerm = [InternToken(type: TOKEN_TYPE_NUMBER, andValue: "5")!,
                               InternToken(type: TOKEN_TYPE_OPERATOR, andValue: MinusOperator.tag)!,
                               InternToken(type: TOKEN_TYPE_NUMBER, andValue: "4")!]
        firstTerm = FormulaTestHelper.appendOperationToList(internTokenList: firstTerm, withOperator: MinusOperator.tag, andTokenType: TOKEN_TYPE_NUMBER, withValue: "1")
        formulaTestHelper.interpretValidFormula(with: firstTerm, description: "5 - 4 - 1", andExpectedResult: 0)

        firstTerm = [InternToken(type: TOKEN_TYPE_NUMBER, andValue: "100")!,
                               InternToken(type: TOKEN_TYPE_OPERATOR, andValue: DivideOperator.tag)!,
                               InternToken(type: TOKEN_TYPE_NUMBER, andValue: "10")!]
        firstTerm = FormulaTestHelper.appendOperationToList(internTokenList: firstTerm, withOperator: DivideOperator.tag, andTokenType: TOKEN_TYPE_NUMBER, withValue: "10")
        formulaTestHelper.interpretValidFormula(with: firstTerm, description: "100 % 10 % 10", andExpectedResult: 1)
    }

    func testOperatorPriority() {
        var firstTerm = [InternToken(type: TOKEN_TYPE_NUMBER, andValue: "1")!,
                               InternToken(type: TOKEN_TYPE_OPERATOR, andValue: MinusOperator.tag)!,
                               InternToken(type: TOKEN_TYPE_NUMBER, andValue: "2")!]
        firstTerm = FormulaTestHelper.appendOperationToList(internTokenList: firstTerm, withOperator: MultOperator.tag, andTokenType: TOKEN_TYPE_NUMBER, withValue: "2")
        formulaTestHelper.interpretValidFormula(with: firstTerm, description: "1 - 2 - 2", andExpectedResult: -3)
    }

    func testUnaryMinus() {
        let internTokenList = [InternToken(type: TOKEN_TYPE_OPERATOR, andValue: MinusOperator.tag)!,
                               InternToken(type: TOKEN_TYPE_NUMBER, andValue: "42.42")!]
        formulaTestHelper.interpretValidFormula(with: internTokenList, description: "-42.42", andExpectedResult: -42.42)
    }

    func testGreaterThan() {
        let tokenGreaterThan = InternToken(type: TOKEN_TYPE_OPERATOR, andValue: GreaterThanOperator.tag)
        let tokenNumber1 = InternToken(type: TOKEN_TYPE_NUMBER, andValue: "1")
        let tokenNumber2 = InternToken(type: TOKEN_TYPE_NUMBER, andValue: "2")
        let tokenString1 = InternToken(type: TOKEN_TYPE_STRING, andValue: "1")
        let tokenString2 = InternToken(type: TOKEN_TYPE_STRING, andValue: "2")

        var internTokenList = [tokenNumber2!, tokenGreaterThan!, tokenNumber1!]
        formulaTestHelper.interpretValidFormula(with: internTokenList, description: "2 > 1", andExpectedResult: true)

        internTokenList = [tokenNumber1!, tokenGreaterThan!, tokenNumber1!]
        formulaTestHelper.interpretValidFormula(with: internTokenList, description: "1 > 1", andExpectedResult: false)

        internTokenList = [tokenNumber1!, tokenGreaterThan!, tokenNumber2!]
        formulaTestHelper.interpretValidFormula(with: internTokenList, description: "1 > 2", andExpectedResult: false)

        internTokenList = [tokenString2!, tokenGreaterThan!, tokenString1!]
        formulaTestHelper.interpretValidFormula(with: internTokenList, description: "2 > 1", andExpectedResult: true)

        internTokenList = [tokenString1!, tokenGreaterThan!, tokenString1!]
        formulaTestHelper.interpretValidFormula(with: internTokenList, description: "1 > 1", andExpectedResult: false)

        internTokenList = [tokenString1!, tokenGreaterThan!, tokenString2!]
        formulaTestHelper.interpretValidFormula(with: internTokenList, description: "1 > 2", andExpectedResult: false)
    }

    func testGreaterOrEqualThan() {
        let tokenGreaterOrEqual = InternToken(type: TOKEN_TYPE_OPERATOR, andValue: GreaterOrEqualOperator.tag)
        let tokenNumber1 = InternToken(type: TOKEN_TYPE_NUMBER, andValue: "1")
        let tokenNumber2 = InternToken(type: TOKEN_TYPE_NUMBER, andValue: "2")
        let tokenString1 = InternToken(type: TOKEN_TYPE_STRING, andValue: "1")
        let tokenString2 = InternToken(type: TOKEN_TYPE_STRING, andValue: "2")

        var internTokenList = [tokenNumber2!, tokenGreaterOrEqual!, tokenNumber1!]
        formulaTestHelper.interpretValidFormula(with: internTokenList, description: "1 >= 2", andExpectedResult: true)

        internTokenList = [tokenNumber1!, tokenGreaterOrEqual!, tokenNumber1!]
        formulaTestHelper.interpretValidFormula(with: internTokenList, description: "1 >= 1", andExpectedResult: true)

        internTokenList = [tokenNumber1!, tokenGreaterOrEqual!, tokenNumber2!]
        formulaTestHelper.interpretValidFormula(with: internTokenList, description: "1 >= 2", andExpectedResult: false)

        internTokenList = [tokenString2!, tokenGreaterOrEqual!, tokenString1!]
        formulaTestHelper.interpretValidFormula(with: internTokenList, description: "2 >= 1", andExpectedResult: true)

        internTokenList = [tokenString1!, tokenGreaterOrEqual!, tokenString1!]
        formulaTestHelper.interpretValidFormula(with: internTokenList, description: "1 >= 1", andExpectedResult: true)

        internTokenList = [tokenString1!, tokenGreaterOrEqual!, tokenString2!]
        formulaTestHelper.interpretValidFormula(with: internTokenList, description: "1 >= 2", andExpectedResult: false)
    }

    func testSmallerThan() {
        let tokenSmallerThan = InternToken(type: TOKEN_TYPE_OPERATOR, andValue: SmallerThanOperator.tag)
        let tokenNumber1 = InternToken(type: TOKEN_TYPE_NUMBER, andValue: "1")
        let tokenNumber2 = InternToken(type: TOKEN_TYPE_NUMBER, andValue: "2")
        let tokenString1 = InternToken(type: TOKEN_TYPE_STRING, andValue: "1")
        let tokenString2 = InternToken(type: TOKEN_TYPE_STRING, andValue: "2")

        var internTokenList = [tokenNumber2!, tokenSmallerThan!, tokenNumber1!]
        formulaTestHelper.interpretValidFormula(with: internTokenList, description: "2 < 1", andExpectedResult: false)

        internTokenList = [tokenNumber1!, tokenSmallerThan!, tokenNumber1!]
        formulaTestHelper.interpretValidFormula(with: internTokenList, description: "1 < 1", andExpectedResult: false)

        internTokenList = [tokenNumber1!, tokenSmallerThan!, tokenNumber2!]
        formulaTestHelper.interpretValidFormula(with: internTokenList, description: "1 > 2", andExpectedResult: true)

        internTokenList = [tokenString2!, tokenSmallerThan!, tokenString1!]
        formulaTestHelper.interpretValidFormula(with: internTokenList, description: "2 > 1", andExpectedResult: false)

        internTokenList = [tokenString1!, tokenSmallerThan!, tokenString1!]
        formulaTestHelper.interpretValidFormula(with: internTokenList, description: "1 > 1", andExpectedResult: false)

        internTokenList = [tokenString1!, tokenSmallerThan!, tokenString2!]
        formulaTestHelper.interpretValidFormula(with: internTokenList, description: "1 > 2", andExpectedResult: true)
    }

    func testSmallerOrEqualThan() {
        let tokenSmallerOrEqual = InternToken(type: TOKEN_TYPE_OPERATOR, andValue: SmallerOrEqualOperator.tag)
        let tokenNumber1 = InternToken(type: TOKEN_TYPE_NUMBER, andValue: "1")
        let tokenNumber2 = InternToken(type: TOKEN_TYPE_NUMBER, andValue: "2")
        let tokenString1 = InternToken(type: TOKEN_TYPE_STRING, andValue: "1")
        let tokenString2 = InternToken(type: TOKEN_TYPE_STRING, andValue: "2")

        var internTokenList = [tokenNumber2!, tokenSmallerOrEqual!, tokenNumber1!]
        formulaTestHelper.interpretValidFormula(with: internTokenList, description: "2 <= 1", andExpectedResult: false)

        internTokenList = [tokenNumber1!, tokenSmallerOrEqual!, tokenNumber1!]
        formulaTestHelper.interpretValidFormula(with: internTokenList, description: "1 <= 1", andExpectedResult: true)

        internTokenList = [tokenNumber1!, tokenSmallerOrEqual!, tokenNumber2!]
        formulaTestHelper.interpretValidFormula(with: internTokenList, description: "1 <= 2", andExpectedResult: true)

        internTokenList = [tokenString2!, tokenSmallerOrEqual!, tokenString1!]
        formulaTestHelper.interpretValidFormula(with: internTokenList, description: "2 <= 1", andExpectedResult: false)

        internTokenList = [tokenString1!, tokenSmallerOrEqual!, tokenString1!]
        formulaTestHelper.interpretValidFormula(with: internTokenList, description: "1 <= 1", andExpectedResult: true)

        internTokenList = [tokenString1!, tokenSmallerOrEqual!, tokenString2!]
        formulaTestHelper.interpretValidFormula(with: internTokenList, description: "1 <= 2", andExpectedResult: true)
    }

    func testEqual() {
        let tokenEqual = InternToken(type: TOKEN_TYPE_OPERATOR, andValue: EqualOperator.tag)
        let tokenNumber1 = InternToken(type: TOKEN_TYPE_NUMBER, andValue: "1")
        let tokenString1 = InternToken(type: TOKEN_TYPE_STRING, andValue: "1")
        let tokenString10 = InternToken(type: TOKEN_TYPE_STRING, andValue: "1.0")

        var internTokenList = [tokenNumber1!, tokenEqual!, tokenNumber1!]
        formulaTestHelper.interpretValidFormula(with: internTokenList, description: "1 == 1", andExpectedResult: true)

        internTokenList = [tokenNumber1!, tokenEqual!,
                           InternToken(type: TOKEN_TYPE_NUMBER, andValue: "2")!]
        formulaTestHelper.interpretValidFormula(with: internTokenList, description: "1 == 2", andExpectedResult: false)

        internTokenList = [tokenNumber1!, tokenEqual!, tokenString10!]
        formulaTestHelper.interpretValidFormula(with: internTokenList, description: "1 == 1.0", andExpectedResult: true)

        internTokenList = [tokenString10!, tokenEqual!, tokenNumber1!]
        formulaTestHelper.interpretValidFormula(with: internTokenList, description: "1.0 == 1", andExpectedResult: true)

        internTokenList = [tokenString10!, tokenEqual!,
                           InternToken(type: TOKEN_TYPE_STRING, andValue: "1.9")!]
        formulaTestHelper.interpretValidFormula(with: internTokenList, description: "1.0 == 1.9", andExpectedResult: false)

        internTokenList = [tokenString1!, tokenEqual!, tokenString10!]
        formulaTestHelper.interpretValidFormula(with: internTokenList, description: "1 == 1.0", andExpectedResult: true)

        internTokenList = [tokenString1!, tokenEqual!,
                           InternToken(type: TOKEN_TYPE_NUMBER, andValue: "1.0")!]
        formulaTestHelper.interpretValidFormula(with: internTokenList, description: "1 == 1.0", andExpectedResult: true)

        internTokenList = [InternToken(type: TOKEN_TYPE_STRING, andValue: "equalString")!, tokenEqual!,
                           InternToken(type: TOKEN_TYPE_STRING, andValue: "equalString")!]
        formulaTestHelper.interpretValidFormula(with: internTokenList, description: "equalString == equalString", andExpectedResult: true)

        internTokenList = [InternToken(type: TOKEN_TYPE_STRING, andValue: "!`\"§$%&/()=?")!, tokenEqual!,
                           InternToken(type: TOKEN_TYPE_STRING, andValue: "!`\"§$%&/()=????")!]
        formulaTestHelper.interpretValidFormula(with: internTokenList, description: "!`\"§$%&/()=? == !`\"§$%&/()=????", andExpectedResult: false)

        internTokenList = [InternToken(type: TOKEN_TYPE_STRING, andValue: "555.555")!, tokenEqual!,
                           InternToken(type: TOKEN_TYPE_STRING, andValue: "055.77.77")!]
        formulaTestHelper.interpretValidFormula(with: internTokenList, description: "555.555 == 055.77.77", andExpectedResult: false)
    }

    func testNotEqual() {
        let tokenNotEqual = InternToken(type: TOKEN_TYPE_OPERATOR, andValue: NotEqualOperator.tag)
        let tokenNumber1 = InternToken(type: TOKEN_TYPE_NUMBER, andValue: "1")
        let tokenString1 = InternToken(type: TOKEN_TYPE_STRING, andValue: "1")
        let tokenString10 = InternToken(type: TOKEN_TYPE_STRING, andValue: "1.0")

        var internTokenList = [tokenNumber1!, tokenNotEqual!, tokenNumber1!]
        formulaTestHelper.interpretValidFormula(with: internTokenList, description: "1 != 1", andExpectedResult: false)

        internTokenList = [tokenNumber1!, tokenNotEqual!,
                           InternToken(type: TOKEN_TYPE_NUMBER, andValue: "2")!]
        formulaTestHelper.interpretValidFormula(with: internTokenList, description: "1 != 2", andExpectedResult: true)

        internTokenList = [tokenNumber1!, tokenNotEqual!, tokenString10!]
        formulaTestHelper.interpretValidFormula(with: internTokenList, description: "1 != 1.0", andExpectedResult: false)

        internTokenList = [tokenString10!, tokenNotEqual!, tokenNumber1!]
        formulaTestHelper.interpretValidFormula(with: internTokenList, description: "1.0 != 1", andExpectedResult: false)

        internTokenList = [tokenString10!, tokenNotEqual!,
                           InternToken(type: TOKEN_TYPE_STRING, andValue: "1.9")!]
        formulaTestHelper.interpretValidFormula(with: internTokenList, description: "1.0 != 1.9", andExpectedResult: true)

        internTokenList = [tokenString1!, tokenNotEqual!, tokenString10!]
        formulaTestHelper.interpretValidFormula(with: internTokenList, description: "1 != 1.0", andExpectedResult: false)

        internTokenList = [tokenString1!, tokenNotEqual!,
                           InternToken(type: TOKEN_TYPE_NUMBER, andValue: "1.0")!]
        formulaTestHelper.interpretValidFormula(with: internTokenList, description: "1 != 1.0", andExpectedResult: false)

        internTokenList = [InternToken(type: TOKEN_TYPE_STRING, andValue: "equalString")!, tokenNotEqual!,
                           InternToken(type: TOKEN_TYPE_STRING, andValue: "equalString")!]
        formulaTestHelper.interpretValidFormula(with: internTokenList, description: "equalString != equalString", andExpectedResult: false)

        internTokenList = [InternToken(type: TOKEN_TYPE_STRING, andValue: "!`\"§$%&/()=?")!, tokenNotEqual!,
                           InternToken(type: TOKEN_TYPE_STRING, andValue: "!`\"§$%&/()=????")!]
        formulaTestHelper.interpretValidFormula(with: internTokenList, description: "!`\"§$%&/()=? != !`\"§$%&/()=????", andExpectedResult: true)

        internTokenList = [InternToken(type: TOKEN_TYPE_STRING, andValue: "555.555")!, tokenNotEqual!,
                           InternToken(type: TOKEN_TYPE_STRING, andValue: "055.77.77")!]
        formulaTestHelper.interpretValidFormula(with: internTokenList, description: "555.555 != 055.77.77", andExpectedResult: true)
    }

    func testNot() {
        let tokenNot = InternToken(type: TOKEN_TYPE_OPERATOR, andValue: NotOperator.tag)
        let tokenNumber1 = InternToken(type: TOKEN_TYPE_NUMBER, andValue: "1")
        let tokenNumber0 = InternToken(type: TOKEN_TYPE_NUMBER, andValue: "0")
        let tokenString1 = InternToken(type: TOKEN_TYPE_STRING, andValue: "1")
        let tokenString0 = InternToken(type: TOKEN_TYPE_STRING, andValue: "0")

        var internTokenList = [tokenNot!, tokenNumber1!]
        formulaTestHelper.interpretValidFormula(with: internTokenList, description: "!1", andExpectedResult: false)

        internTokenList = [tokenNot!, tokenNumber0!]
        formulaTestHelper.interpretValidFormula(with: internTokenList, description: "!0", andExpectedResult: true)

        internTokenList = [tokenNot!, tokenString1!]
        formulaTestHelper.interpretValidFormula(with: internTokenList, description: "!1", andExpectedResult: false)

        internTokenList = [tokenNot!, tokenString0!]
        formulaTestHelper.interpretValidFormula(with: internTokenList, description: "!0", andExpectedResult: true)
    }

    func testAnd() {
        let tokenAnd = InternToken(type: TOKEN_TYPE_OPERATOR, andValue: AndOperator.tag)
        let tokenNumber0 = InternToken(type: TOKEN_TYPE_NUMBER, andValue: "0")
        let tokenNumber1 = InternToken(type: TOKEN_TYPE_NUMBER, andValue: "1")
        let tokenString0 = InternToken(type: TOKEN_TYPE_STRING, andValue: "0")
        let tokenString1 = InternToken(type: TOKEN_TYPE_STRING, andValue: "1")

        var internTokenList = [tokenNumber0!, tokenAnd!, tokenNumber0!]
        formulaTestHelper.interpretValidFormula(with: internTokenList, description: "0 && 0", andExpectedResult: 0)

        internTokenList = [tokenNumber1!, tokenAnd!, tokenNumber0!]
        formulaTestHelper.interpretValidFormula(with: internTokenList, description: "1 && 0", andExpectedResult: 0)

        internTokenList = [tokenNumber1!, tokenAnd!, tokenNumber1!]
        formulaTestHelper.interpretValidFormula(with: internTokenList, description: "1 && 1", andExpectedResult: 1)

        internTokenList = [tokenString0!, tokenAnd!, tokenString0!]
        formulaTestHelper.interpretValidFormula(with: internTokenList, description: "0 && 0", andExpectedResult: 0)

        internTokenList = [tokenString0!, tokenAnd!, tokenString1!]
        formulaTestHelper.interpretValidFormula(with: internTokenList, description: "0 && 1", andExpectedResult: 0)

        internTokenList = [tokenString1!, tokenAnd!, tokenString1!]
        formulaTestHelper.interpretValidFormula(with: internTokenList, description: "1 && 1", andExpectedResult: 1)

        internTokenList = [tokenNumber0!, tokenAnd!, tokenString0!]
        formulaTestHelper.interpretValidFormula(with: internTokenList, description: "0 && 0", andExpectedResult: 0)

        internTokenList = [tokenString1!, tokenAnd!, tokenNumber0!]
        formulaTestHelper.interpretValidFormula(with: internTokenList, description: "1 && 0", andExpectedResult: 0)
    }

    func testOr() {
        let tokenOr = InternToken(type: TOKEN_TYPE_OPERATOR, andValue: OrOperator.tag)
        let tokenNumber0 = InternToken(type: TOKEN_TYPE_NUMBER, andValue: "0")
        let tokenNumber1 = InternToken(type: TOKEN_TYPE_NUMBER, andValue: "1")
        let tokenString0 = InternToken(type: TOKEN_TYPE_STRING, andValue: "0")
        let tokenString1 = InternToken(type: TOKEN_TYPE_STRING, andValue: "1")

        var internTokenList = [tokenNumber0!, tokenOr!, tokenNumber0!]
        formulaTestHelper.interpretValidFormula(with: internTokenList, description: "0 || 0", andExpectedResult: 0)

        internTokenList = [tokenNumber1!, tokenOr!, tokenNumber0!]
        formulaTestHelper.interpretValidFormula(with: internTokenList, description: "1 || 0", andExpectedResult: 1)

        internTokenList = [tokenNumber1!, tokenOr!, tokenNumber1!]
        formulaTestHelper.interpretValidFormula(with: internTokenList, description: "1 || 1", andExpectedResult: 1)

        internTokenList = [tokenString0!, tokenOr!, tokenString0!]
        formulaTestHelper.interpretValidFormula(with: internTokenList, description: "0 || 0", andExpectedResult: 0)

        internTokenList = [tokenString0!, tokenOr!, tokenString1!]
        formulaTestHelper.interpretValidFormula(with: internTokenList, description: "0 || 1", andExpectedResult: 1)

        internTokenList = [tokenString1!, tokenOr!, tokenString1!]
        formulaTestHelper.interpretValidFormula(with: internTokenList, description: "1 || 1", andExpectedResult: 1)

        internTokenList = [tokenNumber0!, tokenOr!, tokenString0!]
        formulaTestHelper.interpretValidFormula(with: internTokenList, description: "0 || 0", andExpectedResult: 0)

        internTokenList = [tokenString1!, tokenOr!, tokenNumber0!]
        formulaTestHelper.interpretValidFormula(with: internTokenList, description: "1 || 0", andExpectedResult: 1)
       }

    func testPlus() {
        let result = 4.3
        let tokenPlus = InternToken(type: TOKEN_TYPE_OPERATOR, andValue: PlusOperator.tag)
        let tokenNumber13 = InternToken(type: TOKEN_TYPE_NUMBER, andValue: "1.3")
        let tokenNumber3 = InternToken(type: TOKEN_TYPE_NUMBER, andValue: "3")
        let tokenString13 = InternToken(type: TOKEN_TYPE_STRING, andValue: "1.3")
        let tokenString3 = InternToken(type: TOKEN_TYPE_STRING, andValue: "3")

        var internTokenList = [tokenNumber13!, tokenPlus!, tokenNumber3!]
        formulaTestHelper.interpretValidFormula(with: internTokenList, description: "1.3 + 3", andExpectedResult: result)

        internTokenList = [tokenString13!, tokenPlus!, tokenString3!]
        formulaTestHelper.interpretValidFormula(with: internTokenList, description: "1.3 + 3", andExpectedResult: result)

        internTokenList = [tokenNumber13!, tokenPlus!, tokenString3!]
        formulaTestHelper.interpretValidFormula(with: internTokenList, description: "1.3 + 3", andExpectedResult: result)

        internTokenList = [tokenString13!, tokenPlus!, tokenNumber3!]
        formulaTestHelper.interpretValidFormula(with: internTokenList, description: "1.3 + 3", andExpectedResult: result)

        internTokenList = [InternToken(type: TOKEN_TYPE_STRING, andValue: "NotANumber")!, tokenPlus!,
                           InternToken(type: TOKEN_TYPE_NUMBER, andValue: "3.14")!]
        formulaTestHelper.interpretValidFormula(with: internTokenList, description: "NotANumber + 3.14", andExpectedResult: "nan")
    }

    func testDivision() {
        let result = 4.5
        let tokenDivide = InternToken(type: TOKEN_TYPE_OPERATOR, andValue: DivideOperator.tag)
        let tokenNumber9 = InternToken(type: TOKEN_TYPE_NUMBER, andValue: "9.0")
        let tokenNumber2 = InternToken(type: TOKEN_TYPE_NUMBER, andValue: "2")
        let tokenString9 = InternToken(type: TOKEN_TYPE_STRING, andValue: "9.0")
        let tokenString2 = InternToken(type: TOKEN_TYPE_STRING, andValue: "2")

        var internTokenList = [tokenNumber9!, tokenDivide!, tokenNumber2!]
        formulaTestHelper.interpretValidFormula(with: internTokenList, description: "9 / 2", andExpectedResult: result)

        internTokenList = [tokenString9!, tokenDivide!, tokenString2!]
        formulaTestHelper.interpretValidFormula(with: internTokenList, description: "9 / 2", andExpectedResult: result)

        internTokenList = [tokenNumber9!, tokenDivide!, tokenString2!]
        formulaTestHelper.interpretValidFormula(with: internTokenList, description: "9 / 2", andExpectedResult: result)

        internTokenList = [tokenString9!, tokenDivide!, tokenNumber2!]
        formulaTestHelper.interpretValidFormula(with: internTokenList, description: "9 / 2", andExpectedResult: result)

        internTokenList = [InternToken(type: TOKEN_TYPE_STRING, andValue: "NotANumber")!, tokenDivide!,
                           InternToken(type: TOKEN_TYPE_NUMBER, andValue: "3.14")!]
        formulaTestHelper.interpretValidFormula(with: internTokenList, description: "NotANumber / 3.14", andExpectedResult: "nan")
    }

    func testMultiplication() {
        let result = 18
        let tokenMult = InternToken(type: TOKEN_TYPE_OPERATOR, andValue: MultOperator.tag)
        let tokenNumber9 = InternToken(type: TOKEN_TYPE_NUMBER, andValue: "9.0")
        let tokenNumber2 = InternToken(type: TOKEN_TYPE_NUMBER, andValue: "2")
        let tokenString9 = InternToken(type: TOKEN_TYPE_STRING, andValue: "9.0")
        let tokenString2 = InternToken(type: TOKEN_TYPE_STRING, andValue: "2")

        var internTokenList = [tokenNumber9!, tokenMult!, tokenNumber2!]
        formulaTestHelper.interpretValidFormula(with: internTokenList, description: "9 * 2", andExpectedResult: result)

        internTokenList = [tokenString9!, tokenMult!, tokenString2!]
        formulaTestHelper.interpretValidFormula(with: internTokenList, description: "9 * 2", andExpectedResult: result)

        internTokenList = [tokenNumber9!, tokenMult!, tokenString2!]
        formulaTestHelper.interpretValidFormula(with: internTokenList, description: "9 * 2", andExpectedResult: result)

        internTokenList = [tokenString9!, tokenMult!, tokenNumber2!]
        formulaTestHelper.interpretValidFormula(with: internTokenList, description: "9 * 2", andExpectedResult: result)

        internTokenList = [InternToken(type: TOKEN_TYPE_STRING, andValue: "NotANumber")!, tokenMult!,
                           InternToken(type: TOKEN_TYPE_NUMBER, andValue: "3.14")!]
        formulaTestHelper.interpretValidFormula(with: internTokenList, description: "NotANumber / 3.14", andExpectedResult: "nan")
    }

    func testMinus() {
        let result = 7
        let tokenMinus = InternToken(type: TOKEN_TYPE_OPERATOR, andValue: MinusOperator.tag)
        let tokenNumber9 = InternToken(type: TOKEN_TYPE_NUMBER, andValue: "9.0")
        let tokenNumber2 = InternToken(type: TOKEN_TYPE_NUMBER, andValue: "2")
        let tokenString9 = InternToken(type: TOKEN_TYPE_STRING, andValue: "9.0")
        let tokenString2 = InternToken(type: TOKEN_TYPE_STRING, andValue: "2")

        var internTokenList = [tokenNumber9!, tokenMinus!, tokenNumber2!]
        formulaTestHelper.interpretValidFormula(with: internTokenList, description: "9 - 2", andExpectedResult: result)

        internTokenList = [tokenString9!, tokenMinus!, tokenString2!]
        formulaTestHelper.interpretValidFormula(with: internTokenList, description: "9 - 2", andExpectedResult: result)

        internTokenList = [tokenNumber9!, tokenMinus!, tokenString2!]
        formulaTestHelper.interpretValidFormula(with: internTokenList, description: "9 - 2", andExpectedResult: result)

        internTokenList = [tokenString9!, tokenMinus!, tokenNumber2!]
        formulaTestHelper.interpretValidFormula(with: internTokenList, description: "9 - 2", andExpectedResult: result)

        internTokenList = [InternToken(type: TOKEN_TYPE_STRING, andValue: "NotANumber")!, tokenMinus!,
                           InternToken(type: TOKEN_TYPE_NUMBER, andValue: "3.14")!]
        formulaTestHelper.interpretValidFormula(with: internTokenList, description: "NotANumber - 3.14", andExpectedResult: "nan")
    }
}
