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

final class InternFormulaTokenSelectionTest: XCTestCase {
    var internFormula: InternFormula?

    override func setUp() {
        super.setUp()
        let internTokens = NSMutableArray()
        internTokens.add(InternToken(type: TOKEN_TYPE_FUNCTION_NAME, andValue: "SIN"))
        internTokens.add(InternToken(type: TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_OPEN))
        internTokens.add(InternToken(type: TOKEN_TYPE_NUMBER, andValue: "42.42"))
        internTokens.add(InternToken(type: TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_CLOSE))

        internFormula = InternFormula(internTokenList: internTokens)
        internFormula?.generateExternFormulaStringAndInternExternMapping()
        let doubleClickIndex = Int((internFormula?.getExternFormulaString()?.count)!)
        internFormula?.setCursorAndSelection(Int32(doubleClickIndex), selected: true)

    }

    func testReplaceFunctionByToken() {
        XCTAssertEqual(0, internFormula?.getSelection().getStartIndex(), "Selection start index not as expected")
        XCTAssertEqual(3, internFormula?.getSelection().getEndIndex(), "Selection end index not as expected")

        let tokenSelection: InternFormulaTokenSelection? = internFormula?.getSelection()
        var tokenSelectionDeepCopy = tokenSelection?.mutableCopy(with: nil) as? InternFormulaTokenSelection

        XCTAssertTrue((tokenSelection?.equals(tokenSelectionDeepCopy))!, "Deep copy of InternFormulaTokenSelection failed")

        tokenSelectionDeepCopy?.tokenSelectionType = PARSER_ERROR_SELECTION

        XCTAssertFalse((tokenSelectionDeepCopy?.equals(tokenSelection))!, "Equal error in InternFormulaTokenSelection")

        tokenSelectionDeepCopy = tokenSelection?.mutableCopy(with: nil) as? InternFormulaTokenSelection
        tokenSelectionDeepCopy?.internTokenSelectionStart = -1

        XCTAssertFalse((tokenSelectionDeepCopy?.equals(tokenSelection))!, "Equal error in InternFormulaTokenSelection")

        tokenSelectionDeepCopy = tokenSelection?.mutableCopy(with: nil) as? InternFormulaTokenSelection
        tokenSelectionDeepCopy?.internTokenSelectionEnd = -1

        XCTAssertFalse((tokenSelectionDeepCopy?.equals(tokenSelection))!, "Equal error in InternFormulaTokenSelection")

        XCTAssertFalse((tokenSelectionDeepCopy?.equals(1))!, "Equal error in InternFormulaTokenSelection")

    }
}
