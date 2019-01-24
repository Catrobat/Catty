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

final class FormulaManagerIdempotenceTests: XCTestCase {

    var interpreter: FormulaInterpreterProtocol!

    override func setUp() {
        interpreter = FormulaManager(sceneSize: Util.screenSize(true))
    }

    func testIsIdempotentDefaultValue() {
        let formula = Formula(formulaElement: FormulaElement())!
        XCTAssertEqual(IdempotenceState.NOT_CHECKED, formula.formulaTree.idempotenceState)
        XCTAssertFalse(interpreter.isIdempotent(formula))
    }

    func testCaching() {
        let formula = Formula(integer: 1)!
        formula.formulaTree.idempotenceState = .IDEMPOTENT
        XCTAssertTrue(interpreter.isIdempotent(formula))

        formula.formulaTree.idempotenceState = .NOT_IDEMPOTENT
        XCTAssertFalse(interpreter.isIdempotent(formula))

        formula.formulaTree.idempotenceState = .NOT_CHECKED
        XCTAssertTrue(interpreter.isIdempotent(formula))
        XCTAssertEqual(IdempotenceState.IDEMPOTENT, formula.formulaTree.idempotenceState)
    }

    func testSingleNumber() {
        let formula = Formula(integer: 1)!
        XCTAssertTrue(interpreter.isIdempotent(formula))
        XCTAssertEqual(IdempotenceState.IDEMPOTENT, formula.formulaTree.idempotenceState)
    }

    func testAddition() {
        let leftChild = FormulaElement(integer: 1)
        let rightChild = FormulaElement(integer: 3)
        let formulaElement = FormulaElement(elementType: ElementType.OPERATOR, value: PlusOperator.tag, leftChild: leftChild, rightChild: rightChild, parent: nil)

        let formula = Formula(formulaElement: formulaElement)!
        XCTAssertTrue(interpreter.isIdempotent(formula))
    }

    func testMultiplication() {
        let subElement = FormulaElement(elementType: ElementType.OPERATOR,
                                        value: MinusOperator.tag,
                                        leftChild: FormulaElement(integer: 3),
                                        rightChild: FormulaElement(integer: 5),
                                        parent: nil)

        let leftChild = FormulaElement(integer: 1)
        let rightChild = FormulaElement(elementType: ElementType.BRACKET, value: nil, leftChild: nil, rightChild: subElement, parent: nil)

        let formulaElement = FormulaElement(elementType: ElementType.OPERATOR, value: MinusOperator.tag, leftChild: leftChild, rightChild: rightChild, parent: nil)

        let formula = Formula(formulaElement: formulaElement)!
        XCTAssertTrue(interpreter.isIdempotent(formula))
    }

    func testSingleSensor() {
        let formula = Formula(formulaElement: FormulaElement(elementType: ElementType.SENSOR, value: AccelerationXSensor.tag))!
        XCTAssertFalse(interpreter.isIdempotent(formula))
    }

    func testTwoSensor() {
        let leftChild = FormulaElement(elementType: ElementType.SENSOR, value: AccelerationXSensor.tag)
        let rightChild = FormulaElement(elementType: ElementType.SENSOR, value: InclinationXSensor.tag)
        let formulaElement = FormulaElement(elementType: ElementType.OPERATOR, value: PlusOperator.tag, leftChild: leftChild, rightChild: rightChild, parent: nil)

        let formula = Formula(formulaElement: formulaElement)!
        XCTAssertFalse(interpreter.isIdempotent(formula))
    }

    func testSensorLeftChild() {
        let leftChild = FormulaElement(elementType: ElementType.SENSOR, value: AccelerationXSensor.tag)
        let rightChild = FormulaElement(integer: 3)
        let formulaElement = FormulaElement(elementType: ElementType.OPERATOR, value: PlusOperator.tag, leftChild: leftChild, rightChild: rightChild, parent: nil)

        let formula = Formula(formulaElement: formulaElement)!
        XCTAssertFalse(interpreter.isIdempotent(formula))
    }

    func testSensorRightChild() {
        let leftChild = FormulaElement(integer: 3)
        let rightChild = FormulaElement(elementType: ElementType.SENSOR, value: AccelerationXSensor.tag)
        let formulaElement = FormulaElement(elementType: ElementType.OPERATOR,
                                            value: PlusOperator.tag,
                                            leftChild: leftChild,
                                            rightChild: rightChild,
                                            parent: nil)

        let formula = Formula(formulaElement: formulaElement)!
        XCTAssertFalse(interpreter.isIdempotent(formula))
    }

    func testNestedSensorRightChild() {
        let sensorElement = FormulaElement(elementType: ElementType.SENSOR, value: InclinationYSensor.tag)

        let leftChild = FormulaElement(integer: 3)
        let rightChild = FormulaElement(elementType: ElementType.OPERATOR,
                                        value: MinusOperator.tag,
                                        leftChild: FormulaElement(integer: 3),
                                        rightChild: sensorElement,
                                        parent: nil)

        let formulaElement = FormulaElement(elementType: ElementType.OPERATOR,
                                            value: PlusOperator.tag,
                                            leftChild: leftChild,
                                            rightChild: rightChild,
                                            parent: nil)

        let formula = Formula(formulaElement: formulaElement)!
        XCTAssertFalse(interpreter.isIdempotent(formula))
    }

    func testSingleNonIdempotentFunction() {
        let function = RandFunction.self
        XCTAssertFalse(function.isIdempotent)

        let formula = Formula(formulaElement: FormulaElement(elementType: ElementType.FUNCTION, value: function.tag))!
        XCTAssertFalse(interpreter.isIdempotent(formula))
    }

    func testSingleIdempotentFunction() {
        let function = SinFunction.self
        XCTAssertTrue(function.isIdempotent)

        let formula = Formula(formulaElement: FormulaElement(elementType: ElementType.FUNCTION, value: function.tag))!
        XCTAssertTrue(interpreter.isIdempotent(formula))
    }

    func testSingleUserVariable() {
        let formula = Formula(formulaElement: FormulaElement(elementType: ElementType.USER_VARIABLE, value: "test"))!
        XCTAssertFalse(interpreter.isIdempotent(formula))
    }

    func testUserVariableAndNumber() {
        let leftChild = FormulaElement(integer: 2)
        let rightChild = FormulaElement(elementType: ElementType.USER_VARIABLE, value: "test")
        let formulaElement = FormulaElement(elementType: ElementType.OPERATOR,
                                            value: MultOperator.tag,
                                            leftChild: leftChild,
                                            rightChild: rightChild,
                                            parent: nil)

        let formula = Formula(formulaElement: formulaElement)!
        XCTAssertFalse(interpreter.isIdempotent(formula))
    }

    func testSingleString() {
        let formula = Formula(formulaElement: FormulaElement(elementType: ElementType.STRING, value: "test"))!
        XCTAssertFalse(interpreter.isIdempotent(formula))
    }
}
