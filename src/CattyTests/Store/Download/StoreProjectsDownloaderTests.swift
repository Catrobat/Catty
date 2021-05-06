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
import Nimble
@testable import Pocket_Code
import XCTest

class StoreProjectsDownloaderTests: XCTestCase {

    let expectedParsingException = "The data couldn’t be read because it is missing."

    // MARK: - Fetch Projects

    func testfetchFeaturedProjectsSucceeds() {
        let dvrSession = Session(cassetteName: "StoreProjectDownloader.fetchFeaturedProjects.success")
        let downloader = StoreProjectDownloader(session: dvrSession)
        let expectation = XCTestExpectation(description: "Fetch Featured Projects")

        downloader.fetchFeaturedProjects(offset: 0) { projects, error in
            XCTAssertNil(error, "request failed")
            guard let projects = projects else { XCTFail("no featured projects found"); return }
            guard let item = projects.first else { XCTFail("no featured projects in array"); return }

            // check that the first item in the first category has no empty properties (except cachedData)
            XCTAssertNotEqual(item.id, "")
            XCTAssertNotEqual(item.name, "")
            XCTAssertNotEqual(item.author, "")

            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1.0)
    }

    func testfetchFeaturedProjectsSucceedsWithIntegerId() {
        let dvrSession = Session(cassetteName: "StoreProjectDownloader.fetchFeaturedProjects.IntegerId.success")
        let downloader = StoreProjectDownloader(session: dvrSession)
        let expectation = XCTestExpectation(description: "Fetch Featured Projects")

        downloader.fetchFeaturedProjects(offset: 0) { projects, error in
            XCTAssertNil(error, "request failed")
            guard let projects = projects else { XCTFail("no featured projects found"); return }
            guard let item = projects.first else { XCTFail("no featured projects in array"); return }

            XCTAssertNotEqual(item.id, "")
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1.0)
    }

    func testfetchFeaturedProjectsFailsWithUnexpectedError() {
        let mockSession = URLSessionMock()
        let downloader = StoreProjectDownloader(session: mockSession)
        let expectation = XCTestExpectation(description: "Fetch Featured Projects")

        downloader.fetchFeaturedProjects(offset: 0) { _, error in
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

        downloader.fetchFeaturedProjects(offset: 0) { _, error in
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

        downloader.fetchFeaturedProjects(offset: 0) { _, error in
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

    func testfetchFeaturedProjectsFailsWithUnexpectedErrorNotification() {
        let session = URLSessionMock()
        let offset = 0
        let url = URL(string: "\(NetworkDefines.apiEndpointProjects)/\(NetworkDefines.connectionFeatured)?\(NetworkDefines.maxVersion)\(Util.catrobatLanguageVersion())&"
                        + "\(NetworkDefines.projectsLimit)\(NetworkDefines.recentProjectsMaxResults)&\(NetworkDefines.projectsOffset)"
                        + "\(offset)")!
        let error = ErrorMock("")
        let downloader = StoreProjectDownloader(session: session)
        let errorInfo = ProjectFetchFailureInfo(url: url.absoluteString, description: error.localizedDescription)

        expect(downloader.fetchFeaturedProjects(offset: 0) { _, _ in }).toEventually(postNotifications(contain(.projectFetchFailure, expectedObject: errorInfo)))
    }

    func testfetchFeaturedProjectsFailsWithRequestErrorNotification() {
        let dvrSession = Session(cassetteName: "StoreProjectDownloader.fetchFeaturedProjects.fail.request")
        let downloader = StoreProjectDownloader(session: dvrSession)
        let offset = 0
        let url = URL(string: "\(NetworkDefines.apiEndpointProjects)/\(NetworkDefines.connectionFeatured)?\(NetworkDefines.maxVersion)\(Util.catrobatLanguageVersion())&"
                        + "\(NetworkDefines.projectsLimit)\(NetworkDefines.recentProjectsMaxResults)&\(NetworkDefines.projectsOffset)"
                        + "\(offset)")!
        let error = ErrorMock("")
        let errorInfo = ProjectFetchFailureInfo(url: url.absoluteString, statusCode: 404, description: error.localizedDescription)

        expect(downloader.fetchFeaturedProjects(offset: 0) { _, _ in }).toEventually(postNotifications(contain(.projectFetchFailure, expectedObject: errorInfo)))
    }

    func testfetchFeaturedProjectsFailsWithParseErrorNotification() {
        let dvrSession = Session(cassetteName: "StoreProjectDownloader.fetchFeaturedProjects.fail.parse")
        let downloader = StoreProjectDownloader(session: dvrSession)
        let offset = 0
        let url = URL(string: "\(NetworkDefines.apiEndpointProjects)/\(NetworkDefines.connectionFeatured)?\(NetworkDefines.maxVersion)\(Util.catrobatLanguageVersion())&"
                        + "\(NetworkDefines.projectsLimit)\(NetworkDefines.recentProjectsMaxResults)&\(NetworkDefines.projectsOffset)"
                        + "\(offset)")!
        let errorInfo = ProjectFetchFailureInfo(url: url.absoluteString, statusCode: 200, description: expectedParsingException)

        expect(downloader.fetchFeaturedProjects(offset: 0) { _, error in
                guard let error = error else { XCTFail("no error received"); return }
                switch error {
                case .parse(error: _):
                    break
                default:
                    XCTFail("wrong error received")
                }
        }).toEventually(postNotifications(contain(.projectFetchFailure, expectedObject: errorInfo)))
    }

    func testfetchFeaturedProjectsFailsWithTimeoutErrorNotification() {
        let offset = 0
        let url = URL(string: "\(NetworkDefines.apiEndpointProjects)/\(NetworkDefines.connectionFeatured)?\(NetworkDefines.maxVersion)\(Util.catrobatLanguageVersion())&"
                        + "\(NetworkDefines.projectsLimit)\(NetworkDefines.recentProjectsMaxResults)&\(NetworkDefines.projectsOffset)"
                        + "\(offset)")!
        let response = HTTPURLResponse(url: url, statusCode: NSURLErrorTimedOut, httpVersion: nil, headerFields: nil)
        let error = NSError(domain: NSURLErrorDomain, code: NSURLErrorTimedOut, userInfo: nil)
        let session = URLSessionMock(response: response, error: error)
        let downloader = StoreProjectDownloader(session: session)

        let errorInfo = ProjectFetchFailureInfo(url: url.absoluteString, description: error.localizedDescription)

        expect(downloader.fetchFeaturedProjects(offset: 0) { _, _ in }).toEventually(postNotifications(contain(.projectFetchFailure, expectedObject: errorInfo)))
    }

    // MARK: - Most Downloaded Projects

    func testfetchMostDownloadedProjectsSucceeds() {
        let dvrSession = Session(cassetteName: "StoreProjectDownloader.fetchMostDownloadedProjects.success")
        let downloader = StoreProjectDownloader(session: dvrSession)
        let expectation = XCTestExpectation(description: "Fetch Most Downloaded Projects")

        downloader.fetchProjects(for: .mostDownloaded, offset: 0) { projects, error in
            XCTAssertNil(error, "request failed")
            guard let projects = projects else { XCTFail("no most downloaded projects found"); return }
            guard let item = projects.first else { XCTFail("no most downloaded projects in array"); return }

            // check that the first item in the first category has no empty properties (except cachedData)
            XCTAssertNotEqual(item.projectId, "")
            XCTAssertNotEqual(item.projectName, "")
            XCTAssertNotEqual(item.author, "")

            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1.0)
    }

    func testfetchMostDownloadedProjectsSucceedsWithIntegerId() {
        let dvrSession = Session(cassetteName: "StoreProjectDownloader.fetchMostDownloadedProjects.IntegerId.success")
        let downloader = StoreProjectDownloader(session: dvrSession)
        let expectation = XCTestExpectation(description: "Fetch Most Downloaded Projects")

        downloader.fetchProjects(for: .mostDownloaded, offset: 0) { projects, error in
            XCTAssertNil(error, "request failed")
            guard let projects = projects else { XCTFail("no most downloaded projects found"); return }
            guard let item = projects.first else { XCTFail("no most downloaded projects in array"); return }

            XCTAssertNotEqual(item.projectId, "")
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1.0)
    }

    func testfetchMostDownloadedProjectsFailsWithUnexpectedError() {
        let mockSession = URLSessionMock()
        let downloader = StoreProjectDownloader(session: mockSession)
        let expectation = XCTestExpectation(description: "Fetch Most Downloaded Projects")

        downloader.fetchProjects(for: .mostDownloaded, offset: 0) { _, error in
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

        downloader.fetchProjects(for: .mostDownloaded, offset: 0) { _, error in
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

        downloader.fetchProjects(for: .mostDownloaded, offset: 0) { _, error in
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

    func testfetchMostDownloadedProjectsFailsWithUnexpectedErrorNotification() {
        let session = URLSessionMock()
        let version: String = Util.catrobatLanguageVersion()
        let offset: Int = 0
        let url = URL(string: "\(NetworkDefines.apiEndpointProjects)?category=\(ProjectType.mostDownloaded.apiCategory())&\(NetworkDefines.maxVersion)\(version)&" +
                        "\(NetworkDefines.projectsLimit)\(NetworkDefines.recentProjectsMaxResults)&\(NetworkDefines.projectsOffset)"
                        + "\(offset)")!
        let error = ErrorMock("")
        let downloader = StoreProjectDownloader(session: session)
        let errorInfo = ProjectFetchFailureInfo(type: ProjectType.mostDownloaded, url: url.absoluteString, description: error.localizedDescription)

        expect(downloader.fetchProjects(for: .mostDownloaded, offset: 0) { _, _ in }).toEventually(postNotifications(contain(.projectFetchFailure, expectedObject: errorInfo)))
    }

    func testfetchMostDownloadedProjectsFailsWithRequestErrorNotification() {
        let dvrSession = Session(cassetteName: "StoreProjectDownloader.fetchMostDownloadedProjects.fail.request")
        let downloader = StoreProjectDownloader(session: dvrSession)
        let version: String = Util.catrobatLanguageVersion()
        let offset: Int = 0
        let url = URL(string: "\(NetworkDefines.apiEndpointProjects)?category=\(ProjectType.mostDownloaded.apiCategory())&\(NetworkDefines.maxVersion)\(version)&" +
                        "\(NetworkDefines.projectsLimit)\(NetworkDefines.recentProjectsMaxResults)&\(NetworkDefines.projectsOffset)"
                        + "\(offset)")!
        let error = ErrorMock("")
        let errorInfo = ProjectFetchFailureInfo(type: ProjectType.mostDownloaded, url: url.absoluteString, statusCode: 404, description: error.localizedDescription)

        expect(downloader.fetchProjects(for: .mostDownloaded, offset: 0) { _, _ in }).toEventually(postNotifications(contain(.projectFetchFailure, expectedObject: errorInfo)))
    }

    func testfetchMostDownloadedProjectsFailsWithParseErrorNotification() {
        let dvrSession = Session(cassetteName: "StoreProjectDownloader.fetchMostDownloadedProjects.fail.parse")
        let downloader = StoreProjectDownloader(session: dvrSession)
        let version: String = Util.catrobatLanguageVersion()
        let offset: Int = 0
        let url = URL(string: "\(NetworkDefines.apiEndpointProjects)?category=\(ProjectType.mostDownloaded.apiCategory())&\(NetworkDefines.maxVersion)\(version)&" +
                        "\(NetworkDefines.projectsLimit)\(NetworkDefines.recentProjectsMaxResults)&\(NetworkDefines.projectsOffset)"
                        + "\(offset)")!

        let errorInfo = ProjectFetchFailureInfo(type: ProjectType.mostDownloaded, url: url.absoluteString, statusCode: 200, description: expectedParsingException)

        expect(downloader.fetchProjects(for: .mostDownloaded, offset: 0) { _, error in
            guard let error = error else { XCTFail("no error received"); return }
            switch error {
            case .parse(error: _):
                break
            default:
                XCTFail("wrong error received")
            }
        }).toEventually(postNotifications(contain(.projectFetchFailure, expectedObject: errorInfo)))
    }

    func testfetchMostDownloadedProjectsFailsWithTimeoutErrorNotification() {
        let version: String = Util.catrobatLanguageVersion()
        let offset: Int = 0
        let url = URL(string: "\(NetworkDefines.apiEndpointProjects)?category=\(ProjectType.mostDownloaded.apiCategory())&\(NetworkDefines.maxVersion)\(version)&" +
                        "\(NetworkDefines.projectsLimit)\(NetworkDefines.recentProjectsMaxResults)&\(NetworkDefines.projectsOffset)"
                        + "\(offset)")!
        let response = HTTPURLResponse(url: url, statusCode: NSURLErrorTimedOut, httpVersion: nil, headerFields: nil)
        let error = NSError(domain: NSURLErrorDomain, code: NSURLErrorTimedOut, userInfo: nil)
        let session = URLSessionMock(response: response, error: error)
        let downloader = StoreProjectDownloader(session: session)
        let errorInfo = ProjectFetchFailureInfo(type: ProjectType.mostDownloaded, url: url.absoluteString, description: error.localizedDescription)

        expect(downloader.fetchProjects(for: .mostDownloaded, offset: 0) { _, _ in }).toEventually(postNotifications(contain(.projectFetchFailure, expectedObject: errorInfo)))
    }

    // MARK: - Most Viewed Projects

    func testfetchMostViewedProjectsSucceeds() {
        let dvrSession = Session(cassetteName: "StoreProjectDownloader.fetchMostViewedProjects.success")
        let downloader = StoreProjectDownloader(session: dvrSession)
        let expectation = XCTestExpectation(description: "Fetch Most Viewed Projects")

        downloader.fetchProjects(for: .mostViewed, offset: 0) { projects, error in
            XCTAssertNil(error, "request failed")
            guard let projects = projects else { XCTFail("no most viewed projects found"); return }
            guard let item = projects.first else { XCTFail("no most viewed projects in array"); return }

            // check that the first item in the first category has no empty properties (except cachedData)
            XCTAssertNotEqual(item.projectId, "")
            XCTAssertNotEqual(item.projectName, "")
            XCTAssertNotEqual(item.author, "")

            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1.0)
    }

    func testfetchMostViewedProjectsSucceedsWithIntegerId() {
        let dvrSession = Session(cassetteName: "StoreProjectDownloader.fetchMostViewedProjects.IntegerId.success")
        let downloader = StoreProjectDownloader(session: dvrSession)
        let expectation = XCTestExpectation(description: "Fetch Most Viewed Projects")

        downloader.fetchProjects(for: .mostViewed, offset: 0) { projects, error in
            XCTAssertNil(error, "request failed")
            guard let projects = projects else { XCTFail("no most viewed projects found"); return }
            guard let item = projects.first else { XCTFail("no most viewed projects in array"); return }

            XCTAssertNotEqual(item.projectId, "")
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1.0)
    }

    func testfetchMostViewedProjectsFailsWithUnexpectedError() {
        let mockSession = URLSessionMock()
        let downloader = StoreProjectDownloader(session: mockSession)
        let expectation = XCTestExpectation(description: "Fetch Most Viewed Projects")

        downloader.fetchProjects(for: .mostViewed, offset: 0) { _, error in
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

        downloader.fetchProjects(for: .mostViewed, offset: 0) { _, error in
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

        downloader.fetchProjects(for: .mostViewed, offset: 0) { _, error in
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

    func testfetchMostViewedProjectsFailsWithUnexpectedErrorNotification() {
        let session = URLSessionMock()
        let version: String = Util.catrobatLanguageVersion()
        let offset: Int = 0
        let url = URL(string: "\(NetworkDefines.apiEndpointProjects)?category=\(ProjectType.mostViewed.apiCategory())&\(NetworkDefines.maxVersion)\(version)&" +
                        "\(NetworkDefines.projectsLimit)\(NetworkDefines.recentProjectsMaxResults)&\(NetworkDefines.projectsOffset)"
                        + "\(offset)")!
        let error = ErrorMock("")
        let downloader = StoreProjectDownloader(session: session)
        let errorInfo = ProjectFetchFailureInfo(type: ProjectType.mostViewed, url: url.absoluteString, description: error.localizedDescription)

        expect(downloader.fetchProjects(for: .mostViewed, offset: 0) { _, _ in }).toEventually(postNotifications(contain(.projectFetchFailure, expectedObject: errorInfo)))
    }

    func testfetchMostViewedProjectsFailsWithRequestErrorNotification() {
        let dvrSession = Session(cassetteName: "StoreProjectDownloader.fetchMostViewedProjects.fail.request")
        let downloader = StoreProjectDownloader(session: dvrSession)
        let version: String = Util.catrobatLanguageVersion()
        let offset: Int = 0
        let url = URL(string: "\(NetworkDefines.apiEndpointProjects)?category=\(ProjectType.mostViewed.apiCategory())&\(NetworkDefines.maxVersion)\(version)&" +
                        "\(NetworkDefines.projectsLimit)\(NetworkDefines.recentProjectsMaxResults)&\(NetworkDefines.projectsOffset)"
                        + "\(offset)")!
        let error = ErrorMock("")
        let errorInfo = ProjectFetchFailureInfo(type: ProjectType.mostViewed, url: url.absoluteString, statusCode: 404, description: error.localizedDescription)

        expect(downloader.fetchProjects(for: .mostViewed, offset: 0) { _, _ in }).toEventually(postNotifications(contain(.projectFetchFailure, expectedObject: errorInfo)))
    }

    func testfetchMostViewedProjectsFailsWithParseErrorNotification() {
        let dvrSession = Session(cassetteName: "StoreProjectDownloader.fetchMostViewedProjects.fail.parse")
        let downloader = StoreProjectDownloader(session: dvrSession)
        let version: String = Util.catrobatLanguageVersion()
        let offset: Int = 0
        let url = URL(string: "\(NetworkDefines.apiEndpointProjects)?category=\(ProjectType.mostViewed.apiCategory())&\(NetworkDefines.maxVersion)\(version)&" +
                        "\(NetworkDefines.projectsLimit)\(NetworkDefines.recentProjectsMaxResults)&\(NetworkDefines.projectsOffset)"
                        + "\(offset)")!

        let errorInfo = ProjectFetchFailureInfo(type: ProjectType.mostViewed, url: url.absoluteString, statusCode: 200, description: expectedParsingException)

        expect(downloader.fetchProjects(for: .mostViewed, offset: 0) { _, error in
            guard let error = error else { XCTFail("no error received"); return }
            switch error {
            case .parse(error: _):
                break
            default:
                XCTFail("wrong error received")
            }
        }).toEventually(postNotifications(contain(.projectFetchFailure, expectedObject: errorInfo)))
    }

    func testfetchMostViewedProjectsFailsWithTimeoutErrorNotification() {
        let version: String = Util.catrobatLanguageVersion()
        let offset: Int = 0
        let url = URL(string: "\(NetworkDefines.apiEndpointProjects)?category=\(ProjectType.mostViewed.apiCategory())&\(NetworkDefines.maxVersion)\(version)&" +
                        "\(NetworkDefines.projectsLimit)\(NetworkDefines.recentProjectsMaxResults)&\(NetworkDefines.projectsOffset)"
                        + "\(offset)")!
        let response = HTTPURLResponse(url: url, statusCode: NSURLErrorTimedOut, httpVersion: nil, headerFields: nil)
        let error = NSError(domain: NSURLErrorDomain, code: NSURLErrorTimedOut, userInfo: nil)
        let session = URLSessionMock(response: response, error: error)
        let downloader = StoreProjectDownloader(session: session)
        let errorInfo = ProjectFetchFailureInfo(type: ProjectType.mostViewed, url: url.absoluteString, description: error.localizedDescription)

        expect(downloader.fetchProjects(for: .mostViewed, offset: 0) { _, _ in }).toEventually(postNotifications(contain(.projectFetchFailure, expectedObject: errorInfo)))
    }

    // MARK: - Most Recent Projects

    func testfetchMostRecentProjectsSucceeds() {
        let dvrSession = Session(cassetteName: "StoreProjectDownloader.fetchMostRecentProjects.success")
        let downloader = StoreProjectDownloader(session: dvrSession)
        let expectation = XCTestExpectation(description: "Fetch Most Recent Projects")

        downloader.fetchProjects(for: .mostRecent, offset: 0) { projects, error in
            XCTAssertNil(error, "request failed")
            guard let projects = projects else { XCTFail("no most recent projects found"); return }
            guard let item = projects.first else { XCTFail("no most recent projects in array"); return }

            // check that the first item in the first category has no empty properties (except cachedData)
            XCTAssertNotEqual(item.projectId, "")
            XCTAssertNotEqual(item.projectName, "")
            XCTAssertNotEqual(item.author, "")

            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1.0)
    }

    func testfetchMostRecentProjectsSucceedsWithIntegerId() {
        let dvrSession = Session(cassetteName: "StoreProjectDownloader.fetchMostRecentProjects.IntegerId.success")
        let downloader = StoreProjectDownloader(session: dvrSession)
        let expectation = XCTestExpectation(description: "Fetch Most Recent Projects")

        downloader.fetchProjects(for: .mostRecent, offset: 0) { projects, error in
            XCTAssertNil(error, "request failed")
            guard let projects = projects else { XCTFail("no most recent projects found"); return }
            guard let item = projects.first else { XCTFail("no most recent projects in array"); return }

            XCTAssertNotEqual(item.projectId, "")
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1.0)
    }

    func testfetchMostRecentProjectsFailsWithUnexpectedError() {
        let mockSession = URLSessionMock()
        let downloader = StoreProjectDownloader(session: mockSession)
        let expectation = XCTestExpectation(description: "Fetch Most Recent Projects")

        downloader.fetchProjects(for: .mostRecent, offset: 0) { _, error in
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

        downloader.fetchProjects(for: .mostRecent, offset: 0) { _, error in
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

        downloader.fetchProjects(for: .mostRecent, offset: 0) { _, error in
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

    func testfetchMostRecentProjectsFailsWithUnexpectedErrorNotification() {
        let session = URLSessionMock()
        let version: String = Util.catrobatLanguageVersion()
        let offset: Int = 0
        let url = URL(string: "\(NetworkDefines.apiEndpointProjects)?category=\(ProjectType.mostRecent.apiCategory())&\(NetworkDefines.maxVersion)\(version)&" +
                        "\(NetworkDefines.projectsLimit)\(NetworkDefines.recentProjectsMaxResults)&\(NetworkDefines.projectsOffset)"
                        + "\(offset)")!
        let error = ErrorMock("")
        let downloader = StoreProjectDownloader(session: session)
        let errorInfo = ProjectFetchFailureInfo(type: ProjectType.mostRecent, url: url.absoluteString, description: error.localizedDescription)

        expect(downloader.fetchProjects(for: .mostRecent, offset: 0) { _, _ in }).toEventually(postNotifications(contain(.projectFetchFailure, expectedObject: errorInfo)))
    }

    func testfetchMostRecentProjectsFailsWithRequestErrorNotification() {
        let dvrSession = Session(cassetteName: "StoreProjectDownloader.fetchMostRecentProjects.fail.request")
        let downloader = StoreProjectDownloader(session: dvrSession)
        let version: String = Util.catrobatLanguageVersion()
        let offset: Int = 0
        let url = URL(string: "\(NetworkDefines.apiEndpointProjects)?category=\(ProjectType.mostRecent.apiCategory())&\(NetworkDefines.maxVersion)\(version)&" +
                        "\(NetworkDefines.projectsLimit)\(NetworkDefines.recentProjectsMaxResults)&\(NetworkDefines.projectsOffset)"
                        + "\(offset)")!
        let error = ErrorMock("")
        let errorInfo = ProjectFetchFailureInfo(type: ProjectType.mostRecent, url: url.absoluteString, statusCode: 404, description: error.localizedDescription)

        expect(downloader.fetchProjects(for: .mostRecent, offset: 0) { _, _ in }).toEventually(postNotifications(contain(.projectFetchFailure, expectedObject: errorInfo)))
    }

    func testfetchMostRecentProjectsFailsWithParseErrorNotification() {
        let dvrSession = Session(cassetteName: "StoreProjectDownloader.fetchMostRecentProjects.fail.parse")
        let downloader = StoreProjectDownloader(session: dvrSession)
        let version: String = Util.catrobatLanguageVersion()
        let offset: Int = 0
        let url = URL(string: "\(NetworkDefines.apiEndpointProjects)?category=\(ProjectType.mostRecent.apiCategory())&\(NetworkDefines.maxVersion)\(version)&" +
                        "\(NetworkDefines.projectsLimit)\(NetworkDefines.recentProjectsMaxResults)&\(NetworkDefines.projectsOffset)"
                        + "\(offset)")!

        let errorInfo = ProjectFetchFailureInfo(type: ProjectType.mostRecent, url: url.absoluteString, statusCode: 200, description: expectedParsingException)

        expect(downloader.fetchProjects(for: .mostRecent, offset: 0) { _, error in
            guard let error = error else { XCTFail("no error received"); return }
            switch error {
            case .parse(error: _):
                break
            default:
                XCTFail("wrong error received")
            }
        }).toEventually(postNotifications(contain(.projectFetchFailure, expectedObject: errorInfo)))
    }

    func testfetchMostRecentProjectsFailsWithTimeoutErrorNotification() {
        let version: String = Util.catrobatLanguageVersion()
        let offset: Int = 0
        let url = URL(string: "\(NetworkDefines.apiEndpointProjects)?category=\(ProjectType.mostRecent.apiCategory())&\(NetworkDefines.maxVersion)\(version)&" +
                        "\(NetworkDefines.projectsLimit)\(NetworkDefines.recentProjectsMaxResults)&\(NetworkDefines.projectsOffset)"
                        + "\(offset)")!
        let response = HTTPURLResponse(url: url, statusCode: NSURLErrorTimedOut, httpVersion: nil, headerFields: nil)
        let error = NSError(domain: NSURLErrorDomain, code: NSURLErrorTimedOut, userInfo: nil)
        let session = URLSessionMock(response: response, error: error)
        let downloader = StoreProjectDownloader(session: session)
        let errorInfo = ProjectFetchFailureInfo(type: ProjectType.mostRecent, url: url.absoluteString, description: error.localizedDescription)

        expect(downloader.fetchProjects(for: .mostRecent, offset: 0) { _, _ in }).toEventually(postNotifications(contain(.projectFetchFailure, expectedObject: errorInfo)))
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
            guard let item = projects.first else { XCTFail("no projects in array"); return }

            // check that the first item in the first category has no empty properties (except cachedData)
            XCTAssertNotEqual(item.projectId, "")
            XCTAssertNotEqual(item.projectName, "")
            XCTAssertNotEqual(item.author, "")

            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1.0)
    }

    func testSearchProjectsSucceedsWithIntegerId() {
        let dvrSession = Session(cassetteName: "StoreProjectDownloader.searchProjects.IntegerId.success")
        let downloader = StoreProjectDownloader(session: dvrSession)
        let expectation = XCTestExpectation(description: "Fetch Search Projects")
        let searchTerm = "Galaxy"

        downloader.fetchSearchQuery(searchTerm: searchTerm) { projects, error in
            XCTAssertNil(error, "request failed")
            guard let projects = projects else { XCTFail("no projects found"); return }
            guard let item = projects.first else { XCTFail("no projects in array"); return }

            XCTAssertNotEqual(item.projectId, "")
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

    func testSearchProjectsNotFoundNotification() {
        let searchTerm = "Galaxy"
        let version: String = Util.catrobatLanguageVersion()

        let url = URL(string: "\(NetworkDefines.apiEndpointProjects)/\(NetworkDefines.connectionSearch)?query=" +
                            "\(searchTerm)&\(NetworkDefines.maxVersion)\(version)&\(NetworkDefines.projectsLimit)" +
                            "\(NetworkDefines.recentProjectsMaxResults)&\(NetworkDefines.projectsOffset)0")
        let response = HTTPURLResponse(url: url!, statusCode: 404, httpVersion: nil, headerFields: nil)
        let error = ErrorMock("errorDescription")
        let session = URLSessionMock(response: response, error: error)
        let downloader = StoreProjectDownloader(session: session)

        let projectErrorInfo = ProjectFetchFailureInfo(url: url?.absoluteString ?? "", statusCode: 404, description: error.localizedDescription, projectName: searchTerm)

        expect(downloader.fetchSearchQuery(searchTerm: searchTerm, completion: { _, _ in
        })).toEventually(postNotifications(contain(.projectSearchFailure, expectedObject: projectErrorInfo)))
    }

    // MARK: - Fetch Project Details

    func testFetchProjectDetailsSucceeds() {
        let dvrSession = Session(cassetteName: "StoreProjectDownloader.fetchProjectDetails.success")
        let downloader = StoreProjectDownloader(session: dvrSession)
        let projectId = "821"
        let expectation = XCTestExpectation(description: "Download Featured Project")

        downloader.fetchProjectDetails(for: projectId) { data, error in
            XCTAssertNil(error, "request failed")
            guard data != nil else { XCTFail("no data received"); return }
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1.0)
    }

    func testFetchProjectDetailsSucceedsWithIntegerId() {
        let dvrSession = Session(cassetteName: "StoreProjectDownloader.fetchProjectDetails.IntegerId.success")
        let downloader = StoreProjectDownloader(session: dvrSession)
        let projectId = "821"
        let expectation = XCTestExpectation(description: "Download Featured Project")

        downloader.fetchProjectDetails(for: projectId) { data, error in
            XCTAssertNil(error, "request failed")
            guard data != nil else { XCTFail("no data received"); return }
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1.0)
    }

    func testFetchProjectDetailsFailsWithUnexpectedError() {
        let mockSession = URLSessionMock()
        let downloader = StoreProjectDownloader(session: mockSession)
        let expectation = XCTestExpectation(description: "Fetch Featured Projects")
        let projectId = "821"

        downloader.fetchProjectDetails(for: projectId) { _, error in
            guard let error = error else { XCTFail("no error returned"); return }
            XCTAssertEqual(error, .unexpectedError)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1.0)
    }

    func testFetchProjectDetailsFailsWithRequestError() {
        let dvrSession = Session(cassetteName: "StoreProjectDownloader.fetchProjectDetails.fail.request")
        let downloader = StoreProjectDownloader(session: dvrSession)
        let expectation = XCTestExpectation(description: "Fetch Featured Projects")
        let projectId = "821"

        downloader.fetchProjectDetails(for: projectId) { _, error in
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

    func testFetchProjectDetailsNotFoundNotification() {
        let projectId = "821"
        let url = URL(string: "\(NetworkDefines.apiEndpointProjectDetails)/\(projectId)")!
        let response = HTTPURLResponse(url: url, statusCode: 404, httpVersion: nil, headerFields: nil)
        let error = ErrorMock("errorDescription")
        let session = URLSessionMock(response: response, error: error)
        let downloader = StoreProjectDownloader(session: session)
        let userInfo = ["projectId": projectId,
                        "url": url.absoluteString,
                        "statusCode": 404,
                        "error": error.localizedDescription] as [String: Any]

        let expectedNotification = Notification(name: .projectFetchDetailsFailure, object: downloader, userInfo: userInfo)

        expect(downloader.fetchProjectDetails(for: projectId) { _, _ in }).toEventually(postNotifications(contain(expectedNotification)))
    }

    // MARK: - Download project
    func testDownloadProjectSucceeds() {
           let dvrSession = Session(cassetteName: "StoreProjectDownloader.downloadProject.success")
           let downloader = StoreProjectDownloader(session: dvrSession)
           let projectId = "00fbfbe1-6f87-11ea-959c-000c293d4b76"
           let expectation = XCTestExpectation(description: "Download Project")

        downloader.download(projectId: projectId,
                            completion: { data, error in
            XCTAssertNil(error, "request failed")
            guard data != nil else { XCTFail("no data received"); return }
            expectation.fulfill()
        }, progression: nil)

            wait(for: [expectation], timeout: 1)
    }

    func testDownloadProjectFailsWithUnexpectedError() {
        let mockSession = URLSessionMock()
        let downloader = StoreProjectDownloader(session: mockSession)
        let expectation = XCTestExpectation(description: "Download Projects")
        let projectId = ""

        downloader.download(projectId: projectId,
                            completion: {_, error in
            guard let error = error else { XCTFail("no error returned"); return }
            XCTAssertEqual(error, .unexpectedError)
            expectation.fulfill()
        }, progression: nil)

        wait(for: [expectation], timeout: 1)
    }

    func testDownloadProjectFailsWithRequestError() {
        let dvrSession = Session(cassetteName: "StoreProjectDownloader.downloadProject.fail.request")
        let downloader = StoreProjectDownloader(session: dvrSession)
        let expectation = XCTestExpectation(description: "Download Projects")
        let projectId = "00fbfbe1-6f87-11ea-959c-000c293d4b76"

        downloader.download(projectId: projectId,
                            completion: { _, error in
            guard let error = error else { XCTFail("no error received"); return }
            switch error {
            case let .request(error: _, statusCode: statusCode):
                XCTAssertEqual(statusCode, 404)
            default:
                XCTFail("wrong error received")
            }
            expectation.fulfill()
        }, progression: nil)
        wait(for: [expectation], timeout: 1)
    }

    func testDownloadProjectVaildProgression() {
        let mockSession = URLSessionMock(response: nil, error: nil, bytesReceived: 600, bytesTotal: 1200)
        let downloader = StoreProjectDownloader(session: mockSession)
        let expectation = XCTestExpectation(description: "Download Project Progression")
        let projectId = "00fbfbe1-6f87-11ea-959c-000c293d4b76"

        downloader.download(projectId: projectId,
                            completion: { _, _ in },
                            progression: { progress in
            XCTAssertEqual(0.5, progress)
            expectation.fulfill()
        })
        wait(for: [expectation], timeout: 1)
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
