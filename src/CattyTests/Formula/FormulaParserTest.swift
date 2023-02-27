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

final class FormulaParserTest: XCTestCase {

    var formulaManager: FormulaManager!
    var interpreter: FormulaInterpreterProtocol!
    var spriteObject: SpriteObject!

    override func setUp() {
        super.setUp()
        let screenSize = Util.screenSize(true)
        formulaManager = FormulaManager(stageSize: screenSize, landscapeMode: false)
        interpreter = formulaManager
        spriteObject = SpriteObject()
    }

    func interpretInvalidFormula(with internTokenList: [InternToken], description: String, andExpectedErrorCode errorCode: Int32) {
        let internParser = InternFormulaParser(tokens: internTokenList, andFormulaManager: formulaManager)
        let parseTree = internParser?.parseFormula(for: nil)
        XCTAssertNil(parseTree, "Parsed invalid formula " + description)

        XCTAssertEqual(errorCode, internParser?.errorTokenIndex, "Invalid error code for formula " + description)
    }

    func interpretValidFormula(with internTokenList: [InternToken], description: String, andExpectedResult result: Double) {
        let internParser = InternFormulaParser(tokens: internTokenList, andFormulaManager: formulaManager)
        let parseTree = internParser?.parseFormula(for: nil)
        XCTAssertNotNil(parseTree, "Could not parse formula " + description)

        let formula = Formula(formulaElement: parseTree)
        XCTAssertEqual(result, interpreter.interpretDouble(formula!, for: spriteObject), "Invalid result for formula " + description)
    }

    func testEmptyInput() {
        let internTokenList = [InternToken]()
        interpretInvalidFormula(with: internTokenList, description: "<EMPTY FORMULA>", andExpectedErrorCode: FORMULA_PARSER_NO_INPUT.rawValue)
    }

    func testInvalidInput() {
        var internTokenList = [InternToken]()
        internTokenList.append(InternToken(type: TOKEN_TYPE_NUMBER, andValue: ""))
        interpretInvalidFormula(with: internTokenList, description: "<EMPTY NUMBER>", andExpectedErrorCode: 0)

        internTokenList.removeAll()
        internTokenList.append(InternToken(type: TOKEN_TYPE_NUMBER, andValue: "."))
        interpretInvalidFormula(with: internTokenList, description: ".", andExpectedErrorCode: 0)

        internTokenList.removeAll()
        internTokenList.append(InternToken(type: TOKEN_TYPE_NUMBER, andValue: ".1"))
        interpretInvalidFormula(with: internTokenList, description: ".1", andExpectedErrorCode: 0)
    }

    func testNumbers() {
        var internTokenList = [InternToken]()
        internTokenList.append(InternToken(type: TOKEN_TYPE_NUMBER, andValue: "1.0"))
        interpretValidFormula(with: internTokenList, description: "1.0", andExpectedResult: 1.0)

        internTokenList.removeAll()
        internTokenList.append(InternToken(type: TOKEN_TYPE_NUMBER, andValue: "1"))
        interpretValidFormula(with: internTokenList, description: "1", andExpectedResult: 1.0)
    }

    func testUnaryMinus() {
        var internTokenList = [InternToken]()
        internTokenList.append(InternToken(type: TOKEN_TYPE_OPERATOR, andValue: MinusOperator.tag))
        internTokenList.append(InternToken(type: TOKEN_TYPE_NUMBER, andValue: "42.42"))
        interpretValidFormula(with: internTokenList, description: "-42.42", andExpectedResult: -42.42)
    }

    func testGreaterOperators() {
        var internTokenList = [InternToken]()
        internTokenList.append(InternToken(type: TOKEN_TYPE_NUMBER, andValue: "2"))
        internTokenList.append(InternToken(type: TOKEN_TYPE_OPERATOR, andValue: GreaterThanOperator.tag))
        internTokenList.append(InternToken(type: TOKEN_TYPE_NUMBER, andValue: "1"))
        interpretValidFormula(with: internTokenList, description: "2 > 1", andExpectedResult: 1.0)

        internTokenList.removeAll()
        internTokenList.append(InternToken(type: TOKEN_TYPE_NUMBER, andValue: "1"))
        internTokenList.append(InternToken(type: TOKEN_TYPE_OPERATOR, andValue: GreaterThanOperator.tag))
        internTokenList.append(InternToken(type: TOKEN_TYPE_NUMBER, andValue: "1"))
        interpretValidFormula(with: internTokenList, description: "1 > 1", andExpectedResult: 0.0)

        internTokenList.removeAll()
        internTokenList.append(InternToken(type: TOKEN_TYPE_NUMBER, andValue: "1"))
        internTokenList.append(InternToken(type: TOKEN_TYPE_OPERATOR, andValue: GreaterOrEqualOperator.tag))
        internTokenList.append(InternToken(type: TOKEN_TYPE_NUMBER, andValue: "1"))
        interpretValidFormula(with: internTokenList, description: "1 >= 1", andExpectedResult: 1.0)

        internTokenList.removeAll()
        internTokenList.append(InternToken(type: TOKEN_TYPE_NUMBER, andValue: "1"))
        internTokenList.append(InternToken(type: TOKEN_TYPE_OPERATOR, andValue: GreaterOrEqualOperator.tag))
        internTokenList.append(InternToken(type: TOKEN_TYPE_NUMBER, andValue: "2"))
        interpretValidFormula(with: internTokenList, description: "1 >= 2", andExpectedResult: 0.0)
    }

    func testSmallerOperators() {
        var internTokenList = [InternToken]()
        internTokenList.append(InternToken(type: TOKEN_TYPE_NUMBER, andValue: "1"))
        internTokenList.append(InternToken(type: TOKEN_TYPE_OPERATOR, andValue: SmallerThanOperator.tag))
        internTokenList.append(InternToken(type: TOKEN_TYPE_NUMBER, andValue: "2"))
        interpretValidFormula(with: internTokenList, description: "1 < 2", andExpectedResult: 1.0)

        internTokenList.removeAll()
        internTokenList.append(InternToken(type: TOKEN_TYPE_NUMBER, andValue: "1"))
        internTokenList.append(InternToken(type: TOKEN_TYPE_OPERATOR, andValue: SmallerThanOperator.tag))
        internTokenList.append(InternToken(type: TOKEN_TYPE_NUMBER, andValue: "1"))
        interpretValidFormula(with: internTokenList, description: "1 < 1", andExpectedResult: 0.0)

        internTokenList.removeAll()
        internTokenList.append(InternToken(type: TOKEN_TYPE_NUMBER, andValue: "1"))
        internTokenList.append(InternToken(type: TOKEN_TYPE_OPERATOR, andValue: SmallerOrEqualOperator.tag))
        internTokenList.append(InternToken(type: TOKEN_TYPE_NUMBER, andValue: "1"))
        interpretValidFormula(with: internTokenList, description: "1 <= 1", andExpectedResult: 1.0)

        internTokenList.removeAll()
        internTokenList.append(InternToken(type: TOKEN_TYPE_NUMBER, andValue: "2"))
        internTokenList.append(InternToken(type: TOKEN_TYPE_OPERATOR, andValue: SmallerOrEqualOperator.tag))
        internTokenList.append(InternToken(type: TOKEN_TYPE_NUMBER, andValue: "1"))
        interpretValidFormula(with: internTokenList, description: "2 <= 1", andExpectedResult: 0.0)
    }

    func testEqualOperators() {
        var internTokenList = [InternToken]()
        internTokenList.append(InternToken(type: TOKEN_TYPE_NUMBER, andValue: "1"))
        internTokenList.append(InternToken(type: TOKEN_TYPE_OPERATOR, andValue: EqualOperator.tag))
        internTokenList.append(InternToken(type: TOKEN_TYPE_NUMBER, andValue: "1"))
        interpretValidFormula(with: internTokenList, description: "1 == 1", andExpectedResult: 1.0)

        internTokenList.removeAll()
        internTokenList.append(InternToken(type: TOKEN_TYPE_NUMBER, andValue: "2"))
        internTokenList.append(InternToken(type: TOKEN_TYPE_OPERATOR, andValue: EqualOperator.tag))
        internTokenList.append(InternToken(type: TOKEN_TYPE_NUMBER, andValue: "1"))
        interpretValidFormula(with: internTokenList, description: "2 == 1", andExpectedResult: 0.0)

        internTokenList.removeAll()
        internTokenList.append(InternToken(type: TOKEN_TYPE_NUMBER, andValue: "2"))
        internTokenList.append(InternToken(type: TOKEN_TYPE_OPERATOR, andValue: NotEqualOperator.tag))
        internTokenList.append(InternToken(type: TOKEN_TYPE_NUMBER, andValue: "1"))
        interpretValidFormula(with: internTokenList, description: "2 != 1", andExpectedResult: 1.0)

        internTokenList.removeAll()
        internTokenList.append(InternToken(type: TOKEN_TYPE_NUMBER, andValue: "1"))
        internTokenList.append(InternToken(type: TOKEN_TYPE_OPERATOR, andValue: NotEqualOperator.tag))
        internTokenList.append(InternToken(type: TOKEN_TYPE_NUMBER, andValue: "1"))
        interpretValidFormula(with: internTokenList, description: "1 != 1", andExpectedResult: 0.0)
    }

    func testLogicalOperators() {
        var internTokenList = [InternToken]()
        internTokenList.append(InternToken(type: TOKEN_TYPE_OPERATOR, andValue: NotOperator.tag))
        internTokenList.append(InternToken(type: TOKEN_TYPE_NUMBER, andValue: "0"))
        internTokenList.append(InternToken(type: TOKEN_TYPE_OPERATOR, andValue: AndOperator.tag))
        internTokenList.append(InternToken(type: TOKEN_TYPE_NUMBER, andValue: "1"))
        interpretValidFormula(with: internTokenList, description: "NOT 0 AND 1", andExpectedResult: 1.0)

        internTokenList.removeAll()
        internTokenList.append(InternToken(type: TOKEN_TYPE_OPERATOR, andValue: NotOperator.tag))
        internTokenList.append(InternToken(type: TOKEN_TYPE_NUMBER, andValue: "1"))
        internTokenList.append(InternToken(type: TOKEN_TYPE_OPERATOR, andValue: OrOperator.tag))
        internTokenList.append(InternToken(type: TOKEN_TYPE_NUMBER, andValue: "0"))
        interpretValidFormula(with: internTokenList, description: "NOT 1 OR 0", andExpectedResult: 0.0)

        internTokenList.removeAll()
        internTokenList.append(InternToken(type: TOKEN_TYPE_OPERATOR, andValue: NotOperator.tag))
        internTokenList.append(InternToken(type: TOKEN_TYPE_NUMBER, andValue: "0"))
        internTokenList.append(InternToken(type: TOKEN_TYPE_OPERATOR, andValue: OrOperator.tag))
        internTokenList.append(InternToken(type: TOKEN_TYPE_NUMBER, andValue: "0"))
        interpretValidFormula(with: internTokenList, description: "NOT 0 OR 0", andExpectedResult: 1.0)

        internTokenList.removeAll()
        internTokenList.append(InternToken(type: TOKEN_TYPE_OPERATOR, andValue: NotOperator.tag))
        internTokenList.append(InternToken(type: TOKEN_TYPE_NUMBER, andValue: "0"))
        internTokenList.append(InternToken(type: TOKEN_TYPE_OPERATOR, andValue: AndOperator.tag))
        internTokenList.append(InternToken(type: TOKEN_TYPE_NUMBER, andValue: "0"))
        interpretValidFormula(with: internTokenList, description: "NOT 0 AND 0", andExpectedResult: 0.0)
    }

    func testOperatorPriority() {
        var internTokenList = [InternToken]()
        internTokenList.append(InternToken(type: TOKEN_TYPE_NUMBER, andValue: "1"))
        internTokenList.append(InternToken(type: TOKEN_TYPE_OPERATOR, andValue: MinusOperator.tag))
        internTokenList.append(InternToken(type: TOKEN_TYPE_NUMBER, andValue: "2"))
        internTokenList.append(InternToken(type: TOKEN_TYPE_OPERATOR, andValue: MultOperator.tag))
        internTokenList.append(InternToken(type: TOKEN_TYPE_NUMBER, andValue: "2"))
        interpretValidFormula(with: internTokenList, description: "1 - 2 * 2", andExpectedResult: -3.0)
    }

    func testOperatorLeftBinding() {
        var internTokenList = [InternToken]()
        internTokenList.append(InternToken(type: TOKEN_TYPE_NUMBER, andValue: "5"))
        internTokenList.append(InternToken(type: TOKEN_TYPE_OPERATOR, andValue: MinusOperator.tag))
        internTokenList.append(InternToken(type: TOKEN_TYPE_NUMBER, andValue: "4"))
        internTokenList.append(InternToken(type: TOKEN_TYPE_OPERATOR, andValue: MinusOperator.tag))
        internTokenList.append(InternToken(type: TOKEN_TYPE_NUMBER, andValue: "1"))
        interpretValidFormula(with: internTokenList, description: "5 - 4 - 1", andExpectedResult: 0.0)

        internTokenList.removeAll()
        internTokenList.append(InternToken(type: TOKEN_TYPE_NUMBER, andValue: "100"))
        internTokenList.append(InternToken(type: TOKEN_TYPE_OPERATOR, andValue: DivideOperator.tag))
        internTokenList.append(InternToken(type: TOKEN_TYPE_NUMBER, andValue: "10"))
        internTokenList.append(InternToken(type: TOKEN_TYPE_OPERATOR, andValue: DivideOperator.tag))
        internTokenList.append(InternToken(type: TOKEN_TYPE_NUMBER, andValue: "10"))
        interpretValidFormula(with: internTokenList, description: "100 / 10 / 10", andExpectedResult: 1.0)
    }

    func testOperatorChain() {
        var internTokenList = [InternToken]()
        internTokenList.append(InternToken(type: TOKEN_TYPE_FUNCTION_NAME, andValue: PowerFunction.tag))
        internTokenList.append(InternToken(type: TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_OPEN))
        internTokenList.append(InternToken(type: TOKEN_TYPE_NUMBER, andValue: "1"))
        internTokenList.append(InternToken(type: TOKEN_TYPE_OPERATOR, andValue: PlusOperator.tag))
        internTokenList.append(InternToken(type: TOKEN_TYPE_NUMBER, andValue: "2"))
        internTokenList.append(InternToken(type: TOKEN_TYPE_OPERATOR, andValue: MultOperator.tag))
        internTokenList.append(InternToken(type: TOKEN_TYPE_NUMBER, andValue: "3"))
        internTokenList.append(InternToken(type: TOKEN_TYPE_FUNCTION_PARAMETER_DELIMITER))
        internTokenList.append(InternToken(type: TOKEN_TYPE_NUMBER, andValue: "2"))
        internTokenList.append(InternToken(type: TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_CLOSE))
        internTokenList.append(InternToken(type: TOKEN_TYPE_OPERATOR, andValue: PlusOperator.tag))
        internTokenList.append(InternToken(type: TOKEN_TYPE_NUMBER, andValue: "1"))
        interpretValidFormula(with: internTokenList, description: "(1 + 2 * 3) ^ 2 + 1", andExpectedResult: 50.0)

        internTokenList.removeAll()
        internTokenList.append(InternToken(type: TOKEN_TYPE_NUMBER, andValue: "1"))
        internTokenList.append(InternToken(type: TOKEN_TYPE_OPERATOR, andValue: PlusOperator.tag))
        internTokenList.append(InternToken(type: TOKEN_TYPE_FUNCTION_NAME, andValue: PowerFunction.tag))
        internTokenList.append(InternToken(type: TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_OPEN))
        internTokenList.append(InternToken(type: TOKEN_TYPE_NUMBER, andValue: "2"))
        internTokenList.append(InternToken(type: TOKEN_TYPE_FUNCTION_PARAMETER_DELIMITER))
        internTokenList.append(InternToken(type: TOKEN_TYPE_NUMBER, andValue: "3"))
        internTokenList.append(InternToken(type: TOKEN_TYPE_OPERATOR, andValue: MultOperator.tag))
        internTokenList.append(InternToken(type: TOKEN_TYPE_NUMBER, andValue: "2"))
        internTokenList.append(InternToken(type: TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_CLOSE))
        interpretValidFormula(with: internTokenList, description: "1 + 2 ^ (3 * 2)", andExpectedResult: 65.0)
    }

    func testBrackets() {
        var internTokenList = [InternToken]()
        internTokenList.append(InternToken(type: TOKEN_TYPE_BRACKET_OPEN))
        internTokenList.append(InternToken(type: TOKEN_TYPE_NUMBER, andValue: "1"))
        internTokenList.append(InternToken(type: TOKEN_TYPE_OPERATOR, andValue: PlusOperator.tag))
        internTokenList.append(InternToken(type: TOKEN_TYPE_NUMBER, andValue: "2"))
        internTokenList.append(InternToken(type: TOKEN_TYPE_BRACKET_CLOSE))
        internTokenList.append(InternToken(type: TOKEN_TYPE_OPERATOR, andValue: MultOperator.tag))
        internTokenList.append(InternToken(type: TOKEN_TYPE_BRACKET_OPEN))
        internTokenList.append(InternToken(type: TOKEN_TYPE_NUMBER, andValue: "1"))
        internTokenList.append(InternToken(type: TOKEN_TYPE_OPERATOR, andValue: PlusOperator.tag))
        internTokenList.append(InternToken(type: TOKEN_TYPE_NUMBER, andValue: "2"))
        internTokenList.append(InternToken(type: TOKEN_TYPE_BRACKET_CLOSE))
        interpretValidFormula(with: internTokenList, description: "(1 + 2) * (1 + 2)", andExpectedResult: 9.0)

        internTokenList.removeAll()
        internTokenList.append(InternToken(type: TOKEN_TYPE_OPERATOR, andValue: MinusOperator.tag))
        internTokenList.append(InternToken(type: TOKEN_TYPE_BRACKET_OPEN))
        internTokenList.append(InternToken(type: TOKEN_TYPE_FUNCTION_NAME, andValue: PowerFunction.tag))
        internTokenList.append(InternToken(type: TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_OPEN))
        internTokenList.append(InternToken(type: TOKEN_TYPE_NUMBER, andValue: "1"))
        internTokenList.append(InternToken(type: TOKEN_TYPE_FUNCTION_PARAMETER_DELIMITER))
        internTokenList.append(InternToken(type: TOKEN_TYPE_NUMBER, andValue: "2"))
        internTokenList.append(InternToken(type: TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_CLOSE))
        internTokenList.append(InternToken(type: TOKEN_TYPE_BRACKET_CLOSE))
        internTokenList.append(InternToken(type: TOKEN_TYPE_OPERATOR, andValue: MinusOperator.tag))
        internTokenList.append(InternToken(type: TOKEN_TYPE_OPERATOR, andValue: MinusOperator.tag))
        internTokenList.append(InternToken(type: TOKEN_TYPE_BRACKET_OPEN))
        internTokenList.append(InternToken(type: TOKEN_TYPE_OPERATOR, andValue: MinusOperator.tag))
        internTokenList.append(InternToken(type: TOKEN_TYPE_NUMBER, andValue: "1"))
        internTokenList.append(InternToken(type: TOKEN_TYPE_OPERATOR, andValue: MinusOperator.tag))
        internTokenList.append(InternToken(type: TOKEN_TYPE_OPERATOR, andValue: MinusOperator.tag))
        internTokenList.append(InternToken(type: TOKEN_TYPE_NUMBER, andValue: "2"))
        internTokenList.append(InternToken(type: TOKEN_TYPE_BRACKET_CLOSE))
        interpretValidFormula(with: internTokenList, description: "-(1 ^ 2) - -(-1 - -2)", andExpectedResult: 0.0)
    }

    func testBracketCorrection() {
        var internTokenList = [InternToken]()
        internTokenList.append(InternToken(type: TOKEN_TYPE_FUNCTION_NAME, andValue: AbsFunction.tag))
        internTokenList.append(InternToken(type: TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_OPEN))
        internTokenList.append(InternToken(type: TOKEN_TYPE_NUMBER, andValue: "2"))
        internTokenList.append(InternToken(type: TOKEN_TYPE_OPERATOR, andValue: MultOperator.tag))
        internTokenList.append(InternToken(type: TOKEN_TYPE_BRACKET_OPEN))
        internTokenList.append(InternToken(type: TOKEN_TYPE_NUMBER, andValue: "5"))
        internTokenList.append(InternToken(type: TOKEN_TYPE_OPERATOR, andValue: MinusOperator.tag))
        internTokenList.append(InternToken(type: TOKEN_TYPE_NUMBER, andValue: "10"))
        internTokenList.append(InternToken(type: TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_CLOSE))
        internTokenList.append(InternToken(type: TOKEN_TYPE_BRACKET_CLOSE))
        interpretValidFormula(with: internTokenList, description: "abs(2 * (5 - 10))", andExpectedResult: 10.0)

        internTokenList.removeAll()
        internTokenList.append(InternToken(type: TOKEN_TYPE_NUMBER, andValue: "3"))
        internTokenList.append(InternToken(type: TOKEN_TYPE_OPERATOR, andValue: MultOperator.tag))
        internTokenList.append(InternToken(type: TOKEN_TYPE_BRACKET_OPEN))
        internTokenList.append(InternToken(type: TOKEN_TYPE_NUMBER, andValue: "2"))
        internTokenList.append(InternToken(type: TOKEN_TYPE_OPERATOR, andValue: PlusOperator.tag))
        internTokenList.append(InternToken(type: TOKEN_TYPE_FUNCTION_NAME, andValue: CosFunction.tag))
        internTokenList.append(InternToken(type: TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_OPEN))
        internTokenList.append(InternToken(type: TOKEN_TYPE_NUMBER, andValue: "0"))
        internTokenList.append(InternToken(type: TOKEN_TYPE_BRACKET_CLOSE))
        internTokenList.append(InternToken(type: TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_CLOSE))
        interpretValidFormula(with: internTokenList, description: "3 * (2 + cos(0))", andExpectedResult: 9.0)

        internTokenList.removeAll()
        internTokenList.append(InternToken(type: TOKEN_TYPE_FUNCTION_NAME, andValue: ModFunction.tag))
        internTokenList.append(InternToken(type: TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_OPEN))
        internTokenList.append(InternToken(type: TOKEN_TYPE_NUMBER, andValue: "1"))
        internTokenList.append(InternToken(type: TOKEN_TYPE_FUNCTION_PARAMETER_DELIMITER))
        internTokenList.append(InternToken(type: TOKEN_TYPE_FUNCTION_NAME, andValue: ModFunction.tag))
        internTokenList.append(InternToken(type: TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_OPEN))
        internTokenList.append(InternToken(type: TOKEN_TYPE_NUMBER, andValue: "1"))
        internTokenList.append(InternToken(type: TOKEN_TYPE_FUNCTION_PARAMETER_DELIMITER))
        internTokenList.append(InternToken(type: TOKEN_TYPE_FUNCTION_NAME, andValue: ModFunction.tag))
        internTokenList.append(InternToken(type: TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_OPEN))
        internTokenList.append(InternToken(type: TOKEN_TYPE_NUMBER, andValue: "5"))
        internTokenList.append(InternToken(type: TOKEN_TYPE_FUNCTION_PARAMETER_DELIMITER))
        internTokenList.append(InternToken(type: TOKEN_TYPE_BRACKET_OPEN))
        internTokenList.append(InternToken(type: TOKEN_TYPE_NUMBER, andValue: "3"))
        internTokenList.append(InternToken(type: TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_CLOSE))
        internTokenList.append(InternToken(type: TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_CLOSE))
        internTokenList.append(InternToken(type: TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_CLOSE))
        internTokenList.append(InternToken(type: TOKEN_TYPE_BRACKET_CLOSE))
        interpretValidFormula(with: internTokenList, description: "mod(1, mod(1, mod(5, (3))))", andExpectedResult: 0.0)
    }
}
