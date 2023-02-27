/**
 *  Copyright (C) 2010-2023 The Catrobat Team
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

final class SetInstrumentBrickTests: XCTestCase {

    override func setUp() {
        super.setUp()
    }

    func testIsEqual() {
        let brickA = SetInstrumentBrick()
        brickA.instrument = Instrument.marimba

        let brickB = SetInstrumentBrick()
        brickB.instrument = Instrument.marimba

        XCTAssertTrue(brickA.isEqual(to: brickB))
    }

    func testIsEqualDifferentInstruments() {
        let brickA = SetInstrumentBrick()
        brickA.instrument = Instrument.marimba

        let brickB = SetInstrumentBrick()
        brickB.instrument = Instrument.bass

        XCTAssertFalse(brickA.isEqual(to: brickB))
    }

    func testMutableCopy() {
        let brick = SetInstrumentBrick()
        brick.instrument = Instrument.clarinet

        let copiedBrick: SetInstrumentBrick = brick.mutableCopy(with: CBMutableCopyContext()) as! SetInstrumentBrick

        XCTAssertTrue(brick.isEqual(to: copiedBrick))
        XCTAssertFalse(brick === copiedBrick)
        XCTAssertEqual(brick.instrument, copiedBrick.instrument)
    }
}
