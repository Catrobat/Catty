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

final class FaceSizeSensorTest: XCTestCase {
    
    var sensor: FaceSizeSensor!
    var cameraManagerMock: FaceDetectionManagerMock!
    
    func testDefaultRawValue() {
        let sensor = FaceSizeSensor { nil }
        XCTAssertEqual(type(of: sensor).defaultRawValue, sensor.rawValue(), accuracy: 0.0001)
    }
    
    override func setUp() {
        self.cameraManagerMock = FaceDetectionManagerMock()
        self.sensor = FaceSizeSensor { [ weak self ] in self?.cameraManagerMock }
    }
    
    override func tearDown() {
        self.cameraManagerMock = nil
        self.sensor = nil
    }
    
    func testRawValue() {
        self.cameraManagerMock.faceSize = CGRect(x: 0, y: 0, width: 10, height: 10)
        XCTAssertEqual(Double((self.cameraManagerMock.faceSize?.width)!) * Double((self.cameraManagerMock.faceSize?.height)!), sensor.rawValue(), accuracy: 0.0001)
        
        self.cameraManagerMock.faceSize = CGRect(x: 0, y: 0, width: 50, height: 70)
        XCTAssertEqual(Double((self.cameraManagerMock.faceSize?.width)!) * Double((self.cameraManagerMock.faceSize?.height)!), sensor.rawValue(), accuracy: 0.0001)
    }
    
    
    func testConvertToStandardized() {
        let screenSize = Util.screenHeight() * Util.screenWidth() / 100
        
        // arm-length from the face
        XCTAssertEqual(28, sensor.convertToStandardized(rawValue: Double(28 * screenSize)))
        
        // good-looking selfie length
        XCTAssertEqual(48, sensor.convertToStandardized(rawValue: Double(48 * screenSize)))
        
        // awkward selfie level -  too close
        XCTAssertEqual(80, sensor.convertToStandardized(rawValue: Double(80 * screenSize)))
    }
    
    func testTag() {
        XCTAssertEqual("FACE_SIZE", type(of: sensor).tag)
    }
    
    func testRequiredResources() {
        XCTAssertEqual(ResourceType.faceDetection, type(of: sensor).requiredResource)
    }
    
    func testFormulaEditorSection() {
        XCTAssertEqual(.device(position: type(of: sensor).position), type(of: sensor).formulaEditorSection(for: SpriteObject()))
    }
}
