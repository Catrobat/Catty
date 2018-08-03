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

class JoinFunctionTest: XCTestCase {
    
    var function: JoinFunction!
    
    override func setUp() {
        self.function = JoinFunction()
    }
    
    override func tearDown() {
        self.function = nil
    }
    
    func testDefaultValue() {
        XCTAssertEqual(type(of: function).defaultValue, function.value(firstParameter: 1 as AnyObject, secondParameter: 2 as AnyObject))
        XCTAssertEqual(type(of: function).defaultValue, function.value(firstParameter: nil, secondParameter: nil))
    }
    
    func testValue() {
        XCTAssertEqual("right " + "now", function.value(firstParameter:"right " as AnyObject, secondParameter:"now" as AnyObject))
        XCTAssertEqual("" + "", function.value(firstParameter:"" as AnyObject, secondParameter:"" as AnyObject))
        XCTAssertEqual("Vann" + "Tile", function.value(firstParameter:"Vann" as AnyObject, secondParameter:"Tile" as AnyObject))
    }
    
    func testFirstParameter() {
        XCTAssertEqual(.string(defaultValue: "hello "), type(of: function).firstParameter())
    }
    
    func testSecondParameter() {
        XCTAssertEqual(.string(defaultValue: "world"), type(of: function).secondParameter())
    }
    
    func testTag() {
        XCTAssertEqual("JOIN", type(of: function).tag)
    }
    
    func testName() {
        XCTAssertEqual("join", type(of: function).name)
    }
    
    func testRequiredResources() {
        XCTAssertEqual(ResourceType.noResources, type(of: function).requiredResource)
    }
    
    func testIsIdempotent() {
        XCTAssertTrue(type(of: function).isIdempotent)
    }
    
    func testFormulaEditorSection() {
        XCTAssertEqual(.math(position: type(of: function).position), type(of: function).formulaEditorSection())
    }
}

