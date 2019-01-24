/**
 *  Copyright (C) 2010-2019 The Catrobat Team
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

//web status codes are on: https://github.com/Catrobat/Catroweb/blob/master/statusCodes.php

class RequestManager {
    static let httpBoundary = "---------------------------98598263596598246508247098291---------------------------"

    static func setFormDataParameter(_ parameterID: String?, with data: Data?, forHTTPBody body: inout Data) {
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

    static func setAttachmentParameter(_ parameterID: String?, with data: Data?, forHTTPBody body: inout Data) {
        if let anEncoding = "--\(httpBoundary)\r\n".data(using: .utf8) {
            body.append(anEncoding)
        }
        let parameterString = "Content-Disposition: attachment; name=\"\(parameterID ?? "")\"; filename=\".zip\" \r\n"
        if let anEncoding = parameterString.data(using: .utf8) {
            body.append(anEncoding)
        }
        if let anEncoding = "Content-Type: application/octet-stream\r\n\r\n".data(using: .utf8) {
            body.append(anEncoding)
        }
        if let aData = data {
            body.append(aData)
        }
        if let anEncoding = "\r\n".data(using: .utf8) {
            body.append(anEncoding)
        }
    }
}
