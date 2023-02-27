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

import DVR
import XCTest

@testable import Pocket_Code

final class WebRequestDownloaderTests: XCTestCase {

    var trustedDomainManager: TrustedDomainManager!

    override func setUp() {
        trustedDomainManager = TrustedDomainManager()
    }

    func testWebRequestSucceeds() {
        let url = "https://share.catrob.at/api/projects?category=random&limit=1"
        _ = trustedDomainManager?.add(url: url)

        let downloader = WebRequestDownloader(url: url, session: nil, trustedDomainManager: trustedDomainManager)

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
        let downloader = WebRequestDownloader(url: "", session: nil, trustedDomainManager: nil)
        let expectation = XCTestExpectation(description: "Fetch Fail")

        downloader.download { _, error in
            switch error {
            case .invalidURL:
                expectation.fulfill()
            default:
                XCTFail("wrong or no error received")
            }
        }

        wait(for: [expectation], timeout: 1.0)
    }

    func testWebRequestFailsWithDownloadSize() {
        let url = "https://share.catrob.at/api/projects?category=random&limit=1500"
        _ = trustedDomainManager?.add(url: url)

        let downloader = WebRequestDownloader(url: url, session: nil, trustedDomainManager: trustedDomainManager)

        let config = downloader.session?.configuration
        let delegate = downloader.session?.delegate
        let backingSession = URLSession(configuration: config!, delegate: delegate, delegateQueue: nil)
        let dvrSession = Session(cassetteName: "WebRequestDownloader.fail", backingSession: backingSession)
        downloader.session = dvrSession

        let expectation = XCTestExpectation(description: "Fetch Fail Download Size")

        downloader.download { data, error in
            XCTAssertNil(data)

            switch error {
            case .downloadSize:
                expectation.fulfill()
            default:
                XCTFail("wrong or no error received")
            }
        }

        wait(for: [expectation], timeout: 1.0)
    }

    func testWebRequestFailsWithNoInternet() {
        let error = NSError(domain: "", code: NSURLErrorNotConnectedToInternet, userInfo: nil)
        let mockSession = URLSessionMock(error: error)

        let url = "https://catrob.at"
        let trustedDomainManager = TrustedDomainManager()
        _ = trustedDomainManager?.add(url: url)
        let downloader = WebRequestDownloader(url: url, session: mockSession, trustedDomainManager: trustedDomainManager)
        let expectation = XCTestExpectation(description: "Fetch Fail Download No Internet")

        downloader.download { data, error in
            XCTAssertNil(data)

            switch error {
            case .noInternet:
                expectation.fulfill()
            default:
                XCTFail("wrong or no error received")
            }
        }

        downloader.urlSession(mockSession, task: URLSessionDataTask(), didCompleteWithError: error)
        wait(for: [expectation], timeout: 1.0)
    }

    func testWebRequestFailsWithRequestError() {
        let url = "https://catrob.at"
        let statusCode = 401
        let response = HTTPURLResponse(url: URL(string: url)!, statusCode: statusCode, httpVersion: "HTTP/1.1", headerFields: nil)
        let mockSession = URLSessionMock(response: response, error: nil)
        let mockTask = URLSessionTaskMock(response: response)

        _ = trustedDomainManager?.add(url: url)
        let downloader = WebRequestDownloader(url: "https://catrob.at", session: mockSession, trustedDomainManager: trustedDomainManager)
        let expectation = XCTestExpectation(description: "Fetch Fail Download No Internet")

        downloader.download { data, error in
            XCTAssertNil(data)

            switch error {
            case .request(error: let err, statusCode: let status):
                XCTAssertNil(err)
                XCTAssertEqual(status, statusCode)
                expectation.fulfill()
            default:
                XCTFail("wrong or no error received")
            }
        }

        downloader.urlSession(mockSession, task: mockTask, didCompleteWithError: nil)
        wait(for: [expectation], timeout: 1.0)
    }

    func testWebRequestFailsWithUnexpectedError() {
        let url = "https://catrob.at"
        let error = NSError(domain: "", code: NSURLErrorUnknown, userInfo: nil)
        let mockSession = URLSessionMock(error: error)

        _ = trustedDomainManager?.add(url: url)
        let downloader = WebRequestDownloader(url: url, session: mockSession, trustedDomainManager: trustedDomainManager)
        let expectation = XCTestExpectation(description: "Fetch Fail Download Unxpected")

        downloader.download { data, error in
            XCTAssertNil(data)

            switch error {
            case .unexpectedError:
                expectation.fulfill()
            default:
                XCTFail("wrong or no error received")
            }
        }

        downloader.urlSession(mockSession, task: URLSessionDataTask(), didCompleteWithError: error)

        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(1, mockSession.dataTasksCreated)
    }

    func testWebRequestFailsNotTrusted() {
        let url = "https://catrob.at.malicious"

        let mockSession = URLSessionMock()
        let downloader = WebRequestDownloader(url: url, session: mockSession, trustedDomainManager: trustedDomainManager)
        let expectation = XCTestExpectation(description: "Fetch Fail Download Unxpected")

        let trusted = trustedDomainManager.isUrlInTrustedDomains(url: url)
        XCTAssertFalse(trusted)

        downloader.download { data, error in
            XCTAssertNil(data)

            switch error {
            case .notTrusted:
                expectation.fulfill()
            default:
                XCTFail("wrong or no error received")
            }
        }

        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(0, mockSession.dataTasksCreated)
    }
}
