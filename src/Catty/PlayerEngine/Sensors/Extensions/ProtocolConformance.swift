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
import CoreLocation

// MARK: - CoreMotion protocol conformance

extension CMMotionManager: MotionManager {
    var accelerometerData: AccelerometerData? {
        return self.value(forKey: "accelerometerData") as? CMAccelerometerData
    }
    var deviceMotion: DeviceMotion? {
        return self.value(forKey: "deviceMotion") as? CMDeviceMotion
    }
    
}
extension CMAccelerometerData: AccelerometerData {
    var acceleration: Acceleration {
        guard let acceleration = self.value(forKey: "acceleration") as? CMAcceleration else { return CMAcceleration() }
        return acceleration
    }
}
extension CMAcceleration: Acceleration {}
extension CMDeviceMotion: DeviceMotion {
    var attitude: Attitude {
        guard let attitude = self.value(forKey: "attitude") as? CMAttitude else { return CMAttitude() }
        return attitude
    }
}
extension CMAttitude: Attitude {}

// MARK: - CoreLocation protocol conformance

extension CLLocationManager: LocationManager {
    var heading: Heading? {
        return self.value(forKey: "heading") as? CLHeading
    }
    
    var location: Location? {
        return self.value(forKey: "location") as? CLLocation
    }
}

extension CLHeading: Heading {}

extension CLLocation: Location {
    var coordinate: LocationCoordinate2D {
        guard let coordinate = self.value(forKey: "coordinate") as? CLLocationCoordinate2D else { return CLLocationCoordinate2D() }
        return coordinate
    }
}

extension CLLocationCoordinate2D: LocationCoordinate2D {}
