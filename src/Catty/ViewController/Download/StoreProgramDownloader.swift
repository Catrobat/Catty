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

protocol StoreProgramDownloaderProtocol {
    func fetchPrograms(forType: ProgramType, completion: @escaping (StoreProgramCollection.StoreProgramCollectionText?, StoreProgramDownloaderError?) -> Void)
    func downloadProgram(for program: StoreProgram, completion: @escaping (StoreProgram?, StoreProgramDownloaderError?) -> Void)
}

final class StoreProgramDownloader: StoreProgramDownloaderProtocol {
    
    let session: URLSession
    var programListOffset: Int
    
    init(session: URLSession = URLSession.shared) {
        self.session = session
        self.programListOffset = 0
    }
    
    func fetchPrograms(forType: ProgramType, completion: @escaping (StoreProgramCollection.StoreProgramCollectionText?, StoreProgramDownloaderError?) -> Void) {
        
        let indexURL: URL
        let version: String = Util.catrobatLanguageVersion()
        
        switch forType {
        case .featured:
            guard let url = URL(string: "\(kConnectionHost)/\(kConnectionFeatured)?\(kProgramsLimit)\(kFeaturedProgramsMaxResults)") else { return }
            indexURL = url
            
        case .mostDownloaded:
            guard let url = URL(string: "\(kConnectionHost)/\(kConnectionMostDownloaded)?\(kProgramsOffset)\(programListOffset)\(kProgramsLimit)\(kRecentProgramsMaxResults)&\(kMaxVersion)\(version)") else { return }
            indexURL = url
            
        case .mostViewed:
            guard let url = URL(string: "\(kConnectionHost)/\(kConnectionMostViewed)?\(kProgramsOffset)\(programListOffset)\(kProgramsLimit)\(kRecentProgramsMaxResults)&\(kMaxVersion)\(version)") else { return }
            indexURL = url
            
        case .mostRecent:
            guard let url = URL(string: "\(kConnectionHost)/\(kConnectionRecent)?\(kProgramsOffset)\(programListOffset)\(kProgramsLimit)\(kRecentProgramsMaxResults)&\(kMaxVersion)\(version)") else { return }
            indexURL = url
        }
        
        let timer = TimerWithBlock(timeInterval: TimeInterval(kConnectionTimeout), repeats: false) { timer in
            completion(nil, .timeout)
            timer.invalidate()
        }
        
        self.session.dataTask(with: indexURL) { (data, response, error) in
            
            guard timer.isValid else { return }
            let handleDataTaskCompletion: (Data?, URLResponse?, Error?) -> (items: StoreProgramCollection.StoreProgramCollectionText?, error: StoreProgramDownloaderError?)
            handleDataTaskCompletion = { (data, response, error) in
                timer.invalidate()
                guard let response = response as? HTTPURLResponse else { return (nil, .unexpectedError) }
                guard let data = data, response.statusCode == 200, error == nil else { return (nil, .request(error: error, statusCode: response.statusCode)) }
                let items: StoreProgramCollection.StoreProgramCollectionText?
                do {
                    items = try JSONDecoder().decode(StoreProgramCollection.StoreProgramCollectionText.self, from: data)
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
    
    func downloadProgram(for program: StoreProgram, completion: @escaping (StoreProgram?, StoreProgramDownloaderError?) -> Void) {
        guard let indexURL = URL(string: "\(kConnectionHost)/\(kConnectionIDQuery)?id=\(program.projectId)") else { return }
        
        self.session.dataTask(with: indexURL) { (data, response, error) in
            let handleDataTaskCompletion: (Data?, URLResponse?, Error?) -> (program: StoreProgram?, error: StoreProgramDownloaderError?)
            handleDataTaskCompletion = { (data, response, error) in
                guard let response = response as? HTTPURLResponse else { return (nil, .unexpectedError) }
                guard let data = data, response.statusCode == 200, error == nil else { return (nil, .request(error: error, statusCode: response.statusCode)) }
                
                let collection: StoreProgramCollection.StoreProgramCollectionNumber?
                do {
                    collection = try JSONDecoder().decode(StoreProgramCollection.StoreProgramCollectionNumber.self, from: data)
                } catch {
                    return (nil, .parse(error: error))
                }
                return (collection?.projects.first, nil)
            }
            let result = handleDataTaskCompletion(data, response, error)
            DispatchQueue.main.async {
                completion(result.program, result.error)
            }
            }.resume()
    }
}

enum StoreProgramDownloaderError: Error {
    /// Indicates an error with the URLRequest.
    case request(error: Error?, statusCode: Int)
    /// Indicates a parsing error of the received data.
    case parse(error: Error)
    /// Indicates a server timeout.
    case timeout
    /// Indicates an unexpected error.
    case unexpectedError
}

enum ProgramType {
    case featured
    case mostDownloaded
    case mostViewed
    case mostRecent
}

