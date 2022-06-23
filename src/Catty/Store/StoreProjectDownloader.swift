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

import Foundation

protocol StoreProjectDownloaderProtocol {
    func fetchProjects(for type: ProjectType, offset: Int, completion: @escaping ([StoreProject]?, StoreProjectDownloaderError?) -> Void)
    func fetchFeaturedProjects(offset: Int, completion: @escaping ([StoreFeaturedProject]?, StoreProjectDownloaderError?) -> Void)
    func fetchSearchQuery(searchTerm: String, completion: @escaping ([StoreProject]?, StoreProjectDownloaderError?) -> Void)
    func fetchProjectDetails(for projectId: String, completion: @escaping (StoreProject?, StoreProjectDownloaderError?) -> Void)
    func download(projectId: String, projectName: String, completion: @escaping (Data?, StoreProjectDownloaderError?) -> Void, progression: ((Float) -> Void)?)
}

class StoreProjectDownloader: NSObject, StoreProjectDownloaderProtocol {

    private let session: URLSession
    private let fileManager: CBFileManager
    private var downloadProjectProgressObserver: NSKeyValueObservation?
    internal var downloadTasks: [String: URLSessionDataTask]

    @objc init(session: URLSession = StoreProjectDownloader.defaultSession(), fileManager: CBFileManager = CBFileManager.shared()) {
        self.session = session
        self.fileManager = fileManager
        self.downloadTasks = [:]
    }

    func fetchSearchQuery(searchTerm: String, completion: @escaping ([StoreProject]?, StoreProjectDownloaderError?) -> Void) {

        let version: String = Util.catrobatLanguageVersion()

        var attributes = StoreProject.defaultQueryParameters
        attributes.append(StoreProject.CodingKeys.author.rawValue)

        var indexURLComponents = URLComponents(string: NetworkDefines.apiEndpointProjectsSearch)
        indexURLComponents?.queryItems = [
            URLQueryItem(name: NetworkDefines.apiParameterQuery, value: searchTerm),
            URLQueryItem(name: NetworkDefines.apiParameterMaxVersion, value: version),
            URLQueryItem(name: NetworkDefines.apiParameterLimit, value: String(NetworkDefines.searchProjectsBatchSize)),
            URLQueryItem(name: NetworkDefines.apiParameterOffset, value: String(0)),
            URLQueryItem(name: NetworkDefines.apiParameterAttributes, value: attributes.joined(separator: ","))
        ]

        guard let indexURL = indexURLComponents?.url else {
            return
        }

        self.session.dataTask(with: URLRequest(url: indexURL)) { data, response, error in
            let handleDataTaskCompletion: (Data?, URLResponse?, Error?) -> (items: [StoreProject]?, error: StoreProjectDownloaderError?)
            handleDataTaskCompletion = { data, response, error in
                if let error = error as NSError?, error.domain == NSURLErrorDomain && error.code == NSURLErrorTimedOut {
                    let searchErrorInfo = ProjectFetchFailureInfo(url: indexURL.absoluteString, description: error.localizedDescription, projectName: searchTerm)

                    NotificationCenter.default.post(name: .projectSearchFailure, object: searchErrorInfo)
                    return (nil, .timeout)
                }

                guard let response = response as? HTTPURLResponse else {
                    let searchErrorInfo = ProjectFetchFailureInfo(url: indexURL.absoluteString, description: error?.localizedDescription ?? "", projectName: searchTerm)

                    NotificationCenter.default.post(name: .projectSearchFailure, object: searchErrorInfo)
                    return (nil, .unexpectedError)
                }
                guard let data = data, response.statusCode == 200, error == nil else {
                    let searchErrorInfo = ProjectFetchFailureInfo(url: indexURL.absoluteString,
                                                                  statusCode: response.statusCode,
                                                                  description: error?.localizedDescription ?? "",
                                                                  projectName: searchTerm)

                    NotificationCenter.default.post(name: .projectSearchFailure, object: searchErrorInfo)

                    return (nil, .request(error: error, statusCode: response.statusCode))
                }
                let items: [StoreProject]?
                do {
                    items = try JSONDecoder().decode([StoreProject].self, from: data)
                } catch {
                    let searchErrorInfo = ProjectFetchFailureInfo(url: indexURL.absoluteString, statusCode: response.statusCode, description: error.localizedDescription, projectName: searchTerm)

                    NotificationCenter.default.post(name: .projectSearchFailure, object: searchErrorInfo)
                    return (nil, .parse(error: error))
                }
                return (items, nil)
            }
            let result = handleDataTaskCompletion(data, response, error)
            DispatchQueue.main.async {
                completion(result.items, result.error)
            }
        }.resume()
    }

    func fetchProjects(for type: ProjectType, offset: Int, completion: @escaping ([StoreProject]?, StoreProjectDownloaderError?) -> Void) {

        let version: String = Util.catrobatLanguageVersion()

        var attributes = StoreProject.defaultQueryParameters
        switch type {
        case .mostDownloaded:
            attributes.append(StoreProject.CodingKeys.downloads.rawValue)
        case .mostViewed:
            attributes.append(StoreProject.CodingKeys.views.rawValue)
        case .mostRecent:
            attributes.append(StoreProject.CodingKeys.uploaded.rawValue)
        }

        var urlComponents = URLComponents(string: NetworkDefines.apiEndpointProjects)
        urlComponents?.queryItems = [
            URLQueryItem(name: NetworkDefines.apiParameterCategory, value: type.apiCategory()),
            URLQueryItem(name: NetworkDefines.apiParameterMaxVersion, value: version),
            URLQueryItem(name: NetworkDefines.apiParameterLimit, value: String(NetworkDefines.chartProjectsBatchSize)),
            URLQueryItem(name: NetworkDefines.apiParameterOffset, value: String(offset)),
            URLQueryItem(name: NetworkDefines.apiParameterAttributes, value: attributes.joined(separator: ","))
        ]

        guard let url = urlComponents?.url else {
            return
        }

        self.session.dataTask(with: URLRequest(url: url)) { data, response, error in
            let handleDataTaskCompletion: (Data?, URLResponse?, Error?) -> (items: [StoreProject]?, error: StoreProjectDownloaderError?)
            handleDataTaskCompletion = { data, response, error in
                if let error = error as NSError?, error.domain == NSURLErrorDomain && error.code == NSURLErrorTimedOut {
                    let errorInfo = ProjectFetchFailureInfo(type: type, url: url.absoluteString, description: error.localizedDescription)

                    NotificationCenter.default.post(name: .projectFetchFailure, object: errorInfo)
                    return (nil, .timeout)
                }

                guard let response = response as? HTTPURLResponse else {
                    let errorInfo = ProjectFetchFailureInfo(type: type, url: url.absoluteString, description: error?.localizedDescription ?? "")

                    NotificationCenter.default.post(name: .projectFetchFailure, object: errorInfo)
                    return (nil, .unexpectedError)
                }
                guard let data = data, response.statusCode == 200, error == nil else {
                    let errorInfo = ProjectFetchFailureInfo(type: type, url: url.absoluteString, statusCode: response.statusCode, description: error?.localizedDescription ?? "")

                    NotificationCenter.default.post(name: .projectFetchFailure, object: errorInfo)
                    return (nil, .request(error: error, statusCode: response.statusCode))
                }
                let items: [StoreProject]?
                do {
                    items = try JSONDecoder().decode([StoreProject].self, from: data)
                } catch {
                    let errorInfo = ProjectFetchFailureInfo(type: type, url: url.absoluteString, statusCode: response.statusCode, description: error.localizedDescription)

                    NotificationCenter.default.post(name: .projectFetchFailure, object: errorInfo)
                    return (nil, .parse(error: error))
                }
                return (items, nil)
            }
            let result = handleDataTaskCompletion(data, response, error)
            DispatchQueue.main.async {
                completion(result.items, result.error)
            }

        }.resume()
    }

    func fetchFeaturedProjects(offset: Int, completion: @escaping ([StoreFeaturedProject]?, StoreProjectDownloaderError?) -> Void) {

        let version: String = Util.catrobatLanguageVersion()

        let attributes = StoreFeaturedProject.defaultQueryParameters

        var featuredUrlComponents = URLComponents(string: NetworkDefines.apiEndpointProjectsFeatured)
        featuredUrlComponents?.queryItems = [
            URLQueryItem(name: NetworkDefines.apiParameterPlatform, value: NetworkDefines.currentPlatform),
            URLQueryItem(name: NetworkDefines.apiParameterMaxVersion, value: version),
            URLQueryItem(name: NetworkDefines.apiParameterLimit, value: String(NetworkDefines.featuredProjectsBatchSize)),
            URLQueryItem(name: NetworkDefines.apiParameterOffset, value: String(offset)),
            URLQueryItem(name: NetworkDefines.apiParameterAttributes, value: attributes.joined(separator: ","))
        ]

        guard let url = featuredUrlComponents?.url else {
            return
        }

        self.session.dataTask(with: URLRequest(url: url)) { data, response, error in
            let handleDataTaskCompletion: (Data?, URLResponse?, Error?) -> (items: [StoreFeaturedProject]?, error: StoreProjectDownloaderError?)
            handleDataTaskCompletion = { data, response, error in
                if let error = error as NSError?, error.domain == NSURLErrorDomain && error.code == NSURLErrorTimedOut {
                    let errorInfo = ProjectFetchFailureInfo(url: url.absoluteString, description: error.localizedDescription)

                    NotificationCenter.default.post(name: .projectFetchFailure, object: errorInfo)
                    return (nil, .timeout)
                }

                guard let response = response as? HTTPURLResponse else {
                    let errorInfo = ProjectFetchFailureInfo(url: url.absoluteString, description: error?.localizedDescription ?? "")

                    NotificationCenter.default.post(name: .projectFetchFailure, object: errorInfo)
                    return (nil, .unexpectedError)
                }
                guard let data = data, response.statusCode == 200, error == nil else {
                    let errorInfo = ProjectFetchFailureInfo(url: url.absoluteString, statusCode: response.statusCode, description: error?.localizedDescription ?? "")

                    NotificationCenter.default.post(name: .projectFetchFailure, object: errorInfo)
                    return (nil, .request(error: error, statusCode: response.statusCode))
                }
                let items: [StoreFeaturedProject]?
                do {
                    items = try JSONDecoder().decode([StoreFeaturedProject].self, from: data)
                } catch {
                    let errorInfo = ProjectFetchFailureInfo(url: url.absoluteString, statusCode: response.statusCode, description: error.localizedDescription)

                    NotificationCenter.default.post(name: .projectFetchFailure, object: errorInfo)
                    return (nil, .parse(error: error))
                }
                return (items, nil)
            }
            let result = handleDataTaskCompletion(data, response, error)
            DispatchQueue.main.async {
                completion(result.items, result.error)
            }

        }.resume()

    }

    func fetchProjectDetails(for projectId: String, completion: @escaping (StoreProject?, StoreProjectDownloaderError?) -> Void) {
        guard let indexURL = URL(string: "\(NetworkDefines.apiEndpointProject)/\(projectId)") else { return }

        self.session.dataTask(with: URLRequest(url: indexURL)) { data, response, error in
            let handleDataTaskCompletion: (Data?, URLResponse?, Error?) -> (project: StoreProject?, error: StoreProjectDownloaderError?)
            handleDataTaskCompletion = { data, response, error in
                guard let response = response as? HTTPURLResponse else { return (nil, .unexpectedError) }

                guard let data = data, response.statusCode == 200, error == nil else {
                    let userInfo = ["projectId": projectId,
                                    "url": indexURL.absoluteString,
                                    "statusCode": response.statusCode,
                                    "error": error?.localizedDescription ?? ""] as [String: Any]

                    NotificationCenter.default.post(name: .projectFetchDetailsFailure, object: self, userInfo: userInfo)
                    return (nil, .request(error: error, statusCode: response.statusCode))
                }

                let project: StoreProject?
                do {
                    project = try JSONDecoder().decode(StoreProject.self, from: data)
                } catch {
                    return (nil, .parse(error: error))
                }
                return (project, nil)
            }
            let result = handleDataTaskCompletion(data, response, error)
            DispatchQueue.main.async {
                completion(result.project, result.error)
            }
        }.resume()
    }

    func download(projectId: String, projectName: String, completion: @escaping (Data?, StoreProjectDownloaderError?) -> Void, progression: ((Float) -> Void)?) {
        guard let indexURL = URL(string: "\(NetworkDefines.apiEndpointProject)/\(projectId)/\(NetworkDefines.apiActionDownload)") else { return }
        let task = self.session.dataTask(with: URLRequest(url: indexURL)) { data, response, error in
            let handleDataTaskCompletion: (Data?, URLResponse?, Error?) -> (projectData: Data?, error: StoreProjectDownloaderError?)
            handleDataTaskCompletion = { data, response, error in
                guard let response = response as? HTTPURLResponse else {
                    NotificationCenter.default.post(name: .projectDownloadFailure, object: nil, userInfo: nil)
                    return (nil, .unexpectedError)
                }

                if let error = error as NSError?, error.domain == NSURLErrorDomain && error.code == NSURLErrorTimedOut {
                    return (nil, .timeout)
                }
                if let error = error as NSError?, error.domain == NSURLErrorDomain && error.code == NSURLErrorCancelled {
                    return (nil, .cancelled)
                }

                if let error = error as NSError? {
                    let userInfo = ["projectId": projectId,
                                    "url": indexURL.absoluteString,
                                    "statusCode": response.statusCode,
                                    "error": error.localizedDescription] as [String: Any]

                    NotificationCenter.default.post(name: .projectDownloadFailure, object: self, userInfo: userInfo)
                }

                guard let data = data, response.statusCode == 200, error == nil else {
                    let userInfo = ["projectId": projectId,
                                    "url": indexURL.absoluteString,
                                    "statusCode": response.statusCode,
                                    "error": error?.localizedDescription ?? ""] as [String: Any]

                    NotificationCenter.default.post(name: .projectDownloadFailure, object: self, userInfo: userInfo)
                    return (nil, .request(error: error, statusCode: response.statusCode))
                }

                if let error = error {
                    return (nil, .parse(error: error))
                }

                return (data, nil)
            }

            let result = handleDataTaskCompletion(data, response, error)

            if result.error == nil {
                let fileManagerResult = self.fileManager.storeDownloadedProject(result.projectData, withID: projectId, andName: projectName)

                if !fileManagerResult {
                    DispatchQueue.main.async {
                        completion(nil, .unexpectedError)
                    }
                }
            }

            self.downloadTasks[projectId] = nil

            DispatchQueue.main.async {
                completion(result.projectData, result.error)
            }
        }

        if let progression = progression {
            downloadProjectProgressObserver = task.observe(\.countOfBytesReceived, options: [.new, .initial]) { progress, _ in
                var progress = Float(progress.countOfBytesReceived) / Float(progress.countOfBytesExpectedToReceive)
                if progress.isNaN {
                    progress = 0
                }
                DispatchQueue.main.async {
                    progression(progress)
                }
            }
        }

        self.downloadTasks[projectId] = task
        task.resume()
    }

    @objc(cancelDownloadForProjectWithId:)
    func cancelDownload(for projectId: String) {
        guard let task = self.downloadTasks[projectId] else { return }
        task.cancel()
    }

    @objc static func defaultSession() -> URLSession {
        let config = URLSessionConfiguration.ephemeral
        config.timeoutIntervalForRequest = Double(NetworkDefines.connectionTimeout)
        return URLSession(configuration: config, delegate: nil, delegateQueue: nil)
    }
}
