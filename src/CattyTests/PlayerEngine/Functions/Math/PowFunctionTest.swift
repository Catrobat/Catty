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

class PowFunctionTest: XCTestCase {
    
    var function: PowFunction!
    
    override func setUp() {
        self.function = PowFunction()
    }
    
    override func tearDown() {
        self.function = nil
    }
    
    func testDefaultValue() {
        XCTAssertEqual(type(of: function).defaultValue, function.value(firstParameter: "invalidParameter" as AnyObject, secondParameter: "invalidParameter" as AnyObject), accuracy: 0.0001)
        XCTAssertEqual(type(of: function).defaultValue, function.value(firstParameter: nil, secondParameter: nil), accuracy: 0.0001)
        XCTAssertEqual(type(of: function).defaultValue, function.value(firstParameter: nil, secondParameter: "invalidParameter" as AnyObject), accuracy: 0.0001)
        XCTAssertEqual(type(of: function).defaultValue, function.value(firstParameter: 3 as AnyObject, secondParameter: "invalidParameter" as AnyObject), accuracy: 0.0001)
        XCTAssertEqual(type(of: function).defaultValue, function.value(firstParameter: "invalidParameter" as AnyObject, secondParameter: 10 as AnyObject), accuracy: 0.0001)
    }
    
    func testValue() {
        XCTAssertEqual(pow(10, 7), function.value(firstParameter: 10 as AnyObject, secondParameter: 7 as AnyObject), accuracy: 0.0001)
        
        XCTAssertEqual(pow(-3, 5), function.value(firstParameter: -3 as AnyObject, secondParameter: 5 as AnyObject), accuracy: 0.0001)
        
        XCTAssertEqual(pow(13, -2), function.value(firstParameter: 13 as AnyObject, secondParameter: -2 as AnyObject), accuracy: 0.0001)
    }
    
    func testFirstParameter() {
        XCTAssertEqual(.number(defaultValue: 2), type(of: function).firstParameter())
    }
    
    func testSecondParameter() {
        XCTAssertEqual(.number(defaultValue: 3), type(of: function).secondParameter())
    }
    
    func testTag() {
        XCTAssertEqual("POW", type(of: function).tag)
    }
    
    func testName() {
        XCTAssertEqual("power", type(of: function).name)
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

