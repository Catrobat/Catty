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

class XMLAbstractTest: XCTestCase {

    override func setUp( ) {
        super.setUp()
        Util.activateTestMode(true)
    }

    override func tearDown() {
        super.tearDown()
    }

    func isXMLElement(xmlElement: GDataXMLElement, equalToXMLElementForXPath xPath: String, inProgramForXML program: String) -> Bool {
        let document = self.getXMLDocumentForPath(xmlPath: self.getPathForXML(xmlFile: program))
        let xml = document.rootElement()
        var array: [Any]
        do {
            try array = (xml?.nodes(forXPath: xPath))!
        } catch let error as NSError {
            print("Error: \(error.domain)")
            return false
        }
        XCTAssertEqual(array.count, 1)
        let xmlElementFromFile = array.first
        return xmlElement.isEqual(to: xmlElementFromFile as? GDataXMLElement)
    }

    func compareProgram(firstProgramName: String, withProgram secondProgramName: String) {
        let firstProgram = self.getProgramForXML(xmlFile: firstProgramName)
        let secondProgram = self.getProgramForXML(xmlFile: secondProgramName)

        // FIXME: HACK => assign same header to both versions => this forces to ignore header
        firstProgram.header = secondProgram.header
        // FICME: HACK => for background objects always replace german name "Hintergrund" with "Background"
        let firstBgObject = firstProgram.objectList[0] as! SpriteObject
        let secondBgObject = secondProgram.objectList[0] as! SpriteObject
        firstBgObject.name = firstBgObject.name.replacingOccurrences(of: "Hintergrund", with: "Background")
        secondBgObject.name = secondBgObject.name.replacingOccurrences(of: "Hintergrund", with: "Background")

        XCTAssertTrue((firstProgram.isEqual(to: secondProgram)), "Programs are not equal")
    }

    func getProgramForXML(xmlFile: String) -> Program {
        let xmlPath = getPathForXML(xmlFile: xmlFile)
        let languageVersion = Util.detectCBLanguageVersionFromXML(withPath: xmlPath)
        // detect right parser for correct catrobat language version

        guard let catrobatParser = CBXMLParser.init(path: xmlPath) else {
            XCTFail("Could not retrieve parser for xml file \(xmlFile)")
            return Program()
        }

        if !catrobatParser.isSupportedLanguageVersion(languageVersion) {
            let parser = Parser()
            guard let program = parser.generateObjectForProgram(withPath: xmlPath) else {
                XCTFail("Could not parse program from file \(xmlFile)")
                return Program()
            }
            return program
        } else {
            guard let program = catrobatParser.parseAndCreateProgram() else {
                XCTFail("Could not parse program from file \(xmlFile)")
                return Program()
            }
            return program
        }
    }

    func isProgram(firstProgram: Program, equalToXML secondProgram: String) -> Bool {
        guard let firstDocument = CBXMLSerializer.xmlDocument(for: firstProgram) else {
            XCTFail("Could not serialize xml document for program ")
            return false
        }
        let secondDocument = self.getXMLDocumentForPath(xmlPath: self.getPathForXML(xmlFile: secondProgram))
        guard let firstRoot = firstDocument.rootElement(), let secondRoot = secondDocument.rootElement() else {
            return false
        }
        return firstRoot.isEqual(to: secondRoot)
    }

    func getXMLDocumentForPath(xmlPath: String) -> GDataXMLDocument {
        let xmlFile: String
        var document = GDataXMLDocument()
        do {
            try xmlFile = String(contentsOfFile: xmlPath, encoding: String.Encoding.utf8)
            guard let xmlData = xmlFile.data(using: String.Encoding.utf8) else {
                XCTFail("Could not retrieve XML Document for path \(xmlPath)")
                return document
            }
            try document = GDataXMLDocument(data: xmlData, options: 0)
        } catch let error as NSError {
            print("Error: \(error.domain)")
            XCTFail("Could not retrieve XML Document for path \(xmlPath)")
        }
        return document
    }

    func saveProgram(program: Program) {
        guard let fileManager = CBFileManager.shared() else {
            XCTFail("Could not retrieve file manager")
            return
        }
        let xmlPath = String.init(format: "%@%@", program.projectPath(), kProgramCodeFileName)
        let serializer = CBXMLSerializer(path: xmlPath, fileManager: fileManager)
        serializer?.serializeProgram(program)
    }

    func testParseXMLAndSerializeProgramAndCompareXML(xmlFile: String) {
        let program = self.getProgramForXML(xmlFile: xmlFile)
        let equal = self.isProgram(firstProgram: program, equalToXML: xmlFile)
        XCTAssertTrue(equal, "Serialized program and XML are not equal (\(xmlFile))")
    }

    func getPathForXML(xmlFile: String) -> String {
        let bundle = Bundle.init(for: self.classForCoder)
        guard let path = bundle.path(forResource: xmlFile, ofType: "xml") else {
            XCTFail("Could not retrieve path for XML File \(xmlFile)")
            return "path_not_found"
        }
        return path
    }
}
