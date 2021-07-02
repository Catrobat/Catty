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

class GDataXMLElementExtensionTests: XCTestCase {
    var rootElement: GDataXMLElement!
    var attribute: GDataXMLElement!
    var secondAttribute: GDataXMLElement!

    override func setUp() {
        self.rootElement = self.createGDXMLElementWith(xmlString: "testElement")

        self.attribute = self.createGDXMLElementWith(xmlString: "testAttribute")
        self.attribute.setStringValue("stringValue1")

        self.secondAttribute = self.createGDXMLElementWith(xmlString: "testAttribute2")
        self.secondAttribute.setStringValue("stringValue2")
    }

    func createGDXMLElementWith(xmlString: String) -> GDataXMLElement? {
        do {
            let element = try GDataXMLElement(xmlString: "<\(xmlString)/>")
            return element
        } catch {
            XCTFail("Error in GDataXMLElement")
        }
        return nil
    }

    func testIsEqualForDifferentNumberOfAttributes() {
        let testRootElement = GDataXMLElement()

        rootElement.addAttribute(attribute)
        XCTAssertFalse(testRootElement.isEqual(to: self.rootElement))
        XCTAssertNil(testRootElement.attributes())
        XCTAssertNotNil(self.rootElement.attributes())
        XCTAssertEqual(1, self.rootElement.attributes().count)
    }

    func testIsEqualForDifferentAttributes() {
        let testRootElement = self.createGDXMLElementWith(xmlString: "testElement2")

        self.rootElement.addAttribute(attribute)
        testRootElement!.addAttribute(secondAttribute)

        XCTAssertFalse(testRootElement!.isEqual(to: self.rootElement))
        XCTAssertEqual(testRootElement!.attributes().count, self.rootElement.attributes().count)
    }

    func testIsEqualForObjectUserDataEqualToElementWithObjectListOfList() {
        self.rootElement = self.createGDXMLElementWith(xmlString: "objectListOfList")
        let testRootElement = self.createGDXMLElementWith(xmlString: "objectListOfList")

        let entry1 = self.createGDXMLElementWith(xmlString: "entry")
        let entry2 = self.createGDXMLElementWith(xmlString: "entry")

        let list1 = self.createGDXMLElementWith(xmlString: "list")
        let list2 = self.createGDXMLElementWith(xmlString: "list")

        let object1 = self.createGDXMLElementWith(xmlString: "object1")
        object1!.setStringValue("object1StringValue")

        list1!.addChild(object1)
        entry1!.addChild(list1)
        testRootElement!.addChild(entry1)
        XCTAssertFalse(testRootElement!.isEqual(to: self.rootElement))

        entry2!.addChild(list2)
        self.rootElement.addChild(entry2)
        XCTAssertFalse(testRootElement!.isEqual(to: self.rootElement))

        testRootElement!.addChild(entry2)
        self.rootElement.addChild(entry1)
        XCTAssertTrue(testRootElement!.isEqual(to: self.rootElement))
    }

    func testIsEqualForObjectUserDataEqualToElementWithObjectVariableList() {
        self.rootElement = self.createGDXMLElementWith(xmlString: "objectVariableList")
        let testRootElement = self.createGDXMLElementWith(xmlString: "objectVariableList")

        let entry1 = self.createGDXMLElementWith(xmlString: "entry")
        let entry2 = self.createGDXMLElementWith(xmlString: "entry")

        let list1 = self.createGDXMLElementWith(xmlString: "list")
        let list2 = self.createGDXMLElementWith(xmlString: "list")

        let variable1 = self.createGDXMLElementWith(xmlString: "variable1")
        variable1!.setStringValue("variable1StringValue")

        list1!.addChild(variable1)
        entry1!.addChild(list1)
        testRootElement!.addChild(entry1)
        XCTAssertFalse(testRootElement!.isEqual(to: self.rootElement))

        entry2!.addChild(list2)
        self.rootElement.addChild(entry2)
        XCTAssertFalse(testRootElement!.isEqual(to: self.rootElement))

        testRootElement!.addChild(entry2)
        self.rootElement.addChild(entry1)
        XCTAssertTrue(testRootElement!.isEqual(to: self.rootElement))
    }

    func testIsEqualForDifferentNumberOfChild() {
        let testRootElement = self.createGDXMLElementWith(xmlString: "testElement2")

        rootElement.addChild(self.attribute)
        XCTAssertFalse(testRootElement!.isEqual(to: self.rootElement))
        XCTAssertNil(testRootElement!.children())
        XCTAssertNotNil(self.rootElement.children())
        XCTAssertEqual(1, self.rootElement.children().count)
    }

    func testIsEqualForDifferentChild() {
        let testRootElement = self.createGDXMLElementWith(xmlString: "testElement2")

        self.rootElement.addChild(attribute)
        testRootElement!.addChild(secondAttribute)

        XCTAssertFalse(testRootElement!.isEqual(to: self.rootElement))
        XCTAssertEqual(testRootElement!.children().count, self.rootElement.children().count)
    }

    func testIsEqualForStringValue() {
        let testRootElement = self.createGDXMLElementWith(xmlString: "testElement2")

        XCTAssertTrue(testRootElement!.isEqual(to: self.rootElement))
        XCTAssertEqual(self.rootElement.stringValue(), testRootElement!.stringValue())
        XCTAssertEqual("", self.rootElement.stringValue())
        XCTAssertEqual("", testRootElement!.stringValue())

        self.rootElement.setStringValue("stringValue1")

        XCTAssertFalse(testRootElement!.isEqual(to: self.rootElement))
        XCTAssertNotEqual(self.rootElement.stringValue(), testRootElement!.stringValue())
        XCTAssertEqual("stringValue1", self.rootElement.stringValue())
        XCTAssertEqual("", testRootElement!.stringValue())

        testRootElement!.setStringValue("stringValue2")

        XCTAssertFalse(testRootElement!.isEqual(to: self.rootElement))
        XCTAssertNotEqual(self.rootElement.stringValue(), testRootElement!.stringValue())
        XCTAssertEqual("stringValue1", self.rootElement.stringValue())
        XCTAssertEqual("stringValue2", testRootElement!.stringValue())
    }

    func testChildWithElementName() {
        let root = self.createGDXMLElementWith(xmlString: "root")
        let firstChild = self.createGDXMLElementWith(xmlString: "child")
        let secondChild = self.createGDXMLElementWith(xmlString: "secondChild")
        let thirdChild = self.createGDXMLElementWith(xmlString: "child")

        root?.addChild(firstChild)
        root?.addChild(secondChild)
        root?.addChild(thirdChild)

        let child = root?.child(withElementName: "child")
        XCTAssertEqual(firstChild, child)
    }

    func testChildWithElementNameUnknown() {
        let root = self.createGDXMLElementWith(xmlString: "root")
        let firstChild = self.createGDXMLElementWith(xmlString: "child")

        root?.addChild(firstChild)
        XCTAssertNil(root?.child(withElementName: "unknown"))
    }

    func testChildrenWithElementName() {
        let root = self.createGDXMLElementWith(xmlString: "root")
        let firstChild = self.createGDXMLElementWith(xmlString: "child")
        let secondChild = self.createGDXMLElementWith(xmlString: "secondChild")
        let thirdChild = self.createGDXMLElementWith(xmlString: "child")

        root?.addChild(firstChild)
        root?.addChild(secondChild)
        root?.addChild(thirdChild)

        let children = root?.children(withElementName: "child")
        XCTAssertEqual(2, children?.count)
        XCTAssertEqual(firstChild, children?.first)
        XCTAssertEqual(thirdChild, children?.last)
    }
}
