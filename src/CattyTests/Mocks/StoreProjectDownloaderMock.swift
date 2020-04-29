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

@testable import Pocket_Code

final class StoreProjectDownloaderMock: StoreProjectDownloaderProtocol {
    func download(projectId: String, completion: @escaping (Data?, StoreProjectDownloaderError?) -> Void, progression: ((Float) -> Void)?) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
            completion(self.projectData, nil)
            if let progression = progression {
                progression(self.progress)
            }
        }
    }

    var progress: Float = 0
    var project: StoreProject?
    var collectionText: StoreProjectCollection.StoreProjectCollectionText?
    var collectionNumber: StoreProjectCollection.StoreProjectCollectionNumber?
    var projectData: Data?

    func fetchSearchQuery(searchTerm: String, completion: @escaping (StoreProjectCollection.StoreProjectCollectionNumber?, StoreProjectDownloaderError?) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
            completion(self.collectionNumber, nil)
        }
    }

    func fetchProjects(forType: ProjectType, offset: Int, completion: @escaping (StoreProjectCollection.StoreProjectCollectionText?, StoreProjectDownloaderError?) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
            completion(self.collectionText, nil)
        }
    }

    func fetchProjectDetails(for projectId: String, completion: @escaping (StoreProject?, StoreProjectDownloaderError?) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
            completion(self.project, nil)
        }
    }
}
