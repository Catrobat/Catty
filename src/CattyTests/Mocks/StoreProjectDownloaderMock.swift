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

@testable import Pocket_Code
import XCTest

final class StoreProjectDownloaderMock: StoreProjectDownloader {

    var progress: Float = 0
    var project: StoreProject?
    var featuredProject: StoreFeaturedProject?
    var projectData: Data?
    var error: StoreProjectDownloaderError?
    var expectation: XCTestExpectation?

    override func download(projectId: String, projectName: String, completion: @escaping (Data?, StoreProjectDownloaderError?) -> Void, progression: ((Float) -> Void)?) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
            completion(self.projectData, self.error)
            self.expectation?.fulfill()

            if let progression = progression {
                progression(self.progress)
            }
        }
    }

    override func fetchSearchQuery(searchTerm: String, completion: @escaping ([StoreProject]?, StoreProjectDownloaderError?) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
            if let project = self.project {
                completion([project], self.error)
            } else {
                completion([StoreProject](), self.error)
            }
            self.expectation?.fulfill()
        }
    }

    override func fetchProjects(for type: ProjectType, offset: Int, completion: @escaping ([StoreProject]?, StoreProjectDownloaderError?) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
            if let project = self.project {
                completion([project], self.error)
            } else {
                completion([StoreProject](), self.error)
            }
            self.expectation?.fulfill()
        }
    }

    override func fetchFeaturedProjects(offset: Int, completion: @escaping ([StoreFeaturedProject]?, StoreProjectDownloaderError?) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
            if let featuredProject = self.featuredProject {
                completion([featuredProject], self.error)
            } else {
                completion([StoreFeaturedProject](), self.error)
            }
            self.expectation?.fulfill()
        }
    }

    override func fetchProjectDetails(for projectId: String, completion: @escaping (StoreProject?, StoreProjectDownloaderError?) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
            completion(self.project, self.error)
            self.expectation?.fulfill()
        }
    }
}
