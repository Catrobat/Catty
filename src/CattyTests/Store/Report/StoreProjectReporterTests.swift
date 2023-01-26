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
import Nimble
@testable import Pocket_Code
import XCTest

class StoreProjectsReporterTests: XCTestCase {

    var expectedZippedProjectData: Data!
    var fileManagerMock: CBFileManagerMock!
    var project: Project!

   override func setUp() {
       super.setUp()
       let header = Header.default()!
       header.programName = kDefaultProjectBundleName
       header.programDescription = ""

       self.project = Project()
       self.project.header = header

       Keychain.saveValue("validToken", forKey: NetworkDefines.kUserLoginToken)
       UserDefaults.standard.setValue("UserName", forKey: kcUsername)

       self.expectedZippedProjectData = "zippedProjectData".data(using: .utf8)
       self.fileManagerMock = CBFileManagerMock(zipData: expectedZippedProjectData)
   }

   override func tearDown() {
       UserDefaults.standard.removeObject(forKey: kcUsername)
       Keychain.deleteValue(forKey: NetworkDefines.kUserLoginToken)
       super.tearDown()
   }

    func testReportProjectSucess() {
        let projectId = "817"
        let message = "Not appropriate content"

        let dvrSession = Session(cassetteName: "StoreProjectReporter.reportProject.success")
        let reporter = StoreProjectReporter(session: dvrSession)
        let expectation = XCTestExpectation(description: "Report Project")

        reporter.report(projectId: projectId, message: message, completion: { error in
            XCTAssertNil(error)
            expectation.fulfill()
        })
        wait(for: [expectation], timeout: 1)
    }

    func testReportProjectInvalidPostData() {
        let projectId = "-1"
        let message = ""

        let dvrSession = Session(cassetteName: "StoreProjectReporter.reportProject.postDataIncorrect.fail")
        let reporter = StoreProjectReporter(session: dvrSession)
        let expectation = XCTestExpectation(description: "Report Project")

        reporter.report(projectId: projectId, message: message, completion: { error in
            XCTAssertNotNil(error)
            XCTAssertEqual(error, .request(error: error, statusCode: 400))
            expectation.fulfill()
        })
        wait(for: [expectation], timeout: 1)
    }

    func testReportProjectInvalidPostDataTooShortMessage() {
        let projectId = "817"
        let message = "i"

        let dvrSession = Session(cassetteName: "StoreProjectReporter.reportProject.postDataIncorrect.shortMessage.fail")
        let reporter = StoreProjectReporter(session: dvrSession)
        let expectation = XCTestExpectation(description: "Report Project")

        reporter.report(projectId: projectId, message: message, completion: { error in
            XCTAssertNotNil(error)
            XCTAssertEqual(error, .request(error: error, statusCode: 400))
            expectation.fulfill()
        })
        wait(for: [expectation], timeout: 1)
    }

    func testReportProjectInvalidPostDataTooLongMessage() {
        let projectId = "817"
        let message = "aaaaabbbbbcccccddddd aaaaabbbbbcccccddddd aaaaabbbbbcccccddddd aaaaabbbbbcccccddddd aaaaabbbbbcccccddddd aaaaabbbbbcccccddddd"

        let dvrSession = Session(cassetteName: "StoreProjectReporter.reportProject.postDataIncorrect.longMessage.fail")
        let reporter = StoreProjectReporter(session: dvrSession)
        let expectation = XCTestExpectation(description: "Report Project")

        reporter.report(projectId: projectId, message: message, completion: { error in
            XCTAssertNotNil(error)
            XCTAssertEqual(error, .request(error: error, statusCode: 400))
            expectation.fulfill()
        })
        wait(for: [expectation], timeout: 1)
    }

    func testReportProjectFailsWithUnexpectedError() {
        let projectId = "817"
        let message = "Not appropriate content"

        let dvrSession = Session(cassetteName: "StoreProjectReporter.reportProject.unexpectedError")
        let reporter = StoreProjectReporter(session: dvrSession)
        let expectation = XCTestExpectation(description: "Report Project")

        reporter.report(projectId: projectId, message: message, completion: { error in
            XCTAssertNotNil(error)
            XCTAssertEqual(error, .unexpectedError)
            expectation.fulfill()
        })
        wait(for: [expectation], timeout: 1)
    }

    func testUploadProjectFailsForAuthenticationError() {
        let projectId = "817"
        let message = "Not appropriate content"

        Keychain.deleteValue(forKey: NetworkDefines.kUserLoginToken)
        let dvrSession = Session(cassetteName: "StoreProjectReporter.reportProject.authentication.fail")
        let expectation = XCTestExpectation(description: "Report Projects")
        let reporter = StoreProjectReporter(session: dvrSession)

        reporter.report(projectId: projectId, message: message, completion: { error in
            XCTAssertNotNil(error)
            XCTAssertEqual(error, .authenticationFailed)
            expectation.fulfill()
        })
        wait(for: [expectation], timeout: 1)
    }
}

extension StoreProjectReporterError: Equatable {
    public static func == (lhs: StoreProjectReporterError, rhs: StoreProjectReporterError) -> Bool {
        switch (lhs, rhs) {
        case (.request, .request),
             (.unexpectedError, .unexpectedError),
             (.timeout, .timeout),
             (.authenticationFailed, .authenticationFailed):
            return true
        default:
            return false
        }
    }
}
