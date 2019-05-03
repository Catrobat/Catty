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

final class UserVariableTests: XCTestCase {

    override func setUp() {
        super.setUp()
    }

    func testInit() {
        let userVariable = UserVariable()
        userVariable.name = "userVar"
        userVariable.isList = true

        let userVariableCopy = UserVariable(variable: userVariable)!

        XCTAssertEqual(userVariable.name, userVariableCopy.name)
        XCTAssertTrue(userVariable.name == userVariableCopy.name)
        XCTAssertEqual(userVariable.isList, userVariableCopy.isList)
    }

    func testMutableCopyWithContext() {
        let userVariable = UserVariable()
        userVariable.name = "userVar"

        let context = CBMutableCopyContext()
        XCTAssertEqual(0, context.updatedReferences.count)

        let userVariableCopy = userVariable.mutableCopy(with: context) as! UserVariable
        XCTAssertEqual(userVariable.name, userVariableCopy.name)
        XCTAssertTrue(userVariable === userVariableCopy)
    }

    func testMutableCopyAndUpdateReference() {
        let userVariableA = UserVariable()
        userVariableA.name = "userVar"

        let userVariableB = UserVariable()
        userVariableB.name = "userVar"

        let context = CBMutableCopyContext()
        context.updateReference(userVariableA, withReference: userVariableB)
        XCTAssertEqual(1, context.updatedReferences.count)

        let userVariableCopy = userVariableA.mutableCopy(with: context) as! UserVariable
        XCTAssertEqual(userVariableA.name, userVariableCopy.name)
        XCTAssertFalse(userVariableA === userVariableCopy)
        XCTAssertTrue(userVariableB === userVariableCopy)
    }
}
