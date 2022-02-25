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

import Foundation
import XCTest

@testable import Pocket_Code

final class CatrobatTableViewControllerExtensionTests: XCTestCase {

    let testId = "817"
    let testAppDownloadUrl = URL(string: "https://share.catrob.at/app/download/817.catrobat?fname=Tic-Tac-Toe%20Master")
    let testInvalidTooLongUrl = URL(string: "https://share.catrob.at/invalid/invalid/invalid/invalid")

    var controller: CatrobatTableViewController!
    var navigationControllerMock: NavigationControllerMock!
    var storeProjectDownloaderMock: StoreProjectDownloaderMock!
    var project: StoreProject!

    override func setUp() {
        navigationControllerMock = NavigationControllerMock()
        controller = CatrobatTableViewControllerMock(navigationControllerMock)

        project = StoreProject(id: testId,
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
                               tags: [""])

        storeProjectDownloaderMock = StoreProjectDownloaderMock()
        storeProjectDownloaderMock.project = project
    }

    func testOpenProjectDetails() {
        let expectation = XCTestExpectation(description: "Fetch project details")
        storeProjectDownloaderMock.expectation = expectation

        controller.openProjectDetails(url: testAppDownloadUrl!, storeProjectDownloader: storeProjectDownloaderMock)

        wait(for: [expectation], timeout: 1.0)

        XCTAssertTrue(navigationControllerMock?.currentViewController is ProjectDetailStoreViewController)

        let projectDetailStoreViewController = navigationControllerMock?.currentViewController as! ProjectDetailStoreViewController
        XCTAssertEqual(testId, projectDetailStoreViewController.project.projectID)
    }

    func testOpenProjectDetailsInvalidURL() {
        controller.openProjectDetails(url: testInvalidTooLongUrl!, storeProjectDownloader: storeProjectDownloaderMock)
        XCTAssertNil(navigationControllerMock?.currentViewController)
    }

    func testOpenProjectDetailsUnableToLoadProject() {
        let expectation = XCTestExpectation(description: "Fetch project details")
        storeProjectDownloaderMock.expectation = expectation
        storeProjectDownloaderMock.error = .unexpectedError

        controller.openProjectDetails(url: testAppDownloadUrl!, storeProjectDownloader: storeProjectDownloaderMock)

        wait(for: [expectation], timeout: 1.0)

        XCTAssertNil(navigationControllerMock?.currentViewController)
    }

    func testOpenProjectDetailsInvalidProject() {
        let expectation = XCTestExpectation(description: "Fetch project details")
        storeProjectDownloaderMock.expectation = expectation
        storeProjectDownloaderMock.project = nil

        controller.openProjectDetails(url: testAppDownloadUrl!, storeProjectDownloader: storeProjectDownloaderMock)

        wait(for: [expectation], timeout: 1.0)

        XCTAssertNil(navigationControllerMock?.currentViewController)
    }
}
