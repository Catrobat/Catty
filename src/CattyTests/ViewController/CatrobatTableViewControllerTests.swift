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

final class CatrobatTableViewControllerTests: XCTestCase {

    var controller: CatrobatTableViewController?
    var navigationController: NavigationControllerMock?

    override func setUp() {
        super.setUp()
        navigationController = NavigationControllerMock()
        controller = CatrobatTableViewControllerMock(navigationController!)

        XCTAssertNil(navigationController!.currentViewController)
    }

    func testShowPrivacyPolicyShowHasNotBeenShownAndDoNotShowOnEveryLaunch() {
        PrivacyPolicyViewController.hasBeenShown = false
        PrivacyPolicyViewController.showOnEveryLaunch = false

        controller?.viewDidLoad()
        XCTAssertTrue(navigationController?.currentViewController is PrivacyPolicyViewController)
    }

    func testDoNotShowPrivacyPolicyHasBeenShownAndDoNotShowOnEveryLaunch() {
        PrivacyPolicyViewController.hasBeenShown = true
        PrivacyPolicyViewController.showOnEveryLaunch = false

        XCTAssertNil(navigationController?.currentViewController)

        controller?.viewDidLoad()
        XCTAssertNil(navigationController!.currentViewController)
    }

    func testShowPrivacyPolicyShowHasNotBeenShownAndDoShowOnEveryLaunch() {
        PrivacyPolicyViewController.hasBeenShown = false
        PrivacyPolicyViewController.showOnEveryLaunch = true

        controller?.viewDidLoad()
        XCTAssertTrue(navigationController?.currentViewController is PrivacyPolicyViewController)
    }

    func testShowPrivacyPolicyShowHasBeenShownAndDoShowOnEveryLaunch() {
        PrivacyPolicyViewController.hasBeenShown = true
        PrivacyPolicyViewController.showOnEveryLaunch = true

        controller?.viewDidLoad()
        XCTAssertTrue(navigationController?.currentViewController is PrivacyPolicyViewController)
    }
}
