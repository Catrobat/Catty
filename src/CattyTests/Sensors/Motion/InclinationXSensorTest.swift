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

import XCTest

@testable import Pocket_Code

final class InclinationXSensorTest: XCTestCase {

    var motionManager: MotionManagerMock!
    var sensor: InclinationXSensor!

    override func setUp() {
        self.motionManager = MotionManagerMock()
        self.sensor = InclinationXSensor { [weak self] in self?.motionManager }
    }

    override func tearDown() {
        self.sensor = nil
        self.motionManager = nil
    }

    func testReturnDefaultValue() {
        let sensor = InclinationXSensor { nil }
        XCTAssertEqual(sensor.rawValue, InclinationXSensor.defaultValue)
        XCTAssertEqual(sensor.standardizedValue, InclinationXSensor.defaultValue)
    }
    
    func testStandardization() {
        self.motionManager.attitude = (roll: -Double.pi/2, pitch: 0)
        XCTAssertEqual(self.sensor.rawValue, -Double.pi/2)
        XCTAssertEqual(self.sensor.standardizedValue, 0)

        self.motionManager.attitude = (roll: -Double.pi/3, pitch: 0)
        XCTAssertEqual(self.sensor.rawValue, -Double.pi/3)
        XCTAssertEqual(self.sensor.standardizedValue, 240) // TODO: circumvent float rounding errors (e.g. by converting to Int)

        // TODO: add more cases
    }

    // TODO: add more tests
}
