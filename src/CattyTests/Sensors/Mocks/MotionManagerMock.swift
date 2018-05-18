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

final class MotionManagerMock: MotionManager {
    var isDeviceMotionAvailable = true
    var isAccelerometerAvailable = true
    var isGyroAvailable = true
    var isMagnetometerAvailable = true
    
    var xAcceleration: Double?
    var yAcceleration: Double?
    var zAcceleration: Double?

    var attitude: (pitch: Double, roll: Double)?

    var accelerometerData: AccelerometerData? {
        guard let xAcceleration = self.xAcceleration,
            let yAcceleration = self.yAcceleration,
            let zAcceleration = self.zAcceleration
            else { return nil }

        return AccelerometerDataMock(
            acceleration: AccelerationMock(
                x: xAcceleration, y: yAcceleration, z: zAcceleration
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
    var acceleration: Acceleration
}

struct AccelerationMock: Acceleration {
    var x: Double
    var y: Double
    var z: Double
}

struct DeviceMotionMock: DeviceMotion {
    var attitude: Attitude
}

struct AttitudeMock: Attitude {
    var pitch: Double
    var roll: Double
}
