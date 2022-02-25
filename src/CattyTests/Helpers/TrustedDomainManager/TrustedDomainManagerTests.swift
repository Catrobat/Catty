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

final class TrustedDomainManagerTests: XCTestCase {

    var fileManager: CBFileManagerMock!

    override func setUp() {
        let trustedDomains = Bundle.main.url(forResource: "TrustedDomains", withExtension: "plist")!.path
        fileManager = CBFileManagerMock(filePath: [trustedDomains], directoryPath: [])
    }

    override func tearDown() {
        let trustedDomains = TrustedDomainManager(fileManager: fileManager)
        _ = trustedDomains?.clear()
        _ = trustedDomains?.storeUserTrustedDomains()
    }

    func testAddAndIsUrlInUserTrustedDomainSuccess() {
        let trustedDomain = TrustedDomainManager(fileManager: fileManager)
        let error = trustedDomain?.add(url: "catrob.at")
        XCTAssertNil(error)
        let res = trustedDomain?.isUrlInTrustedDomains(url: "catrob.at")
        XCTAssertTrue(res!)
    }

    func testAddAndIsUrlInUserTrustedDomainFail() {
        let trustedDomain = TrustedDomainManager(fileManager: fileManager)
        let error = trustedDomain?.add(url: "")
        XCTAssertNil(error)
        let res = trustedDomain?.isUrlInTrustedDomains(url: "catrob.at/test")
        XCTAssertFalse(res!)
    }

    func testAddAndIsUrlInTrustedDomainSuccess() {
        let trustedDomain = TrustedDomainManager(fileManager: fileManager)
        let res = trustedDomain?.isUrlInTrustedDomains(url: "catrob.at")
        XCTAssertFalse(res!)
        let res2 = trustedDomain?.isUrlInTrustedDomains(url: "https://catrob.at")
        XCTAssertTrue(res2!)
    }

    func testAddAndIsUrlInTrustedDomainFail() {
        let trustedDomain = TrustedDomainManager(fileManager: fileManager)
        let res = trustedDomain?.isUrlInTrustedDomains(url: "https://atrob.at/test")
        XCTAssertFalse(res!)
    }

    func testRemoveAndIsUrlInTrustedDomainSuccess() {
        let trustedDomain = TrustedDomainManager(fileManager: fileManager)
        let error = trustedDomain?.add(url: "https://remove.at")
        XCTAssertNil(error)
        let error2 = trustedDomain?.remove(url: "https://remove.at")
        XCTAssertNil(error2)
        let res = trustedDomain?.isUrlInTrustedDomains(url: "https://remove.at")
        XCTAssertFalse(res!)
    }

    func testRemoveTrustedDomainFail() {
        let trustedDomain = TrustedDomainManager(fileManager: fileManager)
        let trustedDomainsBefore = trustedDomain?.userTrustedDomains
        let error = trustedDomain?.remove(url: "https://remove2.at")
        XCTAssertNil(error)
        XCTAssertEqual(trustedDomainsBefore, trustedDomain?.userTrustedDomains)
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

    func testFetchUserTrustedDomainsSuccess() {
        var userTrustedDomain = TrustedDomainManager(fileManager: fileManager)
        let error = userTrustedDomain?.add(url: "test.com")
        XCTAssertNil(error)
        userTrustedDomain = TrustedDomainManager(fileManager: fileManager)
        XCTAssertNotNil(userTrustedDomain?.userTrustedDomains)
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

    func testNoProtocol() {
        let trustedDomain = TrustedDomainManager(fileManager: fileManager)
        XCTAssertTrue((trustedDomain?.isUrlInTrustedDomains(url: "https://www.tugraz.at"))!)
        XCTAssertFalse((trustedDomain?.isUrlInTrustedDomains(url: "www.tugraz.at"))!)
    }

    func testEnding() {
        let trustedDomain = TrustedDomainManager(fileManager: fileManager)
        XCTAssertTrue((trustedDomain?.isUrlInTrustedDomains(url: "https://www.wikipedia.org/blabla"))!)
        XCTAssertFalse((trustedDomain?.isUrlInTrustedDomains(url: "https://something.org.com/blabla"))!)
    }

    func testCommonInternetScheme() {
        let trustedDomain = TrustedDomainManager(fileManager: fileManager)
        XCTAssertTrue((trustedDomain?.isUrlInTrustedDomains(url: "http://myaccount:@www.ist.tugraz.at/blablabla"))!)
        XCTAssertTrue((trustedDomain?.isUrlInTrustedDomains(url: "http://myaccount:mypassword@www.ist.tugraz.at/blablabla"))!)
        XCTAssertTrue((trustedDomain?.isUrlInTrustedDomains(url: "http://www.ist.tugraz.at:8080/blablabla"))!)
        XCTAssertTrue((trustedDomain?.isUrlInTrustedDomains(url: "http://www.ist.tugraz.at:8080/"))!)
        XCTAssertTrue((trustedDomain?.isUrlInTrustedDomains(url: "http://myaccount:mypassword@www.ist.tugraz.at:8080/blablabla"))!)
        XCTAssertFalse((trustedDomain?.isUrlInTrustedDomains(url: "http://www.tugraz.at:/"))!)
    }

    func testDomainEndsWithEntry() {
        let trustedDomain = TrustedDomainManager(fileManager: fileManager)
        XCTAssertTrue((trustedDomain?.isUrlInTrustedDomains(url: "https://www.wikipedia.org/hallo"))!)
        XCTAssertFalse((trustedDomain?.isUrlInTrustedDomains(url: "https://wikipedia.org.dark.net/trallala"))!)
        XCTAssertFalse((trustedDomain?.isUrlInTrustedDomains(url: "https://wikipedia.orgxxx/trallala"))!)
        XCTAssertFalse((trustedDomain?.isUrlInTrustedDomains(url: "https://www.dark.net/wikipedia.org/"))!)
    }

    func testDomainExtension() {
        let trustedDomain = TrustedDomainManager(fileManager: fileManager)
        XCTAssertFalse((trustedDomain?.isUrlInTrustedDomains(url: "https://wwwwikipedia.org/hallo"))!)
    }

    func testEscapedDots() {
        let trustedDomain = TrustedDomainManager(fileManager: fileManager)
        XCTAssertTrue((trustedDomain?.isUrlInTrustedDomains(url: "https://www.tugraz.ac.at/hallo"))!)
        XCTAssertFalse((trustedDomain?.isUrlInTrustedDomains(url: "https://www.tugraz.acbat/hallo"))!)
    }
}
