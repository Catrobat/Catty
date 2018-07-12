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
        
        _ = self.downloadKFeaturedPrograms() // Example call
    }
    
    // FIXME: Errors and Return and DispatchQueue.main.async
    // NEXT STEPS: fetch request for the first k featured programs
    func downloadKFeaturedPrograms() {

        guard let indexURL = URL(string: "\(kConnectionHost)/\(kConnectionFeatured)?\(kProgramsLimit)\(kFeaturedProgramsMaxResults)") else { return }

        self.session.dataTask(with: indexURL) { (data, response, error) in
            guard let response = response as? HTTPURLResponse else { return }
            guard let data = data, response.statusCode == 200 else { return }
            var featuredProgramsBaseInformation: FeaturedProgramsBaseInformation
            
            do {
                featuredProgramsBaseInformation = try JSONDecoder().decode(FeaturedProgramsBaseInformation.self, from: data)
            } catch {
                return
            }
        }.resume()
    }
}
