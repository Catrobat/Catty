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

class RandFunctionTest: XCTestCase {
    
    var function: RandFunction!
    
    override func setUp() {
        function = RandFunction()
    }
    
    override func tearDown() {
        function = nil
    }
    
    func testDefaultValue() {
        XCTAssertEqual(type(of: function).defaultValue, function.value(firstParameter: "invalidParameter" as AnyObject, secondParameter: "invalidParameter" as AnyObject), accuracy: 0.0001)
        XCTAssertEqual(type(of: function).defaultValue, function.value(firstParameter: nil, secondParameter: nil), accuracy: 0.0001)
        XCTAssertEqual(type(of: function).defaultValue, function.value(firstParameter: "invalidParameter" as AnyObject, secondParameter: nil), accuracy: 0.0001)
    }
    
    func testValue() {
        let firstCall = function.value(firstParameter: 10 as AnyObject, secondParameter: 100 as AnyObject)
        XCTAssertGreaterThan(firstCall, 9.9999)
        XCTAssertLessThan(firstCall, 99.9999)
        
        let secondCall = function.value(firstParameter: 100 as AnyObject, secondParameter: 10 as AnyObject)
        XCTAssertGreaterThan(secondCall, 9.9999)
        XCTAssertLessThan(secondCall, 99.9999)
        
        // there are 1 / [(max - min) + 1] ^ 2 chances of having the same number twice
        XCTAssertNotEqual(firstCall, secondCall)
        
        let float = function.value(firstParameter: 10.5 as AnyObject, secondParameter: 20.8 as AnyObject)
        XCTAssertGreaterThan(float, 10.4999)
        XCTAssertLessThan(float, 20.7999)
    }
    
    func testFirstParameter() {
        XCTAssertEqual(.number(defaultValue: 0), function.firstParameter())
    }
    
    func testSecondParameter() {
        XCTAssertEqual(.number(defaultValue: 1), function.secondParameter())
    }
    
    func testTag() {
        XCTAssertEqual("RAND", type(of: function).tag)
    }
    
    func testName() {
        XCTAssertEqual("random", type(of: function).name)
    }
    
    func testRequiredResources() {
        XCTAssertEqual(ResourceType.noResources, type(of: function).requiredResource)
    }
    
    func testIsIdempotent() {
        XCTAssertFalse(type(of: function).isIdempotent)
    }
    
    func testFormulaEditorSection() {
        XCTAssertEqual(.math(position: type(of: function).position), function.formulaEditorSection())
    }
}
