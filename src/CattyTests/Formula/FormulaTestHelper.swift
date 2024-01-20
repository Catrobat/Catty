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

class FormulaTestHelper {

    var formulaManager: FormulaManager!
    var interpreter: FormulaInterpreterProtocol!
    var spriteObject: SpriteObject!

    init() {
        let screenSize = Util.screenSize(true)
        formulaManager = FormulaManager(stageSize: screenSize, landscapeMode: false)
        interpreter = formulaManager
        spriteObject = SpriteObject()
    }

    static func mergeOperatorLists(firstList: [InternToken], withOperator operatorTag: String, andSecondList secondList: [InternToken]) -> [InternToken] {
        var result = firstList
        result.append(InternToken(type: TOKEN_TYPE_OPERATOR, andValue: operatorTag))
        result.append(contentsOf: secondList)
        return result
    }

    static func appendOperationToList(internTokenList: [InternToken], withOperator operatorTag: String, andTokenType tokenType: InternTokenType, withValue value: String) -> [InternToken] {
        var result = internTokenList
        result.append(InternToken(type: TOKEN_TYPE_OPERATOR, andValue: operatorTag))
        result.append(InternToken(type: tokenType, andValue: value))
        return result
    }

    func interpretValidFormula<T>(with internTokens: [InternToken], description: String, andExpectedResult result: T) {
        interpretValidFormula(with: internTokens, description: description, andExpectedResult: result, withAccuracy: Optional<T>.none)
    }

    func interpretValidFormula<T, U>(with internTokens: [InternToken], description: String, andExpectedResult result: T, withAccuracy accuracy: U?) {
        let parser = InternFormulaParser(tokens: internTokens, andFormulaManager: formulaManager)
        let parseTree = parser?.parseFormula(for: nil)
        XCTAssertNotNil(parseTree, "Could not parse formula " + description)
        let formula = Formula(formulaElement: parseTree)!

        if accuracy != nil {
            assertFormulaWithAccuracy(formula: formula, withResult: result, withAccuracy: accuracy)
        } else {
            assertFormula(formula: formula, withResult: result)
        }
    }

    private func assertFormula<T>(formula: Formula, withResult result: T) {
        let errorMessage = "Formula interpretation is not as expected!"

        switch type(of: result) {
        case is Int.Type:
            XCTAssertEqual(interpreter.interpretInteger(formula, for: spriteObject), result as! Int, errorMessage)
        case is Double.Type:
            XCTAssertEqual(interpreter.interpretDouble(formula, for: spriteObject), result as! Double, errorMessage)
        case is Float.Type:
            XCTAssertEqual(interpreter.interpretFloat(formula, for: spriteObject), result as! Float, errorMessage)
        case is String.Type:
            XCTAssertEqual(interpreter.interpretString(formula, for: spriteObject), result as! String, errorMessage)
        case is Bool.Type:
            XCTAssertEqual(interpreter.interpretBool(formula, for: spriteObject), result as! Bool, errorMessage)
        default:
            XCTAssertEqual(interpreter.interpretString(formula, for: spriteObject), result as! String, errorMessage)
        }
    }

    private func assertFormulaWithAccuracy<T, U>(formula: Formula, withResult result: T, withAccuracy accuracy: U) {
        let errorMessage = "Formula interpretation is not as expected!"

        switch type(of: result) {
        case is Int.Type:
            XCTAssertEqual(interpreter.interpretInteger(formula, for: spriteObject), result as! Int, accuracy: accuracy as! Int, errorMessage)
        case is Double.Type:
            XCTAssertEqual(interpreter.interpretDouble(formula, for: spriteObject), result as! Double, accuracy: accuracy as! Double, errorMessage)
        case is Float.Type:
            XCTAssertEqual(interpreter.interpretFloat(formula, for: spriteObject), result as! Float, accuracy: accuracy as! Float, errorMessage)
        default:
            XCTAssertEqual(interpreter.interpretString(formula, for: spriteObject), result as! String, errorMessage)
        }
    }

    func interpretInvalidFormula(with internTokenList: [InternToken], description: String, andExpectedErrorCode errorCode: Int32) {
        let internParser = InternFormulaParser(tokens: internTokenList, andFormulaManager: formulaManager)
        let parseTree = internParser?.parseFormula(for: nil)
        XCTAssertNil(parseTree, "Parsed invalid formula " + description)
        XCTAssertEqual(errorCode, internParser?.errorTokenIndex, "Invalid error code for formula " + description)
    }

}
