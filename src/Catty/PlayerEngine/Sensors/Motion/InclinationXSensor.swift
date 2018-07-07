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

class InclinationXSensor: DeviceSensor {
    
    static let tag = "X_INCLINATION"
    static let name = kUIFESensorInclinationX
    static let defaultRawValue = 0.0
    static let requiredResource = ResourceType.accelerometer

    let getMotionManager: () -> MotionManager?
    
    init(motionManagerGetter: @escaping () -> MotionManager?) {
        self.getMotionManager = motionManagerGetter
    }

    func rawValue() -> Double {
        guard let inclinationSensor = self.getMotionManager() else { return InclinationXSensor.defaultRawValue }
        guard let deviceMotion = inclinationSensor.deviceMotion else {
            return InclinationXSensor.defaultRawValue
        }
        
        return deviceMotion.attitude.roll
    }

    // roll is between -pi, pi on both iOS and Android
    // going to right, it is negative on Android and positive on iOS
    // going to left, it is positive on Android and negative on iOS
    func convertToStandardized(rawValue: Double) -> Double {
        return Util.radians(toDegree: -rawValue)
    }
    
    func showInFormulaEditor() -> Bool {
        return true
    }
}
