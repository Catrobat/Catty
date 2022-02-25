/**
 *  Copyright (C) 2010-2022 The Catrobat Team
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

final class FormulaCacheTests: XCTestCase {

    var cache: FormulaCache!

    override func setUp() {
        cache = FormulaCache()
    }

    func testInsert() {
        XCTAssertEqual(0, cache.count())

        let key = FormulaElement(integer: 0)
        let value = String("value") as AnyObject

        cache.insert(object: value, forKey: key!)
        XCTAssertEqual(1, cache.count())
    }

    func testInsertTwiceForSameKey() {
        XCTAssertEqual(0, cache.count())

        let key = FormulaElement(integer: 0)
        let value = String("value") as AnyObject

        cache.insert(object: value, forKey: key!)
        XCTAssertEqual(1, cache.count())

        cache.insert(object: value, forKey: key!)
        XCTAssertEqual(1, cache.count())
    }

    func testInsertForTwoKeys() {
        XCTAssertEqual(0, cache.count())

        let keyA = FormulaElement(string: "A")
        let keyB = FormulaElement(string: "B")
        let value = String("value") as AnyObject

        cache.insert(object: value, forKey: keyA!)
        cache.insert(object: value, forKey: keyB!)

        XCTAssertEqual(2, cache.count())
    }

    func testRemove() {
        XCTAssertEqual(0, cache.count())

        let keyA = FormulaElement(string: "A")!
        let keyB = FormulaElement(string: "B")!
        let valueA = String("valueA") as AnyObject
        let valueB = String("valueB") as AnyObject

        cache.insert(object: valueA, forKey: keyA)
        cache.insert(object: valueB, forKey: keyB)

        XCTAssertEqual(2, cache.count())

        cache.remove(forKey: keyA)

        XCTAssertEqual(1, cache.count())

        let cachedObject = cache.retrieve(forKey: keyB)
        XCTAssertTrue(valueB === cachedObject!)
    }

    func testRetrieveObject() {
        XCTAssertEqual(0, cache.count())

        let keyA = FormulaElement(string: "A")!
        let keyB = FormulaElement(string: "B")!
        let valueA = String("valueA") as AnyObject
        let valueB = String("valueB") as AnyObject

        XCTAssertNil(cache.retrieve(forKey: keyA))

        cache.insert(object: valueA, forKey: keyA)
        cache.insert(object: valueB, forKey: keyB)

        XCTAssertEqual(2, cache.count())

        let cachedObjectA = cache.retrieve(forKey: keyA)
        XCTAssertTrue(valueA === cachedObjectA!)

        let cachedObjectB = cache.retrieve(forKey: keyB)
        XCTAssertTrue(valueB === cachedObjectB!)
    }

    func testClear() {
        let key = FormulaElement(integer: 0)
        let value = String("value") as AnyObject

        cache.insert(object: value, forKey: key!)
        XCTAssertEqual(1, cache.count())

        cache.clear()

        XCTAssertEqual(0, cache.count())
        XCTAssertNil(cache.retrieve(forKey: key!))
    }
}
