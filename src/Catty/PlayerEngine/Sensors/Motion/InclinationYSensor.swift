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

class InclinationYSensor : CBSensor {

    static let tag = "Y_INCLINATION"
    static let name = kUIFESensorInclinationY
    static let defaultValue = 0.0

    let getMotionManager: () -> MotionManager?

    var rawValue: Double {
        return self.getMotionManager()?.deviceMotion?.attitude.pitch ?? type(of: self).defaultValue
    }

    var standardizedValue: Double {
        var value = Util.radians(toDegree: self.rawValue * -4)

        if ((self.getMotionManager()?.accelerometerData!.acceleration.z)! > 0.0) { // Face Down
            if(value < 0.0) {
                value = -180.0 - value;
            } else {
                value = 180.0 - value;
            }
        }

        return value
    }

    init(motionManagerGetter: @escaping () -> MotionManager?) {
        self.getMotionManager = motionManagerGetter
    }
}
