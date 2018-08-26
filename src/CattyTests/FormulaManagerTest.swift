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

final class FormulaManagerTest: XCTestCase {
    
    var spriteObject: SpriteObject!
    
    override func setUp() {
        self.spriteObject = SpriteObjectMock()
    }
    
    func testFormulaEditorItemsEmpty() {
        let manager = FormulaManager(sensorManager: SensorManagerMock(sensors: [], unavailableResources: 0),
                                     functionManager: FunctionManagerMock(functions: []))
        
        XCTAssertEqual(0, manager.formulaEditorItems(spriteObject: spriteObject).count)
        XCTAssertEqual(0, manager.formulaEditorItemsForMathSection(spriteObject: spriteObject).count)
        XCTAssertEqual(0, manager.formulaEditorItemsForDeviceSection(spriteObject: spriteObject).count)
        XCTAssertEqual(0, manager.formulaEditorItemsForObjectSection(spriteObject: spriteObject).count)
    }
    
    func testFormulaEditorItems() {
        let functionA = FunctionMock(formulaEditorSection: .object(position: 1))
        let functionB = FunctionMock(formulaEditorSection: .device(position: 2))
        let functionC = FunctionMock(formulaEditorSection: .hidden)
        
        let sensorA = SensorMock(formulaEditorSection: .object(position: 3))
        let sensorB = SensorMock(formulaEditorSection: .hidden)
        
        let manager = FormulaManager(sensorManager: SensorManagerMock(sensors: [sensorA, sensorB], unavailableResources: 0),
                                     functionManager: FunctionManagerMock(functions: [functionA, functionB, functionC]))
        
        let items = manager.formulaEditorItems(spriteObject: spriteObject)
        XCTAssertEqual(3, items.count)
        XCTAssertEqual(functionA.formulaEditorSection(), items[0].function?.formulaEditorSection())
        XCTAssertEqual(functionB.formulaEditorSection(), items[1].function?.formulaEditorSection())
        XCTAssertEqual(sensorA.formulaEditorSection(for: spriteObject), items[2].sensor?.formulaEditorSection(for: spriteObject))
    }
    
    func testFormulaEditorItemsSamePosition() {
        let functionA = FunctionMock(formulaEditorSection: .object(position: 1))
        let functionB = FunctionMock(formulaEditorSection: .object(position: 1))
        
        let sensorA = SensorMock(formulaEditorSection: .object(position: 1))
        
        let manager = FormulaManager(sensorManager: SensorManagerMock(sensors: [sensorA], unavailableResources: 0),
                                     functionManager: FunctionManagerMock(functions: [functionA, functionB]))
        
        XCTAssertEqual(3, manager.formulaEditorItems(spriteObject: spriteObject).count)
    }
    
    func testFormulaEditorItemsForMathSection() {
        let functionA = FunctionMock(formulaEditorSection: .math(position: 10))
        let functionB = FunctionMock(formulaEditorSection: .object(position: 1))
        
        let sensorA = SensorMock(formulaEditorSection: .math(position: 20))
        let sensorB = SensorMock(formulaEditorSection: .hidden)
        
        let manager = FormulaManager(sensorManager: SensorManagerMock(sensors: [sensorA, sensorB], unavailableResources: 0),
                                     functionManager: FunctionManagerMock(functions: [functionA, functionB]))
        
        let items = manager.formulaEditorItemsForMathSection(spriteObject: spriteObject)
        XCTAssertEqual(2, items.count)
        XCTAssertEqual(functionA.formulaEditorSection(), items[0].function?.formulaEditorSection())
        XCTAssertEqual(sensorA.formulaEditorSection(for: spriteObject), items[1].sensor?.formulaEditorSection(for: spriteObject))
    }
    
    func testFormulaEditorItemsForDeviceSection() {
        let functionA = FunctionMock(formulaEditorSection: .math(position: 10))
        let functionB = FunctionMock(formulaEditorSection: .device(position: 20))
        
        let sensorA = SensorMock(formulaEditorSection: .device(position: 1))
        let sensorB = SensorMock(formulaEditorSection: .hidden)
        
        let manager = FormulaManager(sensorManager: SensorManagerMock(sensors: [sensorA, sensorB], unavailableResources: 0),
                                     functionManager: FunctionManagerMock(functions: [functionA, functionB]))
        
        let items = manager.formulaEditorItemsForDeviceSection(spriteObject: spriteObject)
        XCTAssertEqual(2, items.count)
        XCTAssertEqual(sensorA.formulaEditorSection(for: spriteObject), items[0].sensor?.formulaEditorSection(for: spriteObject))
        XCTAssertEqual(functionB.formulaEditorSection(), items[1].function?.formulaEditorSection())
    }
    
    func testFormulaEditorItemsForObjectSection() {
        let functionA = FunctionMock(formulaEditorSection: .math(position: 10))
        let functionB = FunctionMock(formulaEditorSection: .device(position: 20))
        
        let sensorA = SensorMock(formulaEditorSection: .object(position: 30))
        let sensorB = SensorMock(formulaEditorSection: .hidden)
        
        let manager = FormulaManager(sensorManager: SensorManagerMock(sensors: [sensorA, sensorB], unavailableResources: 0),
                                     functionManager: FunctionManagerMock(functions: [functionA, functionB]))
        
        let items = manager.formulaEditorItemsForObjectSection(spriteObject: spriteObject)
        XCTAssertEqual(1, items.count)
        XCTAssertEqual(sensorA.formulaEditorSection(for: spriteObject), items[0].sensor?.formulaEditorSection(for: spriteObject))
    }
    
    func testSetupForFormula() {
        let sensorManager = SensorManagerMock(sensors: [], unavailableResources: 0)
        let functionManager = FunctionManagerMock(functions: [])
        let manager = FormulaManager(sensorManager: sensorManager, functionManager: functionManager)
        
        XCTAssertFalse(sensorManager.isStarted)
        XCTAssertFalse(functionManager.isStarted)
        
        manager.setup(for: Formula())
        
        XCTAssertTrue(sensorManager.isStarted)
        XCTAssertTrue(functionManager.isStarted)
    }
    
    func testSetupForProgram() {
        let sensorManager = SensorManagerMock(sensors: [], unavailableResources: 0)
        let functionManager = FunctionManagerMock(functions: [])
        let manager = FormulaManager(sensorManager: sensorManager, functionManager: functionManager)
        
        XCTAssertFalse(sensorManager.isStarted)
        XCTAssertFalse(functionManager.isStarted)
        
        manager.setup(for: Program(), and: CBScene())
        
        XCTAssertTrue(sensorManager.isStarted)
        XCTAssertTrue(functionManager.isStarted)
    }
    
    func testStop() {
        let sensorManager = SensorManagerMock(sensors: [], unavailableResources: 0)
        let functionManager = FunctionManagerMock(functions: [])
        let manager = FormulaManager(sensorManager: sensorManager, functionManager: functionManager)
        
        manager.setup(for: Formula())
        
        XCTAssertTrue(sensorManager.isStarted)
        XCTAssertTrue(functionManager.isStarted)
        
        manager.stop()
        
        XCTAssertFalse(sensorManager.isStarted)
        XCTAssertFalse(functionManager.isStarted)
    }
    
    func testUnavailableResources() {
        let expectedUnavailableResources = 123
        let manager = FormulaManager(sensorManager: SensorManagerMock(sensors: [], unavailableResources: expectedUnavailableResources),
                                     functionManager: FunctionManagerMock(functions: []))
        
        XCTAssertEqual(expectedUnavailableResources, manager.unavailableResources(for: 0))
    }
}
