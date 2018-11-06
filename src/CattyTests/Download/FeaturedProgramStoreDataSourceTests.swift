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

import XCTest
@testable import Pocket_Code

class FeaturedProgramsStoreDataSourceTests: XCTestCase {

    var downloaderMock: StoreProgramDownloaderMock!
    var tableView: UITableView!

    override func setUp() {
        super.setUp()
        self.downloaderMock = StoreProgramDownloaderMock()
        self.tableView = UITableView(frame: .zero)
    }

    override func tearDown() {
        self.downloaderMock = nil
        self.tableView = nil
        super.tearDown()
    }

    // MARK: - FeaturedProgramsStoreDataSource Tests

    func testProgramsNotFetched() {
        let dataSource = FeaturedProgramsStoreTableDataSource.dataSource(with: self.downloaderMock)
        XCTAssertEqual(dataSource.numberOfRows(in: self.tableView), 0)
    }

    func testProgramEmpty() {
        self.downloaderMock.program =
            StoreProgram(projectId: 0, projectName: "", projectNameShort: "", author: "",
                         description: "", version: "", views: 0, downloads: 0, isPrivate: false,
                         uploaded: 0, uploadedString: "", screenshotBig: "", screenshotSmall: "",
                         projectUrl: "", downloadUrl: "", fileSize: 1.0, featuredImage: "")

        let dataSource = FeaturedProgramsStoreTableDataSource.dataSource(with: self.downloaderMock)
        let expectation = XCTestExpectation(description: "Fetch items from data source")

        dataSource.fetchItems { [unowned self] error in
            XCTAssertNil(error)
            XCTAssertEqual(dataSource.numberOfRows(in: self.tableView), 0)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1.0)
    }
}
