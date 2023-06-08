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

protocol MediaLibraryDownloaderProtocol {
    func downloadIndex(for mediaType: MediaType, completion: @escaping ([[MediaItem]]?, MediaLibraryDownloadError?) -> Void)
    func downloadData(for mediaItem: MediaItem, completion: @escaping (Data?, MediaLibraryDownloadError?) -> Void)
}

final class MediaLibraryDownloader: MediaLibraryDownloaderProtocol {

    let session: URLSession

    init(session: URLSession = URLSession.shared) {
        self.session = session
    }

    func downloadIndex(for mediaType: MediaType, completion: @escaping ([[MediaItem]]?, MediaLibraryDownloadError?) -> Void) {
        var indexURLComponents = URLComponents(string: mediaType.indexURLString)
        indexURLComponents?.queryItems = [
            URLQueryItem(name: NetworkDefines.apiParameterLimit, value: String(NetworkDefines.mediaPackageMaxItems)),
            URLQueryItem(name: NetworkDefines.apiParameterOffset, value: String(0)),
            URLQueryItem(name: NetworkDefines.apiParameterAttributes, value: MediaItem.defaultQueryParameters.joined(separator: ","))
        ]

        guard let indexURL = indexURLComponents?.url else {
            completion(nil, .unexpectedError)
            return
        }

        self.session.dataTask(with: URLRequest(url: indexURL)) { data, response, error in

            let handleDataTaskCompletion: (Data?, URLResponse?, Error?) -> (items: [[MediaItem]]?, error: MediaLibraryDownloadError?)
            handleDataTaskCompletion = { data, response, error in
                guard let response = response as? HTTPURLResponse else {
                    let errorInfo = MediaLibraryDownloadFailureInfo(url: indexURL.absoluteString, description: error?.localizedDescription ?? "")
                    NotificationCenter.default.post(name: .mediaLibraryDownloadIndexFailure, object: errorInfo)
                    return (nil, .unexpectedError)
                }
                guard let data = data, response.statusCode == 200, error == nil else {
                    let errorInfo = MediaLibraryDownloadFailureInfo(url: indexURL.absoluteString, statusCode: response.statusCode, description: error?.localizedDescription ?? "")
                    NotificationCenter.default.post(name: .mediaLibraryDownloadIndexFailure, object: errorInfo)
                    return (nil, .request(error: error, statusCode: response.statusCode))
                }
                let items: [[MediaItem]]?
                do {
                    items = try JSONDecoder().decode([MediaItem].self, from: data).groupedByCategories
                } catch {
                    let errorInfo = MediaLibraryDownloadFailureInfo(url: indexURL.absoluteString, statusCode: response.statusCode, description: error.localizedDescription)
                    NotificationCenter.default.post(name: .mediaLibraryDownloadIndexFailure, object: errorInfo)
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

    func downloadData(for mediaItem: MediaItem, completion: @escaping (Data?, MediaLibraryDownloadError?) -> Void) {
        guard let downloadURL = mediaItem.downloadURL else {
            completion(nil, .unexpectedError)
            return
        }
        self.session.dataTask(with: URLRequest(url: downloadURL)) { data, response, error in
            DispatchQueue.main.async {
                guard let response = response as? HTTPURLResponse else {
                    completion(nil, .unexpectedError)
                    let errorInfo = MediaLibraryDownloadFailureInfo(url: downloadURL.absoluteString, description: error?.localizedDescription ?? "")
                    NotificationCenter.default.post(name: .mediaLibraryDownloadDataFailure, object: errorInfo)
                    return
                }
                guard let data = data, response.statusCode == 200, error == nil else {
                    completion(nil, .request(error: error, statusCode: response.statusCode))
                    let errorInfo = MediaLibraryDownloadFailureInfo(url: downloadURL.absoluteString, statusCode: response.statusCode, description: error?.localizedDescription ?? "")
                    NotificationCenter.default.post(name: .mediaLibraryDownloadDataFailure, object: errorInfo)
                    return
                }
                completion(data, nil)
            }
        }.resume()
    }
}

enum MediaLibraryDownloadError: Error {
    /// Indicates an error with the URLRequest.
    case request(error: Error?, statusCode: Int)
    /// Indicates a parsing error of the received data.
    case parse(error: Error)
    /// Indicates an unexpected error.
    case unexpectedError
}

struct MediaLibraryDownloadFailureInfo: Equatable {
    var url: String
    var statusCode: Int?
    var description: String
}
