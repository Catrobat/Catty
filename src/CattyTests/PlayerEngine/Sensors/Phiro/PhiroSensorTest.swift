/**
 *  Copyright (C) 2010-2019 The Catrobat Team
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

    // TODO: other tests - raw value and conversions

    override func setUp() {
        super.setUp()
        bluetoothService = BluetoothService.sharedInstance()
        phiroSideLeft = PhiroSideLeftSensor { [ weak self ] in self?.bluetoothService }
        phiroSideRight = PhiroSideRightSensor { [ weak self ] in self?.bluetoothService }
        phiroFrontLeft = PhiroFrontLeftSensor { [ weak self ] in self?.bluetoothService }
        phiroFrontRight = PhiroFrontRightSensor { [ weak self ] in self?.bluetoothService }
        phiroBottomLeft = PhiroBottomLeftSensor { [ weak self ] in self?.bluetoothService }
        phiroBottomRight = PhiroBottomRightSensor { [ weak self ] in self?.bluetoothService }
    }

    override func tearDown() {
        bluetoothService = nil
        phiroSideLeft = nil
        phiroSideRight = nil
        phiroFrontLeft = nil
        phiroFrontRight = nil
        phiroBottomLeft = nil
        phiroBottomRight = nil
        super.tearDown()
    }

    func testFormulaEditorSectionFrontLeft() {
        UserDefaults.standard.set(true, forKey: kUsePhiroBricks)
        XCTAssertEqual(.device(position: type(of: phiroFrontLeft).position), phiroFrontLeft.formulaEditorSection(for: SpriteObject()))

        UserDefaults.standard.set(false, forKey: kUsePhiroBricks)
        XCTAssertEqual(.hidden, phiroFrontLeft.formulaEditorSection(for: SpriteObject()))
    }

    func testFormulaEditorSectionFrontLRight() {
        UserDefaults.standard.set(true, forKey: kUsePhiroBricks)
        XCTAssertEqual(.device(position: type(of: phiroFrontRight).position), phiroFrontRight.formulaEditorSection(for: SpriteObject()))

        UserDefaults.standard.set(false, forKey: kUsePhiroBricks)
        XCTAssertEqual(.hidden, phiroFrontRight.formulaEditorSection(for: SpriteObject()))
    }

    func testFormulaEditorSectionSideLeft() {
        UserDefaults.standard.set(true, forKey: kUsePhiroBricks)
        XCTAssertEqual(.device(position: type(of: phiroSideLeft).position), phiroSideLeft.formulaEditorSection(for: SpriteObject()))

        UserDefaults.standard.set(false, forKey: kUsePhiroBricks)
        XCTAssertEqual(.hidden, phiroSideLeft.formulaEditorSection(for: SpriteObject()))
    }

    func testFormulaEditorSectionSideRight() {
        UserDefaults.standard.set(true, forKey: kUsePhiroBricks)
        XCTAssertEqual(.device(position: type(of: phiroSideRight).position), phiroSideRight.formulaEditorSection(for: SpriteObject()))

        UserDefaults.standard.set(false, forKey: kUsePhiroBricks)
        XCTAssertEqual(.hidden, phiroSideRight.formulaEditorSection(for: SpriteObject()))
    }

    func testFormulaEditorSectionBottomLeft() {
        UserDefaults.standard.set(true, forKey: kUsePhiroBricks)
        XCTAssertEqual(.device(position: type(of: phiroBottomLeft).position), phiroBottomLeft.formulaEditorSection(for: SpriteObject()))

        UserDefaults.standard.set(false, forKey: kUsePhiroBricks)
        XCTAssertEqual(.hidden, phiroBottomLeft.formulaEditorSection(for: SpriteObject()))
    }

    func testFormulaEditorSectionBottomRight() {
        UserDefaults.standard.set(true, forKey: kUsePhiroBricks)
        XCTAssertEqual(.device(position: type(of: phiroBottomRight).position), phiroBottomRight.formulaEditorSection(for: SpriteObject()))

        UserDefaults.standard.set(false, forKey: kUsePhiroBricks)
        XCTAssertEqual(.hidden, phiroBottomRight.formulaEditorSection(for: SpriteObject()))
    }
}
