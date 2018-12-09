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

final class UserListFunctionsTest: XCTestCase {
    var formulaManager: FormulaManager?
    var spriteObject: SpriteObject?

    override func setUp() {
        super.setUp()
        formulaManager = FormulaManager(sceneSize: Util.screenSize(true))
    }

    func testNumberOfItems() {
        let program = Program()

        let object = SpriteObject()
        object.program = program

        let userVar = UserVariable()
        userVar.name = "TestList"
        userVar.isList = true
        userVar.value = NSMutableArray()
        (userVar.value as! NSMutableArray).add(0 as Any)
        (userVar.value as! NSMutableArray).add(0 as Any)
        (userVar.value as! NSMutableArray).add(0 as Any)
        program.variables.programListOfLists.add(userVar)

        let leftChild = FormulaElement(type: "USER_LIST", value: "TestList", leftChild: nil, rightChild: nil, parent: nil)
        let formulaTree = FormulaElement(type: "FUNCTION", value: "NUMBER_OF_ITEMS", leftChild: leftChild, rightChild: nil, parent: nil)

        let formula = Formula(formulaElement: formulaTree)
        let numberOfItems = formulaManager?.interpretDouble(formula!, for: object)

        XCTAssertEqual(numberOfItems, 3, "Wrong number of Items")
    }

    func testElement() {
        let program = Program()

        let object = SpriteObject()
        object.program = program

        let userVar = UserVariable()
        userVar.name = "TestList"
        userVar.isList = true
        userVar.value = NSMutableArray()
        (userVar.value as! NSMutableArray).add(1 as Any)
        (userVar.value as! NSMutableArray).add(4 as Any)
        (userVar.value as! NSMutableArray).add(8 as Any)
        program.variables.programListOfLists.add(userVar)

        var leftChild = FormulaElement(type: "NUMBER", value: "2", leftChild: nil, rightChild: nil, parent: nil)
        let rightChild = FormulaElement(type: "USER_LIST", value: "TestList", leftChild: nil, rightChild: nil, parent: nil)
        var formulaTree = FormulaElement(type: "FUNCTION", value: "LIST_ITEM", leftChild: leftChild, rightChild: rightChild, parent: nil)
        var formula = Formula(formulaElement: formulaTree)

        var element = formulaManager?.interpretDouble(formula!, for: object)
        XCTAssertEqual(element, 4, "Should be Element of List but is not")

        leftChild = FormulaElement(type: "NUMBER", value: "-3", leftChild: nil, rightChild: nil, parent: nil)
        formulaTree = FormulaElement(type: "FUNCTION", value: "LIST_ITEM", leftChild: leftChild, rightChild: rightChild, parent: nil)
        formula = Formula(formulaElement: formulaTree)

        element = formulaManager?.interpretDouble(formula!, for: object)
        XCTAssertEqual(element, 0, "Invalid default value")

        leftChild = FormulaElement(type: "NUMBER", value: "44", leftChild: nil, rightChild: nil, parent: nil)
        formulaTree = FormulaElement(type: "FUNCTION", value: "LIST_ITEM", leftChild: leftChild, rightChild: rightChild, parent: nil)
        formula = Formula(formulaElement: formulaTree)

        element = formulaManager?.interpretDouble(formula!, for: object)
        XCTAssertEqual(element, 0, "Invalid default value")
    }

    func testContains() {
        let program = Program()

        let object = SpriteObject()
        object.program = program

        let userVar = UserVariable()
        userVar.name = "TestList"
        userVar.isList = true
        userVar.value = NSMutableArray()
        (userVar.value as! NSMutableArray).add(0 as Any)
        (userVar.value as! NSMutableArray).add(4 as Any)
        (userVar.value as! NSMutableArray).add(8 as Any)
        program.variables.programListOfLists.add(userVar)

        let rightChild = FormulaElement(type: "NUMBER", value: "4", leftChild: nil, rightChild: nil, parent: nil)
        let leftChild = FormulaElement(type: "USER_LIST", value: "TestList", leftChild: nil, rightChild: nil, parent: nil)
        let formulaTree = FormulaElement(type: "FUNCTION", value: "CONTAINS", leftChild: leftChild, rightChild: rightChild, parent: nil)

        let formula = Formula(formulaElement: formulaTree)
        let interpretedDouble = formulaManager?.interpretDouble(formula!, for: object)

        XCTAssertTrue(interpretedDouble != 0, "Should be Element of List but is not")
    }
}
