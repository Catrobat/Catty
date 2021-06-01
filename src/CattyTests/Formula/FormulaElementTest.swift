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

        let formulaElement = FormulaElement(elementType: .STRING, value: userVariable.name)!
        XCTAssertFalse(formulaElement.isVariableUsed(userVariable))

        formulaElement.type = ElementType.USER_VARIABLE
        XCTAssertTrue(formulaElement.isVariableUsed(userVariable))
    }

    func testIsVariableUsedWithoutRighChildOnly() {
        let userVariable = UserVariable(name: "UserVariable")

        let parentElement = FormulaElement(elementType: .STRING, value: userVariable.name)!
        XCTAssertFalse(parentElement.isVariableUsed(userVariable))

        let rightChild = FormulaElement(elementType: .USER_VARIABLE, value: userVariable.name)
        parentElement.rightChild = rightChild
        XCTAssertTrue(parentElement.isVariableUsed(userVariable))
    }

    func testIsVariableUsedWithoutLeftChildOnly() {
        let userVariable = UserVariable(name: "UserVariable")

        let parentElement = FormulaElement(elementType: .STRING, value: userVariable.name)!
        XCTAssertFalse(parentElement.isVariableUsed(userVariable))

        parentElement.rightChild = FormulaElement(elementType: .USER_VARIABLE, value: userVariable.name)
        XCTAssertTrue(parentElement.isVariableUsed(userVariable))
    }

    func testIsVariableUsedWithBothChild() {
        let userVariable = UserVariable(name: "UserVariable")

        let parentElement = FormulaElement(integer: 0)!
        XCTAssertFalse(parentElement.isVariableUsed(userVariable))

        parentElement.rightChild = FormulaElement(integer: 0)
        XCTAssertFalse(parentElement.isVariableUsed(userVariable))

        parentElement.leftChild = FormulaElement(elementType: .USER_VARIABLE, value: userVariable.name)
        XCTAssertTrue(parentElement.isVariableUsed(userVariable))
    }

    func testIsListUsedWithNoChild() {
        let userList = UserList(name: "UserList")

        let formulaElement = FormulaElement(integer: 0)!
        XCTAssertFalse(formulaElement.isListUsed(userList))

        formulaElement.value = userList.name
        formulaElement.type = ElementType.USER_LIST
        XCTAssertTrue(formulaElement.isListUsed(userList))
    }

    func testIsListUsedWithRightChildOnly() {
        let userList = UserList(name: "UserList")

        let parentElement = FormulaElement(integer: 0)!
        XCTAssertFalse(parentElement.isListUsed(userList))

        parentElement.rightChild = FormulaElement(elementType: .USER_LIST, value: userList.name)
        XCTAssertTrue(parentElement.isListUsed(userList))
    }

    func testIsListUsedWithLeftChildOnly() {
        let userList = UserList(name: "UserList")

        let parentElement = FormulaElement(integer: 0)!
        XCTAssertFalse(parentElement.isListUsed(userList))

        parentElement.rightChild = FormulaElement(elementType: .USER_LIST, value: userList.name)
        XCTAssertTrue(parentElement.isListUsed(userList))
    }

    func testIsListUsedWithBothChild() {
        let userList = UserList(name: "UserList")

        let parentElement = FormulaElement(integer: 0)!
        XCTAssertFalse(parentElement.isListUsed(userList))

        parentElement.rightChild = FormulaElement(integer: 0)
        XCTAssertFalse(parentElement.isListUsed(userList))

        parentElement.leftChild = FormulaElement(elementType: .USER_LIST, value: userList.name)
        XCTAssertTrue(parentElement.isListUsed(userList))
    }

    func testIsEqualToFormulaElementAndGetRequiredResources() {
        let element = FormulaElement(elementType: ElementType.STRING,
                                     value: nil,
                                     leftChild: nil,
                                     rightChild: nil,
                                     additionalChildren: nil,
                                     parent: nil)

        let element2 = FormulaElement(elementType: ElementType.OPERATOR,
                                      value: nil,
                                      leftChild: nil,
                                      rightChild: nil,
                                      additionalChildren: nil,
                                      parent: nil)

        XCTAssertFalse((element?.isEqual(to: element2))!)

        element2?.type = ElementType.STRING
        XCTAssertTrue((element?.isEqual(to: element2))!)

        element?.value = "Test"
        XCTAssertFalse((element?.isEqual(to: element2))!)

        element2?.value = "Test"
        XCTAssertTrue((element?.isEqual(to: element2))!)

        let child = FormulaElement(elementType: ElementType.SENSOR, value: InclinationYSensor.tag, leftChild: nil, rightChild: nil, parent: nil)
        let child2 = FormulaElement(integer: 1)

        element?.leftChild = child
        element2?.leftChild = child2
        XCTAssertFalse((element?.isEqual(to: element2))!)

        element2?.leftChild = child
        XCTAssertTrue((element?.isEqual(to: element2))!)

        var resources = element?.leftChild.getRequiredResources()
        XCTAssertEqual(resources, ResourceType.accelerometerAndDeviceMotion.rawValue, "Resourses leftChild not correctly calculated")

        element?.rightChild = child
        element2?.rightChild = child2
        XCTAssertFalse((element?.isEqual(to: element2))!)

        element2?.rightChild = child
        XCTAssertTrue((element?.isEqual(to: element2))!)

        resources = element?.rightChild.getRequiredResources()
        XCTAssertEqual(resources, ResourceType.accelerometerAndDeviceMotion.rawValue, "Resourses rightChild not correctly calculated")

        element?.additionalChildren = [child as Any]
        element2?.additionalChildren = [child2 as Any]
        XCTAssertFalse((element?.isEqual(to: element2))!)

        element2?.additionalChildren = [child as Any]
        XCTAssertTrue((element?.isEqual(to: element2))!)

        resources = element?.getRequiredResources()
        XCTAssertEqual(resources, ResourceType.accelerometerAndDeviceMotion.rawValue, "Resourses additionalChildren not correctly calculated")
    }

    func testInitWithAdditionalChildren() {
        let elementWithoutAdditionalChildren = FormulaElement(elementType: ElementType.STRING,
                                                              value: nil,
                                                              leftChild: nil,
                                                              rightChild: nil,
                                                              additionalChildren: nil,
                                                              parent: nil)

        XCTAssertEqual(0, elementWithoutAdditionalChildren?.additionalChildren.count)

        let childA = FormulaElement(integer: 0)!
        let childB = FormulaElement(integer: 0)!

        let elementWithAdditionalChildren = FormulaElement(elementType: ElementType.STRING,
                                                           value: nil,
                                                           leftChild: nil,
                                                           rightChild: nil,
                                                           additionalChildren: [childA, childB],
                                                           parent: nil)

        XCTAssertEqual(2, elementWithAdditionalChildren?.additionalChildren.count)
        XCTAssertEqual(elementWithAdditionalChildren, childA.parent)
        XCTAssertEqual(elementWithAdditionalChildren, childB.parent)
    }
}
