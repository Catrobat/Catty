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

import Nimble
import XCTest

@testable import Pocket_Code

final class StagePresenterViewControllerTest: XCTestCase {

    var vc: StagePresenterViewControllerMock!
    var skView: SKView!
    var project: Project!
    var navigationController: NavigationControllerMock!
    var projectManager: ProjectManager!

    override func setUp() {
        super.setUp()

        vc = StagePresenterViewControllerMock()
        projectManager = ProjectManager.shared

        navigationController = NavigationControllerMock()
        navigationController.view = UIView()

        skView = SKView(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: 1000, height: 2500)))
        project = projectManager.createProject(name: kDefaultProjectBundleName, projectId: kNoProjectIDYetPlaceholder)
    }

    func testNotification() {
        let expectedNotification = Notification(name: .stagePresenterViewControllerDidAppear, object: vc)

        expect(self.vc.viewDidAppear(true)).to(postNotifications(contain(expectedNotification)))
    }

    func testSetupGridViewPortraitMode() {
        let stagePresenterViewController = vc
        stagePresenterViewController!.project = projectManager.createProject(name: "testProject", projectId: "")
        stagePresenterViewController!.project.header.landscapeMode = false

        stagePresenterViewController!.setUpGridView()
        let gridLabels = stagePresenterViewController!.gridView?.subviews.compactMap { $0 as? UILabel }

        XCTAssertEqual(gridLabels![0].text, "0")
        XCTAssertEqual(gridLabels![1].text, String(project.header.screenWidth.intValue / 2))
        XCTAssertEqual(gridLabels![2].text, String(-project.header.screenWidth.intValue / 2))
        XCTAssertEqual(gridLabels![3].text, String(-project.header.screenHeight.intValue / 2))
        XCTAssertEqual(gridLabels![4].text, String(project.header.screenHeight.intValue / 2))
    }

    func testSetupGridViewLandscapeMode() {
        let stagePresenterViewController = vc
        stagePresenterViewController!.project = projectManager.createProject(name: "testProject", projectId: "")
        stagePresenterViewController!.project.header.landscapeMode = true

        stagePresenterViewController!.setUpGridView()
        let gridLabels = stagePresenterViewController!.gridView?.subviews.compactMap { $0 as? UILabel }

        XCTAssertEqual(gridLabels![0].text, "0")
        XCTAssertEqual(gridLabels![1].text, String(project.header.screenHeight.intValue / 2))
        XCTAssertEqual(gridLabels![2].text, String(-project.header.screenHeight.intValue / 2))
        XCTAssertEqual(gridLabels![3].text, String(-project.header.screenWidth.intValue / 2))
        XCTAssertEqual(gridLabels![4].text, String(project.header.screenWidth.intValue / 2))
    }

    func testCheckResourcesAndPushViewController() {
        CBFileManager.shared()?.addDefaultProjectToProjectsRootDirectoryIfNoProjectsExist()
        Util.setLastProjectWithName(kDefaultProjectBundleName, projectID: kNoProjectIDYetPlaceholder)

        XCTAssertNil(navigationController.currentViewController)
        XCTAssertEqual(0, navigationController.view.subviews.count)
        XCTAssertEqual(0, vc.showLoadingViewCalls)

        vc.checkResourcesAndPushViewController(to: navigationController)

        expect(self.navigationController.currentViewController).toEventually(equal(vc), timeout: .seconds(5))
        expect(self.navigationController.view.subviews.count).toEventually(equal(1), timeout: .seconds(5))
        expect(self.vc.showLoadingViewCalls).toEventually(equal(1), timeout: .seconds(5))
        expect(self.vc.hideLoadingViewCalls).toEventually(equal(0), timeout: .seconds(5))
    }

    func testCheckResourcesAndPushViewControllerInvalidProject() {
        Util.setLastProjectWithName("InvalidProject", projectID: Date().timeIntervalSinceNow.description)

        XCTAssertNil(navigationController.currentViewController)

        vc.checkResourcesAndPushViewController(to: navigationController)

        expect(self.navigationController.currentViewController).toEventually(beNil(), timeout: .seconds(3))
        expect(self.navigationController.view.subviews.count).toEventually(equal(1), timeout: .seconds(3))
        expect(self.vc.showLoadingViewCalls).toEventually(equal(1), timeout: .seconds(3))
        expect(self.vc.hideLoadingViewCalls).toEventually(equal(1), timeout: .seconds(3))
    }

    func testShareDST() {
        let expectedStitch = Stitch(x: 0, y: 1)
        let data = Data()

        let stream = EmbroideryStream(projectWidth: project.header.screenWidth as? CGFloat, projectHeight: project.header.screenHeight as? CGFloat)
        stream.stitches.append(expectedStitch)

        let embroideryServiceMock = EmbroideryServiceMock(outputData: data)

        vc.project = project

        XCTAssertEqual(1, project.allObjects().count)

        let background = project.allObjects().first!
        let backgroundNode = CBSpriteNodeMock(spriteObject: background)
        background.spriteNode = backgroundNode

        let object = SpriteObjectMock(scene: project.scene)
        let objectNode = CBSpriteNodeMock(spriteObject: object)
        objectNode.embroideryStream = stream
        object.spriteNode = objectNode
        project.scene.add(object: object)

        XCTAssertEqual(2, project.allObjects().count)
        XCTAssertNil(vc.latestPresentedViewController)
        XCTAssertNil(embroideryServiceMock.inputStream)

        vc.shareDST(embroideryService: embroideryServiceMock)

        XCTAssertNotNil(embroideryServiceMock.inputStream)
        XCTAssertEqual(1, embroideryServiceMock.inputStream?.stitches.count)
        XCTAssertEqual(expectedStitch.getPosition(), embroideryServiceMock.inputStream?.stitches.first?.getPosition())

        XCTAssertNotNil(vc.latestPresentedViewController as? UIActivityViewController)
    }
}
