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

final class FacePositionYSensorTest: XCTestCase {
    
    var sensor: FacePositionYSensor!
    var cameraManagerMock: FaceDetectionManagerMock!
    
    func testDefaultRawValue() {
        let sensor = FaceDetectedSensor { nil }
        XCTAssertEqual(type(of: sensor).defaultRawValue, sensor.rawValue(), accuracy: 0.0001)
    }
    
    override func setUp() {
        self.cameraManagerMock = FaceDetectionManagerMock()
        self.sensor = FacePositionYSensor { [ weak self ] in self?.cameraManagerMock }
    }
    
    override func tearDown() {
        self.cameraManagerMock = nil
        self.sensor = nil
    }
    
    func testRawValue() {
        self.cameraManagerMock.facePositionY = 0
        XCTAssertEqual(0, self.sensor.rawValue())
        
        self.cameraManagerMock.facePositionY = 256
        XCTAssertEqual(256, self.sensor.rawValue())
        
        self.cameraManagerMock.facePositionY = -150
        XCTAssertEqual(-150, self.sensor.rawValue())
    }
    
    func testConvertToStandardized() {
        // the face is in the middle of the screen
        XCTAssertEqual(-300, sensor.convertToStandardized(rawValue: 0))
        
        // mathematical middle
        XCTAssertEqual(0, sensor.convertToStandardized(rawValue: 0))
        
        // half up
        XCTAssertEqual(-450, sensor.convertToStandardized(rawValue: 0))
        
        // half down
        XCTAssertEqual(100, sensor.convertToStandardized(rawValue: 0))
    }
    
    func testTag() {
        XCTAssertEqual("FACE_Y_POSITION", type(of: sensor).tag)
    }
    
    func testRequiredResources() {
        XCTAssertEqual(ResourceType.faceDetection, type(of: sensor).requiredResource)
    }
    
    func testFormulaEditorSection() {
        UserDefaults.standard.set(true, forKey: kUseFaceDetectionSensors)
        XCTAssertEqual(.device(position: type(of: sensor).position), type(of: sensor).formulaEditorSection(for: SpriteObject()))
        
        UserDefaults.standard.set(false, forKey: kUseFaceDetectionSensors)
        XCTAssertEqual(.hidden, type(of: sensor).formulaEditorSection(for: SpriteObject()))
    }
}
