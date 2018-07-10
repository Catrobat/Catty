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

import CoreMotion

class InclinationYSensor : DeviceSensor {

    static let tag = "Y_INCLINATION"
    static let name = kUIFESensorInclinationY
    static let defaultRawValue = 0.0
    static let requiredResource = ResourceType.accelerometer

    let getMotionManager: () -> MotionManager?
    
    init(motionManagerGetter: @escaping () -> MotionManager?) {
        self.getMotionManager = motionManagerGetter
    }

    func rawValue() -> Double {
        guard let inclinationSensor = self.getMotionManager() else { return type(of: self).defaultRawValue }
        guard let deviceMotion = inclinationSensor.deviceMotion else {
            return type(of: self).defaultRawValue
        }
        return deviceMotion.attitude.pitch
      
    }
    
    // pitch is between -pi/2, pi/2 on iOS and -pi,pi on Android
    // going forward, it is positive on both iOS and Android
    // going backwards, it is negative on both iOS and Android
    func convertToStandardized(rawValue: Double) -> Double {
        let faceDown = (getMotionManager()?.accelerometerData?.acceleration.z ?? 0) >  0
        if faceDown == false {
            // screen up
            return Util.radians(toDegree: rawValue)
        } else {
            if rawValue > 0.0001 {
                return Util.radians(toDegree: Double.pi - rawValue)
            } else {
                return Util.radians(toDegree: -Double.pi - rawValue)
            }
        }
    }
    
    func showInFormulaEditor() -> Bool {
        return true
    }
}
