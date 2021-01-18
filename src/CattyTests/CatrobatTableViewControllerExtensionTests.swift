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

import Foundation
import XCTest

@testable import Pocket_Code

final class CatrobatTableViewControllerExtensionTests: XCTestCase {

    let testId = "817"
    let testAppProjectUrl = URL(string: "https://share.catrob.at/app/project/817")
    let testAppDownloadUrl = URL(string: "https://share.catrob.at/app/download/817.catrobat?fname=Tic-Tac-Toe%20Master")
    let testPocketcodeProjectUrl = URL(string: "https://share.catrob.at/pocketcode/project/817")
    let testPocketcodeDownloadUrl = URL(string: "https://share.catrob.at/pocketcode/download/817.catrobat?fname=Tic-Tac-Toe%20Master")
    let testInvalidTooShortUrl = URL(string: "https://share.catrob.at/invalid")
    let testInvalidTooLongUrl = URL(string: "https://share.catrob.at/invalid/invalid/invalid/invalid")
    let testInvalidPathUrl = URL(string: "https://share.catrob.at/app/invalid/817")
    var controller: CatrobatTableViewController!
    var navigationControllerMock: NavigationControllerMock!
    var storeProjectDownloaderMock: StoreProjectDownloaderMock!
    var project: StoreProject!

    override func setUp() {
        navigationControllerMock = NavigationControllerMock()
        controller = CatrobatTableViewControllerMock(navigationControllerMock)

        project = StoreProject(projectId: testId,
                               projectName: "",
                               projectNameShort: "",
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
                               featuredImage: "")

        storeProjectDownloaderMock = StoreProjectDownloaderMock()
        storeProjectDownloaderMock.project = project
    }

    func testIdFromURLAppProjectURL() {
        XCTAssertEqual(testId, CatrobatTableViewController.catrobatProjectIdFromURL(url: testAppProjectUrl!))
    }

    func testIdFromURLAppDownloadURL() {
        XCTAssertEqual(testId, CatrobatTableViewController.catrobatProjectIdFromURL(url: testAppDownloadUrl!))
    }

    func testIdFromURLPocketcodeProjectURL() {
        XCTAssertEqual(testId, CatrobatTableViewController.catrobatProjectIdFromURL(url: testPocketcodeProjectUrl!))
    }

    func testIdFromURLPocketcodeDownloadURL() {
        XCTAssertEqual(testId, CatrobatTableViewController.catrobatProjectIdFromURL(url: testPocketcodeDownloadUrl!))
    }

    func testIdFromURLInvalidTooLongURL() {
        XCTAssertNil(CatrobatTableViewController.catrobatProjectIdFromURL(url: testInvalidTooShortUrl!))
    }
    func testIdFromURLInvalidTooShortURL() {
        XCTAssertNil(CatrobatTableViewController.catrobatProjectIdFromURL(url: testInvalidTooLongUrl!))
    }

    func testIdFromURLInvalidPathURL() {
        XCTAssertNil(CatrobatTableViewController.catrobatProjectIdFromURL(url: testInvalidPathUrl!))
    }

    func testOpenURL() {
        let expectation = XCTestExpectation(description: "Fetch project details")
        storeProjectDownloaderMock.expectation = expectation

        controller.openURL(url: testAppDownloadUrl!, storeProjectDownloader: storeProjectDownloaderMock)

        wait(for: [expectation], timeout: 1.0)

        XCTAssertTrue(navigationControllerMock?.currentViewController is ProjectDetailStoreViewController)

        let projectDetailStoreViewController = navigationControllerMock?.currentViewController as! ProjectDetailStoreViewController
        XCTAssertEqual(testId, projectDetailStoreViewController.project.projectID)
    }

    func testOpenURLInvalidURL() {
        controller.openURL(url: testInvalidTooLongUrl!, storeProjectDownloader: storeProjectDownloaderMock)
        XCTAssertNil(navigationControllerMock?.currentViewController)
    }

    func testOpenURLUnableToLoadProject() {
        let expectation = XCTestExpectation(description: "Fetch project details")
        storeProjectDownloaderMock.expectation = expectation
        storeProjectDownloaderMock.error = .unexpectedError

        controller.openURL(url: testAppDownloadUrl!, storeProjectDownloader: storeProjectDownloaderMock)

        wait(for: [expectation], timeout: 1.0)

        XCTAssertNil(navigationControllerMock?.currentViewController)
    }

    func testOpenURLInvalidProject() {
        let expectation = XCTestExpectation(description: "Fetch project details")
        storeProjectDownloaderMock.expectation = expectation
        storeProjectDownloaderMock.project = nil

        controller.openURL(url: testAppDownloadUrl!, storeProjectDownloader: storeProjectDownloaderMock)

        wait(for: [expectation], timeout: 1.0)

        XCTAssertNil(navigationControllerMock?.currentViewController)
    }
}
