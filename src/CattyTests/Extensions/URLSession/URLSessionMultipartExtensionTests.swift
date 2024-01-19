/**
 *  Copyright (C) 2010-2024 The Catrobat Team
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

final class URLSessionMultipartExtensionTests: XCTestCase {
    let url = URL(string: NetworkDefines.apiEndpointProject)!

    let keyChecksum = "checksum"
    let keyFile = "file"

    let testLanguage = "en"
    let testChecksum = "8a382118b630df98d4a90336174bc528"
    let testFile = "someTestData".data(using: .utf8)!
    let testFilename = "filename.bin"

    func testMultipartUploadTask() {
        let formData = [FormData(name: keyChecksum, value: testChecksum)]

        let headers = ["Accept-Language": testLanguage]

        let attachmentData = [AttachmentData(name: keyFile, data: testFile, filename: testFilename)]

        let expectedMinimumSize = keyChecksum.count + testChecksum.count + keyFile.count + testFile.count + testFilename.count + URLSession.httpBoundary.count * 3

        let task = URLSession.shared.multipartUploadTask(with: url,
                                                         from: formData,
                                                         headers: headers,
                                                         attachmentData: attachmentData,
                                                         completionHandler: { data, response, error in
                                                            XCTAssertNotNil(data)
                                                            XCTAssertNotNil(response)
                                                            XCTAssertNil(error)
        })

        XCTAssertEqual("POST", task.originalRequest?.httpMethod)
        XCTAssertEqual(task.originalRequest!.allHTTPHeaderFields!["Accept-Language"]!, testLanguage)
        XCTAssertTrue(Int(task.originalRequest!.allHTTPHeaderFields!["Content-Length"]!)! >= expectedMinimumSize)

        let request = String(decoding: task.originalRequest!.httpBody!, as: UTF8.self)

        XCTAssertEqual(3, request.components(separatedBy: URLSession.httpBoundary).count - 1)
        XCTAssertTrue(request.contains(keyChecksum))
        XCTAssertTrue(request.contains(testChecksum))
        XCTAssertTrue(request.contains(keyFile))
        XCTAssertTrue(request.contains("filename=\"" + testFilename + "\""))
        XCTAssertTrue(request.contains(String(decoding: testFile, as: UTF8.self)))
    }

    func testMultipartUploadTaskWithAttachmentWithoutFilename() {
        let formData = [FormData(name: keyChecksum, value: testChecksum)]

        let headers = ["Accept-Language": testLanguage]

        let attachmentData = [AttachmentData(name: keyFile, data: testFile, filename: nil)]

        let task = URLSession.shared.multipartUploadTask(with: url,
                                                         from: formData,
                                                         headers: headers,
                                                         attachmentData: attachmentData,
                                                         completionHandler: { data, response, error in
                                                            XCTAssertNotNil(data)
                                                            XCTAssertNotNil(response)
                                                            XCTAssertNil(error)
        })

        XCTAssertEqual("POST", task.originalRequest?.httpMethod)
        XCTAssertEqual(task.originalRequest!.allHTTPHeaderFields!["Accept-Language"]!, testLanguage)

        let request = String(decoding: task.originalRequest!.httpBody!, as: UTF8.self)

        XCTAssertEqual(3, request.components(separatedBy: URLSession.httpBoundary).count - 1)
        XCTAssertTrue(request.contains(keyChecksum))
        XCTAssertTrue(request.contains(testChecksum))
        XCTAssertTrue(request.contains(keyFile))
        XCTAssertFalse(request.contains("filename=\""))
        XCTAssertTrue(request.contains(String(decoding: testFile, as: UTF8.self)))
    }

    func testMultipartUploadTaskWithoutAttachments() {
        let formData = [FormData(name: keyChecksum, value: testChecksum)]

        let headers = ["Accept-Language": testLanguage]

        let task = URLSession.shared.multipartUploadTask(with: url,
                                                         from: formData,
                                                         headers: headers,
                                                         completionHandler: { data, response, error in
                                                            XCTAssertNotNil(data)
                                                            XCTAssertNotNil(response)
                                                            XCTAssertNil(error)
        })

        XCTAssertEqual("POST", task.originalRequest?.httpMethod)
        XCTAssertEqual(task.originalRequest!.allHTTPHeaderFields!["Accept-Language"]!, testLanguage)

        let request = String(decoding: task.originalRequest!.httpBody!, as: UTF8.self)

        XCTAssertEqual(2, request.components(separatedBy: URLSession.httpBoundary).count - 1)
        XCTAssertTrue(request.contains(keyChecksum))
        XCTAssertTrue(request.contains(testChecksum))
        XCTAssertFalse(request.contains("filename=\""))
    }
}
