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

class FormulaParserErrorDetectionTest: XCTestCase {

    var formulaTestHelper: FormulaTestHelper!

    override func setUp() {
        super.setUp()
        formulaTestHelper = FormulaTestHelper()
    }

    func testTooManyOperators() {
        var internTokenList = [InternToken(type: TOKEN_TYPE_OPERATOR, andValue: MinusOperator.tag)!,
                               InternToken(type: TOKEN_TYPE_OPERATOR, andValue: MinusOperator.tag)!,
                               InternToken(type: TOKEN_TYPE_NUMBER, andValue: "42.42")!]
        formulaTestHelper.interpretInvalidFormula(with: internTokenList, description: "Invalid formula parsed: - - 42.42", andExpectedErrorCode: 1)

        internTokenList = [InternToken(type: TOKEN_TYPE_OPERATOR, andValue: PlusOperator.tag)]
        formulaTestHelper.interpretInvalidFormula(with: internTokenList, description: "Invalid formula parsed: +", andExpectedErrorCode: 0)

        internTokenList = [InternToken(type: TOKEN_TYPE_OPERATOR, andValue: MinusOperator.tag)!,
                           InternToken(type: TOKEN_TYPE_OPERATOR, andValue: PlusOperator.tag)!]
        formulaTestHelper.interpretInvalidFormula(with: internTokenList, description: "Invalid formula parsed: + -", andExpectedErrorCode: 1)

        internTokenList = [InternToken(type: TOKEN_TYPE_OPERATOR, andValue: MultOperator.tag)!,
                           InternToken(type: TOKEN_TYPE_NUMBER, andValue: "42.53")!]
        formulaTestHelper.interpretInvalidFormula(with: internTokenList, description: "Invalid formula parsed: * 42.53", andExpectedErrorCode: 0)

        internTokenList = [InternToken(type: TOKEN_TYPE_OPERATOR, andValue: MinusOperator.tag)!,
                           InternToken(type: TOKEN_TYPE_NUMBER, andValue: "42.42")!,
                           InternToken(type: TOKEN_TYPE_OPERATOR, andValue: MinusOperator.tag)!,
                           InternToken(type: TOKEN_TYPE_NUMBER, andValue: "42.42")!,
                           InternToken(type: TOKEN_TYPE_OPERATOR, andValue: MinusOperator.tag)!]
        formulaTestHelper.interpretInvalidFormula(with: internTokenList, description: "Invalid formula parsed: - 42.42 - 42.42 -", andExpectedErrorCode: 5)
    }

    func testOperatorMissing() {
        let internTokenList = [InternToken(type: TOKEN_TYPE_NUMBER, andValue: "42.53")!,
                               InternToken(type: TOKEN_TYPE_NUMBER, andValue: "42.42")!]
        formulaTestHelper.interpretInvalidFormula(with: internTokenList, description: "Invalid formula parsed: 42.53 42.42", andExpectedErrorCode: 1)
    }

    func testNumberMissing() {
        let internTokenList = [InternToken(type: TOKEN_TYPE_OPERATOR, andValue: MultOperator.tag)!,
                               InternToken(type: TOKEN_TYPE_NUMBER, andValue: "42.53")!]
        formulaTestHelper.interpretInvalidFormula(with: internTokenList, description: "Invalid formula parsed: * 42.53", andExpectedErrorCode: 0)
    }

    func testRightBracketMissing() {
        let internTokenList = [InternToken(type: TOKEN_TYPE_BRACKET_OPEN)!,
                               InternToken(type: TOKEN_TYPE_NUMBER, andValue: "42.53")!]
        formulaTestHelper.interpretInvalidFormula(with: internTokenList, description: "Invalid formula parsed: (42.53", andExpectedErrorCode: 2)
    }

    func testLeftBracketMissing() {
        let internTokenList = [InternToken(type: TOKEN_TYPE_NUMBER, andValue: "42.53")!,
                               InternToken(type: TOKEN_TYPE_BRACKET_CLOSE)!]
        formulaTestHelper.interpretInvalidFormula(with: internTokenList, description: "Invalid formula parsed: 42.53)", andExpectedErrorCode: 1)
    }

    func testOutOfBound() {
        let internTokenList = [InternToken(type: TOKEN_TYPE_NUMBER, andValue: "42.53")!,
                               InternToken(type: TOKEN_TYPE_BRACKET_CLOSE)!]
        formulaTestHelper.interpretInvalidFormula(with: internTokenList, description: "Invalid formula parsed: 42.53)", andExpectedErrorCode: 1)
    }
}
