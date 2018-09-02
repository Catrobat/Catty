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
    
    override func setUp() {
    }
    
    func testDefaultValueForUndefinedFunction() {
        let manager = FunctionManager([])
        let defaultValue = 34.56
        type(of: manager).defaultValueForUndefinedFunction = defaultValue
        
        XCTAssertNil(manager.function(tag: SinFunction.tag))
        XCTAssertNil(manager.function(tag: "noFunctionForThisTag"))
        XCTAssertEqual(defaultValue, manager.value(tag: "noFunctionForThisTag", firstParameter: nil, secondParameter: nil) as! Double)
    }
    
    func testExists() {
        let functionA = SinFunction()
        let functionB = CosFunction()
        let manager = FunctionManager([functionA, functionB])
        
        XCTAssertTrue(manager.exists(tag: SinFunction.tag))
        XCTAssertFalse(manager.exists(tag: TanFunction.tag))
        XCTAssertFalse(manager.exists(tag: "noFunctionForThisTag"))
        XCTAssertTrue(manager.exists(tag: CosFunction.tag))
    }
    
    func testFunction() {
        let functionA = SinFunction()
        let functionB = CosFunction()
        let manager = FunctionManager([functionA, functionB])
        
        XCTAssertNil(manager.function(tag: TanFunction.tag))
        
        var foundFunction = manager.function(tag: type(of: functionA).tag)
        XCTAssertNotNil(foundFunction)
        XCTAssertEqual(type(of: functionA).name, type(of: foundFunction!).name)
        
        foundFunction = manager.function(tag: type(of: functionB).tag)
        XCTAssertNotNil(foundFunction)
        XCTAssertEqual(type(of: functionB).name, type(of: foundFunction!).name)
    }
    
    func testFunctions() {
        let functionA = SinFunction()
        let functionB = CosFunction()
        
        var manager = FunctionManager([])
        XCTAssertEqual(0, manager.functions().count)
        
        manager = FunctionManager([functionA])
        XCTAssertEqual(1, manager.functions().count)
        
        manager = FunctionManager([functionA, functionB])
        let functions = manager.functions()
        
        XCTAssertEqual(2, functions.count)
        XCTAssertEqual(type(of: functionA).tag, type(of: functions[0]).tag)
        XCTAssertEqual(type(of: functionB).tag, type(of: functions[1]).tag)
    }
    
    func testRequiredResource() {
        let functionA = SinFunction()
        type(of: functionA).requiredResource = .accelerometer
        
        let functionB = CosFunction()
        type(of: functionB).requiredResource = .compass
        
        var manager = FunctionManager([])
        XCTAssertEqual(ResourceType.noResources, type(of: manager).requiredResource(tag: type(of: functionA).tag))
        
        manager = FunctionManager([functionA])
        XCTAssertEqual(type(of: functionA).requiredResource, type(of: manager).requiredResource(tag: type(of: functionA).tag))
        XCTAssertEqual(ResourceType.noResources, type(of: manager).requiredResource(tag: type(of: functionB).tag))
        
        manager = FunctionManager([functionA, functionB])
        XCTAssertEqual(type(of: functionA).requiredResource, type(of: manager).requiredResource(tag: type(of: functionA).tag))
        XCTAssertEqual(type(of: functionB).requiredResource, type(of: manager).requiredResource(tag: type(of: functionB).tag))
        XCTAssertEqual(ResourceType.noResources, type(of: manager).requiredResource(tag: "unavailableTag"))
    }
    
    func testName() {
        let functionA = SinFunction()
        let functionB = CosFunction()
        type(of: functionB).requiredResource = .compass
        
        var manager = FunctionManager([])
        XCTAssertNil(type(of: manager).name(tag: type(of: functionA).tag))
        
        manager = FunctionManager([functionA])
        XCTAssertEqual(type(of: functionA).name, type(of: manager).name(tag: type(of: functionA).tag))
        XCTAssertNil(type(of: manager).name(tag: type(of: functionB).tag))
        
        manager = FunctionManager([functionA, functionB])
        XCTAssertEqual(type(of: functionA).name, type(of: manager).name(tag: type(of: functionA).tag))
        XCTAssertEqual(type(of: functionB).name, type(of: manager).name(tag: type(of: functionB).tag))
        XCTAssertNil(type(of: manager).name(tag: "unavailableTag"))
    }
    
    func testIsIdempotent() {
        let functionA = CosFunction()
        let functionB = RandFunction()
        
        var manager = FunctionManager([])
        XCTAssertFalse(manager.isIdempotent(tag: type(of: functionA).tag))
        
        manager = FunctionManager([functionA])
        XCTAssertTrue(manager.isIdempotent(tag: type(of: functionA).tag))
        
        manager = FunctionManager([functionA, functionB])
        XCTAssertTrue(manager.isIdempotent(tag: type(of: functionA).tag))
        XCTAssertFalse(manager.isIdempotent(tag: type(of: functionB).tag))
        XCTAssertFalse(manager.isIdempotent(tag: "unavailableTag"))
    }
    
    func testValue() {
        let functionA = ZeroParameterDoubleFunctionMock(value: 12.3)
        let functionB = SingleParameterDoubleFunctionMock(value: 45.6, parameter: FunctionParameter.number(defaultValue: 2))
        let functionC = DoubleParameterDoubleFunctionMock(value: 45.6, firstParameter: FunctionParameter.number(defaultValue: 2), secondParameter: FunctionParameter.number(defaultValue: 3))
        
        var manager = FunctionManager([])
        XCTAssertEqual(type(of: manager).defaultValueForUndefinedFunction, manager.value(tag: type(of: functionA).tag, firstParameter: nil, secondParameter: nil) as! Double)
        
        manager = FunctionManager([functionA, functionB, functionC])
        XCTAssertEqual(functionA.value(), manager.value(tag: type(of: functionA).tag, firstParameter: nil, secondParameter: nil) as! Double)
        XCTAssertEqual(functionB.value(parameter: nil), manager.value(tag: type(of: functionB).tag, firstParameter: nil, secondParameter: nil) as! Double)
        XCTAssertEqual(functionC.value(firstParameter: nil, secondParameter: nil), manager.value(tag: type(of: functionC).tag, firstParameter: nil, secondParameter: nil) as! Double)
    }
    
    func testParameters() {
        // TODO test CBFunction.parameters() method for one ZeroParameterFunction, one SingleParameterFunction and one DoubleParameterFunction
    }
    
    func testNameWithParameters() {
        // TODO test CBFunction.nameWithParameters() method for one ZeroParameterFunction, one SingleParameterFunction and one DoubleParameterFunction
    }
}
