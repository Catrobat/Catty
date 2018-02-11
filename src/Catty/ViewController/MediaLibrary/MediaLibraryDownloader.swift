/**
 *  Copyright (C) 2010-2018 The Catrobat Team
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
        self.session.dataTask(with: mediaType.indexURL) { data, response, error in

            let handleDataTaskCompletion: (Data?, URLResponse?, Error?) -> (items: [[MediaItem]]?, error: MediaLibraryDownloadError?)
            handleDataTaskCompletion = { data, response, error in
                guard let response = response as? HTTPURLResponse else { return (nil, .unexpectedError) }
                guard let data = data, response.statusCode == 200, error == nil else { return (nil, .request(error: error, statusCode: response.statusCode)) }
                let items: [[MediaItem]]?
                do {
                    items = try JSONDecoder().decode([MediaItem].self, from: data).groupedByCategories
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

    func downloadData(for mediaItem: MediaItem, completion: @escaping (Data?, MediaLibraryDownloadError?) -> Void) {
        self.session.dataTask(with: mediaItem.downloadURL) { data, response, error in
            DispatchQueue.main.async {
                guard let response = response as? HTTPURLResponse else { completion(nil, .unexpectedError); return }
                guard let data = data, response.statusCode == 200, error == nil else {
                    completion(nil, .request(error: error, statusCode: response.statusCode))
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
