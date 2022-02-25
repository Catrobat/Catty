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

import Foundation

protocol StoreProjectReporterProtocol {
    func report(projectId: String, message: String, completion: @escaping (StoreProjectReporterError?) -> Void)
}

final class StoreProjectReporter: StoreProjectReporterProtocol {

    private let httpBoundary = "---------------------------98551263596598746108249098092---------------------------"
    private let contentLengthTag = "Content-Length"
    private let authorizationTag = "Authorization"
    private let standardCategory = "Inappropriate"
    let session: URLSession

    init(session: URLSession = StoreProjectReporter.defaultSession()) {
        self.session = session
    }

    func report(projectId: String, message: String, completion: @escaping (StoreProjectReporterError?) -> Void) {

        let urlString = NetworkDefines.reportProjectUrl
        var request = URLRequest.init(url: URL(string: urlString)!)

        guard let postData = String(format: "program=%@&note=%@&category=%@", projectId, message, standardCategory).data(using: .utf8, allowLossyConversion: true) else { return }

        if let token = Keychain.loadValue(forKey: NetworkDefines.kUserLoginToken) as? String {
            let tokenString = String(format: "%@", token)
            request.addValue(tokenString, forHTTPHeaderField: authorizationTag)
        }

        let postLength = String(format: "%lu", UInt(postData.count))
        request.httpMethod = "POST"
        request.httpBody = postData
        request.addValue(postLength, forHTTPHeaderField: contentLengthTag)

        let task = self.session.dataTask(with: request) { _, response, error  in
            let handleDataTaskCompletion: (URLResponse?, Error?) -> (StoreProjectReporterError?)
            handleDataTaskCompletion = { response, error in
                guard let response = response as? HTTPURLResponse else { return (.unexpectedError) }

                if let error = error as NSError?, error.domain == NSURLErrorDomain && error.code == NSURLErrorTimedOut {
                    return (.timeout)
                }

                if Util.isNetworkError(error) {
                    Util.defaultAlertForNetworkError()
                    return(.unexpectedError)
                }

                guard (response.statusCode == 200 || response.statusCode == 204), error == nil else {
                    if response.statusCode == 401 { return (.authenticationFailed) }
                    if response.statusCode == 404 { return (.unexpectedError) }
                    return (.request(error: error, statusCode: response.statusCode))
                }

                return (nil)
            }

            let result = handleDataTaskCompletion(response, error)
            DispatchQueue.main.async {
                completion(result)
            }
        }

        task.resume()
    }

    static func defaultSession() -> URLSession {
        let config = URLSessionConfiguration.ephemeral
        config.timeoutIntervalForRequest = Double(NetworkDefines.connectionTimeout)
        return URLSession(configuration: config, delegate: nil, delegateQueue: nil)
    }
}

enum StoreProjectReporterError: Error {
    case request(error: Error?, statusCode: Int)

    case timeout

    case unexpectedError

    case authenticationFailed
}
