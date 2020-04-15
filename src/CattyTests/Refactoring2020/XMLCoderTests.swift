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
import XMLCoder

@testable import Pocket_Code

final class XMLCoderTests: XCTestCase {

    var encoder: XMLEncoder!
    var decoder: XMLDecoder!

    override func setUp() {
        super.setUp()
        self.encoder = XMLEncoder()
        encoder.outputFormatting = .prettyPrinted

        self.decoder = XMLDecoder()
    }

    func testEncode() {
        let mock = HeaderMock()
        let cbHeader = mock.getMockCBHeader()

        let xmlData = try? encoder.encode(cbHeader, withRootKey: "header")
        let xmlString = String(decoding: xmlData!, as: UTF8.self)
        XCTAssertFalse(xmlString.isEmpty)
    }

    func testDecode() {
        let xmlStr = """
        <header>
            <applicationBuildName>Catty</applicationBuildName>
            <applicationBuildNumber>0</applicationBuildNumber>
            <applicationName>Mock</applicationName>
            <applicationVersion>0.01</applicationVersion>
            <catrobatLanguageVersion>0.80</catrobatLanguageVersion>
            <dateTimeUpload>2020-01-0203:04:05</dateTimeUpload>
            <description>test description</description>
            <deviceName>iPhone X</deviceName>
            <landscapeMode>false</landscapeMode>
            <mediaLicense>http://developer.catrobat.org/ccbysa_v3</mediaLicense>
            <platform>iOS</platform>
            <platformVersion>13.1</platformVersion>
            <programLicense>http://developer.catrobat.org/agpl_v3</programLicense>
            <programName>Test Project</programName>
            <remixOf>https://pocketcode.org/details/719</remixOf>
            <screenHeight>1000</screenHeight>
            <screenMode></screenMode>
            <screenWidth>400</screenWidth>
            <tags>one, two, three</tags>
            <url>http://pocketcode.org/details/719</url>
            <userHandle>Catrobat</userHandle>
            <programID>123</programID>
        </header>
        """

        let data = xmlStr.data(using: .utf8)!
        let cbHeader = try? decoder.decode(CBHeader.self, from: data)
        XCTAssertNotNil(cbHeader)
    }

    func testDecodeFailRequiredValuesMissing() {
        let xmlStr = """
        <header>
            <applicationBuildName>Catty</applicationBuildName>
        </header>
        """

        let data = xmlStr.data(using: .utf8)!
        let cbHeader = try? decoder.decode(CBHeader.self, from: data)
        XCTAssertNil(cbHeader)
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
