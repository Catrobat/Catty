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

import Nimble
import XCTest

@testable import Pocket_Code

final class ScriptCollectionViewControllerTests: XCTestCase {

    var viewController: ScriptCollectionViewController!
    var navigationController: NavigationControllerMock!
    var storyboard: StoryboardMock!
    var project: Project!
    var scene: Scene!
    var spriteObject: SpriteObject!

    override func setUp() {
        super.setUp()

        project = ProjectMock()

        scene = Scene(name: "testScene")
        scene.project = project

        spriteObject = SpriteObject()
        spriteObject.scene = scene
        scene.add(object: spriteObject)

        navigationController = NavigationControllerMock()
        storyboard = StoryboardMock(viewControllers: ["LooksTableViewController": LooksTableViewController()])

        viewController = ScriptCollectionViewControllerMock(navigationController, storyboard: storyboard)
        viewController.object = spriteObject
    }

    func testUpdateBrickCellDataSavesBroadcastMessage() {
        let broadcastBrick = BroadcastBrick()
        let broadcastBrickCell = BroadcastBrickCell()
        let brickCellMessageData = BrickCellMessageData()

        broadcastBrickCell.scriptOrBrick = broadcastBrick
        broadcastBrickCell.dataDelegate = viewController as? BrickCellDataDelegate
        brickCellMessageData.brickCell = broadcastBrickCell

        broadcastBrickCell.dataDelegate.updateBrickCellData(brickCellMessageData, withValue: "Message1")

        XCTAssertTrue((project.allBroadcastMessages?.contains("Message1"))!)
    }

    func testUpdateBrickCellDataForBackground() {
        let brick = SetBackgroundBrick()
        let brickCell = SetBackgroundBrickCell()
        let brickCellBackgroundData = BrickCellBackgroundData(frame: CGRect.zero, andBrickCell: brickCell, andLineNumber: 0, andParameterNumber: 0)!
        let look = Look(name: "lookA", filePath: "path")

        spriteObject.lookList = [look as Any]

        let spriteObjectB = SpriteObject()
        spriteObjectB.scene = scene

        scene.add(object: spriteObjectB)
        viewController.object = spriteObjectB

        XCTAssertNil(brick.look)

        brickCell.scriptOrBrick = brick
        brickCell.dataDelegate = viewController as? BrickCellDataDelegate
        brickCellBackgroundData.brickCell = brickCell

        brickCell.dataDelegate.updateBrickCellData(brickCellBackgroundData, withValue: look.name)

        XCTAssertEqual(look, brick.look)
    }

    func testUpdateBrickCellDataForNewBackground() {
        let brick = SetBackgroundBrick()
        let brickCell = SetBackgroundBrickCell()
        let brickCellBackgroundData = BrickCellBackgroundData(frame: CGRect.zero, andBrickCell: brickCell, andLineNumber: 0, andParameterNumber: 0)!

        let spriteObjectB = SpriteObject()
        spriteObjectB.scene = scene

        scene.add(object: spriteObjectB)
        viewController.object = spriteObjectB

        brickCell.scriptOrBrick = brick
        brickCell.dataDelegate = viewController as? BrickCellDataDelegate
        brickCellBackgroundData.brickCell = brickCell

        brickCell.dataDelegate.updateBrickCellData(brickCellBackgroundData, withValue: kLocalizedNewElement)

        let looksTableViewController = navigationController.currentViewController as? LooksTableViewController
        XCTAssertEqual(spriteObject, looksTableViewController?.object)
    }

    func testBrickRemovedNotification() {
        let viewController = ScriptCollectionViewController()
        let brickCell = WaitBrickCell()
        brickCell.scriptOrBrick = WaitBrick()

        let collectionView = UICollectionViewMock(cell: brickCell)
        viewController.collectionView = collectionView

        let expectedNotification = Notification(name: .brickRemoved, object: brickCell.scriptOrBrick)
        let path = IndexPath()

        expect(viewController.removeBrickOrScript(brickCell.scriptOrBrick, at: path)).toEventually(postNotifications(contain(expectedNotification)))
    }

    func testCollectionViewCanMoveItemAtIndexPath() {
        let script = StartScript()
        let waitBrick = WaitBrick()
        let noteBrick = NoteBrick()
        script.brickList = [waitBrick, noteBrick]
        spriteObject.scriptList = [script]
        let indexPathWaitBrick = IndexPath(row: 1, section: 0)
        let indexPathNoteBrick = IndexPath(row: 2, section: 0)
        (BrickInsertManager.sharedInstance() as! BrickInsertManager).setBrickInsertionMode(false)
        XCTAssertTrue(viewController.collectionView(viewController.collectionView, canMoveItemAt: indexPathWaitBrick))
        XCTAssertTrue(viewController.collectionView(viewController.collectionView, canMoveItemAt: indexPathNoteBrick))
    }

    func testCollectionViewCanMoveItemAtIndexPathBrickInsertionMode() {
        let script = StartScript()
        let waitBrick = WaitBrick()
        let noteBrick = NoteBrick()
        script.brickList = [waitBrick, noteBrick]
        spriteObject.scriptList = [script]
        let indexPathWaitBrick = IndexPath(row: 1, section: 0)
        let indexPathNoteBrick = IndexPath(row: 2, section: 0)
        waitBrick.isAnimatedInsertBrick = true
        (BrickInsertManager.sharedInstance() as! BrickInsertManager).setBrickInsertionMode(true)
        XCTAssertTrue(viewController.collectionView(viewController.collectionView, canMoveItemAt: indexPathWaitBrick))
        (BrickInsertManager.sharedInstance() as! BrickInsertManager).setBrickInsertionMode(true)
        XCTAssertFalse(viewController.collectionView(viewController.collectionView, canMoveItemAt: indexPathNoteBrick))
    }

    func testCollectionViewCanMoveItemAtIndexPathBrickMoveMode() {
        let script = StartScript()
        let waitBrick = WaitBrick()
        let noteBrick = NoteBrick()
        script.brickList = [waitBrick, noteBrick]
        spriteObject.scriptList = [script]
        let indexPathWaitBrick = IndexPath(row: 1, section: 0)
        let indexPathNoteBrick = IndexPath(row: 2, section: 0)
        waitBrick.isAnimatedMoveBrick = true
        (BrickInsertManager.sharedInstance() as! BrickInsertManager).setBrickInsertionMode(true)
        XCTAssertTrue(viewController.collectionView(viewController.collectionView, canMoveItemAt: indexPathWaitBrick))
        (BrickInsertManager.sharedInstance() as! BrickInsertManager).setBrickInsertionMode(true)
        XCTAssertFalse(viewController.collectionView(viewController.collectionView, canMoveItemAt: indexPathNoteBrick))
    }

    func testCollectionViewCanMoveItemAtIndexPathScriptInsertionMode() {
        let startScript = StartScript()
        let waitBrick = WaitBrick()
        let noteBrick = NoteBrick()
        startScript.brickList = [waitBrick, noteBrick]
        let whenScript = WhenScript()
        spriteObject.scriptList = [startScript, whenScript]
        let indexPathStartScript = IndexPath(row: 0, section: 0)
        let indexPathWhenScript = IndexPath(row: 0, section: 1)
        whenScript.isAnimatedInsertBrick = true
        (BrickInsertManager.sharedInstance() as! BrickInsertManager).setBrickInsertionMode(true)
        XCTAssertFalse(viewController.collectionView(viewController.collectionView, canMoveItemAt: indexPathStartScript))
        (BrickInsertManager.sharedInstance() as! BrickInsertManager).setBrickInsertionMode(true)
        XCTAssertTrue(viewController.collectionView(viewController.collectionView, canMoveItemAt: indexPathWhenScript))
    }
}
