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

final class FeaturedProgramsStoreDownloader {

    let session: URLSession
    let kFeaturedProgramsMaxResults = 10

    init(session: URLSession = URLSession.shared) {
        self.session = session
        
        // Example call
        _ = self.fetchKFeaturedPrograms(completion: { (items, error) in
            guard let fetchedPrograms = items, error == nil else { return }
        })
    }
    
    func fetchKFeaturedPrograms(completion: @escaping (FeaturedProgramsCollection?, FeaturedProgramsDownloadError?) -> Void) {

        guard let indexURL = URL(string: "\(kConnectionHost)/\(kConnectionFeatured)?\(kProgramsLimit)\(kFeaturedProgramsMaxResults)") else { return }

        self.session.dataTask(with: indexURL) { (data, response, error) in

            let handleDataTaskCompletion: (Data?, URLResponse?, Error?) -> (items: FeaturedProgramsCollection?, error: FeaturedProgramsDownloadError?)

            handleDataTaskCompletion = { (data, response, error) in
                guard let response = response as? HTTPURLResponse else { return (nil, .unexpectedError) }
                guard let data = data, response.statusCode == 200, error == nil else { return (nil, .request(error: error, statusCode: response.statusCode)) }
                let items: FeaturedProgramsCollection?
                do {
                    items = try JSONDecoder().decode(FeaturedProgramsCollection.self, from: data)
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
}

enum FeaturedProgramsDownloadError: Error {
    /// Indicates an error with the URLRequest.
    case request(error: Error?, statusCode: Int)
    /// Indicates a parsing error of the received data.
    case parse(error: Error)
    /// Indicates an unexpected error.
    case unexpectedError
}
