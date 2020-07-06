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

protocol StoreProjectUploaderProtocol {
    func upload( project: Project, completion: @escaping (String?, StoreProjectUploaderError?) -> Void, progression: ((Float) -> Void)?)
}

enum StoreProjectUploaderError: Error {
    case request(error: Error?, statusCode: Int)

    case zippingError

    case timeout

    case unexpectedError

    case authenticationFailed

    case invalidProject
}

final class StoreProjectUploader: StoreProjectUploaderProtocol {

    private let httpBoundary = "---------------------------98598263596598246508247098291---------------------------"
    private let uploadParameterTag = "upload"
    private let fileChecksumParameterTag = "fileChecksum"
    private let tokenParameterTag = "token"
    private let projectNameTag = "projectTitle"
    private let projectDescriptionTag = "projectDescription"
    private let userEmailTag = "userEmail"
    private let userNameTag = "username"
    private let deviceLanguageTag = "deviceLanguage"
    private let statusCodeTag = "statusCode"
    private let projectIDTag = "projectId"
    private let session: URLSession
    private let fileManager: CBFileManager

    private var uploadProjectProgressObserver: NSKeyValueObservation?

    init(fileManager: CBFileManager, session: URLSession = StoreProjectUploader.defaultSession()) {
        self.session = session
        self.fileManager = fileManager
    }

    func upload(project: Project, completion: @escaping (String?, StoreProjectUploaderError?) -> Void, progression: ((Float) -> Void)?) {
        guard let zipFileData = fileManager.zip(project) else { completion(nil, .zippingError); return }

        let checksum = zipFileData.md5()

        let uploadUrl = NetworkDefines.uploadUrl
        let urlString = "\(uploadUrl)/\(NetworkDefines.connectionUpload)"

        var request = URLRequest(url: URL(string: urlString)!)
        request.url = URL(string: urlString)
        request.httpMethod = "POST"

        let contentType = "multipart/form-data; boundary=\(httpBoundary)"
        request.addValue(contentType, forHTTPHeaderField: "Content-Type")

        var body = Data()

        setFormDataParameter(projectNameTag, with: project.header.programName.data(using: .utf8), forHTTPBody: &body)
        setFormDataParameter(projectDescriptionTag, with: project.header.programDescription.data(using: .utf8), forHTTPBody: &body)

        if let email = UserDefaults.standard.string(forKey: kcEmail) {
            setFormDataParameter(userEmailTag, with: email.data(using: .utf8), forHTTPBody: &body)
        }

        setFormDataParameter(fileChecksumParameterTag, with: checksum.data(using: .utf8), forHTTPBody: &body)

        if let token = JNKeychain.loadValue(forKey: kUserLoginToken) as? String {
            setFormDataParameter(tokenParameterTag, with: token.data(using: .utf8), forHTTPBody: &body)
        }

        if let userName = UserDefaults.standard.string(forKey: kcUsername) {
            setFormDataParameter(userNameTag, with: userName.data(using: .utf8), forHTTPBody: &body)
        }

        setFormDataParameter(deviceLanguageTag, with: NSLocale.preferredLanguages[0].data(using: .utf8), forHTTPBody: &body)
        setAttachmentParameter(uploadParameterTag, with: zipFileData, forHTTPBody: &body)

        if let anEncoding = "--\(httpBoundary)--\r\n".data(using: .utf8) {
            body.append(anEncoding)
        }

        request.httpBody = body

        let postLength = String(format: "%lu", UInt(body.count))
        request.addValue(postLength, forHTTPHeaderField: "Content-Length")

        let task = self.session.dataTask(with: request) { data, response, error in
            let handleDataTaskCompletion: (Data?, URLResponse?, Error?) -> (projectId: String?, error: StoreProjectUploaderError?)
            handleDataTaskCompletion = { data, response, error in
                guard let response = response as? HTTPURLResponse else { return (nil, .unexpectedError) }

                if let error = error as NSError?, error.domain == NSURLErrorDomain && error.code == NSURLErrorTimedOut {
                    return (nil, .timeout)
                }

                guard let data = data, response.statusCode == 200, error == nil else {
                    if response.statusCode == 401 { return (nil, .authenticationFailed) }
                    return (nil, .request(error: error, statusCode: response.statusCode))
                }

                var statusCode: Int?
                var programId: String?
                do {
                    let dictionary = try JSONSerialization.jsonObject(with: data, options: []) as? [AnyHashable: Any]
                    statusCode = dictionary?[self.statusCodeTag] as? Int
                    if let programTag = dictionary?[self.projectIDTag] as? String {
                        programId = programTag
                    }
                } catch {
                    return (nil, .unexpectedError)
                }

                guard statusCode == 200  else { return (nil, .invalidProject) }

                return (programId, nil)
            }

            let result = handleDataTaskCompletion(data, response, error)
            DispatchQueue.main.async {
                completion(result.projectId, result.error)
            }
        }

        if let progression = progression {
            uploadProjectProgressObserver = task.observe(\.countOfBytesSent, options: [.new, .initial]) { progress, _ in
                var progress = Float(progress.countOfBytesSent) / Float(progress.countOfBytesExpectedToSend)
                if progress.isNaN {
                    progress = 0
                }
                progression(progress)
            }
        }

        task.resume()
    }

    static func defaultSession() -> URLSession {
        let config = URLSessionConfiguration.ephemeral
        config.timeoutIntervalForRequest = Double(NetworkDefines.connectionTimeout)
        return URLSession(configuration: config, delegate: nil, delegateQueue: nil)
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

    private func setAttachmentParameter(_ parameterID: String?, with data: Data?, forHTTPBody body: inout Data) {
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
