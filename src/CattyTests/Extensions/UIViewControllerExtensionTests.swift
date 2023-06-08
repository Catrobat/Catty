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

import XCTest

@testable import Pocket_Code

final class UIViewControllerExtensionTests: XCTestCase {

    let testId = "817"

    var controllerMock: CatrobatTableViewControllerMock!
    var navigationControllerMock: NavigationControllerMock!
    var storeProjectDownloaderMock: StoreProjectDownloaderMock!
    var project: StoreProject!

    override func setUp() {
        super.setUp()
        navigationControllerMock = NavigationControllerMock()
        controllerMock = CatrobatTableViewControllerMock(navigationControllerMock)

        project = StoreProject(id: testId, name: "")

        storeProjectDownloaderMock = StoreProjectDownloaderMock()
        storeProjectDownloaderMock.project = project
    }

    func testOpenProject() {
        XCTAssertNil(navigationControllerMock.currentViewController)

        let project = ProjectMock()
        let scene = Scene(name: "testScene")
        scene.project = project

        project.scene = scene

        XCTAssertFalse(project.isLastUsedProject)

        controllerMock.openProject(project)

        let sceneTableViewController = navigationControllerMock.currentViewController as? SceneTableViewController

        XCTAssertEqual(scene, sceneTableViewController?.scene)
        XCTAssertEqual(project, sceneTableViewController?.scene.project)
        XCTAssertTrue(project.isLastUsedProject)
    }

    func testOpenProjectDetails() {
        let expectation = XCTestExpectation(description: "Fetch project details")
        storeProjectDownloaderMock.expectation = expectation

        controllerMock.openProjectDetails(projectId: testId, storeProjectDownloader: storeProjectDownloaderMock)

        wait(for: [expectation], timeout: 1.0)

        XCTAssertTrue(navigationControllerMock?.currentViewController is ProjectDetailStoreViewController)

        let projectDetailStoreViewController = navigationControllerMock?.currentViewController as! ProjectDetailStoreViewController
        XCTAssertEqual(testId, projectDetailStoreViewController.project.projectID)
    }

    func testOpenProjectDetailsUnableToLoadProject() {
        let expectation = XCTestExpectation(description: "Fetch project details")
        storeProjectDownloaderMock.expectation = expectation
        storeProjectDownloaderMock.error = .unexpectedError

        controllerMock.openProjectDetails(projectId: testId, storeProjectDownloader: storeProjectDownloaderMock)

        wait(for: [expectation], timeout: 1.0)

        XCTAssertNil(navigationControllerMock.currentViewController)
    }

    func testOpenProjectDetailsInvalidProject() {
        let expectation = XCTestExpectation(description: "Fetch project details")
        storeProjectDownloaderMock.expectation = expectation
        storeProjectDownloaderMock.project = nil

        controllerMock.openProjectDetails(projectId: testId, storeProjectDownloader: storeProjectDownloaderMock)

        wait(for: [expectation], timeout: 1.0)

        XCTAssertNil(navigationControllerMock.currentViewController)
    }
}
