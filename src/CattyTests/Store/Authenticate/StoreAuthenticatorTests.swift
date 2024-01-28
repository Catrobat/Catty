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

import DVR
@testable import Pocket_Code
import XCTest

class StoreAuthenticatorTests: XCTestCase {
    let testUser = "testUser"
    let testEmail = "test@email.dev"
    let testPass = "testPass"
    //swiftlint:disable line_length
    let testToken = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiYWRtaW4iOnRydWUsImlhdCI6MTUxNjIzOTAyMiwiZXhwIjo0ODIyMDMzMDUyfQ.GNnO3_Y4hYTkULubsayMWZmi25ZAWWw6PV01cRAu7M8"
    let testRefreshToken = "6b40fb5dac84fbd8c5b904545b09130efe6748686a1dca65b3ecc8b51e2e82733825f49b9536fc053c43d0755dc4350ec552ef81e5c0676251552767b090cacb"
    let testLegacyToken = "36cdf53b812dd2d47471367de94e8538"

    override func setUp() {
        UserDefaults.standard.removeObject(forKey: NetworkDefines.kUsername)
        Keychain.deleteValue(forKey: NetworkDefines.kAuthenticationToken)
        Keychain.deleteValue(forKey: NetworkDefines.kRefreshToken)
        Keychain.deleteValue(forKey: NetworkDefines.kLegacyToken)
    }

    // MARK: - Register

    func testRegisterSucceeds() {
        let dvrSession = Session(cassetteName: "StoreAuthenticator.register.success")
        let authenticator = StoreAuthenticator(session: dvrSession)
        let expectation = XCTestExpectation(description: "Register")

        authenticator.register(username: testUser, email: testEmail, password: testPass) { error in
            XCTAssertNil(error, "Register failed")

            XCTAssertTrue(StoreAuthenticator.isLoggedIn())

            XCTAssertEqual(UserDefaults.standard.string(forKey: NetworkDefines.kUsername), self.testUser)
            XCTAssertEqual(Keychain.loadValue(forKey: NetworkDefines.kAuthenticationToken) as? String, self.testToken)
            XCTAssertEqual(Keychain.loadValue(forKey: NetworkDefines.kRefreshToken) as? String, self.testRefreshToken)

            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1.0)
    }

    func testRegisterFailsWithValidationError() {
        register(with: "StoreAuthenticator.register.fail.validation", expecting: .validation(response: ["username": "Username already in use"]))
    }

    func testRegisterFailsWithRequestError() {
        register(with: "StoreAuthenticator.register.fail.request", expecting: .request(error: nil, statusCode: 500))
    }

    func testRegisterFailsWithParseError() {
        register(with: "StoreAuthenticator.register.fail.parse", expecting: .parser)
    }

    func register(with cassette: String, expecting expectedError: StoreAuthenticatorError) {
        let dvrSession = Session(cassetteName: cassette)
        let authenticator = StoreAuthenticator(session: dvrSession)
        let expectation = XCTestExpectation(description: "Register")

        authenticator.register(username: testUser, email: testEmail, password: testPass) { error in
            XCTAssertEqual(error, expectedError)

            XCTAssertFalse(StoreAuthenticator.isLoggedIn())

            XCTAssertNil(UserDefaults.standard.string(forKey: NetworkDefines.kUsername))
            XCTAssertNil(Keychain.loadValue(forKey: NetworkDefines.kAuthenticationToken))
            XCTAssertNil(Keychain.loadValue(forKey: NetworkDefines.kRefreshToken))

            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1.0)
    }

    // MARK: - Login

    func testLoginSucceeds() {
        let dvrSession = Session(cassetteName: "StoreAuthenticator.login.success")
        let authenticator = StoreAuthenticator(session: dvrSession)
        let expectation = XCTestExpectation(description: "Login")

        authenticator.login(username: testUser, password: testPass) { error in
            XCTAssertNil(error, "Login failed")

            XCTAssertTrue(StoreAuthenticator.isLoggedIn())

            XCTAssertEqual(UserDefaults.standard.string(forKey: NetworkDefines.kUsername), self.testUser)
            XCTAssertEqual(Keychain.loadValue(forKey: NetworkDefines.kAuthenticationToken) as? String, self.testToken)
            XCTAssertEqual(Keychain.loadValue(forKey: NetworkDefines.kRefreshToken) as? String, self.testRefreshToken)

            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1.0)
    }

    func testLoginFailsWithAuthenticationError() {
        login(with: "StoreAuthenticator.login.fail.authentication", expecting: .authentication)
    }

    func testLoginFailsWithRequestError() {
        login(with: "StoreAuthenticator.login.fail.request", expecting: .request(error: nil, statusCode: 500))
    }

    func testLoginFailsWithParseError() {
        login(with: "StoreAuthenticator.login.fail.parse", expecting: .parser)
    }

    func login(with cassette: String, expecting expectedError: StoreAuthenticatorError) {
        let dvrSession = Session(cassetteName: cassette)
        let authenticator = StoreAuthenticator(session: dvrSession)
        let expectation = XCTestExpectation(description: "Login")

        authenticator.login(username: testUser, password: testPass) { error in
            XCTAssertEqual(error, expectedError)

            XCTAssertFalse(StoreAuthenticator.isLoggedIn())

            XCTAssertNil(UserDefaults.standard.string(forKey: NetworkDefines.kUsername))
            XCTAssertNil(Keychain.loadValue(forKey: NetworkDefines.kAuthenticationToken))
            XCTAssertNil(Keychain.loadValue(forKey: NetworkDefines.kRefreshToken))

            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1.0)
    }

    // MARK: - Refresh Token

    func testRefreshTokenSucceeds() throws {
        let dvrSession = Session(cassetteName: "StoreAuthenticator.refreshToken.success")
        let authenticator = StoreAuthenticator(session: dvrSession)
        let expectation = XCTestExpectation(description: "Refresh token")

        UserDefaults.standard.set(testUser, forKey: NetworkDefines.kUsername)
        Keychain.saveValue(testToken, forKey: NetworkDefines.kAuthenticationToken)
        Keychain.saveValue(testRefreshToken, forKey: NetworkDefines.kRefreshToken)

        authenticator.refreshToken { error in
            XCTAssertNil(error, "Refresh token failed")

            XCTAssertTrue(StoreAuthenticator.isLoggedIn())

            XCTAssertEqual(UserDefaults.standard.string(forKey: NetworkDefines.kUsername), self.testUser)
            XCTAssertEqual(Keychain.loadValue(forKey: NetworkDefines.kAuthenticationToken) as? String, "newTestToken")
            XCTAssertEqual(Keychain.loadValue(forKey: NetworkDefines.kRefreshToken) as? String, "newTestRefreshToken")

            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1.0)
    }

    func testRefreshTokenSucceedsWithUpgrade() {
        let dvrSession = Session(cassetteName: "StoreAuthenticator.refreshToken.success.upgrade")
        let authenticator = StoreAuthenticator(session: dvrSession)
        let expectation = XCTestExpectation(description: "Refresh token")

        UserDefaults.standard.set(testUser, forKey: NetworkDefines.kUsername)
        Keychain.saveValue(testLegacyToken, forKey: NetworkDefines.kLegacyToken)

        authenticator.refreshToken { error in
            XCTAssertNil(error, "Refresh token failed")

            XCTAssertTrue(StoreAuthenticator.isLoggedIn())

            XCTAssertEqual(UserDefaults.standard.string(forKey: NetworkDefines.kUsername), self.testUser)
            XCTAssertEqual(Keychain.loadValue(forKey: NetworkDefines.kAuthenticationToken) as? String, self.testToken)
            XCTAssertEqual(Keychain.loadValue(forKey: NetworkDefines.kRefreshToken) as? String, self.testRefreshToken)
            XCTAssertNil(Keychain.loadValue(forKey: NetworkDefines.kLegacyToken))

            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1.0)
    }

    func testRefreshTokenFailsWithAuthenticationError() throws {
        refreshToken(with: "StoreAuthenticator.refreshToken.fail.authentication", expecting: .authentication)
    }

    func testRefreshTokenFailsWithRequestError() {
        refreshToken(with: "StoreAuthenticator.refreshToken.fail.request", expecting: .request(error: nil, statusCode: 500))
    }

    func testRefreshTokenFailsWithParseError() throws {
        refreshToken(with: "StoreAuthenticator.refreshToken.fail.parse", expecting: .parser)
    }

    func refreshToken(with cassette: String, expecting expectedError: StoreAuthenticatorError) {
        let dvrSession = Session(cassetteName: cassette)
        let authenticator = StoreAuthenticator(session: dvrSession)
        let expectation = XCTestExpectation(description: "Refresh token")

        UserDefaults.standard.set(testUser, forKey: NetworkDefines.kUsername)
        Keychain.saveValue(testToken, forKey: NetworkDefines.kAuthenticationToken)
        Keychain.saveValue(testRefreshToken, forKey: NetworkDefines.kRefreshToken)
        Keychain.saveValue(testLegacyToken, forKey: NetworkDefines.kLegacyToken)

        authenticator.refreshToken { error in
            XCTAssertEqual(error, expectedError)

            if expectedError == .authentication {
                XCTAssertFalse(StoreAuthenticator.isLoggedIn())

                XCTAssertEqual(UserDefaults.standard.string(forKey: NetworkDefines.kUsername), self.testUser)
                XCTAssertNil(Keychain.loadValue(forKey: NetworkDefines.kAuthenticationToken))
                XCTAssertNil(Keychain.loadValue(forKey: NetworkDefines.kRefreshToken))
                XCTAssertNil(Keychain.loadValue(forKey: NetworkDefines.kLegacyToken))
            } else {
                XCTAssertTrue(StoreAuthenticator.isLoggedIn())

                XCTAssertEqual(UserDefaults.standard.string(forKey: NetworkDefines.kUsername), self.testUser)
                XCTAssertEqual(Keychain.loadValue(forKey: NetworkDefines.kAuthenticationToken) as? String, self.testToken)
                XCTAssertEqual(Keychain.loadValue(forKey: NetworkDefines.kRefreshToken) as? String, self.testRefreshToken)
                XCTAssertEqual(Keychain.loadValue(forKey: NetworkDefines.kLegacyToken) as? String, self.testLegacyToken)
            }

            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1.0)
    }

    // MARK: - Delete User

    func testDeleteUserSucceeds() {
        UserDefaults.standard.set(testUser, forKey: NetworkDefines.kUsername)
        Keychain.saveValue(testToken, forKey: NetworkDefines.kAuthenticationToken)
        Keychain.saveValue(testRefreshToken, forKey: NetworkDefines.kRefreshToken)

        delete(with: "StoreAuthenticator.deleteUser.success")
    }

    func testDeleteUserSucceedsWithRefresh() {
        UserDefaults.standard.set(testUser, forKey: NetworkDefines.kUsername)
        // swiftlint:disable:next line_length
        let expiredToken = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiYWRtaW4iOnRydWUsImlhdCI6MTUxNjIzOTAyMiwiZXhwIjoxNTE2MjM5MDIyfQ.lJ7ZxhkDfz2CTJCYTUlnx-braSZGxj9cZlIA4yqmqWg"
        Keychain.saveValue(expiredToken, forKey: NetworkDefines.kAuthenticationToken)
        Keychain.saveValue(testRefreshToken, forKey: NetworkDefines.kRefreshToken)

        delete(with: "StoreAuthenticator.deleteUser.success.refresh")
    }

    func testDeleteUserSucceedsWithUpgrade() {
        UserDefaults.standard.set(testUser, forKey: NetworkDefines.kUsername)
        let testLegacyToken = "36cdf53b812dd2d47471367de94e8538"
        Keychain.saveValue(testLegacyToken, forKey: NetworkDefines.kLegacyToken)

        delete(with: "StoreAuthenticator.deleteUser.success.upgrade")
    }

    func delete(with cassette: String) {
        let dvrSession = Session(cassetteName: cassette)
        let authenticator = StoreAuthenticator(session: dvrSession)
        let expectation = XCTestExpectation(description: "Delete user")

        authenticator.deleteUser { error in
            XCTAssertNil(error, "Delete user failed")

            XCTAssertFalse(StoreAuthenticator.isLoggedIn())

            XCTAssertNil(UserDefaults.standard.string(forKey: NetworkDefines.kUsername))
            XCTAssertNil(Keychain.loadValue(forKey: NetworkDefines.kAuthenticationToken))
            XCTAssertNil(Keychain.loadValue(forKey: NetworkDefines.kRefreshToken))

            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1.0)
    }

    func testDeleteUserFailsWithAuthenticationError() {
        deleteUser(with: "StoreAuthenticator.deleteUser.fail.authentication", expecting: .authentication)
    }

    func testDeleteUserFailsWithRequestError() {
        deleteUser(with: "StoreAuthenticator.deleteUser.fail.request", expecting: .request(error: nil, statusCode: 500))
    }

    func deleteUser(with cassette: String, expecting expectedError: StoreAuthenticatorError) {
        let dvrSession = Session(cassetteName: cassette)
        let authenticator = StoreAuthenticator(session: dvrSession)
        let expectation = XCTestExpectation(description: "Delete user")

        UserDefaults.standard.set(testUser, forKey: NetworkDefines.kUsername)
        Keychain.saveValue(testToken, forKey: NetworkDefines.kAuthenticationToken)
        Keychain.saveValue(testRefreshToken, forKey: NetworkDefines.kRefreshToken)

        authenticator.deleteUser { error in
            XCTAssertEqual(error, expectedError)

            XCTAssertTrue(StoreAuthenticator.isLoggedIn())

            XCTAssertEqual(UserDefaults.standard.string(forKey: NetworkDefines.kUsername), self.testUser)
            XCTAssertEqual(Keychain.loadValue(forKey: NetworkDefines.kAuthenticationToken) as? String, self.testToken)
            XCTAssertEqual(Keychain.loadValue(forKey: NetworkDefines.kRefreshToken) as? String, self.testRefreshToken)

            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1.0)
    }

    // MARK: - Logout

    func testLogout() {
        UserDefaults.standard.set(testUser, forKey: NetworkDefines.kUsername)
        Keychain.saveValue(testToken, forKey: NetworkDefines.kAuthenticationToken)
        Keychain.saveValue(testRefreshToken, forKey: NetworkDefines.kRefreshToken)
        Keychain.saveValue(testLegacyToken, forKey: NetworkDefines.kLegacyToken)

        StoreAuthenticator.logout()

        XCTAssertNil(UserDefaults.standard.string(forKey: NetworkDefines.kUsername))
        XCTAssertNil(Keychain.loadValue(forKey: NetworkDefines.kAuthenticationToken))
        XCTAssertNil(Keychain.loadValue(forKey: NetworkDefines.kRefreshToken))
        XCTAssertNil(Keychain.loadValue(forKey: NetworkDefines.kLegacyToken))
    }

    // MARK: - Info Methods

    func testIsLoggedIn() {
        XCTAssertFalse(StoreAuthenticator.isLoggedIn())

        Keychain.saveValue(testToken, forKey: NetworkDefines.kAuthenticationToken)
        XCTAssertTrue(StoreAuthenticator.isLoggedIn())

        Keychain.saveValue(testLegacyToken, forKey: NetworkDefines.kLegacyToken)
        XCTAssertTrue(StoreAuthenticator.isLoggedIn())

        Keychain.deleteValue(forKey: NetworkDefines.kAuthenticationToken)
        XCTAssertTrue(StoreAuthenticator.isLoggedIn())
    }

    func testNeedsTokenRefresh() {
        XCTAssertFalse(StoreAuthenticator.needsTokenRefresh())

        Keychain.saveValue(testToken, forKey: NetworkDefines.kAuthenticationToken)
        XCTAssertFalse(StoreAuthenticator.needsTokenRefresh())

        // swiftlint:disable:next line_length
        let expiredToken = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiYWRtaW4iOnRydWUsImlhdCI6MTUxNjIzOTAyMiwiZXhwIjoxNTE2MjM5MDIyfQ.lJ7ZxhkDfz2CTJCYTUlnx-braSZGxj9cZlIA4yqmqWg"
        Keychain.saveValue(expiredToken, forKey: NetworkDefines.kAuthenticationToken)
        XCTAssertTrue(StoreAuthenticator.needsTokenRefresh())

        Keychain.saveValue(testLegacyToken, forKey: NetworkDefines.kLegacyToken)
        XCTAssertTrue(StoreAuthenticator.needsTokenRefresh())
    }

    func testAuthorizationHeader() {
        XCTAssertNil(StoreAuthenticator.authorizationHeader())

        Keychain.saveValue(testToken, forKey: NetworkDefines.kAuthenticationToken)
        // swiftlint:disable:next line_length
        XCTAssertEqual(StoreAuthenticator.authorizationHeader(), "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiYWRtaW4iOnRydWUsImlhdCI6MTUxNjIzOTAyMiwiZXhwIjo0ODIyMDMzMDUyfQ.GNnO3_Y4hYTkULubsayMWZmi25ZAWWw6PV01cRAu7M8")
    }
}

extension StoreAuthenticatorError: Equatable {
    public static func == (lhs: StoreAuthenticatorError, rhs: StoreAuthenticatorError) -> Bool {
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
