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

final class FunctionManagerTest: XCTestCase {
    
    private var manager: FunctionManagerProtocol = FunctionManager.shared
    
    override func setUp() {
    }
    
    func testDefaultValueForUndefinedFunction() {
        let defaultValue = 34.56
        type(of: manager).defaultValueForUndefinedFunction = defaultValue
        
        XCTAssertNil(manager.function(tag: "noFunctionForThisTag"))
        //XCTAssertEqual(defaultValue, manager.value(tag: "noFunctionForThisTag", firstParameter: nil, secondParameter: nil) as! Double)
    }
    
    func testExists() {
        // TODO
    }
    
    func testFunction() {
        // TODO
    }
    
    func testRequiredResource() {
        // TODO
    }
    
    func testIsIdempotent() {
        // TODO
    }
    
    func testName() {
        // TODO
    }
    
    func testValue() {
        // TODO
    }
    
    func testFunctions() {
        // TODO
    }
    
    func testParameters() {
        // TODO test CBFunction.parameters() method for one ZeroParameterFunction, one SingleParameterFunction and one DoubleParameterFunction
    }
    
    func testNameWithParameters() {
        // TODO test CBFunction.nameWithParameters() method for one ZeroParameterFunction, one SingleParameterFunction and one DoubleParameterFunction
    }
}
