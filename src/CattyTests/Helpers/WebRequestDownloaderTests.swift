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

import DVR
import XCTest

@testable import Pocket_Code

final class WebRequestDownloaderTests: XCTestCase {

    func testWebRequestSucceeds() {
        let url = "https://share.catrob.at/api/projects?category=random&limit=1"
        let downloader = WebRequestDownloader(url: url, session: nil)

        let config = downloader.session?.configuration
        let delegate = downloader.session?.delegate
        let backingSession = URLSession(configuration: config!, delegate: delegate, delegateQueue: nil)
        let dvrSession = Session(cassetteName: "WebRequestDownloader.success", backingSession: backingSession)
        downloader.session = dvrSession

        let expectation = XCTestExpectation(description: "Fetch Ok")

        downloader.download { response, error in
            XCTAssertNil(error)
            XCTAssertNotNil(response)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1.0)
    }

    func testWebRequestFailsWithInvalidURL() {
        let downloader = WebRequestDownloader(url: "", session: nil)
        let expectation = XCTestExpectation(description: "Fetch Fail")

        downloader.download { _, error in
            guard let error = error else { XCTFail("no error received"); return }
            switch error {
            case WebRequestDownloadError.invalidUrl:
                expectation.fulfill()
            default:
                XCTFail("wrong error received")
            }
        }

        wait(for: [expectation], timeout: 1.0)
    }

    func testWebRequestFailsWithDownloadSize() {
        let url = "https://share.catrob.at/api/projects?category=random&limit=5000"
        let downloader = WebRequestDownloader(url: url, session: nil)

        let config = downloader.session?.configuration
        let delegate = downloader.session?.delegate
        let backingSession = URLSession(configuration: config!, delegate: delegate, delegateQueue: nil)
        let dvrSession = Session(cassetteName: "WebRequestDownloader.fail", backingSession: backingSession)
        downloader.session = dvrSession

        let expectation = XCTestExpectation(description: "Fetch Fail Download Size")

        downloader.download { _, error in
            guard let error = error else { XCTFail("no error received"); return }
            switch error {
            case WebRequestDownloadError.downloadSize:
                expectation.fulfill()
            default:
                XCTFail("wrong error received")
            }
        }

        wait(for: [expectation], timeout: 1.0)
    }

    func testWebRequestFailsWithNoInternet() {
        let mockSession = URLSessionMock()
        let url = "https://share.catrob.at/api/projects?category=random&limit=5000"
        let mock = WebRequestDownloaderMock(url: url, session: mockSession)

        let error = NSError(domain: "", code: NSURLErrorNotConnectedToInternet, userInfo: nil)
        let expectation = XCTestExpectation(description: "Fetch Fail Download No Internet")

        mock.downloadWithError(error: error) { data, error in
            XCTAssertNil(data)
            switch error as? WebRequestDownloadError {
            case .noInternet:
                expectation.fulfill()
            default:
                XCTFail("wrong error received")
            }
        }

        wait(for: [expectation], timeout: 1.0)
    }

    func testWebRequestFailsWithUnexpectedError() {
        let mockSession = URLSessionMock()
        let url = "https://share.catrob.at/api/projects?category=random"
        let mock = WebRequestDownloaderMock(url: url, session: mockSession)

        let error = NSError(domain: "", code: NSURLErrorUnknown, userInfo: nil)
        let expectation = XCTestExpectation(description: "Fetch Fail Download Unxpected")

        mock.downloadWithError(error: error) { data, error in
            XCTAssertNil(data)
            switch error as? WebRequestDownloadError {
            case .unexpectedError:
                expectation.fulfill()
            default:
                XCTFail("wrong error received")
            }
        }

        wait(for: [expectation], timeout: 1.0)
    }
}
