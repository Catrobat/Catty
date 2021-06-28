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

import XCTest

@testable import Pocket_Code

final class URLSessionMultipartExtensionTests: XCTestCase {

    var urlSession: URLSession!
    var url: URL!
    let uploadParameterTag = "upload"
    let projectNameTag = "projectTitle"
    let projectDescriptionTag = "projectDescription"
    var expectedZippedProjectData: Data!

    override func setUp() {
        self.urlSession = URLSession.shared
        self.url = URL(string: NetworkDefines.uploadUrl)!
        self.expectedZippedProjectData = "zippedProjectData".data(using: .utf8)
    }

    func testMultipartUploadTask() {
        let projectName = "testProjectName"
        let projectDescription = "testProjectDescription"
        let filename = "testFilename.zip"

        let formData = [FormData(name: projectNameTag, value: projectName),
                        FormData(name: projectDescriptionTag, value: projectDescription)]

        let attachmentData = [AttachmentData(name: uploadParameterTag, data: expectedZippedProjectData, filename: filename)]

        let expectedMinimumSize = projectNameTag.count + projectName.count + projectDescriptionTag.count +
            projectDescription.count + uploadParameterTag.count + expectedZippedProjectData.count + filename.count +
            URLSession.httpBoundary.count * 4

        let task = self.urlSession!.multipartUploadTask(with: url,
                                                        from: formData,
                                                        attachmentData: attachmentData,
                                                        completionHandler: { data, response, error in
                                                            XCTAssertNotNil(data)
                                                            XCTAssertNotNil(response)
                                                            XCTAssertNil(error)
        })

        XCTAssertEqual("POST", task.originalRequest?.httpMethod)
        XCTAssertTrue(Int(task.originalRequest!.allHTTPHeaderFields!["Content-Length"]!)! >= expectedMinimumSize)

        let request = String(decoding: task.originalRequest!.httpBody!, as: UTF8.self)

        XCTAssertEqual(4, request.components(separatedBy: URLSession.httpBoundary).count - 1)
        XCTAssertTrue(request.contains(projectNameTag))
        XCTAssertTrue(request.contains(projectName))
        XCTAssertTrue(request.contains(projectDescriptionTag))
        XCTAssertTrue(request.contains(projectDescription))
        XCTAssertTrue(request.contains(uploadParameterTag))
        XCTAssertTrue(request.contains("filename=\"" + filename + "\""))
        XCTAssertTrue(request.contains(String(decoding: expectedZippedProjectData, as: UTF8.self)))
    }

    func testMultipartUploadTaskWithAttachmentWithoutFilename() {
        let projectName = "testProjectName"

        let formData = [FormData(name: projectNameTag, value: projectName)]
        let attachmentData = [AttachmentData(name: uploadParameterTag, data: expectedZippedProjectData, filename: nil)]

        let task = self.urlSession!.multipartUploadTask(with: url,
                                                        from: formData,
                                                        attachmentData: attachmentData,
                                                        completionHandler: { data, response, error in
                                                            XCTAssertNotNil(data)
                                                            XCTAssertNotNil(response)
                                                            XCTAssertNil(error)
        })

        XCTAssertEqual("POST", task.originalRequest?.httpMethod)

        let request = String(decoding: task.originalRequest!.httpBody!, as: UTF8.self)

        XCTAssertEqual(3, request.components(separatedBy: URLSession.httpBoundary).count - 1)
        XCTAssertTrue(request.contains(projectNameTag))
        XCTAssertTrue(request.contains(projectName))
        XCTAssertTrue(request.contains(uploadParameterTag))
        XCTAssertFalse(request.contains("filename=\""))
        XCTAssertTrue(request.contains(String(decoding: expectedZippedProjectData, as: UTF8.self)))
    }

    func testMultipartUploadTaskWithoutAttachments() {
        let projectName = "testProjectName"

        let formData = [FormData(name: projectNameTag, value: projectName)]

        let task = self.urlSession!.multipartUploadTask(with: url,
                                                        from: formData,
                                                        attachmentData: [],
                                                        completionHandler: { data, response, error in
                                                            XCTAssertNotNil(data)
                                                            XCTAssertNotNil(response)
                                                            XCTAssertNil(error)
        })

        XCTAssertEqual("POST", task.originalRequest?.httpMethod)

        let request = String(decoding: task.originalRequest!.httpBody!, as: UTF8.self)

        XCTAssertEqual(2, request.components(separatedBy: URLSession.httpBoundary).count - 1)
        XCTAssertTrue(request.contains(projectNameTag))
        XCTAssertTrue(request.contains(projectName))
        XCTAssertFalse(request.contains("filename=\""))
    }
}
