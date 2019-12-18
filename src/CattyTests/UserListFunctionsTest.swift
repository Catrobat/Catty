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

final class UserListFunctionsTest: XCTestCase {
    var formulaManager: FormulaManager!
    var spriteObject: SpriteObject!

    override func setUp() {
        let screenSize = Util.screenSize(true)
        formulaManager = FormulaManager(sceneSize: screenSize)
    }

    func testNumberOfItems() {
        let project = Project()
        let object = SpriteObject()
        object.project = project

        let userVariable = UserVariable()
        userVariable.name = "TestList"
        userVariable.isList = true
        userVariable.value = [0, 0, 0]
        project.variables.programListOfLists.add(userVariable)

        let leftChild = FormulaElement(elementType: ElementType.USER_LIST, value: "TestList", leftChild: nil, rightChild: nil, parent: nil)
        let formulaTree = FormulaElement(elementType: ElementType.FUNCTION, value: NumberOfItemsFunction.tag, leftChild: leftChild, rightChild: nil, parent: nil)

        let formula = Formula(formulaElement: formulaTree)
        let numberOfItems: Double = formulaManager.interpretDouble(formula!, for: object)

        XCTAssertEqual(numberOfItems, 3)
    }

    func testElement() {
        let project = Project()
        let object = SpriteObject()
        object.project = project

        let userVariable = UserVariable()
        userVariable.name = "TestList"
        userVariable.isList = true
        userVariable.value = [1, 4, 8]
        project.variables.programListOfLists.add(userVariable)

        var leftChild = FormulaElement(elementType: ElementType.NUMBER, value: "2", leftChild: nil, rightChild: nil, parent: nil)
        let rightChild = FormulaElement(elementType: ElementType.USER_LIST, value: "TestList", leftChild: nil, rightChild: nil, parent: nil)
        var formulaTree = FormulaElement(elementType: ElementType.FUNCTION, value: ElementFunction.tag, leftChild: leftChild, rightChild: rightChild, parent: nil)

        var formula = Formula(formulaElement: formulaTree)
        var element: Double = formulaManager.interpretDouble(formula!, for: object)
        XCTAssertEqual(element, 4)

        leftChild = FormulaElement(elementType: ElementType.NUMBER, value: "-3", leftChild: nil, rightChild: nil, parent: nil)
        formulaTree = FormulaElement(elementType: ElementType.FUNCTION, value: ElementFunction.tag, leftChild: leftChild, rightChild: rightChild, parent: nil)
        formula = Formula(formulaElement: formulaTree)

        element = formulaManager.interpretDouble(formula!, for: object)
        XCTAssertEqual(element, 0)

        leftChild = FormulaElement(elementType: ElementType.NUMBER, value: "44", leftChild: nil, rightChild: nil, parent: nil)
        formulaTree = FormulaElement(elementType: ElementType.FUNCTION, value: ElementFunction.tag, leftChild: leftChild, rightChild: rightChild, parent: nil)
        formula = Formula(formulaElement: formulaTree)

        element = formulaManager.interpretDouble(formula!, for: object)
        XCTAssertEqual(element, 0)
    }

    func testContains() {
        let project = Project()
        let object = SpriteObject()
        object.project = project

        let userVariable = UserVariable()
        userVariable.name = "TestList"
        userVariable.isList = true
        userVariable.value = [0, 4, 8]
        project.variables.programListOfLists.add(userVariable)

        let rightChild = FormulaElement(elementType: ElementType.NUMBER, value: "4", leftChild: nil, rightChild: nil, parent: nil)
        let leftChild = FormulaElement(elementType: ElementType.USER_LIST, value: "TestList", leftChild: nil, rightChild: nil, parent: nil)
        let formulaTree = FormulaElement(elementType: ElementType.FUNCTION, value: ContainsFunction.tag, leftChild: leftChild, rightChild: rightChild, parent: nil)

        let formula = Formula(formulaElement: formulaTree)
        let element = formulaManager.interpretDouble(formula!, for: object)
        let contains = Bool(truncating: element as NSNumber)

        XCTAssertTrue(contains)
    }
}
