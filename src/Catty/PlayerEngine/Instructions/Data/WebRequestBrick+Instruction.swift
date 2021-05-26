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

extension WebRequestBrick: CBInstructionProtocol {

    @nonobjc func instruction() -> CBInstruction {
        if WebRequestBrick.isWebRequestBrickEnabled() {
            guard let request = self.request else { fatalError("Unexpected found nil.") }
            guard let displayString = request.getDisplayString() else { fatalError("Unexpected found nil.") }

            var requestString = displayString
            if requestString.hasPrefix("'") {
                requestString = String(requestString.dropFirst())
            }
            if requestString.hasSuffix("'") {
                requestString = String(requestString.dropLast())
            }

            let downloader = WebRequestDownloader(url: requestString, session: nil)

            return CBInstruction.waitExecClosure { _, scheduler in
                self.sendRequest(downloader: downloader) { response, error in
                    self.callbackSubmit(with: response, error: error, scheduler: scheduler)
                }
                scheduler.pause()
            }
        } else {
            return CBInstruction.invalidInstruction
        }
    }

    func callbackSubmit(with input: String?, error: WebRequestBrickError?, scheduler: CBSchedulerProtocol) {
        if let userVariable = self.userVariable {
            userVariable.value = extractMessage(input: input, error: error)
        }

        DispatchQueue.main.async {
          scheduler.resume()
        }
    }

    private func extractMessage(input: String?, error: WebRequestBrickError?) -> String {
        guard let input = input else {
            switch error {
            case .downloadSize:
                return kLocalizedDownloadSizeErrorMessage
            case .invalidURL:
                return kLocalizedInvalidURLGiven
            case .noInternet, .timeout:
                return "500"
            case let .request(error: _, statusCode: statusCode):
                return String(statusCode)
            default:
                return kLocalizedUnexpectedErrorTitle
            }
        }
        return input
    }

    private func sendRequest(downloader: WebRequestDownloader, completion: @escaping (String?, WebRequestBrickError?) -> Void) {
        downloader.download { response, error in
            if let error = error as? WebRequestDownloadError {
                if case WebRequestDownloadError.invalidUrl = error {
                    completion(nil, .invalidURL)
                } else if case WebRequestDownloadError.noInternet = error {
                    completion(nil, .noInternet)
                } else if case WebRequestDownloadError.downloadSize = error {
                    completion(nil, .downloadSize)
                } else {
                    completion(nil, .unexpectedError)
                }
            } else {
                completion(response, nil)
            }
        }
    }

    private static func isWebRequestBrickEnabled() -> Bool {
         UserDefaults.standard.bool(forKey: kUseWebRequestBrick)
    }

    enum WebRequestBrickError: Error {
        /// Indicates a download bigger than kWebRequestMaxDownloadSizeInBytes
        case downloadSize
        /// Indicates an invalid URL
        case invalidURL
        /// Indicates that no internet connection is present
        case noInternet
        /// Indicates an error with the URLRequest
        case request(error: Error?, statusCode: Int)
        /// Indicates a request timeout
        case timeout
        /// Indicates an unexpected error
        case unexpectedError
    }
}
