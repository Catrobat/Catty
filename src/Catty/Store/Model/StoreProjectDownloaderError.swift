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

enum StoreProjectDownloaderError: Equatable {
    /// Indicates an error with the URLRequest.
    case request(error: Error?, statusCode: Int)
    /// Indicates a parsing error of the received data.
    case parse(error: Error)
    /// Indicates a server timeout.
    case timeout
    /// Indicates a manual cancellation by the user.
    case cancelled
    /// Indicates an unexpected error.
    case unexpectedError

    static func == (e1: StoreProjectDownloaderError, e2: StoreProjectDownloaderError) -> Bool {
        switch (e1, e2) {
        case (.request(let error1, let statusCode1), .request(let error2, let statusCode2)) where error1?.localizedDescription == error2?.localizedDescription && statusCode1 == statusCode2:
            return true
        case (.parse(let error1), .parse(let error2)) where error1.localizedDescription == error2.localizedDescription:
            return true
        case (.timeout, .timeout):
            return true
        case (.cancelled, .cancelled):
            return true
        case (.unexpectedError, .unexpectedError):
            return true
        default:
            return false
        }
    }
}
