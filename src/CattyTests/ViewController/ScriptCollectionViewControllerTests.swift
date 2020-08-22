/**
 *  Copyright (C) 2010-2020 The Catrobat Team
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
        let look = Look(name: "lookA", andPath: "path")

        spriteObject.lookList = [look as Any]

        let spriteObjectB = SpriteObject()
        spriteObjectB.scene = scene

        scene.add(object: spriteObjectB)
        viewController.object = spriteObjectB

        XCTAssertNil(brick.look)

        brickCell.scriptOrBrick = brick
        brickCell.dataDelegate = viewController as? BrickCellDataDelegate
        brickCellBackgroundData.brickCell = brickCell

        brickCell.dataDelegate.updateBrickCellData(brickCellBackgroundData, withValue: look!.name)

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
}
