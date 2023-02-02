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

@testable import Pocket_Code
import XCTest

//into eine datei
class ProjectDetailStoreViewControllerTests: XCTestCase {
    let testId = "817"

    var controllerMock: CatrobatTableViewControllerMock!
    var navigationControllerMock: NavigationControllerMock!
    var storeProjectDownloaderMock: StoreProjectDownloaderMock!
    var project: StoreProject!

    var expectedZippedProjectData: Data!
    var projectDetailStoreVC: ProjectDetailStoreViewController!

    override func setUp() {
        super.setUp()
        navigationControllerMock = NavigationControllerMock()
        controllerMock = CatrobatTableViewControllerMock(navigationControllerMock)

        project = StoreProject(id: testId, name: "")

        expectedZippedProjectData = "zippedProjectData".data(using: .utf8)
        storeProjectDownloaderMock = StoreProjectDownloaderMock()
        storeProjectDownloaderMock.project = project

        projectDetailStoreVC = ProjectDetailStoreViewController.init()
        projectDetailStoreVC.project = CatrobatProject.init()
        projectDetailStoreVC.project!.projectID = "817"
        projectDetailStoreVC.project!.projectName = "Tic-Tac-Toe Master"
        projectDetailStoreVC.project!.projectDescription = "This is a fun game"
        projectDetailStoreVC.project!.uploaded = "1614680355"
        projectDetailStoreVC.project!.downloadUrl = "https://web-test.catrob.at/pocketcode/download/817.catrobat"

        projectDetailStoreVC.storeProjectDownloader = storeProjectDownloaderMock

        let scrollView = UIScrollView()
        projectDetailStoreVC.setScrollViewOutlet(scrollView)

        expectedZippedProjectData = "zippedProjectData".data(using: .utf8)
        projectDetailStoreVC.viewDidLoad()
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
        XCTAssertEqual(testId, projectDetailStoreViewController.project!.projectID)
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

    func testStoreProjectDownloader() {
        let expectation = XCTestExpectation(description: "Download project")
        let projectName = "Tic-Tac-Toe Master"

        storeProjectDownloaderMock.expectation = expectation

        self.projectDetailStoreVC.download(name: projectName)

        wait(for: [expectation], timeout: 1.0)
    }
}
