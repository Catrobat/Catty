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

final class LocationManagerMock: LocationManager {
    var magneticHeading: Double?
    var latitude: Double?
    var longitude: Double?
    var altitude: Double?
    var locationAccuracy: Double?

    var heading: Heading? {
        guard let magneticHeading = self.magneticHeading else { return nil }
        return HeadingMock(magneticHeading: magneticHeading)
    }
    
    var location: Location? {
        guard let latitude = self.latitude,
              let longitude = self.longitude,
              let altitude = self.altitude,
              let locationAccuracy = self.locationAccuracy
              else {
                    return nil
                }
        return LocationMock(coordinate: LocationCoordinate2DMock(longitude: longitude, latitude: latitude), altitude: altitude, horizontalAccuracy: locationAccuracy)
    }
}

struct HeadingMock: Heading {
    var magneticHeading: Double
}

struct LocationCoordinate2DMock: LocationCoordinate2D {
    var longitude: Double
    var latitude: Double
}

struct LocationMock: Location {
    var coordinate: LocationCoordinate2D
    var altitude: Double
    var horizontalAccuracy: Double
}
