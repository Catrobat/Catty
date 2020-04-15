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
//import XMLCoder

@testable import Pocket_Code

final class JSONCoderTests: XCTestCase {

    var encoder: JSONEncoder!
    var decoder: JSONDecoder!

    override func setUp() {
        super.setUp()

        self.encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted

        self.decoder = JSONDecoder()
    }

    func testEncode() {
        let mock = HeaderMock()
        let cbHeader = mock.getMockCBHeader()

        let jsonData = try? encoder.encode(cbHeader)
        let jsonString = String(decoding: jsonData!, as: UTF8.self)
        XCTAssertFalse(jsonString.isEmpty)
    }

    func testDecode() {
        let jsonStr = """
        {
          "mediaLicense" : "http://developer.catrobat.org/ccbysa_v3",
          "programName" : "Test Project",
          "applicationName" : "Mock",
          "applicationBuildNumber" : "0",
          "userHandle" : "Catrobat",
          "url" : "http://pocketcode.org/details/719",
          "tags" : "one, two, three",
          "deviceName" : "iPhone X",
          "remixOf" : "https://pocketcode.org/details/719",
          "catrobatLanguageVersion" : "0.80",
          "screenHeight" : "1000",
          "programLicense" : "http://developer.catrobat.org/agpl_v3",
          "platform" : "iOS",
          "applicationBuildName" : "Catty",
          "applicationVersion" : "0.01",
          "screenWidth" : "400",
          "programID" : "123",
          "landscapeMode" : "false",
          "dateTimeUpload" : "2020-01-0203:04:05",
          "screenMode" : "",
          "platformVersion" : "13.1",
          "description" : "test description"
        }
        """

        let data = jsonStr.data(using: .utf8)!
        let cbHeader = try? decoder.decode(CBHeader.self, from: data)
        XCTAssertNotNil(cbHeader)
    }

    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }

    func compareHeaders(left: CBHeader, right: CBHeader) {
        XCTAssertEqual(left.applicationBuildName, right.applicationBuildName)
        XCTAssertEqual(left.applicationBuildNumber, right.applicationBuildNumber)
        XCTAssertEqual(left.applicationName, right.applicationName)
        XCTAssertEqual(left.applicationVersion, right.applicationVersion)
        XCTAssertEqual(left.dateTimeUpload, right.dateTimeUpload)
        XCTAssertEqual(left.description, right.description)
        XCTAssertEqual(left.deviceName, right.deviceName)
        XCTAssertEqual(left.landscapeMode, right.landscapeMode)
        XCTAssertEqual(left.mediaLicense, right.mediaLicense)
        XCTAssertEqual(left.platform, right.platform)
        XCTAssertEqual(left.platformVersion, right.platformVersion)
        XCTAssertEqual(left.programLicense, right.programLicense)
        XCTAssertEqual(left.programName, right.programName)
        XCTAssertEqual(left.remixOf, right.remixOf)
        XCTAssertEqual(left.screenHeight, right.screenHeight)
        XCTAssertEqual(left.screenWidth, right.screenWidth)
        XCTAssertEqual(left.screenMode, right.screenMode)
        XCTAssertEqual(left.tags, right.tags)
        XCTAssertEqual(left.url, right.url)
        XCTAssertEqual(left.userHandle, right.userHandle)
        XCTAssertEqual(left.programID, right.programID)
    }

    func compareHeaders(left: Header, right: Header) {
        XCTAssertEqual(left.applicationBuildName, right.applicationBuildName)
        XCTAssertEqual(left.applicationBuildNumber, right.applicationBuildNumber)
        XCTAssertEqual(left.applicationName, right.applicationName)
        XCTAssertEqual(left.applicationVersion, right.applicationVersion)
        XCTAssertEqual(left.catrobatLanguageVersion, right.catrobatLanguageVersion)
        XCTAssertEqual(left.dateTimeUpload, right.dateTimeUpload)
        XCTAssertEqual(left.programDescription, right.programDescription)
        XCTAssertEqual(left.deviceName, right.deviceName)
        XCTAssertEqual(left.landscapeMode, right.landscapeMode)
        XCTAssertEqual(left.mediaLicense, right.mediaLicense)
        XCTAssertEqual(left.platform, right.platform)
        XCTAssertEqual(left.platformVersion, right.platformVersion)
        XCTAssertEqual(left.programLicense, right.programLicense)
        XCTAssertEqual(left.programName, right.programName)
        XCTAssertEqual(left.remixOf, right.remixOf)
        XCTAssertEqual(left.screenHeight, right.screenHeight)
        XCTAssertEqual(left.screenWidth, right.screenWidth)
        XCTAssertEqual(left.screenMode, right.screenMode)
        XCTAssertEqual(left.tags, right.tags)
        XCTAssertEqual(left.url, right.url)
        XCTAssertEqual(left.userHandle, right.userHandle)
        XCTAssertEqual(left.programID, right.programID)
    }
}
