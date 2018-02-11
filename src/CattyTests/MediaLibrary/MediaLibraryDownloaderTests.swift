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
import DVR

class MediaLibraryDownloaderTests: XCTestCase {

    // MARK: - Download Index

    func testDownloadIndexSucceeds() {
        let dvrSession = Session(cassetteName: "MediaLibraryDownloader.downloadIndex.success")
        let downloader = MediaLibraryDownloader(session: dvrSession)
        let expectation = XCTestExpectation(description: "Download index for backgrounds")

        downloader.downloadIndex(for: .backgrounds) { categories, error in
            XCTAssertNil(error, "request failed")
            guard let categories = categories, !categories.isEmpty else { XCTFail("no categories found"); return }
            guard let items = categories.first, let item = items.first else { XCTFail("no items found in category"); return }

            // check that the first item in the first category has no empty properties (except cachedData)
            XCTAssertNotEqual(item.name, "")
            XCTAssertNotEqual(item.category, "")
            XCTAssertNotEqual(item.fileExtension, "")
            XCTAssertNotEqual(item.relativePath, "")
            XCTAssertNil(item.cachedData)
            XCTAssertNoThrow(item.downloadURL)

            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1.0)
    }

    func testDownloadIndexFailsWithUnexpectedError() {
        let mockSession = URLSessionMock()
        let downloader = MediaLibraryDownloader(session: mockSession)
        let expectation = XCTestExpectation(description: "Download index for backgrounds")

        downloader.downloadIndex(for: .backgrounds) { categories, error in
            guard let error = error else { XCTFail("no error returned"); return }
            XCTAssertEqual(error, .unexpectedError)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1.0)
    }

    func testDownloadIndexFailsWithRequestError() {
        let dvrSession = Session(cassetteName: "MediaLibraryDownloader.downloadIndex.fail.request")
        let downloader = MediaLibraryDownloader(session: dvrSession)
        let expectation = XCTestExpectation(description: "Download index for backgrounds")

        downloader.downloadIndex(for: .backgrounds) { categories, error in
            guard let error = error else { XCTFail("no error received"); return }
            switch error {
            case let .request(error: _, statusCode: statusCode):
                XCTAssertNotEqual(statusCode, 200)
            default:
                XCTFail("wrong error received")
            }
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1.0)
    }

    func testDownloadIndexFailsWithParseError() {
        let dvrSession = Session(cassetteName: "MediaLibraryDownloader.downloadIndex.fail.parse")
        let downloader = MediaLibraryDownloader(session: dvrSession)
        let expectation = XCTestExpectation(description: "Download index for backgrounds")

        downloader.downloadIndex(for: .backgrounds) { categories, error in
            guard let error = error else { XCTFail("no error received"); return }
            switch error {
            case .parse(error: _):
                break
            default:
                XCTFail("wrong error received")
            }
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1.0)
    }

    // MARK: - Download Data

    func testDownloadDataSucceeds() {
        let dvrSession = Session(cassetteName: "MediaLibraryDownloader.downloadData.success")
        let downloader = MediaLibraryDownloader(session: dvrSession)
        let mediaItem = MediaItem(name: "", fileExtension: "", category: "", relativePath: "/pocketcode/download-media/562", cachedData: nil)
        let expectation = XCTestExpectation(description: "Download background item")

        downloader.downloadData(for: mediaItem) { data, error in
            XCTAssertNil(error, "request failed")
            guard let data = data, !data.isEmpty else { XCTFail("no data received"); return }
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1.0)
    }

    func testDownloadDataFailsWithUnexpectedError() {
        let mockSession = URLSessionMock()
        let downloader = MediaLibraryDownloader(session: mockSession)
        let mediaItem = MediaItem(name: "", fileExtension: "", category: "", relativePath: "", cachedData: nil)
        let expectation = XCTestExpectation(description: "Download background item")

        downloader.downloadData(for: mediaItem) { data, error in
            guard let error = error else { XCTFail("no error returned"); return }
            switch error {
            case .unexpectedError:
                break
            default:
                XCTFail("wrong error type")
            }
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1.0)
    }

    func testDownloadDataFailsWithRequestError() {
        let dvrSession = Session(cassetteName: "MediaLibraryDownloader.downloadData.fail.request")
        let downloader = MediaLibraryDownloader(session: dvrSession)
        let mediaItem = MediaItem(name: "", fileExtension: "", category: "", relativePath: "/pocketcode/download-media/99999", cachedData: nil)
        let expectation = XCTestExpectation(description: "Download background item")

        downloader.downloadData(for: mediaItem) { data, error in
            guard let error = error else { XCTFail("no error received"); return }
            switch error {
            case let .request(error: _, statusCode: statusCode):
                XCTAssertEqual(statusCode, 404)
            default:
                XCTFail("wrong error received")
            }
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1.0)
    }
}

// Equatable conformance is added here in order to be able to compare a download operation's error code.
// Wrapped error values won't be compared.
extension MediaLibraryDownloadError: Equatable {
    public static func ==(lhs: MediaLibraryDownloadError, rhs: MediaLibraryDownloadError) -> Bool {
        switch (lhs, rhs) {
        case (.request, .request), (.parse, .parse), (.unexpectedError, .unexpectedError):
            return true
        default:
            return false
        }
    }
}
