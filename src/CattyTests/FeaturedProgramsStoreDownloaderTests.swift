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

class FeaturedProgramsStoreViewControllerTests: XCTestCase {
    
    // MARK: - Fetch Featured Programs
    
    func testFetchFeaturedProgramsSucceeds() {
        let dvrSession = Session(cassetteName: "FeaturedProgramsStoreDownloader.fetchFeaturedPrograms.success")
        let downloader = FeaturedProgramsStoreDownloader(session: dvrSession)
        let expectation = XCTestExpectation(description: "Fetch Featured Programs")

        downloader.fetchKFeaturedPrograms() { programs, error in
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
    
    func testFetchFeaturedProgramsFailsWithUnexpectedError() {
        let mockSession = URLSessionMock()
        let downloader = FeaturedProgramsStoreDownloader(session: mockSession)
        let expectation = XCTestExpectation(description: "Fetch Featured Programs")
        
        downloader.fetchKFeaturedPrograms() { programs, error in
            guard let error = error else { XCTFail("no error returned"); return }
            XCTAssertEqual(error, .unexpectedError)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testFetchFeaturedProgramsFailsWithRequestError() {
        let dvrSession = Session(cassetteName: "FeaturedProgramsStoreDownloader.fetchFeaturedPrograms.fail.request")
        let downloader = FeaturedProgramsStoreDownloader(session: dvrSession)
        let expectation = XCTestExpectation(description: "Fetch Featured Programs")
        
        downloader.fetchKFeaturedPrograms() { programs, error in
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
    
    func testFetchFeaturedProgramsFailsWithParseError() {
        let dvrSession = Session(cassetteName: "FeaturedProgramsStoreDownloader.fetchFeaturedPrograms.fail.parse")
        let downloader = FeaturedProgramsStoreDownloader(session: dvrSession)
        let expectation = XCTestExpectation(description: "Fetch Featured Programs")
        
        downloader.fetchKFeaturedPrograms() { programs, error in
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
    
//    func testDownloadDataSucceeds() {
//        let dvrSession = Session(cassetteName: "FeaturedProgramsStoreDownloader.downloadData.success")
//        let downloader = FeaturedProgramsStoreDownloader(session: dvrSession)
//
//        let program = CBProgram(projectId: 821, projectName: "Whack A Mole", projectNameShort: "", author: "VesnaK", description: "", version: "", views: 0, downloads: 0, isPrivate: false, uploaded: 0, uploadedString: "", screenshotBig: "", screenshotSmall: "", projectUrl: "", downloadUrl: "", fileSize: 1.0, featuredImage: "")
//        let expectation = XCTestExpectation(description: "Download Featured Program")
//
//        downloader.downloadProgram(for: program){ data, error in
//            XCTAssertNil(error, "request failed")
//            guard let data = data, !data.isEmpty else { XCTFail("no data received"); return }
//            expectation.fulfill()
//        }
//
//        wait(for: [expectation], timeout: 1.0)
//    }

    func testDownloadDataFailsWithUnexpectedError() {
        let mockSession = URLSessionMock()
        let downloader = FeaturedProgramsStoreDownloader(session: mockSession)
        let program = CBProgram(projectId: 821, projectName: "Whack A Mole", projectNameShort: "", author: "VesnaK", description: "", version: "", views: 0, downloads: 0, isPrivate: false, uploaded: 0, uploadedString: "", screenshotBig: "", screenshotSmall: "", projectUrl: "", downloadUrl: "", fileSize: 1.0, featuredImage: "")
        let expectation = XCTestExpectation(description: "Download Featured Program")

        downloader.downloadProgram(for: program) { data, error in
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

//    func testDownloadDataFailsWithRequestError() {
//        let dvrSession = Session(cassetteName: "FeaturedProgramsStoreDownloader.downloadData.fail.request")
//        let downloader = FeaturedProgramsStoreDownloader(session: dvrSession)
//        let program = CBProgram(projectId: 821, projectName: "Whack A Mole", projectNameShort: "", author: "VesnaK", description: "", version: "", views: 0, downloads: 0, isPrivate: false, uploaded: 0, uploadedString: "", screenshotBig: "", screenshotSmall: "", projectUrl: "", downloadUrl: "", fileSize: 1.0, featuredImage: "")
//        let expectation = XCTestExpectation(description: "Download Featured Program")
//
//        downloader.downloadProgram(for: program) { data, error in
//            guard let error = error else { XCTFail("no error received"); return }
//            switch error {
//            case let .request(error: _, statusCode: statusCode):
//                XCTAssertEqual(statusCode, 404)
//            default:
//                XCTFail("wrong error received")
//            }
//            expectation.fulfill()
//        }
//
//        wait(for: [expectation], timeout: 1.0)
//    }
}

// Equatable conformance is added here in order to be able to compare a download operation's error code.
// Wrapped error values won't be compared.
extension FeaturedProgramsDownloadError: Equatable {
    public static func ==(lhs: FeaturedProgramsDownloadError, rhs: FeaturedProgramsDownloadError) -> Bool {
        switch (lhs, rhs) {
        case (.request, .request), (.parse, .parse), (.unexpectedError, .unexpectedError):
            return true
        default:
            return false
        }
    }
}
