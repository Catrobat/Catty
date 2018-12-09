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

final class InternFormulaUtilsTest: XCTestCase {

    func testGetFunctionByFunctionBracketCloseOnErrorInput() {
        let internTokens = NSMutableArray()
        internTokens.add(InternToken(type: TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_OPEN))
        internTokens.add(InternToken(type: TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_CLOSE))

        XCTAssertNil(InternFormulaUtils.getFunctionByFunctionBracketClose(nil, index: 0), "End function-bracket index is 0")
        XCTAssertNil(InternFormulaUtils.getFunctionByFunctionBracketClose((internTokens as! [Any]), index: 2), "End function-bracket index is InternTokenListSize")
        XCTAssertNil(InternFormulaUtils.getFunctionByFunctionBracketClose((internTokens as! [Any]), index: 1), "No function name before brackets")

        internTokens.removeAllObjects()

        internTokens.add(InternToken(type: TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_OPEN))
        internTokens.add(InternToken(type: TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_OPEN))
        internTokens.add(InternToken(type: TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_CLOSE))

        XCTAssertNil(InternFormulaUtils.getFunctionByFunctionBracketClose((internTokens as! [Any]), index: 2), "No function name before brackets")
    }

    func testGetFunctionByParameterDelimiter() {
        let internTokens = NSMutableArray()

        internTokens.add(InternToken(type: TOKEN_TYPE_FUNCTION_NAME, andValue: "RAND"))
        internTokens.add(InternToken(type: TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_OPEN))
        internTokens.add(InternToken(type: TOKEN_TYPE_FUNCTION_NAME, andValue: "RAND"))
        internTokens.add(InternToken(type: TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_OPEN))
        internTokens.add(InternToken(type: TOKEN_TYPE_NUMBER, andValue: "1"))
        internTokens.add(InternToken(type: TOKEN_TYPE_FUNCTION_PARAMETER_DELIMITER))
        internTokens.add(InternToken(type: TOKEN_TYPE_NUMBER, andValue: "1"))
        internTokens.add(InternToken(type: TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_CLOSE))
        internTokens.add(InternToken(type: TOKEN_TYPE_FUNCTION_PARAMETER_DELIMITER))
        internTokens.add(InternToken(type: TOKEN_TYPE_FUNCTION_NAME, andValue: "RAND"))
        internTokens.add(InternToken(type: TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_OPEN))
        internTokens.add(InternToken(type: TOKEN_TYPE_NUMBER, andValue: "1"))
        internTokens.add(InternToken(type: TOKEN_TYPE_FUNCTION_PARAMETER_DELIMITER))
        internTokens.add(InternToken(type: TOKEN_TYPE_NUMBER, andValue: "1"))
        internTokens.add(InternToken(type: TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_CLOSE))
        internTokens.add(InternToken(type: TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_CLOSE))

        let functionTokens = InternFormulaUtils.getFunctionByParameterDelimiter((internTokens as! [Any]), index: 8)
        XCTAssertEqual(functionTokens!.count, internTokens.count, "GetFunctionByParameter wrong function returned")

        for index in 0..<functionTokens!.count {
            if (functionTokens![index] as! InternToken).getStringValue() != nil || (internTokens[index] as! InternToken).getStringValue() != nil {
                XCTAssertTrue((functionTokens![index] as! InternToken).getType() == (internTokens[index] as! InternToken).getType() &&
                    ((functionTokens![index] as! InternToken).getStringValue() == (internTokens[index] as! InternToken).getStringValue()), "GetFunctionByParameter wrong function returned")
            }
        }

    }

    func testGetFunctionByParameterDelimiterOnErrorInput() {
        let internTokens = NSMutableArray()
        internTokens.add(InternToken(type: TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_OPEN))
        internTokens.add(InternToken(type: TOKEN_TYPE_FUNCTION_PARAMETER_DELIMITER))
        internTokens.add(InternToken(type: TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_CLOSE))

        XCTAssertNil(InternFormulaUtils.getFunctionByParameterDelimiter(nil, index: 0), "Function delimiter index is 0")
        XCTAssertNil(InternFormulaUtils.getFunctionByParameterDelimiter((internTokens as! [Any]), index: 2), "End delimiter index is InternTokenListSize")
        XCTAssertNil(InternFormulaUtils.getFunctionByParameterDelimiter((internTokens as! [Any]), index: 1), "No function name before brackets")

        internTokens.removeAllObjects()

        internTokens.add(InternToken(type: TOKEN_TYPE_NUMBER))
        internTokens.add(InternToken(type: TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_OPEN))
        internTokens.add(InternToken(type: TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_OPEN))
        internTokens.add(InternToken(type: TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_CLOSE))

        XCTAssertNil(InternFormulaUtils.getFunctionByParameterDelimiter((internTokens as! [Any]), index: 2), "No function name before brackets")
    }

    func testGetFunctionByFunctionBracketOpenOnErrorInput() {
        let internTokens = NSMutableArray()
        internTokens.add(InternToken(type: TOKEN_TYPE_FUNCTION_PARAMETER_DELIMITER))
        internTokens.add(InternToken(type: TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_OPEN))
        internTokens.add(InternToken(type: TOKEN_TYPE_FUNCTION_PARAMETER_DELIMITER))
        internTokens.add(InternToken(type: TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_CLOSE))

        XCTAssertNil(InternFormulaUtils.getFunctionByFunctionBracketOpen(nil, index: 0), "Function bracket index is 0")
        XCTAssertNil(InternFormulaUtils.getFunctionByFunctionBracketOpen((internTokens as! [Any]), index: 2), "End delimiter index is InternTokenListSize")
        XCTAssertNil(InternFormulaUtils.getFunctionByFunctionBracketOpen((internTokens as! [Any]), index: 1), "No function name before brackets")
    }

    func testGenerateTokenListByBracketOpenOnErrorInput() {
        let internTokens = NSMutableArray()
        internTokens.add(InternToken(type: TOKEN_TYPE_FUNCTION_PARAMETER_DELIMITER))
        internTokens.add(InternToken(type: TOKEN_TYPE_BRACKET_OPEN))
        internTokens.add(InternToken(type: TOKEN_TYPE_BRACKET_CLOSE))

        XCTAssertNil(InternFormulaUtils.generateTokenList(byBracketOpen: (internTokens as! [Any]), index: 3), "Index is >= list.size")
        XCTAssertNil(InternFormulaUtils.generateTokenList(byBracketOpen: (internTokens as! [Any]), index: 0), "Index Token is not bracket open")
    }

    func testGenerateTokenListByBracketOpen() {
        let internTokens = NSMutableArray()
        internTokens.add(InternToken(type: TOKEN_TYPE_BRACKET_OPEN))
        internTokens.add(InternToken(type: TOKEN_TYPE_BRACKET_OPEN))
        internTokens.add(InternToken(type: TOKEN_TYPE_BRACKET_OPEN))
        internTokens.add(InternToken(type: TOKEN_TYPE_BRACKET_OPEN))
        internTokens.add(InternToken(type: TOKEN_TYPE_NUMBER, andValue: "1"))
        internTokens.add(InternToken(type: TOKEN_TYPE_BRACKET_CLOSE))
        internTokens.add(InternToken(type: TOKEN_TYPE_BRACKET_CLOSE))
        internTokens.add(InternToken(type: TOKEN_TYPE_BRACKET_CLOSE))
        internTokens.add(InternToken(type: TOKEN_TYPE_BRACKET_CLOSE))

        let functionTokens = InternFormulaUtils.generateTokenList(byBracketOpen: (internTokens as! [Any]), index: 0)
        XCTAssertEqual(functionTokens!.count, internTokens.count, "GetFunctionByParameter wrong function returned")

        for index in 0..<functionTokens!.count {
            if (functionTokens![index] as! InternToken).getStringValue() != nil || (internTokens[index] as! InternToken).getStringValue() != nil {
                XCTAssertTrue((functionTokens![index] as! InternToken).getType() == (internTokens[index] as! InternToken).getType() &&
                    ((functionTokens![index] as! InternToken).getStringValue() == (internTokens[index] as! InternToken).getStringValue()), "GetFunctionByParameter wrong function returned")
            }
        }
    }

    func testGenerateTokenListByBracketCloseOnErrorInput() {
        let internTokens = NSMutableArray()
        internTokens.add(InternToken(type: TOKEN_TYPE_FUNCTION_PARAMETER_DELIMITER))
        internTokens.add(InternToken(type: TOKEN_TYPE_BRACKET_OPEN))
        internTokens.add(InternToken(type: TOKEN_TYPE_BRACKET_CLOSE))

        XCTAssertNil(InternFormulaUtils.generateTokenList(byBracketClose: (internTokens as! [Any]), index: 3), "Index is >= list.size")
        XCTAssertNil(InternFormulaUtils.generateTokenList(byBracketClose: (internTokens as! [Any]), index: 0), "Index Token is not bracket close")
    }

    func testGenerateTokenListByBracketClose() {
        let internTokens = NSMutableArray()
        internTokens.add(InternToken(type: TOKEN_TYPE_BRACKET_OPEN))
        internTokens.add(InternToken(type: TOKEN_TYPE_BRACKET_OPEN))
        internTokens.add(InternToken(type: TOKEN_TYPE_BRACKET_OPEN))
        internTokens.add(InternToken(type: TOKEN_TYPE_BRACKET_OPEN))
        internTokens.add(InternToken(type: TOKEN_TYPE_NUMBER, andValue: "1"))
        internTokens.add(InternToken(type: TOKEN_TYPE_BRACKET_CLOSE))
        internTokens.add(InternToken(type: TOKEN_TYPE_BRACKET_CLOSE))
        internTokens.add(InternToken(type: TOKEN_TYPE_BRACKET_CLOSE))
        internTokens.add(InternToken(type: TOKEN_TYPE_BRACKET_CLOSE))

        let functionTokens = InternFormulaUtils.generateTokenList(byBracketClose: (internTokens as! [Any]), index: 8)
        XCTAssertEqual(functionTokens!.count, internTokens.count, "GetFunctionByParameter wrong function returned")

        for index in 0..<functionTokens!.count {
            if (functionTokens![index] as! InternToken).getStringValue() != nil || (internTokens[index] as! InternToken).getStringValue() != nil {
                XCTAssertTrue((functionTokens![index] as! InternToken).getType() == (internTokens[index] as! InternToken).getType() &&
                    ((functionTokens![index] as! InternToken).getStringValue() == (internTokens[index] as! InternToken).getStringValue()), "GetFunctionByParameter wrong function returned")
            }
        }
    }

    func testGetFunctionParameterInternTokensAsListsOnErrorInput() {
        let internTokens = NSMutableArray()
        internTokens.add(InternToken(type: TOKEN_TYPE_FUNCTION_PARAMETER_DELIMITER))
        internTokens.add(InternToken(type: TOKEN_TYPE_NUMBER))
        internTokens.add(InternToken(type: TOKEN_TYPE_NUMBER))

        XCTAssertNil(InternFormulaUtils.getFunctionParameterInternTokens(asLists: nil), "InternToken list is null")
        XCTAssertNil(InternFormulaUtils.getFunctionParameterInternTokens(asLists: (internTokens as! [Any])), "InternToken list is too small")

        internTokens.add(InternToken(type: TOKEN_TYPE_NUMBER))

        XCTAssertNil(InternFormulaUtils.getFunctionParameterInternTokens(asLists: (internTokens as! [Any])), "First token is not a FunctionName Token")

        internTokens.removeAllObjects()

        internTokens.add(InternToken(type: TOKEN_TYPE_FUNCTION_NAME))
        internTokens.add(InternToken(type: TOKEN_TYPE_NUMBER))
        internTokens.add(InternToken(type: TOKEN_TYPE_NUMBER))
        internTokens.add(InternToken(type: TOKEN_TYPE_NUMBER))
        internTokens.add(InternToken(type: TOKEN_TYPE_NUMBER))

        XCTAssertNil(InternFormulaUtils.getFunctionParameterInternTokens(asLists: (internTokens as! [Any])), "Second token is not a Bracket Token")

    }

    func testIsFunction() {
        let internTokens = NSMutableArray()
        internTokens.add(InternToken(type: TOKEN_TYPE_FUNCTION_NAME))
        internTokens.add(InternToken(type: TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_OPEN))
        internTokens.add(InternToken(type: TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_CLOSE))
        internTokens.add(InternToken(type: TOKEN_TYPE_NUMBER))

        XCTAssertFalse(InternFormulaUtils.isFunction((internTokens as! [Any])), "List contains more elements than just ONE function")

    }

    func testgetFirstInternTokenTypeOnErrorInput() {
        let internTokens = NSMutableArray()
        //TODO: XCTAssertThrowsSpecific(InternFormulaUtils.getFirstInternTokenType(nil), InternFormulaParserException, "Token list is null")
        //TODO: XCTAssertThrowsSpecific(InternFormulaUtils.getFirstInternTokenType(internTokens), InternFormulaParserException, "Token list is null")
    }

    func testisPeriodTokenOnError() {
        let internTokens = NSMutableArray()
        internTokens.add(InternToken(type: TOKEN_TYPE_FUNCTION_NAME))
        internTokens.add(InternToken(type: TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_OPEN))
        internTokens.add(InternToken(type: TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_CLOSE))
        internTokens.add(InternToken(type: TOKEN_TYPE_NUMBER))

        XCTAssertFalse(InternFormulaUtils.isPeriodToken(nil), "Shoult return false, when parameter is null")
        XCTAssertFalse(InternFormulaUtils.isPeriodToken((internTokens as! [Any])), "List size not equal to 1")
    }

    func testisFunctionTokenOnError() {
        let internTokens = NSMutableArray()
        internTokens.add(InternToken(type: TOKEN_TYPE_NUMBER))

        XCTAssertFalse(InternFormulaUtils.isFunctionToken(nil), "Shoult return false on null")
        XCTAssertFalse(InternFormulaUtils.isFunctionToken((internTokens as! [Any])), "Shoult return false, when List size < 1")

    }

    func testIsNumberOnError() {
        XCTAssertFalse(InternFormulaUtils.isNumberToken(nil), "Should return false if parameter is null")
    }

    func testReplaceFunctionButKeepParametersOnError() {
        let internTokens = NSMutableArray()
        internTokens.add(InternToken(type: TOKEN_TYPE_FUNCTION_NAME))

        XCTAssertNil(InternFormulaUtils.replaceFunctionButKeepParameters(nil, replaceWith: nil), "Should return null if functionToReplace is null")
        //TODO XCTAssertEqual(InternFormulaUtils.replaceFunctionButKeepParameters((internTokens as! [Any]), replaceWith: (internTokens as! [Any])), (internTokens as! [Any]), "Function without params whould return null")
    }

    func testGetFunctionParameterCountOnError() {
        let internTokens = NSMutableArray()
        internTokens.add(InternToken(type: TOKEN_TYPE_NUMBER))

        XCTAssertEqual(0, InternFormulaUtils.getFunctionParameterCount(nil), "Should return 0 if List is null")
        XCTAssertEqual(0, InternFormulaUtils.getFunctionParameterCount((internTokens as! [Any])), "Should return 0 if List size < 4")

        internTokens.removeAllObjects()

        internTokens.add(InternToken(type: TOKEN_TYPE_NUMBER))
        internTokens.add(InternToken(type: TOKEN_TYPE_NUMBER))
        internTokens.add(InternToken(type: TOKEN_TYPE_NUMBER))
        internTokens.add(InternToken(type: TOKEN_TYPE_NUMBER))

        XCTAssertEqual(0, InternFormulaUtils.getFunctionParameterCount((internTokens as! [Any])), "Should return 0 if first Token is not a function name token")

        internTokens.removeAllObjects()

        internTokens.add(InternToken(type: TOKEN_TYPE_FUNCTION_NAME))
        internTokens.add(InternToken(type: TOKEN_TYPE_NUMBER))
        internTokens.add(InternToken(type: TOKEN_TYPE_NUMBER))
        internTokens.add(InternToken(type: TOKEN_TYPE_NUMBER))

        XCTAssertEqual(0, InternFormulaUtils.getFunctionParameterCount((internTokens as! [Any])), "Should return 0 if second Token is not a function bracket open token")

        internTokens.removeAllObjects()

        internTokens.add(InternToken(type: TOKEN_TYPE_FUNCTION_NAME))
        internTokens.add(InternToken(type: TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_OPEN))
        internTokens.add(InternToken(type: TOKEN_TYPE_FUNCTION_PARAMETERS_BRACKET_OPEN))
        internTokens.add(InternToken(type: TOKEN_TYPE_NUMBER))
        internTokens.add(InternToken(type: TOKEN_TYPE_NUMBER))

        XCTAssertEqual(0, InternFormulaUtils.getFunctionParameterCount((internTokens as! [Any])), "Should return 0 if function list does not contain a bracket close token")
    }

    func testDeleteNumberByOffset() {
        let numberToken = InternToken(type: TOKEN_TYPE_NUMBER, andValue: "1.1")

        XCTAssertTrue(InternFormulaUtils.deleteNumber(byOffset: numberToken, numberOffset: 0) == numberToken, "Wrong character deleted")
    }
}
