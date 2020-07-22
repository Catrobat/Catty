/**
 *  Copyright (C) 2010-2020 The Catrobat Team
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

@objc class InclinationYSensor: NSObject, DeviceSensor {

    @objc static let tag = "Y_INCLINATION"
    static let name = kUIFESensorInclinationY
    static let defaultRawValue = 0.0
    static let position = 60
    static let requiredResource = ResourceType.accelerometerAndDeviceMotion

    let getMotionManager: () -> MotionManager?

    init(motionManagerGetter: @escaping () -> MotionManager?) {
        self.getMotionManager = motionManagerGetter
    }

    func tag() -> String {
        type(of: self).tag
    }

    func rawValue(landscapeMode: Bool) -> Double {
        if !landscapeMode {
            guard let inclinationSensor = getMotionManager() else { return type(of: self).defaultRawValue }
            guard let deviceMotion = inclinationSensor.deviceMotion else {
                return type(of: self).defaultRawValue
            }
            return deviceMotion.attitude.pitch
        } else {
            return rawValueXSensor()
        }
    }

    func rawValueXSensor() -> Double {
        guard let inclinationSensor = self.getMotionManager() else { return type(of: self).defaultRawValue }
        guard let deviceMotion = inclinationSensor.deviceMotion else {
            return type(of: self).defaultRawValue
        }
        return deviceMotion.attitude.roll
    }

    // pitch is between -pi/2, pi/2 on iOS and -pi,pi on Android
    // going forward, it is positive on both iOS and Android
    // going backwards, it is negative on both iOS and Android
    func convertToStandardized(rawValue: Double) -> Double {
        let faceDown = (getMotionManager()?.accelerometerData?.acceleration.z ?? 0) > 0
        if faceDown == false {
            // screen up
            return Util.radians(toDegree: rawValue)
        } else {
            if rawValue > Double.epsilon {
                return Util.radians(toDegree: Double.pi - rawValue)
            } else {
                return Util.radians(toDegree: -Double.pi - rawValue)
            }
        }
    }

    func formulaEditorSections(for spriteObject: SpriteObject) -> [FormulaEditorSection] {
        [.device(position: type(of: self).position)]
    }
}
