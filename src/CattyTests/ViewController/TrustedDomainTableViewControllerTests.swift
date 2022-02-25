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

@testable import Pocket_Code
import XCTest

final class TrustedDomainTableViewControllerTests: XCTestCase {

    var controller: TrustedDomainTableViewController?
    var tableView: UITableView?

    override func setUp() {
        super.setUp()
        controller = TrustedDomainTableViewController()
        tableView = controller?.tableView
        tableView?.dataSource = controller
        UserDefaults.standard.setValue(true, forKey: kUseWebRequestBrick)
        _ = controller?.trustedDomainManager?.add(url: "https://www.testurl.com")
    }

    func testNumberOfTrustedDomainsEqualNumberOfRows() {
        let numberOfRows = controller?.tableView(controller!.tableView, numberOfRowsInSection: 0)
        let numberOfTrustedDomains = controller?.trustedDomainManager?.userTrustedDomains.count ?? 0
        XCTAssertEqual(numberOfRows, numberOfTrustedDomains)
    }

    func testTrustedDomainLabelsEqualTrustedDomains() {
        let numberOfRows = controller?.tableView(controller!.tableView, numberOfRowsInSection: 0) ?? 0
        XCTAssertNotEqual(numberOfRows, 0)

        for rowIndex in 0...(numberOfRows - 1) {
            let label = controller?.tableView(controller!.tableView, cellForRowAt: IndexPath(row: rowIndex, section: 0)).textLabel?.text
            let trustedDomain = controller?.trustedDomainManager?.userTrustedDomains[rowIndex]
            XCTAssertEqual(label, trustedDomain)
        }
    }
}
