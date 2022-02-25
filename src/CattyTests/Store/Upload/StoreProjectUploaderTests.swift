/**
 *  Copyright (C) 2010-2022 The Catrobat Team
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

class StoreProjectUploaderTests: XCTestCase {

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

    func testUploadProjectSucess() {
        let dvrSession = Session(cassetteName: "StoreProjectUpload.uploadProject.success")
        let expectation = XCTestExpectation(description: "Upload Project")
        let uploader = StoreProjectUploader(fileManager: fileManagerMock, session: dvrSession)
        uploader.upload(project: self.project,
                        completion: { projectId, error  in
                            XCTAssertNotNil(projectId)
                            XCTAssertEqual("4942a248-b7e1-11ea-a7ff-005056a36f47", projectId)
                            XCTAssertNil(error)
                            expectation.fulfill()
        }, progression: nil)
        wait(for: [expectation], timeout: 1)
    }

    func testUploadProjectFailsWithUnexpectedError() {
        let mockSession = URLSessionMock()
        let uploader = StoreProjectUploader(fileManager: self.fileManagerMock, session: mockSession)
        let expectation = XCTestExpectation(description: "Upload Projects")

        uploader.upload(project: self.project,
                        completion: { projectId, error in
                            guard let error = error else { XCTFail("no error returned"); return }
                            XCTAssertNil(projectId)
                            XCTAssertEqual(error, .unexpectedError)
                            expectation.fulfill()
        }, progression: nil)

        wait(for: [expectation], timeout: 1)
    }

    func testUploadProjectFailsForAuthenticationError() {
        Keychain.deleteValue(forKey: NetworkDefines.kUserLoginToken)
        let dvrSession = Session(cassetteName: "StoreProjectDownloader.uploadProject.fail.authentication")
        let expectation = XCTestExpectation(description: "Upload Projects")
        let uploader = StoreProjectUploader(fileManager: fileManagerMock, session: dvrSession)

        uploader.upload(project: self.project,
                        completion: { projectId, error in
                            guard let error = error else { XCTFail("no error received"); return }
                            XCTAssertNil(projectId)
                            XCTAssertEqual(error, .authenticationFailed)
                            expectation.fulfill()
        }, progression: nil)

        wait(for: [expectation], timeout: 1)
    }

    func testUploadProjectFailsForInvalidToken() {
        let dvrSession = Session(cassetteName: "StoreProjectUpload.uploadProject.fail.invalidToken")
        let expectation = XCTestExpectation(description: "Upload Projects")
        let uploader = StoreProjectUploader(fileManager: fileManagerMock, session: dvrSession)

        uploader.upload(project: self.project,
                        completion: { projectId, error in
                            guard let error = error else { XCTFail("no error received"); return }
                            XCTAssertNil(projectId)
                            XCTAssertEqual(error, .authenticationFailed)
                            expectation.fulfill()
        }, progression: nil)

        wait(for: [expectation], timeout: 1)
    }

    func testUploadProjectFailsForZippingError() {
        self.fileManagerMock = CBFileManagerMock(filePath: [String](), directoryPath: [String]())
        let uploader = StoreProjectUploader(fileManager: fileManagerMock)
        let expectation = XCTestExpectation(description: "Upload Projects")

        uploader.upload(project: project,
                        completion: { projectId, error in
                            guard let error = error else { XCTFail("no error received"); return }
                            XCTAssertNil(projectId)
                            XCTAssertEqual(error, .zippingError)
                            expectation.fulfill()
        }, progression: nil)

        wait(for: [expectation], timeout: 1)
    }

    func testUploadProjetFailsForInvalidProject() {
        let dvrSession = Session(cassetteName: "StoreProjectDownloader.uploadProject.fail.invalidProject")
        let uploader = StoreProjectUploader(fileManager: fileManagerMock, session: dvrSession)
        let expectation = XCTestExpectation(description: "Upload Projects")

        uploader.upload(project: project,
                        completion: { projectId, error in
                            guard let error = error else { XCTFail("no error received"); return }
                            XCTAssertNil(projectId)
                            XCTAssertEqual(error, .invalidProject)
                            expectation.fulfill()
        }, progression: nil)

        wait(for: [expectation], timeout: 1)
    }

    func testUploadProjectInvalidChecksum() {
        let dvrSession = Session(cassetteName: "StoreProjectDownloader.uploadProject.fail.invalidChecksum")
        let uploader = StoreProjectUploader(fileManager: fileManagerMock, session: dvrSession)
        let expectation = XCTestExpectation(description: "Upload Projects")

        uploader.upload(project: project,
                        completion: { projectId, error in
                            guard let error = error else { XCTFail("no error received"); return }
                            XCTAssertNil(projectId)
                            XCTAssertEqual(error, .invalidProject)
                            expectation.fulfill()
        }, progression: nil)

        wait(for: [expectation], timeout: 1)
    }

    func testUploadProjectInvalidBody () {
        let dvrSession = Session(cassetteName: "StoreProjectUpload.uploadProject.fail.invalidBody")
        let expectation = XCTestExpectation(description: "Upload Project")
        let uploader = StoreProjectUploader(fileManager: fileManagerMock, session: dvrSession)

        uploader.upload(project: self.project,
                        completion: { projectId, error in
                            guard let error = error else { XCTFail("no error received"); return }
                            XCTAssertNil(projectId)
                            XCTAssertEqual(error, .unexpectedError)
                            expectation.fulfill()
        }, progression: nil)

        wait(for: [expectation], timeout: 1)
    }

    func testUploadProjectVaildProgression() {
        let mockSession = URLSessionMock(bytesSent: 500, bytesTotal: 1000)
        let uploader = StoreProjectUploader(fileManager: self.fileManagerMock, session: mockSession)
        let expectation = XCTestExpectation(description: "Upload Projects")

        uploader.upload(project: self.project,
                        completion: { _, _  in },
                        progression: { progress in
                            XCTAssertEqual(0.5, progress)
                            expectation.fulfill()
        })

        wait(for: [expectation], timeout: 1)
    }

    func testFetchTagsSuccess() {
        let dvrSession = Session(cassetteName: "StoreProjectUpload.fetchTags.success")
        let expectation = XCTestExpectation(description: "Fetch tags")
        let uploader = StoreProjectUploader(fileManager: fileManagerMock, session: dvrSession)
        let languageTag = "en"
        uploader.fetchTags(for: languageTag,
                           completion: { tags, error in
                            XCTAssertNil(error)
                            XCTAssertFalse(tags.isEmpty)
                            expectation.fulfill()
        })
        wait(for: [expectation], timeout: 1)
    }

    func testFetchTagsFailsWithUnexpectedError() {
        let mockSession = URLSessionMock()
        let uploader = StoreProjectUploader(fileManager: fileManagerMock, session: mockSession)
        let expectation = XCTestExpectation(description: "Fetch tags")
        let languageTag = "en"
        uploader.fetchTags(for: languageTag,
                           completion: { tags, error in
                            guard let error = error else { XCTFail("no error returned"); return }
                            XCTAssertEqual(error, .unexpectedError)
                            XCTAssertTrue(tags.isEmpty)
                            expectation.fulfill()
        })
        wait(for: [expectation], timeout: 1)
    }

    func testFetchTagsFailsWithInvalidLanguageTag() {
        let dvrSession = Session(cassetteName: "StoreProjectUpload.fetchTags.invalidLanguageTag")
        let uploader = StoreProjectUploader(fileManager: fileManagerMock, session: dvrSession)
        let expectation = XCTestExpectation(description: "Fetch tags")
        let languageTag = "invalidLanguageTag"
        uploader.fetchTags(for: languageTag,
                           completion: { tags, error in
                            guard let error = error else { XCTFail("no error returned"); return }
                            XCTAssertEqual(error, .invalidLanguageTag)
                            XCTAssertFalse(tags.isEmpty)
                            expectation.fulfill()
        })
        wait(for: [expectation], timeout: 1)
    }

}

extension StoreProjectUploaderError: Equatable {
    public static func == (lhs: StoreProjectUploaderError, rhs: StoreProjectUploaderError) -> Bool {
        switch (lhs, rhs) {
        case (.request, .request),
             (.zippingError, .zippingError),
             (.unexpectedError, .unexpectedError),
             (.timeout, .timeout),
             (.authenticationFailed, .authenticationFailed),
             (.invalidProject, .invalidProject),
             (.invalidLanguageTag, .invalidLanguageTag) :
            return true
        default:
            return false
        }
    }
}
