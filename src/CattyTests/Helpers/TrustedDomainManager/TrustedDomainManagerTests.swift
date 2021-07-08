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

final class TrustedDomainManagerTests: XCTestCase {

    var fileManager: CBFileManagerMock!

    override func setUp() {
        let trustedDomains = Bundle.main.url(forResource: "TrustedDomains", withExtension: "plist")!.path
        fileManager = CBFileManagerMock(filePath: [trustedDomains], directoryPath: [])
    }

    func testCreateTrustedDomainFile() {
        let deviceTrustedDomainPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(kTrustedDomainFilename + ".plist")
        XCTAssertFalse(fileManager.fileExists(deviceTrustedDomainPath.path))

        let trustedDomain = TrustedDomainManager(fileManager: fileManager)

        XCTAssertNotNil(trustedDomain)
        XCTAssertTrue(fileManager.fileExists(deviceTrustedDomainPath.path))
    }

    func testAddAndIsUrlInTrustedDomainSuccess() {
        let trustedDomain = TrustedDomainManager(fileManager: fileManager)
        let error = trustedDomain?.add(url: "catrob.at")
        XCTAssertNil(error)
        let res = trustedDomain?.isUrlInTrustedDomains(url: "catrob.at")
        XCTAssertTrue(res!)
    }

    func testAddAndIsUrlInTrustedDomainFail() {
        let trustedDomain = TrustedDomainManager(fileManager: fileManager)
        let error = trustedDomain?.add(url: "")
        XCTAssertNil(error)
        let res = trustedDomain?.isUrlInTrustedDomains(url: "catrob.at/test")
        XCTAssertFalse(res!)
    }

    func testFetchTrustedDomainsSuccess() {
        let trustedDomain = TrustedDomainManager(fileManager: fileManager)
        XCTAssertNotNil(trustedDomain)
    }

    func testFetchTrustedDomainsFail() {
        fileManager.readWillFail = true
        let trustedDomain = TrustedDomainManager(fileManager: fileManager)
        XCTAssertNil(trustedDomain)
        fileManager.readWillFail = false
    }

    func testStoreTrustedDomainsSuccess() {
        let trustedDomain = TrustedDomainManager(fileManager: fileManager)
        let error = trustedDomain?.add(url: "")
        XCTAssertNil(error)
    }

    func testStoreTrustedDomainsFail() {
        fileManager.writeWillFail = true
        let trustedDomain = TrustedDomainManager(fileManager: fileManager)
        let error = trustedDomain?.add(url: "")
        XCTAssertNotNil(error)
        fileManager.writeWillFail = false
    }

    func testStandardizeUrl() {
        let testUrl1 = "'https://catrob.at'"
        let testUrl2 = "'https://catrob.at/'"

        let trustedDomain = TrustedDomainManager(fileManager: fileManager)
        XCTAssertNotNil(trustedDomain)

        XCTAssertNil(trustedDomain?.add(url: testUrl1))
        XCTAssertTrue((trustedDomain?.isUrlInTrustedDomains(url: testUrl2))!)
    }

    func testClear() {
        let url = "url"
        let trustedDomain = TrustedDomainManager(fileManager: fileManager)

        var error = trustedDomain?.add(url: url)
        XCTAssertNil(error)

        XCTAssertTrue(trustedDomain!.isUrlInTrustedDomains(url: url))

        error = trustedDomain?.clear()
        XCTAssertNil(error)

        XCTAssertFalse(trustedDomain!.isUrlInTrustedDomains(url: url))
    }
}
