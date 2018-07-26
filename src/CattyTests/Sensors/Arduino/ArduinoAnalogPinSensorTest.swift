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

final class ArduinoAnalogPinSensorTest: XCTestCase {
    
    var sensor: ArduinoAnalogPinSensor!
    var bluetoothService: BluetoothService!
    
    func testDefaultRawValue() {
        let sensor = ArduinoAnalogPinSensor { nil }
        XCTAssertEqual(type(of: sensor).defaultRawValue, sensor.rawValue(), accuracy: 0.0001)
    }
    
    func testRawValue() {
        // TODO: add tests
    }
    
    override func setUp() {
        self.bluetoothService = BluetoothService.sharedInstance()
        self.sensor = ArduinoAnalogPinSensor { [ weak self ] in self?.bluetoothService }
    }
    
    override func tearDown() {
        self.bluetoothService = nil
        self.sensor = nil
    }
    
    func testConvertToStandardized() {
        XCTAssertEqual(10, sensor.convertToStandardized(rawValue: 10))
        XCTAssertEqual(1, sensor.convertToStandardized(rawValue: 1))
        XCTAssertEqual(15, sensor.convertToStandardized(rawValue: 15))
    }
    
    func testTag() {
        XCTAssertEqual("analogPin", type(of: sensor).tag)
    }
    
    func testRequiredResources() {
        XCTAssertEqual(ResourceType.bluetoothArduino, type(of: sensor).requiredResource)
    }
    
    func testFormulaEditorSection() {
        UserDefaults.standard.set(true, forKey: kUseArduinoBricks)
        XCTAssertEqual(.device(position: type(of: sensor).position), type(of: sensor).formulaEditorSection(for: SpriteObject()))
        
        UserDefaults.standard.set(false, forKey: kUseArduinoBricks)
        XCTAssertEqual(.hidden, type(of: sensor).formulaEditorSection(for: SpriteObject()))
    }
}
