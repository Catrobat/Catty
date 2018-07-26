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

final class LoudnessSensorTest: XCTestCase {
    
    var audioManager: AudioManagerMock!
    var sensor: LoudnessSensor!
    
    override func setUp() {
        self.audioManager = AudioManagerMock()
        self.sensor = LoudnessSensor { [weak self] in self?.audioManager }
    }
    
    override func tearDown() {
        self.sensor = nil
        self.audioManager = nil
    }
    
    func testDefaultRawValue() {
        let sensor = LoudnessSensor { nil }
        XCTAssertEqual(type(of: sensor).defaultRawValue, sensor.rawValue(), accuracy: 0.0001)
    }
    
    func testRawValue() {
        self.audioManager.mockedLoudnessInDecibels = 3
        XCTAssertEqual(3, self.sensor.rawValue(), accuracy: 0.0001)
        
        self.audioManager.mockedLoudnessInDecibels = -50
        XCTAssertEqual(-50, self.sensor.rawValue(), accuracy: 0.0001)
        
        self.audioManager.mockedLoudnessInDecibels = 10.786
        XCTAssertEqual(10.786, self.sensor.rawValue(), accuracy: 0.0001)
    }
    
    func testConvertToStandardized() {
        // smaller than 0 - Android does not have negative values
        XCTAssertEqual(0, self.sensor.convertToStandardized(rawValue: -60), accuracy: 0.0001)
        
        // background noise
        XCTAssertEqual(1, self.sensor.convertToStandardized(rawValue: -33), accuracy: 0.0001)
        
        // whisper
        XCTAssertEqual(19, self.sensor.convertToStandardized(rawValue: -27), accuracy: 0.0001)
        
        // normal voice
        XCTAssertEqual(70, self.sensor.convertToStandardized(rawValue: -10), accuracy: 0.0001)
        
        // shouting
        XCTAssertEqual(91, self.sensor.convertToStandardized(rawValue: -3), accuracy: 0.0001)
    }
    
    func testTag() {
        XCTAssertEqual("LOUDNESS", type(of: sensor).tag)
    }
    
    func testRequiredResources() {
        XCTAssertEqual(ResourceType.loudness, type(of: sensor).requiredResource)
    }
    
    func testShowInFormulaEditor() {
        XCTAssertTrue(sensor.showInFormulaEditor())
    }
}
