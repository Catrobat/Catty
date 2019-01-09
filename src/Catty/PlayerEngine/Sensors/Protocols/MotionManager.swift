/**
 *  Copyright (C) 2010-2019 The Catrobat Team
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

protocol MotionManager {
    var accelerometerData: AccelerometerData? { get }
    var deviceMotion: DeviceMotion? { get }
    var gyroData: GyroData? { get }
    var isDeviceMotionAvailable: Bool { get }
    var isAccelerometerAvailable: Bool { get }
    var isGyroAvailable: Bool { get }
    var isMagnetometerAvailable: Bool { get }

    func startGyroUpdates()
    func startDeviceMotionUpdates()
    func startAccelerometerUpdates()
    func startMagnetometerUpdates()
    func stopAccelerometerUpdates()
    func stopDeviceMotionUpdates()
    func stopGyroUpdates()
    func stopMagnetometerUpdates()
}

protocol AccelerometerData {
    var acceleration: CMAcceleration { get }
}

protocol DeviceMotion {
    var attitude: Attitude { get }
    var gravity: CMAcceleration { get }
    var userAcceleration: CMAcceleration { get }
}

protocol GyroData {
    var rotationRate: CMRotationRate { get }
}

protocol Attitude {
    var pitch: Double { get }
    var roll: Double { get }
}
