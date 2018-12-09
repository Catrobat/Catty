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

final class InternFormulaParserStringFunctionsTest: XCTestCase {
    override class func setUp() {
        super.setUp()
    }

    func getFormulaElement(forFunction tag: String?, withLeftValue leftValue: String?, andRightValue rightValue: String?) -> FormulaElement? {
        let leftElement = FormulaElement(type: "STRING", value: leftValue, leftChild: nil, rightChild: nil, parent: nil)
        var rightElement: FormulaElement?

        if rightValue != nil {
            rightElement = FormulaElement(type: "STRING", value: rightValue, leftChild: nil, rightChild: nil, parent: nil)
        }

        let formula = FormulaElement(type: "FUNCTION", value: tag, leftChild: leftElement, rightChild: rightElement, parent: nil)

        return formula
    }

    func testLength() {
        let firstParameter = "testString"
        let formula = getFormulaElement(forFunction: "LENGTH", withLeftValue: firstParameter, andRightValue: nil)
        XCTAssertNotNil(formula, "Formula is not parsed correctly!")
    }
}
