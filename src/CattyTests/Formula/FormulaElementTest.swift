/**
 *  Copyright (C) 2010-2021 The Catrobat Team
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

final class FormulaElementTest: XCTestCase {

    var formulaManager: FormulaManager!

    override func setUp() {
        super.setUp()
        let screenSize = Util.screenSize(true)
        formulaManager = FormulaManager(stageSize: screenSize, landscapeMode: false)
    }

    func testGetInternTokenList() {
        let internTokenList = NSMutableArray(array: [InternToken(type: TOKEN_TYPE_BRACKET_OPEN)!,
                               InternToken(type: TOKEN_TYPE_OPERATOR, andValue: MinusOperator.tag)!,
                               InternToken(type: TOKEN_TYPE_NUMBER, andValue: "1")!,
                               InternToken(type: TOKEN_TYPE_BRACKET_CLOSE)!])
        let internParser = InternFormulaParser(tokens: (internTokenList as! [InternToken]), andFormulaManager: formulaManager)
        let parseTree: FormulaElement = internParser!.parseFormula(for: nil)

        XCTAssertNotNil(parseTree)

        let internTokenListAfterConversion = parseTree.getInternTokenList()

        XCTAssertEqual(internTokenListAfterConversion?.count, internTokenList.count)

        for index in 0..<internTokenListAfterConversion!.count {
            XCTAssertTrue( (internTokenListAfterConversion?.object(at: index) as! InternToken).isEqual(to: (internTokenList.object(at: index) as! InternToken)))
        }
        internTokenList.removeAllObjects()
    }

    func testSingleNumberFormula() {
        let element = FormulaElement(elementType: ElementType.NUMBER,
                                     value: nil,
                                     leftChild: nil,
                                     rightChild: nil,
                                     parent: nil)
        XCTAssertEqual(element?.isSingleNumberFormula(), true)

        element?.type = ElementType.STRING
        XCTAssertEqual(element?.isSingleNumberFormula(), false)

        element?.type = ElementType.FUNCTION
        XCTAssertEqual(element?.isSingleNumberFormula(), false)

        element?.type = ElementType.OPERATOR
        XCTAssertEqual(element?.isSingleNumberFormula(), false)

        element?.type = ElementType.OPERATOR

        element?.value = MultOperator.tag
        XCTAssertEqual(element?.isSingleNumberFormula(), false)

        element?.value = MinusOperator.tag
        XCTAssertEqual(element?.isSingleNumberFormula(), false)
    }

    func testSingleNumberFormulaWithChildren() {

        let element = FormulaElement(elementType: ElementType.OPERATOR,
                                     value: MinusOperator.tag,
                                     leftChild: nil,
                                     rightChild: nil,
                                     parent: nil)

        element?.rightChild = FormulaElement(elementType: ElementType.NUMBER,
                                             value: nil,
                                             leftChild: nil,
                                             rightChild: nil,
                                             parent: nil)

        XCTAssertEqual(element?.isSingleNumberFormula(), true)

        element?.leftChild = FormulaElement(elementType: ElementType.NUMBER,
                                            value: nil,
                                            leftChild: nil,
                                            rightChild: nil,
                                            parent: nil)

        XCTAssertEqual(element?.isSingleNumberFormula(), false)
    }

    func testIsVariableUsedWithNoChild() {
        let userVariable = UserVariable(name: "UserVariable")

        let userVariableFormulaElemnt = FormulaElement()
        XCTAssertFalse(userVariableFormulaElemnt.isVariableUsed(userVariable))

        userVariableFormulaElemnt.value = userVariable.name
        userVariableFormulaElemnt.type = ElementType.USER_VARIABLE
        XCTAssertTrue(userVariableFormulaElemnt.isVariableUsed(userVariable))
    }

    func testIsVariableUsedWithoutRighChildOnly() {
        let userVariable = UserVariable(name: "UserVariable")

        let userVariableFormulaElemnt = FormulaElement()
        XCTAssertFalse(userVariableFormulaElemnt.isVariableUsed(userVariable))

        let rightChild = FormulaElement()
        rightChild.value = userVariable.name
        rightChild.type = ElementType.USER_VARIABLE
        userVariableFormulaElemnt.rightChild = rightChild
        XCTAssertTrue(userVariableFormulaElemnt.isVariableUsed(userVariable))
    }

    func testIsVariableUsedWithoutLeftChildOnly() {
        let userVariable = UserVariable(name: "UserVariable")

        let userVariableFormulaElemnt = FormulaElement()
        XCTAssertFalse(userVariableFormulaElemnt.isVariableUsed(userVariable))

        let leftChild = FormulaElement()
        leftChild.value = userVariable.name
        leftChild.type = ElementType.USER_VARIABLE
        userVariableFormulaElemnt.rightChild = leftChild
        XCTAssertTrue(userVariableFormulaElemnt.isVariableUsed(userVariable))
    }

    func testIsVariableUsedWithBothChild() {
        let userVariable = UserVariable(name: "UserVariable")

        let userVariableFormulaElemnt = FormulaElement()
        XCTAssertFalse(userVariableFormulaElemnt.isVariableUsed(userVariable))

        let rightChild = FormulaElement()
        userVariableFormulaElemnt.rightChild = rightChild
        XCTAssertFalse(userVariableFormulaElemnt.isVariableUsed(userVariable))

        let leftChild = FormulaElement()
        leftChild.value = userVariable.name
        leftChild.type = ElementType.USER_VARIABLE
        userVariableFormulaElemnt.leftChild = leftChild
        XCTAssertTrue(userVariableFormulaElemnt.isVariableUsed(userVariable))
    }

    func testIsListUsedWithNoChild() {
        let userList = UserList(name: "UserList")

        let userListFormulaElemnt = FormulaElement()
        XCTAssertFalse(userListFormulaElemnt.isListUsed(userList))

        userListFormulaElemnt.value = userList.name
        userListFormulaElemnt.type = ElementType.USER_LIST
        XCTAssertTrue(userListFormulaElemnt.isListUsed(userList))
    }

    func testIsListUsedWithRightChildOnly() {
        let userList = UserList(name: "UserList")

        let userListFormulaElemnt = FormulaElement()
        XCTAssertFalse(userListFormulaElemnt.isListUsed(userList))

        let rightChild = FormulaElement()
        rightChild.value = userList.name
        rightChild.type = ElementType.USER_LIST
        userListFormulaElemnt.rightChild = rightChild
        XCTAssertTrue(userListFormulaElemnt.isListUsed(userList))
    }

    func testIsListUsedWithLeftChildOnly() {
        let userList = UserList(name: "UserList")

        let userListFormulaElemnt = FormulaElement()
        XCTAssertFalse(userListFormulaElemnt.isListUsed(userList))

        let leftChild = FormulaElement()
        leftChild.value = userList.name
        leftChild.type = ElementType.USER_LIST
        userListFormulaElemnt.rightChild = leftChild
        XCTAssertTrue(userListFormulaElemnt.isListUsed(userList))
    }

    func testIsListUsedWithBothChild() {
        let userList = UserList(name: "UserList")

        let userListFormulaElemnt = FormulaElement()
        XCTAssertFalse(userListFormulaElemnt.isListUsed(userList))

        let rightChild = FormulaElement()
        userListFormulaElemnt.rightChild = rightChild
        XCTAssertFalse(userListFormulaElemnt.isListUsed(userList))

        let leftChild = FormulaElement()
        leftChild.value = userList.name
        leftChild.type = ElementType.USER_LIST
        userListFormulaElemnt.leftChild = leftChild
        XCTAssertTrue(userListFormulaElemnt.isListUsed(userList))
    }

}
