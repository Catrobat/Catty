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
@testable import Pocket_Code

final class MotionManagerMock: MotionManager {
    var isDeviceMotionAvailable = true
    var isAccelerometerAvailable = true
    var isGyroAvailable = true
    var isMagnetometerAvailable = true

    var isGyroUpdateStarted = false
    var isDeviceMotionUpdateStarted = false
    var isAccelerometerUpdateStarted = false
    var isMagnetometerUpdateStarted = false

    var xAcceleration: Double = 0
    var yAcceleration: Double = 0
    var zAcceleration: Double = 0

    var xUserAcceleration: Double = 0
    var yUserAcceleration: Double = 0
    var zUserAcceleration: Double = 0

    var xRotation: Double = 0
    var yRotation: Double = 0
    var zRotation: Double = 0

    var xGravity: Double = 0
    var yGravity: Double = 0
    var zGravity: Double = 0

    var attitude: (pitch: Double, roll: Double) = (pitch: 0, roll: 0)

    var accelerometerData: AccelerometerData? {
        AccelerometerDataMock(
            acceleration: CMAcceleration(
                x: self.xAcceleration, y: self.yAcceleration, z: self.zAcceleration
            )
        )
    }

    var gyroData: GyroData? {
        GyroDataMock(
            rotationRate: CMRotationRate (
                x: self.xRotation, y: self.yRotation, z: self.zRotation
            )
        )
    }

    var deviceMotion: DeviceMotion? {
        DeviceMotionMock(
            attitude: AttitudeMock(
                pitch: attitude.pitch, roll: attitude.roll
            ),
            gravity: CMAcceleration(
                x: self.xGravity, y: self.yGravity, z: self.zGravity
            ),
            userAcceleration: CMAcceleration(
                x: self.xUserAcceleration, y: self.yUserAcceleration, z: self.zUserAcceleration
            )
        )
    }

    func startGyroUpdates() {
        isGyroUpdateStarted = true
    }

    func startDeviceMotionUpdates() {
        isDeviceMotionUpdateStarted = true
    }

    func startAccelerometerUpdates() {
        isAccelerometerUpdateStarted = true
    }

    func stopAccelerometerUpdates() {
        isAccelerometerUpdateStarted = false
    }

    func startMagnetometerUpdates() {
        isMagnetometerUpdateStarted = true
    }

    func stopDeviceMotionUpdates() {
        isDeviceMotionUpdateStarted = false
    }

    func stopGyroUpdates() {
        isGyroUpdateStarted = false
    }

    func stopMagnetometerUpdates() {
        isMagnetometerUpdateStarted = false
    }
}

struct AccelerometerDataMock: AccelerometerData {
    var acceleration: CMAcceleration
}

struct DeviceMotionMock: DeviceMotion {
    var attitude: Attitude
    var gravity: CMAcceleration
    var userAcceleration: CMAcceleration
}

struct AttitudeMock: Attitude {
    var pitch: Double
    var roll: Double
}

struct GyroDataMock: GyroData {
    var rotationRate: CMRotationRate
}
