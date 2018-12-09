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

final class FormulaParserErrorDetectionTest: XCTestCase {

    var formulaManager: FormulaManager?

    override func setUp() {
        super.setUp()
        formulaManager = FormulaManager(sceneSize: Util.screenSize(true))
    }

    func testTooManyOperators() {
        let internTokenList = NSMutableArray()
        internTokenList.add(InternToken(type: TOKEN_TYPE_OPERATOR, andValue: Operators.getName(Operator.MINUS)))
        internTokenList.add(InternToken(type: TOKEN_TYPE_OPERATOR, andValue: Operators.getName(Operator.MINUS)))
        internTokenList.add(InternToken(type: TOKEN_TYPE_NUMBER, andValue: "42.42"))

        var internParser = InternFormulaParser(tokens: (internTokenList as! [InternToken]), andFormulaManager: formulaManager)
        var parseTree: FormulaElement? = internParser!.parseFormula(for: nil)

        XCTAssertNil(parseTree, "Invalid formula parsed: - - 42.42")
        XCTAssertEqual(1, internParser!.errorTokenIndex, "Error Token Index is not as expected")

        internTokenList.removeAllObjects()
        internTokenList.add(InternToken(type: TOKEN_TYPE_OPERATOR, andValue: Operators.getName(Operator.PLUS)))

        internParser = InternFormulaParser(tokens: (internTokenList as! [InternToken]), andFormulaManager: formulaManager)
        parseTree = internParser!.parseFormula(for: nil)

        XCTAssertNil(parseTree, "Invalid formula parsed: +")
        XCTAssertEqual(0, internParser!.errorTokenIndex, "Error Token Index is not as expected")

        internTokenList.removeAllObjects()
        internTokenList.add(InternToken(type: TOKEN_TYPE_OPERATOR, andValue: Operators.getName(Operator.MINUS)))
        internTokenList.add(InternToken(type: TOKEN_TYPE_OPERATOR, andValue: Operators.getName(Operator.PLUS)))

        internParser = InternFormulaParser(tokens: (internTokenList as! [InternToken]), andFormulaManager: formulaManager)
        parseTree = internParser!.parseFormula(for: nil)

        XCTAssertNil(parseTree, "Invalid formula parsed: + -")
        XCTAssertEqual(1, internParser!.errorTokenIndex, "Error Token Index is not as expected")

        internTokenList.removeAllObjects()
        internTokenList.add(InternToken(type: TOKEN_TYPE_OPERATOR, andValue: Operators.getName(Operator.MULT)))
        internTokenList.add(InternToken(type: TOKEN_TYPE_NUMBER, andValue: "42.53"))

        internParser = InternFormulaParser(tokens: (internTokenList as! [InternToken]), andFormulaManager: formulaManager)
        parseTree = internParser!.parseFormula(for: nil)

        XCTAssertNil(parseTree, "Invalid formula parsed: * 42.53")
        XCTAssertEqual(0, internParser!.errorTokenIndex, "Error Token Index is not as expected")

        internTokenList.removeAllObjects()
        internTokenList.add(InternToken(type: TOKEN_TYPE_OPERATOR, andValue: Operators.getName(Operator.MINUS)))
        internTokenList.add(InternToken(type: TOKEN_TYPE_NUMBER, andValue: "42.42"))
        internTokenList.add(InternToken(type: TOKEN_TYPE_OPERATOR, andValue: Operators.getName(Operator.MINUS)))
        internTokenList.add(InternToken(type: TOKEN_TYPE_NUMBER, andValue: "42.42"))
        internTokenList.add(InternToken(type: TOKEN_TYPE_OPERATOR, andValue: Operators.getName(Operator.MINUS)))

        internParser = InternFormulaParser(tokens: (internTokenList as! [InternToken]), andFormulaManager: formulaManager)
        parseTree = internParser!.parseFormula(for: nil)

        XCTAssertNil(parseTree, "Invalid formula parsed: - 42.42 - 42.42 -")
        XCTAssertEqual(5, internParser!.errorTokenIndex, "Error Token Index is not as expected")
    }

    func testOperatorMissing() {
        let internTokenList = NSMutableArray()
        internTokenList.add(InternToken(type: TOKEN_TYPE_NUMBER, andValue: "42.53"))
        internTokenList.add(InternToken(type: TOKEN_TYPE_NUMBER, andValue: "42.52"))

        let internParser = InternFormulaParser(tokens: (internTokenList as! [InternToken]), andFormulaManager: formulaManager)
        let parseTree: FormulaElement? = internParser!.parseFormula(for: nil)

        XCTAssertNil(parseTree, "Invalid formula parsed: 42.53 42.42")
        XCTAssertEqual(1, internParser!.errorTokenIndex, "Error Token Index is not as expected")
    }

    func testNumberMissing() {
        let internTokenList = NSMutableArray()
        internTokenList.add(InternToken(type: TOKEN_TYPE_OPERATOR, andValue: Operators.getName(Operator.MULT)))
        internTokenList.add(InternToken(type: TOKEN_TYPE_NUMBER, andValue: "42.53"))

        let internParser = InternFormulaParser(tokens: (internTokenList as! [InternToken]), andFormulaManager: formulaManager)
        let parseTree: FormulaElement? = internParser!.parseFormula(for: nil)

        XCTAssertNil(parseTree, "Invalid formula parsed: * 42.53")
        XCTAssertEqual(0, internParser!.errorTokenIndex, "Error Token Index is not as expected")
    }

    func testRightBracketMissing() {
        let internTokenList = NSMutableArray()
        internTokenList.add(InternToken(type: TOKEN_TYPE_BRACKET_OPEN))
        internTokenList.add(InternToken(type: TOKEN_TYPE_NUMBER, andValue: "42.53"))

        let internParser = InternFormulaParser(tokens: (internTokenList as! [InternToken]), andFormulaManager: formulaManager)
        let parseTree: FormulaElement? = internParser!.parseFormula(for: nil)

        XCTAssertNil(parseTree, "Invalid formula parsed: (42.53")
        XCTAssertEqual(2, internParser!.errorTokenIndex, "Error Token Index is not as expected")
    }

    func testLeftBracketMissing() {
        let internTokenList = NSMutableArray()
        internTokenList.add(InternToken(type: TOKEN_TYPE_NUMBER, andValue: "42.53"))
        internTokenList.add(InternToken(type: TOKEN_TYPE_BRACKET_CLOSE))

        let internParser = InternFormulaParser(tokens: (internTokenList as! [InternToken]), andFormulaManager: formulaManager)
        let parseTree: FormulaElement? = internParser!.parseFormula(for: nil)

        XCTAssertNil(parseTree, "Invalid formula parsed:   42.53)")
        XCTAssertEqual(1, internParser!.errorTokenIndex, "Error Token Index is not as expected")
    }

    func testOutOfBound() {
        let internTokenList = NSMutableArray()
        internTokenList.add(InternToken(type: TOKEN_TYPE_NUMBER, andValue: "42.53"))
        internTokenList.add(InternToken(type: TOKEN_TYPE_BRACKET_CLOSE))

        let internParser = InternFormulaParser(tokens: (internTokenList as! [InternToken]), andFormulaManager: formulaManager)
        let parseTree: FormulaElement? = internParser!.parseFormula(for: nil)

        XCTAssertNil(parseTree, "Invalid formula parsed: 42.53)")
        XCTAssertEqual(1, internParser!.errorTokenIndex, "Error Token Index is not as expected")
    }
}
