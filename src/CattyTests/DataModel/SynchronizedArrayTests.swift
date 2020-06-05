/**
 *  Copyright (C) 2010-2020 The Catrobat Team
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

    func testThreadSafeArray() {
        let array = SynchronizedArray<Int>()

        DispatchQueue.concurrentPerform(iterations: 1000) { _ in
            let last = array.last ?? 0
            array.append(last + 1)
        }
        XCTAssertEqual(1000, array.count)
    }
}
