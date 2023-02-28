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

protocol StoreAuthenticatorProtocol {
    func register(username: String, email: String, password: String, completion: @escaping (StoreAuthenticatorError?) -> Void)
    func login(username: String, password: String, completion: @escaping (StoreAuthenticatorError?) -> Void)
    func refreshToken(completion: @escaping (StoreAuthenticatorError?) -> Void)
    func deleteUser(completion: @escaping (StoreAuthenticatorError?) -> Void)
    static func logout()
    static func isLoggedIn() -> Bool
    static func needsTokenRefresh() -> Bool
    static func authorizationHeader() -> String?
}

enum StoreAuthenticatorError: Error {
    case request(error: Error?, statusCode: Int)
    case validation(response: [String: String])
    case authentication
    case parser
    case timeout
    case network
    case generic
}

final class StoreAuthenticator: NSObject, StoreAuthenticatorProtocol {
    private let keyUsername = "username"
    private let keyEmail = "email"
    private let keyPassword = "password"
    private let keyToken = "token"
    private let keyRefreshToken = "refresh_token"
    private let keyLegacyToken = "upload_token"

    let session: URLSession

    init(session: URLSession = StoreAuthenticator.defaultSession()) {
        self.session = session
    }

    // MARK: - Action Methods

    func register(username: String, email: String, password: String, completion: @escaping (StoreAuthenticatorError?) -> Void) {
        guard let url = URL.init(string: NetworkDefines.apiEndpointUser) else {
            completion(.generic)
            return
        }

        let body: [String: Any] = [keyUsername: username, keyEmail: email, keyPassword: password]

        var headers = [String: String]()
        if let language = Locale.autoupdatingCurrent.languageCode {
            headers["Accept-Language"] = language
        }

        self.session.jsonDataTask(with: url, bodyData: body, headers: headers) { jsonDict, response, error in
            let handleJsonDataTaskCompletion: ([String: Any]?, URLResponse?, Error?) -> (StoreAuthenticatorError?)
            handleJsonDataTaskCompletion = { jsonDict, response, error in
                if let error = error as NSError?, error.domain == NSURLErrorDomain && error.code == NSURLErrorTimedOut {
                    return .timeout
                }

                guard let response = response as? HTTPURLResponse else {
                    return .network
                }

                guard response.statusCode == 201, error == nil else {
                    if response.statusCode == 422, let jsonDict = jsonDict as? [String: String] {
                        return .validation(response: jsonDict)
                    }
                    return .request(error: error, statusCode: response.statusCode)
                }

                guard let jsonDict = jsonDict,
                      let token = jsonDict[self.keyToken],
                      let refreshToken = jsonDict[self.keyRefreshToken] else {
                    return .parser
                }

                UserDefaults.standard.set(username, forKey: NetworkDefines.kUsername)
                Keychain.saveValue(token, forKey: NetworkDefines.kAuthenticationToken)
                Keychain.saveValue(refreshToken, forKey: NetworkDefines.kRefreshToken)

                return nil
            }

            let result = handleJsonDataTaskCompletion(jsonDict, response, error)
            DispatchQueue.main.async {
                completion(result)
            }
        }.resume()
    }

    func login(username: String, password: String, completion: @escaping (StoreAuthenticatorError?) -> Void) {
        guard let url = URL.init(string: NetworkDefines.apiEndpointAuthentication) else {
            completion(.generic)
            return
        }

        let body = [keyUsername: username, keyPassword: password]

        self.session.jsonDataTask(with: url, bodyData: body) { jsonDict, response, error in
            let handleJsonDataTaskCompletion: ([String: Any]?, URLResponse?, Error?) -> (StoreAuthenticatorError?)
            handleJsonDataTaskCompletion = { jsonDict, response, error in
                if let error = error as NSError?, error.domain == NSURLErrorDomain && error.code == NSURLErrorTimedOut {
                    return .timeout
                }

                guard let response = response as? HTTPURLResponse else {
                    return .network
                }

                guard response.statusCode == 200, error == nil else {
                    if response.statusCode == 401 {
                        return .authentication
                    }
                    return .request(error: error, statusCode: response.statusCode)
                }

                guard let jsonDict = jsonDict,
                      let token = jsonDict[self.keyToken],
                      let refreshToken = jsonDict[self.keyRefreshToken] else {
                    return .parser
                }

                UserDefaults.standard.set(username, forKey: NetworkDefines.kUsername)
                Keychain.saveValue(token, forKey: NetworkDefines.kAuthenticationToken)
                Keychain.saveValue(refreshToken, forKey: NetworkDefines.kRefreshToken)

                return nil
            }

            let result = handleJsonDataTaskCompletion(jsonDict, response, error)
            DispatchQueue.main.async {
                completion(result)
            }
        }.resume()
    }

    func refreshToken(completion: @escaping (StoreAuthenticatorError?) -> Void) {
        var url: URL?
        var body = [String: Any]()
        var upgrade = false

        if let refreshToken = Keychain.loadValue(forKey: NetworkDefines.kRefreshToken) as? String {
            url = URL.init(string: NetworkDefines.apiEndpointAuthenticationRefresh)
            body[keyRefreshToken] = refreshToken
        } else if let legacyToken = Keychain.loadValue(forKey: NetworkDefines.kLegacyToken) as? String {
            url = URL.init(string: NetworkDefines.apiEndpointAuthenticationUpgrade)
            body[keyLegacyToken] = legacyToken
            upgrade = true
        } else {
            StoreAuthenticator.clearUserData(removeUsername: false)
            completion(.authentication)
            return
        }

        guard let url = url else {
            completion(.generic)
            return
        }

        self.session.jsonDataTask(with: url, bodyData: body) { jsonDict, response, error in
            let handleJsonDataTaskCompletion: ([String: Any]?, URLResponse?, Error?) -> (StoreAuthenticatorError?)
            handleJsonDataTaskCompletion = { jsonDict, response, error in
                if let error = error as NSError?, error.domain == NSURLErrorDomain && error.code == NSURLErrorTimedOut {
                    return .timeout
                }

                guard let response = response as? HTTPURLResponse else {
                    return .network
                }

                guard response.statusCode == 200, error == nil else {
                    if response.statusCode == 401 {
                        StoreAuthenticator.clearUserData(removeUsername: false)
                        return .authentication
                    }
                    return .request(error: error, statusCode: response.statusCode)
                }

                guard let jsonDict = jsonDict,
                      let token = jsonDict[self.keyToken],
                      let refreshToken = jsonDict[self.keyRefreshToken] else {
                    return .parser
                }

                Keychain.saveValue(token, forKey: NetworkDefines.kAuthenticationToken)
                Keychain.saveValue(refreshToken, forKey: NetworkDefines.kRefreshToken)

                if upgrade {
                    Keychain.deleteValue(forKey: NetworkDefines.kLegacyToken)
                }

                return nil
            }

            let result = handleJsonDataTaskCompletion(jsonDict, response, error)
            DispatchQueue.main.async {
                completion(result)
            }
        }.resume()
    }

    func deleteUser(completion: @escaping (StoreAuthenticatorError?) -> Void) {
        deleteUser(checkToken: true, completion: completion)
    }

    private func deleteUser(checkToken: Bool, completion: @escaping (StoreAuthenticatorError?) -> Void) {
        if checkToken && StoreAuthenticator.needsTokenRefresh() {
            refreshToken { error in
                switch error {
                case .none:
                    self.deleteUser(checkToken: false, completion: completion)
                default:
                    completion(error)
                }
            }
            return
        }

        guard let url = URL.init(string: NetworkDefines.apiEndpointUser) else {
            completion(.generic)
            return
        }

        guard let authorizationHeader = StoreAuthenticator.authorizationHeader() else {
            completion(.authentication)
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.addValue(authorizationHeader, forHTTPHeaderField: "Authorization")

        self.session.dataTask(with: request) { data, response, error in
            let handleTaskCompletion: (Data?, URLResponse?, Error?) -> (StoreAuthenticatorError?)
            handleTaskCompletion = { _, response, error in
                if let error = error as NSError?, error.domain == NSURLErrorDomain && error.code == NSURLErrorTimedOut {
                    return .timeout
                }

                guard let response = response as? HTTPURLResponse else {
                    return .network
                }

                guard response.statusCode == 204, error == nil else {
                    if response.statusCode == 401 {
                        return .authentication
                    }
                    return .request(error: error, statusCode: response.statusCode)
                }

                StoreAuthenticator.clearUserData(removeUsername: true)

                return nil
            }

            let result = handleTaskCompletion(data, response, error)
            DispatchQueue.main.async {
                completion(result)
            }
        }.resume()
    }

    static func logout() {
        clearUserData(removeUsername: true)
    }

    // MARK: - Info Methods

    @objc static func isLoggedIn() -> Bool {
        if Keychain.loadValue(forKey: NetworkDefines.kAuthenticationToken) != nil ||
           Keychain.loadValue(forKey: NetworkDefines.kLegacyToken) != nil {
            return true
        }
        return false
    }

    static func needsTokenRefresh() -> Bool {
        if Keychain.loadValue(forKey: NetworkDefines.kLegacyToken) != nil {
            return true
        }

        if let token = Keychain.loadValue(forKey: NetworkDefines.kAuthenticationToken) as? String,
           !StoreAuthenticator.isValidJWT(token) {
            return true
        }
        return false
    }

    static func authorizationHeader() -> String? {
        guard let token = Keychain.loadValue(forKey: NetworkDefines.kAuthenticationToken) as? String else {
            return nil
        }
        return "Bearer \(token)"
    }

    // MARK: - Private Helpers

    private static func clearUserData(removeUsername: Bool) {
        if removeUsername {
            UserDefaults.standard.removeObject(forKey: NetworkDefines.kUsername)
        }
        Keychain.deleteValue(forKey: NetworkDefines.kAuthenticationToken)
        Keychain.deleteValue(forKey: NetworkDefines.kRefreshToken)
        Keychain.deleteValue(forKey: NetworkDefines.kLegacyToken)
    }

    private static func isValidJWT(_ token: String) -> Bool {
        guard token.components(separatedBy: ".").count == 3 else {
            return false
        }

        var payloadDataB64 = token.components(separatedBy: ".")[1]
        payloadDataB64 = payloadDataB64.padding(toLength: payloadDataB64.count + payloadDataB64.count % 4, withPad: "=", startingAt: 0)

        guard let payloadData = Data(base64Encoded: payloadDataB64, options: .ignoreUnknownCharacters),
              let dict = try? JSONSerialization.jsonObject(with: payloadData) as? [String: Any],
              let expiryTimestamp = dict["exp"] as? Int else {
            return false
        }

        let expiryDate = Date(timeIntervalSince1970: TimeInterval(expiryTimestamp))
        return expiryDate.compare(Date() + TimeInterval(NetworkDefines.tokenExpirationTolerance)) == .orderedDescending
    }

    // MARK: - Test Helpers

    static func defaultSession() -> URLSession {
        let config = URLSessionConfiguration.ephemeral
        config.timeoutIntervalForRequest = Double(NetworkDefines.connectionTimeout)
        return URLSession(configuration: config, delegate: nil, delegateQueue: nil)
    }
}
