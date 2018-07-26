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

class ArduinoAnalogPinSensor: DeviceSensor {
    
    static let tag = "analogPin"
    static let name = kUIFESensorArduinoAnalog
    static let defaultRawValue = 0.0
    static let position = 360
    static let requiredResource = ResourceType.bluetoothArduino
    
    let getBluetoothService: () -> BluetoothService?
    
    init(bluetoothServiceGetter: @escaping () -> BluetoothService?) {
        self.getBluetoothService = bluetoothServiceGetter
    }
    
    func rawValue() -> Double {
        return self.getBluetoothService()?.getSensorArduino()?.getAnalogPin(0) ?? type(of: self).defaultRawValue
    }
    
    func convertToStandardized(rawValue: Double) -> Double {
        return rawValue
    }
    
    func showInFormulaEditor() -> Bool {
        return UserDefaults.standard.bool(forKey: kUseArduinoBricks)
    }
    
    static func formulaEditorSection(for spriteObject: SpriteObject) -> FormulaEditorSection {
        if UserDefaults.standard.bool(forKey: kUseArduinoBricks) == false {
            return .hidden
        }
        return .device(position: position)
    }
}
