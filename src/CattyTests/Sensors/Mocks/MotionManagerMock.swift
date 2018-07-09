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

@testable import Pocket_Code
import CoreMotion

final class MotionManagerMock: MotionManager {
    var isDeviceMotionAvailable = true
    var isAccelerometerAvailable = true
    var isGyroAvailable = true
    var isMagnetometerAvailable = true
    
    var xAcceleration: Double = 0
    var yAcceleration: Double = 0
    var zAcceleration: Double = 0

    var attitude: (pitch: Double, roll: Double)?

    var accelerometerData: AccelerometerData? {
        return AccelerometerDataMock(
            acceleration: CMAcceleration(
                x: self.xAcceleration, y: self.yAcceleration, z: self.zAcceleration
            )
        )
    }

    var deviceMotion: DeviceMotion? {
        guard let attitude = self.attitude else { return nil }

        return DeviceMotionMock(
            attitude: AttitudeMock(
                pitch: attitude.pitch, roll: attitude.roll
            )
        )
    }
}

struct AccelerometerDataMock: AccelerometerData {
    var acceleration: CMAcceleration
}

struct DeviceMotionMock: DeviceMotion {
    var attitude: Attitude
}

struct AttitudeMock: Attitude {
    var pitch: Double
    var roll: Double
}
