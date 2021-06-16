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

import DVR
@testable import Pocket_Code
import XCTest

class StoreAuthenticatorTests: XCTestCase {

    override func tearDown() {
        StoreAuthenticator().logout()
    }

    func testLoginSuccess() {
        let dvrSession = Session(cassetteName: "StoreAuthenticator.login.success.authentication")

        let expectation = XCTestExpectation(description: "Login")

        let authenticator = StoreAuthenticator(session: dvrSession)
        authenticator.login(username: "test_user", password: "test_user") { error in
            if error != nil {
                XCTFail("There was an error while loggin in!")
            }

            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 5)
    }

    func testLoginAuthenticationFailed() {
        let dvrSession = Session(cassetteName: "StoreAuthenticator.login.fail.authentication")

        let expectation = XCTestExpectation(description: "Login")

        let authenticator = StoreAuthenticator(session: dvrSession)
        authenticator.login(username: "test_user", password: "incorrect_password") { error in
            guard let error = error else {
                XCTFail("authentication was succesful. Replace username and password with some other values.")
                return
            }
            XCTAssertEqual(error, .authenticationFailed)

            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 5)
    }

    func testRegisterSuccess() {
        let dvrSession = Session(cassetteName: "StoreAuthenticator.register.success.authentication")

        let expectation = XCTestExpectation(description: "Register")

        let authenticator = StoreAuthenticator(session: dvrSession)
        authenticator.register(username: "test_user5", password: "test_user5", email: "test_user5@email.com") { error in
            if error != nil {
                XCTFail("An error occured")
                return
            }

            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 5)
    }

    func testRegisterServerResponseEmailAlreadyExist() {
        let dvrSession = Session(cassetteName: "StoreAuthenticator.register.fail.emailalreadyinuse")

        let expectation = XCTestExpectation(description: "Register")

        let authenticator = StoreAuthenticator(session: dvrSession)
        authenticator.register(username: "test_user10", password: "test_user5", email: "test_user5@email.com") { error in

            guard let error = error else {
                XCTFail("No error occured")
                return
            }

            switch error {
            case let .serverResponse(response: response):
                XCTAssertTrue(response == " Email already in use")

            default:
                XCTFail("wrong error received")
            }

            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 5)
    }

    func testRegisterServerResponseUsernameTooShort() {
        let dvrSession = Session(cassetteName: "StoreAuthenticator.register.fail.usernametooshort")

        let expectation = XCTestExpectation(description: "Register")

        let authenticator = StoreAuthenticator(session: dvrSession)
        authenticator.register(username: "ab", password: "new_test_user_password", email: "test_user3@email.com") { error in

            guard let error = error else {
                XCTFail("No error occured")
                return
            }

            switch error {
            case let .serverResponse(response: response):
                XCTAssertTrue(response == " Username too short")

            default:
                XCTFail("wrong error received")
            }

            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 5)
    }

    func testRegisterServerResponsePasswordTooShort() {
        let dvrSession = Session(cassetteName: "StoreAuthenticator.register.fail.passwordtooshort")

        let expectation = XCTestExpectation(description: "Register")

        let authenticator = StoreAuthenticator(session: dvrSession)
        authenticator.register(username: "abcdefg", password: "a", email: "test_user4@email.com") { error in

            guard let error = error else {
                XCTFail("No error occured")
                return
            }

            switch error {
            case let .serverResponse(response: response):
                XCTAssertTrue(response == " Password too short")

            default:
                XCTFail("wrong error received")
            }

            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 5)
    }
}

extension StoreAuthenticatorLoginError: Equatable {
    public static func == (lhs: StoreAuthenticatorLoginError, rhs: StoreAuthenticatorLoginError) -> Bool {
        switch (lhs, rhs) {
        case (.request, .request), (.authenticationFailed, .authenticationFailed), (.unexpectedError, .unexpectedError), (.userDoesNotExist, .userDoesNotExist), (.timeout, .timeout):
            return true
        default:
            return false
        }
    }
}

extension StoreAuthenticatorRegisterError: Equatable {
    public static func == (lhs: StoreAuthenticatorRegisterError, rhs: StoreAuthenticatorRegisterError) -> Bool {
        switch (lhs, rhs) {
        case (.request, .request), (.serverResponse, .serverResponse), (.unexpectedError, .unexpectedError), (.timeout, .timeout):
            return true
        default:
            return false
        }
    }
}
