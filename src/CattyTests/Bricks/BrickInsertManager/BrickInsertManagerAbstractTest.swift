/**
 *  Copyright (C) 2010-2018 The Catrobat Team
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

class BrickInsertManagerAbstractTest: XCTestCase {
    var spriteObject: SpriteObject?
    var startScript: StartScript?
    var viewController: ScriptCollectionViewController?

    override func setUp() {
        super.setUp()
        self.spriteObject = SpriteObject()
        self.spriteObject?.name = "SpriteObject"

        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 100, height: 100)

        viewController = ScriptCollectionViewController(collectionViewLayout: layout)

        XCTAssertNotNil(viewController, "ScriptCollectionViewController must not be nil")

        viewController?.object = spriteObject

        startScript = StartScript()
        startScript?.object = spriteObject

        if let aScript = startScript {
            spriteObject?.scriptList.add(aScript as Any)
        }

        XCTAssertEqual(1, viewController?.collectionView.numberOfSections)
        XCTAssertEqual(1, viewController?.collectionView.numberOfItems(inSection: 0))

        BrickInsertManager.sharedInstance().reset()
    }
}
