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

extension URLSession {

    static var httpBoundary = "---------------------------98598263596598246508247098291---------------------------"

    public func multipartUploadTask(with url: URL, from formData: [FormData], attachmentData: [AttachmentData],
                                    completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {

        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        let contentType = "multipart/form-data; boundary=\(type(of: self).httpBoundary)"
        request.addValue(contentType, forHTTPHeaderField: "Content-Type")

        var body = Data()

        for parameter in formData {
            setFormDataParameter(parameter, forHTTPBody: &body)
        }

        for attachment in attachmentData {
            setAttachmentParameter(attachment, forHTTPBody: &body)
        }

        if let anEncoding = "--\(URLSession.httpBoundary)--\r\n".data(using: .utf8) {
            body.append(anEncoding)
        }

        request.httpBody = body
        let postLength = String(format: "%lu", UInt(body.count))
        request.addValue(postLength, forHTTPHeaderField: "Content-Length")

        let task = self.dataTask(with: request, completionHandler: completionHandler)
        return task
    }

    private func setFormDataParameter(_ formData: FormData, forHTTPBody body: inout Data) {
        let data = formData.value.data(using: .utf8)
        if let anEncoding = "--\(URLSession.httpBoundary)\r\n".data(using: .utf8) {
            body.append(anEncoding)
        }
        let parameterString = "Content-Disposition: form-data; name=\"\(formData.name)\"\r\n\r\n"
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

    private func setAttachmentParameter(_ attachmentData: AttachmentData, forHTTPBody body: inout Data) {
        if let anEncoding = "--\(URLSession.httpBoundary)\r\n".data(using: .utf8) {
            body.append(anEncoding)
        }

        var parameterString = "Content-Disposition: attachment; name=\"\(attachmentData.name)\""
        if let filename = attachmentData.filename {
            parameterString += "; filename=\"" + filename + "\""
        }
        parameterString += " \r\n"

        if let anEncoding = parameterString.data(using: .utf8) {
            body.append(anEncoding)
        }
        if let anEncoding = "Content-Type: application/octet-stream\r\n\r\n".data(using: .utf8) {
            body.append(anEncoding)
        }
        body.append(attachmentData.data)
        if let anEncoding = "\r\n".data(using: .utf8) {
            body.append(anEncoding)
        }
    }
}

public struct FormData {
    let name: String
    let value: String
}

public struct AttachmentData {
    let name: String
    let data: Data
    let filename: String?
}
