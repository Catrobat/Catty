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

final class FormulaEditorTest: XCTestCase {

    var formulaManager: FormulaManager?

    override func setUp() {
        super.setUp()
        formulaManager = FormulaManager(sceneSize: Util.screenSize(true))
    }

    func testGetInternTokenList() {
        let internTokenList = NSMutableArray()
        internTokenList.add(InternToken(type: TOKEN_TYPE_BRACKET_OPEN))
        internTokenList.add(InternToken(type: TOKEN_TYPE_OPERATOR, andValue: Operators.getName(Operator.MINUS)))
        internTokenList.add(InternToken(type: TOKEN_TYPE_NUMBER, andValue: "1"))
        internTokenList.add(InternToken(type: TOKEN_TYPE_BRACKET_CLOSE))

        let internParser = InternFormulaParser(tokens: (internTokenList as! [InternToken]), andFormulaManager: formulaManager)
        let parseTree: FormulaElement? = internParser!.parseFormula(for: nil)

        XCTAssertNotNil(parseTree, "Formula is not parsed correctly: ( - 1 )")

        let internTokenListAfterConversion = parseTree?.getInternTokenList()
        XCTAssertEqual(internTokenListAfterConversion?.count, internTokenList.count, "Generate InternTokenList from Tree error")

        for index in 0..<(internTokenListAfterConversion?.count ?? 0) {
            XCTAssertTrue(((internTokenListAfterConversion?[index] as? InternToken)?.isEqual(to: internTokenList[index] as? InternToken))!, "Generate InternTokenList from Tree error")
        }

        internTokenList.removeAllObjects()
    }
}
