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

final class InternFormulaStateTest: XCTestCase {
    var internState: InternFormulaState?
    var internStateToCompareDifferentSelection: InternFormulaState?
    var internStateTokenList1: InternFormulaState?
    var internStateTokenList2: InternFormulaState?
    var internStateListAndSelection: InternFormulaState?

    override func setUp() {
        super.setUp()
        let internTokenList: NSMutableArray? = []
        let differentInternTokenList1: NSMutableArray? = []
        let differentInternTokenList2: NSMutableArray? = []
        let internTokenSelection = InternFormulaTokenSelection(tokenSelectionType: USER_SELECTION, internTokenSelectionStart: 0, internTokenSelectionEnd: 1)
        internState = InternFormulaState(list: internTokenList, selection: nil, andExternCursorPosition: 0)
        internStateToCompareDifferentSelection = InternFormulaState(list: internTokenList, selection: internTokenSelection, andExternCursorPosition: 0)
        differentInternTokenList1!.add(InternToken(type: TOKEN_TYPE_NUMBER))
        differentInternTokenList2!.add(InternToken(type: TOKEN_TYPE_FUNCTION_NAME))
        internStateTokenList1 = InternFormulaState(list: differentInternTokenList1, selection: nil, andExternCursorPosition: 0)
        internStateTokenList2 = InternFormulaState(list: differentInternTokenList2, selection: nil, andExternCursorPosition: 0)
        internStateListAndSelection = InternFormulaState(list: differentInternTokenList1, selection: internTokenSelection, andExternCursorPosition: 0)

    }

    func testEquals() {

        XCTAssertFalse(internState == internStateToCompareDifferentSelection, "TokenSelection is different")
        XCTAssertFalse(internStateTokenList1 == internStateTokenList2, "TokenList is different")
        //TODO: XCTAssertFalse(internStateTokenList1 == 1.0, "Object to compare is not instance of InternFormulaState")
        XCTAssertTrue(internStateListAndSelection == internStateListAndSelection, "FormulaStates should be the same")
    }
}
