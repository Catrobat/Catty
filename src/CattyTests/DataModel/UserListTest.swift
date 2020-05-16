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

import XCTest

@testable import Pocket_Code

final class UserListTest: XCTestCase {

    override func setUp() {
        super.setUp()
    }

    func testInit() {
        let userList1 = UserList(name: "testList")
        let userList2 = UserList(list: userList1)

        XCTAssertTrue(userList1.isEqual(userList2))
        XCTAssertFalse(userList1 === userList2)
    }

    func testMutableCopyWithContext() {
        let userList = UserList(name: "testList")

        let context = CBMutableCopyContext()
        XCTAssertEqual(0, context.updatedReferences.count)

        let userListCopy = userList.mutableCopy(with: context) as! UserList
        XCTAssertEqual(userList.name, userListCopy.name)
        XCTAssertTrue(userList === userListCopy)
    }

    func testMutableCopyAndUpdateReference() {
        let userListA = UserList(name: "userList")
        let userListB = UserList(name: "userList")

        let context = CBMutableCopyContext()
        context.updateReference(userListA, withReference: userListB)
        XCTAssertEqual(1, context.updatedReferences.count)

        let userListCopy = userListA.mutableCopy(with: context) as! UserList
        XCTAssertEqual(userListA.name, userListCopy.name)
        XCTAssertFalse(userListA === userListCopy)
        XCTAssertTrue(userListB === userListCopy)
    }

    func testIsEqual() {
        let listA = UserList(name: "userList")
        let listB = UserList(name: "userList")

        listA.value = NSMutableArray(array: [50, 51, "item"])
        listB.value = NSMutableArray(array: [50, 52, "itemB"])
        XCTAssertFalse(listB.isEqual(listA))

        listB.value = NSMutableArray(array: [50, 51, "item"])
        XCTAssertTrue(listB.isEqual(listA))

    }

    func testIsEqualToUserListForSameValueDifferentName() {
        let userListA = UserList(name: "userList")
        let userListB = UserList(name: "userListB")
        let userListC = UserList(name: "userList")

        userListA.value = NSMutableArray(array: [50, 51, "item"])
        userListB.value = NSMutableArray(array: [50, 51, "item"])
        userListC.value = NSMutableArray(array: [50, 51, "item"])

        XCTAssertFalse(userListB.isEqual(userListA))
        XCTAssertTrue(userListC.isEqual(userListA))
    }
}
