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

final class BrickCategoryViewControllerTests: XCTestCase {

    var controller: BrickCategoryViewController!
    var collectionView: UICollectionView!
    var brickCell: BrickCell!

    override func setUp() {
        super.setUp()

        let brickCategory = BrickCategory(type: kBrickCategoryType.controlBrick, name: "testCategory", color: UIColor.clear, strokeColor: UIColor.clear)
        let spiteObject = SpriteObject()

        controller = BrickCategoryViewController(brickCategory: brickCategory, andObject: spiteObject)

        brickCell = WaitBrickCell()
        brickCell.scriptOrBrick = WaitBrick()

        collectionView = UICollectionViewMock(cell: brickCell)
        controller!.collectionView = collectionView
    }

    func testBrickSelectedNotification() {
        let expectedNotification = Notification(name: .brickSelected, object: self.brickCell.scriptOrBrick)
        let path = IndexPath()

        expect(self.controller.collectionView(self.collectionView, didSelectItemAt: path)).to(postNotifications(contain(expectedNotification)))
    }
}
