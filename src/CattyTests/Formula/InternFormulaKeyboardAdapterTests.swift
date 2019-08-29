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

final class InternFormulaKeyboardAdapterTests: XCTestCase {

    func testReplaceFunctionButKeepParameters() {
        let internTokenList = NSMutableArray(array: [InternToken(type: TOKEN_TYPE_FUNCTION_NAME, andValue: CosFunction.tag)!,
                                                     InternToken(type: TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_OPEN)!,
                                                     InternToken(type: TOKEN_TYPE_FUNCTION_NAME, andValue: RoundFunction.tag)!,
                                                     InternToken(type: TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_OPEN)!,
                                                     InternToken(type: TOKEN_TYPE_FUNCTION_NAME, andValue: SinFunction.tag)!,
                                                     InternToken(type: TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_OPEN)!,
                                                     InternToken(type: TOKEN_TYPE_NUMBER, andValue: "42.42")!,
                                                     InternToken(type: TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_CLOSE)!,
                                                     InternToken(type: TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_CLOSE)!,
                                                     InternToken(type: TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_CLOSE)!])

        let internFormula = InternFormula(internTokenList: internTokenList)!
        internFormula.generateExternFormulaStringAndInternExternMapping()

        setCursorAtEndAndAssertSelection(internFormula, expectedStartIndex: 0, expectedEndIndex: 9)

        internFormula.handleKeyInput(for: RandFunction())

        assertSelection(internFormula, expectedStartIndex: 2, expectedEndIndex: 8)
        setCursorAtEndAndAssertSelection(internFormula, expectedStartIndex: 0, expectedEndIndex: 11)

        internFormula.handleKeyInput(for: SqrtFunction())

        let doubleClickIndex = internFormula.getExternFormulaString().count

        assertSelection(internFormula, expectedStartIndex: 2, expectedEndIndex: 8)
        setCursorAndAssertSelection(internFormula, cursorIndex: doubleClickIndex, expectedStartIndex: 0, expectedEndIndex: 9)
    }

    func testReplaceFunctionByToken() {
        let internTokenList = NSMutableArray(array: [InternToken(type: TOKEN_TYPE_FUNCTION_NAME, andValue: CosFunction.tag)!,
                                                     InternToken(type: TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_OPEN)!,
                                                     InternToken(type: TOKEN_TYPE_FUNCTION_NAME, andValue: RoundFunction.tag)!,
                                                     InternToken(type: TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_OPEN)!,
                                                     InternToken(type: TOKEN_TYPE_FUNCTION_NAME, andValue: SinFunction.tag)!,
                                                     InternToken(type: TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_OPEN)!,
                                                     InternToken(type: TOKEN_TYPE_NUMBER, andValue: "42.42")!,
                                                     InternToken(type: TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_CLOSE)!,
                                                     InternToken(type: TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_CLOSE)!,
                                                     InternToken(type: TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_CLOSE)!])

        let internFormula = InternFormula(internTokenList: internTokenList)!
        internFormula.generateExternFormulaStringAndInternExternMapping()

        setCursorAtEndAndAssertSelection(internFormula, expectedStartIndex: 0, expectedEndIndex: 9)

        internFormula.handleKeyInput(withName: "4", buttonType: 5)
        internFormula.handleKeyInput(withName: "2", buttonType: 3)

        XCTAssertNil(internFormula.getSelection())
        setCursorAtEndAndAssertSelection(internFormula, expectedStartIndex: 0, expectedEndIndex: 0)
    }

    func testInsertOperatorInNumberToken() {
        let internTokenList = NSMutableArray(array: [InternToken(type: TOKEN_TYPE_NUMBER, andValue: "1234")!])

        let internFormula = InternFormula(internTokenList: internTokenList)!
        internFormula.generateExternFormulaStringAndInternExternMapping()
        setCursor(internFormula, cursorIndex: 2)

        internFormula.handleKeyInput(for: MultOperator())

        XCTAssertEqual(3, internTokenList.count)
        XCTAssertEqual("12", (internTokenList[0] as! InternToken).getStringValue())
        XCTAssertEqual(MultOperator.tag, (internTokenList[1] as! InternToken).getStringValue())
        XCTAssertEqual("34", (internTokenList[2] as! InternToken).getStringValue())
    }

    func testReplaceNumberByTrue() {
        let internTokenList = NSMutableArray(array: [InternToken(type: TOKEN_TYPE_NUMBER, andValue: "1234")!])
        let internFormula = InternFormula(internTokenList: internTokenList)!

        internFormula.generateExternFormulaStringAndInternExternMapping()
        XCTAssertNil(internFormula.getSelection())

        internFormula.selectWholeFormula()
        XCTAssertNotNil(internFormula.getSelection())

        internFormula.handleKeyInput(for: TrueFunction())

        XCTAssertEqual(1, internTokenList.count)
        XCTAssertEqual(TrueFunction.tag, (internTokenList[0] as! InternToken).getStringValue())
        assertSelection(internFormula, expectedStartIndex: 0, expectedEndIndex: 0)
    }

    func testLoudnessSensor() {
        let sensor = LoudnessSensor { AudioManagerMock() }
        let internFormula = InternFormula()
        internFormula.generateExternFormulaStringAndInternExternMapping()

        internFormula.handleKeyInput(for: sensor)

        let tokenList = internFormula.getInternTokenList()

        XCTAssertEqual(1, tokenList?.count)
        XCTAssertEqual(sensor.tag(), (tokenList![0]).getStringValue())
    }

    private func setCursorAtEndAndAssertSelection(_ internFormula: InternFormula, expectedStartIndex: Int, expectedEndIndex: Int) {
        let cursorIndex = internFormula.getExternFormulaString().count
        setCursorAndAssertSelection(internFormula, cursorIndex: cursorIndex, expectedStartIndex: expectedStartIndex, expectedEndIndex: expectedEndIndex)
    }

    private func setCursorAndAssertSelection(_ internFormula: InternFormula, cursorIndex: Int, expectedStartIndex: Int, expectedEndIndex: Int) {
        internFormula.setCursorAndSelection(Int32(truncatingIfNeeded: cursorIndex), selected: true)

        assertSelection(internFormula, expectedStartIndex: expectedStartIndex, expectedEndIndex: expectedEndIndex)
    }

    private func setCursor(_ internFormula: InternFormula, cursorIndex: Int) {
        internFormula.setCursorAndSelection(Int32(truncatingIfNeeded: cursorIndex), selected: false)
    }

    private func assertSelection(_ internFormula: InternFormula, expectedStartIndex: Int, expectedEndIndex: Int) {
        XCTAssertEqual(expectedStartIndex, internFormula.getSelection().getStartIndex())
        XCTAssertEqual(expectedEndIndex, internFormula.getSelection().getEndIndex())
    }
}
