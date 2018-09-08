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

class StoreProgramsDowloaderTests: XCTestCase {
    
    // MARK: - Fetch Programs
    
    func testfetchFeaturedProgramsSucceeds() {
        let dvrSession = Session(cassetteName: "StoreProgramDownloader.fetchFeaturedPrograms.success")
        let downloader = StoreProgramDownloader(session: dvrSession)
        let expectation = XCTestExpectation(description: "Fetch Featured Programs")

        downloader.fetchPrograms(forType: .featured, offset: 0) { programs, error in
            XCTAssertNil(error, "request failed")
            guard let programs = programs else { XCTFail("no featured programs found"); return }
            guard let item = programs.projects.first else { XCTFail("no featured programs in array"); return }

            // check that the first item in the first category has no empty properties (except cachedData)
            XCTAssertNotEqual(item.projectId, 0)
            XCTAssertNotEqual(item.projectName, "")
            XCTAssertNotEqual(item.author, "")

            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1.0)
    }
    
    func testfetchFeaturedProgramsFailsWithUnexpectedError() {
        let mockSession = URLSessionMock()
        let downloader = StoreProgramDownloader(session: mockSession)
        let expectation = XCTestExpectation(description: "Fetch Featured Programs")
        
        downloader.fetchPrograms(forType: .featured, offset: 0) { programs, error in
            guard let error = error else { XCTFail("no error returned"); return }
            XCTAssertEqual(error, .unexpectedError)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testfetchFeaturedProgramsFailsWithRequestError() {
        let dvrSession = Session(cassetteName: "StoreProgramDownloader.fetchFeaturedPrograms.fail.request")
        let downloader = StoreProgramDownloader(session: dvrSession)
        let expectation = XCTestExpectation(description: "Fetch Featured Programs")
        
        downloader.fetchPrograms(forType: .featured, offset: 0) { programs, error in
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
    
    func testfetchFeaturedProgramsFailsWithParseError() {
        let dvrSession = Session(cassetteName: "StoreProgramDownloader.fetchFeaturedPrograms.fail.parse")
        let downloader = StoreProgramDownloader(session: dvrSession)
        let expectation = XCTestExpectation(description: "Fetch Featured Programs")
        
        downloader.fetchPrograms(forType: .featured, offset: 0) { programs, error in
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

    // MARK: - Most Downloaded Programs
    
    func testfetchMostDownloadedProgramsSucceeds() {
        let dvrSession = Session(cassetteName: "StoreProgramDownloader.fetchMostDownloadedPrograms.success")
        let downloader = StoreProgramDownloader(session: dvrSession)
        let expectation = XCTestExpectation(description: "Fetch Most Downloaded Programs")
        
        downloader.fetchPrograms(forType: .mostDownloaded, offset: 0) { programs, error in
            XCTAssertNil(error, "request failed")
            guard let programs = programs else { XCTFail("no most downloaded programs found"); return }
            guard let item = programs.projects.first else { XCTFail("no most downloaded programs in array"); return }
            
            // check that the first item in the first category has no empty properties (except cachedData)
            XCTAssertNotEqual(item.projectId, 0)
            XCTAssertNotEqual(item.projectName, "")
            XCTAssertNotEqual(item.author, "")
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testfetchMostDownloadedProgramsFailsWithUnexpectedError() {
        let mockSession = URLSessionMock()
        let downloader = StoreProgramDownloader(session: mockSession)
        let expectation = XCTestExpectation(description: "Fetch Most Downloaded Programs")
        
        downloader.fetchPrograms(forType: .mostDownloaded, offset: 0) { programs, error in
            guard let error = error else { XCTFail("no error returned"); return }
            XCTAssertEqual(error, .unexpectedError)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }

    func testfetchMostDownloadedProgramsFailsWithRequestError() {
        let dvrSession = Session(cassetteName: "StoreProgramDownloader.fetchMostDownloadedPrograms.fail.request")
        let downloader = StoreProgramDownloader(session: dvrSession)
        let expectation = XCTestExpectation(description: "Fetch Most Downloaded Programs")
        
        downloader.fetchPrograms(forType: .mostDownloaded, offset: 0) { programs, error in
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
    
    func testfetchMostDownloadedProgramsFailsWithParseError() {
        let dvrSession = Session(cassetteName: "StoreProgramDownloader.fetchMostDownloadedPrograms.fail.parse")
        let downloader = StoreProgramDownloader(session: dvrSession)
        let expectation = XCTestExpectation(description: "Fetch Most Downloaded Programs")
        
        downloader.fetchPrograms(forType: .mostDownloaded, offset: 0) { programs, error in
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
    
    //MARK: - Most Viewed Programs
    
    func testfetchMostViewedProgramsSucceeds() {
        let dvrSession = Session(cassetteName: "StoreProgramDownloader.fetchMostViewedPrograms.success")
        let downloader = StoreProgramDownloader(session: dvrSession)
        let expectation = XCTestExpectation(description: "Fetch Most Viewed Programs")
        
        downloader.fetchPrograms(forType: .mostViewed, offset: 0) { programs, error in
            XCTAssertNil(error, "request failed")
            guard let programs = programs else { XCTFail("no most viewed programs found"); return }
            guard let item = programs.projects.first else { XCTFail("no most viewed programs in array"); return }
            
            // check that the first item in the first category has no empty properties (except cachedData)
            XCTAssertNotEqual(item.projectId, 0)
            XCTAssertNotEqual(item.projectName, "")
            XCTAssertNotEqual(item.author, "")
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testfetchMostViewedProgramsFailsWithUnexpectedError() {
        let mockSession = URLSessionMock()
        let downloader = StoreProgramDownloader(session: mockSession)
        let expectation = XCTestExpectation(description: "Fetch Most Viewed Programs")
        
        downloader.fetchPrograms(forType: .mostViewed, offset: 0) { programs, error in
            guard let error = error else { XCTFail("no error returned"); return }
            XCTAssertEqual(error, .unexpectedError)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testfetchMostViewedProgramsFailsWithRequestError() {
        let dvrSession = Session(cassetteName: "StoreProgramDownloader.fetchMostViewedPrograms.fail.request")
        let downloader = StoreProgramDownloader(session: dvrSession)
        let expectation = XCTestExpectation(description: "Fetch Most Viewed Programs")
        
        downloader.fetchPrograms(forType: .mostViewed, offset: 0) { programs, error in
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
    
    func testfetchMostViewedProgramsFailsWithParseError() {
        let dvrSession = Session(cassetteName: "StoreProgramDownloader.fetchMostViewedPrograms.fail.parse")
        let downloader = StoreProgramDownloader(session: dvrSession)
        let expectation = XCTestExpectation(description: "Fetch Most Viewed Programs")
        
        downloader.fetchPrograms(forType: .mostViewed, offset: 0) { programs, error in
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

    //MARK: - Most Recent Programs
    
    func testfetchMostRecentProgramsSucceeds() {
        let dvrSession = Session(cassetteName: "StoreProgramDownloader.fetchMostRecentPrograms.success")
        let downloader = StoreProgramDownloader(session: dvrSession)
        let expectation = XCTestExpectation(description: "Fetch Most Recent Programs")
        
        downloader.fetchPrograms(forType: .mostRecent, offset: 0) { programs, error in
            XCTAssertNil(error, "request failed")
            guard let programs = programs else { XCTFail("no most recent programs found"); return }
            guard let item = programs.projects.first else { XCTFail("no most recent programs in array"); return }
            
            // check that the first item in the first category has no empty properties (except cachedData)
            XCTAssertNotEqual(item.projectId, 0)
            XCTAssertNotEqual(item.projectName, "")
            XCTAssertNotEqual(item.author, "")
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testfetchMostRecentProgramsFailsWithUnexpectedError() {
        let mockSession = URLSessionMock()
        let downloader = StoreProgramDownloader(session: mockSession)
        let expectation = XCTestExpectation(description: "Fetch Most Recent Programs")
        
        downloader.fetchPrograms(forType: .mostRecent, offset: 0) { programs, error in
            guard let error = error else { XCTFail("no error returned"); return }
            XCTAssertEqual(error, .unexpectedError)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testfetchMostRecentProgramsFailsWithRequestError() {
        let dvrSession = Session(cassetteName: "StoreProgramDownloader.fetchMostRecentPrograms.fail.request")
        let downloader = StoreProgramDownloader(session: dvrSession)
        let expectation = XCTestExpectation(description: "Fetch Most Recent Programs")
        
        downloader.fetchPrograms(forType: .mostRecent, offset: 0) { programs, error in
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
    
    func testfetchMostRecentProgramsFailsWithParseError() {
        let dvrSession = Session(cassetteName: "StoreProgramDownloader.fetchMostRecentPrograms.fail.parse")
        let downloader = StoreProgramDownloader(session: dvrSession)
        let expectation = XCTestExpectation(description: "Fetch Most Recent Programs")
        
        downloader.fetchPrograms(forType: .mostRecent, offset: 0) { programs, error in
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
    
    //MARK: - Search Store
    
    func testSearchProgramsSucceeds() {
        let dvrSession = Session(cassetteName: "StoreProgramDownloader.searchPrograms.success")
        let downloader = StoreProgramDownloader(session: dvrSession)
        let expectation = XCTestExpectation(description: "Fetch Search Programs")
        let searchTerm = "Galaxy"
        
        downloader.fetchSearchQuery(searchTerm: searchTerm) { programs, error in
            XCTAssertNil(error, "request failed")
            guard let programs = programs else { XCTFail("no programs found"); return }
            guard let item = programs.projects.first else { XCTFail("no programs in array"); return }
            
            // check that the first item in the first category has no empty properties (except cachedData)
            XCTAssertNotEqual(item.projectId, 0)
            XCTAssertNotEqual(item.projectName, "")
            XCTAssertNotEqual(item.author, "")
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testfetchSearchProgramsFailsWithUnexpectedError() {
        let mockSession = URLSessionMock()
        let downloader = StoreProgramDownloader(session: mockSession)
        let expectation = XCTestExpectation(description: "Fetch Search Programs")
        let searchTerm = "Galaxy"
        
        downloader.fetchSearchQuery(searchTerm: searchTerm) { programs, error in
            guard let error = error else { XCTFail("no error returned"); return }
            XCTAssertEqual(error, .unexpectedError)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testSearchProgramsFailsWithRequestError() {
        let dvrSession = Session(cassetteName: "StoreProgramDownloader.searchPrograms.fail.request")
        let downloader = StoreProgramDownloader(session: dvrSession)
        let expectation = XCTestExpectation(description: "Fetch Search Programs")
        let searchTerm = "Galaxy"
        
        downloader.fetchSearchQuery(searchTerm: searchTerm) { programs, error in
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
    
    func testSearchProgramsFailsWithParseError() {
        let dvrSession = Session(cassetteName: "StoreProgramDownloader.fetchSearchPrograms.fail.parse")
        let downloader = StoreProgramDownloader(session: dvrSession)
        let expectation = XCTestExpectation(description: "Fetch Search Programs")
        let searchTerm = "Galaxy"
        
        downloader.fetchSearchQuery(searchTerm: searchTerm) { programs, error in
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
        let dvrSession = Session(cassetteName: "StoreProgramDownloader.downloadData.success")
        let downloader = StoreProgramDownloader(session: dvrSession)

        let program = StoreProgram(projectId: 821, projectName: "Whack A Mole", projectNameShort: "", author: "VesnaK", description: "", version: "", views: 0, downloads: 0, isPrivate: false, uploaded: 0, uploadedString: "", screenshotBig: "", screenshotSmall: "", projectUrl: "", downloadUrl: "", fileSize: 1.0, featuredImage: "")
        let expectation = XCTestExpectation(description: "Download Featured Program")

        downloader.downloadProgram(for: program){ data, error in
            XCTAssertNil(error, "request failed")
            guard data != nil else { XCTFail("no data received"); return }
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1.0)
    }
    
    func testDownloadDataFailsWithUnexpectedError() {
        let mockSession = URLSessionMock()
        let downloader = StoreProgramDownloader(session: mockSession)
        let expectation = XCTestExpectation(description: "Fetch Featured Programs")
        let program = StoreProgram(projectId: 821, projectName: "Whack A Mole", projectNameShort: "", author: "VesnaK", description: "", version: "", views: 0, downloads: 0, isPrivate: false, uploaded: 0, uploadedString: "", screenshotBig: "", screenshotSmall: "", projectUrl: "", downloadUrl: "", fileSize: 1.0, featuredImage: "")
        
        downloader.downloadProgram(for: program) { programs, error in
            guard let error = error else { XCTFail("no error returned"); return }
            XCTAssertEqual(error, .unexpectedError)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testDownloadDataFailsWithRequestError() {
        let dvrSession = Session(cassetteName: "StoreProgramDownloader.downloadData.fail.request")
        let downloader = StoreProgramDownloader(session: dvrSession)
        let expectation = XCTestExpectation(description: "Fetch Featured Programs")
        let program = StoreProgram(projectId: 821, projectName: "Whack A Mole", projectNameShort: "", author: "VesnaK", description: "", version: "", views: 0, downloads: 0, isPrivate: false, uploaded: 0, uploadedString: "", screenshotBig: "", screenshotSmall: "", projectUrl: "", downloadUrl: "", fileSize: 1.0, featuredImage: "")
        
        downloader.downloadProgram(for: program) { programs, error in
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
extension StoreProgramDownloaderError: Equatable {
    public static func ==(lhs: StoreProgramDownloaderError, rhs: StoreProgramDownloaderError) -> Bool {
        switch (lhs, rhs) {
        case (.request, .request), (.parse, .parse), (.unexpectedError, .unexpectedError):
            return true
        default:
            return false
        }
    }
}
