/**
 *  Copyright (C) 2010-2021 The Catrobat Team
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

final class InstrumentTests: XCTestCase {

    func testCount() {
        XCTAssertTrue(Instrument.allCases.count > 20)
    }

    func testFromTag() {
        for instrument in Instrument.allCases {
            XCTAssertEqual(instrument, Instrument.from(tag: instrument.tag))
        }
    }

    func testFromInvalidTag() {
        XCTAssertNil(Instrument.from(tag: "invalid"))
    }

    func testFromLocalizedName() {
        for instrument in Instrument.allCases {
            XCTAssertEqual(instrument, Instrument.from(localizedName: instrument.localizedName))
        }
    }

    func testFromInvalidLocalizedName() {
        XCTAssertNil(Instrument.from(localizedName: "invalid"))
    }

    func testFileName() {
        XCTAssertEqual("choir.sfz", Instrument.choir.fileName)
    }

    func testURL() {
        XCTAssertEqual(URL(fileURLWithPath: Bundle.main.resourcePath! + "/Audio Engine/Sample Instruments Compressed/choir/choir.sfz"), Instrument.choir.url)
    }
}
