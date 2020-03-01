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

@testable import Pocket_Code

final class LocationManagerMock: LocationManager {

    var magneticHeading: Double = 0
    var latitude: Double = 0
    var longitude: Double = 0
    var altitude: Double = 0
    var locationAccuracy: Double = 0

    var isHeadingUpdateStarted = false
    var isLocationUpdateStarted = false

    static var isHeadingAvailable = true
    static var isLocationServicesEnabled = true

    var heading: Heading? {
        return HeadingMock(magneticHeading: magneticHeading)
    }

    var location: Location? {
        return LocationMock(coordinate: LocationCoordinate2DMock(longitude: longitude, latitude: latitude), altitude: altitude, horizontalAccuracy: locationAccuracy)
    }

    static func headingAvailable() -> Bool {
        return isHeadingAvailable
    }

    static func locationServicesEnabled() -> Bool {
        return isLocationServicesEnabled
    }

    func requestWhenInUseAuthorization() {
    }

    func startUpdatingHeading() {
        isHeadingUpdateStarted = true
    }

    func startUpdatingLocation() {
        isLocationUpdateStarted = true
    }

    func stopUpdatingHeading() {
        isHeadingUpdateStarted = false
    }

    func stopUpdatingLocation() {
        isLocationUpdateStarted = false
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
