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

    var layout: UICollectionViewFlowLayout!
    var viewController: ScriptCollectionViewController!
    var project: Project!
    var broadcastBrick: BroadcastBrick!
    var spriteObject: SpriteObject!
    var broadcastBrickCell: BroadcastBrickCell!
    var brickCellMessageData: BrickCellMessageData!

    override func setUp() {
        super.setUp()

        project = ProjectMock()
        layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 100, height: 100)
        viewController = ScriptCollectionViewController(collectionViewLayout: layout)
        XCTAssertNotNil(viewController, "ScriptCollectionViewController must not be nil")
    }

    func testUpdateBrickCellDataSavesBroadcastMessage() {
        spriteObject = SpriteObject()
        broadcastBrick = BroadcastBrick()
        broadcastBrickCell = BroadcastBrickCell()
        brickCellMessageData = BrickCellMessageData()
        viewController.object = spriteObject
        spriteObject.project = project
        broadcastBrickCell.scriptOrBrick = broadcastBrick
        broadcastBrickCell.dataDelegate = viewController as? BrickCellDataDelegate
        brickCellMessageData.brickCell = broadcastBrickCell

        broadcastBrickCell.dataDelegate.updateBrickCellData(brickCellMessageData, withValue: "Message1")

        XCTAssertTrue((project.allBroadcastMessages?.contains("Message1"))!)
    }
}
