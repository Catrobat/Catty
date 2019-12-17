/**
 *  Copyright (C) 2010-2019 The Catrobat Team
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

final class FormulaManagerInterpreterTests: XCTestCase {

    var interpreter: FormulaInterpreterProtocol!
    var object: SpriteObject!

    override func setUp() {
        interpreter = FormulaManager(sceneSize: Util.screenSize(true))
        object = SpriteObject()
    }

    func testInterpretDouble() {
        var formula = Formula(formulaElement: FormulaElement(elementType: ElementType.NUMBER, value: "1"))!
        XCTAssertEqual(1, interpreter.interpretDouble(formula, for: object))

        formula = Formula(formulaElement: FormulaElement(elementType: ElementType.NUMBER, value: "1.5"))!
        XCTAssertEqual(1.5, interpreter.interpretDouble(formula, for: object))

        formula = Formula(formulaElement: FormulaElement(elementType: ElementType.STRING, value: "2"))!
        XCTAssertEqual(2, interpreter.interpretDouble(formula, for: object))

        formula = Formula(formulaElement: FormulaElement(elementType: ElementType.STRING, value: "-15"))!
        XCTAssertEqual(-15, interpreter.interpretDouble(formula, for: object))

        formula = Formula(formulaElement: FormulaElement(elementType: ElementType.STRING, value: "abc"))!
        XCTAssertEqual(0, interpreter.interpretDouble(formula, for: object))
    }

    func testInterpretFloat() {
        var formula = Formula(formulaElement: FormulaElement(elementType: ElementType.NUMBER, value: "1"))!
        XCTAssertEqual(1, interpreter.interpretFloat(formula, for: object))

        formula = Formula(formulaElement: FormulaElement(elementType: ElementType.NUMBER, value: "1.5"))!
        XCTAssertEqual(1.5, interpreter.interpretFloat(formula, for: object))

        formula = Formula(formulaElement: FormulaElement(elementType: ElementType.STRING, value: "2"))!
        XCTAssertEqual(2, interpreter.interpretFloat(formula, for: object))

        formula = Formula(formulaElement: FormulaElement(elementType: ElementType.STRING, value: "-15"))!
        XCTAssertEqual(-15, interpreter.interpretFloat(formula, for: object))

        formula = Formula(formulaElement: FormulaElement(elementType: ElementType.STRING, value: "abc"))!
        XCTAssertEqual(0, interpreter.interpretFloat(formula, for: object))
    }

    func testInterpretInteger() {
        var formula = Formula(formulaElement: FormulaElement(elementType: ElementType.NUMBER, value: "1"))!
        XCTAssertEqual(1, interpreter.interpretInteger(formula, for: object))

        formula = Formula(formulaElement: FormulaElement(elementType: ElementType.NUMBER, value: "1.5"))!
        XCTAssertEqual(1, interpreter.interpretInteger(formula, for: object))

        formula = Formula(formulaElement: FormulaElement(elementType: ElementType.STRING, value: "2"))!
        XCTAssertEqual(2, interpreter.interpretInteger(formula, for: object))

        formula = Formula(formulaElement: FormulaElement(elementType: ElementType.STRING, value: "-15"))!
        XCTAssertEqual(-15, interpreter.interpretInteger(formula, for: object))

        formula = Formula(formulaElement: FormulaElement(elementType: ElementType.STRING, value: "abc"))!
        XCTAssertEqual(0, interpreter.interpretInteger(formula, for: object))
    }

    func testInterpretIntegerMax() {
        let formula = Formula(formulaElement: FormulaElement(elementType: ElementType.NUMBER, value: "101010101010101010101010101010101010101010101010101010"))!
        XCTAssertEqual(Int.max, interpreter.interpretInteger(formula, for: object))
    }

    func testInterpretBool() {
        var formula = Formula(formulaElement: FormulaElement(elementType: ElementType.NUMBER, value: "1"))!
        XCTAssertTrue(interpreter.interpretBool(formula, for: object))

        formula = Formula(formulaElement: FormulaElement(elementType: ElementType.NUMBER, value: "1.5"))!
        XCTAssertTrue(interpreter.interpretBool(formula, for: object))

        formula = Formula(formulaElement: FormulaElement(elementType: ElementType.STRING, value: "2"))!
        XCTAssertTrue(interpreter.interpretBool(formula, for: object))

        formula = Formula(formulaElement: FormulaElement(elementType: ElementType.STRING, value: "-15"))!
        XCTAssertTrue(interpreter.interpretBool(formula, for: object))

        formula = Formula(formulaElement: FormulaElement(elementType: ElementType.STRING, value: "abc"))!
        XCTAssertFalse(interpreter.interpretBool(formula, for: object))

        formula = Formula(formulaElement: FormulaElement(elementType: ElementType.NUMBER, value: "0"))!
        XCTAssertFalse(interpreter.interpretBool(formula, for: object))
    }

    func testInterpretString() {
        var formula = Formula(formulaElement: FormulaElement(elementType: ElementType.NUMBER, value: "1"))!
        XCTAssertEqual(Double("1"), Double(interpreter.interpretString(formula, for: object)))

        formula = Formula(formulaElement: FormulaElement(elementType: ElementType.NUMBER, value: "1.5"))!
        XCTAssertEqual(Double("1.5"), Double(interpreter.interpretString(formula, for: object)))

        formula = Formula(formulaElement: FormulaElement(elementType: ElementType.STRING, value: "2"))!
        XCTAssertEqual(Double("2"), Double(interpreter.interpretString(formula, for: object)))

        formula = Formula(formulaElement: FormulaElement(elementType: ElementType.STRING, value: "-15"))!
        XCTAssertEqual(Double("-15"), Double(interpreter.interpretString(formula, for: object)))

        formula = Formula(formulaElement: FormulaElement(elementType: ElementType.STRING, value: "abc"))!
        XCTAssertEqual("abc", interpreter.interpretString(formula, for: object))
    }

    func testInterpret() {
        var formula = Formula(formulaElement: FormulaElement(elementType: ElementType.NUMBER, value: "1"))!
        var result = interpreter.interpret(formula, for: object)
        XCTAssertTrue(result is Double)
        XCTAssertEqual(1, result as! Double)

        formula = Formula(formulaElement: FormulaElement(elementType: ElementType.NUMBER, value: "1.9"))!
        result = interpreter.interpret(formula, for: object)
        XCTAssertTrue(result is Double)
        XCTAssertEqual(1.9, result as! Double)

        formula = Formula(formulaElement: FormulaElement(elementType: ElementType.STRING, value: "2"))!
        result = interpreter.interpret(formula, for: object)
        XCTAssertTrue(result is String)
        XCTAssertEqual("2", result as! String)
    }

    func testInterpretNotExisitingUnaryOperator() {
        let element = FormulaElement(elementType: ElementType.OPERATOR,
                                     value: PlusOperator.tag,
                                     leftChild: nil,
                                     rightChild: FormulaElement(integer: 1),
                                     parent: nil)
        let formula = Formula(formulaElement: element)!
        XCTAssertEqual(0, interpreter.interpretDouble(formula, for: object))
    }

    func testCheckDegeneratedDoubleValues() {
        var element = FormulaElement(double: Double.greatestFiniteMagnitude)
        var formula = Formula(formulaElement: element)!
        XCTAssertEqual(Double.greatestFiniteMagnitude, interpreter.interpretDouble(formula, for: object))

        let leftChild = FormulaElement(double: Double.greatestFiniteMagnitude * -1)
        let rightChild = FormulaElement(double: Double.greatestFiniteMagnitude)
        element = FormulaElement(elementType: ElementType.OPERATOR,
                                 value: MinusOperator.tag,
                                 leftChild: leftChild,
                                 rightChild: rightChild,
                                 parent: nil)

        formula = Formula(formulaElement: element)!
        XCTAssertEqual(-Double.greatestFiniteMagnitude, interpreter.interpretDouble(formula, for: object))
    }

    func testDivisionZeroByZero() {
        let leftChild = FormulaElement(double: 0)
        let rightChild = FormulaElement(double: 0)
        let element = FormulaElement(elementType: ElementType.OPERATOR,
                                     value: DivideOperator.tag,
                                     leftChild: leftChild,
                                     rightChild: rightChild,
                                     parent: nil)
        let formula = Formula(formulaElement: element)!

        XCTAssertTrue(interpreter.interpretDouble(formula, for: object).isNaN)
    }

    func testDivisionByZeroAndExpectMaxDouble() {
        let element = FormulaElement(elementType: ElementType.OPERATOR,
                                     value: DivideOperator.tag,
                                     leftChild: FormulaElement(double: 1),
                                     rightChild: FormulaElement(double: 0),
                                     parent: nil)
        let formula = Formula(formulaElement: element)!

        XCTAssertEqual(Double.greatestFiniteMagnitude, interpreter.interpretDouble(formula, for: object))
    }

    func testDivisionNegativeNumberByZeroAndExpectMinDouble() {
        let element = FormulaElement(elementType: ElementType.OPERATOR,
                                     value: DivideOperator.tag,
                                     leftChild: FormulaElement(double: -1),
                                     rightChild: FormulaElement(double: 0),
                                     parent: nil)
        let formula = Formula(formulaElement: element)!

        XCTAssertEqual(-Double.greatestFiniteMagnitude, interpreter.interpretDouble(formula, for: object))
    }

    func testDivision() {
        let leftChild = FormulaElement(double: 10)
        let rightChild = FormulaElement(double: 5)
        let element = FormulaElement(elementType: ElementType.OPERATOR,
                                     value: DivideOperator.tag,
                                     leftChild: leftChild,
                                     rightChild: rightChild,
                                     parent: nil)
        let formula = Formula(formulaElement: element)!

        XCTAssertEqual(10 / 5, interpreter.interpretDouble(formula, for: object))
    }

    func testDivisionWithString() {
        let leftChild = FormulaElement(string: "10")
        let rightChild = FormulaElement(double: 5)
        let element = FormulaElement(elementType: ElementType.OPERATOR,
                                     value: DivideOperator.tag,
                                     leftChild: leftChild,
                                     rightChild: rightChild,
                                     parent: nil)
        let formula = Formula(formulaElement: element)!

        XCTAssertEqual(10 / 5, interpreter.interpretDouble(formula, for: object))
    }

    func testDivisionNested() {
        let leftChild = FormulaElement(elementType: ElementType.OPERATOR,
                                       value: PlusOperator.tag,
                                       leftChild: FormulaElement(string: "6"),
                                       rightChild: FormulaElement(double: 2),
                                       parent: nil)
        var element = FormulaElement(elementType: ElementType.OPERATOR,
                                     value: DivideOperator.tag,
                                     leftChild: leftChild,
                                     rightChild: FormulaElement(double: 5),
                                     parent: nil)
        var formula = Formula(formulaElement: element)!

        XCTAssertEqual((6 + 2) / 5, interpreter.interpretDouble(formula, for: object))

        let rightChild = FormulaElement(elementType: ElementType.OPERATOR,
                                        value: DivideOperator.tag,
                                        leftChild: FormulaElement(string: "2"),
                                        rightChild: FormulaElement(string: "5"),
                                        parent: nil)
        element = FormulaElement(elementType: ElementType.OPERATOR,
                                 value: PlusOperator.tag,
                                 leftChild: FormulaElement(integer: 6),
                                 rightChild: rightChild,
                                 parent: nil)
        formula = Formula(formulaElement: element)!

        XCTAssertEqual(6 + (2 / 5), interpreter.interpretDouble(formula, for: object))
    }

    func testAddition() {
        let leftChild = FormulaElement(double: 3)
        let rightChild = FormulaElement(double: 5)
        let element = FormulaElement(elementType: ElementType.OPERATOR,
                                     value: PlusOperator.tag,
                                     leftChild: leftChild,
                                     rightChild: rightChild,
                                     parent: nil)
        let formula = Formula(formulaElement: element)!

        XCTAssertEqual(3 + 5, interpreter.interpretDouble(formula, for: object))
    }

    func testAdditionWithString() {
        let leftChild = FormulaElement(string: "-3")
        let rightChild = FormulaElement(string: "5")
        let element = FormulaElement(elementType: ElementType.OPERATOR,
                                     value: PlusOperator.tag,
                                     leftChild: leftChild,
                                     rightChild: rightChild,
                                     parent: nil)
        let formula = Formula(formulaElement: element)!

        XCTAssertEqual(-3 + 5, interpreter.interpretDouble(formula, for: object))
    }

    func testAdditionNested() {
        let leftChild = FormulaElement(elementType: ElementType.OPERATOR,
                                       value: MinusOperator.tag,
                                       leftChild: FormulaElement(string: "6"),
                                       rightChild: FormulaElement(double: 2),
                                       parent: nil)
        var element = FormulaElement(elementType: ElementType.OPERATOR,
                                     value: PlusOperator.tag,
                                     leftChild: leftChild,
                                     rightChild: FormulaElement(double: 5),
                                     parent: nil)
        var formula = Formula(formulaElement: element)!

        XCTAssertEqual((6 - 2) + 5, interpreter.interpretDouble(formula, for: object))

        let rightChild = FormulaElement(elementType: ElementType.OPERATOR,
                                        value: MinusOperator.tag,
                                        leftChild: FormulaElement(string: "2"),
                                        rightChild: FormulaElement(string: "5"),
                                        parent: nil)
        element = FormulaElement(elementType: ElementType.OPERATOR,
                                 value: PlusOperator.tag,
                                 leftChild: FormulaElement(integer: 6),
                                 rightChild: rightChild,
                                 parent: nil)
        formula = Formula(formulaElement: element)!

        XCTAssertEqual(6 + (2 - 5), interpreter.interpretDouble(formula, for: object))
    }

    func testSubstraction() {
        let leftChild = FormulaElement(double: -3)
        let rightChild = FormulaElement(double: 5)
        let element = FormulaElement(elementType: ElementType.OPERATOR,
                                     value: MinusOperator.tag,
                                     leftChild: leftChild,
                                     rightChild: rightChild,
                                     parent: nil)
        let formula = Formula(formulaElement: element)!

        XCTAssertEqual(-3 - 5, interpreter.interpretDouble(formula, for: object))
    }

    func testMultiplication() {
        let leftChild = FormulaElement(double: -3)
        let rightChild = FormulaElement(double: -3)
        let element = FormulaElement(elementType: ElementType.OPERATOR,
                                     value: MultOperator.tag,
                                     leftChild: leftChild,
                                     rightChild: rightChild,
                                     parent: nil)
        let formula = Formula(formulaElement: element)!

        XCTAssertEqual(-3 * -3, interpreter.interpretDouble(formula, for: object))
        XCTAssertEqual(-3 * -3, interpreter.interpretFloat(formula, for: object))
        XCTAssertEqual(-3 * -3, interpreter.interpretInteger(formula, for: object))
        XCTAssertTrue(interpreter.interpretBool(formula, for: object))
    }

    func testLogicalAnd() {
        var element = FormulaElement(elementType: ElementType.OPERATOR,
                                     value: AndOperator.tag,
                                     leftChild: FormulaElement(double: 1),
                                     rightChild: FormulaElement(double: 0),
                                     parent: nil)
        var formula = Formula(formulaElement: element)!

        XCTAssertEqual(0.0, interpreter.interpretDouble(formula, for: object))
        XCTAssertFalse(interpreter.interpretBool(formula, for: object))

        element = FormulaElement(elementType: ElementType.OPERATOR,
                                 value: AndOperator.tag,
                                 leftChild: FormulaElement(double: 2.4),
                                 rightChild: FormulaElement(double: 3.5),
                                 parent: nil)
        formula = Formula(formulaElement: element)!

        XCTAssertEqual(1.0, interpreter.interpretDouble(formula, for: object))
        XCTAssertTrue(interpreter.interpretBool(formula, for: object))
    }

    func testLogicalOr() {
        var element = FormulaElement(elementType: ElementType.OPERATOR,
                                     value: OrOperator.tag,
                                     leftChild: FormulaElement(double: -1.4),
                                     rightChild: FormulaElement(double: 0),
                                     parent: nil)
        var formula = Formula(formulaElement: element)!

        XCTAssertEqual(1.0, interpreter.interpretDouble(formula, for: object))
        XCTAssertTrue(interpreter.interpretBool(formula, for: object))

        element = FormulaElement(elementType: ElementType.OPERATOR,
                                 value: OrOperator.tag,
                                 leftChild: FormulaElement(double: 0),
                                 rightChild: FormulaElement(double: 0),
                                 parent: nil)
        formula = Formula(formulaElement: element)!

        XCTAssertEqual(0.0, interpreter.interpretDouble(formula, for: object))
        XCTAssertFalse(interpreter.interpretBool(formula, for: object))
    }

    func testSmallerOrEqual() {
        var element = FormulaElement(elementType: ElementType.OPERATOR,
                                     value: SmallerOrEqualOperator.tag,
                                     leftChild: FormulaElement(double: -1.4),
                                     rightChild: FormulaElement(double: -1.4),
                                     parent: nil)
        var formula = Formula(formulaElement: element)!

        XCTAssertEqual(1.0, interpreter.interpretDouble(formula, for: object))
        XCTAssertTrue(interpreter.interpretBool(formula, for: object))

        element = FormulaElement(elementType: ElementType.OPERATOR,
                                 value: SmallerOrEqualOperator.tag,
                                 leftChild: FormulaElement(double: -10),
                                 rightChild: FormulaElement(double: -28.30),
                                 parent: nil)
        formula = Formula(formulaElement: element)!

        XCTAssertEqual(0.0, interpreter.interpretDouble(formula, for: object))
        XCTAssertFalse(interpreter.interpretBool(formula, for: object))
    }

    func testGreaterOrEqual() {
        var element = FormulaElement(elementType: ElementType.OPERATOR,
                                     value: GreaterOrEqualOperator.tag,
                                     leftChild: FormulaElement(double: -1.4),
                                     rightChild: FormulaElement(double: -1.4),
                                     parent: nil)
        var formula = Formula(formulaElement: element)!

        XCTAssertEqual(1.0, interpreter.interpretDouble(formula, for: object))
        XCTAssertTrue(interpreter.interpretBool(formula, for: object))

        element = FormulaElement(elementType: ElementType.OPERATOR,
                                 value: GreaterOrEqualOperator.tag,
                                 leftChild: FormulaElement(double: -1),
                                 rightChild: FormulaElement(double: -0.9),
                                 parent: nil)
        formula = Formula(formulaElement: element)!

        XCTAssertEqual(0.0, interpreter.interpretDouble(formula, for: object))
        XCTAssertFalse(interpreter.interpretBool(formula, for: object))
    }

    func testSmallerThan() {
        var element = FormulaElement(elementType: ElementType.OPERATOR,
                                     value: SmallerThanOperator.tag,
                                     leftChild: FormulaElement(double: -1.4),
                                     rightChild: FormulaElement(double: -1.3),
                                     parent: nil)
        var formula = Formula(formulaElement: element)!

        XCTAssertEqual(1.0, interpreter.interpretDouble(formula, for: object))
        XCTAssertTrue(interpreter.interpretBool(formula, for: object))

        element = FormulaElement(elementType: ElementType.OPERATOR,
                                 value: SmallerThanOperator.tag,
                                 leftChild: FormulaElement(double: -10),
                                 rightChild: FormulaElement(double: -10),
                                 parent: nil)
        formula = Formula(formulaElement: element)!

        XCTAssertEqual(0.0, interpreter.interpretDouble(formula, for: object))
        XCTAssertFalse(interpreter.interpretBool(formula, for: object))
    }

    func testGreaterThan() {
        var element = FormulaElement(elementType: ElementType.OPERATOR,
                                     value: GreaterThanOperator.tag,
                                     leftChild: FormulaElement(double: -1.4),
                                     rightChild: FormulaElement(double: -1.6),
                                     parent: nil)
        var formula = Formula(formulaElement: element)!

        XCTAssertEqual(1.0, interpreter.interpretDouble(formula, for: object))
        XCTAssertTrue(interpreter.interpretBool(formula, for: object))

        element = FormulaElement(elementType: ElementType.OPERATOR,
                                 value: GreaterThanOperator.tag,
                                 leftChild: FormulaElement(double: -10),
                                 rightChild: FormulaElement(double: -10),
                                 parent: nil)
        formula = Formula(formulaElement: element)!

        XCTAssertEqual(0.0, interpreter.interpretDouble(formula, for: object))
        XCTAssertFalse(interpreter.interpretBool(formula, for: object))
    }

    func testEqual() {
        var element = FormulaElement(elementType: ElementType.OPERATOR,
                                     value: EqualOperator.tag,
                                     leftChild: FormulaElement(double: -1.4),
                                     rightChild: FormulaElement(double: -1.4),
                                     parent: nil)
        var formula = Formula(formulaElement: element)!

        XCTAssertEqual(1.0, interpreter.interpretDouble(formula, for: object))
        XCTAssertTrue(interpreter.interpretBool(formula, for: object))

        element = FormulaElement(elementType: ElementType.OPERATOR,
                                 value: EqualOperator.tag,
                                 leftChild: FormulaElement(string: "-10"),
                                 rightChild: FormulaElement(double: -10),
                                 parent: nil)
        formula = Formula(formulaElement: element)!

        XCTAssertTrue(interpreter.interpretBool(formula, for: object))

        element = FormulaElement(elementType: ElementType.OPERATOR,
                                 value: EqualOperator.tag,
                                 leftChild: FormulaElement(integer: -10),
                                 rightChild: FormulaElement(double: -10),
                                 parent: nil)
        formula = Formula(formulaElement: element)!

        XCTAssertTrue(interpreter.interpretBool(formula, for: object))

        element = FormulaElement(elementType: ElementType.OPERATOR,
                                 value: EqualOperator.tag,
                                 leftChild: FormulaElement(string: "abc"),
                                 rightChild: FormulaElement(string: "abc"),
                                 parent: nil)
        formula = Formula(formulaElement: element)!

        XCTAssertTrue(interpreter.interpretBool(formula, for: object))

        element = FormulaElement(elementType: ElementType.OPERATOR,
                                 value: EqualOperator.tag,
                                 leftChild: FormulaElement(string: "1.4"),
                                 rightChild: FormulaElement(double: 1.4),
                                 parent: nil)
        formula = Formula(formulaElement: element)!

        XCTAssertTrue(interpreter.interpretBool(formula, for: object))

        element = FormulaElement(elementType: ElementType.OPERATOR,
                                 value: EqualOperator.tag,
                                 leftChild: FormulaElement(string: "1.4"),
                                 rightChild: FormulaElement(double: 1.5),
                                 parent: nil)
        formula = Formula(formulaElement: element)!

        XCTAssertEqual(0.0, interpreter.interpretDouble(formula, for: object))
        XCTAssertFalse(interpreter.interpretBool(formula, for: object))
    }

    func testNotEqual() {
        var element = FormulaElement(elementType: ElementType.OPERATOR,
                                     value: NotEqualOperator.tag,
                                     leftChild: FormulaElement(double: -1.3),
                                     rightChild: FormulaElement(double: -1.4),
                                     parent: nil)
        var formula = Formula(formulaElement: element)!

        XCTAssertEqual(1.0, interpreter.interpretDouble(formula, for: object))
        XCTAssertTrue(interpreter.interpretBool(formula, for: object))

        element = FormulaElement(elementType: ElementType.OPERATOR,
                                 value: NotEqualOperator.tag,
                                 leftChild: FormulaElement(string: "-10.1"),
                                 rightChild: FormulaElement(double: -10),
                                 parent: nil)
        formula = Formula(formulaElement: element)!

        XCTAssertTrue(interpreter.interpretBool(formula, for: object))

        element = FormulaElement(elementType: ElementType.OPERATOR,
                                 value: NotEqualOperator.tag,
                                 leftChild: FormulaElement(integer: -11),
                                 rightChild: FormulaElement(double: -10),
                                 parent: nil)
        formula = Formula(formulaElement: element)!

        XCTAssertTrue(interpreter.interpretBool(formula, for: object))

        element = FormulaElement(elementType: ElementType.OPERATOR,
                                 value: NotEqualOperator.tag,
                                 leftChild: FormulaElement(string: "abc"),
                                 rightChild: FormulaElement(string: "abcd"),
                                 parent: nil)
        formula = Formula(formulaElement: element)!

        XCTAssertTrue(interpreter.interpretBool(formula, for: object))

        element = FormulaElement(elementType: ElementType.OPERATOR,
                                 value: NotEqualOperator.tag,
                                 leftChild: FormulaElement(string: "1.41"),
                                 rightChild: FormulaElement(double: 1.4),
                                 parent: nil)
        formula = Formula(formulaElement: element)!

        XCTAssertTrue(interpreter.interpretBool(formula, for: object))

        element = FormulaElement(elementType: ElementType.OPERATOR,
                                 value: NotEqualOperator.tag,
                                 leftChild: FormulaElement(string: "1.4"),
                                 rightChild: FormulaElement(double: 1.4),
                                 parent: nil)
        formula = Formula(formulaElement: element)!

        XCTAssertEqual(0.0, interpreter.interpretDouble(formula, for: object))
        XCTAssertFalse(interpreter.interpretBool(formula, for: object))
    }

    func testInvalidBinaryOperator() {
        let element = FormulaElement(elementType: ElementType.OPERATOR,
                                     value: NotOperator.tag,
                                     leftChild: FormulaElement(double: 1.3),
                                     rightChild: nil,
                                     parent: nil)
        let formula = Formula(formulaElement: element)!

        XCTAssertEqual(0, interpreter.interpretDouble(formula, for: object))
    }

    func testMinus() {
        var element = FormulaElement(elementType: ElementType.OPERATOR,
                                     value: MinusOperator.tag,
                                     leftChild: nil,
                                     rightChild: FormulaElement(double: 1.3),
                                     parent: nil)
        var formula = Formula(formulaElement: element)!

        XCTAssertEqual(-1.3, interpreter.interpretDouble(formula, for: object))

        element = FormulaElement(elementType: ElementType.OPERATOR,
                                 value: MinusOperator.tag,
                                 leftChild: nil,
                                 rightChild: FormulaElement(double: -2),
                                 parent: nil)
        formula = Formula(formulaElement: element)!

        XCTAssertEqual(2, interpreter.interpretDouble(formula, for: object))
    }

    func testLogicalNot() {
        var element = FormulaElement(elementType: ElementType.OPERATOR,
                                     value: NotOperator.tag,
                                     leftChild: nil,
                                     rightChild: FormulaElement(double: 1.3),
                                     parent: nil)
        var formula = Formula(formulaElement: element)!

        XCTAssertEqual(0.0, interpreter.interpretDouble(formula, for: object))
        XCTAssertFalse(interpreter.interpretBool(formula, for: object))

        element = FormulaElement(elementType: ElementType.OPERATOR,
                                 value: NotOperator.tag,
                                 leftChild: nil,
                                 rightChild: FormulaElement(double: 0.0),
                                 parent: nil)
        formula = Formula(formulaElement: element)!

        XCTAssertEqual(1.0, interpreter.interpretDouble(formula, for: object))
        XCTAssertTrue(interpreter.interpretBool(formula, for: object))
    }

    func testInvalidUnaryOperator() {
        let element = FormulaElement(elementType: ElementType.OPERATOR,
                                     value: PlusOperator.tag,
                                     leftChild: nil,
                                     rightChild: FormulaElement(double: 1.3),
                                     parent: nil)
        let formula = Formula(formulaElement: element)!

        XCTAssertEqual(0, interpreter.interpretDouble(formula, for: object))
    }

    func testNumber() {
        var formula = Formula(formulaElement: FormulaElement(elementType: ElementType.NUMBER,
                                                             value: "1"))!
        XCTAssertEqual(1, interpreter.interpretDouble(formula, for: object))

        formula = Formula(formulaElement: FormulaElement(elementType: ElementType.NUMBER,
                                                         value: "2"))!
        XCTAssertEqual(2, interpreter.interpretDouble(formula, for: object))

        formula = Formula(formulaElement: FormulaElement(elementType: ElementType.NUMBER,
                                                         value: "-15"))!
        XCTAssertEqual(-15, interpreter.interpretDouble(formula, for: object))
    }

    func testString() {
        var formula = Formula(formulaElement: FormulaElement(elementType: ElementType.STRING,
                                                             value: "1"))!
        XCTAssertEqual(1, interpreter.interpretDouble(formula, for: object))
        XCTAssertEqual(1, interpreter.interpretInteger(formula, for: object))

        formula = Formula(formulaElement: FormulaElement(elementType: ElementType.STRING,
                                                         value: "abc"))!
        XCTAssertEqual(0, interpreter.interpretDouble(formula, for: object))
        XCTAssertEqual("abc", interpreter.interpretString(formula, for: object))
    }

    func testFunction() {
        let formula = Formula(formulaElement: FormulaElement(elementType: ElementType.FUNCTION,
                                                             value: PiFunction.tag))!
        XCTAssertEqual(Double.pi, interpreter.interpretDouble(formula, for: object))
    }

    func testSensor() {
        let formula = Formula(formulaElement: FormulaElement(elementType: ElementType.SENSOR,
                                                             value: DateDaySensor.tag))!
        XCTAssertEqual(Calendar.current.component(.day, from: Date()), interpreter.interpretInteger(formula,
                                                                                                    for: object))
    }

    func testBracket() {
        var element = FormulaElement(elementType: ElementType.BRACKET,
                                     value: "foo",
                                     leftChild: nil,
                                     rightChild: FormulaElement(double: 1.3),
                                     parent: nil)
        var formula = Formula(formulaElement: element)!

        XCTAssertEqual(1.3, interpreter.interpretDouble(formula, for: object))

        element = FormulaElement(elementType: ElementType.BRACKET,
                                 value: "foo",
                                 leftChild: FormulaElement(double: 1.3),
                                 rightChild: nil,
                                 parent: nil)
        formula = Formula(formulaElement: element)!

        XCTAssertEqual(0.0, interpreter.interpretDouble(formula, for: object))
    }

    func testInterpretNonExistingUserVariable() {
        let element = FormulaElement(elementType: ElementType.USER_VARIABLE,
                                     value: "notExistingUserVariable")
        let formula = Formula(formulaElement: element)!
        XCTAssertEqual(0, interpreter.interpretDouble(formula, for: object))
    }

    func testUserVariable() {
        let project = ProjectMock()!
        let variables = VariablesContainer()
        project.variables = variables
        object.project = project

        let userVariable = UserVariable()
        userVariable.name = "test"
        userVariable.isList = false
        userVariable.value = "testValue"
        variables.programVariableList = [userVariable]

        var element = FormulaElement(elementType: ElementType.USER_VARIABLE,
                                     value: userVariable.name)
        var formula = Formula(formulaElement: element)!
        XCTAssertEqual("testValue", interpreter.interpretString(formula, for: object))

        userVariable.value = 12.3
        element = FormulaElement(elementType: ElementType.USER_VARIABLE,
                                 value: userVariable.name)
        formula = Formula(formulaElement: element)!
        XCTAssertEqual(12.3, interpreter.interpretDouble(formula, for: object))
    }

    func testInterpretNonExistingUserList() {
        let element = FormulaElement(elementType: ElementType.USER_LIST,
                                     value: "notExistingUserList")
        let formula = Formula(formulaElement: element)!
        XCTAssertEqual(0, interpreter.interpretDouble(formula, for: object))
    }

    func testUserList() {
        let project = ProjectMock()!
        let variables = VariablesContainer()
        project.variables = variables
        object.project = project

        let userList = UserVariable()
        userList.name = "test"
        userList.isList = true

        variables.programListOfLists = [userList]
        variables.add(toUserList: userList, value: 12.3)

        var element = FormulaElement(elementType: ElementType.USER_LIST,
                                     value: userList.name)
        var formula = Formula(formulaElement: element)!
        XCTAssertEqual(12.3, interpreter.interpretDouble(formula, for: object))

        variables.add(toUserList: userList, value: "testValue")
        element = FormulaElement(elementType: ElementType.USER_LIST,
                                 value: userList.name)
        formula = Formula(formulaElement: element)!
        XCTAssertEqual("12.3 testValue", interpreter.interpretString(formula, for: object))
    }
}
