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

final class XMLParserHeaderTests093: XMLAbstractTest {
    
     let parserContext = CBXMLParserContext(languageVersion: CGFloat(Float32(0.93)))
    
    func testValidHeader() {
        let xmlRoot = self.getXMLDocumentForPath(xmlPath: self.getPathForXML(xmlFile: "ValidProgram"))
        let firstElement = xmlRoot.rootElement()?.elements(forName: "header")?.first as! GDataXMLElement
        let header = self.parserContext?.parse(from: firstElement, withClass: Header.self) as! Header
   
        XCTAssertNotNil(header, "Header is nil")
        XCTAssertTrue(header.applicationBuildName == "applicationBuildName", "applicationBuildName not correctly parsed")
        XCTAssertTrue(header.applicationBuildNumber == "123", "applicationBuildNumber not correctly parsed")
        XCTAssertTrue(header.applicationVersion == "v0.9.8-260-g4bcf9a2 master", "applicationVersion not correctly parsed")
        XCTAssertTrue(header.catrobatLanguageVersion == "0.93", "catrobatLanguageVersion not correctly parsed")
    
        XCTAssertTrue(Header.headerDateFormatter()?.string(from: header.dateTimeUpload) == "2014-11-0211:00:00", "dateTimeUpload not correctly parsed")
        XCTAssertTrue(header.programDescription == "description", "description not correctly parsed")
        XCTAssertTrue(header.deviceName == "Android SDK built for x86", "deviceName not correctly parsed")
        XCTAssertTrue(header.mediaLicense == "mediaLicense", "mediaLicense not correctly parsed")
        XCTAssertTrue(header.platform == "Android", "platform not correctly parsed")
        XCTAssertTrue(header.programLicense == "programLicense", "programLicense not correctly parsed")
        XCTAssertTrue(header.programName == "Valid Program", "programName not correctly parsed")
        XCTAssertTrue(header.remixOf == "remixOf", "remixOf not correctly parsed")
        XCTAssertEqual(header.screenHeight.intValue, 1184, "screenHeight not correctly parsed")
        XCTAssertEqual(header.screenWidth.intValue, 768, "screenWidth not correctly parsed")
        XCTAssertTrue(header.tags == "tags", "tags not correctly parsed")
        XCTAssertTrue(header.url == "url", "url not correctly parsed")
        XCTAssertTrue(header.userHandle == "userHandle", "userHandle not correctly parsed")
    }
}
