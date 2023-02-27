/**
 *  Copyright (C) 2010-2023 The Catrobat Team
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

final class KeychainTests: XCTestCase {

    let testKey = "someTestKey"
    let value = "superSecretString"
    let otherValue = "otherSuperSecretString"

    override func setUp() {
        Keychain.deleteValue(forKey: testKey)
    }

    func testInvalidKeychainRetrieval() {
        let loadedValue = Keychain.loadValue(forKey: testKey) as? String
        XCTAssertNil(loadedValue)

        XCTAssertFalse(Keychain.deleteValue(forKey: testKey))
    }

    func testKeychainRetrieval() {
        XCTAssertTrue(Keychain.saveValue(value, forKey: testKey))

        let loadedValue = Keychain.loadValue(forKey: testKey) as? String
        XCTAssertEqual(value, loadedValue)

        XCTAssertTrue(Keychain.deleteValue(forKey: testKey))
    }

    func testKeychainOverwrite() {
        XCTAssertTrue(Keychain.saveValue(value, forKey: testKey))

        let loadedValue = Keychain.loadValue(forKey: testKey) as? String
        XCTAssertEqual(value, loadedValue)

        XCTAssertTrue(Keychain.saveValue(otherValue, forKey: testKey))

        let loadedOtherValue = Keychain.loadValue(forKey: testKey) as? String
        XCTAssertEqual(otherValue, loadedOtherValue)

        XCTAssertTrue(Keychain.deleteValue(forKey: testKey))
    }

}
