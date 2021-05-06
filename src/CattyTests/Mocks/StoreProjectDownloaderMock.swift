/**
 *  Copyright (C) 2010-2021 The Catrobat Team
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
import XCTest

final class StoreProjectDownloaderMock: StoreProjectDownloaderProtocol {

    var progress: Float = 0
    var project: StoreProject?
    var featuredProject: StoreFeaturedProject?
    var collectionText: StoreProjectCollection.StoreProjectCollectionText?
    var collectionNumber: StoreProjectCollection.StoreProjectCollectionNumber?
    var projectData: Data?
    var error: StoreProjectDownloaderError?
    var expectation: XCTestExpectation?

    func download(projectId: String, completion: @escaping (Data?, StoreProjectDownloaderError?) -> Void, progression: ((Float) -> Void)?) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
            completion(self.projectData, self.error)
            self.expectation?.fulfill()

            if let progression = progression {
                progression(self.progress)
            }
        }
    }

    func fetchSearchQuery(searchTerm: String, completion: @escaping ([StoreProject]?, StoreProjectDownloaderError?) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
            let projectArrayMock: [StoreProject]? = [self.project ?? StoreProject(id: "",
                                                                                  name: "",
                                                                                  author: "",
                                                                                  description: "",
                                                                                  version: "",
                                                                                  views: 0,
                                                                                  downloads: 0,
                                                                                  uploaded: 0,
                                                                                  uploadedString: "",
                                                                                  screenshotBig: "",
                                                                                  screenshotSmall: "",
                                                                                  projectUrl: "",
                                                                                  downloadUrl: "",
                                                                                  fileSize: 1.0,
                                                                                  tags: [""])] //handle nil project
            completion(projectArrayMock, self.error)
            self.expectation?.fulfill()
        }
    }

    func fetchProjects(for type: ProjectType, offset: Int, completion: @escaping ([StoreProject]?, StoreProjectDownloaderError?) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
            let projectArrayMock: [StoreProject]? = [self.project ?? StoreProject(id: "",
                                                                                  name: "",
                                                                                  author: "",
                                                                                  description: "",
                                                                                  version: "",
                                                                                  views: 0,
                                                                                  downloads: 0,
                                                                                  uploaded: 0,
                                                                                  uploadedString: "",
                                                                                  screenshotBig: "",
                                                                                  screenshotSmall: "",
                                                                                  projectUrl: "",
                                                                                  downloadUrl: "",
                                                                                  fileSize: 1.0,
                                                                                  tags: [""])] //handle nil project
            completion(projectArrayMock, self.error)
            self.expectation?.fulfill()
        }
    }

    func fetchFeaturedProjects(offset: Int, completion: @escaping ([StoreFeaturedProject]?, StoreProjectDownloaderError?) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
            let featuredProjectArrayMock: [StoreFeaturedProject]? = [self.featuredProject ?? StoreFeaturedProject(id: "", url: "", name: "", author: "", featuredImage: "")]

            completion(featuredProjectArrayMock, self.error)
            self.expectation?.fulfill()
        }
    }

    func fetchProjectDetails(for projectId: String, completion: @escaping (StoreProject?, StoreProjectDownloaderError?) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
            completion(self.project, self.error)
            self.expectation?.fulfill()
        }
    }
}
