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

import XCTest

@testable import Pocket_Code

final class StoreProjectTests: XCTestCase {

    private func assertAllFieldsEqual(in catrobatProject: CatrobatProject, and storeProject: StoreProject) {
        let baseURL = NetworkDefines.baseUrl.replacingOccurrences(of: "/pocketcode/", with: "/")

        XCTAssertEqual(catrobatProject.projectName, storeProject.projectName)
        XCTAssertEqual(catrobatProject.author, storeProject.author)
        XCTAssertEqual(catrobatProject.projectDescription, storeProject.description ?? "")
        XCTAssertEqual(catrobatProject.downloadUrl, baseURL + (storeProject.downloadUrl ?? ""))
        XCTAssertEqual(catrobatProject.downloads, (storeProject.downloads as NSNumber?) ?? 0)
        XCTAssertEqual(catrobatProject.projectID, storeProject.projectId)
        XCTAssertEqual(catrobatProject.projectName, storeProject.projectName)
        XCTAssertEqual(catrobatProject.projectUrl, storeProject.projectUrl ?? "")
        XCTAssertEqual(catrobatProject.screenshotBig, baseURL + (storeProject.screenshotBig ?? ""))
        XCTAssertEqual(catrobatProject.screenshotSmall, baseURL + (storeProject.screenshotSmall ?? ""))
        XCTAssertEqual(catrobatProject.featuredImage, baseURL + (storeProject.featuredImage ?? ""))
        if let uploaded = storeProject.uploaded {
            XCTAssertEqual(catrobatProject.uploaded, String(uploaded))
        } else {
            XCTAssertEqual(catrobatProject.uploaded, "")
        }
        XCTAssertEqual(catrobatProject.version, storeProject.version ?? "")
        XCTAssertEqual(catrobatProject.views, (storeProject.views as NSNumber?) ?? 0)
    }

    func testToCatrobatProject() {
        let testProject = StoreProject(
            projectId: "827",
            projectName: "Airplane with shadow",
            projectNameShort: "Airplane with shadow",
            author: "hej-wickie-hej",
            description: "Fly over wooden floor tiles, steering with your device's inclination.",
            version: "0.9.5",
            views: 6428,
            downloads: 6796,
            uploaded: 1367169365,
            uploadedString: "vor mehr als einem Jahr",
            screenshotBig: "resources/screenshots/screen_827.png",
            screenshotSmall: "resources/thumbnails/screen_827.png",
            projectUrl: "pocketcode/project/827",
            downloadUrl: "pocketcode/download/827.catrobat",
            fileSize: 1.2287311553955078,
            featuredImage: nil
        )
        assertAllFieldsEqual(in: testProject.toCatrobatProject(), and: testProject)
    }
}
