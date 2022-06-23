/**
 *  Copyright (C) 2010-2022 The Catrobat Team
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
        XCTAssertEqual(catrobatProject.projectID, storeProject.id)
        XCTAssertEqual(catrobatProject.projectName, storeProject.name ?? "")
        XCTAssertEqual(catrobatProject.author, storeProject.author ?? "")
        XCTAssertEqual(catrobatProject.projectDescription, storeProject.description ?? "")
        XCTAssertEqual(catrobatProject.version, storeProject.version ?? "")
        XCTAssertEqual(catrobatProject.views, (storeProject.views as NSNumber?) ?? 0)
        XCTAssertEqual(catrobatProject.downloads, (storeProject.downloads as NSNumber?) ?? 0)
        XCTAssertEqual(catrobatProject.tags, storeProject.tags ?? [String]())
        XCTAssertEqual(catrobatProject.uploaded, String(storeProject.uploaded ?? 0))
        XCTAssertEqual(catrobatProject.screenshotBig, storeProject.screenshotBig ?? "")
        XCTAssertEqual(catrobatProject.screenshotSmall, storeProject.screenshotSmall ?? "")
        XCTAssertEqual(catrobatProject.projectUrl, storeProject.projectUrl ?? "")
        XCTAssertEqual(catrobatProject.downloadUrl, storeProject.downloadUrl ?? "")
        XCTAssertEqual(catrobatProject.size, String(format: "%.1f", storeProject.fileSize ?? 0))
    }

    func testToCatrobatProject() {
        let testProject = StoreProject(
            id: "827",
            name: "Airplane with shadow",
            author: "hej-wickie-hej",
            description: "Fly over wooden floor tiles, steering with your device's inclination.",
            credits: "",
            version: "0.9.5",
            views: 6428,
            downloads: 6796,
            reactions: 9,
            comments: 0,
            isPrivate: false,
            flavor: "pocketcode",
            tags: [],
            uploaded: 1367169365,
            uploadedString: "more than one year ago",
            screenshotBig: "https://share.catrob.at/resources/screenshots/screen_827.png?t=1598101045",
            screenshotSmall: "https://share.catrob.at/resources/thumbnails/screen_827.png?t=1598163726",
            projectUrl: "https://share.catrob.at/app/project/827",
            downloadUrl: "https://share.catrob.at/api/project/827/catrobat",
            fileSize: 1.2287311553955078
        )
        assertAllFieldsEqual(in: testProject.toCatrobatProject(), and: testProject)
    }

    func testToCatrobatProjectWithDefaultValues() {
        let testProject = StoreProject(id: "827")
        assertAllFieldsEqual(in: testProject.toCatrobatProject(), and: testProject)
    }
}
