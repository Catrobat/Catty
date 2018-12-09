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

final class FormulaParserOperatorsTest: XCTestCase {
    var formulaManager: FormulaManager?

    override func setUp() {
        super.setUp()
        formulaManager = FormulaManager(sceneSize: Util.screenSize(true))
    }

    func buildBinaryOperator(_ firstTokenType: InternTokenType, firstValue: String?, with `operator`: Operator, secondTokenType: InternTokenType, secondValue: String?) -> [AnyHashable]? {
        var internTokens: [AnyHashable] = []
        internTokens.append(InternToken(type: firstTokenType, andValue: firstValue))
        internTokens.append(InternToken(type: TOKEN_TYPE_OPERATOR, andValue: Operators.getName(`operator`)))
        internTokens.append(InternToken(type: secondTokenType, andValue: secondValue))

        return internTokens
    }

    func mergeOperatorLists(_ firstList: [AnyHashable]?, with `operator`: Operator, andSecondList secondList: [AnyHashable]?) -> [AnyHashable]? {
        var firstList = firstList
        let secondList = secondList
        firstList?.append(InternToken(type: TOKEN_TYPE_OPERATOR, andValue: Operators.getName(`operator`)))
        if let aList = secondList {
            firstList?.append(contentsOf: aList)
        }

        return firstList
    }

    func appendOperation(toList internTokenList: [AnyHashable]?, with `operator`: Operator, andTokenType tokenType: InternTokenType, withValue value: String?) -> [AnyHashable]? {
        var internTokenList = internTokenList
        internTokenList?.append(InternToken(type: TOKEN_TYPE_OPERATOR, andValue: Operators.getName(`operator`)))
        internTokenList?.append(InternToken(type: tokenType, andValue: value))

        return internTokenList
    }

    func binaryOperatorTest(_ internTokens: [AnyHashable]?, withExpectedResult result: String?) {
        let internTokens = internTokens
        let parser = InternFormulaParser(tokens: (internTokens as! [InternToken]), andFormulaManager: formulaManager)
        let parseTree: FormulaElement? = parser!.parseFormula(for: nil)
        XCTAssertNotNil(parseTree, "Formula is not parsed correctly!")

        let formula = Formula(formulaElement: parseTree)
        //TODO XCTAssertEqual(formulaManager?.interpretInteger(formula!, for: SpriteObject()), Int(result!), "Formula interpretation is not as expected!")
    }

    func testOperatorChain() {
        var firstTerm = buildBinaryOperator(TOKEN_TYPE_NUMBER, firstValue: "1", with: Operator.PLUS, secondTokenType: TOKEN_TYPE_NUMBER, secondValue: "2")
        firstTerm = appendOperation(toList: firstTerm, with: Operator.MULT, andTokenType: TOKEN_TYPE_NUMBER, withValue: "3")
        var secontTerm = buildBinaryOperator(TOKEN_TYPE_NUMBER, firstValue: "2", with: Operator.PLUS, secondTokenType: TOKEN_TYPE_NUMBER, secondValue: "1")
        firstTerm = mergeOperatorLists(firstTerm, with: Operator.MULT, andSecondList: secontTerm)

        binaryOperatorTest(firstTerm, withExpectedResult: "14")

        firstTerm = buildBinaryOperator(TOKEN_TYPE_NUMBER, firstValue: "1", with: Operator.PLUS, secondTokenType: TOKEN_TYPE_NUMBER, secondValue: "2")
        secontTerm = buildBinaryOperator(TOKEN_TYPE_NUMBER, firstValue: "3", with: Operator.MULT, secondTokenType: TOKEN_TYPE_NUMBER, secondValue: "2")
        firstTerm = mergeOperatorLists(firstTerm, with: Operator.MULT, andSecondList: secontTerm)

        binaryOperatorTest(firstTerm, withExpectedResult: "13")
    }

    func testOperatorLeftBinding() {
        var firstTerm = buildBinaryOperator(TOKEN_TYPE_NUMBER, firstValue: "5", with: Operator.MINUS, secondTokenType: TOKEN_TYPE_NUMBER, secondValue: "4")
        _ = appendOperation(toList: firstTerm, with: Operator.MINUS, andTokenType: TOKEN_TYPE_NUMBER, withValue: "1")

        binaryOperatorTest(firstTerm, withExpectedResult: "0")

        firstTerm = buildBinaryOperator(TOKEN_TYPE_NUMBER, firstValue: "100", with: Operator.DIVIDE, secondTokenType: TOKEN_TYPE_NUMBER, secondValue: "10")
        _ = appendOperation(toList: firstTerm, with: Operator.DIVIDE, andTokenType: TOKEN_TYPE_NUMBER, withValue: "10")

        binaryOperatorTest(firstTerm, withExpectedResult: "1")
    }

    func testOperatorPriority() {
        let firstTerm = buildBinaryOperator(TOKEN_TYPE_NUMBER, firstValue: "1", with: Operator.MINUS, secondTokenType: TOKEN_TYPE_NUMBER, secondValue: "2")
        _ = appendOperation(toList: firstTerm, with: Operator.MULT, andTokenType: TOKEN_TYPE_NUMBER, withValue: "2")

        binaryOperatorTest(firstTerm, withExpectedResult: "-3")
    }

    func testUnaryMinus() {
        let internTokenList = NSMutableArray()
        internTokenList.add(InternToken(type: TOKEN_TYPE_OPERATOR, andValue: Operators.getName(Operator.MINUS)))
        internTokenList.add(InternToken(type: TOKEN_TYPE_NUMBER, andValue: "42.42"))

        let internParser = InternFormulaParser(tokens: (internTokenList as! [InternToken]), andFormulaManager: formulaManager)
        let parseTree: FormulaElement? = internParser!.parseFormula(for: nil)
        XCTAssertNotNil(parseTree, "Formula is not parsed correctly: - 42.42")

        let formula = Formula(formulaElement: parseTree)
        XCTAssertEqual(formulaManager?.interpretDouble(formula!, for: SpriteObject()), -42.42, "Formula interpretation is not as expected")
    }

    func testGreaterThan() {
        var firstTerm = buildBinaryOperator(TOKEN_TYPE_NUMBER, firstValue: "2", with: Operator.GREATER_THAN, secondTokenType: TOKEN_TYPE_NUMBER, secondValue: "1")
        binaryOperatorTest(firstTerm, withExpectedResult: "1")

        firstTerm = buildBinaryOperator(TOKEN_TYPE_NUMBER, firstValue: "1", with: Operator.GREATER_THAN, secondTokenType: TOKEN_TYPE_NUMBER, secondValue: "1")
        binaryOperatorTest(firstTerm, withExpectedResult: "0")

        firstTerm = buildBinaryOperator(TOKEN_TYPE_NUMBER, firstValue: "1", with: Operator.GREATER_THAN, secondTokenType: TOKEN_TYPE_NUMBER, secondValue: "2")
        binaryOperatorTest(firstTerm, withExpectedResult: "0")

        var secondTerm = buildBinaryOperator(TOKEN_TYPE_STRING, firstValue: "2", with: Operator.GREATER_THAN, secondTokenType: TOKEN_TYPE_STRING, secondValue: "1")
        binaryOperatorTest(secondTerm, withExpectedResult: "1")

        secondTerm = buildBinaryOperator(TOKEN_TYPE_STRING, firstValue: "1", with: Operator.GREATER_THAN, secondTokenType: TOKEN_TYPE_STRING, secondValue: "1")
        binaryOperatorTest(secondTerm, withExpectedResult: "0")

        secondTerm = buildBinaryOperator(TOKEN_TYPE_STRING, firstValue: "1", with: Operator.GREATER_THAN, secondTokenType: TOKEN_TYPE_STRING, secondValue: "2")
        binaryOperatorTest(secondTerm, withExpectedResult: "0")
    }

    func testGreaterOrEqualThan() {
        var firstTerm = buildBinaryOperator(TOKEN_TYPE_NUMBER, firstValue: "2", with: Operator.GREATER_OR_EQUAL, secondTokenType: TOKEN_TYPE_NUMBER, secondValue: "1")
        binaryOperatorTest(firstTerm, withExpectedResult: "1")

        firstTerm = buildBinaryOperator(TOKEN_TYPE_NUMBER, firstValue: "1", with: Operator.GREATER_OR_EQUAL, secondTokenType: TOKEN_TYPE_NUMBER, secondValue: "1")
        binaryOperatorTest(firstTerm, withExpectedResult: "1")

        firstTerm = buildBinaryOperator(TOKEN_TYPE_NUMBER, firstValue: "1", with: Operator.GREATER_OR_EQUAL, secondTokenType: TOKEN_TYPE_NUMBER, secondValue: "2")
        binaryOperatorTest(firstTerm, withExpectedResult: "0")

        var secondTerm = buildBinaryOperator(TOKEN_TYPE_STRING, firstValue: "2", with: Operator.GREATER_OR_EQUAL, secondTokenType: TOKEN_TYPE_STRING, secondValue: "1")
        binaryOperatorTest(secondTerm, withExpectedResult: "1")

        secondTerm = buildBinaryOperator(TOKEN_TYPE_STRING, firstValue: "1", with: Operator.GREATER_OR_EQUAL, secondTokenType: TOKEN_TYPE_STRING, secondValue: "1")
        binaryOperatorTest(secondTerm, withExpectedResult: "1")

        secondTerm = buildBinaryOperator(TOKEN_TYPE_STRING, firstValue: "1", with: Operator.GREATER_OR_EQUAL, secondTokenType: TOKEN_TYPE_STRING, secondValue: "2")
        binaryOperatorTest(secondTerm, withExpectedResult: "0")
    }

    func testSmallerThan() {
        var firstTerm = buildBinaryOperator(TOKEN_TYPE_NUMBER, firstValue: "2", with: Operator.SMALLER_THAN, secondTokenType: TOKEN_TYPE_NUMBER, secondValue: "1")
        binaryOperatorTest(firstTerm, withExpectedResult: "0")

        firstTerm = buildBinaryOperator(TOKEN_TYPE_NUMBER, firstValue: "1", with: Operator.SMALLER_THAN, secondTokenType: TOKEN_TYPE_NUMBER, secondValue: "1")
        binaryOperatorTest(firstTerm, withExpectedResult: "0")

        firstTerm = buildBinaryOperator(TOKEN_TYPE_NUMBER, firstValue: "1", with: Operator.SMALLER_THAN, secondTokenType: TOKEN_TYPE_NUMBER, secondValue: "2")
        binaryOperatorTest(firstTerm, withExpectedResult: "1")

        var secondTerm = buildBinaryOperator(TOKEN_TYPE_STRING, firstValue: "2", with: Operator.SMALLER_THAN, secondTokenType: TOKEN_TYPE_STRING, secondValue: "1")
        binaryOperatorTest(secondTerm, withExpectedResult: "0")

        secondTerm = buildBinaryOperator(TOKEN_TYPE_STRING, firstValue: "1", with: Operator.SMALLER_THAN, secondTokenType: TOKEN_TYPE_STRING, secondValue: "1")
        binaryOperatorTest(secondTerm, withExpectedResult: "0")

        secondTerm = buildBinaryOperator(TOKEN_TYPE_STRING, firstValue: "1", with: Operator.SMALLER_THAN, secondTokenType: TOKEN_TYPE_STRING, secondValue: "2")
        binaryOperatorTest(secondTerm, withExpectedResult: "1")
    }

    func testSmallerOrEqualThan() {
        var firstTerm = buildBinaryOperator(TOKEN_TYPE_NUMBER, firstValue: "2", with: Operator.SMALLER_OR_EQUAL, secondTokenType: TOKEN_TYPE_NUMBER, secondValue: "1")
        binaryOperatorTest(firstTerm, withExpectedResult: "0")

        firstTerm = buildBinaryOperator(TOKEN_TYPE_NUMBER, firstValue: "1", with: Operator.SMALLER_OR_EQUAL, secondTokenType: TOKEN_TYPE_NUMBER, secondValue: "1")
        binaryOperatorTest(firstTerm, withExpectedResult: "1")

        firstTerm = buildBinaryOperator(TOKEN_TYPE_NUMBER, firstValue: "1", with: Operator.SMALLER_OR_EQUAL, secondTokenType: TOKEN_TYPE_NUMBER, secondValue: "2")
        binaryOperatorTest(firstTerm, withExpectedResult: "1")

        var secondTerm = buildBinaryOperator(TOKEN_TYPE_STRING, firstValue: "2", with: Operator.SMALLER_OR_EQUAL, secondTokenType: TOKEN_TYPE_STRING, secondValue: "1")
        binaryOperatorTest(secondTerm, withExpectedResult: "0")

        secondTerm = buildBinaryOperator(TOKEN_TYPE_STRING, firstValue: "1", with: Operator.SMALLER_OR_EQUAL, secondTokenType: TOKEN_TYPE_STRING, secondValue: "1")
        binaryOperatorTest(secondTerm, withExpectedResult: "1")

        secondTerm = buildBinaryOperator(TOKEN_TYPE_STRING, firstValue: "1", with: Operator.SMALLER_OR_EQUAL, secondTokenType: TOKEN_TYPE_STRING, secondValue: "2")
        binaryOperatorTest(secondTerm, withExpectedResult: "1")
    }

    func testEqual() {
        var firstTerm = buildBinaryOperator(TOKEN_TYPE_NUMBER, firstValue: "1", with: Operator.EQUAL, secondTokenType: TOKEN_TYPE_NUMBER, secondValue: "1")
        binaryOperatorTest(firstTerm, withExpectedResult: "1")

        firstTerm = buildBinaryOperator(TOKEN_TYPE_NUMBER, firstValue: "1", with: Operator.EQUAL, secondTokenType: TOKEN_TYPE_NUMBER, secondValue: "5")
        binaryOperatorTest(firstTerm, withExpectedResult: "0")

        firstTerm = buildBinaryOperator(TOKEN_TYPE_NUMBER, firstValue: "1", with: Operator.EQUAL, secondTokenType: TOKEN_TYPE_STRING, secondValue: "1.0")
        binaryOperatorTest(firstTerm, withExpectedResult: "1")

        firstTerm = buildBinaryOperator(TOKEN_TYPE_NUMBER, firstValue: "1.0", with: Operator.EQUAL, secondTokenType: TOKEN_TYPE_STRING, secondValue: "1")
        binaryOperatorTest(firstTerm, withExpectedResult: "1")

        firstTerm = buildBinaryOperator(TOKEN_TYPE_STRING, firstValue: "1.0", with: Operator.EQUAL, secondTokenType: TOKEN_TYPE_NUMBER, secondValue: "1.9")
        binaryOperatorTest(firstTerm, withExpectedResult: "0")

        var secondTerm = buildBinaryOperator(TOKEN_TYPE_STRING, firstValue: "equalString", with: Operator.EQUAL, secondTokenType: TOKEN_TYPE_STRING, secondValue: "equalString")
        binaryOperatorTest(secondTerm, withExpectedResult: "1")

        secondTerm = buildBinaryOperator(TOKEN_TYPE_STRING, firstValue: "1", with: Operator.EQUAL, secondTokenType: TOKEN_TYPE_STRING, secondValue: "1.0")
        binaryOperatorTest(secondTerm, withExpectedResult: "0")

        secondTerm = buildBinaryOperator(TOKEN_TYPE_STRING, firstValue: "1", with: Operator.EQUAL, secondTokenType: TOKEN_TYPE_NUMBER, secondValue: "1.0")
        binaryOperatorTest(secondTerm, withExpectedResult: "1")

        secondTerm = buildBinaryOperator(TOKEN_TYPE_STRING, firstValue: "!`\"§$%&/()=?", with: Operator.EQUAL, secondTokenType: TOKEN_TYPE_STRING, secondValue: "!`\"§$%&/()=????")
        binaryOperatorTest(secondTerm, withExpectedResult: "0")

        secondTerm = buildBinaryOperator(TOKEN_TYPE_STRING, firstValue: "555.555", with: Operator.EQUAL, secondTokenType: TOKEN_TYPE_STRING, secondValue: "055.77.77")
        binaryOperatorTest(secondTerm, withExpectedResult: "0")
    }

    func testNotEqual() {
        var firstTerm = buildBinaryOperator(TOKEN_TYPE_NUMBER, firstValue: "1", with: Operator.NOT_EQUAL, secondTokenType: TOKEN_TYPE_NUMBER, secondValue: "1")
        binaryOperatorTest(firstTerm, withExpectedResult: "0")

        firstTerm = buildBinaryOperator(TOKEN_TYPE_NUMBER, firstValue: "1", with: Operator.NOT_EQUAL, secondTokenType: TOKEN_TYPE_NUMBER, secondValue: "5")
        binaryOperatorTest(firstTerm, withExpectedResult: "1")

        firstTerm = buildBinaryOperator(TOKEN_TYPE_NUMBER, firstValue: "1", with: Operator.NOT_EQUAL, secondTokenType: TOKEN_TYPE_STRING, secondValue: "1.0")
        binaryOperatorTest(firstTerm, withExpectedResult: "0")

        firstTerm = buildBinaryOperator(TOKEN_TYPE_NUMBER, firstValue: "1.0", with: Operator.NOT_EQUAL, secondTokenType: TOKEN_TYPE_STRING, secondValue: "1")
        binaryOperatorTest(firstTerm, withExpectedResult: "0")

        firstTerm = buildBinaryOperator(TOKEN_TYPE_STRING, firstValue: "1.0", with: Operator.NOT_EQUAL, secondTokenType: TOKEN_TYPE_NUMBER, secondValue: "1.9")
        binaryOperatorTest(firstTerm, withExpectedResult: "1")

        var secondTerm = buildBinaryOperator(TOKEN_TYPE_STRING, firstValue: "equalString", with: Operator.NOT_EQUAL, secondTokenType: TOKEN_TYPE_STRING, secondValue: "equalString")
        binaryOperatorTest(secondTerm, withExpectedResult: "0")

        secondTerm = buildBinaryOperator(TOKEN_TYPE_STRING, firstValue: "1", with: Operator.NOT_EQUAL, secondTokenType: TOKEN_TYPE_STRING, secondValue: "1.0")
        binaryOperatorTest(secondTerm, withExpectedResult: "1")

        secondTerm = buildBinaryOperator(TOKEN_TYPE_STRING, firstValue: "!`\"§$%&/()=?", with: Operator.NOT_EQUAL, secondTokenType: TOKEN_TYPE_STRING, secondValue: "!`\"§$%&/()=????")
        binaryOperatorTest(secondTerm, withExpectedResult: "1")

        secondTerm = buildBinaryOperator(TOKEN_TYPE_STRING, firstValue: "555.555", with: Operator.NOT_EQUAL, secondTokenType: TOKEN_TYPE_STRING, secondValue: "055.77.77")
        binaryOperatorTest(secondTerm, withExpectedResult: "1")

        secondTerm = buildBinaryOperator(TOKEN_TYPE_STRING, firstValue: "1,555.555", with: Operator.NOT_EQUAL, secondTokenType: TOKEN_TYPE_STRING, secondValue: "1555.555")
        binaryOperatorTest(secondTerm, withExpectedResult: "1")
    }

    func testNot() {
        var internTokenList = NSMutableArray()
        internTokenList.add(InternToken(type: TOKEN_TYPE_OPERATOR, andValue: Operators.getName(Operator.LOGICAL_NOT)))
        internTokenList.add(InternToken(type: TOKEN_TYPE_NUMBER, andValue: "1"))

        var internParser = InternFormulaParser(tokens: (internTokenList as! [InternToken]), andFormulaManager: formulaManager)
        var parseTree: FormulaElement? = internParser!.parseFormula(for: nil)
        XCTAssertNotNil(parseTree, "Formula is not parsed correctly!")

        var formula = Formula(formulaElement: parseTree)
        XCTAssertEqual(0.0, formulaManager?.interpretDouble(formula!, for: SpriteObject()))

        internTokenList = NSMutableArray()
        internTokenList.add(InternToken(type: TOKEN_TYPE_OPERATOR, andValue: Operators.getName(Operator.LOGICAL_NOT)))
        internTokenList.add(InternToken(type: TOKEN_TYPE_NUMBER, andValue: "0"))

        internParser = InternFormulaParser(tokens: (internTokenList as! [InternToken]), andFormulaManager: formulaManager)
        parseTree = internParser!.parseFormula(for: nil)
        XCTAssertNotNil(parseTree, "Formula is not parsed correctly!")

        formula = Formula(formulaElement: parseTree)
        XCTAssertEqual(formulaManager?.interpretDouble(formula!, for: SpriteObject()), 1.0)

        internTokenList = NSMutableArray()
        internTokenList.add(InternToken(type: TOKEN_TYPE_OPERATOR, andValue: Operators.getName(Operator.LOGICAL_NOT)))
        internTokenList.add(InternToken(type: TOKEN_TYPE_STRING, andValue: "1"))

        internParser = InternFormulaParser(tokens: (internTokenList as! [InternToken]), andFormulaManager: formulaManager)
        parseTree = internParser!.parseFormula(for: nil)
        XCTAssertNotNil(parseTree, "Formula is not parsed correctly!")

        formula = Formula(formulaElement: parseTree)
        XCTAssertEqual(0.0, formulaManager?.interpretDouble(formula!, for: SpriteObject()))

        internTokenList = NSMutableArray()
        internTokenList.add(InternToken(type: TOKEN_TYPE_OPERATOR, andValue: Operators.getName(Operator.LOGICAL_NOT)))
        internTokenList.add(InternToken(type: TOKEN_TYPE_STRING, andValue: "0"))

        internParser = InternFormulaParser(tokens: (internTokenList as! [InternToken]), andFormulaManager: formulaManager)
        parseTree = internParser!.parseFormula(for: nil)
        XCTAssertNotNil(parseTree, "Formula is not parsed correctly!")

        formula = Formula(formulaElement: parseTree)
        XCTAssertEqual(1.0, formulaManager?.interpretDouble(formula!, for: SpriteObject()))
    }

    func testAnd() {
        var firstTerm = buildBinaryOperator(TOKEN_TYPE_NUMBER, firstValue: "0", with: Operator.LOGICAL_AND, secondTokenType: TOKEN_TYPE_NUMBER, secondValue: "0")
        binaryOperatorTest(firstTerm, withExpectedResult: "0")

        firstTerm = buildBinaryOperator(TOKEN_TYPE_NUMBER, firstValue: "1", with: Operator.LOGICAL_AND, secondTokenType: TOKEN_TYPE_NUMBER, secondValue: "0")
        binaryOperatorTest(firstTerm, withExpectedResult: "0")

        firstTerm = buildBinaryOperator(TOKEN_TYPE_NUMBER, firstValue: "1", with: Operator.LOGICAL_AND, secondTokenType: TOKEN_TYPE_NUMBER, secondValue: "1")
        binaryOperatorTest(firstTerm, withExpectedResult: "1")

        var secondTerm = buildBinaryOperator(TOKEN_TYPE_STRING, firstValue: "0", with: Operator.LOGICAL_AND, secondTokenType: TOKEN_TYPE_STRING, secondValue: "0")
        binaryOperatorTest(secondTerm, withExpectedResult: "0")

        secondTerm = buildBinaryOperator(TOKEN_TYPE_STRING, firstValue: "0", with: Operator.LOGICAL_AND, secondTokenType: TOKEN_TYPE_STRING, secondValue: "1")
        binaryOperatorTest(secondTerm, withExpectedResult: "0")

        secondTerm = buildBinaryOperator(TOKEN_TYPE_STRING, firstValue: "1", with: Operator.LOGICAL_AND, secondTokenType: TOKEN_TYPE_STRING, secondValue: "1")
        binaryOperatorTest(secondTerm, withExpectedResult: "1")

        secondTerm = buildBinaryOperator(TOKEN_TYPE_NUMBER, firstValue: "0", with: Operator.LOGICAL_AND, secondTokenType: TOKEN_TYPE_STRING, secondValue: "0")
        binaryOperatorTest(secondTerm, withExpectedResult: "0")

        secondTerm = buildBinaryOperator(TOKEN_TYPE_STRING, firstValue: "1", with: Operator.LOGICAL_AND, secondTokenType: TOKEN_TYPE_NUMBER, secondValue: "0")
        binaryOperatorTest(secondTerm, withExpectedResult: "0")
    }

    func testOr() {
        var firstTerm = buildBinaryOperator(TOKEN_TYPE_NUMBER, firstValue: "0", with: Operator.LOGICAL_OR, secondTokenType: TOKEN_TYPE_NUMBER, secondValue: "0")
        binaryOperatorTest(firstTerm, withExpectedResult: "0")

        firstTerm = buildBinaryOperator(TOKEN_TYPE_NUMBER, firstValue: "1", with: Operator.LOGICAL_OR, secondTokenType: TOKEN_TYPE_NUMBER, secondValue: "0")
        binaryOperatorTest(firstTerm, withExpectedResult: "1")

        firstTerm = buildBinaryOperator(TOKEN_TYPE_NUMBER, firstValue: "1", with: Operator.LOGICAL_OR, secondTokenType: TOKEN_TYPE_NUMBER, secondValue: "1")
        binaryOperatorTest(firstTerm, withExpectedResult: "1")

        var secondTerm = buildBinaryOperator(TOKEN_TYPE_STRING, firstValue: "0", with: Operator.LOGICAL_OR, secondTokenType: TOKEN_TYPE_STRING, secondValue: "0")
        binaryOperatorTest(secondTerm, withExpectedResult: "0")

        secondTerm = buildBinaryOperator(TOKEN_TYPE_STRING, firstValue: "0", with: Operator.LOGICAL_OR, secondTokenType: TOKEN_TYPE_STRING, secondValue: "1")
        binaryOperatorTest(secondTerm, withExpectedResult: "1")

        secondTerm = buildBinaryOperator(TOKEN_TYPE_STRING, firstValue: "1", with: Operator.LOGICAL_OR, secondTokenType: TOKEN_TYPE_STRING, secondValue: "1")
        binaryOperatorTest(secondTerm, withExpectedResult: "1")

        secondTerm = buildBinaryOperator(TOKEN_TYPE_NUMBER, firstValue: "0", with: Operator.LOGICAL_OR, secondTokenType: TOKEN_TYPE_STRING, secondValue: "0")
        binaryOperatorTest(secondTerm, withExpectedResult: "0")

        secondTerm = buildBinaryOperator(TOKEN_TYPE_STRING, firstValue: "1", with: Operator.LOGICAL_OR, secondTokenType: TOKEN_TYPE_NUMBER, secondValue: "0")
        binaryOperatorTest(secondTerm, withExpectedResult: "1")
    }

    func testPlus() {
        var firstOperand = "1.3"
        var secondOperand = "3"
        let result = "4.3"

        var firstTerm = buildBinaryOperator(TOKEN_TYPE_NUMBER, firstValue: firstOperand, with: Operator.PLUS, secondTokenType: TOKEN_TYPE_NUMBER, secondValue: secondOperand)
        binaryOperatorTest(firstTerm, withExpectedResult: result)

        firstTerm = buildBinaryOperator(TOKEN_TYPE_STRING, firstValue: firstOperand, with: Operator.PLUS, secondTokenType: TOKEN_TYPE_STRING, secondValue: secondOperand)
        binaryOperatorTest(firstTerm, withExpectedResult: result)

        firstTerm = buildBinaryOperator(TOKEN_TYPE_NUMBER, firstValue: firstOperand, with: Operator.PLUS, secondTokenType: TOKEN_TYPE_STRING, secondValue: secondOperand)
        binaryOperatorTest(firstTerm, withExpectedResult: result)

        firstTerm = buildBinaryOperator(TOKEN_TYPE_STRING, firstValue: firstOperand, with: Operator.PLUS, secondTokenType: TOKEN_TYPE_NUMBER, secondValue: secondOperand)
        binaryOperatorTest(firstTerm, withExpectedResult: result)

        firstOperand = "NotANumber"
        secondOperand = "3.14"

        firstTerm = buildBinaryOperator(TOKEN_TYPE_STRING, firstValue: firstOperand, with: Operator.PLUS, secondTokenType: TOKEN_TYPE_NUMBER, secondValue: secondOperand)
        binaryOperatorTest(firstTerm, withExpectedResult: "3.14")
    }

    func testDivision() {
        var firstOperand = "9.0"
        var secondOperand = "2"
        let result = "4.5"

        var firstTerm = buildBinaryOperator(TOKEN_TYPE_NUMBER, firstValue: firstOperand, with: Operator.DIVIDE, secondTokenType: TOKEN_TYPE_NUMBER, secondValue: secondOperand)
        binaryOperatorTest(firstTerm, withExpectedResult: result)

        firstTerm = buildBinaryOperator(TOKEN_TYPE_STRING, firstValue: firstOperand, with: Operator.DIVIDE, secondTokenType: TOKEN_TYPE_STRING, secondValue: secondOperand)
        binaryOperatorTest(firstTerm, withExpectedResult: result)

        firstTerm = buildBinaryOperator(TOKEN_TYPE_NUMBER, firstValue: firstOperand, with: Operator.DIVIDE, secondTokenType: TOKEN_TYPE_STRING, secondValue: secondOperand)
        binaryOperatorTest(firstTerm, withExpectedResult: result)

        firstTerm = buildBinaryOperator(TOKEN_TYPE_STRING, firstValue: firstOperand, with: Operator.DIVIDE, secondTokenType: TOKEN_TYPE_NUMBER, secondValue: secondOperand)
        binaryOperatorTest(firstTerm, withExpectedResult: result)

        firstOperand = "NotANumber"
        secondOperand = "3.14"

        firstTerm = buildBinaryOperator(TOKEN_TYPE_STRING, firstValue: firstOperand, with: Operator.DIVIDE, secondTokenType: TOKEN_TYPE_NUMBER, secondValue: secondOperand)
        binaryOperatorTest(firstTerm, withExpectedResult: nil)
    }

    func testMultiplication() {
        var firstOperand = "9.0"
        var secondOperand = "2"
        let result = "18.0"

        var firstTerm = buildBinaryOperator(TOKEN_TYPE_NUMBER, firstValue: firstOperand, with: Operator.MULT, secondTokenType: TOKEN_TYPE_NUMBER, secondValue: secondOperand)
        binaryOperatorTest(firstTerm, withExpectedResult: result)

        firstTerm = buildBinaryOperator(TOKEN_TYPE_STRING, firstValue: firstOperand, with: Operator.MULT, secondTokenType: TOKEN_TYPE_STRING, secondValue: secondOperand)
        binaryOperatorTest(firstTerm, withExpectedResult: result)

        firstTerm = buildBinaryOperator(TOKEN_TYPE_NUMBER, firstValue: firstOperand, with: Operator.MULT, secondTokenType: TOKEN_TYPE_STRING, secondValue: secondOperand)
        binaryOperatorTest(firstTerm, withExpectedResult: result)

        firstTerm = buildBinaryOperator(TOKEN_TYPE_STRING, firstValue: firstOperand, with: Operator.MULT, secondTokenType: TOKEN_TYPE_NUMBER, secondValue: secondOperand)
        binaryOperatorTest(firstTerm, withExpectedResult: result)

        firstOperand = "NotANumber"
        secondOperand = "3.14"

        firstTerm = buildBinaryOperator(TOKEN_TYPE_STRING, firstValue: firstOperand, with: Operator.MULT, secondTokenType: TOKEN_TYPE_NUMBER, secondValue: secondOperand)
        binaryOperatorTest(firstTerm, withExpectedResult: nil)
    }

    func testMinus() {
        var firstOperand = "9.0"
        var secondOperand = "2"
        let result = "7.0"

        var firstTerm = buildBinaryOperator(TOKEN_TYPE_NUMBER, firstValue: firstOperand, with: Operator.MINUS, secondTokenType: TOKEN_TYPE_NUMBER, secondValue: secondOperand)
        binaryOperatorTest(firstTerm, withExpectedResult: result)

        firstTerm = buildBinaryOperator(TOKEN_TYPE_STRING, firstValue: firstOperand, with: Operator.MINUS, secondTokenType: TOKEN_TYPE_STRING, secondValue: secondOperand)
        binaryOperatorTest(firstTerm, withExpectedResult: result)

        firstTerm = buildBinaryOperator(TOKEN_TYPE_NUMBER, firstValue: firstOperand, with: Operator.MINUS, secondTokenType: TOKEN_TYPE_STRING, secondValue: secondOperand)
        binaryOperatorTest(firstTerm, withExpectedResult: result)

        firstTerm = buildBinaryOperator(TOKEN_TYPE_STRING, firstValue: firstOperand, with: Operator.MINUS, secondTokenType: TOKEN_TYPE_NUMBER, secondValue: secondOperand)
        binaryOperatorTest(firstTerm, withExpectedResult: result)

        firstOperand = "NotANumber"
        secondOperand = "3.14"

        firstTerm = buildBinaryOperator(TOKEN_TYPE_STRING, firstValue: firstOperand, with: Operator.MINUS, secondTokenType: TOKEN_TYPE_NUMBER, secondValue: secondOperand)
        binaryOperatorTest(firstTerm, withExpectedResult: "-3.14")
    }
}
