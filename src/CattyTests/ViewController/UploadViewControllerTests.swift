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

class UploadViewControllerTests: XCTestCase {

    var uploadViewController: UploadViewController!
    var uploaderMock: StoreProjectUploaderMock!
    var project: Project!
    var selectedCategoriesValueLabel: UILabel!

    override func setUp() {
        super.setUp()
        self.project = ProjectMock()
        self.project.header.programName = "testProjectName"
        self.selectedCategoriesValueLabel = UILabel()

        self.uploaderMock = StoreProjectUploaderMock()
        self.uploadViewController = UploadViewController(uploader: uploaderMock, project: project, selectCategoriesValueLabel: selectedCategoriesValueLabel)
    }

    func testUploadAction() {
        XCTAssertEqual(0, uploaderMock.timesUploadMethodCalled)
        XCTAssertNil(uploaderMock.projectToUpload)

        uploadViewController.uploadAction()
        XCTAssertEqual(1, uploaderMock.timesUploadMethodCalled)
        XCTAssertEqual(project, uploaderMock.projectToUpload)
    }

    func testFetchTag() {
        XCTAssertEqual(0, uploaderMock.timesFetchTagsMethodCalled)

        uploadViewController.fetchTags()
        XCTAssertEqual(1, uploaderMock.timesFetchTagsMethodCalled)
    }

    func testCatagoriesSelected() {
        XCTAssertNil(selectedCategoriesValueLabel.text)
        XCTAssertNil(project.header.tags)

        uploadViewController.categoriesSelected(tags: [StoreProjectTag]())
        XCTAssertNotNil(selectedCategoriesValueLabel.text)
        XCTAssertEqual(selectedCategoriesValueLabel.text, kLocalizedNoCategoriesSelected)
        XCTAssertTrue(project.header.tags.isEmpty)

        uploadViewController.categoriesSelected(tags: [
            StoreProjectTag(id: "testTag1", text: "Test Tag 1"),
            StoreProjectTag(id: "testTag2", text: "Test Tag 2")
        ])
        XCTAssertNotNil(selectedCategoriesValueLabel.text)
        XCTAssertEqual(selectedCategoriesValueLabel.text, "Test Tag 1, Test Tag 2")
        XCTAssertFalse(project.header.tags.isEmpty)
        XCTAssertEqual(project.header.tags, "testTag1,testTag2")
    }

    func testProjectTag() {
        XCTAssertNil(uploaderMock.projectToUpload?.header.tags)

        uploadViewController.uploadAction()
        XCTAssertNil(uploaderMock.projectToUpload?.header.tags)

        uploadViewController.categoriesSelected(tags: [StoreProjectTag]())
        uploadViewController.uploadAction()
        XCTAssertTrue(uploaderMock.projectToUpload!.header.tags.isEmpty)

        uploadViewController.categoriesSelected(tags: [
            StoreProjectTag(id: "testTag1", text: "Test Tag 1"),
            StoreProjectTag(id: "testTag2", text: "Test Tag 2")
        ])
        uploadViewController.uploadAction()
        XCTAssertFalse(uploaderMock.projectToUpload!.header.tags.isEmpty)
        XCTAssertEqual(uploaderMock.projectToUpload!.header.tags, "testTag1,testTag2")

        uploadViewController.categoriesSelected(tags: [
            StoreProjectTag(id: "testTag1", text: "Test Tag 1"),
            StoreProjectTag(id: "testTag2 with space", text: "Test Tag 2 with space")
        ])
        uploadViewController.uploadAction()
        XCTAssertFalse(uploaderMock.projectToUpload!.header.tags.isEmpty)
        XCTAssertEqual(uploaderMock.projectToUpload!.header.tags, "testTag1,testTag2 with space")
    }
}
