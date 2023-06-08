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

class ProjectDetailStoreViewControllerExtensionTests: XCTestCase {
    var expectedZippedProjectData: Data!
    var projectDetailStoreVC: ProjectDetailStoreViewController!
    var storeProjectDownloaderMock: StoreProjectDownloaderMock!

    override func setUp() {
        self.storeProjectDownloaderMock = StoreProjectDownloaderMock()

        self.projectDetailStoreVC = ProjectDetailStoreViewController.init()
        self.projectDetailStoreVC.project = CatrobatProject.init()
        self.projectDetailStoreVC.project.projectID = "817"
        self.projectDetailStoreVC.project.projectName = "Tic-Tac-Toe Master"
        self.projectDetailStoreVC.project.projectDescription = "This is a fun game"
        self.projectDetailStoreVC.project.uploaded = "1614680355"
        self.projectDetailStoreVC.project.downloadUrl = "https://web-test.catrob.at/pocketcode/download/817.catrobat"

        self.projectDetailStoreVC.storeProjectDownloader = storeProjectDownloaderMock

        let scrollView = UIScrollView()
        self.projectDetailStoreVC.scrollViewOutlet = scrollView

        self.expectedZippedProjectData = "zippedProjectData".data(using: .utf8)
        self.projectDetailStoreVC.viewDidLoad()
    }

    func testStoreProjectDownloader() {
        let expectation = XCTestExpectation(description: "Download project")
        let projectName = "Tic-Tac-Toe Master"

        storeProjectDownloaderMock.expectation = expectation

        self.projectDetailStoreVC.download(name: projectName)

        wait(for: [expectation], timeout: 1.0)
    }
}
