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

final class FingerTouchedSensorTest: XCTestCase {
    
    var touchManager: TouchManagerMock!
    var sensor: FingerTouchedSensor!
    
    override func setUp() {
        touchManager = TouchManagerMock()
        sensor = FingerTouchedSensor { [weak self] in self?.touchManager }
    }
    
    override func tearDown() {
        sensor = nil
        touchManager = nil
    }
    
    func testDefaultRawValue() {
        let sensor = FingerTouchedSensor { nil }
        XCTAssertEqual(type(of: sensor).defaultRawValue, sensor.rawValue(), accuracy: 0.0001)
    }
    
    func testRawValue() {
        touchManager.isScreenTouched = true
        XCTAssertEqual(1.0, sensor.rawValue())
        
        touchManager.isScreenTouched = false
        XCTAssertEqual(0.0, sensor.rawValue())
    }
    
    func testConvertToStandardized() {
        XCTAssertEqual(1, self.sensor.convertToStandardized(rawValue: 1, for: SpriteObject()))
        XCTAssertEqual(0, self.sensor.convertToStandardized(rawValue: 0, for: SpriteObject()))
    }
    
    func testTag() {
        XCTAssertEqual("FINGER_TOUCHED", type(of: sensor).tag)
    }
    
    func testRequiredResources() {
        XCTAssertEqual(ResourceType.touchHandler, type(of: sensor).requiredResource)
    }
    
    func testFormulaEditorSection() {
        XCTAssertEqual(.device(position: type(of: sensor).position), sensor.formulaEditorSection(for: SpriteObject()))
    }
}
