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

class MaxFunctionTest: XCTestCase {
    
    var function: MaxFunction!
    
    override func setUp() {
        function = MaxFunction()
    }
    
    override func tearDown() {
        function = nil
    }
    
    func testDefaultValue() {
        XCTAssertEqual(type(of: function).defaultValue, function.value(firstParameter: "invalidParameter" as AnyObject, secondParameter: "invalidParameter" as AnyObject), accuracy: 0.0001)
        XCTAssertEqual(type(of: function).defaultValue, function.value(firstParameter: nil, secondParameter: nil), accuracy: 0.0001)
        XCTAssertEqual(type(of: function).defaultValue, function.value(firstParameter: "invalidParameter" as AnyObject, secondParameter: nil), accuracy: 0.0001)
        XCTAssertEqual(type(of: function).defaultValue, function.value(firstParameter: 3 as AnyObject, secondParameter: "invalidParameter" as AnyObject), accuracy: 0.0001)
        XCTAssertEqual(type(of: function).defaultValue, function.value(firstParameter: "invalidParameter" as AnyObject, secondParameter: 10 as AnyObject), accuracy: 0.0001)
    }
    
    func testValue() {
        XCTAssertEqual(max(100, 200), function.value(firstParameter: 100 as AnyObject, secondParameter: 200 as AnyObject), accuracy: 0.0001)
        
        XCTAssertEqual(max(-100, -200), function.value(firstParameter: -100 as AnyObject, secondParameter: -200 as AnyObject), accuracy: 0.0001)
    }
    
    func testFirstParameter() {
        XCTAssertEqual(.number(defaultValue: 0), type(of: function).firstParameter())
    }
    
    func testSecondParameter() {
        XCTAssertEqual(.number(defaultValue: 1), type(of: function).secondParameter())
    }
    
    func testTag() {
        XCTAssertEqual("MAX", type(of: function).tag)
    }
    
    func testName() {
        XCTAssertEqual("max", type(of: function).name)
    }
    
    func testRequiredResources() {
        XCTAssertEqual(ResourceType.noResources, type(of: function).requiredResource)
    }
    
    func testIsIdempotent() {
        XCTAssertTrue(type(of: function).isIdempotent)
    }
    
    func testFormulaEditorSection() {
        XCTAssertEqual(.math(position: type(of: function).position), function.formulaEditorSection())
    }
}

