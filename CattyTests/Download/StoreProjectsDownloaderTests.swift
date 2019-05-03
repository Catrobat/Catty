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

import DVR
@testable import Pocket_Code
import XCTest

class StoreProjectsDownloaderTests: XCTestCase {

    // MARK: - Fetch Projects

    func testfetchFeaturedProjectsSucceeds() {
        let dvrSession = Session(cassetteName: "StoreProjectDownloader.fetchFeaturedProjects.success")
        let downloader = StoreProjectDownloader(session: dvrSession)
        let expectation = XCTestExpectation(description: "Fetch Featured Projects")

        downloader.fetchProjects(forType: .featured, offset: 0) { projects, error in
            XCTAssertNil(error, "request failed")
            guard let projects = projects else { XCTFail("no featured projects found"); return }
            guard let item = projects.projects.first else { XCTFail("no featured projects in array"); return }

            // check that the first item in the first category has no empty properties (except cachedData)
            XCTAssertNotEqual(item.projectId, 0)
            XCTAssertNotEqual(item.projectName, "")
            XCTAssertNotEqual(item.author, "")

            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1.0)
    }

    func testfetchFeaturedProjectsFailsWithUnexpectedError() {
        let mockSession = URLSessionMock()
        let downloader = StoreProjectDownloader(session: mockSession)
        let expectation = XCTestExpectation(description: "Fetch Featured Projects")

        downloader.fetchProjects(forType: .featured, offset: 0) { _, error in
            guard let error = error else { XCTFail("no error returned"); return }
            XCTAssertEqual(error, .unexpectedError)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1.0)
    }

    func testfetchFeaturedProjectsFailsWithRequestError() {
        let dvrSession = Session(cassetteName: "StoreProjectDownloader.fetchFeaturedProjects.fail.request")
        let downloader = StoreProjectDownloader(session: dvrSession)
        let expectation = XCTestExpectation(description: "Fetch Featured Projects")

        downloader.fetchProjects(forType: .featured, offset: 0) { _, error in
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

    func testfetchFeaturedProjectsFailsWithParseError() {
        let dvrSession = Session(cassetteName: "StoreProjectDownloader.fetchFeaturedProjects.fail.parse")
        let downloader = StoreProjectDownloader(session: dvrSession)
        let expectation = XCTestExpectation(description: "Fetch Featured Projects")

        downloader.fetchProjects(forType: .featured, offset: 0) { _, error in
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

    // MARK: - Most Downloaded Projects

    func testfetchMostDownloadedProjectsSucceeds() {
        let dvrSession = Session(cassetteName: "StoreProjectDownloader.fetchMostDownloadedProjects.success")
        let downloader = StoreProjectDownloader(session: dvrSession)
        let expectation = XCTestExpectation(description: "Fetch Most Downloaded Projects")

        downloader.fetchProjects(forType: .mostDownloaded, offset: 0) { projects, error in
            XCTAssertNil(error, "request failed")
            guard let projects = projects else { XCTFail("no most downloaded projects found"); return }
            guard let item = projects.projects.first else { XCTFail("no most downloaded projects in array"); return }

            // check that the first item in the first category has no empty properties (except cachedData)
            XCTAssertNotEqual(item.projectId, 0)
            XCTAssertNotEqual(item.projectName, "")
            XCTAssertNotEqual(item.author, "")

            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1.0)
    }

    func testfetchMostDownloadedProjectsFailsWithUnexpectedError() {
        let mockSession = URLSessionMock()
        let downloader = StoreProjectDownloader(session: mockSession)
        let expectation = XCTestExpectation(description: "Fetch Most Downloaded Projects")

        downloader.fetchProjects(forType: .mostDownloaded, offset: 0) { _, error in
            guard let error = error else { XCTFail("no error returned"); return }
            XCTAssertEqual(error, .unexpectedError)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1.0)
    }

    func testfetchMostDownloadedProjectsFailsWithRequestError() {
        let dvrSession = Session(cassetteName: "StoreProjectDownloader.fetchMostDownloadedProjects.fail.request")
        let downloader = StoreProjectDownloader(session: dvrSession)
        let expectation = XCTestExpectation(description: "Fetch Most Downloaded Projects")

        downloader.fetchProjects(forType: .mostDownloaded, offset: 0) { _, error in
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

    func testfetchMostDownloadedProjectsFailsWithParseError() {
        let dvrSession = Session(cassetteName: "StoreProjectDownloader.fetchMostDownloadedProjects.fail.parse")
        let downloader = StoreProjectDownloader(session: dvrSession)
        let expectation = XCTestExpectation(description: "Fetch Most Downloaded Projects")

        downloader.fetchProjects(forType: .mostDownloaded, offset: 0) { _, error in
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

    // MARK: - Most Viewed Projects

    func testfetchMostViewedProjectsSucceeds() {
        let dvrSession = Session(cassetteName: "StoreProjectDownloader.fetchMostViewedProjects.success")
        let downloader = StoreProjectDownloader(session: dvrSession)
        let expectation = XCTestExpectation(description: "Fetch Most Viewed Projects")

        downloader.fetchProjects(forType: .mostViewed, offset: 0) { projects, error in
            XCTAssertNil(error, "request failed")
            guard let projects = projects else { XCTFail("no most viewed projects found"); return }
            guard let item = projects.projects.first else { XCTFail("no most viewed projects in array"); return }

            // check that the first item in the first category has no empty properties (except cachedData)
            XCTAssertNotEqual(item.projectId, 0)
            XCTAssertNotEqual(item.projectName, "")
            XCTAssertNotEqual(item.author, "")

            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1.0)
    }

    func testfetchMostViewedProjectsFailsWithUnexpectedError() {
        let mockSession = URLSessionMock()
        let downloader = StoreProjectDownloader(session: mockSession)
        let expectation = XCTestExpectation(description: "Fetch Most Viewed Projects")

        downloader.fetchProjects(forType: .mostViewed, offset: 0) { _, error in
            guard let error = error else { XCTFail("no error returned"); return }
            XCTAssertEqual(error, .unexpectedError)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1.0)
    }

    func testfetchMostViewedProjectsFailsWithRequestError() {
        let dvrSession = Session(cassetteName: "StoreProjectDownloader.fetchMostViewedProjects.fail.request")
        let downloader = StoreProjectDownloader(session: dvrSession)
        let expectation = XCTestExpectation(description: "Fetch Most Viewed Projects")

        downloader.fetchProjects(forType: .mostViewed, offset: 0) { _, error in
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

    func testfetchMostViewedProjectsFailsWithParseError() {
        let dvrSession = Session(cassetteName: "StoreProjectDownloader.fetchMostViewedProjects.fail.parse")
        let downloader = StoreProjectDownloader(session: dvrSession)
        let expectation = XCTestExpectation(description: "Fetch Most Viewed Projects")

        downloader.fetchProjects(forType: .mostViewed, offset: 0) { _, error in
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

    // MARK: - Most Recent Projects

    func testfetchMostRecentProjectsSucceeds() {
        let dvrSession = Session(cassetteName: "StoreProjectDownloader.fetchMostRecentProjects.success")
        let downloader = StoreProjectDownloader(session: dvrSession)
        let expectation = XCTestExpectation(description: "Fetch Most Recent Projects")

        downloader.fetchProjects(forType: .mostRecent, offset: 0) { projects, error in
            XCTAssertNil(error, "request failed")
            guard let projects = projects else { XCTFail("no most recent projects found"); return }
            guard let item = projects.projects.first else { XCTFail("no most recent projects in array"); return }

            // check that the first item in the first category has no empty properties (except cachedData)
            XCTAssertNotEqual(item.projectId, 0)
            XCTAssertNotEqual(item.projectName, "")
            XCTAssertNotEqual(item.author, "")

            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1.0)
    }

    func testfetchMostRecentProjectsFailsWithUnexpectedError() {
        let mockSession = URLSessionMock()
        let downloader = StoreProjectDownloader(session: mockSession)
        let expectation = XCTestExpectation(description: "Fetch Most Recent Projects")

        downloader.fetchProjects(forType: .mostRecent, offset: 0) { _, error in
            guard let error = error else { XCTFail("no error returned"); return }
            XCTAssertEqual(error, .unexpectedError)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1.0)
    }

    func testfetchMostRecentProjectsFailsWithRequestError() {
        let dvrSession = Session(cassetteName: "StoreProjectDownloader.fetchMostRecentProjects.fail.request")
        let downloader = StoreProjectDownloader(session: dvrSession)
        let expectation = XCTestExpectation(description: "Fetch Most Recent Projects")

        downloader.fetchProjects(forType: .mostRecent, offset: 0) { _, error in
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

    func testfetchMostRecentProjectsFailsWithParseError() {
        let dvrSession = Session(cassetteName: "StoreProjectDownloader.fetchMostRecentProjects.fail.parse")
        let downloader = StoreProjectDownloader(session: dvrSession)
        let expectation = XCTestExpectation(description: "Fetch Most Recent Projects")

        downloader.fetchProjects(forType: .mostRecent, offset: 0) { _, error in
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

    // MARK: - Search Store

    func testSearchProjectsSucceeds() {
        let dvrSession = Session(cassetteName: "StoreProjectDownloader.searchProjects.success")
        let downloader = StoreProjectDownloader(session: dvrSession)
        let expectation = XCTestExpectation(description: "Fetch Search Projects")
        let searchTerm = "Galaxy"

        downloader.fetchSearchQuery(searchTerm: searchTerm) { projects, error in
            XCTAssertNil(error, "request failed")
            guard let projects = projects else { XCTFail("no projects found"); return }
            guard let item = projects.projects.first else { XCTFail("no projects in array"); return }

            // check that the first item in the first category has no empty properties (except cachedData)
            XCTAssertNotEqual(item.projectId, 0)
            XCTAssertNotEqual(item.projectName, "")
            XCTAssertNotEqual(item.author, "")

            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1.0)
    }

    func testfetchSearchProjectsFailsWithUnexpectedError() {
        let mockSession = URLSessionMock()
        let downloader = StoreProjectDownloader(session: mockSession)
        let expectation = XCTestExpectation(description: "Fetch Search Projects")
        let searchTerm = "Galaxy"

        downloader.fetchSearchQuery(searchTerm: searchTerm) { _, error in
            guard let error = error else { XCTFail("no error returned"); return }
            XCTAssertEqual(error, .unexpectedError)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1.0)
    }

    func testSearchProjectsFailsWithRequestError() {
        let dvrSession = Session(cassetteName: "StoreProjectDownloader.searchProjects.fail.request")
        let downloader = StoreProjectDownloader(session: dvrSession)
        let expectation = XCTestExpectation(description: "Fetch Search Projects")
        let searchTerm = "Galaxy"

        downloader.fetchSearchQuery(searchTerm: searchTerm) { _, error in
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

    func testSearchProjectsFailsWithParseError() {
        let dvrSession = Session(cassetteName: "StoreProjectDownloader.fetchSearchProjects.fail.parse")
        let downloader = StoreProjectDownloader(session: dvrSession)
        let expectation = XCTestExpectation(description: "Fetch Search Projects")
        let searchTerm = "Galaxy"

        downloader.fetchSearchQuery(searchTerm: searchTerm) { _, error in
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
        let dvrSession = Session(cassetteName: "StoreProjectDownloader.downloadData.success")
        let downloader = StoreProjectDownloader(session: dvrSession)

        let project = StoreProject(projectId: 821,
                                   projectName: "Whack A Mole",
                                   projectNameShort: "",
                                   author: "VesnaK",
                                   description: "",
                                   version: "",
                                   views: 0,
                                   downloads: 0,
                                   uploaded: 0,
                                   uploadedString: "",
                                   screenshotBig: "",
                                   screenshotSmall: "",
                                   projectUrl: "",
                                   downloadUrl: "",
                                   fileSize: 1.0,
                                   featuredImage: "")
        let expectation = XCTestExpectation(description: "Download Featured Project")

        downloader.downloadProject(for: project) { data, error in
            XCTAssertNil(error, "request failed")
            guard data != nil else { XCTFail("no data received"); return }
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1.0)
    }

    func testDownloadDataFailsWithUnexpectedError() {
        let mockSession = URLSessionMock()
        let downloader = StoreProjectDownloader(session: mockSession)
        let expectation = XCTestExpectation(description: "Fetch Featured Projects")
        let project = StoreProject(projectId: 821,
                                   projectName: "Whack A Mole",
                                   projectNameShort: "",
                                   author: "VesnaK",
                                   description: "",
                                   version: "",
                                   views: 0,
                                   downloads: 0,
                                   uploaded: 0,
                                   uploadedString: "",
                                   screenshotBig: "",
                                   screenshotSmall: "",
                                   projectUrl: "",
                                   downloadUrl: "",
                                   fileSize: 1.0,
                                   featuredImage: "")

        downloader.downloadProject(for: project) { _, error in
            guard let error = error else { XCTFail("no error returned"); return }
            XCTAssertEqual(error, .unexpectedError)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1.0)
    }

    func testDownloadDataFailsWithRequestError() {
        let dvrSession = Session(cassetteName: "StoreProjectDownloader.downloadData.fail.request")
        let downloader = StoreProjectDownloader(session: dvrSession)
        let expectation = XCTestExpectation(description: "Fetch Featured Projects")
        let project = StoreProject(projectId: 821,
                                   projectName: "Whack A Mole",
                                   projectNameShort: "",
                                   author: "VesnaK",
                                   description: "",
                                   version: "",
                                   views: 0,
                                   downloads: 0,
                                   uploaded: 0,
                                   uploadedString: "",
                                   screenshotBig: "",
                                   screenshotSmall: "",
                                   projectUrl: "",
                                   downloadUrl: "",
                                   fileSize: 1.0,
                                   featuredImage: "")

        downloader.downloadProject(for: project) { _, error in
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
extension StoreProjectDownloaderError: Equatable {
    public static func == (lhs: StoreProjectDownloaderError, rhs: StoreProjectDownloaderError) -> Bool {
        switch (lhs, rhs) {
        case (.request, .request), (.parse, .parse), (.unexpectedError, .unexpectedError):
            return true
        default:
            return false
        }
    }
}
