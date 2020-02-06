/**
 *  Copyright (C) 2010-2020 The Catrobat Team
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

class LoginViewControllerTests: XCTestCase {
    
    var loginViewController: LoginViewControllerMock!

    override func setUp() {
        super.setUp()
        loginViewController = LoginViewControllerMock()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testServerTimeoutForUnexpectedStatusCode() {
        let unknownResponse = ["statusCode": "901"]
        loginViewController.handleLoginResponse(with: dataMock(status_code: unknownResponse), andResponse: nil)
        XCTAssertEqual(kLocalizedServerTimeoutIssueMessage, loginViewController.errorMessage!)
    }

    func testServerForAuthentificationFailedStatusCode() {
        let statusAuthentificationFailed = ["statusCode": "601"]
        loginViewController.handleLoginResponse(with: dataMock(status_code: statusAuthentificationFailed), andResponse: nil)
        XCTAssertEqual(kLocalizedAuthenticationFailed, loginViewController.errorMessage!)
    }

    func testServerForStatusCodeOK() {
        let statusOk = ["statusCode": "200"]
        loginViewController.handleLoginResponse(with: dataMock(status_code: statusOk), andResponse: nil)
        let isLoggedIn = UserDefaults.standard.bool(forKey: kUserIsLoggedIn)
        XCTAssertEqual(true, isLoggedIn)
    }

    func dataMock(status_code: [String: String]) -> Data {
        let jsonData = try? JSONSerialization.data(withJSONObject: status_code, options: .prettyPrinted)
        let encodedString = jsonData?.base64EncodedData()
        let data = Data(base64Encoded: encodedString!)

        return data!
    }
}
