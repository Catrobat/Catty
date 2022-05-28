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

protocol StoreProjectUploaderProtocol {
    func upload( project: Project, completion: @escaping (String?, StoreProjectUploaderError?) -> Void, progression: ((Float) -> Void)?)
    func fetchTags(for language: String, completion: @escaping ([String], StoreProjectUploaderError?) -> Void)
}

enum StoreProjectUploaderError: Error {
    case request(error: Error?, statusCode: Int)

    case zippingError

    case timeout

    case unexpectedError

    case authenticationFailed

    case invalidProject

    case invalidLanguageTag
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
    private let availableTags = "constantTags"
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
        let attachments = [AttachmentData(name: uploadParameterTag, data: zipFileData, filename: ".zip")]

        let uploadUrl = NetworkDefines.uploadUrl
        let urlString = "\(uploadUrl)/\(NetworkDefines.connectionUpload)"
        guard let url = URL(string: urlString) else { completion(nil, .unexpectedError); return }

        var parameters = [FormData(name: projectNameTag, value: project.header.programName),
                          FormData(name: projectDescriptionTag, value: project.header.programDescription)]
        if let email = UserDefaults.standard.string(forKey: kcEmail) {
            parameters.append(FormData(name: userEmailTag, value: email))
        }

        parameters.append(FormData(name: fileChecksumParameterTag, value: checksum))

        if let token = Keychain.loadValue(forKey: NetworkDefines.kUserLoginToken) as? String {
            parameters.append(FormData(name: tokenParameterTag, value: token))
        }

        if let userName = UserDefaults.standard.string(forKey: kcUsername) {
            parameters.append(FormData(name: userNameTag, value: userName))
        }

        parameters.append(FormData(name: deviceLanguageTag, value: NSLocale.preferredLanguages[0]))

        let task = self.session.multipartUploadTask(with: url, from: parameters, attachmentData: attachments) { data, response, error in
            let handleDataTaskCompletion: (Data?, URLResponse?, Error?) -> (projectId: String?, error: StoreProjectUploaderError?)
            handleDataTaskCompletion = { data, response, error in
                guard let response = response as? HTTPURLResponse else { return (nil, .unexpectedError) }

                if let error = error as NSError?, error.domain == NSURLErrorDomain && error.code == NSURLErrorTimedOut {
                    return (nil, .timeout)
                }

                guard let data = data, response.statusCode == 200, error == nil else {
                    if response.statusCode == 401 || response.statusCode == 403 { return (nil, .authenticationFailed) }
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

    func fetchTags(for language: String, completion: @escaping ([String], StoreProjectUploaderError?) -> Void) {
        var tagUrlComponents = URLComponents(string: NetworkDefines.tagUrl)
        tagUrlComponents?.queryItems = [
            URLQueryItem(name: NetworkDefines.tagLanguage, value: language)
        ]

        guard let tagUrl = tagUrlComponents?.url else {
            return
        }

        self.session.dataTask(with: tagUrl) { data, response, error in
            let handleDataTaskCompletion: (Data?, URLResponse?, Error?) -> (availableTags: [String], error: StoreProjectUploaderError?)

            handleDataTaskCompletion = { data, response, error in
                guard let response = response as? HTTPURLResponse else { return ([], .unexpectedError) }

                if let error = error as NSError?, error.domain == NSURLErrorDomain && error.code == NSURLErrorTimedOut {
                    return ([], .timeout)
                }

                guard let data = data, response.statusCode == 200, error == nil else {
                    return ([], .request(error: error, statusCode: response.statusCode))
                }

                var statusCode: Int?
                var tags = [String]()

                do {
                    let dictionary = try JSONSerialization.jsonObject(with: data, options: []) as? [AnyHashable: Any]
                    statusCode = dictionary?[self.statusCodeTag] as? Int
                    if let availableTags = dictionary?[self.availableTags] as? [String] {
                        tags = availableTags
                    }
                } catch {
                    return ([], .unexpectedError)
                }

                guard statusCode == 200  else { return (tags, .invalidLanguageTag) }

                return (tags, nil)
            }

            let result = handleDataTaskCompletion(data, response, error)
            DispatchQueue.main.async {
                completion(result.availableTags, result.error)
            }
        }.resume()
    }

    static func defaultSession() -> URLSession {
        let config = URLSessionConfiguration.ephemeral
        config.timeoutIntervalForRequest = Double(NetworkDefines.connectionTimeout)
        return URLSession(configuration: config, delegate: nil, delegateQueue: nil)
    }
}
