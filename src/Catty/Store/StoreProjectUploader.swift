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

protocol StoreProjectUploaderProtocol {
    func upload(project: Project, completion: @escaping (String?, StoreProjectUploaderError?) -> Void, progression: ((Float) -> Void)?)
    func fetchTags(completion: @escaping ([StoreProjectTag]?, StoreProjectUploaderError?) -> Void)
}

enum StoreProjectUploaderError: Error {
    case request(error: Error?, statusCode: Int)
    case validation(response: String)
    case authentication
    case parser
    case timeout
    case network
    case generic
}

final class StoreProjectUploader: StoreProjectUploaderProtocol {
    private let keyChecksum = "checksum"
    private let keyFile = "file"
    private let keyError = "error"

    private let session: URLSession
    private let fileManager: CBFileManager

    private var uploadProjectProgressObserver: NSKeyValueObservation?

    init(fileManager: CBFileManager = CBFileManager(), session: URLSession = StoreProjectUploader.defaultSession()) {
        self.session = session
        self.fileManager = fileManager
    }

    func upload(project: Project, completion: @escaping (String?, StoreProjectUploaderError?) -> Void, progression: ((Float) -> Void)?) {
        upload(project: project, checkToken: true, completion: completion, progression: progression)
    }

    private func upload(project: Project, checkToken: Bool, completion: @escaping (String?, StoreProjectUploaderError?) -> Void, progression: ((Float) -> Void)?) {
        if checkToken && StoreAuthenticator.needsTokenRefresh() {
            StoreAuthenticator(session: session).refreshToken { error in
                switch error {
                case .none:
                    self.upload(project: project, checkToken: false, completion: completion, progression: progression)
                case .request(error: let error, statusCode: let statusCode):
                    completion(nil, .request(error: error, statusCode: statusCode))
                case .authentication:
                    completion(nil, .authentication)
                case .parser:
                    completion(nil, .parser)
                case .network:
                    completion(nil, .network)
                case .timeout:
                    completion(nil, .timeout)
                default:
                    completion(nil, .generic)
                }
            }
            return
        }

        guard let url = URL(string: NetworkDefines.apiEndpointProjects),
              let language = Locale.autoupdatingCurrent.languageCode,
              let zipFileData = self.fileManager.zip(project) else {
            completion(nil, .generic)
            return
        }

        guard let authorizationHeader = StoreAuthenticator.authorizationHeader() else {
            completion(nil, .authentication)
            return
        }

        let parameters = [FormData(name: keyChecksum, value: zipFileData.md5())]
        let headers = ["Accept-Language": language, "Authorization": authorizationHeader]
        let attachments = [AttachmentData(name: keyFile, data: zipFileData, filename: ".zip")]

        let task = self.session.multipartUploadTask(with: url, from: parameters, headers: headers, attachmentData: attachments) { data, response, error in
            let handleDataTaskCompletion: (Data?, URLResponse?, Error?) -> (projectId: String?, error: StoreProjectUploaderError?)
            handleDataTaskCompletion = { data, response, error in
                if let error = error as NSError?, error.domain == NSURLErrorDomain && error.code == NSURLErrorTimedOut {
                    return (nil, .timeout)
                }

                guard let response = response as? HTTPURLResponse else {
                    return (nil, .network)
                }

                guard let data = data, response.statusCode == 201, error == nil else {
                    if response.statusCode == 401 {
                        return (nil, .authentication)
                    } else if response.statusCode == 422, let jsonData = data,
                              let jsonDict = try? JSONSerialization.jsonObject(with: jsonData) as? [String: String],
                              let errorString = jsonDict[self.keyError] {
                        return (nil, .validation(response: errorString))
                    }
                    return (nil, .request(error: error, statusCode: response.statusCode))
                }

                guard let storeProject = try? JSONDecoder().decode(StoreProject.self, from: data) else {
                    return (nil, .parser)
                }

                return (storeProject.id, nil)
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

    func fetchTags(completion: @escaping ([StoreProjectTag]?, StoreProjectUploaderError?) -> Void) {
        guard let url = URL(string: NetworkDefines.apiEndpointProjectsTags),
              let language = Locale.autoupdatingCurrent.languageCode else {
            completion(nil, .generic)
            return
        }

        var request = URLRequest(url: url)
        request.addValue(language, forHTTPHeaderField: "Accept-Language")

        self.session.dataTask(with: request) { data, response, error in
            let handleDataTaskCompletion: (Data?, URLResponse?, Error?) -> (availableTags: [StoreProjectTag]?, error: StoreProjectUploaderError?)
            handleDataTaskCompletion = { data, response, error in
                if let error = error as NSError?, error.domain == NSURLErrorDomain && error.code == NSURLErrorTimedOut {
                    return (nil, .timeout)
                }

                guard let response = response as? HTTPURLResponse else {
                    return (nil, .network)
                }

                guard response.statusCode == 200, error == nil else {
                    return (nil, .request(error: error, statusCode: response.statusCode))
                }

                guard let data = data, let tags = try? JSONDecoder().decode([StoreProjectTag].self, from: data) else {
                    return (nil, .parser)
                }

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
