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

protocol StoreProjectDownloaderProtocol {
    func fetchProjects(forType: ProjectType, offset: Int, completion: @escaping (StoreProjectCollection.StoreProjectCollectionText?, StoreProjectDownloaderError?) -> Void)
    func fetchSearchQuery(searchTerm: String, completion: @escaping (StoreProjectCollection.StoreProjectCollectionNumber?, StoreProjectDownloaderError?) -> Void)
    func downloadProject(for project: StoreProject, completion: @escaping (StoreProject?, StoreProjectDownloaderError?) -> Void)
}

final class StoreProjectDownloader: StoreProjectDownloaderProtocol {

    let session: URLSession

    init(session: URLSession = StoreProjectDownloader.defaultSession()) {
        self.session = session
    }

    func fetchSearchQuery(searchTerm: String, completion: @escaping (StoreProjectCollection.StoreProjectCollectionNumber?, StoreProjectDownloaderError?) -> Void) {

        guard let indexURL = URL(string: String(format: "%@/%@?q=%@&%@%i&%@%i&%@%@",
                                                kConnectionHost,
                                                kConnectionSearch,
                                                searchTerm.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) ?? "",
                                                kProjectsLimit,
                                                kSearchStoreMaxResults,
                                                kProjectsOffset,
                                                0,
                                                kMaxVersion,
                                                Util.catrobatLanguageVersion()))
            else { return }

        self.session.dataTask(with: URLRequest(url: indexURL)) { data, response, error in
            let handleDataTaskCompletion: (Data?, URLResponse?, Error?) -> (items: StoreProjectCollection.StoreProjectCollectionNumber?, error: StoreProjectDownloaderError?)
            handleDataTaskCompletion = { data, response, error in
                if let error = error as NSError?, error.domain == NSURLErrorDomain && error.code == NSURLErrorTimedOut {
                    return (nil, .timeout)
                }

                guard let response = response as? HTTPURLResponse else { return (nil, .unexpectedError) }
                guard let data = data, response.statusCode == 200, error == nil else { return (nil, .request(error: error, statusCode: response.statusCode)) }
                let items: StoreProjectCollection.StoreProjectCollectionNumber?
                do {
                    items = try JSONDecoder().decode(StoreProjectCollection.StoreProjectCollectionNumber.self, from: data)
                } catch {
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

    func fetchProjects(forType: ProjectType, offset: Int, completion: @escaping (StoreProjectCollection.StoreProjectCollectionText?, StoreProjectDownloaderError?) -> Void) {

        let indexURL: URL
        let version: String = Util.catrobatLanguageVersion()

        switch forType {
        case .featured:
            guard let url = URL(string: "\(kConnectionHost)/\(kConnectionFeatured)?\(kProjectsLimit)\(kChartProjectsMaxResults)") else { return }
            indexURL = url

        case .mostDownloaded:
            guard let url = URL(string: "\(kConnectionHost)/\(kConnectionMostDownloaded)?\(kProjectsOffset)"
                + "\(offset)&\(kProjectsLimit)\(kRecentProjectsMaxResults)&\(kMaxVersion)\(version)") else { return }
            indexURL = url

        case .mostViewed:
            guard let url = URL(string: "\(kConnectionHost)/\(kConnectionMostViewed)?\(kProjectsOffset)"
                + "\(offset)&\(kProjectsLimit)\(kRecentProjectsMaxResults)&\(kMaxVersion)\(version)") else { return }
            indexURL = url

        case .mostRecent:
            guard let url = URL(string: "\(kConnectionHost)/\(kConnectionRecent)?\(kProjectsOffset)"
                + "\(offset)&\(kProjectsLimit)\(kRecentProjectsMaxResults)&\(kMaxVersion)\(version)") else { return }
            indexURL = url
        }

        self.session.dataTask(with: URLRequest(url: indexURL)) { data, response, error in
            let handleDataTaskCompletion: (Data?, URLResponse?, Error?) -> (items: StoreProjectCollection.StoreProjectCollectionText?, error: StoreProjectDownloaderError?)
            handleDataTaskCompletion = { data, response, error in
                if let error = error as NSError?, error.domain == NSURLErrorDomain && error.code == NSURLErrorTimedOut {
                    return (nil, .timeout)
                }

                guard let response = response as? HTTPURLResponse else { return (nil, .unexpectedError) }
                guard let data = data, response.statusCode == 200, error == nil else {
                    return (nil, .request(error: error, statusCode: response.statusCode))
                }
                let items: StoreProjectCollection.StoreProjectCollectionText?
                do {
                    items = try JSONDecoder().decode(StoreProjectCollection.StoreProjectCollectionText.self, from: data)
                } catch {
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

    func downloadProject(for project: StoreProject, completion: @escaping (StoreProject?, StoreProjectDownloaderError?) -> Void) {
        guard let indexURL = URL(string: "\(kConnectionHost)/\(kConnectionIDQuery)?id=\(project.projectId)") else { return }

        self.session.dataTask(with: URLRequest(url: indexURL)) { data, response, error in
            let handleDataTaskCompletion: (Data?, URLResponse?, Error?) -> (project: StoreProject?, error: StoreProjectDownloaderError?)
            handleDataTaskCompletion = { data, response, error in
                guard let response = response as? HTTPURLResponse else { return (nil, .unexpectedError) }
                guard let data = data, response.statusCode == 200, error == nil else { return (nil, .request(error: error, statusCode: response.statusCode)) }

                let collection: StoreProjectCollection.StoreProjectCollectionNumber?
                do {
                    collection = try JSONDecoder().decode(StoreProjectCollection.StoreProjectCollectionNumber.self, from: data)
                } catch {
                    return (nil, .parse(error: error))
                }
                return (collection?.projects.first, nil)
            }
            let result = handleDataTaskCompletion(data, response, error)
            DispatchQueue.main.async {
                completion(result.project, result.error)
            }
        }.resume()
    }

    static func defaultSession() -> URLSession {
        let config = URLSessionConfiguration.ephemeral
        config.timeoutIntervalForRequest = Double(kConnectionTimeout)
        return URLSession(configuration: config, delegate: nil, delegateQueue: nil)
    }
}

enum StoreProjectDownloaderError: Error {
    /// Indicates an error with the URLRequest.
    case request(error: Error?, statusCode: Int)
    /// Indicates a parsing error of the received data.
    case parse(error: Error)
    /// Indicates a server timeout.
    case timeout
    /// Indicates an unexpected error.
    case unexpectedError
}

enum ProjectType {
    case featured
    case mostDownloaded
    case mostViewed
    case mostRecent
}
