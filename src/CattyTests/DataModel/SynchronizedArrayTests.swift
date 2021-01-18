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

import Nimble
import XCTest

@testable import Pocket_Code

final class SynchronizedArrayTests: XCTestCase {

    func testIsEmpty() {
        let array = SynchronizedArray<Int>()
        XCTAssertTrue(array.isEmpty)

        array.append(5)
        XCTAssertFalse(array.isEmpty)
    }

    func testCount() {
        let array = SynchronizedArray<AnyObject>()

        let formula1 = Formula(double: 1)!
        let formula2 = Formula(double: 1)!
        let formula3 = Formula(double: 1)!

        array.append(formula1)
        array.append(formula2)
        XCTAssertEqual(2, array.count)

        array.append(formula3)
        XCTAssertEqual(3, array.count)
    }

    func testStartIndex() {
        let array = SynchronizedArray<Int>()

        array.append(5)
        XCTAssertEqual(0, array.startIndex)
        XCTAssertEqual(5, array[array.startIndex])

        array.append(6)
        array.remove(at: array.startIndex)
        XCTAssertEqual(0, array.startIndex)
        XCTAssertEqual(6, array[array.startIndex])
    }

    func testFirst() {
        let array = SynchronizedArray<String>()

        XCTAssertNil(array.first)

        array.append("5")
        array.append("6")
        XCTAssertEqual("5", array.first)

        array.insert("7", at: 0)
        XCTAssertEqual("7", array.first)
    }

    func testLast() {
        let array = SynchronizedArray<Int>()

        XCTAssertNil(array.first)

        array.append(5)
        array.append(6)
        XCTAssertEqual(6, array.last)

        array.append(7)
        XCTAssertEqual(7, array.last)
    }

    func testSubscript() {
        let array = SynchronizedArray<Int>()

        XCTAssertNil(array[0])

        array.append(5)
        array.append(6)
        var lastIndex = array.count - 1
        XCTAssertEqual(6, array[lastIndex])

        array.append(7)
        lastIndex = array.count - 1
        XCTAssertEqual(7, array[lastIndex])
    }

    func testIndex() {
        let array = SynchronizedArray<Int>()

        array.append(5)
        array.append(6)
        XCTAssertEqual(1, array.index(i: 0, offsetBy: 1))

        array.append(7)
        XCTAssertEqual(2, array.index(i: 1, offsetBy: 1))
    }

    func testAppend() {
        let array = SynchronizedArray<Int>()

        array.append(5)
        XCTAssertEqual(1, array.count)
        XCTAssertEqual(5, array[0])

        array.append(7)
        XCTAssertEqual(2, array.count)
        XCTAssertEqual(5, array[0])
        XCTAssertEqual(7, array[1])
    }

    func testInsertElementAt() {
        let array = SynchronizedArray<Int>()

        array.append(5)
        array.insert(6, at: 0)
        XCTAssertEqual(2, array.count)
        XCTAssertEqual(6, array[0])

        array.insert(7, at: 0)
        XCTAssertEqual(3, array.count)
        XCTAssertEqual(7, array[0])
    }

    func testRemoveAt() {
        let array = SynchronizedArray<Int>()

        array.append(5)
        array.append(6)
        array.append(7)
        XCTAssertEqual(3, array.count)

        array.remove(at: 0)
        XCTAssertEqual(2, array.count)
        XCTAssertEqual(6, array[0])

        array.remove(at: 0)
        XCTAssertEqual(1, array.count)
        XCTAssertEqual(7, array[0])
    }

    func testRemoveAll() {
        let array = SynchronizedArray<Int>()

        array.append(5)
        array.append(6)
        array.append(7)
        XCTAssertEqual(3, array.count)

        array.removeAll()
        XCTAssertEqual(0, array.count)
    }

    func testRemoveSubrange() {
        let array = SynchronizedArray<Int>()

        array.append(5)
        array.append(6)
        array.append(7)
        array.append(8)
        array.append(9)
        array.append(10)

        XCTAssertEqual(6, array.count)
        array.removeSubrange(2..<5)
        XCTAssertEqual(3, array.count)

        XCTAssertEqual(5, array[0])
        XCTAssertEqual(6, array[1])
        XCTAssertEqual(10, array[2])
    }

    func testEnumeration() {
        let syncronizedArray = SynchronizedArray<Int>()
        syncronizedArray.append(5)
        syncronizedArray.append(6)
        syncronizedArray.append(7)

        var array = [Int]()
        array.append(5)
        array.append(6)
        array.append(7)

        let syncArrayEnumerated = syncronizedArray.enumerated()
        let arrayEnumerated = array.enumerated()

        for ((index1, value1), (index2, value2)) in zip(syncArrayEnumerated, arrayEnumerated) {
            XCTAssertEqual(index1, index2)
            XCTAssertEqual(value1, value2)
        }
    }

    func testContains() {
        let array = SynchronizedArray<Int>()

        array.append(5)
        array.append(6)
        XCTAssertFalse(array.isEmpty)
        XCTAssertFalse(array.contains(7))

        array.append(7)
        XCTAssertFalse(array.isEmpty)
        XCTAssertTrue(array.contains(7))
    }

    func testContainsWhere() {
        let array = SynchronizedArray<Int>()

        array.append(5)
        array.append(6)
        let doesContain = array.contains { element -> Bool in
            if element == 6 {
                return true
            } else {
                return false
            }
        }
        XCTAssertFalse(array.isEmpty)
        XCTAssertTrue(doesContain)
    }

    func testIsEqual() {
        let array1 = SynchronizedArray<Int>()
        let array2 = SynchronizedArray<Int>()

        array1.append(6)
        XCTAssertFalse(array1.isEqual(array2))

        array2.append(6)
        XCTAssertTrue(array1.isEqual(array2))
    }

    func testIsEqualForArrayWithDifferentOrder() {
        let array1 = SynchronizedArray<AnyObject>()
        let array2 = SynchronizedArray<AnyObject>()

        let formula1 = Formula(double: 1)!
        let formula2 = Formula(double: 2)!

        array1.append(formula1)
        array1.append(formula2)
        XCTAssertFalse(array1.isEqual(array2))

        array2.append(formula2)
        array2.append(formula1)
        XCTAssertFalse(array1.isEqual(array2))
    }

    func testIsEqualWithMultipleDataType() {
        let array1 = SynchronizedArray<Any>()
        let array2 = SynchronizedArray<Any>()

        let formula1 = Formula(double: 1)!

        array1.append(formula1)
        array1.append("2")
        XCTAssertFalse(array1.isEqual(array2))

        array2.append(formula1)
        array2.append("2")
        XCTAssertTrue(array1.isEqual(array2))

    }

    func testRemoveWhenInitializedWithUserList() {
        let array = SynchronizedArray<UserList>()

        XCTAssertEqual(0, array.count)

        let userList1 = UserList(name: "userList1")
        let userList2 = UserList(name: "userList2")

        array.append(userList1)
        array.append(userList2)
        XCTAssertEqual(2, array.count)

        array.remove(name: "testList")
        XCTAssertEqual(2, array.count)

        array.remove(name: "userList1")
        XCTAssertEqual(1, array.count)
        XCTAssertEqual(userList2, array[0])
    }

    func testRemoveWhenInitializedWithUserVariable() {
        let array = SynchronizedArray<UserVariable>()

        XCTAssertEqual(0, array.count)

        let userVariable1 = UserVariable(name: "userVariable1")
        let userVariable2 = UserVariable(name: "userVariable2")

        array.append(userVariable1)
        array.append(userVariable2)
        XCTAssertEqual(2, array.count)

        array.remove(name: "testVariable")
        XCTAssertEqual(2, array.count)

        array.remove(name: "userVariable1")
        XCTAssertEqual(1, array.count)
        XCTAssertEqual(userVariable2, array[0])
    }

    func testRemoveWhenInitializedWithUserDataProtocol() {
        let array = SynchronizedArray<UserDataProtocol>()

        let variable = UserVariable(name: "userVariable")
        let list = UserList(name: "userList")

        array.append(variable)
        array.append(list)
        XCTAssertEqual(2, array.count)

        array.remove(name: "testUserData")
        XCTAssertEqual(2, array.count)

        array.remove(name: "userVariable")
        XCTAssertEqual(1, array.count)
        XCTAssertEqual(list, array[0] as! UserList)
    }

    func testThreadSafeArray() {
        let array = SynchronizedArray<Int>()

        DispatchQueue.concurrentPerform(iterations: 1000) { _ in
            let last = array.last ?? 0
            array.append(last + 1)
        }
        XCTAssertEqual(1000, array.count)
    }

    func testRemoveElement() {
        let array = SynchronizedArray<Int>()

        array.append(5)
        array.append(6)
        array.append(7)
        XCTAssertEqual(3, array.count)

        array.remove(element: 5)
        XCTAssertEqual(2, array.count)
        XCTAssertEqual(6, array[0])

        array.remove(element: 6)
        XCTAssertEqual(1, array.count)
        XCTAssertEqual(7, array[0])
    }
}
