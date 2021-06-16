/**
 *  Copyright (C) 2010-2021 The Catrobat Team
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

@objc class ArduinoAnalogPinFunction: NSObject, SingleParameterDoubleFunction {

    @objc static var tag = "analogPin"
    static var name = kUIFESensorArduinoAnalog
    static var defaultValue = 0.0
    static var position = 350
    static var isIdempotent = false
    static var requiredResource = ResourceType.bluetoothArduino

    let getBluetoothService: () -> BluetoothService?

    init(bluetoothServiceGetter: @escaping () -> BluetoothService?) {
        self.getBluetoothService = bluetoothServiceGetter
    }

    func tag() -> String {
        type(of: self).tag
    }

    func firstParameter() -> FunctionParameter {
        .number(defaultValue: 0)
    }

    func value(parameter: AnyObject?) -> Double {
        guard let pin = parameter as? Int else { return type(of: self).defaultValue }

        return self.getBluetoothService()?.getSensorArduino()?.getAnalogPin(pin) ?? type(of: self).defaultValue
    }

    func formulaEditorSections() -> [FormulaEditorSection] {
        if UserDefaults.standard.bool(forKey: kUseArduinoBricks) == false {
            return []
        }
        return [.sensors(position: type(of: self).position, subsection: .arduino)]
    }
}
