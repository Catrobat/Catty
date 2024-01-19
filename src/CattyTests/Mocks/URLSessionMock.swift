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

/// An URLSession subclass that doesn't send a proper URLResponse in the completion handlers.
class URLSessionMock: URLSession {

    var response: URLResponse?
    var error: Error?
    var bytesReceived: Int64?
    var bytesSent: Int64?
    var bytesTotal: Int64?
    var dataTasksCreated = 0

    init(response: URLResponse? = nil, error: Error? = nil, bytesSent: Int64? = nil, bytesReceived: Int64? = nil, bytesTotal: Int64? = nil) {
        self.response = response
        self.error = error
        self.bytesReceived = bytesReceived
        self.bytesTotal = bytesTotal
        self.bytesSent = bytesSent
        super.init()
    }

    override func dataTask(with url: URL) -> URLSessionDataTask {
        dataTasksCreated += 1
        return URLSessionDataTaskMock(nil, response: response, error: error, self.bytesSent, self.bytesReceived, self.bytesTotal)
    }

    override func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        dataTasksCreated += 1
        return URLSessionDataTaskMock(completionHandler, response: response, error: error, self.bytesSent, self.bytesReceived, self.bytesTotal)
    }

    override func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        dataTasksCreated += 1
        return URLSessionDataTaskMock(completionHandler, response: response, error: error, self.bytesSent, self.bytesReceived, self.bytesTotal)
    }

    class URLSessionDataTaskMock: URLSessionDataTask {

        private var bytesReceived = Int64()
        private var bytesTotal = Int64()
        private var bytesSent = Int64()

        override var countOfBytesReceived: Int64 {
             bytesReceived
        }

        override var countOfBytesExpectedToReceive: Int64 {
             bytesTotal
        }

        override var countOfBytesExpectedToSend: Int64 {
            bytesTotal
        }

        override var countOfBytesSent: Int64 {
            bytesSent
        }

        var completionHandler: ((Data?, URLResponse?, Error?) -> Void)?
        var mockResponse: URLResponse?
        var mockError: Error?
        var cancelled = false

        required init(_ completionHandler: ((Data?, URLResponse?, Error?) -> Void)?,
                      response: URLResponse?,
                      error: Error?,
                      _ bytesSent: Int64? = 0,
                      _ bytesReceived: Int64? = 0,
                      _ bytesTotal: Int64? = 0) {

            self.completionHandler = completionHandler
            self.mockResponse = response
            self.mockError = error
            if let bytesTotal = bytesTotal {
                self.bytesTotal = bytesTotal
            }
            if let bytesReceived = bytesReceived {
                self.bytesReceived = bytesReceived
            }

            if let bytesSent = bytesSent {
                self.bytesSent = bytesSent
            }
        }

        override func resume() {
            self.completionHandler?(nil, mockResponse, mockError)
            self.completionHandler = nil
        }

        override func cancel() {
            cancelled = true
        }
    }
}
