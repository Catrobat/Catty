/**
 *  Copyright (C) 2010-2019 The Catrobat Team
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

class MediaItemTest: XCTestCase {

    func testGroupedByCategories() {
        let mediaItemA = MediaItem(name: "nameA", fileExtension: "", category: "categoryA", relativePath: "", cachedData: nil)
        let mediaItemB = MediaItem(name: "nameB", fileExtension: "", category: "categoryB", relativePath: "", cachedData: nil)
        let mediaItemC = MediaItem(name: "nameC", fileExtension: "", category: "categoryA", relativePath: "", cachedData: nil)

        XCTAssertNotEqual(mediaItemA.category, mediaItemB.category)
        XCTAssertNotEqual(mediaItemB.category, mediaItemC.category)
        XCTAssertEqual(mediaItemA.category, mediaItemC.category)

        let categories = [mediaItemA, mediaItemB, mediaItemC]
        let groupedByCategories = categories.groupedByCategories
        XCTAssertEqual(2, groupedByCategories.count)

        XCTAssertEqual(2, groupedByCategories[0].count)
        XCTAssertEqual(mediaItemA.name, groupedByCategories[0][0].name)
        XCTAssertEqual(mediaItemC.name, groupedByCategories[0][1].name)

        XCTAssertEqual(1, groupedByCategories[1].count)
        XCTAssertEqual(mediaItemB.name, groupedByCategories[1][0].name)
    }

    func testGroupedByCategoriesSingleItems() {
        let mediaItemA = MediaItem(name: "nameA", fileExtension: "", category: "categoryA", relativePath: "", cachedData: nil)
        let mediaItemB = MediaItem(name: "nameB", fileExtension: "", category: "categoryB", relativePath: "", cachedData: nil)
        let mediaItemC = MediaItem(name: "nameC", fileExtension: "", category: "categoryC", relativePath: "", cachedData: nil)

        XCTAssertNotEqual(mediaItemA.category, mediaItemB.category)
        XCTAssertNotEqual(mediaItemB.category, mediaItemC.category)
        XCTAssertNotEqual(mediaItemA.category, mediaItemC.category)

        let categories = [mediaItemA, mediaItemB, mediaItemC]
        let groupedByCategories = categories.groupedByCategories

        XCTAssertEqual(3, groupedByCategories.count)

        XCTAssertEqual(1, groupedByCategories[0].count)
        XCTAssertEqual(mediaItemA.name, groupedByCategories[0][0].name)

        XCTAssertEqual(1, groupedByCategories[1].count)
        XCTAssertEqual(mediaItemB.name, groupedByCategories[1][0].name)

        XCTAssertEqual(1, groupedByCategories[2].count)
        XCTAssertEqual(mediaItemC.name, groupedByCategories[2][0].name)
    }

    func testGroupedByCategoriesPrioritized() {
        var categories = [MediaItem]()
        XCTAssertTrue(!categories.prioritizedCategories.isEmpty)

        let mediaItemA = MediaItem(name: "nameA", fileExtension: "", category: "categoryA", relativePath: "", cachedData: nil)
        let mediaItemB = MediaItem(name: "nameB", fileExtension: "", category: categories.prioritizedCategories[0], relativePath: "", cachedData: nil)
        let mediaItemC = MediaItem(name: "nameC", fileExtension: "", category: "categoryC", relativePath: "", cachedData: nil)

        XCTAssertNotEqual(mediaItemA.category, mediaItemB.category)
        XCTAssertNotEqual(mediaItemB.category, mediaItemC.category)
        XCTAssertNotEqual(mediaItemA.category, mediaItemC.category)

        categories = [mediaItemA, mediaItemB, mediaItemC]

        let groupedByCategories = categories.groupedByCategories
        XCTAssertEqual(3, groupedByCategories.count)

        XCTAssertEqual(1, groupedByCategories[0].count)
        XCTAssertEqual(mediaItemB.name, groupedByCategories[0][0].name)

        XCTAssertEqual(1, groupedByCategories[1].count)
        XCTAssertEqual(mediaItemA.name, groupedByCategories[1][0].name)

        XCTAssertEqual(1, groupedByCategories[2].count)
        XCTAssertEqual(mediaItemC.name, groupedByCategories[2][0].name)
    }
}
