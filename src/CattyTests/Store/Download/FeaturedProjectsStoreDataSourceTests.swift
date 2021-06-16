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

class FeaturedProjectsStoreDataSourceTests: XCTestCase {

    var downloaderMock: StoreProjectDownloaderMock!
    var tableView: UITableView!

    override func setUp() {
        super.setUp()
        self.downloaderMock = StoreProjectDownloaderMock()
        self.tableView = UITableView(frame: .zero)
    }

    override func tearDown() {
        self.downloaderMock = nil
        self.tableView = nil
        super.tearDown()
    }

    // MARK: - FeaturedProjectsStoreDataSource Tests

    func testProjectsNotFetched() {
        let dataSource = FeaturedProjectsStoreTableDataSource.dataSource(with: self.downloaderMock)
        XCTAssertEqual(dataSource.numberOfRows(in: self.tableView), 0)
    }

    func testProjectEmpty() {
        self.downloaderMock.project = nil

        let dataSource = FeaturedProjectsStoreTableDataSource.dataSource(with: self.downloaderMock)
        let expectation = XCTestExpectation(description: "Fetch items from data source")

        dataSource.fetchItems { [unowned self] error in
            XCTAssertNil(error)
            XCTAssertEqual(dataSource.numberOfRows(in: self.tableView), 0)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1.0)
    }
}
