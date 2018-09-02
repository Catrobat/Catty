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

final class FormulaManagerInterpreterTest: XCTestCase {
    
    var interpreter: FormulaInterpreterProtocol!
    var object: SpriteObject!
    
    override func setUp() {
        interpreter = FormulaManager()
        object = SpriteObject()
    }
    
    func testInterpretNonExistingUserVariable() {
        let element = FormulaElement(elementType: ElementType.USER_VARIABLE, value: "notExistingUserVariable")
        let formula = Formula(formulaElement: element)!
        XCTAssertEqual(0, self.interpreter.interpretDouble(formula, for: object))
    }
    
    func testInterpretNonExistingUserList() {
        let element = FormulaElement(elementType: ElementType.USER_LIST, value: "notExistingUserList")
        let formula = Formula(formulaElement: element)!
        XCTAssertEqual(0, self.interpreter.interpretDouble(formula, for: object))
    }
    
    func testInterpretNotExisitingUnaryOperator() {
        let element = FormulaElement(elementType: ElementType.OPERATOR, value: Operators.getName(Operator.PLUS), leftChild: nil, rightChild: FormulaElement(integer: 1), parent: nil)
        let formula = Formula(formulaElement: element)!
        XCTAssertEqual(0, self.interpreter.interpretDouble(formula, for: object))
    }
    
    func testCheckDegeneratedDoubleValues() {
        var element = FormulaElement(double: Double.greatestFiniteMagnitude)
        var formula = Formula(formulaElement: element)!
        XCTAssertEqual(Double.greatestFiniteMagnitude, self.interpreter.interpretDouble(formula, for: object))
        
        let leftChild = FormulaElement(double: Double.greatestFiniteMagnitude * -1)
        let rightChild = FormulaElement(double: Double.greatestFiniteMagnitude)
        element = FormulaElement(elementType: ElementType.OPERATOR, value: Operators.getName(Operator.MINUS), leftChild: leftChild, rightChild: rightChild, parent: nil)
        
        formula = Formula(formulaElement: element)!
        XCTAssertEqual(-Double.infinity, self.interpreter.interpretDouble(formula, for: object))
    }
    
    func testDivisionByZero() {
        let leftChild = FormulaElement(double: 0)
        let rightChild = FormulaElement(double: 0)
        let element = FormulaElement(elementType: ElementType.OPERATOR, value: Operators.getName(Operator.DIVIDE), leftChild: leftChild, rightChild: rightChild, parent: nil)
        let formula = Formula(formulaElement: element)!
        
        XCTAssertTrue(self.interpreter.interpretDouble(formula, for: object).isNaN)
    }
}
