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

protocol StoreAuthenticatorProtocol {
    func login(username: String, password: String, completion: @escaping (StoreAuthenticatorLoginError?) -> Void)
    func register(username: String, password: String, email: String, completion: @escaping (StoreAuthenticatorRegisterError?) -> Void)
    func logout()
}

enum StoreAuthenticatorRegisterError: Error {
    case request(error: Error?, statusCode: Int)
    case serverResponse(response: String)
    case timeout
    case unexpectedError
}

enum StoreAuthenticatorLoginError: Error {
    case request(error: Error?, statusCode: Int)
    case authenticationFailed
    case userDoesNotExist
    case timeout
    case unexpectedError
}

final class StoreAuthenticator: StoreAuthenticatorProtocol {

    let httpBoundary = "---------------------------98598263596598246508247098291---------------------------"
    let usernameTag = "username"
    let passwordTag = "password"
    let emailTag = "email"
    let registrationCountryTag = "registrationCountry"
    let dryRunTag = "dry-run"
    let defaultCountryCode = "US"
    let statusCodeTag = "statusCode"
    let statusCodeLoginSuccess = 200
    let statusCodeRegistrationSuccess = 201
    let statusCodeAuthenticationFailed = 401
    let statusCodeRegisterFailedWithServerResponse = 422
    let tokenTag = "token"
    let answerTag = "answer"

    let session: URLSession

    var username: String?
    var password: String?
    var email: String?

    init(session: URLSession = StoreAuthenticator.defaultSession()) {
        self.session = session
    }

    private func setFormDataParameter(_ parameterID: String?, with data: Data?, forHTTPBody body: inout Data) {
        if let anEncoding = "--\(httpBoundary)\r\n".data(using: .utf8) {
            body.append(anEncoding)
        }
        let parameterString = "Content-Disposition: form-data; name=\"\(parameterID ?? "")\"\r\n\r\n"
        if let anEncoding = parameterString.data(using: .utf8) {
            body.append(anEncoding)
        }
        if let aData = data {
            body.append(aData)
        }
        if let anEncoding = "\r\n".data(using: .utf8) {
            body.append(anEncoding)
        }
    }

    private func handleLoginResponse(data: Data, response: HTTPURLResponse) -> StoreAuthenticatorLoginError? {

        var dictionary: [String: Any]?
        do {
            dictionary = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        } catch {
            NSLog(error.localizedDescription)
            return .unexpectedError
        }

        debugPrint("Login successful")
        guard let token = dictionary?[tokenTag] else {
            return .unexpectedError
        }
        debugPrint("Token is: \(token)")

        UserDefaults.standard.set(true, forKey: NetworkDefines.kUserIsLoggedIn)
        UserDefaults.standard.set(self.username!, forKey: kcUsername)

        JNKeychain.saveValue(token, forKey: NetworkDefines.kUserLoginToken)

        return nil
    }

    private func handleRegisterResponse(data: Data, statusCode: Int) -> StoreAuthenticatorRegisterError? {

        var dictionary: [String: Any]?
        do {
            dictionary = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        } catch {
            NSLog(error.localizedDescription)
            return .unexpectedError
        }

        if statusCode == 201 {

            debugPrint("Register successful")
            guard let token = dictionary?[tokenTag] else {
                return .unexpectedError
            }
            debugPrint("Token is: \(token)")

            UserDefaults.standard.set(true, forKey: NetworkDefines.kUserIsLoggedIn)
            UserDefaults.standard.set(self.username!, forKey: kcUsername)
            UserDefaults.standard.set(self.email!, forKey: kcEmail)

            JNKeychain.saveValue(token, forKey: NetworkDefines.kUserLoginToken)

            return nil

        } else if statusCode == self.statusCodeRegisterFailedWithServerResponse {

            var serverResponseString = ""

            if let usernameErrorMessage = dictionary?[usernameTag] as? String {
                serverResponseString += " " + usernameErrorMessage
            }

            if let emailErrorMessage = dictionary?[emailTag] as? String {
                serverResponseString += " " + emailErrorMessage
            }

            if let passwordErrorMessage = dictionary?[passwordTag] as? String {
                serverResponseString += " " + passwordErrorMessage
            }

            debugPrint("All Server Error Responses: \(serverResponseString)")
            return .serverResponse(response: serverResponseString)

        } else {

            return .unexpectedError
        }

    }

    func login(username: String, password: String, completion: @escaping (StoreAuthenticatorLoginError?) -> Void) {

        debugPrint("Login started with username: \(username) and password: \(password)")
        self.username = username
        self.password = password

        guard let url = URL.init(string: NetworkDefines.loginUrl) else {
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        let contentType = "multipart/form-data; boundary=\(httpBoundary)"
        request.addValue(contentType, forHTTPHeaderField: "Content-Type")

        var body = Data()
        self.setFormDataParameter(usernameTag, with: username.data(using: .utf8), forHTTPBody: &body)
        self.setFormDataParameter(passwordTag, with: password.data(using: .utf8), forHTTPBody: &body)

        let encoding = "--\(httpBoundary)--\r\n"

        if let data = encoding.data(using: .utf8) {
            body.append(data)
        }

        request.httpBody = body

        let postLength = String(format: "%lu", UInt(body.count))
        request.addValue(postLength, forHTTPHeaderField: "Content-Length")

        request.timeoutInterval = TimeInterval(NetworkDefines.connectionTimeout)

        let task = self.session.dataTask(with: request) { data, response, error in

            guard let response = response as? HTTPURLResponse else {
                completion(.unexpectedError)
                return
            }

            if let error = error as NSError?, error.domain == NSURLErrorDomain && error.code == NSURLErrorTimedOut {
                completion(.timeout)
            }

            guard let data = data, response.statusCode == self.statusCodeLoginSuccess, error == nil else {
                if response.statusCode == self.statusCodeAuthenticationFailed {
                    completion(.authenticationFailed)
                    return
                }
                completion(.request(error: error, statusCode: response.statusCode))
                return
            }
            completion(self.handleLoginResponse(data: data, response: response))

        }

        task.resume()
    }

    func register(username: String, password: String, email: String, completion: @escaping (StoreAuthenticatorRegisterError?) -> Void) {

        debugPrint("Register started with username: \(username) and password: \(password) and email: \(email)")
        self.username = username
        self.password = password
        self.email = email

        guard let url = URL.init(string: NetworkDefines.registerUrl) else {
            completion(.unexpectedError)
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        let contentType = "multipart/form-data; boundary=\(httpBoundary)"
        request.addValue(contentType, forHTTPHeaderField: "Content-Type")

        var body = Data()
        self.setFormDataParameter(usernameTag, with: username.data(using: .utf8), forHTTPBody: &body)
        self.setFormDataParameter(passwordTag, with: password.data(using: .utf8), forHTTPBody: &body)
        self.setFormDataParameter(emailTag, with: email.data(using: .utf8), forHTTPBody: &body)
        self.setFormDataParameter(dryRunTag, with: "false".data(using: .utf8), forHTTPBody: &body)

        let encoding = "--\(httpBoundary)--\r\n"

        if let data = encoding.data(using: .utf8) {
            body.append(data)
        }

        request.httpBody = body
        request.timeoutInterval = TimeInterval(NetworkDefines.connectionTimeout)

        let postLength = String(format: "%lu", UInt(body.count))
        request.addValue(postLength, forHTTPHeaderField: "Content-Length")

        let task = self.session.dataTask(with: request) { data, response, error in

            guard let response = response as? HTTPURLResponse else {
                completion(.unexpectedError)
                return
            }

            if let error = error as NSError?, error.domain == NSURLErrorDomain && error.code == NSURLErrorTimedOut {
                completion(.timeout)
            }

            if let data = data, error == nil {
                completion(self.handleRegisterResponse(data: data, statusCode: response.statusCode))
            } else {
                completion(.request(error: error, statusCode: response.statusCode))
            }

        }

        task.resume()

    }

    func logout() {
        UserDefaults.standard.setValue(false, forKey: NetworkDefines.kUserIsLoggedIn)
        UserDefaults.standard.removeObject(forKey: NetworkDefines.kUserLoginToken)
        UserDefaults.standard.removeObject(forKey: kcUsername)
        UserDefaults.standard.removeObject(forKey: kcEmail)
    }

    static func defaultSession() -> URLSession {
        let config = URLSessionConfiguration.ephemeral
        config.timeoutIntervalForRequest = Double(NetworkDefines.connectionTimeout)
        return URLSession(configuration: config, delegate: nil, delegateQueue: nil)
    }

}
