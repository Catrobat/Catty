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

final class CBStackTests: XCTestCase {

    /*TODO
    let kNumberOfRoundsToTest = 100
    let kMinNumberOfStackElements = 1000
    let kMaxNumberOfStackElements = 100000

    func testNumberOfElementsAfterPushing() {
        //TODO CBAssert(kMinNumberOfStackElements < kMaxNumberOfStackElements)
        let stack = CBStack<Any>()
        for round in 0..<kNumberOfRoundsToTest {
            let numberOfElementsToPush = (Int(arc4random()) % (kMaxNumberOfStackElements - kMinNumberOfStackElements + 1)) + kMinNumberOfStackElements
            for elementNumber in 0..<numberOfElementsToPush {
                stack.push(elementNumber)
            }
            XCTAssertEqual(stack.count(),
                           numberOfElementsToPush,
                           String(format: "Number of elements on CBStack is %lu but should be %lu", UInt(stack.count()), UInt(numberOfElementsToPush)))
            stack.pop() //TODO allelements
        }
    }

    func testNumberOfElementsAfterPopping() {
        //TODO CBAssert(kMinNumberOfStackElements < kMaxNumberOfStackElements)
        let stack = CBStack<Int>()
        for round in 0..<kNumberOfRoundsToTest {
            for elementNumber in 0..<kMaxNumberOfStackElements {
                stack.push(elementNumber)
            }
            let numberOfElementsToPop = (Int(arc4random()) % (kMaxNumberOfStackElements - kMinNumberOfStackElements + 1)) + kMinNumberOfStackElements
            var lastPoppedNumber: Int?
            for elementNumber in 0..<numberOfElementsToPop {
                lastPoppedNumber = stack.pop()
            }
            XCTAssertEqual(stack.count(),
                           (kMaxNumberOfStackElements - numberOfElementsToPop),
                           String(format: "Number of remaining elements on CBStack is %lu but should be %lu", UInt(stack.count()), UInt(kMaxNumberOfStackElements - numberOfElementsToPop)))
            stack.pop() //TODO allelements
        }
    }*/
}
