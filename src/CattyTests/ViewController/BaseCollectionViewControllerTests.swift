/**
 *  Copyright (C) 2010-2024 The Catrobat Team
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

import Nimble
import XCTest

@testable import Pocket_Code

final class BaseTableViewControllerTests: XCTestCase {

    var baseTableViewControllerMock: BaseTableViewControllerMock!
    var project: Project!
    var projectManager: ProjectManager!

    override func setUp() {
        super.setUp()

        baseTableViewControllerMock = BaseTableViewControllerMock()

        let stagePresenterViewControllerMock = StagePresenterViewControllerMock()
        baseTableViewControllerMock.setStagePresenter(stagePresenterViewControllerMock)
        projectManager = ProjectManager.shared

        project = projectManager.createProject(name: kDefaultProjectBundleName, projectId: kNoProjectIDYetPlaceholder)
        stagePresenterViewControllerMock.stageManager = StageManager(project: project)
    }

    func testNotification() {
        let controller = BaseTableViewController()
        let expectedNotification = Notification(name: .baseTableViewControllerDidAppear, object: controller)

        expect(controller.viewDidAppear(true)).to(postNotifications(contain(expectedNotification)))
    }

    func testPlaySceneAction() {
        CBFileManager.shared()?.deleteAllFilesInDocumentsDirectory()
        CBFileManager.shared()?.addDefaultProjectToProjectsRootDirectoryIfNoProjectsExist()
        Util.setLastProjectWithName(kDefaultProjectBundleName, projectID: kNoProjectIDYetPlaceholder)

        baseTableViewControllerMock.playSceneAction(UIButton())

        expect(self.baseTableViewControllerMock.showLoadingViewCalls).toEventually(equal(1), timeout: .seconds(3))
        expect(self.baseTableViewControllerMock.hideLoadingViewCalls).toEventually(equal(1), timeout: .seconds(3))
    }

    func testPlaySceneActionInvalidProject() {
        Util.setLastProjectWithName("InvalidProject", projectID: Date().timeIntervalSinceNow.description)

        baseTableViewControllerMock.playSceneAction(UIButton())

        expect(self.baseTableViewControllerMock.showLoadingViewCalls).toEventually(equal(1), timeout: .seconds(3))
        expect(self.baseTableViewControllerMock.hideLoadingViewCalls).toEventually(equal(1), timeout: .seconds(3))
    }
}
