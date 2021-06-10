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

enum WebRequestBrickError: Error {
    case blacklisted
    /// Indicates a download bigger than kWebRequestMaxDownloadSizeInBytes
    case downloadSize
    case invalidURL
    case noInternet
    /// Indicates an error with the URLRequest
    case request(error: Error?, statusCode: Int)
    case timeout
    case unexpectedError

    init(downloaderError: WebRequestDownloaderError) {
        switch downloaderError {
        case .downloadSize:
            self = .downloadSize
        case .invalidUrl:
            self = .invalidURL
        case .noInternet:
            self = .noInternet
        case .unexpectedError:
            self = .unexpectedError
        }
    }

    func message() -> String {
        switch self {
        case .blacklisted:
            return "511"
        case .downloadSize:
            return kLocalizedDownloadSizeErrorMessage
        case .invalidURL:
            return kLocalizedInvalidURLGiven
        case .noInternet, .timeout:
            return "500"
        case .request(error: _, statusCode: let statusCode):
            return String(statusCode)
        case .unexpectedError:
            return kLocalizedUnexpectedErrorTitle
        }
    }
}
