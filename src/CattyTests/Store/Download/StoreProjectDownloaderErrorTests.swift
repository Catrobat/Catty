/**
 *  Copyright (C) 2010-2024 The Catrobat Team
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
import XCTest

class StoreProjectDownloaderErrorTests: XCTestCase {

    func testEqualStoreProjectDowloaderErrors() {
        let request1 = StoreProjectDownloaderError.request(error: nil, statusCode: 200)
        let request2 = StoreProjectDownloaderError.request(error: nil, statusCode: 200)
        let request3 = StoreProjectDownloaderError.request(error: nil, statusCode: 404)
        let request4 = StoreProjectDownloaderError.request(error: ErrorMock.init(""), statusCode: 200)
        let parse = StoreProjectDownloaderError.parse(error: ErrorMock.init(""))

        let cancelled = StoreProjectDownloaderError.cancelled
        let timeout = StoreProjectDownloaderError.timeout
        let unexpectedError = StoreProjectDownloaderError.unexpectedError

        XCTAssertTrue(request1 == request2)
        XCTAssertFalse(request1 == request3)
        XCTAssertFalse(request2 == request4)
        XCTAssertFalse(request4 == parse)

        XCTAssertTrue(cancelled == cancelled && timeout == timeout && unexpectedError == unexpectedError && parse == parse)
        XCTAssertFalse(cancelled == unexpectedError)
        XCTAssertFalse(cancelled == timeout)
        XCTAssertFalse(unexpectedError == timeout)
        XCTAssertFalse(request1 == cancelled)
    }
}
