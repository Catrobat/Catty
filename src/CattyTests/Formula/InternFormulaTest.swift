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

final class InternFormulaTest: XCTestCase {

    var internFormulaTokenSelection: InternFormulaTokenSelection?
    var externCursorPosition: Int = 0
    var externInternRepresentationMapping: ExternInternRepresentationMapping?
    var cursorPositionInternTokenIndex: Int = 0

    func testInsertRightToCurrentToken() {
        var internTokens = NSMutableArray()
        internTokens.add(InternToken(type: TOKEN_TYPE_OPERATOR, andValue: Operators.getName(Operator.PLUS)))
        var internFormula = InternFormula(internTokenList: internTokens)
        internFormula!.generateExternFormulaStringAndInternExternMapping()
        internFormula!.setCursorAndSelection(0, selected: false)
        internFormula!.handleKeyInput(withName: "DECIMAL_MARK", butttonType: 413)

        XCTAssertTrue(((internTokens[0] as! InternToken).getStringValue() == "0."), "Enter decimal mark error")

        internTokens = NSMutableArray()

        internTokens.add(InternToken(type: TOKEN_TYPE_OPERATOR, andValue: Operators.getName(Operator.PLUS)))
        internFormula = InternFormula(internTokenList: internTokens)
        internFormula!.generateExternFormulaStringAndInternExternMapping()
        internFormula!.setCursorAndSelection(1, selected: false)
        internFormula!.handleKeyInput(withName: "DECIMAL_MARK", butttonType: 413)

        XCTAssertTrue(((internTokens[1] as! InternToken).getStringValue() == "0."), "Enter decimal mark error")

        internTokens = NSMutableArray()

        internFormula = InternFormula(internTokenList: internTokens)
        internFormula!.generateExternFormulaStringAndInternExternMapping()
        internFormula!.setCursorAndSelection(0, selected: false)
        internFormula!.handleKeyInput(withName: "DECIMAL_MARK", butttonType: 413)

        XCTAssertTrue(((internTokens[0] as! InternToken).getStringValue() == "0."), "Enter decimal mark error")
    }

    func testInsertLeftToCurrentToken() {
        var internTokens = NSMutableArray()
        internTokens.add(InternToken(type: TOKEN_TYPE_NUMBER, andValue: "42.42"))
        var internFormula = InternFormula(internTokenList: internTokens)
        internFormula!.generateExternFormulaStringAndInternExternMapping()
        internFormula!.setCursorAndSelection(0, selected: false)
        let externFormulaStringBeforeInput = internFormula!.getExternFormulaString()
        internFormula!.handleKeyInput(withName: "DECIMAL_MARK", butttonType: 413)

        XCTAssertTrue((externFormulaStringBeforeInput == internFormula!.getExternFormulaString()), "Number changed!")

        internTokens = NSMutableArray()
        internTokens.add(InternToken(type: TOKEN_TYPE_NUMBER, andValue: "42.42"))
        internTokens.add(InternToken(type: TOKEN_TYPE_OPERATOR, andValue: Operators.getName(Operator.PLUS)))
        internFormula = InternFormula(internTokenList: internTokens)
        internFormula!.generateExternFormulaStringAndInternExternMapping()
        internFormula!.setCursorAndSelection(6, selected: false)
        internFormula!.handleKeyInput(withName: "0", butttonType: 1)

        XCTAssertTrue(((internTokens[0] as! InternToken).getStringValue() == "42.420"), "Append number error")

        internTokens = NSMutableArray()
        internTokens.add(InternToken(type: TOKEN_TYPE_NUMBER, andValue: "42.42"))
        internTokens.add(InternToken(type: TOKEN_TYPE_OPERATOR, andValue: Operators.getName(Operator.PLUS)))
        internFormula = InternFormula(internTokenList: internTokens)
        internFormula!.generateExternFormulaStringAndInternExternMapping()
        internFormula!.setCursorAndSelection(6, selected: false)
        internFormula!.handleKeyInput(withName: "DECIMAL_MARK", butttonType: 413)

        XCTAssertTrue(((internTokens[0] as! InternToken).getStringValue() == "42.42"), "Append number error")

        internTokens = NSMutableArray()
        internTokens.add(InternToken(type: TOKEN_TYPE_NUMBER, andValue: "4242"))
        internTokens.add(InternToken(type: TOKEN_TYPE_OPERATOR, andValue: Operators.getName(Operator.PLUS)))
        internFormula = InternFormula(internTokenList: internTokens)
        internFormula!.generateExternFormulaStringAndInternExternMapping()
        internFormula!.setCursorAndSelection(5, selected: false)
        internFormula!.handleKeyInput(withName: "DECIMAL_MARK", butttonType: 413)

        XCTAssertTrue(((internTokens[0] as! InternToken).getStringValue() == "4242."), "Append decimal mark error")

        internTokens = NSMutableArray()
        internTokens.add(InternToken(type: TOKEN_TYPE_OPERATOR, andValue: Operators.getName(Operator.PLUS)))
        internFormula = InternFormula(internTokenList: internTokens)
        internFormula!.generateExternFormulaStringAndInternExternMapping()
        internFormula!.setCursorAndSelection(0, selected: false)
        internFormula!.handleKeyInput(withName: "DECIMAL_MARK", butttonType: 413)

        XCTAssertTrue(((internTokens[0] as! InternToken).getStringValue() == "0."), "Prepend decimal mark error")
    }

    func testInsertOperaorInNumberToken() {
        let internTokens = NSMutableArray()
        internTokens.add(InternToken(type: TOKEN_TYPE_NUMBER, andValue: "1234"))
        let internFormula = InternFormula(internTokenList: internTokens)
        internFormula!.generateExternFormulaStringAndInternExternMapping()
        internFormula!.setCursorAndSelection(2, selected: false)
        internFormula!.handleKeyInput(withName: "MULT", butttonType: 410)

        XCTAssertTrue(((internTokens[0] as! InternToken).getStringValue() == "12"), "Insert operator in number token error")
        XCTAssertTrue(((internTokens[1] as! InternToken).getStringValue() == "MULT"), "Insert operator in number token error")
        XCTAssertTrue(((internTokens[2] as! InternToken).getStringValue() == "34"), "Insert operator in number token error")
    }

    func testSelectBrackets() {
        let internTokens = NSMutableArray()
        internTokens.add(InternToken(type: TOKEN_TYPE_BRACKET_OPEN))
        internTokens.add(InternToken(type: TOKEN_TYPE_FUNCTION_NAME, andValue: "COS"))
        internTokens.add(InternToken(type: TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_OPEN))
        internTokens.add(InternToken(type: TOKEN_TYPE_NUMBER, andValue: "42.42"))
        internTokens.add(InternToken(type: TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_CLOSE))
        internTokens.add(InternToken(type: TOKEN_TYPE_BRACKET_CLOSE))

        let internFormula = InternFormula(internTokenList: internTokens)
        internFormula!.generateExternFormulaStringAndInternExternMapping()
        let externFormulaString = internFormula!.getExternFormulaString()
        var doubleClickIndex: Int = externFormulaString!.count

        var offsetRight: Int = 0

        while offsetRight < 2 {
            internFormula!.setCursorAndSelection((Int32(doubleClickIndex - offsetRight)), selected: true)
            XCTAssertEqual(0, internFormula!.getSelection().getStartIndex(), "Selection start index not as expected")
            XCTAssertEqual(5, internFormula!.getSelection().getEndIndex(), "Selection end index not as expected")
            offsetRight += 1
        }

        internFormula!.setCursorAndSelection((Int32(doubleClickIndex - offsetRight)), selected: true)

        XCTAssertEqual(1, internFormula!.getSelection().getStartIndex(), "Selection start index not as expected")
        XCTAssertEqual(4, internFormula!.getSelection().getEndIndex(), "Selection end index not as expected")

        doubleClickIndex = 0
        var offsetLeft: Int = 0

        while offsetLeft < 2 {
            internFormula!.setCursorAndSelection((Int32(doubleClickIndex + offsetLeft)), selected: true)
            XCTAssertEqual(0, internFormula!.getSelection().getStartIndex(), "Selection start index not as expected")
            XCTAssertEqual(5, internFormula!.getSelection().getEndIndex(), "Selection end index not as expected")
            offsetLeft += 1
        }

        internFormula!.setCursorAndSelection((Int32(doubleClickIndex + offsetLeft)), selected: true)

        XCTAssertEqual(1, internFormula!.getSelection().getStartIndex(), "Selection start index not as expected")
        XCTAssertEqual(4, internFormula!.getSelection().getEndIndex(), "Selection end index not as expected")

    }

    func testSelectFunctionAndSingleTab() {
        let internTokens = NSMutableArray()
        internTokens.add(InternToken(type: TOKEN_TYPE_FUNCTION_NAME, andValue: "RAND"))
        internTokens.add(InternToken(type: TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_OPEN))
        internTokens.add(InternToken(type: TOKEN_TYPE_NUMBER, andValue: "42.42"))
        internTokens.add(InternToken(type: TOKEN_TYPE_FUNCTION_PARAMETER_DELIMITER))
        internTokens.add(InternToken(type: TOKEN_TYPE_NUMBER, andValue: "42.42"))
        internTokens.add(InternToken(type: TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_CLOSE))

        let internFormula = InternFormula(internTokenList: internTokens)
        internFormula!.generateExternFormulaStringAndInternExternMapping()
        let externFormulaString = internFormula!.getExternFormulaString()

        internFormula!.setCursorAndSelection(0, selected: true)
        XCTAssertEqual(0, internFormula!.getSelection().getStartIndex(), "Single Tab before Function fail")

        var doubleClickIndex: Int = externFormulaString!.count
        var offsetRight: Int = 0

        while offsetRight < 2 {
            internFormula!.setCursorAndSelection((Int32(doubleClickIndex - offsetRight)), selected: true)
            XCTAssertEqual(0, internFormula!.getSelection().getStartIndex(), "Selection start index not as expected")
            XCTAssertEqual(5, internFormula!.getSelection().getEndIndex(), "Selection end index not as expected")
            offsetRight += 1
        }

        internFormula!.setCursorAndSelection((Int32(doubleClickIndex - offsetRight)), selected: true)

        XCTAssertEqual(4, internFormula!.getSelection().getStartIndex(), "Selection start index not as expected")
        XCTAssertEqual(4, internFormula!.getSelection().getEndIndex(), "Selection end index not as expected")

        doubleClickIndex = 0

        internFormula!.setCursorAndSelection(Int32(doubleClickIndex), selected: true)

        XCTAssertEqual(0, internFormula!.getSelection().getStartIndex(), "Selection start index not as expected")
        XCTAssertEqual(5, internFormula!.getSelection().getEndIndex(), "Selection end index not as expected")

        doubleClickIndex = "random".count

        let singleClickIndex: Int = doubleClickIndex

        internFormula!.setCursorAndSelection(Int32(singleClickIndex), selected: false)
        XCTAssertEqual(0, internFormula!.getSelection().getStartIndex(), "Selection start index not as expected")
        XCTAssertEqual(5, internFormula!.getSelection().getEndIndex(), "Selection end index not as expected")

        internFormula!.setCursorAndSelection(Int32(doubleClickIndex), selected: true)
        XCTAssertEqual(0, internFormula!.getSelection().getStartIndex(), "Selection start index not as expected")
        XCTAssertEqual(5, internFormula!.getSelection().getEndIndex(), "Selection end index not as expected")

        doubleClickIndex += 1

        internFormula!.setCursorAndSelection(Int32(doubleClickIndex), selected: true)
        XCTAssertEqual(0, internFormula!.getSelection().getStartIndex(), "Selection start index not as expected")
        XCTAssertEqual(5, internFormula!.getSelection().getEndIndex(), "Selection end index not as expected")

        doubleClickIndex += " 42.42 ".count

        internFormula!.setCursorAndSelection(Int32(doubleClickIndex), selected: true)
        XCTAssertEqual(0, internFormula!.getSelection().getStartIndex(), "Selection start index not as expected")
        XCTAssertEqual(5, internFormula!.getSelection().getEndIndex(), "Selection end index not as expected")

        doubleClickIndex += 1

        internFormula!.setCursorAndSelection(Int32(doubleClickIndex), selected: true)
        XCTAssertEqual(0, internFormula!.getSelection().getStartIndex(), "Selection start index not as expected")
        XCTAssertEqual(5, internFormula!.getSelection().getEndIndex(), "Selection end index not as expected")

        doubleClickIndex += 1

        internFormula!.setCursorAndSelection(Int32(doubleClickIndex), selected: true)
        XCTAssertEqual(4, internFormula!.getSelection().getStartIndex(), "Selection start index not as expected")
        XCTAssertEqual(4, internFormula!.getSelection().getEndIndex(), "Selection end index not as expected")

    }

    func testReplaceSelection() {
        let internTokens = NSMutableArray()
        internTokens.add(InternToken(type: TOKEN_TYPE_NUMBER, andValue: "42.42"))

        let internFormula = InternFormula(internTokenList: internTokens)
        internFormula!.generateExternFormulaStringAndInternExternMapping()
        let externFormulaString = internFormula!.getExternFormulaString()

        internFormula!.setCursorAndSelection(1, selected: true)

        let tokenSelectionStartIndex: Int = -1
        let tokenSelectionEndIndex: Int = 3

        let internFormulaTokenSelection = InternFormulaTokenSelection(tokenSelectionType: USER_SELECTION,
                                                                      internTokenSelectionStart: tokenSelectionStartIndex,
                                                                      internTokenSelectionEnd: tokenSelectionEndIndex)

        internFormula!.internFormulaTokenSelection = internFormulaTokenSelection

        internFormula!.handleKeyInput(withName: "0", butttonType: 1)
        internFormula!.generateExternFormulaStringAndInternExternMapping()

        XCTAssertTrue((internFormula!.getExternFormulaString() == externFormulaString), "ExternFormulaString changed on buggy input!")
    }

    func testHandleDeletion() {
        let internTokens = NSMutableArray()
        internTokens.add(InternToken(type: TOKEN_TYPE_NUMBER, andValue: "42.42"))

        let internFormula = InternFormula(internTokenList: internTokens)
        internFormula!.generateExternFormulaStringAndInternExternMapping()
        let externFormulaString = internFormula!.getExternFormulaString()

        internFormula!.setCursorAndSelection(0, selected: false)

        internFormula!.handleKeyInput(withName: "CLEAR", butttonType: 4000)
        internFormula!.generateExternFormulaStringAndInternExternMapping()

        XCTAssertTrue((internFormula!.getExternFormulaString() == externFormulaString), "ExternFormulaString changed on buggy input!")

    }

    func testDeleteInternTokenByIndex() {
        let internTokens = NSMutableArray()
        internTokens.add(InternToken(type: TOKEN_TYPE_NUMBER, andValue: "42.42"))
        internTokens.add(InternToken(type: TOKEN_TYPE_OPERATOR, andValue: Operators.getName(Operator.PLUS)))
        internTokens.add(InternToken(type: TOKEN_TYPE_NUMBER, andValue: "42.42"))

        var internFormula = InternFormula(internTokenList: internTokens)
        internFormula!.generateExternFormulaStringAndInternExternMapping()
        internFormula!.setCursorAndSelection(1, selected: false)

        var externFormulaString = internFormula!.getExternFormulaString()

        internFormula!.externCursorPosition = -1
        internFormula!.handleKeyInput(withName: "CLEAR", butttonType: 4000)
        internFormula!.generateExternFormulaStringAndInternExternMapping()

        XCTAssertTrue((internFormula!.getExternFormulaString() == externFormulaString), "ExternFormulaString changed on buggy input!")

        internTokens.removeAllObjects()

        internTokens.add(InternToken(type: TOKEN_TYPE_FUNCTION_NAME, andValue: "SIN"))
        internTokens.add(InternToken(type: TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_OPEN, andValue: Operators.getName(Operator.PLUS)))
        internTokens.add(InternToken(type: TOKEN_TYPE_NUMBER, andValue: "42.42"))

        internFormula = InternFormula(internTokenList: internTokens)
        internFormula!.generateExternFormulaStringAndInternExternMapping()
        internFormula!.setCursorAndSelection(1, selected: false)

        externFormulaString = internFormula!.getExternFormulaString()

        internFormula!.handleKeyInput(withName: "CLEAR", butttonType: 4000)
        internFormula!.generateExternFormulaStringAndInternExternMapping()

        XCTAssertTrue((internFormula!.getExternFormulaString() == externFormulaString), "ExternFormulaString changed on buggy input!")

        internTokens.removeAllObjects()

        internTokens.add(InternToken(type: TOKEN_TYPE_FUNCTION_NAME, andValue: "SIN"))
        internTokens.add(InternToken(type: TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_OPEN))
        internTokens.add(InternToken(type: TOKEN_TYPE_NUMBER, andValue: "42.42"))

        internFormula = InternFormula(internTokenList: internTokens)
        internFormula!.generateExternFormulaStringAndInternExternMapping()
        internFormula!.setCursorAndSelection(Int32("sin".count + 1), selected: false)

        externFormulaString = internFormula!.getExternFormulaString()

        internFormula!.handleKeyInput(withName: "CLEAR", butttonType: 4000)
        internFormula!.generateExternFormulaStringAndInternExternMapping()

        XCTAssertTrue((internFormula!.getExternFormulaString() == externFormulaString), "ExternFormulaString changed on buggy input!")

        internTokens.removeAllObjects()

        internTokens.add(InternToken(type: TOKEN_TYPE_FUNCTION_NAME, andValue: "SIN"))
        internTokens.add(InternToken(type: TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_CLOSE))
        internTokens.add(InternToken(type: TOKEN_TYPE_NUMBER, andValue: "42.42"))

        internFormula = InternFormula(internTokenList: internTokens)
        internFormula!.generateExternFormulaStringAndInternExternMapping()
        internFormula!.setCursorAndSelection(Int32("SIN".count + 2), selected: false)

        externFormulaString = internFormula!.getExternFormulaString()

        internFormula!.handleKeyInput(withName: "CLEAR", butttonType: 4000)
        internFormula!.generateExternFormulaStringAndInternExternMapping()

        XCTAssertTrue((internFormula!.getExternFormulaString() == externFormulaString), "ExternFormulaString changed on buggy input!")

        internTokens.removeAllObjects()

        internTokens.add(InternToken(type: TOKEN_TYPE_FUNCTION_NAME, andValue: "SIN"))
        internTokens.add(InternToken(type: TOKEN_TYPE_FUNCTION_PARAMETER_DELIMITER))
        internTokens.add(InternToken(type: TOKEN_TYPE_NUMBER, andValue: "42.42"))

        internFormula = InternFormula(internTokenList: internTokens)
        internFormula!.generateExternFormulaStringAndInternExternMapping()
        internFormula!.setCursorAndSelection(Int32("SIN".count + 2), selected: false)

        externFormulaString = internFormula!.getExternFormulaString()

        internFormula!.handleKeyInput(withName: "CLEAR", butttonType: 4000)
        internFormula!.generateExternFormulaStringAndInternExternMapping()

        XCTAssertTrue((internFormula!.getExternFormulaString() == externFormulaString), "ExternFormulaString changed on buggy input!")

        internTokens.removeAllObjects()

    }

    func testSetExternCursorPositionLeftTo() {
        let internTokens = NSMutableArray()
        internTokens.add(InternToken(type: TOKEN_TYPE_NUMBER, andValue: "42.42"))
        internTokens.add(InternToken(type: TOKEN_TYPE_OPERATOR, andValue: Operators.getName(Operator.PLUS)))
        internTokens.add(InternToken(type: TOKEN_TYPE_NUMBER, andValue: "42.42"))

        let internFormula = InternFormula(internTokenList: internTokens)
        internFormula!.generateExternFormulaStringAndInternExternMapping()
        internFormula!.setCursorAndSelection(1, selected: false)

        let externInternRepresentationMapping = ExternInternRepresentationMapping()

        let externCursorPositionBeforeMethodCall = internFormula!.getExternCursorPosition()
        internFormula!.externInternRepresentationMapping = externInternRepresentationMapping
        internFormula!.setExternCursorPositionLeftTo(1)

        XCTAssertEqual(externCursorPositionBeforeMethodCall, internFormula!.getExternCursorPosition(), "Extern cursor position changed!")

    }

    func testSetExternCursorPositionRightTo() {
        let internTokens = NSMutableArray()
        var internFormula = InternFormula(internTokenList: internTokens)
        internFormula!.generateExternFormulaStringAndInternExternMapping()
        internFormula!.setCursorAndSelection(1, selected: false)

        var externCursorPositionBeforeMethodCall = internFormula!.getExternCursorPosition()

        internFormula!.setExternCursorPositionRightTo(1)

        XCTAssertEqual(externCursorPositionBeforeMethodCall, internFormula!.getExternCursorPosition(), "Extern cursor position changed!")

        internTokens.removeAllObjects()

        internTokens.add(InternToken(type: TOKEN_TYPE_NUMBER, andValue: "42.42"))
        internTokens.add(InternToken(type: TOKEN_TYPE_OPERATOR, andValue: Operators.getName(Operator.PLUS)))
        internTokens.add(InternToken(type: TOKEN_TYPE_NUMBER, andValue: "42.42"))

        internFormula = InternFormula(internTokenList: internTokens)
        internFormula!.generateExternFormulaStringAndInternExternMapping()
        internFormula!.setCursorAndSelection(1, selected: false)
        internFormula!.setExternCursorPositionRightTo(3)

        XCTAssertEqual(13, internFormula!.getExternCursorPosition(), "Extern cursor position changed!")

        let externInternRepresentationMapping = ExternInternRepresentationMapping()
        internFormula!.externInternRepresentationMapping = externInternRepresentationMapping

        externCursorPositionBeforeMethodCall = internFormula!.getExternCursorPosition()
        internFormula!.setExternCursorPositionRightTo(2)

        XCTAssertEqual(externCursorPositionBeforeMethodCall, internFormula!.getExternCursorPosition(), "Extern cursor position changed!")
    }

    func testSelectCursorPositionInternTokenOnError() {
        let internTokens = NSMutableArray()
        internTokens.add(InternToken(type: TOKEN_TYPE_BRACKET_OPEN))
        internTokens.add(InternToken(type: TOKEN_TYPE_NUMBER, andValue: "42.42"))

        let internFormula = InternFormula(internTokenList: internTokens)

        internFormula!.selectCursorPositionInternToken(USER_SELECTION)

        XCTAssertNil(internFormula!.internFormulaTokenSelection, "Selection changed!")

    }

    func testSelectCursorPositionInternToken() {
        var internTokens = NSMutableArray()
        internTokens.add(InternToken(type: TOKEN_TYPE_BRACKET_OPEN))
        internTokens.add(InternToken(type: TOKEN_TYPE_NUMBER, andValue: "42.42"))

        var internFormula = InternFormula(internTokenList: internTokens)
        internFormula!.generateExternFormulaStringAndInternExternMapping()
        internFormula!.setCursorAndSelection(0, selected: true)

        XCTAssertNil(internFormula!.internFormulaTokenSelection, "Selection changed!")

        internTokens.removeAllObjects()

        internTokens.add(InternToken(type: TOKEN_TYPE_BRACKET_CLOSE))
        internTokens.add(InternToken(type: TOKEN_TYPE_NUMBER, andValue: "42.42"))

        internFormula = InternFormula(internTokenList: internTokens)
        internFormula!.generateExternFormulaStringAndInternExternMapping()
        internFormula!.setCursorAndSelection(0, selected: true)

        XCTAssertNil(internFormula!.internFormulaTokenSelection, "Selection changed!")

        internTokens.removeAllObjects()

        internTokens.add(InternToken(type: TOKEN_TYPE_FUNCTION_NAME, andValue: "SIN"))
        internTokens.add(InternToken(type: TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_OPEN))
        internTokens.add(InternToken(type: TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_CLOSE))
        internTokens.add(InternToken(type: TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_CLOSE))
        internTokens.add(InternToken(type: TOKEN_TYPE_NUMBER, andValue: "42.42"))

        internFormula = InternFormula(internTokenList: internTokens)
        internFormula!.generateExternFormulaStringAndInternExternMapping()
        internFormula!.setCursorAndSelection(Int32("SIN".count + 4), selected: true)

        XCTAssertNil(internFormula!.internFormulaTokenSelection, "Selection changed!")

        internTokens.removeAllObjects()

        internTokens.add(InternToken(type: TOKEN_TYPE_FUNCTION_NAME, andValue: "SIN"))
        internTokens.add(InternToken(type: TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_OPEN))
        internTokens.add(InternToken(type: TOKEN_TYPE_FUNCTION_PARAMETER_DELIMITER))
        internTokens.add(InternToken(type: TOKEN_TYPE_NUMBER, andValue: "42.42"))

        internFormula = InternFormula(internTokenList: internTokens)
        internFormula!.generateExternFormulaStringAndInternExternMapping()
        internFormula!.setCursorAndSelection(Int32("SIN".count + 2), selected: true)

        XCTAssertNil(internFormula!.internFormulaTokenSelection, "Selection changed!")

        internTokens.removeAllObjects()

        internTokens.add(InternToken(type: TOKEN_TYPE_FUNCTION_NAME, andValue: "SIN"))
        internTokens.add(InternToken(type: TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_OPEN))
        internTokens.add(InternToken(type: TOKEN_TYPE_NUMBER, andValue: "42.42"))

        internFormula = InternFormula(internTokenList: internTokens)
        internFormula!.generateExternFormulaStringAndInternExternMapping()
        internFormula!.setCursorAndSelection(Int32("SIN".count), selected: true)

        XCTAssertNil(internFormula!.internFormulaTokenSelection, "Selection changed!")

        internTokens.removeAllObjects()

        internTokens.add(InternToken(type: TOKEN_TYPE_FUNCTION_NAME, andValue: "SIN"))
        internTokens.add(InternToken(type: TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_OPEN))
        internTokens.add(InternToken(type: TOKEN_TYPE_NUMBER, andValue: "42.42"))

        internFormula = InternFormula(internTokenList: internTokens)
        internFormula!.generateExternFormulaStringAndInternExternMapping()
        internFormula!.setCursorAndSelection(1, selected: false)

        XCTAssertNil(internFormula!.internFormulaTokenSelection, "Selection changed!")
    }

    func testreplaceCursorPositionInternTokenByTokenList() {
        let tokensToReplaceWith = NSMutableArray()
        tokensToReplaceWith.add(InternToken(type: TOKEN_TYPE_NUMBER, andValue: "1"))

        let internTokens = NSMutableArray()
        internTokens.add(InternToken(type: TOKEN_TYPE_NUMBER, andValue: "42.42"))

        var internFormula = InternFormula(internTokenList: internTokens)
        internFormula!.generateExternFormulaStringAndInternExternMapping()
        internFormula!.setCursorAndSelection(1, selected: true)

        internFormula!.cursorPositionInternTokenIndex = -1

        XCTAssertEqual(DO_NOT_MODIFY, internFormula!.replaceCursorPositionInternToken(byTokenList: (tokensToReplaceWith as! [Any])), "Do not modify on error")

        tokensToReplaceWith.removeAllObjects()
        tokensToReplaceWith.add(InternToken(type: TOKEN_TYPE_PERIOD))

        XCTAssertEqual(DO_NOT_MODIFY, internFormula!.replaceCursorPositionInternToken(byTokenList: (tokensToReplaceWith as! [Any])), "Do not modify on when second period token is inserted")

        internTokens.removeAllObjects()
        internTokens.add(InternToken(type: TOKEN_TYPE_NUMBER, andValue: "4242"))

        internFormula = InternFormula(internTokenList: internTokens)
        internFormula!.generateExternFormulaStringAndInternExternMapping()
        internFormula!.setCursorAndSelection(1, selected: false)

        internFormula!.cursorPositionInternTokenIndex = -1

        XCTAssertEqual(DO_NOT_MODIFY, internFormula!.replaceCursorPositionInternToken(byTokenList: (tokensToReplaceWith as! [Any])), "Do not modify on error")

        internTokens.removeAllObjects()

        internTokens.add(InternToken(type: TOKEN_TYPE_FUNCTION_NAME, andValue: "SIN"))
        internTokens.add(InternToken(type: TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_OPEN))

        internFormula = InternFormula(internTokenList: internTokens)
        internFormula!.generateExternFormulaStringAndInternExternMapping()
        internFormula!.setCursorAndSelection(1, selected: false)

        XCTAssertEqual(DO_NOT_MODIFY, internFormula!.replaceCursorPositionInternToken(byTokenList: (tokensToReplaceWith as! [Any])), "Do not modify on error")

        internTokens.removeAllObjects()

        internTokens.add(InternToken(type: TOKEN_TYPE_SENSOR, andValue: BrightnessSensor.tag))

        internFormula = InternFormula(internTokenList: internTokens)
        internFormula!.generateExternFormulaStringAndInternExternMapping()
        internFormula!.setCursorAndSelection(1, selected: false)

        XCTAssertEqual(AM_RIGHT, internFormula!.replaceCursorPositionInternToken(byTokenList: (tokensToReplaceWith as! [Any])), "Do not modify on error")

        internTokens.removeAllObjects()

        internTokens.add(InternToken(type: TOKEN_TYPE_SENSOR, andValue: BrightnessSensor.tag))

        internFormula = InternFormula(internTokenList: internTokens)
        internFormula!.generateExternFormulaStringAndInternExternMapping()
        internFormula!.setCursorAndSelection(1, selected: false)

        tokensToReplaceWith.removeAllObjects()
        tokensToReplaceWith.add(InternToken(type: TOKEN_TYPE_FUNCTION_NAME))

        XCTAssertEqual(AM_RIGHT, internFormula!.replaceCursorPositionInternToken(byTokenList: (tokensToReplaceWith as! [Any])), "Do not modify on error")
    }
}
