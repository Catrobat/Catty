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

final class PhiroSensorTest: XCTestCase {
    
    var bluetoothService: BluetoothService!
    var phiroSideLeft: PhiroSideLeftSensor!
    var phiroSideRight: PhiroSideRightSensor!
    var phiroFrontLeft: PhiroFrontLeftSensor!
    var phiroFrontRight: PhiroFrontRightSensor!
    var phiroBottomLeft: PhiroBottomLeftSensor!
    var phiroBottomRight: PhiroBottomRightSensor!
    
    // TO DO: other tests - raw value and conversions
    
    override func setUp() {
        self.bluetoothService = BluetoothService.sharedInstance()
        self.phiroSideLeft = PhiroSideLeftSensor { [ weak self ] in self?.bluetoothService }
        self.phiroSideRight = PhiroSideRightSensor { [ weak self ] in self?.bluetoothService }
        self.phiroFrontLeft = PhiroFrontLeftSensor { [ weak self ] in self?.bluetoothService }
        self.phiroFrontRight = PhiroFrontRightSensor { [ weak self ] in self?.bluetoothService }
        self.phiroBottomLeft = PhiroBottomLeftSensor { [ weak self ] in self?.bluetoothService }
        self.phiroBottomRight = PhiroBottomRightSensor { [ weak self ] in self?.bluetoothService }
    }
    
    override func tearDown() {
        self.bluetoothService = nil
        self.phiroSideLeft = nil
        self.phiroSideRight = nil
        self.phiroFrontLeft = nil
        self.phiroFrontRight = nil
        self.phiroBottomLeft = nil
        self.phiroBottomRight = nil
    }
    
    func testShowInFormulaEditorForPhiroSideLeft() {
        UserDefaults.standard.set(true, forKey: kUsePhiroBricks)
        XCTAssertTrue(phiroSideLeft.showInFormulaEditor())
        
        UserDefaults.standard.set(false, forKey: kUsePhiroBricks)
        XCTAssertFalse(phiroSideLeft.showInFormulaEditor())
    }
    
    func testShowInFormulaEditorForPhiroSideRight() {
        UserDefaults.standard.set(true, forKey: kUsePhiroBricks)
        XCTAssertTrue(phiroSideRight.showInFormulaEditor())
        
        UserDefaults.standard.set(false, forKey: kUsePhiroBricks)
        XCTAssertFalse(phiroSideRight.showInFormulaEditor())
    }
    
    func testShowInFormulaEditorForPhiroFrontLeft() {
        UserDefaults.standard.set(true, forKey: kUsePhiroBricks)
        XCTAssertTrue(phiroFrontLeft.showInFormulaEditor())
        
        UserDefaults.standard.set(false, forKey: kUsePhiroBricks)
        XCTAssertFalse(phiroFrontLeft.showInFormulaEditor())
    }
    
    func testShowInFormulaEditorForPhiroFrontRight() {
        UserDefaults.standard.set(true, forKey: kUsePhiroBricks)
        XCTAssertTrue(phiroFrontRight.showInFormulaEditor())
        
        UserDefaults.standard.set(false, forKey: kUsePhiroBricks)
        XCTAssertFalse(phiroFrontRight.showInFormulaEditor())
    }
    
    func testShowInFormulaEditorForPhiroBottomLeft() {
        UserDefaults.standard.set(true, forKey: kUsePhiroBricks)
        XCTAssertTrue(phiroBottomLeft.showInFormulaEditor())
        
        UserDefaults.standard.set(false, forKey: kUsePhiroBricks)
        XCTAssertFalse(phiroBottomLeft.showInFormulaEditor())
    }
    
    func testShowInFormulaEditorForPhiroBottomRight() {
        UserDefaults.standard.set(true, forKey: kUsePhiroBricks)
        XCTAssertTrue(phiroBottomRight.showInFormulaEditor())
        
        UserDefaults.standard.set(false, forKey: kUsePhiroBricks)
        XCTAssertFalse(phiroBottomRight.showInFormulaEditor())
    }
    
    func testFormulaEditorSectionFrontLeft() {
        UserDefaults.standard.set(true, forKey: kUsePhiroBricks)
        XCTAssertEqual(.device(position: 300), type(of: phiroFrontLeft).formulaEditorSection(for: SpriteObject()))
        
        UserDefaults.standard.set(false, forKey: kUsePhiroBricks)
        XCTAssertEqual(.hidden, type(of: phiroFrontLeft).formulaEditorSection(for: SpriteObject()))
    }
    
    func testFormulaEditorSectionFrontLRight() {
        UserDefaults.standard.set(true, forKey: kUsePhiroBricks)
        XCTAssertEqual(.device(position: 310), type(of: phiroFrontRight).formulaEditorSection(for: SpriteObject()))
        
        UserDefaults.standard.set(false, forKey: kUsePhiroBricks)
        XCTAssertEqual(.hidden, type(of: phiroFrontRight).formulaEditorSection(for: SpriteObject()))
    }
    
    func testFormulaEditorSectionSideLeft() {
        UserDefaults.standard.set(true, forKey: kUsePhiroBricks)
        XCTAssertEqual(.device(position: 320), type(of: phiroSideLeft).formulaEditorSection(for: SpriteObject()))
        
        UserDefaults.standard.set(false, forKey: kUsePhiroBricks)
        XCTAssertEqual(.hidden, type(of: phiroSideLeft).formulaEditorSection(for: SpriteObject()))
    }
    
    func testFormulaEditorSectionSideRight() {
        UserDefaults.standard.set(true, forKey: kUsePhiroBricks)
        XCTAssertEqual(.device(position: 330), type(of: phiroSideRight).formulaEditorSection(for: SpriteObject()))
        
        UserDefaults.standard.set(false, forKey: kUsePhiroBricks)
        XCTAssertEqual(.hidden, type(of: phiroSideRight).formulaEditorSection(for: SpriteObject()))
    }
    
    func testFormulaEditorSectionBottomLeft() {
        UserDefaults.standard.set(true, forKey: kUsePhiroBricks)
        XCTAssertEqual(.device(position: 340), type(of: phiroBottomLeft).formulaEditorSection(for: SpriteObject()))
        
        UserDefaults.standard.set(false, forKey: kUsePhiroBricks)
        XCTAssertEqual(.hidden, type(of: phiroBottomLeft).formulaEditorSection(for: SpriteObject()))
    }
    
    func testFormulaEditorSectionBottomRight() {
        UserDefaults.standard.set(true, forKey: kUsePhiroBricks)
        XCTAssertEqual(.device(position: 350), type(of: phiroBottomRight).formulaEditorSection(for: SpriteObject()))
        
        UserDefaults.standard.set(false, forKey: kUsePhiroBricks)
        XCTAssertEqual(.hidden, type(of: phiroBottomRight).formulaEditorSection(for: SpriteObject()))
    }
}
