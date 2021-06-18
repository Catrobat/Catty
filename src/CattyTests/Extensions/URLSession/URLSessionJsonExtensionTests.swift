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
import XCTest

@testable import Pocket_Code

final class URLSessionJsonExtensionTests: XCTestCase {

    func testJsonDataTask() {
        let urlSession = Session(cassetteName: "URLSession.jsonDataTask.success")
        let expectation = XCTestExpectation(description: "Json data task")

        let bodyData = ["username": "username", "password": "password"]
        let url = URL(string: "https://web-test.catrob.at/api/authentication")!

        let task = urlSession.jsonDataTask(with: url, bodyData: bodyData, completionHandler: { jsonResponseData, response, error in
            XCTAssertEqual(2, jsonResponseData?.count)
            XCTAssertEqual("Invalid credentials.", jsonResponseData!["message"] as! String)
            XCTAssertEqual(401, jsonResponseData!["code"] as! Int)

            XCTAssertNotNil(response)
            XCTAssertNil(error)

            expectation.fulfill()
        })

        task.resume()

        wait(for: [expectation], timeout: 1.0)
    }

    func testJsonDataTaskFailInvalidJsonResponse() {
        let urlSession = Session(cassetteName: "URLSession.jsonDataTask.fail")
        let expectation = XCTestExpectation(description: "Json data task")

        let bodyData = ["username": "username", "password": "password"]
        let url = URL(string: "https://web-test.catrob.at/api/authentication")!

        let task = urlSession.jsonDataTask(with: url, bodyData: bodyData, completionHandler: { jsonResponseData, response, error in
            XCTAssertNil(jsonResponseData)
            XCTAssertNotNil(response)
            XCTAssertNil(error)

            expectation.fulfill()
        })

        task.resume()

        wait(for: [expectation], timeout: 1.0)
    }
}
