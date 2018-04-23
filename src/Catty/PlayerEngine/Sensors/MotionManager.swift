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

protocol MotionManager {
    var accelerometerData: AccelerometerData? { get }
    var deviceMotion: DeviceMotion? { get }
}

protocol AccelerometerData {
    var acceleration: Acceleration { get }
}

protocol Acceleration {
    var x: Double { get }
    var y: Double { get }
    var z: Double { get }
}

protocol DeviceMotion {
    var attitude: Attitude { get }
}

protocol Attitude {
    var pitch: Double { get }
    var roll: Double { get }
}
