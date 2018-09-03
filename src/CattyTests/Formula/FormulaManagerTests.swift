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
    var motionManager: MotionManagerMock!
    var locationManager: LocationManagerMock!
    var faceDetectionManager: FaceDetectionManagerMock!
    var audioManager: AudioManagerMock!
    var touchManager: TouchManagerMock!
    var bluetoothService: BluetoothService!
    
    override func setUp() {
        spriteObject = SpriteObjectMock()
        
        motionManager = MotionManagerMock()
        locationManager = LocationManagerMock()
        faceDetectionManager = FaceDetectionManagerMock()
        audioManager = AudioManagerMock()
        touchManager = TouchManagerMock()
        bluetoothService = BluetoothService.sharedInstance()
    }
    
    func testFormulaEditorItemsEmpty() {
        let manager = FormulaManager(sensorManager: SensorManagerMock(sensors: []),
                                     functionManager: FunctionManagerMock(functions: []))
        
        XCTAssertEqual(0, manager.formulaEditorItems(spriteObject: spriteObject).count)
        XCTAssertEqual(0, manager.formulaEditorItemsForMathSection(spriteObject: spriteObject).count)
        XCTAssertEqual(0, manager.formulaEditorItemsForDeviceSection(spriteObject: spriteObject).count)
        XCTAssertEqual(0, manager.formulaEditorItemsForObjectSection(spriteObject: spriteObject).count)
    }
    
    func testFormulaEditorItems() {
        let functionA = ZeroParameterDoubleFunctionMock(value: 1.0, formulaEditorSection: .object(position: 1))
        let functionB = ZeroParameterDoubleFunctionMock(value: 2.0, formulaEditorSection: .device(position: 2))
        let functionC = ZeroParameterDoubleFunctionMock(value: 3.0, formulaEditorSection: .hidden)
        
        let sensorA = SensorMock(formulaEditorSection: .object(position: 3))
        let sensorB = SensorMock(formulaEditorSection: .hidden)
        
        let manager = FormulaManager(sensorManager: SensorManagerMock(sensors: [sensorA, sensorB]),
                                     functionManager: FunctionManager(functions: [functionA, functionB, functionC]))
        
        let items = manager.formulaEditorItems(spriteObject: spriteObject)
        XCTAssertEqual(3, items.count)
        XCTAssertEqual(functionA.formulaEditorSection(), items[0].function?.formulaEditorSection())
        XCTAssertEqual(functionB.formulaEditorSection(), items[1].function?.formulaEditorSection())
        XCTAssertEqual(sensorA.formulaEditorSection(for: spriteObject), items[2].sensor?.formulaEditorSection(for: spriteObject))
    }
    
    func testFormulaEditorItemsSamePosition() {
        let functionA = ZeroParameterDoubleFunctionMock(value: 1.0, formulaEditorSection: .object(position: 1))
        let functionB = ZeroParameterDoubleFunctionMock(value: 2.0, formulaEditorSection: .object(position: 1))
        
        let sensorA = SensorMock(formulaEditorSection: .object(position: 1))
        
        let manager = FormulaManager(sensorManager: SensorManagerMock(sensors: [sensorA]),
                                     functionManager: FunctionManager(functions: [functionA, functionB]))
        
        XCTAssertEqual(3, manager.formulaEditorItems(spriteObject: spriteObject).count)
    }
    
    func testFormulaEditorItemsForMathSection() {
        let functionA = ZeroParameterDoubleFunctionMock(value: 1.0, formulaEditorSection: .math(position: 10))
        let functionB = ZeroParameterDoubleFunctionMock(value: 2.0, formulaEditorSection: .object(position: 1))
        
        let sensorA = SensorMock(formulaEditorSection: .math(position: 20))
        let sensorB = SensorMock(formulaEditorSection: .hidden)
        
        let manager = FormulaManager(sensorManager: SensorManagerMock(sensors: [sensorA, sensorB]),
                                     functionManager: FunctionManager(functions: [functionA, functionB]))
        
        let items = manager.formulaEditorItemsForMathSection(spriteObject: spriteObject)
        XCTAssertEqual(2, items.count)
        XCTAssertEqual(functionA.formulaEditorSection(), items[0].function?.formulaEditorSection())
        XCTAssertEqual(sensorA.formulaEditorSection(for: spriteObject), items[1].sensor?.formulaEditorSection(for: spriteObject))
    }
    
    func testFormulaEditorItemsForDeviceSection() {
        let functionA = ZeroParameterDoubleFunctionMock(value: 1.0, formulaEditorSection: .math(position: 10))
        let functionB = ZeroParameterDoubleFunctionMock(value: 2.0, formulaEditorSection: .device(position: 20))
        
        let sensorA = SensorMock(formulaEditorSection: .device(position: 1))
        let sensorB = SensorMock(formulaEditorSection: .hidden)
        
        let manager = FormulaManager(sensorManager: SensorManagerMock(sensors: [sensorA, sensorB]),
                                     functionManager: FunctionManager(functions: [functionA, functionB]))
        
        let items = manager.formulaEditorItemsForDeviceSection(spriteObject: spriteObject)
        XCTAssertEqual(2, items.count)
        XCTAssertEqual(sensorA.formulaEditorSection(for: spriteObject), items[0].sensor?.formulaEditorSection(for: spriteObject))
        XCTAssertEqual(functionB.formulaEditorSection(), items[1].function?.formulaEditorSection())
    }
    
    func testFormulaEditorItemsForObjectSection() {
        let functionA = ZeroParameterDoubleFunctionMock(value: 1.0, formulaEditorSection: .math(position: 10))
        let functionB = ZeroParameterDoubleFunctionMock(value: 2.0, formulaEditorSection: .device(position: 20))
        
        let sensorA = SensorMock(formulaEditorSection: .object(position: 30))
        let sensorB = SensorMock(formulaEditorSection: .hidden)
        
        let manager = FormulaManager(sensorManager: SensorManagerMock(sensors: [sensorA, sensorB]),
                                     functionManager: FunctionManager(functions: [functionA, functionB]))
        
        let items = manager.formulaEditorItemsForObjectSection(spriteObject: spriteObject)
        XCTAssertEqual(1, items.count)
        XCTAssertEqual(sensorA.formulaEditorSection(for: spriteObject), items[0].sensor?.formulaEditorSection(for: spriteObject))
    }
}
