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

enum WebRequestDownloaderError: Error {
    /// Indicates a download bigger than kWebRequestMaxDownloadSizeInBytes
    case downloadSize
    case invalidURL
    case noInternet
    /// Indicates an untrusted domain download request
    case notTrusted
    /// Indicates an error with the URLRequest
    case request(error: Error?, statusCode: Int)
    case unexpectedError

    init(downloaderError: WebRequestDownloaderError) {
        switch downloaderError {
        case .downloadSize:
            self = .downloadSize
        case .invalidURL:
            self = .invalidURL
        case .noInternet:
            self = .noInternet
        case .notTrusted:
            self = .notTrusted
        case .request(error: _, statusCode: _):
            self = .request(error: nil, statusCode: 200)
        case .unexpectedError:
            self = .unexpectedError
        }
    }

    func message() -> String {
        switch self {
        case .downloadSize:
            return kLocalizedDownloadSizeErrorMessage
        case .invalidURL:
            return kLocalizedInvalidURLGiven
        case .noInternet:
            return "500"
        case .notTrusted:
            return "511"
        case .request(error: _, statusCode: let statusCode):
            return String(statusCode)
        case .unexpectedError:
            return kLocalizedUnexpectedErrorTitle
        }
    }
}
