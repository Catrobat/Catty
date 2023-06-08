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

class StoreProjectUploaderTests: XCTestCase {

    var fileManagerMock: CBFileManagerMock!
    var project: Project!

    override func setUp() {
        super.setUp()

        self.project = Project()
        self.fileManagerMock = CBFileManagerMock(zipData: "zippedProjectData".data(using: .utf8)!)

        let testUser = "testUser"
        //swiftlint:disable line_length
        let testToken = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiYWRtaW4iOnRydWUsImlhdCI6MTUxNjIzOTAyMiwiZXhwIjo0ODIyMDMzMDUyfQ.GNnO3_Y4hYTkULubsayMWZmi25ZAWWw6PV01cRAu7M8"
        let testRefreshToken = "6b40fb5dac84fbd8c5b904545b09130efe6748686a1dca65b3ecc8b51e2e82733825f49b9536fc053c43d0755dc4350ec552ef81e5c0676251552767b090cacb"

        UserDefaults.standard.set(testUser, forKey: NetworkDefines.kUsername)
        Keychain.saveValue(testToken, forKey: NetworkDefines.kAuthenticationToken)
        Keychain.saveValue(testRefreshToken, forKey: NetworkDefines.kRefreshToken)
        Keychain.deleteValue(forKey: NetworkDefines.kLegacyToken)
    }

    // MARK: - Upload

    func testUploadSucceeds() {
        upload(with: "StoreProjectUploader.upload.success")
    }

    func testUploadSucceedsWithRefresh() {
        // swiftlint:disable:next line_length
        let expiredToken = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiYWRtaW4iOnRydWUsImlhdCI6MTUxNjIzOTAyMiwiZXhwIjoxNTE2MjM5MDIyfQ.lJ7ZxhkDfz2CTJCYTUlnx-braSZGxj9cZlIA4yqmqWg"
        Keychain.saveValue(expiredToken, forKey: NetworkDefines.kAuthenticationToken)

        upload(with: "StoreProjectUploader.upload.success.refresh")
    }

    func testUploadSucceedsWithUpgrade() {
        let testLegacyToken = "36cdf53b812dd2d47471367de94e8538"
        Keychain.deleteValue(forKey: NetworkDefines.kAuthenticationToken)
        Keychain.deleteValue(forKey: NetworkDefines.kRefreshToken)
        Keychain.saveValue(testLegacyToken, forKey: NetworkDefines.kLegacyToken)

        upload(with: "StoreProjectUploader.upload.success.upgrade")
    }

    func upload(with cassette: String) {
        let dvrSession = Session(cassetteName: cassette)
        let uploader = StoreProjectUploader(fileManager: fileManagerMock, session: dvrSession)
        let expectation = XCTestExpectation(description: "Upload project")

        uploader.upload(project: project,
                        completion: { projectId, error in
                            XCTAssertNil(error)

                            XCTAssertEqual(projectId, "2c43d3ee-4ba4-4dd5-9811-4bdb1656bdde")

                            expectation.fulfill()
                        },
                        progression: nil)

        wait(for: [expectation], timeout: 1.0)
    }

    func testUploadFailsWithValidationError() {
        upload(expecting: .validation(response: "Error while creating project entity. Try uploading again!"),
               with: "StoreProjectUploader.upload.fail.validation")
    }

    func testUploadFailsWithAuthenticationError() {
        upload(expecting: .authentication, with: "StoreProjectUploader.upload.fail.authentication")
    }

    func testUploadFailsWithRequestError() {
        upload(expecting: .request(error: nil, statusCode: 500), with: "StoreProjectUploader.upload.fail.request")
    }

    func testUploadFailsWithParseError() {
        upload(expecting: .parser, with: "StoreProjectUploader.upload.fail.parse")
    }

    func testUploadFailsWithGenericError() {
        self.fileManagerMock = CBFileManagerMock(filePath: [String](), directoryPath: [String]())
        upload(expecting: .generic)
    }

    func upload(expecting expectedError: StoreProjectUploaderError, with cassette: String? = nil) {
        let dvrSession = cassette != nil ? Session(cassetteName: cassette!) : StoreProjectUploader.defaultSession()
        let uploader = StoreProjectUploader(fileManager: fileManagerMock, session: dvrSession)
        let expectation = XCTestExpectation(description: "Upload project")

        uploader.upload(project: project,
                        completion: { projectId, error in
                            XCTAssertEqual(error, expectedError)

                            XCTAssertNil(projectId)

                            expectation.fulfill()
                        },
                        progression: nil)

        wait(for: [expectation], timeout: 1.0)
    }

    func testUploadProgression() {
        let mockSession = URLSessionMock(bytesSent: 500, bytesTotal: 1000)
        let uploader = StoreProjectUploader(fileManager: self.fileManagerMock, session: mockSession)
        let expectation = XCTestExpectation(description: "Upload project")

        uploader.upload(project: self.project,
                        completion: { _, _  in },
                        progression: { progress in
                            XCTAssertEqual(0.5, progress)
                            expectation.fulfill()
        })

        wait(for: [expectation], timeout: 1.0)
    }

    // MARK: - Fetch Tags

    func testFetchTagsSuccess() {
        let dvrSession = Session(cassetteName: "StoreProjectUploader.fetchTags.success")
        let expectation = XCTestExpectation(description: "Fetch tags")
        let uploader = StoreProjectUploader(fileManager: fileManagerMock, session: dvrSession)

        uploader.fetchTags { tags, error in
            XCTAssertNil(error)

            XCTAssertNotNil(tags)
            XCTAssertEqual(tags?.first?.id, "game")
            XCTAssertEqual(tags?.first?.text, "Game")

            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1.0)
    }

    func testFetchTagsFailsWithRequestError() {
        fetchTags(expecting: .request(error: nil, statusCode: 500), with: "StoreProjectUploader.fetchTags.fail.request")
    }

    func testFetchTagsFailsWithParseError() {
        fetchTags(expecting: .parser, with: "StoreProjectUploader.fetchTags.fail.parse")
    }

    func fetchTags(expecting expectedError: StoreProjectUploaderError, with cassette: String) {
        let dvrSession = Session(cassetteName: cassette)
        let uploader = StoreProjectUploader(fileManager: fileManagerMock, session: dvrSession)
        let expectation = XCTestExpectation(description: "Fetch tags")

        uploader.fetchTags { tags, error in
            XCTAssertEqual(error, expectedError)

            XCTAssertNil(tags)

            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1.0)
    }
}

extension StoreProjectUploaderError: Equatable {
    public static func == (lhs: StoreProjectUploaderError, rhs: StoreProjectUploaderError) -> Bool {
        switch (lhs, rhs) {
        case (.request(let errorLhs, let statusCodeLhs), .request(let errorRhs, let statusCodeRhs)) where
            errorLhs?.localizedDescription == errorRhs?.localizedDescription && statusCodeLhs == statusCodeRhs:
            return true
        case (.validation(let responseLhs), .validation(let responseRhs)) where responseLhs == responseRhs:
            return true
        case (.authentication, .authentication), (.parser, .parser), (.timeout, .timeout), (.network, .network), (.generic, .generic):
            return true
        default:
            return false
        }
    }
}
