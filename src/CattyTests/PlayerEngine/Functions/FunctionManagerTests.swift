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

final class FunctionManagerTests: XCTestCase {
    
    var spriteObject: SpriteObject!
    
    override func setUp() {
        spriteObject = SpriteObjectMock()
    }
    
    func testDefaultValueForUndefinedFunction() {
        let manager = FunctionManager(functions: [])
        let defaultValue = 34.56
        type(of: manager).defaultValueForUndefinedFunction = defaultValue
        
        XCTAssertNil(manager.function(tag: SinFunction.tag))
        XCTAssertNil(manager.function(tag: "noFunctionForThisTag"))
        XCTAssertEqual(defaultValue, manager.value(tag: "noFunctionForThisTag", firstParameter: nil, secondParameter: nil, spriteObject: spriteObject) as! Double)
    }
    
    func testExists() {
        let functionA = SinFunction()
        let functionB = CosFunction()
        let manager = FunctionManager(functions: [functionA, functionB])
        
        XCTAssertTrue(manager.exists(tag: SinFunction.tag))
        XCTAssertFalse(manager.exists(tag: TanFunction.tag))
        XCTAssertFalse(manager.exists(tag: "noFunctionForThisTag"))
        XCTAssertTrue(manager.exists(tag: CosFunction.tag))
    }
    
    func testFunction() {
        let functionA = SinFunction()
        let functionB = CosFunction()
        let manager = FunctionManager(functions: [functionA, functionB])
        
        XCTAssertNil(manager.function(tag: TanFunction.tag))
        
        var foundFunction = manager.function(tag: functionA.tag())
        XCTAssertNotNil(foundFunction)
        XCTAssertEqual(type(of: functionA).name, type(of: foundFunction!).name)
        
        foundFunction = manager.function(tag: functionB.tag())
        XCTAssertNotNil(foundFunction)
        XCTAssertEqual(type(of: functionB).name, type(of: foundFunction!).name)
    }
    
    func testFunctions() {
        let functionA = SinFunction()
        let functionB = CosFunction()
        
        var manager = FunctionManager(functions: [])
        XCTAssertEqual(0, manager.functions().count)
        
        manager = FunctionManager(functions: [functionA])
        XCTAssertEqual(1, manager.functions().count)
        
        manager = FunctionManager(functions: [functionA, functionB])
        let functions = manager.functions()
        
        XCTAssertEqual(2, functions.count)
        XCTAssertTrue(functions.contains { $0.tag() == functionA.tag() })
        XCTAssertTrue(functions.contains { $0.tag() == functionB.tag() })
    }
    
    func testRequiredResource() {
        let functionA = ZeroParameterDoubleFunctionMock(tag: "tagA", value: 0)
        type(of: functionA).requiredResource = .accelerometer
        
        let functionB = SingleParameterDoubleFunctionMock(tag: "tagB", value: 0, parameter: .number(defaultValue: 1))
        type(of: functionB).requiredResource = .compass
        
        var manager = FunctionManager(functions: [])
        XCTAssertEqual(ResourceType.noResources, type(of: manager).requiredResource(tag: functionA.tag()))
        
        manager = FunctionManager(functions: [functionA])
        XCTAssertEqual(type(of: functionA).requiredResource, type(of: manager).requiredResource(tag: functionA.tag()))
        XCTAssertEqual(ResourceType.noResources, type(of: manager).requiredResource(tag: functionB.tag()))
        
        manager = FunctionManager(functions: [functionA, functionB])
        XCTAssertEqual(type(of: functionA).requiredResource, type(of: manager).requiredResource(tag: functionA.tag()))
        XCTAssertEqual(type(of: functionB).requiredResource, type(of: manager).requiredResource(tag: functionB.tag()))
        XCTAssertEqual(ResourceType.noResources, type(of: manager).requiredResource(tag: "unavailableTag"))
    }
    
    func testName() {
        let functionA = SinFunction()
        let functionB = CosFunction()
        type(of: functionB).requiredResource = .compass
        
        var manager = FunctionManager(functions: [])
        XCTAssertNil(type(of: manager).name(tag: type(of: functionA).tag))
        
        manager = FunctionManager(functions: [functionA])
        XCTAssertEqual(type(of: functionA).name, type(of: manager).name(tag: type(of: functionA).tag))
        XCTAssertNil(type(of: manager).name(tag: type(of: functionB).tag))
        
        manager = FunctionManager(functions: [functionA, functionB])
        XCTAssertEqual(type(of: functionA).name, type(of: manager).name(tag: type(of: functionA).tag))
        XCTAssertEqual(type(of: functionB).name, type(of: manager).name(tag: type(of: functionB).tag))
        XCTAssertNil(type(of: manager).name(tag: "unavailableTag"))
    }
    
    func testIsIdempotent() {
        let functionA = CosFunction()
        let functionB = RandFunction()
        
        var manager = FunctionManager(functions: [])
        XCTAssertFalse(manager.isIdempotent(tag: type(of: functionA).tag))
        
        manager = FunctionManager(functions: [functionA])
        XCTAssertTrue(manager.isIdempotent(tag: type(of: functionA).tag))
        
        manager = FunctionManager(functions: [functionA, functionB])
        XCTAssertTrue(manager.isIdempotent(tag: type(of: functionA).tag))
        XCTAssertFalse(manager.isIdempotent(tag: type(of: functionB).tag))
        XCTAssertFalse(manager.isIdempotent(tag: "unavailableTag"))
    }
    
    func testValue() {
        let functionA = ZeroParameterDoubleFunctionMock(tag: "tagA", value: 12.3)
        let functionB = SingleParameterDoubleFunctionMock(tag: "tagB", value: 45.6, parameter: FunctionParameter.number(defaultValue: 2))
        let functionC = DoubleParameterDoubleFunctionMock(tag: "tagC", value: 78.9, firstParameter: FunctionParameter.number(defaultValue: 2), secondParameter: FunctionParameter.number(defaultValue: 3))
        let functionD = SingleParameterStringFunctionMock(tag: "tagD", value: "test", parameter: FunctionParameter.number(defaultValue: 2))
        
        var manager = FunctionManager(functions: [])
        XCTAssertEqual(type(of: manager).defaultValueForUndefinedFunction, manager.value(tag: functionA.tag(), firstParameter: nil, secondParameter: nil, spriteObject: spriteObject) as! Double)
        
        manager = FunctionManager(functions: [functionA, functionB, functionC, functionD])
        XCTAssertEqual(functionA.value(), manager.value(tag: functionA.tag(), firstParameter: nil, secondParameter: nil, spriteObject: spriteObject) as! Double)
        XCTAssertEqual(functionB.value(parameter: nil), manager.value(tag: functionB.tag(), firstParameter: nil, secondParameter: nil, spriteObject: spriteObject) as! Double)
        XCTAssertEqual(functionC.value(firstParameter: nil, secondParameter: nil), manager.value(tag: functionC.tag(), firstParameter: nil, secondParameter: nil, spriteObject: spriteObject) as! Double)
        XCTAssertEqual(functionD.value(parameter: nil), manager.value(tag: functionD.tag(), firstParameter: nil, secondParameter: nil, spriteObject: spriteObject) as! String)
    }
    
    func testFormulaEditorItems() {
        let functionA = ZeroParameterDoubleFunctionMock(tag: "tagA", value: 12.3, formulaEditorSection: .hidden)
        let functionB = SingleParameterDoubleFunctionMock(tag: "tagB", value: 45.6, parameter: FunctionParameter.list(defaultValue: "list"), formulaEditorSection: .device(position: 1))
        let functionC = DoubleParameterDoubleFunctionMock(tag: "tagC", value: 12.3, firstParameter: FunctionParameter.list(defaultValue: "list"), secondParameter: FunctionParameter.number(defaultValue: 1), formulaEditorSection: .object(position: 2))
        
        let manager = FunctionManager(functions: [functionA, functionB, functionC])
        let items = manager.formulaEditorItems()
        XCTAssertEqual(3, items.count)
        XCTAssertTrue(items.contains { $0.function?.tag() == functionA.tag() })
        XCTAssertTrue(items.contains { $0.function?.tag() == functionB.tag() })
        XCTAssertTrue(items.contains { $0.function?.tag() == functionB.tag() })
    }
}
